import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/astro/api_config.dart';
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

/// Client del motore astrologico su effemeridi svizzere (FreeAstroAPI).
///
/// Endpoint reale: POST /api/v1/natal/calculate su api.freeastroapi.com, con
/// la chiave nell'header `x-api-key`. La chiave si legge da `AstroApiConfig`
/// (variabile d'ambiente), mai dal codice. Il client e' iniettabile con un
/// `http.Client` per i test con API simulata.
class FreeAstroClient {
  FreeAstroClient({
    http.Client? httpClient,
    String? apiKey,
    String baseUrl = AstroApiConfig.baseUrl,
    this.endpointPath = '/api/v1/natal/calculate',
    this.timeout = const Duration(seconds: 15),
  })  : _http = httpClient ?? http.Client(),
        _apiKey = apiKey ?? AstroApiConfig.apiKey,
        _baseUrl = baseUrl;

  final http.Client _http;
  final String? _apiKey;
  final String _baseUrl;
  final String endpointPath;
  final Duration timeout;

  bool get hasKey => _apiKey != null && _apiKey.isNotEmpty;

  /// Calcola la carta natale chiamando l'API. Solleva `AstroApiException` se la
  /// chiave manca, la rete fallisce o la risposta non e' interpretabile.
  Future<NatalChart> fetchNatalChart(BirthDetails details) async {
    final key = _apiKey;
    if (key == null || key.isEmpty) {
      throw const AstroApiException('Chiave API non configurata.');
    }

    final body = jsonEncode({
      'year': details.date.year,
      'month': details.date.month,
      'day': details.date.day,
      'hour': details.time?.hour ?? 12,
      'minute': details.time?.minute ?? 0,
      'lat': details.place.latitude,
      'lng': details.place.longitude,
      'tz_str': details.place.timezone,
    });

    late http.Response res;
    try {
      res = await _http
          .post(
            Uri.parse('$_baseUrl$endpointPath'),
            headers: {
              'x-api-key': key,
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: body,
          )
          .timeout(timeout);
    } catch (_) {
      throw const AstroApiException('Il cielo non risponde in questo momento.');
    }

    if (res.statusCode != 200) {
      throw AstroApiException(
        'Il motore astrologico ha risposto con un imprevisto.',
        statusCode: res.statusCode,
      );
    }

    try {
      return _parse(jsonDecode(res.body) as Map<String, dynamic>, details);
    } catch (e) {
      if (e is AstroApiException) rethrow;
      throw const AstroApiException('La risposta del cielo non e\' leggibile.');
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

    // Case.
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

  void dispose() => _http.close();
}
