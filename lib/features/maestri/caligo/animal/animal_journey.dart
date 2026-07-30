import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../design_system/components/scroll_reveal.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import '../../../../core/sensi/palette_sensoriale.dart';

/// Il viaggio sciamanico prima della rivelazione, fedele al core shamanism di
/// Harner: l'animale di potere non viene detto, lo trovi viaggiando col tamburo.
///
/// Il tamburo e' l'arte di scena `tamburo_sciamanico_v1.webp`, con un leggero
/// bagliore dietro. L'utente lo tocca a ritmo: a ogni battito partono onde
/// concentriche dal punto colpito, sovrapposte all'immagine come overlay, con un
/// piccolo rimbalzo del tamburo e un feedback aptico; la nebbia si apre un poco e
/// gli occhi dell'animale affiorano. Dopo pochi battiti il viaggio si conclude e
/// si passa alla rivelazione. Piccola fatica prima del dono, mai un gioco
/// difficile. Ripiego sempre presente: con Riduci Movimento basta un tocco solo,
/// e c'e' comunque il tasto per arrivare subito. Deterministico, nessuna AI.
class AnimalJourney extends StatefulWidget {
  const AnimalJourney({
    super.key,
    required this.palette,
    required this.onComplete,
  });

  final MaestroPalette palette;
  final VoidCallback onComplete;

  @override
  State<AnimalJourney> createState() => _AnimalJourneyState();
}

class _AnimalJourneyState extends State<AnimalJourney>
    with TickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  /// L'onda che parte dal punto colpito a ogni battito.
  late final AnimationController _onda = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  );

  /// Il piccolo rimbalzo di scala del tamburo a ogni colpo.
  late final AnimationController _rimbalzo = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  /// Quanti battiti servono. Con Riduci Movimento basta un tocco.
  int _soglia = 6;
  int _battiti = 0;
  bool _fatto = false;
  bool _animazioni = true;

  /// Il punto dell'ultimo colpo, in coordinate normalizzate della pelle.
  Offset _colpo = const Offset(0.5, 0.5);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ScrollReveal.motionOff(context)) {
      _soglia = 1;
      _animazioni = false;
      _pulse.stop();
      _pulse.value = 1.0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    _onda.dispose();
    _rimbalzo.dispose();
    super.dispose();
  }

  double get _progresso => (_battiti / _soglia).clamp(0.0, 1.0);

  void _colpisci(TapDownDetails d, Size size) {
    if (_fatto) return;
    // Il tamburo del totem: conferma, non rivelazione. La rivelazione arriva
    // quando l'animale si mostra, non a ogni colpo.
    PaletteSensoriale.eseguiSchema(SchemaAptico.conferma);
    setState(() {
      _battiti++;
      _colpo = Offset(
        (d.localPosition.dx / size.width).clamp(0.0, 1.0),
        (d.localPosition.dy / size.height).clamp(0.0, 1.0),
      );
    });
    if (_animazioni) {
      _onda.forward(from: 0);
      _rimbalzo.forward(from: 0);
    }
    if (_battiti >= _soglia) _concludi();
  }

  void _concludi() {
    if (_fatto) return;
    _fatto = true;
    // Un attimo perche' gli occhi restino accesi, poi la rivelazione.
    Future<void>.delayed(const Duration(milliseconds: 350), () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    const lato = 300.0;
    return Padding(
      key: const Key('animal_journey'),
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        children: [
          const SizedBox(height: SpacingTokens.sm),
          Text('Tocca il tamburo a ritmo per chiamare il tuo animale dalla nebbia.',
              key: const Key('animal_journey_guide'),
              textAlign: TextAlign.center,
              style: TypographyTokens.body(size: 16)
                  .copyWith(color: ColorTokens.textPrimary, height: 1.5)),
          const SizedBox(height: SpacingTokens.lg),
          Expanded(
            child: Center(
              child: GestureDetector(
                key: const Key('animal_drum'),
                onTapDown: (d) => _colpisci(d, const Size(lato, lato)),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: lato,
                  height: lato,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_pulse, _onda, _rimbalzo]),
                    builder: (context, _) {
                      // Il rimbalzo: un piccolo pop che si smorza dopo il colpo.
                      final scala = 1.0 +
                          0.06 *
                              (1 - Curves.easeOut.transform(_rimbalzo.value)) *
                              (_rimbalzo.isAnimating ? 1.0 : 0.0);
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Il bagliore dietro il tamburo, che respira.
                          Container(
                            width: lato * 0.92,
                            height: lato * 0.92,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(colors: [
                                palette.gold.withValues(
                                    alpha: 0.26 * (0.7 + 0.3 * _pulse.value)),
                                palette.primary.withValues(alpha: 0.10),
                                palette.primary.withValues(alpha: 0.0),
                              ], stops: const [
                                0.0,
                                0.55,
                                1.0
                              ]),
                            ),
                          ),
                          // Il tamburo, l'arte di scena, col rimbalzo del colpo.
                          Transform.scale(
                            scale: scala,
                            child: Image.asset(
                              'assets/img/caligo/tamburo_sciamanico_v1.webp',
                              width: lato * 0.82,
                              height: lato * 0.82,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.medium,
                            ),
                          ),
                          // Le onde del battito e gli occhi, overlay sopra la
                          // immagine, non impressi in essa.
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _OndePainter(
                                palette: palette,
                                onda: _onda.isAnimating ? _onda.value : -1,
                                colpo: _colpo,
                                progresso: _progresso,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          // I battiti, in pallini che si accendono a ogni tocco.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < _soglia; i++) ...[
                if (i > 0) const SizedBox(width: SpacingTokens.xs),
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < _battiti
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

/// Solo le onde del battito e gli occhi che affiorano, come overlay sopra
/// l'immagine del tamburo. Il corpo del tamburo e il sigillo li da' l'immagine.
/// A ogni battito cerchi concentrici si propagano dal punto colpito, come le
/// onde di un tamburo suonato, in oro di Caligo; clip al disco della pelle.
class _OndePainter extends CustomPainter {
  _OndePainter({
    required this.palette,
    required this.onda,
    required this.colpo,
    required this.progresso,
  });

  final MaestroPalette palette;

  /// Avanzamento dell'onda, da zero a uno, oppure negativo se non c'e' onda.
  final double onda;

  /// Punto colpito, normalizzato nella superficie.
  final Offset colpo;

  /// Quanto e' avanzato il viaggio, per gli occhi che affiorano.
  final double progresso;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final rPelle = size.shortestSide * 0.34; // il disco della pelle del tamburo

    // Le onde, clip al disco della pelle cosi' restano sopra il tamburo.
    if (onda >= 0) {
      canvas.save();
      canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: rPelle)));
      final centro = Offset(colpo.dx * size.width, colpo.dy * size.height);
      for (var k = 0; k < 3; k++) {
        final fase = (onda - k * 0.16).clamp(0.0, 1.0);
        if (fase <= 0) continue;
        canvas.drawCircle(
          centro,
          fase * rPelle * 1.5,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.6 * (1 - fase)
            ..color = palette.goldSoft.withValues(alpha: 0.55 * (1 - fase)),
        );
      }
      canvas.restore();
    }

    // Gli occhi dell'animale che affiorano in cima col progredire del viaggio.
    if (progresso > 0.01) {
      final cy = c.dy - rPelle * 1.15;
      final dx = size.width * 0.08;
      for (final segno in [-1, 1]) {
        final centro = Offset(c.dx + segno * dx, cy);
        canvas.drawCircle(
            centro,
            10,
            Paint()
              ..color = palette.gold.withValues(alpha: 0.5 * progresso)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
        canvas.drawCircle(centro, 3.2,
            Paint()..color = palette.goldSoft.withValues(alpha: progresso));
      }
    }
  }

  @override
  bool shouldRepaint(_OndePainter old) =>
      old.onda != onda ||
      old.colpo != colpo ||
      old.progresso != progresso;
}
