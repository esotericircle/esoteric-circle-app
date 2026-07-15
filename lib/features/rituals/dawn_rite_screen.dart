import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/identity/birth_identity.dart';
import '../../core/identity/profile_controller.dart';
import '../../core/maestro/maestro.dart';
import '../../core/rituals/daily_rituals.dart';
import '../../core/rituals/dawn_gift.dart';
import '../../core/rituals/ritual_streak.dart';
import '../../design_system/components/ritual_backdrop.dart';
import '../../design_system/components/zodiac_wheel.dart';
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
          // La ruota zodiacale come firma disegnata dal codice, in basso sul
          // fondale, la' dove prima stava la ruota dipinta nella foto. Si tinge
          // dell'oro dell'Alba e reagisce alla luce del gesto: si attenua mentre
          // l'utente solleva l'alba e il bagliore cresce, torna quando la scena
          // si calma. Sotto Riduci Movimento resta la sua versione statica, per
          // conto del componente stesso. Non ruba leggibilita' al dono: quando il
          // dono si rivela il sollevamento e' al massimo e la ruota e' gia'
          // svanita, e la bolla scura del velo le resta comunque sopra.
          Positioned.fill(
            child: IgnorePointer(
              child: LayoutBuilder(
                builder: (context, c) {
                  final side = c.maxWidth * 0.84;
                  return Stack(
                    children: [
                      Positioned(
                        left: (c.maxWidth - side) / 2,
                        top: c.maxHeight * 0.86 - side / 2,
                        width: side,
                        height: side,
                        child: ZodiacWheel(
                          color: palette.gold,
                          opacity: (0.6 * (1 - _progress)).clamp(0.0, 1.0),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
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
const Color _dayBubble = Color(0xF2FCF5E4); // superficie chiara calda della bolla
const Color _dayBubbleBorder = Color(0x22000000);
const Color _dayInset = Color(0x14000000); // superfici interne, un velo caldo

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

    // La bolla chiara adattata alla scena a giorno pieno: testo scuro sopra, per
    // la leggibilita' piena sulla luce.
    return Container(
      decoration: BoxDecoration(
        color: _dayBubble,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _dayBubbleBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
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

/// Il livello di luce del sollevamento dell'alba, disegnato sopra la foto.
///
/// Tutto e' modulato dal progresso: a zero non disegna nulla e resta la sola
/// foto; salendo, il bagliore si diffonde dall'orizzonte, il riflesso sul mare
/// si allunga, il cielo si scalda e le costellazioni in alto si spengono sotto
/// la luce. La ruota zodiacale, invece, non la disegna questo livello: e' il
/// componente [ZodiacWheel] montato sul fondale, che si attenua proprio mentre
/// questa luce cresce. Il sole non e' un secondo disco: solo un alone allineato
/// al sole della foto.
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

  // Misure della foto notturna, per allineare il sole disegnato alla linea del
  // mare reale con la stessa matematica del BoxFit.cover, a ogni dimensione.
  static const double _imgW = 704;
  static const double _imgH = 1520;
  static const double _horizonFrac = 0.637;

  double _horizonY(Size size) {
    final scale = math.max(size.width / _imgW, size.height / _imgH);
    final scaledH = _imgH * scale;
    final offsetY = (size.height - scaledH) / 2;
    return offsetY + _horizonFrac * _imgH * scale;
  }

  static const _daySky = Color(0xFFC3D8EE);
  static const _dawnWarm = Color(0xFFFFE3A6);
  static const _seaLit = Color(0xFF8BA0AB);

  @override
  void paint(Canvas canvas, Size size) {
    final p = progress.clamp(0.0, 1.0);
    if (p <= 0.001) return;

    final w = size.width;
    final h = size.height;
    final horizonY = _horizonY(size);
    final rect = Offset.zero & size;
    final rise = Curves.easeOutCubic.transform(p);

    // 1) La scena passa dalla notte al giorno: un velo di luce calda cresce su
    // tutto, piu' intenso verso l'orizzonte. Copre cielo e mare e assorbe la
    // luna e le costellazioni nel chiarore.
    final horizonStop = (horizonY / h).clamp(0.05, 0.95);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _daySky.withValues(alpha: 1.0 * p),
            _dawnWarm.withValues(alpha: 0.93 * p),
            _seaLit.withValues(alpha: 0.72 * p),
          ],
          stops: [0.0, horizonStop, 1.0],
        ).createShader(rect),
    );

    // 2) Bagliore dell'alba sull'orizzonte, un'ampia luce calda che si diffonde.
    final glowR = w * (0.5 + 0.5 * p);
    final glowC = Offset(w * 0.5, horizonY);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: Alignment(0, (horizonY / h) * 2 - 1),
          radius: 0.9,
          colors: [
            _dawnWarm.withValues(alpha: 0.55 * p),
            const Color(0x00000000),
          ],
        ).createShader(Rect.fromCircle(center: glowC, radius: glowR)),
    );

    // 3) Il sole, elemento disegnato: un ampio disco luminoso che emerge dal
    // mare. Sale di poco, restando sulla linea del mare, che ne nasconde la
    // parte sotto l'orizzonte, cosi' sembra sorgere dall'acqua.
    final sunR = w * 0.17;
    final sunCenter = Offset(w * 0.5, horizonY + sunR - sunR * 1.15 * rise);

    // Alone ampio attorno al sole, non tagliato: bagliore che invade il cielo.
    canvas.drawCircle(
      sunCenter,
      sunR * (2.4 + 0.8 * p),
      Paint()
        ..shader = RadialGradient(
          colors: [
            _dawnWarm.withValues(alpha: 0.6 * p),
            const Color(0x00000000),
          ],
        ).createShader(
            Rect.fromCircle(center: sunCenter, radius: sunR * (2.4 + 0.8 * p))),
    );

    // Sole e raggi solo sopra l'orizzonte: il mare copre il resto.
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, w, horizonY));

    // Raggi lenti che si aprono col sorgere.
    final rayPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..color = palette.goldSoft.withValues(alpha: 0.22 * p);
    for (var i = 0; i < 16; i++) {
      final a = 2 * math.pi * i / 16;
      final dir = Offset(math.cos(a), math.sin(a));
      rayPaint.strokeWidth = i.isEven ? 3.0 : 1.5;
      canvas.drawLine(sunCenter + dir * sunR * 1.15,
          sunCenter + dir * sunR * (1.7 + 0.6 * p), rayPaint);
    }

    // Il disco: cuore bianco caldo, bordo dorato.
    canvas.drawCircle(
      sunCenter,
      sunR,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFFDF3),
            palette.goldSoft,
            palette.gold,
          ],
          stops: const [0.0, 0.7, 1.0],
        ).createShader(Rect.fromCircle(center: sunCenter, radius: sunR)),
    );
    canvas.restore();

    // 4) Il riflesso dorato sul mare si accende e si allunga sotto il sole, con
    // un brillio d'ambiente fermo sotto Riduci Movimento.
    final shimmer = reduceMotion ? 0.0 : math.sin(2 * math.pi * ambient);
    final beamHalf = w * (0.05 + 0.10 * p) * (1 + 0.06 * shimmer);
    final beamBottom = horizonY + (h - horizonY) * (0.35 + 0.65 * p);
    final beamRect =
        Rect.fromLTRB(w * 0.5 - beamHalf, horizonY, w * 0.5 + beamHalf, beamBottom);
    canvas.drawRect(
      beamRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFFF3D6).withValues(alpha: 0.75 * p),
            palette.goldSoft.withValues(alpha: 0.0),
          ],
        ).createShader(beamRect)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );
  }

  @override
  bool shouldRepaint(_DawnLightPainter old) =>
      old.progress != progress ||
      old.ambient != ambient ||
      old.palette != palette ||
      old.reduceMotion != reduceMotion;
}
