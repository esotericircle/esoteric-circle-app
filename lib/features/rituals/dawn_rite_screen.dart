import 'package:flutter/material.dart';

import '../../core/maestro/maestro.dart';
import '../../core/rituals/daily_rituals.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'ritual_view.dart';

/// Rito dell'Alba: a rotazione tra i tre Maestri di giorno in giorno.
///
/// Contenuto deterministico dalla data: il Maestro di turno e il suo messaggio
/// del mattino. Livello visivo, un'alba, prima del testo. Gesto tattile
/// universale per riceverlo.
class DawnRiteScreen extends StatelessWidget {
  const DawnRiteScreen({super.key, this.now});

  final DateTime? now;

  static Route<void> route({DateTime? now}) => MaterialPageRoute<void>(
        builder: (_) => MaestroScope(child: DawnRiteScreen(now: now)),
      );

  @override
  Widget build(BuildContext context) {
    final date = now ?? DateTime.now();
    final maestro = DailyRituals.dawnMaestro(date);
    final palette = MaestroPalette.forKey(ThemeKey.of(maestro));
    final message = DailyRituals.dawnMessage(date);

    return RitualView(
      title: 'Rito dell\'Alba',
      palette: palette,
      // Fondale reale dell'alba, cablato nello slot condiviso: mare all'alba
      // con filigrana zodiacale. In sua assenza lo slot ripiega sul fondo
      // procedurale. Gli altri quattro riti restano ancora procedurali.
      backgroundAsset: 'assets/ritual_backgrounds/dawn.png',
      gesture: RitualGesture.tap,
      prompt: 'Tocca per ricevere il rito',
      sensorHint: 'Un gesto solo: tocca la scena per accogliere l\'alba.',
      // Il livello visivo dell'alba e' ora la foto reale nello slot fondale:
      // la scena resta trasparente, cosi' l'immagine non e' coperta e non si
      // sovrappone un secondo sole procedurale. Il gesto e la rivelazione del
      // responso restano invariati.
      visualBuilder: (context, revealed, t) => const SizedBox.expand(),
      revealed: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('L\'alba di ${maestro.displayName}',
              style: TypographyTokens.display(size: 18)
                  .copyWith(color: palette.goldSoft)),
          const SizedBox(height: SpacingTokens.sm),
          Text(message,
              style: TypographyTokens.body(size: 16)
                  .copyWith(color: ColorTokens.textPrimary, height: 1.5)),
        ],
      ),
    );
  }
}
