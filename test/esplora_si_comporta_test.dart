import 'dart:io';

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/features/maestri/ask/ask_maestri_screen.dart';
import 'package:esoteric_circle/features/maestri/chat/maestro_chat_screen.dart';
import 'package:esoteric_circle/features/maestri/domain_screen.dart';
import 'package:esoteric_circle/features/shell/esplora.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// COME SI COMPORTA ESPLORA, misurato sull'app montata.
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

  /// Monta l'app vera. `giaRisvegliato` falso significa primissima apertura.
  Future<NavigatorState> monta(WidgetTester tester,
      {bool giaRisvegliato = true}) async {
    silenzia();
    SharedPreferences.setMockInitialValues(
        giaRisvegliato ? {'onboarding.done': true} : {});
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    return tester.state<NavigatorState>(find.byType(Navigator).last);
  }

  /// Lo scorrimento VERTICALE della schermata. `find.byType(Scrollable).first`
  /// prendeva la striscia orizzontale dei Doni, e trascinarla in verticale non
  /// produce nessuna notifica: le due prove sullo scorrimento nascevano cieche.
  Finder ilCorpo() => find.byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down);

  Future<void> respira(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  bool linguettaVisibile() =>
      find.byKey(const Key('esplora_linguetta')).evaluate().isNotEmpty;
  bool esploraCE() =>
      linguettaVisibile() ||
      find.byKey(const Key('esplora_vie')).evaluate().isNotEmpty;

  /// APERTA VUOL DIRE VIE IN VISTA, e si misura in punti.
  ///
  /// Dal 6 agosto 2026 le vie non compaiono e non spariscono: rientrano dietro
  /// la linguetta con un movimento continuo, quindi sono sempre nell'albero e
  /// contarle non direbbe piu' niente. Aperta e' quando il blocco delle vie
  /// sta appoggiato sopra la linguetta invece che rientrato dietro di lei.
  bool apertaVisibile(WidgetTester tester) {
    final vie = find.byKey(const Key('esplora_vie'));
    if (vie.evaluate().isEmpty) return false;
    final striscia = find.byType(EsploraStriscia);
    final quantoEScesa = tester.getTopLeft(vie).dy -
        tester.getTopLeft(striscia).dy;
    return quantoEScesa < EsploraStriscia.corsa / 2;
  }

  testWidgets('dove il guscio ha gia\' la sua barra, Esplora non c\'e\'',
      (tester) async {
    await monta(tester);
    // NEL SANTUARIO NON CI VA, e non e' questione di gusto: Esplora e' un
    // Positioned sopra il contenuto, quindi intercettava i tocchi della
    // SantuarioBottomBar e la barra del guscio non rispondeva piu'. Undici
    // prove lo hanno preso il 6 agosto 2026, fra cui il tocco su Passport,
    // l'icona Maestro che non portava al dominio e le Impostazioni
    // irraggiungibili.
    expect(esploraCE(), isFalse,
        reason: 'Nel Santuario la barra del guscio c\'e\' gia\': Esplora la '
            'duplicherebbe, e stando sopra le ruberebbe i tocchi.');

    // E DOPO UN PUSH E UN POP DEVE RESTARE ASSENTE. E' qui che il difetto
    // viveva: la valutazione girava una volta per evento di navigazione,
    // dentro un post frame callback, quando la rotta USCENTE era ancora
    // montata. Tornando dal dominio trovava DomainScreen, decideva presente, e
    // nessun altro evento arrivava a correggerla.
    final nav = tester.state<NavigatorState>(find.byType(Navigator).last);
    nav.push(DomainScreen.route(
        maestro: Maestro.medora, services: AppServices.offline()));
    await respira(tester);
    nav.pop();
    await respira(tester);
    expect(esploraCE(), isFalse,
        reason: 'Tornati nel Santuario la striscia e\' rimasta accesa: la '
            'decisione ha guardato la rotta che stava uscendo invece di quella '
            'in cima alla pila.');
  });

  testWidgets('nelle chat c\'e\', in una immersiva non c\'e\' affatto',
      (tester) async {
    final nav = await monta(tester);

    // La chat e' una rotta spinta SOPRA il guscio, col proprio Scaffold: e' il
    // caso che ha generato Esplora, ed e' il piu' facile da perdere.
    nav.push(MaestroChatScreen.route(
        maestro: Maestro.medora, services: AppServices.offline()));
    await respira(tester);
    expect(esploraCE(), isTrue,
        reason: 'Nella chat la striscia deve esserci: e\' li\' che nasce il '
            'problema che Esplora risolve.');
    nav.pop();
    await respira(tester);

    // Un'immersiva: li' non c'e' nemmeno richiusa.
    nav.push(MaterialPageRoute<void>(
        builder: (_) => const _FintaImmersiva()));
    await respira(tester);
    expect(esploraCE(), isFalse,
        reason: 'In una schermata immersiva la striscia non deve esserci '
            'nemmeno a linguetta: l\'assenza e\' una scelta.');
  });

  /// Apre una chat, che e' una delle schermate dove Esplora c'e'. Il Santuario
  /// non serve piu' a queste prove: li' il guscio ha gia' la sua barra e
  /// Esplora non compare.
  Future<void> inChat(WidgetTester tester) async {
    final nav = await monta(tester);
    nav.push(MaestroChatScreen.route(
        maestro: Maestro.medora, services: AppServices.offline()));
    await respira(tester);
  }

  testWidgets('si chiude scorrendo giu\' e torna scorrendo su', (tester) async {
    await inChat(tester);
    // Si parte a linguetta: non e' la primissima apertura.
    expect(linguettaVisibile(), isTrue);

    final scorribile = ilCorpo().first;
    // Scorrere verso l'alto il contenuto, cioe' leggere: la striscia resta
    // ritratta.
    await tester.drag(scorribile, const Offset(0, -220));
    await respira(tester);
    expect(apertaVisibile(tester), isFalse,
        reason: 'Scorrendo per leggere la striscia non deve aprirsi.');

    // Scorrere verso il basso, cioe' tornare su: la striscia torna.
    await tester.drag(scorribile, const Offset(0, 220));
    await respira(tester);
    expect(apertaVisibile(tester), isTrue,
        reason: 'Scorrendo verso l\'alto la striscia deve tornare: e\' il '
            'gesto che tutti conoscono, e non va spiegato.');

    // E richiudersi di nuovo scorrendo per leggere.
    await tester.drag(scorribile, const Offset(0, -220));
    await respira(tester);
    expect(linguettaVisibile(), isTrue,
        reason: 'Scorrendo di nuovo per leggere deve tornare linguetta.');
  });

  testWidgets('nessun timer chiude la striscia', (tester) async {
    await inChat(tester);
    final scorribile = ilCorpo().first;
    await tester.drag(scorribile, const Offset(0, 220));
    await respira(tester);
    expect(apertaVisibile(tester), isTrue);

    // Trenta secondi di quiete. Se esistesse una chiusura a tempo, qui la
    // striscia sarebbe gia' scesa.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(seconds: 5));
    }
    expect(apertaVisibile(tester), isTrue,
        reason: 'La striscia si e\' chiusa da sola dopo trenta secondi di '
            'quiete. Una chiusura a tempo e\' la distrazione che si voleva '
            'togliere, e ha un difetto peggiore: se si abbassa mentre il dito '
            'ci sta andando, il tocco va a vuoto o colpisce cio\' che sta '
            'sotto.');
  });

  test('nel sorgente di Esplora non esiste nessuna chiusura a tempo', () {
    // La prova a video sopra dimostra il comportamento; questa toglie anche la
    // possibilita' che qualcuno reintroduca un timer con un ritardo piu' lungo
    // di quello che una prova puo' aspettare.
    final sorgente = File('lib/features/shell/esplora.dart').readAsStringSync();
    for (final vietato in const [
      'Timer(',
      'Timer.periodic',
      'Future.delayed',
    ]) {
      expect(sorgente.contains(vietato), isFalse,
          reason: 'In esplora.dart compare "$vietato". Esplora non si chiude '
              'da sola: si chiude col gesto, e solo col gesto.');
    }
  });

  testWidgets('la catena chat, Consiglio, chat non supera tre schermate',
      (tester) async {
    final nav = await monta(tester);
    final servizi = AppServices.offline();

    // 1. chat con Medora
    nav.push(MaestroChatScreen.route(maestro: Maestro.medora, services: servizi));
    await respira(tester);
    // 2. il Consiglio
    nav.push(AskMaestriScreen.perLaSintesi(
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
    ));
    await respira(tester);
    // 3. dal Consiglio si torna da Medora, la cui chat e' gia' aperta piu' in
    //    basso: ci si TORNA, non se ne apre una seconda.
    EsploraNavigazione.apriUnaVoltaSola(
      tipo: 'MaestroChatScreen',
      costruisci: () =>
          MaestroChatScreen.route(maestro: Maestro.medora, services: servizi),
    );
    await respira(tester);

    // SI CONTANO LE ROTTE, NON I WIDGET A VIDEO. `find.byType` salta di
    // default quello che sta fuori scena, e una chat sepolta sotto un'altra
    // rotta e' fuori scena: contandola cosi' la prova restava verde anche con
    // due chat nella pila, ed e' successo davvero il 6 agosto 2026, nascondendo
    // che l'osservatore non era nemmeno collegato.
    final chatVive = find
        .byType(MaestroChatScreen, skipOffstage: false)
        .evaluate()
        .length;
    expect(chatVive, lessThanOrEqualTo(1),
        reason: 'Ci sono $chatVive chat vive nella pila: tornare da un Maestro '
            'la cui chat e\' gia\' aperta piu\' in basso deve TORNARCI, non '
            'aprirne una seconda. Con questa sola regola la catena chat, '
            'Consiglio, chat non cresce oltre tre schermate.');
    expect(find.byType(AskMaestriScreen, skipOffstage: false).evaluate(),
        isEmpty,
        reason: 'Tornando alla chat, il Consiglio che stava sopra deve essere '
            'stato sfilato.');
  });

  testWidgets('le tre misure dichiarate sono quelle vere', (tester) async {
    // TRE COSTANTI CHE DESCRIVONO UNA RESA, quindi vanno confrontate con la
    // resa. `altezzaAperta` serve a `EsploraScope` per fare posto alla striscia
    // invece di coprirci sotto; `corsa` e' la lunghezza del movimento continuo,
    // e se fosse piu' corta della resa a fondo corsa le vie resterebbero a
    // sporgere da sotto la linguetta, se fosse piu' lunga scenderebbero oltre.
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => MaestroController()),
            ],
            child: const EsploraStriscia(
              ritiro: 0,
              onLinguetta: _niente,
              onChiudi: _niente,
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    final misure = <String, (double, double)>{
      'la striscia intera': (
        tester.getSize(find.byType(EsploraStriscia)).height,
        EsploraStriscia.altezzaAperta
      ),
      'la linguetta': (
        tester.getSize(find.byKey(const Key('esplora_linguetta'))).height,
        EsploraStriscia.altezzaLinguetta
      ),
      'la corsa, cioe\' il blocco delle vie': (
        tester.getSize(find.byKey(const Key('esplora_vie'))).height,
        EsploraStriscia.corsa
      ),
    };
    misure.forEach((cosa, m) {
      final (vera, dichiarata) = m;
      // Due punti di tolleranza: il bordo e l'arrotondamento del testo muovono
      // la resa di qualche decimo, non di piu'.
      expect((vera - dichiarata).abs(), lessThanOrEqualTo(2.0),
          reason: '$cosa misura ${vera.toStringAsFixed(2)} punti e ne dichiara '
              '$dichiarata.');
    });
  });

  testWidgets('si presenta aperta solo alla primissima apertura',
      (tester) async {
    // Si guarda in chat e non nel Santuario: nel Santuario il guscio ha gia' la
    // sua barra e Esplora non compare affatto.
    final nav = await monta(tester, giaRisvegliato: false);
    nav.push(MaestroChatScreen.route(
        maestro: Maestro.medora, services: AppServices.offline()));
    await respira(tester);
    expect(apertaVisibile(tester), isTrue,
        reason: 'Alla primissima apertura in assoluto la striscia si presenta '
            'aperta, per insegnare che esiste.');
  });

  testWidgets('a ogni ritorno successivo si presenta a linguetta',
      (tester) async {
    await inChat(tester);
    expect(apertaVisibile(tester), isFalse,
        reason: 'Aprirsi a ogni ritorno diventerebbe un tic.');
    expect(linguettaVisibile(), isTrue,
        reason: 'Ma la linguetta resta sempre: mai un vicolo cieco.');
  });
}

/// Una schermata dichiarata immersiva, montata per davvero.
///
/// Si chiama come una schermata vera dell'elenco perche' la decisione guarda il
/// TIPO del widget: qui interessa il comportamento dello scope, non la scena.
class _FintaImmersiva extends StatelessWidget {
  const _FintaImmersiva();

  @override
  Widget build(BuildContext context) => const MeditationScreen();
}

/// Il tipo dichiarato immersivo. Vive qui e non e' quello vero perche' la
/// Meditazione vera accende il lettore audio, che in prova non esiste: la
/// decisione di Esplora guarda il nome del tipo, e questo basta a provarla.
// ignore: camel_case_types
class MeditationScreen extends StatelessWidget {
  const MeditationScreen({super.key});

  @override
  Widget build(BuildContext context) => const Scaffold(
        body: Center(child: Text('meditazione')),
      );
}

/// Un callback che non fa niente, per le prove che misurano e non toccano.
void _niente() {}
