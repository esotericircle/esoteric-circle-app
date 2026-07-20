import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/maestro/maestro.dart';
import '../../../core/quality/quality_tier.dart';
import '../../../design_system/theme/maestro_palette.dart';

/// Il mezzo busto del Maestro che sfonda il cerchio, in chiave 2.5D.
///
/// Alla base un anello dorato con l'aura nel colore del Maestro; davanti, il
/// mezzo busto ricavato dall'avatar a figura intera (stesso ritaglio in alto e
/// sfumatura in basso di `MedoraStage`) che esce SOPRA il bordo dell'anello,
/// testa e spalle oltre il cerchio, con `clipBehavior` a nessuno cosi' il busto
/// non viene tagliato. Un'ombra di contatto morbida sotto il collo da' la
/// profondita' del pop-out.
///
/// Ripiego: solo se l'asset manca, l'icona lineare dorata dentro il cerchio
/// (via `errorBuilder`). L'icona sta dietro l'anello e il busto opaco la copre,
/// quindi non e' mai visibile quando il volto c'e': si vede solo dove il volto
/// non c'e'.
///
/// Movimento: il cenno di speaking fa pulsare l'aura e il bordo. Con Riduci
/// Movimento (`MediaQuery.disableAnimations`) o su Quality Tier basso il moto si
/// ferma del tutto e resta la presenza statica.
class MaestroBust extends StatefulWidget {
  const MaestroBust({
    super.key,
    required this.maestro,
    this.ring = 44,
    this.popFactor = 0.42,
    this.bustFraction = 0.26,
    this.speaking = false,
    this.image,
  });

  final Maestro maestro;

  /// Diametro dell'anello alla base.
  final double ring;

  /// Quanto la testa del busto sale sopra il bordo dell'anello, in frazione del
  /// diametro. Piu' alto vuol dire piu' pop-out. Nell'header conviene ridurlo,
  /// cosi' la testa non finisce sotto la barra del titolo.
  final double popFactor;

  /// Frazione superiore dell'avatar a figura intera che resta in scena: piu'
  /// piccola vuol dire ritaglio piu' stretto sul volto e sulle spalle.
  final double bustFraction;

  /// Quando vero, l'aura pulsa: il cenno di speaking mentre il Maestro risponde.
  final bool speaking;

  /// Sorgente dell'immagine. In produzione resta null e si usa l'avatar del
  /// Maestro; i test possono iniettare un provider che fallisce per esercitare
  /// il ripiego sull'icona.
  final ImageProvider? image;

  @override
  State<MaestroBust> createState() => _MaestroBustState();
}

class _MaestroBustState extends State<MaestroBust>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = MaestroPalette.forKey(ThemeKey.of(widget.maestro));
    final tier = context.watch<QualityTierController>().tier;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final motion = !reduceMotion && tier != QualityTier.low;
    // Il pulsare vive solo quando parla e il movimento e' consentito.
    final pulsa = widget.speaking && motion;
    if (pulsa && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!pulsa && _controller.isAnimating) {
      _controller
        ..stop()
        ..value = 0;
    }

    final ring = widget.ring;
    final pop = ring * widget.popFactor;
    final boxH = ring + pop;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final pulse = pulsa ? _controller.value : 0.0;
        return SizedBox(
          width: ring,
          height: boxH,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // L'anello alla base, con l'aura che pulsa. Dentro, l'icona di
              // ripiego: la copre il busto quando il volto c'e'.
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: ring,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: palette.primary.withValues(alpha: 0.5),
                    border: Border.all(
                      color: palette.gold.withValues(alpha: 0.6 + 0.3 * pulse),
                      width: 1.4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            palette.glow.withValues(alpha: 0.25 + 0.45 * pulse),
                        blurRadius: 8 + 14 * pulse,
                        spreadRadius: 1 + 3 * pulse,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    widget.maestro.icon,
                    key: Key('maestro_bust_icon_${widget.maestro.id}'),
                    color: palette.goldSoft,
                    size: ring * 0.44,
                  ),
                ),
              ),
              // L'ombra di contatto: una macchia morbida sotto il collo, sul
              // piano dell'anello, che stacca il busto e lo fa sporgere.
              Positioned(
                bottom: ring * 0.34,
                child: Container(
                  width: ring * 0.66,
                  height: ring * 0.16,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.elliptical(
                        ring * 0.33, ring * 0.08)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.28),
                        blurRadius: ring * 0.14,
                      ),
                    ],
                  ),
                ),
              ),
              // Il mezzo busto che sfonda il cerchio. clipBehavior none piu' in
              // alto lascia uscire testa e spalle oltre l'anello.
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: boxH,
                child: _CroppedBust(
                  maestro: widget.maestro,
                  image: widget.image,
                  bustFraction: widget.bustFraction,
                  palette: palette,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Il ritaglio a mezzo busto dell'avatar a figura intera: si tiene la parte
/// alta e si sfuma in basso, come `MedoraStage`. Se l'asset manca, resta il
/// vuoto e affiora l'icona di ripiego dietro l'anello.
class _CroppedBust extends StatelessWidget {
  const _CroppedBust({
    required this.maestro,
    required this.image,
    required this.bustFraction,
    required this.palette,
  });

  final Maestro maestro;
  final ImageProvider? image;
  final double bustFraction;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    // Il taglio del busto sfuma, non e' una linea netta.
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white, Colors.white, Colors.transparent],
        stops: [0.0, 0.72, 1.0],
      ).createShader(rect),
      child: ClipRect(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // L'immagine si scala su un'altezza pari a quella del riquadro
            // diviso la frazione: allineata in alto e tagliata, resta la sola
            // parte superiore, testa e spalle. L'OverflowBox serve perche'
            // altrimenti il riquadro schiaccerebbe l'immagine prima del
            // ritaglio, lasciando una figura intera rimpicciolita.
            final scaled = constraints.maxHeight / bustFraction;
            return OverflowBox(
              alignment: Alignment.topCenter,
              minWidth: 0,
              maxWidth: double.infinity,
              minHeight: scaled,
              maxHeight: scaled,
              child: Image(
                image: image ?? AssetImage(maestro.avatarAsset),
                fit: BoxFit.contain,
                alignment: Alignment.topCenter,
                // Se l'arte manca, nessun busto: affiora l'icona di ripiego
                // dietro l'anello.
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            );
          },
        ),
      ),
    );
  }
}
