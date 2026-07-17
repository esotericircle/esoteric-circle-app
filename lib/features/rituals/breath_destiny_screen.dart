import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/identity/birth_identity.dart';
import '../../core/identity/profile_controller.dart';
import '../../core/maestro/maestro.dart';
import '../../core/rituals/dawn_gift.dart';
import '../../core/rituals/ritual_streak.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'ritual_gift_card.dart';

/// Soffio del Destino, dominio Aura.
///
/// Stesso impianto degli altri riti, fondale piu' dono, con un motore proprio a
/// livelli composti in un solo canvas: il prato del mattino con l'alone verde di
/// Aura, il soffione al centro coi pappi luminosi in additivo, e i semi che, al
/// soffio, si staccano e volano via come scintille disegnate dal codice, a
/// comporre il visivo del dono. Il gesto e' il microfono, col ripiego di
/// spazzare col dito o tenere premuto. Sotto Riduci Movimento i semi volano via
/// subito. Il dono e' quello di Aura, fondato ma provvisorio, mai inventato.
class BreathDestinyScreen extends StatefulWidget {
  const BreathDestinyScreen({super.key, this.now});

  final DateTime? now;

  static Route<void> route({DateTime? now}) => MaterialPageRoute<void>(
        builder: (_) => MaestroScope(child: BreathDestinyScreen(now: now)),
      );

  @override
  State<BreathDestinyScreen> createState() => _BreathDestinyScreenState();
}

class _BreathDestinyScreenState extends State<BreathDestinyScreen>
    with TickerProviderStateMixin {
  // Dispersione dei semi, da 0 (testa piena) a 1 (dono rivelato).
  double _progress = 0;
  bool _revealed = false;
  DawnGift? _gift;
  int _streak = 0;

  late final AnimationController _disperse;
  Animation<double>? _disperseAnim;
  late final AnimationController _ambient; // brezza e brillio

  ui.Image? _meadowImg;
  ui.Image? _dandelionImg;

  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Uint8List>? _micStream;
  StreamSubscription<Amplitude>? _micAmplitude;

  // Distanza di spazzata sul soffione che disperde del tutto i semi.
  static const double _sweepSpan = 240;
  static const double _completeThreshold = 0.5;

  @override
  void initState() {
    super.initState();
    _disperse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..addListener(() {
        final anim = _disperseAnim;
        if (anim != null) setState(() => _progress = anim.value);
      });
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _loadLayers();
    _startMic();
  }

  Future<void> _loadLayers() async {
    try {
      final imgs = await Future.wait([
        _resolveAsset('assets/ritual_backgrounds/breath_meadow.png'),
        _resolveAsset('assets/ritual_backgrounds/breath_dandelion.png'),
      ]);
      if (!mounted) return;
      setState(() {
        _meadowImg = imgs[0];
        _dandelionImg = imgs[1];
      });
    } catch (_) {
      // Senza livelli il motore non disegna la scena, ma il rito resta
      // compibile col ripiego e il dono appare comunque.
    }
  }

  Future<ui.Image> _resolveAsset(String asset) {
    final completer = Completer<ui.Image>();
    final stream = AssetImage(asset).resolve(const ImageConfiguration());
    late final ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) {
        if (!completer.isCompleted) completer.complete(info.image);
        stream.removeListener(listener);
      },
      onError: (error, stack) {
        if (!completer.isCompleted) completer.completeError(error);
        stream.removeListener(listener);
      },
    );
    stream.addListener(listener);
    return completer.future;
  }

  // Chiede il permesso del microfono e ascolta il livello audio: un soffio e' un
  // picco d'ampiezza. Se il permesso e' negato o il microfono non c'e', resta il
  // ripiego tattile, senza mai sollevare un errore.
  Future<void> _startMic() async {
    try {
      if (!await _recorder.hasPermission()) return;
      final stream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          numChannels: 1,
          sampleRate: 16000,
        ),
      );
      _micStream = stream.listen((_) {});
      _micAmplitude = _recorder
          .onAmplitudeChanged(const Duration(milliseconds: 160))
          .listen((amp) {
        // Un soffio deciso supera la soglia: i semi si liberano.
        if (!_revealed && amp.current > -18) _complete();
      });
    } catch (_) {
      // Microfono non disponibile o permesso negato: vale il ripiego.
    }
  }

  Future<void> _stopMic() async {
    await _micAmplitude?.cancel();
    await _micStream?.cancel();
    try {
      if (await _recorder.isRecording()) await _recorder.stop();
    } catch (_) {}
    await _recorder.dispose();
  }

  @override
  void dispose() {
    _stopMic();
    _disperse.dispose();
    _ambient.dispose();
    _meadowImg?.dispose();
    _dandelionImg?.dispose();
    super.dispose();
  }

  bool get _reduceMotion => MediaQuery.of(context).disableAnimations;

  BirthIdentity? _identity() {
    try {
      return context.read<ProfileController>().identity;
    } catch (_) {
      return null;
    }
  }

  // Ripiego a spazzata: il dito che scorre sul soffione disperde i semi.
  void _onPanUpdate(DragUpdateDetails d) {
    if (_revealed) return;
    _disperse.stop();
    setState(() {
      _progress = (_progress + d.delta.distance / _sweepSpan).clamp(0.0, 1.0);
    });
  }

  void _onPanEnd(DragEndDetails _) {
    if (_revealed) return;
    if (_progress >= _completeThreshold) {
      _complete();
    } else {
      _animateTo(0);
    }
  }

  // Ripiego a tocco prolungato.
  void _onLongPress() {
    if (_revealed) return;
    _complete();
  }

  void _complete() {
    if (_reduceMotion) {
      setState(() => _progress = 1);
      _reveal();
      return;
    }
    _animateTo(1, onDone: _reveal);
  }

  void _animateTo(double target, {VoidCallback? onDone}) {
    _disperseAnim = Tween<double>(begin: _progress, end: target).animate(
      CurvedAnimation(parent: _disperse, curve: Curves.easeOutCubic),
    );
    _disperse.forward(from: 0).then((_) {
      if (mounted) onDone?.call();
    });
  }

  void _reveal() {
    if (_revealed) return;
    final date = widget.now ?? DateTime.now();
    setState(() {
      _revealed = true;
      _gift = DawnGift.forMaestro(date, Maestro.aura, identity: _identity());
    });
    _stopMic();
    _recordStreak(date);
  }

  Future<void> _recordStreak(DateTime date) async {
    final n = await const RitualStreak(id: 'breath').recordToday(date);
    if (!mounted) return;
    setState(() => _streak = n);
  }

  Future<void> _shareWord(DawnGift gift) async {
    final word = gift.word;
    if (word == null) return;
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: 'La mia parola del giorno dal Soffio del Destino: $word. '
              '${gift.orientation} Con Esoteric Circle.',
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
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.aura));

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
        title:
            Text('Soffio del Destino', style: TypographyTokens.display(size: 20)),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: Listenable.merge([_disperse, _ambient]),
                builder: (context, _) => CustomPaint(
                  painter: _BreathScenePainter(
                    progress: _progress,
                    ambient: _reduceMotion ? 0 : _ambient.value,
                    reduceMotion: _reduceMotion,
                    palette: palette,
                    meadow: _meadowImg,
                    dandelion: _dandelionImg,
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Column(
              children: [
                Expanded(
                  flex: 5,
                  child: Semantics(
                    button: true,
                    label: 'Libera il tuo destino. Soffia, oppure spazza col '
                        'dito o tieni premuto.',
                    onTap: _onLongPress,
                    child: GestureDetector(
                      key: const Key('ritual_gesture'),
                      behavior: HitTestBehavior.opaque,
                      onPanUpdate: _onPanUpdate,
                      onPanEnd: _onPanEnd,
                      onLongPress: _onLongPress,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (!_revealed)
                            Align(
                              alignment: const Alignment(0, -0.55),
                              child: _BreathPrompt(palette: palette),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, 0,
                        SpacingTokens.lg, SpacingTokens.lg),
                    child: (_revealed && _gift != null)
                        ? RitualGiftCard(
                            key: const Key('ritual_content'),
                            gift: _gift!,
                            streak: _streak,
                            onShare: () => _shareWord(_gift!),
                          )
                        : const SizedBox.shrink(),
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

/// L'invito al soffio e il suo ripiego, chiari sul prato.
class _BreathPrompt extends StatelessWidget {
  const _BreathPrompt({required this.palette});

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.lg, vertical: SpacingTokens.md),
      decoration: BoxDecoration(
        gradient: RadialGradient(
          radius: 0.95,
          colors: [
            Colors.black.withValues(alpha: 0.28),
            Colors.black.withValues(alpha: 0.0),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.air_rounded,
              color: palette.goldSoft.withValues(alpha: 0.9), size: 26),
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
              'Soffia per liberare il tuo destino',
              style: TypographyTokens.label(size: 12)
                  .copyWith(color: palette.goldSoft, letterSpacing: 0.8),
            ),
          ),
          const SizedBox(height: SpacingTokens.sm),
          Text(
            'Oppure spazza col dito o tieni premuto',
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

/// Il motore del Soffio a livelli, composto in un solo canvas.
class _BreathScenePainter extends CustomPainter {
  _BreathScenePainter({
    required this.progress,
    required this.ambient,
    required this.reduceMotion,
    required this.palette,
    required this.meadow,
    required this.dandelion,
  });

  final double progress;
  final double ambient;
  final bool reduceMotion;
  final MaestroPalette palette;
  final ui.Image? meadow;
  final ui.Image? dandelion;

  // Testa del soffione nell'immagine (centro e raggio come frazioni).
  static const double _headFx = 0.501;
  static const double _headFy = 0.440;
  static const double _headRFrac = 0.244; // del lato dell'immagine

  @override
  void paint(Canvas canvas, Size size) {
    final meadow = this.meadow, dandelion = this.dandelion;
    if (meadow == null || dandelion == null) return;
    final p = progress.clamp(0.0, 1.0);
    final w = size.width, h = size.height;
    final rect = Offset.zero & size;

    // --- Prato, cover ---
    _drawCover(canvas, meadow, size, Paint());

    // --- Alone verde di Aura del dominio, dal basso ---
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(0, 0.35),
          radius: 0.9,
          colors: [
            palette.glow.withValues(alpha: 0.30),
            palette.glow.withValues(alpha: 0.0),
          ],
        ).createShader(rect),
    );

    // Geometria del soffione montato sul prato.
    final dw = dandelion.width.toDouble(), dh = dandelion.height.toDouble();
    final dstH = h * 0.62;
    final dstW = dstH * dw / dh;
    final headCenter = Offset(w * 0.5, h * 0.52);
    final dstTop = headCenter.dy - _headFy * dstH;
    final dstLeft = w * 0.5 - _headFx * dstW;
    final headR = _headRFrac * dstW;
    final giftCenter = Offset(w * 0.5, h * 0.26);

    // --- Visivo del dono, provvisorio: una forma energetica che si accende ---
    // man mano che le scintille dei semi salgono a comporla. La forma vera
    // verra' dal cantiere.
    _paintGiftForm(canvas, giftCenter, w, p);

    // --- Alone morbido d'aria attorno al soffione, appena un respiro ---
    final auraR = headR * 1.9;
    canvas.drawCircle(
      headCenter,
      auraR,
      Paint()
        ..shader = RadialGradient(
          colors: [
            palette.goldSoft.withValues(alpha: 0.16),
            palette.glow.withValues(alpha: 0.06),
            const Color(0x00000000),
          ],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(Rect.fromCircle(center: headCenter, radius: auraR)),
    );

    // --- Soffione in composizione normale: l'alpha cotto dal fondo nero tiene
    // il dettaglio reale, i pappi coi bordi morbidi e lo stelo piantato. Niente
    // additivo, niente bruciatura a bianco. In due parti: lo stelo col
    // ricettacolo resta sempre, la testa si svuota progressivamente col soffio.
    const headBottomFy = 0.63, stemTopFy = 0.60;
    // Lo stelo col ricettacolo, sempre piantato nel prato.
    canvas.drawImageRect(
      dandelion,
      Rect.fromLTWH(0, stemTopFy * dh, dw, dh * (1 - stemTopFy)),
      Rect.fromLTWH(
          dstLeft, dstTop + stemTopFy * dstH, dstW, dstH * (1 - stemTopFy)),
      Paint(),
    );
    // La testa, che si dirada fino allo spoglio col progredire del soffio.
    final headOpacity = (1 - p).clamp(0.0, 1.0);
    if (headOpacity > 0.01) {
      canvas.drawImageRect(
        dandelion,
        Rect.fromLTWH(0, 0, dw, dh * headBottomFy),
        Rect.fromLTWH(dstLeft, dstTop, dstW, dstH * headBottomFy),
        Paint()..color = Colors.white.withValues(alpha: headOpacity),
      );
    }

    // --- Semi che volano via verso l'alto come scintille, con deriva di vento --
    _paintSeeds(canvas, headCenter, headR, giftCenter, p);
  }

  void _drawCover(Canvas canvas, ui.Image img, Size size, Paint paint) {
    final iw = img.width.toDouble(), ih = img.height.toDouble();
    final scale = math.max(size.width / iw, size.height / ih);
    final dw = iw * scale, dh = ih * scale;
    final dst = Rect.fromLTWH(
        (size.width - dw) / 2, (size.height - dh) / 2, dw, dh);
    canvas.drawImageRect(img, Rect.fromLTWH(0, 0, iw, ih), dst, paint);
  }

  // Il visivo del dono, provvisorio ma costruito: un soffione di luce, non una
  // palla sfocata. Cuore definito, raggi che terminano in nodi luminosi, due
  // anelli fini e un alone verde-oro. Si accende col salire delle scintille. La
  // forma definitiva verra' dal cantiere.
  void _paintGiftForm(Canvas canvas, Offset center, double w, double p) {
    if (p <= 0.02) return;
    final breathe = reduceMotion ? 0.0 : math.sin(2 * math.pi * ambient);
    final r = w * (0.13 + 0.10 * p) * (1 + 0.025 * breathe);

    // Alone verde-oro d'aria, morbido, dietro alla forma.
    canvas.drawCircle(
      center,
      r * 1.7,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = RadialGradient(
          colors: [
            palette.glow.withValues(alpha: 0.26 * p),
            const Color(0x00000000),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: r * 1.7)),
    );

    // Due anelli fini che danno struttura.
    Paint ring(double a, double sw) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw
      ..color = palette.gold.withValues(alpha: a * p);
    canvas.drawCircle(center, r, ring(0.5, 1.2));
    canvas.drawCircle(center, r * 0.5, ring(0.4, 1.0));

    // Raggi che terminano in nodi luminosi, come un soffione di luce.
    const n = 24;
    final ray = Paint()
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round
      ..color = palette.gold.withValues(alpha: 0.42 * p);
    for (var i = 0; i < n; i++) {
      final a = 2 * math.pi * i / n - math.pi / 2;
      final dir = Offset(math.cos(a), math.sin(a));
      final outer = center + dir * r * 0.92;
      canvas.drawLine(center + dir * r * 0.5, outer, ray);
      // Bagliore additivo e nodo definito al vertice.
      canvas.drawCircle(
        outer,
        3.4,
        Paint()
          ..blendMode = BlendMode.plus
          ..color = palette.goldSoft.withValues(alpha: 0.22 * p),
      );
      canvas.drawCircle(outer, 1.7,
          Paint()..color = palette.goldSoft.withValues(alpha: 0.85 * p));
    }

    // Cuore definito e luminoso.
    canvas.drawCircle(
      center,
      r * 0.4,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFF6DC).withValues(alpha: 0.85 * p),
            const Color(0x00FFF6DC),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: r * 0.4)),
    );
    canvas.drawCircle(center, r * 0.09,
        Paint()..color = const Color(0xFFFFF9E8).withValues(alpha: 0.95 * p));
  }

  void _paintSeeds(Canvas canvas, Offset head, double headR, Offset gift,
      double p) {
    if (p <= 0.001) return;
    final rng = math.Random(31);
    const n = 90;
    final wind = reduceMotion ? 0.0 : math.sin(2 * math.pi * ambient);
    final paint = Paint()..blendMode = BlendMode.plus;
    for (var i = 0; i < n; i++) {
      final threshold = (i / n) * 0.85;
      if (p <= threshold) continue;
      final f = ((p - threshold) / (1 - threshold)).clamp(0.0, 1.0);
      // Punto di partenza sulla testa, arrivo verso la forma del dono.
      final a0 = rng.nextDouble() * 2 * math.pi;
      final r0 = math.sqrt(rng.nextDouble()) * headR;
      final start = head + Offset(math.cos(a0), math.sin(a0)) * r0;
      final endJitter = Offset(
          (rng.nextDouble() - 0.5) * headR * 1.6,
          (rng.nextDouble() - 0.5) * headR * 0.8);
      final end = gift + endJitter;
      final flightCurve = Curves.easeOut.transform(f);
      final windX = wind * headR * 0.5 * (rng.nextDouble() + 0.3) * f;
      final pos = Offset.lerp(start, end, flightCurve)! + Offset(windX, 0);
      // Scintilla: piu' viva a meta' volo, si spegne arrivando.
      final glow = (math.sin(f * math.pi)).clamp(0.0, 1.0);
      final radius = 1.0 + rng.nextDouble() * 1.6;
      canvas.drawCircle(
        pos,
        radius * 2.4,
        paint
          ..color = palette.goldSoft.withValues(alpha: 0.10 * glow)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      paint.maskFilter = null;
      canvas.drawCircle(
        pos,
        radius,
        paint..color = const Color(0xFFFFF6DC).withValues(alpha: 0.8 * glow),
      );
    }
  }

  @override
  bool shouldRepaint(_BreathScenePainter old) =>
      old.progress != progress ||
      old.ambient != ambient ||
      old.reduceMotion != reduceMotion ||
      old.palette != palette ||
      old.meadow != meadow ||
      old.dandelion != dandelion;
}
