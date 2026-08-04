import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/archetypes/archetype_history.dart';
import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/features/maestri/chat/widgets/chat_composer.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LE ANTEPRIME DELL'ORDINE E, a 360 per 797 punti logici, rapporto 3.
///
/// Cinque immagini in `docs/preview/ordine_e/`: la pausa nelle tre chat, per
/// far vedere che le frasi sono diverse; una risposta a meta' scrittura; la
/// stessa appena arrivata, dove si deve vedere che quello che si legge e'
/// l'INIZIO.
///
/// **Il limite, dichiarato.** In prova non esiste un `FirebaseAI`, quindi il
/// testo lo mette una voce finta. Non e' inventato: e' copiato parola per
/// parola da una risposta vera misurata il 3 agosto 2026 con
/// `flutter test tool/risposte_intere.dart`.
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

  // Una nascita vera, cosi' la pausa nomina un DATO SUO invece di una frase
  // generica: e' il punto 1b dell'ordine, e in anteprima si deve vedere.
  final nascita = BirthDetails(
    date: DateTime(1975, 7, 6),
    time: const TimeOfDay(hour: 9, minute: 30),
    place: const BirthPlace(
      latitude: 41.9,
      longitude: 12.5,
      timezone: 'Europe/Rome',
      label: 'Roma',
    ),
  );

  const risposta =
      'Un velo sottile di Luna nuova sembra avvolgerti, Sofia. La tua Luna in '
      'Pesci si lega alla tua natura di Cancro, portandoti a sentire ogni cosa '
      'due volte. Il timore di sbagliare è una risonanza del tuo numero, che '
      'ti spinge alla comprensione profonda.\n\n'
      'Il tuo Ascendente in Vergine chiede ordine a ciò che la Luna muove '
      'senza chiedere permesso. Non è un difetto da correggere: è il modo in '
      'cui il tuo cielo ti fa guardare le cose.\n\n'
      'Il ciclo lunare si chiuderà fra sette giorni, e allora la stessa '
      'domanda avrà una risposta diversa.';

  Future<void> conLaChat(
    WidgetTester tester,
    Maestro maestro,
    Future<void> Function(WidgetTester tester, GlobalKey radice) cosaFare,
  ) async {
    silenzia();
    SharedPreferences.setMockInitialValues({});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2392);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final memoria = InMemoryMaestroMemoryRepository();
    await memoria
        .saveProfile(UserProfile(disclaimerAcceptedAt: DateTime(2026, 7, 1)));
    final servizi = AppServices(
      ai: _VoceConUnTesto(risposta),
      memory: memoria,
      memoryPersistent: false,
      diagnostics: 'anteprime ordine E',
    );

    final radice = GlobalKey();
    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<AppServices>.value(value: servizi),
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ArchetypeHistory()),
        ChangeNotifierProvider(create: (_) => QuestionAllowance()),
        // Piano del Cerchio: le altre voci sono del Cerchio, e col Viandante
        // l'anteprima fotograferebbe l'invito a salire invece delle voci. Il
        // gating e' giusto, ed e' l'altra strada che qui va mostrata.
        ChangeNotifierProvider(
            create: (_) => EntitlementService(initial: Tier.tier1)),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(
            create: (_) => BirthIdentityController()
              ..setBirth(nascita, null)),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: RepaintBoundary(
          key: radice,
          child: Navigator(
            onGenerateRoute: (_) => MaestroChatScreen.route(
              maestro: maestro,
              services: servizi,
            ),
          ),
        ),
      ),
    ));
    await cosaFare(tester, radice);
  }

  Future<void> scatta(
      WidgetTester tester, GlobalKey radice, String nome) async {
    await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 3.0);
      final dati = await img.toByteData(format: ui.ImageByteFormat.png);
      // LA STESSA REGOLA DEL CORREDO: si scrive in docs/ solo a comando.
      //
      // Senza questa riga ogni `flutter test` riscriveva le cinque immagini e
      // sporcava l'albero di lavoro, cosa che il corredo non fa da sempre. Le
      // catture restano fuori dal corredo per il rapporto di pixel, ma questa
      // regola non c'entra col rapporto: e' buon vicinato.
      final dir = Directory(
          Platform.environment['AGGIORNA_ANTEPRIME'] == '1'
              ? 'docs/preview/ordine_e'
              : 'build/preview/ordine_e');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File('${dir.path}/$nome.png').writeAsBytesSync(dati!.buffer.asUint8List());
      img.dispose();
    });
  }

  Future<void> chiedi(WidgetTester tester) async {
    final campo = find.descendant(
      of: find.byType(ChatComposer),
      matching: find.byType(TextField),
    );
    expect(campo, findsOneWidget);
    await tester.enterText(campo, 'ho paura di sbagliare');
    await tester.pump();
    await tester.testTextInput.receiveAction(TextInputAction.send);
  }

  // LA PAUSA, nelle tre chat: le frasi sono diverse perche' sono del Maestro.
  for (final maestro in Maestro.values) {
    testWidgets('Anteprima: la pausa di ${maestro.id}', (tester) async {
      await conLaChat(tester, maestro, (tester, radice) async {
        for (var i = 0; i < 12; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        await chiedi(tester);
        // Dentro la pausa, dopo la prima riga ancorata e sulla seconda, che e'
        // la frase del Maestro: e' li' che le tre si distinguono.
        for (var i = 0; i < 12; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        await scatta(tester, radice, 'pausa_${maestro.id}');
        // Si lascia finire il turno: lo scatto e' dentro la pausa, e chiudere
        // li' lascerebbe vivi i timer della scena.
        for (var i = 0; i < 200; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
      });
    });
  }

  testWidgets('Anteprima: la risposta a meta\' scrittura', (tester) async {
    await conLaChat(tester, Maestro.medora, (tester, radice) async {
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await chiedi(tester);
      // La pausa, la dissolvenza, poi meta' della scrittura.
      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await scatta(tester, radice, 'meta_scrittura');
    });
  });


  // LE DUE ANTEPRIME DELL'ORDINE F, nella stessa impalcatura: la chat e' la
  // stessa, e una seconda copia dell'impalcatura sarebbe una seconda porta.
  testWidgets('Anteprima: le altre voci nella stessa conversazione',
      (tester) async {
    await conLaChat(tester, Maestro.medora, (tester, radice) async {
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await chiedi(tester);
      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      // La riga sta in fondo alla risposta viva: la si raggiunge scorrendo,
      // come farebbe la persona dopo aver letto.
      await tester.dragUntilVisible(
        find.byKey(const Key('chat_altre_voci')),
        find.byType(ListView).first,
        const Offset(0, -120),
      );
      await tester.pump();
      await scatta(tester, radice, 'altre_voci_riga');

      await tester.tap(find.byKey(const Key('chat_altre_voci')));
      // Due voci, due pause.
      for (var i = 0; i < 120; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await scatta(tester, radice, 'altre_voci_arrivate');
    });
  });

  testWidgets('Anteprima: la risposta appena arrivata, si legge l\'INIZIO',
      (tester) async {
    await conLaChat(tester, Maestro.medora, (tester, radice) async {
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await chiedi(tester);
      for (var i = 0; i < 200; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await scatta(tester, radice, 'inizio_della_risposta');
    });
  });
}

/// Una voce che consegna un testo dato, per fotografarlo. Il testo e' copiato
/// da una risposta vera misurata, non inventato.
class _VoceConUnTesto implements MaestroAiProvider {
  _VoceConUnTesto(this.testo);

  final String testo;

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
      testo;

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
