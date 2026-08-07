/// LA FISICA DELLA GETTATA, PURA E DETERMINISTICA.
///
/// **Perche' esiste.** La gettata era un teletrasporto: al tocco le pietre si
/// materializzavano gia' posate, e Mauro l'ha detto senza giri: scattosa, poco
/// professionale, per nulla realistica. Il gesto centrale dell'arte deve
/// sembrare vero: le pietre CADONO, rimbalzano, ruotano, si fermano storte
/// come sassi veri.
///
/// **Il determinismo viene prima della bellezza.** Tutto quello che qui
/// sembra caso, i ritardi, le rotazioni, le inclinazioni finali, viene da un
/// SEME, mai da un caso vero: a parita' di seme la disposizione finale e'
/// identica al decimo di punto, e una prova lo pretende. Il seme lo deriva la
/// schermata da persona, giorno, domanda e rune uscite.
///
/// **Perche' e' in forma chiusa e non integrata.** Ogni grandezza e' una
/// funzione pura del tempo: niente stato accumulato fotogramma su fotogramma,
/// quindi niente derive numeriche, niente dipendenza dal ritmo dei
/// fotogrammi, e il costo per fotogramma e' una manciata di moltiplicazioni.
/// E' cio' che rende la fluidita' una proprieta' strutturale invece che una
/// speranza.
library;

import 'dart:math' as math;
import 'dart:ui' show Offset;

/// Lo stato di una pietra a un istante della gettata.
class StatoPietra {
  const StatoPietra({
    required this.posizione,
    required this.rotazione,
    required this.quota,
    required this.visibile,
  });

  /// Dove sta la pietra, in coordinate normalizzate del telo (0..1).
  final Offset posizione;

  /// La rotazione attorno al proprio centro, in radianti.
  final double rotazione;

  /// L'altezza dal telo, 1 all'inizio della caduta, 0 al contatto. Governa
  /// l'ombra: alta e' larga e chiara, a terra e' stretta e scura.
  final double quota;

  /// Falso prima che la pietra entri in scena (le pietre cadono in cascata).
  final bool visibile;
}

/// La traiettoria di una singola pietra, tutta decisa alla costruzione.
class _Traiettoria {
  _Traiettoria({
    required this.arrivo,
    required this.partenza,
    required this.ritardo,
    required this.durata,
    required this.spin,
    required this.inclinazioneFinale,
  });

  final Offset arrivo;
  final Offset partenza;

  /// Quando la pietra parte, come frazione del tempo totale (0..1).
  final double ritardo;

  /// Quanto dura il suo volo, come frazione del tempo totale.
  final double durata;

  /// Quanta rotazione compie durante il volo, in radianti.
  final double spin;

  /// Come resta storta da ferma. Mai zero: nessuna pietra vera si posa
  /// perfettamente dritta.
  final double inclinazioneFinale;
}

/// Il motore. Si costruisce con un seme e i punti d'arrivo, e da li' in poi e'
/// una funzione pura del tempo.
class FisicaDellaGettata {
  /// LO SMORZAMENTO DEI RIMBALZI, dichiarato: ogni rimbalzo conserva il 32%
  /// dell'altezza del precedente. Due rimbalzi e non piu': il primo arriva al
  /// 32% della quota di caduta, il secondo al 10%, il terzo varrebbe il 3%,
  /// cioe' meno di un pixel su un telo da 300 punti, quindi non esiste.
  static const double smorzamento = 0.32;

  /// Quando tocca terra la prima volta, come frazione del volo della singola
  /// pietra: prima il volo, poi i due rimbalzi negli ultimi 45 centesimi.
  static const double _contatto = 0.55;
  static const double _fineRimbalzo1 = 0.82;

  /// L'inclinazione minima da ferma, in radianti: circa 3,4 gradi. E' cio'
  /// che garantisce che NESSUNA pietra resti perfettamente allineata.
  static const double inclinazioneMinima = 0.06;

  FisicaDellaGettata({
    required int seme,
    required List<Offset> arrivi,
    required double semiLarghezza,
    required double semiAltezza,
  }) {
    final rng = _Lcg(seme);
    final separati = separaSenzaSovrapposizioni(
        arrivi, semiLarghezza, semiAltezza);
    _traiettorie = List.generate(separati.length, (i) {
      final arrivo = separati[i];
      // La cascata: le pietre non partono insieme, ognuna con un piccolo
      // ritardo, cosi' il lancio e' un gesto e non una salva.
      final ritardo = i * (0.4 / math.max(1, separati.length));
      final durata = 0.5 + rng.frazione() * 0.1;
      // Ogni pietra parte da poco sopra il telo, spostata di lato: cadendo
      // percorre un piccolo arco, come uscisse da una mano sopra il centro.
      final partenza = Offset(
        (arrivo.dx + (rng.frazione() - 0.5) * 0.24).clamp(0.05, 0.95),
        -0.18 - rng.frazione() * 0.1,
      );
      // Gira su se' stessa mentre cade, fra mezzo giro e un giro e mezzo,
      // in un verso o nell'altro.
      final spin = (rng.frazione() * 2 - 1) * math.pi * (0.5 + rng.frazione());
      // L'inclinazione finale: mai sotto la minima, mai uguale a un'altra
      // per costruzione, perche' cresce con l'indice.
      final verso = rng.frazione() < 0.5 ? -1.0 : 1.0;
      final inclinazione = verso *
          (inclinazioneMinima + 0.03 * i + rng.frazione() * 0.02);
      return _Traiettoria(
        arrivo: arrivo,
        partenza: partenza,
        ritardo: ritardo,
        durata: durata,
        spin: spin,
        inclinazioneFinale: inclinazione,
      );
    });
  }

  late final List<_Traiettoria> _traiettorie;

  int get quante => _traiettorie.length;

  /// Le posizioni finali, gia' separate e dentro il campo.
  List<Offset> get arrivi =>
      [for (final t in _traiettorie) t.arrivo];

  /// Le inclinazioni da ferme, per chi vuole disegnare la scena gia' posata.
  List<double> get inclinazioniFinali =>
      [for (final t in _traiettorie) t.inclinazioneFinale];

  /// Il momento del PRIMO CONTATTO della pietra [i] col telo, come frazione
  /// del tempo totale della gettata: e' l'istante del suono e della
  /// vibrazione.
  double primoContatto(int i) {
    final tr = _traiettorie[i];
    return tr.ritardo + tr.durata * _contatto;
  }

  /// Lo stato della pietra [i] al tempo [t], con t da 0 a 1 sull'intera
  /// gettata. Oltre l'uno, tutto e' fermo alla posizione finale.
  StatoPietra a(int i, double t) {
    final tr = _traiettorie[i];
    final s = ((t - tr.ritardo) / tr.durata).clamp(0.0, 1.0);
    if (s <= 0) {
      return StatoPietra(
        posizione: tr.partenza,
        rotazione: 0,
        quota: 1,
        visibile: false,
      );
    }

    // Il piano: la pietra viaggia dalla partenza all'arrivo con un piccolo
    // anticipo orizzontale, e' gia' quasi a destinazione quando tocca.
    final corsaPiano = math.min(1.0, s / _contatto);
    final morbida = 1 - (1 - corsaPiano) * (1 - corsaPiano);
    final posizione = Offset(
      tr.partenza.dx + (tr.arrivo.dx - tr.partenza.dx) * morbida,
      tr.partenza.dy + (tr.arrivo.dy - tr.partenza.dy) * morbida,
    );

    // La quota: caduta accelerata, poi due rimbalzi smorzati.
    double quota;
    if (s < _contatto) {
      final c = s / _contatto;
      quota = 1 - c * c; // gravita': parte piano, arriva veloce
    } else if (s < _fineRimbalzo1) {
      final c = (s - _contatto) / (_fineRimbalzo1 - _contatto);
      quota = smorzamento * 4 * c * (1 - c);
    } else {
      final c = (s - _fineRimbalzo1) / (1 - _fineRimbalzo1);
      quota = smorzamento * smorzamento * 4 * c * (1 - c);
    }

    // La rotazione: quasi tutta durante la caduta, si assesta
    // sull'inclinazione finale mentre rimbalza.
    final giro = 1 - math.pow(1 - s, 3).toDouble();
    final rotazione =
        tr.spin * (1 - s) * (1 - s) + tr.inclinazioneFinale * giro;

    return StatoPietra(
      posizione: posizione,
      rotazione: rotazione,
      quota: quota.clamp(0.0, 1.0),
      visibile: true,
    );
  }

  /// SEPARA I PUNTI D'ARRIVO FINCHE' NESSUNA PIETRA NE COPRE UN'ALTRA.
  ///
  /// A scena ferma due pietre non si toccano e nessuna esce dal campo: e' un
  /// rilassamento iterativo, deterministico perche' l'ordine delle coppie e'
  /// fisso e non c'e' nessun caso. Le semiestensioni sono in coordinate
  /// normalizzate del telo.
  static List<Offset> separaSenzaSovrapposizioni(
    List<Offset> punti,
    double semiLarghezza,
    double semiAltezza,
  ) {
    final p = List<Offset>.from(punti);
    // UN FILO D'ARIA OLTRE IL MINIMO: due pietre separate di esattamente la
    // loro misura si toccano bordo a bordo, e ai double basta un epsilon per
    // dichiararle sovrapposte. Il due per cento e' meno di un punto sul telo,
    // invisibile, ma rende la separazione vera invece che al limite.
    final minDx = semiLarghezza * 2 * 1.02;
    final minDy = semiAltezza * 2 * 1.02;
    for (var giro = 0; giro < 60; giro++) {
      var mosso = false;
      for (var i = 0; i < p.length; i++) {
        for (var j = i + 1; j < p.length; j++) {
          final dx = p[j].dx - p[i].dx;
          final dy = p[j].dy - p[i].dy;
          // Sovrapposte se vicine su TUTTI E DUE gli assi.
          final copertoX = minDx - dx.abs();
          final copertoY = minDy - dy.abs();
          if (copertoX > 0 && copertoY > 0) {
            mosso = true;
            // Si spinge lungo l'asse che chiede lo spostamento minore.
            if (copertoX < copertoY) {
              final spinta = copertoX / 2 * (dx >= 0 ? 1 : -1);
              p[i] = Offset(p[i].dx - spinta, p[i].dy);
              p[j] = Offset(p[j].dx + spinta, p[j].dy);
            } else {
              final spinta = copertoY / 2 * (dy >= 0 ? 1 : -1);
              p[i] = Offset(p[i].dx, p[i].dy - spinta);
              p[j] = Offset(p[j].dx, p[j].dy + spinta);
            }
          }
        }
      }
      // Il campo: nessuna pietra sborda, i bordi la respingono dentro.
      for (var i = 0; i < p.length; i++) {
        p[i] = Offset(
          p[i].dx.clamp(semiLarghezza, 1 - semiLarghezza),
          p[i].dy.clamp(semiAltezza, 1 - semiAltezza),
        );
      }
      if (!mosso) break;
    }
    return p;
  }

  /// Deriva il seme della fisica dai dati della gettata: persona, giorno,
  /// domanda e rune uscite. Stessi dati, stessa disposizione: e' l'hash FNV
  /// gia' usato dall'Oroscopo, non un caso vero.
  static int semeDa(String persona, DateTime giorno, String domanda,
      Iterable<String> runeUscite) {
    var h = 0x811c9dc5;
    void mangia(String s) {
      for (final c in s.codeUnits) {
        h ^= c;
        h = (h * 0x01000193) & 0x7fffffff;
      }
    }

    mangia(persona);
    mangia('${giorno.year}-${giorno.month}-${giorno.day}');
    mangia(domanda);
    runeUscite.forEach(mangia);
    return h;
  }
}

/// Un generatore lineare congruente, piccolo e riproducibile: la stessa
/// sequenza su ogni piattaforma, senza dipendere da come `dart:math` semina.
class _Lcg {
  _Lcg(int seme) : _stato = seme & 0x7fffffff;

  int _stato;

  double frazione() {
    _stato = (_stato * 48271) % 0x7fffffff;
    return _stato / 0x7fffffff;
  }
}
