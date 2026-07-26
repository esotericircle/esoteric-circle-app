import 'package:flutter/material.dart';

import '../../../rituals/rune_strokes.dart';

/// Il sigillo del giorno: una bindrune, un glifo unico che intreccia le rune
/// uscite sovrapponendone i tratti su un'asta centrale condivisa, in oro. E'
/// deterministico dalle rune della gettata, nessuna casualita' nel disegno.
class BindruneSigillo extends StatelessWidget {
  const BindruneSigillo({
    super.key,
    required this.runeNames,
    required this.oro,
    this.alone,
    this.lato = 150,
    this.deduplica = false,
  });

  /// I nomi delle rune da intrecciare, nell'ordine di lettura.
  final List<String> runeNames;

  /// L'oro dei tratti e dell'asta.
  final Color oro;

  /// Un secondo tono d'oro per l'alone, oppure [oro] se assente.
  final Color? alone;

  final double lato;

  /// Se vero, i tratti identici sovrapposti si disegnano una volta sola. Lo
  /// usa il sigillo della settimana, che intreccia sette rune: senza, i tratti
  /// comuni si addenserebbero. L'Estrazione Rune lo lascia falso, invariata.
  final bool deduplica;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('bindrune'),
      width: lato,
      height: lato,
      child: CustomPaint(
        painter: _BindrunePainter(
          runeNames: runeNames,
          oro: oro,
          alone: alone ?? oro,
          deduplica: deduplica,
        ),
      ),
    );
  }
}

class _BindrunePainter extends CustomPainter {
  _BindrunePainter({
    required this.runeNames,
    required this.oro,
    required this.alone,
    required this.deduplica,
  });

  final List<String> runeNames;
  final Color oro;
  final Color alone;
  final bool deduplica;

  @override
  void paint(Canvas canvas, Size size) {
    if (deduplica) {
      _paintStelo(canvas, size);
    } else {
      _paintSovrapposto(canvas, size);
    }
  }

  // Il sigillo della settimana: un solo stelo verticale centrale, spesso, e i
  // rami delle rune innestati a quote diverse lungo lo stelo, mai allo stesso
  // punto. Le rune ripetute contano una volta sola; quelle senza rami
  // rappresentabili, come Isa che e' solo un'asta, si omettono senza rompere il
  // disegno. Tono osso caldo, bagliore ambrato.
  void _paintStelo(Canvas canvas, Size size) {
    final box = size.shortestSide * 0.82;
    final left = (size.width - box) / 2;
    final top = (size.height - box) / 2;
    Offset map(Offset p) => Offset(left + p.dx * box, top + p.dy * box);

    const osso = Color(0xFFEAD8AE); // osso caldo, non giallo pieno
    final ambra = alone; // bagliore ambrato, dal secondo oro passato

    // Alone tondo dietro il sigillo.
    canvas.drawCircle(
      size.center(Offset.zero),
      box * 0.6,
      Paint()
        ..shader = RadialGradient(colors: [
          ambra.withValues(alpha: 0.20),
          ambra.withValues(alpha: 0.0),
        ]).createShader(
            Rect.fromCircle(center: size.center(Offset.zero), radius: box * 0.6)),
    );

    // Raccoglie i rami di ogni runa unica, saltando l'asta verticale che lo
    // stelo condiviso gia' rappresenta. Le rune senza rami si scartano.
    final viste = <String>{};
    final conRami = <_RamiRuna>[];
    for (final name in runeNames) {
      if (!viste.add(name)) continue; // una sola occorrenza per runa
      final strokes = kRuneStrokes[name];
      if (strokes == null) continue;
      final rami = <List<Offset>>[];
      var minX = 1.0, maxX = 0.0, asseX = 0.5;
      var trovataAsta = false;
      for (final poly in strokes) {
        var pMinX = 1.0, pMaxX = 0.0, pMinY = 1.0, pMaxY = 0.0;
        for (final p in poly) {
          pMinX = p.dx < pMinX ? p.dx : pMinX;
          pMaxX = p.dx > pMaxX ? p.dx : pMaxX;
          pMinY = p.dy < pMinY ? p.dy : pMinY;
          pMaxY = p.dy > pMaxY ? p.dy : pMaxY;
        }
        final verticale = (pMaxX - pMinX) < 0.08 && (pMaxY - pMinY) > 0.5;
        if (verticale) {
          asseX = (pMinX + pMaxX) / 2; // l'asse della runa, da portare sullo stelo
          trovataAsta = true;
          continue; // l'asta la disegna lo stelo condiviso
        }
        rami.add(poly);
        minX = pMinX < minX ? pMinX : minX;
        maxX = pMaxX > maxX ? pMaxX : maxX;
      }
      if (rami.isEmpty) continue; // nessun ramo rappresentabile: si omette
      if (!trovataAsta) asseX = (minX + maxX) / 2;
      // Centroide verticale dei rami, per distribuirli lungo lo stelo.
      var somma = 0.0, conta = 0;
      for (final poly in rami) {
        for (final p in poly) {
          somma += p.dy;
          conta++;
        }
      }
      conRami.add(_RamiRuna(rami, asseX, conta == 0 ? 0.5 : somma / conta));
    }

    // Lo stelo verticale centrale, spesso, sotto i rami.
    final steloTop = map(const Offset(0.5, 0.04));
    final steloBot = map(const Offset(0.5, 0.96));
    canvas.drawLine(
        steloTop,
        steloBot,
        Paint()
          ..strokeCap = StrokeCap.round
          ..strokeWidth = box * 0.05
          ..color = ambra.withValues(alpha: 0.4)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, box * 0.035));
    canvas.drawLine(
        steloTop,
        steloBot,
        Paint()
          ..strokeCap = StrokeCap.round
          ..strokeWidth = box * 0.05
          ..color = osso);

    // I rami, ognuno a una quota diversa lungo lo stelo.
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = box * 0.045
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = ambra.withValues(alpha: 0.5)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, box * 0.04);
    final tratto = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = box * 0.03
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = osso;

    final n = conRami.length;
    for (var i = 0; i < n; i++) {
      final r = conRami[i];
      final quota = n == 1 ? 0.5 : 0.22 + 0.56 * (i / (n - 1));
      final dx = 0.5 - r.asseX;
      final dy = quota - r.centroY;
      for (final poly in r.rami) {
        final path = Path();
        for (var k = 0; k < poly.length; k++) {
          final y = (poly[k].dy + dy).clamp(0.04, 0.96);
          final p = map(Offset(poly[k].dx + dx, y));
          if (k == 0) {
            path.moveTo(p.dx, p.dy);
          } else {
            path.lineTo(p.dx, p.dy);
          }
        }
        canvas.drawPath(path, glow);
        canvas.drawPath(path, tratto);
      }
    }
  }

  void _paintSovrapposto(Canvas canvas, Size size) {
    final box = size.shortestSide * 0.74;
    final left = (size.width - box) / 2;
    final top = (size.height - box) / 2;
    Offset map(Offset p) => Offset(left + p.dx * box, top + p.dy * box);

    // Alone tondo dietro il sigillo, per staccarlo dal fondo.
    canvas.drawCircle(
      size.center(Offset.zero),
      box * 0.62,
      Paint()
        ..shader = RadialGradient(colors: [
          alone.withValues(alpha: 0.22),
          alone.withValues(alpha: 0.0),
        ]).createShader(
            Rect.fromCircle(center: size.center(Offset.zero), radius: box * 0.62)),
    );

    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = box * 0.05
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = alone.withValues(alpha: 0.45)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, box * 0.04);

    final tratto = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = box * 0.035
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = oro;

    // I tratti di ogni runa, centrati orizzontalmente sull'asta condivisa. Con
    // [deduplica] un tratto gia' disegnato non si ridisegna, cosi' l'intreccio
    // di sette rune non si addensa.
    final visti = <String>{};
    for (final name in runeNames) {
      final strokes = kRuneStrokes[name];
      if (strokes == null) continue;
      var minX = 1.0;
      var maxX = 0.0;
      for (final poly in strokes) {
        for (final p in poly) {
          if (p.dx < minX) minX = p.dx;
          if (p.dx > maxX) maxX = p.dx;
        }
      }
      final shift = 0.5 - (minX + maxX) / 2;
      for (final poly in strokes) {
        if (deduplica) {
          final firma = poly
              .map((p) => '${((p.dx + shift) * 100).round()},'
                  '${(p.dy * 100).round()}')
              .join(';');
          if (!visti.add(firma)) continue;
        }
        final path = Path()
          ..moveTo(map(poly.first.translate(shift, 0)).dx,
              map(poly.first.translate(shift, 0)).dy);
        for (var i = 1; i < poly.length; i++) {
          final p = map(poly[i].translate(shift, 0));
          path.lineTo(p.dx, p.dy);
        }
        canvas.drawPath(path, glow);
        canvas.drawPath(path, tratto);
      }
    }

    // L'asta centrale condivisa, sopra tutto, che unisce l'intreccio.
    final asta = Path()
      ..moveTo(map(const Offset(0.5, 0.02)).dx, map(const Offset(0.5, 0.02)).dy)
      ..lineTo(map(const Offset(0.5, 0.98)).dx, map(const Offset(0.5, 0.98)).dy);
    canvas.drawPath(
        asta,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = box * 0.06
          ..strokeCap = StrokeCap.round
          ..color = alone.withValues(alpha: 0.4)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, box * 0.03));
    canvas.drawPath(
        asta,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = box * 0.045
          ..strokeCap = StrokeCap.round
          ..color = oro);
  }

  @override
  bool shouldRepaint(_BindrunePainter old) =>
      old.runeNames != runeNames ||
      old.oro != oro ||
      old.alone != alone ||
      old.deduplica != deduplica;
}

/// I rami di una runa per il sigillo a stelo: le spezzate senza l'asta, l'asse
/// verticale della runa e il centroide verticale dei rami.
class _RamiRuna {
  const _RamiRuna(this.rami, this.asseX, this.centroY);
  final List<List<Offset>> rami;
  final double asseX;
  final double centroY;
}
