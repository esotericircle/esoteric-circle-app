import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/astro/zodiac.dart';
import '../../core/horoscope/horoscope.dart';
import '../../design_system/components/cosmos_background.dart';
import '../../design_system/components/depth_card.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// Oroscopo a quattro schede, la headline di Medora.
///
/// Quattro schede per segno (Generale, Amore, Carriera, Fortuna), ognuna con il
/// suo indicatore visivo, deterministiche dal giorno: stesso segno stesso giorno,
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

class _OroscopoScreenState extends State<OroscopoScreen> {
  late Zodiac _sign = widget.userSign;

  // Il giorno per l'oroscopo, letto una sola volta a livello di schermata.
  late final DateTime _date = widget.now ?? DateTime.now();
  late final int _dayOfYear = Horoscope.dayOfYear(_date);
  late final int _year = _date.year;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final cards = Horoscope.forSign(
        sign: _sign, dayOfYear: _dayOfYear, year: _year);

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
          child: ListView(
            key: const Key('oroscopo_list'),
            padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, kToolbarHeight,
                SpacingTokens.lg, SpacingTokens.xxxl),
            children: [
              // Intestazione del segno: il simbolo grande, poi il nome.
              Center(
                child: Column(
                  children: [
                    Text(_sign.symbol,
                        style: TextStyle(
                            fontSize: 44, color: palette.goldSoft)),
                    const SizedBox(height: SpacingTokens.xs),
                    Text(_sign.italianName,
                        style: TypographyTokens.display(size: 24)
                            .copyWith(color: palette.goldSoft)),
                    Text('Le stelle di oggi',
                        style: TypographyTokens.label(size: 11).copyWith(
                            color: ColorTokens.textSecondary,
                            letterSpacing: 1.2)),
                  ],
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              // Selettore dei dodici segni, per la Demo: il default resta il
              // segno di nascita dell'utente.
              SizedBox(
                height: 60,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: Zodiac.values.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: SpacingTokens.xs),
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
              // Le quattro schede, in ordine Generale, Amore, Carriera, Fortuna.
              for (final card in cards) ...[
                _HoroscopeCardView(card: card, palette: palette),
                const SizedBox(height: SpacingTokens.md),
              ],
              const SizedBox(height: SpacingTokens.sm),
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
          ),
        ),
      ),
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
        width: 52,
        alignment: Alignment.center,
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
            Text(zodiac.symbol,
                style: TextStyle(
                    fontSize: 20,
                    color: selected
                        ? palette.goldSoft
                        : ColorTokens.textSecondary)),
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
  const _HoroscopeCardView({required this.card, required this.palette});

  final HoroscopeCard card;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return DepthCard(
      key: Key('oroscopo_card_${card.domain.name}'),
      raised: true,
      padding: const EdgeInsets.all(SpacingTokens.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Livello visivo prima del testo: l'indicatore riempito da 2 a 5.
          _IndicatorRow(
              domain: card.domain, value: card.indicator, palette: palette),
          const SizedBox(height: SpacingTokens.sm),
          Text(card.title,
              style: TypographyTokens.display(size: 18)
                  .copyWith(color: palette.goldSoft)),
          Text(card.domain.label.toUpperCase(),
              style: TypographyTokens.label(size: 9).copyWith(
                  color: ColorTokens.textSecondary, letterSpacing: 1.4)),
          const SizedBox(height: SpacingTokens.sm),
          Text(card.text,
              style: TypographyTokens.body(size: 15)
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

/// La riga dell'indicatore: cinque glifi del dominio, i primi [value] pieni.
/// Icone diverse per dominio: Generale energia, Amore cuori, Carriera spinta che
/// sale, Fortuna quadrifoglio.
class _IndicatorRow extends StatelessWidget {
  const _IndicatorRow(
      {required this.domain, required this.value, required this.palette});

  final HoroscopeDomain domain;
  final int value;
  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    final filled = palette.gold;
    final empty = palette.gold.withValues(alpha: 0.22);
    return Row(
      children: [
        for (var i = 0; i < Horoscope.indicatorMax; i++) ...[
          _glyph(i < value ? filled : empty),
          if (i < Horoscope.indicatorMax - 1) const SizedBox(width: 4),
        ],
      ],
    );
  }

  Widget _glyph(Color color) {
    const size = 18.0;
    switch (domain) {
      case HoroscopeDomain.generale:
        return Icon(Icons.bolt_rounded, size: size, color: color);
      case HoroscopeDomain.amore:
        return Icon(Icons.favorite_rounded, size: size, color: color);
      case HoroscopeDomain.carriera:
        return Icon(Icons.trending_up_rounded, size: size, color: color);
      case HoroscopeDomain.fortuna:
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(painter: _CloverPainter(color: color)),
        );
    }
  }
}

/// Un quadrifoglio disegnato a vettori, quattro lobi a cuore attorno al centro.
class _CloverPainter extends CustomPainter {
  _CloverPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide * 0.26;
    final paint = Paint()..color = color;
    for (var i = 0; i < 4; i++) {
      final a = math.pi / 2 * i + math.pi / 4;
      final center = c + Offset(math.cos(a), math.sin(a)) * r;
      canvas.drawCircle(center, r * 1.05, paint);
    }
    // Stelo.
    canvas.drawLine(
      c,
      c + Offset(0, size.height * 0.42),
      Paint()
        ..color = color
        ..strokeWidth = size.shortestSide * 0.08
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_CloverPainter old) => old.color != color;
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
                    color: _dayColor(card.dayColor) ?? palette.goldSoft,
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

/// Traduce il nome del colore del giorno in una tinta per la pastiglia. Nomi
/// dalle palette del corpus; se un nome non e' mappato resta null e la pastiglia
/// usa l'oro tenue.
Color? _dayColor(String? name) => name == null ? null : _colorByName[name];

const Map<String, Color> _colorByName = {
  'rosso': Color(0xFFC0392B),
  'oro': Color(0xFFD4AF37),
  'corallo': Color(0xFFFF7F50),
  'cremisi': Color(0xFFDC143C),
  'verde salvia': Color(0xFF9CAF88),
  'terracotta': Color(0xFFE2725B),
  'ottone': Color(0xFFB5A642),
  'rosa antico': Color(0xFFC08081),
  'giallo': Color(0xFFF1C40F),
  'azzurro': Color(0xFF7EC8E3),
  'argento': Color(0xFFC0C0C0),
  'lilla': Color(0xFFC8A2C8),
  'bianco perla': Color(0xFFF0EAD6),
  'blu notte': Color(0xFF191970),
  'glicine': Color(0xFFC9A0DC),
  'ambra': Color(0xFFFFBF00),
  'arancio': Color(0xFFE67E22),
  'porpora': Color(0xFF800080),
  'verde bosco': Color(0xFF228B22),
  'beige': Color(0xFFE8DCC4),
  'blu polvere': Color(0xFFB0C4DE),
  'bronzo': Color(0xFFCD7F32),
  'rosa cipria': Color(0xFFE6BFCB),
  'verde acqua': Color(0xFF7FFFD4),
  'oro rosa': Color(0xFFB76E79),
  'celeste': Color(0xFF9FD8E6),
  'rosso scuro': Color(0xFF8B0000),
  'nero': Color(0xFF1A1A1A),
  'bordeaux': Color(0xFF6D071A),
  'verde smeraldo': Color(0xFF2ECC71),
  'viola': Color(0xFF7D3C98),
  'indaco': Color(0xFF4B0082),
  'turchese': Color(0xFF40E0D0),
  'grigio pietra': Color(0xFF928E85),
  'marrone': Color(0xFF7B4B2A),
  'verde scuro': Color(0xFF14532D),
  'antracite': Color(0xFF383E42),
  'blu elettrico': Color(0xFF1F6FEB),
  'blu ghiaccio': Color(0xFFD6ECEF),
  'verde mare': Color(0xFF2E8B57),
  'lavanda': Color(0xFFB497BD),
  'blu oltremare': Color(0xFF1B3A8B),
};
