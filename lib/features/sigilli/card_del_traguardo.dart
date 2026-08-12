import 'package:flutter/material.dart';

import '../../core/sigilli/bonus_della_condivisione.dart';
import '../../core/maestro/maestro.dart';
import '../../core/sigilli/sentieri.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../design_system/components/icona_degli_eos.dart';

/// LA CARD CONDIVISIBILE DI UN TRAGUARDO, nel formato unico gia' in uso.
///
/// Stesso impianto delle altre card del Cerchio (stesa, oroscopo, animale):
/// cornice oro sul buio, il nome in cerimoniale, la frase del Maestro, il
/// marchio in fondo. Cambia il contenuto, non la grammatica.
class CardDelTraguardo extends StatelessWidget {
  const CardDelTraguardo({
    super.key,
    required this.traguardo,
    required this.sentiero,
  });

  final Traguardo traguardo;
  final Sentiero sentiero;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      key: const Key('card_del_traguardo'),
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette.surfaceElevated, palette.deepest],
        ),
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        border: Border.all(color: palette.gold.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            // UNO SOLO, quindi la forma SINGOLARE, dichiarata: questa
            // etichetta nomina il traguardo che si e' appena acceso, che e'
            // uno.
            traguardo.eGrande
                ? sentiero.grande.singolare.toUpperCase()
                : sentiero.mini.singolare.toUpperCase(),
            style: TypographyTokens.etichetta().copyWith(
              color: palette.goldSoft,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
          Text(traguardo.nome,
              key: const Key('card_nome_del_traguardo'),
              style: TypographyTokens.cerimoniale()
                  .copyWith(color: ColorTokens.textPrimary)),
          const SizedBox(height: SpacingTokens.sm),
          Text(traguardo.frase,
              style: TypographyTokens.corpo()
                  .copyWith(color: ColorTokens.textSecondary, height: 1.45)),
          const SizedBox(height: SpacingTokens.md),
          Row(
            children: [
              IconaDegliEos(misura: 16, colore: palette.goldSoft),
              const SizedBox(width: SpacingTokens.xs),
              Text('${traguardo.eos} Eos',
                  style: TypographyTokens.etichetta()
                      .copyWith(color: palette.goldSoft)),
              const Spacer(),
              Text(sentiero.titolo,
                  style: TypographyTokens.didascalia()
                      .copyWith(color: ColorTokens.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

/// LE VIE DELLA CONDIVISIONE, uguali in tutte e due le forme della
/// celebrazione e uguali quando si riapre la card dal journal.
///
/// **Perche' un componente e non tre copie.** L'ordine chiede che il pulsante
/// di condivisione ci sia a schermo pieno, in sovrimpressione e sul Sigillo
/// gia' acceso, e che porti sempre allo stesso bonus. Tre copie diventerebbero
/// tre bonus diversi al primo ritocco.
class VieDellaCondivisione extends StatelessWidget {
  const VieDellaCondivisione({
    super.key,
    required this.suScelta,
    this.compatte = false,
  });

  final void Function(ModoDellaCondivisione modo) suScelta;

  /// In sovrimpressione c'e' meno spazio: un pulsante solo, che apre le tre
  /// vie. La via resta la stessa, cambia quanto posto occupa.
  final bool compatte;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    if (compatte) {
      return TextButton.icon(
        key: const Key('condividi_traguardo_compatto'),
        onPressed: () => _apriLeVie(context),
        icon: Icon(Icons.ios_share_rounded, size: 18, color: palette.goldSoft),
        label: Text('Condividi',
            style:
                TypographyTokens.etichetta().copyWith(color: palette.goldSoft)),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final modo in ModoDellaCondivisione.values) ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: Key('condividi_${modo.motivo}'),
              onPressed: () => suScelta(modo),
              style: FilledButton.styleFrom(
                backgroundColor: palette.surfaceElevated,
                foregroundColor: palette.goldSoft,
                side: BorderSide(color: palette.gold.withValues(alpha: 0.4)),
                padding:
                    const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
              ),
              icon: Icon(_iconaDi(modo), size: 18),
              label: Text(modo.etichetta,
                  style: TypographyTokens.etichetta()),
            ),
          ),
          const SizedBox(height: SpacingTokens.xs),
        ],
      ],
    );
  }

  void _apriLeVie(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (foglio) => Container(
        key: const Key('vie_della_condivisione'),
        padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.md,
            SpacingTokens.lg, SpacingTokens.xl),
        decoration: BoxDecoration(
          color: context.palette.surfaceElevated,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(SpacingTokens.radiusXl)),
        ),
        child: SafeArea(
          top: false,
          child: VieDellaCondivisione(suScelta: (modo) {
            Navigator.of(foglio).pop();
            suScelta(modo);
          }),
        ),
      ),
    );
  }

  static IconData _iconaDi(ModoDellaCondivisione modo) => switch (modo) {
        ModoDellaCondivisione.invitoConDownload => Icons.person_add_alt_1,
        ModoDellaCondivisione.socialPubblico => Icons.public_rounded,
        ModoDellaCondivisione.condivisionePrivata => Icons.send_rounded,
      };
}

/// LA PALETTE DEL SENTIERO: il colore del Maestro che lo governa.
MaestroPalette paletteDelSentiero(Sentiero sentiero) =>
    MaestroPalette.forKey(ThemeKey.of(sentiero.maestro));
