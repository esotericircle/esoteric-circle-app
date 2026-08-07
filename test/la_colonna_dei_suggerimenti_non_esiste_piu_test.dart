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

  testWidgets('a chat vuota resta il solo benvenuto, e la porta e\' una',
      (tester) async {
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

    // **LE ALTRE DUE PORTE SONO SPARITE, ordine 2164 voci 3 e 4.** Questa
    // prova pretendeva l'invito e l'assaggio, che erano la risposta della
    // voce 4 del 2163; Mauro li ha tolti (bolle inutili e ripetitive, e il
    // pulsante ripeteva le stelline). Non e' un allentamento: e' la stessa
    // prova sulla stessa regola, col numero di porte che passa da tre a una.
    expect(find.byKey(const Key('chat_invito_stelline')), findsNothing,
        reason: 'Il pulsante "Tocca per tutte le domande" e\' tornato.');
    expect(find.byKey(const Key('chat_assaggio')), findsNothing,
        reason: 'La riga di bolle orizzontali e\' tornata.');
    expect(find.byKey(const Key('chat_benvenuto')), findsOneWidget,
        reason: 'Il primo schermo resta col benvenuto del Maestro.');

    // E LA PORTA CHE RESTA E' UN GESTO VERO: si tocca e il pannello si
    // apre. Trovarla senza toccarla non proverebbe niente.
    await tester.tap(find.byKey(const Key('chat_stelline')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const Key('pannello_suggerimenti')), findsOneWidget,
        reason: 'Il tocco sulle stelline non apre il pannello: l\'unica '
            'porta rimasta non funziona.');
  });

  test('oltre il pannello, al massimo UNA porta mostra suggerimenti', () {
    // L'ENUMERAZIONE DELLE PORTE, sui sorgenti: il pannello
    // (pannello_suggerimenti) e' la porta piena; l'assaggio
    // (chat_assaggio) e' l'unica altra ammessa; le chiavi della colonna
    // (chat_famiglia_*) non devono esistere piu' in lib.
    var famiglie = 0;
    var assaggi = 0;
    var inviti = 0;
    var stelline = 0;
    var pannelli = 0;
    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final testo = f.readAsStringSync();
      famiglie += "Key('chat_famiglia_".allMatches(testo).length;
      assaggi += "Key('chat_assaggio')".allMatches(testo).length;
      inviti += "Key('chat_invito_stelline')".allMatches(testo).length;
      stelline += "Key('chat_stelline')".allMatches(testo).length;
      pannelli += "Key('pannello_suggerimenti')".allMatches(testo).length;
    }
    expect(famiglie, 0,
        reason: 'Le chiavi della colonna delle famiglie vivono ancora in '
            'lib: la seconda porta non e\' stata tolta.');
    expect(pannelli, 1,
        reason: 'Il pannello deve avere UNA definizione.');
    // ORDINE 2164 VOCI 3 E 4: LE PORTE PASSANO DA TRE A UNA. Erano il
    // pulsante d'invito, la riga d'assaggio e le stelline accanto al campo.
    // Adesso la porta e' una sola, e questa prova cade se qualcuno ne
    // riapre una seconda.
    expect(assaggi, 0,
        reason: 'La riga d\'assaggio vive ancora in lib: trovata $assaggi '
            'volte. La voce 3 chiedeva di toglierla, non di nasconderla.');
    expect(inviti, 0,
        reason: 'Il pulsante d\'invito vive ancora in lib: trovato $inviti '
            'volte. La voce 4 chiedeva di toglierlo.');
    expect(stelline, 1,
        reason: 'Le porte ai suggerimenti non sono piu\' UNA: le stelline '
            'compaiono $stelline volte in lib.');
  });
}
