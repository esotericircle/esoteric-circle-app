import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design_system/theme/maestro_palette.dart';

/// L'astrolabio che si costruisce: la prima cosa che si vede del Cerchio.
///
/// Sostituisce il cerchio anonimo dell'accoglienza. Il testo sotto promette di
/// comporre il cielo un passo alla volta, e un cerchio fermo non promette
/// niente: qui gli anelli si TRACCIANO uno dopo l'altro, come sotto una mano
/// invisibile, e solo quando sono tracciati cominciano a ruotare a velocita'
/// diverse fra loro. E' lo stesso gesto che il rito chiede alla persona.
///
/// Tutto procedurale, nessun asset: il Cerchio si presenta con qualcosa che
/// nasce, non con un'immagine che c'era gia'.
class Astrolabio extends StatefulWidget {
  const Astrolabio({
    super.key,
    required this.palette,
    this.reduceMotion = false,
  });

  final MaestroPalette palette;
  final bool reduceMotion;

  /// Quanto dura la costruzione, dal primo tratto all'ultimo.
  static const Duration costruzione = Duration(milliseconds: 2600);

  /// Quanti anelli. Tre come i Maestri, che e' una coincidenza voluta.
  static const int anelli = 3;

  @override
  State<Astrolabio> createState() => _AstrolabioState();
}

class _AstrolabioState extends State<Astrolabio>
    with TickerProviderStateMixin {
  late final AnimationController _traccia;
  late final AnimationController _giro;

  @override
  void initState() {
    super.initState();
    _traccia = AnimationController(
      vsync: this,
      duration: Astrolabio.costruzione,
    );
    // La rotazione e' un ciclo lungo e continuo, separato dalla costruzione:
    // sono due tempi diversi, e mescolarli avrebbe legato la velocita' di
    // rotazione alla durata del disegno.
    _giro = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    );
    if (widget.reduceMotion) {
      // Con Riduci Movimento l'astrolabio c'e' gia', finito e fermo: si vede
      // la stessa cosa, senza il viaggio.
      _traccia.value = 1;
    } else {
      _traccia.forward();
      _giro.repeat();
    }
  }

  @override
  void dispose() {
    _traccia.dispose();
    _giro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_traccia, _giro]),
      builder: (context, _) => CustomPaint(
        key: const Key('astrolabio'),
        painter: AstrolabioPainter(
          palette: widget.palette,
          costruzione: _traccia.value,
          giro: widget.reduceMotion ? 0 : _giro.value,
        ),
      ),
    );
  }
}

/// Il disegno dell'astrolabio. Pubblico perche' l'avanzamento della
/// costruzione e' l'unica cosa che un test possa leggere senza i pixel.
class AstrolabioPainter extends CustomPainter {
  AstrolabioPainter({
    required this.palette,
    required this.costruzione,
    required this.giro,
  });

  final MaestroPalette palette;

  /// Da 0 (niente) a 1 (tutti gli anelli tracciati).
  final double costruzione;

  /// La fase della rotazione, in giri.
  final double giro;

  /// Quanta parte della costruzione tocca a un anello, sfalsata dalle altre.
  static double avanzamentoAnello(double t, int i) {
    // I tre anelli si tracciano in fila, con una sovrapposizione: il
    // secondo parte quando il primo e' a meta'. Il conto e' fatto perche'
    // l'ULTIMO chiuda esattamente a fine costruzione: con un passo piu'
    // largo il terzo anello restava aperto al 95 per cento, cioe' un
    // astrolabio che non finiva mai di costruirsi.
    const passo = 0.25;
    final inizio = i * passo;
    const durata = 1.0 - (Astrolabio.anelli - 1) * passo;
    return ((t - inizio) / durata).clamp(0.0, 1.0);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final rMax = math.min(size.width, size.height) / 2 - 6;
    if (rMax <= 0) return;

    for (var i = 0; i < Astrolabio.anelli; i++) {
      final k = Curves.easeOutCubic
          .transform(avanzamentoAnello(costruzione, i));
      if (k <= 0) continue;

      final r = rMax * (1.0 - i * 0.26);
      // Ogni anello gira a una velocita' sua, e uno gira al contrario: senza
      // questo sarebbero tre cerchi concentrici fermi in un blocco solo.
      final velocita = [1.0, -0.62, 0.34][i];
      final fase = giro * 2 * math.pi * velocita;

      // Il tratto che si disegna: parte dall'alto e chiude il cerchio.
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        -math.pi / 2 + fase,
        2 * math.pi * k,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = i == 0 ? 1.6 : 1.1
          ..strokeCap = StrokeCap.round
          ..color = palette.gold.withValues(alpha: 0.30 + 0.28 * k),
      );

      // Le tacche dell'anello, che compaiono man mano che il tratto passa.
      final quante = [24, 12, 8][i];
      for (var j = 0; j < quante; j++) {
        final frazione = j / quante;
        if (frazione > k) break;
        final a = -math.pi / 2 + fase + frazione * 2 * math.pi;
        final d = Offset(math.cos(a), math.sin(a));
        canvas.drawLine(
          c + d * (r - 5),
          c + d * r,
          Paint()
            ..strokeWidth = 1.0
            ..color = palette.goldSoft.withValues(alpha: 0.45),
        );
      }

      // Un punto di luce che percorre l'anello: e' quello che fa sembrare
      // l'astrolabio uno strumento acceso invece di un disegno.
      if (k >= 1) {
        final a = -math.pi / 2 + fase * 2.4 + i * 2.1;
        final p = c + Offset(math.cos(a), math.sin(a)) * r;
        canvas.drawCircle(
          p,
          9,
          Paint()
            ..shader = RadialGradient(colors: [
              palette.goldSoft.withValues(alpha: 0.5),
              palette.goldSoft.withValues(alpha: 0),
            ]).createShader(Rect.fromCircle(center: p, radius: 9)),
        );
        canvas.drawCircle(p, 2.2, Paint()..color = palette.goldSoft);
      }
    }

    // La stella al centro nasce per ultima e pulsa lenta, come un battito.
    final nascita = ((costruzione - 0.55) / 0.45).clamp(0.0, 1.0);
    if (nascita > 0) {
      final battito = 0.5 + 0.5 * math.sin(giro * 2 * math.pi * 6);
      final r = (5.0 + 2.0 * battito) * nascita;
      canvas.drawCircle(
        c,
        r * 3.4,
        Paint()
          ..shader = RadialGradient(colors: [
            palette.goldSoft.withValues(alpha: 0.42 * nascita),
            palette.goldSoft.withValues(alpha: 0),
          ]).createShader(Rect.fromCircle(center: c, radius: r * 3.4)),
      );
      canvas.drawCircle(c, r, Paint()..color = palette.goldSoft);
      // I quattro raggi della stella.
      final raggio = Paint()
        ..strokeWidth = 1.3
        ..strokeCap = StrokeCap.round
        ..color = palette.goldSoft.withValues(alpha: 0.85 * nascita);
      for (var i = 0; i < 4; i++) {
        final a = i * math.pi / 2;
        final d = Offset(math.cos(a), math.sin(a));
        canvas.drawLine(c + d * (r + 2), c + d * (r + 8 + 3 * battito), raggio);
      }
    }
  }

  @override
  bool shouldRepaint(AstrolabioPainter old) =>
      old.costruzione != costruzione || old.giro != giro;
}
