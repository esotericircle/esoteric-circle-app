import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'il_tunnel_che_scende.dart';

/// **IL BOSCO AL CREPUSCOLO, E IN MEZZO L'APERTURA NELLA TERRA.**
/// Ordine DC voce 21, forma rifatta il 10 settembre 2026.
///
/// **DA DOVE NASCE.** Il fondatore ha guardato la fotografia della soglia e ha
/// detto: *"l'utente e' gia' scappato prima ancora di leggere. Solo testo da
/// leggere, nessuna vena artistica, nessuna immagine o riquadro che metta in
/// evidenza o guidi l'utente. Niente di attraente a primo impatto, niente che
/// faccia capire di cosa si tratta a primo impatto."*
///
/// **PERCHE' DIPINTO E NON UNA FOTOGRAFIA.** Le famiglie grafiche di questo
/// progetto sono sei, e **nessuna e' un paesaggio**: ci sono i tarocchi, gli
/// angeli, le rune, i cristalli, i ritratti VIP e i dodici totem degli
/// animali. Un bosco non esiste, e generarne uno e' un lavoro di un altro
/// ordine. **Dipingerlo costa niente e non aspetta nessuno**, ed e' la stessa
/// mano del tunnel, della nebbia e dell'animale: la soglia non promette una
/// grafica che poi non arriva.
///
/// **E ANTICIPA CIO' CHE SI VEDRA' DAVVERO.** Il cielo parte dal blu profondo
/// del punto di fuga del tunnel e arriva al bruno delle radici, che sono
/// **gli stessi due colori** della galleria. Chi guarda la soglia sta gia'
/// guardando il Mondo di Sotto da fuori.
///
/// **LE MISURE, sotto la Regola I**, cioe' contate sui pixel dipinti e nella
/// finestra vera: il bosco **copre la scena intera**, i tronchi si contano
/// come **colonne scure distinte** e non come una macchia, e **l'apertura e'
/// il punto piu' chiaro della scena**.
class PittoreDelBosco extends CustomPainter {
  PittoreDelBosco({this.quantoRespira = 0});

  /// Da 0 a 1, e muove appena i piani lontani: **un bosco fermo e' un
  /// fondale, un bosco che respira e' un posto**. Con Riduci Movimento resta
  /// a zero e non si muove niente.
  final double quantoRespira;

  /// **IL BLU DEL CIELO FRA I TRONCHI**, che e' il blu del punto di fuga.
  static const Color cielo = PittoreDelTunnel.bluProfondo;

  /// **IL BRUNO DELLA TERRA**, che e' il bruno delle radici.
  static const Color terra = PittoreDelTunnel.brunoDelleRadici;

  /// **QUANTI TRONCHI, piano per piano.**
  ///
  /// Nove lontani, sei di mezzo, tre vicini. **Diciotto in tutto**, e sono la
  /// soglia sotto cui una fila di tronchi si legge come una staccionata
  /// invece che come un bosco: con meno di dodici l'occhio li conta.
  static const List<int> quantiPerPiano = [9, 6, 3];

  /// **DOVE STA L'APERTURA**, in frazione della scena.
  static const double apertoAX = 0.5;
  static const double apertoAY = 0.62;

  /// Quante colonne scure distinte deve poter contare una guardia.
  static int quantiTronchi() =>
      quantiPerPiano.fold(0, (a, b) => a + b);

  /// **DOVE STANNO I TRONCHI VICINI**, in frazione di larghezza.
  ///
  /// Ai lati e non al centro, **perche' il centro e' della luce**. La prima
  /// stesura li spargeva su tutta la scena e il chiarore dell'apertura
  /// finiva dietro un tronco: un bosco con la luce nascosta e' un bosco
  /// senza motivo di guardarlo.
  static const List<double> doveStannoIVicini = [0.07, 0.90, 0.70];

  @override
  void paint(Canvas canvas, Size size) {
    final tutto = Offset.zero & size;

    // **IL CIELO FRA I TRONCHI**, dal blu profondo al bruno delle radici.
    canvas.drawRect(
      tutto,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [cielo, Color(0xFF1B1330), Color(0xFF2E1E12), terra],
          stops: [0.0, 0.38, 0.72, 1.0],
        ).createShader(tutto),
    );

    // **PRIMA I LONTANI**, che stanno dentro la luce e ne escono in
    // controluce.
    _unPiano(canvas, size, 0);
    _unPiano(canvas, size, 1);

    // **POI L'APERTURA NELLA TERRA.**
    //
    // Sta **dopo** i piani lontani e **prima** dei vicini, ed e' tutto il
    // punto: cosi' i tronchi lontani ci si stagliano dentro e i vicini le
    // fanno da cornice. Nella prima stesura la luce era dipinta per prima e
    // finiva coperta da diciotto tronchi: c'era, e non si vedeva.
    final centro = Offset(size.width * apertoAX, size.height * apertoAY);
    final raggio = size.shortestSide * 0.78;
    canvas.drawCircle(
      centro,
      raggio,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFFBEFD2).withValues(alpha: 0.62),
          const Color(0xFFE0B478).withValues(alpha: 0.30),
          const Color(0xFF8A5E30).withValues(alpha: 0.10),
          Colors.transparent,
        ], stops: const [
          0.0,
          0.24,
          0.55,
          1.0
        ]).createShader(Rect.fromCircle(center: centro, radius: raggio)),
    );

    // **LA BOCCA VERA**, un ovale scuro dentro il chiarore: la luce non e'
    // un sole, e' un'apertura nella terra che ne lascia passare.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centro.dx, centro.dy + size.height * 0.10),
        width: size.width * 0.30,
        height: size.height * 0.14,
      ),
      Paint()
        ..color = const Color(0xFF120A06).withValues(alpha: 0.72)
        ..maskFilter = MaskFilter.blur(
            BlurStyle.normal, size.shortestSide * 0.035),
    );

    // **POI I VICINI**, che fanno da cornice e sono quasi neri.
    _unPiano(canvas, size, 2);

    // **LA NEBBIA BASSA**, che separa il bosco dalla terra ed e' insieme la
    // prima riga della fase che verra' dopo la discesa.
    for (var i = 0; i < 2; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * (0.35 + 0.3 * i), size.height * 0.82),
          width: size.width * (1.3 + 0.3 * i),
          height: size.height * 0.14,
        ),
        Paint()
          ..color = const Color(0xFFCBBDA2).withValues(alpha: 0.12 + 0.05 * i)
          ..maskFilter = MaskFilter.blur(
              BlurStyle.normal, size.shortestSide * 0.06),
      );
    }

    // **IL SUOLO**, e la luce ci si posa: senza il riflesso il chiarore
    // galleggia e non illumina niente.
    canvas.drawRect(
      Rect.fromLTRB(0, size.height * 0.86, size.width, size.height),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x00150D07), Color(0xCC120B06)],
        ).createShader(Rect.fromLTRB(
            0, size.height * 0.86, size.width, size.height)),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(centro.dx, size.height * 0.93),
        width: size.width * 0.62,
        height: size.height * 0.14,
      ),
      Paint()
        ..color = const Color(0xFFE0B478).withValues(alpha: 0.16)
        ..maskFilter = MaskFilter.blur(
            BlurStyle.normal, size.shortestSide * 0.07),
    );
  }

  void _unPiano(Canvas canvas, Size size, int piano) {
    final quanti = quantiPerPiano[piano];
    final vicinanza = piano / (quantiPerPiano.length - 1);
    final larghezza = size.width * (0.016 + 0.068 * vicinanza);
    // **UN TRONCO E' PIU' SCURO DEL CIELO CHE HA DIETRO, sempre.**
    //
    // La prima stesura schiariva il tronco verso la luce su tutta la sua
    // larghezza, e sull'anteprima dipinta i piani lontani si leggevano come
    // **colonne di luce** invece che come alberi: il bosco sembrava una
    // vetrata. Un controluce non schiarisce cio' che sta davanti, gli
    // accende il bordo.
    final tinta = Color.lerp(
        const Color(0xFF151B2E), const Color(0xFF04060A), vicinanza)!;
    final opacita = 0.62 + 0.36 * vicinanza;
    final cima = size.height * (0.08 - 0.08 * vicinanza);
    final piede = size.height * (0.88 + 0.12 * vicinanza);
    // **IL RESPIRO SPOSTA SOLO I PIANI LONTANI**, e di pochissimo: e' cio'
    // che gli occhi leggono come aria in mezzo agli alberi.
    final scorrimento = quantoRespira * size.width * 0.02 * (1 - vicinanza);

    final rnd = math.Random(1700 + piano);
    for (var i = 0; i < quanti; i++) {
      // Le posizioni sono deterministiche: lo stesso bosco a ogni apertura,
      // perche' un posto che cambia forma a ogni sguardo non e' un posto.
      final double t;
      if (piano == quantiPerPiano.length - 1) {
        t = doveStannoIVicini[i % doveStannoIVicini.length];
      } else {
        t = (i + 0.5) / quanti + (rnd.nextDouble() - 0.5) * (0.9 / quanti);
      }
      final x = size.width * t + scorrimento;
      // I tronchi non sono verticali: una pendenza piccola e diversa per
      // ognuno e' la differenza fra un bosco e una staccionata.
      final pendenza = (rnd.nextDouble() - 0.5) * size.width * 0.03;
      final w = larghezza * (0.72 + rnd.nextDouble() * 0.62);

      final tronco = Path()
        ..moveTo(x - w / 2 + pendenza, cima)
        ..lineTo(x + w / 2 + pendenza, cima)
        ..lineTo(x + w * 0.66, piede)
        ..lineTo(x - w * 0.66, piede)
        ..close();
      // **IL TRONCO NON E' UNA BANDA PIATTA.** Un filo di luce sul solo
      // bordo rivolto all'apertura, largo un decimo: e' cio' che lo fa
      // sembrare tondo senza disegnare niente di tondo, e senza schiarirlo.
      final versoLaLuce = x < size.width * apertoAX ? 1.0 : -1.0;
      canvas.drawPath(
        tronco,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment(-versoLaLuce, 0),
            end: Alignment(versoLaLuce, 0),
            colors: [
              tinta.withValues(alpha: opacita),
              tinta.withValues(alpha: opacita),
              Color.lerp(tinta, const Color(0xFFD6A868), 0.55)!
                  .withValues(alpha: opacita),
              tinta.withValues(alpha: opacita * 0.92),
            ],
            stops: const [0.0, 0.82, 0.94, 1.0],
          ).createShader(
              Rect.fromLTRB(x - w * 0.7, cima, x + w * 0.7, piede)),
      );

      // **DUE RAMI**, solo sul piano vicino: sui lontani sarebbero rumore.
      if (piano == quantiPerPiano.length - 1) {
        for (final verso in [-1.0, 1.0]) {
          final daY = cima + (piede - cima) * (0.10 + rnd.nextDouble() * 0.10);
          final lungo = size.width * (0.14 + rnd.nextDouble() * 0.10);
          // **I RAMI SONO TRATTI, non triangoli.** Chiusi in un cammino
          // pieno leggevano come cunei neri appesi in cima ai tronchi, e
          // l'anteprima li mostrava come uccelli.
          canvas.drawPath(
            Path()
              ..moveTo(x + pendenza, daY)
              ..quadraticBezierTo(
                  x + pendenza + verso * lungo * 0.55,
                  daY - size.height * 0.015,
                  x + pendenza + verso * lungo,
                  daY - size.height * 0.075),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeCap = StrokeCap.round
              ..strokeWidth = w * 0.22
              ..color = tinta.withValues(alpha: opacita * 0.92),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(PittoreDelBosco vecchio) =>
      vecchio.quantoRespira != quantoRespira;
}
