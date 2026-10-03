import 'dart:math' as math;

import 'package:flutter/material.dart';

/// LA LUNA DEL PROGETTO, UNA SOLA.
///
/// **Il dato che ha fatto nascere questo file.** Nell'anteprima del consulto,
/// guardata alla misura vera, il testo diceva "La Luna crescente sotto cui sei
/// nato" e il disco era una META' ESATTA col terminatore dritto, cioe' un primo
/// quarto. Una falce crescente e' un'altra forma. Un disegno che contraddice il
/// proprio numero e' peggio di un disegno impreciso: il primo distrugge la
/// fiducia, il secondo la mette solo alla prova.
///
/// **Erano tre geometrie.** La Luna realistica esisteva gia', costruita e
/// verificata per il Sigillo del Sogno, ma viveva dentro un metodo privato di una
/// classe privata: nessun'altra superficie poteva usarla. Accanto c'erano una
/// versione semplificata, con mezzo disco e un contorno netto, che il consulto
/// e il profilo mostravano, e una terza per l'ombra sopra la foto del Santuario.
/// Tre curve del terminatore che dovevano restare d'accordo fra loro, e non lo
/// erano.
///
/// Adesso la forma nasce qui, e in un punto solo. I trattamenti restano diversi
/// perche' servono a cose diverse, un disco dipinto e un velo sopra una foto,
/// ma la CURVA e' la stessa.
class LunaReale {
  const LunaReale._();

  /// Dove abita la geometria, dichiarato per la prova che la fa rispettare.
  static const String casa = 'lib/design_system/components/luna_reale.dart';

  /// Spessore minimo della falce, in frazione del raggio.
  ///
  /// A Luna nuova la falce vera sarebbe sotto il pixel e il disco sparirebbe:
  /// resta un filo di luce, cosi' la Luna nuova si vede ancora come Luna e non
  /// come un buco nel cielo.
  static const double falceMinima = 0.07;

  /// LA PARTE ILLUMINATA DEL DISCO, l'unica curva del terminatore del progetto.
  ///
  /// Non e' un mezzo disco e non e' un'ellisse: e' la loro INTERSEZIONE quando
  /// la Luna e' meno di meta' illuminata, la loro UNIONE quando e' piu' di
  /// meta'. E' questa la differenza fra una falce e un primo quarto, cioe'
  /// esattamente cio' che l'anteprima ha mostrato sbagliato.
  ///
  /// [illuminazione] va da 0 (nuova) a 1 (piena). [crescente] mette la luce a
  /// destra, come si vede dall'emisfero nord.
  static Path parteIlluminata(
    Offset c,
    double r, {
    required double illuminazione,
    required bool crescente,
  }) {
    final ill = illuminazione.clamp(0.0, 1.0);
    final disco = Path()..addOval(Rect.fromCircle(center: c, radius: r));

    // Il semiasse dell'ellisse del terminatore: zero a mezza luce, cioe' il
    // terminatore dritto del primo e dell'ultimo quarto.
    var a = r * (2 * ill - 1).abs();
    if (ill < 0.5) {
      final minimo = math.max(2.0, r * falceMinima);
      a = math.min(a, r - minimo);
    }

    final meta = Path()
      ..addRect(Rect.fromLTRB(
        crescente ? c.dx : c.dx - r,
        c.dy - r,
        crescente ? c.dx + r : c.dx,
        c.dy + r,
      ));
    final metaDisco = Path.combine(PathOperation.intersect, disco, meta);
    final ellisse = Path()
      ..addOval(Rect.fromCenter(center: c, width: 2 * a, height: 2 * r));
    final ellisseDisco = Path.combine(PathOperation.intersect, disco, ellisse);

    return ill >= 0.5
        ? Path.combine(PathOperation.union, metaDisco, ellisseDisco)
        : Path.combine(PathOperation.difference, metaDisco, ellisseDisco);
  }

  /// LA LUNA DIPINTA, con la luce cinerea, il bordo sfumato e i mari.
  ///
  /// Nessun contorno netto: un cerchio con la penna sopra il disco la fa
  /// sembrare un adesivo, e non un corpo lontano illuminato di lato.
  ///
  /// [visibilita] moltiplica ogni opacita', cosi' la Luna puo' comparire e
  /// sparire senza che il chiamante rifaccia i colori.
  static void dipingi(
    Canvas canvas,
    Offset c,
    double r, {
    required double illuminazione,
    required bool crescente,
    double visibilita = 1.0,
    bool alone = true,
    bool mari = true,
  }) {
    final vis = visibilita.clamp(0.0, 1.0);
    if (vis <= 0.01 || r <= 0) return;

    final disco = Path()..addOval(Rect.fromCircle(center: c, radius: r));

    if (alone) {
      // Alone a piu' strati, morbido, che fa da luce attorno al corpo.
      for (final s in const [4.6, 3.0, 1.9]) {
        canvas.drawCircle(
          c,
          r * s,
          Paint()
            ..shader = RadialGradient(colors: [
              const Color(0xFFCFDDFF).withValues(alpha: 0.15 * vis),
              const Color(0x00000000),
            ]).createShader(Rect.fromCircle(center: c, radius: r * s)),
        );
      }
    }

    // Luce cinerea: il disco in ombra resta appena illuminato, cosi' anche la
    // Luna nuova si vede. La luce riflessa dalla Terra esiste davvero, e senza
    // di essa la parte in ombra sarebbe un vuoto nero che il cielo non ha.
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.25, -0.3),
          colors: [
            const Color(0xFF9DAFD8).withValues(alpha: 0.24 * vis),
            const Color(0xFF56668F).withValues(alpha: 0.10 * vis),
          ],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    // Il bordo, sfumato dentro il disco invece che tracciato sopra.
    canvas.drawCircle(
      c,
      r * 0.97,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.12
        ..color = const Color(0xFFB9CBF2).withValues(alpha: 0.18 * vis)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.12),
    );

    final illuminata = parteIlluminata(c, r,
        illuminazione: illuminazione, crescente: crescente);
    canvas.drawPath(
      illuminata,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.2, -0.3),
          colors: [
            const Color(0xFFFFFDF6).withValues(alpha: 0.98 * vis),
            const Color(0xFFDCE3F4).withValues(alpha: 0.88 * vis),
          ],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    // Bagliore sopra la parte illuminata.
    canvas.drawPath(
      illuminata,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.22 * vis)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.28),
    );

    if (!mari) return;
    // Qualche mare lunare appena accennato. Il seme e' fisso: i mari della Luna
    // stanno sempre dove stanno, e farli ballare a ogni fotogramma sarebbe un
    // altro modo di dire il falso.
    canvas.save();
    canvas.clipPath(disco);
    final caso = math.Random(9);
    for (var i = 0; i < 5; i++) {
      final mc = c +
          Offset((caso.nextDouble() - 0.5) * 1.4 * r,
              (caso.nextDouble() - 0.5) * 1.4 * r);
      canvas.drawCircle(
        mc,
        r * (0.16 + caso.nextDouble() * 0.2),
        Paint()
          ..color = const Color(0xFF9AA8C8).withValues(alpha: 0.16 * vis)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.14),
      );
    }
    canvas.restore();
  }
}
