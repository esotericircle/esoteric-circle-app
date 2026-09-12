import 'dart:async';
import 'dart:math' as math;

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/rivelazione_in_video.dart';
import 'package:esoteric_circle/features/onboarding/maestro_reveal_screen.dart';
import 'package:esoteric_circle/features/onboarding/widgets/maestro_card.dart';
import 'package:esoteric_circle/features/onboarding/widgets/velo_di_rivelazione.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

import 'attorno_alla_rivelazione.dart';

/// IL VIDEO DELLA RIVELAZIONE E' LO SFONDO DELLA SCHERMATA. Ordine BR.
///
/// **Parole del fondatore, che sono la premessa di tutto l'ordine:** "il video
/// di rivelazione dei maestri e' stato inserito dentro la carta, la carta che
/// solitamente sta dietro al maestro, mentre il video eravamo d'accordo che
/// sarebbe stata full screen come sfondo e inoltre il video si dovrebbe fermare
/// all'ultimo frame in modo che resti come immagine fissa". E poi: "il video va
/// sotto come sfondo e sopra ci metti i testi, info ecc. ma tienili come sono
/// adesso in basso cosi' copre solo la parte bassa del video, quindi dalla vita
/// in giu' di ogni maestro".
///
/// **L'ordine BQ aveva fatto esattamente cio' che gli era stato chiesto, e cio'
/// che gli era stato chiesto era sbagliato.** Queste prove non correggono un
/// errore di BQ: misurano la specifica nuova.
void main() {
  late BancoDeiLettori banco;

  setUp(() => banco = BancoDeiLettori());

  Widget scena(Maestro maestro, {bool riduciMovimento = false}) =>
      attornoAllaRivelazione(
        MaestroRevealScreen(
          maestro: maestro,
          onRevealed: (_) {},
          fabbricaDelVideo: banco.crea,
        ),
        riduciMovimento: riduciMovimento,
      );

  /// Quanti Maestri sono a video in questo istante: quello della carta e quello
  /// del filmato contano uno per uno. **Deve fare sempre uno.** Zero vuol dire
  /// scena vuota, due vuol dire un Maestro sopra l'altro.
  int maestriAVideo() {
    final carta = find.byType(MaestroCardReveal).evaluate().length;
    final filmato = find
        .descendant(
            of: find.byType(VeloDiRivelazione),
            matching: find.byType(ColoredBox))
        .evaluate()
        .length;
    return carta + filmato;
  }

  group(
      'BR.00, la ricognizione: cosa fa video_player quando il filmato finisce',
      () {
    testWidgets(
        'Alla fine il lettore non si chiude e la sua vista resta in albero',
        (tester) async {
      // **QUESTA MISURA REGGE L'INTERA VOCE BR.02 e per questo non si stima.**
      // Se alla fine della riproduzione il lettore venisse liberato, o la sua
      // vista sparisse dall'albero, il "fermo sull'ultimo fotogramma" sarebbe
      // un rettangolo nero sul telefono e la voce andava fermata.
      //
      // **Cosa questa prova NON puo' dire.** Se la superficie nativa conservi i
      // pixel dell'ultimo quadro e' cosa del decodificatore, non di Flutter, e
      // in una prova headless non c'e' nessun decodificatore da interrogare.
      // Per questo la voce BR.02 non ci scommette sopra: sotto al filmato il
      // velo tiene SEMPRE il ritratto del Maestro, quindi il caso peggiore non
      // e' il nero, e' il ritratto.
      final piattaforma = _PiattaformaFinta();
      VideoPlayerPlatform.instance = piattaforma;
      final lettore = VeloDiRivelazione.lettoreVero(
          RivelazioneInVideo.assetDi(Maestro.medora));
      unawaited(lettore.apri());
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(lettore.pronto, isTrue, reason: 'il filmato non e\' partito');
      expect(lettore.finito, isFalse);

      await tester.pumpWidget(Directionality(
          textDirection: TextDirection.ltr, child: lettore.disegna()));
      expect(find.byKey(const Key('video_finto')), findsOneWidget,
          reason: 'la vista della piattaforma non e\' in albero nemmeno '
              'mentre il filmato suona');
      final visteMentreSuona = List<int>.from(piattaforma.viste);

      piattaforma.finisci();
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(lettore.finito, isTrue,
          reason: 'il filmato e\' arrivato in fondo e nessuno se n\'e\' '
              'accorto');
      expect(piattaforma.chiusi, 0,
          reason: 'il lettore e\' stato liberato alla fine della '
              'riproduzione: li\' la texture si svuota e resta un rettangolo '
              'nero. Con questo numero diverso da zero la voce BR.02 si ferma');

      await tester.pumpWidget(Directionality(
          textDirection: TextDirection.ltr, child: lettore.disegna()));
      expect(find.byKey(const Key('video_finto')), findsOneWidget,
          reason: 'dopo la fine la vista della piattaforma non e\' piu\' in '
              'albero');
      // ignore: avoid_print
      print('ORDINE BR VOCE 0: mentre suona viste $visteMentreSuona, dopo la '
          'fine viste ${piattaforma.viste}, lettori liberati '
          '${piattaforma.chiusi}, posizione ${piattaforma.posizione}');
      expect(piattaforma.viste.toSet(), hasLength(1),
          reason:
              'dopo la fine la vista porta un numero diverso: e\' un\'altra '
              'texture, quindi l\'ultimo fotogramma non e\' quello di prima');
      lettore.chiudi();
    });
  });

  group('BR.01, il video e\' lo sfondo della schermata', () {
    testWidgets(
        'Il velo prende le misure dello schermo, non quelle della carta',
        (tester) async {
      pinnaLoSchermo(tester);
      await tester.pumpWidget(scena(Maestro.medora));
      await svelaIlMaestro(tester);
      final misura = tester.getSize(find.byType(VeloDiRivelazione));
      // ignore: avoid_print
      print('ORDINE BR VOCE 1: il velo misura '
          '${misura.width.toStringAsFixed(0)} per '
          '${misura.height.toStringAsFixed(0)}, lo schermo '
          '${schermoDiRiferimento.width.toStringAsFixed(0)} per '
          '${schermoDiRiferimento.height.toStringAsFixed(0)}');
      expect(misura.width, schermoDiRiferimento.width,
          reason: 'il velo e\' largo ${misura.width} invece di '
              '${schermoDiRiferimento.width}: non e\' lo sfondo della '
              'schermata, e\' l\'inquilino di qualcosa di piu\' stretto');
      expect(misura.height, schermoDiRiferimento.height,
          reason: 'il velo e\' alto ${misura.height} invece di '
              '${schermoDiRiferimento.height}');
    });

    testWidgets('Il piede e\' in albero e si disegna DOPO il velo',
        (tester) async {
      // **L'ORDINE SI VERIFICA SULL'ALBERO VERO, non a occhio e non sui
      // parametri di un widget.** Gli elementi si visitano in ordine di figlio:
      // chi viene prima nell'elenco viene prima nella visita, e sullo schermo
      // sta sotto.
      pinnaLoSchermo(tester);
      await tester.pumpWidget(scena(Maestro.aura));
      await svelaIlMaestro(tester);
      expect(find.byKey(const Key('reveal_footer')), findsOneWidget,
          reason: 'il piede coi pulsanti non e\' in albero: senza di lui non '
              'si entra nel Cerchio');
      final tutti = collectAllElementsFrom(
              tester.element(find.byType(MaestroRevealScreen)),
              skipOffstage: false)
          .toList();
      final doveIlVelo = tutti.indexWhere((e) => e.widget is VeloDiRivelazione);
      final doveIlPiede =
          tutti.indexWhere((e) => e.widget.key == const Key('reveal_footer'));
      // ignore: avoid_print
      print('ORDINE BR VOCE 1: il velo e\' il figlio numero $doveIlVelo, il '
          'piede il numero $doveIlPiede');
      expect(doveIlVelo, greaterThanOrEqualTo(0));
      expect(doveIlPiede, greaterThan(doveIlVelo),
          reason: 'il piede si disegna PRIMA del velo: il filmato gli finisce '
              'sopra e i pulsanti spariscono sotto al Maestro');
    });

    testWidgets('Il piede copre solo la parte bassa del filmato',
        (tester) async {
      // Parole del fondatore: "tienili come sono adesso in basso cosi' copre
      // solo la parte bassa del video, quindi dalla vita in giu' di ogni
      // maestro". Trentotto per cento e' il tetto che l'ordine fissa.
      pinnaLoSchermo(tester);
      await tester.pumpWidget(scena(Maestro.caligo));
      await svelaIlMaestro(tester);
      final piede = tester.getSize(find.byKey(const Key('reveal_footer')));
      final quota = piede.height / schermoDiRiferimento.height;
      // ignore: avoid_print
      print('ORDINE BR VOCE 1: il piede e\' alto '
          '${piede.height.toStringAsFixed(1)} punti su '
          '${schermoDiRiferimento.height.toStringAsFixed(0)}, cioe\' il '
          '${(quota * 100).toStringAsFixed(1)} per cento della schermata');
      expect(quota, lessThanOrEqualTo(0.38),
          reason: 'il piede si prende il ${(quota * 100).toStringAsFixed(1)} '
              'per cento dell\'altezza: non copre piu\' solo la parte bassa '
              'del filmato');
    });

    testWidgets('Quando il filmato copre, la carta con la cornice non c\'e\'',
        (tester) async {
      pinnaLoSchermo(tester);
      await tester.pumpWidget(scena(Maestro.medora));
      await svelaIlMaestro(tester);
      expect(find.byType(MaestroCardReveal), findsNothing,
          reason: 'la carta e\' rimasta in scena sotto al filmato: sono due '
              'Maestri, uno sopra l\'altro');
      expect(
          find.descendant(
              of: find.byType(VeloDiRivelazione),
              matching: find.byType(ColoredBox)),
          findsOneWidget,
          reason: 'il filmato non sta disegnando niente');
    });

    testWidgets(
        'In nessun fotogramma ci sono due Maestri, ne un fotogramma senza',
        (tester) async {
      // **IL PASSAGGIO SI MISURA A FOTOGRAMMI, non prima e dopo.** La carta se
      // ne va e il filmato appare nello stesso giro di costruzione: se il
      // segnale arrivasse un fotogramma dopo, si vedrebbe la cornice sopra il
      // filmato, e se arrivasse un fotogramma prima si vedrebbe il cosmo.
      pinnaLoSchermo(tester);
      await tester.pumpWidget(scena(Maestro.aura));
      await tester.drag(
          find.byType(MaestroRevealScreen), const Offset(0, 1200));
      final conteggi = <int>[];
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        conteggi.add(maestriAVideo());
      }
      // ignore: avoid_print
      print('ORDINE BR VOCE 1: Maestri a video, fotogramma per fotogramma '
          '$conteggi');
      for (var i = 0; i < conteggi.length; i++) {
        expect(conteggi[i], 1,
            reason: 'al fotogramma $i ci sono ${conteggi[i]} Maestri a video '
                'invece di uno');
      }
    });

    testWidgets('Il filmato riempie e si fa tagliare, non lascia due bande',
        (tester) async {
      // **cover E NON contain.** Un filmato 9 a 16 dentro uno schermo piu' alto
      // con `contain` lascerebbe una banda sopra e una sotto: si vedrebbe il
      // cosmo intorno al Maestro invece di uno sfondo pieno.
      final piattaforma = _PiattaformaFinta();
      VideoPlayerPlatform.instance = piattaforma;
      pinnaLoSchermo(tester);
      final lettore = VeloDiRivelazione.lettoreVero(
          RivelazioneInVideo.assetDi(Maestro.aura));
      unawaited(lettore.apri());
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 16));
      }
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: SizedBox(
            width: schermoDiRiferimento.width,
            height: schermoDiRiferimento.height,
            child: lettore.disegna(),
          ),
        ),
      ));
      final riquadro = tester.widget<FittedBox>(find.byType(FittedBox));
      expect(riquadro.fit, BoxFit.cover,
          reason: 'il filmato non riempie: con ${riquadro.fit} restano bande');
      final dentro = tester.widget<SizedBox>(find
          .descendant(
              of: find.byType(FittedBox), matching: find.byType(SizedBox))
          .first);
      final scala = math.max(schermoDiRiferimento.width / dentro.width!,
          schermoDiRiferimento.height / dentro.height!);
      final disegnato = Size(dentro.width! * scala, dentro.height! * scala);
      final conContain = math.min(schermoDiRiferimento.width / dentro.width!,
          schermoDiRiferimento.height / dentro.height!);
      final bande =
          (schermoDiRiferimento.height - dentro.height! * conContain) / 2;
      // ignore: avoid_print
      print(
          'ORDINE BR VOCE 1: il filmato e\' ${dentro.width!.toStringAsFixed(0)}'
          ' per ${dentro.height!.toStringAsFixed(0)}, disegnato a '
          '${disegnato.width.toStringAsFixed(1)} per '
          '${disegnato.height.toStringAsFixed(1)} su uno schermo '
          '${schermoDiRiferimento.width.toStringAsFixed(0)} per '
          '${schermoDiRiferimento.height.toStringAsFixed(0)}. Con contain '
          'avrebbe lasciato due bande da ${bande.toStringAsFixed(1)} punti');
      expect(disegnato.width, greaterThanOrEqualTo(schermoDiRiferimento.width),
          reason: 'il filmato non arriva ai bordi in larghezza');
      expect(
          disegnato.height, greaterThanOrEqualTo(schermoDiRiferimento.height),
          reason: 'il filmato non arriva ai bordi in altezza');
      lettore.chiudi();
    });

    testWidgets('Con Riduci Movimento nessun lettore nasce e la carta resta',
        (tester) async {
      pinnaLoSchermo(tester);
      await tester.pumpWidget(scena(Maestro.medora, riduciMovimento: true));
      await svelaIlMaestro(tester);
      await tester.pump(const Duration(milliseconds: 500));
      expect(banco.nati, 0,
          reason: 'con Riduci Movimento sono nati ${banco.nati} lettori');
      expect(find.byType(MaestroCardReveal), findsOneWidget,
          reason: 'senza filmato la carta e\' la scena, e deve esserci');
    });
  });

  group('BR.02, il filmato si ferma sull\'ultimo fotogramma e ci resta', () {
    testWidgets(
        'Trenta fotogrammi dopo la fine: il filmato c\'e\', la carta no',
        (tester) async {
      pinnaLoSchermo(tester);
      await tester.pumpWidget(scena(Maestro.medora));
      await svelaIlMaestro(tester);
      final lettore = banco.vivi.single;
      lettore.finisci();
      var conIlFilmato = 0;
      var conLaCarta = 0;
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        final filmato = find
            .descendant(
                of: find.byType(VeloDiRivelazione),
                matching: find.byType(ColoredBox))
            .evaluate()
            .length;
        if (filmato == 1) conIlFilmato++;
        if (find.byType(MaestroCardReveal).evaluate().isNotEmpty) {
          conLaCarta++;
        }
        expect(filmato, 1,
            reason: 'al fotogramma $i dopo la fine il filmato non e\' piu\' a '
                'video: l\'ultimo fotogramma non resta, e il fondatore lo '
                'aveva chiesto con queste parole, "in modo che resti come '
                'immagine fissa"');
        expect(find.byType(MaestroCardReveal), findsNothing,
            reason: 'al fotogramma $i dopo la fine e\' tornata la carta: '
                'sopra al fermo immagine c\'e\' un secondo Maestro');
      }
      // ignore: avoid_print
      print('ORDINE BR VOCE 2: fotogrammi dopo la fine col filmato a video '
          '$conIlFilmato su 30, con la carta tornata $conLaCarta su 30');
      expect(conIlFilmato, 30);
      expect(conLaCarta, 0);
      expect(banco.vivi, hasLength(1),
          reason: 'il lettore e\' stato chiuso alla fine del filmato');
    });

    testWidgets('Il fermo non ha timer: cinque secondi dopo e\' ancora li\'',
        (tester) async {
      pinnaLoSchermo(tester);
      await tester.pumpWidget(scena(Maestro.aura));
      await svelaIlMaestro(tester);
      banco.vivi.single.finisci();
      await tester.pump(const Duration(seconds: 5));
      expect(
          find.descendant(
              of: find.byType(VeloDiRivelazione),
              matching: find.byType(ColoredBox)),
          findsOneWidget,
          reason: 'cinque secondi dopo la fine il fermo immagine e\' sparito '
              'da solo: c\'e\' un timer o una dissolvenza che l\'ordine vieta');
      expect(find.byType(MaestroCardReveal), findsNothing);
      expect(banco.vivi, hasLength(1));
    });

    testWidgets('Dieci aperture e chiusure lasciano zero lettori vivi',
        (tester) async {
      pinnaLoSchermo(tester);
      for (var giro = 0; giro < 10; giro++) {
        await tester.pumpWidget(scena(Maestro.caligo));
        await svelaIlMaestro(tester);
        banco.vivi.single.finisci();
        await tester.pump();
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      }
      // ignore: avoid_print
      print('ORDINE BR VOCE 2: lettori nati ${banco.nati}, vivi '
          '${banco.vivi.length}');
      expect(banco.nati, 10,
          reason: 'dieci aperture devono creare dieci lettori');
      expect(banco.vivi, isEmpty,
          reason: 'un fermo immagine che non si smonta mai tiene un '
              'decodificatore per ogni apertura della scena');
    });

    testWidgets('L\'app che va dietro chiude il filmato e scopre la carta',
        (tester) async {
      // **ESITO DICHIARATO, non nascosto.** L'app che passa in secondo piano
      // continua a chiudere il filmato, come faceva prima e per la stessa
      // ragione. Al ritorno non c'e' piu' il fermo immagine: c'e' la carta.
      pinnaLoSchermo(tester);
      await tester.pumpWidget(scena(Maestro.medora));
      await svelaIlMaestro(tester);
      banco.vivi.single.finisci();
      await tester.pump();
      // **LA MISURA SI PRENDE IN DUE TEMPI, e il secondo non e' un vezzo.**
      // Un'app in pausa non disegna: il motore smette di programmare
      // fotogrammi, quindi finche' sta dietro l'albero resta quello di
      // prima, e guardarlo li' non direbbe niente. Cio' che si puo'
      // misurare subito e' che il decodificatore e' stato liberato, ed
      // e' un conto e non un disegno. Cio' che la persona vede si vede
      // al ritorno.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(banco.vivi, isEmpty,
          reason: 'l\'app e\' passata dietro e il lettore e\' rimasto vivo');
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(find.byType(MaestroCardReveal), findsOneWidget,
          reason: 'chiuso il filmato deve tornare la carta, altrimenti la '
              'scena resta senza Maestro');
    });
  });
}

/// La piattaforma video finta: dichiara il video pronto, sa dire quando l'ha
/// finito, e registra quante viste ha costruito e quanti lettori ha liberato.
class _PiattaformaFinta extends VideoPlayerPlatform {
  final StreamController<VideoEvent> _eventi =
      StreamController<VideoEvent>.broadcast();

  int creati = 0;
  int chiusi = 0;
  final List<int> viste = [];
  Duration posizione = Duration.zero;

  /// Dieci secondi, come i tre filmati veri.
  static const Duration durata = Duration(seconds: 10);

  void finisci() {
    posizione = durata;
    _eventi.add(VideoEvent(eventType: VideoEventType.completed));
  }

  @override
  Future<void> init() async {}

  @override
  Future<void> dispose(int playerId) async => chiusi++;

  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async {
    creati++;
    // L'evento arriva su un timer e non su una microtask, perche' chi crea il
    // lettore si mette in ascolto DOPO: su un flusso broadcast un evento
    // emesso troppo presto non lo sente nessuno.
    Timer(Duration.zero, () {
      _eventi.add(VideoEvent(
        eventType: VideoEventType.initialized,
        duration: durata,
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
  Future<void> setVolume(int playerId, double volume) async {}

  @override
  Future<void> play(int playerId) async {}

  @override
  Future<void> pause(int playerId) async {}

  @override
  Future<void> seekTo(int playerId, Duration position) async =>
      posizione = position;

  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {}

  @override
  Future<Duration> getPosition(int playerId) async => posizione;

  @override
  Widget buildView(int playerId) {
    viste.add(playerId);
    return const SizedBox.shrink(key: Key('video_finto'));
  }

  @override
  Widget buildViewWithOptions(VideoViewOptions options) {
    viste.add(options.playerId);
    return const SizedBox.shrink(key: Key('video_finto'));
  }
}
