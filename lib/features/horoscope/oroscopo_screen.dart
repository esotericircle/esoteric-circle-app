import 'package:flutter/material.dart';

import '../../core/astro/zodiac.dart';
import '../../core/horoscope/horoscope.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/components/depth_card.dart';
import '../../design_system/components/zodiac_glyph.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import 'horoscope_visuals.dart';
import 'oroscopo_colors.dart';
import 'oroscopo_share_card.dart';

/// Oroscopo a quattro schede, la headline di Medora.
///
/// Quattro schede per segno (Generale, Amore, Carriera, Fortuna), ognuna con la
/// sua forma a tema viva, deterministiche dal giorno: stesso segno stesso giorno,
/// stesso responso. Il giorno si legge una sola volta qui e si passa come intero
/// ai calcoli, cosi' l'hash resta puro. Contenuto su dispositivo, senza backend.
class OroscopoScreen extends StatefulWidget {
  const OroscopoScreen({super.key, required this.userSign, this.now});

  final Zodiac userSign;
  final DateTime? now;

  static Route<void> route({required Zodiac userSign, DateTime? now}) {
    return MaterialPageRoute<void>(
      builder: (_) =>
          MaestroScope(child: OroscopoScreen(userSign: userSign, now: now)),
    );
  }

  @override
  State<OroscopoScreen> createState() => _OroscopoScreenState();
}

class _OroscopoScreenState extends State<OroscopoScreen>
    with SingleTickerProviderStateMixin {
  late Zodiac _sign = widget.userSign;

  // Il giorno per l'oroscopo, letto una sola volta a livello di schermata.
  late final DateTime _date = widget.now ?? DateTime.now();
  late final int _dayOfYear = Horoscope.dayOfYear(_date);
  late final int _year = _date.year;

  // Pulsazione lenta condivisa: respiro dell'emblema e delle forme a tema.
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  )..repeat();

  final GlobalKey _cardKey = GlobalKey();
  bool _sharing = false;
  bool _renderCard = false;

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final cards =
        Horoscope.forSign(sign: _sign, dayOfYear: _dayOfYear, year: _year);

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
        title: Text('Oroscopo', style: TypographyTokens.display(size: 20)),
      ),
      body: CosmosBackground(
        showZodiac: false,
        child: SafeArea(
          child: Stack(
            children: [
              _content(palette, cards),
              if (_renderCard)
                Positioned(
                  left: -3000,
                  top: 0,
                  child: RepaintBoundary(
                    key: _cardKey,
                    child: OroscopoShareCard(
                        sign: _sign, cards: cards, palette: palette),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(MaestroPalette palette, List<HoroscopeCard> cards) {
    return ListView(
      key: const Key('oroscopo_list'),
      padding: const EdgeInsets.fromLTRB(
          SpacingTokens.lg, kToolbarHeight, SpacingTokens.lg, SpacingTokens.lg),
      children: [
        // Il colpo d'occhio: l'emblema dentro un alone che respira, sul cosmo.
        _Headline(sign: _sign, palette: palette, pulse: _pulse),
        const SizedBox(height: SpacingTokens.md),
        // Selettore dei dodici segni, default sul segno di nascita dell'utente.
        SizedBox(
          height: 64,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: Zodiac.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: SpacingTokens.xs),
            itemBuilder: (context, i) {
              final z = Zodiac.values[i];
              return _SignChip(
                zodiac: z,
                selected: z == _sign,
                palette: palette,
                onTap: () => setState(() => _sign = z),
              );
            },
          ),
        ),
        const SizedBox(height: SpacingTokens.md),
        for (final card in cards) ...[
          _HoroscopeCardView(card: card, palette: palette, pulse: _pulse),
          const SizedBox(height: SpacingTokens.md),
        ],
        // La leva virale: il tasto Condividi.
        Text('Porta il tuo cielo di oggi con te',
            textAlign: TextAlign.center,
            style: TypographyTokens.body(size: 14)
                .copyWith(color: ColorTokens.textSecondary)),
        const SizedBox(height: SpacingTokens.sm),
        Center(
          child: FilledButton.icon(
            key: const Key('oroscopo_share'),
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
        const SizedBox(height: SpacingTokens.md),
        // Disclaimer, una sola volta.
        Text(
          Horoscope.disclaimer,
          key: const Key('oroscopo_disclaimer'),
          textAlign: TextAlign.center,
          style: TypographyTokens.body(size: 12).copyWith(
              color: ColorTokens.textSecondary,
              height: 1.4,
              fontStyle: FontStyle.italic),
        ),
      ],
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
      await shareOroscopoCard(
        boundaryKey: _cardKey,
        text: 'Il mio oroscopo di oggi, ${_sign.italianName}. Esoteric Circle.',
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

/// Il colpo d'occhio in alto: l'emblema del segno dentro un alone luminoso che
/// respira, col nome sotto. E' l'immagine che vende la giornata prima del testo.
class _Headline extends StatelessWidget {
  const _Headline(
      {required this.sign, required this.palette, required this.pulse});

  final Zodiac sign;
  final MaestroPalette palette;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: AnimatedBuilder(
            animation: pulse,
            builder: (context, _) {
              final breathe =
                  0.5 + 0.5 * (1 - (pulse.value - 0.5).abs() * 2);
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 130 + 20 * breathe,
                    height: 130 + 20 * breathe,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(colors: [
                        palette.gold.withValues(alpha: 0.10 + 0.18 * breathe),
                        palette.glow.withValues(alpha: 0.08 * breathe),
                        Colors.transparent,
                      ], stops: const [
                        0.0,
                        0.5,
                        1.0
                      ]),
                    ),
                  ),
                  // Il colpo d'occhio: l'emblema grande 3D metallico del segno
                  // (asset in assets/img/zodiac/).
                  ZodiacEmblem(
                      sign: sign, size: 104, art: ZodiacEmblemArt.emblem),
                ],
              );
            },
          ),
        ),
        Text(sign.italianName,
            key: const Key('oroscopo_sign_name'),
            style: TypographyTokens.display(size: 26)
                .copyWith(color: palette.goldSoft)),
        Text('Le stelle di oggi',
            style: TypographyTokens.label(size: 11).copyWith(
                color: ColorTokens.textSecondary, letterSpacing: 1.4)),
      ],
    );
  }
}

class _SignChip extends StatelessWidget {
  const _SignChip({
    required this.zodiac,
    required this.selected,
    required this.palette,
    required this.onTap,
  });

  final Zodiac zodiac;
  final bool selected;
  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key('oroscopo_sign_${zodiac.id}'),
      onTap: onTap,
      child: Container(
        width: 54,
        padding: const EdgeInsets.symmetric(vertical: 4),
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
                  : palette.gold.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Il chip usa il simbolo in miniatura (asset suo, in
            // assets/img_thumb/zodiac/), non l'emblema scalato. Il segno scelto
            // resta pieno, gli altri appena smorzati.
            Opacity(
              opacity: selected ? 1.0 : 0.55,
              child: ZodiacEmblem(
                  sign: zodiac, size: 30, art: ZodiacEmblemArt.symbol),
            ),
            const SizedBox(height: 2),
            Text(zodiac.italianName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TypographyTokens.label(size: 7).copyWith(
                    color: selected
                        ? palette.goldSoft
                        : ColorTokens.textSecondary,
                    letterSpacing: 0.2)),
          ],
        ),
      ),
    );
  }
}

class _HoroscopeCardView extends StatelessWidget {
  const _HoroscopeCardView(
      {required this.card, required this.palette, required this.pulse});

  final HoroscopeCard card;
  final MaestroPalette palette;
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    return DepthCard(
      key: Key('oroscopo_card_${card.domain.name}'),
      raised: true,
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Livello visivo prima del testo: la forma a tema del dominio.
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DomainVisual(
                domain: card.domain,
                value: card.indicator,
                palette: palette,
                pulse: pulse,
              ),
              const SizedBox(width: SpacingTokens.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(card.title,
                        style: TypographyTokens.display(size: 19)
                            .copyWith(color: palette.goldSoft)),
                    Text(card.domain.label.toUpperCase(),
                        style: TypographyTokens.label(size: 9).copyWith(
                            color: ColorTokens.textSecondary,
                            letterSpacing: 1.4)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),
          Text(card.text,
              style: TypographyTokens.body(size: 17)
                  .copyWith(color: ColorTokens.textPrimary, height: 1.5)),
          if (card.domain == HoroscopeDomain.fortuna) ...[
            const SizedBox(height: SpacingTokens.md),
            _FortunaFooter(card: card, palette: palette),
          ],
        ],
      ),
    );
  }
}

/// Il piede della scheda Fortuna: numero fortunato e colore del giorno con la
/// sua pastiglia.
class _FortunaFooter extends StatelessWidget {
  const _FortunaFooter({required this.card, required this.palette});

  final HoroscopeCard card;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _Pill(
          label: 'Numero',
          palette: palette,
          child: Text('${card.luckyNumber}',
              style: TypographyTokens.display(size: 20)
                  .copyWith(color: palette.goldSoft)),
        ),
        const SizedBox(width: SpacingTokens.sm),
        Expanded(
          child: _Pill(
            label: 'Colore del giorno',
            palette: palette,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: oroscopoColor(card.dayColor) ?? palette.goldSoft,
                    border: Border.all(
                        color: palette.gold.withValues(alpha: 0.6)),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(card.dayColor ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TypographyTokens.body(size: 13).copyWith(
                          color: ColorTokens.textPrimary)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(
      {required this.label, required this.child, required this.palette});

  final String label;
  final Widget child;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: SpacingTokens.sm, vertical: SpacingTokens.xs),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
        color: palette.primary.withValues(alpha: 0.4),
        border: Border.all(color: palette.gold.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label.toUpperCase(),
              style: TypographyTokens.label(size: 8).copyWith(
                  color: ColorTokens.textSecondary, letterSpacing: 0.8)),
          const SizedBox(height: 2),
          child,
        ],
      ),
    );
  }
}
