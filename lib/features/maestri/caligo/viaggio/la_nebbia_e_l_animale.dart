import 'dart:math' as math;

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

  /// **QUANTO OCCUPA L'ANIMALE IN PIENA LUCE, in frazione dell'ALTEZZA della
  /// scena in cui sta.**
  ///
  /// **SESSANTA, e la misura e' l'altezza perche' e' l'altezza che l'ordine
  /// nomina**: *"almeno il sessanta per cento dell'altezza utile dello
  /// schermo"*.
  ///
  /// **DUE STESURE SBAGLIATE PRIMA DI QUESTA, e vale la pena scriverle.** La
  /// prima diceva 0,65 pensando alla larghezza, e la guardia misuro'
  /// ottantotto per cento sui pixel. La seconda diceva 0,50 come frazione del
  /// **lato corto**: sul telefono 767f596c, il 10 settembre 2026, l'incontro
  /// metteva tre ombre in tre colonne affiancate, il lato corto di una
  /// colonna era un terzo di schermo, e le tre ombre **non si vedevano
  /// affatto**. Legare una misura al lato corto vuol dire lasciarla decidere
  /// dalla forma del contenitore invece che dall'occhio.
  ///
  /// **SESSANTADUE E NON SESSANTA, e non e' un arrotondamento di comodo.**
  /// Il sessanta dell'ordine e' un **pavimento**, e la griglia dei pixel toglie
  /// sempre qualcosa: una sagoma alta 173,4 punti su una scena di 289 si
  /// dipinge su 173 righe, cioe' 59,9 per cento. Chiedere esattamente il
  /// minimo vuol dire consegnare sotto il minimo. Si alza la grandezza
  /// dipinta, **mai la soglia della guardia**, che resta a sessanta.
  static const double quotaInPienaLuce = 0.62;

  /// **E QUANTO SE NE VEDE ALLA DISCESA [discesa].**
  ///
  /// Ordine DC voce 04: un'ombra che passa, di profilo che si allontana, ti
  /// guarda e non fugge, viene in piena luce.
  static double quotaAllaDiscesa(int discesa) {
    // Le tre quote prima della piena luce stanno sotto il sessanta per cento
    // di **larghezza dipinta** anche col fattore 1,35 del corpo: 0,38 per 1,35
    // fa 0,51, e la guardia lo verifica sui pixel invece che su questa riga.
    const quote = [0.26, 0.36, 0.46, quotaInPienaLuce];
    return quote[discesa.clamp(0, quote.length - 1)];
  }

  /// **LA LUCE DIETRO, che e' cio' che rende un controluce un controluce.**
  ///
  /// **DIFETTO VISTO SUL TELEFONO 767f596c IL 10 SETTEMBRE 2026**: l'incontro
  /// era **uno schermo vuoto**. Le tre sagome erano dipinte, ma di colore
  /// 0xFF07040D sopra il blu profondo della pagina, cioe' **nero su quasi
  /// nero**, e la guardia non poteva accorgersene perche' misurava il canale
  /// alfa su una tela trasparente: la sagoma c'era, e non si vedeva.
  ///
  /// Un controluce ha bisogno di due cose, e ne mancava una: la figura scura
  /// c'era, la luce dietro no.
  void _laLuceDietro(Canvas canvas, Size size) {
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
    // L'alone caldo alle spalle dell'animale: **piu' e' vicino alla piena
    // luce, piu' l'alone e' aperto**, e la sagoma si stacca.
    final raggio = size.shortestSide * (0.45 + 0.35 * quantaLuce);
    final dietro = Offset(size.width * 0.5, size.height * 0.46);
    canvas.drawCircle(
      dietro,
      raggio,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFF0DDB0).withValues(alpha: 0.34 + 0.34 * quantaLuce),
          const Color(0xFFB08A4E).withValues(alpha: 0.10),
          Colors.transparent,
        ], stops: const [
          0.0,
          0.55,
          1.0
        ]).createShader(Rect.fromCircle(center: dietro, radius: raggio)),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    // **PRIMA LA LUCE, POI L'OMBRA.** Vedi [_laLuceDietro].
    _laLuceDietro(canvas, size);
    final quota = quotaAllaDiscesa(discesa);
    final centro = size.center(Offset.zero);
    // **L'ALTEZZA COMANDA, e la larghezza la segue**: e' l'altezza che
    // l'ordine nomina. Se il corpo, largo un terzo in piu' dell'altezza, non
    // ci sta nella scena, si stringono tutte e due insieme invece di
    // schiacciare la sagoma.
    var alto = size.height * quota;
    var largo = alto * 1.35;
    final tetto = size.width * 0.94;
    if (largo > tetto) {
      alto = alto * tetto / largo;
      largo = tetto;
    }

    // **LA SAGOMA.** Un corpo, una testa, quattro zampe accennate: non serve
    // che sia un animale vero, serve che sia riconoscibile come **un** animale
    // e che due semi diversi diano due profili diversi.
    //
    // **SI DISEGNA IN UNITA' E POI SI PORTA ALLA MISURA VOLUTA.**
    //
    // Difetto misurato il 10 settembre 2026: la quota veniva applicata al
    // parametro `alto`, ma il dorso arrivava solo a `alto` per zero virgola
    // sei due, quindi **la sagoma dipinta era alta la meta' di quanto la
    // quota prometteva**: sessanta per cento chiesto, trentadue virgola nove
    // misurato sui pixel. E' la stessa famiglia di difetto del loto
    // dell'ordine DB: un numero che descrive la formula e non la forma.
    //
    // Disegnando in un quadrato di lato uno e portando poi **i limiti veri
    // del cammino** alla misura voluta, la quota torna a essere l'altezza che
    // si vede.
    final rnd = math.Random(seme);
    // **UN QUADRUPEDE DI PROFILO, non una collina con una testa sopra.**
    //
    // Difetto visto sulle anteprime dipinte il 10 settembre 2026. La prima
    // sagoma era un dorso a gobba chiuso in basso da una riga: sui pixel
    // misurava benissimo, e a guardarla era **una montagna con un
    // lecca-lecca**. Una guardia che conta i pixel scuri di una figura non
    // puo' dire se quella figura sembra un animale: quello lo dice solo
    // l'occhio, ed e' il motivo per cui le anteprime esistono.
    //
    // Un animale in controluce si riconosce da cinque cose, e ci sono tutte:
    // **la massa orizzontale del corpo**, **le quattro zampe che toccano
    // terra**, **il collo che sale**, **la testa col muso in avanti**, **la
    // coda**. Le orecchie sono la sesta e sono quella che distingue una lince
    // da un orso quando non si vede altro.
    //
    // **SI DISEGNA IN UNITA' E POI SI PORTA ALLA MISURA VOLUTA**, cosi' la
    // quota resta l'altezza che si vede: la stesura di prima applicava la
    // quota a un parametro che il disegno usava solo in parte, e prometteva
    // sessanta per cento dipingendone trentadue.
    const w = 1.35;
    final zampe = 0.24 + rnd.nextDouble() * 0.12;
    final spessore = 0.26 + rnd.nextDouble() * 0.10;
    final testaR = 0.10 + rnd.nextDouble() * 0.035;
    final orecchio = 0.05 + rnd.nextDouble() * 0.09;
    final coda = 0.08 + rnd.nextDouble() * 0.14;
    final pancia = 1 - zampe;
    final dorso = pancia - spessore;
    final testaCx = w - testaR * 1.25;
    final testaCy = dorso - testaR * 0.95 - orecchio * 0.35;

    final unitario = Path()..fillType = PathFillType.nonZero;
    // **IL CORPO**, una massa orizzontale con gli angoli tondi.
    unitario.addRRect(RRect.fromLTRBR(0.17, dorso, 0.99, pancia + 0.02,
        Radius.circular(spessore * 0.45)));
    // **LE QUATTRO ZAMPE**, che toccano terra: sono quelle a dire che sta in
    // piedi invece di essere una macchia.
    for (final x in [0.235, 0.375, 0.735, 0.875]) {
      unitario.addRect(Rect.fromLTRB(x, pancia - 0.03, x + 0.085, 1));
    }
    // **IL COLLO**, che sale dal corpo alla testa.
    unitario
      ..moveTo(0.83, dorso + 0.03)
      ..lineTo(testaCx - testaR * 0.9, testaCy + testaR * 0.5)
      ..lineTo(testaCx + testaR * 0.2, testaCy + testaR * 1.1)
      ..lineTo(0.97, dorso + spessore * 0.7)
      ..close();
    // **LA TESTA e IL MUSO IN AVANTI.**
    unitario
      ..addOval(Rect.fromCenter(
          center: Offset(testaCx, testaCy),
          width: testaR * 2.1,
          height: testaR * 1.9))
      ..addOval(Rect.fromCenter(
          center: Offset(testaCx + testaR * 0.9, testaCy + testaR * 0.35),
          width: testaR * 1.3,
          height: testaR * 0.9));
    // **LE ORECCHIE**, due, e sono la firma della specie.
    for (final dx in [-testaR * 0.55, testaR * 0.25]) {
      unitario
        ..moveTo(testaCx + dx, testaCy - testaR * 0.6)
        ..lineTo(testaCx + dx + testaR * 0.22, testaCy - testaR * 0.6 -
            orecchio)
        ..lineTo(testaCx + dx + testaR * 0.5, testaCy - testaR * 0.5)
        ..close();
    }
    // **LA CODA.**
    unitario
      ..moveTo(0.19, dorso + spessore * 0.25)
      ..lineTo(0.19 - coda, dorso - 0.02)
      ..lineTo(0.19 - coda * 0.85, dorso + 0.07)
      ..lineTo(0.22, dorso + spessore * 0.55)
      ..close();

    // I limiti veri del cammino, che sono cio' che si vede.
    final limiti = unitario.getBounds();
    final fattoreX = largo / limiti.width;
    final fattoreY = alto / limiti.height;
    final spostaX = centro.dx - largo / 2 - limiti.left * fattoreX;
    final spostaY = centro.dy - alto / 2 - limiti.top * fattoreY;
    final porta = Matrix4.identity()
      ..translateByDouble(spostaX, spostaY, 0, 1)
      ..scaleByDouble(fattoreX, fattoreY, 1, 1);
    final corpo = unitario.transform(porta.storage);

    canvas.drawPath(
      corpo,
      Paint()
        // **QUASI OPACA E NON NOVANTADUE.** Un controluce e' una figura
        // **nera**: col nove per cento di alone che trapassava, il colmo del
        // dorso, che sta proprio sopra la luce, si schiariva abbastanza da
        // non leggersi piu' come sagoma, e la misura sui pixel ne perdeva
        // trenta su centosettantatre.
        ..color = const Color(0xFF07040D).withValues(alpha: 0.985)
        // **LA SFOCATURA E' PROPORZIONALE ALLA SAGOMA, non in pixel fissi.**
        //
        // Difetto visto sul telefono 767f596c il 10 settembre 2026, nella
        // casella dell'Animale nel Passaporto: sei pixel di sfocatura su una
        // scena larga trecentonovanta sono un velo, **sugli stessi sei pixel
        // dentro un tondo da cinquantadue la sagoma sparisce del tutto**, e
        // la casella mostrava una macchia bruna. Una misura assoluta dentro
        // un disegno che si scala e' una misura che vale in un posto solo.
        ..maskFilter = MaskFilter.blur(
            BlurStyle.normal, alto * (1 - quantaLuce) * 0.06 + 0.5),
    );

    // **GLI OCCHI CHE RIFLETTONO**, che sono la cosa che lo rende vivo e che
    // si vede anche quando tutto il resto e' un'ombra. Passano per la stessa
    // trasformazione della sagoma, altrimenti finirebbero fuori dalla testa.
    final testaX = testaCx * fattoreX + spostaX;
    final testaY = testaCy * fattoreY + spostaY;
    //
    // **UNO SOLO, perche' di profilo se ne vede uno.** Due occhi affiancati
    // sulla stessa testa la fanno leggere di fronte, e allora la sagoma non e'
    // piu' un animale di passaggio, e' una faccia.
    final occhio = alto * 0.022;
    canvas.drawCircle(
      Offset(testaX + occhio * 0.6, testaY - occhio * 0.2),
      occhio,
      Paint()
        ..color = const Color(0xFFE8D9A8)
            .withValues(alpha: 0.55 + 0.40 * quantaLuce),
    );
  }

  @override
  bool shouldRepaint(PittoreDellAnimale vecchio) =>
      vecchio.discesa != discesa ||
      vecchio.quantaLuce != quantaLuce ||
      vecchio.seme != seme;
}
