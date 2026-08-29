import 'dart:async';

import 'package:flutter/material.dart';

import '../../design_system/tokens/typography_tokens.dart';
import 'package:provider/provider.dart';

import '../sigilli/regia_del_cammino.dart';

import '../../core/diagnosi/briciole.dart';
import '../../core/astro/birth_details.dart';
import '../../core/astro/natal_chart_controller.dart';
import '../../core/angels/guardian_angels.dart';
import '../../core/astro/night_sky.dart';
import '../../core/astro/resonance.dart';
import '../../core/rituals/guide_animal_derivation.dart';
import '../../core/astro/zodiac_controller.dart';
import '../../core/identity/natal_identity.dart';
import '../../core/maestro/maestro.dart';
import '../../core/maestro/maestro_controller.dart';
import '../../core/onboarding/onboarding_controller.dart';
import '../../design_system/components/immersive_scaffold.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../santuario/sky_overview_screen.dart';
import 'custodia_del_cielo_step.dart';
import 'maestro_reveal_screen.dart';
import 'natal_chart_reveal.dart';
import 'resonance_screen.dart';
import 'trionfi_screen.dart';
import 'primo_approdo.dart';

/// La coda del Risveglio, dal sigillo in poi: il cielo reale di nascita, la
/// carta natale ornata, la risonanza coi Maestri e la rivelazione col soffio.
///
/// Riusa esattamente le schermate validate della Carta Natale. Il ponte
/// d'identita' e' a monte: il rito raccoglie i dati e li porta qui gia' come
/// [BirthDetails], alimentando NatalChartController e BirthIdentityController.
/// Una sola fonte, niente doppioni. Il Maestro si sceglie solo alla risonanza:
/// fino a li' il cosmo resta neutro.
class RisveglioJourney extends StatefulWidget {
  const RisveglioJourney({super.key, required this.details});

  final BirthDetails details;

  static Route<void> route({required BirthDetails details}) {
    // Porta il MaestroScope con se': il cosmo profondo e le schermate natali lo
    // leggono per la palette (neutra finche' non si sceglie il Maestro).
    return MaterialPageRoute<void>(
      builder: (_) => MaestroScope(child: RisveglioJourney(details: details)),
    );
  }

  @override
  State<RisveglioJourney> createState() => _RisveglioJourneyState();
}

/// Le tappe della coda del Risveglio, nell'ordine in cui si attraversano.
///
/// I due trionfi vengono PRIMI, subito dopo il numero della vita che chiude
/// l'onboarding. Prima il Risveglio partiva dal cielo di nascita, quindi fra il
/// numero e i suoi trionfi si infilava un'altra schermata.
///
/// Restano comunque PRIMA della carta natale, come erano: messi dopo
/// rivelerebbero una cosa gia' vista, perche' la carta contiene la tessera del
/// lupo e quella dei tre angeli, quindi chi arrivasse al trionfo li avrebbe
/// gia' incontrati come voci di un elenco. Un trionfo che svela il noto non e'
/// un trionfo.
///
/// L'ordine e' quello di un racconto: prima i compagni uno per uno, poi il
/// cielo in cui sono nati, poi il ritratto d'insieme che li raccoglie, infine
/// la guida.
/// L'ULTIMA TAPPA E' LA CUSTODIA, ordine N voce 1b: la richiesta di non
/// perdere il proprio cielo arriva DOPO la rivelazione del Maestro, cioe'
/// quando c'e' davvero qualcosa da perdere. Chi rimanda entra lo stesso.
enum _Phase { animale, angeli, heaven, chart, resonance, reveal, custodia }

class _RisveglioJourneyState extends State<RisveglioJourney> {
  _Phase _phase = _Phase.animale;
  Maestro _assigned = Maestro.medora;
  Resonance? _resonance;

  /// SOLO PER LA BUILD DIAGNOSTICA (kDiagnosiAttiva): l'ingresso incriminato
  /// entra un pezzo alla volta, con una briciola e un'etichetta a schermo per
  /// pezzo, circa tre secondi l'uno. E' qui che la 2159 muore senza dire
  /// niente: cosi' il pezzo che uccide resta scritto come ultima briciola.
  /// Temporaneo e dichiarato, debito annotato in STATO_VIVO.
  int _tappaDiagnosi = 0;
  Timer? _passiDiagnosi;

  static const List<String> _briciole = [
    'risveglio_a_impalcatura_vuota',
    'risveglio_b_cosmo',
    'risveglio_c_testi_trionfo',
    'risveglio_d_immagine_totem',
    'risveglio_e_nebbia_completa',
    'risveglio_f_compute_chart',
  ];

  @override
  void initState() {
    super.initState();
    if (kDiagnosiAttiva) {
      // FINO ALLA TAPPA f _computeChart NON DEVE PARTIRE: la callable con
      // App Check e' uno dei sospettati, e va isolata come gli altri.
      Briciole.lascia(_briciole[0]);
      _passiDiagnosi =
          Timer.periodic(const Duration(seconds: 3), (timer) {
        if (!mounted || _tappaDiagnosi >= 5) {
          timer.cancel();
          return;
        }
        setState(() => _tappaDiagnosi++);
        Briciole.lascia(_briciole[_tappaDiagnosi]);
        if (_tappaDiagnosi == 5) {
          timer.cancel();
          _computeChart();
        }
      });
      return;
    }
    // La carta si calcola mentre la persona contempla il cielo reale: e' pronta
    // quando prosegue. Ripiego sul cielo essenziale se l'API non risponde.
    WidgetsBinding.instance.addPostFrameCallback((_) => _computeChart());
  }

  @override
  void dispose() {
    _passiDiagnosi?.cancel();
    super.dispose();
  }

  Future<void> _computeChart() async {
    final chartCtrl = context.read<NatalChartController>();
    await chartCtrl.compute(widget.details);
    if (!mounted) return;
    final chart = chartCtrl.chart;
    // I fatti identitari (fase lunare, numero della vita) dietro il modello
    // riusabile, cosi' carta e profilo leggono la stessa fonte.
    context.read<BirthIdentityController>().setBirth(widget.details, chart);
    if (chart != null) {
      setState(() {
        _resonance = computeResonance(chart);
        _assigned = _resonance!.winner;
      });
    }
  }

  void _onAnimaleContinue() => setState(() => _phase = _Phase.angeli);

  void _onAngeliContinue() => setState(() => _phase = _Phase.heaven);

  void _onHeavenContinue() => setState(() => _phase = _Phase.chart);

  void _onChartContinue() => setState(() => _phase = _Phase.resonance);

  void _onResonanceContinue() {
    // Entrando nel rito, il colore del Maestro sboccia nel cosmo: qui, non prima.
    context.read<MaestroController>().selectMaestro(_assigned);
    setState(() => _phase = _Phase.reveal);
  }

  void _onRevealed(Maestro maestro) {
    context.read<MaestroController>().selectMaestro(maestro);
    final sun = context.read<NatalChartController>().sunSign;
    if (sun != null) context.read<ZodiacController>().setSunSign(sun);
    _assigned = maestro;
    // NON si chiude ancora: resta la custodia del cielo, che e' l'ultimo
    // passo. Chiudere qui vorrebbe dire chiedere l'account dopo, a freddo,
    // ed e' esattamente cio' che l'ordine N vieta.
    setState(() => _phase = _Phase.custodia);
  }

  /// La fine vera del Risveglio, custodito o rimandato che sia.
  void _chiudiIlRisveglio() {
    // **LA CARTA E' NATA, ed e' L'UNICA festa della fine dell'onboarding.**
    // Ordine BD voce 05. Il corpus di med_1 dice "la carta natale viene
    // calcolata per la prima volta", e la prima volta e' QUESTA: il gesto si
    // segna qui, la coda delle feste lo celebra all'arrivo nel Santuario.
    // Gli altri gradini dell'identita' non maturano piu' in blocco: ognuno
    // ha la sua porta, il saluto per nome, la carta aperta, il portale del
    // cielo, il Sigillo del Cerchio.
    if (context.read<NatalChartController>().chart != null) {
      unawaited(RegiaDelCammino.dopoUnGesto(context, 'carta_natale'));
    }
    context.read<OnboardingController>().complete();
    // **QUI SI ARMA IL PRIMO APPRODO. Ordine CB voce 02.** Il fondatore lo
    // vuole "solo appena l'utente approda per la prima volta nella Home il
    // cerchio", e questo e' l'istante: il Risveglio e' finito, la prossima
    // cosa che si vede e' il Cerchio.
    //
    // **Sta nel RITO e non dentro `complete()`, e la ragione e' misurata.**
    // Messo dentro il controller, si armava anche per le prove che chiamano
    // `complete()` per portarsi nello stato "dentro il Cerchio": tredici
    // prove hanno smesso di funzionare in un colpo, perche' il velo del
    // tutorial si prendeva i tocchi destinati alla scena. `complete()` dice
    // che il rito e' fatto; arrivare nel Cerchio per la prima volta e' una
    // cosa che succede QUI, e solo qui.
    unawaited(MemoriaDelPrimoApprodo.arma());
    // pop e non maybePop: maybePop passa dal PopScope qui sotto, che rifiuta
    // sempre. Questa e' l'uscita legittima, la sola, e deve poter uscire.
    Navigator.of(context).pop();
  }

  /// Il gesto Indietro retrocede di una fase, come fara' la freccia.
  void _indietroDiFase() {
    final i = _phase.index;
    if (i > 0) setState(() => _phase = _Phase.values[i - 1]);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Il Risveglio e' la porta gemella dell'onboarding, e va chiusa allo
      // stesso modo. Il Maestro si assegna alla rivelazione, cioe' all'ultima
      // fase: uscire prima significava entrare nel Cerchio senza Maestro, per
      // di piu' senza che l'onboarding tornasse a proporsi, dato che il
      // lanciatore lo aveva gia' considerato gestito.
      //
      // Come nell'onboarding, il gesto retrocede invece di buttare fuori, e
      // dalla prima fase non fa nulla.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _indietroDiFase();
      },
      child: _corpo(),
    );
  }

  Widget _corpo() {
    // L'INGRESSO A TAPPE della diagnosi, solo sulla fase incriminata.
    if (kDiagnosiAttiva && _phase == _Phase.animale) {
      const etichette = [
        'A. IMPALCATURA VUOTA',
        'B. COSMO',
        'C. TESTI DEL TRIONFO',
        'D. IMMAGINE DEL TOTEM',
        'E. NEBBIA COMPLETA',
        'F. CARTA IN CALCOLO',
      ];
      final Widget contenuto;
      if (_tappaDiagnosi == 0) {
        // a. la rotta con un'impalcatura VUOTA: niente cosmo, niente scena.
        contenuto = Container(color: const Color(0xFF05060A));
      } else if (_tappaDiagnosi == 1) {
        // b. entra ImmersiveScaffold col cosmo, ancora senza scena.
        contenuto = const ImmersiveScaffold(
            seed: 14, child: SizedBox.expand());
      } else {
        // c/d/e/f: entra il trionfo, coi pezzi che si aggiungono.
        contenuto = ImmersiveScaffold(
          seed: 14,
          child: TrionfoAnimale(
            key: const ValueKey('animale'),
            animale: GuideAnimalDerivation.forSign(
                NightSky.sunSign(widget.details.dateTime)),
            palette: context.palette,
            reduceMotion: MediaQuery.of(context).disableAnimations,
            onContinue: _onAnimaleContinue,
            mostraImmagine: _tappaDiagnosi >= 3,
            mostraNebbia: _tappaDiagnosi >= 4,
          ),
        );
      }
      return Stack(
        children: [
          Positioned.fill(child: contenuto),
          // L'ETICHETTA GRANDE: Mauro vede a occhio quale pezzo era a
          // schermo quando l'app e' scomparsa.
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xCC05060A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFC9A961)),
                  ),
                  child: Text(
                    etichette[_tappaDiagnosi],
                    style: TypographyTokens.titoloSezione(weight: 700)
                        .copyWith(
                            color: const Color(0xFFC9A961),
                            letterSpacing: 1.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
    return ImmersiveScaffold(
      seed: 14,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        child: _buildPhase(),
      ),
    );
  }

  Widget _buildPhase() {
    switch (_phase) {
      case _Phase.heaven:
        // Il cielo alla nascita e' la STESSA schermata del cielo in tempo
        // reale, alimentata col momento della nascita: costellazioni e Luna
        // toccabili con la scheda che racconta cosa hai toccato, parallasse
        // dal motore unico. Prima qui viveva un eroe suo, con un painter
        // gemello e la culla di luce che nessuno leggeva come culla.
        return SkyOverviewScreen(
          key: const ValueKey('heaven'),
          now: widget.details.dateTime,
          birth: true,
          // Il cielo non e' piu' la prima fase: da qui un indietro esiste,
          // quindi la freccia si mostra. La sua freccia fa maybePop, che passa
          // dal PopScope qui sopra e retrocede di fase: non serve un
          // richiamo dedicato, il gesto e la freccia sono la stessa cosa.
          showBack: true,
          ctaLabel: 'Leggi la tua carta',
          onCta: _onHeavenContinue,
          // Data, ora e luogo sono appena stati inseriti a mano: la bolla non
          // deve dare dell'esempio proprio a chi ha appena compilato. Il
          // profilo qui direbbe di no, perche' viene scritto piu' avanti.
          nascitaRegistrata: widget.details.place != null,
        );
      case _Phase.chart:
        return NatalChartReveal(
          key: const ValueKey('chart'),
          onContinue: _onChartContinue,
        );
      case _Phase.animale:
        return TrionfoAnimale(
          key: const ValueKey('animale'),
          animale: GuideAnimalDerivation.forSign(
              NightSky.sunSign(widget.details.dateTime)),
          palette: context.palette,
          reduceMotion: MediaQuery.of(context).disableAnimations,
          onContinue: _onAnimaleContinue,
          // Nessuna freccia: e' il primo, quindi un indietro non esiste e non
          // si mostra un comando che non fa nulla.
        );
      case _Phase.angeli:
        return TrionfoAngeli(
          key: const ValueKey('angeli'),
          triade: GuardianAngels.forBirth(widget.details),
          palette: context.palette,
          reduceMotion: MediaQuery.of(context).disableAnimations,
          onContinue: _onAngeliContinue,
          onBack: _indietroDiFase,
        );
      case _Phase.resonance:
        return _resonance == null
            ? const SizedBox.shrink()
            : ResonanceScreen(
                key: const ValueKey('resonance'),
                resonance: _resonance!,
                onContinue: _onResonanceContinue,
              );
      case _Phase.reveal:
        return MaestroRevealScreen(
          key: const ValueKey('reveal'),
          maestro: _assigned,
          onRevealed: _onRevealed,
        );
      case _Phase.custodia:
        return CustodiaDelCieloStep(
          key: const ValueKey('custodia'),
          maestro: _assigned,
          suFine: _chiudiIlRisveglio,
        );
    }
  }
}
