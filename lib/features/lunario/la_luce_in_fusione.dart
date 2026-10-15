import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// **LA LUCE IN FUSIONE SCHERMO.** Ordine FV voci FV.01 e FV.06, 15 ottobre
/// 2026: le tre luci dipinte (l'alone d'oro, la scia d'oro e il seme di
/// luce) sono luce su fondo nero, "da posare in fusione schermo (il nero
/// sparisce)".
///
/// Flutter non ha un widget che posi un'immagine in `BlendMode.screen` su
/// cio' che sta sotto: questo lo fa e basta. Apre uno strato col pennello in
/// fusione schermo, ci dipinge l'asset e lo chiude; l'opacita' sta nel
/// pennello dello strato, cosi' la dissolvenza non passa da un `Opacity` che
/// aprirebbe uno strato suo e farebbe ricomparire il nero.
///
/// **Non disegna niente di suo** (R9, la grafica e' dipinta): dipinge solo il
/// figlio, che e' un asset.
///
/// **Il limite, dichiarato**: la fusione vale contro cio' che e' dipinto
/// nello stesso strato. Per questo la schermata posa le luci fuori da ogni
/// `PageView`, `RepaintBoundary` o `Opacity`, nello stesso strato dello
/// sfondo della scena.
class LaLuceInFusione extends SingleChildRenderObjectWidget {
  const LaLuceInFusione({super.key, this.opacita = 1, required Widget child})
      : super(child: child);

  /// Da 0 a 1.
  final double opacita;

  /// La fusione: schermo, come vuole l'ordine.
  static const BlendMode fusione = BlendMode.screen;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      RenderDellaLuceInFusione(opacita);

  @override
  void updateRenderObject(
          BuildContext context, covariant RenderDellaLuceInFusione renderObject) =>
      renderObject.opacita = opacita;
}

class RenderDellaLuceInFusione extends RenderProxyBox {
  RenderDellaLuceInFusione(this._opacita);

  double _opacita;
  set opacita(double v) {
    if (v == _opacita) return;
    _opacita = v;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final figlio = child;
    if (figlio == null || _opacita <= 0) return;
    final a = (_opacita.clamp(0.0, 1.0) * 255).round();
    context.canvas.saveLayer(
      offset & size,
      Paint()
        ..blendMode = LaLuceInFusione.fusione
        ..color = Color.fromARGB(a, 0, 0, 0),
    );
    context.paintChild(figlio, offset);
    context.canvas.restore();
  }
}
