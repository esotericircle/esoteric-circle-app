import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/astro/night_sky.dart';
import '../../core/astro/zodiac.dart';
import '../../core/identity/birth_identity.dart';
import '../../core/synastry/vip_catalog.dart';
import '../../core/synastry/synastry.dart';
import '../../design_system/components/depth_card.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/theme/maestro_scope.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// Sinastria VIP: l'affinita' fra il tuo cielo e quello di un VIP.
///
/// Un VIP e' sempre precaricato, cosi' la Demo puo' aprirsi da qui in un tap dal
/// Santuario. Il calcolo e' deterministico per elemento, un gioco simbolico di
/// intrattenimento, non una previsione. Nessuna nuova arte richiesta.
class SinastriaVipScreen extends StatefulWidget {
  const SinastriaVipScreen({super.key, this.userSign});

  final Zodiac? userSign;

  static Route<void> route({Zodiac? userSign}) {
    return MaterialPageRoute<void>(
      builder: (_) =>
          MaestroScope(child: SinastriaVipScreen(userSign: userSign)),
    );
  }

  @override
  State<SinastriaVipScreen> createState() => _SinastriaVipScreenState();
}

class _SinastriaVipScreenState extends State<SinastriaVipScreen> {
  late Vip _vip = VipCatalog.first;

  Zodiac get _userSign =>
      widget.userSign ?? NightSky.sunSign(BirthIdentity.example.birthMoment);

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final result = Synastry.between(_userSign, _vip.sign);

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
        title: Text('Sinastria VIP',
            style: TypographyTokens.display(size: 20)),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          key: const Key('sinastria_list'),
          padding: const EdgeInsets.fromLTRB(SpacingTokens.lg, SpacingTokens.md,
              SpacingTokens.lg, SpacingTokens.xxxl),
          children: [
            // I due poli: tu e il VIP.
            Row(
              children: [
                Expanded(child: _Pole(title: 'Tu', sign: _userSign.italianName, palette: palette)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: SpacingTokens.sm),
                  child: Icon(Icons.favorite_border_rounded,
                      color: palette.goldSoft, size: 22),
                ),
                Expanded(
                    child: _Pole(
                        title: _vip.name,
                        sign: _vip.sign.italianName,
                        palette: palette,
                        imagePath: _vip.imagePath)),
              ],
            ),
            const SizedBox(height: SpacingTokens.lg),
            // Il quadrante dell'affinita'.
            Center(
              child: SizedBox(
                width: 180,
                height: 180,
                child: CustomPaint(
                  key: const Key('sinastria_gauge'),
                  painter: _GaugePainter(percent: result.percent, palette: palette),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${result.percent}%',
                            style: TypographyTokens.display(size: 34)
                                .copyWith(color: palette.goldSoft)),
                        Text(result.title,
                            textAlign: TextAlign.center,
                            style: TypographyTokens.label(size: 11).copyWith(
                              color: ColorTokens.textSecondary,
                              letterSpacing: 0.6,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: SpacingTokens.lg),
            DepthCard(
              raised: true,
              padding: const EdgeInsets.all(SpacingTokens.lg),
              child: Text(result.reading,
                  style: TypographyTokens.body(size: 16).copyWith(
                      color: ColorTokens.textPrimary, height: 1.5)),
            ),
            const SizedBox(height: SpacingTokens.md),
            Text('Il tuo VIP',
                style: TypographyTokens.display(size: 16)
                    .copyWith(color: palette.goldSoft)),
            const SizedBox(height: SpacingTokens.sm),
            // Selettore dei VIP precaricati.
            SizedBox(
              height: 116,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: VipCatalog.vips.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: SpacingTokens.sm),
                itemBuilder: (context, i) {
                  final vip = VipCatalog.vips[i];
                  return _VipChip(
                    vip: vip,
                    selected: vip.name == _vip.name,
                    palette: palette,
                    onTap: () => setState(() => _vip = vip),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pole extends StatelessWidget {
  const _Pole({
    required this.title,
    required this.sign,
    required this.palette,
    this.imagePath,
  });

  final String title;
  final String sign;
  final MaestroPalette palette;

  /// Ritratto illustrato del polo, quando l'asset c'e'. Se manca, resta il
  /// medaglione dorato con la scintilla, segnaposto curato, mai un vuoto.
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && imagePath!.isNotEmpty;
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              palette.primary.withValues(alpha: 0.6),
              palette.deepest.withValues(alpha: 0.4),
            ]),
            border: Border.all(color: palette.gold.withValues(alpha: 0.6)),
          ),
          alignment: Alignment.center,
          child: hasImage
              ? Image.asset(
                  imagePath!,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Icon(Icons.auto_awesome, color: palette.goldSoft, size: 26),
                )
              : Icon(Icons.auto_awesome, color: palette.goldSoft, size: 26),
        ),
        const SizedBox(height: SpacingTokens.sm),
        Text(title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TypographyTokens.display(size: 16)),
        Text(sign,
            style: TypographyTokens.label(size: 11)
                .copyWith(color: palette.goldSoft, letterSpacing: 0.6)),
      ],
    );
  }
}

class _VipChip extends StatelessWidget {
  const _VipChip({
    required this.vip,
    required this.selected,
    required this.palette,
    required this.onTap,
  });

  final Vip vip;
  final bool selected;
  final MaestroPalette palette;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key('vip_${vip.name}'),
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(SpacingTokens.sm),
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
                  : palette.gold.withValues(alpha: 0.22)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(vip.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TypographyTokens.display(size: 14).copyWith(
                    color: selected ? palette.goldSoft : ColorTokens.textPrimary)),
            Text(vip.sign.italianName,
                style: TypographyTokens.label(size: 9)
                    .copyWith(color: palette.goldSoft, letterSpacing: 0.4)),
            const SizedBox(height: 2),
            Expanded(
              child: Text(vip.note,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TypographyTokens.body(size: 11)
                      .copyWith(color: ColorTokens.textSecondary, height: 1.2)),
            ),
            if (vip.hasCategory) ...[
              const SizedBox(height: 6),
              // Banner basso della categoria del VIP.
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(SpacingTokens.radiusSm),
                  color: palette.primary.withValues(alpha: 0.5),
                  border: Border.all(color: palette.gold.withValues(alpha: 0.4)),
                ),
                child: Text(vip.category.toUpperCase(),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TypographyTokens.label(size: 9).copyWith(
                        color: palette.goldSoft, letterSpacing: 0.8)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.percent, required this.palette});

  final int percent;
  final MaestroPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide / 2 * 0.86;
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..color = palette.surfaceElevated.withValues(alpha: 0.6),
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      -math.pi / 2,
      2 * math.pi * (percent / 100),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          colors: [palette.gold, palette.goldSoft, palette.gold],
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.percent != percent || old.palette != palette;
}
