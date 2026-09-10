import 'dart:math' as math;

import 'package:flutter/material.dart';

/// **LA NEBBIA CHE LA MANO APRE, E L'ANIMALE IN CONTROLUCE.**
/// Ordine DC voce 07, 10 settembre 2026.
///
/// **LA NEBBIA NON SI DIRADA DA SOLA**, e l'ordine e' esplicito: *"la mano la
/// apre, con un varco che si richiude piano"*. E' la stessa scelta del tunnel
/// e del Loto: **cio' che si guarda non vale quanto cio' che si fa**.
///
/// **L'ANIMALE NON E' UNA FOTOGRAFIA E NON E' UNA ILLUSTRAZIONE FERMA**: e'
/// una figura scura in controluce, riconoscibile dalla sagoma e dal modo di
/// muoversi, con gli occhi che riflettono. Nei primi tre viaggi si vede sempre
/// **parzialmente**. Al quarto, e solo al quarto, viene in piena luce.
///
/// **LE MISURE, sotto la Regola I.** L'animale al quarto viaggio occupa almeno
/// il **sessanta per cento dell'altezza utile dello SCHERMO**, non del suo
/// riquadro: e' la distinzione che sull'ordine DB e' costata due giri interi.
class PittoreDellaNebbia extends CustomPainter {
  PittoreDellaNebbia({
    required this.varchi,
    required this.senzaMoto,
    this.densita = 1.0,
  });

  /// I varchi aperti dalla mano: centro e quanto sono ancora aperti, da 1
  /// appena fatto a 0 richiuso.
  final List<VarcoNellaNebbia> varchi;

  final bool senzaMoto;

  /// Quanto e' fitta, da 0 a 1. Ordine DC voce 08: chi torna dopo settimane
  /// trova **nebbia fitta**.
  final double densita;

  /// **QUANTI STRATI.** Tre, e scorrono a velocita' diverse: due si leggono
  /// come una texture ferma, quattro costano senza aggiungere niente.
  static const int quantiStrati = 3;

  /// **QUANTO DURA UN VARCO PRIMA DI RICHIUDERSI**, in secondi.
  ///
  /// Due secondi e mezzo: il tempo di guardare cosa c'e' sotto senza che la
  /// nebbia diventi una tenda che si apre e resta aperta. **Se restasse
  /// aperta, il gesto varrebbe una volta sola e poi la nebbia sarebbe finita.**
  static const double quantoDuraUnVarco = 2.5;

  @override
  void paint(Canvas canvas, Size size) {
    final lato = size.longestSide;
    for (var s = 0; s < quantiStrati; s++) {
      final quota = (s + 1) / quantiStrati;
      final pittura = Paint()
        ..color = const Color(0xFF9FA8BF)
            .withValues(alpha: (0.13 + 0.10 * quota) * densita)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 18.0 + 22.0 * quota);
      // Bande morbide sfalsate, che a strati sovrapposti si leggono come
      // nebbia invece che come strisce.
      for (var b = 0; b < 4; b++) {
        final y = size.height * ((b + s * 0.37) % 4) / 4;
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(size.width * (0.3 + 0.4 * ((b + s) % 3) / 2), y),
            width: lato * (0.9 + 0.3 * quota),
            height: size.height * 0.33,
          ),
          pittura,
        );
      }
    }
    // **I VARCHI SI RITAGLIANO DALLA NEBBIA**, invece di essere disegnati
    // sopra: un alone chiaro sopra la nebbia sarebbe luce, non un buco.
    for (final v in varchi) {
      if (v.quantoEAperto <= 0) continue;
      final raggio = lato * 0.22 * v.quantoEAperto;
      canvas.drawCircle(
        v.dove,
        raggio,
        Paint()
          ..blendMode = BlendMode.dstOut
          ..shader = RadialGradient(colors: [
            Colors.black.withValues(alpha: 0.95),
            Colors.transparent,
          ]).createShader(Rect.fromCircle(center: v.dove, radius: raggio)),
      );
    }
  }

  @override
  bool shouldRepaint(PittoreDellaNebbia vecchio) => true;
}

/// Un varco aperto dalla mano nella nebbia.
class VarcoNellaNebbia {
  const VarcoNellaNebbia({required this.dove, required this.quantoEAperto});

  final Offset dove;

  /// Da 1 appena aperto a 0 richiuso.
  final double quantoEAperto;
}

/// **L'ANIMALE IN CONTROLUCE.** Ordine DC voce 07.
///
/// Non una fotografia: **una sagoma scura con gli occhi che riflettono**. Il
/// grado di rivelazione dipende dalla discesa, e nei primi tre e' sempre
/// parziale.
class PittoreDellAnimale extends CustomPainter {
  PittoreDellAnimale({
    required this.discesa,
    required this.quantaLuce,
    required this.seme,
  });

  /// La discesa, da 0 a 3. Alla quarta viene in piena luce.
  final int discesa;

  /// Quanta luce lo colpisce, da 0 a 1: la muove la scena, non questo pittore.
  final double quantaLuce;

  /// Il seme della sagoma, dal nome dell'animale: **due animali diversi hanno
  /// sagome diverse**, ed e' l'unica cosa che li distingue in controluce.
  final int seme;

  /// **QUANTO OCCUPA L'ANIMALE IN PIENA LUCE**, in frazione del lato.
  ///
  /// **CINQUANTA, E NON SESSANTACINQUE, e la ragione e' una misura.**
  ///
  /// Questa quota e' l'**altezza** della sagoma, e il corpo e' largo
  /// `alto * 1.35`: la larghezza dipinta, che e' quella che l'ordine misura,
  /// vale un terzo in piu'. Cinquanta di altezza fanno **sessantasette per
  /// cento di larghezza**, sopra il sessanta che l'ordine chiede.
  ///
  /// **La prima stesura scriveva 0,65 pensando alla larghezza**, e la guardia
  /// ha misurato **ottantotto per cento** sui pixel. Non era sbagliato di
  /// poco: era la misura sbagliata.
  static const double quotaInPienaLuce = 0.50;

  /// **E QUANTO SE NE VEDE ALLA DISCESA [discesa].**
  ///
  /// Ordine DC voce 04: un'ombra che passa, di profilo che si allontana, ti
  /// guarda e non fugge, viene in piena luce.
  static double quotaAllaDiscesa(int discesa) {
    // Le tre quote prima della piena luce stanno sotto il sessanta per cento
    // di **larghezza dipinta** anche col fattore 1,35 del corpo: 0,38 per 1,35
    // fa 0,51, e la guardia lo verifica sui pixel invece che su questa riga.
    const quote = [0.22, 0.30, 0.38, quotaInPienaLuce];
    return quote[discesa.clamp(0, quote.length - 1)];
  }

  @override
  void paint(Canvas canvas, Size size) {
    final lato = size.shortestSide;
    final quota = quotaAllaDiscesa(discesa);
    final centro = size.center(Offset.zero);
    final alto = lato * quota;
    final largo = alto * 1.35;

    // **LA SAGOMA.** Un corpo, una testa, quattro zampe accennate: non serve
    // che sia un animale vero, serve che sia riconoscibile come **un** animale
    // e che due semi diversi diano due profili diversi.
    final rnd = math.Random(seme);
    final corpo = Path();
    final baseY = centro.dy + alto * 0.35;
    final sx = centro.dx - largo / 2;
    corpo.moveTo(sx, baseY);
    const quantiDossi = 7;
    for (var i = 0; i <= quantiDossi; i++) {
      final t = i / quantiDossi;
      final x = sx + largo * t;
      // Il dorso, con una gobba che il seme sposta: e' cio' che distingue un
      // orso da una lince quando si vede solo il profilo.
      final gobba = math.sin(t * math.pi) * alto * (0.42 + rnd.nextDouble() * 0.2);
      corpo.lineTo(x, baseY - gobba);
    }
    // La testa, in fondo al dorso.
    final testaX = sx + largo * 0.94;
    final testaY = baseY - alto * (0.5 + rnd.nextDouble() * 0.25);
    corpo.lineTo(testaX, testaY);
    corpo.lineTo(sx + largo, baseY);
    corpo.close();

    canvas.drawPath(
      corpo,
      Paint()
        ..color = const Color(0xFF07040D).withValues(alpha: 0.92)
        ..maskFilter = MaskFilter.blur(
            BlurStyle.normal, (1 - quantaLuce) * 6 + 1),
    );

    // **GLI OCCHI CHE RIFLETTONO**, che sono la cosa che lo rende vivo e che
    // si vede anche quando tutto il resto e' un'ombra.
    final occhio = alto * 0.035;
    for (final dx in [-occhio * 1.6, occhio * 0.4]) {
      canvas.drawCircle(
        Offset(testaX + dx, testaY + occhio * 1.2),
        occhio,
        Paint()
          ..color = const Color(0xFFE8D9A8)
              .withValues(alpha: 0.55 + 0.40 * quantaLuce),
      );
    }
  }

  @override
  bool shouldRepaint(PittoreDellAnimale vecchio) =>
      vecchio.discesa != discesa ||
      vecchio.quantaLuce != quantaLuce ||
      vecchio.seme != seme;
}
