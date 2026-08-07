import 'dart:io';

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LA COLONNA DEI SUGGERIMENTI NON ESISTE PIU': ERA UNA SECONDA PORTA.
///
/// Ordine 2163, voce 4. Visto: prima di aprire il pannello, i suggerimenti
/// erano una colonna lunghissima in mezzo alla schermata, che scorreva
/// dietro al campo e dietro alla barra, con ESPLORA stampata sopra un
/// suggerimento. Se esiste il pannello, quella colonna e' una seconda porta
/// per la stessa cosa: si toglie la porta, non la si corregge.
///
/// Al posto suo: il benvenuto del Maestro, l'invito a toccare le stelline,
/// e al massimo TRE voci d'assaggio in una riga orizzontale dentro i
/// margini.
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

  testWidgets('a chat vuota: benvenuto, invito alle stelline, assaggio in '
      'riga', (tester) async {
    silenzia();
    SharedPreferences.setMockInitialValues({
      'onboarding.done': true,
      'profile.birthDate': '1990-08-15',
    });
    tester.view.physicalSize = const Size(430, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final servizi = AppServices.offline();
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: servizi));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).last);
    nav.push(
        MaestroChatScreen.route(maestro: Maestro.medora, services: servizi));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // La colonna delle famiglie NON esiste piu' sul primo schermo.
    expect(find.byKey(const Key('chat_famiglia_frequenti')), findsNothing,
        reason: 'La colonna delle frequenti sta ancora sul primo schermo: '
            'e\' la seconda porta che la voce 4 ordina di togliere.');
    expect(find.byKey(const Key('chat_famiglia_personali')), findsNothing,
        reason: 'La colonna delle personali sta ancora sul primo schermo.');

    // L'invito alle stelline c'e' ED E' UN GESTO VERO: si tocca e il
    // pannello si apre. Trovarlo senza toccarlo non prova niente.
    expect(find.byKey(const Key('chat_invito_stelline')), findsOneWidget,
        reason: 'Manca l\'invito a toccare le stelline.');
    // Si scorre come farebbe il dito: col greeting lungo l'invito puo'
    // nascere dietro il vetro del blocco sospeso, e dietro il vetro non si
    // tocca. E' il contenuto che passa sotto, la regola della 2161.
    await tester.drag(find.byType(SingleChildScrollView).first,
        const Offset(0, -160), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const Key('chat_invito_stelline')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const Key('pannello_suggerimenti')), findsOneWidget,
        reason: 'Il tocco sull\'invito alle stelline non apre il pannello: '
            'l\'invito e\' una scritta, non un gesto.');
    await tester.tapAt(const Offset(10, 60));
    await tester.pump(const Duration(milliseconds: 400));

    // L'assaggio: al massimo tre voci, in UNA riga, dentro i margini.
    final assaggio = find.byKey(const Key('chat_assaggio'));
    if (assaggio.evaluate().isNotEmpty) {
      final chips = find.descendant(
          of: assaggio, matching: find.byKey(const Key('chat_assaggio_voce'),
              skipOffstage: false));
      final quanti = chips.evaluate().length;
      expect(quanti, lessThanOrEqualTo(3),
          reason: 'L\'assaggio porta $quanti voci: al massimo tre.');
      final rettangoli = [
        for (var i = 0; i < quanti; i++) tester.getRect(chips.at(i))
      ];
      final quote = rettangoli.map((r) => r.top).toSet();
      expect(quote.length, 1,
          reason: 'Le voci d\'assaggio non stanno su UNA riga: quote '
              '$quote. La colonna e\' tornata.');
      final schermo = tester.view.physicalSize.width;
      final rigaRect = tester.getRect(assaggio);
      expect(rigaRect.left, greaterThanOrEqualTo(0));
      expect(rigaRect.width, lessThanOrEqualTo(schermo + 0.1),
          reason: 'La riga d\'assaggio esce dai margini dello schermo.');
    }
  });

  test('oltre il pannello, al massimo UNA porta mostra suggerimenti', () {
    // L'ENUMERAZIONE DELLE PORTE, sui sorgenti: il pannello
    // (pannello_suggerimenti) e' la porta piena; l'assaggio
    // (chat_assaggio) e' l'unica altra ammessa; le chiavi della colonna
    // (chat_famiglia_*) non devono esistere piu' in lib.
    var famiglie = 0;
    var assaggi = 0;
    var pannelli = 0;
    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final testo = f.readAsStringSync();
      famiglie += "Key('chat_famiglia_".allMatches(testo).length;
      assaggi += "Key('chat_assaggio')".allMatches(testo).length;
      pannelli += "Key('pannello_suggerimenti')".allMatches(testo).length;
    }
    expect(famiglie, 0,
        reason: 'Le chiavi della colonna delle famiglie vivono ancora in '
            'lib: la seconda porta non e\' stata tolta.');
    expect(pannelli, 1,
        reason: 'Il pannello deve avere UNA definizione.');
    expect(assaggi, lessThanOrEqualTo(1),
        reason: 'L\'assaggio deve essere al massimo UNO oltre il pannello: '
            'trovati $assaggi.');
  });
}
