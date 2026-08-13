import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../rituals/rune_strokes.dart';

/// Il sigillo del giorno: una bindrune, un glifo unico che intreccia le rune
/// uscite sovrapponendone i tratti su un'asta centrale condivisa, in oro. E'
/// deterministico dalle rune della gettata, nessuna casualita' nel disegno.
class BindruneSigillo extends StatelessWidget {
  const BindruneSigillo({
    super.key,
    required this.runeNames,
    required this.oro,
    this.alone,
    this.lato = 150,
    this.deduplica = false,
  });

  /// I nomi delle rune da intrecciare, nell'ordine di lettura.
  final List<String> runeNames;

  /// L'oro dei tratti e dell'asta.
  final Color oro;

  /// Un secondo tono d'oro per l'alone, oppure [oro] se assente.
  final Color? alone;

  final double lato;

  /// Se vero, i tratti identici sovrapposti si disegnano una volta sola. Lo
  /// usa il sigillo della settimana, che intreccia sette rune: senza, i tratti
  /// comuni si addenserebbero. L'Estrazione Rune lo lascia falso, invariata.
  final bool deduplica;

  /// L'estremo alto e quello basso dello stelo, in coordinate normalizzate: alto
  /// il settanta per cento del riquadro, centrato.
  /// IL RAGGIO DEL TONDO, in frazione del lato: il disco su cui il segno e' inciso.
  static const double raggioDelTondo = 0.44;

  /// IL MARGINE fra il segno e l'anello, in frazione del lato. **Non e' estetica:**
  /// un segno che tocca il bordo si legge come un segno tagliato, e il tondo smette
  /// di essere una cornice e diventa un ostacolo. Una prova lo misura sulla resa.
  static const double margineDelTondo = 0.05;

  static const double steloAlto = 0.15;
  static const double steloBasso = 0.85;

  /// Il numero massimo di rami del sigillo: oltre, il segno non si legge piu'.
  /// Sono dodici perche' ogni runa puo' portarne fino a due, e sette rune con un
  /// ramo solo collasserebbero su segni quasi uguali.
  static const int maxRami = 12;

  /// Quanti rami al massimo prende una singola runa.
  static const int maxRamiPerRuna = 2;

  /// I rami del sigillo in coordinate normalizzate, uno per runa unica, gia'
  /// agganciati allo stelo e ripiegati su un solo lato. E' la geometria vera del
  /// disegno, esposta cosi' che il test possa verificarla senza dipingere.
  ///
  /// Ogni ramo nasce dal punto piu' vicino all'asse della runa, viene ripiegato
  /// tutto da una parte (quindi non attraversa mai lo stelo), scalato per stare
  /// nel riquadro e portato alla sua quota. Le rune di solo stelo, come Isa, non
  /// generano rami: contribuiscono soltanto allo stelo condiviso.
  static List<List<Offset>> ramiDi(List<String> runeNames) {
    // Una runa per volta, senza ripetizioni. Ogni runa porta fino a due rami,
    // cosi' segni diversi restano distinguibili invece di collassare tutti su
    // una barretta obliqua uguale.
    final viste = <String>{};
    final grezzi = <List<Offset>>[];
    for (final name in runeNames) {
      if (grezzi.length >= maxRami) break;
      if (!viste.add(name)) continue;
      for (final ramo in _ramiDiRuna(name)) {
        if (grezzi.length >= maxRami) break;
        grezzi.add(ramo);
      }
    }
    if (grezzi.isEmpty) return const [];

    // Le quote lungo lo stelo, distribuite, con un margine agli estremi cosi' il
    // ramo non tocca mai la punta.
    const primo = steloAlto + 0.06;
    const ultimo = steloBasso - 0.06;
    final n = grezzi.length;
    final passo = n == 1 ? 0.0 : (ultimo - primo) / (n - 1);

    // Estensione massima di un ramo: mai oltre il riquadro, con un margine. Con
    // piu' rami le quote si infittiscono, quindi ogni ramo occupa meno altezza,
    // altrimenti invade quella del vicino e il segno si ingarbuglia.
    const estensione = 0.26;
    final altezzaMax = n <= 6 ? 0.22 : 0.14;

    final quoteUsate = <int, List<double>>{}; // per lato, le quote occupate
    final rami = <List<Offset>>[];
    for (var i = 0; i < n; i++) {
      final grezzo = grezzi[i];
      final lato = i.isEven ? 1 : -1; // destra, sinistra, destra...
      var quota = n == 1 ? (primo + ultimo) / 2 : primo + passo * i;
      // Se un ramo cade troppo vicino a un altro dello stesso lato, si sposta.
      final occupate = quoteUsate.putIfAbsent(lato, () => <double>[]);
      final minimo = passo == 0 ? 0.12 : passo * 0.5;
      while (occupate.any((q) => (q - quota).abs() < minimo)) {
        quota += minimo;
      }
      occupate.add(quota);

      // Ripiegatura su un lato: si prende la distanza dall'innesto in valore
      // assoluto, cosi' nessun punto passa dall'altra parte dello stelo.
      var largo = 0.0;
      var alto = 0.0;
      for (final p in grezzo) {
        largo = p.dx.abs() > largo ? p.dx.abs() : largo;
        alto = p.dy.abs() > alto ? p.dy.abs() : alto;
      }
      var scala = 1.0;
      if (largo > 0) scala = math.min(scala, estensione / largo);
      if (alto > 0) scala = math.min(scala, (altezzaMax / 2) / alto);

      final ramo = <Offset>[];
      for (final p in grezzo) {
        final x = 0.5 + lato * p.dx.abs() * scala;
        final y = quota + p.dy * scala;
        ramo.add(Offset(x.clamp(0.02, 0.98), y.clamp(0.02, 0.98)));
      }
      rami.add(ramo);
    }
    return rami;
  }

  /// Fino a due rami di una runa, in coordinate relative al punto d'innesto: le
  /// due spezzate non verticali piu' estese, scartando la seconda se e' troppo
  /// simile alla prima per angolo e lunghezza (sarebbe un doppione muto).
  /// Vuota per le rune di solo stelo, come Isa.
  static List<List<Offset>> _ramiDiRuna(String name) {
    final strokes = kRuneStrokes[name];
    if (strokes == null) return const [];

    // L'asse verticale della runa, se c'e': i rami si agganciano a quello.
    var asseX = 0.5;
    var trovata = false;
    for (final poly in strokes) {
      if (_eAsta(poly)) {
        final xs = poly.map((p) => p.dx);
        asseX = (xs.reduce(math.max) + xs.reduce(math.min)) / 2;
        trovata = true;
        break;
      }
    }

    // Le spezzate candidate, dalla piu' estesa alla meno estesa.
    final candidate = <List<Offset>>[
      for (final poly in strokes)
        if (!_eAsta(poly)) poly,
    ]..sort((a, b) => _estensione(b).compareTo(_estensione(a)));
    if (candidate.isEmpty) return const []; // solo stelo: nessun ramo

    if (!trovata) {
      final xs = candidate.first.map((p) => p.dx);
      asseX = (xs.reduce(math.max) + xs.reduce(math.min)) / 2;
    }

    final scelte = <List<Offset>>[candidate.first];
    for (final poly in candidate.skip(1)) {
      if (scelte.length >= maxRamiPerRuna) break;
      if (scelte.every((s) => _abbastanzaDiverse(s, poly))) scelte.add(poly);
    }

    return [
      for (final poly in scelte) _traslataSullInnesto(poly, asseX),
    ];
  }

  /// Vero se la spezzata e' l'asta verticale della runa, quella che nel sigillo
  /// e' gia' rappresentata dallo stelo condiviso.
  static bool _eAsta(List<Offset> poly) {
    final xs = poly.map((p) => p.dx);
    final ys = poly.map((p) => p.dy);
    final dx = xs.reduce(math.max) - xs.reduce(math.min);
    final dy = ys.reduce(math.max) - ys.reduce(math.min);
    return dx < 0.08 && dy > 0.5;
  }

  /// L'estensione di una spezzata, larghezza piu' altezza del suo ingombro.
  static double _estensione(List<Offset> poly) {
    final xs = poly.map((p) => p.dx);
    final ys = poly.map((p) => p.dy);
    return (xs.reduce(math.max) - xs.reduce(math.min)) +
        (ys.reduce(math.max) - ys.reduce(math.min));
  }

  /// La lunghezza percorsa da una spezzata, somma dei suoi segmenti.
  static double _lunghezza(List<Offset> poly) {
    var l = 0.0;
    for (var i = 1; i < poly.length; i++) {
      l += (poly[i] - poly[i - 1]).distance;
    }
    return l;
  }

  /// L'angolo dal primo all'ultimo punto, in radianti.
  static double _angolo(List<Offset> poly) {
    final d = poly.last - poly.first;
    return math.atan2(d.dy, d.dx);
  }

  /// Due spezzate sono abbastanza diverse se cambiano direzione di almeno venti
  /// gradi, se una e' almeno un terzo piu' lunga dell'altra, oppure se nascono a
  /// quote chiaramente distinte. Quest'ultimo caso conta: in Fehu le due barre
  /// sono parallele e uguali, e sono proprio loro a fare il segno; scartarne una
  /// e' il modo per far collassare rune diverse sullo stesso ramo.
  static bool _abbastanzaDiverse(List<Offset> a, List<Offset> b) {
    var scarto = (_angolo(a) - _angolo(b)).abs();
    if (scarto > math.pi) scarto = 2 * math.pi - scarto;
    if (scarto > 20 * math.pi / 180) return true;
    final la = _lunghezza(a);
    final lb = _lunghezza(b);
    final maggiore = math.max(la, lb);
    if (maggiore > 0 && (la - lb).abs() / maggiore > 0.33) return true;
    // Parallele e di pari lunghezza, ma innestate a quote diverse: sono due
    // barre distinte del segno, non un doppione.
    return (a.first.dy - b.first.dy).abs() > 0.1;
  }

  /// La spezzata portata sull'origine, nel suo punto piu' vicino all'asse: da li'
  /// il ramo si innesta sullo stelo.
  static List<Offset> _traslataSullInnesto(List<Offset> poly, double asseX) {
    var innesto = poly.first;
    var minDist = (innesto.dx - asseX).abs();
    for (final p in poly) {
      final d = (p.dx - asseX).abs();
      if (d < minDist) {
        minDist = d;
        innesto = p;
      }
    }
    return [for (final p in poly) Offset(p.dx - innesto.dx, p.dy - innesto.dy)];
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('bindrune'),
      width: lato,
      height: lato,
      child: CustomPaint(
        painter: _BindrunePainter(
          runeNames: runeNames,
          oro: oro,
          alone: alone ?? oro,
          deduplica: deduplica,
        ),
      ),
    );
  }
}

class _BindrunePainter extends CustomPainter {
  _BindrunePainter({
    required this.runeNames,
    required this.oro,
    required this.alone,
    required this.deduplica,
  });

  final List<String> runeNames;
  final Color oro;
  final Color alone;
  final bool deduplica;

  @override
  void paint(Canvas canvas, Size size) {
    if (deduplica) {
      _paintStelo(canvas, size);
    } else {
      _paintSovrapposto(canvas, size);
    }
  }

  /// Il disco e l'anello: la superficie su cui il sigillo e' inciso.
  ///
  /// **Tre strati, e ognuno fa una cosa sola.** Il disco scuro da' un fondo al
  /// segno, cosi' i tratti chiari hanno qualcosa dietro invece del cosmo; l'alone
  /// caldo dentro il disco lo fa sembrare inciso e non stampato; l'anello d'oro
  /// chiude la forma, ed e' il tratto che dice "sigillo" prima ancora che si legga
  /// il glifo.
  void _paintTondo(Canvas canvas, Size size) {
    final centro = size.center(Offset.zero);
    final raggio = size.shortestSide * BindruneSigillo.raggioDelTondo;

    canvas.drawCircle(
      centro,
      raggio,
      Paint()..color = const Color(0xFF1A0C10).withValues(alpha: 0.55),
    );
    canvas.drawCircle(
      centro,
      raggio,
      Paint()
        ..shader = RadialGradient(colors: [
          alone.withValues(alpha: 0.16),
          alone.withValues(alpha: 0.0),
        ]).createShader(Rect.fromCircle(center: centro, radius: raggio)),
    );
    canvas.drawCircle(
      centro,
      raggio,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.shortestSide * 0.012
        ..color = oro.withValues(alpha: 0.85),
    );
  }

  // Il sigillo della settimana: un unico segno composto. Un solo stelo
  // verticale centrale, spesso, alto il settanta per cento del riquadro, e i
  // rami delle rune agganciati allo stelo, uno per runa, ciascuno alla propria
  // quota, alternando destra e sinistra. Nessun ramo attraversa lo stelo,
  // nessuno esce dal riquadro, al massimo sette. Tono osso caldo, alone ambrato.
  void _paintStelo(Canvas canvas, Size size) {
    // **IL SIGILLO STA DENTRO UN TONDO, ordine S voce 25.**
    //
    // Prima era un intreccio di tratti d'oro sospeso sul fondo, e a video si
    // leggeva come un groviglio: nessuna forma che lo contenesse, nessun
    // appoggio, nessun bordo. Un sigillo e' un segno impresso su qualcosa, e senza
    // quel qualcosa restano solo le linee.
    //
    // Adesso c'e' un DISCO su cui il segno e' inciso e un ANELLO che lo chiude, coi
    // due tratti che l'app usa gia' per le cornici: il segno rientra dentro
    // l'anello con un margine dichiarato, quindi non lo tocca mai.
    _paintTondo(canvas, size);
    // **IL RIQUADRO DEL GLIFO SI RICAVA DALL'ANELLO, non si sceglie.** E' il
    // quadrato piu' grande inscritto nel cerchio interno, cioe' nel tondo meno il
    // margine: cosi' se un giorno il raggio o il margine cambiano, il glifo li
    // segue da solo e nessuno deve ricordarsi di aggiustare un terzo numero.
    final box = size.shortestSide *
        (BindruneSigillo.raggioDelTondo - BindruneSigillo.margineDelTondo) *
        2 /
        math.sqrt2;
    final left = (size.width - box) / 2;
    final top = (size.height - box) / 2;
    Offset map(Offset p) => Offset(left + p.dx * box, top + p.dy * box);

    const osso = Color(0xFFEAD8AE); // osso caldo, non giallo pieno
    final ambra = alone; // bagliore ambrato, dal secondo oro passato

    // Alone tondo dietro il sigillo.
    canvas.drawCircle(
      size.center(Offset.zero),
      box * 0.6,
      Paint()
        ..shader = RadialGradient(colors: [
          ambra.withValues(alpha: 0.20),
          ambra.withValues(alpha: 0.0),
        ]).createShader(
            Rect.fromCircle(center: size.center(Offset.zero), radius: box * 0.6)),
    );

    // **I TRATTI SEGUONO IL LATO, non il riquadro del glifo. Ordine S voce 25.**
    //
    // Erano frazioni di `box`, e quando il riquadro e' sceso dentro l'anello si
    // sono assottigliati con lui: il segno stava dentro il tondo ma inciso piu'
    // piano di prima, e un sigillo piu' pallido non e' un sigillo migliore. I due
    // numeri qui sotto sono gli stessi PESI ASSOLUTI di prima (0,82 per 0,055 e
    // 0,82 per 0,042), riscritti sul lato perche' non seguano piu' una misura che
    // cambia.
    final pesoStelo = size.shortestSide * 0.045;
    final pesoRami = size.shortestSide * 0.034;
    // Lo stelo verticale centrale, spesso, sotto i rami.
    final steloTop = map(const Offset(0.5, BindruneSigillo.steloAlto));
    final steloBot = map(const Offset(0.5, BindruneSigillo.steloBasso));
    canvas.drawLine(
        steloTop,
        steloBot,
        Paint()
          ..strokeCap = StrokeCap.round
          ..strokeWidth = pesoStelo
          ..color = ambra.withValues(alpha: 0.4)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, box * 0.035));
    canvas.drawLine(
        steloTop,
        steloBot,
        Paint()
          ..strokeCap = StrokeCap.round
          ..strokeWidth = pesoStelo
          ..color = osso);

    // I rami, ognuno a una quota diversa lungo lo stelo.
    //
    // DALL'ORDINE H il tratto dei rami sale da 0,03 a 0,042 del riquadro: a
    // 0,03 i rami si leggevano come fili accanto a uno stelo di 0,055, e un
    // sigillo e' un segno inciso, non un ricamo. Il bagliore segue.
    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = pesoStelo
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = ambra.withValues(alpha: 0.5)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, box * 0.04);
    final tratto = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = pesoRami
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = osso;

    for (final ramo in BindruneSigillo.ramiDi(runeNames)) {
      final path = Path();
      for (var k = 0; k < ramo.length; k++) {
        final p = map(ramo[k]);
        if (k == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(path, glow);
      canvas.drawPath(path, tratto);
    }
  }


  void _paintSovrapposto(Canvas canvas, Size size) {
    // **IL TONDO VALE ANCHE QUI, ordine S voce 25.** Le due strade dipingono lo
    // stesso oggetto, il Sigillo del Giorno: una lo compone con un solo stelo, e
    // l'altra sovrappone i glifi. Se il tondo stesse su una sola delle due, il
    // sigillo sarebbe un sigillo a giorni alterni, ed e' la famiglia delle due
    // porte.
    _paintTondo(canvas, size);
    // Lo stesso riquadro ricavato dall'anello: il quadrato piu' grande inscritto
    // nel cerchio interno.
    final box = size.shortestSide *
        (BindruneSigillo.raggioDelTondo - BindruneSigillo.margineDelTondo) *
        2 /
        math.sqrt2;
    final left = (size.width - box) / 2;
    final top = (size.height - box) / 2;
    Offset map(Offset p) => Offset(left + p.dx * box, top + p.dy * box);

    // Alone tondo dietro il sigillo, per staccarlo dal fondo.
    canvas.drawCircle(
      size.center(Offset.zero),
      box * 0.62,
      Paint()
        ..shader = RadialGradient(colors: [
          alone.withValues(alpha: 0.22),
          alone.withValues(alpha: 0.0),
        ]).createShader(
            Rect.fromCircle(center: size.center(Offset.zero), radius: box * 0.62)),
    );

    final glow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = box * 0.05
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = alone.withValues(alpha: 0.45)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, box * 0.04);

    final tratto = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = box * 0.035
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = oro;

    // I tratti di ogni runa, centrati orizzontalmente sull'asta condivisa. Con
    // [deduplica] un tratto gia' disegnato non si ridisegna, cosi' l'intreccio
    // di sette rune non si addensa.
    final visti = <String>{};
    for (final name in runeNames) {
      final strokes = kRuneStrokes[name];
      if (strokes == null) continue;
      var minX = 1.0;
      var maxX = 0.0;
      for (final poly in strokes) {
        for (final p in poly) {
          if (p.dx < minX) minX = p.dx;
          if (p.dx > maxX) maxX = p.dx;
        }
      }
      final shift = 0.5 - (minX + maxX) / 2;
      for (final poly in strokes) {
        if (deduplica) {
          final firma = poly
              .map((p) => '${((p.dx + shift) * 100).round()},'
                  '${(p.dy * 100).round()}')
              .join(';');
          if (!visti.add(firma)) continue;
        }
        final path = Path()
          ..moveTo(map(poly.first.translate(shift, 0)).dx,
              map(poly.first.translate(shift, 0)).dy);
        for (var i = 1; i < poly.length; i++) {
          final p = map(poly[i].translate(shift, 0));
          path.lineTo(p.dx, p.dy);
        }
        canvas.drawPath(path, glow);
        canvas.drawPath(path, tratto);
      }
    }

    // L'asta centrale condivisa, sopra tutto, che unisce l'intreccio.
    final asta = Path()
      ..moveTo(map(const Offset(0.5, 0.02)).dx, map(const Offset(0.5, 0.02)).dy)
      ..lineTo(map(const Offset(0.5, 0.98)).dx, map(const Offset(0.5, 0.98)).dy);
    canvas.drawPath(
        asta,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = box * 0.06
          ..strokeCap = StrokeCap.round
          ..color = alone.withValues(alpha: 0.4)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, box * 0.03));
    canvas.drawPath(
        asta,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = box * 0.045
          ..strokeCap = StrokeCap.round
          ..color = oro);
  }

  @override
  bool shouldRepaint(_BindrunePainter old) =>
      old.runeNames != runeNames ||
      old.oro != oro ||
      old.alone != alone ||
      old.deduplica != deduplica;
}

/// I rami di una runa per il sigillo a stelo: le spezzate senza l'asta, l'asse
/// verticale della runa e il centroide verticale dei rami.
