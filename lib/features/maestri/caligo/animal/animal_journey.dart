import 'package:flutter/material.dart';

import '../../../../core/rituals/animal_catalog.dart';
import '../../../../core/rituals/animal_constellations.dart';
import '../../../../core/sensi/palette_sensoriale.dart';
import '../../../../design_system/components/scroll_reveal.dart';
import '../../../../design_system/components/stelle_da_unire.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';

/// LA RIVELAZIONE A COSTELLAZIONE, ordine L voce 3c.
///
/// Il tocco ripetuto sul tamburo NON ESISTE PIU': l'animale si rivela unendo
/// le stelle della SUA costellazione, coi punti cardinali presi dalla sua
/// sagoma (testa, garrese, zampe, coda), dichiarati in
/// `kCostellazioniAnimali`. Unite le stelle nasce la sagoma; poi la sagoma si
/// riempie nella rivelazione e l'animale appare.
///
/// La meccanica del tocco in sequenza e' il componente UNICO `StelleDaUnire`,
/// lo stesso del Sigillo del Sogno: la stella che aspetta il tocco e' l'unica
/// accesa e pulsa, e con Riduci Movimento resta accesa e ferma. Il ripiego
/// resta: il tasto che porta subito alla rivelazione.
class AnimalJourney extends StatefulWidget {
  const AnimalJourney({
    super.key,
    required this.palette,
    required this.animal,
    required this.onComplete,
  });

  final MaestroPalette palette;

  /// L'animale del giorno: la sua costellazione, non un disegno generico.
  final GuideAnimal animal;

  final VoidCallback onComplete;

  @override
  State<AnimalJourney> createState() => _AnimalJourneyState();
}

class _AnimalJourneyState extends State<AnimalJourney> {
  bool _fatto = false;
  int _unite = 0;

  late final CostellazioneAnimale _costellazione =
      costellazioneDi(widget.animal.name);

  void _allUnione(int indice) {
    PaletteSensoriale.eseguiSchema(SchemaAptico.conferma);
    setState(() => _unite = indice + 1);
  }

  void _concludi() {
    if (_fatto) return;
    _fatto = true;
    // Un attimo perche' la sagoma unita resti negli occhi, poi la
    // rivelazione. Con Riduci Movimento la figura si compone senza volo e
    // il passaggio e' immediato: chi toglie il moto non perde il rito.
    // LETTURA SENZA ASCOLTO: siamo dentro un gesto, non in una build, e
    // Provider con l'ascolto acceso qui solleva. Preso dalla cattura ad
    // animazioni accese: la prova col solo Riduci Movimento usciva prima
    // della lettura e non lo vedeva.
    final attesa = ScrollReveal.motionOff(context, listen: false)
        ? Duration.zero
        : const Duration(milliseconds: 900);
    Future<void>.delayed(attesa, () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final figura = _costellazione.figura;
    const lato = 320.0;
    return Padding(
      key: const Key('animal_journey'),
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        children: [
          const SizedBox(height: SpacingTokens.sm),
          Text(
              _fatto
                  ? 'La sagoma è unita: il tuo animale arriva.'
                  : 'Unisci le stelle: la costellazione del tuo animale ti aspetta.',
              key: const Key('animal_journey_guide'),
              textAlign: TextAlign.center,
              style: TypographyTokens.body(size: 16)
                  .copyWith(color: ColorTokens.textPrimary, height: 1.5)),
          const SizedBox(height: SpacingTokens.lg),
          Expanded(
            child: Center(
              child: SizedBox(
                width: lato,
                height: lato,
                child: Stack(
                  children: [
                    // Il cielo dietro la costellazione: un alone quieto.
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(colors: [
                            palette.primary.withValues(alpha: 0.16),
                            palette.deepest.withValues(alpha: 0.10),
                            Colors.transparent,
                          ], stops: const [0.0, 0.6, 1.0]),
                        ),
                      ),
                    ),
                    // IL COMPONENTE UNICO: stelle grandi, una alla volta.
                    Positioned.fill(
                      child: StelleDaUnire(
                        figura: figura,
                        palette: palette,
                        keyPrefix: 'animal_star',
                        // La sagoma vive nel quadrato con un margine.
                        mappa: (p) => Offset(
                          (0.08 + p.dx * 0.84) * lato,
                          (0.08 + p.dy * 0.84) * lato,
                        ),
                        onTocco: _allUnione,
                        onCompleta: _concludi,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          // Le stelle unite, in pallini: la piccola fatica si vede.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < figura.punti.length; i++) ...[
                if (i > 0) const SizedBox(width: SpacingTokens.xs),
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < _unite
                        ? palette.goldSoft
                        : palette.gold.withValues(alpha: 0.2),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: SpacingTokens.sm),
          TextButton(
            key: const Key('animal_journey_skip'),
            onPressed: _concludi,
            child: Text('Portami all\'animale',
                style: TypographyTokens.label(size: 12)
                    .copyWith(color: palette.goldSoft)),
          ),
        ],
      ),
    );
  }
}
