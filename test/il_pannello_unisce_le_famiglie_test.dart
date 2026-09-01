import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL PANNELLO PORTA LE DUE FAMIGLIE, ED E' RAGGIUNGIBILE SEMPRE.
///
/// **QUESTA PROVA E' STATA RISCRITTA, non allentata, ordine 2164 voce 7.**
/// Nasceva con l'ordine 2163 voce 3, che chiedeva le due famiglie unite in
/// un solo scorrevole "non a linguette": quella era una lettura sbagliata
/// delle parole di Mauro da parte dell'Architetto, e Mauro l'ha superata
/// chiedendo i DUE TITOLI selezionabili, com'era nelle build precedenti.
/// Cio' che questa prova sorveglia resta: le due famiglie ci sono tutte e
/// due nello stesso pannello, il pannello si apre in qualunque momento
/// della conversazione, e le personali senza il loro dato NON compaiono.
/// Cambia il modo in cui la seconda famiglia si raggiunge: un tocco sul
/// suo titolo invece dello scorrimento.
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

  Future<NavigatorState> monta(WidgetTester tester, AppServices servizi,
      {Map<String, Object> prefs = const {'onboarding.done': true}}) async {
    silenzia();
    SharedPreferences.setMockInitialValues(prefs);
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester
        .pumpWidget(EsotericCircleApp(conIntro: false, services: servizi));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    return tester.state<NavigatorState>(find.byType(Navigator).last);
  }

  Future<void> unoScambio(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField).first, 'Ciao');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();
    for (var i = 0; i < 16; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
  }

  Future<void> apriPannello(WidgetTester tester) async {
    await tester.tap(find.text('Suggerimenti').first, warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('le due intestazioni vivono nello stesso albero, senza tocchi',
      (tester) async {
    final servizi = AppServices(
      ai: const _VocePronta(),
      memory: InMemoryMaestroMemoryRepository(),
      memoryPersistent: false,
    );
    final nav = await monta(tester, servizi, prefs: {
      'onboarding.done': true,
      // La data c'e': le personali sul Sole esistono e la famiglia compare.
      'profile.birthDate': '1990-08-15',
    });
    nav.push(
        MaestroChatScreen.route(maestro: Maestro.medora, services: servizi));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await unoScambio(tester);
    await apriPannello(tester);

    expect(find.byKey(const Key('pannello_suggerimenti')), findsOneWidget);
    // TUTTE E DUE, senza toccare nulla: non sono piu' linguette alternative.
    // I due titoli affiancati, tutti e due nell'albero senza nessun tocco.
    expect(find.text('DOMANDE FREQUENTI'), findsOneWidget,
        reason: 'L\'intestazione delle frequenti non e\' nel pannello.');
    expect(find.text('DOMANDE PERSONALI'), findsOneWidget,
        reason: 'L\'intestazione delle personali non e\' nel pannello '
            'insieme alle frequenti: sono tornate le linguette.');
  });

  testWidgets('a conversazione avviata il pannello resta raggiungibile',
      (tester) async {
    final servizi = AppServices(
      ai: const _VocePronta(),
      memory: InMemoryMaestroMemoryRepository(),
      memoryPersistent: false,
    );
    final nav = await monta(tester, servizi);
    nav.push(
        MaestroChatScreen.route(maestro: Maestro.caligo, services: servizi));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await unoScambio(tester);
    await unoScambio(tester);
    await apriPannello(tester);
    expect(find.byKey(const Key('pannello_suggerimenti')), findsOneWidget,
        reason: 'A chat piena il pannello non si apre piu\'.');
  });

  testWidgets('senza il dato, la famiglia delle personali non compare',
      (tester) async {
    // NESSUNA data di nascita: le personali non hanno il loro dato, quindi
    // niente segnaposto, niente intestazione: la famiglia sparisce.
    final servizi = AppServices(
      ai: const _VocePronta(),
      memory: InMemoryMaestroMemoryRepository(),
      memoryPersistent: false,
    );
    final nav = await monta(tester, servizi);
    nav.push(
        MaestroChatScreen.route(maestro: Maestro.medora, services: servizi));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await unoScambio(tester);
    await apriPannello(tester);

    expect(find.text('DOMANDE FREQUENTI'), findsOneWidget);
    expect(find.text('DOMANDE PERSONALI'), findsNothing,
        reason: 'Senza nessun dato natale la famiglia delle personali '
            'compare lo stesso: o mostra segnaposto, o mostra domande che '
            'parlano di un dato che non c\'e\'.');
  });
}

/// Una voce pronta che risponde subito.
class _VocePronta implements MaestroAiProvider {
  // Aggiunto con la voce S.19: il presagio delle rune passa dal confine come
  // tutte le altre voci, e una finta che non lo implementa non compila.
  @override
  Future<Responso> presagioDelleRune({
    required EsitoGettata esito,
    required String domanda,
    required UserProfile profile,
    NatalContext natal = NatalContext.none,
  }) async =>
      throw const MaestroAiUnavailable();

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
