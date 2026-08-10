import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../core/diagnosi/briciole.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// L'INTRO DI APERTURA: **il video, e nient'altro.**
///
/// **Cosa e' cambiato, e perche'.** Prima qui c'era una sequenza in tre momenti
/// costruita in codice attorno a un video di prova: tre secondi di nero con la
/// frase "IN PRINCIPIO ERA IL NULLA" scritta lettera per lettera su una voce
/// registrata, poi il video, poi il logo che cresceva. Serviva perche' il video
/// di allora era un frammento senza apertura e senza chiusura, e il codice
/// gliele metteva intorno.
///
/// Il video nuovo **le contiene gia' tutte e due**: si apre sul nero con la
/// scritta e si chiude sul marchio. Tenere anche la versione in codice avrebbe
/// voluto dire mostrare la stessa frase due volte e il logo due volte. Il nero,
/// la frase, la voce e il logo se ne vanno da qui perche' hanno cambiato posto,
/// non perche' siano stati tolti: adesso stanno dentro l'immagine.
///
/// **Resta cio' che il video non puo' fare da solo**: il tocco che salta, la
/// dissolvenza che consegna la schermata sotto senza uno stacco, il rispetto del
/// silenzio e di Riduci Movimento, e la garanzia che nessun fotogramma resti
/// congelato se qualcosa va storto.
///
/// **La destinazione sta sempre sotto, gia' costruita**: l'intro non decide dove
/// si va, ritarda soltanto il momento in cui si vede. Chi ha gia' fatto il
/// Risveglio entra nel Cerchio, chi non l'ha fatto lo trova ad aspettarlo.
class SequenzaIntro extends StatefulWidget {
  const SequenzaIntro({
    super.key,
    required this.child,
    this.mostra = true,
    this.conSuono = true,
  });

  /// Cio' che c'e' sotto: lo shell con la sua destinazione, quale che sia.
  final Widget child;

  /// Falso per le prove e le anteprime che non vogliono l'intro davanti.
  final bool mostra;

  /// IL SILENZIO DELL'APP, non quello del sistema operativo.
  ///
  /// E' lo stesso interruttore unico che governa suono e vibrazione in
  /// Impostazioni: chi lo spegne ha detto che da questa app non vuole sentire
  /// niente, e un'apertura che parla lo stesso sarebbe la prima cosa a
  /// contraddire la sua scelta. A silenzio acceso il video si vede e non si
  /// sente.
  ///
  /// **Il limite, dichiarato.** L'interruttore fisico del silenzioso su iPhone
  /// e' un'altra cosa, e non passa di qui: il lettore video apre la sessione
  /// audio nella categoria della riproduzione, che per progetto di sistema
  /// ignora quell'interruttore, ed esporre la categoria vorrebbe dire mettere
  /// le mani nel codice nativo del pacchetto. Chi vuole l'apertura muta la
  /// spegne da Impostazioni.
  final bool conSuono;

  /// Il video, convertito e versionato.
  ///
  /// Il sorgente stava a dodici megabit e mezzo al secondo, ventidue megabyte
  /// per quattordici secondi. Qui e' lo STESSO video, 1080 per 1920 a
  /// ventiquattro fotogrammi, ricodificato a qualita' costante, con l'audio
  /// ORIGINALE copiato e non ricodificato: una seconda codifica dell'audio
  /// sarebbe stata perdita in cambio di niente.
  ///
  /// **Il terzo, non il secondo.** Il video e' stato rifatto da Mauro con una
  /// voce nuova, e anche le immagini sono cambiate: la somiglianza fra i due
  /// sorgenti e' 0,939, quindi non era un ritocco all'audio. La conversione
  /// riparte OGNI VOLTA DAL SORGENTE e mai dal convertito precedente, perche'
  /// una seconda compressione sopra la prima degrada senza dichiararlo. Del
  /// video di prima non resta niente nel pacchetto: due video introduttivi
  /// sono peso morto e sono la porta sbagliata da cui qualcuno ripartirebbe.
  static const String video = 'brand_assets/intro/Intro-Test-3.mp4';

  /// La dissolvenza in uscita, che consegna la schermata sotto senza stacco.
  static const Duration dissolvenza = Duration(milliseconds: 500);

  /// LA SCORTA OLTRE LA FINE del video, prima di andare avanti comunque.
  ///
  /// Un lettore puo' fermarsi senza dichiararsi finito, e in quel caso senza
  /// questa scorta l'apertura resterebbe su un fotogramma immobile finche'
  /// qualcuno non tocca lo schermo. L'intro deve poter finire da sola anche
  /// quando il video non collabora.
  static const Duration scorta = Duration(seconds: 2);

  @override
  State<SequenzaIntro> createState() => _SequenzaIntroState();
}

/// I momenti della sequenza. Ne restano due: il video, e la fine.
enum MomentoIntro { video, finita }

class _SequenzaIntroState extends State<SequenzaIntro>
    with WidgetsBindingObserver {
  MomentoIntro _momento = MomentoIntro.video;

  /// Vero finche' l'intro si vede. Passa a falso PRIMA di `finita`, perche' fra
  /// i due c'e' la dissolvenza: se si smontasse subito, l'uscita sarebbe un
  /// taglio secco invece di una consegna.
  bool _visibile = true;

  Timer? _scorta;
  Timer? _uscita;
  VideoPlayerController? _video;

  /// RIDUCI MOVIMENTO NON MOSTRA L'INTRO AFFATTO.
  ///
  /// Prima questa impostazione toglieva la macchina da scrivere e la crescita
  /// del logo, cioe' il movimento che il codice aggiungeva attorno al video.
  /// Adesso il codice non aggiunge piu' niente: resta il video, e un cosmo che
  /// si attraversa a tutto schermo per quattordici secondi **e'** il movimento
  /// che quell'impostazione chiede di togliere. Non c'e' una versione posata da
  /// mostrare al suo posto, e inventarla sarebbe peggio. L'intro ritarda e non
  /// devia, quindi chi non la vede non perde niente: arriva solo prima.
  bool get _riduciMovimento => MediaQuery.of(context).disableAnimations;

  @override
  void initState() {
    super.initState();
    if (!widget.mostra) {
      _momento = MomentoIntro.finita;
      _visibile = false;
      return;
    }
    WidgetsBinding.instance.addObserver(this);
    Briciole.lascia('intro_montata');
    WidgetsBinding.instance.addPostFrameCallback((_) => _avvia());
  }

  /// L'APP CHE PASSA IN SECONDO PIANO CHIUDE L'INTRO.
  ///
  /// Non la mette in pausa: la chiude. Una pausa lascerebbe un fotogramma
  /// congelato ad aspettare un ritorno che potrebbe arrivare mezz'ora dopo, e
  /// chi rientra si troverebbe davanti un'apertura gia' vista, ferma. E' la
  /// stessa regola della guardia del suono, che a un ritorno non fa mai
  /// ripartire da solo cio' che stava suonando.
  ///
  /// **Cio' che si vede solo qui.** Mentre l'app sta dietro, il sistema non
  /// disegna: la dissolvenza non scorre e lo smontaggio si compie al ritorno,
  /// dal primo fotogramma utile. E' giusto cosi', ma vuol dire che fra l'uscita
  /// e il rientro il lettore resta in piedi, e IL LETTORE HA UN OSSERVATORE
  /// SUO che al ritorno fa ripartire da solo cio' che aveva messo in pausa.
  /// Senza il muto qui sotto si sentirebbe l'audio dell'apertura sotto la
  /// schermata gia' aperta, per il fotogramma che serve a smontarla.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _finisci();
  }

  Future<void> _avvia() async {
    if (!mounted) return;
    if (_riduciMovimento) return _finisci();

    final c = VideoPlayerController.asset(SequenzaIntro.video);
    _video = c;
    try {
      await c.initialize();
      if (!mounted) return;
      // Il silenzio si applica PRIMA della riproduzione: un decimo di secondo
      // di audio prima del muto e' comunque un suono che non era stato chiesto.
      await c.setVolume(widget.conSuono ? 1 : 0);
      setState(() {});
      await c.play();
      // Quando finisce si passa oltre da soli: nessun comando a schermo.
      c.addListener(_guardaLaFine);
      _scorta = Timer(c.value.duration + SequenzaIntro.scorta, _finisci);
    } catch (_) {
      // Il video non parte, per esempio in prova headless dove non c'e' una
      // piattaforma che lo decodifichi: si va alla destinazione invece di
      // restare sul nero. Un'apertura che non si vede costa meno di un'app che
      // non si apre.
      _finisci();
    }
  }

  void _guardaLaFine() {
    final c = _video;
    if (c == null || !mounted) return;
    final v = c.value;
    if (v.isInitialized && !v.isPlaying && v.position >= v.duration) {
      c.removeListener(_guardaLaFine);
      _finisci();
    }
  }

  /// Salta tutto e va alla destinazione. Un tocco qualunque.
  void _salta() => _finisci();

  void _finisci() {
    if (!_visibile) return;
    _scorta?.cancel();
    _video?.pause();
    // E MUTO, non solo fermo. Fermare basta finche' e' questo codice a
    // decidere, ma l'osservatore del lettore puo' farlo ripartire per conto
    // suo al ritorno dell'app: il muto vale comunque, senza dipendere
    // dall'ordine in cui i due osservatori vengono chiamati.
    _video?.setVolume(0);
    if (!mounted) return;
    // Prima si sfuma, e solo alla fine della sfumatura si smonta. Fra i due
    // passi lo schermo mostra il video che si dirada su cio' che c'e' sotto:
    // NESSUN COLORE INTERMEDIO, quindi nessun lampo.
    setState(() => _visibile = false);
    _uscita = Timer(SequenzaIntro.dissolvenza, () {
      Briciole.lascia('intro_conclusa');
      if (mounted) setState(() => _momento = MomentoIntro.finita);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scorta?.cancel();
    _uscita?.cancel();
    _video?.removeListener(_guardaLaFine);
    _video?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_momento != MomentoIntro.finita)
          Positioned.fill(
            // Durante la dissolvenza l'intro non intercetta piu' i tocchi: chi
            // ha appena toccato per saltarla sta gia' guardando cio' che c'e'
            // sotto, e mezzo secondo di schermo sordo si sente.
            child: IgnorePointer(
              ignoring: !_visibile,
              child: AnimatedOpacity(
                opacity: _visibile ? 1 : 0,
                duration: SequenzaIntro.dissolvenza,
                child: GestureDetector(
                  key: const Key('intro_salta'),
                  behavior: HitTestBehavior.opaque,
                  onTap: _salta,
                  child: _IlVideo(controller: _video),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Il video, a tutto schermo e senza tagliare il soggetto.
class _IlVideo extends StatelessWidget {
  const _IlVideo({required this.controller});

  final VideoPlayerController? controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
    // IL NERO STA SOTTO DA SUBITO, prima ancora che il video sia pronto: e' il
    // colore su cui il video stesso si apre, quindi l'attesa non si distingue
    // dall'inizio. Un fondo chiaro qui sarebbe il lampo bianco all'avvio.
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        children: [
          if (c != null && c.value.isInitialized)
            Center(
              // `contain` e non `cover`: la proporzione si rispetta e il
              // soggetto non si taglia, che e' la stessa regola delle
              // miniature.
              child: AspectRatio(
                aspectRatio: c.value.aspectRatio,
                child: VideoPlayer(c),
              ),
            ),
          const _InvitoASaltare(),
        ],
      ),
    );
  }
}

/// L'invito a saltare: discreto e piccolo, in basso. Nessun pulsante vistoso.
class _InvitoASaltare extends StatelessWidget {
  const _InvitoASaltare();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 44),
        child: Text(
          'Tocca per entrare',
          style: TypographyTokens.etichetta().copyWith(
            color: ColorTokens.textSecondary.withValues(alpha: 0.6),
            letterSpacing: 2,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
