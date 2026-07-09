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
/// La chiave si legge da `AstroApiConfig` (variabile d'ambiente), mai dal
/// codice, e viaggia nell'header `x-api-key`. Il client e' iniettabile con un
/// `http.Client` per i test con API simulata.
///
/// Nota per lo sviluppo: il percorso e lo schema esatti vanno confermati sul
/// piano FreeAstroAPI. La richiesta e la lettura della risposta sono isolate e
/// tolleranti: nomi di campo alternativi vengono riconosciuti, e se qualcosa
/// non torna si solleva `AstroApiException`, cosi' il chiamante mostra il cielo
/// essenziale senza mai un errore tecnico.
class FreeAstroClient {
  FreeAstroClient({
    http.Client? httpClient,
    String? apiKey,
    String baseUrl = AstroApiConfig.baseUrl,
    this.endpointPath = '/api/v1/natal-chart',
    this.timeout = const Duration(seconds: 12),
  })  : _http = httpClient ?? http.Client(),
        _apiKey = apiKey ?? AstroApiConfig.apiKey,
        _baseUrl = baseUrl;

  final http.Client _http;
  final String? _apiKey;
  final String _baseUrl;
  final String endpointPath;
  final Duration timeout;

  bool get hasKey => _apiKey != null && _apiKey.isNotEmpty;

  /// Calcola la carta natale chiamando l'API. Solleva `AstroApiException` se
  /// la chiave manca, la rete fallisce o la risposta non e' interpretabile.
  Future<NatalChart> fetchNatalChart(BirthDetails details) async {
    final key = _apiKey;
    if (key == null || key.isEmpty) {
      throw const AstroApiException('Chiave API non configurata.');
    }

    final dt = details.dateTime;
    final body = jsonEncode({
      'year': dt.year,
      'month': dt.month,
      'day': dt.day,
      'hour': details.time?.hour ?? 12,
      'minute': details.time?.minute ?? 0,
      'latitude': details.place.latitude,
      'longitude': details.place.longitude,
      'timezone': details.place.timezoneOffsetHours,
      'settings': {
        'house_system': 'placidus',
        'zodiac': 'tropical',
        'language': 'it',
      },
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
    } catch (e) {
      throw const AstroApiException('Il cielo non risponde in questo momento.');
    }

    if (res.statusCode != 200) {
      throw AstroApiException(
        'Il motore astrologico ha risposto con un imprevisto.',
        statusCode: res.statusCode,
      );
    }

    try {
      final decoded = jsonDecode(res.body);
      return _parse(decoded, details);
    } catch (e) {
      if (e is AstroApiException) rethrow;
      throw const AstroApiException('La risposta del cielo non e\' leggibile.');
    }
  }

  // --- Interpretazione tollerante della risposta ---

  NatalChart _parse(dynamic decoded, BirthDetails details) {
    final planetsRaw = _findPlanetList(decoded);
    if (planetsRaw.isEmpty) {
      throw const AstroApiException('Nessun pianeta nella risposta.');
    }

    final planets = <PlanetPosition>[];
    Zodiac? sunSign;
    Zodiac? moonSign;
    Zodiac? ascendant;

    for (final raw in planetsRaw) {
      if (raw is! Map) continue;
      final map = raw.cast<String, dynamic>();
      final rawName = (map['name'] ?? map['planet'] ?? map['body'] ?? '')
          .toString()
          .toLowerCase()
          .trim();
      final lon = _readLongitude(map);
      final sign = _readSign(map) ??
          (lon != null ? _signFromLongitude(lon) : null);
      if (sign == null) continue;

      if (rawName.contains('asc')) {
        ascendant = sign;
        continue; // l'Ascendente non e' un pianeta da disegnare
      }
      final it = _planetIt[rawName];
      if (it == null) continue; // ignora nodi e punti non gestiti in C2
      if (rawName.contains('sun')) sunSign = sign;
      if (rawName.contains('moon')) moonSign = sign;
      planets.add(PlanetPosition(
        name: it.$1,
        symbol: it.$2,
        longitude: lon ?? Zodiac.values.indexOf(sign) * 30.0 + 15,
        sign: sign,
      ));
    }

    // L'Ascendente ha senso solo con l'ora di nascita.
    if (!details.hasTime) ascendant = null;

    sunSign ??= Zodiac.fromDate(details.date);
    if (planets.isEmpty) {
      throw const AstroApiException('Pianeti non riconosciuti.');
    }

    return NatalChart(
      sunSign: sunSign,
      moonSign: moonSign,
      ascendant: ascendant,
      planets: planets,
      hasTime: details.hasTime,
    );
  }

  List<dynamic> _findPlanetList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map) {
      for (final key in ['planets', 'output', 'data', 'result', 'bodies']) {
        final v = decoded[key];
        if (v is List) return v;
        if (v is Map) {
          final inner = v['planets'] ?? v['output'] ?? v['data'];
          if (inner is List) return inner;
        }
      }
    }
    return const [];
  }

  double? _readLongitude(Map<String, dynamic> map) {
    for (final k in [
      'fullDegree',
      'full_degree',
      'longitude',
      'lon',
      'norm_degree',
      'normDegree',
      'degree',
    ]) {
      final v = map[k];
      if (v is num) return v.toDouble();
      if (v is String) {
        final parsed = double.tryParse(v);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  Zodiac? _readSign(Map<String, dynamic> map) {
    for (final k in ['sign', 'zodiac_sign', 'sign_name', 'zodiac']) {
      final v = map[k];
      if (v is String) {
        final z = _zodiacFromEnglish(v);
        if (z != null) return z;
      }
      if (v is Map) {
        final name = v['name'];
        if (name is String) {
          final z = _zodiacFromEnglish(name);
          if (z != null) return z;
        }
      }
    }
    return null;
  }

  static Zodiac _signFromLongitude(double lon) {
    final normalized = ((lon % 360) + 360) % 360;
    final index = (normalized ~/ 30).clamp(0, 11);
    return Zodiac.values[index];
  }

  static Zodiac? _zodiacFromEnglish(String raw) => _english[raw.toLowerCase()];

  // Nome inglese -> segno.
  static const Map<String, Zodiac> _english = {
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

  // Nome inglese del pianeta -> (nome italiano, simbolo).
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
  };

  void dispose() => _http.close();
}
