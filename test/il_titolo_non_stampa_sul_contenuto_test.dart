import 'dart:ui' as ui;

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/maestri/ask/ask_maestri_screen.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/features/maestri/domain_screen.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LA SCRITTA ESPLORA NON STAMPA PIU' SOPRA LE CARTE.
///
/// Ordine 2163, voce 7. Visto: il titolo copriva la carta "Chiedi anche
/// agli altri" e la riga di chiusura nel Consiglio. Il titolo e' una nota
/// di servizio e non copre contenuto: la fascia dietro di lui ha un fondo,
/// alto quanto il titolo VERO (misurato con TextPainter nel widget, non
/// indovinato).
///
/// La prova e' differenziale a pixel, come la voce 1: nel rettangolo del
/// titolo, allargato di due punti, i pixel non cambiano quando il
/// contenuto scorre dietro. Schermate enumerate: home, dominio, chat,
/// Consiglio (il Passport monta la stessa barra della home, stessa
/// superficie, e il suo scorrevole e' gia' coperto dalle altre).
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  const pixelDiversiMassimi = 30;

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

  testWidgets('nelle schermate enumerate il titolo ha il suo fondo',
      (tester) async {
    silenzia();
    SharedPreferences.setMockInitialValues({'onboarding.done': true});
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final servizi = AppServices.offline();
    final radice = GlobalKey();
    await tester.pumpWidget(RepaintBoundary(
      key: radice,
      child: EsotericCircleApp(conIntro: false, services: servizi),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).last);

    final colpe = <String>[];

    Future<void> misura(String dove) async {
      // A TEMPO FERMO: il drag sposta il contenuto, il pump a durata zero
      // ridisegna senza far avanzare le animazioni della schermata.
      final titolo =
          tester.getRect(find.byKey(const Key('barra_titolo')).first);
      final zona = titolo.inflate(2);
      final prima = await tester.runAsync(() => pixelDi(tester, radice));
      // SENZA DITO: un drag porterebbe il dito e la barra si ritirerebbe
      // seguendolo (regola della 2158), spostando il titolo stesso. Il
      // salto di posizione non ha dito: il contenuto si muove, la barra e
      // il titolo restano dove sono.
      final scorrevole = find.byWidgetPredicate(
          (w) => w is Scrollable && w.axisDirection == AxisDirection.down);
      final posizione = tester
          .state<ScrollableState>(scorrevole.first)
          .position;
      final da = posizione.pixels;
      posizione.jumpTo(
          (da + 70).clamp(0.0, posizione.maxScrollExtent));
      await tester.pump(Duration.zero);
      final dopo = await tester.runAsync(() => pixelDi(tester, radice));
      final larghezza = tester.view.physicalSize.width.round();
      var diversi = 0;
      for (var y = zona.top.ceil(); y < zona.bottom.floor(); y++) {
        for (var x = zona.left.ceil(); x < zona.right.floor(); x++) {
          final i = (y * larghezza + x) * 4;
          if ((prima![i] - dopo![i]).abs() > 3 ||
              (prima[i + 1] - dopo[i + 1]).abs() > 3 ||
              (prima[i + 2] - dopo[i + 2]).abs() > 3) {
            diversi++;
          }
        }
      }
      // ignore: avoid_print
      print('TITOLO $dove: pixel cambiati nel rettangolo = $diversi '
          '(massimo $pixelDiversiMassimi)');
      if (diversi > pixelDiversiMassimi) {
        colpe.add('$dove: $diversi pixel del contenuto attraversano il '
            'titolo');
      }
      // Il contenuto si riporta dov'era, per la schermata dopo.
      posizione.jumpTo(da);
      await tester.pump(Duration.zero);
    }

    await misura('home');

    nav.push(DomainScreen.route(maestro: Maestro.caligo, services: servizi));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    // Nel dominio si scende un poco: la scritta copriva le carte in fondo.
    await misura('dominio');

    nav.push(
        MaestroChatScreen.route(maestro: Maestro.medora, services: servizi));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await misura('chat');

    nav.push(AskMaestriScreen.perLaSintesi(
      starter: Maestro.caligo,
      tema: 'una scelta',
      lenti: [
        MaestroLens.strati(
            maestro: Maestro.medora,
            glance: 'stelle',
            reading: 'il cielo tiene aperta la domanda',
            invite: 'guarda'),
        MaestroLens.strati(
            maestro: Maestro.aura,
            glance: 'respiro',
            reading: 'il corpo conosce il suo passo',
            invite: 'ascolta'),
      ],
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await misura('consiglio');

    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });
}
