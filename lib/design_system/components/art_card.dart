import 'package:flutter/material.dart';

import '../../core/arts/art_catalog.dart';
import '../../core/entitlement/plan_catalog.dart';
import '../theme/maestro_palette.dart';
import '../tokens/color_tokens.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';

/// La card di un'arte del Cerchio, un solo linguaggio per tutti e tre gli stati.
///
/// Lo stato distingue, non l'impaginazione: la forma e' sempre la stessa, cambia
/// il segno. ATTIVA piena e vivida; PREMIUM col lucchetto piccolo e la riga che
/// dice come si sblocca; IN ARRIVO con un velo LEGGERO e l'etichetta di fase.
/// Premium e In arrivo restano pienamente leggibili: lo scopo e' far desiderare
/// l'arte, non nasconderla.
class ArtCard extends StatelessWidget {
  const ArtCard({
    super.key,
    required this.art,
    required this.palette,
    this.onTap,
  });

  final ArtEntry art;
  final MaestroPalette palette;

  /// Azione al tocco. Per le arti non attive si mostra comunque un anticipo,
  /// mai un vicolo cieco: lo decide chi la usa.
  final VoidCallback? onTap;

  /// Quanto e' velata la card: nulla sull'attiva, appena un soffio sulle altre,
  /// cosi' il testo resta nitido.
  double get _veil => art.state == ArtState.attiva ? 1.0 : 0.86;

  @override
  Widget build(BuildContext context) {
    final attiva = art.state == ArtState.attiva;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('art_${art.id}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(SpacingTokens.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                palette.surfaceElevated
                    .withValues(alpha: attiva ? 0.95 : 0.72),
                palette.surface.withValues(alpha: attiva ? 0.80 : 0.60),
              ],
            ),
            border: Border.all(
              color: palette.gold.withValues(alpha: attiva ? 0.45 : 0.26),
            ),
          ),
          child: Opacity(
            // Velo leggero, mai fino all'illeggibile.
            opacity: _veil,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(art.icon,
                        size: 22,
                        color: palette.goldSoft
                            .withValues(alpha: attiva ? 1.0 : 0.85)),
                    const SizedBox(width: SpacingTokens.sm),
                    Expanded(
                      child: Text(
                        art.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TypographyTokens.display(size: 16)
                            .copyWith(color: ColorTokens.textPrimary),
                      ),
                    ),
                    if (art.state == ArtState.premium)
                      Icon(Icons.lock_rounded,
                          key: Key('art_lock_${art.id}'),
                          size: 15,
                          color: palette.goldSoft.withValues(alpha: 0.9)),
                  ],
                ),
                const SizedBox(height: SpacingTokens.xs),
                Text(
                  art.teaser,
                  style: TypographyTokens.body(size: 13).copyWith(
                    color: ColorTokens.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: SpacingTokens.sm),
                _StateLine(art: art, palette: palette),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// La riga di stato in fondo alla card: che cosa e' questa arte, adesso.
class _StateLine extends StatelessWidget {
  const _StateLine({required this.art, required this.palette});

  final ArtEntry art;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    switch (art.state) {
      case ArtState.attiva:
        return _Badge(
          key: Key('art_state_attiva_${art.id}'),
          label: 'Attiva',
          icon: Icons.play_circle_outline_rounded,
          palette: palette,
          strong: true,
        );
      case ArtState.premium:
        final piano = art.requiredTier == null
            ? 'il Cerchio'
            : PlanCatalog.forTier(art.requiredTier!).name;
        return _Badge(
          key: Key('art_state_premium_${art.id}'),
          label: 'Si apre col $piano',
          icon: Icons.workspace_premium_outlined,
          palette: palette,
          strong: true,
        );
      case ArtState.inArrivo:
        final fase = art.phase ?? 'presto';
        return _Badge(
          key: Key('art_state_arrivo_${art.id}'),
          label: 'In arrivo, $fase',
          icon: Icons.schedule_rounded,
          palette: palette,
          strong: false,
        );
    }
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    super.key,
    required this.label,
    required this.icon,
    required this.palette,
    required this.strong,
  });

  final String label;
  final IconData icon;
  final MaestroPalette palette;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
        color: palette.gold.withValues(alpha: strong ? 0.18 : 0.10),
        border: Border.all(
          color: palette.gold.withValues(alpha: strong ? 0.55 : 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: palette.goldSoft),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TypographyTokens.label(size: 10).copyWith(
                color: palette.goldSoft,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
