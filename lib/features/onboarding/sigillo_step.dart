import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/identity/circle_seal.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../identity/seal_painter.dart';

/// L'ultimo passo del Risveglio: il Sigillo, al centro, che si sigilla col
/// dito e si chiude con un trionfo.
///
/// Perche' e' una schermata a se' e non un passo come gli altri. Gli altri
/// passi usano l'impalcatura comune, che tiene il visivo in una scatola alta
/// 190 in cima e sotto mette titolo, sottotitolo e contenuto: e' giusta per un
/// passo dove si compila qualcosa, ed e' proprio quella scatola a spingere il
/// Sigillo in alto lasciando mezzo schermo vuoto sotto. Il Sigillo non
/// compila niente, e' un gesto: sta al CENTRO e tutto il resto gli gira
/// intorno.
///
/// Tre momenti, in ordine.
/// 1. Riposo: il Sigillo pulsa piano come un cuore.
/// 2. Pressione: un anello si riempie attorno al bordo, cosi' si vede che
///    bisogna tenere premuto e quanto manca. Alzando il dito prima della fine
///    l'anello torna indietro, senza punire.
/// 3. Trionfo: il Sigillo si espande, i raggi si accendono, le particelle si
///    diffondono e restano un istante prima che la schermata cambi.
///
/// Con Riduci Movimento non pulsa, non si riempie niente e il trionfo diventa
/// una dissolvenza: il gesto resta lo stesso, il tempo pure.
class SigilloStep extends StatefulWidget {
  const SigilloStep({
    super.key,
    required this.seal,
    required this.palette,
    required this.reduceMotion,
    required this.onComplete,
  });

  final CircleSeal seal;
  final MaestroPalette palette;
  final bool reduceMotion;
  final VoidCallback onComplete;

  /// Quanto va tenuto premuto perche' il Sigillo si chiuda. Abbastanza da
  /// essere un gesto voluto, non tanto da diventare una prova di pazienza.
  static const Duration attesa = Duration(milliseconds: 1100);

  /// La durata del trionfo. Va vista, quindi non puo' essere un lampo.
  static const Duration trionfo = Duration(milliseconds: 1500);

  /// Il diametro del Sigillo a riposo.
  static const double diametro = 168;

  @override
  State<SigilloStep> createState() => _SigilloStepState();
}

class _SigilloStepState extends State<SigilloStep>
    with TickerProviderStateMixin {
  late final AnimationController _cuore;
  late final AnimationController _tenuta;
  late final AnimationController _trionfo;
  bool _chiuso = false;

  @override
  void initState() {
    super.initState();
    _cuore = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    if (!widget.reduceMotion) _cuore.repeat(reverse: true);

    // L'anello di progressione. Torna indietro piu' in fretta di quanto
    // avanza: mollare non deve costare quanto premere.
    _tenuta = AnimationController(
      vsync: this,
      duration: SigilloStep.attesa,
      reverseDuration: const Duration(milliseconds: 260),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) _sigilla();
      });

    _trionfo = AnimationController(
      vsync: this,
      duration: SigilloStep.trionfo,
    )..addStatusListener((s) {
        // Il passaggio avviene alla FINE del trionfo: se avvenisse all'inizio
        // il trionfo non lo vedrebbe nessuno, che e' come non averlo fatto.
        if (s == AnimationStatus.completed) widget.onComplete();
      });
  }

  @override
  void dispose() {
    _cuore.dispose();
    _tenuta.dispose();
    _trionfo.dispose();
    super.dispose();
  }

  void _premi() {
    if (_chiuso) return;
    _tenuta.forward();
  }

  void _molla() {
    if (_chiuso) return;
    _tenuta.reverse();
  }

  void _sigilla() {
    if (_chiuso) return;
    setState(() => _chiuso = true);
    _cuore.stop();
    _trionfo.forward();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        // Il centro geometrico dell'area utile: e' li' che va il Sigillo, non
        // "in alto con dello spazio sotto".
        final centro = Offset(c.maxWidth / 2, c.maxHeight / 2);
        const raggio = SigilloStep.diametro / 2;

        return Stack(
          children: [
            // Il nome del rito, sopra il Sigillo ma non appiccicato al bordo:
            // a un sesto dell'altezza. Piu su lasciava una fascia vuota di
            // 231 px su 844, cioe' il 27 per cento, che e' lo stesso difetto di
            // prima ribaltato: prima il vuoto stava sotto, poi sopra.
            Positioned(
              top: c.maxHeight * 0.17,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text('Il tuo Sigillo',
                      textAlign: TextAlign.center,
                      style: TypographyTokens.display(size: 24)
                          .copyWith(color: widget.palette.goldSoft)),
                  const SizedBox(height: SpacingTokens.xs),
                  Text(
                    'Il numero che nasce dal tuo nome e dal tuo cielo.',
                    textAlign: TextAlign.center,
                    style: TypographyTokens.body(size: 14).copyWith(
                        color: ColorTokens.textSecondary, height: 1.45),
                  ),
                ],
              ),
            ),

            // Il Sigillo, centrato sul centro vero.
            Positioned(
              left: centro.dx - raggio,
              top: centro.dy - raggio,
              width: SigilloStep.diametro,
              height: SigilloStep.diametro,
              // Listener e non GestureDetector: il riconoscitore di tap
              // aspetta la sua soglia prima di dichiarare la pressione, e per
              // un anello che deve partire NEL momento in cui il dito tocca
              // quel ritardo si vede. Qui il dito scrive direttamente.
              child: Listener(
                key: const Key('risveglio_sigillo'),
                behavior: HitTestBehavior.opaque,
                onPointerDown: (_) => _premi(),
                onPointerUp: (_) => _molla(),
                onPointerCancel: (_) => _molla(),
                child: AnimatedBuilder(
                  animation:
                      Listenable.merge([_cuore, _tenuta, _trionfo]),
                  builder: (context, _) {
                    final battito = widget.reduceMotion
                        ? 0.0
                        : Curves.easeInOut.transform(_cuore.value);
                    final tenuta = _tenuta.value;
                    final t = _trionfo.value;

                    // La scala: il battito a riposo, un affondo mentre si
                    // preme, l'espansione del trionfo.
                    final espansione = _chiuso
                        ? (widget.reduceMotion
                            ? 1.0
                            : 1.0 + 0.30 * Curves.easeOutBack.transform(
                                math.min(1.0, t * 2.2)))
                        : 1.0;
                    final scala =
                        (1.0 + 0.05 * battito - 0.04 * tenuta) * espansione;

                    // Con Riduci Movimento il trionfo e' una dissolvenza.
                    final opacita = widget.reduceMotion && _chiuso
                        ? 1.0 - Curves.easeOut.transform(t)
                        : 1.0;

                    return Opacity(
                      opacity: opacita,
                      child: Transform.scale(
                        scale: scala,
                        child: CustomPaint(
                          painter: _SigilloPainter(
                            seal: widget.seal,
                            palette: widget.palette,
                            tenuta: widget.reduceMotion ? 0 : tenuta,
                            trionfo: widget.reduceMotion ? 0 : t,
                            chiuso: _chiuso,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // L'istruzione, appena sotto il Sigillo: dice cosa fare e dove.
            Positioned(
              top: centro.dy + raggio + SpacingTokens.lg,
              left: SpacingTokens.lg,
              right: SpacingTokens.lg,
              child: AnimatedOpacity(
                opacity: _chiuso ? 0 : 1,
                duration: const Duration(milliseconds: 260),
                child: Column(
                  children: [
                    Text(
                      'Posa il dito sul numero al centro',
                      key: const Key('sigillo_istruzione'),
                      textAlign: TextAlign.center,
                      style: TypographyTokens.body(size: 16).copyWith(
                          color: ColorTokens.textPrimary, height: 1.4),
                    ),
                    const SizedBox(height: SpacingTokens.md),
                    // La firma di cio' che si sta sigillando: nome, segno e
                    // numero. Non e' un riempitivo, e' il contenuto del
                    // Sigillo scritto in chiaro, e occupa la fascia che
                    // altrimenti resterebbe vuota fra il gesto e il fondo.
                    Text(
                      '${widget.seal.name} · ${widget.seal.sign.italianName} '
                      '· ${widget.seal.lifePath}',
                      textAlign: TextAlign.center,
                      style: TypographyTokens.label(size: 13).copyWith(
                        color: widget.palette.goldSoft.withValues(alpha: 0.8),
                        letterSpacing: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // In fondo, la riga che si accende a rito compiuto: chiude la
            // fascia bassa e dice che e' andata.
            Positioned(
              bottom: c.maxHeight * 0.13,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _chiuso ? 1 : 0,
                duration: const Duration(milliseconds: 420),
                child: Text(
                  'Il Cerchio ti riconosce',
                  textAlign: TextAlign.center,
                  style: TypographyTokens.display(size: 20)
                      .copyWith(color: widget.palette.goldSoft),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Il Sigillo con addosso l'anello di progressione e il trionfo.
class _SigilloPainter extends CustomPainter {
  _SigilloPainter({
    required this.seal,
    required this.palette,
    required this.tenuta,
    required this.trionfo,
    required this.chiuso,
  });

  final CircleSeal seal;
  final MaestroPalette palette;

  /// Quanto e' pieno l'anello di attesa, da 0 a 1.
  final double tenuta;

  /// Quanto e' avanzato il trionfo, da 0 a 1.
  final double trionfo;

  final bool chiuso;

  @override
  void paint(Canvas canvas, Size size) {
    // Il Sigillo vero e proprio: lo disegna il painter che esiste gia', cosi'
    // il segno resta quello del resto dell'app.
    SealPainter(seal: seal, progress: 1.0).paint(canvas, size);

    final c = size.center(Offset.zero);
    final r = size.width / 2;

    if (!chiuso && tenuta > 0) _anello(canvas, c, r);
    if (chiuso && trionfo > 0) _trionfo(canvas, c, r);
  }

  /// L'anello che si riempie: parte dall'alto e gira in senso orario, come
  /// ogni conto alla rovescia che la gente ha gia' visto.
  void _anello(Canvas canvas, Offset c, double r) {
    final raggio = r - 3;
    final rect = Rect.fromCircle(center: c, radius: raggio);

    // La traccia sotto, appena visibile: senza, l'arco sembra sospeso.
    canvas.drawCircle(
      c,
      raggio,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = palette.gold.withValues(alpha: 0.18),
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * tenuta,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.4
        ..strokeCap = StrokeCap.round
        ..color = palette.goldSoft,
    );
    // La testa dell'arco, un punto di luce che corre sul bordo.
    final a = -math.pi / 2 + 2 * math.pi * tenuta;
    canvas.drawCircle(
      c + Offset(math.cos(a), math.sin(a)) * raggio,
      3.2,
      Paint()..color = palette.goldSoft,
    );
  }

  /// Il trionfo: raggi che si accendono e particelle che si diffondono.
  void _trionfo(Canvas canvas, Offset c, double r) {
    // Tre tempi dentro un'animazione sola: l'onda parte subito, i raggi
    // crescono e restano, le particelle escono e svaniscono in coda.
    final onda = Curves.easeOut.transform(math.min(1.0, trionfo * 1.8));
    final raggi = Curves.easeOutCubic.transform(
        ((trionfo - 0.06) / 0.5).clamp(0.0, 1.0));
    final semi = ((trionfo - 0.12) / 0.85).clamp(0.0, 1.0);

    // L'onda circolare che si allarga e si dissolve.
    if (onda < 1) {
      canvas.drawCircle(
        c,
        r * (0.9 + 1.5 * onda),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5 * (1 - onda)
          ..color = palette.goldSoft.withValues(alpha: 0.55 * (1 - onda)),
      );
    }

    // I raggi: dodici, come i segni, quindi il numero non e' casuale.
    const quanti = 12;
    for (var i = 0; i < quanti; i++) {
      final a = -math.pi / 2 + i * 2 * math.pi / quanti;
      final d = Offset(math.cos(a), math.sin(a));
      final da = r * 0.98;
      final aA = r * (0.98 + 0.55 * raggi);
      // Svaniscono in coda al trionfo, senza sparire di colpo.
      final coda = 1.0 - ((trionfo - 0.62) / 0.38).clamp(0.0, 1.0);
      canvas.drawLine(
        c + d * da,
        c + d * aA,
        Paint()
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round
          ..color = palette.goldSoft.withValues(alpha: 0.75 * raggi * coda),
      );
    }

    // Le particelle: deterministiche, cosi' il trionfo e' sempre lo stesso
    // e non balla fra una prova e l'altra.
    final rnd = math.Random(seal.lifePath * 7919 + 31);
    for (var i = 0; i < 26; i++) {
      final a = rnd.nextDouble() * 2 * math.pi;
      final ritardo = rnd.nextDouble() * 0.25;
      final k = ((semi - ritardo) / (1 - ritardo)).clamp(0.0, 1.0);
      if (k <= 0) continue;
      final lontananza = r * (1.0 + 1.35 * Curves.easeOut.transform(k));
      final p = c + Offset(math.cos(a), math.sin(a)) * lontananza;
      canvas.drawCircle(
        p,
        2.2 * (1 - k) + 0.6,
        Paint()
          ..color = (i.isEven ? palette.goldSoft : palette.glow)
              .withValues(alpha: 0.9 * (1 - k)),
      );
    }
  }

  @override
  bool shouldRepaint(_SigilloPainter old) =>
      old.tenuta != tenuta ||
      old.trionfo != trionfo ||
      old.chiuso != chiuso ||
      old.seal != seal;
}
