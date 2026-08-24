import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/core/sigilli/traguardo.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/aura/meditation/meditation_screen.dart';
import 'package:esoteric_circle/features/maestri/aura/meditation/meditation_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'istante_dichiarato.dart';

/// LA MEDITAZIONE HA UNA FINE. Ordine BF voce 05.b, ordine P voce 35.
///
/// La schermata esisteva ma non arrivava a una chiusura: il respiro girava
/// in cerchio per sempre, nessun traguardo si accendeva, e i gradini
/// aur_50 e aur_51 dormivano proprio per questo buco. Adesso la sessione
/// dura dodici cicli di respiro: al compimento il tono si ferma, la scena
/// lo dice, e la regia registra il gesto `meditazione`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('aur_50 e aur_51 sono svegli e chiedono il gesto meditazione', () {
    final loto = Sentieri.di(Sentiero.loto);
    final primo = loto.firstWhere((t) => t.id == 'aur_50');
    final settimo = loto.firstWhere((t) => t.id == 'aur_51');
    expect(primo.dormiente, isFalse,
        reason: 'aur_50 dorme ancora: la fine della meditazione non lo ha '
            'svegliato');
    expect(settimo.dormiente, isFalse);
    expect(primo.condizione, isA<GestiCompiuti>());
    expect((primo.condizione as GestiCompiuti).gesto, 'meditazione');
    expect((primo.condizione as GestiCompiuti).quanti, 1);
    expect((settimo.condizione as GestiCompiuti).quanti, 7);
  });

  testWidgets('la sessione si compie, lo dice, e il gesto arriva al diario',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await diario.carica();
    final player = _LettoreMuto();

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: MaestroScope(child: MeditationScreen(player: player)),
      ),
    ));
    await tester.pump();

    // Si parte: il tono suona e il compimento non c'e' ancora.
    await tester.tap(find.byKey(const Key('meditation_play')));
    await tester.pump();
    expect(player.inSuono, isTrue);
    expect(find.byKey(const Key('meditazione_compiuta')), findsNothing);
    expect(diario.haFatto('meditazione'), isFalse,
        reason: 'il gesto si registra al compimento, non all\'apertura');

    // A meta' sessione non e' compiuta: fermarsi qui non registra niente.
    await tester.pump(const Duration(seconds: 60));
    expect(find.byKey(const Key('meditazione_compiuta')), findsNothing);

    // Dodici cicli da undici secondi: al compimento il tono si ferma, la
    // scena lo dice, e il diario ha il gesto.
    await tester.pump(const Duration(seconds: 80));
    await tester.pump();
    expect(find.byKey(const Key('meditazione_compiuta')), findsOneWidget,
        reason: 'la sessione e\' finita in silenzio: la persona non sa di '
            'essere arrivata');
    expect(player.inSuono, isFalse,
        reason: 'il tono continua a suonare oltre il compimento');
    expect(diario.haFatto('meditazione'), isTrue,
        reason: 'il gesto meditazione non e\' arrivato al diario: aur_50 '
            'non potra\' mai maturare');
  });

  testWidgets('fermarsi a meta\' non e\' compiere', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await diario.carica();
    final player = _LettoreMuto();

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: MaestroScope(child: MeditationScreen(player: player)),
      ),
    ));
    await tester.pump();

    await tester.tap(find.byKey(const Key('meditation_play')));
    await tester.pump(const Duration(seconds: 30));
    await tester.tap(find.byKey(const Key('meditation_play')));
    await tester.pump(const Duration(seconds: 150));
    expect(find.byKey(const Key('meditazione_compiuta')), findsNothing,
        reason: 'la sessione interrotta si e\' dichiarata compiuta lo '
            'stesso: il timer non e\' stato fermato');
    expect(diario.haFatto('meditazione'), isFalse,
        reason: 'fermarsi a meta\' ha registrato il gesto: chi apre e chiude '
            'farmerebbe i traguardi del respiro');
  });
}

/// Un lettore che non suona davvero ma ricorda se sta suonando.
class _LettoreMuto implements TonePlayer {
  bool inSuono = false;

  @override
  Future<void> play(MeditationPreset preset) async => inSuono = true;

  @override
  Future<void> stop() async => inSuono = false;
}
