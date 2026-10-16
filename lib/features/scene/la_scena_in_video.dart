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
  bool _scaduta = false;

  /// **IL VIDEO HA UN TEMPO PER PREPARARSI**, ordine FX voce FXA.08. Da
  /// quando il resto della schermata aspetta la scena ferma
  /// ([IlRestoDopoLaScena]), un lettore che non risponde mai (una
  /// piattaforma che non decodifica e non dice di no) terrebbe la schermata
  /// vuota per sempre. Passato questo tempo senza che il video sia pronto,
  /// la scena e' ferma come se non si fosse caricato, e un video pronto
  /// dopo non parte piu'.
  ///
  /// **DODICI SECONDI, NON QUATTRO** (ordine FY, il fondatore sulla build
  /// 2313: "Il video all'apertura dell'oroscopo, parte solo la seconda
  /// volta"). Sul Realme la prima apertura di un video, a freddo, chiede
  /// piu' di quattro secondi: la scena si arrendeva ("La scena non si
  /// prepara entro 0:00:04", letto dai registri del telefono) e il video non
  /// partiva; la seconda volta era gia' in memoria e partiva. Padre FXA.08.
  /// E se il video e' pronto dopo l'attesa, parte lo stesso.
  static const Duration attesaMassima = Duration(seconds: 12);

  /// La scena e' ferma sul suo ultimo fotogramma: Riduci Movimento, grafica
  /// alleggerita, video che non si carica, oppure video finito o saltato.
  bool get ferma {
    final l = _lettore;
    return _ferma || _scaduta || l == null || l.fallito || l.finito || _saltata;
  }

  /// Il video gira (o sta per girare): e' il momento in cui un tocco lo
  /// salta.
  bool get inCorso {
    final l = _lettore;
    return !_ferma &&
        !_saltata &&
        !_scaduta &&
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
    return !_ferma && !_scaduta && l != null && !l.fallito && l.cominciato;
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
    final apertura = lettore.apri();
    await apertura.timeout(attesaMassima, onTimeout: () {
      if (lettore.pronto || lettore.fallito) return;
      debugPrint('La scena non si prepara entro $attesaMassima, intanto ferma');
      _scaduta = true;
      if (!_chiusa) notifyListeners();
    });
    // IL VIDEO PRONTO TARDI PARTE LO STESSO: si aspetta la fine vera
    // dell'apertura, e se arriva pronto si torna a mostrarlo.
    if (_scaduta && !_chiusa) {
      try {
        await apertura;
      } catch (errore) {
        debugPrint('La scena non si apre: $errore');
      }
      if (_chiusa || _saltata || !lettore.pronto) return;
      _scaduta = false;
      notifyListeners();
    }
    if (_chiusa || _scaduta || !lettore.pronto) return;
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
    if (l == null || !l.pronto || l.finito || _saltata || _scaduta) return;
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

/// **IL RESTO ASPETTA LA SCENA, IL PUNTO UNICO.** Ordine FX voce FXA.08, 16
/// ottobre 2026. Il fondatore: *"assicurati che tutto venga sovrapposto dopo
/// aver visto il video di scena e non che il Video si veda coperto da
/// riquadri e testi"*.
///
/// Avvolge ogni cosa della schermata che non e' il video, la barra in alto
/// o lo sfondo: pannelli, testi, pulsanti, carte, numeri, la riga del
/// Maestro. **Finche' la scena non e' ferma** ([scenaFerma] falso: il video
/// si prepara o gira) il resto non si vede, non si tocca e non si legge;
/// **quando il video finisce o il tocco lo salta** compare in dissolvenza
/// sopra l'ultimo fotogramma, con la stessa durata del salto
/// ([IlFilmatoCheSfuma.dissolvenza]). Con Riduci Movimento o la grafica
/// alleggerita la scena e' ferma dalla prima immagine, e il resto e' pieno
/// subito, senza dissolvenza.
///
/// **SI MONTA SEMPRE, ANCHE A SCENA FERMA.** Cambia solo l'opacita': un
/// avvolgimento che comparisse e sparisse ricostruirebbe cio' che avvolge,
/// e un campo da scrivere perderebbe il suo testo.
///
/// La guardia di ogni scena chiama `test/sopra_il_filmato.dart` a video in
/// corso, e cade col nome di cio' che si vede sopra il video.
class IlRestoDopoLaScena extends StatelessWidget {
  const IlRestoDopoLaScena({
    super.key,
    required this.scenaFerma,
    required this.child,
    this.subito = false,
  });

  /// **SENZA VIDEO, SUBITO.** Vero quando nessun video e' stato in scena
  /// (non si e' caricato, o la scena non e' partita): "senza video, tutto
  /// compare subito sulla scena ferma" (FXA.08). Senza, un video che non si
  /// carica faceva comunque attendere la dissolvenza, e la chat di Medora
  /// mostrava la sua fascia sotto il campo ancora a meta' (preso dal
  /// cancello, la_riga_del_campo_e_pulita_test, sul commit 8a354397).
  final bool subito;

  /// La scena e' ferma sul suo ultimo fotogramma, o non ha video: il resto
  /// si vede. Per chi usa [RegiaDellaScena] e' [RegiaDellaScena.ferma].
  final bool scenaFerma;
  final Widget child;

  /// Avvolge ogni figlio di [figli] tranne quelli in [scena], che restano
  /// come sono: per le schermate che mettono la scena dentro un elenco,
  /// insieme a cio' che le sta sotto.
  static List<Widget> attorno(
    List<Widget> figli, {
    required bool scenaFerma,
    required Set<Widget> scena,
  }) =>
      [
        for (final f in figli)
          scena.any((s) => identical(s, f))
              ? f
              : IlRestoDopoLaScena(scenaFerma: scenaFerma, child: f),
      ];

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: scenaFerma ? 1 : 0,
      duration: subito ? Duration.zero : IlFilmatoCheSfuma.dissolvenza,
      curve: Curves.easeOut,
      child: IgnorePointer(
        ignoring: !scenaFerma,
        child: ExcludeSemantics(excluding: !scenaFerma, child: child),
      ),
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
