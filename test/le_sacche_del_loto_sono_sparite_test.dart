import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

/// LE SACCHE BIANCHE DEL LOTO SONO SPARITE. Ordine AF voce 01.
///
/// **Il difetto, visto da Mauro.** Lo scontorno per inondazione dal bordo non
/// raggiunge il bianco chiuso dentro l'arte: fra i petali e gli steli restavano
/// sacche di fondo bianco OPACHE, e sul fondo scuro dell'app si vedevano forte.
/// Adesso lo strumento le rende trasparenti, con una protezione: dentro i
/// cinquantacinque dischi delle perle e dei centri non si tocca niente, perche'
/// i riflessi sono bianchi anche loro e sono arte.
///
/// **La soglia dei cento pixel viene da un baratro misurato, non da una
/// scelta**: i lustrini d'arte residui (riflessi sull'oro, bordi ricampionati)
/// misurano al massimo 13 pixel, le sacche vere partivano da 839. Cento sta nel
/// mezzo e non tocca nessuna delle due popolazioni.
void main() {
  const arte = 'brand_assets/sentieri/loto.png';
  const pallini = 'brand_assets/sentieri/loto_pallini.png';
  const sogliaDelBianco = 235;
  const saccaMinima = 100;

  Future<(int, int, List<int>)> apri(String file) async {
    final byte = await File(file).readAsBytes();
    final codice = await ui.instantiateImageCodec(byte);
    final immagine = (await codice.getNextFrame()).image;
    final dati =
        (await immagine.toByteData(format: ui.ImageByteFormat.rawRgba))!
            .buffer
            .asUint8List();
    return (immagine.width, immagine.height, dati);
  }

  testWidgets('nessuna sacca bianca opaca fuori dai dischi delle perle',
      (tester) async {
    // **DENTRO runAsync**, perche' il codec completa sul tempo vero.
    await tester.runAsync(() async {
      final (w, h, px) = await apri(arte);
      final (pw, ph, pp) = await apri(pallini);
      expect((pw, ph), (w, h),
          reason: 'arte e pallini hanno misure diverse: i dischi non valgono');

      bool chiara(int q) {
        final i = q * 4;
        if (px[i + 3] <= 128) return false;
        final minimo =
            [px[i], px[i + 1], px[i + 2]].reduce((a, b) => a < b ? a : b);
        return minimo >= sogliaDelBianco;
      }

      // L'inondazione dal perimetro: cio' che resta e' chiuso dentro l'arte.
      final visto = List<bool>.filled(w * h, false);
      final coda = <int>[];
      void semina(int x, int y) {
        final q = y * w + x;
        if (chiara(q) && !visto[q]) {
          visto[q] = true;
          coda.add(q);
        }
      }

      for (var x = 0; x < w; x++) {
        semina(x, 0);
        semina(x, h - 1);
      }
      for (var y = 0; y < h; y++) {
        semina(0, y);
        semina(w - 1, y);
      }
      while (coda.isNotEmpty) {
        final q = coda.removeLast();
        final x = q % w, y = q ~/ w;
        for (final d in const [
          [1, 0],
          [-1, 0],
          [0, 1],
          [0, -1]
        ]) {
          final nx = x + d[0], ny = y + d[1];
          if (nx < 0 || ny < 0 || nx >= w || ny >= h) continue;
          final n = ny * w + nx;
          if (chiara(n) && !visto[n]) {
            visto[n] = true;
            coda.add(n);
          }
        }
      }

      // Le regioni chiare chiuse: sopra la soglia e fuori dai dischi = sacca.
      var sacche = 0;
      var risparmiateNeiDischi = 0;
      final esempi = <String>[];
      for (var q = 0; q < w * h; q++) {
        if (!chiara(q) || visto[q]) continue;
        visto[q] = true;
        final pila = <int>[q];
        var quanti = 0;
        var toccaUnDisco = false;
        var cx = 0, cy = 0;
        while (pila.isNotEmpty) {
          final t = pila.removeLast();
          quanti++;
          cx += t % w;
          cy += t ~/ w;
          if (pp[t * 4 + 3] > 128) toccaUnDisco = true;
          final x = t % w, y = t ~/ w;
          for (final d in const [
            [1, 0],
            [-1, 0],
            [0, 1],
            [0, -1]
          ]) {
            final nx = x + d[0], ny = y + d[1];
            if (nx < 0 || ny < 0 || nx >= w || ny >= h) continue;
            final n = ny * w + nx;
            if (chiara(n) && !visto[n]) {
              visto[n] = true;
              pila.add(n);
            }
          }
        }
        if (toccaUnDisco) {
          risparmiateNeiDischi++;
        } else if (quanti >= saccaMinima) {
          sacche++;
          if (esempi.length < 5) {
            esempi.add('$quanti pixel a (${cx ~/ quanti},${cy ~/ quanti})');
          }
        }
      }

      // **ZERO PIXEL TRASPARENTI DENTRO I DISCHI**: la protezione dei riflessi.
      var toltiNeiDischi = 0;
      for (var q = 0; q < w * h; q++) {
        if (px[q * 4 + 3] == 0 && pp[q * 4 + 3] > 128) toltiNeiDischi++;
      }

      // **QUANTE OSSERVAZIONI, e cade se il quadro e' irriconoscibile.**
      // ignore: avoid_print
      print('ORDINE AF VOCE 01: sacche sopra $saccaMinima pixel: $sacche, '
          'regioni risparmiate nei dischi: $risparmiateNeiDischi, pixel '
          'trasparenti nei dischi: $toltiNeiDischi');
      expect(risparmiateNeiDischi, greaterThanOrEqualTo(40),
          reason: 'i riflessi delle perle risparmiati sono '
              '$risparmiateNeiDischi: se fossero pochi, o i dischi sono nel '
              'posto sbagliato o i riflessi sono stati mangiati');
      expect(sacche, 0,
          reason: 'restano $sacche sacche di fondo bianco opache fuori dai '
              'dischi: ${esempi.join(" | ")}. Sul fondo scuro dell\'app si '
              'vedono, ed e\' il difetto che Mauro ha indicato per primo');
      expect(toltiNeiDischi, 0,
          reason: 'lo scontorno ha reso trasparenti $toltiNeiDischi pixel '
              'DENTRO i dischi delle perle: i riflessi sono arte e non si '
              'toccano');
    });
  });
}
