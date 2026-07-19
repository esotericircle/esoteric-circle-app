import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/tarot/tarot_spread.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// La firma di una stesa: un sigillo unico e deterministico, una piccola
/// costellazione che unisce i simboli delle tre carte.
///
/// Nasce solo dagli identificativi delle tre carte e dal loro verso: la stessa
/// stesa da' sempre la stessa firma, stese diverse danno firme diverse. Non
/// dipende dall'ora ne' dal caso.
class SpreadSignature {
  const SpreadSignature({required this.seed, required this.nodes});

  /// Il seme da cui nasce il disegno, dalle tre carte e dai loro versi.
  final int seed;

  /// I nodi della costellazione, in coordinate normalizzate 0..1.
  final List<Offset> nodes;

  /// Quanti nodi ha la costellazione: uno per carta piu' i satelliti.
  static const int nodeCount = 7;

  /// Compone la firma di una stesa.
  static SpreadSignature of(TarotSpread spread) {
    final seed = seedOf(spread);
    final rnd = math.Random(seed);
    final nodes = <Offset>[];
    // Tre nodi maggiori, uno per carta, disposti sull'arco della stesa.
    for (var i = 0; i < spread.cards.length; i++) {
      final base = math.pi * (0.25 + 0.25 * i);
      final wobble = (rnd.nextDouble() - 0.5) * 0.5;
      final r = 0.30 + rnd.nextDouble() * 0.08;
      nodes.add(Offset(
        0.5 + math.cos(base + wobble) * r,
        0.5 + math.sin(base + wobble) * r * 0.8,
      ));
    }
    // Satelliti, per dare corpo alla costellazione.
    while (nodes.length < nodeCount) {
      nodes.add(Offset(0.18 + rnd.nextDouble() * 0.64,
          0.18 + rnd.nextDouble() * 0.64));
    }
    return SpreadSignature(seed: seed, nodes: nodes);
  }

  /// Il seme della firma: FNV-1a sugli stem delle tre carte e sui loro versi.
  static int seedOf(TarotSpread spread) {
    var hash = 0x811c9dc5;
    void mix(int byte) {
      hash = (hash ^ byte) & 0xFFFFFFFF;
      // Moltiplicazione a 32 bit esatta, come nell'Oroscopo.
      final lo = (hash & 0xFFFF) * 0x01000193;
      final hi = (((hash >> 16) & 0xFFFF) * 0x01000193 & 0xFFFF) << 16;
      hash = (lo + hi) & 0xFFFFFFFF;
    }

    for (final drawn in spread.cards) {
      for (final code in drawn.card.stem.codeUnits) {
        mix(code & 0xFF);
      }
      mix(drawn.reversed ? 1 : 0);
    }
    return hash & 0xFFFFFFFF;
  }

  /// Il codice breve della firma, da mostrare sotto il sigillo.
  String get code {
    const alfabeto = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';
    var n = seed;
    final buffer = StringBuffer();
    for (var i = 0; i < 6; i++) {
      buffer.write(alfabeto[n % alfabeto.length]);
      n = n ~/ alfabeto.length;
    }
    return buffer.toString();
  }
}

/// Il sigillo disegnato: la costellazione della stesa, in oro.
class SpreadSignatureMark extends StatelessWidget {
  const SpreadSignatureMark({
    super.key,
    required this.signature,
    required this.palette,
    this.size = 64,
    this.showCode = false,
  });

  final SpreadSignature signature;
  final MaestroPalette palette;
  final double size;
  final bool showCode;

  @override
  Widget build(BuildContext context) {
    final mark = SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SignaturePainter(signature: signature, palette: palette),
      ),
    );
    if (!showCode) return mark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(height: 3),
        // L'etichetta dice che cos'e': senza, il codice sembrerebbe una stringa
        // tecnica invece della firma della stesa.
        Text('SIGILLO',
            key: const Key('firma_etichetta'),
            style: TypographyTokens.label(size: 7).copyWith(
              letterSpacing: 2.4,
              color: palette.goldSoft.withValues(alpha: 0.55),
            )),
        const SizedBox(height: 1),
        // Col font di brand: uno stile nudo cadrebbe sul carattere di sistema.
        Text(signature.code,
            key: const Key('firma_codice'),
            style: TypographyTokens.label(size: 9).copyWith(
              letterSpacing: 2.0,
              color: palette.goldSoft.withValues(alpha: 0.85),
            )),
      ],
    );
  }
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter({required this.signature, required this.palette});

  final SpreadSignature signature;
  final MaestroPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    Offset p(Offset n) => Offset(n.dx * size.width, n.dy * size.height);
    final nodes = signature.nodes.map(p).toList();

    // I fili che uniscono i simboli.
    final filo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.018
      ..strokeCap = StrokeCap.round
      ..color = palette.gold.withValues(alpha: 0.55);
    for (var i = 0; i < nodes.length - 1; i++) {
      canvas.drawLine(nodes[i], nodes[i + 1], filo);
    }
    // Chiude il cerchio fra la prima e l'ultima, cosi' e' un sigillo.
    canvas.drawLine(nodes.last, nodes.first, filo);

    // I nodi: piu' grandi i tre delle carte.
    for (var i = 0; i < nodes.length; i++) {
      final grande = i < 3;
      final r = size.shortestSide * (grande ? 0.055 : 0.028);
      if (grande) {
        canvas.drawCircle(
          nodes[i],
          r * 2.2,
          Paint()
            ..color = palette.goldSoft.withValues(alpha: 0.22)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      }
      canvas.drawCircle(
          nodes[i],
          r,
          Paint()
            ..color = grande
                ? palette.goldSoft
                : palette.gold.withValues(alpha: 0.7));
    }
  }

  @override
  bool shouldRepaint(_SignaturePainter old) =>
      old.signature.seed != signature.seed || old.palette != palette;
}
