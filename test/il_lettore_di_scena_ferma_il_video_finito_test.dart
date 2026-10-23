import 'dart:async';

import 'package:esoteric_circle/features/scene/la_scena_in_video.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

/// **IL VIDEO FINITO VA FERMATO DAVVERO, NON SOLO LETTO COME FINITO.**
/// Trovato misurando un consumo di CPU anomalo sul Realme 767f596c
/// (80-126 per cento, costante, su schermate quasi ferme, con due
/// `VideoPlayerController` vivi e nessuno disposto), ordine FZ voce FZ.09,
/// 19 ottobre 2026.
///
/// **La causa, risalita fino al pacchetto `video_player`**: il suo timer
/// interno che interroga la posizione (`_applyPlayPause`, ogni cento
/// millisecondi) si ferma solo quando qualcuno chiama `pause()` sul
/// controller. Il pacchetto lo fa da solo SOLO se riceve l'evento nativo
/// "completed" dalla piattaforma; su Android quell'evento non arriva
/// sempre in modo affidabile. `_LettoreDiScenaVero._guarda()` calcola il
/// proprio `_finito` anche guardando `v.position >= v.duration` (un
/// calcolo nostro, indipendente dall'evento nativo): un video che la
/// nostra logica considera finito per questa via, senza l'evento nativo,
/// restava con un controller mai messo in pausa, e il suo timer di
/// polling girava per sempre.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _PiattaformaFinta piattaforma;

  setUp(() {
    piattaforma = _PiattaformaFinta();
    VideoPlayerPlatform.instance = piattaforma;
  });

  test(
      'il video che raggiunge la fine per posizione, senza l evento nativo '
      '"completed", viene messo in pausa lo stesso', () async {
    final lettore = LettoreDiScena.vero('un_asset_qualunque.mp4');
    var cambiamenti = 0;
    lettore.ascolta(() => cambiamenti++);
    await lettore.apri();
    await lettore.avvia();
    expect(piattaforma.inPausa, isFalse,
        reason: 'il video non e mai partito: la prova non misura niente');

    // **LA POSIZIONE RAGGIUNGE LA FINE, MA NESSUN EVENTO "completed" ARRIVA
    // DALLA PIATTAFORMA**: e' esattamente il caso visto sul Realme, dove
    // l'evento nativo non arrivava mai.
    piattaforma.posizione = piattaforma.durata;
    piattaforma.emettiAggiornamentoPosizione();
    // Il controller vero aggiorna la sua posizione sul proprio timer
    // periodico: si lascia girare un giro vero dell'event loop.
    await Future<void>.delayed(const Duration(milliseconds: 150));

    expect(lettore.finito, isTrue,
        reason: 'il lettore non si accorge che il video e arrivato alla '
            'fine');
    expect(piattaforma.inPausa, isTrue,
        reason: 'il video e considerato finito ma il controller non e mai '
            'stato messo in pausa: il timer di polling della posizione del '
            'pacchetto video_player continua a girare per tutta la vita del '
            'processo, anche a video gia fermo');

    lettore.chiudi();
  });
}

/// La piattaforma video finta, minimale: dichiara il video pronto, lascia
/// avanzare la posizione a comando, e MAI emette da sola l'evento nativo
/// "completed" (il caso che questa prova riproduce apposta).
class _PiattaformaFinta extends VideoPlayerPlatform {
  final StreamController<VideoEvent> _eventi =
      StreamController<VideoEvent>.broadcast();
  final Duration durata = const Duration(seconds: 10);

  bool inPausa = true;
  Duration posizione = Duration.zero;

  @override
  Future<void> init() async {}

  @override
  Future<void> dispose(int playerId) async {}

  @override
  Future<int?> createWithOptions(VideoCreationOptions options) async {
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
  Future<void> setMixWithOthers(bool mixWithOthers) async {}

  @override
  Future<void> setLooping(int playerId, bool looping) async {}

  @override
  Future<void> setVolume(int playerId, double volume) async {}

  @override
  Future<void> play(int playerId) async => inPausa = false;

  @override
  Future<void> pause(int playerId) async => inPausa = true;

  @override
  Future<void> seekTo(int playerId, Duration position) async =>
      posizione = position;

  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {}

  @override
  Future<Duration> getPosition(int playerId) async => posizione;

  void emettiAggiornamentoPosizione() {
    // Nessun VideoEvent reale: il controller legge la posizione dal suo
    // timer di polling via getPosition, non da un evento.
  }

  @override
  Widget buildView(int playerId) =>
      const SizedBox.shrink(key: Key('video_finto'));

  @override
  Widget buildViewWithOptions(VideoViewOptions options) =>
      const SizedBox.shrink(key: Key('video_finto'));
}
