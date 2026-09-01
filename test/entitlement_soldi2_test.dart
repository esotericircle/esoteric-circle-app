import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/ritual_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/feature_flags/feature_catalog.dart';
import 'package:esoteric_circle/core/feature_flags/feature_flag.dart';
import 'package:esoteric_circle/core/santuario/function_shelf.dart';
import 'package:flutter_test/flutter_test.dart';

/// Le altre quattro voci sui soldi.
void main() {
  group('V3, la Profonda deve aprirsi a chi ha pagato', () {
    test('Nessuno passa mai premiumUnlocked, quindi resta chiusa per tutti',
        () {
      // Il difetto e' strutturale, quindi si misura sul sorgente: se nessun
      // punto dell'app passa quel parametro, la voce Profonda e' chiusa
      // anche a chi l'ha comprata, e nessun test di widget potrebbe vederlo
      // perche' non esiste una schermata dove sia aperta.
      final montaggi = <String>[];
      for (final f in Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))) {
        final src = f.readAsStringSync();
        if (!src.contains('AnswerDepthSelector(')) continue;
        if (f.path.endsWith('answer_depth.dart')) continue;
        montaggi.add(f.path);
        expect(src.contains('premiumUnlocked'), isTrue,
            reason: '${f.path} monta il selettore senza dire se la persona '
                'ha pagato: la Profonda resta col lucchetto per tutti');
      }
      expect(montaggi, isNotEmpty,
          reason: 'nessuno monta il selettore: il test non misura niente');
    });

    test('Il diritto alla Profonda si legge dalla matrice, non a mano', () {
      // Il Viandante ha l'oroscopo Base, gli altri Dettagliato: la matrice lo
      // dice gia', quindi nessuno deve riscrivere la regola altrove.
      expect(PlanCatalog.haProfondita(Tier.free), isFalse);
      expect(PlanCatalog.haProfondita(Tier.tier1), isTrue);
      expect(PlanCatalog.haProfondita(Tier.tier2), isTrue);
      expect(PlanCatalog.haProfondita(Tier.tier3), isTrue);
    });
  });

  group('V5, l\'invito non promette cio\' che il piano non da\'', () {
    test('Per ogni piano l\'invito dichiara il limite vero di quel piano', () {
      for (final t in [Tier.tier1, Tier.tier2, Tier.tier3]) {
        final testo = PlanCatalog.promessaDomande(t);
        final limite =
            PlanCatalog.limiteGiornaliero(PlanCatalog.rigaDomande, t);
        if (limite == null) {
          expect(testo.toLowerCase(), contains('senza limiti'),
              reason: 'il piano $t e\' illimitato e l\'invito non lo dice');
        } else {
          expect(testo, contains('$limite'),
              reason: 'per il piano $t l\'invito dice "$testo" mentre il '
                  'limite vero e\' $limite al giorno');
          expect(testo.toLowerCase().contains('senza limiti'), isFalse,
              reason: 'per il piano $t si promettono domande senza limiti, '
                  'mentre ne da\' $limite');
        }
      }
    });
  });

  group('V6, i feature flag devono governare e concordare', () {
    test('Il catalogo dei flag e il manifest dicono la stessa cosa', () {
      final manifest =
          jsonDecode(File('docs/stato_funzioni.json').readAsStringSync())
              as Map<String, dynamic>;
      final funzioni = (manifest['funzioni'] as Map).cast<String, dynamic>();

      final scostamenti = <String>[];
      for (final f in FeatureCatalog.all) {
        if (!funzioni.containsKey(f.id)) continue;
        final vivaNelManifest = funzioni[f.id] == true;
        final vivaNelCatalogo =
            f.defaultAvailability == RemoteAvailability.enabled;
        if (vivaNelManifest != vivaNelCatalogo) {
          scostamenti.add('${f.id}: manifest ${funzioni[f.id]}, '
              'catalogo ${f.defaultAvailability.name}');
        }
      }
      expect(scostamenti, isEmpty,
          reason: 'le due fonti si contraddicono:\n${scostamenti.join('\n')}');
    });

    test('Ogni voce dello scaffale ha la sua definizione nel catalogo', () {
      final mancanti = <String>[];
      for (final fn in FunctionShelf.functions) {
        if (!FeatureCatalog.all.any((f) => f.id == fn.id)) {
          mancanti.add(fn.id);
        }
      }
      expect(mancanti, isEmpty,
          reason: 'nello scaffale ci sono funzioni che il catalogo dei flag '
              'non conosce: ${mancanti.join(', ')}');
    });
  });

  group('V7, i limiti di sinastria e tarocchi esistono', () {
    test('La matrice li promette, quindi il codice li sa leggere', () {
      // Tre sinastrie e una carta al giorno per il Viandante: sono promesse
      // scritte nella matrice, e finche' nessuno le legge sono regali.
      expect(
          PlanCatalog.limiteGiornaliero(PlanCatalog.rigaSinastria, Tier.free),
          3);
      expect(
          PlanCatalog.limiteGiornaliero(
              PlanCatalog.rigaCartaSingola, Tier.free),
          1);
      // **NON PIU" + E + " ILLIMITATI, ordine CE voce 08.** L\'Adepto ha trenta
      // carte singole al giorno e l\'Illuminato cinquanta: numeri ampi, ma
      // numeri.
      expect(
          PlanCatalog.limiteGiornaliero(
              PlanCatalog.rigaCartaSingola, Tier.tier2),
          30,
          reason: 'il tetto delle carte singole dell\'Adepto e\' cambiato');
    });

    test('Il contatore rifiuta oltre soglia e si azzera col giorno', () {
      var giorno = DateTime(2026, 7, 30, 10);
      final c = RitualAllowance(clock: () => giorno);

      for (var i = 0; i < 3; i++) {
        expect(c.puo(RitualQuota.sinastria, Tier.free), isTrue);
        c.registra(RitualQuota.sinastria, Tier.free);
      }
      expect(c.puo(RitualQuota.sinastria, Tier.free), isFalse,
          reason: 'la quarta sinastria del Viandante passa lo stesso');

      expect(c.puo(RitualQuota.cartaSingola, Tier.free), isTrue);
      c.registra(RitualQuota.cartaSingola, Tier.free);
      expect(c.puo(RitualQuota.cartaSingola, Tier.free), isFalse,
          reason: 'la seconda estrazione dello stesso giorno passa lo stesso');

      // Il giorno rituale nuovo azzera tutto.
      giorno = DateTime(2026, 7, 31, 10);
      expect(c.puo(RitualQuota.sinastria, Tier.free), isTrue);
      expect(c.puo(RitualQuota.cartaSingola, Tier.free), isTrue);

      // Chi ha l'illimitato non incontra mai un muro.
      for (var i = 0; i < 20; i++) {
        expect(c.puo(RitualQuota.sinastria, Tier.tier3), isTrue);
        c.registra(RitualQuota.sinastria, Tier.tier3);
      }
    });
  });
}
