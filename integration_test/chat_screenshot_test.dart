import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Cattura uno screenshot della chat di Medora con una conversazione vera, ma
/// senza rete: usa un provider AI offline con risposte già pronte. Valida la UI
/// (layout, tema, bolle, indicatore). La prova della risposta reale di Vertex
/// resta l'APK installato sul telefono.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Le animazioni del cosmo sono in loop, quindi non si usa mai pumpAndSettle:
  // si avanza con pump a durate fisse.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets('Screenshot della chat di Medora', (tester) async {
    final services = AppServices(
      ai: _ScriptedMedora(),
      memory: InMemoryMaestroMemoryRepository(),
      memoryPersistent: false,
      diagnostics: 'Screenshot offline.',
    );

    await tester.pumpWidget(EsotericCircleApp(services: services));
    await settle(tester);

    // Apre la sezione di Medora dalla bottom bar.
    await tester.tap(find.text('Medora').last);
    await settle(tester);

    // Entra nella chat.
    await tester.tap(find.text('Parla con Medora'));
    await settle(tester);

    // Il disclaimer compare una volta: lo si accetta se presente.
    final accept = find.text('Ho capito, entriamo');
    if (accept.evaluate().isNotEmpty) {
      await tester.tap(accept);
      await settle(tester);
    }

    // Invia un messaggio e attende la risposta pronta.
    await tester.enterText(find.byType(TextField), 'Parlami del mio segno');
    await settle(tester);
    await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
    await settle(tester);
    await tester.pump(const Duration(milliseconds: 400));

    // Cattura lo screenshot come artifact.
    await binding.convertFlutterSurfaceToImage();
    await tester.pump(const Duration(milliseconds: 200));
    await binding.takeScreenshot('medora-chat');
  });
}

/// Medora offline: risponde con un testo fisso, nella sua voce, senza rete.
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
    return 'Il tuo segno racconta una tensione fra il cuore e la volonta\'. '
        'Oggi le stelle ti invitano a scegliere con calma, senza fretta. '
        'Vuoi che guardi un ambito in particolare, l\'amore o il lavoro?';
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
