import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/astro/birth_details.dart';
import '../../core/astro/natal_chart_controller.dart';
import '../../core/astro/resonance.dart';
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

enum _Phase { heaven, chart, resonance, reveal }

class _RisveglioJourneyState extends State<RisveglioJourney> {
  _Phase _phase = _Phase.heaven;
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
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
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
          showBack: false,
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
