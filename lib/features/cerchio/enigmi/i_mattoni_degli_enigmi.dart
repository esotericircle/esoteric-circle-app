import 'package:flutter/material.dart';

import '../../../design_system/theme/maestro_palette.dart';
import '../../../design_system/tokens/color_tokens.dart';
import '../../../design_system/tokens/spacing_tokens.dart';
import '../../../design_system/tokens/typography_tokens.dart';

/// I MATTONI DEGLI ENIGMI DEL CERCHIO, ordine FF: il pulsante d'oro, il
/// titolo di sezione e la riga del tempo che resta, gli stessi della
/// schermata del Cerchio.
class PulsanteDegliEnigmi extends StatelessWidget {
  const PulsanteDegliEnigmi({
    super.key,
    required this.etichetta,
    required this.onPressed,
    this.icona,
    this.segno,
  });

  final String etichetta;
  final VoidCallback? onPressed;
  final IconData? icona;

  /// Un segno disegnato al posto dell'icona: il denaro del Cerchio,
  /// `IconaDegliEos`, sui gesti che costano Eos.
  final Widget? segno;

  @override
  Widget build(BuildContext context) {
    const palette = MaestroPalette.neutral;
    final stile = FilledButton.styleFrom(
      backgroundColor: palette.gold,
      foregroundColor: palette.onPrimary,
      minimumSize: const Size.fromHeight(48),
    );
    final testo = Text(etichetta, style: TypographyTokens.etichetta());
    if (segno != null) {
      return FilledButton.icon(
          style: stile, onPressed: onPressed, icon: segno!, label: testo);
    }
    return icona == null
        ? FilledButton(style: stile, onPressed: onPressed, child: testo)
        : FilledButton.icon(
            style: stile,
            onPressed: onPressed,
            icon: Icon(icona),
            label: testo);
  }
}

class SezioneDegliEnigmi extends StatelessWidget {
  const SezioneDegliEnigmi(this.titolo, {super.key});
  final String titolo;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(
            top: SpacingTokens.lg, bottom: SpacingTokens.xs),
        child: Text(titolo.toUpperCase(),
            style: TypographyTokens.etichetta().copyWith(
                color: MaestroPalette.neutral.goldSoft, letterSpacing: 1.4)),
      );
}

/// Un testo secondario, il grigio che il censimento dei contrasti conosce.
class RigaDegliEnigmi extends StatelessWidget {
  const RigaDegliEnigmi(this.testo, {super.key, this.oro = false});
  final String testo;
  final bool oro;

  @override
  Widget build(BuildContext context) => Text(testo,
      style: TypographyTokens.corpo().copyWith(
          color:
              oro ? MaestroPalette.neutral.goldSoft : ColorTokens.textSecondary,
          height: 1.4));
}
