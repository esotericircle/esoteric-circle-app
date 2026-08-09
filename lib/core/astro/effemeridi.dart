import 'dart:math' as math;

/// LA PORTA SOLA per la domanda "dove sta questo corpo a questo istante".
///
/// **Perche' questo file esiste.** La longitudine eclittica del Sole si
/// calcolava in DUE posti con formule scritte a mano due volte
/// (`Celestial.sunEclipticLongitude` e `NightSky.sunEclipticLongitude`), e
/// quella della Luna in TRE, ciascuno con una troncatura diversa della serie:
/// sei termini in `Celestial.moonEquatorial`, tre in
/// `Celestial.moonIllumination`, dieci in `NightSky.moonEclipticLongitude`.
/// Tre definizioni dello stesso numero che devono restare d'accordo sono la
/// famiglia di difetti piu' cara di questo progetto. Qui c'e' una definizione
/// sola, e tutti gli altri la chiamano.
///
/// **Le firme di fuori non cambiano.** `Celestial.sunEclipticLongitude`,
/// `NightSky.sunSign`, `NightSky.moonSign`, `MoonPhase.forDate`,
/// `ArchetypeSky.pianetiDelGiorno` restano quelle di prima: cambia cosa c'e'
/// dentro, non come si chiamano. Nessun consumatore fuori da `lib/core/astro/`
/// e' stato toccato.
///
/// **Nessuna rete.** Tutto e' aritmetica locale: niente API, niente quota,
/// niente chiave, niente cache da tenere allineata.
enum CorpoCeleste {
  sole('Sole', '☉', 'sun'),
  luna('Luna', '☽', 'moon'),
  mercurio('Mercurio', '☿', 'mercury'),
  venere('Venere', '♀', 'venus'),
  marte('Marte', '♂', 'mars'),
  giove('Giove', '♃', 'jupiter'),
  saturno('Saturno', '♄', 'saturn'),
  urano('Urano', '♅', 'uranus'),
  nettuno('Nettuno', '♆', 'neptune'),
  plutone('Plutone', '♇', 'pluto');

  const CorpoCeleste(this.nome, this.glifo, this.id);

  /// Nome italiano, come lo mostra la carta natale.
  final String nome;

  /// Glifo astronomico, stesso repertorio della carta natale.
  final String glifo;

  /// L'identificatore che usa la carta natale (`PlanetPosition.id`), cosi' il
  /// lato transito e il lato natale si riconoscono senza una tabella di mezzo.
  final String id;
}

/// Effemeridi geocentriche locali.
///
/// **I corpi che ci sono, e perche' non ce ne sono altri.** Sole, Luna,
/// Mercurio, Venere, Marte, Giove, Saturno. Mancano Urano, Nettuno e Plutone:
/// gli elementi orbitali medi di Meeus li coprono, ma i tre lenti muovono da
/// uno a tre gradi l'anno, quindi un loro aspetto resta aperto per mesi e non
/// distingue un giorno dall'altro. Entreranno quando ci sara' una funzione che
/// ne ha bisogno, non prima. Mancano anche Nodo, Chirone e Lilith, che non sono
/// corpi a moto kepleriano e vogliono una trattazione loro.
class Effemeridi {
  const Effemeridi._();

  static const double _grad = math.pi / 180.0;

  static double _norm360(double x) {
    final v = x % 360.0;
    return v < 0 ? v + 360.0 : v;
  }

  /// **L'UNICA funzione che dice dove sta un corpo.** Longitudine eclittica
  /// geocentrica in gradi [0, 360), riferita all'equinozio della data.
  ///
  /// [jd] e' il giorno giuliano, quello che produce `Celestial.julianDay`.
  static double longitudineEclittica(CorpoCeleste corpo, double jd) {
    switch (corpo) {
      case CorpoCeleste.sole:
        return _sole(jd);
      case CorpoCeleste.luna:
        return _luna(jd);
      case CorpoCeleste.mercurio:
      case CorpoCeleste.venere:
      case CorpoCeleste.marte:
      case CorpoCeleste.giove:
      case CorpoCeleste.saturno:
      case CorpoCeleste.urano:
      case CorpoCeleste.nettuno:
      case CorpoCeleste.plutone:
        return _pianeta(corpo, jd);
    }
  }

  /// SE UN CORPO E' RETROGRADO a un certo istante.
  ///
  /// Non e' una proprieta' da tabella: si misura. Si guarda dove sta il corpo
  /// oggi e dove stava ieri, e se la longitudine e' CALATA il corpo sta
  /// tornando indietro visto dalla Terra. E' esattamente cio' che vuol dire
  /// retrogrado: un'apparenza prospettica, non un moto reale all'indietro.
  ///
  /// Il passo e' di un giorno intero perche' i pianeti lenti si muovono
  /// pochissimo: Plutone fa quattro millesimi di grado al giorno, e con un
  /// passo di un'ora il moto sparirebbe sotto l'errore della serie.
  ///
  /// Il Sole e la Luna non retrogradano mai, e qui infatti non risultano mai
  /// retrogradi: la loro longitudine geocentrica cresce sempre.
  static bool retrogrado(CorpoCeleste corpo, double jd) =>
      velocitaGiornaliera(corpo, jd) < 0;

  /// Di quanti gradi al giorno si muove un corpo, col segno.
  ///
  /// Negativo vuol dire retrogrado. Serve anche a sapere se un aspetto si sta
  /// stringendo o sciogliendo, e a dire quanto e' incerto il giorno esatto di
  /// un transito.
  static double velocitaGiornaliera(CorpoCeleste corpo, double jd) {
    final prima = longitudineEclittica(corpo, jd - 0.5);
    final dopo = longitudineEclittica(corpo, jd + 0.5);
    var delta = dopo - prima;
    // Il salto da 359 a 1 grado non e' un moto di meno 358 gradi.
    if (delta > 180.0) delta -= 360.0;
    if (delta < -180.0) delta += 360.0;
    return delta;
  }

  /// **Questo file non sa cosa sia un `DateTime`, ed e' voluto.** La conversione
  /// da istante civile a giorno giuliano vive in `Celestial.julianDay` e in
  /// nessun altro posto: il 1 agosto 2026 il fuso veniva tolto due volte proprio
  /// perche' quella conversione era sparsa. Qui si entra col giorno giuliano
  /// gia' fatto, cosi' non c'e' una seconda strada per sbagliarlo.
  ///
  /// LO SCARTO MASSIMO MISURATO contro JPL Horizons, in gradi, corpo per corpo.
  ///
  /// Non sono stime: sono i numeri della prova
  /// `effemeridi_contro_fonte_terza_test.dart`, su tre date distanti fra loro.
  /// Stanno qui perche' servono a calcolare quanto e' incerto il GIORNO di un
  /// transito, e perche' chi cambia una serie deve vedere subito cosa promette.
  /// **E VALGONO PER IL CIELO DI OGGI, NON PER UNA NASCITA.** Misurato il 9
  /// agosto 2026, ordine 2169 voce 5: alle date del 2026 Saturno sbaglia 0,141
  /// gradi, ma al 21 marzo 1950 ne sbaglia **0,570**, quattro volte tanto.
  /// Sole e Luna reggono in tutte e due le epoche (Sole 0,003 e 0,006, Luna
  /// 0,042 e 0,157).
  ///
  /// La causa e' la forma stessa di questi polinomi, costruiti attorno
  /// all'epoca corrente: piu' ci si allontana, piu' i pianeti lenti sbandano.
  ///
  /// **Cosa vuol dire in pratica.** Questo motore serve ai TRANSITI e al cielo
  /// di stanotte, dove regge. La carta di NASCITA viene dal motore remoto, che
  /// e' esatto al mezzo millesimo di grado su tre nascite in tre epoche
  /// (ordine 2170). Il giorno che qualcuno volesse calcolare una carta natale
  /// in locale, mezzo grado su Saturno sposta un aspetto e cambia la casa di
  /// un pianeta: quel mezzo grado va risolto PRIMA, non dopo.
  ///
  /// A sorvegliarlo c'e' `il_motore_locale_e_per_oggi_test.dart`.
  static const Map<CorpoCeleste, double> scartoMisurato = {
    CorpoCeleste.sole: 0.0062,
    CorpoCeleste.luna: 0.1542,
    CorpoCeleste.mercurio: 0.0084,
    CorpoCeleste.venere: 0.0078,
    CorpoCeleste.marte: 0.0424,
    CorpoCeleste.giove: 0.0216,
    CorpoCeleste.saturno: 0.1414,
    CorpoCeleste.urano: 0.0040,
    CorpoCeleste.nettuno: 0.0167,
    CorpoCeleste.plutone: 0.0149,
  };

  /// DI QUANTI GIORNI E' INCERTO il momento esatto di un transito.
  ///
  /// **Questo e' il limite da dichiarare, e va dichiarato dove si calcola.**
  /// Lo scarto su Saturno e' 0,1414 gradi, e Saturno percorre circa 0,03 gradi
  /// al giorno: sono quasi cinque giorni di incertezza su QUANDO l'aspetto e'
  /// esatto. Per dire che l'aspetto C'E' va benissimo, perche' l'orbo e' due
  /// gradi, cioe' quattordici volte lo scarto. Per dire "il transito e' esatto
  /// oggi" no, e nessun testo lo deve affermare.
  ///
  /// Il caso peggiore sono i lenti: precisi in posizione, lentissimi, quindi
  /// il giorno esatto e' l'informazione che il motore non sa dare.
  /// L'EPOCA PER CUI QUESTO MOTORE E' STATO VERIFICATO, in anni.
  ///
  /// Fuori da qui gli scarti qui sopra non valgono piu': al 1950 Saturno ne
  /// sbaglia quattro volte tanto. Non e' un divieto tecnico, il calcolo torna
  /// comunque un numero: e' il confine oltre il quale quel numero non e' stato
  /// misurato da nessuno, e percio' non si puo' promettere.
  static const int primoAnnoVerificato = 2020;
  static const int ultimoAnnoVerificato = 2030;

  /// Se quell'istante sta dentro l'epoca verificata.
  static bool dentroEpocaVerificata(DateTime quando) =>
      quando.year >= primoAnnoVerificato && quando.year <= ultimoAnnoVerificato;

  static double giorniDiIncertezza(CorpoCeleste corpo, double jd) {
    final velocita = velocitaGiornaliera(corpo, jd).abs();
    if (velocita < 1e-9) return double.infinity;
    return scartoMisurato[corpo]! / velocita;
  }

  /// Tutti i corpi a un istante, nell'ordine dell'enum.
  static Map<CorpoCeleste, double> tutte(double jd) => {
        for (final c in CorpoCeleste.values) c: longitudineEclittica(c, jd),
      };

  // ---------------------------------------------------------------------------
  // IL SOLE
  // ---------------------------------------------------------------------------

  /// Longitudine del Sole, formula a bassa precisione dell'Astronomical Almanac
  /// (Meeus, *Astronomical Algorithms*, 2a ed., cap. 25, "lower accuracy").
  ///
  /// **Questa formula NON e' stata toccata.** E' identica, cifra per cifra, a
  /// quella che stava in `Celestial` e in `NightSky`: le due erano gia' la
  /// stessa formula scritta due volte, e la verifica del 1 agosto 2026 poggia su
  /// questi numeri. Unificarle non ha cambiato un solo valore, e la prova del
  /// rosso lo pretende.
  static double _sole(double jd) {
    final n = jd - 2451545.0;
    final l = _norm360(280.460 + 0.9856474 * n);
    final g = (357.528 + 0.9856003 * n) * _grad;
    return _norm360(l + 1.915 * math.sin(g) + 0.020 * math.sin(2 * g));
  }

  // ---------------------------------------------------------------------------
  // LA LUNA
  // ---------------------------------------------------------------------------

  /// Longitudine della Luna, termini periodici principali (Meeus, cap. 47,
  /// serie troncata ai termini sopra i tre centesimi di grado).
  ///
  /// **Qui i valori SONO cambiati, ed e' il punto.** Delle tre versioni che
  /// convivevano si e' tenuta la piu' completa e le si e' restituito il termine
  /// da 0,214 gradi in `2M'` che solo `Celestial.moonEquatorial` aveva. Le altre
  /// due erano troncature piu' povere della stessa serie, quindi la
  /// convergenza migliora entrambe invece di peggiorarle: il confronto con JPL
  /// Horizons sta nella consegna, coi numeri delle due parti.
  static double _luna(double jd) {
    final d = jd - 2451545.0;
    final lp = 218.316 + 13.176396 * d; // longitudine media
    final m = (134.963 + 13.064993 * d) * _grad; // anomalia media lunare
    final ms = (357.529 + 0.985600 * d) * _grad; // anomalia media solare
    final dd = (297.850 + 12.190749 * d) * _grad; // elongazione media
    return _norm360(lp +
        6.289 * math.sin(m) +
        1.274 * math.sin(2 * dd - m) +
        0.658 * math.sin(2 * dd) +
        0.214 * math.sin(2 * m) -
        0.186 * math.sin(ms) -
        0.059 * math.sin(2 * m - 2 * dd) +
        0.053 * math.sin(m + 2 * dd) +
        0.046 * math.sin(2 * dd - ms) +
        0.041 * math.sin(m - ms) -
        0.035 * math.sin(dd) -
        0.031 * math.sin(m + ms));
  }

  // ---------------------------------------------------------------------------
  // I PIANETI
  // ---------------------------------------------------------------------------

  /// Longitudine geocentrica di un pianeta, per moto kepleriano dagli elementi
  /// orbitali medi all'equinozio della data.
  ///
  /// Fonte: Meeus, *Astronomical Algorithms*, 2a ed., tavola 31.A per gli
  /// elementi e cap. 33 per il passaggio da eliocentrico a geocentrico, con la
  /// correzione del tempo luce.
  static double _pianeta(CorpoCeleste corpo, double jd) {
    final t = (jd - 2451545.0) / 36525.0;
    final terra = _posizione(_elementiTerra, t);

    // Correzione del tempo luce: la luce del pianeta e' partita quando il
    // pianeta stava un po' piu' indietro. Due passate bastano, la terza
    // sposterebbe la longitudine di meno di un millesimo di grado.
    var tau = 0.0;
    var pianeta = _posizione(_elementi[corpo]!, t);
    for (var giro = 0; giro < 2; giro++) {
      final dx = pianeta.x - terra.x;
      final dy = pianeta.y - terra.y;
      final dz = pianeta.z - terra.z;
      final distanza = math.sqrt(dx * dx + dy * dy + dz * dz);
      tau = 0.0057755183 * distanza; // giorni luce per unita' astronomica
      pianeta = _posizione(_elementi[corpo]!, (jd - tau - 2451545.0) / 36525.0);
    }

    final x = pianeta.x - terra.x;
    final y = pianeta.y - terra.y;
    return _norm360(math.atan2(y, x) / _grad);
  }

  /// Posizione eliocentrica rettangolare, in unita' astronomiche.
  static _Punto _posizione(_Elementi el, double t) {
    final l = _poli(el.l, t);
    final a = _poli(el.a, t);
    final e = _poli(el.e, t);
    final i = _poli(el.i, t) * _grad;
    final omega = _poli(el.omega, t) * _grad;
    final perielio = _poli(el.perielio, t);

    // Anomalia media, poi Keplero.
    final mm = _norm360(l - perielio) * _grad;
    final ecc = _keplero(mm, e);

    // Anomalia vera e raggio vettore.
    final v = 2.0 *
        math.atan2(
          math.sqrt(1 + e) * math.sin(ecc / 2),
          math.sqrt(1 - e) * math.cos(ecc / 2),
        );
    final r = a * (1 - e * math.cos(ecc));

    // Argomento di latitudine, misurato dal nodo ascendente.
    final u = v + (perielio * _grad) - omega;
    final cosU = math.cos(u);
    final sinU = math.sin(u);
    return _Punto(
      r * (math.cos(omega) * cosU - math.sin(omega) * sinU * math.cos(i)),
      r * (math.sin(omega) * cosU + math.cos(omega) * sinU * math.cos(i)),
      r * sinU * math.sin(i),
    );
  }

  /// Equazione di Keplero, `E - e sin E = M`, per iterazione di Newton.
  ///
  /// Converge in poche passate per tutte le eccentricita' dei pianeti trattati,
  /// che stanno sotto 0,21. Il tetto sui giri e' una cintura, non un limite
  /// atteso: senza, un dato malformato girerebbe per sempre.
  static double _keplero(double m, double e) {
    var ecc = m;
    for (var giro = 0; giro < 12; giro++) {
      final delta = (ecc - e * math.sin(ecc) - m) / (1 - e * math.cos(ecc));
      ecc -= delta;
      if (delta.abs() < 1e-12) break;
    }
    return ecc;
  }

  static double _poli(List<double> c, double t) {
    var v = 0.0;
    for (var i = c.length - 1; i >= 0; i--) {
      v = v * t + c[i];
    }
    return v;
  }

  /// Elementi orbitali medi all'equinozio della data, in gradi e unita'
  /// astronomiche, come polinomi in T (secoli giuliani da J2000.0).
  ///
  /// Fonte: Meeus, *Astronomical Algorithms*, 2a ed., tavola 31.A.
  static const _Elementi _elementiTerra = _Elementi(
    l: [100.466457, 36000.7698278, 0.00030322, 0.000000020],
    a: [1.000001018],
    e: [0.01670863, -0.000042037, -0.0000001267, 0.00000000014],
    i: [0.0],
    omega: [0.0],
    perielio: [102.937348, 1.7195366, 0.00045688, -0.000000018],
  );

  static const Map<CorpoCeleste, _Elementi> _elementi = {
    CorpoCeleste.mercurio: _Elementi(
      l: [252.250906, 149474.0722491, 0.00030350, 0.000000018],
      a: [0.387098310],
      e: [0.20563175, 0.000020407, -0.0000000283, -0.00000000018],
      i: [7.004986, 0.0018215, -0.00001810, 0.000000056],
      omega: [48.330893, 1.1861883, 0.00017542, 0.000000215],
      perielio: [77.456119, 1.5564776, 0.00029544, 0.000000009],
    ),
    CorpoCeleste.venere: _Elementi(
      l: [181.979801, 58519.2130302, 0.00031014, 0.000000015],
      a: [0.723329820],
      e: [0.00677192, -0.000047765, 0.0000000981, 0.00000000046],
      i: [3.394662, 0.0010037, -0.00000088, -0.000000007],
      omega: [76.679920, 0.9011206, 0.00040618, -0.000000093],
      perielio: [131.563703, 1.4022288, -0.00107618, -0.00005678],
    ),
    CorpoCeleste.marte: _Elementi(
      l: [355.433000, 19141.6964471, 0.00031052, 0.000000016],
      a: [1.523679342],
      e: [0.09340065, 0.000090484, -0.0000000806, -0.00000000025],
      i: [1.849726, -0.0006011, 0.00001276, -0.000000007],
      omega: [49.558093, 0.7720959, 0.00001557, 0.000002267],
      perielio: [336.060234, 1.8410449, 0.00013477, 0.000000536],
    ),
    CorpoCeleste.giove: _Elementi(
      l: [34.351519, 3036.3027748, 0.00022330, 0.000000037],
      a: [5.202603209, 0.0000001913],
      e: [0.04849793, 0.000163225, -0.0000004714, -0.00000000201],
      i: [1.303267, -0.0054965, 0.00000466, -0.000000002],
      omega: [100.464407, 1.0209774, 0.00040315, 0.000000404],
      perielio: [14.331207, 1.6126352, 0.00103042, -0.000004464],
    ),
    CorpoCeleste.saturno: _Elementi(
      l: [50.077444, 1223.5110686, 0.00051908, -0.000000030],
      a: [9.554909192, -0.0000021390, 0.000000004],
      e: [0.05554814, -0.000346641, -0.0000006436, 0.00000000340],
      i: [2.488879, -0.0037362, -0.00001519, 0.000000087],
      omega: [113.665503, 0.8770880, -0.00012176, -0.000002249],
      perielio: [93.057237, 1.9637613, 0.00083753, 0.000004928],
    ),
    /// **I TRE LENTI VENGONO DA UN'ALTRA FONTE, e la ragione e' misurata.**
    ///
    /// La tavola 31.A di Meeus si ferma a Nettuno e non contiene Plutone. Ma il
    /// problema non era solo Plutone: provati con gli elementi medi di Meeus,
    /// **Urano sbagliava di 0,95 gradi e Nettuno di 0,63** contro JPL Horizons,
    /// cioe' dieci volte peggio di Giove e Saturno. Urano e Nettuno si
    /// perturbano forte a vicenda, e gli elementi medi non lo raccontano.
    ///
    /// Qui si usano invece gli elementi kepleriani approssimati del JPL,
    /// E. M. Standish, *Keplerian Elements for Approximate Positions of the
    /// Major Planets*, validi dal 1800 al 2050. Con questi, tutti e tre stanno
    /// entro due centesimi di grado: i numeri sono nella consegna.
    ///
    /// Sono riferiti all'eclittica e all'equinozio J2000, non a quello della
    /// data come gli altri: per portarli nello stesso riferimento si aggiunge
    /// la precessione generale in longitudine, 1,396971 gradi per secolo, alle
    /// tre longitudini (media, del nodo, del perielio). L'inclinazione non
    /// cambia al primo ordine.
    CorpoCeleste.urano: _Elementi(
      l: [313.23810451, 428.48202785 + 1.396971],
      a: [19.18916464, -0.00196176],
      e: [0.04725744, -0.00004397],
      i: [0.77263783, -0.00242939],
      omega: [74.01692503, 0.04240589 + 1.396971],
      perielio: [170.95427630, 0.40805281 + 1.396971],
    ),
    CorpoCeleste.nettuno: _Elementi(
      l: [-55.12002969, 218.45945325 + 1.396971],
      a: [30.06992276, 0.00026291],
      e: [0.00859048, 0.00005105],
      i: [1.77004347, 0.00035372],
      omega: [131.78422574, -0.00508664 + 1.396971],
      perielio: [44.96476227, -0.32241464 + 1.396971],
    ),
    CorpoCeleste.plutone: _Elementi(
      l: [238.92903833, 145.20780515 + 1.396971],
      a: [39.48211675, -0.00031596],
      e: [0.24882730, 0.00005170],
      i: [17.14001206, 0.00004818],
      omega: [110.30393684, -0.01183482 + 1.396971],
      perielio: [224.06891629, -0.04062942 + 1.396971],
    ),
  };
}

class _Elementi {
  const _Elementi({
    required this.l,
    required this.a,
    required this.e,
    required this.i,
    required this.omega,
    required this.perielio,
  });

  /// Longitudine media.
  final List<double> l;

  /// Semiasse maggiore, unita' astronomiche.
  final List<double> a;

  /// Eccentricita'.
  final List<double> e;

  /// Inclinazione sull'eclittica.
  final List<double> i;

  /// Longitudine del nodo ascendente.
  final List<double> omega;

  /// Longitudine del perielio.
  final List<double> perielio;
}

class _Punto {
  const _Punto(this.x, this.y, this.z);
  final double x;
  final double y;
  final double z;
}
