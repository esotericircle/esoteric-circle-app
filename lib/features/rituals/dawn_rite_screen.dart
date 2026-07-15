import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/astro/night_sky.dart';
import '../../core/astro/zodiac.dart';
import '../../core/identity/profile_controller.dart';
import '../../core/maestro/maestro.dart';
import '../../core/rituals/daily_rituals.dart';
import '../../core/rituals/dawn_gift.dart';
import '../../core/rituals/ritual_streak.dart';
import '../../design_system/components/ritual_backdrop.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// Rito dell'Alba, prototipo di riferimento dei cinque riti quotidiani.
///
/// Fondale reale cablato nello slot condiviso e Maestro a rotazione giornaliera,
/// entrambi gia' esistenti, restano il basamento. Sopra si costruisce il rito
/// completo: un gesto rituale di sollevamento dell'alba con un livello di luce
/// che cresce sopra la foto e uno stato rivelato che porge il dono del giorno.
///
/// Ogni gesto ha il suo ripiego tattile universale (tocco o tocco prolungato) e
/// tutte le animazioni rispettano Riduci Movimento.
class DawnRiteScreen extends StatefulWidget {
  const DawnRiteScreen({super.key, this.now});

  final DateTime? now;

  static Route<void> route({DateTime? now}) => MaterialPageRoute<void>(
        builder: (_) => MaestroScope(child: DawnRiteScreen(now: now)),
      );

  @override
  State<DawnRiteScreen> createState() => _DawnRiteScreenState();
}

class _DawnRiteScreenState extends State<DawnRiteScreen>
    with TickerProviderStateMixin {
  // Livello di sollevamento dell'alba, da 0 (velato) a 1 (alba sollevata).
  double _progress = 0;
  bool _revealed = false;
  DawnGift? _gift;
  int _streak = 0;

  // Anima il completamento del gesto, o il ritorno se rilasciato troppo presto.
  late final AnimationController _lift;
  Animation<double>? _liftAnim;

  // Deriva lenta e brillio del riflesso, ambiente, ferma sotto Riduci Movimento.
  late final AnimationController _ambient;

  // Distanza di trascinamento verso l'alto che solleva del tutto l'alba.
  static const double _dragSpan = 220;
  // Oltre questa soglia, al rilascio, l'alba si compie da sola.
  static const double _completeThreshold = 0.55;

  @override
  void initState() {
    super.initState();
    _lift = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    )..addListener(() {
        final anim = _liftAnim;
        if (anim != null) setState(() => _progress = anim.value);
      });
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();
  }

  @override
  void dispose() {
    _lift.dispose();
    _ambient.dispose();
    super.dispose();
  }

  bool get _reduceMotion => MediaQuery.of(context).disableAnimations;

  // Segno dell'utente dal profilo, se disponibile. Senza ProfileController, per
  // esempio montando lo screen da solo in un test, si ripiega su null.
  Zodiac? _userSign() {
    try {
      final identity = context.read<ProfileController>().identity;
      return NightSky.sunSign(identity.birthMoment);
    } catch (_) {
      return null;
    }
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (_revealed) return;
    _lift.stop();
    setState(() {
      // Trascinare verso l'alto (delta negativo) solleva l'alba.
      _progress = (_progress - (d.primaryDelta ?? 0) / _dragSpan).clamp(0.0, 1.0);
    });
  }

  void _onDragEnd(DragEndDetails _) {
    if (_revealed) return;
    if (_progress >= _completeThreshold) {
      _complete();
    } else {
      _animateProgressTo(0);
    }
  }

  // Ripiego tattile universale: un tocco, o un tocco prolungato, compie il rito.
  void _tapComplete() {
    if (_revealed) return;
    _complete();
  }

  void _complete() {
    if (_reduceMotion) {
      setState(() => _progress = 1);
      _reveal();
      return;
    }
    _animateProgressTo(1, onDone: _reveal);
  }

  void _animateProgressTo(double target, {VoidCallback? onDone}) {
    _liftAnim = Tween<double>(begin: _progress, end: target).animate(
      CurvedAnimation(parent: _lift, curve: Curves.easeOutCubic),
    );
    _lift.forward(from: 0).then((_) {
      if (mounted) onDone?.call();
    });
  }

  void _reveal() {
    if (_revealed) return;
    final date = widget.now ?? DateTime.now();
    setState(() {
      _revealed = true;
      _gift = DawnGift.of(date, sign: _userSign());
    });
    _recordStreak(date);
  }

  Future<void> _recordStreak(DateTime date) async {
    final n = await const RitualStreak(id: 'dawn').recordToday(date);
    if (!mounted) return;
    setState(() => _streak = n);
  }

  Future<void> _shareWord(DawnGift gift) async {
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: 'La mia parola del giorno dal Rito dell\'Alba: ${gift.word}. '
              '${gift.message} Con Esoteric Circle.',
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Condivisione non disponibile ora.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = widget.now ?? DateTime.now();
    final maestro = DailyRituals.dawnMaestro(date);
    final palette = MaestroPalette.forKey(ThemeKey.of(maestro));

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
        title: Text('Rito dell\'Alba',
            style: TypographyTokens.display(size: 20)),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondale reale dell'alba, gia' cablato nello slot condiviso. La
          // palette del Maestro di turno conta solo per l'eventuale ripiego
          // procedurale, l'immagine reale non ne dipende.
          RitualBackdrop(
            palette: palette,
            assetPath: 'assets/ritual_backgrounds/dawn.png',
            child: const SizedBox.expand(),
          ),
          // Livello di luce del sollevamento, sopra la foto, mai un secondo sole.
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: Listenable.merge([_lift, _ambient]),
                builder: (context, _) => CustomPaint(
                  painter: _DawnLightPainter(
                    progress: _progress,
                    ambient: _reduceMotion ? 0 : _ambient.value,
                    palette: palette,
                    reduceMotion: _reduceMotion,
                  ),
                ),
              ),
            ),
          ),
          // Scena e responso.
          SafeArea(
            top: false,
            child: Column(
              children: [
                Expanded(
                  flex: 5,
                  child: Semantics(
                    button: true,
                    label:
                        'Solleva l\'alba. Trascina verso l\'alto, oppure tocca.',
                    onTap: _tapComplete,
                    child: GestureDetector(
                      key: const Key('ritual_gesture'),
                      behavior: HitTestBehavior.opaque,
                      onVerticalDragUpdate: _onDragUpdate,
                      onVerticalDragEnd: _onDragEnd,
                      onTap: _tapComplete,
                      onLongPress: _tapComplete,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (!_revealed)
                            Positioned(
                              bottom: SpacingTokens.lg,
                              child: _LiftPrompt(
                                  palette: palette, progress: _progress),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Stack(
                    children: [
                      // Velo scuro morbido dietro il dono: tiene il testo
                      // leggibile anche col bagliore al massimo, coprendo il
                      // testo e non la scena. Sfuma verso l'alto, cosi' non
                      // taglia un bordo netto sulla foto.
                      if (_revealed)
                        const Positioned.fill(
                          child: IgnorePointer(child: _GiftVeil()),
                        ),
                      SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, 0,
                            SpacingTokens.lg, SpacingTokens.lg),
                        child: (_revealed && _gift != null)
                            ? _DawnGiftCard(
                                key: const Key('ritual_content'),
                                gift: _gift!,
                                palette: palette,
                                streak: _streak,
                                onShare: () => _shareWord(_gift!),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Velo scuro morbido dietro il blocco del dono. Sfuma dall'alto trasparente al
/// fondo scuro, cosi' copre il testo e non la scena, e regge la lettura anche
/// col bagliore del sollevamento al massimo.
class _GiftVeil extends StatelessWidget {
  const _GiftVeil();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x00000000),
            Color(0x59000000),
            Color(0x8C000000),
          ],
          stops: [0.0, 0.35, 1.0],
        ),
      ),
    );
  }
}

/// L'invito al gesto, che si accende man mano che l'alba si solleva.
class _LiftPrompt extends StatelessWidget {
  const _LiftPrompt({required this.palette, required this.progress});

  final MaestroPalette palette;
  final double progress;

  @override
  Widget build(BuildContext context) {
    // Velo scuro morbido dietro il sotto invito: un alone che sfuma ai bordi,
    // cosi' il testo resta leggibile sul riflesso luminoso senza tagliare un
    // riquadro sulla scena.
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.lg, vertical: SpacingTokens.md),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          radius: 0.95,
          colors: [
            Colors.black.withValues(alpha: 0.34),
            Colors.black.withValues(alpha: 0.0),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.keyboard_double_arrow_up_rounded,
              color: palette.goldSoft.withValues(alpha: 0.6 + 0.4 * progress),
              size: 26),
          const SizedBox(height: SpacingTokens.sm),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
              color: palette.deepest.withValues(alpha: 0.5),
              border: Border.all(color: palette.gold.withValues(alpha: 0.5)),
            ),
            child: Text(
              'Trascina verso l\'alto per sollevare l\'alba',
              style: TypographyTokens.label(size: 12)
                  .copyWith(color: palette.goldSoft, letterSpacing: 0.8),
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          Text(
            'Oppure tocca o tieni premuto',
            style: TypographyTokens.label(size: 10).copyWith(
              color: palette.goldSoft.withValues(alpha: 0.85),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Il dono del giorno, in forma strutturata: tipo di dono, messaggio personale,
/// parola del giorno in risalto, condivisione e filo di continuita'.
class _DawnGiftCard extends StatelessWidget {
  const _DawnGiftCard({
    super.key,
    required this.gift,
    required this.palette,
    required this.streak,
    required this.onShare,
  });

  final DawnGift gift;
  final MaestroPalette palette;
  final int streak;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          gift.kind.label.toUpperCase(),
          style: TypographyTokens.label(size: 11).copyWith(
            color: palette.goldSoft,
            letterSpacing: 2.4,
          ),
        ),
        const SizedBox(height: SpacingTokens.sm),
        Text(
          gift.message,
          style: TypographyTokens.body(size: 16)
              .copyWith(color: ColorTokens.textPrimary, height: 1.5),
        ),
        const SizedBox(height: SpacingTokens.lg),
        // La parola del giorno, messa tipograficamente in risalto.
        Text(
          'PAROLA DEL GIORNO',
          style: TypographyTokens.label(size: 10).copyWith(
            color: palette.goldSoft.withValues(alpha: 0.7),
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(
          gift.word,
          style: TypographyTokens.display(size: 32).copyWith(
            color: palette.goldSoft,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: SpacingTokens.md),
        Row(
          children: [
            _ShareWordButton(palette: palette, onShare: onShare),
            if (streak >= 1) ...[
              const SizedBox(width: SpacingTokens.md),
              _StreakChip(palette: palette, days: streak),
            ],
          ],
        ),
      ],
    );
  }
}

/// Pulsante discreto per condividere la parola del giorno con la condivisione
/// nativa del sistema.
class _ShareWordButton extends StatelessWidget {
  const _ShareWordButton({required this.palette, required this.onShare});

  final MaestroPalette palette;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      key: const Key('dawn_share_word'),
      onPressed: onShare,
      style: TextButton.styleFrom(
        foregroundColor: palette.goldSoft,
        padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          side: BorderSide(color: palette.gold.withValues(alpha: 0.5)),
        ),
      ),
      icon: const Icon(Icons.ios_share_rounded, size: 16),
      label: Text(
        'Condividi la parola',
        style: TypographyTokens.label(size: 12)
            .copyWith(color: palette.goldSoft, letterSpacing: 0.5),
      ),
    );
  }
}

/// Indicatore discreto dei giorni consecutivi di rito compiuto.
class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.palette, required this.days});

  final MaestroPalette palette;
  final int days;

  @override
  Widget build(BuildContext context) {
    final label = days == 1 ? 'Primo giorno' : '$days giorni di fila';
    return Container(
      key: const Key('dawn_streak'),
      padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
        color: palette.deepest.withValues(alpha: 0.4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wb_twilight_rounded,
              size: 14, color: palette.goldSoft.withValues(alpha: 0.85)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TypographyTokens.label(size: 11).copyWith(
              color: palette.goldSoft.withValues(alpha: 0.85),
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Il livello di luce del sollevamento dell'alba, disegnato sopra la foto.
///
/// Tutto e' modulato dal progresso: a zero non disegna nulla e resta la sola
/// foto; salendo, il bagliore si diffonde dall'orizzonte, il riflesso sul mare
/// si allunga, il cielo si scalda, le costellazioni in alto si spengono sotto la
/// luce e il cerchio zodiacale in filigrana si accende e ruota di pochi gradi.
/// Il sole non e' un secondo disco: solo un alone allineato al sole della foto.
class _DawnLightPainter extends CustomPainter {
  _DawnLightPainter({
    required this.progress,
    required this.ambient,
    required this.palette,
    required this.reduceMotion,
  });

  final double progress;
  final double ambient;
  final MaestroPalette palette;
  final bool reduceMotion;

  @override
  void paint(Canvas canvas, Size size) {
    final p = progress.clamp(0.0, 1.0);
    if (p <= 0.001) return;

    final w = size.width;
    final h = size.height;
    // Allineati alla foto: sole sull'orizzonte al centro, ruota in basso.
    final horizonY = h * 0.5;
    final sunCenter = Offset(w * 0.5, horizonY);
    final wheelCenter = Offset(w * 0.5, h * 0.86);
    final wheelRadius = w * 0.42;

    // Il cielo si scalda: velo caldo che cresce, piu' denso verso l'orizzonte.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            palette.primary.withValues(alpha: 0.05 * p),
            palette.gold.withValues(alpha: 0.20 * p),
            palette.primary.withValues(alpha: 0.05 * p),
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Offset.zero & size),
    );

    // Le costellazioni in alto si spengono sotto una luce che sale dall'alba.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h * 0.42),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            palette.goldSoft.withValues(alpha: 0.30 * p),
            palette.deepest.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, h * 0.42)),
    );

    // Alone del sole allineato alla foto, che si diffonde dall'orizzonte.
    final sunR = w * (0.22 + 0.4 * p);
    canvas.drawCircle(
      sunCenter,
      sunR,
      Paint()
        ..shader = RadialGradient(
          colors: [
            palette.goldSoft.withValues(alpha: 0.55 * p),
            const Color(0x00000000),
          ],
        ).createShader(Rect.fromCircle(center: sunCenter, radius: sunR)),
    );

    // Il riflesso sul mare si allunga verso il basso, con un brillio d'ambiente.
    final shimmer = reduceMotion ? 0.0 : math.sin(2 * math.pi * ambient);
    final beamHalf = w * (0.04 + 0.09 * p) * (1 + 0.06 * shimmer);
    final beamRect = Rect.fromLTRB(
      sunCenter.dx - beamHalf,
      horizonY,
      sunCenter.dx + beamHalf,
      h,
    );
    canvas.drawRect(
      beamRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            palette.goldSoft.withValues(alpha: 0.5 * p),
            palette.goldSoft.withValues(alpha: 0.0),
          ],
        ).createShader(beamRect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );

    // Il cerchio zodiacale in filigrana si accende e ruota di pochi gradi.
    _paintWheel(canvas, wheelCenter, wheelRadius, p);
  }

  void _paintWheel(Canvas canvas, Offset center, double radius, double p) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    // Pochi gradi di rotazione col progresso.
    canvas.rotate(p * 8 * math.pi / 180);

    final alpha = 0.5 * p;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = palette.gold.withValues(alpha: alpha);

    // Due anelli concentrici.
    canvas.drawCircle(Offset.zero, radius, line);
    canvas.drawCircle(Offset.zero, radius * 0.72, line);

    // Dodici raggi con una piccola stella al vertice esterno.
    final dot = Paint()
      ..color = palette.goldSoft.withValues(alpha: 0.7 * p);
    for (var i = 0; i < 12; i++) {
      final a = 2 * math.pi * i / 12 - math.pi / 2;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(dir * radius * 0.72, dir * radius, line);
      canvas.drawCircle(dir * radius, 1.6, dot);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_DawnLightPainter old) =>
      old.progress != progress ||
      old.ambient != ambient ||
      old.palette != palette ||
      old.reduceMotion != reduceMotion;
}
