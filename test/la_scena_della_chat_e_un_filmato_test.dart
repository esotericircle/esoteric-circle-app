import 'package:esoteric_circle/core/archetypes/archetype_history.dart';
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/la_scena_del_maestro.dart';
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
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_controller.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/features/maestri/chat/widgets/chat_empty_state.dart';
import 'package:esoteric_circle/features/scene/la_scena_in_video.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'il_diario_finto.dart';

/// **LA SCENA DELLA CHAT E' UN FILMATO.** Ordine FW voce FW.04, 15 ottobre
/// 2026: il video del Maestro parte all'apertura della chat vuota, prima del
/// primo messaggio, al posto del busto fermo; un tocco lo fa sfumare; alla
/// prima risposta la scena sale e scompare, con lo stesso meccanismo del
/// tocco che salta delle altre scene.
class _Finta implements LettoreDiScena {
  _Finta();
  VoidCallback? _ascolta;
  bool _pronto = false, _cominciato = false;
  final bool _fallito = false;
  final bool _finito = false;
  int aperture = 0, sospensioni = 0;

  @override
  bool get pronto => _pronto;
  @override
  bool get fallito => _fallito;
  @override
  bool get cominciato => _cominciato;
  @override
  bool get finito => _finito;
  @override
  void ascolta(VoidCallback? q) => _ascolta = q;
  @override
  Future<void> apri() async {
    aperture++;
    _pronto = true;
    _ascolta?.call();
  }

  @override
  Future<void> volume(double q) async {}
  @override
  Future<void> avvia() async {}
  @override
  Future<void> sospendi() async => sospensioni++;
  @override
  Widget disegna() =>
      const ColoredBox(key: Key('finta_del_filmato_chat'), color: Color(0xFF102030));
  @override
  void chiudi() {}

  void comincia() {
    _cominciato = true;
    _ascolta?.call();
  }
}

class _Ai implements MaestroAiProvider {
  bool rispondi = false;

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
  }) async {
    while (!rispondi) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
    return 'Il cielo ti e\' propizio.';
  }

  @override
  Future<Responso> presagioDelleRune({
    required EsitoGettata esito,
    required String domanda,
    required UserProfile profile,
  }) async =>
      throw const MaestroAiUnavailable();

  @override
  Future<MaestroReply> consult({
    required Maestro maestro,
    required String theme,
    required UserProfile profile,
    MaestroMemory memory = MaestroMemory.empty,
    NatalContext? natal,
    ConsultDepth depth = ConsultDepth.breve,
  }) async =>
      throw const MaestroAiUnavailable();

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
      throw const MaestroAiUnavailable();
}

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenceSensors() {
    final messenger = binding.defaultBinaryMessenger;
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
  }

  setUp(silenceSensors);

  Future<_Ai> monta(
    WidgetTester tester, {
    required Maestro maestro,
    required _Finta lettore,
    bool riduci = false,
  }) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    final memory = InMemoryMaestroMemoryRepository();
    await memory.saveProfile(
        UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)));
    final ai = _Ai();
    final services = AppServices(
      ai: ai,
      memory: memory,
      memoryPersistent: false,
      diagnostics: 'test',
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
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: riduci),
          child: MaestroScope(
            maestro: maestro,
            child: MaestroChatScreen(
                maestro: maestro, fabbricaDellaScena: () => lettore),
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));
    return ai;
  }

  testWidgets('FW.04: il video della chat parte, prima del primo messaggio',
      (tester) async {
    final lettore = _Finta();
    await monta(tester, maestro: Maestro.medora, lettore: lettore);
    expect(lettore.aperture, 1);
    expect(find.byKey(const Key('chat_benvenuto')), findsOneWidget);
    expect(find.byType(ChatEmptyState), findsOneWidget);
  });

  testWidgets('FW.04: un tocco fa sfumare il video della chat',
      (tester) async {
    final lettore = _Finta();
    await monta(tester, maestro: Maestro.aura, lettore: lettore);
    lettore.comincia();
    await tester.pump();
    expect(find.byKey(const Key('finta_del_filmato_chat')), findsOneWidget);
    await tester.tap(find.byKey(const Key('chat_scena_fotogramma')));
    await tester.pump(const Duration(milliseconds: 400));
    expect(lettore.sospensioni, 1,
        reason: 'il tocco non ha fatto sospendere il lettore della chat');
  });

  testWidgets(
      'FW.04: fermo, il fotogramma mostrato e\' l\'ultimo della scena della chat',
      (tester) async {
    final lettore = _Finta();
    await monta(tester, maestro: Maestro.caligo, lettore: lettore);
    final scena = LaScenaDelMaestro.dellaChat(Maestro.caligo);
    expect(
        tester
            .widget<Image>(find.byKey(const Key('chat_scena_fotogramma')))
            .image,
        isA<AssetImage>().having(
            (a) => a.assetName, 'assetName', scena.primoFotogramma));
  });

  testWidgets('FW.04: con Riduci Movimento il video non si apre nemmeno',
      (tester) async {
    final lettore = _Finta();
    await monta(
        tester, maestro: Maestro.medora, lettore: lettore, riduci: true);
    expect(lettore.aperture, 0);
  });

  testWidgets(
      'FW.04: alla prima risposta la scena sale e scompare, il busto non torna',
      (tester) async {
    final lettore = _Finta();
    final ai = await monta(tester, maestro: Maestro.medora, lettore: lettore);
    lettore.comincia();
    await tester.pump();
    expect(find.byType(ChatEmptyState), findsOneWidget);

    await tester.enterText(find.byKey(const Key('chat_campo')), 'Che dici?');
    await tester.pump();
    await tester.tap(find.byKey(const Key('chat_invio')));
    await tester.pump();
    // **LA RISPOSTA NON ASPETTA LA FINE DEL VIDEO**: il video sta ancora
    // "girando" (non saltato, non fallito) quando il messaggio parte, e la
    // regia lo deve far sfumare da sola.
    await tester.pump(const Duration(milliseconds: 50));
    expect(lettore.sospensioni, greaterThanOrEqualTo(1),
        reason: 'il primo messaggio non ha fatto sfumare il video in corso');

    ai.rispondi = true;
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    expect(find.byType(ChatEmptyState), findsNothing,
        reason: 'la scena della chat vuota e\' ancora in scena dopo la '
            'risposta');
  });
}
