import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/sigilli/ancoraggi_dei_sentieri.dart';
import 'package:esoteric_circle/core/sigilli/lettura_degli_ancoraggi.dart';
import 'package:esoteric_circle/core/sigilli/regole_delle_tre_arti.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// GLI ANCORAGGI VENGONO DALL'ARTE, E CI RESTANO. Ordine T voce 01.
///
/// **Cosa presidia.** Che i cinquantacinque punti scritti in
/// `ancoraggi_dei_sentieri.dart` siano ancora quelli che l'arte produce: se
/// Mauro cambia un'immagine e nessuno rilancia lo strumento, una riga cade qui
/// invece di scoprirlo sul telefono.
///
/// **Le prove del rosso si fanno su immagini FABBRICATE**, non sull'arte vera:
/// un'immagine costruita dal codice e' ripetibile, e permette di sbagliarla
/// apposta in quattro modi diversi.
void main() {
  /// Una tela quadrata con cinquantacinque pallini: cinque gruppi da undici,
  /// disposti in cinque anelli di dieci attorno a un pallino grande.
  ///
  /// **E' la forma piu' semplice che soddisfa la regola**, quindi qualunque
  /// difetto che si inietta e' l'unico difetto presente.
  Future<ui.Image> tavolaDeiPallini({
    int quantiPiccoli = 10,
    int quantiGrandi = 1,
    bool sovrapponi = false,
  }) async {
    const lato = 900.0;
    final registratore = ui.PictureRecorder();
    final tela = Canvas(registratore);
    final pennello = Paint()..color = const Color(0xFFFFFFFF);
    for (var gruppo = 0; gruppo < 5; gruppo++) {
      final cy = 110.0 + gruppo * 170.0;
      const cx = lato / 2;
      // Il grande, al centro del suo gruppo.
      for (var g = 0; g < quantiGrandi; g++) {
        tela.drawCircle(Offset(cx + g * 70, cy), 30, pennello);
      }
      for (var k = 0; k < quantiPiccoli; k++) {
        final angolo = k * 2 * math.pi / 10;
        // Due pallini attaccati, per la prova della sovrapposizione.
        final raggio = (sovrapponi && gruppo == 2 && k == 3) ? 118.0 : 130.0;
        tela.drawCircle(
            Offset(cx + raggio * math.cos(angolo),
                cy + raggio * math.sin(angolo) * 0.42),
            13,
            pennello);
      }
    }
    return registratore
        .endRecording()
        .toImage(lato.toInt(), (110 + 4 * 170 + 120).toInt());
  }

  Future<Uint8List> crudo(ui.Image i) async =>
      (await i.toByteData(format: ui.ImageByteFormat.rawRgba))!
          .buffer
          .asUint8List();

  testWidgets('OGNI sentiero da\' ancora i cinquantacinque punti scritti',
      (tester) async {
    await tester.runAsync(() async {
      // **SI ENUMERANO TUTTI E TRE, ciascuno dalla SUA sorgente dichiarata**:
      // l'Albero dall'arte, Costellazione e Loto dal file dei pallini. Prima
      // questa prova guardava il solo Albero, ed era vero allora: adesso
      // guardarne uno solo lascerebbe due sentieri senza guardia.
      var sentieriOsservati = 0;
      var confrontati = 0;
      final diversi = <String>[];
      for (final sentiero in Sentieri.tutti) {
        final scritti = AncoraggiDeiSentieri.di(sentiero);
        if (scritti == null) continue;
        sentieriOsservati++;
        final regola = RegoleDelleTreArti.per(sentiero);
        final sorgente = RegoleDelleTreArti.sorgenteDi(sentiero);
        final file = File(RegoleDelleTreArti.daDoveSiLegge(sentiero));
        expect(file.existsSync(), isTrue,
            reason: '${sentiero.name}: la sorgente degli ancoraggi non esiste '
                'più: ${file.path}');
        final codice = await ui.instantiateImageCodec(await file.readAsBytes());
        final immagine = (await codice.getNextFrame()).image;
        final adesso = LetturaDegliAncoraggi.leggi(
            await crudo(immagine), immagine.width, immagine.height, regola,
            raggruppaPerColore: sorgente == SorgenteDegliAncoraggi.pallini);
        expect(adesso.length, scritti.length);
        for (var i = 0; i < adesso.length; i++) {
          confrontati++;
          final a = adesso[i], b = scritti[i];
          if ((a.x - b.x).abs() > 0.0001 ||
              (a.y - b.y).abs() > 0.0001 ||
              a.gruppo != b.gruppo ||
              a.eGrande != b.eGrande) {
            diversi.add('${sentiero.name} numero ${i + 1}: adesso $a, '
                'scritto $b');
          }
        }
      }
      // **QUANTE OSSERVAZIONI, e cade se sono zero.**
      // ignore: avoid_print
      print('ORDINE T VOCE 01: sentieri riletti $sentieriOsservati, ancoraggi '
          'confrontati $confrontati');
      expect(sentieriOsservati, greaterThan(0),
          reason: 'nessun sentiero riletto: la prova gira a vuoto');
      expect(confrontati, greaterThan(0),
          reason: 'la prova non ha confrontato nessun ancoraggio');
      expect(diversi, isEmpty,
          reason: 'la sorgente non produce più i punti scritti nel dato. '
              'Rilancia flutter test tool/ancoraggi_dai_sentieri.dart e GUARDA '
              'le immagini di verifica prima di committare. '
              '${diversi.take(4).join(" | ")}');
    });
  });

  testWidgets('ogni sentiero con arte ha cinque gruppi da undici, un grande',
      (tester) async {
    await tester.runAsync(() async {
      var osservati = 0;
      final colpe = <String>[];
      for (final sentiero in Sentieri.tutti) {
        final a = AncoraggiDeiSentieri.di(sentiero);
        if (a == null) continue;
        osservati++;
        // La convalida e' la stessa del lettore: un solo punto che giudica.
        try {
          LetturaDegliAncoraggi.convalida(a, 941, 1672, sentiero.name);
        } on AncoraggiNonValidi catch (e) {
          colpe.add(e.messaggio);
        }
        // E l'ordine dei gruppi sale: il gruppo 0 sta piu' in basso del 4.
        final grandi = a.where((p) => p.eGrande).toList();
        for (var g = 1; g < grandi.length; g++) {
          if (grandi[g].y >= grandi[g - 1].y) {
            colpe.add('${sentiero.name}: il gruppo $g non sta piu\' in alto '
                'del gruppo ${g - 1}, e il cammino deve salire');
          }
        }
      }
      // ignore: avoid_print
      print('ORDINE T VOCE 01: sentieri con arte osservati $osservati');
      expect(osservati, greaterThan(0),
          reason: 'nessun sentiero ha ancoraggi: la prova non guarda niente');
      expect(colpe, isEmpty, reason: colpe.join(' | '));
    });
  });

  testWidgets('una tavola di pallini SANA da\' cinquantacinque ancoraggi',
      (tester) async {
    await tester.runAsync(() async {
      final i = await tavolaDeiPallini();
      final a = LetturaDegliAncoraggi.leggi(
          await crudo(i), i.width, i.height, RegoleDelleTreArti.pallini);
      expect(a.length, 55);
      expect(a.where((p) => p.eGrande).length, 5);
      for (var g = 0; g < 5; g++) {
        expect(a.where((p) => p.gruppo == g).length, 11,
            reason: 'il gruppo $g non ha undici punti');
      }
    });
  });

  testWidgets('ROSSO: un gruppo con nove piccoli cade dicendo QUALE e QUANTI',
      (tester) async {
    await tester.runAsync(() async {
      final storta = await tavolaDeiPallini(quantiPiccoli: 9);
      // **L'INIEZIONE SI VERIFICA PRIMA DI LEGGERE L'ESITO.** Una tavola
      // costruita male che per sbaglio esce sana lascerebbe la prova verde su
      // codice intatto, e quel verde non si distingue da un rosso mai fatto.
      final macchie = LetturaDegliAncoraggi.elementi(
          LetturaDegliAncoraggi.macchie(await crudo(storta), storta.width,
              storta.height, RegoleDelleTreArti.pallini),
          RegoleDelleTreArti.pallini);
      expect(macchie.length, 50,
          reason: 'INIEZIONE NON ENTRATA: volevo una tavola con cinque gruppi '
              'da nove piccoli piu\' il grande, cioe\' cinquanta elementi, e ne '
              'ho contati ${macchie.length}');
      // ignore: avoid_print
      print('ORDINE T VOCE 01: iniezione ENTRATA, la tavola storta porta '
          '${macchie.length} elementi invece di 55');
      final byte = await crudo(storta);
      expect(
          () => LetturaDegliAncoraggi.leggi(
              byte, storta.width, storta.height, RegoleDelleTreArti.pallini),
          throwsA(isA<AncoraggiNonValidi>().having((e) => e.messaggio,
              'messaggio', contains('50 elementi invece di 55'))));
    });
  });

  testWidgets('ROSSO: due grandi nello stesso gruppo cadono parlando',
      (tester) async {
    await tester.runAsync(() async {
      final storta = await tavolaDeiPallini(quantiGrandi: 2, quantiPiccoli: 9);
      final macchie = LetturaDegliAncoraggi.elementi(
          LetturaDegliAncoraggi.macchie(await crudo(storta), storta.width,
              storta.height, RegoleDelleTreArti.pallini),
          RegoleDelleTreArti.pallini);
      // Cinque gruppi da due grandi piu' nove piccoli: cinquantacinque elementi,
      // quindi il conto TOTALE torna e a cadere deve essere il conto dei grandi.
      expect(macchie.length, 55,
          reason: 'INIEZIONE NON ENTRATA: volevo cinquantacinque elementi con '
              'due grandi per gruppo, ne ho contati ${macchie.length}');
      final grandi = macchie.where((m) => m.diametro > 40).length;
      expect(grandi, 10,
          reason: 'INIEZIONE NON ENTRATA: i grandi dovevano essere dieci, sono '
              '$grandi');
      // ignore: avoid_print
      print('ORDINE T VOCE 01: iniezione ENTRATA, la tavola porta $grandi '
          'elementi grandi invece di 5');
      final byte = await crudo(storta);
      expect(
          () => LetturaDegliAncoraggi.leggi(
              byte, storta.width, storta.height, RegoleDelleTreArti.pallini),
          throwsA(isA<AncoraggiNonValidi>().having(
              (e) => e.messaggio, 'messaggio', contains('grandi sono 10'))));
    });
  });

  test('ROSSO: due punti sovrapposti cadono con la distanza', () {
    // Una lista sana, e poi DUE PUNTI portati uno sopra l'altro.
    final vicini = <AncoraggioDelSentiero>[];
    for (var g = 0; g < 5; g++) {
      for (var k = 0; k < 10; k++) {
        vicini.add(AncoraggioDelSentiero(
            x: 0.10 + k * 0.08, y: 0.10 + g * 0.15, gruppo: g, eGrande: false));
      }
      vicini.add(AncoraggioDelSentiero(
          x: 0.90, y: 0.10 + g * 0.15, gruppo: g, eGrande: true));
    }
    // L'INIEZIONE: il secondo punto si sposta addosso al primo.
    vicini[1] = AncoraggioDelSentiero(
        x: vicini[0].x + 0.008, y: vicini[0].y, gruppo: 0, eGrande: false);
    // **E SI VERIFICA CHE SIA ENTRATA PRIMA DI LEGGERE L'ESITO.**
    final dx = (vicini[0].x - vicini[1].x) * 941;
    final dy = (vicini[0].y - vicini[1].y) * 1672;
    final d = math.sqrt(dx * dx + dy * dy);
    expect(d, lessThan(LetturaDegliAncoraggi.distanzaMinimaInPixel),
        reason: 'INIEZIONE NON ENTRATA: i due punti distano '
            '${d.toStringAsFixed(1)} pixel, che non sta sotto il minimo di '
            '${LetturaDegliAncoraggi.distanzaMinimaInPixel}');
    // ignore: avoid_print
    print('ORDINE T VOCE 01: iniezione ENTRATA, due punti a '
        '${d.toStringAsFixed(1)} pixel');
    expect(
        () => LetturaDegliAncoraggi.convalida(vicini, 941, 1672, 'finta'),
        throwsA(isA<AncoraggiNonValidi>()
            .having((e) => e.messaggio, 'messaggio', contains('distano'))));
  });

  test('ROSSO: un punto fuori dalla tela cade col suo numero', () {
    final fuori = <AncoraggioDelSentiero>[];
    for (var g = 0; g < 5; g++) {
      for (var k = 0; k < 10; k++) {
        fuori.add(AncoraggioDelSentiero(
            x: 0.1 + k * 0.08, y: 0.1 + g * 0.15, gruppo: g, eGrande: false));
      }
      fuori.add(AncoraggioDelSentiero(
          x: 0.9, y: 0.1 + g * 0.15, gruppo: g, eGrande: true));
    }
    // L'iniezione: il terzo punto esce dalla tela.
    fuori[2] = const AncoraggioDelSentiero(
        x: 1.4, y: 0.1, gruppo: 0, eGrande: false);
    expect(fuori[2].x, greaterThan(1.0),
        reason: 'INIEZIONE NON ENTRATA: il punto e\' ancora dentro la tela');
    // ignore: avoid_print
    print('ORDINE T VOCE 01: iniezione ENTRATA, un punto a x = ${fuori[2].x}');
    expect(
        () => LetturaDegliAncoraggi.convalida(fuori, 941, 1672, 'finta'),
        throwsA(isA<AncoraggiNonValidi>().having((e) => e.messaggio, 'messaggio',
            allOf(contains('numero 3'), contains('fuori dalla tela')))));
  });

  test('l\'immagine di verifica esiste per ogni sentiero con arte', () {
    var osservati = 0;
    final mancanti = <String>[];
    for (final sentiero in Sentieri.tutti) {
      if (AncoraggiDeiSentieri.di(sentiero) == null) continue;
      osservati++;
      final f = File('docs/preview/ancoraggi_${sentiero.name}.png');
      if (!f.existsSync()) mancanti.add(f.path);
    }
    // ignore: avoid_print
    print('ORDINE T VOCE 01: immagini di verifica cercate $osservati');
    expect(osservati, greaterThan(0));
    expect(mancanti, isEmpty,
        reason: 'senza l\'immagine di verifica nessuno puo\' dire se i punti '
            'sono i punti GIUSTI: ${mancanti.join(", ")}');
  });
}
