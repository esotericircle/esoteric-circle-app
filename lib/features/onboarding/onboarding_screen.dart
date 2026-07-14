import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/identity/profile_controller.dart';
import '../../core/maestro/maestro.dart';
import '../../core/onboarding/onboarding_controller.dart';
import '../../core/rituals/daily_rituals.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../santuario/greeting_controller.dart';

/// "Il Risveglio": la primissima soglia del cerchio, mostrata una sola volta al
/// primo avvio, prima del Santuario. La Guida di turno del giorno accoglie la
/// persona per nome; un tocco entra nel Santuario, che da qui in poi e' la home.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key, this.clock});

  /// Orologio iniettabile per i test. Di default l'ora locale.
  final DateTime Function()? clock;

  static Route<void> route({DateTime Function()? clock}) {
    return MaterialPageRoute<void>(
      builder: (_) => OnboardingScreen(clock: clock),
      fullscreenDialog: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = (clock ?? DateTime.now)();
    final maestro = DailyRituals.dawnMaestro(now);
    final palette = MaestroPalette.forKey(ThemeKey.of(maestro));
    final name = context.read<ProfileController>().vocative;
    final greeting = GreetingController.greetingFor(maestro, name);

    return Scaffold(
      backgroundColor: ColorTokens.neutralDeepest,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.3),
            radius: 1.1,
            colors: [
              palette.surfaceElevated.withValues(alpha: 0.6),
              ColorTokens.neutralDeepest,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(SpacingTokens.xl),
            child: Column(
              key: const Key('onboarding_risveglio'),
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Text('Il Risveglio',
                    textAlign: TextAlign.center,
                    style: TypographyTokens.display(size: 30)
                        .copyWith(color: palette.goldSoft)),
                const SizedBox(height: SpacingTokens.xl),
                // Livello visivo: il volto della Guida di turno.
                Container(
                  width: 132,
                  height: 132,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      palette.primary.withValues(alpha: 0.6),
                      palette.deepest.withValues(alpha: 0.5),
                    ]),
                    border: Border.all(
                        color: palette.gold.withValues(alpha: 0.7), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: palette.glow.withValues(alpha: 0.4),
                        blurRadius: 30,
                        spreadRadius: -6,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    maestro.avatarAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(Icons.auto_awesome,
                        color: palette.goldSoft, size: 48),
                  ),
                ),
                const SizedBox(height: SpacingTokens.lg),
                // Il saluto per nome, sottotitolo sempre a schermo (la voce
                // Gemini-TTS lo accompagna sul device quando disponibile).
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.graphic_eq_rounded,
                        size: 18, color: palette.goldSoft),
                    const SizedBox(width: SpacingTokens.sm),
                    Flexible(
                      child: Text(
                        greeting,
                        textAlign: TextAlign.center,
                        style: TypographyTokens.body(size: 17).copyWith(
                          color: ColorTokens.textPrimary,
                          fontStyle: FontStyle.italic,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                _EnterButton(
                  palette: palette,
                  label: 'Entra nel Santuario',
                  onTap: () {
                    context.read<OnboardingController>().complete();
                    Navigator.of(context).maybePop();
                  },
                ),
                const SizedBox(height: SpacingTokens.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EnterButton extends StatelessWidget {
  const _EnterButton({
    required this.palette,
    required this.label,
    required this.onTap,
  });

  final MaestroPalette palette;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const Key('onboarding_enter'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: SpacingTokens.md),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
              gradient: LinearGradient(colors: [
                palette.primary.withValues(alpha: 0.8),
                palette.surfaceElevated.withValues(alpha: 0.8),
              ]),
              border: Border.all(color: palette.gold.withValues(alpha: 0.7)),
            ),
            child: Text(label,
                style: TypographyTokens.display(size: 17)
                    .copyWith(color: palette.goldSoft)),
          ),
        ),
      ),
    );
  }
}
