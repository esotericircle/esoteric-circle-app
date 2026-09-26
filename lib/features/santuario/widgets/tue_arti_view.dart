import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/arts/art_catalog.dart';
import '../../../core/arts/arti_preferite.dart';
import '../../../core/maestro/maestro.dart';
import '../../../design_system/theme/maestro_palette.dart';
import '../../../design_system/theme/maestro_scope.dart';
import '../../../design_system/tokens/spacing_tokens.dart';
import '../../../design_system/tokens/typography_tokens.dart';
import '../../maestri/rotta_arte.dart';
import '../../../design_system/transizioni/velo_del_cerchio.dart';

/// **LO SCAFFALE "LE ARTI PREFERITE" E' USCITO DAL CODICE, ordine EO voce
/// 09.** Dall'ordine AK fino all'ordine EN qui viveva `TueArtiView`, le
/// bolle grandi con la pressione lunga che toglie l'arte. Dall'ordine EO
/// le arti preferite sono la prima riga della home
/// (`le_righe_della_casa.dart`), con le schede nuove, la stessa matita e la
/// stessa pressione lunga. Qui resta il foglio della matita, che la riga
/// apre.

/// Il foglio della matita: l'elenco completo delle arti vive, a spunte,
/// raggruppato per Maestro.
///
/// Il foglio nasce sotto il Navigator, quindi fuori dal MaestroScope della
/// schermata: la palette gli va passata, altrimenti non trova nessuno scope e
/// l'asserzione salta.
void mostraSceltaArti(BuildContext context) {
  final preferite = context.read<ArtiPreferiteController>();
  final palette = MaestroScope.of(context);
  foglioDelCerchio<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider<ArtiPreferiteController>.value(
      value: preferite,
      child: _FoglioScelta(palette: palette),
    ),
  );
}

class _FoglioScelta extends StatelessWidget {
  const _FoglioScelta({required this.palette});

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    final preferite = context.watch<ArtiPreferiteController>();
    return Container(
      key: const Key('tue_arti_foglio'),
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.md,
          SpacingTokens.lg, SpacingTokens.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.surfaceElevated, palette.deepest],
        ),
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(SpacingTokens.lg)),
        border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // La maniglia: dice che il foglio si trascina, e tiene il titolo
            // lontano dal bordo superiore che lo tagliava.
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: SpacingTokens.md),
                decoration: BoxDecoration(
                  color: palette.goldSoft.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('Le arti preferite',
                style: TypographyTokens.titoloSezione()
                    .copyWith(color: palette.textPrimary)),
            const SizedBox(height: SpacingTokens.xs),
            Text(
              'Scegline fino a ${ArtiPreferiteController.tetto}: saranno le '
              'prime che trovi nel Cerchio. Niente di tutto questo dipende dal '
              'tuo piano.',
              style: TypographyTokens.corpo()
                  .copyWith(color: palette.textSecondary),
            ),
            const SizedBox(height: SpacingTokens.md),
            for (final m in Maestro.values) ...[
              Padding(
                padding: const EdgeInsets.only(top: SpacingTokens.sm),
                child: Text(m.displayName,
                    style: TypographyTokens.label(size: 12).copyWith(
                      color: MaestroPalette.forKey(ThemeKey.of(m)).goldSoft,
                      letterSpacing: 0.8,
                    )),
              ),
              for (final arte in ArtCatalog.activeOf(m))
                CheckboxListTile(
                  key: Key('scelta_${arte.id}'),
                  value: preferite.contiene(arte.id),
                  onChanged: (_) {
                    final esito = preferite.cambia(arte.id);
                    if (esito == EsitoPreferita.pieno ||
                        esito == EsitoPreferita.ripristinata) {
                      CuorePreferita.mostraEsito(context, esito, palette);
                    }
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  activeColor: MaestroPalette.forKey(ThemeKey.of(m)).primary,
                  checkColor: palette.textPrimary,
                  title: Text(arte.title,
                      style: TypographyTokens.corpo()
                          .copyWith(color: palette.textPrimary)),
                ),
            ],
            const SizedBox(height: SpacingTokens.md),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                key: const Key('tue_arti_chiudi'),
                onPressed: () => Navigator.of(context).maybePop(),
                child: Text('Fatto',
                    style: TypographyTokens.label(size: 14)
                        .copyWith(color: palette.goldSoft)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
