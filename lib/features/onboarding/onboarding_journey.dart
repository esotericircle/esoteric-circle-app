import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_flow/app_flow_controller.dart';
import '../../core/astro/birth_details.dart';
import '../../core/astro/natal_chart_controller.dart';
import '../../core/astro/resonance.dart';
import '../../core/astro/zodiac_controller.dart';
import '../../core/maestro/maestro.dart';
import '../../core/maestro/maestro_controller.dart';
import '../../design_system/components/immersive_scaffold.dart';
import 'maestro_reveal_screen.dart';
import 'name_step.dart';
import 'natal_chart_reveal.dart';
import 'onboarding_controller.dart';
import 'onboarding_form.dart';
import 'resonance_screen.dart';

enum _JourneyPhase { name, sky, chart, resonance, reveal }

/// Orchestrazione dell'onboarding: nome e forma, dati di nascita (Accendi il
/// tuo cielo), carta natale, risonanza coi Maestri, rivelazione col soffio.
class OnboardingJourney extends StatefulWidget {
  const OnboardingJourney({super.key});

  @override
  State<OnboardingJourney> createState() => _OnboardingJourneyState();
}

class _OnboardingJourneyState extends State<OnboardingJourney> {
  _JourneyPhase _phase = _JourneyPhase.name;
  Maestro _assigned = Maestro.medora;
  Resonance? _resonance;

  Future<void> _onSubmit(BirthDetails details) async {
    setState(() => _phase = _JourneyPhase.chart);
    final chartCtrl = context.read<NatalChartController>();
    await chartCtrl.compute(details);
    if (!mounted) return;
    final chart = chartCtrl.chart;
    if (chart != null) {
      _resonance = computeResonance(chart);
      _assigned = _resonance!.winner;
    }
  }

  void _onChartContinue() {
    setState(() => _phase = _JourneyPhase.resonance);
  }

  void _onResonanceContinue() {
    // Entrando nel rito, il colore del Maestro sboccia nel cosmo.
    context.read<MaestroController>().selectMaestro(_assigned);
    setState(() => _phase = _JourneyPhase.reveal);
  }

  void _onRevealed(Maestro maestro) {
    context.read<MaestroController>().selectMaestro(maestro);
    final sun = context.read<NatalChartController>().sunSign;
    if (sun != null) context.read<ZodiacController>().setSunSign(sun);
    context.read<AppFlowController>().toApp();
  }

  @override
  Widget build(BuildContext context) {
    return ImmersiveScaffold(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        child: _buildPhase(),
      ),
    );
  }

  Widget _buildPhase() {
    switch (_phase) {
      case _JourneyPhase.name:
        return NameStep(
          key: const ValueKey('name'),
          onContinue: () => setState(() => _phase = _JourneyPhase.sky),
        );
      case _JourneyPhase.sky:
        return ChangeNotifierProvider(
          key: const ValueKey('sky'),
          create: (_) => OnboardingController(),
          child: OnboardingForm(onSubmit: _onSubmit),
        );
      case _JourneyPhase.chart:
        return NatalChartReveal(
          key: const ValueKey('chart'),
          onContinue: _onChartContinue,
        );
      case _JourneyPhase.resonance:
        return _resonance == null
            ? const SizedBox.shrink()
            : ResonanceScreen(
                key: const ValueKey('resonance'),
                resonance: _resonance!,
                onContinue: _onResonanceContinue,
              );
      case _JourneyPhase.reveal:
        return MaestroRevealScreen(
          key: const ValueKey('reveal'),
          maestro: _assigned,
          onRevealed: _onRevealed,
        );
    }
  }
}
