import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/quality/quality_tier.dart';

/// Comparsa progressiva di un elemento mentre si scorre.
///
/// L'elemento entra in dissolvenza con un piccolo movimento verso l'alto. La
/// parallasse nasce dalla PROFONDITA': gli strati piu' interni (il contenuto di
/// una card) salgono di piu' e un soffio piu' tardi dello strato che li
/// contiene, quindi durante la comparsa i piani si muovono a velocita' diverse.
///
/// I guardrail non sono opzionali.
/// - Rivelazione una volta sola: appena finita, l'elemento resta fermo e non
///   ri-anima piu', nemmeno tornando indietro con lo scorrimento.
/// - Movimento piccolo e rapido, mai una scenografia.
/// - Con Riduci Movimento di sistema oppure con Quality Tier basso non anima
///   nulla: tutto e' subito in posizione, piena opacita'.
/// - La leggibilita' del testo non dipende mai dall'animazione: a riposo
///   l'opacita' e' 1 e nessuna trasformazione resta applicata.
/// - Il ritardo dello strato vive dentro la curva dell'animazione, non in un
///   timer a parte: cosi' non resta nulla in sospeso quando la schermata muore.
class ScrollReveal extends StatefulWidget {
  const ScrollReveal({
    super.key,
    required this.child,
    this.depth = 0,
    this.enabled = true,
  });

  final Widget child;

  /// Lo strato: 0 e' il contenitore, 1 il contenuto che gli sta dentro. Piu' e'
  /// profondo, piu' lungo il tragitto e piu' tardi la partenza, ed e' da qui che
  /// viene la parallasse.
  final int depth;

  /// Permette a chi la usa di spegnerla del tutto, per esempio in una superficie
  /// che deve restare immobile.
  final bool enabled;

  /// Il tragitto in pixel di ogni strato: piccolo, per non spostare la lettura.
  static double slideFor(int depth) => 10.0 + depth * 8.0;

  /// La durata della sola comparsa, uguale per tutti gli strati.
  static const Duration duration = Duration(milliseconds: 260);

  /// Il ritardo di partenza di uno strato.
  static Duration delayFor(int depth) => Duration(milliseconds: depth * 60);

  /// Se il movimento va spento: Riduci Movimento di sistema oppure Quality Tier
  /// basso. Sta qui, in un punto solo, cosi' i test la verificano.
  static bool motionOff(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return true;
    // Il controller puo' mancare in una superficie montata da sola: la lettura
    // nullabile torna null invece di sollevare, e il movimento resta acceso.
    return context.watch<QualityTierController?>()?.tier == QualityTier.low;
  }

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal>
    with SingleTickerProviderStateMixin {
  // Creati subito e non in modo pigro: un `late` inizializzato solo dentro
  // dispose costruirebbe un Ticker a albero gia' smontato, che e' un errore.
  late final AnimationController _controller;
  late final Animation<double> _t;

  // Rivelato una volta sola: quando e' vero, l'elemento resta stabile per
  // sempre, qualunque cosa faccia lo scorrimento.
  bool _revealed = false;
  bool _off = false;

  @override
  void initState() {
    super.initState();
    final delay = ScrollReveal.delayFor(widget.depth);
    final total = delay + ScrollReveal.duration;
    _controller = AnimationController(vsync: this, duration: total);
    // Il ritardo dello strato e' un intervallo dentro la curva: nessun timer.
    _t = CurvedAnimation(
      parent: _controller,
      curve: Interval(
        total.inMilliseconds == 0
            ? 0
            : delay.inMilliseconds / total.inMilliseconds,
        1,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _off = !widget.enabled || ScrollReveal.motionOff(context);
    // Le liste del dominio sono pigre: un elemento si costruisce quando lo
    // scorrimento lo porta vicino alla finestra, quindi il primo aggancio e'
    // gia' il momento giusto per rivelarlo.
    if (!_off && !_revealed && !_controller.isAnimating) {
      _controller.forward().whenComplete(() {
        if (mounted) _revealed = true;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_off || _revealed) return widget.child;
    final slide = ScrollReveal.slideFor(widget.depth);
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _t.value,
        child: Transform.translate(
          offset: Offset(0, (1 - _t.value) * slide),
          child: child,
        ),
      ),
    );
  }
}
