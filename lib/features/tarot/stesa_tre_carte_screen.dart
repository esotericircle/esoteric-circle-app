import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/maestro/maestro.dart';
import '../../core/tarot/tarot_card.dart';
import '../../core/tarot/tarot_spread.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'stesa_share_card.dart';
import 'medora_stage.dart';
import 'spread_signature.dart';
import 'tarot_card_art.dart';
import 'tarot_selectors.dart';

/// Il rapporto delle carte del mazzo, due a tre.
const double kTarotAspect = 2 / 3;

/// Stesa a Tre Carte, la headline dei tarocchi di Medora.
///
/// Un ventaglio di carte coperte col dorso di Medora: se ne pescano tre, che si
/// girano con un flip e prendono posto in Passato, Presente, Futuro. Ogni carta
/// esce dritta o rovesciata, e il testo mostrato e' sempre quello del verso in
/// cui e' uscita. Il pescaggio passa da un seme opzionale, cosi' test e anteprima
/// sono riproducibili.
class StesaTreCarteScreen extends StatefulWidget {
  const StesaTreCarteScreen({super.key, this.seed, this.revealAll = false});

  /// Seme del pescaggio. Se nullo, ogni apertura e' una stesa nuova.
  final int? seed;

  /// Per l'anteprima e i test: parte con le tre carte gia' rivelate.
  final bool revealAll;

  static Route<void> route({int? seed}) => MaterialPageRoute<void>(
        builder: (_) => MaestroScope(child: StesaTreCarteScreen(seed: seed)),
      );

  @override
  State<StesaTreCarteScreen> createState() => _StesaTreCarteScreenState();
}

class _StesaTreCarteScreenState extends State<StesaTreCarteScreen> {
  late final TarotSpread _spread = TarotSpread.draw(seed: widget.seed);

  /// Quante carte sono gia' state pescate, da 0 a 3.
  late int _drawn = widget.revealAll ? SpreadPosition.values.length : 0;

  /// Quali carte del ventaglio sono gia' state prese.
  final Set<int> _taken = {};

  final GlobalKey _cardKey = GlobalKey();
  bool _sharing = false;
  bool _renderCard = false;

  /// I selettori prima della stesa. Le voci non pronte restano Coming soon.
  TarotSetup _setup = const TarotSetup();

  /// L'ultima carta scoperta: e' quella su cui Medora posa lo sguardo.
  DrawnCard? get _active => _drawn == 0 ? null : _spread.cards[_drawn - 1];

  bool get _complete => _drawn >= SpreadPosition.values.length;

  void _pick(int fanIndex) {
    if (_complete || _taken.contains(fanIndex)) return;
    setState(() {
      _taken.add(fanIndex);
      _drawn++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // La stesa e' di Medora: blu e oro suoi, sempre.
    final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: palette.goldSoft),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Indietro',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text('Stesa a Tre Carte',
            style: TypographyTokens.display(size: 20)),
      ),
      body: CosmosBackground(
        showZodiac: false,
        child: SafeArea(
          child: Stack(
            children: [
              _content(palette),
              if (_renderCard)
                Positioned(
                  left: -3000,
                  top: 0,
                  child: RepaintBoundary(
                    key: _cardKey,
                    child: StesaShareCard(spread: _spread, palette: palette),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(MaestroPalette palette) {
    return ListView(
      key: const Key('stesa_list'),
      padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, kToolbarHeight,
          SpacingTokens.lg, SpacingTokens.lg),
      children: [
        // Medora presiede la stesa, con le carte davanti a lei.
        MedoraStage(palette: palette, active: _active),
        const SizedBox(height: SpacingTokens.md),
        // I selettori prima della stesa.
        if (!_complete) ...[
          TarotSetupPanel(
            setup: _setup,
            palette: palette,
            onChanged: (s) => setState(() => _setup = s),
            onLocked: _showComingSoon,
          ),
          const SizedBox(height: SpacingTokens.md),
        ],
        // Colpo d'occhio: il ventaglio coperto, finche' restano carte da pescare.
        if (!_complete) ...[
          Text(
            _drawn == 0
                ? 'Scegli tre carte dal ventaglio'
                : 'Scegli ancora ${SpreadPosition.values.length - _drawn}',
            key: const Key('stesa_prompt'),
            textAlign: TextAlign.center,
            style: TypographyTokens.label(size: 12).copyWith(
                color: ColorTokens.textSecondary, letterSpacing: 1.2),
          ),
          const SizedBox(height: SpacingTokens.md),
          _Fan(
            palette: palette,
            taken: _taken,
            onPick: _pick,
          ),
          const SizedBox(height: SpacingTokens.lg),
        ],
        // La sintesi memorabile, sopra le tre carte.
        if (_complete) ...[
          Text(_spread.synthesis,
              key: const Key('stesa_synthesis'),
              textAlign: TextAlign.center,
              style: TypographyTokens.display(size: 22)
                  .copyWith(color: palette.goldSoft, height: 1.25)),
          const SizedBox(height: SpacingTokens.md),
        ],
        // I tre slot, che si girano man mano.
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < SpreadPosition.values.length; i++) ...[
              Expanded(
                child: _Slot(
                  position: SpreadPosition.values[i],
                  drawn: i < _drawn ? _spread.cards[i] : null,
                  palette: palette,
                ),
              ),
              if (i < SpreadPosition.values.length - 1)
                const SizedBox(width: SpacingTokens.xs),
            ],
          ],
        ),
        if (_complete) ...[
          const SizedBox(height: SpacingTokens.lg),
          // La lettura che unisce le tre posizioni.
          Container(
            padding: const EdgeInsets.all(SpacingTokens.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  palette.surfaceElevated.withValues(alpha: 0.95),
                  Color.lerp(palette.surface, palette.deepest, 0.35)!
                      .withValues(alpha: 0.92),
                ],
              ),
              border: Border.all(color: palette.gold.withValues(alpha: 0.32)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_spread.reading,
                    key: const Key('stesa_reading'),
                    style: TypographyTokens.body(size: 17).copyWith(
                        color: ColorTokens.textPrimary, height: 1.55)),
                const SizedBox(height: SpacingTokens.md),
                Text(TarotSpread.closing,
                    key: const Key('stesa_closing'),
                    style: TypographyTokens.body(size: 15).copyWith(
                        color: palette.goldSoft,
                        height: 1.4,
                        fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          const SizedBox(height: SpacingTokens.lg),
          Center(
            child: FilledButton.icon(
              key: const Key('stesa_share'),
              onPressed: _sharing ? null : _onShare,
              style: FilledButton.styleFrom(
                backgroundColor: palette.gold,
                foregroundColor: palette.deepest,
                padding: const EdgeInsets.symmetric(
                    horizontal: SpacingTokens.xl, vertical: SpacingTokens.sm),
              ),
              icon: _sharing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.ios_share_rounded, size: 18),
              label: Text(_sharing ? 'Preparo la card' : 'Condividi',
                  style: TypographyTokens.label(size: 13)
                      .copyWith(letterSpacing: 0.6)),
            ),
          ),
        ],
        if (_complete) ...[
          const SizedBox(height: SpacingTokens.md),
          // La firma della stesa, in piccolo a fine schermata.
          Center(
            child: SpreadSignatureMark(
              key: const Key('stesa_signature'),
              signature: SpreadSignature.of(_spread),
              palette: palette,
              size: 54,
              showCode: true,
            ),
          ),
        ],
        const SizedBox(height: SpacingTokens.sm),
        // Disclaimer, una sola volta.
        Text(TarotSpread.disclaimer,
            key: const Key('stesa_disclaimer'),
            textAlign: TextAlign.center,
            style: TypographyTokens.body(size: 12).copyWith(
                color: ColorTokens.textSecondary,
                height: 1.4,
                fontStyle: FontStyle.italic)),
      ],
    );
  }

  void _showComingSoon(String voce) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$voce arriva presto nel Cerchio.')),
    );
  }

  Future<void> _onShare() async {
    setState(() {
      _sharing = true;
      _renderCard = true;
    });
    try {
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 80));
      await shareStesaCard(
        boundaryKey: _cardKey,
        text: 'La mia stesa a tre carte. Esoteric Circle.',
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Non riesco a preparare la card ora.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _sharing = false;
          _renderCard = false;
        });
      }
    }
  }
}

/// Il ventaglio di carte coperte, col dorso di Medora.
class _Fan extends StatelessWidget {
  const _Fan(
      {required this.palette, required this.taken, required this.onPick});

  final MaestroPalette palette;
  final Set<int> taken;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const n = TarotSpread.fanSize;
          final w = constraints.maxWidth;
          final cardW = math.min(74.0, w / (n * 0.62));
          final step = (w - cardW) / (n - 1);
          return Stack(
            clipBehavior: Clip.none,
            children: [
              for (var i = 0; i < n; i++)
                Positioned(
                  left: step * i,
                  top: (i - (n - 1) / 2).abs() * 4,
                  child: Transform.rotate(
                    // Ventaglio: le carte ai lati inclinano verso l'esterno.
                    angle: (i - (n - 1) / 2) * 0.055,
                    child: _FanCard(
                      key: Key('stesa_fan_$i'),
                      width: cardW,
                      palette: palette,
                      taken: taken.contains(i),
                      onTap: () => onPick(i),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _FanCard extends StatelessWidget {
  const _FanCard({
    super.key,
    required this.width,
    required this.palette,
    required this.taken,
    required this.onTap,
  });

  final double width;
  final MaestroPalette palette;
  final bool taken;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: taken ? null : onTap,
      child: AnimatedOpacity(
        opacity: taken ? 0.25 : 1.0,
        duration: const Duration(milliseconds: 250),
        child: SizedBox(
          width: width,
          height: width / kTarotAspect,
          child: _CardBack(palette: palette),
        ),
      ),
    );
  }
}

/// Il dorso di Medora. Se l'arte manca, un dorso dipinto, mai un vuoto.
class _CardBack extends StatelessWidget {
  const _CardBack({required this.palette});

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: palette.gold.withValues(alpha: 0.55)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Image.asset(
          TarotDeck.dorsoFull,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => CustomPaint(
            painter: _PaintedBackPainter(palette: palette),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

/// Uno dei tre slot della stesa: vuoto, oppure la carta che si gira.
class _Slot extends StatelessWidget {
  const _Slot(
      {required this.position, required this.drawn, required this.palette});

  final SpreadPosition position;
  final DrawnCard? drawn;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: kTarotAspect,
          child: drawn == null
              ? _EmptySlot(palette: palette)
              : _FlipCard(
                  key: ValueKey('${position.name}_${drawn!.card.stem}'),
                  drawn: drawn!,
                  palette: palette),
        ),
        const SizedBox(height: SpacingTokens.xs),
        Text(position.label.toUpperCase(),
            textAlign: TextAlign.center,
            style: TypographyTokens.label(size: 9).copyWith(
                color: palette.goldSoft, letterSpacing: 1.2)),
        if (drawn != null) ...[
          // Il nome in chiaro, grande e leggibile: nel cartiglio resta piccolo
          // e decorativo.
          // Il minimo tipografico non scende sotto una certa misura: qui si
          // rimpicciolisce la riga intera, cosi' il nome resta su due righe e
          // nessuna parola va a capo da sola.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(splitNomeCartiglio(drawn!.card.name).join('\n'),
                key: Key('stesa_name_${position.name}'),
                textAlign: TextAlign.center,
                style: TypographyTokens.display(size: 15)
                    .copyWith(color: ColorTokens.textPrimary, height: 1.15)),
          ),
          if (drawn!.reversed)
            Text('rovesciato',
                key: Key('stesa_reversed_${position.name}'),
                textAlign: TextAlign.center,
                style: TypographyTokens.label(size: 9).copyWith(
                    color: palette.goldSoft, letterSpacing: 0.6)),
          const SizedBox(height: 2),
          Text(drawn!.meaning,
              key: Key('stesa_meaning_${position.name}'),
              textAlign: TextAlign.center,
              style: TypographyTokens.body(size: 12).copyWith(
                  color: ColorTokens.textSecondary, height: 1.35)),
        ],
      ],
    );
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot({required this.palette});

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color: palette.gold.withValues(alpha: 0.28),
            style: BorderStyle.solid),
        color: palette.deepest.withValues(alpha: 0.35),
      ),
      child: Center(
        child: Icon(Icons.auto_awesome,
            size: 18, color: palette.gold.withValues(alpha: 0.35)),
      ),
    );
  }
}

/// La carta che si gira: dorso, mezzo giro, faccia. La rovesciata si mostra
/// ruotata di mezzo giro.
class _FlipCard extends StatefulWidget {
  const _FlipCard(
      {super.key, required this.drawn, required this.palette});

  final DrawnCard drawn;
  final MaestroPalette palette;

  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.of(context).disableAnimations) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = Curves.easeInOut.transform(_controller.value);
        final angle = (1 - t) * math.pi;
        final showBack = angle > math.pi / 2;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateY(angle),
          // A meta' giro il contenuto e' specchiato: va contro-ruotato il DORSO,
          // che si vede quando l'angolo e' oltre il quarto di giro. La faccia,
          // che si vede ad angolo zero, non va toccata, altrimenti resterebbe
          // specchiata a riposo e i cartigli si leggerebbero al contrario.
          child: showBack
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(math.pi),
                  child: _CardBack(palette: widget.palette),
                )
              : _CardFace(drawn: widget.drawn, palette: widget.palette),
        );
      },
    );
  }
}

/// La faccia della carta, con i cartigli riempiti a runtime.
class _CardFace extends StatelessWidget {
  const _CardFace({required this.drawn, required this.palette});

  final DrawnCard drawn;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return TarotCardArt(
      card: drawn.card,
      palette: palette,
      reversed: drawn.reversed,
    );
  }
}


/// Dorso dipinto di ripiego: un cielo con la stella di Medora.
class _PaintedBackPainter extends CustomPainter {
  _PaintedBackPainter({required this.palette});

  final MaestroPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [palette.surfaceElevated, palette.deepest],
        ).createShader(Offset.zero & size),
    );
    final c = size.center(Offset.zero);
    final r = size.shortestSide * 0.26;
    final gold = Paint()..color = palette.gold.withValues(alpha: 0.75);
    for (var k = 0; k < 8; k++) {
      final a = k * math.pi / 4;
      canvas.drawCircle(
          c + Offset(math.cos(a), math.sin(a)) * r, size.shortestSide * 0.03, gold);
    }
    canvas.drawCircle(c, size.shortestSide * 0.07, gold);
  }

  @override
  bool shouldRepaint(_PaintedBackPainter old) => old.palette != palette;
}
