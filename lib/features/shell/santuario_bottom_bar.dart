import 'package:flutter/material.dart';

import '../../core/maestro/maestro.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import 'navigation_controller.dart';

/// Bottom bar dei tre Maestri con l'ancora del Santuario.
///
/// Ogni voce Maestro, se toccata, naviga alla sua sezione e cambia il tema
/// dell'interfaccia con la dissolvenza cromatica. La voce attiva si illumina
/// d'oro nel colore del Maestro.
class SantuarioBottomBar extends StatelessWidget {
  const SantuarioBottomBar({
    super.key,
    required this.current,
    required this.onSelected,
    required this.onPassport,
  });

  final AppDestination current;
  final ValueChanged<AppDestination> onSelected;

  /// Il Cosmic Passport e' distinto: non e' una destinazione della pila, apre il
  /// profilo con i fatti identitari conquistati.
  final VoidCallback onPassport;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Container(
      decoration: BoxDecoration(
        // Velo alto e deciso: i contenuti che scorrono sotto la barra sfumano
        // nel buio prima di raggiungere le icone, cosi' il testo delle tessere
        // non si accavalla mai con la navigazione.
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            palette.deepest.withValues(alpha: 0.0),
            palette.deepest.withValues(alpha: 0.88),
            palette.deepest,
            palette.deepest,
          ],
          stops: const [0.0, 0.24, 0.44, 1.0],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(
            left: SpacingTokens.md,
            right: SpacingTokens.md,
            top: SpacingTokens.lg,
            bottom: SpacingTokens.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BarItem(
                label: 'Santuario',
                iconData: Icons.brightness_3,
                selected: current == AppDestination.santuario,
                onTap: () => onSelected(AppDestination.santuario),
              ),
              for (final maestro in Maestro.values)
                _BarItem(
                  label: maestro.displayName,
                  iconData: maestro.icon,
                  selected: current == AppDestination.forMaestro(maestro),
                  onTap: () =>
                      onSelected(AppDestination.forMaestro(maestro)),
                ),
              _BarItem(
                label: 'Passport',
                iconData: Icons.hexagon_outlined,
                selected: false,
                distinct: true,
                onTap: onPassport,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  const _BarItem({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.iconData,
    this.distinct = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData iconData;

  /// Voce distinta (il Cosmic Passport): bordo dorato sempre acceso.
  final bool distinct;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final Color color = selected || distinct
        ? palette.goldSoft
        : ColorTokens.textMuted;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: SpacingTokens.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? palette.primary.withValues(alpha: 0.5)
                      : Colors.transparent,
                  border: Border.all(
                    color: selected
                        ? palette.gold.withValues(alpha: 0.8)
                        : distinct
                            ? palette.gold.withValues(alpha: 0.55)
                            : Colors.transparent,
                    width: 1.2,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: palette.glow.withValues(alpha: 0.5),
                            blurRadius: 18,
                            spreadRadius: -2,
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Icon(iconData, color: color, size: 22),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
