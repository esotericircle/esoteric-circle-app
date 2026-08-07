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

/// IL CAMPO DI SCRITTURA E' OPACO: IL CONTENUTO CI SPARISCE SOTTO.
///
/// Ordine 2163, voce 1, visto in sei screenshot su tredici: il testo delle
/// bolle si leggeva ATTRAVERSO il riquadro "Scrivi a..." e attraverso il
/// tondo di invio.
///
/// La prova e' DIFFERENZIALE, perche' e' l'unica onesta per l'opacita': si
/// rende la stessa schermata con la conversazione in due posizioni di
/// scorrimento diverse, e i pixel DENTRO il campo e dentro il tondo devono
/// essere identici nelle due rese. Se il fondo lascia passare quello che c'e'
/// dietro, i pixel cambiano insieme al contenuto, e il conto li denuncia.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  /// Piu' di questo numero di pixel diversi dentro il campo vuol dire che il
  /// contenuto traspare. Un margine piccolo resta per l'antialias del bordo.
  const pixelDiversiMassimi = 150;

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

  Future<Uint8List> pixelDi(WidgetTester tester, GlobalKey radice) async {
    final rb =
        radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final img = await rb.toImage(pixelRatio: 1.0);
    final dati = (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    final byte = dati.buffer.asUint8List();
    img.dispose();
    return byte;
  }

  int diversiDentro(Rect r, Uint8List a, Uint8List b, int larghezza) {
    var diversi = 0;
    for (var y = r.top.ceil(); y < r.bottom.floor(); y++) {
      for (var x = r.left.ceil(); x < r.right.floor(); x++) {
        final i = (y * larghezza + x) * 4;
        if ((a[i] - b[i]).abs() > 3 ||
            (a[i + 1] - b[i + 1]).abs() > 3 ||
            (a[i + 2] - b[i + 2]).abs() > 3) {
          diversi++;
        }
      }
    }
    return diversi;
  }

  testWidgets('campo e tondo di invio non lasciano trasparire le bolle',
      (tester) async {
    silenzia();
    SharedPreferences.setMockInitialValues({'onboarding.done': true});
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final servizi = AppServices(
      ai: const _VoceLunga(),
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
    nav.push(
        MaestroChatScreen.route(maestro: Maestro.caligo, services: servizi));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Uno scambio con una risposta LUNGA: e' lei che deve passare dietro al
    // campo senza farsi vedere.
    await tester.enterText(find.byType(TextField).first, 'Chi sei tu?');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump();
    for (var i = 0; i < 24; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }

    final campo = tester.getRect(find.byKey(const Key('chat_campo')));
    final tondo = tester.getRect(find.byKey(const Key('chat_invio')));

    // Prima resa, poi si sposta la conversazione di sessanta punti e si
    // rende di nuovo: dietro il campo adesso passano righe diverse.
    final prima = await tester.runAsync(() => pixelDi(tester, radice));
    await tester.drag(find.byType(ListView).first, const Offset(0, 60),
        warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 400));
    final dopo = await tester.runAsync(() => pixelDi(tester, radice));

    final larghezza = tester.view.physicalSize.width.round();
    final nelCampo = diversiDentro(campo.deflate(2), prima!, dopo!, larghezza);
    final nelTondo = diversiDentro(tondo.deflate(2), prima, dopo, larghezza);
    // ignore: avoid_print
    print('OPACITA: pixel diversi nel campo $nelCampo, nel tondo $nelTondo '
        '(massimo $pixelDiversiMassimi)');
    expect(nelCampo, lessThanOrEqualTo(pixelDiversiMassimi),
        reason: 'Dentro il campo di scrittura $nelCampo pixel cambiano '
            'quando la conversazione scorre dietro: il contenuto traspare, '
            'che e\' il difetto visto in sei screenshot su tredici.');
    expect(nelTondo, lessThanOrEqualTo(pixelDiversiMassimi),
        reason: 'Dentro il tondo di invio $nelTondo pixel cambiano quando '
            'la conversazione scorre dietro: il tondo traspare.');
  });
}

/// Una voce pronta che risponde con un testo LUNGO, cosi' le righe passano
/// dietro al campo di scrittura.
class _VoceLunga implements MaestroAiProvider {
  const _VoceLunga();

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
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List.filled(
            14,
            'Il cielo tiene aperta la tua domanda e la osserva con te, '
            'riga dopo riga, senza fretta.')
        .join(' ');
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
