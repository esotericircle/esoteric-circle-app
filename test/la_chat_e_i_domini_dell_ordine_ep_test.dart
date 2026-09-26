import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/arts/gli_sfondi_delle_schede.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/schede/la_scheda_dell_arte.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// **LA SCHEDA CONSULTA DEI DOMINI E LA CHAT.** Ordine EP, voci 12, 13, 14 e
/// 15, 26 settembre 2026.
///
/// Si apre l'app intera, dal Maestro al centro al suo dominio, e da li' la
/// chat toccando la scheda "Consulta": la strada vera della persona.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzio() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final n in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(n), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  Future<void> passo(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> apriIlDominio(WidgetTester tester, Maestro maestro,
      {double larghezza = 390,
      double scala = 1,
      bool frasiLunghe = false}) async {
    silenzio();
    tester.view.physicalSize = Size(larghezza, 844);
    tester.view.devicePixelRatio = 1.0;
    tester.platformDispatcher.textScaleFactorTestValue = scala;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    // Un'app nuova a ogni Maestro: senza, la stessa prova ritroverebbe la
    // chat di prima ancora aperta.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await passo(tester);
    final ctx = tester.element(find.byType(MaterialApp));
    ctx.read<MaestroController>().selectMaestro(maestro);
    // Senza la risposta del server i contatori tacciono (ordine BG voce
    // 04): qui la si da', come arriva sul telefono.
    ctx.read<QuestionAllowance>().ilServerHaParlato();
    if (frasiLunghe) {
      // **LE FRASI PIU' LUNGHE DEI CONTATORI.** Col piano del fondatore, 50
      // domande al giorno, e una domanda e un approfondimento gia' fatti, le
      // righe dicono "Ti restano 49 ... su 50, oggi": la forma piu' lunga.
      // Col piano libero e niente consumato la frase era la piu' corta, e la
      // prima stesura di questa guardia restava verde anche col difetto.
      ctx.read<EntitlementService>().setTier(Tier.tier3);
      ctx.read<QuestionAllowance>()
        ..record(Tier.tier3)
        ..registraApprofondimento(Tier.tier3);
    }
    await passo(tester);
    await tester.tap(find.byKey(const Key('santuario_central_bust')));
    await passo(tester);
    await passo(tester);
  }

  Future<void> apriLaChat(WidgetTester tester, Maestro maestro,
      {double larghezza = 390,
      double scala = 1,
      bool frasiLunghe = false}) async {
    await apriIlDominio(tester, maestro,
        larghezza: larghezza, scala: scala, frasiLunghe: frasiLunghe);
    final scheda = find.byKey(Key('scheda_tocco_consulta_${maestro.name}'));
    await tester.ensureVisible(scheda);
    await tester.pump();
    await tester.tap(scheda);
    await tester.pump(const Duration(milliseconds: 500));
    await passo(tester);
  }

  // --- EP.12 ----------------------------------------------------------------

  for (final m in Maestro.values) {
    testWidgets(
        'EP.12: in cima al dominio di ${m.id} la scheda "Consulta" illustrata '
        'apre la sua chat', (tester) async {
      await apriIlDominio(tester, m);
      final scheda = find.byKey(Key('scheda_tocco_consulta_${m.name}'));
      expect(scheda, findsOneWidget, reason: 'nessuna scheda Consulta');
      final immagini = tester
          .widgetList<Image>(
              find.descendant(of: scheda, matching: find.byType(Image)))
          .map((i) {
        final img = i.image;
        final a = img is ResizeImage ? img.imageProvider : img;
        return (a as AssetImage).assetName;
      }).toList();
      expect(immagini, contains(GliSfondiDelleSchede.consultaDi(m)));
      // **ORIZZONTALE.** Il fondatore, a ordine aperto: "in ogni dominio, in
      // alto ci devi mettere la scheda della chat orizzontale e non
      // quadrata". L'ordine diceva verticale.
      final laScheda = tester.widget<LaSchedaDellArte>(find
          .ancestor(of: scheda, matching: find.byType(LaSchedaDellArte))
          .first);
      expect(laScheda.formato, FormatoDellaScheda.orizzontale,
          reason: 'la scheda Consulta di ${m.id} non e\' orizzontale');
      expect(immagini.single, endsWith('-Oriz-1.webp'));
      expect(
          tester
              .widget<Text>(find.byKey(Key('scheda_titolo_consulta_${m.name}')))
              .data,
          'Consulta ${m.displayName}');
      // In cima: sopra le righe del dominio.
      expect(tester.getRect(scheda).top,
          lessThan(tester.getRect(find.byKey(const Key('dominio_righe'))).top));
      await tester.ensureVisible(scheda);
      await tester.pump();
      await tester.tap(scheda);
      await tester.pump(const Duration(milliseconds: 500));
      await passo(tester);
      expect(
          find.byKey(const Key('chat_cerchietto_del_maestro')), findsOneWidget,
          reason: 'il tocco sulla scheda Consulta non apre la chat');
      expect(find.byKey(const Key('chat_nome_del_maestro')), findsOneWidget);
      expect(
          tester
              .widget<Text>(find.byKey(const Key('chat_nome_del_maestro')))
              .data,
          contains(m.displayName));
    });
  }

  // --- EP.13 ed EP.15 ------------------------------------------------------

  for (final m in Maestro.values) {
    testWidgets(
        'EP.13 ed EP.15: nella chat di ${m.id} il pulsante dice LIVE e il '
        'menu\' ha il colore del Maestro', (tester) async {
      await apriLaChat(tester, m);
      expect(
          tester
              .widget<Text>(find.byKey(const Key('chat_dal_vivo_scritta')))
              .data,
          'LIVE');
      expect(find.text('Dal vivo'), findsNothing);

      final menu = tester.widget<PopupMenuButton<Object>>(
          find.byKey(const Key('chat_menu_della_barra')));
      final attesa = MaestroPalette.forKey(ThemeKey.of(m)).surface;
      expect(menu.color, attesa, reason: 'il menu\' non ha il suo colore');
      final c = menu.color!;
      final (r, g, b) = (c.r, c.g, c.b);
      switch (m) {
        case Maestro.medora:
          expect(b, greaterThan(r + 0.05), reason: 'il menu\' non e\' blu');
          expect(b, greaterThan(g + 0.05), reason: 'il menu\' non e\' blu');
        case Maestro.aura:
          expect(g, greaterThan(r + 0.05), reason: 'il menu\' non e\' verde');
          expect(g, greaterThan(b + 0.05), reason: 'il menu\' non e\' verde');
        case Maestro.caligo:
          expect(r, greaterThan(g + 0.05), reason: 'il menu\' non e\' rosso');
          expect(r, greaterThan(b + 0.05), reason: 'il menu\' non e\' rosso');
      }
      // E aperto, a video, lo sfondo e' quello.
      await tester.tap(find.byKey(const Key('chat_menu_della_barra')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      final voce = find.byKey(const Key('chat_i_giorni_prima'));
      expect(voce, findsOneWidget);
      final fondo = tester
          .widgetList<Material>(
              find.ancestor(of: voce, matching: find.byType(Material)))
          .where((x) => x.color != null && x.color!.a > 0)
          .map((x) => x.color)
          .toList();
      expect(fondo, contains(attesa),
          reason: 'aperto, il menu\' non mostra il colore del Maestro');
    });
  }

  // --- EP.14 ----------------------------------------------------------------

  for (final larghezza in const [360.0, 390.0, 412.0]) {
    for (final scala in const [1.0, 1.3]) {
      testWidgets(
          'EP.14: i due contatori stanno su due righe, a $larghezza punti e '
          'testo $scala', (tester) async {
        var righe = 0;
        final dette = <String>[];
        for (final m in Maestro.values) {
          await apriLaChat(tester, m,
              larghezza: larghezza, scala: scala, frasiLunghe: true);
          for (final chiave in const [
            'chat_residuo_domande',
            'chat_residuo_approfondimenti'
          ]) {
            final riga = find.byKey(Key(chiave));
            expect(riga, findsOneWidget, reason: '${m.id}: manca $chiave');
            // **LA FRASE, NON LA CLESSIDRA.** Anche l'icona e' un RichText, e
            // la prima stesura misurava lei: una riga sempre, anche col
            // difetto innestato. Si prende il paragrafo che porta parole.
            final p = tester
                .renderObjectList<RenderParagraph>(
                    find.descendant(of: riga, matching: find.byType(RichText)))
                .firstWhere((x) => x.text.toPlainText().contains(' '));
            final una = TextPainter(
              text: TextSpan(text: 'A', style: p.text.style),
              textDirection: TextDirection.ltr,
              textScaler: p.textScaler,
            )..layout();
            final quante = (p.size.height / una.height).round();
            una.dispose();
            righe += quante;
            // Quanto la riga si e' stretta per stare intera, se si e' stretta.
            final scatola = tester.renderObject<RenderBox>(find
                .ancestor(
                    of: find.byType(Text).evaluate().isEmpty
                        ? riga
                        : find.descendant(
                            of: riga,
                            matching: find.text(p.text.toPlainText())),
                    matching: find.byType(FittedBox))
                .first);
            final stretta =
                (scatola.size.width / p.size.width).clamp(0.0, 1.0) * 100;
            dette.add('${m.id} "${p.text.toPlainText()}" $quante riga, al '
                '${stretta.toStringAsFixed(0)}%');
            expect(quante, 1,
                reason: '${m.id}: "${p.text.toPlainText()}" va a capo '
                    '($quante righe)');
          }
        }
        // ignore: avoid_print
        print('EP.14 MISURA a $larghezza punti, testo $scala: righe dei '
            'contatori $righe per 3 chat (${dette.join('; ')})');
        expect(righe, 6);
      });
    }
  }
}
