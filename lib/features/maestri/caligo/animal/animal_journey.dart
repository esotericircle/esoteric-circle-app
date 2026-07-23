import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../design_system/components/scroll_reveal.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';

/// Il viaggio sciamanico prima della rivelazione, fedele al core shamanism di
/// Harner: l'animale di potere non viene detto, lo trovi viaggiando col tamburo.
///
/// L'utente tocca a ritmo il tamburo di Caligo, alone rosso e oro, e a ogni
/// battito la nebbia si apre un poco e dal punto colpito partono le onde della
/// pelle; dopo pochi battiti si accendono gli occhi dell'animale e il viaggio si
/// conclude, passando alla rivelazione. Piccola fatica prima del dono, mai un
/// gioco difficile. Ripiego sempre presente: con Riduci Movimento basta un tocco
/// solo, e c'e' comunque il tasto per arrivare subito. Deterministico, nessuna AI.
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
    super.dispose();
  }

  double get _progresso => (_battiti / _soglia).clamp(0.0, 1.0);

  void _colpisci(TapDownDetails d, Size size) {
    if (_fatto) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _battiti++;
      _colpo = Offset(
        (d.localPosition.dx / size.width).clamp(0.0, 1.0),
        (d.localPosition.dy / size.height).clamp(0.0, 1.0),
      );
    });
    if (_animazioni) _onda.forward(from: 0);
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
                onTapDown: (d) =>
                    _colpisci(d, const Size(lato, lato)),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: lato,
                  height: lato,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_pulse, _onda]),
                    builder: (context, _) => CustomPaint(
                      painter: _TamburoPainter(
                        palette: palette,
                        pulsazione: _pulse.value,
                        progresso: _progresso,
                        onda: _onda.isAnimating ? _onda.value : -1,
                        colpo: _colpo,
                      ),
                    ),
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

/// Il tamburo sciamanico di Caligo, in 2.5D: cerchio di legno con lo spessore
/// del bordo, la pelle tesa con una texture leggera e il sigillo caligo al
/// centro, un battente appoggiato di traverso. A ogni battito, cerchi
/// concentrici si propagano dal punto colpito, come le onde di un tamburo
/// suonato. Alone rosso e oro che respira.
class _TamburoPainter extends CustomPainter {
  _TamburoPainter({
    required this.palette,
    required this.pulsazione,
    required this.progresso,
    required this.onda,
    required this.colpo,
  });

  final MaestroPalette palette;
  final double pulsazione;
  final double progresso;

  /// Avanzamento dell'onda, da zero a uno, oppure negativo se non c'e' onda.
  final double onda;

  /// Punto colpito, normalizzato nella superficie.
  final Offset colpo;

  static const Color _legnoAlto = Color(0xFF7A4A2C);
  static const Color _legnoBasso = Color(0xFF3B2113);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.shortestSide * 0.32; // raggio della pelle
    final spessore = r * 0.16; // spessore del bordo di legno
    final rLegno = r + spessore;

    // Alone caldo che respira, rosso e oro, dietro tutto.
    final alone = 0.85 + 0.15 * pulsazione;
    canvas.drawCircle(
      c,
      rLegno * 1.55 * alone,
      Paint()
        ..shader = RadialGradient(colors: [
          palette.gold.withValues(alpha: 0.3 * pulsazione),
          palette.primary.withValues(alpha: 0.0),
        ]).createShader(Rect.fromCircle(center: c, radius: rLegno * 1.55 * alone)),
    );

    // Ombra a terra sotto il tamburo, per lo stacco 2.5D.
    canvas.drawOval(
      Rect.fromCenter(
          center: c.translate(0, rLegno * 0.86),
          width: rLegno * 1.7,
          height: rLegno * 0.4),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );

    // Il cerchio di legno, con lo spessore visibile del bordo (2.5D): un anello
    // in gradiente verticale, piu' chiaro in alto e piu' scuro in basso.
    canvas.drawCircle(
      c,
      rLegno,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_legnoAlto, _legnoBasso],
        ).createShader(Rect.fromCircle(center: c, radius: rLegno)),
    );
    // Il filo d'oro sul cerchio esterno e su quello interno del bordo.
    final oro = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = palette.gold.withValues(alpha: 0.8);
    canvas.drawCircle(c, rLegno - 1, oro);
    canvas.drawCircle(c, r + 1, oro);

    // La pelle tesa: membrana chiara al centro, piu' scura al bordo.
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r)));
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [
            palette.surfaceElevated,
            palette.deepest,
          ],
          stops: const [0.0, 1.0],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    // Texture leggera della pelle: cerchi di grana tenui.
    final grana = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = palette.gold.withValues(alpha: 0.06);
    for (var i = 1; i <= 5; i++) {
      canvas.drawCircle(c, r * (i / 5.6), grana);
    }
    // Le onde del battito, dal punto colpito, dentro la pelle.
    if (onda >= 0) {
      final centro = Offset(colpo.dx * size.width, colpo.dy * size.height);
      for (var k = 0; k < 3; k++) {
        final fase = (onda - k * 0.16).clamp(0.0, 1.0);
        if (fase <= 0) continue;
        canvas.drawCircle(
          centro,
          fase * r * 1.4,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4 * (1 - fase)
            ..color = palette.goldSoft.withValues(alpha: 0.5 * (1 - fase)),
        );
      }
    }
    canvas.restore();

    // La legatura: piccole V d'oro che tendono la pelle al cerchio, a raggiera.
    final legatura = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = palette.gold.withValues(alpha: 0.6);
    for (var i = 0; i < 12; i++) {
      final a = i * math.pi / 6;
      final dir = Offset(math.cos(a), math.sin(a));
      final perp = Offset(-math.sin(a), math.cos(a));
      final estr = c + dir * rLegno;
      final baseA = c + dir * (r * 0.92) + perp * (r * 0.09);
      final baseB = c + dir * (r * 0.92) - perp * (r * 0.09);
      canvas.drawLine(estr, baseA, legatura);
      canvas.drawLine(estr, baseB, legatura);
    }

    // Il sigillo caligo al centro, una runa incisa nell'oro.
    _sigillo(canvas, c, r * 0.28, pulsazione);

    // Il battente appoggiato di traverso, sopra la pelle.
    _battente(canvas, size, r);

    // Gli occhi dell'animale che affiorano in cima col progredire del viaggio.
    if (progresso > 0.01) {
      final cy = c.dy - rLegno * 1.55;
      final dx = size.width * 0.09;
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

  /// Il sigillo di Caligo: un cerchio con una runa a tre bracci verso l'alto,
  /// incisa in oro, che pulsa piano.
  void _sigillo(Canvas canvas, Offset c, double raggio, double pulse) {
    final oro = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..color = palette.gold.withValues(alpha: 0.75 + 0.25 * pulse);
    canvas.drawCircle(c, raggio, oro);
    // Stelo verticale.
    canvas.drawLine(
        c.translate(0, raggio * 0.7), c.translate(0, -raggio * 0.7), oro);
    // Tre bracci verso l'alto, come un totem.
    canvas.drawLine(c.translate(0, -raggio * 0.15),
        c.translate(-raggio * 0.6, -raggio * 0.6), oro);
    canvas.drawLine(c.translate(0, -raggio * 0.15),
        c.translate(raggio * 0.6, -raggio * 0.6), oro);
    canvas.drawCircle(c.translate(0, -raggio * 0.7), 2.4,
        Paint()..color = palette.goldSoft.withValues(alpha: 0.9));
  }

  /// Il battente: uno stelo di legno con la testa imbottita, appoggiato di
  /// traverso sulla pelle, con la sua ombra.
  void _battente(Canvas canvas, Size size, double r) {
    final c = Offset(size.width / 2, size.height / 2);
    // Dallo spigolo in basso a sinistra allo spigolo in alto a destra.
    final coda = c + Offset(-r * 0.85, r * 0.62);
    final testa = c + Offset(r * 0.72, -r * 0.5);
    // Ombra dello stelo.
    canvas.drawLine(
        coda.translate(3, 6),
        testa.translate(3, 6),
        Paint()
          ..strokeWidth = 9
          ..strokeCap = StrokeCap.round
          ..color = Colors.black.withValues(alpha: 0.28)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    // Lo stelo di legno.
    canvas.drawLine(
        coda,
        testa,
        Paint()
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round
          ..shader = const LinearGradient(colors: [_legnoBasso, _legnoAlto])
              .createShader(Rect.fromPoints(coda, testa)));
    // Un filo d'oro lungo lo stelo.
    canvas.drawLine(
        coda,
        testa,
        Paint()
          ..strokeWidth = 1.4
          ..strokeCap = StrokeCap.round
          ..color = palette.gold.withValues(alpha: 0.4));
    // La testa imbottita.
    canvas.drawCircle(
        coda,
        r * 0.17,
        Paint()
          ..shader = RadialGradient(colors: [
            palette.primary,
            _legnoBasso,
          ]).createShader(Rect.fromCircle(center: coda, radius: r * 0.17)));
    canvas.drawCircle(
        coda,
        r * 0.17,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = palette.gold.withValues(alpha: 0.7));
  }

  @override
  bool shouldRepaint(_TamburoPainter old) =>
      old.pulsazione != pulsazione ||
      old.progresso != progresso ||
      old.onda != onda ||
      old.colpo != colpo;
}
