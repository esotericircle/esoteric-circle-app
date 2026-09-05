import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/features/maestri/rotta_arte.dart';
import 'package:esoteric_circle/features/sigilli/la_mappa_del_sentiero.dart';
import 'package:esoteric_circle/features/sigilli/sentiero_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'istante_dichiarato.dart';

/// I SENTIERI NON HANNO IL CUORE DEI PREFERITI. Coda dell'ordine BF.
///
/// **Parola del fondatore**: "elimina il cuoricino nelle 3 schermate dei
/// sentieri dei traguardi: non sono attivabili, ma cmq non sono funzionalita'
/// che possono e devono finire tra i preferiti in home".
///
/// **La causa**: la rotta del sentiero avvolgeva la schermata in una
/// `SogliaArte`, la soglia delle arti del catalogo, che porta con se' il
/// cuore. L'id salvato sarebbe stato `sigilli_<nome>`, che nessuno scaffale
/// conosce: un cuore che prometteva un posto in home che non esiste.
///
/// **La prova monta LA ROTTA VERA**, `SentieroScreen.route`, non la schermata
/// nuda: il difetto viveva nel guscio della rotta, e una prova che lo salta
/// non lo vedrebbe mai.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final sentiero in Sentiero.values) {
    testWidgets('il sentiero ${sentiero.name} non monta nessun cuore',
        (tester) async {
      tester.view.physicalSize = const Size(360, 797);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      final diario = DiarioDelCammino(orologio: orologioDelleProve);
      await diario.carica();
      await LaMappaDelSentiero.segnaLIngresso(sentiero);

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
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  key: const Key('apri_il_sentiero'),
                  onPressed: () => Navigator.of(context)
                      .push(SentieroScreen.route(sentiero)),
                  child: const Text('apri'),
                ),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.byKey(const Key('apri_il_sentiero')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));

      expect(find.byType(SentieroScreen), findsOneWidget,
          reason: 'la rotta non ha aperto il sentiero: la prova non sta '
              'guardando niente');
      expect(find.byType(CuorePreferita), findsNothing,
          reason: 'il cuore dei preferiti e\' tornato sul sentiero '
              '${sentiero.name}: la rotta e\' rientrata in una SogliaArte');
      expect(find.byType(ConCuore), findsNothing,
          reason: 'il cuore sovrapposto delle schermate senza barra e\' '
              'comparso sul sentiero ${sentiero.name}');
    });
  }
}
