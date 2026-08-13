import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/frase_di_ripiego.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/features/maestri/chat/widgets/chat_composer.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:esoteric_circle/core/maestro/tempi_dell_attesa.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Quando la voce tace, il Maestro NON resta muto, e la causa non si perde.
///
/// Due regole in una prova sola, perche' sono la stessa cosa vista dai due lati:
/// a video la persona deve leggere un ripiego DICHIARATO nel tono del suo
/// Maestro, e dietro le quinte il tipo dell'eccezione vera deve sopravvivere.
///
/// La prova monta l'app dall'avvio vero e arriva alla chat camminando, non
/// costruendo la schermata a mano: una prova che riceve il dato gia' pronto
/// passerebbe anche se nell'app vera il ripiego non arrivasse mai, e per due
/// giri di lavoro e' esattamente cio' che e' successo.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  // In headless i sensori non esistono: si silenziano per evitare l'eccezione
  // asincrona della parallasse.
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

  /// Un passo della chat, che adesso comprende LA PAUSA DEL CONSULTO.
  ///
  /// Quattrocento millisecondi bastavano finche' la risposta compariva appena
  /// la voce tornava. Dal 3 agosto 2026 anche il RIPIEGO passa dalla pausa
  /// minima: una risposta che fallisce non fa sparire la scena di colpo, la fa
  /// chiudere al suo tempo come le altre. Il tempo si legge dal dato e non si
  /// scrive qui: se domani la pausa cambia, questa prova la segue da sola.
  Future<void> step(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(TempiDellAttesa.durataMinima +
        TempiDellAttesa.dissolvenza +
        const Duration(milliseconds: 400));
  }

  /// I servizi veri dell'app, con una voce che solleva l'errore che il progetto
  /// ha davvero: l'API di Firebase AI non abilitata.
  Future<AppServices> serviziConVoceInGuasto() async {
    final memory = InMemoryMaestroMemoryRepository();
    // Disclaimer gia' accettato, cosi' non copre la chat con la modale.
    await memory.saveProfile(
        UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)));
    return AppServices(
      ai: _VoceInGuasto(),
      memory: memory,
      memoryPersistent: false,
      diagnostics: 'prova del silenzio',
    );
  }

  Future<void> apriLaChat(
    WidgetTester tester,
    AppServices servizi,
    Maestro maestro,
  ) async {
    await tester
        .pumpWidget(EsotericCircleApp(conIntro: false, services: servizi));
    await step(tester);
    final ctx = tester.element(find.byType(MaterialApp));
    ctx.read<MaestroController>().selectMaestro(maestro);
    await step(tester);
    await tester.tap(find.byKey(const Key('santuario_central_bust')));
    await step(tester);
    await step(tester);
    await tester.tap(find.text('Consulta ${maestro.displayName}'));
    await step(tester);
  }

  Future<void> chiediQualcosa(WidgetTester tester) async {
    final campo = find.descendant(
      of: find.byType(ChatComposer),
      matching: find.byType(TextField),
    );
    expect(campo, findsOneWidget,
        reason: 'senza il campo della domanda non si arriva al ramo del guasto');
    await tester.enterText(campo, 'Che cosa mi dice il mio cammino?');
    await step(tester);
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await step(tester);
    await step(tester);
  }

  // Enumerati, non campionati: la regola vale per tutti e tre i Maestri, e per
  // quelli che nascessero domani.
  for (final maestro in Maestro.values) {
    testWidgets(
        'La chat di ${maestro.id} mostra il ripiego dichiarato quando la voce tace',
        (tester) async {
      silenceSensors();
      tester.view.physicalSize = const Size(1080, 2392);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final servizi = await serviziConVoceInGuasto();
      await apriLaChat(tester, servizi, maestro);
      await chiediQualcosa(tester);

      // 1. La bolla APRE col ripiego nel tono di questo Maestro, e non con la
      //    frase unica che prima valeva per tutti e tre.
      //
      //    Si cerca l'inizio e non il testo esatto: dal 2 agosto 2026 il
      //    ripiego non e' piu' solo una scusa, prosegue con una lettura vera
      //    costruita dai dati sul dispositivo e con una via d'uscita. Cercare
      //    la stringa intera vorrebbe dire riscrivere la prova ogni volta che
      //    la lettura si rifinisce, e una prova cosi' si finisce per allentarla.
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Text &&
              (w.data ?? '').startsWith(RipiegoDelMaestro.silenzioDi(maestro)),
        ),
        findsOneWidget,
        reason: 'il Maestro deve dire qualcosa in carattere, non tacere',
      );

      // 2. E la bolla DICHIARA di essere un ripiego: senza questa riga la
      //    persona la legge come una risposta.
      expect(
        find.text(RipiegoDelMaestro.etichettaDi(maestro)),
        findsOneWidget,
        reason: 'ogni ripiego dichiara di essere un ripiego, anche a schermo',
      );
    });
  }

  testWidgets('Il tipo dell\'eccezione vera sopravvive al guasto',
      (tester) async {
    silenceSensors();
    tester.view.physicalSize = const Size(1080, 2392);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final servizi = await serviziConVoceInGuasto();
    expect(servizi.guasti.haGuasti, isFalse,
        reason: 'si parte da un registro pulito');

    await apriLaChat(tester, servizi, Maestro.medora);
    await chiediQualcosa(tester);

    final ultimo = servizi.guasti.ultimo;
    expect(ultimo, isNotNull,
        reason: 'il guasto deve esistere dopo un turno fallito: '
            'se il registro e\' vuoto, qualcuno lo sta ancora inghiottendo');
    // Il TIPO e' il dato che i `catch (_)` buttavano via, ed e' l'unico che
    // distingue un servizio spento da una quota finita.
    expect(ultimo!.tipo, '_ApiSpenta');
    expect(ultimo.operazione, 'reply');
    expect(ultimo.messaggio, contains('firebasevertexai.googleapis.com'));
    // E il registro sa riconoscere da solo il caso che non si corregge nel
    // codice, cosi' il pannello di messa a punto lo puo' dire a chi guarda.
    expect(ultimo.eLApiSpenta, isTrue);
  });
}

/// L'eccezione che il progetto solleva davvero finche'
/// `firebasevertexai.googleapis.com` resta spenta: ricalca `ServiceApiNotEnabled`
/// dell'SDK, che in prova non si puo' costruire senza Firebase.
class _ApiSpenta implements Exception {
  @override
  String toString() =>
      'The Vertex AI in Firebase SDK requires the Vertex AI in Firebase API '
      '(`firebasevertexai.googleapis.com`) to be enabled in your Firebase '
      'project.';
}

/// Una voce accesa che pero' fallisce a ogni chiamata, come oggi.
class _VoceInGuasto implements MaestroAiProvider {
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
      throw _ApiSpenta();

  @override
  Future<MaestroReply> consult({
    required Maestro maestro,
    required String theme,
    required UserProfile profile,
    MaestroMemory memory = MaestroMemory.empty,
    NatalContext? natal,
    ConsultDepth depth = ConsultDepth.breve,
  }) async =>
      throw _ApiSpenta();

  @override
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
  }) async =>
      throw _ApiSpenta();

  @override
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<ChatMessage> history,
  }) async =>
      throw _ApiSpenta();
}
