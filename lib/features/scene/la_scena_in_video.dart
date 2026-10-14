import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../core/quality/quality_tier.dart';
import '../../core/sensi/la_suoneria.dart';
import '../../core/settings/settings_controller.dart';

/// **LA SCENA IN VIDEO, LE PARTI COMUNI.** Ordine FU, 15 ottobre 2026.
///
/// La Stesa (ordine FS) e la Sinastria evolutiva (ordine FT) avevano ognuna
/// il suo lettore e la sua regia, scritti due volte. L'ordine FU porta tre
/// scene nuove (l'Oracolo degli Angeli, l'Oroscopo, la Sinastria VIP): qui il
/// lettore e la regia stanno una volta sola, e le scene nuove li usano. Le
/// due scene di prima tengono i loro lettori (R10 dell'ordine: nessun loro
/// file cambia comportamento) e prendono da qui il solo tocco che salta.
///
/// **LE REGOLE DI OGNI SCENA**, le stesse della Stesa e della Sinastria
/// evolutiva:
/// - il video parte a ogni apertura della funzione, una volta per apertura,
///   e si ferma sull'ultimo fotogramma;
/// - con Riduci Movimento, con la grafica alleggerita o se il video non si
///   carica, la scena e' ferma sul suo ultimo fotogramma;
/// - l'audio suona solo con l'interruttore del suono dell'app acceso e il
///   telefono non in silenzioso, mescolato agli altri suoni, senza prendere
///   il fuoco audio;
/// - uscendo dall'app il video si ferma, e al ritorno riprende se non e'
///   finito;
/// - **un tocco in qualunque punto, mentre il video gira, lo fa sfumare
///   sulla scena ferma** ([IlToccoCheSalta], voce FU.15).
abstract class LettoreDiScena {
  factory LettoreDiScena.vero(String filmato) = _LettoreDiScenaVero;

  Future<void> apri();
  bool get pronto;
  bool get fallito;
  bool get cominciato;
  bool get finito;
  void ascolta(VoidCallback? quandoCambia);
  Future<void> volume(double quanto);
  Future<void> avvia();
  Future<void> sospendi();

  /// Il video, gia' nella sua misura: chi lo monta lo mette nel riquadro
  /// della scena.
  Widget disegna();
  void chiudi();
}

typedef FabbricaDiScena = LettoreDiScena Function();

class _LettoreDiScenaVero implements LettoreDiScena {
  _LettoreDiScenaVero(this.filmato);

  final String filmato;
  VideoPlayerController? _c;
  VoidCallback? _quandoCambia;
  bool _pronto = false;
  bool _fallito = false;
  bool _cominciato = false;
  bool _finito = false;

  @override
  bool get pronto => _pronto;
  @override
  bool get fallito => _fallito;
  @override
  bool get cominciato => _cominciato;
  @override
  bool get finito => _finito;

  @override
  void ascolta(VoidCallback? quandoCambia) => _quandoCambia = quandoCambia;

  @override
  Future<void> apri() async {
    // MESCOLATO AGLI ALTRI SUONI, come i lettori della Stesa e della
    // Sinastria evolutiva: senza `mixWithOthers` il video prende il fuoco
    // esclusivo e su Android ferma la musica di chi ascolta altro.
    final c = VideoPlayerController.asset(filmato,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
    _c = c;
    try {
      await c.initialize();
      if (!identical(_c, c)) return;
      await c.setVolume(0);
      await c.setLooping(false);
      c.addListener(_guarda);
      _pronto = true;
    } catch (errore) {
      debugPrint('La scena $filmato non si prepara, resta ferma: $errore');
      _fallito = true;
    }
    _quandoCambia?.call();
  }

  void _guarda() {
    final c = _c;
    if (c == null) return;
    final v = c.value;
    var cambiato = false;
    if (!_cominciato && v.position > Duration.zero) {
      _cominciato = true;
      cambiato = true;
    }
    if (!_finito &&
        v.isInitialized &&
        v.duration > Duration.zero &&
        (v.isCompleted || v.position >= v.duration)) {
      _finito = true;
      cambiato = true;
    }
    if (v.hasError && !_fallito) {
      _fallito = true;
      cambiato = true;
    }
    if (cambiato) _quandoCambia?.call();
  }

  @override
  Future<void> volume(double quanto) async {
    try {
      await _c?.setVolume(quanto.clamp(0.0, 1.0).toDouble());
    } catch (errore) {
      debugPrint('Il volume della scena $filmato non cambia: $errore');
    }
  }

  @override
  Future<void> avvia() async {
    if (_finito) return;
    try {
      await _c?.play();
    } catch (errore) {
      debugPrint('La scena $filmato non parte: $errore');
    }
  }

  @override
  Future<void> sospendi() async {
    try {
      await _c?.pause();
    } catch (errore) {
      debugPrint('La scena $filmato non si ferma: $errore');
    }
  }

  @override
  Widget disegna() {
    final c = _c;
    if (c == null) return const SizedBox.shrink();
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
    _quandoCambia = null;
    if (c == null) return;
    c.removeListener(_guarda);
    c.pause().catchError((Object _) {});
    c.dispose().catchError((Object _) {});
  }
}

/// **LA REGIA DI UNA SCENA**: apre il video, ne decide il volume, lo ferma
/// quando l'app va in fondo e lo riprende al ritorno, e sa dire alla
/// schermata che cosa mostrare. Una regia per apertura della funzione:
/// la schermata la crea in `initState` e la chiude in `dispose`.
class RegiaDellaScena extends ChangeNotifier with WidgetsBindingObserver {
  RegiaDellaScena(this._fabbrica);

  final FabbricaDiScena _fabbrica;
  LettoreDiScena? _lettore;
  bool _avviata = false;
  bool _ferma = false;
  bool _saltata = false;
  bool _sospesaDaNoi = false;
  bool _chiusa = false;

  /// La scena e' ferma sul suo ultimo fotogramma: Riduci Movimento, grafica
  /// alleggerita, video che non si carica, oppure video finito o saltato.
  bool get ferma {
    final l = _lettore;
    return _ferma || l == null || l.fallito || l.finito || _saltata;
  }

  /// Il video gira (o sta per girare): e' il momento in cui un tocco lo
  /// salta.
  bool get inCorso {
    final l = _lettore;
    return !_ferma &&
        !_saltata &&
        l != null &&
        !l.fallito &&
        !l.finito &&
        l.pronto;
  }

  /// Il video si vede: e' cominciato e non e' fallito. Resta montato anche a
  /// video finito (e' l'ultimo fotogramma) e durante la dissolvenza del
  /// salto.
  bool get filmatoInScena {
    final l = _lettore;
    return !_ferma && l != null && !l.fallito && l.cominciato;
  }

  /// Il video e' stato saltato col tocco: la schermata lo fa sfumare.
  bool get saltata => _saltata;

  /// Il video, da mettere nel riquadro della scena.
  Widget disegna() => _lettore?.disegna() ?? const SizedBox.shrink();

  /// Parte una volta sola: chiamata da `didChangeDependencies`, perche' legge
  /// Riduci Movimento e la grafica dal contesto.
  Future<void> avvia(BuildContext context) async {
    if (_avviata) return;
    _avviata = true;
    final tierBasso =
        _forse<QualityTierController>(context)?.tier == QualityTier.low;
    if (MediaQuery.of(context).disableAnimations || tierBasso) {
      _ferma = true;
      notifyListeners();
      return;
    }
    final suono =
        _forse<SettingsController>(context)?.suonoEVibrazione ?? false;
    WidgetsBinding.instance.addObserver(this);
    final lettore = _fabbrica();
    _lettore = lettore;
    lettore.ascolta(() {
      if (!_chiusa) notifyListeners();
    });
    await lettore.apri();
    if (_chiusa || !lettore.pronto) return;
    final muto = !suono || await LaSuoneria.spenta();
    if (_chiusa) return;
    await lettore.volume(muto ? 0 : 1);
    if (_chiusa || _saltata) return;
    await lettore.avvia();
  }

  /// **IL TOCCO CHE SALTA**, voce FU.15: il video si ferma e la schermata
  /// lo fa sfumare sulla scena ferma; tutto cio' che il video doveva
  /// preparare compare subito.
  void salta() {
    if (_saltata || !inCorso) return;
    _saltata = true;
    unawaited(_lettore?.sospendi());
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final l = _lettore;
    if (l == null || !l.pronto || l.finito || _saltata) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      if (_sospesaDaNoi) return;
      _sospesaDaNoi = true;
      unawaited(l.sospendi());
    } else if (state == AppLifecycleState.resumed && _sospesaDaNoi) {
      _sospesaDaNoi = false;
      unawaited(l.avvia());
    }
  }

  T? _forse<T>(BuildContext context) {
    try {
      return context.read<T>();
    } catch (senzaProvider) {
      debugPrint('La scena: manca $T, ripiego ($senzaProvider)');
      return null;
    }
  }

  @override
  void dispose() {
    _chiusa = true;
    WidgetsBinding.instance.removeObserver(this);
    _lettore?.chiudi();
    _lettore = null;
    super.dispose();
  }
}

/// **IL TOCCO CHE SALTA IL VIDEO, IL PUNTO UNICO.** Ordine FU voce FU.15, 15
/// ottobre 2026. Il fondatore: *"bisogna fare in modo che con un click il
/// video possa sparire in dissolvenza. Dopo un po' stanca, se qualcuno
/// accede spesso o ripetutamente"*.
///
/// Avvolge tutta la schermata di una scena. Mentre il video gira
/// ([inCorso]), un velo trasparente sopra ogni cosa prende il tocco, in
/// qualunque punto dello schermo, e lo consuma: **il tocco che salta non
/// vale anche come scelta**. Finito o saltato il video, il velo sparisce e
/// la schermata risponde come sempre.
///
/// Ogni scena dell'app passa da qui: la guardia
/// `test/ogni_scena_si_salta_col_tocco_test.dart` cade col nome della scena
/// che non ci passa.
class IlToccoCheSalta extends StatelessWidget {
  const IlToccoCheSalta({
    super.key,
    required this.inCorso,
    required this.onSalta,
    required this.child,
  });

  final bool inCorso;
  final VoidCallback onSalta;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (inCorso)
          Positioned.fill(
            child: GestureDetector(
              key: const Key('il_tocco_che_salta'),
              behavior: HitTestBehavior.opaque,
              onTap: onSalta,
            ),
          ),
      ],
    );
  }
}

/// **LA DISSOLVENZA DEL SALTO**: il video sfuma sulla scena ferma che sta
/// sotto di lui. Quanto dura e' scritto qui, una volta per tutte le scene.
class IlFilmatoCheSfuma extends StatelessWidget {
  const IlFilmatoCheSfuma({
    super.key,
    required this.saltato,
    required this.child,
  });

  static const Duration dissolvenza = Duration(milliseconds: 450);

  final bool saltato;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: saltato ? 0 : 1,
      duration: dissolvenza,
      curve: Curves.easeOut,
      child: IgnorePointer(ignoring: saltato, child: child),
    );
  }
}

/// **LA SCENA FERMA CHE APPARE**, l'altra meta' della dissolvenza
/// incrociata: mentre il video saltato sfuma, la posa ferma che lo
/// sostituisce entra con la stessa durata. Senza salto ([appare] falso) la
/// posa e' gia' piena, come prima dell'ordine FU.
class LaScenaFermaCheAppare extends StatelessWidget {
  const LaScenaFermaCheAppare({
    super.key,
    required this.appare,
    required this.child,
  });

  final bool appare;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!appare) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: IlFilmatoCheSfuma.dissolvenza,
      curve: Curves.easeOut,
      builder: (context, quanto, figlio) =>
          Opacity(opacity: quanto, child: figlio),
      child: child,
    );
  }
}
