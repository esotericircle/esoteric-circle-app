import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../design_system/theme/maestro_palette.dart';

/// **IL SOFFIONE D'ORO INCISO, disegnato e non fotografato.** Ordine EF voce
/// 03, 23 settembre 2026.
///
/// **Il fatto del fondatore, verbatim**: *"il soffione fa cagare, addirittura
/// peggio di prima"*, e sulla cattura del momento del soffio si vede perche':
/// era una **fotografia** di un soffione vero, in mezzo a un'app incisa in
/// oro, con un alone scuro frastagliato attorno alla testa e lo stelo spezzato
/// da uno scalino a meta', dove due pezzi del ritaglio non combaciavano.
/// Messo davanti alla scelta, il fondatore ha chiesto **"Quello d'oro
/// inciso"**.
///
/// **E LA FOTOGRAFIA NON ERA SOLO BRUTTA: RENDEVA LA SCHERMATA CIECA ALLE
/// PROVE.** Il pittore della scena cominciava con `if (dandelion == null)
/// return;`, e sotto `flutter test` un asset PNG non si carica mai: **in ogni
/// prova di layout mai scritta su questa schermata il soffione semplicemente
/// non esisteva**. Nessuna guardia poteva accorgersi che un riquadro lo
/// copriva, perche' nella prova non c'era niente da coprire. Un disegno non
/// ha niente da caricare: da qui in poi **il soffione c'e' anche nelle
/// prove**, ed e' questa la vera ragione per cui la voce 03 viene prima della
/// voce 01.
///
/// **Perche' e' pubblico.** Stessa ragione di `FormaDelDono`, ordine DU voce
/// 14: una scena si misura solo se una prova la puo' dipingere da sola.
///
/// **Come si costruisce un soffione che si riconosca.** Non bastano dei raggi
/// che escono da un centro, quelli sono un sole. Un soffione e' fatto di
/// **pappi**: ognuno ha un gambo sottile e in cima un ombrellino di filamenti
/// che si aprono a ventaglio. E ha **volume**: i pappi partono da una sfera,
/// non da un disco, quindi quelli che puntano verso chi guarda si vedono
/// corti e quelli di taglio si vedono lunghi. Qui le direzioni si prendono
/// sulla sfera di Fibonacci e si proiettano, cosi' la testa e' una palla e non
/// una ruota.
abstract final class SoffioneInciso {
  /// Quanti pappi ha una testa piena.
  ///
  /// **Il numero non e' estetico soltanto.** Sotto i quaranta la testa si
  /// legge come un sole; sopra il centinaio i gambi si impastano in una
  /// macchia e l'incisione si perde. Sessantaquattro tiene il disegno
  /// leggibile e la testa piena.
  static const int pappi = 64;

  /// Quanti filamenti ha l'ombrellino in cima a ogni pappo.
  static const int filamenti = 5;

  /// Quanto e' lungo lo stelo rispetto al raggio della testa.
  ///
  /// **Corto abbastanza da lasciare respirare il riquadro sotto.** La voce 01
  /// pretende che niente copra il soffione nemmeno in parte, quindi tutto
  /// cio' che la figura occupa e' spazio tolto alla bolla descrittiva: uno
  /// stelo da manuale di botanica costerebbe alla bolla piu' di quanto rende
  /// al disegno. Il fondo dello stelo lo assorbe l'orizzonte della scena.
  static const double steloSuRaggio = 2.05;

  /// Quanto la figura sporge oltre il raggio dei gambi, per via degli
  /// ombrellini in cima a ogni pappo.
  ///
  /// **Serve a chi deve sapere dove finisce il soffione senza dipingerlo**, e
  /// in particolare alla guardia che pretende la quota di larghezza: misurare
  /// il solo raggio dei gambi direbbe una figura piu' piccola di quella che
  /// si vede.
  static const double sporgenzaDelPappo = 1.17;

  /// L'ingombro verticale del soffione intero, testa piu' stelo, dato il
  /// raggio della testa. Serve a chi deve sapere dove finisce la figura senza
  /// dipingerla.
  static double altezzaIntera(double raggio) => raggio + raggio * steloSuRaggio;

  /// La direzione e la profondita' del pappo [i], sulla sfera di Fibonacci.
  ///
  /// Torna il verso sul piano dello schermo e quanto il pappo punta verso chi
  /// guarda, da 0 di taglio a 1 in pieno viso. **Sta fuori da `dipingi`
  /// perche' una prova deve poter contare i pappi senza rasterizzare.**
  static ({Offset verso, double diFronte}) versoDelPappo(int i) {
    // Angolo aureo: la distribuzione piu' uniforme che esista su una sfera
    // senza cuciture ne' poli affollati.
    const aureo = math.pi * (3 - 2.23606797749979);
    final z = 1 - 2 * (i + 0.5) / pappi;
    final r = math.sqrt((1 - z * z).clamp(0.0, 1.0));
    final t = aureo * i;
    return (
      verso: Offset(math.cos(t) * r, math.sin(t) * r),
      diFronte: z.abs(),
    );
  }

  /// Dipinge il soffione.
  ///
  /// [centro] e' il centro della testa e [raggio] il suo raggio a schermo.
  /// [spoglio] va da zero, testa piena, a uno, testa vuota: e' quanto del
  /// soffio e' gia' stato fatto. [steloOpacita] spegne lo stelo alla fine del
  /// gesto, perche' un soffione soffiato via non lascia il suo gambo in
  /// primo piano. Con [fermo] i filamenti non ondeggiano.
  static void dipingi(
    Canvas canvas, {
    required Offset centro,
    required double raggio,
    required MaestroPalette palette,
    double? raggioDelloStelo,
    double spoglio = 0.0,
    double steloOpacita = 1.0,
    double aria = 0.0,
    bool fermo = false,
  }) {
    if (raggio <= 0) return;
    final via = spoglio.clamp(0.0, 1.0);

    if (steloOpacita > 0.01) {
      // **LO STELO NON RESPIRA.** Chi chiama puo' passargli il raggio a
      // riposo: la testa si gonfia e si sgonfia col fiato, il gambo no, o si
      // allungherebbe e accorcerebbe come un elastico a ogni inspirazione.
      _stelo(canvas, centro, raggioDelloStelo ?? raggio, palette, steloOpacita);
    }

    // L'alone: aria attorno alla testa, che tiene il soffione dentro la scena
    // invece di lasciarlo ritagliato sopra il cielo.
    if (via < 0.99) {
      final alone = raggio * 1.6;
      canvas.drawCircle(
        centro,
        alone,
        Paint()
          ..blendMode = BlendMode.plus
          ..shader = RadialGradient(
            colors: [
              palette.goldSoft.withValues(alpha: 0.13 * (1 - via)),
              palette.glow.withValues(alpha: 0.05 * (1 - via)),
              const Color(0x00000000),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(Rect.fromCircle(center: centro, radius: alone)),
      );
    }

    // **I PAPPI SE NE VANNO IN ORDINE SPARSO, non a fetta di torta.** Se il
    // criterio fosse l'indice, e gli indici stanno su una spirale, la testa si
    // svuoterebbe a spirale: si vedrebbe il disegno perdere i capelli invece
    // di disperdersi. Il numero mescolato da' un ordine stabile fra un
    // fotogramma e l'altro, perche' e' una funzione dell'indice e non un caso
    // estratto ogni volta.
    for (var i = 0; i < pappi; i++) {
      final quando = _quandoSeNeVa(i);
      if (via >= quando) continue;
      // Sul punto di partire il pappo sbianca appena: il distacco si vede.
      final vicino = ((quando - via) / 0.12).clamp(0.0, 1.0);
      _pappo(canvas, centro, raggio, i, palette, vicino, aria, fermo);
    }

    _ricettacolo(canvas, centro, raggio, palette, 1 - via);
  }

  /// A che punto del soffio se ne va il pappo [i], fra zero e 0,88.
  ///
  /// Mescolato con un moltiplicatore primo, cosi' due pappi vicini sulla
  /// spirale partono in momenti lontani.
  static double _quandoSeNeVa(int i) => (i * 37 % pappi) / pappi * 0.88;

  static void _pappo(
    Canvas canvas,
    Offset centro,
    double raggio,
    int i,
    MaestroPalette palette,
    double vicino,
    double aria,
    bool fermo,
  ) {
    final d = versoDelPappo(i);
    // Un pappo di taglio si vede per tutta la sua lunghezza, uno che punta
    // verso chi guarda si vede accorciato: e' la proiezione che da' la palla.
    final scorcio = 0.42 + 0.58 * (1 - d.diFronte);
    // L'onda dell'aria: lo stesso respiro che muove la scena, sfalsato pappo
    // per pappo, cosi' la testa vibra invece di pulsare tutta insieme.
    final onda =
        fermo ? 0.0 : math.sin(2 * math.pi * (aria + i / pappi * 0.7)) * 0.035;
    final lungo = raggio * scorcio * (1 + onda);
    final dentro = centro + d.verso * raggio * 0.11;
    final fuori = centro + d.verso * lungo;

    // I pappi che puntano verso chi guarda stanno davanti e sono piu' chiari:
    // e' la profondita', detta col colore invece che con una terza dimensione.
    final profondita = 0.55 + 0.45 * d.diFronte;
    final chiarore = (0.34 + 0.30 * profondita) * (0.55 + 0.45 * vicino);

    canvas.drawLine(
      dentro,
      fuori,
      Paint()
        ..strokeWidth = 0.7 + 0.5 * profondita
        ..strokeCap = StrokeCap.round
        ..color = palette.gold.withValues(alpha: chiarore.clamp(0.0, 1.0)),
    );

    // **L'OMBRELLINO, che e' cio' che fa di un raggio un pappo.** Filamenti
    // corti aperti a ventaglio attorno alla punta, nel verso del gambo.
    final angolo = math.atan2(d.verso.dy, d.verso.dx);
    final ombrello = raggio * 0.17 * scorcio;
    final filo = Paint()
      ..strokeWidth = 0.55
      ..strokeCap = StrokeCap.round
      ..color =
          palette.goldSoft.withValues(alpha: (chiarore * 0.85).clamp(0.0, 1.0));
    for (var f = 0; f < filamenti; f++) {
      final apertura = (f / (filamenti - 1) - 0.5) * 1.35;
      final a = angolo + apertura;
      canvas.drawLine(
        fuori,
        fuori + Offset(math.cos(a), math.sin(a)) * ombrello,
        filo,
      );
    }

    // Il nodo dove il gambo incontra l'ombrellino: il punto di luce che da'
    // l'incisione.
    canvas.drawCircle(
      fuori,
      (0.9 + 0.7 * profondita),
      Paint()
        ..color = palette.goldSoft
            .withValues(alpha: (0.75 * profondita).clamp(0.0, 1.0)),
    );
  }

  /// Il ricettacolo: il piccolo disco da cui partono tutti i pappi. Resta
  /// anche a testa vuota, perche' e' il fiore e non il seme.
  static void _ricettacolo(
    Canvas canvas,
    Offset centro,
    double raggio,
    MaestroPalette palette,
    double pieno,
  ) {
    final r = raggio * 0.115;
    canvas.drawCircle(
      centro,
      r * 2.1,
      Paint()
        ..blendMode = BlendMode.plus
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFF6DC).withValues(alpha: 0.30 + 0.35 * pieno),
            const Color(0x00FFF6DC),
          ],
        ).createShader(Rect.fromCircle(center: centro, radius: r * 2.1)),
    );
    canvas.drawCircle(
      centro,
      r,
      Paint()..color = palette.gold.withValues(alpha: 0.55 + 0.30 * pieno),
    );
    canvas.drawCircle(
      centro,
      r * 0.45,
      Paint()..color = const Color(0xFFFFF9E8).withValues(alpha: 0.85),
    );
  }

  /// Lo stelo, con la piega appena accennata di un gambo vero e le brattee
  /// sotto la testa.
  static void _stelo(
    Canvas canvas,
    Offset centro,
    double raggio,
    MaestroPalette palette,
    double opacita,
  ) {
    final lungo = raggio * steloSuRaggio;
    final cima = centro + Offset(0, raggio * 0.10);
    final fondo = cima + Offset(0, lungo);
    // **UNA CURVA SOLA, E LEGGERA.** Uno stelo dritto sembra un'asta, uno
    // piegato sembra rotto: e' esattamente il difetto che il fondatore ha
    // visto nella fotografia, dove il gambo aveva uno scalino a meta'.
    final piega = raggio * 0.11;
    final via = Path()
      ..moveTo(cima.dx, cima.dy)
      ..cubicTo(
        cima.dx + piega,
        cima.dy + lungo * 0.34,
        cima.dx - piega * 0.7,
        cima.dy + lungo * 0.70,
        fondo.dx,
        fondo.dy,
      );
    canvas.drawPath(
      via,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.4, raggio * 0.030)
        ..strokeCap = StrokeCap.round
        ..shader = ui.Gradient.linear(
          cima,
          fondo,
          [
            palette.gold.withValues(alpha: 0.95 * opacita),
            palette.gold.withValues(alpha: 0.42 * opacita),
          ],
        ),
    );
    // Le brattee: tre trattini che si piegano in giu' sotto la testa, come nel
    // fiore vero.
    final brattea = Paint()
      ..strokeWidth = math.max(0.8, raggio * 0.015)
      ..strokeCap = StrokeCap.round
      ..color = palette.gold.withValues(alpha: 0.55 * opacita);
    for (var i = -1; i <= 1; i++) {
      final a = math.pi / 2 + i * 0.55;
      canvas.drawLine(
        cima,
        cima + Offset(math.cos(a), math.sin(a)) * raggio * 0.26,
        brattea,
      );
    }
  }
}
