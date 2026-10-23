import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../design_system/components/scroll_reveal.dart';
import '../../../../design_system/theme/maestro_palette.dart';

/// La rivelazione del totem nella nebbia rossa e oro di Caligo.
///
/// La nebbia si dirada lentamente: prima si accendono gli occhi dell'animale nel
/// buio, poi emerge il totem intero, l'arte a bundle. Con Riduci Movimento o
/// Quality Tier basso la nebbia sparisce subito e si vede il totem, senza
/// l'animazione pesante.
class AnimalReveal extends StatefulWidget {
  const AnimalReveal({
    super.key,
    required this.assetTotem,
    required this.palette,
    this.lato = 300,
    this.conNebbia = true,
  });

  /// SOLO PER LA BUILD DIAGNOSTICA: a falso, il totem si mostra subito senza
  /// la nebbia che si dirada, lo stesso ramo di Riduci Movimento.
  final bool conNebbia;

  final String assetTotem;
  final MaestroPalette palette;
  final double lato;

  @override
  State<AnimalReveal> createState() => _AnimalRevealState();
}

class _AnimalRevealState extends State<AnimalReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!widget.conNebbia || ScrollReveal.motionOff(context)) {
      _c.value = 1.0; // subito il totem, nessuna nebbia
    } else if (!_c.isAnimating && _c.value == 0) {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;
    return SizedBox(
      key: const Key('animal_reveal'),
      width: widget.lato,
      height: widget.lato,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = _c.value;
          // Il totem emerge dopo che gli occhi si sono accesi.
          final totem = ((t - 0.3) / 0.7).clamp(0.0, 1.0);
          return Stack(
            fit: StackFit.expand,
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: totem,
                child: Image.asset(
                  widget.assetTotem,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(Icons.pets,
                      size: widget.lato * 0.5, color: palette.goldSoft),
                ),
              ),
              CustomPaint(
                painter: _NebbiaPainter(avanzamento: t, palette: palette),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// La nebbia rossa e oro che si dirada, con gli occhi che si accendono nel buio
/// prima che emerga il totem.
class _NebbiaPainter extends CustomPainter {
  _NebbiaPainter({required this.avanzamento, required this.palette});

  final double avanzamento;
  final MaestroPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final t = avanzamento;
    // La nebbia cala da piena a nulla.
    final densita = (1.0 - t).clamp(0.0, 1.0);
    if (densita > 0.01) {
      final c = Offset(size.width / 2, size.height / 2);

      // La nebbia sta DENTRO un ovale, per costruzione: nessun angolo del
      // riquadro puo' essere dipinto, nemmeno per sbaglio, nemmeno da un banco
      // di nebbia che sborda.
      //
      // Prima qui c'era un drawRect su tutta l'area con l'ultimo stop del
      // gradiente OPACO: il riquadro finiva di netto contro il fondo, quindi
      // prima che l'animale emergesse si vedeva un quadrato. Il difetto non era
      // il colore, era la forma.
      canvas.save();
      canvas.clipPath(Path()..addOval(Offset.zero & size));

      canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..shader = RadialGradient(
            colors: [
              palette.deepest.withValues(alpha: 0.55 * densita),
              palette.primary.withValues(alpha: 0.75 * densita),
              palette.deepest.withValues(alpha: 0.85 * densita),
              // L'ultimo stop e' trasparente: la nebbia si dissolve nel fondo
              // invece di finire con un bordo.
              palette.deepest.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.45, 0.82, 1.0],
          ).createShader(Offset.zero & size),
      );
      // Qualche banco di nebbia piu' denso, deterministico.
      final blob = Paint()
        ..color = palette.deepest.withValues(alpha: 0.5 * densita)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
      for (var i = 0; i < 5; i++) {
        final a = i * 1.2566; // 72 gradi
        // Raggi piu' raccolti di prima: i banchi restano nel cuore della
        // nebbia invece di premere contro il bordo del riquadro.
        final r = size.shortestSide * (0.16 + 0.05 * i);
        canvas.drawCircle(c + Offset(math.cos(a), math.sin(a)) * r,
            size.shortestSide * 0.18, blob);
      }
      canvas.restore();
    }

    // Gli occhi: si accendono presto (0.05..0.5), poi si spengono quando il
    // totem prende il loro posto.
    final occhi = t < 0.5
        ? (t / 0.5).clamp(0.0, 1.0)
        : (1.0 - (t - 0.5) / 0.35).clamp(0.0, 1.0);
    if (occhi > 0.01) {
      final cy = size.height * 0.42;
      final dx = size.width * 0.12;
      for (final segno in [-1, 1]) {
        final centro = Offset(size.width / 2 + segno * dx, cy);
        canvas.drawCircle(
          centro,
          size.shortestSide * 0.06,
          Paint()
            ..color = palette.gold.withValues(alpha: 0.5 * occhi)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
        );
        canvas.drawCircle(centro, size.shortestSide * 0.018,
            Paint()..color = palette.goldSoft.withValues(alpha: occhi));
      }
    }
  }

  @override
  bool shouldRepaint(_NebbiaPainter old) => old.avanzamento != avanzamento;
}
