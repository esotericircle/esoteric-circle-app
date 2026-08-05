import 'dart:async';
import 'dart:io';

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/features/intro/sequenza_intro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

/// L'INTRO DI APERTURA: il video di Mauro, il tocco che lo salta, e quello che
/// l'intro deve rispettare mentre lo mostra.
///
/// **Perche' queste prove hanno una piattaforma finta.** In prova headless non
/// esiste niente che decodifichi un video: il lettore vero fallisce, e l'intro
/// per progetto va dritta alla destinazione invece di restare su una schermata
/// nera. Ottimo sul telefono, disastroso in prova: l'intro sparirebbe da sola
/// al primo istante, e una prova che chiede "il tocco la salta?" vedrebbe
/// verde anche col tocco scollegato, perche' l'intro era gia' andata via per
/// conto suo. La piattaforma finta qui sotto dichiara il video pronto, e da
/// quel momento le prove misurano il comportamento e non il fallimento.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _PiattaformaFinta piattaforma;

  setUp(() {
    piattaforma = _PiattaformaFinta();
    VideoPlayerPlatform.instance = piattaforma;
  });

  Widget conIntro({
    bool riduciMovimento = false,
    bool conSuono = true,
  }) =>
      MaterialApp(
        home: Builder(
          builder: (ctx) => MediaQuery(
            data:
                MediaQuery.of(ctx).copyWith(disableAnimations: riduciMovimento),
            child: SequenzaIntro(
              conSuono: conSuono,
              child: const Scaffold(
                body: Center(
                  child: Text('DESTINAZIONE', key: Key('destinazione')),
                ),
              ),
            ),
          ),
        ),
      );

  /// Il tempo che serve al lettore per dichiararsi pronto e cominciare.
  Future<void> finoAlVideo(WidgetTester tester) async {
    await tester.pump(); // il primo fotogramma fa partire la sequenza
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 10));
    }
  }

  group('Il video che si apre e quello nuovo', () {
    test('La costante indica il convertito, e il convertito esiste davvero',
        () {
      expect(SequenzaIntro.video, 'brand_assets/intro/Intro-Test-3.mp4');

      // NON BASTA CHE LA COSTANTE SIA GIUSTA: un percorso puo' puntare a un
      // file che non c'e', e l'app si aprirebbe sul nero. Si guarda il disco.
      final file = File(SequenzaIntro.video);
      expect(file.existsSync(), isTrue,
          reason: 'il video dichiarato non sta sul disco: ${file.path}');

      // E PESA COME UN VIDEO CONVERTITO, non come un grezzo. Il sorgente era
      // 22.416.587 byte: se un giorno qualcuno copiasse qui il grezzo senza
      // convertirlo, il pacchetto crescerebbe di sedici megabyte in silenzio.
      final peso = file.lengthSync();
      expect(peso, greaterThan(1000000),
          reason: 'il file e troppo leggero per essere quel video: $peso byte');
      expect(peso, lessThan(10000000),
          reason: 'il video pesa $peso byte: sembra il grezzo, non il '
              'convertito');
    });

    test('Nella cartella dell intro c e UN video solo', () {
      // La cartella brand_assets/intro/ entra INTERA nel pacchetto: un file
      // dimenticato li' dentro pesa anche se nessuno lo apre piu'. E' gia'
      // successo due volte, col primo video e col secondo, ogni volta che
      // Mauro ne ha mandato uno nuovo.
      //
      // LA REGOLA E' IL NUMERO, non il nome: qui non si scrive quale file ci
      // debba essere, si scrive che ce n'e' uno. Chiedere il nome vorrebbe
      // dire ricavare l'atteso dalla costante che si sta sorvegliando, e il
      // nome e' gia' fissato dalla prova qui sopra.
      final dentro = Directory('brand_assets/intro')
          .listSync()
          .whereType<File>()
          .map((f) => f.uri.pathSegments.last)
          .toList();
      expect(dentro.length, 1,
          reason: 'nella cartella dell intro ci sono $dentro: quelli che non '
              'si aprono piu pesano lo stesso, e sono la porta sbagliata da '
              'cui qualcuno un giorno ripartira');
    });

    test('Il grezzo non entra nel repository', () {
      // La cartella di lavoro col sorgente sta accanto al progetto, e
      // .gitignore deve escluderla. Il nome ha uno spazio dentro, quindi
      // nessuna regola generica la prendeva.
      final regole = File('.gitignore').readAsStringSync();
      expect(regole.contains('intro video/'), isTrue,
          reason: 'il grezzo dell intro non e escluso: un git add -A lo '
              'porterebbe dentro con i suoi ventidue megabyte');
    });
  });

  group('Dell intro costruita in codice non resta niente', () {
    testWidgets('Ne frase, ne logo a schermo', (tester) async {
      await tester.pumpWidget(conIntro());
      await finoAlVideo(tester);

      expect(find.byKey(const Key('intro_frase')), findsNothing,
          reason: 'la frase la dice il video: scritta anche dal codice, si '
              'vedrebbe due volte');
      expect(find.byKey(const Key('intro_logo_immagine')), findsNothing,
          reason: 'il logo lo mostra il video in chiusura: mostrato anche dal '
              'codice, si vedrebbe due volte');
      // E il video invece c'e'.
      expect(find.byType(VideoPlayer), findsOneWidget,
          reason: 'il video non e a schermo');
    });

    test('Ne voce, ne suoni suonati dal codice', () {
      // TRASVERSALE, sul FATTO e non sul nome: si legge il sorgente e si
      // controlla che l'intro non chiami piu' il motore audio ne il catalogo
      // dei suoni. Rinominare un file non la fa uscire da questa prova.
      final sorgente =
          File('lib/features/intro/sequenza_intro.dart').readAsStringSync();
      for (final vietato in const [
        'MotoreAudio',
        'SuonoDelCerchio',
        'catalogo_suoni',
        'motore_audio',
      ]) {
        expect(sorgente.contains(vietato), isFalse,
            reason: 'l intro suona ancora qualcosa per conto suo ($vietato): '
                'la voce sta dentro il video, e due voci sovrapposte sono '
                'rumore');
      }
    });
  });

  group('Cio che il video non puo fare da solo', () {
    testWidgets('Un tocco salta e consegna la destinazione', (tester) async {
      await tester.pumpWidget(conIntro());
      await finoAlVideo(tester);

      // L'INTRO C'E' DAVVERO PRIMA DEL TOCCO. Senza questa riga la prova
      // passerebbe anche se l'intro non fosse mai comparsa.
      expect(find.byKey(const Key('intro_salta')), findsOneWidget);
      expect(piattaforma.inRiproduzione, isTrue,
          reason: 'il video non sta suonando: la prova che segue non misura '
              'il salto, misura un intro gia finita da sola');

      await tester.tap(find.byKey(const Key('intro_salta')));
      await tester.pump();
      expect(piattaforma.inRiproduzione, isFalse,
          reason: 'il tocco non ferma il video, che continuerebbe a suonare '
              'sotto la schermata gia aperta');

      // La dissolvenza, e poi lo smontaggio.
      await tester.pump(SequenzaIntro.dissolvenza);
      await tester.pump();
      expect(find.byKey(const Key('intro_salta')), findsNothing,
          reason: 'il tocco non salta l intro');
      expect(find.byKey(const Key('destinazione')), findsOneWidget);
    });

    testWidgets('L uscita e una dissolvenza, non un taglio secco',
        (tester) async {
      await tester.pumpWidget(conIntro());
      await finoAlVideo(tester);
      await tester.tap(find.byKey(const Key('intro_salta')));
      await tester.pump();

      // A META' DELLA DISSOLVENZA l'intro deve essere ancora montata e
      // parzialmente trasparente. Se sparisse di colpo, qui non ci sarebbe
      // piu' niente da misurare, e sullo schermo si vedrebbe uno stacco.
      await tester.pump(SequenzaIntro.dissolvenza ~/ 2);
      final velo = tester.widget<AnimatedOpacity>(
          find.ancestor(
                  of: find.byKey(const Key('intro_salta')),
                  matching: find.byType(AnimatedOpacity))
              .first);
      expect(velo.opacity, 0.0,
          reason: 'l intro non sta sfumando: sparisce di colpo');
      final opacita = tester
          .widget<FadeTransition>(find
              .descendant(
                  of: find.byType(AnimatedOpacity), matching: find.byType(FadeTransition))
              .first)
          .opacity
          .value;
      expect(opacita, greaterThan(0.0),
          reason: 'a meta dissolvenza l intro e gia del tutto trasparente');
      expect(opacita, lessThan(1.0),
          reason: 'a meta dissolvenza l intro e ancora del tutto opaca');
    });

    testWidgets('Riduci Movimento non mostra l intro affatto', (tester) async {
      await tester.pumpWidget(conIntro(riduciMovimento: true));
      await finoAlVideo(tester);

      expect(piattaforma.inRiproduzione, isFalse,
          reason: 'con Riduci Movimento il video parte lo stesso: quattordici '
              'secondi di cosmo a tutto schermo sono esattamente il movimento '
              'che quell impostazione chiede di togliere');
      await tester.pump(SequenzaIntro.dissolvenza);
      await tester.pump();
      expect(find.byKey(const Key('intro_salta')), findsNothing);
      expect(find.byKey(const Key('destinazione')), findsOneWidget);
    });

    testWidgets('Il silenzio dell app arriva al video prima che suoni',
        (tester) async {
      await tester.pumpWidget(conIntro(conSuono: false));
      await finoAlVideo(tester);

      // IL MUTO ERA GIA' IN VIGORE QUANDO IL VIDEO HA COMINCIATO. Chiedere
      // soltanto "il volume finale e zero" lascerebbe passare un muto messo un
      // istante dopo l'avvio, e quell'istante si sente.
      expect(piattaforma.volumeAlPrimoPlay, 0.0,
          reason: 'a suono spento l apertura parla lo stesso, almeno per il '
              'primo istante');
      expect(piattaforma.volumeApplicato, 0.0,
          reason: 'a suono spento l apertura parla lo stesso');
    });

    testWidgets('A suono acceso il video si sente', (tester) async {
      await tester.pumpWidget(conIntro());
      await finoAlVideo(tester);
      expect(piattaforma.volumeAlPrimoPlay, 1.0,
          reason: 'a suono acceso l apertura resta muta');
    });

    testWidgets('L app che va via e torna non trova l apertura ad aspettarla',
        (tester) async {
      await tester.pumpWidget(conIntro());
      await finoAlVideo(tester);
      expect(find.byKey(const Key('intro_salta')), findsOneWidget);

      // Una telefonata, il centro di controllo, o l'app messa via.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(piattaforma.inRiproduzione, isFalse,
          reason: 'il video continua a suonare con l app in secondo piano');
      expect(piattaforma.volumeApplicato, 0.0,
          reason: 'l apertura che se ne va non e stata messa in muto: il '
              'lettore ha un osservatore suo che al ritorno fa ripartire da '
              'solo cio che aveva fermato, e si sentirebbe sotto la schermata');

      // MENTRE L'APP STA DIETRO IL SISTEMA NON DISEGNA, quindi la dissolvenza
      // non scorre e non deve: qui non si misura niente. Cio' che conta si
      // vede AL RITORNO, che e' anche il momento in cui la persona guarda.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      await tester.pump(SequenzaIntro.dissolvenza);
      await tester.pump();
      expect(find.byKey(const Key('intro_salta')), findsNothing,
          reason: 'tornando nell app si trova un fotogramma congelato, '
              'un apertura gia vista e ferma');
      expect(find.byKey(const Key('destinazione')), findsOneWidget);
      expect(piattaforma.volumeApplicato, 0.0,
          reason: 'al ritorno l apertura torna a farsi sentire');
    });

    testWidgets('Il video che non parte non blocca l apertura',
        (tester) async {
      // La via d'errore, che sul telefono e' il caso del file corrotto o del
      // decodificatore che manca: si va alla destinazione, non si resta sul
      // nero. E' anche il caso di ogni prova che non installa la finta.
      piattaforma.fallisce = true;
      await tester.pumpWidget(conIntro());
      await finoAlVideo(tester);
      await tester.pump(SequenzaIntro.dissolvenza);
      await tester.pump();
      expect(find.byKey(const Key('destinazione')), findsOneWidget);
      expect(find.byKey(const Key('intro_salta')), findsNothing);
    });

    testWidgets('Senza intro si va dritti alla destinazione', (tester) async {
      // E' il caso delle prove e delle anteprime, e prova che la destinazione
      // sotto e' la stessa in tutti e due i casi: l'intro ritarda, non devia.
      await tester.pumpWidget(const MaterialApp(
        home: SequenzaIntro(
          mostra: false,
          child: Scaffold(
            body: Center(child: Text('DESTINAZIONE', key: Key('destinazione'))),
          ),
        ),
      ));
      await tester.pump();
      expect(find.byKey(const Key('destinazione')), findsOneWidget);
      expect(find.byKey(const Key('intro_salta')), findsNothing);
      expect(piattaforma.inRiproduzione, isFalse,
          reason: 'senza intro il video parte lo stesso');
    });
  });

  group('Dove l intro sta montata', () {
    testWidgets('Sta SOPRA il Navigator, non dentro la route iniziale',
        (tester) async {
      // IL DIFETTO CHE QUESTA PROVA TIENE CHIUSO, segnalato sulla 2123: si
      // sentiva la voce e si vedeva il Risveglio. L'intro stava dentro `home`,
      // cioe' dentro la ROUTE INIZIALE, e il Risveglio non e' un ramo
      // dell'albero, e' un `push`: una route spinta SOPRA copre chi sta sotto.
      // L'intro era viva e sepolta.
      //
      // La prova e' STRUTTURALE e non a tempo: chiede se SequenzaIntro sia
      // antenata del Navigator. Prima chiedeva se dopo 1,2 secondi la frase si
      // leggesse ancora, e una prova a tempo si rompe ogni volta che i tempi
      // cambiano, anche quando la struttura e' giusta.
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(const EsotericCircleApp());
      // Il tempo che serve all'app per finire di decidersi: senza, le sue
      // attese restano appese e la prova finisce con dei timer in volo.
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      final intro = find.byType(SequenzaIntro);
      expect(intro, findsOneWidget, reason: 'l intro non e montata affatto');
      expect(
          find.descendant(of: intro, matching: find.byType(Navigator)),
          findsWidgets,
          reason: 'il Navigator non sta sotto l intro: qualunque route spinta '
              'sopra coprirebbe l apertura, che resterebbe viva e sepolta');
    });

    test('Il silenzio dell app viene passato all intro dal punto di montaggio',
        () {
      // Il dato sta in un posto solo, l'interruttore unico di Impostazioni, e
      // l'intro lo riceve da chi la monta. Se qualcuno stacca questo filo, il
      // video torna a suonare a suono spento e nessuna prova a schermo se ne
      // accorgerebbe, perche' il difetto e' nel collegamento e non nell intro.
      final montaggio = File('lib/app.dart').readAsStringSync();
      expect(montaggio.contains('conSuono: settings.suonoEVibrazione'), isTrue,
          reason: 'il punto di montaggio non passa piu il silenzio dell app '
              'all intro');
    });
  });
}

/// La piattaforma video finta: dichiara il video pronto e registra cosa le e'
/// stato chiesto, cosi' le prove misurano il comportamento invece del
/// fallimento.
class _PiattaformaFinta extends VideoPlayerPlatform {
  final StreamController<VideoEvent> _eventi =
      StreamController<VideoEvent>.broadcast();

  /// Vero per simulare il file che non si apre.
  bool fallisce = false;

  bool inRiproduzione = false;
  double? volumeApplicato;

  /// IL VOLUME IN VIGORE NELL'ISTANTE IN CUI IL VIDEO COMINCIA.
  ///
  /// Non "il volume e' stato deciso prima di suonare", che sembrava la stessa
  /// domanda e non lo era: il lettore applica un volume suo appena si
  /// inizializza, quindi un volume "prima del play" c'e' sempre, anche quando
  /// l'intro non ne ha chiesto nessuno. Cieca. La domanda vera e' quale volume
  /// fosse in vigore quando il primo fotogramma ha cominciato a suonare.
  double? volumeAlPrimoPlay;

  Duration posizione = Duration.zero;

  @override
  Future<void> init() async {}

  @override
  Future<void> dispose(int playerId) async {}

  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async {
    if (fallisce) throw PlatformExceptionFinta();
    // L'evento arriva su un timer e non su una microtask, perche' chi crea il
    // lettore si mette in ascolto DOPO: su un flusso broadcast un evento
    // emesso troppo presto non lo sente nessuno.
    Timer(Duration.zero, () {
      _eventi.add(VideoEvent(
        eventType: VideoEventType.initialized,
        duration: const Duration(seconds: 14),
        size: const Size(1080, 1920),
      ));
    });
    return 1;
  }

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) => _eventi.stream;

  @override
  Future<void> setPreventsDisplaySleepDuringVideoPlayback(
      int playerId, bool value) async {}

  @override
  Future<void> setLooping(int playerId, bool looping) async {}

  @override
  Future<void> setVolume(int playerId, double volume) async =>
      volumeApplicato = volume;

  @override
  Future<void> play(int playerId) async {
    volumeAlPrimoPlay ??= volumeApplicato;
    inRiproduzione = true;
  }

  @override
  Future<void> pause(int playerId) async => inRiproduzione = false;

  @override
  Future<void> seekTo(int playerId, Duration position) async =>
      posizione = position;

  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {}

  @override
  Future<Duration> getPosition(int playerId) async => posizione;

  @override
  Widget buildView(int playerId) =>
      const SizedBox.shrink(key: Key('video_finto'));

  @override
  Widget buildViewWithOptions(VideoViewOptions options) =>
      const SizedBox.shrink(key: Key('video_finto'));
}

/// Un errore qualunque, per la via del video che non si apre.
class PlatformExceptionFinta implements Exception {}
