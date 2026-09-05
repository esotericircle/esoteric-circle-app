import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Ingresso di schermata a due tempi, riutilizzabile.
///
/// Prima compare solo l'eroe, grande, che si rimpicciolisce e si posa nella sua
/// sede; poi i contenuti scendono a cascata dall'alto verso il basso con un
/// leggero stagger. Con Riduci Movimento attivo non anima nulla e mette tutto
/// gia' in posizione, come chiede la regola dell'accessibilita'.
///
/// Si usa al posto della lista scorrevole della schermata: [hero] e' il widget
/// dell'eroe, [items] sono i contenuti nell'ordine in cui devono comparire.
class EntranceCascade extends StatefulWidget {
  const EntranceCascade({
    super.key,
    required this.hero,
    required this.items,
    this.padding = EdgeInsets.zero,
    this.listKey,
    this.introScale = 1.9,
    this.duration = const Duration(milliseconds: 1500),
  });

  /// L'eroe che entra per primo, grande, e si posa nella sua sede.
  final Widget hero;

  /// I contenuti che scendono a cascata dopo l'eroe.
  final List<Widget> items;

  final EdgeInsets padding;
  final Key? listKey;

  /// Quanto e' grande l'eroe all'ingresso, rispetto alla sua misura finale.
  final double introScale;

  final Duration duration;

  @override
  State<EntranceCascade> createState() => _EntranceCascadeState();
}

class _EntranceCascadeState extends State<EntranceCascade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    // Riduci Movimento: niente animazione, tutto gia' in posizione.
    if (MediaQuery.of(context).disableAnimations) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Finestra di comparsa dell'elemento i-esimo, dopo che l'eroe si e' posato.
  //
  // Il passo si distribuisce sulla finestra disponibile: con molti elementi si
  // stringe, cosi' anche l'ultimo arriva a destinazione entro la fine. Senza
  // questo, le voci in fondo non comparirebbero mai.
  double _itemProgress(double t, int i) {
    const heroEnd = 0.40;
    const span = 0.28;
    const maxStep = 0.07;
    final n = widget.items.length;
    const lastStart = 1.0 - span;
    final step =
        n <= 1 ? 0.0 : math.min(maxStep, (lastStart - heroEnd) / (n - 1));
    final start = heroEnd + i * step;
    final raw = (t - start) / span;
    return Curves.easeOutCubic.transform(raw.clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final heroT = Curves.easeOutCubic.transform((t / 0.40).clamp(0.0, 1.0));
        final scale = widget.introScale + (1.0 - widget.introScale) * heroT;

        return ListView(
          key: widget.listKey,
          padding: widget.padding,
          // L'eroe ingrandito puo' sporgere dalla sua sede durante l'ingresso.
          clipBehavior: Clip.none,
          children: [
            Opacity(
              opacity: heroT.clamp(0.0, 1.0),
              child: Transform.scale(scale: scale, child: widget.hero),
            ),
            for (var i = 0; i < widget.items.length; i++)
              Builder(builder: (context) {
                final p = _itemProgress(t, i);
                return Opacity(
                  opacity: p,
                  child: Transform.translate(
                    offset: Offset(0, 18 * (1 - p)),
                    child: widget.items[i],
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}
