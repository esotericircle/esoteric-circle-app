import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/identity/birth_identity.dart';
import '../../core/identity/profile_controller.dart';
import '../../core/maestro/maestro.dart';
import '../../core/rituals/daily_rituals.dart';
import '../../core/rituals/dawn_gift.dart';
import '../../core/rituals/ritual_streak.dart';
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

  // I tre livelli del motore del sorgere, decodificati come immagini vere per
  // comporli in un solo canvas con i blend giusti (il sole in additivo).
  ui.Image? _nightImg;
  ui.Image? _dayImg;
  ui.Image? _sunImg;

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
    _loadLayers();
  }

  Future<void> _loadLayers() async {
    try {
      final imgs = await Future.wait([
        _resolveAsset('assets/ritual_backgrounds/dawn_sky_night.png'),
        _resolveAsset('assets/ritual_backgrounds/dawn_sky_day.png'),
        _resolveAsset('assets/ritual_backgrounds/dawn_sun.png'),
      ]);
      if (!mounted) return;
      setState(() {
        _nightImg = imgs[0];
        _dayImg = imgs[1];
        _sunImg = imgs[2];
      });
    } catch (_) {
      // Se un asset non si decodifica, il motore resta senza livelli e non
      // disegna nulla: nessun crash.
    }
  }

  // Risolve un asset in una ui.Image passando dal framework, cosi' sfrutta la
  // cache immagini e resta decodificabile anche in un test dopo precacheImage.
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

  @override
  void dispose() {
    _lift.dispose();
    _ambient.dispose();
    _nightImg?.dispose();
    _dayImg?.dispose();
    _sunImg?.dispose();
    super.dispose();
  }

  bool get _reduceMotion => MediaQuery.of(context).disableAnimations;

  // Carta natale dell'utente dal profilo, se disponibile. Senza
  // ProfileController, per esempio montando lo screen da solo in un test, si
  // ripiega su null e il dono resta fondato ma senza ancora natale.
  BirthIdentity? _identity() {
    try {
      return context.read<ProfileController>().identity;
    } catch (_) {
      return null;
    }
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (_revealed) return;
    _lift.stop();
    setState(() {
      // Trascinare verso l'alto (delta negativo) solleva l'alba.
      _progress =
          (_progress - (d.primaryDelta ?? 0) / _dragSpan).clamp(0.0, 1.0);
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
      _gift = DawnGift.forChart(date, identity: _identity());
    });
    _recordStreak(date);
  }

  Future<void> _recordStreak(DateTime date) async {
    final n = await const RitualStreak(id: 'dawn').recordToday(date);
    if (!mounted) return;
    setState(() => _streak = n);
  }

  Future<void> _shareWord(DawnGift gift) async {
    final word = gift.word;
    if (word == null) return;
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: 'La mia parola del giorno dal Rito dell\'Alba: $word. '
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
        title:
            Text('Rito dell\'Alba', style: TypographyTokens.display(size: 20)),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Il motore del sorgere a livelli, composto in un solo canvas cosi' i
          // blend sono corretti: cielo notte-giorno in dissolvenza, sole in
          // additivo con la sua corona zodiacale, mare davanti che lo copre
          // sull'orizzonte, riflesso e luna che svanisce. La vecchia ruota in
          // basso non c'e' piu': la ruota ora e' la corona del sole.
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: Listenable.merge([_lift, _ambient]),
                builder: (context, _) => CustomPaint(
                  painter: _DawnScenePainter(
                    progress: _progress,
                    ambient: _reduceMotion ? 0 : _ambient.value,
                    reduceMotion: _reduceMotion,
                    night: _nightImg,
                    day: _dayImg,
                    sun: _sunImg,
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
                            Align(
                              // In alto sul cielo notturno, libero dal sole che
                              // invita a sorgere sull'orizzonte, in basso.
                              alignment: const Alignment(0, -0.4),
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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, 0,
                        SpacingTokens.lg, SpacingTokens.lg),
                    child: (_revealed && _gift != null)
                        ? _DawnGiftCard(
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

// Colori del dono nello stato illuminato. A gesto completato la scena e' giorno
// pieno: il dono usa testo scuro su una bolla chiara, per la leggibilita' piena
// sulla luce. E' il rovescio dell'invito notturno, chiaro sul buio.
const Color _dayInk = Color(0xFF2A2213); // testo forte
const Color _dayInkSoft = Color(0xFF6E5B33); // etichette e testo secondario
const Color _dayAccent = Color(0xFF7A5E1E); // oro scuro, accenti e parola
const Color _dayInset = Color(0x14000000); // superfici interne, un velo caldo
// La bolla e' un vetro smerigliato: semitrasparente e sfocata, lascia intravedere
// la scena sotto ma tiene il testo scuro leggibile sul chiaro.
const Color _dayGlass = Color(0xC7FBF4E2); // bianco caldo, alpha circa 0.78
const Color _dayGlassBorder = Color(0x4DFFFFFF);

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

/// Il dono del giorno, in forma strutturata e fondata. Porge tre livelli:
/// l'orientamento del giorno, la parola del giorno e la base apribile che
/// spiega da dove nasce. Finche' i contenuti verificati non arrivano, i testi
/// del cielo restano provvisori e marcati, mai inventati.
class _DawnGiftCard extends StatefulWidget {
  const _DawnGiftCard({
    super.key,
    required this.gift,
    required this.streak,
    required this.onShare,
  });

  final DawnGift gift;
  final int streak;
  final VoidCallback onShare;

  @override
  State<_DawnGiftCard> createState() => _DawnGiftCardState();
}

class _DawnGiftCardState extends State<_DawnGiftCard> {
  bool _baseOpen = false;

  @override
  Widget build(BuildContext context) {
    final gift = widget.gift;
    final word = gift.word;

    // La bolla di vetro smerigliato: lascia intravedere la scena sotto, cosi' il
    // sole resta grande sopra, e tiene il testo scuro leggibile sul chiaro.
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: BoxDecoration(
            color: _dayGlass,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _dayGlassBorder),
          ),
          padding: const EdgeInsets.all(SpacingTokens.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Livello uno: il tipo di dono e l'orientamento del giorno.
              Row(
                children: [
                  Flexible(
                    child: Text(
                      gift.kind.label.toUpperCase(),
                      style: TypographyTokens.label(size: 11).copyWith(
                        color: _dayAccent,
                        letterSpacing: 2.4,
                      ),
                    ),
                  ),
                  if (gift.provisional) ...[
                    const SizedBox(width: SpacingTokens.sm),
                    const _ProvisionalTag(),
                  ],
                ],
              ),
              const SizedBox(height: SpacingTokens.sm),
              Text(
                gift.orientation,
                style: TypographyTokens.body(size: 16)
                    .copyWith(color: _dayInk, height: 1.5),
              ),
              const SizedBox(height: SpacingTokens.lg),
              // Livello due: la parola del giorno, in risalto, o il suo segnaposto.
              Text(
                'PAROLA DEL GIORNO',
                style: TypographyTokens.label(size: 10).copyWith(
                  color: _dayInkSoft,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: SpacingTokens.xs),
              if (word != null)
                Text(
                  word,
                  style: TypographyTokens.display(size: 32).copyWith(
                    color: _dayAccent,
                    letterSpacing: 1.4,
                  ),
                )
              else
                Text(
                  'In arrivo',
                  style: TypographyTokens.display(size: 24).copyWith(
                    color: _dayInkSoft.withValues(alpha: 0.7),
                    letterSpacing: 1.2,
                  ),
                ),
              const SizedBox(height: SpacingTokens.md),
              // Livello tre: la base apribile, da dove nasce il dono.
              _BaseToggle(
                open: _baseOpen,
                onTap: () => setState(() => _baseOpen = !_baseOpen),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.topCenter,
                child: _baseOpen
                    ? _BasePanel(source: gift.source)
                    : const SizedBox(width: double.infinity),
              ),
              const SizedBox(height: SpacingTokens.md),
              Row(
                children: [
                  // La condivisione della parola torna quando la parola e' reale.
                  if (word != null) _ShareWordButton(onShare: widget.onShare),
                  if (widget.streak >= 1) ...[
                    if (word != null) const SizedBox(width: SpacingTokens.md),
                    _StreakChip(days: widget.streak),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Marcatore discreto che dichiara un contenuto provvisorio.
class _ProvisionalTag extends StatelessWidget {
  const _ProvisionalTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
        border: Border.all(color: _dayInkSoft.withValues(alpha: 0.5)),
      ),
      child: Text(
        'PROVVISORIO',
        style: TypographyTokens.label(size: 9).copyWith(
          color: _dayInkSoft,
          letterSpacing: 1.6,
        ),
      ),
    );
  }
}

/// La riga che apre e chiude la base del dono.
class _BaseToggle extends StatelessWidget {
  const _BaseToggle({required this.open, required this.onTap});

  final bool open;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: const Key('dawn_base_toggle'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline_rounded, size: 15, color: _dayAccent),
            const SizedBox(width: 6),
            Text(
              'Da dove nasce questo dono',
              style: TypographyTokens.label(size: 11).copyWith(
                color: _dayAccent,
                letterSpacing: 0.4,
              ),
            ),
            Icon(open ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                size: 18, color: _dayAccent),
          ],
        ),
      ),
    );
  }
}

/// Il pannello della base: ancora natale reale, transito e tradizione, con la
/// provvisorieta' dichiarata dove il contenuto verificato manca.
class _BasePanel extends StatelessWidget {
  const _BasePanel({required this.source});

  final GiftSource source;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('dawn_base_panel'),
      width: double.infinity,
      margin: const EdgeInsets.only(top: SpacingTokens.sm),
      padding: const EdgeInsets.all(SpacingTokens.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: _dayInset,
        border: Border.all(color: _dayInkSoft.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BaseRow(
            label: 'Ancora natale',
            value: source.natalDescription,
            provisional: false,
          ),
          const SizedBox(height: SpacingTokens.sm),
          _BaseRow(
            label: 'Transito attivo oggi',
            value: source.transit ??
                'In attesa dei contenuti astrologici verificati.',
            provisional: source.transit == null,
          ),
          const SizedBox(height: SpacingTokens.sm),
          _BaseRow(
            label: 'Nella tradizione',
            value: source.tradition ??
                'In attesa dei contenuti astrologici verificati.',
            provisional: source.tradition == null,
          ),
        ],
      ),
    );
  }
}

class _BaseRow extends StatelessWidget {
  const _BaseRow({
    required this.label,
    required this.value,
    required this.provisional,
  });

  final String label;
  final String value;
  final bool provisional;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                label.toUpperCase(),
                style: TypographyTokens.label(size: 9).copyWith(
                  color: _dayInkSoft,
                  letterSpacing: 1.6,
                ),
              ),
            ),
            if (provisional) ...[
              const SizedBox(width: SpacingTokens.sm),
              const _ProvisionalTag(),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TypographyTokens.body(size: 14).copyWith(
            color: provisional ? _dayInkSoft : _dayInk,
            height: 1.4,
            fontStyle: provisional ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ],
    );
  }
}

/// Pulsante discreto per condividere la parola del giorno con la condivisione
/// nativa del sistema.
class _ShareWordButton extends StatelessWidget {
  const _ShareWordButton({required this.onShare});

  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      key: const Key('dawn_share_word'),
      onPressed: onShare,
      style: TextButton.styleFrom(
        foregroundColor: _dayAccent,
        padding: const EdgeInsets.symmetric(
            horizontal: SpacingTokens.md, vertical: SpacingTokens.sm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SpacingTokens.radiusPill),
          side: BorderSide(color: _dayAccent.withValues(alpha: 0.5)),
        ),
      ),
      icon: const Icon(Icons.ios_share_rounded, size: 16),
      label: Text(
        'Condividi la parola',
        style: TypographyTokens.label(size: 12)
            .copyWith(color: _dayAccent, letterSpacing: 0.5),
      ),
    );
  }
}

/// Indicatore discreto dei giorni consecutivi di rito compiuto.
class _StreakChip extends StatelessWidget {
  const _StreakChip({required this.days});

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
        color: _dayInset,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wb_twilight_rounded, size: 14, color: _dayAccent),
          const SizedBox(width: 6),
          Text(
            label,
            style: TypographyTokens.label(size: 11).copyWith(
              color: _dayAccent,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Il motore del sorgere del Rito dell'Alba, a livelli, composto in un solo
/// canvas cosi' i blend restano corretti.
///
/// Dal fondo alla superficie: il cielo che passa in dissolvenza dalla scena
/// notturna a quella diurna, e con esso la luna svanisce; il sole in blend
/// additivo che emerge dall'orizzonte e sale fino al posto della luna con la
/// sua corona zodiacale; il mare davanti che ne copre la parte bassa e passa
/// anch'esso da notte a giorno; il riflesso dorato che si accende sul mare. A
/// progresso zero mostra solo mezzo disco sull'orizzonte, come invito.
class _DawnScenePainter extends CustomPainter {
  _DawnScenePainter({
    required this.progress,
    required this.ambient,
    required this.reduceMotion,
    required this.night,
    required this.day,
    required this.sun,
  });

  final double progress;
  final double ambient;
  final bool reduceMotion;
  final ui.Image? night;
  final ui.Image? day;
  final ui.Image? sun;

  // Notte e giorno hanno lo stesso formato e lo stesso orizzonte; la luna sta al
  // punto dove il sole si ferma.
  static const double _sceneW = 704;
  static const double _sceneH = 1520;
  static const double _horizonFrac = 0.4993;
  static const double _moonFx = 0.462;
  static const double _moonFy = 0.210;
  // Frazione della larghezza dell'immagine del sole occupata dal disco.
  static const double _sunDiscFrac = 0.171;

  @override
  void paint(Canvas canvas, Size size) {
    final night = this.night, day = this.day, sun = this.sun;
    if (night == null || day == null || sun == null) return;
    final p = progress.clamp(0.0, 1.0);
    final w = size.width, h = size.height;

    final scale = math.max(w / _sceneW, h / _sceneH);
    final dstW = _sceneW * scale, dstH = _sceneH * scale;
    final dstL = (w - dstW) / 2, dstT = (h - dstH) / 2;
    const sceneSrc = Rect.fromLTWH(0, 0, _sceneW, _sceneH);
    final sceneDst = Rect.fromLTWH(dstL, dstT, dstW, dstH);
    final horizonY = dstT + _horizonFrac * dstH;
    Offset scenePoint(double fx, double fy) =>
        Offset(dstL + fx * dstW, dstT + fy * dstH);

    // Il sole sale dall'orizzonte al posto della luna.
    final rise = reduceMotion ? p : Curves.easeOutCubic.transform(p);
    final moon = scenePoint(_moonFx, _moonFy);
    final sunCenter = Offset(moon.dx, horizonY + (moon.dy - horizonY) * rise);
    final discR = w * (0.135 + 0.055 * p);

    // --- Cielo: sopra l'orizzonte, notte in dissolvenza verso il giorno ---
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, w, horizonY));
    canvas.drawImageRect(night, sceneSrc, sceneDst, Paint());
    if (p > 0) {
      canvas.drawImageRect(day, sceneSrc, sceneDst,
          Paint()..color = Colors.white.withValues(alpha: p));
    }
    canvas.restore();

    // --- Sole: additivo, il nero sparisce e l'aura si fonde ---
    _paintSun(canvas, sun, sunCenter, discR);

    // --- Mare: sotto l'orizzonte, davanti al sole, notte verso giorno ---
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, horizonY, w, h - horizonY));
    canvas.drawImageRect(night, sceneSrc, sceneDst, Paint());
    if (p > 0) {
      canvas.drawImageRect(day, sceneSrc, sceneDst,
          Paint()..color = Colors.white.withValues(alpha: p));
    }
    _paintReflection(canvas, w, h, horizonY, sunCenter.dx, p);
    canvas.restore();
  }

  void _paintSun(Canvas canvas, ui.Image sun, Offset center, double discR) {
    // Abbassa il cielo sotto il disco con un velo scuro morbido, che sfuma al
    // bordo: cosi' l'additivo dorato ci si posa sopra e il disco resta caldo e
    // non satura a bianco sul cielo diurno luminoso. Il velo sta tutto sotto il
    // disco, non lascia aloni scuri fuori.
    canvas.drawCircle(
      center,
      discR * 1.02,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.black.withValues(alpha: 0.5),
            Colors.black.withValues(alpha: 0.5),
            Colors.black.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.7, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: discR * 1.02)),
    );

    final sw = sun.width.toDouble(), sh = sun.height.toDouble();
    // Scala l'immagine cosi' il disco ha raggio discR sullo schermo. Il margine
    // nero ampio lascia i raggi liberi di estendersi senza taglio.
    final s = discR / (_sunDiscFrac * sw);
    final dst = Rect.fromCenter(center: center, width: sw * s, height: sh * s);
    // Additivo a intensita' ridotta: il nero sparisce e l'aura si fonde da sola,
    // ma sul cielo gia' abbassato il disco resta dorato, mantenendo comunque il
    // bagliore del sorgere.
    canvas.drawImageRect(
      sun,
      Rect.fromLTWH(0, 0, sw, sh),
      dst,
      Paint()
        ..blendMode = BlendMode.plus
        ..color = Colors.white.withValues(alpha: 0.78),
    );
  }

  void _paintReflection(
      Canvas canvas, double w, double h, double horizonY, double cx, double p) {
    if (p <= 0.001) return;
    final shimmer = reduceMotion ? 0.0 : math.sin(2 * math.pi * ambient);
    final half = w * (0.03 + 0.06 * p) * (1 + 0.06 * shimmer);
    final bottom = horizonY + (h - horizonY) * (0.4 + 0.6 * p);
    final rect = Rect.fromLTRB(cx - half, horizonY, cx + half, bottom);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFFE2A6).withValues(alpha: 0.6 * p),
            const Color(0x00FFE2A6),
          ],
        ).createShader(rect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14)
        ..blendMode = BlendMode.plus,
    );
  }

  @override
  bool shouldRepaint(_DawnScenePainter old) =>
      old.progress != progress ||
      old.ambient != ambient ||
      old.reduceMotion != reduceMotion ||
      old.night != night ||
      old.day != day ||
      old.sun != sun;
}
