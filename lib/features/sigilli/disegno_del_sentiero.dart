import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/sigilli/sentieri.dart';
import '../../design_system/theme/maestro_scope.dart';

/// IL DISEGNO DEI TRE SENTIERI, ordine P voce 33.
///
/// **Il fatto che ha aperto la voce.** `sentiero_screen.dart` montava un
/// `ListView.builder` di `ListTile` con le icone di serie del framework, e i
/// tre sentieri si distinguevano per due cose sole: la palette del Maestro e
/// lo stesso `CosmosBackground(seed: 19)`, cioe' lo stesso campo di stelle
/// soltanto tinto. Nel file non esisteva nessun `CustomPainter`. La sezione 13
/// del Briefing di Progetto non era costruita: i file di dati dei 55 traguardi
/// c'erano, il disegno no.
///
/// **Cosa disegna, e perche' tre disegni e non uno ricolorato.**
///
///   - COSTELLAZIONE DI MEDORA. Ogni mini e' una stella; le stelle accese si
///     uniscono con una linea luminosa; ogni dieci stelle la figura si chiude
///     in una Costellazione, che e' il grande. Le stelle spente esistono nel
///     disegno, in trasparenza, cosi' si vede la forma che manca.
///   - ALBERO DELLA VITA DI CALIGO. Ogni mini e' un frutto su un ramo; i
///     cinque grandi sono le Sefirot che si accendono salendo, fino a Keter
///     come cinquantesimo. Rami e sentieri si vedono anche a frutti spenti.
///   - FIORE DI LOTO DI AURA. Ogni mini e' un petalo che si apre lungo lo
///     stelo; i cinque grandi sono le Fioriture, cinque livelli di apertura.
///     I petali chiusi si vedono.
///
/// **Una geometria sola per il disegno e per il tocco.** I punti si calcolano
/// qui una volta e li leggono sia il pittore sia il riconoscimento del tocco:
/// se fossero due elenchi, prima o poi il tocco cadrebbe accanto alla stella
/// invece che su di lei, e nessuno saprebbe dire quale dei due ha ragione.
class GeometriaDelSentiero {
  const GeometriaDelSentiero._();

  /// I punti del disegno, in coordinate normalizzate fra 0 e 1.
  ///
  /// Deterministici e senza caso: un disegno che cambia a ogni montaggio non
  /// si puo' provare a pixel, e soprattutto non e' piu' il TUO cammino.
  static List<PuntoDelSentiero> punti(Sentiero sentiero) =>
      switch (sentiero) {
        Sentiero.costellazione => _costellazione(),
        Sentiero.albero => _albero(),
        Sentiero.loto => _loto(),
      };

  /// I cinque centri delle figure della costellazione: cinque gruppi da dieci
  /// stelle, sparsi come si sparge un cielo e non allineati come un elenco.
  static const List<Offset> centriDelleFigure = [
    Offset(0.27, 0.18),
    Offset(0.73, 0.30),
    Offset(0.28, 0.53),
    Offset(0.74, 0.72),
    Offset(0.46, 0.88),
  ];

  static List<PuntoDelSentiero> _costellazione() {
    final mini = Sentieri.miniDi(Sentiero.costellazione);
    final grandi = Sentieri.grandiDi(Sentiero.costellazione);
    final punti = <PuntoDelSentiero>[];
    for (var figura = 0; figura < 5; figura++) {
      final centro = centriDelleFigure[figura];
      for (var k = 0; k < 10; k++) {
        final indice = figura * 10 + k;
        // L'irregolarita' e' calcolata, non estratta: una figura perfettamente
        // circolare non somiglia a nessuna costellazione vera.
        final angolo = 2 * math.pi * k / 10 + figura * 0.37;
        final raggio = 0.105 * (0.58 + 0.42 * math.sin(k * (figura + 2) + 1.1));
        punti.add(PuntoDelSentiero(
          traguardo: mini[indice],
          dove: Offset(
            centro.dx + raggio * math.cos(angolo) * 1.15,
            centro.dy + raggio * math.sin(angolo),
          ),
          raggio: 0.0135,
          gruppo: figura,
        ));
      }
      punti.add(PuntoDelSentiero(
        traguardo: grandi[figura],
        dove: centro,
        raggio: 0.030,
        gruppo: figura,
      ));
    }
    return punti;
  }

  /// Le cinque Sefirot Maggiori sul pilastro centrale, dal Regno alla Corona.
  static const List<double> altezzeDelleSefirot = [0.86, 0.68, 0.50, 0.30, 0.10];

  static List<PuntoDelSentiero> _albero() {
    final mini = Sentieri.miniDi(Sentiero.albero);
    final grandi = Sentieri.grandiDi(Sentiero.albero);
    final punti = <PuntoDelSentiero>[];
    for (var ramo = 0; ramo < 5; ramo++) {
      final base = ramo == 0 ? 0.99 : altezzeDelleSefirot[ramo - 1];
      final cima = altezzeDelleSefirot[ramo];
      for (var k = 0; k < 10; k++) {
        final indice = ramo * 10 + k;
        final t = (k + 1) / 11;
        // I frutti si alternano ai due lati del tronco, e piu' si sale piu'
        // il ramo si accorcia: un albero si stringe verso la cima.
        final lato = k.isEven ? -1.0 : 1.0;
        final apertura = (0.11 + 0.19 * math.sin(math.pi * t)) *
            (1.0 - 0.32 * ramo / 4);
        punti.add(PuntoDelSentiero(
          traguardo: mini[indice],
          dove: Offset(0.5 + lato * apertura, base + (cima - base) * t),
          raggio: 0.011,
          gruppo: ramo,
        ));
      }
      punti.add(PuntoDelSentiero(
        traguardo: grandi[ramo],
        dove: Offset(0.5, cima),
        raggio: 0.028,
        gruppo: ramo,
      ));
    }
    return punti;
  }

  /// Il cuore del loto e i raggi delle cinque corone di petali.
  static const Offset cuoreDelLoto = Offset(0.5, 0.44);
  static const List<double> raggiDelLoto = [0.095, 0.155, 0.215, 0.275, 0.335];

  static List<PuntoDelSentiero> _loto() {
    final mini = Sentieri.miniDi(Sentiero.loto);
    final grandi = Sentieri.grandiDi(Sentiero.loto);
    final punti = <PuntoDelSentiero>[];
    for (var corona = 0; corona < 5; corona++) {
      final raggio = raggiDelLoto[corona];
      for (var k = 0; k < 10; k++) {
        final indice = corona * 10 + k;
        // Ogni corona e' ruotata rispetto alla precedente, cosi' i petali si
        // incastrano invece di sovrapporsi in raggi dritti.
        final angolo = 2 * math.pi * k / 10 + corona * 0.314 - math.pi / 2;
        punti.add(PuntoDelSentiero(
          traguardo: mini[indice],
          dove: Offset(
            cuoreDelLoto.dx + raggio * math.cos(angolo),
            cuoreDelLoto.dy + raggio * math.sin(angolo) * 0.92,
          ),
          raggio: 0.013,
          angolo: angolo,
          gruppo: corona,
        ));
      }
      // LA FIORITURA HA LA SUA DIREZIONE, una per corona.
      //
      // **Erano tutte e cinque in cima.** Con l'angolo fisso a -pi/2 le cinque
      // Fioriture si impilavano una sull'altra sopra il cuore e formavano una
      // torre di losanghe che sbilanciava il fiore e copriva i petali della
      // corona piu' alta: si vede nell'anteprima, non nel codice. Distribuite
      // sui cinque quinti del giro, ognuna e' il petalo grande della sua
      // direzione e il fiore resta in equilibrio.
      final direzione = -math.pi / 2 + corona * 2 * math.pi / 5;
      final quanto = raggio * 1.05;
      punti.add(PuntoDelSentiero(
        traguardo: grandi[corona],
        dove: Offset(
          cuoreDelLoto.dx + quanto * math.cos(direzione),
          cuoreDelLoto.dy + quanto * math.sin(direzione) * 0.92,
        ),
        raggio: 0.024,
        angolo: direzione,
        gruppo: corona,
      ));
    }
    return punti;
  }
}

/// UN PUNTO DEL DISEGNO: una stella, un frutto, un petalo.
class PuntoDelSentiero {
  const PuntoDelSentiero({
    required this.traguardo,
    required this.dove,
    required this.raggio,
    required this.gruppo,
    this.angolo = 0,
  });

  final Traguardo traguardo;

  /// Dove sta, fra 0 e 1 sui due lati della tela.
  final Offset dove;

  /// Quanto e' grande, in frazione del lato corto della tela.
  final double raggio;

  /// Verso dove punta, per i petali del loto.
  final double angolo;

  /// A quale dei cinque gruppi appartiene: la figura, il ramo, la corona.
  final int gruppo;

  bool get eGrande => traguardo.eGrande;
}

/// IL DISEGNO A SCHERMO, con i suoi punti toccabili.
class DisegnoDelSentiero extends StatelessWidget {
  const DisegnoDelSentiero({
    super.key,
    required this.sentiero,
    required this.accesi,
    this.evidenziato,
    this.suTocco,
  });

  final Sentiero sentiero;

  /// Gli identificativi dei traguardi gia' accesi.
  final Set<String> accesi;

  /// Il traguardo che l'elenco sta evidenziando: il disegno gli mette attorno
  /// un alone, cosi' elenco e disegno si parlano nei due versi.
  final String? evidenziato;

  /// Toccando un punto si va al suo traguardo.
  final void Function(Traguardo traguardo)? suTocco;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final punti = GeometriaDelSentiero.punti(sentiero);
    return LayoutBuilder(
      builder: (context, vincoli) {
        final misura = Size(vincoli.maxWidth, vincoli.maxHeight);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: suTocco == null
              ? null
              : (dettaglio) {
                  final tocco = dettaglio.localPosition;
                  final corto = math.min(misura.width, misura.height);
                  PuntoDelSentiero? vicino;
                  var minima = double.infinity;
                  for (final punto in punti) {
                    final centro = Offset(punto.dove.dx * misura.width,
                        punto.dove.dy * misura.height);
                    final distanza = (centro - tocco).distance;
                    if (distanza < minima) {
                      minima = distanza;
                      vicino = punto;
                    }
                  }
                  // La zona toccabile e' piu' larga del disegno: un punto da
                  // undici millesimi di tela e' piu' piccolo di un polpastrello,
                  // e un bersaglio che non si prende non e' un bersaglio.
                  if (vicino != null && minima <= corto * 0.055) {
                    suTocco!(vicino.traguardo);
                  }
                },
          child: CustomPaint(
            key: Key('disegno_${sentiero.name}'),
            size: Size.infinite,
            painter: switch (sentiero) {
              Sentiero.costellazione => PittoreDellaCostellazione(
                  punti: punti,
                  accesi: accesi,
                  evidenziato: evidenziato,
                  oro: palette.gold,
                  oroTenue: palette.goldSoft,
                ),
              Sentiero.albero => PittoreDellAlbero(
                  punti: punti,
                  accesi: accesi,
                  evidenziato: evidenziato,
                  oro: palette.gold,
                  oroTenue: palette.goldSoft,
                ),
              Sentiero.loto => PittoreDelLoto(
                  punti: punti,
                  accesi: accesi,
                  evidenziato: evidenziato,
                  oro: palette.gold,
                  oroTenue: palette.goldSoft,
                ),
            },
          ),
        );
      },
    );
  }
}

/// La parte comune ai tre pittori: cosa e' acceso, con che oro si dipinge.
abstract class _PittoreDelSentiero extends CustomPainter {
  const _PittoreDelSentiero({
    required this.punti,
    required this.accesi,
    required this.evidenziato,
    required this.oro,
    required this.oroTenue,
  });

  final List<PuntoDelSentiero> punti;
  final Set<String> accesi;
  final String? evidenziato;
  final Color oro;
  final Color oroTenue;

  bool acceso(PuntoDelSentiero p) => accesi.contains(p.traguardo.id);

  Offset assoluto(PuntoDelSentiero p, Size s) =>
      Offset(p.dove.dx * s.width, p.dove.dy * s.height);

  double corto(Size s) => math.min(s.width, s.height);

  /// L'ALONE del punto che l'elenco sta evidenziando: e' il modo in cui il
  /// traguardo scelto nell'elenco si fa riconoscere dentro il disegno.
  void alone(Canvas tela, Offset centro, double raggio) {
    tela.drawCircle(
      centro,
      raggio * 2.6,
      Paint()
        ..color = oro.withValues(alpha: 0.28)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, raggio * 1.4),
    );
  }

  @override
  bool shouldRepaint(covariant _PittoreDelSentiero vecchio) =>
      vecchio.accesi.length != accesi.length ||
      vecchio.evidenziato != evidenziato ||
      vecchio.oro != oro;
}

/// LA COSTELLAZIONE DI MEDORA: stelle che si uniscono in figure.
class PittoreDellaCostellazione extends _PittoreDelSentiero {
  const PittoreDellaCostellazione({
    required super.punti,
    required super.accesi,
    required super.evidenziato,
    required super.oro,
    required super.oroTenue,
  });

  @override
  void paint(Canvas tela, Size misura) {
    final c = corto(misura);
    final perGruppo = <int, List<PuntoDelSentiero>>{};
    for (final p in punti.where((p) => !p.eGrande)) {
      perGruppo.putIfAbsent(p.gruppo, () => []).add(p);
    }

    // 1. LA FORMA CHE MANCA, sempre visibile: il filo tenue che chiude ogni
    // figura anche quando nessuna delle sue stelle e' accesa. Senza questo
    // non si vedrebbe dove si sta andando, e un cammino di cui non si vede la
    // meta non e' un cammino.
    final tenue = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = c * 0.0032
      ..color = oroTenue.withValues(alpha: 0.40);
    for (final gruppo in perGruppo.values) {
      final via = Path()..moveTo(assoluto(gruppo.first, misura).dx,
          assoluto(gruppo.first, misura).dy);
      for (final p in gruppo.skip(1)) {
        final a = assoluto(p, misura);
        via.lineTo(a.dx, a.dy);
      }
      via.close();
      tela.drawPath(via, tenue);
    }

    // 2. LA LINEA LUMINOSA fra le stelle accese consecutive: e' il tratto che
    // la persona ha davvero percorso.
    final viva = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = c * 0.0042
      ..strokeCap = StrokeCap.round
      ..color = oro.withValues(alpha: 0.85);
    for (final gruppo in perGruppo.values) {
      for (var i = 0; i < gruppo.length - 1; i++) {
        if (!acceso(gruppo[i]) || !acceso(gruppo[i + 1])) continue;
        tela.drawLine(
            assoluto(gruppo[i], misura), assoluto(gruppo[i + 1], misura), viva);
      }
    }

    // 3. LE STELLE. Le spente ci sono, in trasparenza: e' la forma che manca.
    for (final p in punti.where((p) => !p.eGrande)) {
      final centro = assoluto(p, misura);
      final r = p.raggio * c;
      if (p.traguardo.id == evidenziato) alone(tela, centro, r);
      if (acceso(p)) {
        tela.drawCircle(
            centro,
            r * 2.2,
            Paint()
              ..color = oro.withValues(alpha: 0.30)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, r));
        tela.drawCircle(centro, r, Paint()..color = Colors.white);
        // I quattro raggi: una stella accesa non e' un pallino.
        final raggio = Paint()
          ..strokeWidth = c * 0.0018
          ..color = oro.withValues(alpha: 0.9);
        tela.drawLine(centro.translate(-r * 2.6, 0),
            centro.translate(r * 2.6, 0), raggio);
        tela.drawLine(centro.translate(0, -r * 2.6),
            centro.translate(0, r * 2.6), raggio);
      } else {
        tela.drawCircle(
            centro,
            r * 0.84,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = c * 0.0026
              ..color = oroTenue.withValues(alpha: 0.66));
      }
    }

    // 4. LE CINQUE COSTELLAZIONI: il grande al centro della sua figura.
    for (final p in punti.where((p) => p.eGrande)) {
      final centro = assoluto(p, misura);
      final r = p.raggio * c;
      if (p.traguardo.id == evidenziato) alone(tela, centro, r);
      final punte = Path();
      for (var i = 0; i < 10; i++) {
        final ang = -math.pi / 2 + math.pi * i / 5;
        final lungo = i.isEven ? r : r * 0.42;
        final punto = Offset(
            centro.dx + lungo * math.cos(ang), centro.dy + lungo * math.sin(ang));
        i == 0 ? punte.moveTo(punto.dx, punto.dy) : punte.lineTo(punto.dx, punto.dy);
      }
      punte.close();
      if (acceso(p)) {
        tela.drawPath(
            punte,
            Paint()
              ..color = oro
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.5));
        tela.drawPath(punte, Paint()..color = Colors.white.withValues(alpha: 0.92));
      } else {
        tela.drawPath(
            punte,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = c * 0.0034
              ..color = oroTenue.withValues(alpha: 0.62));
      }
    }
  }
}

/// L'ALBERO DELLA VITA DI CALIGO: rami, frutti e Sefirot che salgono.
class PittoreDellAlbero extends _PittoreDelSentiero {
  const PittoreDellAlbero({
    required super.punti,
    required super.accesi,
    required super.evidenziato,
    required super.oro,
    required super.oroTenue,
  });

  @override
  void paint(Canvas tela, Size misura) {
    final c = corto(misura);

    final asse = misura.width * 0.5;

    // 1. IL TRONCO, sempre visibile: si assottiglia salendo, come un tronco.
    //
    // **Era una tavola.** Nella prima stesura andava da 0,020 a 0,005 del lato
    // corto e a schermo si leggeva come un rettangolo pieno tagliato di netto
    // in basso: l'anteprima lo ha mostrato. Adesso e' un pilastro sottile che
    // esce dal bordo, e le Sefirot si leggono sopra invece che dentro.
    final tronco = Path()..moveTo(asse - c * 0.011, misura.height * 1.02);
    tronco
      ..lineTo(asse - c * 0.0028, misura.height * 0.05)
      ..lineTo(asse + c * 0.0028, misura.height * 0.05)
      ..lineTo(asse + c * 0.011, misura.height * 1.02)
      ..close();
    tela.drawPath(tronco, Paint()..color = oroTenue.withValues(alpha: 0.46));

    // 1b. I SENTIERI FRA LE SEFIROT, che l'ordine chiede espressamente
    // ("i rami e i sentieri fra le Sefirot si vedono anche quando i frutti
    // sono spenti"): due archi laterali per ogni coppia, cioe' i due pilastri
    // esterni dell'Albero, sempre visibili.
    final grandi = punti.where((p) => p.eGrande).toList()
      ..sort((a, b) => b.dove.dy.compareTo(a.dove.dy));
    for (var i = 0; i < grandi.length - 1; i++) {
      final basso = assoluto(grandi[i], misura);
      final alto = assoluto(grandi[i + 1], misura);
      final ampiezza = c * (0.20 - 0.028 * i);
      for (final lato in const [-1.0, 1.0]) {
        final sentiero = Path()
          ..moveTo(basso.dx, basso.dy)
          ..quadraticBezierTo(
            basso.dx + lato * ampiezza,
            (basso.dy + alto.dy) / 2,
            alto.dx,
            alto.dy,
          );
        tela.drawPath(
            sentiero,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = c * 0.0026
              ..color = (acceso(grandi[i]) && acceso(grandi[i + 1]))
                  ? oro.withValues(alpha: 0.72)
                  : oroTenue.withValues(alpha: 0.40));
      }
    }

    // 2. I RAMI, uno per frutto, e si vedono anche a frutto spento: e' la
    // struttura dell'Albero, non la ricompensa.
    for (final p in punti.where((p) => !p.eGrande)) {
      final meta = assoluto(p, misura);
      final attacco = Offset(asse, meta.dy + c * 0.045);
      final ramo = Path()
        ..moveTo(attacco.dx, attacco.dy)
        ..quadraticBezierTo(
            (attacco.dx + meta.dx) / 2, attacco.dy - c * 0.012, meta.dx, meta.dy);
      tela.drawPath(
          ramo,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = c * (acceso(p) ? 0.0042 : 0.0030)
            ..strokeCap = StrokeCap.round
            ..color = acceso(p)
                ? oro.withValues(alpha: 0.80)
                : oroTenue.withValues(alpha: 0.46));
    }

    // 3. I FRUTTI.
    for (final p in punti.where((p) => !p.eGrande)) {
      final centro = assoluto(p, misura);
      final r = p.raggio * c;
      if (p.traguardo.id == evidenziato) alone(tela, centro, r);
      if (acceso(p)) {
        tela.drawCircle(
            centro,
            r * 2.0,
            Paint()
              ..color = oro.withValues(alpha: 0.26)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, r));
        tela.drawCircle(centro, r, Paint()..color = oro);
        tela.drawCircle(centro.translate(-r * 0.3, -r * 0.3), r * 0.34,
            Paint()..color = Colors.white.withValues(alpha: 0.8));
      } else {
        tela.drawCircle(
            centro,
            r * 0.86,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = c * 0.0026
              ..color = oroTenue.withValues(alpha: 0.66));
      }
    }

    // 4. LE CINQUE SEFIROT sul pilastro, fino a Keter in cima.
    for (final p in punti.where((p) => p.eGrande)) {
      final centro = assoluto(p, misura);
      final r = p.raggio * c;
      if (p.traguardo.id == evidenziato) alone(tela, centro, r);
      if (acceso(p)) {
        tela.drawCircle(
            centro,
            r * 1.9,
            Paint()
              ..color = oro.withValues(alpha: 0.30)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.9));
        tela.drawCircle(centro, r, Paint()..color = oro);
        tela.drawCircle(
            centro,
            r * 0.58,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = c * 0.0028
              ..color = Colors.white.withValues(alpha: 0.85));
      } else {
        tela.drawCircle(
            centro,
            r,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = c * 0.0040
              ..color = oroTenue.withValues(alpha: 0.68));
      }
    }
  }
}

/// IL FIORE DI LOTO DI AURA: lo stelo, le corone di petali, le Fioriture.
class PittoreDelLoto extends _PittoreDelSentiero {
  const PittoreDelLoto({
    required super.punti,
    required super.accesi,
    required super.evidenziato,
    required super.oro,
    required super.oroTenue,
  });

  /// UN PETALO, ordine P voce 33.
  ///
  /// **La prima stesura non era un loto.** Tutti i petali partivano dal cuore
  /// e la loro lunghezza cresceva con la corona: le corone esterne uscivano
  /// dalla tela e si accavallavano, e a schermo si vedeva un groviglio di
  /// raggi, non un fiore. L'anteprima lo ha mostrato, la lettura del codice
  /// no.
  ///
  /// **Come si costruisce un loto.** Ogni corona di petali PARTE dove finisce
  /// la precedente, non dal cuore: petali corti e larghi, che si sovrappongono
  /// come le squame di un fiore vero. Aperto quando il traguardo e' raggiunto,
  /// stretto e piu' corto quando non lo e' ancora, perche' **i petali chiusi
  /// si vedono**: sono la parte di loto che deve ancora aprirsi.
  Path _petalo(
    Offset cuore,
    double da,
    double a,
    double largo,
    double angolo,
  ) {
    final base = Offset(
        cuore.dx + da * math.cos(angolo), cuore.dy + da * math.sin(angolo) * 0.92);
    final punta = Offset(
        cuore.dx + a * math.cos(angolo), cuore.dy + a * math.sin(angolo) * 0.92);
    final normale = angolo + math.pi / 2;
    final fianco = Offset(largo * math.cos(normale), largo * math.sin(normale));
    final meta = Offset((base.dx + punta.dx) / 2, (base.dy + punta.dy) / 2);
    return Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(
          meta.dx + fianco.dx, meta.dy + fianco.dy, punta.dx, punta.dy)
      ..quadraticBezierTo(
          meta.dx - fianco.dx, meta.dy - fianco.dy, base.dx, base.dy)
      ..close();
  }

  @override
  void paint(Canvas tela, Size misura) {
    final c = corto(misura);
    final cuore = Offset(GeometriaDelSentiero.cuoreDelLoto.dx * misura.width,
        GeometriaDelSentiero.cuoreDelLoto.dy * misura.height);

    double raggioDi(int corona) => GeometriaDelSentiero.raggiDelLoto[corona] * c;
    double partenzaDi(int corona) =>
        corona == 0 ? c * 0.030 : raggioDi(corona - 1) * 0.86;

    // 1. LO STELO, sempre visibile: il loto non galleggia da solo.
    final stelo = Path()
      ..moveTo(cuore.dx, misura.height)
      ..quadraticBezierTo(
          cuore.dx + c * 0.06, misura.height * 0.78, cuore.dx, cuore.dy);
    tela.drawPath(
        stelo,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = c * 0.010
          ..strokeCap = StrokeCap.round
          ..color = oroTenue.withValues(alpha: 0.50));

    // 2. I PETALI, dalla corona piu' esterna verso il cuore, cosi' i vicini
    // coprono i lontani come in un fiore vero.
    final mini = punti.where((p) => !p.eGrande).toList()
      ..sort((a, b) => b.gruppo.compareTo(a.gruppo));
    for (final p in mini) {
      final aperto = acceso(p);
      final da = partenzaDi(p.gruppo);
      final a = raggioDi(p.gruppo) * (aperto ? 1.0 : 0.84);
      final largo = (a - da) * (aperto ? 0.62 : 0.34);
      final via = _petalo(cuore, da, a, largo, p.angolo);
      if (aperto) {
        tela.drawPath(via, Paint()..color = oro.withValues(alpha: 0.30));
        tela.drawPath(
            via,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = c * 0.0030
              ..color = oro.withValues(alpha: 0.95));
      } else {
        tela.drawPath(
            via,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = c * 0.0026
              ..color = oroTenue.withValues(alpha: 0.58));
      }
      if (p.traguardo.id == evidenziato) {
        alone(tela, assoluto(p, misura), p.raggio * c);
      }
    }

    // 3. LE CINQUE FIORITURE: un petalo piu' grande in cima alla sua corona,
    // e non piu' un anello geometrico intero. L'anello tagliava il fiore da
    // parte a parte e si leggeva come una circonferenza, non come un livello
    // di apertura.
    for (final p in punti.where((p) => p.eGrande)) {
      final centro = assoluto(p, misura);
      final r = p.raggio * c;
      if (p.traguardo.id == evidenziato) alone(tela, centro, r);
      final da = partenzaDi(p.gruppo);
      final a = raggioDi(p.gruppo) * 1.05;
      final via = _petalo(cuore, da, a, (a - da) * 0.44, p.angolo);
      if (acceso(p)) {
        tela.drawPath(via, Paint()..color = oro.withValues(alpha: 0.42));
        tela.drawPath(
            via,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = c * 0.0044
              ..color = Colors.white.withValues(alpha: 0.90));
      } else {
        tela.drawPath(
            via,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = c * 0.0036
              ..color = oroTenue.withValues(alpha: 0.64));
      }
    }

    // 4. IL CUORE del fiore, sempre.
    tela.drawCircle(
        cuore, c * 0.022, Paint()..color = oro.withValues(alpha: 0.70));
    tela.drawCircle(
        cuore,
        c * 0.022,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = c * 0.003
          ..color = Colors.white.withValues(alpha: 0.55));
  }
}
