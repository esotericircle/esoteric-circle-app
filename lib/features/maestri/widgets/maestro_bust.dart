import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/maestro/maestro.dart';
import '../../../core/quality/quality_tier.dart';
import '../../../design_system/theme/maestro_palette.dart';

/// Il volto del Maestro che rompe il cerchio, in chiave 2.5D.
///
/// Alla base un anello dorato con l'aura nel colore del Maestro; davanti, un
/// ritaglio STRETTO sul volto (la testa e poco piu'), ingrandito e posizionato
/// perche' la sommita' del capo e la chioma escano SOPRA il bordo dell'anello,
/// con `clipBehavior` a nessuno cosi' la testa non viene tagliata. Un'ombra di
/// contatto morbida sotto il mento da' la profondita' del pop-out. E' la scelta
/// esplicita di Mauro: il volto o poco piu' che sfonda il cerchio.
///
/// Robustezza: il volto e' un `Image.asset` con `errorBuilder`, lo stesso schema
/// solido della bolla della chat, quindi si disegna appena l'immagine e'
/// decodificata, in qualunque contesto. L'icona lineare di riferimento compare
/// solo se l'asset manca DAVVERO (l'`errorBuilder` scatta), mai come fondale e
/// mai durante il caricamento.
///
/// Movimento: il cenno di speaking fa pulsare l'aura e il bordo. Con Riduci
/// Movimento (`MediaQuery.disableAnimations`) o su Quality Tier basso il moto si
/// ferma del tutto e resta la presenza statica.
class MaestroBust extends StatefulWidget {
  const MaestroBust({
    super.key,
    required this.maestro,
    this.ring = 44,
    this.popFactor = 0.55,
    this.faceFraction = 0.17,
    this.speaking = false,
    this.image,
  });

  final Maestro maestro;

  /// Diametro dell'anello alla base.
  final double ring;

  /// Quanto la testa sale sopra il bordo dell'anello, in frazione del diametro.
  /// Piu' alto vuol dire piu' pop-out.
  final double popFactor;

  /// Frazione superiore dell'avatar a figura intera che riempie il riquadro:
  /// piccola vuol dire ritaglio stretto e ingrandito sul volto. La testa di una
  /// figura intera sta grosso modo nel primo sesto dell'immagine, quindi valori
  /// intorno a 0,17 tengono il volto e la chioma, non il busto.
  final double faceFraction;

  /// Quando vero, l'aura pulsa: il cenno di speaking mentre il Maestro risponde.
  final bool speaking;

  /// Sorgente dell'immagine. In produzione resta null e si usa l'avatar del
  /// Maestro; i test possono iniettare un provider che fallisce per esercitare
  /// il ripiego sull'icona, o uno che dipinge per verificare il volto.
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

  /// Vero solo quando l'immagine dell'avatar ha fallito il caricamento, saputo
  /// dall'`errorBuilder` dell'Image. Solo allora si mostra l'icona di ripiego.
  /// Mai come fondale, mai durante il caricamento.
  bool _failed = false;

  ImageProvider get _provider =>
      widget.image ?? AssetImage(widget.maestro.avatarAsset);

  @override
  void didUpdateWidget(MaestroBust oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Cambiato Maestro o sorgente: si riprova a disegnare il volto.
    if (oldWidget.maestro != widget.maestro || oldWidget.image != widget.image) {
      _failed = false;
    }
  }

  void _markFailed() {
    // L'errorBuilder e' chiamato durante il build: si rimanda il setState al
    // frame dopo, cosi' non si tocca lo stato mentre si costruisce l'albero.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_failed) setState(() => _failed = true);
    });
  }

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
              // L'anello alla base, con l'aura che pulsa. L'icona di ripiego
              // vive qui, ma solo quando l'immagine ha fallito davvero.
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
                  child: _failed
                      ? Icon(
                          widget.maestro.icon,
                          key: Key('maestro_bust_icon_${widget.maestro.id}'),
                          color: palette.goldSoft,
                          size: ring * 0.44,
                        )
                      : null,
                ),
              ),
              // L'ombra di contatto: una macchia morbida sotto il mento, sul
              // piano dell'anello, che stacca il volto e lo fa sporgere.
              if (!_failed)
                Positioned(
                  bottom: ring * 0.42,
                  child: Container(
                    width: ring * 0.62,
                    height: ring * 0.15,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                          Radius.elliptical(ring * 0.31, ring * 0.075)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.30),
                          blurRadius: ring * 0.14,
                        ),
                      ],
                    ),
                  ),
                ),
              // Il volto che sfonda il cerchio. clipBehavior none piu' in alto
              // lascia uscire la testa e la chioma oltre l'anello.
              if (!_failed)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: boxH,
                  child: _FaceCrop(
                    provider: _provider,
                    faceFraction: widget.faceFraction,
                    onError: _markFailed,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Il ritaglio stretto sul volto dell'avatar a figura intera: l'immagine si
/// ingrandisce finche' la testa riempie il riquadro, allineata in alto e
/// tagliata sotto con una sfumatura, cosi' il volto rompe l'anello e sfuma verso
/// il collo. La testa di una figura intera sta nel primo sesto circa
/// dell'immagine: con `faceFraction` piccolo resta il volto, non il busto.
///
/// L'immagine e' un `Image` con `errorBuilder`, come la bolla della chat: se
/// l'asset manca davvero, avvisa `onError` e lascia il vuoto, cosi' MaestroBust
/// accende l'icona di ripiego nell'anello.
class _FaceCrop extends StatelessWidget {
  const _FaceCrop({
    required this.provider,
    required this.faceFraction,
    required this.onError,
  });

  final ImageProvider provider;
  final double faceFraction;
  final VoidCallback onError;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white, Colors.white, Colors.transparent],
        stops: [0.0, 0.78, 1.0],
      ).createShader(rect),
      child: ClipRect(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // L'immagine si scala su un'altezza pari al riquadro diviso la
            // frazione: piccola vuol dire immagine molto piu' alta del riquadro,
            // quindi solo la parte alta (il volto) resta in vista. L'OverflowBox
            // serve perche' altrimenti il riquadro schiaccerebbe l'immagine
            // prima del ritaglio, lasciando una figura intera rimpicciolita.
            final scaled = constraints.maxHeight / faceFraction;
            return OverflowBox(
              alignment: Alignment.topCenter,
              minWidth: 0,
              maxWidth: double.infinity,
              minHeight: 0,
              maxHeight: double.infinity,
              child: Image(
                image: provider,
                height: scaled,
                fit: BoxFit.fitHeight,
                alignment: Alignment.topCenter,
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, __, ___) {
                  onError();
                  return const SizedBox.shrink();
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
