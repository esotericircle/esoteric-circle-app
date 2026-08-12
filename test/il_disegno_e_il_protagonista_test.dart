import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/sigilli/sentiero_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL DISEGNO DEL SENTIERO E' IL PROTAGONISTA. Ordine S voce 01.
///
/// **Due regole dello stesso ordine P si combattevano, e vinceva quella
/// sbagliata.** La voce P.33 vuole il disegno come prima cosa che si vede; la
/// voce P.36 fa scendere lo scorrimento fino al traguardo raggiunto appena la
/// schermata si apre. Il risultato a video: chi apriva il sentiero atterrava
/// sull'elenco e il disegno non lo vedeva mai. Non era un difetto di nessuna
/// delle due voci, era la loro somma.
///
/// **Decisione di Mauro: la discesa automatica si toglie, il codice della misura
/// resta e passa al TOCCO.** Buttarlo sarebbe stato uno spreco: quella misura e'
/// costata una voce intera, perche' prima il punto di arrivo si stimava da
/// un'altezza scritta a mano e scivolava.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> caricaCaratteri() async {
    for (final f in const [
      ['Cinzel', 'assets/fonts/Cinzel-variable.ttf'],
      ['EBGaramond', 'assets/fonts/EBGaramond-variable.ttf'],
    ]) {
      final loader = FontLoader(f[0]);
      loader.addFont(
          Future.value(ByteData.view(File(f[1]).readAsBytesSync().buffer)));
      await loader.load();
    }
  }

  /// LO SCHERMO VERO, quello su cui l'app viene guardata: 360 per 797 punti.
  const Size schermoReale = Size(360, 797);

  Future<void> monta(
    WidgetTester tester, {
    Sentiero sentiero = Sentiero.costellazione,
    int accesi = 17,
    bool riduciMovimento = false,
  }) async {
    await caricaCaratteri();
    tester.view.physicalSize = schermoReale;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final diario = DiarioDelCammino();
    await diario.carica();
    // Un cammino a meta': senza traguardi accesi il punto raggiunto sarebbe in
    // cima e il tocco non avrebbe dove portare, cioe' la prova non misurerebbe
    // niente.
    for (final t in Sentieri.miniDi(sentiero).take(accesi)) {
      await diario.accendi(t.id);
    }
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => QuestionAllowance()),
        ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
      ],
      child: MediaQuery(
        data: MediaQueryData(
            size: schermoReale, disableAnimations: riduciMovimento),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          home: MaestroScope(
            child: SentieroScreen(sentiero: sentiero, senzaVolo: false),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
  }

  ScrollPosition posizione(WidgetTester tester) =>
      tester.state<ScrollableState>(find.byType(Scrollable).first).position;

  group('All\'apertura si resta sul disegno', () {
    testWidgets('lo scorrimento e\' a zero e il disegno e\' tutto dentro',
        (tester) async {
      await monta(tester);
      expect(posizione(tester).pixels, 0.0,
          reason: 'la schermata si e\' mossa da se\': chi apre il sentiero '
              'atterra sull\'elenco e il disegno non lo vede mai');

      final disegno = tester.getRect(find.byKey(const Key('sentiero_disegno')));
      final viewport = tester.getRect(find.byType(Scrollable).first);
      expect(disegno.top, greaterThanOrEqualTo(viewport.top - 0.5),
          reason: 'il disegno comincia sopra il viewport: ne resta fuori un '
              'pezzo proprio all\'apertura');
      expect(disegno.bottom, lessThanOrEqualTo(viewport.bottom + 0.5),
          reason: 'il disegno finisce ${disegno.bottom} oltre il viewport, che '
              'arriva a ${viewport.bottom}: all\'apertura non ci sta dentro');
    });

    testWidgets('il disegno prende almeno il 55 per cento dell\'altezza utile',
        (tester) async {
      await monta(tester);
      final disegno = tester.getRect(find.byKey(const Key('sentiero_disegno')));
      final viewport = tester.getRect(find.byType(Scrollable).first);
      final quota = disegno.height / viewport.height;
      expect(quota, greaterThanOrEqualTo(0.55),
          reason: 'il disegno prende il ${(quota * 100).toStringAsFixed(1)} per '
              'cento dell\'altezza utile invece del 55 chiesto: e\' ancora un '
              'francobollo in cima a un elenco');
      // E non se la prende tutta: sotto deve restare abbastanza da capire che
      // c'e' altro da leggere.
      expect(quota, lessThan(0.75),
          reason: 'il disegno occupa quasi tutto: nessuno capisce che sotto '
              'c\'e' ' un elenco');
    });

    testWidgets('il comando porta al punto in cui sei, e prima non si muove',
        (tester) async {
      await monta(tester);
      expect(posizione(tester).pixels, 0.0);
      final comando = find.byKey(const Key('sentiero_vai_al_punto'));
      expect(comando, findsOneWidget,
          reason: 'il comando non c\'e\': togliendo la discesa automatica il '
              'punto raggiunto non si raggiunge piu\' in nessun modo');
      await tester.tap(comando);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1600));
      expect(posizione(tester).pixels, greaterThan(100.0),
          reason: 'il tocco non ha portato da nessuna parte: la misura della '
              'voce P.36 e\' stata buttata invece di essere spostata');
    });

    testWidgets('con Riduci Movimento vale lo stesso, e il tocco non vola',
        (tester) async {
      await monta(tester, riduciMovimento: true);
      expect(posizione(tester).pixels, 0.0,
          reason: 'con Riduci Movimento la schermata si e\' mossa da se\'');
      await tester.tap(find.byKey(const Key('sentiero_vai_al_punto')));
      // UN SOLO fotogramma: senza volo il punto si raggiunge subito. Se ci
      // arrivasse animato, dopo un fotogramma saremmo a meta' strada.
      await tester.pump();
      final dopoUnFotogramma = posizione(tester).pixels;
      expect(dopoUnFotogramma, greaterThan(100.0),
          reason: 'con Riduci Movimento il punto si raggiunge con un volo: '
              'dopo un fotogramma siamo a $dopoUnFotogramma');
    });
  });
}
