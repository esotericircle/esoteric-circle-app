import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
import 'maestro_reveal_screen.dart';
import 'natal_chart_reveal.dart';
import 'resonance_screen.dart';
import 'trionfi_screen.dart';

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
enum _Phase { animale, angeli, heaven, chart, resonance, reveal }

class _RisveglioJourneyState extends State<RisveglioJourney> {
  _Phase _phase = _Phase.animale;
  Maestro _assigned = Maestro.medora;
  Resonance? _resonance;

  @override
  void initState() {
    super.initState();
    // La carta si calcola mentre la persona contempla il cielo reale: e' pronta
    // quando prosegue. Ripiego sul cielo essenziale se l'API non risponde.
    WidgetsBinding.instance.addPostFrameCallback((_) => _computeChart());
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
    // Chiude il Risveglio ed entra nel Cerchio (il Santuario resta la home).
    context.read<OnboardingController>().complete();
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
      child: ImmersiveScaffold(
        seed: 14,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 450),
          child: _buildPhase(),
        ),
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
    }
  }
}
