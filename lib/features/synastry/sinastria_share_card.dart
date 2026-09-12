import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/astro/zodiac.dart';
import '../../core/synastry/synastry_report.dart';
import '../../core/synastry/vip_catalog.dart';
import '../../design_system/components/vip_frame.dart';
import '../../design_system/theme/maestro_palette.dart';
import '../../design_system/tokens/color_tokens.dart';
import '../../design_system/tokens/spacing_tokens.dart';
import '../../design_system/tokens/typography_tokens.dart';
import '../../core/condivisione/porta_della_condivisione.dart';
import '../../design_system/components/card_a_misura_fissa.dart';

/// La card condivisibile della Sinastria: i due volti nella cornice VIP col
/// cuore, il cerchio dell'affinita', le quattro barre, la cornice oro e blu di
/// Medora e il rilancio "sfida i tuoi amici". Snapshot statico per i social.
class SinastriaShareCard extends StatelessWidget {
  const SinastriaShareCard({
    super.key,
    required this.report,
    required this.vip,
    required this.userSign,
    required this.userName,
    required this.userDate,
    required this.palette,
    this.userPhoto,
    this.width = 360,
  });

  /// **LE PROPORZIONI DI UNA STORIA, ordine BO voce 11.** Nove a sedici, che
  /// e' il riquadro in cui la card viene guardata davvero: una card quadrata
  /// dentro una storia lascia due fasce vuote sopra e sotto, e quelle fasce
  /// sono meta' dell'attenzione di chi guarda.
  static const double rapportoDellaStoria = 9 / 16;

  final SynastryReport report;
  final Vip vip;
  final Zodiac userSign;
  final String userName;
  final String userDate;
  final MaestroPalette palette;
  final Uint8List? userPhoto;
  final double width;

  @override
  Widget build(BuildContext context) {
    // **UNA CARD CHE ESCE DAL TELEFONO SI DISEGNA A MISURA FISSA.**
    // Ordine CN voce 12: la scala del testo di chi la crea non entra
    // nell'immagine, perche' l'immagine la guardano altri.
    return CardAMisuraFissa(
      child: SizedBox(
        key: const Key('sinastria_card'),
        width: width,
        height: width / rapportoDellaStoria,
        child: _dentro(),
      ),
    );
  }

  Widget _dentro() {
    return Container(
      width: width,
      height: width / rapportoDellaStoria,
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
        border:
            Border.all(color: palette.gold.withValues(alpha: 0.8), width: 2),
        boxShadow: [
          BoxShadow(
              color: palette.gold.withValues(alpha: 0.25),
              blurRadius: 20,
              spreadRadius: 1),
        ],
      ),
      // **IL CONTENUTO SI ADATTA AL RIQUADRO INVECE DI TRABOCCARE.**
      //
      // La card ha adesso una misura fissa, quella di una storia, e il
      // contenuto no: un nome VIP lungo, un nome utente lungo e quattro barre
      // insieme sforavano di 101 pixel, misurati. Un `FittedBox` che
      // rimpicciolisce quanto basta e' l'unica soluzione che regge TUTTI i
      // casi, compresi quelli che nessuno ha ancora provato: qualunque
      // aggiustamento di spaziature reggerebbe i tre nomi provati e cadrebbe
      // al quarto. La card e' un'immagine da guardare, non una schermata da
      // toccare, quindi il pavimento tipografico dell'app qui non si applica:
      // conta che si legga, e a scendere e' tutta la composizione insieme.
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: SizedBox(
          width: width - SpacingTokens.lg * 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('SINASTRIA',
                  style: TypographyTokens.label(size: 12)
                      .copyWith(color: palette.goldSoft, letterSpacing: 3.0)),
              const SizedBox(height: SpacingTokens.md),
              // I due volti nella cornice VIP col cuore.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _CardPole(
                      palette: palette,
                      sign: userSign,
                      portrait: VipFramedPortrait(
                        palette: palette,
                        name: userName,
                        date: userDate,
                        sign: userSign.symbol,
                        photo: userPhoto,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: SpacingTokens.sm, vertical: 60),
                    child: Icon(Icons.favorite_rounded,
                        color: palette.gold, size: 22),
                  ),
                  Expanded(
                    child: _CardPole(
                      palette: palette,
                      sign: vip.sign,
                      portrait: VipFramedPortrait(
                        palette: palette,
                        name: vip.name,
                        date: vip.note,
                        sign: vip.sign.symbol,
                        vipAsset: vip.fullPath,
                      ),
                    ),
                  ),
                ],
              ),
              // **I TRE FILI DEGLI ASPETTI PIU' FORTI, disegnati fra i due volti.**
              // Ordine BO voce 11: sono gli stessi tre che si sono accesi nella
              // chiamata, quindi cio' che si e' visto e cio' che si condivide sono
              // la stessa cosa.
              if (report.aspettiPiuForti.isNotEmpty)
                SizedBox(
                  height: 34,
                  width: double.infinity,
                  child: CustomPaint(
                    key: const Key('sinastria_card_fili'),
                    painter: FiliDellaCard(
                      quanti: report.aspettiPiuForti.length,
                      colore: palette.goldSoft,
                    ),
                  ),
                ),
              const SizedBox(height: SpacingTokens.md),
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
                            style: TypographyTokens.cerimoniale()
                                .copyWith(color: palette.goldSoft)),
                        Text(report.band.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TypographyTokens.etichetta().copyWith(
                                color: ColorTokens.textSecondary,
                                letterSpacing: 0.6)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: SpacingTokens.md),
              ...report.bars.map((b) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: SynastryBarRow(
                        bar: b,
                        palette: palette,
                        progress: 1,
                        meetingReport: report),
                  )),
              const SizedBox(height: SpacingTokens.md),
              Text(SynastryReport.challengeLine(vip.name),
                  textAlign: TextAlign.center,
                  style: TypographyTokens.corpo()
                      .copyWith(color: ColorTokens.textPrimary, height: 1.3)),
              const SizedBox(height: 6),
              Text('Esoteric Circle',
                  style: TypographyTokens.etichetta()
                      .copyWith(color: palette.goldSoft, letterSpacing: 1.6)),
            ],
          ),
        ),
      ),
    );
  }
}

/// I FILI DEGLI ASPETTI SULLA CARD. Ordine BO voce 11.
///
/// **Un tratto per aspetto, e nessuno di piu'.** Il numero arriva da
/// `SynastryReport.aspettiPiuForti`, cioe' dalla stessa lista che si accende
/// nella chiamata: la card non ne inventa nemmeno uno.
class FiliDellaCard extends CustomPainter {
  const FiliDellaCard({required this.quanti, required this.colore});

  final int quanti;
  final Color colore;

  @override
  void paint(Canvas canvas, Size size) {
    if (quanti <= 0) return;
    final penna = Paint()
      ..color = colore.withValues(alpha: 0.75)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final tracciato = Path();
    for (var i = 0; i < quanti; i++) {
      final y = size.height * (i + 1) / (quanti + 1);
      final curva = (i.isEven ? -1 : 1) * size.height * 0.28;
      tracciato.moveTo(size.width * 0.12, y);
      tracciato.quadraticBezierTo(
          size.width / 2, y + curva, size.width * 0.88, y);
    }
    canvas.drawPath(tracciato, penna);
  }

  @override
  bool shouldRepaint(FiliDellaCard vecchio) =>
      vecchio.quanti != quanti || vecchio.colore != colore;
}

class _CardPole extends StatelessWidget {
  const _CardPole({
    required this.palette,
    required this.sign,
    required this.portrait,
  });

  final MaestroPalette palette;
  final Zodiac sign;
  final Widget portrait;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        portrait,
        const SizedBox(height: 6),
        Text(sign.italianName,
            style: TypographyTokens.etichetta()
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
    // **QUELLO CHE SI VEDE DEVE DISTINGUERE DUE COPPIE. Ordine CA voce 06.**
    //
    // Il rilievo era stato chiuso dall'ordine BX come falso, e la
    // motivazione era giusta a meta': la possibilita' d'incontro NON e' sempre
    // bassissima, lo era la misura, fatta con una citta' sola. La misura e'
    // stata corretta; **il valore che la persona vede no**, e sulla build 2211
    // il fondatore leggeva ancora 1,8 per cento.
    //
    // La causa stava qui: `bars` porta gia' `indiceSullaScala`, cioe' quanto
    // quella possibilita' e' vicina al massimo che il modello concede, ma
    // questa riga lo buttava via e ridisegnava la percentuale cruda, che su
    // una scala da cento e' una barra vuota per tutti. Adesso la barra usa
    // l'indice, e al posto del numero si legge il gradino in PAROLE, che
    // distingue due coppie a colpo d'occhio. **La percentuale vera non
    // sparisce**: sta nella riga sotto, insieme al perche'.
    final fraction = bar.value / 100;
    final valueText =
        isMeeting ? meetingReport.incontro.inParole : '${bar.value}%';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(bar.label,
                  style: TypographyTokens.etichetta().copyWith(
                      color: ColorTokens.textPrimary, letterSpacing: 0.4)),
            ),
            Text(valueText,
                style: TypographyTokens.etichetta()
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
          // Il perche', con dentro la percentuale vera: il numero non si
          // nasconde, si mette dove non fa credere che sia una barra vuota.
          Text('${meetingReport.meetingLabel}. ${bar.quip}',
              style: TypographyTokens.corpo().copyWith(
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
  // Ordine BG voce 04: l'esito VERO della porta risale al chiamante,
  // che a condivisione avvenuta paga il premio dichiarato sul pulsante.
  return PortaDellaCondivisione.daFile(file.path, testo: text);
}
