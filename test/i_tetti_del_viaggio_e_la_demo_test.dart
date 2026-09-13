import 'dart:io';

import 'package:esoteric_circle/core/config/app_flags.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/viaggio/diario_dei_viaggi.dart';
import 'package:esoteric_circle/core/viaggio/tetti_del_viaggio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';

/// **I TETTI PER PIANO, E LA DEMO SENZA LIMITI.**
/// Ordine DE voce 14, 11 settembre 2026.
///
/// **LA GUARDIA CHE L'ORDINE CHIEDE, parola per parola**: *"con la chiave
/// spenta i quattro tetti sono quelli dichiarati e la rivelazione resta una al
/// giorno; con la chiave accesa nessun limite risponde"*.
///
/// **E UNA TERZA META' che l'ordine non chiede e che serve lo stesso**: la
/// rivelazione **non si compra**. Un tetto che si puo' superare pagando non e'
/// un metodo, e la voce DE.14 dice perche': *"se un pagante puo' fare i quattro
/// viaggi in dieci minuti, l'incontro con il proprio animale diventa una
/// schermata di caricamento"*.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('CHIAVE SPENTA, i tetti sono quelli dichiarati', () {
    // **DALL'ORDINE DI VOCE 15 I TETTI SONO 1, 1, 1 e 2**, e stanno nella
    // matrice dei piani: erano 1, 3, 7 e 20, in una mappa di questo file.
    test('I QUATTRO TETTI DOPO LA RIVELAZIONE SONO 1, 1, 1 e 2', () {
      final letti = <String, int?>{
        for (final t in Tier.values)
          t.label: TettiDelViaggio.quanteAlGiorno(
              giaRiconosciuto: true, tier: t, demo: false),
      };
      // ignore: avoid_print
      print('ORDINE DE VOCE 14: coi limiti accesi i tetti per piano sono '
          '$letti');
      expect(letti, {
        'Free': 1,
        'Tier 1': 1,
        'Tier 2': 1,
        'Tier 3': 2,
      });
      // **IL CARDINALE**: quattro piani, quattro tetti, e nessuno a zero. Se
      // un quinto piano nascesse senza la sua cella, varrebbe zero.
      expect(Tier.values.where((t) => TettiDelViaggio.discesePerIlPiano(t) < 1),
          isEmpty,
          reason: 'ci sono piani senza discese nella matrice');
    });

    test('LA RIVELAZIONE E UNA AL GIORNO PER TUTTI, anche per il piu alto', () {
      for (final t in Tier.values) {
        final tetto = TettiDelViaggio.quanteAlGiorno(
            giaRiconosciuto: false, tier: t, demo: false);
        expect(tetto, 1,
            reason: 'col piano ${t.label} le discese del riconoscimento al '
                'giorno sono $tetto: il pagante fa i quattro viaggi in dieci '
                'minuti e l incontro diventa una schermata di caricamento');
      }
      // ignore: avoid_print
      print('ORDINE DE VOCE 14: prima della rivelazione tutti e '
          '${Tier.values.length} i piani hanno lo stesso tetto, '
          '${TettiDelViaggio.discesePrimaDellaRivelazione}');
    });

    // **E DALL'ORDINE DI VOCE 15 NON SI COMPRA NEMMENO DOPO.** Qui la prova
    // chiamava `siPuoComprareAncora`, una funzione che tornava sempre falso e
    // che nessuna strada dell'app chiamava: tolta con l'ordine DJ voce 05. La
    // regola si sorveglia dove una discesa si potrebbe vendere davvero: il
    // listino del riscatto sul server, che vende soltanto i budget del tipo
    // `Budget`, e le porte che spendono gli Eos, che nessun file del Viaggio
    // deve toccare.
    test(
        'LA RIVELAZIONE NON SI COMPRA CON GLI EOS, e nemmeno le discese dopo: '
        'il listino non ha un budget per le discese, e il Viaggio non tocca le '
        'porte che spendono', () {
      final budget = File('functions/src/budget.ts').readAsStringSync();
      final elenco = RegExp(r'export const BUDGET: Budget\[\] = \[([^\]]*)\]')
          .firstMatch(budget);
      expect(elenco, isNotNull,
          reason: 'l\'elenco dei budget del server non si trova piu\'');
      final voci = RegExp(r'"([a-z_]+)"')
          .allMatches(elenco!.group(1)!)
          .map((m) => m.group(1)!)
          .toList();
      cardinaleMinimo(voci.length, 6,
          cosa: 'budget del server',
          perche: 'Su un listino vuoto nessuna discesa sarebbe in vendita.');
      final inVendita = voci
          .where((v) => RegExp('disces|viagg|rivelaz|segn').hasMatch(v))
          .toList();
      final file = [
        for (final cartella in [
          'lib/core/viaggio',
          'lib/features/maestri/caligo/viaggio'
        ])
          ...Directory(cartella)
              .listSync(recursive: true)
              .whereType<File>()
              .where((f) => f.path.endsWith('.dart')),
      ];
      cardinaleMinimo(file.length, 30,
          cosa: 'file del Viaggio',
          perche: 'Senza file nessuno tocca le porte che spendono.');
      final porte = RegExp(
          // Gli import e i tipi delle due porte, e non le parole: un
          // commento che racconta il riscatto non spende niente.
          r"import '[^']*(porta_del_cerchio|question_allowance)\.dart'|"
          r'\b(PortaDelCerchio|QuestionAllowance)\b');
      final spendono = [
        for (final f in file)
          if (porte.hasMatch(f.readAsStringSync())) f.path,
      ];
      // ignore: avoid_print
      print('ORDINE DJ VOCE 05: budget del server ${voci.length}, in vendita '
          'per il Viaggio ${inVendita.length}; file del Viaggio ${file.length}, '
          'che toccano le porte che spendono ${spendono.length}');
      expect(inVendita, isEmpty,
          reason: 'il server vende $inVendita: la rivelazione e le discese non '
              'si comprano');
      expect(spendono, isEmpty,
          reason: 'questi file del Viaggio toccano le porte che spendono gli '
              'Eos: $spendono');
    });

    test('IL TETTO SI RAGGIUNGE DAVVERO, piano per piano', () {
      for (final t in Tier.values) {
        final tetto = TettiDelViaggio.discesePerIlPiano(t);
        // Alla penultima si scende ancora, all ultima no.
        expect(
            TettiDelViaggio.siPuoScendere(
                giaRiconosciuto: true,
                quanteOggi: tetto - 1,
                tier: t,
                demo: false),
            isTrue,
            reason: 'col piano ${t.label} la domanda numero $tetto e gia '
                'negata: il tetto dichiarato e $tetto e se ne fanno '
                '${tetto - 1}');
        expect(
            TettiDelViaggio.siPuoScendere(
                giaRiconosciuto: true, quanteOggi: tetto, tier: t, demo: false),
            isFalse,
            reason: 'col piano ${t.label} si scende anche dopo aver finito le '
                '$tetto domande: il tetto non tiene');
      }
      // ignore: avoid_print
      print('ORDINE DE VOCE 14: ogni piano si ferma esattamente sul suo tetto');
    });

    test('LE DUE RIGHE DEL RIFIUTO SONO DUE, e dicono cose diverse', () {
      final primaDellaRivelazione = TettiDelViaggio.percheNonOggi(
          giaRiconosciuto: false, quanteOggi: 1, tier: Tier.free, demo: false);
      final dopo = TettiDelViaggio.percheNonOggi(
          giaRiconosciuto: true, quanteOggi: 1, tier: Tier.free, demo: false);
      // ignore: avoid_print
      print('ORDINE DE VOCE 14: prima della rivelazione si legge '
          '"$primaDellaRivelazione"; dopo si legge "$dopo"');
      expect(primaDellaRivelazione, isNotNull);
      expect(dopo, isNotNull);
      expect(primaDellaRivelazione, isNot(dopo),
          reason: 'le due attese hanno cause diverse e si leggono uguali');
      expect(primaDellaRivelazione!.toLowerCase(), contains('metodo'),
          reason: 'chi aspetta per il metodo non legge che e il metodo');
      expect(primaDellaRivelazione.toLowerCase().contains('eos'), isFalse,
          reason: 'a chi aspetta per il metodo si offrono gli Eos: si sta '
              'vendendo la fonte');
      // **DALL'ORDINE DI VOCE 15**: chi ha finito le discese del piano
      // legge quando torna, e il nutrimento. Qui si pretendeva la parola Eos.
      expect(dopo!.toLowerCase().contains('eos'), isFalse,
          reason: 'al tetto si promette di comprare con gli Eos: nessuna '
              'strada vende una discesa');
      expect(dopo, contains('domani'),
          reason: 'al tetto non si dice quando si torna a scendere');
    });

    test('E SI SCENDE, quando il tetto non e stato raggiunto', () {
      expect(
          TettiDelViaggio.percheNonOggi(
              giaRiconosciuto: false,
              quanteOggi: 0,
              tier: Tier.free,
              demo: false),
          isNull,
          reason: 'chi non e ancora sceso oggi legge gia un rifiuto');
    });
  });

  group('CHIAVE ACCESA, nessun limite risponde', () {
    test('IN DEMO NESSUN PIANO HA UN TETTO, prima e dopo la rivelazione', () {
      for (final t in Tier.values) {
        for (final riconosciuto in [false, true]) {
          expect(
              TettiDelViaggio.quanteAlGiorno(
                  giaRiconosciuto: riconosciuto, tier: t, demo: true),
              isNull,
              reason: 'in Demo il piano ${t.label} ha ancora un tetto '
                  '(riconosciuto: $riconosciuto)');
          // **E SI SCENDE ANCHE DOPO NOVECENTONOVANTANOVE.** Qui si chiedeva
          // a `quanteNeRestano`, che nessuna schermata chiamava: tolta con
          // l'ordine DJ voce 05, e la pretesa passa dalla porta vera.
          expect(
              TettiDelViaggio.siPuoScendere(
                  giaRiconosciuto: riconosciuto,
                  quanteOggi: 999,
                  tier: t,
                  demo: true),
              isTrue);
        }
      }
      // ignore: avoid_print
      print('ORDINE DE VOCE 14: in Demo i tetti nulli sono '
          '${Tier.values.length * 2} su ${Tier.values.length * 2}');
    });

    test('IN DEMO LE QUATTRO DISCESE SI FANNO DI SEGUITO, e si continua oltre',
        () {
      // **E il caso che l ordine nomina**: *"deve poter fare le quattro
      // discese di seguito, e continuare oltre, senza aspettare giorni"*.
      for (var gia = 0; gia < 12; gia++) {
        expect(
            TettiDelViaggio.siPuoScendere(
                giaRiconosciuto: gia >= 4,
                quanteOggi: gia,
                tier: Tier.free,
                demo: true),
            isTrue,
            reason: 'in Demo la discesa numero ${gia + 1} dello stesso giorno '
                'e negata: per valutare la funzione bisogna aspettare giorni');
        expect(
            TettiDelViaggio.percheNonOggi(
                giaRiconosciuto: gia >= 4,
                quanteOggi: gia,
                tier: Tier.free,
                demo: true),
            isNull,
            reason: 'in Demo compare una riga di rifiuto alla discesa '
                '${gia + 1}');
      }
      // ignore: avoid_print
      print('ORDINE DE VOCE 14: in Demo dodici discese di fila, tutte '
          'concesse, col piano piu basso');
    });

    test('LA CHIAVE E QUELLA GIA IN USO, non una seconda', () {
      // **Il valore di partenza dei tetti E `AppFlags.isDemo`**, e non una
      // copia sua: se qualcuno spegnesse la demo del progetto e questa
      // restasse accesa per conto suo, la Demo proverebbe una funzione che
      // gli utenti non hanno.
      final senzaDirlo = TettiDelViaggio.quanteAlGiorno(
          giaRiconosciuto: true, tier: Tier.free);
      final conLaChiaveDelProgetto = TettiDelViaggio.quanteAlGiorno(
          giaRiconosciuto: true, tier: Tier.free, demo: AppFlags.isDemo);
      // ignore: avoid_print
      print('ORDINE DE VOCE 14: AppFlags.isDemo vale ${AppFlags.isDemo}; '
          'senza dire niente il tetto e $senzaDirlo, con la chiave del '
          'progetto e $conLaChiaveDelProgetto');
      expect(senzaDirlo, conLaChiaveDelProgetto,
          reason: 'i tetti hanno una chiave loro invece di quella del '
              'progetto: due strade che divergono');
    });
  });

  group('IL DIARIO CONTA LE DISCESE DI OGGI', () {
    test('QUANTE OGGI CONTA SOLO OGGI', () async {
      final oggi = DateTime(2026, 9, 11, 20);
      final diario = DiarioDeiViaggi(orologio: () => oggi);
      await diario.carica();
      UnViaggio quando(DateTime d) => UnViaggio(
            quando: d,
            domanda: 'una domanda',
            temaDellaDomanda: '',
            pezzi: const ['a', 'b', 'c', 'd'],
            animaleSeguito: 'Lupo',
            nitidezza: 1.0,
          );
      await diario.segna(quando(DateTime(2026, 9, 11, 9)));
      await diario.segna(quando(DateTime(2026, 9, 11, 18)));
      await diario.segna(quando(DateTime(2026, 9, 10, 23, 59)));
      // ignore: avoid_print
      print('ORDINE DE VOCE 14: tre viaggi segnati, due oggi e uno ieri; '
          'quanteOggi dice ${diario.quanteOggi} e quanteDiscese '
          '${diario.quanteDiscese}');
      expect(diario.quanteOggi, 2,
          reason: 'il conto di oggi prende anche quello di ieri, oppure ne '
              'perde uno');
      expect(diario.quanteDiscese, 3,
          reason: 'il conto totale non e piu il totale');
    });
  });
}
