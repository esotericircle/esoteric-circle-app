import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'il_tavolo_di_medora.dart';

/// **LA SCENA DELLA STESA E' UN FILMATO.** Ordine FS aggiunta, voce FS.A2,
/// 14 ottobre 2026.
///
/// **Il fondatore:** *"vorrei fare lo stesso lavoro che abbiamo fatto per
/// animare lo sfondo dei tarocchi e cosi' faremo per ogni funzionalita'"*. Il
/// video scelto e' *"Il vortice"*: Medora porta avanti il mazzo chiuso, le
/// carte salgono in vortice e diventano polvere di stelle, la polvere cade
/// come neve d'oro e sparisce prima del velluto, e Medora resta ferma
/// nell'invito, col velluto pulito.
///
/// **IL TAGLIO.** Il filmato e' girato sulla geometria del tavolo: copre lo
/// sfondo `tavolo_medora_v2.webp` dal pixel [sopra] al pixel [sotto], a tutta
/// larghezza, e [nellaScena] lo mette esattamente li'. Misurato, l'ultimo
/// fotogramma coincide col tavolo fermo a un decimo di pixel
/// (`docs/collaudo/FS/aggiunta_video/a2_allineamento.txt`): le carte, il
/// velluto e i posti della stesa restano dove sono.
///
/// **UNA VOLTA PER APERTURA.** Il filmato parte quando si apre la Stesa, si
/// ferma sull'ultimo fotogramma e ci resta; una stesa rifatta nella stessa
/// visita non lo fa ripartire. Con Riduci Movimento, o se il filmato non si
/// carica, la scena e' ferma: lo sfondo con la posa dell'invito.
class ScenaDellaStesaInVideo {
  const ScenaDellaStesaInVideo._();

  /// **IL PERCORSO E' SPEZZATO IN PEZZI SENZA BARRE**, come quello della
  /// discesa: una barra scritta dentro una stringa viene letta come un elenco
  /// di participi dalla guardia `niente_vocativo_a_schermo`.
  static const String _dentro = 'brand_assets';
  static const String _dove = 'tavolo';
  static const String _file = 'medora_mazzo_in_vortice_v1.mp4';

  /// Il filmato del fondatore: 720 per 1280, 24 fotogrammi al secondo, 8,000
  /// secondi, con l'audio. L'impronta sta in `docs/stato_asset.json`.
  static const String filmato = '$_dentro/$_dove/$_file';

  /// Le misure del filmato, in pixel.
  static const Size misura = Size(720, 1280);

  /// Quanto dura il filmato intero, 192 fotogrammi a 24 al secondo. La
  /// scena non arriva fin qui: si ferma prima, a [fermaA].
  static const Duration durata = Duration(seconds: 8);

  /// **DOVE SI FERMA LA SCENA, NON ALLA FINE DEL FILMATO.** Ordine del 14
  /// ottobre 2026, dal telefono del fondatore: *"il video di animazione,
  /// Medora deve fermarsi poco prima della fine del video, quando ha la
  /// mano sul petto e non quando la allontana"*. Negli ultimi istanti del
  /// filmato la mano destra, ferma fino a circa 6,5 s, si allontana dal
  /// petto verso il gesto di invito finale (8,000 s): la scena si ferma
  /// prima, al fotogramma 166 (6,917 s), misurato guardando il filmato
  /// fotogramma per fotogramma (`docs/collaudo/FS/aggiunta_video/
  /// a4_dove_si_ferma_la_scena.txt`): la polvere d'oro e' gia' sparita dal
  /// velluto, la mano sinistra e' sul petto, la destra non si e' ancora
  /// mossa verso il gesto finale.
  static const Duration fermaA = Duration(milliseconds: 6917);

  /// **L'ULTIMO SECONDO RALLENTA, NON SI FERMA DI SCATTO.** Lo stesso
  /// fondatore: *"cerca di rallentare l'ultimo secondo in modo che non si
  /// fermi di botto"*. Negli ultimi [rallentamento] prima di [fermaA] la
  /// velocita' scende da 1,0 verso [velocitaMinima], mai a zero (il lettore
  /// video non riparte da fermo): l'ultimo gradino e' la pausa vera, quando
  /// la posizione raggiunge [fermaA]. Stessa idea della rampa del dito della
  /// discesa nel Mondo di Sotto (`DiscesaInVideo`), qui continua invece che
  /// a gradini, perche' non c'e' un dito che la guida.
  static const Duration rallentamento = Duration(seconds: 1);

  /// La velocita' minima della rampa: la stessa di [DiscesaInVideo.gradini],
  /// un decimo, per restare visibilmente in moto fino all'ultimo fotogramma
  /// prima della pausa vera.
  static const double velocitaMinima = 0.1;

  /// **LA VELOCITA' A [posizione].** 1,0 finche' manca piu' di
  /// [rallentamento] a [fermaA], poi scende verso [velocitaMinima] in
  /// proporzione a quanto manca. Non dice mai 0: la pausa vera e' un
  /// comando a parte ([fermo]), perche' `video_player` a velocita' zero non
  /// riparte da solo.
  ///
  /// Funzione pura, senza un lettore: una prova puo' misurarla fotogramma
  /// per fotogramma senza montare nulla.
  static double velocitaA(Duration posizione) {
    final restante = fermaA - posizione;
    if (restante <= Duration.zero) return velocitaMinima;
    if (restante > rallentamento) return 1.0;
    final frazione = restante.inMicroseconds / rallentamento.inMicroseconds;
    return frazione.clamp(velocitaMinima, 1.0).toDouble();
  }

  /// Vero quando [posizione] ha raggiunto o superato [fermaA]: qui la scena
  /// si ferma davvero, e ci resta.
  static bool fermo(Duration posizione) => posizione >= fermaA;

  /// **IL RIQUADRO DEL FILMATO NELLO SFONDO**, in pixel dello sfondo: dal
  /// pixel 147 al 1370, a tutta larghezza. E' il taglio 9 a 16 su cui il
  /// fondatore ha composto il primo e l'ultimo fotogramma (P2 dell'ordine).
  static const double sopra = 147;
  static const double sotto = 1370;

  /// Il rettangolo del filmato nella scena larga [w]: comincia sopra la
  /// scena, dove la scena taglia lo sfondo ([GeometriaDelTavolo.taglioInAlto]),
  /// e il resto lo nasconde il ritaglio della scena.
  static Rect nellaScena(double w) {
    final s = GeometriaDelTavolo.scala(w);
    return Rect.fromLTWH(0, (sopra - GeometriaDelTavolo.taglioInAlto) * s, w,
        (sotto - sopra) * s);
  }

  /// **LA SFUMATURA IN ALTO, col filmato: sei pixel e non quaranta.** Lo
  /// sfondo fermo entra nel cosmo per quaranta pixel, ma li' Medora stava
  /// fuori dalla sfumatura, disegnata sopra. Nel filmato Medora e' dentro
  /// l'immagine, e la sua testa comincia otto pixel e mezzo sotto il taglio
  /// (misurata sul fotogramma): con quaranta i capelli sarebbero sbiaditi.
  static const double sfumaturaInAlto = 6;
}

/// **IL LETTORE DELLA SCENA, dietro una porta sola.**
///
/// E' la stessa forma di `LettoreDellaDiscesa`: in una prova headless non c'e'
/// nessuna piattaforma che decodifichi un filmato, e senza una finta al posto
/// del lettore vero nessuna misura della scena si potrebbe prendere.
///
/// **Chi lo implementa promette di non lanciare mai.** Un file mancante o un
/// codec rifiutato si dichiarano con [fallito], e la scena resta ferma.
abstract class LettoreDellaScena {
  /// Il lettore vero, con `video_player`.
  factory LettoreDellaScena.vero() = _LettoreDellaScenaVero;

  /// Prepara il filmato **senza farlo partire**. Non lancia mai.
  Future<void> apri();

  /// Vero quando il filmato e' pronto a partire.
  bool get pronto;

  /// Vero quando [apri] ha finito senza riuscirci.
  bool get fallito;

  /// Vero quando il filmato e' andato oltre il primo fotogramma: da li' in
  /// poi lo si mostra, prima c'e' la posa ferma del mazzo.
  bool get cominciato;

  /// Vero quando il filmato e' arrivato in fondo: resta fermo li'.
  bool get finito;

  /// Chi ascolta i cambi di stato: uno solo, e nullo per smettere.
  void ascolta(VoidCallback? quandoCambia);

  /// Il volume, fra 0 e 1. Si dice prima di [avvia].
  Future<void> volume(double quanto);

  /// Parte, o riparte da dove si era fermato. A filmato finito non fa niente.
  Future<void> avvia();

  /// Si ferma dov'e'.
  Future<void> sospendi();

  /// Il fotogramma corrente, a riempire il riquadro.
  Widget disegna();

  /// Libera tutto. Va chiamata sempre, anche se [apri] non ce l'ha fatta.
  void chiudi();
}

/// Chi costruisce il lettore. La finta delle prove si mette qui.
typedef FabbricaDellaScena = LettoreDellaScena Function();

class _LettoreDellaScenaVero implements LettoreDellaScena {
  _LettoreDellaScenaVero();

  VideoPlayerController? _c;
  AppLifecycleListener? _ciclo;
  VoidCallback? _quandoCambia;
  bool _pronto = false;
  bool _fallito = false;
  bool _cominciato = false;
  bool _finito = false;

  /// L'ultima velocita' impostata durante la rampa, per non richiamare
  /// `setPlaybackSpeed` a ogni fotogramma quando il numero non e' cambiato
  /// di una quantita' che si vede.
  double? _ultimaVelocita;

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
    // **MESCOLATO AGLI ALTRI SUONI, SENZA PRENDERE IL FUOCO AUDIO.** Senza
    // questa opzione il lettore chiede il fuoco esclusivo: su Android ferma
    // la musica di chi ascolta altro, e la memoria di questo progetto ha gia'
    // un caso in cui il lettore degli effetti restava muto mentre un video
    // aveva il fuoco (ordine CN). Il suono del vortice sta sopra la musica
    // d'ambiente, come un effetto.
    final c = VideoPlayerController.asset(ScenaDellaStesaInVideo.filmato,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true));
    _c = c;
    try {
      await c.initialize();
      // Chiuso mentre si preparava: la persona se n'e' andata dalla Stesa.
      if (!identical(_c, c)) return;
      // Muto finche' chi lo apre non dice il volume: un decimo di secondo di
      // audio prima del muto e' comunque un suono che non era stato chiesto.
      await c.setVolume(0);
      await c.setLooping(false);
      c.addListener(_guarda);
      // **IL LETTORE SA DA SE' QUANDO L'APP SE NE VA**, come ogni sorgente
      // di suono di lib (guardia `nessuna_sorgente_resta_accesa_in_
      // sottofondo`): con l'app dietro il video si ferma, anche se chi l'ha
      // aperto non glielo dice. La ripresa al ritorno la decide la Stesa,
      // che sa se il video era fermo per l'uscita o perche' era finito.
      _ciclo = AppLifecycleListener(
        onHide: () => c.pause().catchError((Object errore) {
          debugPrint('Il filmato della scena non si ferma: $errore');
        }),
      );
      _pronto = true;
    } catch (errore) {
      // **PERCHE' QUESTO ERRORE SI ASSORBE**, come nel lettore della
      // discesa: file assente, codec rifiutato o nessuna piattaforma che
      // decodifichi vogliono tutti la stessa risposta, cioe' la scena ferma.
      debugPrint('Il filmato della scena della Stesa non si prepara, la '
          'scena resta ferma: $errore');
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
    if (!_finito && v.isInitialized) {
      // **LA SCENA SI FERMA A `fermaA`, NON ALLA FINE DEL FILMATO.** Mai un
      // `seekTo`: si lascia che il filmato arrivi li' da solo, rallentando
      // nell'ultimo [ScenaDellaStesaInVideo.rallentamento]
      // ([ScenaDellaStesaInVideo.velocitaA]) e fermandosi (`pause`) quando
      // la posizione lo raggiunge o lo supera ([ScenaDellaStesaInVideo.
      // fermo]), cosi' un fotogramma perso per il tempo reale non lascia il
      // lettore in corsa per sempre.
      if (ScenaDellaStesaInVideo.fermo(v.position)) {
        _finito = true;
        cambiato = true;
        unawaited(c.pause());
      } else {
        final velocita = ScenaDellaStesaInVideo.velocitaA(v.position);
        final ultima = _ultimaVelocita;
        if (ultima == null || (velocita - ultima).abs() > 0.02) {
          _ultimaVelocita = velocita;
          unawaited(c.setPlaybackSpeed(velocita));
        }
      }
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
      debugPrint('Il volume della scena non cambia: $errore');
    }
  }

  @override
  Future<void> avvia() async {
    // **A FILMATO FINITO NON SI RIPARTE**: `play` di video_player, a
    // posizione uguale alla durata, torna all'inizio con un salto.
    if (_finito) return;
    try {
      await _c?.play();
    } catch (errore) {
      debugPrint('Il filmato della scena non parte: $errore');
    }
  }

  @override
  Future<void> sospendi() async {
    try {
      await _c?.pause();
    } catch (errore) {
      debugPrint('Il filmato della scena non si ferma: $errore');
    }
  }

  /// `BoxFit.fill`: il riquadro di [ScenaDellaStesaInVideo.nellaScena] ha gia'
  /// la proporzione del filmato (688 su 1223 contro 720 su 1280, cinque
  /// decimillesimi di differenza).
  @override
  Widget disegna() {
    final c = _c;
    if (c == null) return const SizedBox.shrink();
    return FittedBox(
      fit: BoxFit.fill,
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
    _ciclo?.dispose();
    _ciclo = null;
    if (c == null) return;
    c.removeListener(_guarda);
    c.pause().catchError((Object _) {});
    c.dispose().catchError((Object _) {});
  }
}
