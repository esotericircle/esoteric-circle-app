import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  ///
  /// **Non si puo' alzare, e l'ho verificato.** Portandolo a diciotto piu' sei
  /// gli elementi vicini si SOVRAPPONGONO durante la comparsa, perche' ognuno e'
  /// traslato di una quantita' diversa secondo il proprio strato: un tocco che
  /// arriva in quel momento finisce sulla voce sbagliata, e tre prove del
  /// dominio lo hanno denunciato. Per crescere davvero, prima va sospeso il
  /// tocco finche' la comparsa non e' conclusa.
  static double slideFor(int depth) => 10.0 + depth * 8.0;

  /// La durata della sola comparsa, uguale per tutti gli strati.
  ///
  /// Era 260 millisecondi, ed e' il motivo per cui la comparsa veniva
  /// dichiarata fatta e a schermo non si notava: un quarto di secondo e' sotto
  /// la soglia di quello che l'occhio registra come movimento, soprattutto
  /// mentre la transizione della rotta, che dura circa 300 millisecondi, sta
  /// ancora entrando e copre tutto.
  ///
  /// 420 millisecondi: la comparsa sopravvive all'ingresso della schermata,
  /// quindi si vede. Cio' che si nota e' la dissolvenza dell'opacita', non i
  /// dieci pixel di tragitto, che restano quelli per la ragione qui sopra.
  static const Duration duration = Duration(milliseconds: 420);

  /// Il ritardo di partenza di uno strato.
  static Duration delayFor(int depth) => Duration(milliseconds: depth * 60);

  /// Se il movimento va spento: Riduci Movimento di sistema oppure Quality Tier
  /// basso. Sta qui, in un punto solo, cosi' i test la verificano.
  ///
  /// Con [listen] falso non si iscrive ai cambi, e allora si puo' chiamare
  /// anche fuori da un build, per esempio dentro un gestore di tocco.
  static bool motionOff(BuildContext context, {bool listen = true}) {
    if (MediaQuery.of(context).disableAnimations) return true;
    // Il controller puo' mancare in una superficie montata da sola: la lettura
    // nullabile torna null invece di sollevare, e il movimento resta acceso.
    return Provider.of<QualityTierController?>(context, listen: listen)?.tier ==
        QualityTier.low;
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

  // La posizione di scorrimento a cui questo elemento e' agganciato. Prima la
  // comparsa partiva al montaggio, non all'ingresso nello schermo: su una
  // lista non pigra tutto si rivelava insieme, fuori vista compreso, e
  // scendendo si trovavano elementi gia' fermi da un pezzo.
  ScrollPosition? _position;

  /// Quanti pixel dell'elemento devono essere entrati perche' la comparsa
  /// parta: un filo, cosi' parte appena il bordo affiora.
  static const double _soglia = 24;

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
    final pos = Scrollable.maybeOf(context)?.position;
    if (!identical(pos, _position)) {
      _position?.removeListener(_controlla);
      _position = pos;
      if (!_off && !_revealed) _position?.addListener(_controlla);
    }
    // Il primo controllo aspetta il layout: prima non c'e' una geometria.
    if (!_off && !_revealed) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _controlla());
    }
  }

  /// Parte solo quando l'elemento sta davvero entrando nello schermo.
  void _controlla() {
    if (!mounted || _off || _revealed || _controller.isAnimating) return;
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !box.hasSize) return;
    final pos = _position;
    if (pos == null || !pos.hasPixels || !pos.hasViewportDimension) {
      // Nessuno scorrimento attorno: la superficie e' ferma e l'elemento e'
      // gia' in scena, quindi si rivela subito.
      _avvia();
      return;
    }
    final viewport = RenderAbstractViewport.maybeOf(box);
    if (viewport == null) {
      _avvia();
      return;
    }
    // L'offset che porterebbe il bordo alto dell'elemento in cima alla
    // finestra: l'elemento affiora dal fondo quando lo scorrimento supera
    // quell'offset meno l'altezza della finestra.
    final rivelaA = viewport.getOffsetToReveal(box, 0).offset;
    final affiora = rivelaA - pos.viewportDimension + _soglia;
    if (pos.pixels >= affiora) _avvia();
  }

  void _avvia() {
    _position?.removeListener(_controlla);
    // Niente setState al completamento: _revealed serve solo a non ripartire.
    // La forma dell'albero NON cambia mai (vedi build): cambiarla al volo
    // deattiverebbe e ricreerebbe l'intero sottoalbero, perdendo ogni stato e
    // uccidendo i contesti catturati dalle chiusure, che e' la famiglia degli
    // schianti "deactivated widget's ancestor".
    _controller.forward().whenComplete(() {
      if (mounted) _revealed = true;
    });
  }

  @override
  void dispose() {
    _position?.removeListener(_controlla);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // La forma dell'albero e' SEMPRE la stessa, prima, durante e dopo la
    // comparsa: a riposo l'involucro vale identita' (opacita' 1, scostamento
    // zero, che il framework salta senza costo). Restituire il figlio nudo
    // dopo la comparsa sembrava una pulizia ed era una bomba: il sottoalbero
    // veniva deattivato e ricreato, perdendo stato e contesti.
    final slide = ScrollReveal.slideFor(widget.depth);
    return AnimatedBuilder(
      animation: _t,
      child: widget.child,
      builder: (context, child) {
        final t = _off ? 1.0 : _t.value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * slide),
            child: child,
          ),
        );
      },
    );
  }
}
