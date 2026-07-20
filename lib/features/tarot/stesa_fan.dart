import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/tarot/tarot_card.dart';
import '../../core/tarot/tarot_spread.dart';
import '../../design_system/theme/maestro_palette.dart';
import 'tarot_card_art.dart';
import 'stesa_choreography.dart';

/// Il ventaglio delle carte coperte, con tutta la sua regia.
///
/// Fa quattro cose, tutte guidate dalla scena corrente: l'ingresso a spirale
/// dal fondo stellato, il respiro lento mentre aspetta, il taglio in due meta'
/// e il vortice del mescolamento. Il movimento e' 2.5D, scala e scostamento e
/// una punta di rotazione: nessuna prospettiva vera, cosi' resta fluido anche
/// sui dispositivi di mezzo.
///
/// Con Riduci Movimento tutto arriva subito alla posa di riposo.
class StesaFan extends StatelessWidget {
  const StesaFan({
    super.key,
    required this.palette,
    required this.taken,
    required this.onPick,
    required this.scene,
    required this.ingresso,
    required this.respiro,
    required this.taglio,
    required this.mescolamento,
    required this.taglioIndice,
    this.reduceMotion = false,
  });

  final MaestroPalette palette;
  final Set<int> taken;
  final ValueChanged<int> onPick;

  final StesaScene scene;

  /// Le quattro fasi, ognuna da 0 a 1.
  final double ingresso;
  final double respiro;
  final double taglio;
  final double mescolamento;

  /// Dove il mazzo e' stato tagliato: le carte da qui in su sono la meta' alta.
  final int taglioIndice;

  final bool reduceMotion;

  /// Quante carte stanno su una riga prima di passare a due file.
  ///
  /// Sotto una certa larghezza il ventaglio unico schiaccerebbe le carte fino a
  /// renderle indistinguibili: meglio due file piu' corte.
  static const double sogliaDoppiaFila = 340;

  /// Le carte per fila, data la larghezza disponibile.
  static List<int> fileFor(double larghezza, {int n = TarotSpread.fanSize}) {
    if (larghezza >= sogliaDoppiaFila) return [n];
    final prima = (n / 2).ceil();
    return [prima, n - prima];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final file = fileFor(w);
        final doppia = file.length > 1;
        final cardW = doppia
            ? math.min(78.0, w / (file.first * 0.66))
            : math.min(74.0, w / (TarotSpread.fanSize * 0.62));
        final cardH = cardW / TarotFrame.aspect;
        final altezzaFila = cardH + 26;

        var indice = 0;
        final righe = <Widget>[];
        for (final quante in file) {
          final base = indice;
          righe.add(SizedBox(
            height: altezzaFila,
            child: _Fila(
              palette: palette,
              taken: taken,
              onPick: onPick,
              scene: scene,
              ingresso: ingresso,
              respiro: respiro,
              taglio: taglio,
              mescolamento: mescolamento,
              taglioIndice: taglioIndice,
              reduceMotion: reduceMotion,
              indiceBase: base,
              quante: quante,
              cardW: cardW,
            ),
          ));
          indice += quante;
        }

        return Column(
          key: const Key('stesa_fan'),
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < righe.length; i++) ...[
              if (i > 0) const SizedBox(height: 6),
              righe[i],
            ],
          ],
        );
      },
    );
  }
}

class _Fila extends StatelessWidget {
  const _Fila({
    required this.palette,
    required this.taken,
    required this.onPick,
    required this.scene,
    required this.ingresso,
    required this.respiro,
    required this.taglio,
    required this.mescolamento,
    required this.taglioIndice,
    required this.reduceMotion,
    required this.indiceBase,
    required this.quante,
    required this.cardW,
  });

  final MaestroPalette palette;
  final Set<int> taken;
  final ValueChanged<int> onPick;
  final StesaScene scene;
  final double ingresso;
  final double respiro;
  final double taglio;
  final double mescolamento;
  final int taglioIndice;
  final bool reduceMotion;
  final int indiceBase;
  final int quante;
  final double cardW;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final step = quante > 1 ? (w - cardW) / (quante - 1) : 0.0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            for (var i = 0; i < quante; i++)
              _posiziona(
                context: context,
                i: i,
                globale: indiceBase + i,
                left: step * i,
                w: w,
              ),
          ],
        );
      },
    );
  }

  Widget _posiziona({
    required BuildContext context,
    required int i,
    required int globale,
    required double left,
    required double w,
  }) {
    // L'arco del ventaglio: le carte ai lati si alzano e si inclinano.
    final metaFila = (quante - 1) / 2;
    final scarto = quante > 1 ? (i - metaFila) / metaFila : 0.0;
    final arco = -math.pow(scarto, 2).toDouble() * 10 + 10;
    final inclinazione = scarto * 0.16;

    var offset = Offset.zero;
    var scala = 1.0;
    var opacita = 1.0;
    var angolo = inclinazione;

    if (!reduceMotion) {
      // Ingresso: la carta nasce dietro Medora e scende in spirale.
      if (ingresso < 1) {
        final posa = SpiralPose.of(
          index: globale,
          count: TarotSpread.fanSize,
          t: ingresso,
          centro: Offset(w / 2 - left - cardW / 2, -180),
        );
        offset += posa.offset;
        scala *= posa.scale;
        opacita *= posa.opacity;
        angolo += posa.angle;
      } else {
        // Respiro: un battito lento di scala e opacita' mentre aspetta.
        final battito = math.sin(respiro * 2 * math.pi);
        scala *= 1 + 0.012 * battito;
        opacita *= 0.94 + 0.06 * ((battito + 1) / 2);
      }
      // Taglio: le due meta' scorrono e tornano.
      if (taglio > 0 && taglio < 1) {
        offset += CutPose.offsetOf(
          index: globale,
          count: TarotSpread.fanSize,
          taglioA: taglioIndice,
          t: taglio,
        );
      }
      // Vortice del mescolamento.
      if (mescolamento > 0 && mescolamento < 1) {
        offset += VortexPose.offsetOf(
          index: globale,
          count: TarotSpread.fanSize,
          t: mescolamento,
        );
        angolo += VortexPose.angleOf(
          index: globale,
          count: TarotSpread.fanSize,
          t: mescolamento,
        );
      }
    }

    return Positioned(
      left: left + offset.dx,
      top: arco + offset.dy,
      width: cardW,
      child: Opacity(
        opacity: opacita.clamp(0.0, 1.0),
        child: Transform.rotate(
          angle: angolo,
          child: Transform.scale(
            scale: scala,
            child: _FanCard(
              key: Key('stesa_fan_$globale'),
              width: cardW,
              palette: palette,
              taken: taken.contains(globale),
              attivo: scene.accettaGesti,
              onTap: () => onPick(globale),
            ),
          ),
        ),
      ),
    );
  }
}

/// Una carta coperta del ventaglio, col dorso di Medora.
class _FanCard extends StatelessWidget {
  const _FanCard({
    super.key,
    required this.width,
    required this.palette,
    required this.taken,
    required this.attivo,
    required this.onTap,
  });

  final double width;
  final MaestroPalette palette;
  final bool taken;

  /// Fuori dalla scena di riposo il ventaglio non risponde al tocco.
  final bool attivo;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: taken || !attivo ? null : onTap,
      child: AnimatedOpacity(
        opacity: taken ? 0.25 : 1.0,
        duration: const Duration(milliseconds: 250),
        child: AspectRatio(
          aspectRatio: TarotFrame.aspect,
          child: CardBack(palette: palette),
        ),
      ),
    );
  }
}

/// Il dorso di Medora, identico dritto e capovolto: dal dorso non si capisce
/// mai in che verso uscira' la carta.
class CardBack extends StatelessWidget {
  const CardBack({super.key, required this.palette});

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
          errorBuilder: (_, __, ___) => _DorsoDipinto(palette: palette),
        ),
      ),
    );
  }
}

/// Ripiego dipinto se il dorso mancasse: mai una carta vuota.
class _DorsoDipinto extends StatelessWidget {
  const _DorsoDipinto({required this.palette});

  final MaestroPalette palette;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DorsoPainter(palette: palette));
  }
}

class _DorsoPainter extends CustomPainter {
  _DorsoPainter({required this.palette});

  final MaestroPalette palette;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(r, Paint()..color = palette.surfaceElevated);
    final oro = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = palette.gold.withValues(alpha: 0.5);
    canvas.drawRect(r.deflate(4), oro);
    canvas.drawCircle(r.center, size.shortestSide * 0.22, oro);
  }

  @override
  bool shouldRepaint(_DorsoPainter old) => old.palette != palette;
}
