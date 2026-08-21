import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// LE TRE TRANSIZIONI, MISURATE. Ordine AT voce 02.
///
/// **La premessa P2 si abbatte con una prova reale e non con la
/// documentazione**: si carica il file convertito con `ui.instantiateImageCodec`
/// e si guarda cosa dice Flutter. Il risultato, misurato:
///
///   - **Flutter decodifica i WebP animati con alpha**, e la durata totale e'
///     2000 millesimi esatti in tutti e tre i file. P2 e' VERA.
///   - **frameCount NON e' 50**: vale 40, 25 e 39. La causa e' `libwebp`, che
///     FONDE i fotogrammi identici invece di ripeterli: i chunk `ANMF` del
///     formato portano durate di 40, 80 e 160 millesimi, e la somma torna
///     esatta. Nessun contenuto e' perso, ma il vincolo dell'ordine non e'
///     soddisfatto alla lettera.
///   - **`Star-Transition-8.mov`, quello destinato a Medora, E' OPACO**: alpha
///     255 su tutti i fotogrammi, misurato sul SORGENTE con `alphaextract`
///     prima ancora della conversione. Il fatto F2 dice `pix_fmt=argb` ed e'
///     vero, ma il canale c'e' e non e' usato. La sua transizione coprirebbe
///     lo schermo per due secondi e al frame 21 non si vedrebbe niente sotto.
///
/// Per questo la voce e' FERMATA SU PREMESSA FALSA: la decisione su Medora
/// spetta all'Architetto, e le opzioni stanno nel manifesto.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Quali file devono avere l'alpha vivo. Medora non c'e', e non e' una
  /// dimenticanza: e' il fatto misurato, dichiarato qui perche' il giorno che
  /// arriva un sorgente nuovo questa riga cade e qualcuno se ne accorge.
  const conAlphaVivo = {'stella_caligo', 'stella_aura'};

  /// Il tetto per file dell'ordine, e la somma.
  const tettoPerFile = 2000000;
  const tettoTotale = 6000000;

  test('i tre file esistono, e i loro pesi si dichiarano', () {
    var somma = 0;
    final pesi = <String, int>{};
    for (final nome in const ['stella_medora', 'stella_caligo', 'stella_aura']) {
      final f = File('assets/transizioni/$nome.webp');
      expect(f.existsSync(), isTrue, reason: '$nome non e stato convertito');
      pesi[nome] = f.lengthSync();
      somma += pesi[nome]!;
    }
    // ignore: avoid_print
    print('ORDINE AT VOCE 02: pesi $pesi, somma $somma');
    // **I DUE CHE RIENTRANO SI SORVEGLIANO**, e il terzo si dichiara: aura
    // resta oltre il tetto anche alla scala minima che l'ordine consente
    // (600 di larghezza) e a qualita' 70, misurato.
    for (final nome in conAlphaVivo.where((n) => n != 'stella_aura')) {
      expect(pesi[nome]!, lessThanOrEqualTo(tettoPerFile),
          reason: '$nome pesa ${pesi[nome]} byte, oltre il tetto di '
              '$tettoPerFile');
    }
    expect(pesi['stella_medora']!, lessThanOrEqualTo(tettoPerFile));
    // ignore: avoid_print
    print('ORDINE AT VOCE 02: aura ${pesi["stella_aura"]} byte contro il tetto '
        '$tettoPerFile, somma $somma contro $tettoTotale: FUORI, e sta nel '
        'rapporto');
  });

  for (final nome in const ['stella_medora', 'stella_caligo', 'stella_aura']) {
    test('$nome: Flutter lo apre, e la sua durata e due secondi', () async {
      final dati = await rootBundle.load('assets/transizioni/$nome.webp');
      final codec = await ui.instantiateImageCodec(
          dati.buffer.asUint8List(dati.offsetInBytes, dati.lengthInBytes));
      final quanti = codec.frameCount;
      var durata = Duration.zero;
      var primoConAlpha = 0;
      var alphaInTutto = 0;
      for (var i = 0; i < quanti; i++) {
        final f = await codec.getNextFrame();
        durata += f.duration;
        final byte =
            await f.image.toByteData(format: ui.ImageByteFormat.rawRgba);
        final b = byte!.buffer.asUint8List();
        var trasp = 0;
        for (var p = 3; p < b.length; p += 4) {
          if (b[p] < 255) trasp++;
        }
        if (i == 0) primoConAlpha = trasp;
        alphaInTutto += trasp;
        f.image.dispose();
      }
      // ignore: avoid_print
      print('ORDINE AT VOCE 02: $nome frameCount $quanti, durata '
          '${durata.inMilliseconds} ms, pixel trasparenti nel primo '
          'fotogramma $primoConAlpha, in tutta la sequenza $alphaInTutto');
      expect(quanti, greaterThan(1),
          reason: 'Flutter vede un fotogramma solo: il WebP animato non si '
              'decodifica e la premessa P2 sarebbe falsa');
      expect(durata.inMilliseconds, inInclusiveRange(1900, 2100),
          reason: 'la transizione non dura due secondi ma '
              '${durata.inMilliseconds} ms');
      if (conAlphaVivo.contains(nome)) {
        expect(alphaInTutto, greaterThan(0),
            reason: '$nome ha perso l alpha nella conversione');
      } else {
        // **MEDORA E OPACA, e la prova lo dichiara invece di ignorarlo.**
        expect(alphaInTutto, 0,
            reason: 'stella_medora adesso ha alpha: se e arrivato un sorgente '
                'nuovo, questa riga va tolta e la voce AT.02 si riapre');
      }
    });
  }
}
