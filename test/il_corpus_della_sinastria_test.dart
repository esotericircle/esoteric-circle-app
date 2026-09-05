import 'dart:io';

import 'package:esoteric_circle/core/synastry/responso_della_sinastria.dart';
import 'package:esoteric_circle/core/synastry/synastry_report.dart';
import 'package:esoteric_circle/core/synastry/testi_della_sinastria.dart';
import 'package:esoteric_circle/core/synastry/cielo_della_sinastria.dart';
import 'package:esoteric_circle/core/synastry/vip_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL CORPUS DELLA SINASTRIA, revisione B. Ordine CA voci 04, 05 e 06.
///
/// **CA.04, la grandezza misurata e' QUANTE FRASI DIVERSE l'app puo' produrre
/// sopra il cerchio**, che oggi valeva uno per fascia, cioe' cinque in tutto,
/// e la presenza del titolo della bolla e della nota separata, che non
/// esistevano.
///
/// **CA.05**: un fatto di attualita' scaduto non compare nel testo, e lo stato
/// in vita si corregge dal server senza pubblicare l'app.
///
/// **CA.06, la grandezza misurata e' L'INTERVALLO DEI VALORI EFFETTIVAMENTE
/// MOSTRATI** su un insieme di coppie diverse, non quello che il calcolo
/// potrebbe produrre.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(CorrezioniDeiVip.azzera);
  tearDown(CorrezioniDeiVip.azzera);

  final corpus = File('docs/corpus/sinastria_testi.md').readAsStringSync();

  test('CA.04: il corpus e\' la fonte, e ogni riga dell\'app viene da li\'',
      () {
    // **Un corpus e una copia che divergono sono due corpus.** Qui si rilegge
    // il documento e si pretende che ogni frase che l'app puo' dire sia
    // scritta li' dentro.
    final mancanti = <String>[];
    for (final r in TestiDellaSinastria.sopraIlCerchio.values) {
      for (final frase in r.values) {
        if (!corpus.contains(frase)) mancanti.add(frase);
      }
    }
    for (final r in TestiDellaSinastria.titoliDellaBolla.values) {
      for (final t in r.values) {
        if (!corpus.contains(t)) mancanti.add(t);
      }
    }
    for (final l in TestiDellaSinastria.aperture.values) {
      for (final a in l) {
        if (!corpus.contains(a)) mancanti.add(a);
      }
    }
    for (final l in TestiDellaSinastria.stoccate.values) {
      for (final a in l) {
        if (!corpus.contains(a)) mancanti.add(a);
      }
    }
    for (final p in TestiDellaSinastria.presentazioni.values) {
      if (!corpus.contains(p)) mancanti.add(p);
    }
    // ignore: avoid_print
    print('ORDINE CA VOCE 4: frasi confrontate col corpus '
        '${TestiDellaSinastria.sopraIlCerchio.length * 5 + TestiDellaSinastria.titoliDellaBolla.length * 5 + 21 + 25 + TestiDellaSinastria.presentazioni.length}, '
        'fuori dal corpus ${mancanti.length}');
    expect(mancanti, isEmpty,
        reason: 'queste frasi non stanno nel corpus: $mancanti');
  });

  test('CA.04: sopra il cerchio ci sono trentacinque frasi, non cinque', () {
    final distinte = <String>{};
    for (final r in RelazioneFraSegni.values) {
      for (final f in FasciaDiAffinita.values) {
        distinte.add(TestiDellaSinastria.sopraIlCerchio[r]![f]!);
      }
    }
    // ignore: avoid_print
    print('ORDINE CA VOCE 4: frasi distinte sopra il cerchio '
        '${distinte.length}, titoli della bolla '
        '${TestiDellaSinastria.titoliDellaBolla.values.expand((m) => m.values).toSet().length}');
    expect(distinte.length, greaterThanOrEqualTo(30),
        reason: 'sopra il cerchio l\'app puo\' dire solo ${distinte.length} '
            'frasi diverse: era il difetto, cioe\' un testo che dipende dalla '
            'sola fascia e si ripete sempre uguale');
  });

  test('CA.04: il responso porta i cinque pezzi, e la nota sta fuori', () {
    final vip = VipCatalog.vips[3];
    final report = SynastryReport.perCieli(
      tuo: CieloDiSinastria.perVip(VipCatalog.vips[9]),
      vip: vip,
      quando: DateTime(2026, 8, 28),
    );
    // ignore: avoid_print
    print('ORDINE CA VOCE 4: sopra il cerchio "${report.sopraIlCerchio}", '
        'titolo "${report.titoloDellaBolla}", nota di '
        '${report.nota.length} caratteri, sfida "${report.sfida}"');
    expect(report.sopraIlCerchio, isNotEmpty,
        reason: 'la frase sopra il cerchio non c\'e\'');
    expect(report.titoloDellaBolla, isNotEmpty,
        reason: 'il titolo della bolla non c\'e\'');
    expect(report.sfida, isNotEmpty, reason: 'la sfida non c\'e\'');
    // **IL DISCLAIMER DELL\'ORA NON C\'E\' PIU\', E NON E\' UNA PERDITA.**
    // Ordine CC voce 06g, parole del fondatore: "quando non si conosce
    // l\'orario di nascita del vip c\'e\' sempre un testo che dice "non si finge
    // cio\' che non si conosce" ecc. eliminalo! al suo posto, ma in ogni
    // responso inserisci 2 righe con Ora di Nascita: e Luogo di Residenza:".
    //
    // **La cosa difesa resta**, ed e\' piu\' difesa di prima: che l\'app dichiari
    // quando non conosce l\'ora. Prima lo diceva con tre righe e solo quando
    // mancava; adesso con due parole e in OGNI responso.
    expect(report.oraDiNascita, contains('Ora di Nascita:'),
        reason: 'la riga dell\'ora di nascita non c\'e\'');
    expect(report.luogoDiResidenza, contains('Luogo di Residenza:'),
        reason: 'la riga del luogo di residenza non c\'e\'');
    expect(report.reading.contains('ora esatta di nascita'), isFalse,
        reason: 'il disclaimer e\' tornato dentro la bolla');
    expect(report.reading.startsWith('Il fatto è questo'), isFalse,
        reason: 'la bolla apre ancora sempre allo stesso modo');
  });

  test('CA.05: un fatto scaduto non entra nel testo', () {
    final vip = VipCatalog.vips[3];
    const fatto = 'ha aperto la stagione con un concerto a Milano';
    // Fresco di ieri: entra.
    CorrezioniDeiVip.applicaAttualita({
      vip.name: {
        'testo': fatto,
        'verificata_il': '2026-08-27',
      }
    });
    final fresco = SynastryReport.perCieli(
      tuo: CieloDiSinastria.perVip(VipCatalog.vips[9]),
      vip: vip,
      quando: DateTime(2026, 8, 28),
    );
    expect(fresco.reading, contains(fatto),
        reason: 'un fatto verificato ieri non entra nel testo');
    expect(fresco.nota, contains('aggiornate al'),
        reason: 'la nota non dice a quando sono aggiornate le notizie');

    // Vecchio di sei mesi: non entra, e non si vede che manchi.
    CorrezioniDeiVip.applicaAttualita({
      vip.name: {
        'testo': fatto,
        'verificata_il': '2026-02-01',
      }
    });
    final vecchio = SynastryReport.perCieli(
      tuo: CieloDiSinastria.perVip(VipCatalog.vips[9]),
      vip: vip,
      quando: DateTime(2026, 8, 28),
    );
    // ignore: avoid_print
    print('ORDINE CA VOCE 5: col fatto fresco il testo lo porta? '
        '${fresco.reading.contains(fatto)}; col fatto di sei mesi fa? '
        '${vecchio.reading.contains(fatto)}');
    expect(vecchio.reading.contains(fatto), isFalse,
        reason: 'un fatto vecchio di sei mesi viene raccontato come '
            'attualita\': oltre i novanta giorni non e\' piu\' attualita\'');
    expect(vecchio.reading, isNotEmpty,
        reason: 'senza il fatto la frase non regge piu\'');
  });

  test('CA.05: lo stato in vita si corregge dal server, senza pubblicare', () {
    final vip = VipCatalog.vips.firstWhere((v) => !v.eScomparso);
    expect(vip.eScomparso, isFalse);
    CorrezioniDeiVip.applica({vip.name: 'scomparso'});
    // ignore: avoid_print
    print('ORDINE CA VOCE 5: dopo la correzione del server ${vip.name} '
        'risulta scomparso? ${vip.eScomparso}');
    expect(vip.eScomparso, isTrue,
        reason: 'la correzione del server non arriva al catalogo: lo stato in '
            'vita cambierebbe solo pubblicando una versione nuova dell\'app');
    // E il testo cambia con lui: niente attualita', e la chiusura sobria.
    CorrezioniDeiVip.applicaAttualita({
      vip.name: {'testo': 'un fatto qualunque', 'verificata_il': '2026-08-27'}
    });
    final report = SynastryReport.perCieli(
      tuo: CieloDiSinastria.perVip(VipCatalog.vips[9]),
      vip: vip,
      quando: DateTime(2026, 8, 28),
    );
    expect(report.reading.contains('un fatto qualunque'), isFalse,
        reason: 'si racconta l\'attualita\' di chi non c\'e\' piu\'');
    expect(TestiDellaSinastria.memoria.any((m) => report.reading.contains(m)),
        isTrue,
        reason: 'la chiusura non e\' quella sobria della memoria');
  });

  test('CA.06: i valori mostrati distinguono le coppie', () {
    // **L'INTERVALLO DEI VALORI EFFETTIVAMENTE MOSTRATI**, non quello che il
    // calcolo potrebbe produrre: si guarda cosa finisce nella barra e nella
    // parola, su venti coppie diverse.
    final tuo = CieloDiSinastria.perVip(VipCatalog.vips[9]);
    final mostrati = <int>[];
    final parole = <String>{};
    for (final vip in VipCatalog.vips.take(20)) {
      final r = SynastryReport.perCieli(
          tuo: tuo, vip: vip, quando: DateTime(2026, 8, 28));
      if (!r.incontro.esiste) continue;
      final barra = r.bars.firstWhere((b) => b.quip.isNotEmpty);
      mostrati.add(barra.value);
      parole.add(r.incontro.inParole);
    }
    mostrati.sort();
    final intervallo = mostrati.last - mostrati.first;
    // ignore: avoid_print
    print('ORDINE CA VOCE 6: su ${mostrati.length} coppie i valori mostrati '
        'vanno da ${mostrati.first} a ${mostrati.last}, cioe\' un intervallo '
        'di $intervallo, con ${parole.length} gradini diversi in parole');
    expect(intervallo, greaterThanOrEqualTo(30),
        reason: 'i valori mostrati stanno tutti dentro $intervallo punti: due '
            'coppie diverse sembrano uguali, ed e\' il rilievo riaperto dal '
            'fondatore');
    expect(parole.length, greaterThanOrEqualTo(2),
        reason: 'tutte le coppie leggono la stessa parola');
  });

  test(
      'CA.06: quello che la barra mostra e\' l\'indice, non la percentuale '
      'cruda', () {
    final tuo = CieloDiSinastria.perVip(VipCatalog.vips[9]);
    final r = SynastryReport.perCieli(
        tuo: tuo, vip: VipCatalog.vips[3], quando: DateTime(2026, 8, 28));
    final barra = r.bars.firstWhere((b) => b.quip.isNotEmpty);
    expect(barra.value, r.incontro.indiceSullaScala,
        reason: 'la barra non porta l\'indice sulla scala');
    expect(barra.value.toDouble(), isNot(closeTo(r.meetingPercent, 0.5)),
        reason: 'la barra mostra ancora la percentuale cruda, che e\' quella '
            'che il fondatore legge come 1,8 per cento');
  });

  test('CA.04: la sfida non e\' sempre la stessa riga', () {
    final righe = <String>{};
    for (var i = 0; i < 12; i++) {
      righe.add(ResponsoDellaSinastria.laSfida(
          nome: 'Tizio', percento: 50 + i, seme: i));
    }
    // ignore: avoid_print
    print('ORDINE CA VOCE 4: sfide distinte su dodici giri ${righe.length}');
    expect(righe.length, greaterThanOrEqualTo(4),
        reason: 'la riga della sfida e\' quasi sempre la stessa');
  });
}
