import 'package:esoteric_circle/core/config/app_flags.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/viaggio/diario_dei_viaggi.dart';
import 'package:esoteric_circle/core/viaggio/tetti_del_viaggio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    test('I QUATTRO TETTI DOPO LA RIVELAZIONE SONO 1, 3, 7 e 20', () {
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
        'Tier 1': 3,
        'Tier 2': 7,
        'Tier 3': 20,
      });
      // **IL CARDINALE**: quattro piani, quattro tetti. Se un quinto piano
      // nascesse senza il suo numero, questo confronto cade.
      expect(TettiDelViaggio.domandeAlGiorno.length, Tier.values.length,
          reason: 'ci sono piani senza tetto dichiarato: '
              '${Tier.values.where((t) => !TettiDelViaggio.domandeAlGiorno.containsKey(t)).toList()}');
    });

    test('LA RIVELAZIONE E UNA AL GIORNO PER TUTTI, anche per il piu alto',
        () {
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

    test('LA RIVELAZIONE NON SI COMPRA CON GLI EOS, le domande si', () {
      expect(TettiDelViaggio.siPuoComprareAncora(giaRiconosciuto: false),
          isFalse,
          reason: 'le quattro discese del riconoscimento si possono comprare');
      expect(TettiDelViaggio.siPuoComprareAncora(giaRiconosciuto: true), isTrue,
          reason: 'dopo la rivelazione non si possono comprare altre domande, '
              'e allora il tetto del piano e un muro invece di un listino');
      // ignore: avoid_print
      print('ORDINE DE VOCE 14: prima della rivelazione si compra '
          '${TettiDelViaggio.siPuoComprareAncora(giaRiconosciuto: false)}, '
          'dopo ${TettiDelViaggio.siPuoComprareAncora(giaRiconosciuto: true)}');
    });

    test('IL TETTO SI RAGGIUNGE DAVVERO, piano per piano', () {
      for (final t in Tier.values) {
        final tetto = TettiDelViaggio.domandeAlGiorno[t]!;
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
                giaRiconosciuto: true,
                quanteOggi: tetto,
                tier: t,
                demo: false),
            isFalse,
            reason: 'col piano ${t.label} si scende anche dopo aver finito le '
                '$tetto domande: il tetto non tiene');
        expect(
            TettiDelViaggio.quanteNeRestano(
                giaRiconosciuto: true,
                quanteOggi: tetto,
                tier: t,
                demo: false),
            0);
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
      expect(dopo!.toLowerCase(), contains('eos'),
          reason: 'chi ha finito le domande del piano non sa che puo '
              'comprarne altre');
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
          expect(
              TettiDelViaggio.quanteNeRestano(
                  giaRiconosciuto: riconosciuto,
                  quanteOggi: 999,
                  tier: t,
                  demo: true),
              isNull);
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
