import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/responsi/anatomia_del_responso.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

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
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LA SCENA DI ATTESA NON COPRE NIENTE, E NON HA UN FONDO SUO.
///
/// Ordine 2164, voce 6. Visto da Mauro: il riquadro opaco della scena
/// (ordine 2163 voce 5) copriva la bolla della persona, dove si leggeva
/// "amore?" tagliato a meta'. Mauro rifiuta il riquadro: emblema e frasi si
/// compongono sopra il cosmo, senza sfondo, e il problema che il riquadro
/// risolveva si risolve in altro modo, cioe' la scena si riserva la sua
/// fascia in cima e la conversazione si ferma sotto di lei.
///
/// Due misure, tutte e due a pixel o sui rettangoli della resa vera, perche'
/// una prova che conta widget non vede una sovrapposizione: i widget ci sono
/// tutti anche quando si coprono.
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

  /// Una voce che tace finche' non la si libera: cosi' la scena di attesa
  /// resta a video e si puo' misurare.
  final attesa = _VoceLenta();

  Future<void> chatConScena(WidgetTester tester, GlobalKey radice) async {
    silenzia();
    SharedPreferences.setMockInitialValues({'onboarding.done': true});
    // **SCHERMO BASSO APPOSTA, e la grandezza e' cambiata per questo.** Su
    // 844 punti la conversazione di un solo scambio resta molto sotto la
    // fascia della scena, e il rosso NON scattava nemmeno rimettendo il
    // vecchio layout: non c'era niente da coprire. Il visto di Mauro
    // arrivava da una chat PIENA, dove la lista sale fin sotto l'emblema.
    // Con 520 punti due bolle bastano a riprodurre quella condizione.
    tester.view.physicalSize = const Size(390, 520);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final servizi = AppServices(
      ai: attesa,
      memory: InMemoryMaestroMemoryRepository(),
      memoryPersistent: false,
    );
    await tester.pumpWidget(RepaintBoundary(
      key: radice,
      child: EsotericCircleApp(conIntro: false, services: servizi),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).last);
    nav.push(
        MaestroChatScreen.route(maestro: Maestro.medora, services: servizi));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    // Una domanda vera: da qui la scena di attesa vive finche' la voce tace.
    await tester.enterText(
        find.byType(TextField).first, 'Cosa dicono le stelle sul mio amore?');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
  }

  testWidgets(
      'la conversazione si ferma sotto la scena, non ci passa '
      'dietro', (tester) async {
    final radice = GlobalKey();
    await chatConScena(tester, radice);

    final scena = find.byKey(const Key('riquadro_attesa'));
    expect(scena, findsOneWidget,
        reason: 'La scena di attesa non e\' a video: non c\'e\' niente da '
            'misurare.');

    // **SI MISURA IL RETTANGOLO DELLA CONVERSAZIONE, non quello di una
    // bolla, e la grandezza e' cambiata per una ragione.** La prima stesura
    // cercava la bolla della domanda: adesso che la conversazione perde
    // altezza per il tempo dell'attesa, quella bolla puo' finire FUORI
    // dalla finestra e la prova non trovava piu' niente da misurare, pur
    // essendo tutto a posto. Cio' che conta e' che la finestra della
    // conversazione si fermi sotto la scena: se i due rettangoli non si
    // toccano, nessun messaggio puo' finire dietro l'emblema.
    final lista = find.byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.up);
    expect(lista, findsWidgets, reason: 'La conversazione non e\' a video.');
    final rLista = tester.getRect(lista.first);
    final rScena = tester.getRect(scena);
    final sovrapposto = rScena.overlaps(rLista);
    // ignore: avoid_print
    print('SCENA: fascia ${rScena.top.toStringAsFixed(1)}-'
        '${rScena.bottom.toStringAsFixed(1)}, conversazione '
        '${rLista.top.toStringAsFixed(1)}-${rLista.bottom.toStringAsFixed(1)}'
        ', sovrapposti: $sovrapposto');
    expect(sovrapposto, isFalse,
        reason: 'La scena si stende SOPRA la conversazione: e\' il visto di '
            'Mauro, la bolla con "amore?" tagliata a meta\'.');
  });

  testWidgets(
      'dietro l\'emblema si vede il cosmo, cioe\' la scena non ha '
      'un fondo suo', (tester) async {
    final radice = GlobalKey();
    await chatConScena(tester, radice);
    final rScena = tester.getRect(find.byKey(const Key('riquadro_attesa')));

    // LA MISURA: dentro la fascia della scena, ai suoi bordi laterali dove
    // l'emblema non arriva, i pixel devono VARIARE come varia il cosmo. Un
    // fondo opaco renderebbe quella zona una tinta piatta.
    final byte = (await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 1.0);
      final dati = (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      img.dispose();
      return dati.buffer.asUint8List();
    }))!;
    final larghezza = tester.view.physicalSize.width.round();
    final colori = <int>{};
    for (var y = rScena.top.ceil() + 4; y < rScena.bottom.floor() - 4; y++) {
      for (var x = rScena.left.ceil() + 2; x < rScena.left.ceil() + 24; x++) {
        final i = (y * larghezza + x) * 4;
        colori.add((byte[i] << 16) | (byte[i + 1] << 8) | byte[i + 2]);
      }
    }
    // ignore: avoid_print
    print('SCENA: colori distinti nella colonna di sinistra della fascia = '
        '${colori.length}');
    // La soglia dichiarata: col cosmo dietro la colonna porta decine di
    // sfumature; col fondo opaco del riquadro ne portava pochissime, ed e'
    // cio' che il rosso ha misurato.
    expect(colori.length, greaterThan(12),
        reason: 'Dietro la scena ci sono solo ${colori.length} colori '
            'distinti: e\' un fondo opaco, non il cosmo.');
  });

  test('nel sorgente la scena non compone piu\' un fondo suo', () {
    // ORDINE 2164 VOCE 6, la regola dove vive: la scena non deve avere
    // decoration con gradiente ne' bordo. E' la prova che vede la DECISIONE
    // e non solo il suo effetto.
    final sorgente = File('lib/features/maestri/chat/maestro_chat_screen.dart')
        .readAsStringSync();
    final i = sorgente.indexOf("key: const Key('riquadro_attesa')");
    expect(i, greaterThan(0));
    final blocco = sorgente.substring(i, i + 700);
    expect(blocco.contains('decoration:'), isFalse,
        reason: 'La scena di attesa ha di nuovo una decorazione sua: Mauro '
            'la vuole senza sfondo (ordine 2164 voce 6).');
    expect(blocco.contains('Border.all'), isFalse,
        reason: 'La scena di attesa ha di nuovo un bordo.');
  });
}

/// La voce che non risponde mai: tiene viva la scena di attesa, che e'
/// esattamente cio' che questa prova deve misurare.
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
  }) {
    // UN'ATTESA SENZA TIMER: con un Future.delayed il test finiva con un
    // timer pendente e cadeva pur avendo gia' misurato bene. Una future che
    // non si compie non lascia niente in sospeso nel motore delle prove.
    return Completer<String>().future;
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
