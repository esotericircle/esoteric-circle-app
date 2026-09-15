import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:esoteric_circle/features/maestri/ask/ask_maestri_screen.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/features/maestri/domain_screen.dart';
import 'package:esoteric_circle/features/passport/cosmic_passport_screen.dart';
import 'package:esoteric_circle/features/santuario/daily_strip.dart';
import 'package:esoteric_circle/features/shell/app_shell.dart';
import 'package:esoteric_circle/features/shell/barra_del_cerchio.dart';
import 'package:esoteric_circle/features/shell/santuario_bottom_bar.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// UNA BARRA SOLA IN TUTTA L'APP, misurata sull'app montata.
///
/// Decisione di Mauro del 6 agosto 2026: la barra e' quella storica del guscio,
/// porta il titolo ESPLORA, si vede in cinque schermate e segue il dito.
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

  Future<NavigatorState> monta(WidgetTester tester,
      {bool riduciMovimento = false}) async {
    silenzia();
    SharedPreferences.setMockInitialValues({
      'onboarding.done': true,
      if (riduciMovimento) 'settings.reduceAnimations': true,
    });
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

  int quanteBarre() =>
      find.byType(SantuarioBottomBar, skipOffstage: false).evaluate().length;

  Finder ilCorpo() => find.byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down);

  double doveStaLaBarra(WidgetTester tester) =>
      tester.getTopLeft(find.byType(SantuarioBottomBar)).dy;

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

  group('dove si vede, e quante ce ne sono', () {
    testWidgets('nella home ce n\'e\' UNA, non due', (tester) async {
      await monta(tester);
      expect(quanteBarre(), 1,
          reason: 'Nella home ci sono ${quanteBarre()} barre. Erano due, una '
              'dentro il guscio e una sopra il Navigator, ed e\' il difetto '
              'che lo spostamento chiude.');
      expect(find.byKey(const Key('barra_titolo')), findsOneWidget,
          reason: 'La barra deve portare il titolo.');
      expect(find.text(SantuarioBottomBar.titolo), findsOneWidget);
    });

    testWidgets('nel dominio, nella chat e nel Consiglio c\'e\', una sola',
        (tester) async {
      final nav = await monta(tester);
      final servizi = AppServices.offline();

      nav.push(DomainScreen.route(maestro: Maestro.medora, services: servizi));
      await respira(tester);
      expect(quanteBarre(), 1, reason: 'Nel dominio manca, oppure e\' doppia.');

      nav.push(
          MaestroChatScreen.route(maestro: Maestro.medora, services: servizi));
      await respira(tester);
      expect(quanteBarre(), 1, reason: 'Nella chat manca, oppure e\' doppia.');

      nav.push(versoIlConsiglio());
      await respira(tester);
      expect(quanteBarre(), 1,
          reason: 'Nel Consiglio dei Maestri manca, oppure e\' doppia.');
    });

    testWidgets('dove sei e\' acceso: nella chat di Medora, Medora',
        (tester) async {
      // Visto sull'anteprima: nella chat di Medora restava acceso Il Cerchio,
      // perche' la barra chiedeva al `MaestroController`, che la chat non
      // tocca. La chat dichiara il suo Maestro allo scope che si monta addosso,
      // ed e' li' che va chiesto.
      final nav = await monta(tester);
      nav.push(MaestroChatScreen.route(
          maestro: Maestro.medora, services: AppServices.offline()));
      await respira(tester);

      final barra =
          tester.widget<SantuarioBottomBar>(find.byType(SantuarioBottomBar));
      expect(barra.maestroCorrente, Maestro.medora,
          reason: 'Nella chat di Medora la barra accende '
              '${barra.maestroCorrente?.displayName ?? "Il Cerchio"}.');
    });

    testWidgets('nella home invece non e\' acceso nessun Maestro',
        (tester) async {
      await monta(tester);
      final barra =
          tester.widget<SantuarioBottomBar>(find.byType(SantuarioBottomBar));
      expect(barra.maestroCorrente, isNull,
          reason: 'Nel guscio "dove sei" lo dice gia\' la vista: le icone '
              'Maestro sono scorciatoie, non lo stato del centro.');
    });

    testWidgets('nel Passport c\'e\', e la sua voce e\' accesa',
        (tester) async {
      await monta(tester);
      await tester.tap(find.byKey(const Key('via_icona_passport')).first);
      await respira(tester);
      expect(find.byType(CosmicPassport, skipOffstage: false), findsOneWidget);
      expect(quanteBarre(), 1);
    });

    testWidgets('in un Dono del giorno non c\'e\' affatto', (tester) async {
      final nav = await monta(tester);
      nav.push(dailyElementRoute(DailyElement.oracle));
      await respira(tester);
      expect(quanteBarre(), 0,
          reason: 'Un Dono si compie con un gesto: una via d\'uscita sempre a '
              'vista lo interrompe.');
    });

    testWidgets('in una immersiva non c\'e\' affatto', (tester) async {
      final nav = await monta(tester);
      nav.push(
          MaterialPageRoute<void>(builder: (_) => const _FintaImmersiva()));
      await respira(tester);
      expect(quanteBarre(), 0);
    });

    testWidgets('tornando dal dominio la home ne ha ancora una sola',
        (tester) async {
      // E' qui che il difetto vecchio viveva: la decisione guardava la rotta
      // USCENTE, ancora montata, e nel Santuario restavano due barre.
      final nav = await monta(tester);
      nav.push(DomainScreen.route(
          maestro: Maestro.medora, services: AppServices.offline()));
      await respira(tester);
      nav.pop();
      await respira(tester);
      expect(quanteBarre(), 1);
    });
  });

  group('il movimento segue il dito', () {
    testWidgets('meta\' della corsa scorsa, meta\' della corsa scesa',
        (tester) async {
      await monta(tester);
      final gesto =
          await tester.startGesture(tester.getCenter(ilCorpo().first));
      // Il primo tratto serve a superare la soglia del trascinamento, che il
      // riconoscitore si mangia.
      await gesto.moveBy(const Offset(0, -kDragSlopDefault));
      await tester.pump();
      final partenza = doveStaLaBarra(tester);

      const mezzaCorsa = BarraDelCerchio.corsa / 2;
      await gesto.moveBy(const Offset(0, -mezzaCorsa));
      await tester.pump();
      final arrivo = doveStaLaBarra(tester);

      expect(arrivo - partenza, closeTo(mezzaCorsa, 1.0),
          reason: 'Il dito ha scorso $mezzaCorsa punti e la barra si e\' '
              'spostata di ${(arrivo - partenza).toStringAsFixed(1)}. Deve '
              'seguire il dito, non commutare fra due stati.');

      await gesto.moveBy(const Offset(0, mezzaCorsa));
      await tester.pump();
      expect(doveStaLaBarra(tester), closeTo(partenza, 1.0),
          reason: 'Tornando indietro col dito la barra deve risalire di '
              'altrettanto.');
      await gesto.up();
      await tester.pump();
    });

    testWidgets('oltre i due estremi si ferma', (tester) async {
      await monta(tester);
      final inVista = doveStaLaBarra(tester);
      final gesto =
          await tester.startGesture(tester.getCenter(ilCorpo().first));
      await gesto.moveBy(const Offset(0, -kDragSlopDefault));
      await gesto.moveBy(const Offset(0, -BarraDelCerchio.corsa * 4));
      await tester.pump();
      expect(doveStaLaBarra(tester) - inVista,
          closeTo(BarraDelCerchio.corsa, 1.0));
      await gesto.moveBy(const Offset(0, BarraDelCerchio.corsa * 8));
      await tester.pump();
      expect(doveStaLaBarra(tester), closeTo(inVista, 1.0));
      await gesto.up();
      await tester.pump();
    });

    testWidgets('con Riduci Movimento il cambio resta secco', (tester) async {
      await monta(tester, riduciMovimento: true);
      final inVista = doveStaLaBarra(tester);
      final gesto =
          await tester.startGesture(tester.getCenter(ilCorpo().first));
      await gesto.moveBy(const Offset(0, -kDragSlopDefault));
      // Un solo punto: col movimento continuo si sposterebbe di un punto, col
      // cambio secco e' gia' tutta scesa.
      await gesto.moveBy(const Offset(0, -1));
      await tester.pump();
      expect(doveStaLaBarra(tester) - inVista,
          closeTo(BarraDelCerchio.corsa, 1.0));
      await gesto.up();
      await tester.pump();
    });

    testWidgets('l\'altezza dichiarata e\' quella vera', (tester) async {
      // La misura serve a fare posto al contenuto: se scadesse, il contenuto
      // tornerebbe sotto la barra senza che niente lo dica.
      await monta(tester);
      final vera = tester.getSize(find.byType(SantuarioBottomBar)).height;
      expect((vera - BarraDelCerchio.altezza).abs(), lessThanOrEqualTo(2.0),
          reason: 'La barra misura ${vera.toStringAsFixed(1)} punti e ne '
              'dichiara ${BarraDelCerchio.altezza}.');
    });
  });

  group('le voci aprono davvero', () {
    Future<void> daUnaChat(WidgetTester tester) async {
      final nav = await monta(tester);
      nav.push(MaestroChatScreen.route(
          maestro: Maestro.medora, services: AppServices.offline()));
      await respira(tester);
    }

    testWidgets('dalla chat, Il Cerchio riporta al Cerchio', (tester) async {
      await daUnaChat(tester);
      await tester.tap(find.byKey(const Key('via_icona_cerchio')).first);
      await respira(tester);
      expect(find.byType(MaestroChatScreen, skipOffstage: false), findsNothing);
      expect(find.byType(AppShell, skipOffstage: false), findsOneWidget);
    });

    testWidgets('dalla chat, il Passport porta al Passport', (tester) async {
      await daUnaChat(tester);
      await tester.tap(find.byKey(const Key('via_icona_passport')).first);
      await respira(tester);
      expect(find.byType(CosmicPassport, skipOffstage: false), findsOneWidget);
    });

    testWidgets('lo stesso dominio non si impila due volte', (tester) async {
      // **LA REGOLA CONTRO IL DOPPIONE SERVE ANCORA, e adesso serve di piu'.**
      // Nata con Esplora, resta in `NavigazioneDellaBarra.apriUnaVoltaSola`:
      // la barra porta alle stesse cinque destinazioni da OGNI schermata,
      // quindi senza di lei bastano due tocchi per avere due domini dello
      // stesso Maestro impilati, e il tasto indietro ne chiederebbe due per
      // uscire da una sola stanza.
      //
      // Si contano le ROTTE e non i widget a video: `find.byType` salta di
      // default cio' che sta fuori scena, e un dominio sepolto sotto un altro
      // e' fuori scena.
      await daUnaChat(tester);
      await tester.tap(find.byKey(const Key('via_icona_medora')).first);
      await respira(tester);
      await tester.tap(find.byKey(const Key('via_icona_medora')).first);
      await respira(tester);
      final quanti =
          find.byType(DomainScreen, skipOffstage: false).evaluate().length;
      expect(quanti, 1,
          reason: 'Ci sono $quanti domini vivi nella pila: toccare due volte '
              'la stessa voce deve TORNARE dove si e\' gia\', non aprire una '
              'seconda stanza uguale.');
    });

    for (final maestro in Maestro.fixedOrder) {
      testWidgets('dal Consiglio, ${maestro.displayName} apre il suo dominio',
          (tester) async {
        final nav = await monta(tester);
        nav.push(versoIlConsiglio());
        await respira(tester);
        await tester.tap(find.byKey(Key('via_icona_${maestro.id}')).first);
        await respira(tester);
        expect(find.byType(DomainScreen, skipOffstage: false), findsOneWidget,
            reason: 'La voce di ${maestro.displayName} non ha aperto niente.');
      });
    }
  });
}

/// Una schermata dichiarata immersiva, montata per davvero.
class _FintaImmersiva extends StatelessWidget {
  const _FintaImmersiva();

  @override
  Widget build(BuildContext context) => const MeditationScreen();
}

/// Il tipo dichiarato immersivo. Vive qui e non e' quello vero perche' la
/// Meditazione vera accende il lettore audio, che in prova non esiste: la
/// decisione guarda il nome del tipo, e questo basta a provarla.
// ignore: camel_case_types
class MeditationScreen extends StatelessWidget {
  const MeditationScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('meditazione')),
      );
}
