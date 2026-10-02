import 'dart:math';

import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/core/rituals/il_corpus_del_presagio.g.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/rune/rune_draw_screen.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LE RUNE NON CHIAMANO PIU' IL MODELLO. Ordine EX voce 03.**
///
/// Col corpus dell'Architetto completo la lettura di una gettata si compone
/// sul telefono: la schermata vera, con un modello pronto che conta le
/// chiamate, non lo chiama mai. Prima del corpus le chiamate per gettata
/// erano 1,85 in media (ordine EW, `docs/costi/costo_per_funzione.md`).
void main() {
  testWidgets('una gettata delle tre Norne: zero chiamate al modello',
      (tester) async {
    expect(corpusDelPresagio.completo, isTrue);
    SharedPreferences.setMockInitialValues({});
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final name in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(
        EventChannel(name),
        MockStreamHandler.inline(onListen: (args, events) {}),
      );
    }
    tester.view.physicalSize = const Size(430, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final modello = _IlModelloCheConta();
    final servizi = AppServices(
      ai: modello,
      memory: InMemoryMaestroMemoryRepository(),
      memoryPersistent: false,
    );
    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<AppServices?>.value(value: servizi),
        ChangeNotifierProvider(
            create: (_) =>
                MaestroController(initial: const ThemeKey.of(Maestro.caligo))),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => QuestionAllowance()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: RuneDrawScreen(random: Random(3)),
      ),
    ));
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    await tester.tap(find.byKey(const Key('rune_segment_norne')));
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    final getta = find.byKey(const Key('rune_cast_button'));
    await tester.ensureVisible(getta);
    await tester.pump();
    await tester.tap(getta);
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }

    expect(find.byKey(const Key('rune_presage')), findsOneWidget);
    expect(modello.presagi, 0,
        reason: 'col corpus completo la gettata non chiama il modello');
    // La lettura e' passata dal corpus: la memoria di cio' che la persona
    // ha letto e' scritta sul telefono.
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('rune.presagio.memoria'), isNotNull);
    expect(prefs.getString('rune.presagio.memoria'), isNotEmpty);
  });
}

/// Un modello pronto che conta i presagi chiesti. Il resto dell'interfaccia
/// qui non serve.
class _IlModelloCheConta implements MaestroAiProvider {
  int presagi = 0;

  @override
  bool get isReady => true;

  @override
  Future<Responso> presagioDelleRune({
    required EsitoGettata esito,
    required String domanda,
    required UserProfile profile,
    NatalContext natal = NatalContext.none,
  }) async {
    presagi++;
    throw const MaestroAiUnavailable();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
