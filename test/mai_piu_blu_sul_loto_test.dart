import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/sigilli/ancoraggi_dei_sentieri.dart';
import 'package:esoteric_circle/core/sigilli/forme_dei_sentieri.dart';
import 'package:esoteric_circle/core/sigilli/regole_delle_tre_arti.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/design_system/tokens/color_tokens.dart';
import 'package:esoteric_circle/features/sigilli/journal_dall_arte.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// MAI PIU' BLU SUL LOTO. Ordine AG voce 02.
///
/// **Il difetto, con la causa vera misurata.** Mauro ha visto petali che
/// cambiano colore e tendono al blu quando la perla sopra e' illuminata, e
/// l'Architetto due lampade azzurre su cinquantacinque. La causa NON era la
/// fusione: era l'eredita' del colore della materia dentro l'alone. Due dischi
/// (gli indici 13 e 46) portano una tinta fredda quasi invisibile, 190 e 220
/// gradi con saturazione 0,050 e 0,032, e il pavimento di saturazione 0,74
/// della legge dell'ordine X la trasformava in azzurro pieno.
///
/// **La cura, dichiarata nel pittore**: sul Loto la palette e' FISSA (sempre
/// l'oro del sentiero, mai la materia) e la fusione scelta per l'alone e'
/// NESSUNA, perche' le perle stanno su petali dipinti e qualunque velo
/// colorato sopra un petalo ne cambia la tinta.
///
/// **Due misure, e la seconda sui casi che andavano al blu.** Prima: la tinta
/// dei cinquantacinque dischi accesi sta nella fascia dell'oro, enumerati
/// tutti e non campionati. Seconda: la tinta del petalo attorno alle perle 13
/// e 46 accese resta quella che aveva da spente. Si accende UNA perla alla
/// volta, cosi' nessuna linea di progresso attraversa l'anello misurato, e
/// la resa e' deterministica: la soglia e' UN grado, il passo della misura.
void main() {
  /// La fascia dell'oro: le tinte del gradiente della lampadina vanno da 40
  /// (oro caldo 0xFFE9B84D) a 42 gradi (bianco caldo 0xFFFFF3D6); la fascia
  /// li avvolge con l'aria dei mescolamenti di bordo. L'azzurro delle due
  /// lampade malate stava a 190 e 220 gradi, lontano un giro.
  const tintaMinima = 25.0;
  const tintaMassima = 60.0;
  const sogliaDelPetalo = 1.0;

  testWidgets('i cinquantacinque dischi accesi sono oro e i petali non virano',
      (tester) async {
    // **DENTRO runAsync**, perche' codec e toImage completano sul tempo vero.
    await tester.runAsync(() async {
      const sentiero = Sentiero.loto;
      final fileArte = File(RegoleDelleTreArti.arteDi(sentiero));
      expect(fileArte.existsSync(), isTrue);
      final codice =
          await ui.instantiateImageCodec(await fileArte.readAsBytes());
      final arte = (await codice.getNextFrame()).image;

      const larghezza = 360.0, altezza = 580.0;
      final ordinati = Sentieri.di(sentiero).toList()
        ..sort((a, b) => Sentieri.ordineNelCammino(a)
            .compareTo(Sentieri.ordineNelCammino(b)));
      final ancoraggi = AncoraggiDeiSentieri.di(sentiero)!;
      final forme = FormeDeiSentieri.di(sentiero)!;
      final wArte = arte.width.toDouble(), hArte = arte.height.toDouble();
      final scala =
          [larghezza / wArte, altezza / hArte].reduce((a, b) => a < b ? a : b);
      final dx = (larghezza - wArte * scala) / 2;
      final dy = (altezza - hArte * scala) / 2;

      Future<Uint8List> resa(Set<String> accesi) async {
        final registratore = ui.PictureRecorder();
        final tela = Canvas(registratore);
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
        final quadro = await registratore
            .endRecording()
            .toImage(larghezza.round(), altezza.round());
        return (await quadro.toByteData(format: ui.ImageByteFormat.rawRgba))!
            .buffer
            .asUint8List();
      }

      (double, double, double) mediane(
          Uint8List px, double cx, double cy, double daR, double aR) {
        final rs = <int>[], gs = <int>[], bs = <int>[];
        for (var oy = -aR.ceil(); oy <= aR.ceil(); oy++) {
          for (var ox = -aR.ceil(); ox <= aR.ceil(); ox++) {
            final d2 = (ox * ox + oy * oy).toDouble();
            if (d2 < daR * daR || d2 > aR * aR) continue;
            final x = (cx + ox).round(), y = (cy + oy).round();
            if (x < 0 || y < 0 || x >= larghezza || y >= altezza) continue;
            final k = (y * larghezza.round() + x) * 4;
            rs.add(px[k]);
            gs.add(px[k + 1]);
            bs.add(px[k + 2]);
          }
        }
        rs.sort();
        gs.sort();
        bs.sort();
        return (
          rs[rs.length ~/ 2].toDouble(),
          gs[gs.length ~/ 2].toDouble(),
          bs[bs.length ~/ 2].toDouble()
        );
      }

      double tintaDi((double, double, double) c) {
        final (r, g, b) = c;
        final mx = math.max(r, math.max(g, b));
        final mn = math.min(r, math.min(g, b));
        if (mx == mn) return 0;
        double t;
        if (mx == r) {
          t = 60 * (((g - b) / (mx - mn)) % 6);
        } else if (mx == g) {
          t = 60 * ((b - r) / (mx - mn) + 2);
        } else {
          t = 60 * ((r - g) / (mx - mn) + 4);
        }
        return (t + 360) % 360;
      }

      Offset centroDi(int i) => Offset(dx + ancoraggi[i].x * wArte * scala,
          dy + ancoraggi[i].y * hArte * scala);
      double raggioDi(int i) => math.max(
          math.sqrt(forme[i].area / math.pi) * scala,
          PittoreDelleLuci.pavimentoDelRaggio);

      // PRIMA MISURA: tutti e cinquantacinque accesi, ogni disco e' oro.
      final tutti = ordinati.map((t) => t.id).toSet();
      final pxTutti = await resa(tutti);
      var osservati = 0;
      final fuoriFascia = <String>[];
      for (var i = 0; i < ancoraggi.length; i++) {
        osservati++;
        final c = centroDi(i);
        final r = raggioDi(i);
        // Il cuore del disco, dal quarto al mezzo raggio: dentro il colmo
        // bianco la tinta e' instabile, sul bordo entra il petalo.
        final tinta = tintaDi(mediane(pxTutti, c.dx, c.dy, r * 0.25, r * 0.55));
        if (tinta < tintaMinima || tinta > tintaMassima) {
          fuoriFascia.add('disco $i tinta ${tinta.toStringAsFixed(0)}');
        }
      }
      // ignore: avoid_print
      print('ORDINE AG VOCE 02: dischi accesi osservati $osservati, '
          'fuori dalla fascia dell\'oro ${fuoriFascia.length}');
      expect(osservati, 55, reason: 'i dischi del Loto sono cinquantacinque');
      expect(fuoriFascia, isEmpty,
          reason: 'la palette e\' fissa e questi dischi non sono oro: '
              '${fuoriFascia.join(" | ")}');

      // SECONDA MISURA: i due casi che andavano al blu, una perla alla volta.
      //
      // **LA MISURA E' AL PIXEL, RIMIRATA DALL'ORDINE BF VOCE 02.** Prima si
      // prendeva la tinta di un colore SINTETICO, le mediane dei tre canali
      // calcolate indipendenti sull'anello: con l'alone bianco della strada 1
      // (che per aritmetica non muove la tinta di NESSUN pixel: un velo
      // bianco scala le differenze fra i canali tutte insieme) quel sintetico
      // segnava 10,1 gradi di virata, fabbricata dal pescare la mediana di R
      // da un pixel e quella di B da un altro. La tinta mediana DEI PIXEL
      // misura cio' che la guardia vuole vietare, il velo colorato che
      // sporca, ed e' anche piu' severa: un alone blu sposta la tinta di
      // ogni singolo pixel, e qui non si diluirebbe in un sintetico.
      double tintaMedianaDeiPixel(
          Uint8List px, double cx, double cy, double daR, double aR) {
        final tinte = <double>[];
        for (var oy = -aR.ceil(); oy <= aR.ceil(); oy++) {
          for (var ox = -aR.ceil(); ox <= aR.ceil(); ox++) {
            final d2 = (ox * ox + oy * oy).toDouble();
            if (d2 < daR * daR || d2 > aR * aR) continue;
            final x = (cx + ox).round(), y = (cy + oy).round();
            if (x < 0 || y < 0 || x >= larghezza || y >= altezza) continue;
            final k = (y * larghezza.round() + x) * 4;
            final r = px[k].toDouble(),
                g = px[k + 1].toDouble(),
                b = px[k + 2].toDouble();
            final mx = math.max(r, math.max(g, b));
            final mn = math.min(r, math.min(g, b));
            // Un pixel grigio non ha tinta: non puo' testimoniare.
            if (mx - mn < 4) continue;
            tinte.add(tintaDi((r, g, b)));
          }
        }
        expect(tinte, isNotEmpty,
            reason: 'nessun pixel con tinta nell\'anello: la misura non sta '
                'guardando niente');
        tinte.sort();
        return tinte[tinte.length ~/ 2];
      }

      final pxSpenti = await resa(const {});
      var casi = 0;
      for (final indice in const [13, 46]) {
        casi++;
        final c = centroDi(indice);
        final r = raggioDi(indice);
        final pxUno = await resa({ordinati[indice].id});
        final prima =
            tintaMedianaDeiPixel(pxSpenti, c.dx, c.dy, r * 1.15, r * 1.75);
        final dopo =
            tintaMedianaDeiPixel(pxUno, c.dx, c.dy, r * 1.15, r * 1.75);
        var scarto = (dopo - prima).abs();
        if (scarto > 180) scarto = 360 - scarto;
        // ignore: avoid_print
        print('ORDINE AG VOCE 02: petalo della perla $indice, tinta spenta '
            '${prima.toStringAsFixed(1)} accesa ${dopo.toStringAsFixed(1)}, '
            'scarto ${scarto.toStringAsFixed(1)} gradi');
        expect(scarto, lessThanOrEqualTo(sogliaDelPetalo),
            reason: 'accendere la perla $indice cambia la tinta del petalo '
                'attorno di ${scarto.toStringAsFixed(1)} gradi: la fusione '
                'dichiarata e\' NESSUNA e il petalo deve restare suo');
      }
      // ignore: avoid_print
      print('ORDINE AG VOCE 02: casi del blu misurati $casi');
      expect(casi, 2);
    });
  });
}
