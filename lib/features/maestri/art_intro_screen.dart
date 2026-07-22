import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/arts/art_catalog.dart';
import '../../core/maestro/maestro.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../services/app_services.dart';
import 'chat/maestro_chat_screen.dart';

/// La soglia di un'arte che si apre ma non ha ancora la sua esperienza piena.
///
/// Non e' un cartello di lavori in corso e non e' un vicolo cieco: e' una
/// schermata vera che presenta l'arte, dice con onesta' a che punto e', e offre
/// l'unica cosa che si puo' fare davvero adesso, cioe' parlarne col Maestro che
/// la custodisce. Quando l'esperienza arrivera', bastera' cambiare la rotta in
/// `artRouteFor` e questa schermata sparira' da sola dal cammino.
class ArtIntroScreen extends StatelessWidget {
  const ArtIntroScreen({
    super.key,
    required this.art,
    required this.maestro,
  });

  final ArtEntry art;
  final Maestro maestro;

  static Route<void> route({required ArtEntry art, required Maestro maestro}) {
    return MaterialPageRoute<void>(
      builder: (_) => MaestroScope(
        child: ArtIntroScreen(art: art, maestro: maestro),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(ThemeKey.of(maestro));
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: palette.deepest.withValues(alpha: 0.35),
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Indietro',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(art.title, style: TypographyTokens.display(size: 19)),
      ),
      body: CosmosBackground(
        showZodiac: false,
        child: SafeArea(
          child: SingleChildScrollView(
            key: Key('art_intro_${art.id}'),
            padding: const EdgeInsets.all(SpacingTokens.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: palette.primary.withValues(alpha: 0.45),
                    border:
                        Border.all(color: palette.gold.withValues(alpha: 0.6)),
                  ),
                  alignment: Alignment.center,
                  child: Icon(art.icon, size: 34, color: palette.goldSoft),
                ),
                const SizedBox(height: SpacingTokens.md),
                Text(art.title,
                    style: TypographyTokens.display(size: 24)
                        .copyWith(color: palette.goldSoft)),
                const SizedBox(height: SpacingTokens.sm),
                Text(
                  art.teaser,
                  style: TypographyTokens.body(size: 17).copyWith(
                    color: ColorTokens.textPrimary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: SpacingTokens.lg),
                Text(
                  'L\'esperienza piena di quest\'arte sta prendendo forma nelle '
                  'mani di ${maestro.displayName}. Intanto puoi portargliela '
                  'come domanda: il Cerchio risponde già adesso.',
                  style: TypographyTokens.body(size: 15).copyWith(
                    color: ColorTokens.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: SpacingTokens.lg),
                FilledButton.icon(
                  key: const Key('art_intro_consulta'),
                  onPressed: () {
                    final services = context.read<AppServices>();
                    Navigator.of(context).pushReplacement(
                      MaestroChatScreen.route(
                          maestro: maestro, services: services),
                    );
                  },
                  icon: const Icon(Icons.forum_outlined),
                  label: Text('Consulta ${maestro.displayName}'),
                ),
                if (art.benessere) ...[
                  const SizedBox(height: SpacingTokens.xl),
                  _CorniceBenessere(palette: palette),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// La cornice onesta delle arti del benessere, sempre uguale a se stessa.
class _CorniceBenessere extends StatelessWidget {
  const _CorniceBenessere({required this.palette});

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const Key('art_disclaimer_benessere'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.eco_outlined, size: 15, color: palette.goldSoft),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            ArtCatalog.disclaimerBenessere,
            style: TypographyTokens.body(size: 12).copyWith(
              color: ColorTokens.textSecondary,
              height: 1.4,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}
