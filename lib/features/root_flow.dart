import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_flow/app_flow_controller.dart';
import 'intro/intro_screen.dart';
import 'onboarding/onboarding_journey.dart';
import 'shell/app_shell.dart';

/// Sceglie la fase di ingresso da mostrare: intro, onboarding o app.
///
/// Le tre fasi condividono la stessa base (MaestroScope e cosmo), cosi' la
/// transizione tra loro e' fluida.
class RootFlow extends StatelessWidget {
  const RootFlow({super.key});

  @override
  Widget build(BuildContext context) {
    final flow = context.watch<AppFlowController>();

    final Widget child = switch (flow.phase) {
      AppPhase.intro => IntroScreen(
          key: const ValueKey('intro'),
          onFinish: flow.toOnboarding,
        ),
      AppPhase.onboarding => const OnboardingJourney(key: ValueKey('onboarding')),
      AppPhase.app => const AppShell(key: ValueKey('app')),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: child,
    );
  }
}
