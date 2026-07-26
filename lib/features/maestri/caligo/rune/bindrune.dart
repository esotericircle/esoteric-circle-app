import 'dart:math' as math;

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

  /// L'estremo alto e quello basso dello stelo, in coordinate normalizzate: alto
  /// il settanta per cento del riquadro, centrato.
  static const double steloAlto = 0.15;
  static const double steloBasso = 0.85;

  /// Il numero massimo di rami del sigillo: oltre, il segno non si legge piu'.
  static const int maxRami = 7;

  /// I rami del sigillo in coordinate normalizzate, uno per runa unica, gia'
  /// agganciati allo stelo e ripiegati su un solo lato. E' la geometria vera del
  /// disegno, esposta cosi' che il test possa verificarla senza dipingere.
  ///
  /// Ogni ramo nasce dal punto piu' vicino all'asse della runa, viene ripiegato
  /// tutto da una parte (quindi non attraversa mai lo stelo), scalato per stare
  /// nel riquadro e portato alla sua quota. Le rune di solo stelo, come Isa, non
  /// generano rami: contribuiscono soltanto allo stelo condiviso.
  static List<List<Offset>> ramiDi(List<String> runeNames) {
    // Una runa per volta, senza ripetizioni, fino al massimo dei rami.
    final viste = <String>{};
    final grezzi = <List<Offset>>[];
    for (final name in runeNames) {
      if (grezzi.length >= maxRami) break;
      if (!viste.add(name)) continue;
      final ramo = _ramoPrincipale(name);
      if (ramo != null) grezzi.add(ramo);
    }
    if (grezzi.isEmpty) return const [];

    // Le quote lungo lo stelo, distribuite, con un margine agli estremi cosi' il
    // ramo non tocca mai la punta.
    const primo = steloAlto + 0.06;
    const ultimo = steloBasso - 0.06;
    final n = grezzi.length;
    final passo = n == 1 ? 0.0 : (ultimo - primo) / (n - 1);

    // Estensione massima di un ramo: mai oltre il riquadro, con un margine.
    const estensione = 0.30;
    const altezzaMax = 0.24;

    final quoteUsate = <int, List<double>>{}; // per lato, le quote occupate
    final rami = <List<Offset>>[];
    for (var i = 0; i < n; i++) {
      final grezzo = grezzi[i];
      final lato = i.isEven ? 1 : -1; // destra, sinistra, destra...
      var quota = n == 1 ? (primo + ultimo) / 2 : primo + passo * i;
      // Se un ramo cade troppo vicino a un altro dello stesso lato, si sposta.
      final occupate = quoteUsate.putIfAbsent(lato, () => <double>[]);
      final minimo = passo == 0 ? 0.12 : passo * 0.5;
      while (occupate.any((q) => (q - quota).abs() < minimo)) {
        quota += minimo;
      }
      occupate.add(quota);

      // Ripiegatura su un lato: si prende la distanza dall'innesto in valore
      // assoluto, cosi' nessun punto passa dall'altra parte dello stelo.
      var largo = 0.0;
      var alto = 0.0;
      for (final p in grezzo) {
        largo = p.dx.abs() > largo ? p.dx.abs() : largo;
        alto = p.dy.abs() > alto ? p.dy.abs() : alto;
      }
      var scala = 1.0;
      if (largo > 0) scala = math.min(scala, estensione / largo);
      if (alto > 0) scala = math.min(scala, (altezzaMax / 2) / alto);

      final ramo = <Offset>[];
      for (final p in grezzo) {
        final x = 0.5 + lato * p.dx.abs() * scala;
        final y = quota + p.dy * scala;
        ramo.add(Offset(x.clamp(0.02, 0.98), y.clamp(0.02, 0.98)));
      }
      rami.add(ramo);
    }
    return rami;
  }

  /// Il ramo principale di una runa, in coordinate relative all'innesto: la
  /// spezzata non verticale piu' estesa, traslata sul suo punto d'aggancio.
  /// Null per le rune di solo stelo.
  static List<Offset>? _ramoPrincipale(String name) {
    final strokes = kRuneStrokes[name];
    if (strokes == null) return null;
    // L'asse verticale della runa, se c'e': i rami si agganciano a quello.
    var asseX = 0.5;
    var trovata = false;
    for (final poly in strokes) {
      final xs = poly.map((p) => p.dx);
      final ys = poly.map((p) => p.dy);
      final dx = xs.reduce(math.max) - xs.reduce(math.min);
      final dy = ys.reduce(math.max) - ys.reduce(math.min);
      if (dx < 0.08 && dy > 0.5) {
        asseX = (xs.reduce(math.max) + xs.reduce(math.min)) / 2;
        trovata = true;
        break;
      }
    }
    // Fra le spezzate non verticali, quella con l'estensione maggiore.
    List<Offset>? scelto;
    var miglior = 0.0;
    for (final poly in strokes) {
      final xs = poly.map((p) => p.dx);
      final ys = poly.map((p) => p.dy);
      final dx = xs.reduce(math.max) - xs.reduce(math.min);
      final dy = ys.reduce(math.max) - ys.reduce(math.min);
      if (dx < 0.08 && dy > 0.5) continue; // e' l'asta, la fa lo stelo
      final est = dx + dy;
      if (est > miglior) {
        miglior = est;
        scelto = poly;
      }
    }
    if (scelto == null) return null; // solo stelo: nessun ramo
    if (!trovata) {
      final xs = scelto.map((p) => p.dx);
      asseX = (xs.reduce(math.max) + xs.reduce(math.min)) / 2;
    }
    // L'innesto e' il punto piu' vicino all'asse: da lui parte il ramo.
    var innesto = scelto.first;
    var minDist = (innesto.dx - asseX).abs();
    for (final p in scelto) {
      final d = (p.dx - asseX).abs();
      if (d < minDist) {
        minDist = d;
        innesto = p;
      }
    }
    return [for (final p in scelto) Offset(p.dx - innesto.dx, p.dy - innesto.dy)];
  }

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

  // Il sigillo della settimana: un unico segno composto. Un solo stelo
  // verticale centrale, spesso, alto il settanta per cento del riquadro, e i
  // rami delle rune agganciati allo stelo, uno per runa, ciascuno alla propria
  // quota, alternando destra e sinistra. Nessun ramo attraversa lo stelo,
  // nessuno esce dal riquadro, al massimo sette. Tono osso caldo, alone ambrato.
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

    // Lo stelo verticale centrale, spesso, sotto i rami.
    final steloTop = map(const Offset(0.5, BindruneSigillo.steloAlto));
    final steloBot = map(const Offset(0.5, BindruneSigillo.steloBasso));
    canvas.drawLine(
        steloTop,
        steloBot,
        Paint()
          ..strokeCap = StrokeCap.round
          ..strokeWidth = box * 0.055
          ..color = ambra.withValues(alpha: 0.4)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, box * 0.035));
    canvas.drawLine(
        steloTop,
        steloBot,
        Paint()
          ..strokeCap = StrokeCap.round
          ..strokeWidth = box * 0.055
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

    for (final ramo in BindruneSigillo.ramiDi(runeNames)) {
      final path = Path();
      for (var k = 0; k < ramo.length; k++) {
        final p = map(ramo[k]);
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
