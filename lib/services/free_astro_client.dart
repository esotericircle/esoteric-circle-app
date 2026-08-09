import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';

import '../core/astro/birth_details.dart';
import '../core/astro/natal_chart.dart';
import '../core/astro/zodiac.dart';

/// Errore del motore astrologico, con un messaggio gia' in tono per l'utente.
class AstroApiException implements Exception {
  const AstroApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => 'AstroApiException($statusCode): $message';
}

/// Trasporto verso il motore astrologico: prende il payload dei dati di nascita
/// e restituisce il JSON grezzo della carta. In produzione e' la callable
/// Firebase; nei test si inietta una funzione finta, senza rete ne Firebase.
typedef NatalChartCaller = Future<Object?> Function(Map<String, Object?> data);

/// Client del motore astrologico su effemeridi svizzere (FreeAstroAPI).
///
/// La chiave NON vive piu' nel client: la carta passa dalla callable Firebase
/// "natalChart" in europe-west1, che tiene la chiave in Secret Manager ed e'
/// protetta da App Check. Il client invia i dati di nascita e riceve il JSON di
/// FreeAstroAPI, che interpreta con lo stesso parsing di prima. Il trasporto e'
/// iniettabile ([caller]) per i test con callable simulata.
/// IL SISTEMA DI CASE CHE L'APP SI ASPETTA, e su cui sono tarate tutte le
/// prove del cielo di nascita.
///
/// Placidus e' quello che il fornitore restituisce oggi, verificato sulle tre
/// risposte conservate nel repository (Roma, Sydney, Reykjavik). Non e' una
/// preferenza estetica: le cuspidi che la ruota disegna, gli aspetti e le
/// case dei pianeti dipendono da questa scelta.
const String sistemaDiCaseAtteso = 'placidus';

class FreeAstroClient {
  FreeAstroClient({NatalChartCaller? caller})
      : _caller = caller ?? _firebaseCaller;

  final NatalChartCaller _caller;

  /// La chiave e' lato server: dal punto di vista dell'app il servizio e'
  /// configurato, e un eventuale fallimento e' transitorio (rete o motore).
  bool get hasKey => true;

  /// Chiamata reale: la callable Firebase in europe-west1. La regione e' fissa e
  /// coincide con quella della function; App Check e' imposto lato server.
  static Future<Object?> _firebaseCaller(Map<String, Object?> data) async {
    final callable = FirebaseFunctions.instanceFor(region: 'europe-west1')
        .httpsCallable(
      'natalChart',
      options: HttpsCallableOptions(timeout: const Duration(seconds: 20)),
    );
    final res = await callable.call<Object?>(data);
    return res.data;
  }

  /// Calcola la carta natale via callable. Solleva `AstroApiException` se la
  /// chiamata fallisce o la risposta non e' interpretabile, cosi' il controller
  /// puo' ripiegare sul cielo essenziale.
  Future<NatalChart> fetchNatalChart(BirthDetails details) async =>
      _parse(await fetchRawNatalChart(details), details);

  /// La risposta GREZZA del cielo, gia' normalizzata e ancora da interpretare.
  ///
  /// Esiste perche' la carta natale si CONSERVI fra un avvio e l'altro: si
  /// tiene da parte questa risposta e la si reinterpreta, invece di serializzare
  /// il modello. Conservare la risposta e non l'oggetto significa che, se domani
  /// l'interpretazione migliora, il cielo gia' scaricato ne beneficia senza che
  /// nessuno debba riscaricarlo.
  Future<Map<String, dynamic>> fetchRawNatalChart(BirthDetails details) async {
    // Senza luogo non si chiede niente a nessuno. Il motore risponderebbe
    // comunque, ma risponderebbe per il punto che gli mandiamo: se glielo
    // inventiamo, Ascendente e case tornano esatti e falsi insieme. Qui la
    // catena si ferma, il controller ripiega sul cielo essenziale e la
    // schermata dichiara che senza luogo quei valori non si calcolano.
    final place = details.place;
    if (place == null) {
      throw const AstroApiException(
        'Senza il luogo di nascita l\'Ascendente e le case non si calcolano.',
      );
    }

    final payload = <String, Object?>{
      'year': details.date.year,
      'month': details.date.month,
      'day': details.date.day,
      'hour': details.time?.hour ?? 12,
      'minute': details.time?.minute ?? 0,
      'lat': place.latitude,
      'lng': place.longitude,
      'tz_str': place.timezone,
    };

    Object? raw;
    try {
      raw = await _caller(payload);
    } catch (_) {
      throw const AstroApiException('Il cielo non risponde in questo momento.');
    }

    try {
      // La callable puo' restituire mappe con chiavi dinamiche: si normalizza
      // via JSON alla forma Map<String, dynamic> attesa dal parsing.
      final json = jsonDecode(jsonEncode(raw));
      if (json is! Map<String, dynamic>) {
        throw const AstroApiException('La risposta del cielo non è leggibile.');
      }
      return json;
    } catch (e) {
      if (e is AstroApiException) rethrow;
      throw const AstroApiException('La risposta del cielo non è leggibile.');
    }
  }

  /// Interpreta una risposta gia' ottenuta (usata per i test e per la fixture
  /// di revisione).
  NatalChart parseResponse(Map<String, dynamic> json, BirthDetails details) =>
      _parse(json, details);

  NatalChart _parse(Map<String, dynamic> d, BirthDetails details) {
    // La verita' sull'ora e' quella data dall'utente: senza ora, Ascendente e
    // Case non hanno senso anche se l'API le calcola dal mezzogiorno di default.
    final hasTime = details.hasTime;

    // IL SISTEMA DI CASE DELLA RISPOSTA, CONTROLLATO PRIMA DI CREDERLE.
    //
    // **Ordine 2170, voce 4.** Placidus, Koch e Case Uguali danno cuspidi
    // diverse per la stessa nascita: se il fornitore cambiasse default,
    // tutte le carte cambierebbero sotto i piedi delle persone e nessun
    // numero in questo codice se ne accorgerebbe. Adesso se ne accorge qui.
    //
    // **Il campo non si spedisce ANCORA nella richiesta**, ed e' voluto: la
    // callable in produzione rifiuta i campi che non conosce, quindi una
    // versione dell'app che lo mandasse verrebbe respinta finche' la
    // funzione aggiornata non e' pubblicata. Il lato server e' pronto
    // (`functions/src/validate.ts` accetta `house_system` e
    // `functions/src/index.ts` verifica la risposta): il giorno del deploy
    // basta aggiungere il campo al payload qui sopra.
    final sistemaCase = ((d['subject'] as Map<String, dynamic>?)?['settings']
        as Map<String, dynamic>?)?['house_system'];
    if (sistemaCase != null && sistemaCase != sistemaDiCaseAtteso) {
      throw AstroApiException(
        'Il cielo ha risposto con un altro modo di dividere le case '
        '($sistemaCase invece di $sistemaDiCaseAtteso).',
      );
    }

    final planetsRaw = d['planets'];
    if (planetsRaw is! List || planetsRaw.isEmpty) {
      throw const AstroApiException('Nessun pianeta nella risposta.');
    }

    final planets = <PlanetPosition>[];
    final lonById = <String, double>{};
    Zodiac? sunSign;
    Zodiac? moonSign;

    for (final raw in planetsRaw) {
      if (raw is! Map) continue;
      final map = raw.cast<String, dynamic>();
      final id = (map['id'] ?? map['name'] ?? '').toString().toLowerCase().trim();
      final lon = _num(map['abs_pos'] ?? map['fullDegree'] ?? map['longitude']);
      if (lon == null) continue;
      final sign = _sign(map['sign_id'] ?? map['sign']) ?? _signFromLon(lon);
      final it = _planetIt[id];
      if (it == null) continue; // punti non gestiti in C3
      lonById[id] = lon;
      if (id == 'sun') sunSign = sign;
      if (id == 'moon') moonSign = sign;
      planets.add(PlanetPosition(
        id: id,
        name: it.$1,
        glyph: it.$2,
        longitude: lon,
        sign: sign,
        retrograde: (map['retrograde'] as bool?) ?? false,
        house: (map['house'] as num?)?.toInt(),
      ));
    }
    if (planets.isEmpty) {
      throw const AstroApiException('Pianeti non riconosciuti.');
    }

    // Angoli.
    Zodiac? ascendant;
    double? ascLon;
    Zodiac? mc;
    double? mcLon;
    final angles = d['angles'] as Map<String, dynamic>?;
    final angleDetails = d['angles_details'] as Map<String, dynamic>?;
    if (hasTime && angles != null) {
      ascLon = _num(angles['asc']);
      mcLon = _num(angles['mc']);
      ascendant = _sign(angleDetails?['asc']?['sign_id']) ??
          (ascLon != null ? _signFromLon(ascLon) : null);
      mc = _sign(angleDetails?['mc']?['sign_id']) ??
          (mcLon != null ? _signFromLon(mcLon) : null);
    }

    // CASE, E IL SISTEMA E' PLACIDUS.
    //
    // **Non era dichiarato da nessuna parte**, e senza saperlo le cuspidi non
    // sono nemmeno confrontabili con una fonte terza: Placidus, Koch e Case
    // Uguali danno numeri diversi per la stessa nascita, quindi uno scarto di
    // tre gradi puo' voler dire "abbiamo un difetto" oppure "stiamo
    // confrontando due cose diverse".
    //
    // Il dato non e' un'ipotesi: la risposta del motore lo porta scritto in
    // `subject.settings.house_system`, e nella risposta conservata in
    // `assets/data/sample_natal_rome.json` quel campo vale "placidus". Lo
    // conferma la forma delle cuspidi: non sono equidistanti (26,7 gradi fra
    // la prima e la seconda, 34,1 fra la terza e la quarta), quindi non e'
    // Case Uguali ne' Whole Sign; e le opposte stanno esattamente a 180
    // gradi, come in tutti i sistemi a quadranti.
    //
    // NOI NON LO CHIEDIAMO: la richiesta non porta nessun parametro di
    // sistema, quindi quello che arriva e' il default del motore. Se un
    // giorno cambiasse default, le carte cambierebbero sotto i piedi senza
    // che nessuno tocchi una riga: e' il motivo per cui esiste
    // `test/il_sistema_delle_case_e_dichiarato_test.dart`.
    final houses = <HouseCusp>[];
    if (hasTime && d['houses'] is List) {
      for (final h in d['houses'] as List) {
        if (h is! Map) continue;
        final n = (h['house'] as num?)?.toInt();
        final lon = _num(h['abs_pos']);
        if (n != null && lon != null) {
          houses.add(HouseCusp(number: n, longitude: lon));
        }
      }
    }

    // Aspetti (tra pianeti riconosciuti).
    final aspects = <ChartAspect>[];
    if (d['aspects'] is List) {
      for (final a in d['aspects'] as List) {
        if (a is! Map) continue;
        final p1 = a['p1']?.toString().toLowerCase();
        final p2 = a['p2']?.toString().toLowerCase();
        final type = AspectType.fromId(a['type']?.toString() ?? '');
        final l1 = lonById[p1];
        final l2 = lonById[p2];
        if (type != null && l1 != null && l2 != null) {
          aspects.add(ChartAspect(aLongitude: l1, bLongitude: l2, type: type));
        }
      }
    }

    sunSign ??= Zodiac.fromDate(details.date);

    return NatalChart(
      sunSign: sunSign,
      moonSign: moonSign,
      ascendant: ascendant,
      ascendantLongitude: ascLon,
      midheaven: mc,
      midheavenLongitude: mcLon,
      houses: houses,
      aspects: aspects,
      planets: planets,
      hasTime: hasTime,
    );
  }

  static double? _num(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static Zodiac _signFromLon(double lon) {
    final n = ((lon % 360) + 360) % 360;
    return Zodiac.values[(n ~/ 30).clamp(0, 11)];
  }

  static Zodiac? _sign(dynamic v) {
    if (v is! String) return null;
    final s = v.toLowerCase().trim();
    return _fullNames[s] ?? _shortNames[s];
  }

  static const Map<String, Zodiac> _fullNames = {
    'aries': Zodiac.aries,
    'taurus': Zodiac.taurus,
    'gemini': Zodiac.gemini,
    'cancer': Zodiac.cancer,
    'leo': Zodiac.leo,
    'virgo': Zodiac.virgo,
    'libra': Zodiac.libra,
    'scorpio': Zodiac.scorpio,
    'sagittarius': Zodiac.sagittarius,
    'capricorn': Zodiac.capricorn,
    'aquarius': Zodiac.aquarius,
    'pisces': Zodiac.pisces,
  };

  static const Map<String, Zodiac> _shortNames = {
    'ari': Zodiac.aries,
    'tau': Zodiac.taurus,
    'gem': Zodiac.gemini,
    'can': Zodiac.cancer,
    'leo': Zodiac.leo,
    'vir': Zodiac.virgo,
    'lib': Zodiac.libra,
    'sco': Zodiac.scorpio,
    'sag': Zodiac.sagittarius,
    'cap': Zodiac.capricorn,
    'aqu': Zodiac.aquarius,
    'pis': Zodiac.pisces,
  };

  // id -> (nome italiano, glifo)
  static const Map<String, (String, String)> _planetIt = {
    'sun': ('Sole', '☉'),
    'moon': ('Luna', '☽'),
    'mercury': ('Mercurio', '☿'),
    'venus': ('Venere', '♀'),
    'mars': ('Marte', '♂'),
    'jupiter': ('Giove', '♃'),
    'saturn': ('Saturno', '♄'),
    'uranus': ('Urano', '♅'),
    'neptune': ('Nettuno', '♆'),
    'pluto': ('Plutone', '♇'),
    'north_node': ('Nodo Nord', '☊'),
    'chiron': ('Chirone', '⚷'),
    'lilith': ('Lilith', '⚸'),
  };
}
