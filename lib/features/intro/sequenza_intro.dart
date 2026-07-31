import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../core/sensi/catalogo_suoni.dart';
import '../../core/sensi/motore_audio.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// L'INTRO DI APERTURA. **PROVVISORIA, per le dimostrazioni.**
///
/// Nasce perche' il fondatore deve mostrare l'app a un professionista esterno, e
/// va sostituita quando arriveranno gli asset definitivi: il video e' un
/// `Intro-Test`, il nome lo dice.
///
/// **La sequenza**: tre secondi di nero con la frase che si scrive lettera per
/// lettera, dissolvenza, il video una volta sola, dissolvenza, il logo che
/// cresce di poco, dissolvenza, e poi si va DOVE SI SAREBBE ANDATI COMUNQUE. Chi
/// ha gia' fatto il Risveglio entra nel Cerchio: l'intro non decide la
/// destinazione, la ritarda soltanto.
///
/// **Si salta con un tocco.** Il professionista aprira' l'app molte volte, e
/// un'intro non saltabile diventa un fastidio dopo la seconda.
///
/// **Riduci Movimento** toglie la macchina da scrivere e la crescita del logo:
/// la frase compare posata e il logo fermo. Le dissolvenze restano, perche' sono
/// transizioni e non movimento.
class SequenzaIntro extends StatefulWidget {
  const SequenzaIntro({
    super.key,
    required this.child,
    this.mostra = true,
  });

  /// Cio' che c'e' sotto: lo shell con la sua destinazione, quale che sia.
  final Widget child;

  /// Falso per le prove e le anteprime che non vogliono l'intro davanti.
  final bool mostra;

  /// La frase del principio.
  static const String frase = 'IN PRINCIPIO ERA IL NULLA';

  /// Quanto dura il nero con la frase, scrittura compresa.
  static const Duration duranteIlNero = Duration(seconds: 3);

  /// LA VOCE che pronuncia la frase, sulla schermata nera.
  static String get voce => SuonoDelCerchio.principio.percorso;

  /// Quanto dura la voce, letta dal file all'avvio.
  ///
  /// **Non scritta a mano**: se un giorno la voce cambia, la scritta la segue da
  /// sola. Il valore qui sotto e' il ripiego per quando la durata non si riesce
  /// a leggere, per esempio in prova headless dove il lettore non c'e'.
  static Duration get voceDiRipiego => SuonoDelCerchio.principio.durataAttesa;

  /// La cadenza di una lettera si CALIBRA SULLA VOCE, non sui tre secondi.
  ///
  /// Le lettere devono finire di scriversi quando la voce finisce di parlare,
  /// non prima e non dopo: la scritta e' quella voce, e vederla correre avanti o
  /// restare indietro rompe l'illusione che sia la stessa cosa.
  static Duration cadenzaPer(Duration voce) => Duration(
      microseconds: (voce.inMicroseconds / frase.length).round());

  /// La dissolvenza fra un momento e l'altro.
  static const Duration dissolvenza = Duration(milliseconds: 500);

  /// Quanto resta il logo prima di sfumare.
  static const Duration duranteIlLogo = Duration(milliseconds: 1800);

  /// Il video, che sta gia' nel repo.
  static const String video = 'brand_assets/intro/Intro-Test-1.mp4';

  /// Il logo esportato leggero, versionato.
  static const String logo = 'assets/brand/logo.png';

  @override
  State<SequenzaIntro> createState() => _SequenzaIntroState();
}

/// I momenti della sequenza, in ordine.
enum MomentoIntro { nero, video, logo, finita }

class _SequenzaIntroState extends State<SequenzaIntro> {
  MomentoIntro _momento = MomentoIntro.nero;
  int _lettere = 0;
  Duration _cadenza = SequenzaIntro.cadenzaPer(SequenzaIntro.voceDiRipiego);
  Timer? _macchina;
  Timer? _passo;
  VideoPlayerController? _video;

  bool get _riduciMovimento => MediaQuery.of(context).disableAnimations;

  @override
  void initState() {
    super.initState();
    if (!widget.mostra) {
      _momento = MomentoIntro.finita;
      return;
    }
    // IN PRESENZA DELL'INTRO LA FIRMA NON SUONA, e il suo posto lo prende la
    // VOCE. E' la seconda delle due strade che l'ordine lascia scegliere, ed e'
    // quella giusta: la firma dura due secondi e la voce 2,43, quindi farle
    // convivere sulla stessa schermata nera vorrebbe dire sfumarne una sotto
    // l'altra in tre secondi scarsi. Due suoni che si contendono lo stesso
    // momento non fanno un'apertura piu' ricca, fanno rumore. La firma resta
    // per le sessioni in cui l'intro non c'e'.
    WidgetsBinding.instance.addPostFrameCallback((_) => _avvia());
  }

  Future<void> _avvia() async {
    if (!mounted) return;
    // La voce parte INSIEME alla comparsa della scritta. Se il suono di sistema
    // e' spento non suona, e i tempi restano identici: la sequenza non dipende
    // dall'audio, lo accompagna.
    final durata = await _suonaLaVoce();
    if (!mounted) return;
    _cadenza = SequenzaIntro.cadenzaPer(durata);
    if (!_riduciMovimento) {
      _macchina = Timer.periodic(_cadenza, (t) {
        if (!mounted) return t.cancel();
        setState(() => _lettere++);
        if (_lettere >= SequenzaIntro.frase.length) t.cancel();
      });
    } else {
      // Posata, non scritta: Riduci Movimento toglie il movimento e non il testo.
      setState(() => _lettere = SequenzaIntro.frase.length);
    }
    _passo = Timer(SequenzaIntro.duranteIlNero, _versoIlVideo);
  }

  Future<void> _versoIlVideo() async {
    if (!mounted) return;
    setState(() => _momento = MomentoIntro.video);
    final c = VideoPlayerController.asset(SequenzaIntro.video);
    _video = c;
    try {
      await c.initialize();
      if (!mounted) return;
      setState(() {});
      await c.play();
      // Quando finisce si passa oltre da soli: nessun comando a schermo.
      c.addListener(_guardaLaFine);
    } catch (_) {
      // Il video non si riproduce, per esempio in prova headless: la sequenza
      // prosegue lo stesso invece di restare bloccata sul nero.
      _versoIlLogo();
    }
  }

  void _guardaLaFine() {
    final c = _video;
    if (c == null || !mounted) return;
    final v = c.value;
    if (v.isInitialized && !v.isPlaying && v.position >= v.duration) {
      c.removeListener(_guardaLaFine);
      _versoIlLogo();
    }
  }

  void _versoIlLogo() {
    if (!mounted || _momento == MomentoIntro.finita) return;
    setState(() => _momento = MomentoIntro.logo);
    _passo?.cancel();
    _passo = Timer(SequenzaIntro.duranteIlLogo, _finisci);
  }

  /// Suona la voce e dice quanto dura.
  ///
  /// La durata si prende dal FILE e non da una costante: se un giorno la voce
  /// cambia, la scritta la segue da sola. Quando non si riesce a leggerla, per
  /// esempio in prova dove il lettore non c'e', si usa il ripiego dichiarato.
  Future<Duration> _suonaLaVoce() async {
    try {
      // UN TEMPO MASSIMO BREVE, e non e' una cautela di comodo: un lettore che
      // non risponde bloccherebbe l'intera apertura dell'app, che e' un prezzo
      // fuori misura per sapere quanto dura un suono. Scaduto, si usa il
      // ripiego dichiarato e la sequenza parte comunque.
      final letta = await MotoreAudio.condiviso
          .effetto(SequenzaIntro.voce)
          .timeout(const Duration(milliseconds: 250), onTimeout: () => null);
      if (letta != null && letta > Duration.zero) return letta;
    } catch (_) {
      // Suono spento o non disponibile: la sequenza resta identica nei tempi.
    }
    return SequenzaIntro.voceDiRipiego;
  }

  /// Salta tutto e va alla destinazione. Un tocco qualunque.
  void _salta() {
    if (_momento == MomentoIntro.finita) return;
    _finisci();
  }

  void _finisci() {
    _macchina?.cancel();
    _passo?.cancel();
    // IL TOCCO FERMA ANCHE LA VOCE, subito: una voce che continua a parlare
    // sopra la schermata gia' aperta e' peggio dell'intro che si voleva saltare.
    MotoreAudio.condiviso.fermaTutto();
    _video?.pause();
    if (mounted) setState(() => _momento = MomentoIntro.finita);
  }

  @override
  void dispose() {
    _macchina?.cancel();
    _passo?.cancel();
    _video?.removeListener(_guardaLaFine);
    _video?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // LA DESTINAZIONE STA SEMPRE SOTTO, gia' costruita: l'intro non decide dove
    // si va, ritarda solo il momento in cui si vede. Chi ha gia' fatto il
    // Risveglio entra nel Cerchio, chi non l'ha fatto lo trova ad aspettarlo.
    return Stack(
      children: [
        widget.child,
        if (_momento != MomentoIntro.finita)
          Positioned.fill(
            child: GestureDetector(
              key: const Key('intro_salta'),
              behavior: HitTestBehavior.opaque,
              onTap: _salta,
              child: AnimatedSwitcher(
                duration: SequenzaIntro.dissolvenza,
                child: _momentoCorrente(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _momentoCorrente() {
    switch (_momento) {
      case MomentoIntro.nero:
        return _Nero(
          key: const ValueKey('intro_nero'),
          scritte: SequenzaIntro.frase.substring(
              0, _lettere.clamp(0, SequenzaIntro.frase.length)),
        );
      case MomentoIntro.video:
        return _Video(key: const ValueKey('intro_video'), controller: _video);
      case MomentoIntro.logo:
        return _Logo(
          key: const ValueKey('intro_logo'),
          cresce: !_riduciMovimento,
        );
      case MomentoIntro.finita:
        return const SizedBox.shrink(key: ValueKey('intro_niente'));
    }
  }
}

/// Il nero con la frase che si scrive.
class _Nero extends StatelessWidget {
  const _Nero({super.key, required this.scritte});

  final String scritte;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                scritte,
                key: const Key('intro_frase'),
                textAlign: TextAlign.center,
                style: TypographyTokens.display(size: 22).copyWith(
                  // Oro tenue su nero pieno.
                  color: const Color(0xFFD9B65C),
                  letterSpacing: 3,
                  height: 1.5,
                  // Dichiarata: senza, fuori da un Material il testo eredita la
                  // sottolineatura di sistema, e su una schermata d'apertura si
                  // vede.
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
          const _InvitoASaltare(),
        ],
      ),
    );
  }
}

/// Il video, a tutto schermo e senza tagliare il soggetto.
class _Video extends StatelessWidget {
  const _Video({super.key, required this.controller});

  final VideoPlayerController? controller;

  @override
  Widget build(BuildContext context) {
    final c = controller;
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

/// Il logo, che cresce di poco.
class _Logo extends StatefulWidget {
  const _Logo({super.key, required this.cresce});

  final bool cresce;

  @override
  State<_Logo> createState() => _LogoState();
}

class _LogoState extends State<_Logo> {
  double _scala = 1.0;

  @override
  void initState() {
    super.initState();
    if (!widget.cresce) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _scala = 1.08);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Stack(
        children: [
          Center(
            child: AnimatedScale(
              // Una crescita lenta e piccola, non un ingrandimento vistoso.
              scale: _scala,
              duration: const Duration(milliseconds: 1600),
              curve: Curves.easeOutCubic,
              child: Image.asset(
                SequenzaIntro.logo,
                key: const Key('intro_logo_immagine'),
                width: 220,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
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
          style: TypographyTokens.label(size: 11).copyWith(
            color: ColorTokens.textSecondary.withValues(alpha: 0.6),
            letterSpacing: 2,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
