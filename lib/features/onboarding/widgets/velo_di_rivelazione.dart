import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';

import '../../../core/maestro/maestro.dart';
import '../../../core/maestro/rivelazione_in_video.dart';

/// IL VELO DI RIVELAZIONE: il video del Maestro, sopra la sua immagine ferma.
/// Ordine BQ voci 2 e 3.
///
/// **NON SOSTITUISCE L'IMMAGINE, LE STA SOPRA, ed e' la decisione che regge
/// tutte e due le voci.** Un widget che scambia l'immagine col video avrebbe
/// avuto tre modi di lasciare la scena vuota: mentre il filmato si prepara, se
/// il file non c'e', e nel fotogramma fra l'ultimo quadro e il ritorno
/// all'immagine. Cosi' invece l'immagine e' SEMPRE in albero e il video le si
/// posa davanti: quando finisce, o se non parte affatto, non c'e' nessun
/// passaggio da fare e quindi nessun nero possibile.
///
/// **Il video si riproduce una volta sola, senza ciclo**, e alla fine si toglie
/// da solo scoprendo l'immagine che c'era gia'.
class VeloDiRivelazione extends StatefulWidget {
  const VeloDiRivelazione({
    super.key,
    required this.maestro,
    required this.riduciMovimento,
    this.fabbrica = lettoreVero,
  });

  final Maestro maestro;

  /// **CON RIDUCI MOVIMENTO IL LETTORE NON NASCE NEMMENO.** Non nasce e viene
  /// messo in pausa: non nasce affatto, perche' un filmato aperto e fermo
  /// occupa comunque un decodificatore.
  final bool riduciMovimento;

  /// Chi costruisce il lettore. Le prove ne passano uno finto.
  final FabbricaDiLettori fabbrica;

  /// Il lettore vero, quello che usa `video_player` come gia' fa l'intro.
  static LettoreDiRivelazione lettoreVero(String asset) =>
      _LettoreConVideoPlayer(asset);

  @override
  State<VeloDiRivelazione> createState() => _VeloDiRivelazioneState();
}

class _VeloDiRivelazioneState extends State<VeloDiRivelazione>
    with WidgetsBindingObserver {
  LettoreDiRivelazione? _lettore;

  @override
  void initState() {
    super.initState();
    if (widget.riduciMovimento) return;
    WidgetsBinding.instance.addObserver(this);
    // Si apre dopo il primo fotogramma, non dentro initState: cosi' la scena e'
    // gia' a video mentre il filmato si prepara, e chi guarda non aspetta
    // davanti a niente.
    WidgetsBinding.instance.addPostFrameCallback((_) => _apri());
  }

  Future<void> _apri() async {
    if (!mounted) return;
    final lettore =
        widget.fabbrica(RivelazioneInVideo.assetDi(widget.maestro));
    _lettore = lettore;
    lettore.ascolta(_cambiato);
    await lettore.apri();
    if (!mounted) {
      // La schermata se n'e' andata mentre il filmato si preparava: si libera
      // subito, altrimenti resta vivo un decodificatore che nessuno guarda.
      lettore.chiudi();
      _lettore = null;
      return;
    }
    setState(() {});
  }

  void _cambiato() {
    if (!mounted) return;
    setState(() {});
  }

  /// **L'APP CHE PASSA IN SECONDO PIANO CHIUDE IL FILMATO, non lo mette in
  /// pausa.** E' la stessa regola dell'intro, presa dalla ricognizione di questa
  /// voce, e qui il motivo e' anche piu' semplice: sotto il filmato c'e' gia'
  /// l'immagine ferma del Maestro. Una pausa lascerebbe un fotogramma congelato
  /// ad aspettare un ritorno che puo' arrivare mezz'ora dopo, e chi rientra
  /// troverebbe il Maestro bloccato a meta' gesto invece del suo ritratto.
  /// Chiudere non toglie niente a nessuno: scopre cio' che c'era gia'.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) return;
    _lettore?.chiudi();
    _lettore = null;
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // SEMPRE, anche se l'apertura era fallita: chiudere un lettore che non e'
    // partito non costa niente, dimenticarne uno che e' partito costa un
    // decodificatore per ogni apertura della scena.
    _lettore?.chiudi();
    _lettore = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lettore = _lettore;
    // Niente lettore, non pronto, oppure gia' finito: non si disegna niente e
    // resta cio' che c'e' sotto, cioe' l'immagine ferma. **Questo ramo e' la
    // voce BQ.03 per intero**, e non ha bisogno di sapere PERCHE' il filmato
    // non c'e': file assente, codec rifiutato o lettore fallito finiscono tutti
    // qui, senza un messaggio e senza un'attesa.
    if (lettore == null || !lettore.pronto || lettore.finito) {
      return const SizedBox.shrink();
    }
    return lettore.disegna();
  }
}

/// Il lettore vero. Tiene dentro `VideoPlayerController` e non lo lascia
/// uscire: chi usa il velo non sa che esista, e il giorno che il lettore
/// dell'app cambia si tocca solo questa classe.
class _LettoreConVideoPlayer implements LettoreDiRivelazione {
  _LettoreConVideoPlayer(this.asset);

  final String asset;
  VideoPlayerController? _c;
  VoidCallback? _quandoCambia;
  bool _pronto = false;
  bool _finito = false;

  @override
  bool get pronto => _pronto;

  @override
  bool get finito => _finito;

  @override
  void ascolta(VoidCallback quandoCambia) => _quandoCambia = quandoCambia;

  @override
  Future<void> apri() async {
    final c = VideoPlayerController.asset(asset);
    _c = c;
    try {
      await c.initialize();
      // Muto sempre: la rivelazione ha gia' il suo suono, e due audio insieme
      // sono rumore. Il volume si mette PRIMA della riproduzione, come
      // nell'intro: un decimo di secondo di audio prima del muto e' comunque
      // un suono che nessuno aveva chiesto.
      await c.setVolume(0);
      await c.setLooping(false);
      c.addListener(_guarda);
      await c.play();
      _pronto = true;
      _quandoCambia?.call();
    } catch (errore) {
      // **PERCHE' QUESTO ERRORE SI IGNORA, ed e' l'unico posto dell'app dove si
      // puo' fare.** Qui dentro finiscono tre cose che vogliono tutte la stessa
      // risposta: il file non c'e', il codec e' rifiutato, oppure non c'e'
      // nessuna piattaforma che decodifichi (una prova headless, per dirne
      // una). In tutti e tre i casi la scena ha gia' il ritratto del Maestro
      // sotto il velo, quindi non c'e' niente da salvare e niente da dire a
      // nessuno: e' la voce BQ.03, la promessa mantenuta. Rilanciare
      // trasformerebbe un filmato che manca in una schermata che si rompe.
      //
      // L'errore NON viene buttato: chi apre la console lo trova.
      debugPrint('Il video di rivelazione non parte, resta il ritratto: '
          '$asset, $errore');
      _pronto = false;
    }
  }

  void _guarda() {
    final c = _c;
    if (c == null || _finito) return;
    final v = c.value;
    if (v.isInitialized && !v.isPlaying && v.position >= v.duration) {
      _finito = true;
      _quandoCambia?.call();
    }
  }

  @override
  Widget disegna() {
    final c = _c;
    if (c == null) return const SizedBox.shrink();
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: c.value.size.width,
        height: c.value.size.height,
        child: VideoPlayer(c),
      ),
    );
  }

  @override
  void chiudi() {
    _c?.removeListener(_guarda);
    _c?.pause();
    _c?.dispose();
    _c = null;
    _quandoCambia = null;
  }
}
