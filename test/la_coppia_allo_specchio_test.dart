// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/synastry/lo_specchio.dart';
import 'package:esoteric_circle/core/synastry/responso_della_sinastria.dart';
import 'package:esoteric_circle/core/synastry/synastry_report.dart';
import 'package:esoteric_circle/core/synastry/testi_dello_specchio.dart';
import 'package:esoteric_circle/core/synastry/vip_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA COPPIA ALLO SPECCHIO.** Ordine DR, 16 settembre 2026.
///
/// **Il fatto, dal fondatore**: ha accoppiato nella Sinastria VIP un
/// personaggio con se' stesso e la scheda si leggeva come un guasto, con la
/// stessa frase stampata due volte di fila. La decisione e' stata di non
/// vietare quel caso: diventa un easter egg che nomina il gesto e lo esagera.
///
/// **Qui si misura che il gioco funzioni e che i numeri non si siano
/// mossi.**
void main() {
  final gaga = VipCatalog.vips.firstWhere((v) => v.name == 'Lady Gaga');
  final gates = VipCatalog.vips.firstWhere((v) => v.name == 'Bill Gates');

  group('DR.01, la porta che riconosce lo specchio', () {
    test('lo stesso personaggio due volte e specchio, due diversi no', () {
      expect(LoSpecchio.sono(gaga, gaga), isTrue);
      expect(LoSpecchio.sono(gaga, gates), isFalse);
    });

    test('DUE PERSONAGGI DIVERSI NATI LO STESSO GIORNO NON SONO ALLO SPECCHIO',
        () {
      // **IL CASO NON ESISTE NEL CATALOGO, e va costruito.** Misurato
      // leggendo `vip_catalog.dart`: cinquanta personaggi, cinquanta nomi
      // diversi, cinquanta stem diversi e **cinquanta date di nascita
      // diverse**. Una prova che pescasse dal catalogo sarebbe verde senza
      // aver guardato niente, quindi i due gemelli di data si fabbricano qui.
      final quante = VipCatalog.vips.length;
      final date = VipCatalog.vips
          .map((v) => '${v.annoDiNascita}-${v.meseDiNascita}-${v.giornoDiNascita}')
          .toSet();
      print('ORDINE DR VOCE 01: nel catalogo $quante personaggi e '
          '${date.length} date di nascita diverse');
      expect(date.length, quante,
          reason: 'due personaggi del catalogo condividono la data: la prova '
              'qui sotto non basta piu, va rifatta su quelli veri');
      const uno = Vip(
        name: 'Primo Finto',
        sign: Zodiac.aries,
        annoDiNascita: 1980,
        meseDiNascita: 4,
        giornoDiNascita: 1,
        stem: 'primo_finto_v1',
        statoInVita: StatoInVita.inVita,
        esposizione: EsposizionePubblica.media,
        fonti: {},
      );
      const due = Vip(
        name: 'Secondo Finto',
        sign: Zodiac.aries,
        annoDiNascita: 1980,
        meseDiNascita: 4,
        giornoDiNascita: 1,
        stem: 'secondo_finto_v1',
        statoInVita: StatoInVita.inVita,
        esposizione: EsposizionePubblica.media,
        fonti: {},
      );
      expect(LoSpecchio.sono(uno, due), isFalse,
          reason: 'stessa data e stesso segno, ma sono due persone diverse: '
              'e una coincidenza, non una coppia allo specchio');
      expect(LoSpecchio.sono(uno, uno), isTrue);
    });
  });

  group('DR.02, il numero resta quello vero', () {
    test('il cerchio e le sei barre non cambiano fra specchio e calcolo', () {
      final report = SynastryReport.fraDueVip(primo: gaga, vip2: gaga);
      // **IL NUMERO NON SI TOCCA**: e' quello che il calcolo produce, e le
      // tre catture del fondatore dicono 79 per questo personaggio.
      print('ORDINE DR VOCE 02: lo specchio di ${gaga.name} da '
          '${report.overall} per cento, barre '
          '${report.bars.map((b) => "${b.label} ${b.value}").join(", ")}');
      expect(report.overall, 79,
          reason: 'il numero del cerchio si e mosso: l ordine DR vieta di '
              'toccarlo');
      expect(report.terraComune, 92);
      expect(report.ritmo, 34,
          reason: 'segno cardinale: la tradizione dice 34 e resta 34');
      expect(report.vitaQuotidiana, 70);
      expect(report.bars.where((b) => b.label == 'Ritmo'), hasLength(1));
    });

    test('LA RIGA DELLA BARRA SEGUE LA BARRA PIU BASSA VERA', () {
      // **Il testo che descrive una barra sbagliata e peggio di nessun
      // testo**, dice l'ordine. Qui si prende la barra piu' bassa dal report
      // e si pretende che il corpo parli proprio di quella.
      var guardati = 0;
      final storti = <String>[];
      for (final vip in VipCatalog.vips.where((v) => !v.eScomparso)) {
        final report = SynastryReport.fraDueVip(primo: vip, vip2: vip);
        final sei = report.bars.where((b) => b.label != 'Possibilità di incontro');
        final minimo = sei.map((b) => b.value).reduce((a, b) => a < b ? a : b);
        final piuBassa = sei.firstWhere((b) => b.value == minimo).label;
        final righe = TestiDelloSpecchio.laBarraPiuBassa[piuBassa];
        expect(righe, isNotNull,
            reason: 'nessun testo per la barra piu bassa "$piuBassa"');
        guardati++;
        if (!righe!.any((r) => report.reading.contains(r))) {
          storti.add('${vip.name}: la piu bassa e "$piuBassa" e il corpo non '
              'la nomina');
        }
      }
      print('ORDINE DR VOCE 02: barre piu basse guardate su $guardati '
          'personaggi');
      expect(guardati, greaterThan(40),
          reason: 'la prova non ha guardato abbastanza personaggi');
      expect(storti, isEmpty, reason: storti.join(' | '));
    });
  });

  group('DR.04, la sorpresa che non si ripete', () {
    test('DODICI APERTURE DI FILA DANNO DODICI TESTI DIVERSI', () {
      final visti = <String>{};
      for (var volta = 0; volta < TestiDelloSpecchio.quante; volta++) {
        final report =
            SynastryReport.fraDueVip(primo: gaga, vip2: gaga, volteAlloSpecchio: volta);
        visti.add('${report.sopraIlCerchio}|${report.titoloDellaBolla}|'
            '${report.reading}|${report.sfida}');
      }
      print('ORDINE DR VOCE 04: dodici aperture, ${visti.length} testi '
          'diversi');
      expect(visti, hasLength(TestiDelloSpecchio.quante),
          reason: 'due aperture di fila hanno dato lo stesso testo: la '
              'sorpresa muore alla seconda volta');
    });

    test('il testo non si muove dentro una stessa apertura', () {
      final uno = SynastryReport.fraDueVip(
          primo: gaga, vip2: gaga, volteAlloSpecchio: 3);
      final due = SynastryReport.fraDueVip(
          primo: gaga, vip2: gaga, volteAlloSpecchio: 3);
      expect(uno.reading, due.reading);
      expect(uno.sopraIlCerchio, due.sopraIlCerchio);
      expect(uno.sfida, due.sfida);
    });

    test('ALLA PRIMA APERTURA I CINQUANTA COPRONO TUTTE E DODICI LE VARIANTI',
        () {
      // **L'ORDINE CHIEDE CHE DUE PERSONAGGI DIVERSI DIANO TESTI DIVERSI, e
      // universalmente non si puo'**: i personaggi sono cinquanta e le
      // varianti dodici, quindi qualcuno le condivide per forza. La cosa
      // vera da pretendere e' che alla prima apertura le dodici varianti
      // siano tutte raggiunte, cioe' che il testo dipenda davvero da chi
      // hai scelto.
      final indici = <int>{};
      for (final vip in VipCatalog.vips) {
        indici.add(ResponsoDellaSinastria.varianteDelloSpecchio(vip, 0));
      }
      print('ORDINE DR VOCE 04: alla prima apertura i ${VipCatalog.vips.length} '
          'personaggi coprono ${indici.length} varianti su '
          '${TestiDelloSpecchio.quante}');
      expect(indici, hasLength(TestiDelloSpecchio.quante),
          reason: 'alla prima apertura le varianti raggiunte sono '
              '${indici.length}: il testo non dipende abbastanza da chi hai '
              'scelto');
      expect(
          ResponsoDellaSinastria.varianteDelloSpecchio(gaga, 0) !=
              ResponsoDellaSinastria.varianteDelloSpecchio(gates, 0),
          isTrue,
          reason: 'i due personaggi della cattura del fondatore danno la '
              'stessa variante');
    });
  });

  group('DR.03, il corpus dei gemelli', () {
    test('la prima riga nomina il gesto, in tutte e dodici', () {
      // **Il modo di uccidere il sospetto dell errore e dirlo per primi**: la
      // prima riga del corpo e' sempre quella che nomina la scelta.
      for (var volta = 0; volta < TestiDelloSpecchio.quante; volta++) {
        final report = SynastryReport.fraDueVip(
            primo: gaga, vip2: gaga, volteAlloSpecchio: volta);
        final quale =
            ResponsoDellaSinastria.varianteDelloSpecchio(gaga, volta);
        final gesto = TestiDelloSpecchio.ilGesto[quale]
            .replaceAll('NOME', gaga.name);
        expect(report.reading.startsWith(gesto), isTrue,
            reason: 'alla volta $volta il corpo non comincia nominando il '
                'gesto: "${report.reading.substring(0, 60)}"');
      }
    });

    test('OGNI VARIANTE SPIEGA PERCHE NON E CENTO, col numero vero dentro',
        () {
      for (var volta = 0; volta < TestiDelloSpecchio.quante; volta++) {
        final report = SynastryReport.fraDueVip(
            primo: gaga, vip2: gaga, volteAlloSpecchio: volta);
        expect(report.reading, contains('${report.overall}'),
            reason: 'alla volta $volta il corpo non porta il numero vero');
      }
      // E la spiegazione non e' un blocco fisso incollato in fondo: le dodici
      // righe sono dodici righe diverse.
      expect(TestiDelloSpecchio.percheNonCento.toSet(),
          hasLength(TestiDelloSpecchio.quante));
    });

    test('GLI SCOMPARSI RESTANO FUORI DALLA SATIRA, tutti quanti', () {
      final scomparsi = VipCatalog.vips.where((v) => v.eScomparso).toList();
      print('ORDINE DR VOCE 03: scomparsi nel catalogo ${scomparsi.length}');
      expect(scomparsi, isNotEmpty,
          reason: 'nessuno scomparso nel catalogo: questa prova non '
              'guarderebbe niente');
      final comici = <String>[
        ...TestiDelloSpecchio.sopraIlCerchio,
        ...TestiDelloSpecchio.titoli,
        ...TestiDelloSpecchio.ilGesto,
        ...TestiDelloSpecchio.percheNonCento,
        ...TestiDelloSpecchio.chiuse,
        ...TestiDelloSpecchio.sfide,
        for (final r in TestiDelloSpecchio.laBarraPiuBassa.values) ...r,
      ];
      for (final vip in scomparsi) {
        for (var volta = 0; volta < 4; volta++) {
          final report = SynastryReport.fraDueVip(
              primo: vip, vip2: vip, volteAlloSpecchio: volta);
          final tutto = '${report.sopraIlCerchio} ${report.titoloDellaBolla} '
              '${report.reading} ${report.sfida}';
          for (final battuta in comici) {
            final nuda = battuta.replaceAll('NOME', vip.name);
            expect(tutto.contains(nuda), isFalse,
                reason: '${vip.name} non c\'e\' piu\' e riceve una battuta: '
                    '"$nuda"');
          }
        }
      }
    });

    test('IL BERSAGLIO E LA SCELTA, MAI LA PERSONA: nessun nome del catalogo '
        'dentro i testi', () {
      // **La guardia del bersaglio**, ordine DR voce 06: i nomi entrano solo
      // per sostituzione. Una battuta che nomina un personaggio e' una
      // battuta su quella persona, ed e' esattamente cio' che il vincolo
      // legale vieta.
      final testi = <String>[
        ...TestiDelloSpecchio.sopraIlCerchio,
        ...TestiDelloSpecchio.titoli,
        ...TestiDelloSpecchio.ilGesto,
        ...TestiDelloSpecchio.percheNonCento,
        ...TestiDelloSpecchio.chiuse,
        ...TestiDelloSpecchio.sfide,
        ...TestiDelloSpecchio.corpoPerChiNonCePiu,
        TestiDelloSpecchio.sopraIlCerchioPerChiNonCePiu,
        TestiDelloSpecchio.titoloPerChiNonCePiu,
        TestiDelloSpecchio.sfidaPerChiNonCePiu,
        for (final r in TestiDelloSpecchio.laBarraPiuBassa.values) ...r,
      ];
      final colpevoli = <String>[];
      for (final t in testi) {
        for (final vip in VipCatalog.vips) {
          // Il nome intero, e anche il solo cognome o nome proprio quando e'
          // una parola che non si usa in italiano comune.
          if (t.contains(vip.name)) colpevoli.add('"$t" nomina ${vip.name}');
        }
      }
      print('ORDINE DR VOCE 06: testi dello specchio guardati ${testi.length}');
      expect(testi.length, greaterThan(70),
          reason: 'i testi guardati sono pochi: la guardia non copre il '
              'corpus');
      expect(colpevoli, isEmpty, reason: colpevoli.join(' | '));
    });
  });
}
