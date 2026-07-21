import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/maestro/maestro.dart';
import '../../../core/quality/quality_tier.dart';
import '../../../design_system/theme/maestro_palette.dart';

/// Punto del volto di un Maestro, in coordinate normalizzate 0..1 sull'immagine
/// intera dell'avatar (origine in alto a sinistra). Misurato sugli asset reali.
@immutable
class MaestroFacePoint {
  const MaestroFacePoint({
    required this.centerX,
    required this.headTopY,
    required this.collarY,
  });

  /// Ascissa del centro del volto, frazione della larghezza.
  final double centerX;

  /// Ordinata della sommita' del capo, frazione dell'altezza.
  final double headTopY;

  /// Ordinata della linea del collo, frazione dell'altezza.
  final double collarY;
}

/// L'inquadratura calcolata del volto dentro il cerchio, in pixel logici. Tutti
/// i valori scalano in proporzione al diametro dell'anello, cosi' header, lente
/// e bolla mostrano lo stesso identico taglio a misure diverse.
@immutable
class BustFraming {
  const BustFraming({
    required this.imageHeight,
    required this.verticalOffset,
    required this.faceDx,
    required this.boxHeight,
    required this.bandTop,
    required this.bandBottom,
  });

  /// Altezza a cui disegnare l'immagine intera dell'avatar.
  final double imageHeight;

  /// Traslazione verticale dell'immagine, dopo l'allineamento in alto.
  final double verticalOffset;

  /// Correzione orizzontale, frazione della larghezza dell'immagine, per portare
  /// il centro del volto al centro del cerchio.
  final double faceDx;

  /// Altezza del riquadro del widget: il diametro piu' lo spazio sopra l'anello
  /// dove la testa sporge.
  final double boxHeight;

  /// Ordinata della sommita' del capo nel riquadro.
  final double bandTop;

  /// Ordinata della linea del collo nel riquadro.
  final double bandBottom;
}

/// Il volto del Maestro che rompe il cerchio, in chiave 2.5D.
///
/// L'inquadratura non usa piu' una frazione di ritaglio unica sui tre avatar,
/// che dava tagli incoerenti (a volte i soli occhi, a volte la figura intera),
/// ma un punto del volto misurato per Maestro (`MaestroBust.facePoints`) piu' una
/// regola indipendente dalla dimensione: la fascia dal capo al collo riempie
/// circa l'80 per cento del diametro del cerchio, centrata sul centro del volto.
/// Cosi' il taglio e' identico in header, lente e bolla, cambia solo la misura e
/// se la testa sporge sopra l'anello o resta contenuta nel tondo.
///
/// Con [popOut] vero (header e lente) la sommita' del capo esce appena sopra
/// l'anello; con [popOut] falso (bolla della chat) lo stesso volto resta tutto
/// dentro il cerchio, senza sporgenza.
///
/// Robustezza: il volto e' un `Image` con `errorBuilder`, lo stesso schema
/// solido della bolla, quindi si disegna appena l'immagine e' decodificata.
/// L'icona lineare di riferimento compare solo se l'`errorBuilder` scatta per un
/// asset davvero mancante, mai come fondale e mai durante il caricamento.
///
/// Movimento: il cenno di speaking fa pulsare l'aura. Con Riduci Movimento o su
/// Quality Tier basso la presenza resta statica.
class MaestroBust extends StatefulWidget {
  const MaestroBust({
    super.key,
    required this.maestro,
    this.ring = 44,
    this.popOut = true,
    this.speaking = false,
    this.image,
  });

  final Maestro maestro;

  /// Diametro dell'anello alla base.
  final double ring;

  /// Vero: la testa sporge appena sopra l'anello (header, lente). Falso: il
  /// volto resta contenuto nel tondo (bolla), stesso taglio, senza sporgenza.
  final bool popOut;

  /// Quando vero, l'aura pulsa: il cenno di speaking mentre il Maestro risponde.
  final bool speaking;

  /// Sorgente dell'immagine. In produzione resta null e si usa l'avatar del
  /// Maestro; i test possono iniettare un provider che fallisce o che dipinge.
  final ImageProvider? image;

  /// Il punto del volto misurato per ciascun Maestro. Valori affinabili a
  /// occhio, ma partono giusti sugli asset reali.
  static const Map<Maestro, MaestroFacePoint> facePoints = {
    Maestro.medora:
        MaestroFacePoint(centerX: 0.52, headTopY: 0.05, collarY: 0.23),
    Maestro.aura: MaestroFacePoint(centerX: 0.49, headTopY: 0.03, collarY: 0.22),
    Maestro.caligo:
        MaestroFacePoint(centerX: 0.48, headTopY: 0.04, collarY: 0.23),
  };

  /// Quanta parte del diametro riempie la fascia del volto, dal capo al collo.
  static const double kBandOfDiameter = 0.8;

  /// Spazio sopra l'anello, in frazione del diametro, dove la testa sporge.
  static const double kTopPad = 0.32;

  /// Di quanto la sommita' del capo esce sopra il bordo dell'anello (popOut) o
  /// resta sotto di esso, cioe' contenuta (non popOut), in frazione del diametro.
  static const double kCrestOut = 0.05;
  static const double kCrestIn = -0.10;

  /// Calcola l'inquadratura per un Maestro a un dato diametro. E' la regola
  /// dell'inquadratura, in un punto solo, cosi' i test la verificano e il build
  /// la usa senza divergere. Tutti i valori scalano linearmente col diametro.
  static BustFraming framingFor({
    required Maestro maestro,
    required double ring,
    required bool popOut,
  }) {
    final p = facePoints[maestro]!;
    final band = p.collarY - p.headTopY;
    final imageHeight = kBandOfDiameter * ring / band;
    final topPad = popOut ? kTopPad * ring : 0.0;
    final boxHeight = ring + topPad;
    final ringTopY = topPad;
    final crest = (popOut ? kCrestOut : kCrestIn) * ring;
    final bandTop = ringTopY - crest;
    final verticalOffset = bandTop - p.headTopY * imageHeight;
    final bandBottom = verticalOffset + p.collarY * imageHeight;
    return BustFraming(
      imageHeight: imageHeight,
      verticalOffset: verticalOffset,
      faceDx: 0.5 - p.centerX,
      boxHeight: boxHeight,
      bandTop: bandTop,
      bandBottom: bandBottom,
    );
  }

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
  /// dall'`errorBuilder`. Allora si mostra l'icona di ripiego. Mai come fondale,
  /// mai durante il caricamento.
  bool _failed = false;

  ImageProvider get _provider =>
      widget.image ?? AssetImage(widget.maestro.avatarAsset);

  @override
  void didUpdateWidget(MaestroBust oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.maestro != widget.maestro || oldWidget.image != widget.image) {
      _failed = false;
    }
  }

  void _markFailed() {
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
    final pulsa = widget.speaking && motion;
    if (pulsa && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!pulsa && _controller.isAnimating) {
      _controller
        ..stop()
        ..value = 0;
    }

    final ring = widget.ring;
    final framing = MaestroBust.framingFor(
      maestro: widget.maestro,
      ring: ring,
      popOut: widget.popOut,
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final pulse = pulsa ? _controller.value : 0.0;
        return SizedBox(
          width: ring,
          height: framing.boxHeight,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // L'anello alla base, con l'aura che pulsa. L'icona di ripiego vive
              // qui, ma solo quando l'immagine ha fallito davvero.
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
              if (!_failed && widget.popOut)
                Positioned(
                  bottom: ring * 0.36,
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
              // Il volto inquadrato. Copre l'intero riquadro; nel popOut la testa
              // esce sopra l'anello, nella bolla resta dentro il tondo.
              if (!_failed)
                Positioned.fill(
                  child: _FaceView(
                    provider: _provider,
                    framing: framing,
                    ring: ring,
                    popOut: widget.popOut,
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

/// Disegna l'avatar inquadrato sul volto secondo [framing]. Nel popOut ritaglia
/// a rettangolo e sfuma in basso verso il collo; nella bolla ritaglia al tondo
/// dell'anello. Il centro del volto va al centro del cerchio con una traslazione
/// frazionaria, indipendente dalle proporzioni dell'immagine.
class _FaceView extends StatelessWidget {
  const _FaceView({
    required this.provider,
    required this.framing,
    required this.ring,
    required this.popOut,
    required this.onError,
  });

  final ImageProvider provider;
  final BustFraming framing;
  final double ring;
  final bool popOut;
  final VoidCallback onError;

  @override
  Widget build(BuildContext context) {
    Widget image = OverflowBox(
      alignment: Alignment.topCenter,
      minWidth: 0,
      maxWidth: double.infinity,
      minHeight: 0,
      maxHeight: double.infinity,
      child: Transform.translate(
        offset: Offset(0, framing.verticalOffset),
        child: FractionalTranslation(
          // Sposta il centro del volto al centro del cerchio, in frazione della
          // larghezza dell'immagine: aspetto-indipendente.
          translation: Offset(framing.faceDx, 0),
          child: Image(
            image: provider,
            height: framing.imageHeight,
            fit: BoxFit.fitHeight,
            alignment: Alignment.topCenter,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, __, ___) {
              onError();
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    if (!popOut) {
      // Bolla: il volto contenuto nel tondo dell'anello.
      return ClipOval(child: image);
    }

    // Header e lente: rettangolo, con la base che sfuma nel collo cosi' il volto
    // si posa sull'anello senza una linea netta.
    return ClipRect(
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (rect) {
          // La sfumatura parte appena sotto il collo, in proporzione al riquadro.
          final fadeStart =
              (framing.bandBottom / framing.boxHeight).clamp(0.0, 1.0);
          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: const [Colors.white, Colors.white, Colors.transparent],
            stops: [0.0, fadeStart, (fadeStart + 0.14).clamp(0.0, 1.0)],
          ).createShader(rect);
        },
        child: image,
      ),
    );
  }
}
