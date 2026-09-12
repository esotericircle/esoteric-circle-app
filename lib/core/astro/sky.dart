import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart' show rootBundle;

import 'birth_details.dart';
import 'birth_place.dart';
import 'celestial.dart';
import 'moon_phase.dart';

/// Una costellazione del catalogo: stelle in coordinate equatoriali J2000 e le
/// linee che le uniscono.
class CatalogConstellation {
  const CatalogConstellation({
    required this.name,
    required this.stars,
    required this.lines,
  });

  final String name;

  /// Ogni stella e' [ascensione retta gradi, declinazione gradi, magnitudine].
  final List<List<double>> stars;
  final List<List<int>> lines;
}

/// Il catalogo di stelle luminose, caricato una volta dal bundle.
class SkyCatalog {
  SkyCatalog(this.constellations);
  final List<CatalogConstellation> constellations;

  static SkyCatalog? _cache;

  static Future<SkyCatalog> load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/data/bright_stars.json');
    final data = json.decode(raw) as Map<String, dynamic>;
    final list = <CatalogConstellation>[];
    for (final c in data['constellations'] as List) {
      final m = c as Map<String, dynamic>;
      list.add(CatalogConstellation(
        name: m['name'] as String,
        stars: [
          for (final s in m['stars'] as List)
            [for (final v in s as List) (v as num).toDouble()]
        ],
        lines: [
          for (final l in m['lines'] as List)
            [for (final v in l as List) (v as num).toInt()]
        ],
      ));
    }
    return _cache = SkyCatalog(list);
  }
}

/// L'ALTEZZA SOTTO LA QUALE UN ASTRO E' TRAMONTATO, in gradi.
///
/// **Perche' e' un dato solo.** Era quattro numeri sparsi che non concordavano:
/// il motore filtrava a meno due, le costellazioni ambientali a zero, la Luna a
/// meno tre, e la scheda che risponde controllava a meno cinque. Chi sta fra
/// meno cinque e meno due era quindi FILTRATO dal motore e cercato dalla scheda:
/// il messaggio giusto, "adesso sta sotto il suolo", era codice morto e al suo
/// posto usciva quello sbagliato, "non sta fra quelle che il motore segue".
///
/// Meno due e non zero: la rifrazione atmosferica alza di circa mezzo grado cio'
/// che sta appena sotto la linea, e un margine stretto evita che un astro sparisca
/// e ricompaia a ogni ricalcolo.
const double kAltezzaOrizzonte = -2;

/// Una stella proiettata sull'orizzonte dell'osservatore.
class SkyStar {
  const SkyStar({required this.altDeg, required this.azDeg, required this.mag});
  final double altDeg;
  final double azDeg;
  final double mag;
}

class SkyConstellation {
  const SkyConstellation({
    required this.name,
    required this.stars,
    required this.lines,
  });
  final String name;
  final List<SkyStar> stars;
  final List<List<int>> lines;

  /// Vera se almeno una stella e' sopra l'orizzonte.
  bool get anyVisible => stars.any((s) => s.altDeg > kAltezzaOrizzonte);
}

/// Il cielo autentico di un istante, visto da un luogo: costellazioni proiettate,
/// Luna nella sua posizione e fase reali, e l'azimut su cui centrare lo sguardo.
class SkySnapshot {
  const SkySnapshot({
    required this.constellations,
    required this.moon,
    required this.moonPhase,
    required this.centerAzDeg,
    required this.hasTime,
    required this.latitude,
    required this.longitude,
    required this.istanteLocale,
    required this.istanteUtc,
  });

  final List<SkyConstellation> constellations;
  final SkyStar? moon;
  final MoonIllumination moonPhase;

  /// Azimut su cui e' bello centrare lo sguardo iniziale (la Luna se e' alta,
  /// altrimenti la regione di cielo piu' ricca).
  final double centerAzDeg;
  final bool hasTime;

  /// La latitudine da cui questa volta e' vista. Vive qui, e non si ripesca dai
  /// dati di nascita, perche' una volta celeste sa da dove e' guardata: chi ne
  /// compone i testi, per esempio per l'emisfero della stagione, la trova qui.
  final double latitude;

  /// La longitudine usata. Come la latitudine: chi mostra i valori del calcolo
  /// li deve poter leggere dallo snapshot, non ricostruire per conto proprio.
  final double longitude;

  /// L'istante locale usato per il calcolo.
  final DateTime istanteLocale;

  /// L'istante in tempo universale a cui il calcolo e' stato fatto.
  ///
  /// Serve alla trasparenza: chi confronta con un'effemeride ha bisogno di
  /// sapere a che UT guardare, altrimenti non puo' confrontare niente.
  final DateTime istanteUtc;

  /// La posizione della Luna nel ciclo, da 0 (nuova) a 1.
  double get faseLunare => moonPhase.elongationDeg / 360.0;

  /// Il nome italiano della fase, dalla nomenclatura unica.
  String get nomeFaseLunare => MoonPhase.nomeItaliano(faseLunare);

  /// Le costellazioni sopra l'orizzonte adesso, per nome.
  List<String> get nomiVisibili => [
        for (final c in constellations)
          if (c.stars.any((s) => s.altDeg > kAltezzaOrizzonte)) c.name,
      ];
}

/// Costruisce l'istantanea del cielo per i dati di nascita, visto da [place].
///
/// Il fuso civile non e' noto in locale come offset: si usa il tempo medio
/// locale del luogo (dalla longitudine), che colloca il cielo con buona fedelta'
/// senza dipendere da tabelle esterne. Se l'ora manca, si usa la notte simbolica
/// (mezzanotte) del giorno.
///
/// Il luogo e' un parametro a se', obbligatorio, e non si prende piu' da
/// [details], dove ora puo' mancare: una volta celeste senza un punto da cui
/// guardarla non esiste, e chi il luogo non ce l'ha deve fermarsi prima invece
/// di riceverne una calcolata su coordinate inventate.
SkySnapshot buildSkySnapshot(
    SkyCatalog catalog, BirthDetails details, BirthPlace place) {
  // Istante locale: ora reale se c'e', altrimenti la mezzanotte simbolica.
  final local = details.hasTime
      ? DateTime(details.date.year, details.date.month, details.date.day,
          details.time!.hour, details.time!.minute)
      : DateTime(details.date.year, details.date.month, details.date.day, 0, 0);
  return buildSkyFor(catalog, local, place, hasTime: details.hasTime);
}

/// IL PUNTO DELLA FIGURA DI CUI SI PARLA: la sua stella piu' luminosa.
///
/// **Perche' serve dichiararlo.** Le stelle della Bilancia stanno fra 0,8 e 13
/// gradi di altezza NELLO STESSO ISTANTE: dire "13 gradi" senza dire di cosa
/// non e' un dato, e' un numero. Se ne parla la stella piu' luminosa, che e'
/// quella che una persona all'aperto trova per prima e l'unica che si possa
/// indicare col dito.
///
/// **E vale per tutti.** Prima l'altezza era il massimo fra le stelle e la
/// direzione quella della prima dell'elenco, cioe' due stelle diverse nella
/// stessa frase. Adesso il punto e' uno, e chi lo vuole passa da qui.
///
/// Torna nullo se nessuna stella della figura sta sopra l'orizzonte.
SkyStar? puntoDellaFigura(List<SkyStar> stelle) {
  SkyStar? migliore;
  for (final s in stelle) {
    if (s.altDeg <= kAltezzaOrizzonte) continue;
    // A PARITA' DI LUCE VINCE LA PIU' ALTA, e non e' un dettaglio: nella
    // Bilancia due stelle hanno la stessa magnitudine e stanno a 13 e a 3,8
    // gradi. Senza questa regola il punto dipendeva dall'ordine in cui il
    // catalogo le elenca, cioe' da niente, e la stessa figura poteva
    // rispondere due altezze diverse allo stesso istante. Fra due luci uguali
    // si indica quella che si vede meglio.
    if (migliore == null ||
        s.mag < migliore.mag ||
        (s.mag == migliore.mag && s.altDeg > migliore.altDeg)) {
      migliore = s;
    }
  }
  return migliore;
}

/// QUANDO UN CORPO SORGE, cercandolo nelle ventiquattro ore dopo [da].
///
/// **Perche' esiste.** La regola e' che niente si disegna senza poter dire
/// dov'era: un corpo sotto l'orizzonte o non compare, oppure compare
/// DICHIARANDO che era sotto e quando sorse. Senza quest'ora la seconda strada
/// non e' percorribile, e resta solo il silenzio che il fondatore ha
/// fotografato toccando l'Ariete.
///
/// Si cerca a passi di dieci minuti e poi si affina al minuto: e' un attraversamento
/// di orizzonte, non un'effemeride, e dieci minuti non lo mancano mai. Torna
/// nullo se il corpo non sorge affatto nelle ventiquattro ore, che alle nostre
/// latitudini vuol dire circumpolare al contrario, cioe' mai visibile.
DateTime? quandoSorge(
  SkyCatalog catalog,
  String nomeFigura,
  DateTime da,
  BirthPlace place,
) {
  bool sopra(DateTime t) {
    final cielo = buildSkyFor(catalog, t, place);
    for (final c in cielo.constellations) {
      if (c.name.toLowerCase() != nomeFigura.toLowerCase()) continue;
      return puntoDellaFigura(c.stars) != null;
    }
    return false;
  }

  if (sopra(da)) return da;
  var precedente = da;
  for (var m = 10; m <= 24 * 60; m += 10) {
    final t = da.add(Duration(minutes: m));
    if (!sopra(t)) {
      precedente = t;
      continue;
    }
    // Affinamento al minuto dentro l'intervallo trovato.
    for (var k = 1; k <= 10; k++) {
      final f = precedente.add(Duration(minutes: k));
      if (sopra(f)) return f;
    }
    return t;
  }
  return null;
}

/// LA MEZZANOTTE DELLA NOTTE CHE VIENE, l'unico istante della schermata del
/// cielo.
///
/// La schermata nasce come "le costellazioni all'opposizione, cioe' alte a
/// mezzanotte stanotte": e' quello che il motore calcola e quello che ha senso
/// per un'app che si guarda di sera. La parola "adesso" e' arrivata dopo, e ha
/// prodotto una schermata che si dichiarava in tempo reale mentre mostrava la
/// notte, cioe' una contraddizione misurabile.
///
/// LA REGOLA, dichiarata qui e in nessun altro posto: prima di mezzogiorno la
/// notte che viene e' quella gia' cominciata, cioe' la mezzanotte di oggi
/// appena passata; da mezzogiorno in poi e' la mezzanotte che deve ancora
/// arrivare. Chi guarda alle due di notte non vuole sentirsi dire "domani".
DateTime mezzanotteDellaNotteCheViene(DateTime adesso) {
  final giorno = DateTime(adesso.year, adesso.month, adesso.day);
  return adesso.hour < 12 ? giorno : giorno.add(const Duration(days: 1));
}

/// L'istantanea del cielo a un ISTANTE e da un LUOGO qualunque.
///
/// E' la forma generale, e `buildSkySnapshot` e' il caso particolare del cielo
/// di nascita. Serve perche' il cielo di ADESSO non e' un cielo di nascita:
/// prima questa funzione non c'era, quindi la schermata "Il cielo sopra di te"
/// non aveva modo di chiedere al motore il cielo del momento, e infatti non lo
/// chiedeva. Disegnava una volta procedurale e spostava il tutto di un offset
/// grafico quando arrivava la posizione, il che spiega perche' concedere il
/// permesso non cambiava niente di astronomico.
SkySnapshot buildSkyFor(
  SkyCatalog catalog,
  DateTime istanteLocale,
  BirthPlace place, {
  bool hasTime = true,
}) {
  final lat = place.latitude;
  final lon = place.longitude;
  final local = istanteLocale;

  // DA ORA CIVILE A UT, col fuso VERO dell'istante.
  //
  // Qui si convertiva col TEMPO MEDIO LOCALE, cioe' `lon / 15 * 60`, mentre chi
  // chiama passa `DateTime.now()`, che e' ora civile. Per l'Italia sono circa
  // ventiquattro minuti d'errore d'inverno e ottantaquattro d'estate, e
  // ottantaquattro minuti valgono ventuno gradi di rotazione della volta: la
  // posizione poteva anche essere giusta, il cielo restava sbagliato.
  //
  // L'istante porta con se' il proprio fuso, ora legale inclusa, e lo dichiara
  // in `timeZoneOffset`.
  //
  // MA LA SOTTRAZIONE A MANO ERA UN ERRORE, ed e' costata due voci. Togliere
  // l'offset da un DateTime locale produce un altro DateTime LOCALE, con i
  // campi gia' spostati indietro ma il flag ancora a "locale": poi
  // `Celestial.julianDay` chiama `toUtc()` e toglie l'offset UNA SECONDA
  // VOLTA. In Italia d'estate sono quattro ore di errore invece di due, e la
  // volta ruotava di una trentina di gradi in piu' del dovuto.
  //
  // E' la causa dei 123,7 gradi fra lo stesso istante scritto in UTC e in ora
  // civile che stava aperta in RIPRESA.md: un istante gia' in UTC non veniva
  // toccato, uno civile veniva convertito due volte, quindi i due cieli non
  // potevano coincidere. Una causa sola per due difetti che sembravano
  // distinti.
  //
  // `toUtc()` fa la conversione giusta e una volta sola, e su un istante gia'
  // in UTC non fa niente.
  final utc = local.toUtc();

  final jd = Celestial.julianDay(utc);
  final lst = Celestial.localSiderealDegrees(jd, lon);

  SkyStar project(double ra, double dec, double mag) {
    final h = Celestial.equatorialToHorizontal(
        raDeg: ra, decDeg: dec, latDeg: lat, lstDeg: lst);
    return SkyStar(altDeg: h.altDeg, azDeg: h.azDeg, mag: mag);
  }

  final constellations = <SkyConstellation>[];
  for (final c in catalog.constellations) {
    final stars = [
      for (final s in c.stars) project(s[0], s[1], s[2]),
    ];
    final con = SkyConstellation(name: c.name, stars: stars, lines: c.lines);
    if (con.anyVisible) constellations.add(con);
  }

  // Luna: posizione e fase reali.
  final moonEq = Celestial.moonEquatorial(jd);
  final moonH = Celestial.equatorialToHorizontal(
      raDeg: moonEq.raDeg, decDeg: moonEq.decDeg, latDeg: lat, lstDeg: lst);
  final moon = SkyStar(altDeg: moonH.altDeg, azDeg: moonH.azDeg, mag: -12);
  final moonPhase = Celestial.moonIllumination(jd);

  // Centro dello sguardo: la Luna se e' alta, altrimenti la media pesata degli
  // azimut delle stelle luminose piu' alte.
  double centerAz;
  if (moon.altDeg > 12) {
    centerAz = moon.azDeg;
  } else {
    var sx = 0.0, sy = 0.0, wsum = 0.0;
    for (final con in constellations) {
      for (final s in con.stars) {
        if (s.altDeg <= 5) continue;
        final w = (3.0 - s.mag).clamp(0.3, 4.0) * (s.altDeg / 90.0);
        final a = s.azDeg * math.pi / 180.0;
        sx += w * math.cos(a);
        sy += w * math.sin(a);
        wsum += w;
      }
    }
    centerAz = wsum > 0 ? math.atan2(sy, sx) * 180.0 / math.pi : 180.0;
    if (centerAz < 0) centerAz += 360.0;
  }

  return SkySnapshot(
    constellations: constellations,
    moon: moon.altDeg > kAltezzaOrizzonte ? moon : null,
    moonPhase: moonPhase,
    centerAzDeg: centerAz,
    hasTime: hasTime,
    latitude: lat,
    longitude: lon,
    istanteLocale: local,
    istanteUtc: utc,
  );
}
