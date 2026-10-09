// LE ANTEPRIME DELL'ORDINE FH, il Real Time Cosmo con la sua profondita'.
//
// Stesse condizioni delle anteprime FG (360 per 797, rapporto 3, 8 ottobre
// 2026 alle 20 UTC, nascita a Napoli il 14 maggio 1988, nessuna posizione
// concessa), cosi' ogni immagine ha il suo "prima" nella cartella FG con lo
// stesso nome di inquadratura. Le immagini vanno in docs/preview/FH/ solo con
// AGGIORNA_ANTEPRIME=1.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/astro/sky_location.dart';
import 'package:esoteric_circle/features/real_time_cosmo/cielo_reale_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'le_anteprime_dell_ordine_fg_test.dart' as fg;

Future<void> scatta(WidgetTester tester, String nome) async {
  if (!fg.scrivi) return;
  await tester.runAsync(() async {
    final rb = fg.radice.currentContext!.findRenderObject()!
        as RenderRepaintBoundary;
    final img = await rb.toImage(pixelRatio: 3.0);
    final dati = await img.toByteData(format: ui.ImageByteFormat.png);
    final dir = Directory('docs/preview/FH');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    File('${dir.path}/$nome.png').writeAsBytesSync(dati!.buffer.asUint8List());
    img.dispose();
  });
}

/// Il caricamento piu' l'alleggerimento dei dodici veli, che gira in un
/// isolato: tempo vero, dentro runAsync.
Future<void> caricaEAlleggerisci(WidgetTester tester) async {
  await fg.carica(tester);
  for (var i = 0; i < 16; i++) {
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 250)));
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> girati(WidgetTester tester, double dx, int volte) async {
  final centro =
      tester.getCenter(find.byKey(const Key('real_time_cosmo_cielo')));
  for (var i = 0; i < volte; i++) {
    await tester.dragFrom(centro, Offset(dx, 0));
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  testWidgets('FH.1-2: un velo solo, leggero, verso sud', (tester) async {
    await fg.monta(tester, fg.cielo(ModoDelCielo.adesso));
    await caricaEAlleggerisci(tester);
    await fg.passa(tester, 20);
    await scatta(tester, 'fh_02_il_cielo_di_adesso_a_sud');
  });

  testWidgets('FH.6: la Luna sotto l\'orizzonte, la vista sul piu\' brillante',
      (tester) async {
    await fg.monta(tester, fg.cielo(ModoDelCielo.adesso));
    await caricaEAlleggerisci(tester);
    await fg.passa(tester, 10);
    expect(find.byKey(const Key('real_time_cosmo_riga_della_luna')),
        findsOneWidget);
    await scatta(tester, 'fh_10_la_luna_non_c_e');
  });

  testWidgets('FH.6: la Luna sopra l\'orizzonte, la vista parte da lei',
      (tester) async {
    await fg.monta(
        tester,
        CieloRealeScreen(
          modo: ModoDelCielo.adesso,
          orologio: () => DateTime.utc(2026, 10, 20, 18),
          posizione: const DisabledSkyLocation(),
        ));
    await caricaEAlleggerisci(tester);
    await fg.passa(tester, 10);
    expect(find.byKey(const Key('real_time_cosmo_riga_della_luna')),
        findsNothing);
    await scatta(tester, 'fh_11_la_vista_parte_dalla_luna');
  });

  testWidgets('FH.5: il menu dei bersagli, i due livelli', (tester) async {
    await fg.monta(tester, fg.cielo(ModoDelCielo.adesso));
    await caricaEAlleggerisci(tester);
    await fg.passa(tester, 10);
    await tester.tap(find.byKey(const Key('real_time_cosmo_guida')));
    await fg.passa(tester, 6);
    expect(find.byKey(const Key('real_time_cosmo_categoria_costellazioni')),
        findsOneWidget);
    await scatta(tester, 'fh_05_il_menu_le_categorie');
    await tester.tap(
        find.byKey(const Key('real_time_cosmo_categoria_nebuloseEGalassie')));
    await fg.passa(tester, 4);
    await scatta(tester, 'fh_06_il_menu_dentro_la_categoria');
    await tester.tap(find.byKey(const Key('real_time_cosmo_bersaglio_m45')));
    await fg.passa(tester, 10);
    await scatta(tester, 'fh_07_l_indicatore_sulle_pleiadi');
  });

  testWidgets('FH.5: il Sole sotto l\'orizzonte dice quando sorge',
      (tester) async {
    await fg.monta(tester, fg.cielo(ModoDelCielo.adesso));
    await caricaEAlleggerisci(tester);
    await fg.passa(tester, 10);
    await tester.tap(find.byKey(const Key('real_time_cosmo_guida')));
    await fg.passa(tester, 6);
    await tester.tap(find.byKey(const Key('real_time_cosmo_categoria_lunaESole')));
    await fg.passa(tester, 4);
    await tester.tap(find.byKey(const Key('real_time_cosmo_bersaglio_sole')));
    await fg.passa(tester, 10);
    expect(find.textContaining('sorge alle'), findsOneWidget);
    await scatta(tester, 'fh_08_il_sole_sotto_l_orizzonte');
  });

  testWidgets('FH.5: il Sole alto porta il suo avviso', (tester) async {
    await fg.monta(
        tester,
        CieloRealeScreen(
          modo: ModoDelCielo.adesso,
          orologio: () => DateTime.utc(2026, 10, 8, 10),
          posizione: const DisabledSkyLocation(),
        ));
    await caricaEAlleggerisci(tester);
    await fg.passa(tester, 10);
    await tester.tap(find.byKey(const Key('real_time_cosmo_guida')));
    await fg.passa(tester, 6);
    await tester.tap(find.byKey(const Key('real_time_cosmo_categoria_lunaESole')));
    await fg.passa(tester, 4);
    await tester.tap(find.byKey(const Key('real_time_cosmo_bersaglio_sole')));
    await fg.passa(tester, 10);
    await scatta(tester, 'fh_09_l_avviso_del_sole');
  });

  testWidgets('FH.1-2: un velo solo, leggero, verso est', (tester) async {
    await fg.monta(tester, fg.cielo(ModoDelCielo.adesso));
    await caricaEAlleggerisci(tester);
    await fg.passa(tester, 10);
    await girati(tester, 45, 10);
    // Il velo che diventa quello al centro passa avanti nella fila
    // dell'alleggerimento, che gira in un isolato: serve tempo vero.
    await caricaEAlleggerisci(tester);
    await fg.passa(tester, 20);
    await scatta(tester, 'fh_03_il_cielo_verso_est');
  });
}
