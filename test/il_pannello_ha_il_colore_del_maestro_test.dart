import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL PANNELLO DEI SUGGERIMENTI PRENDE IL COLORE DEL MAESTRO DELLA SCHERMATA.
///
/// Ordine 2163, voce 2, visto: nella chat di Medora, blu notte, il pannello
/// si apriva ROSSO di Caligo. La causa accertata in premessa C: il foglio
/// vive nell'overlay del navigator e veniva riavvolto in un MaestroScope
/// SENZA maestro, che quindi leggeva il controller (l'ultimo Maestro
/// attivo) invece della rotta. Il colore si deriva dal Maestro della
/// schermata, che il pannello riceve gia' come parametro dalla rotta.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    final messenger = binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(
        EventChannel(nome),
        MockStreamHandler.inline(onListen: (args, events) {}),
      );
    }
  }

  testWidgets('nei tre domini il pannello veste il colore di casa',
      (tester) async {
    silenzia();
    SharedPreferences.setMockInitialValues({'onboarding.done': true});
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final servizi = AppServices(
      ai: const _VocePronta(),
      memory: InMemoryMaestroMemoryRepository(),
      memoryPersistent: false,
    );
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: servizi));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).last);

    final colpe = <String>[];
    for (final maestro in Maestro.fixedOrder) {
      nav.push(MaestroChatScreen.route(maestro: maestro, services: servizi));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // Un primo scambio: oggi l'icona a stelline compare a conversazione
      // avviata, e il pannello si apre da li'.
      await tester.enterText(find.byType(TextField).first, 'Ciao');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pump();
      for (var i = 0; i < 18; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }

      // Si apre il pannello dall'icona a stelline accanto al campo.
      await tester.tap(find.text('Suggerimenti').first, warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final pannello = find.byKey(const Key('pannello_suggerimenti'));
      if (pannello.evaluate().isEmpty) {
        colpe.add('${maestro.displayName}: il pannello non si e\' aperto');
      } else {
        // Il colore si legge dal vestito RISOLTO del pannello: se lo scope
        // sbaglia Maestro, qui esce la palette sbagliata.
        final scatola = tester.widget<Container>(pannello.first);
        final deco = scatola.decoration! as BoxDecoration;
        final colori = (deco.gradient! as LinearGradient).colors;
        final attesa = MaestroPalette.forKey(ThemeKey.of(maestro));
        if (colori.first != attesa.surfaceElevated ||
            colori.last != attesa.deepest) {
          // Di chi e' il colore sbagliato? Si nomina, per leggere il rosso.
          String diChi = 'di nessuno';
          for (final altro in Maestro.values) {
            final p = MaestroPalette.forKey(ThemeKey.of(altro));
            if (colori.first == p.surfaceElevated) diChi = altro.displayName;
          }
          colpe.add('${maestro.displayName}: il pannello veste il colore '
              '$diChi invece del suo');
        }
        await tester.tapAt(const Offset(10, 60));
        await tester.pump(const Duration(milliseconds: 400));
      }
      nav.pop();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });
}


/// Una voce pronta che risponde subito, quanto basta per avviare la chat.
class _VocePronta implements MaestroAiProvider {
  const _VocePronta();

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
      'Il cielo osserva con te questa domanda e la tiene aperta.';

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
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
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
}
