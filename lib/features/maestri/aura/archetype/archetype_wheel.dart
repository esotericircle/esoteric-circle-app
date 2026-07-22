import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/archetypes/archetype.dart';
import '../../../../core/archetypes/archetype_scoring.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/tokens/typography_tokens.dart';

/// La ruota a dodici raggi del profilo archetipico.
///
/// E' il livello visivo che arriva prima del testo: si legge il profilo a colpo
/// d'occhio, col raggio del dominante acceso, prima di leggere una sola parola.
///
/// Le etichette stanno FUORI dalla ruota e in chiaro, mai in minuscolo, cosi'
/// restano leggibili anche quando il raggio e' corto. I dodici sono nell'ordine
/// canonico, in senso orario dall'alto.
class ArchetypeWheel extends StatelessWidget {
  const ArchetypeWheel({
    super.key,
    required this.profilo,
    required this.palette,
    this.avanzamento = 1.0,
    this.lato = 300,
    this.etichette = true,
  });

  final ArchetypeProfile profilo;
  final MaestroPalette palette;

  /// Da zero a uno: quanto e' disegnato il profilo. A uno la ruota e' intera.
  final double avanzamento;

  final double lato;

  /// Le etichette esterne. Si spengono nella mini-ruota della card.
  final bool etichette;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('archetype_wheel'),
      width: lato,
      height: lato,
      child: CustomPaint(
        painter: _RuotaPainter(
          profilo: profilo,
          palette: palette,
          avanzamento: avanzamento.clamp(0.0, 1.0),
          etichette: etichette,
        ),
      ),
    );
  }
}

class _RuotaPainter extends CustomPainter {
  _RuotaPainter({
    required this.profilo,
    required this.palette,
    required this.avanzamento,
    required this.etichette,
  });

  final ArchetypeProfile profilo;
  final MaestroPalette palette;
  final double avanzamento;
  final bool etichette;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    // Spazio per le etichette esterne, quando ci sono.
    final margine = etichette ? size.shortestSide * 0.20 : size.shortestSide * 0.04;
    final r = size.shortestSide / 2 - margine;
    if (r <= 0) return;

    final massimo = Archetype.values
        .map(profilo.percentualeDi)
        .fold<double>(0.0001, math.max);

    final filo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = palette.gold.withValues(alpha: 0.22);

    // Le tre corone di riferimento: danno la scala senza numeri.
    for (final q in [0.34, 0.67, 1.0]) {
      canvas.drawCircle(c, r * q, filo);
    }

    // I dodici raggi, in senso orario dall'alto.
    final raggio = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = palette.gold.withValues(alpha: 0.16);
    for (var i = 0; i < Archetype.values.length; i++) {
      final a = _angolo(i);
      canvas.drawLine(c, c + Offset(math.cos(a), math.sin(a)) * r, raggio);
    }

    // Il profilo: un poligono a dodici vertici che si disegna col progresso.
    final punti = <Offset>[];
    for (var i = 0; i < Archetype.values.length; i++) {
      final quota = profilo.percentualeDi(Archetype.values[i]) / massimo;
      final lung = r * (0.10 + 0.90 * quota) * avanzamento;
      final a = _angolo(i);
      punti.add(c + Offset(math.cos(a), math.sin(a)) * lung);
    }
    final forma = Path()..addPolygon(punti, true);
    canvas.drawPath(
      forma,
      Paint()
        ..style = PaintingStyle.fill
        ..color = palette.primary.withValues(alpha: 0.30 * avanzamento),
    );
    canvas.drawPath(
      forma,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = palette.glow.withValues(alpha: 0.85 * avanzamento),
    );

    // Il raggio del dominante si accende: e' la cosa che l'occhio deve trovare
    // per prima.
    final iDom = profilo.dominante.ordineCanonico;
    final aDom = _angolo(iDom);
    final finoA = c + Offset(math.cos(aDom), math.sin(aDom)) * r;
    canvas.drawLine(
      c,
      Offset.lerp(c, finoA, avanzamento)!,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..color = palette.goldSoft.withValues(alpha: 0.95),
    );
    canvas.drawCircle(
      Offset.lerp(c, punti[iDom], 1.0)!,
      5.5 * avanzamento,
      Paint()..color = palette.goldSoft,
    );

    if (!etichette) return;

    // Le etichette esterne, in chiaro e mai minuscole.
    for (var i = 0; i < Archetype.values.length; i++) {
      final a = _angolo(i);
      final dir = Offset(math.cos(a), math.sin(a));
      final dom = i == iDom;
      final tp = TextPainter(
        text: TextSpan(
          text: Archetype.values[i].nome.toUpperCase(),
          style: TypographyTokens.label(size: dom ? 10 : 9).copyWith(
            color: dom
                ? palette.goldSoft
                : palette.textSecondary.withValues(alpha: 0.85),
            letterSpacing: 0.6,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: margine * 2.4);
      final ancora = c + dir * (r + margine * 0.42);
      canvas.save();
      canvas.translate(ancora.dx, ancora.dy);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }

  /// L'angolo del raggio i, in senso orario partendo dall'alto.
  double _angolo(int i) =>
      -math.pi / 2 + i * 2 * math.pi / Archetype.values.length;

  @override
  bool shouldRepaint(_RuotaPainter old) =>
      old.avanzamento != avanzamento ||
      old.profilo.dominante != profilo.dominante ||
      old.etichette != etichette;
}
