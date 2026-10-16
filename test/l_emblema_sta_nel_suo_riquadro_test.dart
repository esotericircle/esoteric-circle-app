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

/// L'EMBLEMA DELL'ATTESA STA DENTRO IL SUO RIQUADRO, NON SOPRA LE BOLLE.
///
/// Ordine 2163, voce 5. Visto: la volpe da Caligo e i Gemelli da Medora
/// grandi mezzo schermo, SOPRA le bolle e sopra i ritratti, con la frase
/// dell'attesa caduta sopra i tre puntini. La scena vive in un riquadro
/// dichiarato (riquadro_attesa), opaco, con l'emblema dimensionato dentro e
/// la frase sotto: la conversazione ci sparisce dietro, mai attraverso.
///
/// Due misure:
/// - il corpo dell'emblema sta DENTRO il rettangolo del riquadro;
/// - la finestra della conversazione comincia dove il riquadro finisce:
///   nessuna bolla si legge attraverso la scena. Fino all'ordine EJ voce 09
///   questa seconda misura si faceva a pixel ed era cieca, la storia sta
///   accanto alla misura.
///
/// Il minimo garantito del 2161 non si tocca: la sua prova resta viva.
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

  testWidgets('nella chat di Aura la scena resta nel riquadro', (tester) async {
    silenzia();
    SharedPreferences.setMockInitialValues({
      'onboarding.done': true,
      'profile.birthDate': '1990-08-15',
    });
    // Schermo basso: la conversazione si riempie con un solo scambio, che
    // e' la condizione degli screenshot di Mauro.
    tester.view.physicalSize = const Size(430, 760);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final servizi = AppServices(
      ai: const _VoceLenta(),
      memory: InMemoryMaestroMemoryRepository(),
      memoryPersistent: false,
    );
    final radice = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: radice,
      child: EsotericCircleApp(conIntro: false, services: servizi),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).last);
    nav.push(MaestroChatScreen.route(maestro: Maestro.aura, services: servizi));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Primo scambio intero: riempie la conversazione.
    await tester.enterText(find.byType(TextField).first, 'Chi sei tu?');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();
    for (var i = 0; i < 24; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
    // Secondo invio: la scena si compone adesso.
    await tester.enterText(
        find.byType(TextField).first, 'Continua il discorso, ti ascolto.');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    final riquadro = tester.getRect(find.byKey(const Key('riquadro_attesa')));
    final corpo = tester.getRect(find.byKey(const Key('consulto_corpo')));
    expect(
        corpo.left >= riquadro.left - 1 &&
            corpo.right <= riquadro.right + 1 &&
            corpo.top >= riquadro.top - 1 &&
            corpo.bottom <= riquadro.bottom + 1,
        isTrue,
        reason: 'L\'emblema ($corpo) sborda dal riquadro ($riquadro): '
            'e\' di nuovo grande mezzo schermo sopra la conversazione.');

    // LA GRANDEZZA GIUSTA, e la storia delle sbagliate. La prima stesura
    // misurava la fascia SOTTO il riquadro durante la composizione, e il
    // rosso non scattava. La seconda misurava i pixel DENTRO il riquadro
    // trascinando la conversazione dietro: **era cieca**, e lo si e' scoperto
    // con l'ordine EJ voce 09, 25 settembre 2026. Il trascinamento non
    // muoveva la lista, da 0,0 a 0,0 punti, quindi "zero pixel cambiati" non
    // aveva guardato niente. Fatta muovere davvero, i pixel cambiati erano
    // 2.608, ed erano le stelle del fondo che scorrono con la lista, non
    // bolle: dall'ordine 2164 voce 6 il riquadro non e' piu' opaco, la scena
    // si riserva la sua fascia e la conversazione sta SOTTO. PROVENIENZA:
    // ordine 2164 voce 6, che ha tolto il riquadro opaco senza cambiare
    // questa misura.
    //
    // Si misura quindi cio' che quella voce garantisce: la finestra della
    // conversazione, che taglia ogni bolla al suo bordo, comincia dove il
    // riquadro della scena finisce. Nessuna bolla puo' leggersi attraverso.
    final finestra = tester.getRect(find.byType(Scrollable).first);
    // ignore: avoid_print
    print('RIQUADRO: la scena finisce a ${riquadro.bottom}, la conversazione '
        'comincia a ${finestra.top}');
    expect(finestra.top, greaterThanOrEqualTo(riquadro.bottom - 1),
        reason: 'La conversazione ($finestra) entra nel riquadro della scena '
            '($riquadro): le bolle si leggono ATTRAVERSO la scena, che e\' '
            'cio\' che Mauro ha visto.');

    // Si esaurisce l'attesa residua.
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
  });
}

/// Una voce pronta che risponde con calma, cosi' l'attesa esiste.
class _VoceLenta implements MaestroAiProvider {
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

  const _VoceLenta();

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
    UserProfile? profile,
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
