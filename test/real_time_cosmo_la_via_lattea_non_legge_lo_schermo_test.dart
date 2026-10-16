// LA VIA LATTEA NON LEGGE LO SCHERMO. Ordine FH, voce C5 dell'aggiunta, 10
// ottobre 2026.
//
// Sul Realme la corsa della Macchina del tempo faceva 44 fotogrammi al
// secondo, e la diagnosi ha trovato il peso nella Via Lattea in modalita'
// `screen`, una fusione avanzata che legge lo schermo sotto di se' (14,7 ms
// di disegno medio contro 7,8 in `plus`). Due cose:
//
// a) la composizione della Via Lattea e' una fusione semplice, che non legge
//    lo schermo (le Porter-Duff, fino a `modulate`);
// b) il cielo e' lo STESSO di prima: sul fondo del cielo, la tessitura in
//    `screen` coi colori grigi di una volta e in `plus` coi colori moltiplicati
//    per (1 - fondo) danno gli stessi pixel, a un livello su 255.

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esoteric_circle/features/real_time_cosmo/la_via_lattea_in_scena.dart';
import 'package:esoteric_circle/features/real_time_cosmo/lo_stile_del_cielo.dart';
import 'package:flutter_test/flutter_test.dart';

/// Una tessitura di prova: una sfumatura con una macchia chiara, come la
/// Via Lattea fra buio e luce.
ui.Image _tessitura() {
  final r = ui.PictureRecorder();
  final c = ui.Canvas(r);
  c.drawRect(
    const ui.Rect.fromLTWH(0, 0, 64, 32),
    ui.Paint()
      ..shader = ui.Gradient.linear(
        ui.Offset.zero,
        const ui.Offset(64, 32),
        const [
          ui.Color(0xFF000000),
          ui.Color(0xFFFFF2D0),
          ui.Color(0xFF6070A0)
        ],
        const [0, 0.5, 1],
      ),
  );
  return r.endRecording().toImageSync(64, 32);
}

Future<Uint8List> _disegna(ui.Image tex, ui.BlendMode modo, int colore) async {
  final r = ui.PictureRecorder();
  final c = ui.Canvas(r);
  c.drawRect(
      const ui.Rect.fromLTWH(0, 0, 64, 32), ui.Paint()..color = kFondoDelCielo);
  final pennello = ui.Paint()
    ..shader = ui.ImageShader(
        tex,
        ui.TileMode.clamp,
        ui.TileMode.clamp,
        Float64List.fromList(
            const [1.0, 0, 0, 0, 0, 1.0, 0, 0, 0, 0, 1.0, 0, 0, 0, 0, 1.0]))
    ..blendMode = modo
    ..color = const ui.Color.fromRGBO(255, 255, 255, kOpacitaDellaViaLattea);
  c.drawVertices(
    ui.Vertices.raw(
      ui.VertexMode.triangles,
      Float32List.fromList([0, 0, 64, 0, 0, 32, 64, 0, 64, 32, 0, 32]),
      textureCoordinates:
          Float32List.fromList([0, 0, 64, 0, 0, 32, 64, 0, 64, 32, 0, 32]),
      colors: Int32List.fromList(List.filled(6, colore)),
    ),
    ui.BlendMode.modulate,
    pennello,
  );
  final img = r.endRecording().toImageSync(64, 32);
  final dati = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
  return dati!.buffer.asUint8List();
}

void main() {
  test('a) la composizione della Via Lattea non legge lo schermo', () {
    expect(kComposizioneDellaViaLattea.index,
        lessThanOrEqualTo(ui.BlendMode.modulate.index),
        reason: '$kComposizioneDellaViaLattea e\' una fusione avanzata');
  });

  test('b) in plus coi colori nuovi il cielo e\' quello di screen', () async {
    final tex = _tessitura();
    var peggiore = 0, confronti = 0;
    for (final luce in [255, 180, 90, 30]) {
      final grigio = 0xFF000000 | (luce << 16) | (luce << 8) | luce;
      final prima = await _disegna(tex, ui.BlendMode.screen, grigio);
      final dopo = await _disegna(
          tex, kComposizioneDellaViaLattea, coloreDelVertice(luce));
      for (var i = 0; i < prima.length; i++) {
        final d = (prima[i] - dopo[i]).abs();
        if (d > peggiore) peggiore = d;
        confronti++;
      }
    }
    // ignore: avoid_print
    print('VIA LATTEA: $confronti canali confrontati, scarto peggiore '
        '$peggiore su 255');
    expect(confronti, 4 * 64 * 32 * 4);
    expect(peggiore, lessThanOrEqualTo(1));
  });
}
