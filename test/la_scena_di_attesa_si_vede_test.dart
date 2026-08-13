import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/maestro/consult_depth.dart';
import 'package:esoteric_circle/core/maestro/maestro_reply.dart';
import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/maestro/tempi_dell_attesa.dart';
import 'package:esoteric_circle/services/ai/maestro_ai_provider.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/design_system/components/consulto_del_cielo_view.dart';
import 'package:esoteric_circle/design_system/components/scena_sopra_la_conversazione.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LA SCENA DI ATTESA SI VEDE, PER IL TEMPO GARANTITO, IN TUTTE E TRE LE CHAT.
///
/// La regressione dell'ordine 2161: l'emblema e le frasi di riflessione erano
/// SPARITI da tutte le chat senza che una prova cadesse. Il codice c'era, la
/// scena era montata, il minimo garantito governava l'uscita: ma il layout
/// dava alla scena "quello che avanza", e con una conversazione che riempie
/// lo schermo non avanza NIENTE: la scena viveva alta zero pixel. Le prove
/// contavano widget su chat corte, dove lo spazio avanza sempre, e per
/// questo erano verdi per la ragione sbagliata.
///
/// Questa prova monta l'app DALL'AVVIO VERO, riempie la conversazione finche'
/// lo schermo e' pieno, e misura PER QUANTO TEMPO la scena resta a video con
/// un'altezza leggibile. Contare i widget non basta: il widget c'era anche
/// quando era invisibile.
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

  for (final maestro in Maestro.fixedOrder) {
    testWidgets(
        'nella chat di ${maestro.displayName} la scena dura almeno il minimo',
        (tester) async {
      silenzia();
      SharedPreferences.setMockInitialValues({
        'onboarding.done': true,
        // LA NASCITA C'E', ed e' la condizione vera del telefono: l'emblema
        // dell'attesa e' il simbolo della PERSONA, e senza nascita la scena
        // per Medora e Caligo dice il vero mostrando la sola riga.
        'profile.birthDate': '1990-08-15',
      });
      // UNO SCHERMO BASSO, apposta: la conversazione lo riempie con un solo
      // scambio, che e' la condizione vera del telefono con la storia. Su
      // uno schermo alto lo spazio avanza e il difetto non si vede.
      tester.view.physicalSize = const Size(1080, 2000);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);
      // UNA VOCE VERA E PRONTA, altrimenti il compositore resta spento e
      // nessun turno parte: offline aiReady e' falso.
      final servizi = AppServices(
        ai: const _VocePaziente(),
        memory: InMemoryMaestroMemoryRepository(),
        memoryPersistent: false,
      );
      await tester.pumpWidget(
          EsotericCircleApp(conIntro: false, services: servizi));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));
      final nav =
          tester.state<NavigatorState>(find.byType(Navigator).last);
      nav.push(MaestroChatScreen.route(maestro: maestro, services: servizi));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // PRIMO SCAMBIO: riempie la conversazione. Si porta a termine intero.
      await tester.enterText(find.byType(TextField).first, 'Chi sei tu?');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pump();
      for (var i = 0; i < 24; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }

      // SECONDO SCAMBIO: adesso lo schermo e' pieno, ed e' qui che la scena
      // spariva. Si campiona ogni 200 ms per la durata del minimo garantito
      // e si somma il tempo in cui la scena e' VISIBILE, cioe' alta almeno
      // quanto l'emblema, non solo presente nell'albero.
      await tester.enterText(
          find.byType(TextField).first, 'Continua il discorso di prima, ti ascolto.');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pump();

      const passo = Duration(milliseconds: 200);
      var visibileMs = 0;
      var vincoloConcesso = false;
      var emblemaVisto = false;
      final finestraMs =
          TempiDellAttesa.durataMinima.inMilliseconds + 800;
      for (var trascorso = 0;
          trascorso < finestraMs;
          trascorso += passo.inMilliseconds) {
        await tester.pump(passo);
        final scena = find.byType(ConsultoDelCieloView);
        if (scena.evaluate().isNotEmpty) {
          final altezza = tester.getSize(scena.first).height;
          // La riga di consultazione da sola e' alta 74: sotto i 60 la scena
          // non sta dicendo niente a nessuno.
          if (altezza >= 60) visibileMs += passo.inMilliseconds;
        }
        // IL VINCOLO CONCESSO: la scatola deve offrire alla scena viva
        // l'altezza del consulto INTERO. Senza questa pretesa la scena
        // tornerebbe alta zero sopra una conversazione piena, che e' la
        // regressione di quest'ordine.
        final scatole = find.byType(ScenaSopraLaConversazione);
        if (scatole.evaluate().isNotEmpty) {
          final scatola =
              tester.widget<ScenaSopraLaConversazione>(scatole.first);
          if (scatola.altezzaMinimaDellaScena >=
              ScenaSopraLaConversazione.altezzaDelConsulto) {
            vincoloConcesso = true;
          }
        }
        // L'EMBLEMA VERO. Nel montaggio di prova la carta natale non c'e',
        // quindi per Medora e Caligo il simbolo della persona manca e la
        // scena dice il vero con la sola riga: e' la regola del contenuto.
        // Il simbolo di AURA invece e' il loto, disegnato e non caricato,
        // quindi su Aura l'emblema si pretende visibile davvero.
        if (find.byKey(const Key('consulto_corpo')).evaluate().isNotEmpty) {
          emblemaVisto = true;
        }
      }
      // Si esaurisce l'attesa residua, cosi' il prossimo giro parte pulito.
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }

      final minimoMs = TempiDellAttesa.durataMinima.inMilliseconds;
      expect(vincoloConcesso, isTrue,
          reason: 'Nella chat di ${maestro.displayName} la scatola non ha '
              'mai concesso alla scena viva la misura del consulto intero: '
              'con una conversazione piena la scena torna alta zero, che '
              'sarebbe la regressione vista da Mauro.');
      if (maestro == Maestro.aura) {
        expect(emblemaVisto, isTrue,
            reason: 'Nella chat di Aura non si vede mai il suo emblema: il '
                'loto viene disegnato, non caricato, quindi qui non ci sono '
                'scuse di asset.');
      }
      expect(visibileMs, greaterThanOrEqualTo(minimoMs - 600),
          reason: 'Nella chat di ${maestro.displayName} la scena di attesa '
              'e\' stata VISIBILE per $visibileMs ms contro un minimo '
              'garantito di $minimoMs: o la scena e\' tornata alta zero '
              'sopra una conversazione piena, o il minimo non governa '
              'piu\' l\'uscita. Il widget che esiste nell\'albero non '
              'conta: conta cio' ' che la persona vede.');
    });
  }
}


/// Una voce pronta che risponde con calma: quanto basta perche' l'attesa
/// esista e la scena abbia qualcosa da accompagnare.
class _VocePaziente implements MaestroAiProvider {
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

  const _VocePaziente();

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
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return 'Il cielo osserva con te questa domanda e la tiene aperta. '
        'Guarda quel che torna due volte nello stesso giorno. '
        'Consiglio: annota stasera quel che il mattino ti ha detto.';
  }

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
