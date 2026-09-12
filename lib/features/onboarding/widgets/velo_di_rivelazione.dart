import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';

import '../../../core/maestro/maestro.dart';
import '../../../core/maestro/rivelazione_in_video.dart';
import 'maestro_card.dart';
import '../../../core/sensi/regia_della_musica.dart';
import 'dart:async';

/// IL VELO DI RIVELAZIONE: il video del Maestro, a schermo pieno, sotto a tutta
/// la schermata. Ordine BQ voci 2 e 3, ordine BR voci 1 e 2.
///
/// **NON E' PIU' UN INQUILINO DELLA CARTA, E' LO SFONDO DELLA SCHERMATA.**
/// L'ordine BQ lo aveva messo dentro la cornice, al posto del ritratto: era
/// esattamente cio' che l'ordine chiedeva, e cio' che l'ordine chiedeva era
/// sbagliato. Parole del fondatore: "il video eravamo d'accordo che sarebbe
/// stata full screen come sfondo", e "il video va sotto come sfondo e sopra ci
/// metti i testi, info ecc.". Quindi il velo riempie tutto, si fa tagliare ai
/// lati invece di lasciare due bande, e chi lo monta gli disegna sopra il testo
/// e il piede.
///
/// **IL RITRATTO FERMO STA SEMPRE SOTTO AL FILMATO, ed e' la regola dell'ordine
/// BQ che nessun ordine successivo tocca.** Un widget che scambiasse l'immagine
/// col video avrebbe tre modi di lasciare la scena vuota: mentre il filmato si
/// prepara, se il file non c'e', e nel fotogramma fra l'ultimo quadro e il
/// ritorno all'immagine. Qui invece, ogni volta che c'e' un filmato da
/// disegnare, sotto di lui c'e' gia' il Maestro: se la texture si svuotasse
/// nessuno vedrebbe un rettangolo nero, vedrebbe il ritratto.
///
/// **IL FILMATO SI FERMA SULL'ULTIMO FOTOGRAMMA E CI RESTA**, voce BR.02.
/// Sempre parole del fondatore: "il video si dovrebbe fermare all'ultimo frame
/// in modo che resti come immagine fissa". Non si smonta niente e non si chiude
/// niente quando la riproduzione arriva in fondo: si smette di riprodurre e
/// basta, e cio' che era a video ci rimane finche' la persona non lascia la
/// schermata.
class VeloDiRivelazione extends StatefulWidget {
  const VeloDiRivelazione({
    super.key,
    required this.maestro,
    required this.riduciMovimento,
    this.fabbrica = lettoreVero,
    this.ilVideoCopre,
  });

  final Maestro maestro;

  /// **CON RIDUCI MOVIMENTO IL LETTORE NON NASCE NEMMENO.** Non nasce e viene
  /// messo in pausa: non nasce affatto, perche' un filmato aperto e fermo
  /// occupa comunque un decodificatore.
  final bool riduciMovimento;

  /// Chi costruisce il lettore. Le prove ne passano uno finto.
  final FabbricaDiLettori fabbrica;

  /// **VERO QUANDO IL FILMATO E' A VIDEO**, in riproduzione o fermo sul suo
  /// ultimo fotogramma. Chi monta il velo lo ascolta per togliere di scena la
  /// carta con la cornice: due Maestri uno sopra l'altro sono la promessa
  /// mancata che la voce BR.01 esiste per impedire. Il velo lo scrive e non lo
  /// possiede: chi lo crea lo libera.
  final ValueNotifier<bool>? ilVideoCopre;

  /// Il lettore vero, quello che usa `video_player` come gia' fa l'intro.
  static LettoreDiRivelazione lettoreVero(String asset) =>
      _LettoreConVideoPlayer(asset);

  /// **PERCHE' IL RITRATTO SOTTO AL FILMATO NON E' A SCHERMO PIENO.** Sta alla
  /// stessa altezza a cui la carta lo disegna, e la sceglie
  /// `RitrattoInteroDelMaestro`, che e' la porta unica di quella figura. A
  /// schermo pieno con `cover` verrebbe stirato: sul telefono di riferimento,
  /// 360x797 punti a rapporto 3, sarebbero 2391 pixel fisici contro i 1700
  /// della tela su cui gli avatar sono stati normalizzati, e la prova
  /// `nessuno_disegna_oltre_la_tela` esiste per impedirlo. Sotto al filmato non
  /// si vede comunque mai; il giorno che si vedesse, si vedrebbe il Maestro
  /// alla misura giusta invece di un Maestro sfocato.
  static const double altezzaDelRitratto =
      RitrattoInteroDelMaestro.altezzaNellaCarta;

  @override
  State<VeloDiRivelazione> createState() => _VeloDiRivelazioneState();
}

class _VeloDiRivelazioneState extends State<VeloDiRivelazione>
    with WidgetsBindingObserver {
  LettoreDiRivelazione? _lettore;

  /// Vero quando c'e' un fotogramma da mostrare, che sia in movimento o fermo.
  /// **La fine del filmato NON conta come assenza**: e' la voce BR.02.
  bool get _copre {
    final l = _lettore;
    return l != null && l.pronto;
  }

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
    final lettore = widget.fabbrica(RivelazioneInVideo.assetDi(widget.maestro));
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
    setState(_dichiaraLaCopertura);
  }

  void _cambiato() {
    if (!mounted) return;
    setState(_dichiaraLaCopertura);
  }

  /// **LA CARTA SPARISCE E IL VELO APPARE NELLO STESSO FOTOGRAMMA.** Il segnale
  /// si scrive dentro il `setState` che ridisegna il velo, quindi chi ascolta si
  /// sporca nello stesso giro di costruzione: non esiste un fotogramma con due
  /// Maestri, ne uno con nessuno.
  void _dichiaraLaCopertura() {
    final notaio = widget.ilVideoCopre;
    if (notaio == null) return;
    final adesso = _copre;
    if (notaio.value != adesso) notaio.value = adesso;
  }

  /// **L'APP CHE PASSA IN SECONDO PIANO CHIUDE IL FILMATO, non lo mette in
  /// pausa.** E' la stessa regola dell'intro, presa dalla ricognizione della
  /// voce BQ.02. Una pausa lascerebbe un fotogramma congelato ad aspettare un
  /// ritorno che puo' arrivare mezz'ora dopo.
  ///
  /// **AL RITORNO SI SCOPRE LA CARTA COL RITRATTO FERMO, ed e' un esito
  /// accettabile dichiarato dall'ordine BR**, non un difetto nascosto: il
  /// filmato non riparte da solo, perche' un filmato che ricomincia mentre la
  /// persona sta leggendo il suo primo momento sarebbe peggio del ritratto.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) return;
    _lettore?.chiudi();
    _lettore = null;
    if (mounted) setState(_dichiaraLaCopertura);
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
    // Niente lettore o non pronto: non si disegna niente e resta cio' che c'e'
    // sotto, cioe' la schermata come e' sempre stata, carta compresa. **Questo
    // ramo e' la voce BQ.03 per intero**, e non ha bisogno di sapere PERCHE' il
    // filmato non c'e': file assente, codec rifiutato o lettore fallito
    // finiscono tutti qui, senza un messaggio e senza un'attesa.
    //
    // **La fine del filmato non passa piu' di qui**: prima tornava un
    // `SizedBox.shrink()` anche quando `finito` era vero, e l'ultimo fotogramma
    // spariva. Voce BR.02.
    if (lettore == null || !lettore.pronto) {
      return const SizedBox.shrink();
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        // IL RITRATTO FERMO, SOTTO AL FILMATO E SEMPRE. Non si vede mai finche'
        // il filmato copre, ed e' esattamente il punto: e' la rete che rende
        // impossibile il rettangolo nero, non una scommessa sul fatto che la
        // texture conservi l'ultimo quadro. Sta in basso e alla sua misura,
        // come nella carta: vedi altezzaDelRitratto.
        Align(
          alignment: Alignment.bottomCenter,
          child: RitrattoInteroDelMaestro(
            maestro: widget.maestro,
            altezza: VeloDiRivelazione.altezzaDelRitratto,
          ),
        ),
        lettore.disegna(),
      ],
    );
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
      // **IL VIDEO PARLA, ordine CN del 2 settembre 2026.**
      //
      // Qui c'era `setVolume(0)`, con questa ragione: "la rivelazione
      // ha gia' il suo suono, e due audio insieme sono rumore".
      // **Quella ragione era gia' falsa quando e' stata scritta**: la
      // voce CN.09 ha verificato che sopra questi video non suona
      // niente, la schermata della rivelazione esegue solo la
      // vibrazione. Il muto non proteggeva da nessun secondo audio: **lo
      // toglieva e basta.**
      //
      // Dal 1 settembre i tre video portano la loro traccia, portata
      // alla stessa sonorita' degli effetti. Adesso si sente.
      //
      // **E la musica scende sotto**, come sotto ogni effetto: dieci
      // secondi di voce di un Maestro sopra un tappeto d'ambiente
      // sarebbero due cose che si contendono la stessa attenzione.
      await c.setVolume(1);
      unawaited(RegiaDellaMusica.sola.scendiSottoUnEffetto(c.value.duration));
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
      // una). In tutti e tre i casi la scena ha gia' la carta col ritratto del
      // Maestro, quindi non c'e' niente da salvare e niente da dire a nessuno:
      // e' la voce BQ.03, la promessa mantenuta. Rilanciare trasformerebbe un
      // filmato che manca in una schermata che si rompe.
      //
      // L'errore NON viene buttato: chi apre la console lo trova.
      debugPrint('Il video di rivelazione non parte, resta il ritratto: '
          '$asset, $errore');
      _pronto = false;
    }
  }

  /// **QUANDO IL FILMATO FINISCE NON SI CHIUDE NIENTE.** [finito] diventa vero e
  /// lo dichiara a chi ascolta, ma il lettore resta vivo e la sua vista resta in
  /// albero: e' cosi' che l'ultimo fotogramma resta a video. Misurato nella
  /// ricognizione BR.00: dopo l'evento di fine il lettore non viene liberato, la
  /// vista della piattaforma e' ancora montata e porta lo stesso numero.
  void _guarda() {
    final c = _c;
    if (c == null || _finito) return;
    final v = c.value;
    if (v.isInitialized && !v.isPlaying && v.position >= v.duration) {
      _finito = true;
      _quandoCambia?.call();
    }
  }

  /// **BoxFit.cover E NON contain, ed e' la voce BR.01 in una riga.** Un filmato
  /// 9 a 16 dentro uno schermo piu' alto, con `contain`, lascia due bande: si
  /// vedrebbe il cosmo sopra e sotto il Maestro invece di uno sfondo pieno. Con
  /// `cover` il filmato riempie e si fa tagliare ai lati, che e' cio' che il
  /// fondatore ha chiesto con la parola "full screen".
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
    _c?.removeListener(_guarda);
    _c?.pause();
    _c?.dispose();
    _c = null;
    _quandoCambia = null;
  }
}
