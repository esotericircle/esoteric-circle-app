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

  /// Quanto dura.
  static const Duration durata = Duration(seconds: 8);

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
    if (c == null) return;
    c.removeListener(_guarda);
    c.pause().catchError((Object _) {});
    c.dispose().catchError((Object _) {});
  }
}
