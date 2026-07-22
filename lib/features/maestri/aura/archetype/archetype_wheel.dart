import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/archetypes/archetype.dart';
import '../../../../core/archetypes/archetype_scoring.dart';
import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import 'archetype_glyphs.dart';

/// La ruota astrolabio del profilo archetipico.
///
/// E' il livello visivo che arriva prima del testo: si legge il profilo a colpo
/// d'occhio, con la fetta del dominante accesa in oro, prima di leggere una
/// sola parola. La statua NON sta dentro la ruota, sta sopra: qui c'e' solo il
/// cielo dei dodici.
///
/// Divisa in dodici fette. L'anello esterno porta i dodici nomi, ognuno nel suo
/// slot, col testo tenuto sempre DRITTO e leggibile: le etichette della meta'
/// bassa non si capovolgono. Accanto a ogni nome un piccolo glifo essenziale.
class ArchetypeWheel extends StatelessWidget {
  const ArchetypeWheel({
    super.key,
    required this.profilo,
    required this.palette,
    this.avanzamento = 1.0,
    this.lato = 340,
    this.etichette = true,
  });

  final ArchetypeProfile profilo;
  final MaestroPalette palette;

  /// Da zero a uno: quanto e' posato l'astrolabio. A uno la ruota e' intera e
  /// la fetta del dominante e' accesa.
  final double avanzamento;

  final double lato;

  /// Le etichette esterne coi glifi. Si spengono nella mini-ruota della card.
  final bool etichette;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('archetype_wheel'),
      width: lato,
      height: lato,
      child: CustomPaint(
        painter: _AstrolabioPainter(
          profilo: profilo,
          palette: palette,
          avanzamento: avanzamento.clamp(0.0, 1.0),
          etichette: etichette,
        ),
      ),
    );
  }
}

class _AstrolabioPainter extends CustomPainter {
  _AstrolabioPainter({
    required this.profilo,
    required this.palette,
    required this.avanzamento,
    required this.etichette,
  });

  final ArchetypeProfile profilo;
  final MaestroPalette palette;
  final double avanzamento;
  final bool etichette;

  static const int n = 12;
  static const double _passo = 2 * math.pi / n;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final margine = etichette ? size.shortestSide * 0.19 : size.shortestSide * 0.04;
    final r = size.shortestSide / 2 - margine;
    if (r <= 0) return;

    final iDom = profilo.dominante.ordineCanonico;

    // La fetta del dominante, accesa in oro, disegnata per prima cosi' sta
    // sotto le linee. Cresce col posarsi dell'astrolabio.
    final aStart = _angoloFetta(iDom) - _passo / 2;
    canvas.drawPath(
      Path()
        ..moveTo(c.dx, c.dy)
        ..arcTo(Rect.fromCircle(center: c, radius: r), aStart,
            _passo * avanzamento, false)
        ..close(),
      Paint()
        ..style = PaintingStyle.fill
        ..color = palette.gold.withValues(alpha: 0.20 * avanzamento),
    );

    // Le tre corone di riferimento: danno la scala senza numeri.
    final filo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = palette.gold.withValues(alpha: 0.22);
    for (final q in [0.34, 0.67, 1.0]) {
      canvas.drawCircle(c, r * q, filo);
    }

    // Le dodici linee di divisione delle fette.
    final divisione = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = palette.gold.withValues(alpha: 0.16);
    for (var i = 0; i < n; i++) {
      final a = _angoloFetta(i) - _passo / 2;
      canvas.drawLine(c, c + Offset(math.cos(a), math.sin(a)) * r, divisione);
    }

    // Il profilo, poligono a dodici vertici sulle fette.
    final massimo =
        Archetype.values.map(profilo.percentualeDi).fold<double>(0.0001, math.max);
    final punti = <Offset>[];
    for (var i = 0; i < n; i++) {
      final quota = profilo.percentualeDi(Archetype.values[i]) / massimo;
      final lung = r * (0.10 + 0.90 * quota) * avanzamento;
      final a = _angoloFetta(i);
      punti.add(c + Offset(math.cos(a), math.sin(a)) * lung);
    }
    final forma = Path()..addPolygon(punti, true);
    canvas.drawPath(
      forma,
      Paint()
        ..style = PaintingStyle.fill
        ..color = palette.primary.withValues(alpha: 0.28 * avanzamento),
    );
    canvas.drawPath(
      forma,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = palette.glow.withValues(alpha: 0.85 * avanzamento),
    );

    // Il vertice del dominante, un punto d'oro sulla sua fetta.
    canvas.drawCircle(punti[iDom], 5.5 * avanzamento, Paint()..color = palette.goldSoft);

    if (!etichette) return;

    // L'anello esterno: nome e glifo per ogni slot, testo sempre dritto.
    for (var i = 0; i < n; i++) {
      final a = _angoloFetta(i);
      final dir = Offset(math.cos(a), math.sin(a));
      final dom = i == iDom;
      final ancora = c + dir * (r + margine * 0.52);

      // Il glifo, appena sopra il nome verso il centro.
      _disegnaGlifo(canvas, Archetype.values[i],
          c + dir * (r + margine * 0.16),
          margine * 0.34,
          (dom ? palette.goldSoft : palette.textSecondary)
              .withValues(alpha: dom ? 1.0 : 0.85));

      final tp = TextPainter(
        text: TextSpan(
          text: Archetype.values[i].nome.toUpperCase(),
          style: TypographyTokens.label(size: dom ? 10 : 9).copyWith(
            color: dom
                ? palette.goldSoft
                : palette.textSecondary.withValues(alpha: 0.85),
            letterSpacing: 0.5,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: margine * 2.6);
      // Il testo resta orizzontale, mai capovolto: le etichette della meta'
      // bassa NON si girano sottosopra.
      canvas.save();
      canvas.translate(ancora.dx, ancora.dy);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }
  }

  void _disegnaGlifo(
      Canvas canvas, Archetype a, Offset centro, double raggio, Color colore) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, raggio * 0.16)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = colore;
    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = colore;
    ArchetypeGlyphs.disegna(a, canvas, centro, raggio, paint, fill);
  }

  /// L'angolo del centro della fetta i, in senso orario dall'alto.
  double _angoloFetta(int i) => -math.pi / 2 + i * _passo;

  @override
  bool shouldRepaint(_AstrolabioPainter old) =>
      old.avanzamento != avanzamento ||
      old.profilo.dominante != profilo.dominante ||
      old.etichette != etichette;
}
