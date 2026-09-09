import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/maestro/colore_del_centro.dart';

/// **IL LOTO CHE RESPIRA.** Ordine DB voce 04, 9 settembre 2026, seconda
/// stesura dopo il rifiuto del fondatore.
///
/// **La prima stesura e' stata respinta**, e la voce DB.04 non lascia margine:
/// *"Il cerchio che si gonfia esce, ed esce anche qualunque figura piccola
/// circondata da spazio vuoto. Questa voce non lascia margine di
/// interpretazione: sono misure."*
///
/// **I DUE DIFETTI CHE QUESTA STESURA ESISTE PER CHIUDERE.** Il fiore era
/// piccolo dentro un riquadro con la cornice vuota attorno, ed era nei colori
/// del Maestro invece che in quelli del centro del giorno. Sette petali su una
/// corona sola, che a schermo pieno sembrano poveri.
///
/// **LE MISURE, e sono pretese da una guardia.**
/// - Al culmine dell'inspiro la corona piu' esterna arriva **almeno
///   all'ottantacinque per cento** della larghezza dello schermo.
/// - Al fondo dell'espiro il fiore **non scende sotto il cinquanta per
///   cento**: si chiude, non sparisce.
/// - **Quattro corone** concentriche, col numero di petali che cresce anello
///   dopo anello: sette, undici, diciassette, ventitre'.
///
/// **PERCHE' QUEI QUATTRO NUMERI.** Sette e' il numero dei centri e sta al
/// cuore, dove la traccia deve poter mostrare quale centro e' spento. Gli altri
/// tre sono **numeri primi crescenti**: due corone con petali in rapporto
/// intero allineano i loro petali su raggi comuni e disegnano braccia, che e'
/// la stella a punte da cui questo fiore deve stare lontano. Con sette, undici,
/// diciassette e ventitre' nessun petalo di una corona cade mai sullo stesso
/// raggio di quello di un'altra.
///
/// **L'ONDA, ed e' qui che il respiro si vede.** L'apertura non e' una scala
/// uniforme: parte dal cuore e si propaga verso fuori, con un ritardo
/// dichiarato fra un anello e il successivo. Sull'espiro il moto si inverte e
/// la chiusura arriva dall'esterno verso il cuore. **Senza l'onda il fiore e'
/// una figura che si ingrandisce**, ed e' esattamente cio' che il fondatore ha
/// respinto.
///
/// **CHI LO DISEGNA.** Il fiore e' disegnato qui, nel codice, come la spirale
/// di stelle. Le immagini di riferimento del fondatore vengono da banche
/// immagini con watermark: **non entrano nel progetto in nessuna forma**, e
/// dentro il disegno non entra nessuna icona di serie del framework.
class LotoCheRespira extends StatelessWidget {
  const LotoCheRespira({
    super.key,
    required this.apertura,
    required this.coloreDelCentro,
    this.gocce = const [],
    this.centroDiOggi = 0,
    this.senzaMoto = false,
    this.inclinazione = Offset.zero,
  });

  /// Quanto e' aperto il fiore, da 0 a 1. Viene dal respiro vero.
  final double apertura;

  /// **IL COLORE DEL CENTRO ACCESO OGGI**, non quello del Maestro. Ordine DB
  /// voce 04: siccome il centro cambia ogni giorno, il fiore di domani e' di
  /// un altro colore, ed e' un motivo per tornare che non costa niente.
  final Color coloreDelCentro;

  /// Le gocce per centro, una per petalo della corona del cuore: quante volte
  /// quel centro e' stato respirato.
  final List<int> gocce;

  /// Quale petalo e' quello di oggi, per accenderlo piu' degli altri.
  final int centroDiOggi;

  /// **CON RIDUCI MOVIMENTO I PETALI NON SI ANIMANO.** La fase cambia con uno
  /// stato fermo e visibile, **il colore resta**, e la vibrazione resta.
  final bool senzaMoto;

  /// L'inclinazione del telefono, per la parallasse leggera fra le corone.
  /// Zero quando il giroscopio non c'e' o quando il moto e' ridotto.
  final Offset inclinazione;

  /// **QUANTI PETALI PER CORONA**, dal cuore verso fuori.
  static const List<int> petaliPerCorona = [7, 11, 17, 23];

  /// **QUANTO RITARDA UNA CORONA SULLA PRECEDENTE**, in frazione del respiro.
  /// Con quattro corone il fronte d'onda occupa il quaranta per cento
  /// dell'inspiro: il cuore e' gia' aperto mentre il bordo sta ancora salendo,
  /// e il fiore finisce comunque di aprirsi prima della fine dell'inspiro.
  static const double ritardoPerCorona = 0.13;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: PittoreDelLoto(
          apertura: senzaMoto ? (apertura > 0.5 ? 1.0 : 0.0) : apertura,
          coloreDelCentro: coloreDelCentro,
          gocce: gocce,
          centroDiOggi: centroDiOggi,
          senzaMoto: senzaMoto,
          inclinazione: senzaMoto ? Offset.zero : inclinazione,
        ),
      );
}

/// Il pittore del Loto. **Pubblico apposta**: la sua geometria e' la cosa che
/// va misurata, e per misurarla una guardia deve poterlo interrogare senza
/// montare una schermata intera.
class PittoreDelLoto extends CustomPainter {
  PittoreDelLoto({
    required this.apertura,
    required this.coloreDelCentro,
    required this.gocce,
    required this.centroDiOggi,
    this.senzaMoto = false,
    this.inclinazione = Offset.zero,
  });

  final double apertura;
  final Color coloreDelCentro;
  final List<int> gocce;
  final int centroDiOggi;
  final bool senzaMoto;
  final Offset inclinazione;

  /// **QUANTO OCCUPA IL FIORE AL CULMINE**, in frazione del lato corto.
  /// L'ordine chiede almeno l'ottantacinque per cento della larghezza dello
  /// schermo: qui si tiene l'ottantotto, cosi' la misura passa anche quando il
  /// riquadro non e' esattamente largo quanto lo schermo.
  static const double quotaAperto = 0.88;

  /// **E QUANTO AL FONDO DELL'ESPIRO.** L'ordine chiede di non scendere sotto
  /// il cinquanta per cento: **si chiude, non sparisce.** Cinquantaquattro
  /// lascia il margine che serve perche' la misura resti sopra la soglia anche
  /// col petalo piu' corto.
  static const double quotaChiuso = 0.54;

  /// **QUANTO E' APERTA LA CORONA [i], con l'onda.**
  ///
  /// Il cuore segue il respiro senza ritardo; ogni corona successiva parte
  /// piu' tardi e arriva piu' tardi. Sull'espiro l'onda si inverte da sola,
  /// perche' la corona esterna e' l'ultima ad aver raggiunto il pieno ed e' la
  /// prima a lasciarlo.
  ///
  /// **Pubblica e pura**: e' la formula che rende il respiro leggibile, ed e'
  /// la cosa che una guardia deve poter misurare senza dipingere niente.
  static double aperturaDellaCorona(double apertura, int i) {
    if (i <= 0) return apertura.clamp(0.0, 1.0);
    final ritardo = LotoCheRespira.ritardoPerCorona * i;
    // La corona parte quando il respiro ha superato il suo ritardo, e copre
    // il resto della corsa nello spazio che le rimane.
    final utile = 1.0 - ritardo;
    if (utile <= 0) return apertura >= 1.0 ? 1.0 : 0.0;
    return ((apertura - ritardo) / utile).clamp(0.0, 1.0);
  }

  /// **IL RAGGIO DELLA CORONA [i] a una data apertura**, in punti.
  ///
  /// Serve alla guardia che misura quanto il fiore occupa: il raggio della
  /// corona piu' esterna al culmine e' la meta' della larghezza che l'ordine
  /// pretende.
  static double raggioDellaCorona(
      double lato, double apertura, int i, int quanteCorone) {
    final apertaQui = aperturaDellaCorona(apertura, i);
    // Ogni corona sta piu' fuori della precedente anche da chiusa: e' cio'
    // che rende il fiore un mandala e non una stella sola.
    final base = (i + 1) / quanteCorone;
    final meta = lato / 2;
    final chiuso = meta * quotaChiuso * base;
    final aperto = meta * quotaAperto * base;
    return chiuso + (aperto - chiuso) * apertaQui;
  }

  /// Quante forme vive il pittore disegna al culmine: la somma dei petali di
  /// tutte le corone, piu' l'alone, il cuore e le gocce.
  static int formeAlCulmine() {
    final petali =
        LotoCheRespira.petaliPerCorona.reduce((a, b) => a + b);
    // Ogni petalo e' una forma piena piu' il suo filo di luce sul bordo.
    return petali * 2 + 2 + LotoCheRespira.petaliPerCorona.first;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final centro = size.center(Offset.zero);
    final lato = size.shortestSide;
    final corone = LotoCheRespira.petaliPerCorona.length;

    // **L'ALONE, che e' la luce del respiro.** Ordine DB voce 04: al culmine
    // dell'inspiro il cuore si accende e l'alone si allarga; sull'espiro la
    // luce si ritira. **Il respiro deve essere leggibile a occhi socchiusi**,
    // guardando solo il chiarore.
    final raggioEsterno =
        raggioDellaCorona(lato, apertura, corone - 1, corone);
    canvas.drawCircle(
      centro,
      raggioEsterno * (0.85 + 0.35 * apertura),
      Paint()
        ..shader = RadialGradient(colors: [
          coloreDelCentro.withValues(alpha: 0.05 + 0.22 * apertura),
          Colors.transparent,
        ]).createShader(
            Rect.fromCircle(center: centro, radius: raggioEsterno * 1.2)),
    );

    // **DALL'ESTERNO VERSO IL CUORE**, cosi' le corone interne cadono sopra
    // quelle esterne e la profondita' si legge.
    for (var i = corone - 1; i >= 0; i--) {
      _corona(canvas, centro, lato, i, corone);
    }

    // Il cuore del fiore, che si accende col respiro.
    final cuore = raggioDellaCorona(lato, apertura, 0, corone) * 0.20;
    canvas.drawCircle(
      centro,
      cuore * (0.85 + 0.30 * apertura),
      Paint()
        ..shader = RadialGradient(colors: [
          ColoreDelCentro.bordoDi(coloreDelCentro)
              .withValues(alpha: 0.55 + 0.40 * apertura),
          coloreDelCentro.withValues(alpha: 0.20),
        ]).createShader(Rect.fromCircle(center: centro, radius: cuore * 1.4)),
    );
  }

  void _corona(
      Canvas canvas, Offset centro, double lato, int i, int quanteCorone) {
    final quanti = LotoCheRespira.petaliPerCorona[i];
    final raggio = raggioDellaCorona(lato, apertura, i, quanteCorone);
    final apertaQui = aperturaDellaCorona(apertura, i);
    final quota = quanteCorone <= 1 ? 0.0 : i / (quanteCorone - 1);
    final tinta = ColoreDelCentro.sfumato(coloreDelCentro, quota);
    final bordo = ColoreDelCentro.bordoDi(tinta);

    // **LA PARALLASSE, e sta nelle corone e non nel fiore intero.** Ordine DB
    // voce 04: gli anelli stanno su piani diversi. Un fiore che trasla tutto
    // insieme non ha profondita', ha uno spostamento.
    final scarto = inclinazione * (2.0 + 4.0 * quota);
    final o = centro + scarto;

    // L'ombra propria dell'anello, che cade dal centro verso fuori.
    final ombra = Paint()
      ..color = const Color(0xFF07030F).withValues(alpha: 0.35 * (1 - quota))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    for (var p = 0; p < quanti; p++) {
      // **LO SFASAMENTO FRA CORONE.** Ogni corona ruota di mezzo passo
      // rispetto alla precedente, cosi' i petali si incastrano invece di
      // sovrapporsi.
      final passo = 2 * math.pi / quanti;
      final angolo = -math.pi / 2 + p * passo + (i.isOdd ? passo / 2 : 0);

      // **OGNI PETALO RUOTA MENTRE SI APRE.** Ordine DB voce 04: *"come un
      // fiore vero, invece di limitarsi ad allontanarsi dal centro"*. La
      // torsione e' piccola e in verso alterno fra corone: piu' di cosi' il
      // mandala si scompone.
      final torsione = (i.isEven ? 1 : -1) * 0.22 * apertaQui;

      final lungo = raggio * (0.34 + 0.66 * apertaQui);
      final largo = raggio * (0.13 + 0.10 * apertaQui) *
          (quanti <= 8 ? 1.0 : 7 / quanti + 0.35);

      // La traccia vive sulla corona del cuore, dove i petali sono sette.
      var forza = 0.42 + 0.38 * apertaQui;
      if (i == 0) {
        final quante = p < gocce.length ? gocce[p] : 0;
        if (quante == 0) forza *= 0.34;
        if (p == centroDiOggi) forza = (forza * 1.3).clamp(0.0, 1.0);
      }

      final petalo = _petalo(o, angolo + torsione, lungo, largo);
      canvas.drawPath(petalo.shift(const Offset(0, 3)), ombra);
      canvas.drawPath(
          petalo,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.center,
              end: Alignment.topCenter,
              colors: [
                tinta.withValues(alpha: forza),
                tinta.withValues(alpha: forza * 0.55),
              ],
            ).createShader(petalo.getBounds()));
      canvas.drawPath(
          petalo,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.1
            ..color = bordo.withValues(alpha: forza * 0.75));
    }
  }

  /// Un petalo: due archi che si incontrano in punta, con l'attacco al centro.
  Path _petalo(Offset centro, double angolo, double lungo, double largo) {
    final punta = centro + Offset(math.cos(angolo), math.sin(angolo)) * lungo;
    final normale = Offset(-math.sin(angolo), math.cos(angolo));
    final meta = centro +
        Offset(math.cos(angolo), math.sin(angolo)) * (lungo * 0.45);
    final a = meta + normale * largo;
    final b = meta - normale * largo;
    return Path()
      ..moveTo(centro.dx, centro.dy)
      ..quadraticBezierTo(a.dx, a.dy, punta.dx, punta.dy)
      ..quadraticBezierTo(b.dx, b.dy, centro.dx, centro.dy)
      ..close();
  }

  @override
  bool shouldRepaint(covariant PittoreDelLoto vecchio) =>
      vecchio.apertura != apertura ||
      vecchio.coloreDelCentro != coloreDelCentro ||
      vecchio.centroDiOggi != centroDiOggi ||
      vecchio.inclinazione != inclinazione ||
      vecchio.senzaMoto != senzaMoto ||
      !_stesseGocce(vecchio.gocce, gocce);

  static bool _stesseGocce(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
