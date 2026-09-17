// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/rituals/arcano_dell_alba/archivio_dell_alba.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/rituals/arcano_dell_alba_screen.dart';
import 'package:esoteric_circle/features/tarot/tarot_card_art.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **L'ARCANO DELL'ALBA SI GIRA.** Ordine DT voci 02, 03 e 04, 17 settembre
/// 2026.
///
/// Si misura la schermata come la usa la persona: carte coperte tutte uguali,
/// un gesto solo e nessun altro comando; il verso deciso dal sistema e non
/// dalla carta toccata; il limite delle stese intatto; i due gesti del
/// cammino; il dono che, riaperto, e' quello di prima; e il dorso del mazzo che
/// al mezzo giro resta se stesso, cosi' che una carta coperta non dica niente.
void main() {
  final adesso = DateTime(2026, 9, 18, 7, 40);

  Future<({DiarioDelCammino diario, QuestionAllowance conto})> monta(
      WidgetTester tester,
      {Random? caso}) async {
    tester.view.physicalSize = const Size(390, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final diario = DiarioDelCammino(orologio: () => adesso);
    final conto = QuestionAllowance();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
        ChangeNotifierProvider<QuestionAllowance>.value(value: conto),
      ],
      child: MaterialApp(
        home: MaestroScope(
          child: ArcanoDellAlbaScreen(now: adesso, caso: caso ?? Random(21)),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    return (diario: diario, conto: conto);
  }

  Future<void> gira(WidgetTester tester, int quale) async {
    await tester.tap(find.byKey(Key('arcano_alba_carta_$quale')));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ArchivioDellAlba.dimenticaLaMemoria();
  });

  testWidgets(
      'UN GESTO SOLO: carte coperte tutte uguali e nessun altro comando',
      (tester) async {
    await monta(tester);
    final carte = find.byKey(const Key('arcano_alba_dorso'));
    expect(carte, findsNWidgets(ArcanoDellAlbaScreen.carteCoperte));
    final immagini = tester.widgetList<Image>(carte).toList();
    expect(immagini.map((i) => (i.image as AssetImage).assetName).toSet(),
        {TarotDeck.dorsoFull},
        reason: 'le carte coperte non hanno lo stesso dorso');
    final misure = [
      for (var i = 0; i < ArcanoDellAlbaScreen.carteCoperte; i++)
        tester.getSize(find.byKey(Key('arcano_alba_carta_$i'))),
    ];
    expect(misure.toSet(), hasLength(1),
        reason: 'le carte coperte non hanno la stessa misura: $misure');
    // Nessun pulsante oltre al ritorno: niente cielo, transiti, arti, cuore.
    for (final tipo in [
      ElevatedButton,
      TextButton,
      OutlinedButton,
      FilledButton,
      PopupMenuButton,
    ]) {
      expect(find.byType(tipo), findsNothing, reason: 'c\'e\' un $tipo');
    }
    expect(find.byType(IconButton), findsOneWidget,
        reason: 'oltre al ritorno c\'e\' un altro comando');
    expect(find.byType(TarotCardArt), findsNothing,
        reason: 'prima del gesto la faccia di una carta e\' gia\' montata');
  });

  testWidgets(
      'girata la carta: la faccia col suo verso e i tre movimenti, e '
      'le carte coperte se ne vanno', (tester) async {
    await monta(tester);
    await gira(tester, 1);
    final oggi = await tester.runAsync(() => ArchivioDellAlba.diOggi(adesso));
    expect(oggi, isNotNull);
    final faccia = tester.widget<TarotCardArt>(find.byType(TarotCardArt));
    expect(faccia.card.name, oggi!.carta.name);
    expect(faccia.reversed, oggi.stato.rovescio,
        reason: 'la faccia non porta il verso estratto');
    expect(find.byKey(const Key('arcano_alba_dorso')), findsNothing);
    expect(find.text(oggi.primo), findsOneWidget);
    expect(find.text(oggi.terzo), findsOneWidget);
    expect(find.byKey(const Key('arcano_alba_dono')), findsOneWidget);
    expect(find.byKey(const Key('arcano_alba_parola')),
        oggi.parola == null ? findsNothing : findsOneWidget);
    print('ORDINE DT: ${oggi.primo} | ${oggi.secondo} | ${oggi.terzo}');
  });

  testWidgets(
      'IL VERSO NON LO DECIDE LA CARTA TOCCATA: stesso caso, carte '
      'diverse, stesso stato', (tester) async {
    final stati = <int>{};
    for (final quale in [0, 2]) {
      SharedPreferences.setMockInitialValues({});
      ArchivioDellAlba.dimenticaLaMemoria();
      // Albero vuoto fra i due giri, se no la schermata conserva lo stato.
      await tester.pumpWidget(const SizedBox());
      await monta(tester, caso: Random(77));
      await gira(tester, quale);
      final oggi = await tester.runAsync(() => ArchivioDellAlba.diOggi(adesso));
      stati.add(oggi!.stato.id);
    }
    expect(stati, hasLength(1),
        reason:
            'toccare un\'altra carta coperta ha cambiato lo stato estratto');
  });

  testWidgets('nella prima meta\' del giro si vede solo il dorso',
      (tester) async {
    await monta(tester);
    await tester.tap(find.byKey(const Key('arcano_alba_carta_0')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.byType(TarotCardArt), findsNothing,
        reason: 'la faccia, e con lei il verso, compare prima della meta\' del '
            'giro');
  });

  testWidgets(
      'IL LIMITE DELLE STESE NON SI TOCCA, e nel cammino entrano i due '
      'gesti', (tester) async {
    final montati = await monta(tester);
    final prima = montati.conto.steseRimaste(Tier.free);
    await gira(tester, 0);
    await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();
    expect(montati.conto.steseRimaste(Tier.free), prima,
        reason: 'l\'Arcano dell\'Alba ha consumato una stesa');
    expect(montati.diario.haFatto('alba'), isTrue,
        reason: 'il gesto alba non e\' entrato nel cammino');
    expect(montati.diario.haFatto('oracolo'), isTrue,
        reason: 'il gesto oracolo non e\' entrato nel cammino');
  });

  testWidgets(
      'riaperta, la carta e\' quella di prima e non si sceglie due volte',
      (tester) async {
    await monta(tester);
    await gira(tester, 2);
    final prima =
        (await tester.runAsync(() => ArchivioDellAlba.diOggi(adesso)))!;
    await tester.pumpWidget(const SizedBox());
    await monta(tester, caso: Random(999));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(const Key('arcano_alba_dorso')), findsNothing,
        reason: 'riaprendo il dono si torna alle carte coperte');
    expect(find.text(prima.primo), findsOneWidget);
  });

  test('IL DORSO AL MEZZO GIRO RESTA SE STESSO', () async {
    final byte = await File(TarotDeck.dorsoFull).readAsBytes();
    final codice = await ui.instantiateImageCodec(byte);
    final immagine = (await codice.getNextFrame()).image;
    final dati = (await immagine.toByteData())!;
    final l = immagine.width, a = immagine.height;
    var somma = 0, oltre = 0, punti = 0;
    for (var y = 0; y < a; y += 3) {
      for (var x = 0; x < l; x += 3) {
        final i = (y * l + x) * 4;
        final j = ((a - 1 - y) * l + (l - 1 - x)) * 4;
        var scarto = 0;
        for (var c = 0; c < 3; c++) {
          scarto =
              max(scarto, (dati.getUint8(i + c) - dati.getUint8(j + c)).abs());
        }
        somma += scarto;
        if (scarto > 48) oltre++;
        punti++;
      }
    }
    final medio = somma / punti;
    print('ORDINE DT: il dorso ruotato di mezzo giro scarta in media '
        '${medio.toStringAsFixed(2)} su 255, e oltre 48 in $oltre punti su '
        '$punti');
    expect(medio, lessThan(8),
        reason: 'il dorso non e\' simmetrico: una carta coperta dice il verso');
    expect(oltre / punti, lessThan(0.01));
  });
}
