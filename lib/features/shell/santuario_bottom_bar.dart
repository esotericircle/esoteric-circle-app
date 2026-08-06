import 'package:flutter/material.dart';

import '../../core/maestro/maestro.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import 'navigation_controller.dart';
import 'vie_del_cerchio.dart';

/// Bottom bar a cinque voci: Santuario, i tre Maestri nell'ordine fisso
/// (Medora, Caligo, Aura) e il Cosmic Passport, distinto e staccato.
///
/// Le voci Maestro sono porte dirette al dominio del Maestro, non centrano il
/// busto: il cambio del centro nel Santuario avviene col carosello. Nel
/// Santuario resta acceso solo Santuario; le icone Maestro restano spente,
/// sono scorciatoie verso i domini.
class SantuarioBottomBar extends StatelessWidget {
  const SantuarioBottomBar({
    super.key,
    required this.view,
    required this.onSantuario,
    required this.onMaestro,
    required this.onPassport,
  });

  final ShellView view;
  final VoidCallback onSantuario;
  final ValueChanged<Maestro> onMaestro;
  final VoidCallback onPassport;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final onSantuarioView = view == ShellView.santuario;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            palette.deepest.withValues(alpha: 0.0),
            palette.deepest.withValues(alpha: 0.85),
            palette.deepest,
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.sm,
            vertical: SpacingTokens.sm,
          ),
          // LE VOCI VENGONO DALL'ELENCO UNICO, non da qui.
          //
          // Il nome, il disegno e l'ordine stanno in `ViaDelCerchio`, che e'
          // la stessa fonte da cui legge la striscia Esplora: finche' erano
          // due liste scritte a mano sono divergiute, di una voce e di
          // un'icona. Qui restano le cose che appartengono davvero alla barra,
          // cioe' quale voce e' accesa e cosa succede al tocco.
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final via in ViaDelCerchio.tutte) ...[
                // Il Passport, staccato dai Maestri da un filo verticale.
                if (via.specie == SpecieDiVia.passport)
                  Container(
                    width: 1,
                    height: 34,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    color: palette.gold.withValues(alpha: 0.2),
                  ),
                _BarItem(
                  label: via.etichetta,
                  icona: via.icona,
                  // Le icone Maestro portano al dominio: restano spente nel
                  // Santuario, sono scorciatoie, non lo stato del centro.
                  selected: switch (via.specie) {
                    SpecieDiVia.cerchio => onSantuarioView,
                    SpecieDiVia.maestro => false,
                    SpecieDiVia.passport => view == ShellView.passport,
                  },
                  onTap: () => switch (via.specie) {
                    SpecieDiVia.cerchio => onSantuario(),
                    SpecieDiVia.maestro => onMaestro(via.maestro!),
                    SpecieDiVia.passport => onPassport(),
                  },
                ),
              ],
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
    required this.icona,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Il disegno dell'icona, colore e lato decisi qui dentro perche' lo stato
  /// attivo e la dimensione ottica sono della barra, non della singola voce.
  /// Prima era un `IconData`, e un `IconData` non puo' essere una falce dentro
  /// un anello: la voce del Cerchio non esiste fra le icone di Material.
  final Widget Function(Color colore, double lato) icona;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final Color color = selected ? palette.goldSoft : ColorTokens.textMuted;

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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: selected
                      ? palette.primary.withValues(alpha: 0.5)
                      : Colors.transparent,
                  border: Border.all(
                    color: selected
                        ? palette.gold.withValues(alpha: 0.8)
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
                child: icona(color, 21),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
