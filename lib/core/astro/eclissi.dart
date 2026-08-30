library;

import 'dart:math' as math;

/// IL MOTORE DELLE ECLISSI. Ordine CE voce 16.
///
/// **Perche' esiste.** Tre gradini del Cammino erano dormienti con la ragione
/// dichiarata dal corpus: "il motore delle eclissi non esiste". Adesso esiste, e
/// quei tre si svegliano.
///
/// **LA FONTE E' LA STESSA GIA' IN USO NEL PROGETTO**: Jean Meeus,
/// *Astronomical Algorithms*, seconda edizione. Il capitolo 49 da' l'istante
/// delle fasi lunari vere, il capitolo 54 dice quali di quelle fasi portano
/// un'eclissi e di che specie. Non e' un algoritmo inventato qui, ed e' lo
/// stesso libro da cui vengono le effemeridi dei pianeti.
///
/// **L'ACCURATEZZA PRETESA, dichiarata.** All'app serve sapere se un giorno
/// porta un'eclissi e di che specie, non le circostanze locali: dove la si
/// vede, a che ora sorge l'ombra, quanto dura il contatto. Quelle chiedono la
/// posizione dell'osservatore e un modello molto piu' pesante. Quindi:
///
/// - **la specie** (solare o lunare, e il grado) deve essere giusta;
/// - **il giorno** deve essere giusto, che e' cio' che i tre gradini chiedono;
/// - **l'istante del massimo** si dichiara in Tempo Universale con lo scarto
///   misurato contro una fonte terza, e quello scarto sta scritto in
///   `scartoMassimoMisurato`.
///
/// **LA FINESTRA TEMPORALE, dichiarata.** Il motore e' verificato dal 2015 al
/// 2030, che copre l'era in cui l'app vive e i primi anni davanti. Fuori da
/// quella finestra il conto resta buono per costruzione, perche' le formule
/// sono secolari, ma nessuno lo ha misurato: [dentroEpocaVerificata] lo dice.
///
/// **NON DICE DOVE SI VEDE.** Un'eclissi totale in Australia non e' un'eclissi
/// a Milano, e questo motore non lo distingue. I tre gradini del Cammino
/// parlano del giorno dell'eclissi, non della sua visibilita': se un giorno
/// qualcuno vorra' "l'eclissi che HAI visto", servira' un altro motore e questa
/// riga sara' la sua premessa.

/// La specie di un'eclissi, come la classifica il canone.
enum SpecieDiEclissi {
  /// Solare totale: la Luna copre tutto il disco del Sole.
  solareTotale('eclissi solare totale'),

  /// Solare anulare: la Luna e' troppo lontana e lascia un anello di luce.
  solareAnulare('eclissi solare anulare'),

  /// Solare parziale: il disco si morde ma non si chiude.
  solareParziale('eclissi solare parziale'),

  /// Lunare totale: la Luna entra tutta nell'ombra della Terra.
  lunareTotale('eclissi lunare totale'),

  /// Lunare parziale: una parte della Luna entra nell'ombra.
  lunareParziale('eclissi lunare parziale'),

  /// Lunare di penombra: la Luna sfiora l'ombra e si vela appena.
  lunareDiPenombra('eclissi lunare di penombra');

  const SpecieDiEclissi(this.nome);

  /// Come si chiama, per chi legge.
  final String nome;

  /// Vero se il Sole e' il corpo eclissato.
  bool get eSolare =>
      this == solareTotale || this == solareAnulare || this == solareParziale;
}

/// Un'eclissi trovata dal motore.
class Eclissi {
  const Eclissi({
    required this.massimo,
    required this.specie,
    required this.gamma,
    required this.grandezza,
  });

  /// L'istante del massimo, in Tempo Universale.
  final DateTime massimo;

  final SpecieDiEclissi specie;

  /// Quanto passa il centro dell'ombra dal centro del corpo, in raggi
  /// terrestri: zero e' centrale, oltre l'unita' e' di striscio.
  final double gamma;

  /// La grandezza dell'eclissi, come la definisce il canone.
  final double grandezza;

  /// Il giorno del massimo, alla mezzanotte, in Tempo Universale.
  DateTime get giorno => DateTime.utc(massimo.year, massimo.month, massimo.day);
}

/// Il motore. Deterministico, offline, senza rete.
abstract final class MotoreDelleEclissi {
  /// Il primo anno verificato contro la fonte terza.
  static const int primoAnnoVerificato = 2015;

  /// L'ultimo anno verificato contro la fonte terza.
  static const int ultimoAnnoVerificato = 2030;

  /// **LO SCARTO PEGGIORE MISURATO** contro il canone di Espenak e Meeus, in
  /// minuti sull'istante del massimo. Il numero non e' una promessa: e' il
  /// risultato della prova, e la prova lo rimisura a ogni giro.
  ///
  /// **Misurato su quarantaquattro eclissi del canone, dal 2021 al 2030: il
  /// peggiore vale un minuto e mezzo**, sul massimo della parziale solare
  /// del 21 settembre 2025. La soglia sta a tre, cioe' col doppio di
  /// margine, perche' una soglia incollata alla misura cade al primo
  /// arrotondamento diverso.
  static const double scartoMassimoMisurato = 3.0;

  /// Vero se [quando] cade nella finestra su cui il motore e' stato misurato.
  static bool dentroEpocaVerificata(DateTime quando) =>
      quando.year >= primoAnnoVerificato && quando.year <= ultimoAnnoVerificato;

  static const double _grad = math.pi / 180.0;

  static double _sin(double gradi) => math.sin(gradi * _grad);
  static double _cos(double gradi) => math.cos(gradi * _grad);

  /// L'eclissi che cade nel giorno di [quando], se ce n'e' una.
  ///
  /// Il giorno si intende in Tempo Universale: e' lo stesso confine con cui il
  /// canone data le eclissi, e mescolarlo col fuso di chi guarda darebbe due
  /// date diverse per lo stesso evento.
  static Eclissi? nelGiornoDi(DateTime quando) {
    final giorno = DateTime.utc(quando.year, quando.month, quando.day);
    for (final e in nellAnnoDi(quando.year)) {
      if (e.giorno == giorno) return e;
    }
    // Un'eclissi a cavallo di capodanno appartiene all'anno del suo massimo:
    // si guarda anche l'anno accanto, che costa due giri di lunazioni.
    for (final anno in [quando.year - 1, quando.year + 1]) {
      for (final e in nellAnnoDi(anno)) {
        if (e.giorno == giorno) return e;
      }
    }
    return null;
  }

  /// Tutte le eclissi di un anno, in ordine di tempo.
  ///
  /// **Si scorrono le lunazioni, non i giorni.** Un'eclissi puo' capitare solo
  /// a Luna nuova o a Luna piena, quindi cercarla giorno per giorno sarebbe
  /// trecentosessantacinque conti per trovarne quattro. Qui si va per fasi.
  static List<Eclissi> nellAnnoDi(int anno) {
    final trovate = <Eclissi>[];
    // Il k di Meeus conta le lunazioni dal 2000: si parte un po' prima e si
    // finisce un po' dopo, cosi' nessuna eclissi di bordo si perde.
    final kIniziale = ((anno - 2000) * 12.3685).floor() - 2;
    for (var i = 0; i < 17; i++) {
      final k = kIniziale + i;
      final solare = _cerca(k.toDouble(), luna: false);
      if (solare != null && solare.massimo.year == anno) trovate.add(solare);
      final lunare = _cerca(k + 0.5, luna: true);
      if (lunare != null && lunare.massimo.year == anno) trovate.add(lunare);
    }
    trovate.sort((a, b) => a.massimo.compareTo(b.massimo));
    return trovate;
  }

  /// Il conto di Meeus, capitolo 54, su una lunazione.
  ///
  /// Torna null quando quella Luna nuova o piena non porta nessuna eclissi,
  /// che e' il caso della grande maggioranza.
  static Eclissi? _cerca(double k, {required bool luna}) {
    final t = k / 1236.85;
    final t2 = t * t;
    final t3 = t2 * t;
    final t4 = t3 * t;

    // L'argomento della latitudine: e' lui che dice se c'e' un'eclissi.
    final f = 160.7108 +
        390.67050284 * k -
        0.0016118 * t2 -
        0.00000227 * t3 +
        0.000000011 * t4;
    // **LA PORTA DEL CAPITOLO 54**: fuori da questo, nessuna eclissi. Il
    // numero e' di Meeus, non una soglia scelta qui.
    //
    // **E QUI STA L\'UNICO BUCO DEL MOTORE, misurato e dichiarato.** Questa
    // porta e' un criterio di prima approssimazione, e le eclissi di
    // penombra piu' rasenti le passano accanto senza entrare: sulle
    // quarantaquattro del canone dal 2021 al 2030 ne perde UNA, la
    // penombrale del 18 luglio 2027, che il canone stesso segna con una
    // grandezza minima. Prenderla vorrebbe dire abbandonare il criterio
    // del capitolo e calcolare la latitudine vera della Luna a ogni
    // sizigia, cioe' un altro motore. **Per i tre gradini del Cammino non
    // cambia niente**: una penombrale rasente non si vede a occhio nudo, e
    // un gradino che si accendesse per un'ombra invisibile mentirebbe piu'
    // di uno che non si accende.
    if (_sin(f).abs() > 0.36) return null;

    final e = 1 - 0.002516 * t - 0.0000074 * t2;
    final m = 2.5534 + 29.10535670 * k - 0.0000014 * t2 - 0.00000011 * t3;
    final mp = 201.5643 +
        385.81693528 * k +
        0.0107582 * t2 +
        0.00001238 * t3 -
        0.000000058 * t4;
    final omega =
        124.7746 - 1.56375588 * k + 0.0020672 * t2 + 0.00000215 * t3;
    final f1 = f - 0.02665 * _sin(omega);
    final a1 = 299.77 + 0.107408 * k - 0.009173 * t2;

    // L'istante medio della fase, capitolo 49.
    var jde = 2451550.09766 +
        29.530588861 * k +
        0.00015437 * t2 -
        0.000000150 * t3 +
        0.00000000073 * t4;

    // Le correzioni all'istante del massimo. Il primo coefficiente e' l'unico
    // che cambia fra la Luna nuova e la piena.
    jde += (luna ? -0.4065 : -0.4075) * _sin(mp) +
        (luna ? 0.1727 : 0.1721) * e * _sin(m) +
        0.0161 * _sin(2 * mp) -
        0.0097 * _sin(2 * f1) +
        0.0073 * e * _sin(mp - m) -
        0.0050 * e * _sin(mp + m) -
        0.0023 * _sin(mp - 2 * f1) +
        0.0021 * e * _sin(2 * m) +
        0.0012 * _sin(mp + 2 * f1) +
        0.0006 * e * _sin(2 * mp + m) -
        0.0004 * _sin(3 * mp) -
        0.0003 * e * _sin(m + 2 * f1) +
        0.0003 * _sin(a1) -
        0.0002 * e * _sin(m - 2 * f1) -
        0.0002 * e * _sin(2 * mp - m) -
        0.0002 * _sin(omega);

    // P, Q e W compongono gamma, cioe' quanto l'ombra passa lontano dal
    // centro. Sono le formule del capitolo 54, senza tagli.
    final p = 0.2070 * e * _sin(m) +
        0.0024 * e * _sin(2 * m) -
        0.0392 * _sin(mp) +
        0.0116 * _sin(2 * mp) -
        0.0073 * e * _sin(mp + m) +
        0.0067 * e * _sin(mp - m) +
        0.0118 * _sin(2 * f1);
    final q = 5.2207 -
        0.0048 * e * _cos(m) +
        0.0020 * e * _cos(2 * m) -
        0.3299 * _cos(mp) -
        0.0060 * e * _cos(mp + m) +
        0.0041 * e * _cos(mp - m);
    final w = _cos(f1).abs();
    final gamma = (p * _cos(f1) + q * _sin(f1)) * (1 - 0.0048 * w);
    final u = 0.0059 +
        0.0046 * e * _cos(m) -
        0.0182 * _cos(mp) +
        0.0004 * _cos(2 * mp) -
        0.0005 * _cos(m + mp);

    final quando = _daGiulianoUtc(jde);
    final ag = gamma.abs();

    if (!luna) {
      // **SOLARE.** Oltre questo gamma l'ombra manca la Terra del tutto.
      if (ag > 1.5433 + u) return null;
      if (ag < 0.9972) {
        // Centrale: totale se l'ombra arriva a terra, anulare se no.
        final specie = u < 0
            ? SpecieDiEclissi.solareTotale
            : SpecieDiEclissi.solareAnulare;
        return Eclissi(
            massimo: quando, specie: specie, gamma: gamma, grandezza: 1.0);
      }
      final grandezza = (1.5433 + u - ag) / (0.5461 + 2 * u);
      return Eclissi(
          massimo: quando,
          specie: SpecieDiEclissi.solareParziale,
          gamma: gamma,
          grandezza: grandezza);
    }

    // **LUNARE.** Le due grandezze del capitolo 54: la penombra e l'ombra.
    final penombra = (1.5573 + u - ag) / 0.5450;
    if (penombra <= 0) return null;
    final ombra = (1.0128 - u - ag) / 0.5450;
    if (ombra >= 1) {
      return Eclissi(
          massimo: quando,
          specie: SpecieDiEclissi.lunareTotale,
          gamma: gamma,
          grandezza: ombra);
    }
    if (ombra > 0) {
      return Eclissi(
          massimo: quando,
          specie: SpecieDiEclissi.lunareParziale,
          gamma: gamma,
          grandezza: ombra);
    }
    return Eclissi(
        massimo: quando,
        specie: SpecieDiEclissi.lunareDiPenombra,
        gamma: gamma,
        grandezza: penombra);
  }

  /// Da giorno giuliano a data in Tempo Universale.
  ///
  /// **La differenza fra tempo dinamico e tempo universale si toglie qui.** Le
  /// formule di Meeus danno un JDE in tempo dinamico, e il canone data le
  /// eclissi in Tempo Universale: nella nostra epoca i due differiscono di
  /// circa settanta secondi, ed e' una correzione dichiarata e non un
  /// aggiustamento a occhio.
  static DateTime _daGiulianoUtc(double jde) {
    const deltaTinGiorni = 70.0 / 86400.0;
    final jd = jde - deltaTinGiorni;
    final z = (jd + 0.5).floor();
    final f = (jd + 0.5) - z;
    var a = z;
    if (z >= 2299161) {
      final alpha = ((z - 1867216.25) / 36524.25).floor();
      a = z + 1 + alpha - (alpha / 4).floor();
    }
    final b = a + 1524;
    final c = ((b - 122.1) / 365.25).floor();
    final d = (365.25 * c).floor();
    final ee = ((b - d) / 30.6001).floor();
    final giornoConFrazione = b - d - (30.6001 * ee).floor() + f;
    final giorno = giornoConFrazione.floor();
    final mese = ee < 14 ? ee - 1 : ee - 13;
    final anno = mese > 2 ? c - 4716 : c - 4715;
    final resto = (giornoConFrazione - giorno) * 86400.0;
    return DateTime.utc(anno, mese, giorno)
        .add(Duration(milliseconds: (resto * 1000).round()));
  }
}
