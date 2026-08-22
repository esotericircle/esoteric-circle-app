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
///   - **`Star-Transition-8.mov`, quello destinato a Medora, ERA OPACO**:
///     alpha 255 su tutti i fotogrammi, misurato sul SORGENTE con
///     `alphaextract` prima ancora della conversione.
///
/// **ORDINE AU VOCI 01 E 02: tutte e tre le fermate sono cadute.** Il
/// fondatore ha scelto la ricostruzione dell'alpha dalla luminanza, e siccome
/// il fondo del file 8 e' nero la luminanza E' la maschera. Insieme e' caduto
/// anche il peso, e per una ragione che nessuno aveva visto: **`libwebp`
/// comprime il canale alpha SENZA PERDITA anche quando il colore va a
/// perdita**, quindi un alpha con duecentocinquantasei livelli di sfumatura
/// costa piu' dell'immagine che accompagna. Ridotta la maschera a otto
/// gradini, Medora passa da 6.660.786 a 2.291.038 byte e **Aura torna a 720
/// per 1280 pesando 1.900.416**, cioe' meno del tetto VECCHIO che l'aveva
/// costretta a 600 per 1067.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// **ADESSO CE L'HANNO TUTTI E TRE**, ordine AU voce 01. Medora e' entrato
  /// in questo elenco il 22 agosto 2026: l'alpha non e' arrivato da un
  /// sorgente nuovo, e' stato ricostruito dalla luminanza.
  const conAlphaVivo = {'stella_medora', 'stella_caligo', 'stella_aura'};

  /// **IL TETTO NUOVO, ordine AU voce 02**: 3 MB per file e 8,5 MB in tutto.
  /// Quello vecchio, 2 e 6, aveva costretto Aura a 600 per 1067 mentre gli
  /// altri due stavano a 720 per 1280, e il fondatore ha deciso che tre
  /// Maestri hanno la stessa dignita'. **Alla fine non e' servito**: con
  /// l'alpha a otto gradini la somma dei tre fa 5.267.170 byte, cioe' sta
  /// dentro anche il tetto vecchio.
  const tettoPerFile = 3000000;
  const tettoTotale = 8500000;

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
    // **ADESSO SI SORVEGLIANO TUTTI E TRE**, nessuno dichiarato fuori.
    for (final nome in conAlphaVivo) {
      expect(pesi[nome]!, lessThanOrEqualTo(tettoPerFile),
          reason: '$nome pesa ${pesi[nome]} byte, oltre il tetto di '
              '$tettoPerFile');
    }
    expect(somma, lessThanOrEqualTo(tettoTotale),
        reason: 'i tre filmati insieme pesano $somma byte, oltre gli '
            '$tettoTotale concessi');
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
        // Nessuno resta senza alpha: se un giorno qualcuno rimettesse un
        // sorgente opaco, questa riga lo direbbe invece di lasciarlo
        // passare in silenzio.
        fail('$nome non e nell elenco di quelli con alpha vivo, e dopo l ordine AU voce 01 ce l hanno tutti e tre');
      }
    });
  }
}
