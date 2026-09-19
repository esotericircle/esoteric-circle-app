import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design_system/theme/maestro_palette.dart';

/// **LA FORMA DEL DONO DEL SOFFIO DEL DESTINO.** Ordine DU voce 14,
/// 17 settembre 2026.
///
/// **Il fatto, visto a video dal fondatore**: attorno alla forma c'era un
/// cerchio che non tornava con niente. Erano due anelli fini disegnati a raggio
/// `r` e `r/2`, mentre i petali finiscono a `0,92 r` coi loro nodi luminosi
/// appena oltre: l'anello tagliava i nodi invece di contenerli, e il respiro
/// gonfiava e sgonfiava tutta la figura, anelli compresi, come una bolla.
///
/// **Adesso il respiro sta nei petali.** Ogni petalo si allunga e si accorcia
/// per conto suo, con la sua fase, e la figura resta ferma nel suo centro:
/// e' un soffione di luce che pulsa, non un cerchio che si dilata. Nessun
/// anello viene piu' disegnato, ed e' la cosa che la guardia misura.
///
/// Sta in un file suo perche' **una scena si misura solo se si puo'
/// raggiungere**: dentro il pittore privato della schermata nessuna prova
/// poteva dipingerla da sola.
abstract final class FormaDelDono {
  /// Quanti petali, cioe' quanti raggi che finiscono in un nodo.
  static const int petali = 24;

  /// Quanto si allunga e si accorcia un petalo col fiato, in frazione.
  static const double respiroDelPetalo = 0.12;

  /// Il raggio della figura, dato lo spazio [w] e il soffio [p] gia' fatto.
  static double raggio(double w, double p) => w * (0.13 + 0.10 * p);

  /// Dipinge il dono: alone, petali che respirano, cuore.
  ///
  /// [respiro] va da zero a uno e gira: e' la fase del fiato. Con Riduci
  /// Movimento chi chiama passa sempre la stessa fase, e i petali stanno
  /// fermi alla loro lunghezza piena.
  static void dipingi(
    Canvas canvas, {
    required Offset centro,
    required double larghezza,
    required double soffio,
    required double respiro,
    required MaestroPalette palette,
    bool fermo = false,
  }) {
    final p = soffio.clamp(0.0, 1.0);
    if (p <= 0.02) return;
    final r = raggio(larghezza, p);

    // Alone verde-oro d'aria, morbido, dietro alla forma.
    canvas.drawCircle(
      centro,
      r * 1.7,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = RadialGradient(
          colors: [
            palette.glow.withValues(alpha: 0.26 * p),
            const Color(0x00000000),
          ],
        ).createShader(Rect.fromCircle(center: centro, radius: r * 1.7)),
    );

    // **I PETALI RESPIRANO, UNO PER UNO.** Qui prima c'erano due anelli fini
    // "che danno struttura": erano il cerchio disallineato. La struttura la
    // fanno i petali, che sono cio' che un soffione ha davvero.
    final ray = Paint()
      ..strokeWidth = 0.9
      ..strokeCap = StrokeCap.round
      ..color = palette.gold.withValues(alpha: 0.42 * p);
    for (var i = 0; i < petali; i++) {
      final a = 2 * math.pi * i / petali - math.pi / 2;
      final dir = Offset(math.cos(a), math.sin(a));
      // La fase sfalsata fa muovere i petali in onda e non tutti insieme.
      final fase = fermo ? 0.25 : respiro + i / petali * 0.5;
      final onda = fermo ? 1.0 : math.sin(2 * math.pi * fase);
      final lungo = r * (0.92 + respiroDelPetalo * onda);
      final dentro = centro + dir * r * 0.5;
      final fuori = centro + dir * lungo;
      canvas.drawLine(dentro, fuori, ray);
      // Bagliore additivo e nodo definito al vertice.
      canvas.drawCircle(
        fuori,
        3.4,
        Paint()
          ..blendMode = BlendMode.plus
          ..color = palette.goldSoft.withValues(alpha: 0.22 * p),
      );
      canvas.drawCircle(fuori, 1.7,
          Paint()..color = palette.goldSoft.withValues(alpha: 0.85 * p));
    }

    // Cuore definito e luminoso.
    canvas.drawCircle(
      centro,
      r * 0.4,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFF6DC).withValues(alpha: 0.85 * p),
            const Color(0x00FFF6DC),
          ],
        ).createShader(Rect.fromCircle(center: centro, radius: r * 0.4)),
    );
    canvas.drawCircle(centro, r * 0.09,
        Paint()..color = const Color(0xFFFFF9E8).withValues(alpha: 0.95 * p));
  }
}
