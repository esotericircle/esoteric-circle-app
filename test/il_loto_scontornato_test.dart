import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

/// L'ARTE DEL LOTO E' SCONTORNATA DAVVERO. Ordine AE voce 01.
///
/// **Cosa sorveglia.** Il Loto delle perle nasce da un sorgente con fondo bianco
/// pieno e senza trasparenza: `docs/preview/journal_loto_nuovo-1.png`, che non si
/// modifica mai sul posto. `tool/scontorna_loto.py` toglie il bianco COLLEGATO AL
/// BORDO per inondazione, mai il bianco ovunque, perche' i riflessi delle perle
/// sono bianchi anche loro, e scrive `brand_assets/sentieri/loto.png` a 941 per
/// 1672. Questa prova apre tutti e due i file e pretende che lo scontorno sia
/// avvenuto e che non abbia mangiato arte.
///
/// **Il perimetro non e' tutto trasparente, ed e' un fatto dell'arte, non un
/// difetto dello scontorno**: la corona del fiore in cima tocca il bordo del
/// sorgente per disegno, 66 pixel non bianchi sul perimetro. La grandezza giusta
/// quindi non e' "perimetro tutto trasparente" ma la CORRISPONDENZA: ogni pixel
/// opaco sul perimetro dell'arte pronta deve corrispondere ad arte vera nel
/// sorgente, mai a fondo bianco sopravvissuto.
void main() {
  const arte = 'brand_assets/sentieri/loto.png';
  const sorgente = 'docs/preview/journal_loto_nuovo-1.png';

  /// La soglia del bianco, la stessa dichiarata nello strumento: un pixel del
  /// sorgente e' fondo quando il suo canale minimo sta sopra questo valore.
  const sogliaDelBianco = 235;

  Future<(int, int, List<int>)> apri(String file) async {
    final byte = await File(file).readAsBytes();
    final codice = await ui.instantiateImageCodec(byte);
    final immagine = (await codice.getNextFrame()).image;
    final dati = (await immagine.toByteData(format: ui.ImageByteFormat.rawRgba))!
        .buffer
        .asUint8List();
    return (immagine.width, immagine.height, dati);
  }

  testWidgets('lo scontorno e\' avvenuto e non ha mangiato arte',
      (tester) async {
    // **DENTRO runAsync**, perche' il codec completa sul tempo vero.
    await tester.runAsync(() async {
      final (w, h, px) = await apri(arte);

      // **L'ALFA MINIMO PER PRIMO**: e' la firma dello scontorno. Il sorgente ha
      // alfa minimo 238, l'arte pronta deve avere pixel del tutto trasparenti.
      var alfaMinimo = 255;
      for (var i = 3; i < px.length; i += 4) {
        if (px[i] < alfaMinimo) alfaMinimo = px[i];
      }
      expect(alfaMinimo, 0,
          reason: 'l\'alfa minimo e\' $alfaMinimo invece di zero: questo file '
              'non e\' stato scontornato, e\' ancora il fondo pieno');

      expect((w, h), (941, 1672),
          reason: 'l\'arte pronta misura $w per $h invece di 941 per 1672');

      final (sw, sh, sp) = await apri(sorgente);
      // **LA CORRISPONDENZA TOLLERA UN PIXEL DI VICINATO nel sorgente**, e non
      // e' una soglia allentata: e' il supporto del ricampionamento. Un pixel
      // dell'arte pronta nasce da un intorno di pixel del sorgente, quindi sul
      // bordo di un tratto un pixel con alfa parziale puo' mappare, arrotondando,
      // sul pixel bianco accanto al tratto. Fondo "vero" e' un intorno TUTTO
      // bianco; arte "vera" e' un intorno che di bianco non ha niente.
      bool intornoTuttoBianco(int x, int y) {
        final sx = (x * sw / w).round().clamp(0, sw - 1);
        final sy = (y * sh / h).round().clamp(0, sh - 1);
        for (var dy = -1; dy <= 1; dy++) {
          for (var dx = -1; dx <= 1; dx++) {
            final nx = (sx + dx).clamp(0, sw - 1);
            final ny = (sy + dy).clamp(0, sh - 1);
            final i = (ny * sw + nx) * 4;
            final minimo = [sp[i], sp[i + 1], sp[i + 2]]
                .reduce((a, b) => a < b ? a : b);
            if (minimo < sogliaDelBianco) return false;
          }
        }
        return true;
      }

      bool intornoTuttoArte(int x, int y) {
        final sx = (x * sw / w).round().clamp(0, sw - 1);
        final sy = (y * sh / h).round().clamp(0, sh - 1);
        for (var dy = -1; dy <= 1; dy++) {
          for (var dx = -1; dx <= 1; dx++) {
            final nx = (sx + dx).clamp(0, sw - 1);
            final ny = (sy + dy).clamp(0, sh - 1);
            final i = (ny * sw + nx) * 4;
            final minimo = [sp[i], sp[i + 1], sp[i + 2]]
                .reduce((a, b) => a < b ? a : b);
            if (minimo >= sogliaDelBianco) return false;
          }
        }
        return true;
      }

      // **IL PERIMETRO: ogni pixel opaco corrisponde ad arte vera.**
      var opachiSulPerimetro = 0;
      final fughe = <String>[];
      void perimetro(int x, int y) {
        final a = px[(y * w + x) * 4 + 3];
        if (a == 0) return;
        opachiSulPerimetro++;
        if (intornoTuttoBianco(x, y) && fughe.length < 5) {
          fughe.add('($x,$y) alfa $a su fondo bianco del sorgente');
        }
      }

      for (var x = 0; x < w; x++) {
        perimetro(x, 0);
        perimetro(x, h - 1);
      }
      for (var y = 1; y < h - 1; y++) {
        perimetro(0, y);
        perimetro(w - 1, y);
      }
      // ignore: avoid_print
      print('ORDINE AE VOCE 01: perimetro opaco $opachiSulPerimetro pixel, '
          'tutti su arte vera: ${fughe.isEmpty}');
      expect(fughe, isEmpty,
          reason: 'sul perimetro c\'e\' fondo bianco sopravvissuto allo '
              'scontorno: ${fughe.join(" | ")}');

      // **NESSUN BUCO DENTRO L'ARTE**: ogni pixel del tutto trasparente deve
      // corrispondere a fondo bianco del sorgente, mai ad arte. E' il presidio
      // contro lo scontorno ingenuo che buca i riflessi.
      var trasparenti = 0;
      final buchi = <String>[];
      for (var p = 0; p < w * h; p++) {
        if (px[p * 4 + 3] != 0) continue;
        trasparenti++;
        final x = p % w, y = p ~/ w;
        if (intornoTuttoArte(x, y) && buchi.length < 5) {
          buchi.add('($x,$y)');
        }
      }
      // ignore: avoid_print
      print('ORDINE AE VOCE 01: pixel trasparenti $trasparenti, buchi su arte '
          'vera: ${buchi.length}');
      expect(trasparenti, greaterThan(0),
          reason: 'zero pixel trasparenti: la prova starebbe guardando un file '
              'non scontornato senza accorgersene');
      expect(buchi, isEmpty,
          reason: 'lo scontorno ha bucato l\'arte in questi punti: '
              '${buchi.join(" | ")}');
    });
  });
}
