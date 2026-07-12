import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Cattura headless della chat di Medora, con font reali (corpo e icone),
/// provider AI offline e una conversazione gia' seminata. Nessuna rete, nessun
/// device. Scrive il PNG in docs/preview/medora-chat.png.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> loadFont(String family, String path) async {
    final loader = FontLoader(family);
    final bytes = File(path).readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    await loader.load();
  }

  List<String> materialIconsCandidates() {
    const rel = 'artifacts/material_fonts/MaterialIcons-Regular.otf';
    final env = Platform.environment;
    final out = <String>[
      if (env['MATERIAL_ICONS_FONT'] != null) env['MATERIAL_ICONS_FONT']!,
      if (env['FLUTTER_ROOT'] != null) '${env['FLUTTER_ROOT']}/bin/cache/$rel',
    ];
    // L'eseguibile puo' essere dart (.../cache/dart-sdk/bin/dart) o
    // flutter_tester (.../cache/artifacts/engine/.../flutter_tester): si risale
    // di qualche livello provando entrambe le forme, cosi' si trova la cache in
    // ogni caso.
    var dir = File(Platform.resolvedExecutable).parent;
    for (var i = 0; i < 8; i++) {
      out.add('${dir.path}/$rel');
      out.add('${dir.path}/bin/cache/$rel');
      dir = dir.parent;
    }
    return out;
  }

  Future<void> loadFonts() async {
    await loadFont('Cinzel', 'assets/fonts/Cinzel-variable.ttf');
    await loadFont('EBGaramond', 'assets/fonts/EBGaramond-variable.ttf');
    // Icone Material: si risolve il font dalla cache dell'SDK di Flutter a
    // partire dall'eseguibile Dart, cosi' il test e' autosufficiente. Un
    // eventuale percorso esplicito via ambiente ha la precedenza.
    for (final candidate in materialIconsCandidates()) {
      if (File(candidate).existsSync()) {
        await loadFont('MaterialIcons', candidate);
        break;
      }
    }
  }

  // Silenzia i sensori: in headless non esistono, e senza questo la parallasse
  // solleva una MissingPluginException asincrona che sporca il test.
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

  Future<void> step(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('Cattura la chat di Medora', (tester) async {
    silenceSensors();
    await loadFonts();

    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Conversazione gia' avvenuta, cosi' la cattura e' deterministica.
    final memory = InMemoryMaestroMemoryRepository();
    await memory.saveProfile(
      UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)),
    );
    Future<void> add(ChatRole role, String text) =>
        memory.appendMessage(Maestro.medora, ChatMessage(role: role, text: text));
    await add(ChatRole.user, 'Parlami del mio segno');
    await add(
      ChatRole.maestro,
      'Il tuo segno racconta una tensione fra il cuore e la volontà. Oggi le '
      'stelle ti invitano a scegliere con calma, senza fretta. Vuoi che guardi '
      'un ambito, l\'amore o il lavoro?',
    );
    await add(ChatRole.user, 'L\'amore, ti ascolto');
    await add(
      ChatRole.maestro,
      'Venere ti sfiora con dolcezza. Un legame chiede verità, non '
      'perfezione. Prova a dire una cosa sincera a chi ami oggi, poi osserva '
      'come cambia la luce fra voi.',
    );

    final services = AppServices(
      ai: _ScriptedMedora(),
      memory: memory,
      memoryPersistent: true,
      diagnostics: 'Cattura offline.',
    );

    final rootKey = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: rootKey,
        child: EsotericCircleApp(services: services),
      ),
    );
    await step(tester);

    // Forza il Maestro attivo su Medora (tema blu) e alza la leggibilita' con
    // un tier senza blur pesante. Selezionare Medora porta anche lo shell sulla
    // sua schermata, da cui si apre la chat.
    final ctx = tester.element(find.byType(MaterialApp));
    ctx.read<MaestroController>().selectMaestro(Maestro.medora);
    ctx.read<QualityTierController>().setTier(QualityTier.medium);
    await step(tester);

    await tester.tap(find.text('Parla con Medora'));
    await step(tester);
    await step(tester);

    await tester.runAsync(() async {
      final boundary =
          rootKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      final out = File('docs/preview/medora-chat.png');
      out.createSync(recursive: true);
      out.writeAsBytesSync(data!.buffer.asUint8List());
    });

    expect(File('docs/preview/medora-chat.png').existsSync(), isTrue);
  });
}

/// Medora offline: risponde con un testo fisso, senza rete.
class _ScriptedMedora implements MaestroAiProvider {
  @override
  bool get isReady => true;

  @override
  Future<String> reply({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory memory,
    required List<ChatMessage> history,
    required String userMessage,
  }) async {
    return 'Le stelle ti ascoltano. Dimmi ancora, cerchiamo insieme il filo.';
  }

  @override
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<ChatMessage> history,
  }) async =>
      null;
}
