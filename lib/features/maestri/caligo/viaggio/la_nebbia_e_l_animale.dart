import 'package:flutter/material.dart';

import 'il_tunnel_che_scende.dart';

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
    required this.apertura,
    required this.senzaMoto,
    this.densita = 1.0,
  });

  /// **QUANTO E' GIA' DIRADATA, da 0 a 1.** Ordine DG voce 05,
  /// 11 settembre 2026.
  ///
  /// **Prima qui c'era un elenco di varchi**, uno per tocco, e tre tocchi
  /// bastavano a passare oltre. Il fondatore li ha contati: *"per diradare la
  /// nebbia devo fare 3 tap con grafica di merda e non un movimento continuo
  /// come per il dono sigillo del sogno"*.
  ///
  /// Adesso la nebbia si alza **tutta insieme**, in proporzione a quanto il
  /// dito si e' mosso, con la taratura del Sigillo del Sogno che vive in
  /// `RespiroCheDirada`.
  final double apertura;

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

  /// **CHE COSA C'E' SOTTO LA NEBBIA.**
  ///
  /// **DIFETTO VISTO SUL TELEFONO 767f596c IL 10 SETTEMBRE 2026.** I varchi
  /// aperti dalla mano erano **due buchi neri**: il ritaglio con
  /// `BlendMode.dstOut` toglieva nebbia e, non essendoci nessuno strato sotto
  /// di essa, toglieva la scena intera fino al nero della finestra. **Chi
  /// apriva la nebbia trovava il nulla.**
  ///
  /// Il mondo di sotto e' il fondo della galleria appena percorsa: il blu
  /// profondo in alto, il bruno delle radici in basso, e tre masse scure che
  /// sono il terreno. Non e' una scena da guardare, e' **cio' che il varco
  /// scopre**, e per questo basta che sia riconoscibile.
  void _ilMondoDiSotto(Canvas canvas, Size size) {
    final tutto = Offset.zero & size;
    canvas.drawRect(
      tutto,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            PittoreDelTunnel.bluProfondo,
            Color(0xFF2A1C12),
            PittoreDelTunnel.brunoDelleRadici,
          ],
          stops: [0.0, 0.55, 1.0],
        ).createShader(tutto),
    );
    // **IL TERRENO**, e ha un orlo.
    //
    // La prima stesura metteva tre ovali sfocati di ventisei: dentro il varco
    // si vedeva **una macchia**, non un posto. Con un orlo netto in mezzo alla
    // scena e le masse appena sfumate, chi apre la nebbia trova un sopra e un
    // sotto, che e' il minimo perche' un luogo sia un luogo.
    final orlo = size.height * 0.62;
    canvas.drawRect(
      Rect.fromLTRB(0, orlo, size.width, size.height),
      Paint()..color = const Color(0xFF160E08).withValues(alpha: 0.55),
    );
    for (var i = 0; i < 3; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * (0.22 + 0.30 * i),
              orlo - size.height * (0.02 + 0.05 * i)),
          width: size.width * (0.48 + 0.16 * i),
          height: size.height * (0.10 + 0.05 * i),
        ),
        Paint()
          ..color = const Color(0xFF0E0906).withValues(alpha: 0.55 + 0.12 * i)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final lato = size.longestSide;
    // **PRIMA IL MONDO, POI LA NEBBIA.** Vedi [_ilMondoDiSotto].
    _ilMondoDiSotto(canvas, size);
    // **LA NEBBIA VIVE IN UNO STRATO SUO**, cosi' il ritaglio del varco toglie
    // nebbia e **soltanto nebbia**: senza questo strato il ritaglio arrivava
    // fino al fondo della finestra e apriva un buco nero.
    canvas.saveLayer(Offset.zero & size, Paint());
    for (var s = 0; s < quantiStrati; s++) {
      final quota = (s + 1) / quantiStrati;
      final pittura = Paint()
        ..color = const Color(0xFF9FA8BF).withValues(
            alpha: (0.13 + 0.10 * quota) * densita * (1 - apertura))
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
    canvas.restore();
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
/// **IL PITTORE PROCEDURALE DELLE SAGOME E' USCITO DI SCENA.** Ordine DG,
/// 11 settembre 2026.
///
/// `PittoreDellAnimale` disegnava una figura scura **da un seme**: corpo,
/// quattro zampe, collo, testa. Serviva quando i dodici file delle ombre non
/// esistevano, e aveva il difetto di verita' che l'ordine DE aveva gia' tolto
/// dall'incontro: **faceva sempre un quadrupede**, e aquila, corvo, falco e
/// gufo non lo sono, e il serpente nemmeno.
///
/// Adesso le ombre sono dodici file veri in `assets/img/mondo_di_sotto`, presi
/// dal canale alpha delle dodici illustrazioni, e li mostra
/// `OmbraDellAnimale`. Un ripiego che nessuno vede e' codice morto.
