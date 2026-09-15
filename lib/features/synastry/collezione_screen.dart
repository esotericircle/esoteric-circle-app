import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/astro/data_italiana.dart';
import '../../core/maestro/maestro.dart';
import '../../core/synastry/collezione_delle_coppie.dart';
import '../../core/synastry/vip_catalog.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/components/titolo_che_non_si_rompe.dart';
import '../maestri/rotta_arte.dart';
import '../../design_system/transizioni/passaggio_del_cerchio.dart';

/// LA TUA COLLEZIONE DI COPPIE. Ordine BO voce 13.
///
/// **Soltanto le coppie che hai composto tu**, in fila per punteggio, coi due
/// volti, il numero e il giorno in cui le hai scoperte. Le altre non si vedono
/// e non si calcolano: con cinquanta VIP le combinazioni sono 1.225, con
/// duecento diventano 19.900, e una classifica di tutte non e' una schermata.
class CollezioneScreen extends StatelessWidget {
  const CollezioneScreen({super.key, required this.onApri});

  /// Riaprire una coppia dalla collezione **non consuma niente**: e' una cosa
  /// gia' pagata che si rilegge.
  final void Function(CoppiaScoperta) onApri;

  static Route<void> route({required void Function(CoppiaScoperta) onApri}) =>
      PassaggioDelCerchio.rotta<void>((_) => MaestroScope(
            maestro: Maestro.medora,
            child: CollezioneScreen(onApri: onApri),
          ));

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
    final collezione = context.watch<CollezioneDelleCoppie>();
    final coppie = collezione.inFila;
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        title: TitoloCheNonSiRompe(
            testo: 'La tua collezione',
            stile: TypographyTokens.titoloSezione()),
        actions: const [AngoloDellaBarra()],
      ),
      body: CosmosBackground(
        seed: 21,
        showZodiac: false,
        child: SafeArea(
          child: ListView(
            key: const Key('collezione_lista'),
            padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, kToolbarHeight,
                SpacingTokens.lg, SpacingTokens.xxxl),
            children: [
              // **LA RIGA IN TESTA: quante ne hai scoperte e quante ne
              // esistono.** Il totale si calcola dal catalogo e non si scrive
              // a mano: il giorno che i VIP diventano duecento cambia da solo.
              Text(collezione.riepilogo,
                  key: const Key('collezione_riepilogo'),
                  textAlign: TextAlign.center,
                  style: TypographyTokens.cerimoniale()
                      .copyWith(color: palette.goldSoft)),
              const SizedBox(height: SpacingTokens.lg),
              if (collezione.eVuota)
                _LInvito(palette: palette)
              else
                for (final c in coppie) ...[
                  _RigaDellaCoppia(
                    key: Key('coppia_${c.chiave}'),
                    coppia: c,
                    palette: palette,
                    onApri: () => onApri(c),
                  ),
                  const SizedBox(height: SpacingTokens.sm),
                ],
            ],
          ),
        ),
      ),
    );
  }
}

/// **LA COLLEZIONE VUOTA SI DICHIARA, mai con una schermata bianca.**
class _LInvito extends StatelessWidget {
  const _LInvito({required this.palette});

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('collezione_invito'),
      children: [
        Icon(Icons.auto_awesome, color: palette.goldSoft, size: 36),
        const SizedBox(height: SpacingTokens.sm),
        Text('Qui finiscono le coppie che componi.',
            textAlign: TextAlign.center,
            style: TypographyTokens.titoloScheda()
                .copyWith(color: palette.goldSoft)),
        const SizedBox(height: SpacingTokens.xs),
        Text(
            'Scegli un VIP e guarda quanto il suo cielo somiglia al tuo. '
            'Oppure metti due VIP uno di fronte all\'altro: la prima casella '
            'si può sostituire.',
            textAlign: TextAlign.center,
            style: TypographyTokens.corpo()
                .copyWith(color: ColorTokens.textSecondary, height: 1.4)),
      ],
    );
  }
}

class _RigaDellaCoppia extends StatelessWidget {
  const _RigaDellaCoppia({
    super.key,
    required this.coppia,
    required this.palette,
    required this.onApri,
  });

  final CoppiaScoperta coppia;
  final MaestroPalette palette;
  final VoidCallback onApri;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onApri,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minHeight: 72),
        padding: const EdgeInsets.all(SpacingTokens.sm),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
          color: palette.surface.withValues(alpha: 0.45),
          border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            _volto(coppia.primo),
            const SizedBox(width: SpacingTokens.xs),
            Icon(Icons.favorite_rounded, color: palette.goldSoft, size: 16),
            const SizedBox(width: SpacingTokens.xs),
            _volto(coppia.secondo),
            const SizedBox(width: SpacingTokens.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                      '${coppia.seiTu ? 'Tu' : coppia.primo} '
                      'e ${coppia.secondo}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TypographyTokens.corpo()
                          .copyWith(color: ColorTokens.textPrimary)),
                  Text(dataItalianaEstesa(coppia.quando),
                      style: TypographyTokens.didascalia()
                          .copyWith(color: ColorTokens.textSecondary)),
                ],
              ),
            ),
            Text('${coppia.punteggio}%',
                style: TypographyTokens.titoloSezione()
                    .copyWith(color: palette.goldSoft)),
          ],
        ),
      ),
    );
  }

  Widget _volto(String nome) {
    final vip = nome.isEmpty ? null : VipCatalog.conNome(nome);
    return SizedBox(
      width: 40,
      height: 52,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
        child: vip != null && vip.hasImage
            ? Image.asset(vip.thumbPath!, fit: BoxFit.contain)
            : DecoratedBox(
                decoration: BoxDecoration(
                    color: palette.deepest.withValues(alpha: 0.7)),
                child: Icon(Icons.person_outline,
                    color: palette.goldSoft, size: 20),
              ),
      ),
    );
  }
}
