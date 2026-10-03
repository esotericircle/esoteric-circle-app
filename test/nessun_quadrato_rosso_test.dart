import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/maestri/caligo/animal/animal_reveal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Nessun quadrato, in nessun istante della rivelazione dell'animale.
///
/// La nebbia di Caligo era dipinta con `drawRect` su tutta l'area del riquadro,
/// e l'ultimo stop del suo gradiente radiale era opaco: il riquadro finiva di
/// netto contro il fondo, quindi si vedeva un quadrato prima che l'animale
/// emergesse. Una nebbia con quattro angoli non e' una nebbia.
///
/// **Come si misura, e come NON si misura.**
///
/// Il primo tentativo usava il matcher `paints..rect`: passava senza che avessi
/// corretto nulla, quindi non misurava il difetto. Buttato.
///
/// Il secondo guardava l'intensita' assoluta agli angoli: sempre verde, perche'
/// i colori di Caligo su fondo nero sono scuri di per se'. Una prova di vista
/// aggiunta apposta ha mostrato che l'angolo valeva 0,044 e il centro 0,017,
/// cioe' che i pixel c'erano ma erano tutti scuri. Il quadrato non si vede per
/// quanto e' rosso, si vede perche' ha un BORDO NETTO.
///
/// Quindi si misura il salto attraverso il bordo del riquadro: si fotografa
/// un'area piu' larga della nebbia e si confronta la striscia appena dentro con
/// quella appena fuori. Se c'e' un gradino, si vede un quadrato.
void main() {
  const lato = 280.0;
  const area = 400.0;

  Future<ui.Image> fotografa(WidgetTester tester) async {
    final boundary = tester
        .element(find.byKey(const Key('area_prova')))
        .findRenderObject()! as RenderRepaintBoundary;
    return boundary.toImage();
  }

  /// La luminosita' media di una striscia orizzontale.
  double media(ByteData d, int w, int y, int daX, int aX) {
    var somma = 0.0;
    for (var x = daX; x < aX; x++) {
      final i = (y * w + x) * 4;
      final a = d.getUint8(i + 3) / 255;
      somma +=
          (d.getUint8(i) + d.getUint8(i + 1) + d.getUint8(i + 2)) / 3 * a / 255;
    }
    return somma / (aX - daX);
  }

  Future<void> nessunGradinoSulBordo(
      WidgetTester tester, String istante) async {
    late double dentro;
    late double fuori;
    await tester.runAsync(() async {
      final img = await fotografa(tester);
      final d = (await img.toByteData())!;
      final w = img.width;
      // Il riquadro della nebbia sta al centro dell'area: il suo bordo
      // superiore e' a (area - lato) / 2.
      final bordoY = ((area - lato) / 2).round();
      final daX = ((area - lato) / 2).round() + 4;
      final aX = daX + lato.round() - 8;
      fuori = media(d, w, bordoY - 3, daX, aX);
      dentro = media(d, w, bordoY + 3, daX, aX);
      img.dispose();
    });
    // Un gradino sul bordo e' quello che rende visibile la forma quadrata.
    expect((dentro - fuori).abs(), lessThan(0.03),
        reason: 'a $istante il bordo del riquadro fa un gradino: fuori '
            '${fuori.toStringAsFixed(3)}, dentro ${dentro.toStringAsFixed(3)}. '
            'Quel gradino e\' il quadrato che si vede prima dell\'animale');
  }

  Future<void> monta(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(area, area);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      home: RepaintBoundary(
        key: const Key('area_prova'),
        child: Container(
          width: area,
          height: area,
          color: Colors.black,
          alignment: Alignment.center,
          child: AnimalReveal(
            assetTotem: 'assets/nessun_totem_qui.png',
            palette: MaestroPalette.forKey(const ThemeKey.of(Maestro.caligo)),
            lato: lato,
          ),
        ),
      ),
    ));
  }

  testWidgets('PROVA DI VISTA: la misura distingue dentro da fuori',
      (tester) async {
    // Prima di credere a un verde, serve sapere che la misura sa vedere un
    // gradino quando c'e'. Si fotografa un quadrato dichiaratamente pieno e si
    // verifica che la misura lo denunci.
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(area, area);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      home: RepaintBoundary(
        key: const Key('area_prova'),
        child: Container(
          width: area,
          height: area,
          color: Colors.black,
          alignment: Alignment.center,
          child: Container(
              width: lato, height: lato, color: const Color(0xFFB02630)),
        ),
      ),
    ));
    await tester.pump();

    late double salto;
    await tester.runAsync(() async {
      final img = await fotografa(tester);
      final d = (await img.toByteData())!;
      final bordoY = ((area - lato) / 2).round();
      final daX = ((area - lato) / 2).round() + 4;
      salto = (media(d, img.width, bordoY + 3, daX, daX + 200) -
              media(d, img.width, bordoY - 3, daX, daX + 200))
          .abs();
      img.dispose();
    });
    expect(salto, greaterThan(0.03),
        reason: 'la misura non riconosce nemmeno un quadrato pieno: e\' cieca, '
            'quindi ogni verde che darebbe sarebbe senza valore');
  });

  testWidgets('Al primo frame non si vede nessun quadrato', (tester) async {
    await monta(tester);
    await tester.pump();
    await nessunGradinoSulBordo(tester, 'primo frame');
  });

  testWidgets('A un quinto, quando la nebbia e\' ancora densa', (tester) async {
    await monta(tester);
    await tester.pump(const Duration(milliseconds: 520));
    await nessunGradinoSulBordo(tester, 'un quinto');
  });

  testWidgets('A meta\' animazione non si vede nessun quadrato',
      (tester) async {
    await monta(tester);
    // L'ordine chiede di guardare proprio a meta', non solo all'inizio.
    await tester.pump(const Duration(milliseconds: 1300));
    await nessunGradinoSulBordo(tester, 'meta animazione');
  });
}
