// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/archetypes/archetype_history.dart';
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/feature_flags/feature_flag_service.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/core/ricordi/registro_dei_ricordi.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/features/maestri/domain_screen.dart';
import 'package:esoteric_circle/features/santuario/greeting_controller.dart';
import 'package:esoteric_circle/features/scene/la_scena_in_video.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart' show MaestroLens;
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'il_diario_finto.dart';

/// **LE ANTEPRIME DELLA SCENA DEI MAESTRI**, ordine FW voce FW.06, 15 ottobre
/// 2026: a 360 per 797 punti logici col rapporto di pixel 3, in
/// `docs/preview/FW/`, con `--dart-define=STATO=dopo`. Per ogni Maestro, il
/// dominio sulla scena ferma e la chat sulla scena ferma col benvenuto.
///
/// Il filmato vero si guarda sul telefono: qui il lettore finto fallisce
/// subito, come un video che non si carica (R9), cosi' la scena e' gia'
/// `ferma` sul suo ultimo fotogramma al primo pump, lo stesso stato che un
/// video davvero finito lascerebbe in scena.
const _stato = String.fromEnvironment('STATO');

class _FilmatoFermo implements LettoreDiScena {
  VoidCallback? _ascolta;
  @override
  bool get pronto => false;
  @override
  bool get fallito => true;
  @override
  bool get cominciato => false;
  @override
  bool get finito => false;
  @override
  void ascolta(VoidCallback? quandoCambia) => _ascolta = quandoCambia;
  @override
  Future<void> apri() async => _ascolta?.call();
  @override
  Future<void> volume(double quanto) async {}
  @override
  Future<void> avvia() async {}
  @override
  Future<void> sospendi() async {}
  @override
  Widget disegna() => const SizedBox.shrink();
  @override
  void chiudi() {}
}

class _AiMuto implements MaestroAiProvider {
  @override
  bool get isReady => true;
  @override
  Future<String> reply({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory memory,
    required List<ChatMessage> history,
    required String userMessage,
    NatalContext natal = NatalContext.none,
    bool insistiSullAncoraggio = false,
    String? rispostaGiaData,
  }) async =>
      throw UnsupportedError('non chiamato in anteprima');
  @override
  Future<Responso> presagioDelleRune({
    required EsitoGettata esito,
    required String domanda,
    required UserProfile profile,
  }) async =>
      throw UnsupportedError('non chiamato in anteprima');
  @override
  Future<MaestroReply> consult({
    required Maestro maestro,
    required String theme,
    required UserProfile profile,
    MaestroMemory memory = MaestroMemory.empty,
    NatalContext? natal,
    ConsultDepth depth = ConsultDepth.breve,
  }) async =>
      throw UnsupportedError('non chiamato in anteprima');
  @override
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<ChatMessage> history,
  }) async =>
      null;
  @override
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
    UserProfile? profile,
  }) async =>
      throw UnsupportedError('non chiamato in anteprima');
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  final radice = GlobalKey();

  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
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

  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> passa(WidgetTester tester, [int volte = 3]) async {
    for (var i = 0; i < volte; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  Future<void> decodifica(WidgetTester tester) async {
    await tester.runAsync(() async {
      for (final e in find.byType(Image).evaluate()) {
        final w = e.widget as Image;
        await precacheImage(w.image, e);
      }
    });
  }

  Future<void> scatta(WidgetTester tester, String nome) async {
    await decodifica(tester);
    await passa(tester, 2);
    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 3.0);
      final dati = await img.toByteData(format: ui.ImageByteFormat.png);
      final dir = Directory('docs/preview/FW');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File('${dir.path}/${nome}_$_stato.png')
          .writeAsBytesSync(dati!.buffer.asUint8List());
      print(
          'FW ANTEPRIMA: ${dir.path}/${nome}_$_stato.png ${img.width}x${img.height}');
      img.dispose();
    });
  }

  Future<void> montaDominio(WidgetTester tester, Maestro maestro) async {
    silenzia();
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => GreetingController()),
        ChangeNotifierProvider(
          create: (ctx) =>
              FeatureFlagService(entitlement: ctx.read<EntitlementService>())
                ..initialize(),
        ),
      ],
      child: RepaintBoundary(
        key: radice,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          home: MaestroScope(
            maestro: maestro,
            child: DomainScreen(
                maestro: maestro, fabbricaDellaScena: () => _FilmatoFermo()),
          ),
        ),
      ),
    ));
    await passa(tester, 3);
  }

  Future<void> montaChat(WidgetTester tester, Maestro maestro) async {
    silenzia();
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2391);
    addTearDown(tester.view.reset);
    final memory = InMemoryMaestroMemoryRepository();
    await memory.saveProfile(
        UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)));
    final services = AppServices(
      ai: _AiMuto(),
      memory: memory,
      memoryPersistent: false,
      diagnostics: 'anteprima',
    );
    final registro = RegistroDeiRicordi(porta: PortaFintaDelDiario());
    final allowance = QuestionAllowance(freeDailyLimit: 3);
    final controller = MaestroChatController(
      maestro: maestro,
      conversazioneNuova: true,
      leConversazioniDelDiario: () async => const [],
      segnaNeiRicordi: (_) {},
      ai: services.ai,
      memory: services.memory,
      allowance: allowance,
      tier: () => Tier.free,
      natal: () => NatalContext.none,
    )..init();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<MaestroChatController>.value(value: controller),
        ChangeNotifierProvider<QuestionAllowance>.value(value: allowance),
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ArchetypeHistory()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider<RegistroDeiRicordi>.value(value: registro),
        Provider<AppServices>.value(value: services),
      ],
      child: RepaintBoundary(
        key: radice,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          home: MaestroScope(
            maestro: maestro,
            child: MaestroChatScreen(
                maestro: maestro, fabbricaDellaScena: () => _FilmatoFermo()),
          ),
        ),
      ),
    ));
    await passa(tester, 3);
  }

  for (final m in Maestro.values) {
    testWidgets('FW.06 ${m.id}: il dominio sulla scena ferma', (tester) async {
      if (_stato.isEmpty) return;
      await montaDominio(tester, m);
      await scatta(tester, 'fw06_${m.id}_dominio_ferma');
    });

    testWidgets('FW.06 ${m.id}: la chat sulla scena ferma col benvenuto',
        (tester) async {
      if (_stato.isEmpty) return;
      await montaChat(tester, m);
      await scatta(tester, 'fw06_${m.id}_chat_ferma');
    });
  }
}
