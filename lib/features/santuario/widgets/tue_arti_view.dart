import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/arts/art_catalog.dart';
import '../../../core/arts/arti_preferite.dart';
import '../../../core/maestro/maestro.dart';
import '../../../core/maestro/maestro_controller.dart';
import '../../../design_system/theme/maestro_palette.dart';
import '../../../design_system/theme/maestro_scope.dart';
import '../../../design_system/tokens/spacing_tokens.dart';
import '../../../design_system/tokens/typography_tokens.dart';
import '../../maestri/rotta_arte.dart';
import '../santuario_screen.dart';

/// "Le tue arti": lo scaffale personale, in cima all'elenco.
///
/// Non parte mai vuoto, perche' il seme vive nel dato. La matita accanto al
/// titolo apre l'elenco completo a spunte, e ogni bolla porta il colore del
/// Maestro a cui l'arte appartiene, come le altre bolle del Cerchio.
class TueArtiView extends StatelessWidget {
  const TueArtiView({super.key, required this.onOpen});

  /// Apre un'arte dal suo identificativo. La rotta la conosce il Santuario, che
  /// ha in mano segno e profilo.
  final void Function(String id) onOpen;

  @override
  Widget build(BuildContext context) {
    final preferite = context.watch<ArtiPreferiteController?>();
    if (preferite == null) return const SizedBox.shrink();
    final palette = MaestroScope.of(context);
    // Finche' il disco non ha risposto si mostra il seme, non un vuoto: un
    // lampo di scaffale spoglio all'avvio sarebbe indistinguibile dal difetto
    // che questa funzione deve evitare.
    final ids = preferite.caricato && preferite.ids.isNotEmpty
        ? preferite.ids
        : ArtiPreferiteController.semePer(
            context.read<MaestroController>().activeMaestro);

    return Padding(
      padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.lg,
          SpacingTokens.lg, SpacingTokens.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Le tue arti',
                  key: const Key('tue_arti_titolo'),
                  style: TypographyTokens.display(size: 20)
                      .copyWith(color: palette.textPrimary)),
              const SizedBox(width: SpacingTokens.xs),
              // La matita accanto al titolo: si personalizza da qui, non da un
              // menu nascosto.
              IconButton(
                key: const Key('tue_arti_matita'),
                tooltip: 'Scegli le tue arti',
                iconSize: 18,
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.edit_outlined, color: palette.goldSoft),
                onPressed: () => mostraSceltaArti(context),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.xs),
          // Le BOLLE GRANDI, non le pillole: emblema, titolo, riga di
          // anticipo e freccia. Le pillole piccole troncavano i titoli, e lo
          // stile grande e' quello dell'elenco che "Le tue arti" sostituisce.
          for (final id in ids) ...[
            _BollaArte(id: id, onOpen: () => onOpen(id)),
            const SizedBox(height: SpacingTokens.sm),
          ],
        ],
      ),
    );
  }
}

/// Una bolla dello scaffale personale, nel colore del suo Maestro.
///
/// La pressione lunga toglie l'arte, senza dover entrare per farlo.
class _BollaArte extends StatelessWidget {
  const _BollaArte({required this.id, required this.onOpen});

  final String id;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final voce = ArtCatalog.all.where((a) => a.id == id).toList();
    if (voce.isEmpty) return const SizedBox.shrink();
    final arte = voce.first;
    final proprietario = _proprietarioDi(id) ?? Maestro.medora;
    final propria = MaestroPalette.forKey(ThemeKey.of(proprietario));
    final preferite = context.watch<ArtiPreferiteController?>();

    return GestureDetector(
      key: Key('tua_arte_$id'),
      // La pressione lunga toglie l'arte: sta qui e non nella tessera, perche'
      // la tessera e' condivisa con altri scaffali che non hanno preferiti.
      onLongPress: preferite == null
          ? null
          : () => CuorePreferita.mostraEsito(
              context, preferite.cambia(id), propria),
      child: ShelfCard(
        titolo: arte.title,
        anticipo: arte.teaser,
        icona: arte.icon,
        maestro: proprietario,
        onTap: onOpen,
      ),
    );
  }
}

/// Di chi e' un'arte, secondo il catalogo.
Maestro? _proprietarioDi(String id) {
  for (final m in Maestro.values) {
    if (ArtCatalog.activeOf(m).any((a) => a.id == id)) return m;
  }
  return null;
}

/// Il foglio della matita: l'elenco completo delle arti vive, a spunte,
/// raggruppato per Maestro.
///
/// Il foglio nasce sotto il Navigator, quindi fuori dal MaestroScope della
/// schermata: la palette gli va passata, altrimenti non trova nessuno scope e
/// l'asserzione salta.
void mostraSceltaArti(BuildContext context) {
  final preferite = context.read<ArtiPreferiteController>();
  final palette = MaestroScope.of(context);
  showModalBottomSheet<void>(
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
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85),
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
            Text('Le tue arti',
                style: TypographyTokens.display(size: 22)
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
                        .copyWith(color: palette.gold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
