import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_flow/app_flow_controller.dart';
import '../../core/astro/birth_details.dart';
import '../../core/astro/maestro_assignment.dart';
import '../../core/astro/natal_chart_controller.dart';
import '../../core/astro/zodiac_controller.dart';
import '../../core/maestro/maestro.dart';
import '../../core/maestro/maestro_controller.dart';
import '../../design_system/components/immersive_scaffold.dart';
import 'maestro_reveal_screen.dart';
import 'natal_chart_reveal.dart';
import 'onboarding_controller.dart';
import 'onboarding_form.dart';

enum _JourneyPhase { form, chart, reveal }

/// Orchestrazione dell'onboarding Il Risveglio: raccolta dati, calcolo della
/// carta natale, e rivelazione del Maestro col soffio.
class OnboardingJourney extends StatefulWidget {
  const OnboardingJourney({super.key});

  @override
  State<OnboardingJourney> createState() => _OnboardingJourneyState();
}

class _OnboardingJourneyState extends State<OnboardingJourney> {
  _JourneyPhase _phase = _JourneyPhase.form;
  Maestro _assigned = Maestro.medora;

  Future<void> _onSubmit(BirthDetails details) async {
    setState(() => _phase = _JourneyPhase.chart);

    final chartCtrl = context.read<NatalChartController>();
    await chartCtrl.compute(details);
    if (!mounted) return;

    final chart = chartCtrl.chart;
    if (chart != null) {
      _assigned = assignMaestro(chart.sunSign);
    }
  }

  void _onChartContinue() {
    // Entrando nel rito, il colore del Maestro assegnato sboccia nel cosmo.
    context.read<MaestroController>().selectMaestro(_assigned);
    setState(() => _phase = _JourneyPhase.reveal);
  }

  void _onRevealed(Maestro maestro) {
    context.read<MaestroController>().selectMaestro(maestro);
    // Solo ora, entrando nel Santuario, il cielo evidenzia la costellazione
    // del segno solare dell'utente: durante tutto l'onboarding nessuna
    // costellazione resta pinnata in un angolo.
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
      case _JourneyPhase.form:
        return ChangeNotifierProvider(
          key: const ValueKey('form'),
          create: (_) => OnboardingController(),
          child: OnboardingForm(onSubmit: _onSubmit),
        );
      case _JourneyPhase.chart:
        return NatalChartReveal(
          key: const ValueKey('chart'),
          onContinue: _onChartContinue,
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
