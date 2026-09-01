import 'dart:math' as math;

import 'dart:async';

import '../../../sigilli/regia_del_cammino.dart';

import 'package:flutter/material.dart';

import '../../../../design_system/theme/maestro_palette.dart';
import '../../../../design_system/theme/maestro_scope.dart';
import '../../../../design_system/tokens/color_tokens.dart';
import '../../../../design_system/tokens/spacing_tokens.dart';
import '../../../../design_system/tokens/typography_tokens.dart';
import 'meditation_audio.dart';
import '../../../../core/maestro/maestro.dart';
import '../../rotta_arte.dart';
import '../../../../../design_system/components/titolo_che_non_si_rompe.dart';
import '../../../../design_system/transizioni/passaggio_del_cerchio.dart';
import '../../../../design_system/typography/paragrafi_di_lettura.dart';

/// Meditazione di Aura con suono e cimatica.
///
/// Tre strati che nascono l'uno dall'altro: uno strato sonoro generato a runtime
/// (toni a 432 e 528 Hz e un battito binaurale, da ascoltare con le cuffie), un
/// visualizzatore a cimatica (un mandala di geometria sacra che nasce dal suono
/// e pulsa col respiro) e una guida al respiro. Fondamento onesto: cornice di
/// benessere e non cura, le frequenze come tradizione culturale, non fatto
/// medico. Il disclaimer completo sta all'ingresso, non si ripete qui.
///
/// La prova dell'audio resta al device, dietro `TonePlayer`: in headless si usa
/// il lettore silenzioso, che genera comunque i toni senza riprodurli.
class MeditationScreen extends StatefulWidget {
  MeditationScreen({super.key, TonePlayer? player})
      : player = player ?? LettoreToniReale();

  final TonePlayer player;

  static Route<void> route({TonePlayer? player}) {
    return PassaggioDelCerchio.rotta<void>((_) => SogliaArte(
        id: 'meditation',
        maestro: Maestro.aura,
        child: MeditationScreen(player: player)));
  }

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen>
    with TickerProviderStateMixin {
  // Il respiro: inspira, trattieni, espira, in un ciclo lento e continuo.
  static const int _inhaleMs = 4000;
  static const int _holdMs = 2000;
  static const int _exhaleMs = 5000;
  static const int _cycleMs = _inhaleMs + _holdMs + _exhaleMs;

  late final AnimationController _breath;
  MeditationPreset _preset = MeditationPreset.calm432;
  bool _active = false;

  /// **LA MEDITAZIONE HA UNA FINE, ordine BF voce 05.b (ordine P voce 35).**
  /// Prima il respiro girava in cerchio per sempre: la schermata non
  /// arrivava a una chiusura, non accendeva traguardi e non funzionava come
  /// rito. La sessione dura [cicliDellaSessione] cicli di respiro (dodici
  /// da undici secondi, poco piu' di due minuti): al compimento il tono si
  /// ferma, la scena lo dice, e la regia registra il gesto `meditazione`,
  /// che e' cio' che sveglia aur_50 e aur_51. Il tempo lo tiene un Timer e
  /// non l'animazione, cosi' il compimento arriva anche con Riduci
  /// Movimento, dove il respiro visivo sta fermo.
  static const int cicliDellaSessione = 12;
  Timer? _sessione;
  bool _compiuta = false;

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _cycleMs),
    );
  }

  /// **IL GIRO PARTE SOLO SENZA RIDUCI MOVIMENTO, ordine AJ voce 01**: il
  /// repeat di `_breath` girava anche per chi ha chiesto meno movimento. La
  /// MediaQuery non si legge in initState, quindi la guardia sta qui e vale
  /// a ogni cambio di dipendenze.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      if (_breath.isAnimating) _breath.stop();
    } else {
      if (!_breath.isAnimating) _breath.repeat();
    }
  }

  @override
  void dispose() {
    // IL TONO SI FERMA QUI. Prima si chiudeva il respiro e basta: il tono suona
    // in ciclo continuo, quindi uscendo dalla schermata restava acceso per
    // sempre. Che fosse una dimenticanza e non una scelta lo diceva il Rito del
    // Sogno, che con lo stesso lettore lo fermava gia'.
    _sessione?.cancel();
    widget.player.stop();
    _breath.dispose();
    super.dispose();
  }

  // Da 0 a 1: quanto e' pieno il respiro adesso, piu' l'etichetta della fase.
  ({double fill, String phase}) _breathState() {
    final ms = _breath.value * _cycleMs;
    if (ms < _inhaleMs) {
      return (
        fill: Curves.easeInOut.transform(ms / _inhaleMs),
        phase: 'Inspira'
      );
    }
    if (ms < _inhaleMs + _holdMs) {
      return (fill: 1.0, phase: 'Trattieni');
    }
    final e = (ms - _inhaleMs - _holdMs) / _exhaleMs;
    return (fill: 1.0 - Curves.easeInOut.transform(e), phase: 'Espira');
  }

  void _togglePlay() {
    setState(() {
      _active = !_active;
      if (_active) _compiuta = false;
    });
    if (_active) {
      widget.player.play(_preset);
      _sessione?.cancel();
      _sessione = Timer(
        const Duration(milliseconds: _cycleMs * cicliDellaSessione),
        _alCompimento,
      );
    } else {
      // Fermarsi a meta' non e' compiere: il gesto si registra solo alla
      // fine della sessione, e chi interrompe riparte da capo.
      _sessione?.cancel();
      widget.player.stop();
    }
  }

  void _alCompimento() {
    if (!mounted) return;
    widget.player.stop();
    setState(() {
      _active = false;
      _compiuta = true;
    });
    // IL CAMMINO SE NE ACCORGE: la meditazione e' compiuta, non aperta.
    unawaited(RegiaDelCammino.dopoUnGesto(context, 'meditazione'));
  }

  void _choose(MeditationPreset preset) {
    setState(() => _preset = preset);
    if (_active) widget.player.play(preset);
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    return Scaffold(
      backgroundColor: ColorTokens.neutralDeepest,
      appBar: AppBar(
        backgroundColor: palette.deepest.withValues(alpha: 0.4),
        elevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Indietro',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        // **IL TITOLO NON SI ROMPE**, ordine S voce 05: a capo fra le
        // parole, la misura scende solo quanto serve, e non si tronca mai.
        // Col borsellino nella riga delle azioni lo spazio del titolo si e'
        // ristretto, e un `Text` nudo qui torna a mettere i puntini.
        title: TitoloCheNonSiRompe(
            testo: 'Meditazione', stile: TypographyTokens.titoloDiSchermata()),
        // IL BORSELLINO, ordine S voce 06: stesso segno, stesso angolo, in
        // ogni schermata della pratica. Un saldo che appare e scompare non
        // si impara.
        actions: const [AngoloDellaBarra()],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Il visualizzatore a cimatica, col respiro sovrapposto.
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: AnimatedBuilder(
                    animation: _breath,
                    builder: (context, _) {
                      final b = _breathState();
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              key: const Key('meditation_cymatics'),
                              painter: _CymaticsPainter(
                                breath: b.fill,
                                preset: _preset,
                                active: _active,
                                palette: palette,
                              ),
                            ),
                          ),
                          _BreathGuide(
                            fill: b.fill,
                            phase: _active
                                ? b.phase
                                : (_compiuta
                                    ? 'Il respiro è compiuto'
                                    : 'Tocca per iniziare'),
                            palette: palette,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  SpacingTokens.lg, 0, SpacingTokens.lg, SpacingTokens.md),
              child: Column(
                children: [
                  // Selettore dei preset sonori.
                  Row(
                    children: [
                      for (final p in MeditationPreset.values) ...[
                        _PresetChip(
                          preset: p,
                          selected: p == _preset,
                          palette: palette,
                          onTap: () => _choose(p),
                        ),
                        if (p != MeditationPreset.values.last)
                          const SizedBox(width: SpacingTokens.sm),
                      ],
                    ],
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  // **IL COMPIMENTO SI DICE, ordine BF voce 05.b**: senza
                  // questa riga la sessione finirebbe in silenzio e la
                  // persona non saprebbe di essere arrivata.
                  if (_compiuta) ...[
                    Row(
                      key: const Key('meditazione_compiuta'),
                      children: [
                        Icon(Icons.spa_outlined,
                            size: 16, color: palette.goldSoft),
                        const SizedBox(width: SpacingTokens.xs),
                        Expanded(
                          child: ParagrafiDiLettura(
                            testo: 'La meditazione è portata a compimento: '
                                'porta questa calma con te.',
                            stile: TypographyTokens.lettura()
                                .copyWith(color: palette.goldSoft),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: SpacingTokens.md),
                  ],
                  // Play e invito alle cuffie.
                  Row(
                    children: [
                      _PlayButton(
                        active: _active,
                        palette: palette,
                        onTap: _togglePlay,
                      ),
                      const SizedBox(width: SpacingTokens.md),
                      Expanded(
                        child: Text(
                          _preset.binaural
                              ? 'Metti le cuffie: il battito nasce fra i due orecchi.'
                              : 'Con le cuffie l\'ascolto si fa più pieno.',
                          style: TypographyTokens.corpo()
                              .copyWith(color: ColorTokens.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SpacingTokens.md),
                  // Fondamento onesto, senza ripetere il disclaimer.
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.eco_outlined,
                          size: 14, color: palette.goldSoft),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Cornice di benessere, non cura. Le frequenze Solfeggio '
                          'e il 432 sono tradizione culturale, non un fatto medico.',
                          style: TypographyTokens.corpo().copyWith(
                            color: palette.goldSoft.withValues(alpha: 0.7),
                            letterSpacing: 0.3,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// La guida al respiro: un cerchio che si allarga inspirando e si restringe
/// espirando, con l'etichetta della fase al centro.
class _BreathGuide extends StatelessWidget {
  const _BreathGuide({
    required this.fill,
    required this.phase,
    required this.palette,
  });

  final double fill;
  final String phase;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(constraints.maxWidth, constraints.maxHeight);
        final d = side * (0.28 + 0.16 * fill);
        return Container(
          width: d,
          height: d,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              palette.primary.withValues(alpha: 0.35),
              palette.deepest.withValues(alpha: 0.05),
            ]),
            border: Border.all(
                color: palette.gold.withValues(alpha: 0.5), width: 1.2),
          ),
          child: Text(
            phase,
            textAlign: TextAlign.center,
            style: TypographyTokens.label(size: 12).copyWith(
              color: palette.goldSoft,
              letterSpacing: 1.4,
            ),
          ),
        );
      },
    );
  }
}

/// Un preset sonoro selezionabile.
class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.preset,
    required this.selected,
    required this.palette,
    required this.onTap,
  });

  final MeditationPreset preset;
  final bool selected;
  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        key: Key('meditation_preset_${preset.id}'),
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: SpacingTokens.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SpacingTokens.radiusMd),
            gradient: selected
                ? LinearGradient(colors: [
                    palette.primary.withValues(alpha: 0.6),
                    palette.surfaceElevated.withValues(alpha: 0.6),
                  ])
                : null,
            border: Border.all(
              color: selected
                  ? palette.gold.withValues(alpha: 0.7)
                  : palette.gold.withValues(alpha: 0.22),
            ),
          ),
          child: Column(
            children: [
              Text(
                preset.label,
                textAlign: TextAlign.center,
                style: TypographyTokens.titoloDiRiga().copyWith(
                  color:
                      selected ? palette.goldSoft : ColorTokens.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              // Nessun troncamento: il sottotitolo va a capo per intero.
              Text(
                preset.subtitle,
                textAlign: TextAlign.center,
                style: TypographyTokens.etichetta().copyWith(
                  color: selected
                      ? palette.goldSoft.withValues(alpha: 0.8)
                      : ColorTokens.textSecondary.withValues(alpha: 0.8),
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Il bottone che avvia o ferma il suono e il visualizzatore.
class _PlayButton extends StatelessWidget {
  const _PlayButton({
    required this.active,
    required this.palette,
    required this.onTap,
  });

  final bool active;
  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('meditation_play'),
      onTap: onTap,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [
            palette.primary.withValues(alpha: 0.7),
            palette.surfaceElevated.withValues(alpha: 0.6),
          ]),
          border: Border.all(color: palette.gold.withValues(alpha: 0.7)),
          boxShadow: [
            BoxShadow(
              color: palette.glow.withValues(alpha: active ? 0.5 : 0.2),
              blurRadius: 18,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Icon(
          active ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: palette.goldSoft,
          size: 30,
        ),
      ),
    );
  }
}

/// Il visualizzatore a cimatica: un mandala di geometria sacra che nasce dal
/// suono (la simmetria viene dalla frequenza del preset) e pulsa col respiro.
///
/// Non e' una simulazione fisica di Chladni, ma un'evocazione fedele nello
/// spirito: onde stazionarie a simmetria radiale, il cui numero di lobi cresce
/// con la frequenza, che si aprono inspirando e si chiudono espirando.
class _CymaticsPainter extends CustomPainter {
  _CymaticsPainter({
    required this.breath,
    required this.preset,
    required this.active,
    required this.palette,
  });

  final double breath;
  final MeditationPreset preset;
  final bool active;
  final MaestroPalette palette;

  int get _symmetry => (preset.baseHz / 48).round().clamp(5, 12);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxR = size.shortestSide / 2 * 0.94;
    // Col respiro il mandala si apre; da fermo resta raccolto e tenue.
    final intensity = active ? 1.0 : 0.4;
    final open = 0.7 + 0.3 * breath;

    // Alone di fondo, verde smeraldo di Aura verso l'oro.
    canvas.drawCircle(
      center,
      maxR,
      Paint()
        ..shader = RadialGradient(colors: [
          palette.glow.withValues(alpha: 0.12 * intensity),
          Colors.transparent,
        ]).createShader(Rect.fromCircle(center: center, radius: maxR)),
    );

    final sym = _symmetry;

    // Anelli concentrici delle onde stazionarie: nodi e ventri.
    const rings = 5;
    for (var k = 1; k <= rings; k++) {
      final rr = maxR * open * k / rings;
      canvas.drawCircle(
        center,
        rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = palette.gold.withValues(alpha: 0.10 * intensity),
      );
    }

    // Due rose sovrapposte, la simmetria dal suono: r = R (0.5 + 0.5 |cos(sym t)|).
    _drawRose(canvas, center, maxR * open, sym, palette.goldSoft,
        0.75 * intensity, 1.4);
    _drawRose(canvas, center, maxR * open * 0.66, sym * 2, palette.glow,
        0.5 * intensity, 1.0);

    // Nodi luminosi sulle punte dei lobi, dove il suono raccoglie la materia.
    final nodePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85 * intensity);
    for (var i = 0; i < sym; i++) {
      final a = 2 * math.pi * i / sym - math.pi / 2;
      final tip = center + Offset(math.cos(a), math.sin(a)) * maxR * open;
      canvas.drawCircle(tip, 2.2 + 2.0 * breath, nodePaint);
      canvas.drawCircle(
        tip,
        6 + 4 * breath,
        Paint()
          ..color = palette.goldSoft.withValues(alpha: 0.25 * intensity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }

    // Cuore luminoso che respira.
    canvas.drawCircle(
      center,
      maxR * 0.06 * (0.7 + 0.6 * breath),
      Paint()
        ..shader = RadialGradient(colors: [
          Colors.white.withValues(alpha: 0.9 * intensity),
          palette.goldSoft.withValues(alpha: 0.0),
        ]).createShader(Rect.fromCircle(
            center: center, radius: maxR * 0.12 * (0.7 + 0.6 * breath))),
    );
  }

  void _drawRose(Canvas canvas, Offset center, double radius, int petals,
      Color color, double alpha, double stroke) {
    final path = Path();
    const steps = 720;
    for (var i = 0; i <= steps; i++) {
      final t = 2 * math.pi * i / steps;
      final r = radius * (0.5 + 0.5 * math.cos(petals * t).abs());
      final p = center + Offset(math.cos(t), math.sin(t)) * r;
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeJoin = StrokeJoin.round
        ..color = color.withValues(alpha: alpha),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.fill
        ..color = color.withValues(alpha: 0.06 * alpha),
    );
  }

  @override
  bool shouldRepaint(_CymaticsPainter old) =>
      old.breath != breath ||
      old.preset != preset ||
      old.active != active ||
      old.palette != palette;
}
