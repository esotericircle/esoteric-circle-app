// LE ANTEPRIME DELLA MACCHINA DEL TEMPO. Aggiunta all'ordine FH, prova di
// vista I1-I6 e I10-I12.
//
// Stesse condizioni delle anteprime FG e FH (360 per 797, rapporto 3, 8
// ottobre 2026 alle 20 UTC, nascita a Napoli il 14 maggio 1988 alle 6:40 UTC).
// Le immagini vanno in docs/collaudo/FH/ col prefisso "aggiunta", solo con
// AGGIORNA_ANTEPRIME=1. Le registrazioni della corsa e la prova con Riduci
// Movimento (I7, I8, I9) si fanno sul telefono di collaudo.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/astro/sky_location.dart';
import 'package:esoteric_circle/features/real_time_cosmo/cielo_reale_screen.dart';
import 'package:esoteric_circle/features/real_time_cosmo/pittore_del_cielo.dart';
import 'package:esoteric_circle/features/real_time_cosmo/real_time_cosmo_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'le_anteprime_dell_ordine_fg_test.dart' as fg;
import 'le_anteprime_dell_ordine_fh_test.dart' as fh;

/// Un luogo attuale concesso, Milano, per la riga del luogo nei due stati.
class _Milano extends SkyLocation {
  const _Milano();
  static const luogo =
      SkyPlace(latitude: 45.46, longitude: 9.19, citta: 'Milano');
  @override
  bool get available => true;
  @override
  Future<SkyPlace?> resolve() async => luogo;
  @override
  Future<SkyPlace?> resolveSeConcesso() async => luogo;
}

/// La misura e il rapporto dichiarati accanto alle catture, come vuole il
/// corredo delle anteprime: gli stessi di fg.monta.
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
    final dir = Directory('docs/collaudo/FH');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    File('${dir.path}/aggiunta_$nome.png')
        .writeAsBytesSync(dati!.buffer.asUint8List());
    img.dispose();
  });
}

CieloRealeScreen _macchina(
        {SkyLocation posizione = const DisabledSkyLocation()}) =>
    CieloRealeScreen(
      modo: ModoDelCielo.ritorno,
      orologio: () => DateTime.utc(2026, 10, 8, 20),
      posizione: posizione,
    );

FotogrammaDelCielo _fotogramma(WidgetTester tester) => tester
    .widgetList<CustomPaint>(find.byType(CustomPaint))
    .map((c) => c.painter)
    .whereType<PittoreDelCielo>()
    .first
    .fotogramma;

/// Porta una ruota del pannello alla voce [i].
Future<void> ruota(WidgetTester tester, String chiave, int i) async {
  final ruota = tester.widget<ListWheelScrollView>(find.descendant(
      of: find.byKey(Key(chiave)), matching: find.byType(ListWheelScrollView)));
  (ruota.controller! as FixedExtentScrollController).jumpToItem(i);
  await tester.pump(const Duration(milliseconds: 50));
}

Future<void> apriIlPannello(WidgetTester tester) async {
  await tester.tap(find.text('Scegli il giorno'));
  await fg.passa(tester, 8);
}

/// Una corsa di sei secondi verso il giorno scelto, fino all'arrivo.
Future<void> viaggia(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('macchina_viaggia')));
  await fg.passa(tester, 66);
}

/// Mentre la corsa o l'arrivo parlano al centro, i punti cardinali e il
/// nome dell'eclittica tacciono (visto sul Realme il 10 ottobre 2026: la S
/// toccava la frase d'arrivo, il nome del filo passava sopra la Luna).
void _taccionoLeScritteDelCielo(FotogrammaDelCielo f, String quando) {
  expect(f.scritte.length, greaterThanOrEqualTo(4));
  for (var k = 0; k < 4; k++) {
    expect(f.scritte[k].luce, 0, reason: 'il punto cardinale $k parla $quando');
  }
  expect(f.eclittica?.scrittaVisibile ?? false, isFalse,
      reason: "il nome dell'eclittica parla $quando");
}

void main() {
  testWidgets('I1: il menu con la voce rinominata', (tester) async {
    await monta(tester, const RealTimeCosmoScreen());
    await fg.passa(tester, 10);
    expect(find.text('La macchina del tempo'), findsOneWidget);
    expect(find.textContaining('ritorno indietro'), findsNothing);
    await scatta(tester, 'i01_il_menu_rinominato');
  });

  testWidgets('I2-I3: il titolo e il pannello con la nascita scelta',
      (tester) async {
    await monta(tester, _macchina());
    await fh.caricaEAlleggerisci(tester);
    await fg.passa(tester, 10);
    expect(find.text('La macchina del tempo'), findsOneWidget);
    await scatta(tester, 'i02_il_titolo_e_i_comandi');
    await apriIlPannello(tester);
    expect(find.byKey(const Key('macchina_pannello')), findsOneWidget);
    expect(find.text('maggio'), findsWidgets);
    await scatta(tester, 'i03_il_pannello_con_la_nascita');
  });

  testWidgets('I4: il cielo del 1 gennaio 1900', (tester) async {
    await monta(tester, _macchina());
    await fh.caricaEAlleggerisci(tester);
    await fg.passa(tester, 10);
    await apriIlPannello(tester);
    await ruota(tester, 'macchina_ruota_anno', 0);
    await ruota(tester, 'macchina_ruota_mese', 0);
    await ruota(tester, 'macchina_ruota_giorno', 0);
    await viaggia(tester);
    expect(find.text('QUESTO ERA IL CIELO DEL 1 gennaio 1900'), findsOneWidget);
    await scatta(tester, 'i04_il_cielo_del_1900');
  });

  testWidgets('I5: il cielo del 31 dicembre 2100', (tester) async {
    await monta(tester, _macchina());
    await fh.caricaEAlleggerisci(tester);
    await fg.passa(tester, 10);
    await apriIlPannello(tester);
    await ruota(tester, 'macchina_ruota_anno', 200);
    await ruota(tester, 'macchina_ruota_mese', 11);
    await ruota(tester, 'macchina_ruota_giorno', 30);
    await viaggia(tester);
    expect(
        find.text('QUESTO SARÀ IL CIELO DEL 31 dicembre 2100'), findsOneWidget);
    await scatta(tester, 'i05_il_cielo_del_2100');
  });

  testWidgets('I6 e I11: la nascita, la Luna grande nella corsa e l\'arrivo',
      (tester) async {
    await monta(tester, _macchina());
    await fh.caricaEAlleggerisci(tester);
    await fg.passa(tester, 10);
    await tester.tap(find.byKey(const Key('macchina_viaggia_dal_cielo')));
    await tester.pump(const Duration(milliseconds: 50));
    // A undici secondi: l'ultimo anno, la Luna quasi piena e grande cinque
    // volte, la camera agganciata (voci F1, F2, F7).
    await fg.passa(tester, 110);
    final f = _fotogramma(tester);
    final riposo = f.lunaLato / 5;
    // I pianeti soltanto: il Sole non e' un pianeta e la Luna si posa a
    // parte (voce F6).
    var aloneDelPianeta = 0.0;
    for (var k = 2; k < f.corpi.length; k++) {
      final c = f.corpi[k];
      if (c.visibile && c.raggio > aloneDelPianeta) aloneDelPianeta = c.raggio;
    }
    expect(aloneDelPianeta * 3 <= riposo * 3 / 10 + 0.5, isTrue,
        reason: 'un pianeta ha l\'alone piu\' grande del disco della Luna');
    // ignore: avoid_print
    print('MACCHINA: Luna al colmo, lato ${(f.lunaLato * 3).round()} px '
        '(disco ${(f.lunaLato * 3 / 10 * 2).round()} px di diametro), '
        'a riposo disco ${(riposo * 3 / 10 * 2).round()} px; alone del '
        'pianeta piu\' grande in campo ${(aloneDelPianeta * 3).round()} px di '
        'raggio; Luna in x ${f.lunaX.round()} y ${f.lunaY.round()}');
    _taccionoLeScritteDelCielo(f, 'nella corsa');
    await scatta(tester, 'i07_anteprima_la_luna_grande_nella_corsa');
    await fg.passa(tester, 62);
    expect(
        find.text('QUESTO ERA IL CIELO SOPRA DI TE QUANDO SEI VENUTO AL MONDO'),
        findsOneWidget);
    _taccionoLeScritteDelCielo(_fotogramma(tester), "all'arrivo");
    await scatta(tester, 'i06_l_arrivo_sulla_nascita');
  });

  testWidgets('I11: la Luna quasi piena, a riposo', (tester) async {
    // Il 28 ottobre 2026 la Luna e' quasi piena e alle 7:40 di Napoli, l'ora
    // di nascita ereditata (voce D4), sta ancora sopra l'orizzonte a ovest:
    // il 26, il giorno della piena, a quell'ora e' gia' tramontata. Il bordo
    // del disco deve restare distinto dall'alone (voce F7), a riposo.
    await monta(tester, _macchina());
    await fh.caricaEAlleggerisci(tester);
    await fg.passa(tester, 10);
    await apriIlPannello(tester);
    await ruota(tester, 'macchina_ruota_anno', 126);
    await ruota(tester, 'macchina_ruota_mese', 9);
    await ruota(tester, 'macchina_ruota_giorno', 27);
    await viaggia(tester);
    expect(
        find.text('QUESTO SARÀ IL CIELO DEL 28 ottobre 2026'), findsOneWidget);
    final f = _fotogramma(tester);
    // ignore: avoid_print
    print('MACCHINA I11: Luna in x ${f.lunaX.round()} y ${f.lunaY.round()}, '
        'lato ${(f.lunaLato * 3).round()} px');
    expect(f.lunaX > 0 && f.lunaX < 360 && f.lunaY > 0 && f.lunaY < 797, isTrue,
        reason: 'la Luna non sta in quadro');
    await scatta(tester, 'i11_la_luna_quasi_piena');
  });

  testWidgets('I9 ed E9: con Riduci Movimento il salto senza corsa',
      (tester) async {
    // Visto sul Realme il 10 ottobre 2026: la prima stesura mostrava per 1,8
    // secondi l'eta' di oggi prima del salto. Qui il salto e' immediato e la
    // frase d'arrivo compare subito.
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await monta(tester, _macchina());
    await fh.caricaEAlleggerisci(tester);
    await fg.passa(tester, 10);
    await tester.tap(find.byKey(const Key('macchina_viaggia_dal_cielo')));
    await fg.passa(tester, 2);
    expect(find.byKey(const Key('real_time_cosmo_anni')), findsNothing);
    expect(
        find.text('QUESTO ERA IL CIELO SOPRA DI TE QUANDO SEI VENUTO AL MONDO'),
        findsOneWidget);
    await scatta(tester, 'i09_il_salto_con_riduci_movimento');
  });

  testWidgets('I10: la riga del luogo nei suoi due stati', (tester) async {
    await monta(tester, _macchina(posizione: const _Milano()));
    await fh.caricaEAlleggerisci(tester);
    await fg.passa(tester, 10);
    expect(find.textContaining('il tuo luogo di nascita'), findsOneWidget);
    await scatta(tester, 'i10_il_luogo_di_nascita');
    await tester.tap(find.text('Usa dove sei ora'));
    await fg.passa(tester, 4);
    expect(find.textContaining('Milano, dove sei ora'), findsOneWidget);
    await scatta(tester, 'i10_il_luogo_attuale');
  });

  testWidgets("la riga del luogo del pannello e' larga quanto il pannello",
      (tester) async {
    // Visto sul Realme il 10 ottobre 2026: sulla stessa riga del bottone
    // "Usa il luogo di nascita" il testo "Cielo su Roma, dove sei ora." andava
    // a capo in quattro righe strette. Il testo sta sopra, largo quanto la
    // riga, in tutti e due gli stati.
    await monta(tester, _macchina(posizione: const _Milano()));
    await fh.caricaEAlleggerisci(tester);
    await fg.passa(tester, 10);
    await apriIlPannello(tester);
    var stati = 0;
    for (final atteso in ['il tuo luogo di nascita', 'dove sei ora']) {
      if (atteso == 'dove sei ora') {
        await tester.tap(find.byKey(const Key('macchina_cambia_luogo')));
        await fg.passa(tester, 4);
      }
      final testo = find.byKey(const Key('macchina_testo_del_luogo'));
      expect(tester.widget<Text>(testo).data, contains(atteso));
      final largo = tester.getSize(testo).width;
      final riga = tester
          .getSize(find.byKey(const Key('macchina_riga_del_luogo')))
          .width;
      // ignore: avoid_print
      print('LUOGO ($atteso): testo largo ${largo.round()} su ${riga.round()}');
      expect(largo, greaterThanOrEqualTo(riga * 0.95),
          reason: "la riga del luogo '$atteso' e' stretta");
      stati++;
    }
    expect(stati, 2);
  });

  testWidgets('esplora senza distrazioni, e le scritte si riaccendono',
      (tester) async {
    // Richiesta del fondatore del 10 ottobre 2026: troppe scritte sul cielo,
    // una voce del menu dell'indicatore che le spegne, e che si riaccende.
    await monta(tester, _macchina());
    await fh.caricaEAlleggerisci(tester);
    await fg.passa(tester, 10);
    final guida = find.byKey(const Key('real_time_cosmo_guida_nome'));
    expect(guida, findsOneWidget);
    var f = _fotogramma(tester);
    var cardinali = 0;
    for (var k = 0; k < 4; k++) {
      if (f.scritte[k].luce > 0) cardinali++;
    }
    expect(cardinali, greaterThan(0));
    await tester.tap(guida);
    await fg.passa(tester, 8);
    await tester
        .tap(find.byKey(const Key('real_time_cosmo_senza_distrazioni')));
    await fg.passa(tester, 4);
    await tester.tapAt(const Offset(180, 60));
    await fg.passa(tester, 8);
    f = _fotogramma(tester);
    for (var k = 0; k < f.scritte.length; k++) {
      expect(f.scritte[k].luce, 0, reason: 'la scritta $k parla');
    }
    expect(f.nomiDeiCorpi, isFalse);
    expect(f.eclittica?.scrittaVisibile ?? false, isFalse);
    expect(guida, findsNothing);
    await scatta(tester, 'esplora_senza_distrazioni');
    // Si riaccende dalla testata.
    await tester
        .tap(find.byKey(const Key('real_time_cosmo_riaccendi_le_scritte')));
    await fg.passa(tester, 8);
    expect(guida, findsOneWidget);
    expect(_fotogramma(tester).nomiDeiCorpi, isTrue);
    expect(find.byKey(const Key('real_time_cosmo_riaccendi_le_scritte')),
        findsNothing);
  });

  testWidgets('il pulsante riparte dopo un cambio di data o di luogo',
      (tester) async {
    // Segnalato dal fondatore il 10 ottobre 2026: "quando entro posso
    // cliccare sul pulsante e parte l'animazione, ma se poi modifico la data
    // o il luogo senza uscire, se rifaccio click sul pulsante non funziona".
    await monta(tester, _macchina(posizione: const _Milano()));
    await fh.caricaEAlleggerisci(tester);
    await fg.passa(tester, 10);
    final numeri = find.byKey(const Key('macchina_blocco_dei_numeri'));
    final viaggia = find.byKey(const Key('macchina_viaggia_dal_cielo'));
    // La prima corsa, verso la nascita, fino a scena ferma.
    await tester.tap(viaggia);
    await fg.passa(tester, 240);
    expect(viaggia, findsOneWidget);

    // 1. La data cambiata nel pannello, chiuso senza "Portami lì".
    await apriIlPannello(tester);
    await ruota(tester, 'macchina_ruota_anno', 100);
    await tester.tapAt(const Offset(180, 30));
    await fg.passa(tester, 8);
    expect(find.byKey(const Key('macchina_pannello')), findsNothing);
    expect(find.textContaining('2000'), findsWidgets,
        reason: 'la schermata non ha tenuto il giorno scelto nel pannello');
    await tester.tap(viaggia);
    await fg.passa(tester, 10);
    expect(numeri, findsOneWidget, reason: 'dopo la data la corsa non parte');
    await fg.passa(tester, 120);

    // 2. Il solo luogo cambiato sulla schermata.
    final riga = find.byKey(const Key('macchina_riga_del_luogo_in_cielo'));
    await tester
        .tap(find.descendant(of: riga, matching: find.textContaining('Usa')));
    await fg.passa(tester, 4);
    await tester.tap(viaggia);
    await fg.passa(tester, 10);
    expect(numeri, findsOneWidget, reason: 'dopo il luogo la corsa non parte');
    await fg.passa(tester, 120);

    // 3. Niente di cambiato: nessuna corsa, ma una risposta.
    await tester.tap(viaggia);
    await fg.passa(tester, 3);
    expect(numeri, findsNothing);
    expect(find.byKey(const Key('macchina_gia_qui')), findsOneWidget,
        reason: 'il tocco non ha risposto: un vicolo cieco');
  });

  testWidgets("l'indicatore non copre la testata, in ogni direzione",
      (tester) async {
    // Visto sul Realme il 10 ottobre 2026 sera: con lo sguardo che manda il
    // bersaglio in alto, la freccia e "I tuoi Gemelli" con la riga di quando
    // sorge salivano sul titolo della schermata. Si gira lo sguardo in
    // orizzontale e in verticale e, dove l'indicatore c'e', il suo riquadro
    // vero non tocca il titolo ne' i bottoni della testata. Sul telefono la
    // schermata vive sotto la barra dell'app, che arriva come margine
    // superiore: qui un margine di 90 punti, come sul Realme.
    tester.view.padding = const FakeViewPadding(top: 270);
    addTearDown(tester.view.resetPadding);
    await monta(tester, _macchina());
    await fh.caricaEAlleggerisci(tester);
    await fg.passa(tester, 10);
    final cielo =
        tester.getCenter(find.byKey(const Key('real_time_cosmo_cielo')));
    final guida = find.byKey(const Key('real_time_cosmo_guida'));
    final testata = [
      find.text('La macchina del tempo'),
      find.byKey(const Key('real_time_cosmo_fonti_bottone')),
    ];
    var guardate = 0;
    final coperte = <String>[];
    for (var v = 0; v < 5; v++) {
      for (var h = 0; h < 8; h++) {
        await tester.dragFrom(cielo, const Offset(90, 0));
        await fg.passa(tester, 3);
        if (guida.evaluate().isEmpty) continue;
        final r = tester.getRect(guida);
        guardate++;
        for (final t in testata) {
          if (t.evaluate().isEmpty) continue;
          if (tester.getRect(t).overlaps(r)) {
            coperte.add('giro $v.$h: $r sopra ${tester.getRect(t)}');
          }
        }
      }
      await tester.dragFrom(cielo, const Offset(0, -60));
      await fg.passa(tester, 3);
    }
    // ignore: avoid_print
    print('INDICATORE: $guardate posizioni guardate, ${coperte.length} '
        'sulla testata');
    expect(guardate, greaterThanOrEqualTo(10));
    expect(coperte, isEmpty, reason: coperte.join(' | '));
  });

  testWidgets('I12: le fonti della Macchina con le quattro righe',
      (tester) async {
    await monta(tester, _macchina());
    await fh.caricaEAlleggerisci(tester);
    await fg.passa(tester, 10);
    await tester.tap(find.byKey(const Key('real_time_cosmo_fonti_bottone')));
    await fg.passa(tester, 8);
    // Le quattro righe dell'Architetto stanno nel testo (voce G1), in fondo:
    // il testo e' un blocco solo, e si scorre fino alla fine.
    for (final r in [
      'La finestra va dal 1900 al 2100.',
      'non vengono riportate all\'equinozio della data',
      'Il moto proprio delle stelle non è applicato.',
      'Durante l\'animazione la Luna viene ingrandita',
    ]) {
      expect(find.textContaining(r), findsOneWidget, reason: r);
    }
    await tester.drag(
        find.byType(SingleChildScrollView).last, const Offset(0, -3000));
    await fg.passa(tester, 8);
    await scatta(tester, 'i12_le_fonti_della_macchina');
  });
}
