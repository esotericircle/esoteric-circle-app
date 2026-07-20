import 'package:flutter/material.dart';

import '../../core/tarot/tarot_card.dart';
import '../../core/tarot/tarot_spread.dart';
import '../../design_system/theme/maestro_palette.dart';

/// L'espressione di Medora mentre presiede la stesa.
///
/// Non e' un capriccio: nasce in modo deterministico dalla carta attiva, cosi'
/// la stessa carta da' sempre la stessa presenza.
enum MedoraExpression {
  /// Nessuna carta ancora scelta, oppure una carta neutra: presenza quieta.
  serena('serena'),

  /// Carta dritta che apre bene: sorriso caldo.
  sorrisoCaldo('sorriso caldo'),

  /// Carta rovesciata, o Arcano Maggiore severo: sguardo grave.
  sguardoGrave('sguardo grave');

  const MedoraExpression(this.label);

  final String label;

  /// L'espressione per la carta attiva. Senza carta, Medora resta serena.
  ///
  /// Dritto porta luce, rovesciato porta ombra, e i Maggiori pesano di piu' dei
  /// Minori, come si conviene a un Arcano.
  static MedoraExpression forCard(DrawnCard? drawn) {
    if (drawn == null) return MedoraExpression.serena;
    if (drawn.reversed) return MedoraExpression.sguardoGrave;
    return drawn.card.arcana == TarotArcana.maggiore
        ? MedoraExpression.sorrisoCaldo
        : MedoraExpression.serena;
  }
}

/// La scena di Medora: il mezzo busto che presiede la stesa, con le carte
/// davanti a lei.
///
/// Oggi mostra il segnaposto `brand_assets/avatars/Medora-1.png` che respira con
/// un micro movimento di scala e un alone che pulsa. Gli stati (espressione,
/// carta attiva, luce o ombra) sono gia' quelli definitivi: quando arrivera'
/// l'animazione finale bastera' sostituire il corpo della scena, senza rifare ne'
/// gli stati ne' il resto della schermata.
class MedoraStage extends StatefulWidget {
  const MedoraStage({
    super.key,
    required this.palette,
    this.active,
    this.height = 320,
    this.breathe = true,
  });

  final MaestroPalette palette;

  /// La carta su cui Medora posa lo sguardo, se ce n'e' una.
  final DrawnCard? active;

  final double height;

  /// Respiro e pulsazione. Con Riduci Movimento la scena resta ferma.
  final bool breathe;

  /// Il ritratto unico, che c'e' sempre. E' il ripiego: se i tre ritratti
  /// d'espressione non sono ancora stati prodotti, la scena usa questo e non
  /// resta mai vuota.
  static const String placeholderAsset = 'brand_assets/avatars/Medora-1.png';

  /// I tre ritratti d'espressione, che Mauro produrra'.
  ///
  /// Stanno nella cartella gia' dichiarata nel pubspec, quindi entrano nel
  /// bundle appena compaiono, senza toccare il codice. Finche' mancano,
  /// `Image.asset` finisce nel suo ripiego e si vede il ritratto unico: mai un
  /// vuoto, mai un errore a video.
  static const Map<MedoraExpression, String> ritratti = {
    MedoraExpression.serena: 'brand_assets/avatars/Medora-serena.png',
    MedoraExpression.sorrisoCaldo: 'brand_assets/avatars/Medora-sorriso.png',
    MedoraExpression.sguardoGrave: 'brand_assets/avatars/Medora-grave.png',
  };

  /// Il ritratto che spetta a un'espressione.
  static String assetFor(MedoraExpression e) =>
      ritratti[e] ?? placeholderAsset;

  /// Quanta parte dell'avatar a figura intera resta in scena: dalla testa fino
  /// sotto le mani che reggono le carte.
  static const double bustoFactor = 0.58;

  @override
  State<MedoraStage> createState() => _MedoraStageState();
}

class _MedoraStageState extends State<MedoraStage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4200),
  );

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final ferma = !widget.breathe || MediaQuery.of(context).disableAnimations;
    if (ferma) {
      _pulse.value = 0.5;
    } else {
      _pulse.repeat();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    final expression = MedoraExpression.forCard(widget.active);
    // Dritto porta luce, rovesciato porta ombra.
    final ombra = widget.active?.reversed ?? false;
    final maggiore = widget.active?.card.arcana == TarotArcana.maggiore;

    return SizedBox(
      key: const Key('medora_stage'),
      height: widget.height,
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, _) {
          // Respiro: un micro movimento di scala, appena percepibile.
          final t = _pulse.value;
          final respiro = 1 - (t - 0.5).abs() * 2; // 0..1..0
          final scala = 1.0 + 0.012 * respiro;
          final alone = 0.10 + (ombra ? 0.06 : 0.16) * respiro;
          final enfasi = maggiore ? 1.25 : 1.0;

          return Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // L'alone che pulsa dietro la presenza.
              Center(
                child: Container(
                  width: widget.height * 0.92 * enfasi,
                  height: widget.height * 0.92 * enfasi,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      (ombra ? palette.primary : palette.gold)
                          .withValues(alpha: alone),
                      palette.glow.withValues(alpha: alone * 0.5),
                      Colors.transparent,
                    ], stops: const [
                      0.0,
                      0.55,
                      1.0
                    ]),
                  ),
                ),
              ),
              // Il mezzo busto, che respira.
              Transform.scale(
                scale: scala,
                alignment: Alignment.bottomCenter,
                child: ShaderMask(
                  // Sul rovesciato la presenza si incupisce.
                  blendMode: BlendMode.srcATop,
                  shaderCallback: (rect) => LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: ombra
                        ? [
                            palette.deepest.withValues(alpha: 0.35),
                            palette.deepest.withValues(alpha: 0.10),
                          ]
                        : [
                            palette.gold.withValues(alpha: 0.10),
                            Colors.transparent,
                          ],
                  ).createShader(rect),
                  // Mezzo busto: dell'avatar a figura intera si tiene la parte
                  // alta, cosi' Medora presiede da vicino. L'OverflowBox serve
                  // perche' altrimenti lo Stack schiaccerebbe l'immagine prima
                  // del ritaglio, e resterebbe una figura intera rimpicciolita.
                  child: SizedBox(
                    height: widget.height,
                    // Il taglio del busto sfuma, non e' una linea netta.
                    child: ShaderMask(
                      blendMode: BlendMode.dstIn,
                      shaderCallback: (rect) => const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white,
                          Colors.white,
                          Colors.transparent
                        ],
                        stops: [0.0, 0.86, 1.0],
                      ).createShader(rect),
                      child: ClipRect(
                        child: OverflowBox(
                          alignment: Alignment.topCenter,
                          minHeight: widget.height / MedoraStage.bustoFactor,
                          maxHeight: widget.height / MedoraStage.bustoFactor,
                          child: Image.asset(
                            MedoraStage.placeholderAsset,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Lo stato, leggibile dai test e dagli strumenti.
              Positioned(
                bottom: 0,
                child: Semantics(
                  label: 'Medora, ${expression.label}',
                  child: const SizedBox.shrink(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
