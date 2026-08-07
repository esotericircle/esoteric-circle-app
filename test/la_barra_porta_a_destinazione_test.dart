import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/features/maestri/ask/ask_maestri_screen.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/features/maestri/domain_screen.dart';
import 'package:esoteric_circle/features/passport/cosmic_passport_screen.dart';
import 'package:esoteric_circle/features/shell/app_shell.dart';
import 'package:esoteric_circle/features/shell/barra_del_cerchio.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LA BARRA PORTA A DESTINAZIONE, E IL COLORE NON MENTE.
///
/// Il difetto visto sul telefono il 7 agosto 2026: dal dominio di Medora,
/// toccando Caligo nella barra, il colore virava e il dominio restava quello
/// di Medora. Due cause, tutte e due in `NavigazioneDellaBarra`:
///
/// 1. il confronto contro il doppione guardava il NOME della classe,
///    `'DomainScreen'`, quindi tre stanze diverse risultavano una sola;
/// 2. `selectMaestro` correva PRIMA del confronto, quindi il colore cambiava
///    anche quando la rotta non cambiava.
///
/// Queste prove misurano le due cose insieme, perche' a video sono una cosa
/// sola: dopo ogni tocco sulla barra, la stanza a video e il Maestro del tema
/// devono raccontare la stessa storia.
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

  Future<NavigatorState> monta(WidgetTester tester) async {
    silenzia();
    SharedPreferences.setMockInitialValues({'onboarding.done': true});
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    return tester.state<NavigatorState>(find.byType(Navigator).last);
  }

  Future<void> respira(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  MaestroController controller(WidgetTester tester) =>
      tester.element(find.byType(AppShell, skipOffstage: false)).read();

  Route<void> versoIlConsiglio() => AskMaestriScreen.perLaSintesi(
        starter: Maestro.medora,
        tema: 'una scelta',
        lenti: [
          MaestroLens.strati(
              maestro: Maestro.aura,
              glance: 'respiro',
              reading: 'il corpo sa',
              invite: 'ascolta'),
          MaestroLens.strati(
              maestro: Maestro.caligo,
              glance: 'runa',
              reading: 'il segno parla',
              invite: 'traccia'),
        ],
      );

  /// Porta l'app su una delle cinque schermate di partenza.
  Future<void> parteDa(
      WidgetTester tester, NavigatorState nav, String partenza) async {
    switch (partenza) {
      case 'Santuario':
        break;
      case 'Passport':
        await tester.tap(find.byKey(const Key('via_icona_passport')).first);
        await respira(tester);
      case 'Dominio di Medora':
        nav.push(DomainScreen.route(
            maestro: Maestro.medora, services: AppServices.offline()));
        await respira(tester);
      case 'Chat di Medora':
        nav.push(MaestroChatScreen.route(
            maestro: Maestro.medora, services: AppServices.offline()));
        await respira(tester);
      case 'Consiglio':
        nav.push(versoIlConsiglio());
        await respira(tester);
    }
  }

  group('venticinque combinazioni: cinque partenze per cinque destinazioni',
      () {
    const partenze = [
      'Santuario',
      'Passport',
      'Dominio di Medora',
      'Chat di Medora',
      'Consiglio',
    ];

    for (final partenza in partenze) {
      testWidgets('da $partenza, ogni voce porta a destinazione al primo tocco',
          (tester) async {
        // Le cinque destinazioni si provano in sequenza sulla stessa app
        // montata, ripartendo ogni volta dalla schermata di partenza: e' il
        // gesto vero di una persona che gira per l'app, non cinque app
        // separate.
        for (final via in const [
          'medora',
          'caligo',
          'aura',
          'passport',
          'cerchio'
        ]) {
          await tester.pumpWidget(const SizedBox());
          final nav = await monta(tester);
          await parteDa(tester, nav, partenza);

          await tester.tap(find.byKey(Key('via_icona_$via')).first);
          await respira(tester);

          final attivo = controller(tester).activeMaestro;
          if (via == 'cerchio') {
            expect(find.byType(DomainScreen, skipOffstage: false), findsNothing,
                reason: 'Da $partenza, Il Cerchio ha lasciato rotte impilate.');
            expect(attivo, isNull,
                reason: 'Da $partenza, al Cerchio il tema non e\' neutro.');
          } else if (via == 'passport') {
            // IL PASSPORT AL PRIMO TOCCO: era il tocco che non faceva nulla.
            expect(find.byType(CosmicPassport), findsOneWidget,
                reason: 'Da $partenza, il Passport non si e\' aperto al primo '
                    'tocco.');
          } else {
            final maestro = Maestro.values.byName(via);
            final aVideo = tester
                .widget<DomainScreen>(find.byType(DomainScreen))
                .maestro;
            expect(aVideo, maestro,
                reason: 'Da $partenza, toccando ${maestro.displayName} la '
                    'stanza a video e\' quella di ${aVideo.displayName}: '
                    'destinazioni confuse, si e\' tornati su una stanza dello '
                    'stesso tipo invece di aprire quella giusta.');
            // IL COLORE NON MENTE: il Maestro del tema e' quello della stanza.
            expect(attivo, maestro,
                reason: 'Da $partenza, la stanza e\' di ${maestro.displayName} '
                    'ma il tema dice ${attivo?.displayName ?? 'neutro'}: il '
                    'colore dichiara un passaggio diverso da quello avvenuto.');
          }
        }
      });
    }
  });

  group('il difetto del telefono, tenuto fermo', () {
    testWidgets('dal dominio di Medora, Caligo apre Caligo e la pila cresce '
        'di uno', (tester) async {
      final nav = await monta(tester);
      nav.push(DomainScreen.route(
          maestro: Maestro.medora, services: AppServices.offline()));
      await respira(tester);
      final rottePrima = NavigazioneDellaBarra.osservatore!.pila.length;

      await tester.tap(find.byKey(const Key('via_icona_caligo')).first);
      await respira(tester);

      final aVideo =
          tester.widget<DomainScreen>(find.byType(DomainScreen)).maestro;
      expect(aVideo, Maestro.caligo,
          reason: 'La stanza a video e\' di ${aVideo.displayName}: il tocco '
              'su Caligo non ha aperto Caligo. Destinazioni confuse: '
              'DominioMedora e DominioCaligo trattate come la stessa.');
      final rotteDopo = NavigazioneDellaBarra.osservatore!.pila.length;
      expect(rotteDopo, rottePrima + 1,
          reason: 'La pila e\' passata da $rottePrima a $rotteDopo rotte: '
              'deve crescere di uno, la stanza nuova, non di due.');
      // E il colore dice Caligo, perche' la rotta dice Caligo.
      expect(controller(tester).activeMaestro, Maestro.caligo);
    });

    testWidgets('il colore non cambia se la rotta non cambia', (tester) async {
      // Il gesto: dal dominio di Caligo si ritocca Caligo. La rotta non ha
      // dove andare, quindi nemmeno il colore.
      //
      // **La sentinella vera di questa prova e' la coppia con la matrice
      // sopra:** nel codice storico, selectMaestro prima del confronto piu'
      // il confronto sul nome, il colore virava su Caligo mentre la stanza
      // restava di Medora, e a cadere e' l'asserzione della matrice che
      // confronta tema e stanza. Qui si tiene fermo il caso piu' semplice.
      final nav = await monta(tester);
      nav.push(DomainScreen.route(
          maestro: Maestro.caligo, services: AppServices.offline()));
      await respira(tester);
      controller(tester).selectMaestro(Maestro.caligo);
      await respira(tester);
      final rottePrima = NavigazioneDellaBarra.osservatore!.pila.length;

      await tester.tap(find.byKey(const Key('via_icona_caligo')).first);
      await respira(tester);

      expect(NavigazioneDellaBarra.osservatore!.pila.length, rottePrima,
          reason: 'Ritoccare la voce della stanza in cui si e\' gia\' ha '
              'mosso la pila.');
      expect(controller(tester).activeMaestro, Maestro.caligo,
          reason: 'Il colore e\' cambiato senza che la rotta cambiasse.');
    });

    testWidgets('tema e stanza concordano, qualunque cosa accada', (tester) async {
      // LA PROVA DEL COLORE, isolata. Non pretende una stanza precisa:
      // pretende che il tema dica la stanza che si vede, che e' la promessa
      // che il colore fa alla persona. Nel codice storico, selectMaestro
      // prima del confronto, il tema virava su Caligo mentre la stanza
      // restava di Medora, e questa prova cade proprio li'.
      final nav = await monta(tester);
      nav.push(DomainScreen.route(
          maestro: Maestro.medora, services: AppServices.offline()));
      await respira(tester);

      await tester.tap(find.byKey(const Key('via_icona_caligo')).first);
      await respira(tester);

      final stanza =
          tester.widget<DomainScreen>(find.byType(DomainScreen)).maestro;
      final tema = controller(tester).activeMaestro;
      expect(tema, stanza,
          reason: 'Il tema dice ${tema?.displayName ?? 'neutro'} ma la stanza '
              'a video e\' di ${stanza.displayName}: il colore e\' cambiato '
              'senza che la rotta lo seguisse.');
    });

    testWidgets('due tocchi sulla stessa voce non impilano due copie',
        (tester) async {
      final nav = await monta(tester);
      nav.push(MaestroChatScreen.route(
          maestro: Maestro.medora, services: AppServices.offline()));
      await respira(tester);
      await tester.tap(find.byKey(const Key('via_icona_aura')).first);
      await respira(tester);
      await tester.tap(find.byKey(const Key('via_icona_aura')).first);
      await respira(tester);
      final quanti = find
          .byWidgetPredicate((w) => w is DomainScreen && w.maestro == Maestro.aura,
              skipOffstage: false)
          .evaluate()
          .length;
      expect(quanti, 1,
          reason: 'Ci sono $quanti domini di Aura nella pila: toccare due '
              'volte la stessa voce deve tornare, non impilare.');
    });

    testWidgets('la destinazione la dichiara la fabbrica della rotta',
        (tester) async {
      // Se qualcuno toglie il RouteSettings da DomainScreen.route, la barra
      // smette di riconoscere le stanze aperte dalle altre porte, il
      // Santuario e il guscio, e il doppione torna da li'. Questa prova
      // guarda la rotta appena costruita, non la barra.
      final rotta = DomainScreen.route(
          maestro: Maestro.aura, services: AppServices.offline());
      expect(rotta.settings.arguments, isNotNull,
          reason: 'DomainScreen.route non dichiara piu\' la destinazione.');
      expect(rotta.settings.arguments.toString(), contains('aura'),
          reason: 'La destinazione dichiarata non nomina il suo Maestro.');
    });
  });
}
