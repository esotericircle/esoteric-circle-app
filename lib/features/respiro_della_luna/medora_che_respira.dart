import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// **MEDORA RESPIRA COL DITO.** Ordine GD voce GD.24, 23 ottobre 2026. Il
/// fondatore: *"il video di Medora doveva andare avanti e indietro seguendo
/// «espira e inspira» e per questo avevamo creato il video apposta con
/// Medora che inspira ed espira"*.
///
/// Il video e' quello della scena del Respiro (ordine FX, P1): Medora sulla
/// terrazza alza il viso e prende l'aria mentre la Luna si svela. Guardato
/// fotogramma per fotogramma, l'inspiro sale dal primo fotogramma fino a
/// quattro secondi e mezzo (il viso piu' alto, la bocca aperta), poi Medora
/// abbassa il capo. Qui vive solo quel tratto: **avanti sull'inspiro,
/// indietro sull'espiro**, comandato dalla posizione del lettore e mai dalla
/// velocita'.
///
/// **PERCHE' LA POSIZIONE E NON LA VELOCITA'.** Su Android il cambio di
/// velocita' del lettore arriva circa mezzo secondo tardi, e un video non si
/// suona all'indietro: la posizione si chiede invece al fotogramma.
///
/// **PERCHE' UN FILE SUO.** Il video della scena ha un solo fotogramma
/// chiave, il primo (misurato con ffprobe sul ramo): ogni salto indietro
/// costringerebbe il telefono a ridecodificare dal primo fotogramma, e su
/// Android un salto si aggancia al fotogramma chiave, cioe' tornerebbe
/// sempre all'inizio. Il file di questo rito e' lo stesso filmato dipinto,
/// tagliato ai suoi primi quattro secondi e mezzo e codificato con un
/// fotogramma chiave per ogni fotogramma (108 su 108): ogni salto costa la
/// decodifica di un solo fotogramma.
abstract class LettoreDelRespiro {
  factory LettoreDelRespiro.vero(String filmato) = _LettoreDelRespiroVero;

  /// Prepara il video; non lo fa partire.
  Future<void> apri();

  /// Vero quando il video e' pronto a mostrare un fotogramma.
  bool get pronto;

  /// Porta il video al fotogramma di [posizione]: e' l'unico comando.
  Future<void> vaiA(Duration posizione);

  /// Il fotogramma mostrato, gia' nella sua misura.
  Widget disegna();

  void chiudi();
}

typedef FabbricaDelRespiro = LettoreDelRespiro Function();

class _LettoreDelRespiroVero implements LettoreDelRespiro {
  _LettoreDelRespiroVero(this.filmato);

  final String filmato;
  VideoPlayerController? _c;
  bool _pronto = false;

  /// **SA QUANDO L'APP SE NE VA** (guardia dell'ordine CT voce 07, ogni
  /// lettore di lib osserva il ciclo di vita). Questo lettore non suona mai
  /// (il file non ha audio, il volume e' zero) e non e' mai in riproduzione:
  /// si muove solo a salti. Se una piattaforma lo lasciasse in riproduzione
  /// dopo un salto, andando in fondo si ferma lo stesso.
  AppLifecycleListener? _ciclo;

  @override
  bool get pronto => _pronto;

  @override
  Future<void> apri() async {
    final c = VideoPlayerController.asset(filmato,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
    _c = c;
    _ciclo = AppLifecycleListener(
        onHide: () => _c?.pause().catchError((Object _) {}));
    try {
      await c.initialize();
      if (!identical(_c, c)) return;
      await c.setVolume(0);
      await c.setLooping(false);
      _pronto = true;
    } catch (errore) {
      debugPrint('Medora che respira non si prepara, la scena resta '
          'ferma: $errore');
    }
  }

  @override
  Future<void> vaiA(Duration posizione) async {
    try {
      await _c?.seekTo(posizione);
    } catch (errore) {
      debugPrint('Medora che respira non va a $posizione: $errore');
    }
  }

  @override
  Widget disegna() {
    final c = _c;
    if (c == null || !_pronto) return const SizedBox.shrink();
    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: c.value.size.width,
        height: c.value.size.height,
        child: VideoPlayer(c),
      ),
    );
  }

  @override
  void chiudi() {
    final c = _c;
    _c = null;
    _pronto = false;
    _ciclo?.dispose();
    _ciclo = null;
    if (c == null) return;
    c.dispose().catchError((Object _) {});
  }
}

/// **IL RESPIRO DIVENTA UN FOTOGRAMMA.** Riceve quanto e' aperto il respiro
/// (zero velata, uno piena luce, lo stesso valore che accende la Luna) e
/// porta il lettore al fotogramma corrispondente del tratto dell'inspiro.
///
/// **UN SALTO ALLA VOLTA.** Un salto chiesto mentre il precedente non e'
/// finito non parte: si ricorda solo l'ultimo fotogramma voluto, e appena il
/// lettore risponde si va li'. Cosi' il telefono non accumula salti che
/// arrivano tardi, e un fotogramma uguale al precedente non si richiede.
class MedoraCheRespira {
  MedoraCheRespira(this.lettore);

  final LettoreDelRespiro lettore;

  /// Il video dell'inspiro, nel pacchetto (dichiarato con la cartella
  /// `brand_assets/respiro_della_luna/`).
  static const String filmato =
      'brand_assets/respiro_della_luna/medora_il_respiro_della_luna_inspiro_v1.mp4';

  /// Fotogrammi al secondo del filmato (24, come la scena di FX).
  static const int fotogrammiAlSecondo = 24;

  /// Fotogrammi del tratto dell'inspiro: quattro secondi e mezzo a 24.
  static const int fotogrammi = 108;

  int? _chiesto;
  int? _voluto;
  bool _inViaggio = false;
  bool _chiuso = false;

  /// Il fotogramma dell'apertura [respiro], fra zero e [fotogrammi] meno uno.
  static int fotogrammaDi(double respiro) =>
      (respiro.clamp(0.0, 1.0) * (fotogrammi - 1)).round();

  /// L'istante del fotogramma [n] nel filmato.
  static Duration istanteDi(int n) =>
      Duration(microseconds: (n * 1000000 / fotogrammiAlSecondo).round());

  /// Segue il respiro: chiamata a ogni fotogramma della Luna.
  void segui(double respiro) {
    if (_chiuso || !lettore.pronto) return;
    _voluto = fotogrammaDi(respiro);
    unawaited(_vai());
  }

  Future<void> _vai() async {
    if (_inViaggio) return;
    while (!_chiuso && _voluto != null && _voluto != _chiesto) {
      final n = _voluto!;
      _chiesto = n;
      _inViaggio = true;
      await lettore.vaiA(istanteDi(n));
      _inViaggio = false;
    }
  }

  void chiudi() {
    _chiuso = true;
    lettore.chiudi();
  }
}
