import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/astro/zodiac.dart';
import '../../core/synastry/synastry_report.dart';
import '../../core/synastry/vip_catalog.dart';
import '../../design_system/components/vip_arch_frame.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';

/// Un volto della Sinastria dentro la cornice ad arco dei ritratti VIP.
///
/// Regola del contenuto, in ordine: se c'e' la foto dell'utente la incornicia
/// con filtro dorato, altrimenti il ritratto illustrato del VIP, altrimenti il
/// segnaposto a costellazione. Cosi' il polo del VIP mostra sempre il suo
/// ritratto pieno, mai un cerchio vuoto.
class SinastriaFace extends StatelessWidget {
  const SinastriaFace({
    super.key,
    required this.palette,
    required this.sign,
    this.photoBytes,
    this.vipImagePath,
    this.borderWidth = 4,
  });

  final MaestroPalette palette;
  final Zodiac sign;
  final Uint8List? photoBytes;
  final String? vipImagePath;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final Widget inner;
    if (photoBytes != null) {
      inner = GoldenCosmicPhoto(
        bytes: photoBytes!,
        gold: palette.gold,
        blue: palette.primary,
      );
    } else if (vipImagePath != null) {
      inner = Image.asset(
        vipImagePath!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _Constellation(palette: palette, sign: sign),
      );
    } else {
      inner = _Constellation(palette: palette, sign: sign);
    }
    return VipArchFrame(
      gold: palette.gold,
      goldSoft: palette.goldSoft,
      blue: palette.primary,
      borderWidth: borderWidth,
      child: inner,
    );
  }
}

/// Il segnaposto a costellazione: un cielo profondo col simbolo del segno e una
/// scintilla, mai un vuoto piatto.
class _Constellation extends StatelessWidget {
  const _Constellation({required this.palette, required this.sign});

  final MaestroPalette palette;
  final Zodiac sign;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            palette.primary.withValues(alpha: 0.7),
            palette.deepest.withValues(alpha: 0.9),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(sign.symbol,
              style: TextStyle(
                  fontSize: 34,
                  color: palette.goldSoft.withValues(alpha: 0.5))),
          Icon(Icons.auto_awesome,
              color: palette.goldSoft.withValues(alpha: 0.9), size: 20),
        ],
      ),
    );
  }
}

/// La card condivisibile della Sinastria: i due volti col cuore, il cerchio
/// dell'affinita', le quattro barre, la cornice oro e blu di Medora e il rilancio
/// "sfida i tuoi amici". Snapshot statico, pronto per i social.
class SinastriaShareCard extends StatelessWidget {
  const SinastriaShareCard({
    super.key,
    required this.report,
    required this.vip,
    required this.userSign,
    required this.palette,
    this.userPhoto,
    this.width = 340,
  });

  final SynastryReport report;
  final Vip vip;
  final Zodiac userSign;
  final MaestroPalette palette;
  final Uint8List? userPhoto;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SpacingTokens.radiusLg),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            palette.deepest,
            Color.lerp(palette.deepest, palette.primary, 0.5)!,
            palette.deepest,
          ],
        ),
        border: Border.all(color: palette.gold.withValues(alpha: 0.8), width: 2),
        boxShadow: [
          BoxShadow(
              color: palette.gold.withValues(alpha: 0.25),
              blurRadius: 20,
              spreadRadius: 1),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('SINASTRIA',
              style: TypographyTokens.label(size: 12).copyWith(
                  color: palette.goldSoft, letterSpacing: 3.0)),
          const SizedBox(height: SpacingTokens.md),
          // I due volti col cuore.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: _CardPole(
                      palette: palette,
                      name: 'Tu',
                      sign: userSign,
                      face: SinastriaFace(
                          palette: palette,
                          sign: userSign,
                          photoBytes: userPhoto))),
              Padding(
                padding: const EdgeInsets.only(top: 34),
                child: Icon(Icons.favorite_rounded,
                    color: palette.gold, size: 22),
              ),
              Expanded(
                  child: _CardPole(
                      palette: palette,
                      name: vip.name,
                      sign: vip.sign,
                      face: SinastriaFace(
                          palette: palette,
                          sign: vip.sign,
                          vipImagePath: vip.fullPath))),
            ],
          ),
          const SizedBox(height: SpacingTokens.md),
          // Il cerchio dell'affinita'.
          SizedBox(
            width: 120,
            height: 120,
            child: CustomPaint(
              painter: SynastryGaugePainter(
                  percent: report.overall, palette: palette, progress: 1),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${report.overall}%',
                        style: TypographyTokens.display(size: 26)
                            .copyWith(color: palette.goldSoft)),
                    Text(report.band.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TypographyTokens.label(size: 8).copyWith(
                            color: ColorTokens.textSecondary,
                            letterSpacing: 0.6)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: SpacingTokens.md),
          // Le quattro barre.
          ...report.bars.map((b) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: SynastryBarRow(
                    bar: b, palette: palette, progress: 1, meetingReport: report),
              )),
          const SizedBox(height: SpacingTokens.md),
          Text(SynastryReport.challengeLine(vip.name),
              textAlign: TextAlign.center,
              style: TypographyTokens.body(size: 12)
                  .copyWith(color: ColorTokens.textPrimary, height: 1.3)),
          const SizedBox(height: 6),
          Text('Esoteric Circle',
              style: TypographyTokens.label(size: 9)
                  .copyWith(color: palette.goldSoft, letterSpacing: 1.6)),
        ],
      ),
    );
  }
}

class _CardPole extends StatelessWidget {
  const _CardPole({
    required this.palette,
    required this.name,
    required this.sign,
    required this.face,
  });

  final MaestroPalette palette;
  final String name;
  final Zodiac sign;
  final Widget face;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(width: 78, height: 96, child: face),
        const SizedBox(height: 6),
        Text(name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TypographyTokens.display(size: 14)),
        Text(sign.italianName,
            style: TypographyTokens.label(size: 9)
                .copyWith(color: palette.goldSoft, letterSpacing: 0.6)),
      ],
    );
  }
}

/// Il cerchio dell'affinita': una traccia e un arco d'oro, riempito da
/// [progress] (0..1) per l'animazione a video, pieno nella card.
class SynastryGaugePainter extends CustomPainter {
  SynastryGaugePainter({
    required this.percent,
    required this.palette,
    required this.progress,
  });

  final int percent;
  final MaestroPalette palette;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide / 2 * 0.86;
    canvas.drawCircle(
      center,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..color = palette.surfaceElevated.withValues(alpha: 0.6),
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      -math.pi / 2,
      2 * math.pi * (percent / 100) * progress.clamp(0.0, 1.0),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..shader = SweepGradient(
          colors: [palette.gold, palette.goldSoft, palette.gold],
        ).createShader(Rect.fromCircle(center: center, radius: r)),
    );
  }

  @override
  bool shouldRepaint(SynastryGaugePainter old) =>
      old.percent != percent ||
      old.palette != palette ||
      old.progress != progress;
}

/// Una barra infografica: etichetta, valore e traccia riempita da [progress].
/// Per la barra dell'incontro mostra la percentuale minima con la micro battuta.
class SynastryBarRow extends StatelessWidget {
  const SynastryBarRow({
    super.key,
    required this.bar,
    required this.palette,
    required this.progress,
    required this.meetingReport,
  });

  final SynastryBar bar;
  final MaestroPalette palette;
  final double progress;

  /// Serve solo per la barra dell'incontro, per la percentuale minima esatta.
  final SynastryReport meetingReport;

  @override
  Widget build(BuildContext context) {
    final isMeeting = bar.quip.isNotEmpty;
    // La barra dell'incontro e' volutamente cortissima: si usa la percentuale
    // reale minima, non il valore intero, cosi' resta un filo di riempimento.
    final fraction =
        isMeeting ? (meetingReport.meetingPercent / 100) : (bar.value / 100);
    final valueText =
        isMeeting ? meetingReport.meetingLabel : '${bar.value}%';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(bar.label,
                  style: TypographyTokens.label(size: 11).copyWith(
                      color: ColorTokens.textPrimary, letterSpacing: 0.4)),
            ),
            Text(valueText,
                style: TypographyTokens.label(size: 11)
                    .copyWith(color: palette.goldSoft)),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            children: [
              Container(
                  height: 7,
                  color: palette.surfaceElevated.withValues(alpha: 0.6)),
              FractionallySizedBox(
                widthFactor: (fraction * progress).clamp(0.0, 1.0),
                child: Container(
                  height: 7,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [palette.gold, palette.goldSoft]),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (isMeeting) ...[
          const SizedBox(height: 2),
          Text(bar.quip,
              style: TypographyTokens.body(size: 10).copyWith(
                  color: ColorTokens.textSecondary,
                  fontStyle: FontStyle.italic)),
        ],
      ],
    );
  }
}

/// Cattura il boundary indicato come PNG. Ritorna null se il boundary non e'
/// pronto.
Future<Uint8List?> captureBoundaryPng(GlobalKey key,
    {double pixelRatio = 3}) async {
  final obj = key.currentContext?.findRenderObject();
  if (obj is! RenderRepaintBoundary) return null;
  final image = await obj.toImage(pixelRatio: pixelRatio);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return data?.buffer.asUint8List();
}

/// Genera la card come immagine dal boundary e apre il foglio di condivisione
/// dei social. Il PNG va in un file temporaneo del dispositivo, non su un
/// server. Ritorna vero se la condivisione e' partita.
Future<bool> shareSynastryCard({
  required GlobalKey boundaryKey,
  required String text,
}) async {
  final png = await captureBoundaryPng(boundaryKey);
  if (png == null) return false;
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/sinastria_card.png');
  await file.writeAsBytes(png, flush: true);
  await SharePlus.instance.share(
    ShareParams(files: [XFile(file.path)], text: text),
  );
  return true;
}
