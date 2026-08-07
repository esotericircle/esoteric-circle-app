import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LA RIGA DEL CAMPO E' PULITA, E LE PORTE AI SUGGERIMENTI SONO UNA SOLA.
///
/// Ordine 2164, voci 2, 3, 4 e 5.
/// - Voce 2: sotto e attorno alla riga con stelline, campo e freccia c'era
///   una fascia scura piena larga quanto lo schermo. Tolta: restano il campo
///   e il tondo di invio, opachi loro, appoggiati sul cosmo.
/// - Voci 3 e 4: via l'assaggio di tre domande in riga e via il pulsante
///   "Tocca per tutte le domande". Resta UNA porta, l'icona a stelline.
/// - Voce 5: icona e scritta si allineano al centro verticale del campo.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  /// Quanto puo' distare il centro dell'icona dal centro del campo. Due
  /// punti: e' il resto di un arrotondamento, non un allineamento diverso.
  const scartoMassimo = 2.0;

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

  Future<NavigatorState> chatDi(WidgetTester tester, Maestro maestro,
      GlobalKey radice) async {
    silenzia();
    SharedPreferences.setMockInitialValues({'onboarding.done': true});
    tester.view.physicalSize = const Size(360, 797);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final servizi = AppServices.offline();
    await tester.pumpWidget(RepaintBoundary(
      key: radice,
      child: EsotericCircleApp(conIntro: false, services: servizi),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).last);
    nav.push(MaestroChatScreen.route(maestro: maestro, services: servizi));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    return nav;
  }

  testWidgets('sotto il campo non esiste una fascia piena larga quanto lo '
      'schermo', (tester) async {
    final radice = GlobalKey();
    await chatDi(tester, Maestro.medora, radice);

    // LA MISURA E' A PIXEL, perche' i widget ci sono tutti anche quando la
    // fascia c'e': si guarda la RIGA di pixel che sta appena sotto il campo
    // e si conta quanto e' uniforme. Una fascia piena rende quella riga
    // tutta dello stesso colore da bordo a bordo; il cosmo no, perche' e'
    // una scena con stelle e sfumature.
    final campo = tester.getRect(find.byKey(const Key('chat_campo')));
    final byte = (await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 1.0);
      final dati = (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      img.dispose();
      return dati.buffer.asUint8List();
    }))!;
    final larghezza = tester.view.physicalSize.width.round();
    final y = (campo.bottom + 6).round();
    // Quanti pixel della riga sono IDENTICI al primo: con una fascia piena
    // sono quasi tutti, col cosmo dietro no.
    final i0 = (y * larghezza) * 4;
    var uguali = 0;
    for (var x = 0; x < larghezza; x++) {
      final i = (y * larghezza + x) * 4;
      if ((byte[i] - byte[i0]).abs() <= 2 &&
          (byte[i + 1] - byte[i0 + 1]).abs() <= 2 &&
          (byte[i + 2] - byte[i0 + 2]).abs() <= 2) {
        uguali++;
      }
    }
    final quota = uguali / larghezza;
    // ignore: avoid_print
    print('RIGA SOTTO IL CAMPO: pixel uguali al primo = $uguali su '
        '$larghezza (${(quota * 100).toStringAsFixed(1)} per cento)');
    // La soglia dichiarata: sopra il 92 per cento la riga e' una tinta
    // unita, cioe' una fascia. Col cosmo dietro la prova ha misurato molto
    // meno, e il rosso (fascia rimessa) ha misurato il 100 per cento.
    expect(quota, lessThan(0.92),
        reason: 'Sotto il campo c\'e\' di nuovo una fascia piena larga '
            'quanto lo schermo: ${(quota * 100).toStringAsFixed(1)} per '
            'cento della riga e\' della stessa tinta.');
  });

  testWidgets('le stelline sono allineate al centro del campo',
      (tester) async {
    final radice = GlobalKey();
    await chatDi(tester, Maestro.aura, radice);
    final campo = tester.getRect(find.byKey(const Key('chat_campo')));
    final stelline = tester.getRect(find.byKey(const Key('chat_stelline')));
    final scarto = (stelline.center.dy - campo.center.dy).abs();
    // ignore: avoid_print
    print('STELLINE: scarto fra il centro dell\'icona e quello del campo = '
        '${scarto.toStringAsFixed(1)} punti (massimo $scartoMassimo)');
    expect(scarto, lessThanOrEqualTo(scartoMassimo),
        reason: 'Le stelline stanno ${scarto.toStringAsFixed(1)} punti '
            'fuori dal centro del campo: la scritta Suggerimenti torna a '
            'sbordare su cio\' che sta sopra.');
    // E non escono in alto oltre il campo, che era il visto di Mauro.
    expect(stelline.top, greaterThanOrEqualTo(campo.top - scartoMassimo),
        reason: 'Le stelline salgono sopra il campo.');
  });

  testWidgets('sul primo schermo c\'e\' il solo benvenuto', (tester) async {
    final radice = GlobalKey();
    await chatDi(tester, Maestro.caligo, radice);
    expect(find.byKey(const Key('chat_benvenuto')), findsOneWidget);
    expect(find.byKey(const Key('chat_assaggio')), findsNothing,
        reason: 'La riga di bolle orizzontali e\' tornata: voce 3.');
    expect(find.byKey(const Key('chat_invito_stelline')), findsNothing,
        reason: 'Il pulsante "Tocca per tutte le domande" e\' tornato: '
            'voce 4.');
    expect(find.textContaining('Tocca per tutte le domande'), findsNothing);
  });

  test('resta UNA porta sola ai suggerimenti, e si contano nel sorgente',
      () {
    // LA PROVA ENUMERANTE, portata da tre porte a una (ordine 2164 voce 4).
    // Si contano nel SORGENTE perche' una porta puo' esistere anche dove
    // una schermata montata in prova non la costruisce.
    final composer = File('lib/features/maestri/chat/widgets/'
            'chat_composer.dart')
        .readAsStringSync();
    final vuota = File('lib/features/maestri/chat/widgets/'
            'chat_empty_state.dart')
        .readAsStringSync();
    final schermata =
        File('lib/features/maestri/chat/maestro_chat_screen.dart')
            .readAsStringSync();

    expect('chat_stelline'.allMatches(composer).length, 1,
        reason: 'La porta a stelline non e\' piu\' una sola nel composer.');
    for (final sparito in const [
      'chat_invito_stelline',
      'chat_assaggio',
      'chat_assaggio_voce',
      '_VoceDAssaggio',
    ]) {
      expect(vuota.contains(sparito), isFalse,
          reason: 'Il primo schermo ha di nuovo "$sparito": le voci 3 e 4 '
              'chiedevano di TOGLIERE, non di nascondere.');
    }
    // Nella schermata il pannello si apre da un punto solo.
    expect('showSuggestionsPanel('.allMatches(schermata).length, 1,
        reason: 'Il pannello dei suggerimenti si apre da piu\' di un punto '
            'nella schermata della chat.');
  });
}
