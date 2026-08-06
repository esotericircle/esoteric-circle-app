import 'package:flutter/material.dart';

import '../../core/rituals/daily_elements.dart';
import '../../core/rituals/voce_del_dono.dart';
import '../theme/accento_del_maestro.dart';
import '../tokens/spacing_tokens.dart';
import '../tokens/typography_tokens.dart';

/// LA RIGA CHE DICE CHI PARLA, sopra il contenuto di ogni Dono.
///
/// La frase la compone `VoceDelDono`, che e' il punto unico; qui c'e' solo come
/// si vede. Le due cose restano separate perche' la frase serve anche dove non
/// c'e' uno schermo, per esempio a una prova che enumera tutti i Doni.
///
/// **Il colore e' quello del Maestro del giorno, portato dove si legge.**
/// Passa da `AccentoDelMaestro`, la stessa regola della scheda dei Doni: chi
/// monta questa riga dichiara su che superficie la sta appoggiando, e il colore
/// sale o scende di quanto basta. Il verde di Aura preso com'e' non passerebbe
/// su nessuna delle due.
class RigaDelDono extends StatelessWidget {
  const RigaDelDono({
    super.key,
    required this.dono,
    required this.giorno,
    required this.superficie,
  });

  final DailyElement dono;
  final DateTime giorno;

  /// Il colore su cui questa riga viene appoggiata. Non si indovina dal tema:
  /// le schermate dei riti dipingono il proprio fondale, e il tema non lo sa.
  final Color superficie;

  @override
  Widget build(BuildContext context) {
    final maestro = DailyElements.maestroFor(dono, giorno);
    final accento = AccentoDelMaestro.su(maestro, superficie: superficie);
    return Padding(
      key: const Key('riga_del_dono'),
      padding: const EdgeInsets.only(bottom: SpacingTokens.sm),
      child: Row(
        children: [
          Icon(maestro.icon, size: 15, color: accento),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              VoceDelDono.frase(dono: dono, giorno: giorno),
              style: TypographyTokens.label(size: 12).copyWith(
                color: accento,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
