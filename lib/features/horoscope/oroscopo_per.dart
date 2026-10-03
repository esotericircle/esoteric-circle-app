import 'package:flutter/material.dart';

import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// **IL SELETTORE "OROSCOPO PER".** Ordine EU voce 05, 1 ottobre 2026.
///
/// Il fondatore: *"voglio un selettore proprio sopra il selettore di giorno,
/// settimana, mese, anno) in cui l'utente può scegliere se vuole consultare
/// l'oroscopo per se stesso o un amico/a. Quindi un testo "oroscopo per" +
/// pulsante [nome utente] predefinito + pulsante [amico/a]. Se fai click su
/// [amico/a] compare la schermata "i tuoi amici". Così scompare il pulsante
/// in alto che è poco visibile."*
///
/// Lo usano due schermate: l'Oroscopo della persona, dove e' scelto il suo
/// nome, e la lettura dell'amico, dove e' scelto il nome dell'amico e il nome
/// della persona riporta alla sua lettura. Una riga sola: se il carattere
/// ingrandito non la fa stare, si rimpicciolisce intera, come il selettore
/// dei periodi.
class OroscopoPer extends StatelessWidget {
  const OroscopoPer({
    super.key,
    required this.nomeTuo,
    required this.palette,
    required this.onTe,
    required this.onAmico,
    this.nomeAmico,
  });

  /// Il nome della persona, o "te" se l'app non lo conosce.
  final String nomeTuo;

  /// Il nome dell'amico di cui si legge l'oroscopo; senza, "amico/a".
  final String? nomeAmico;

  final MaestroPalette palette;

  /// Il tocco sul nome della persona: la sua lettura.
  final VoidCallback onTe;

  /// Il tocco sul secondo pulsante: la schermata "I tuoi amici".
  final VoidCallback onAmico;

  @override
  Widget build(BuildContext context) {
    final perTe = nomeAmico == null;
    Widget scelta(
            String chiave, String testo, bool scelto, VoidCallback tocco) =>
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.xs / 2),
          child: ChoiceChip(
            key: Key(chiave),
            showCheckmark: false,
            shape: const StadiumBorder(),
            side: BorderSide(
                color: palette.gold.withValues(alpha: scelto ? 0.7 : 0.25)),
            backgroundColor: palette.surfaceElevated.withValues(alpha: 0.45),
            selectedColor: palette.primary,
            label: Text(testo,
                maxLines: 1,
                softWrap: false,
                style: TypographyTokens.etichetta().copyWith(
                    color:
                        scelto ? palette.goldSoft : ColorTokens.textSecondary)),
            selected: scelto,
            onSelected: (_) => tocco(),
          ),
        );
    return FittedBox(
      key: const Key('oroscopo_per'),
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Oroscopo per',
              style: TypographyTokens.didascalia()
                  .copyWith(color: ColorTokens.textSecondary)),
          const SizedBox(width: SpacingTokens.xs),
          scelta('oroscopo_per_te', nomeTuo, perTe, onTe),
          scelta('oroscopo_per_amico', nomeAmico ?? 'amico/a', !perTe, onAmico),
        ],
      ),
    );
  }
}
