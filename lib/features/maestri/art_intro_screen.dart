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
import '../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../../design_system/typography/paragrafi_di_lettura.dart';

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
    return PassaggioDelCerchio.rotta<void>((_) => MaestroScope(
        child: ArtIntroScreen(art: art, maestro: maestro),
      ));
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
        seed: 6,
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
                // **ALLA MISURA DEL RESPONSO. Ordine CE voce 10.** Parole del fondatore:
                // "nella maggior parte delle funzionalita' NON SI LEGGE BENE IL TESTO. anche
                // nei doni o tutte le funzionalita' anche prima di chiedere un responso". La
                // misura non si sceglie, si prende: e' `lettura()`, la stessa del responso dei
                // Tarocchi e dell'Oroscopo.
                ParagrafiDiLettura(
                  testo: art.teaser,
                  stile: TypographyTokens.lettura()
                      .copyWith(color: ColorTokens.textPrimary),
                ),
                const SizedBox(height: SpacingTokens.lg),
                Text(
                  'L\'esperienza piena di quest\'arte sta prendendo forma nelle '
                  'mani di ${maestro.displayName}. Intanto puoi portargliela '
                  'come domanda: il Cerchio risponde già adesso.',
                  style: TypographyTokens.lettura()
                      .copyWith(color: ColorTokens.textSecondary),
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
                // LA CORNICE ONESTA E' USCITA DA QUI, ed era uno dei SETTE
                // disclaimer a schermo. Le linee guida dicevano da sempre
                // "una volta sola", e per sette volte ognuno ha pensato
                // che il proprio fosse quella volta. Adesso sta in un
                // posto solo, nell'area privacy.
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// La cornice onesta delle arti, sempre uguale a se stessa.
