import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/sigilli/ancoraggi_dei_sentieri.dart';
import 'package:esoteric_circle/core/sigilli/forme_dei_sentieri.dart';
import 'package:esoteric_circle/core/sigilli/regole_delle_tre_arti.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/design_system/tokens/color_tokens.dart';
import 'package:esoteric_circle/features/sigilli/journal_dall_arte.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// UNA LAMPADINA ACCESA SI DISTINGUE DA UNA SPENTA. Ordine AF voce 02.
///
/// **Il difetto, visto da Mauro**: una perla accesa non si distingueva da una
/// spenta, la luce era una scintilla tenue. Adesso l'elemento acceso si
/// ridipinge come una lampadina, gradiente pieno da bianco caldo a oro caldo
/// col riflesso forte, senza sfocature e senza `BlendMode.plus`, perche' quella
/// tecnica e' la stessa sospettata di non comparire affatto sul telefono.
///
/// **Cosa misura, e perche' NON il rapporto.** Si monta l'arte vera con le luci
/// del pittore vero, dodici accesi, e si guarda la luminanza mediana dentro il
/// cuore di ogni disco. Il rapporto acceso su spento era la prima grandezza
/// provata ed era quella SBAGLIATA: misura la base piu' della lampadina, e
/// l'Albero, le cui sfere di peltro spente partono gia' da 122, faceva 1,72 con
/// una lampadina identica a quella degli altri due (acceso a 210 su tutti e
/// tre). La grandezza giusta e' doppia, e viene da cosa dev'essere vero:
/// **una lampadina accesa e' LUMINOSA in assoluto**, sopra i 180 su 255, e
/// **si distingue dallo spento con uno scarto che l'occhio non manca**, almeno
/// 60 punti, un quarto della scala. Misurato: acceso 200, 210 e 211; scarti
/// 156, 88 e 122. Tutti dentro con margine, e la scintilla vecchia non passava.
void main() {
  const lumeMinimoDellAcceso = 180.0;
  const scartoMinimo = 60.0;

  testWidgets('un elemento acceso e\' almeno il doppio piu\' luminoso',
      (tester) async {
    // **DENTRO runAsync**, perche' codec e toImage completano sul tempo vero.
    await tester.runAsync(() async {
      var sentieriOsservati = 0;
      final fiacchi = <String>[];
      for (final sentiero in Sentieri.tutti) {
        final fileArte = File(RegoleDelleTreArti.arteDi(sentiero));
        if (!fileArte.existsSync()) continue;
        sentieriOsservati++;
        final codice =
            await ui.instantiateImageCodec(await fileArte.readAsBytes());
        final arte = (await codice.getNextFrame()).image;

        const larghezza = 360.0, altezza = 580.0;
        final ordinati = Sentieri.di(sentiero).toList()
          ..sort((a, b) => Sentieri.ordineNelCammino(a)
              .compareTo(Sentieri.ordineNelCammino(b)));
        final accesi = ordinati.take(12).map((t) => t.id).toSet();

        final registratore = ui.PictureRecorder();
        final tela = Canvas(registratore);
        final wArte = arte.width.toDouble(), hArte = arte.height.toDouble();
        final scala = [larghezza / wArte, altezza / hArte]
            .reduce((a, b) => a < b ? a : b);
        final dx = (larghezza - wArte * scala) / 2;
        final dy = (altezza - hArte * scala) / 2;
        tela.drawImageRect(arte, Rect.fromLTWH(0, 0, wArte, hArte),
            Rect.fromLTWH(dx, dy, wArte * scala, hArte * scala), Paint());
        PittoreDelleLuci(
          sentiero: sentiero,
          accesi: accesi,
          evidenziato: null,
          oro: ColorTokens.gold,
          oroTenue: ColorTokens.goldLight,
          respiro: 1.0,
          effettiPieni: true,
        ).paint(tela, const Size(larghezza, altezza));
        final resa = await registratore
            .endRecording()
            .toImage(larghezza.round(), altezza.round());
        final px = (await resa.toByteData(format: ui.ImageByteFormat.rawRgba))!
            .buffer
            .asUint8List();

        final ancoraggi = AncoraggiDeiSentieri.di(sentiero)!;
        final forme = FormeDeiSentieri.di(sentiero)!;
        double lumenDelDisco(int i) {
          final cx = dx + ancoraggi[i].x * wArte * scala;
          final cy = dy + ancoraggi[i].y * hArte * scala;
          // Il raggio equivalente della forma sulla tela, e si campiona nel
          // CUORE, a meta' raggio: il bordo porta l'ombra della sfera e
          // sporcherebbe la mediana da tutte e due le parti.
          final raggio = math.sqrt(forme[i].area / math.pi) * scala / 2;
          final rQ = math.max(2.0, raggio);
          final v = <int>[];
          final w = resa.width;
          for (var oy = -rQ.round(); oy <= rQ.round(); oy++) {
            for (var ox = -rQ.round(); ox <= rQ.round(); ox++) {
              if (ox * ox + oy * oy > rQ * rQ) continue;
              final x = (cx + ox).round(), y = (cy + oy).round();
              if (x < 0 || y < 0 || x >= w || y >= resa.height) continue;
              final k = (y * w + x) * 4;
              v.add((px[k] * 299 + px[k + 1] * 587 + px[k + 2] * 114) ~/ 1000);
            }
          }
          if (v.isEmpty) return 0;
          v.sort();
          return v[v.length ~/ 2].toDouble();
        }

        final lumAccesi = <double>[];
        final lumSpenti = <double>[];
        for (var i = 0; i < ancoraggi.length; i++) {
          (accesi.contains(ordinati[i].id) ? lumAccesi : lumSpenti)
              .add(lumenDelDisco(i));
        }
        lumAccesi.sort();
        lumSpenti.sort();
        final medAcceso = lumAccesi[lumAccesi.length ~/ 2];
        final medSpento = lumSpenti[lumSpenti.length ~/ 2];
        // ignore: avoid_print
        print('ORDINE AF VOCE 02: ${sentiero.name}, luminanza mediana acceso '
            '${medAcceso.toStringAsFixed(0)}, spento '
            '${medSpento.toStringAsFixed(0)}, rapporto '
            '${(medAcceso / medSpento).toStringAsFixed(2)}');
        if (medAcceso < lumeMinimoDellAcceso ||
            medAcceso - medSpento < scartoMinimo) {
          fiacchi
              .add('${sentiero.name}: acceso ${medAcceso.toStringAsFixed(0)} '
                  'contro spento ${medSpento.toStringAsFixed(0)}');
        }
      }
      // **QUANTI SENTIERI, e cade se sono zero.**
      // ignore: avoid_print
      print('ORDINE AF VOCE 02: sentieri osservati $sentieriOsservati');
      expect(sentieriOsservati, Sentieri.tutti.length);
      expect(fiacchi, isEmpty,
          reason: 'una lampadina accesa deve essere almeno il doppio piu\' '
              'luminosa di una spenta, e qui non lo e\': '
              '${fiacchi.join(" | ")}');
    });
  });
}
