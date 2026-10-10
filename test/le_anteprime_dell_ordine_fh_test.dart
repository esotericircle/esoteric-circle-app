// LE ANTEPRIME DELL'ORDINE FH, il Real Time Cosmo con la sua profondita'.
//
// Stesse condizioni delle anteprime FG (360 per 797, rapporto 3, 8 ottobre
// 2026 alle 20 UTC, nascita a Napoli il 14 maggio 1988, nessuna posizione
// concessa), cosi' ogni immagine ha il suo "prima" nella cartella FG con lo
// stesso nome di inquadratura. Le immagini vanno in docs/preview/FH/ solo con
// AGGIORNA_ANTEPRIME=1.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/astro/real_time_cosmo/i_bersagli_del_cielo.dart';
import 'package:esoteric_circle/core/astro/real_time_cosmo/le_schede_del_cielo_profondo.dart';
import 'package:esoteric_circle/core/astro/sky_location.dart';
import 'package:esoteric_circle/features/real_time_cosmo/cielo_reale_screen.dart';
import 'package:esoteric_circle/features/real_time_cosmo/pittore_del_cielo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'le_anteprime_dell_ordine_fg_test.dart' as fg;

/// La misura e il rapporto dichiarati qui, accanto alle catture, come vuole
/// il corredo delle anteprime: sono gli stessi di `fg.monta`, che li imposta
/// anch'esso, ma la guardia del corredo legge il file che scrive le immagini.
Future<void> monta(WidgetTester tester, Widget schermata) {
  tester.view.devicePixelRatio = 3.0;
  tester.view.physicalSize = const Size(1080, 2391);
  return fg.monta(tester, schermata);
}

Future<void> scatta(WidgetTester tester, String nome) async {
  if (!fg.scrivi) return;
  await tester.runAsync(() async {
    final rb =
        fg.radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
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
    await monta(tester, fg.cielo(ModoDelCielo.adesso));
    await caricaEAlleggerisci(tester);
    await fg.passa(tester, 20);
    await scatta(tester, 'fh_02_il_cielo_di_adesso_a_sud');
  });

  testWidgets('FH.6: la Luna sotto l\'orizzonte, la vista sul piu\' brillante',
      (tester) async {
    await monta(tester, fg.cielo(ModoDelCielo.adesso));
    await caricaEAlleggerisci(tester);
    await fg.passa(tester, 10);
    expect(find.byKey(const Key('real_time_cosmo_riga_della_luna')),
        findsOneWidget);
    await scatta(tester, 'fh_10_la_luna_non_c_e');
  });

  testWidgets('FH.6: la Luna sopra l\'orizzonte, la vista parte da lei',
      (tester) async {
    await monta(
        tester,
        CieloRealeScreen(
          modo: ModoDelCielo.adesso,
          orologio: () => DateTime.utc(2026, 10, 20, 18),
          posizione: const DisabledSkyLocation(),
        ));
    await caricaEAlleggerisci(tester);
    await fg.passa(tester, 10);
    expect(
        find.byKey(const Key('real_time_cosmo_riga_della_luna')), findsNothing);
    await scatta(tester, 'fh_11_la_vista_parte_dalla_luna');
  });

  testWidgets('FH.7: l\'orizzonte e il cielo che si vede attraverso',
      (tester) async {
    await monta(tester, fg.cielo(ModoDelCielo.adesso));
    await caricaEAlleggerisci(tester);
    await fg.passa(tester, 10);
    final centro =
        tester.getCenter(find.byKey(const Key('real_time_cosmo_cielo')));
    // Lo sguardo scende all'orizzonte...
    for (var i = 0; i < 8; i++) {
      await tester.dragFrom(centro, const Offset(0, -45));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await fg.passa(tester, 10);
    await scatta(tester, 'fh_12_lo_skyline');
    // ...e poi sotto, dove il terreno diventa un velo.
    for (var i = 0; i < 10; i++) {
      await tester.dragFrom(centro, const Offset(0, -45));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await fg.passa(tester, 10);
    await scatta(tester, 'fh_13_attraverso_il_terreno');
    // 7.4: la scheda di una stella sotto l'orizzonte dice quando sorge. Lo
    // sguardo e' sotto l'orizzonte: si tocca la stella accesa piu' vicina al
    // centro del riquadro.
    final scena = tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((c) => c.painter)
        .whereType<PittoreDelCielo>()
        .first
        .scena;
    var migliore = -1;
    var distanza = double.infinity;
    for (var n = 0; n < scena.quante; n++) {
      final d =
          (scena.xSchermo[n] - 180).abs() + (scena.ySchermo[n] - 400).abs();
      if (d < distanza) {
        distanza = d;
        migliore = n;
      }
    }
    expect(migliore, greaterThanOrEqualTo(0));
    await tester
        .tapAt(Offset(scena.xSchermo[migliore], scena.ySchermo[migliore]));
    await fg.passa(tester, 6);
    expect(find.byKey(const Key('real_time_cosmo_scheda')), findsOneWidget);
    final scheda = find.descendant(
        of: find.byKey(const Key('real_time_cosmo_scheda')),
        matching: find.textContaining(RegExp('sorge alle|oggi non sorge')));
    expect(scheda, findsOneWidget);
    await scatta(tester, 'fh_22_la_scheda_sotto_l_orizzonte');
  });

  testWidgets('FH.8: il rallentamento agganciato alla Luna, poi l\'arrivo',
      (tester) async {
    await monta(tester, fg.cielo(ModoDelCielo.ritorno));
    await caricaEAlleggerisci(tester);
    // La corsa parte dal pulsante (aggiunta della Macchina del tempo).
    await tester.tap(find.byKey(const Key('macchina_viaggia_dal_cielo')));
    await tester.pump(const Duration(milliseconds: 50));
    // All'inizio "38 anni" e la data di oggi (aggiunta del fondatore).
    expect(find.text('38'), findsOneWidget);
    expect(find.text('anni'), findsOneWidget);
    expect(find.text('8 ottobre 2026'), findsOneWidget);
    // A meta' della corsa la data e gli anni scendono insieme.
    await fg.passa(tester, 45);
    final meta =
        tester.widget<Text>(find.byKey(const Key('real_time_cosmo_data')));
    final anniAMeta = int.parse(tester
        .widget<Text>(find.byKey(const Key('real_time_cosmo_anni')))
        .data!);
    final annoAMeta = int.parse(meta.data!.split(' ').last);
    // ignore: avoid_print
    print('FH.8 a meta\' corsa: $anniAMeta anni, ${meta.data}');
    expect(anniAMeta, inInclusiveRange(1, 37));
    // L'eta' e' quella vera in quel giorno: nato nel 1988, a maggio.
    expect(annoAMeta - 1988 - anniAMeta, inInclusiveRange(0, 1));
    await scatta(tester, 'fh_16_la_corsa_con_la_data');
    // L'eta' (1,8 secondi) e la corsa (7): a 4 secondi dentro l'ultimo anno.
    await fg.passa(tester, 65);
    expect(find.text('STO TORNANDO INDIETRO NEL TEMPO'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(
        tester.widget<Text>(find.byKey(const Key('real_time_cosmo_data'))).data,
        anyOf(endsWith('1988'), endsWith('1989')));
    await scatta(tester, 'fh_14_il_rallentamento');
    await fg.passa(tester, 60);
    expect(
        find.text('QUESTO ERA IL CIELO SOPRA DI TE QUANDO SEI VENUTO AL MONDO'),
        findsOneWidget);
    await scatta(tester, 'fh_15_l_arrivo_col_genere');
  });

  testWidgets('FH.10: un oggetto del cielo profondo e la sua scheda',
      (tester) async {
    await monta(tester, fg.cielo(ModoDelCielo.adesso));
    await caricaEAlleggerisci(tester);
    await fg.passa(tester, 10);
    final fotogramma = tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((c) => c.painter)
        .whereType<PittoreDelCielo>()
        .first
        .fotogramma;
    // Si gira col dito finche' un oggetto non sta nella parte libera dello
    // schermo, sopra il pie' di pagina.
    int? trovato;
    for (var giro = 0; giro < 16 && trovato == null; giro++) {
      final p = fotogramma.profondo!;
      for (var i = 0; i < kCieloProfondo.length; i++) {
        if (p.visibile[i] == 1 &&
            p.x[i] > 40 &&
            p.x[i] < 320 &&
            p.y[i] > 140 &&
            p.y[i] < 420) {
          trovato = i;
          break;
        }
      }
      if (trovato == null) await girati(tester, 45, 2);
      await fg.passa(tester, 2);
    }
    expect(trovato, isNotNull, reason: 'nessun oggetto profondo in vista');
    final p = fotogramma.profondo!;
    // ignore: avoid_print
    print('FH.10: ${kCieloProfondo[trovato!].nome} a '
        '${p.x[trovato].round()}, ${p.y[trovato].round()}, lato '
        '${p.lato[trovato].toStringAsFixed(1)} punti');
    await scatta(tester, 'fh_17_il_cielo_profondo');
    await tester.tapAt(Offset(p.x[trovato], p.y[trovato]));
    await fg.passa(tester, 6);
    expect(find.byKey(const Key('real_time_cosmo_scheda_profonda')),
        findsOneWidget);
    expect(
        find.text(kSchedeDelCieloProfondo
            .firstWhere((s) => s.id == kCieloProfondo[trovato!].id)
            .apertura),
        findsOneWidget);
    await scatta(tester, 'fh_18_la_scheda_del_cielo_profondo');
  });

  testWidgets('FH.12: una stella cadente nella notte delle Perseidi',
      (tester) async {
    await monta(
        tester,
        CieloRealeScreen(
          modo: ModoDelCielo.adesso,
          orologio: () => DateTime.utc(2026, 8, 12, 23),
          posizione: const DisabledSkyLocation(),
        ));
    await caricaEAlleggerisci(tester);
    await fg.passa(tester, 10);
    final f = tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((c) => c.painter)
        .whereType<PittoreDelCielo>()
        .first
        .fotogramma;
    // La nascita forzata: la frequenza vera, cento all'ora, ne fa vedere una
    // ogni pochi minuti nel riquadro.
    f.meteore!.prossimaSubito = true;
    await fg.passa(tester, 4, const Duration(milliseconds: 60));
    // ignore: avoid_print
    print('FH.12: meteore nate ${f.meteore!.nate}, vertici '
        '${f.meteore!.vertici}');
    expect(f.meteore!.vertici, greaterThan(0));
    await scatta(tester, 'fh_19_una_stella_cadente');
  });

  testWidgets('FH.13: l\'eclittica accesa, poi spenta dal menu',
      (tester) async {
    await monta(tester, fg.cielo(ModoDelCielo.adesso));
    await caricaEAlleggerisci(tester);
    await fg.passa(tester, 10);
    final f = tester
        .widgetList<CustomPaint>(find.byType(CustomPaint))
        .map((c) => c.painter)
        .whereType<PittoreDelCielo>()
        .first
        .fotogramma;
    expect(f.eclittica, isNotNull);
    // Lo sguardo scende di qualche grado e gira finche' il filo e il suo
    // nome entrano nel riquadro: a quest'ora l'eclittica sta bassa.
    final centro =
        tester.getCenter(find.byKey(const Key('real_time_cosmo_cielo')));
    for (var i = 0; i < 3; i++) {
      await tester.dragFrom(centro, const Offset(0, -45));
      await tester.pump(const Duration(milliseconds: 50));
    }
    for (var i = 0; i < 16 && !f.eclittica!.scrittaVisibile; i++) {
      await girati(tester, -45, 2);
      await fg.passa(tester, 2);
    }
    expect(f.eclittica!.vertici, greaterThan(0));
    expect(f.eclittica!.scrittaVisibile, isTrue);
    // LAPIDE della regola vecchia (ordine FH parte 13: il nome sempre
    // acceso). Il fondatore, 10 ottobre 2026: "e' proprio necessario tenere
    // sempre visibile la scritta? Si sovrappone a tutto". Il posto per il nome
    // c'e', ma il nome tace: parla solo dopo che la persona accende
    // l'eclittica dal menu, per cinque secondi.
    expect(f.nomeDellEclittica, isFalse,
        reason: "il nome del filo parla senza che nessuno l'abbia acceso");
    await tester.tap(find.byKey(const Key('real_time_cosmo_guida')));
    await fg.passa(tester, 6);
    await tester.tap(find.byKey(const Key('real_time_cosmo_eclittica')));
    await fg.passa(tester, 4);
    await scatta(tester, 'fh_21_il_menu_con_l_eclittica_spenta');
    // A foglio aperto la schermata coperta non disegna: si chiude il foglio
    // col tocco fuori, e il fotogramma dopo non porta piu' il filo.
    await tester.tapAt(const Offset(180, 40));
    await fg.passa(tester, 8);
    expect(f.eclittica, isNull);
    // Riaccesa dal menu: il nome parla, poi tace.
    await tester.tap(find.byKey(const Key('real_time_cosmo_guida')));
    await fg.passa(tester, 6);
    await tester.tap(find.byKey(const Key('real_time_cosmo_eclittica')));
    await fg.passa(tester, 4);
    await tester.tapAt(const Offset(180, 40));
    await fg.passa(tester, 8);
    expect(f.nomeDellEclittica, isTrue,
        reason: 'riaccesa dal menu, il nome del filo non parla');
    await scatta(tester, 'fh_20_l_eclittica');
    await fg.passa(tester, 50);
    expect(f.nomeDellEclittica, isFalse,
        reason: 'dopo cinque secondi il nome del filo parla ancora');
  });

  testWidgets('FH.5: il menu dei bersagli, i due livelli', (tester) async {
    await monta(tester, fg.cielo(ModoDelCielo.adesso));
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
    await monta(tester, fg.cielo(ModoDelCielo.adesso));
    await caricaEAlleggerisci(tester);
    await fg.passa(tester, 10);
    await tester.tap(find.byKey(const Key('real_time_cosmo_guida')));
    await fg.passa(tester, 6);
    await tester
        .tap(find.byKey(const Key('real_time_cosmo_categoria_lunaESole')));
    await fg.passa(tester, 4);
    await tester.tap(find.byKey(const Key('real_time_cosmo_bersaglio_sole')));
    await fg.passa(tester, 10);
    // La riga dell'indicatore: dalla parte 6 anche la riga della Luna dice
    // "sorge alle".
    expect(
        find.textContaining("Sotto l'orizzonte: sorge alle"), findsOneWidget);
    await scatta(tester, 'fh_08_il_sole_sotto_l_orizzonte');
  });

  testWidgets('FH.5: il Sole alto porta il suo avviso', (tester) async {
    await monta(
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
    await tester
        .tap(find.byKey(const Key('real_time_cosmo_categoria_lunaESole')));
    await fg.passa(tester, 4);
    await tester.tap(find.byKey(const Key('real_time_cosmo_bersaglio_sole')));
    await fg.passa(tester, 10);
    await scatta(tester, 'fh_09_l_avviso_del_sole');
  });

  testWidgets('FH.1-2: un velo solo, leggero, verso est', (tester) async {
    await monta(tester, fg.cielo(ModoDelCielo.adesso));
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
