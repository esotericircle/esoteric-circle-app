import 'dart:math' as math;

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import '../identity/birth_place.dart';

/// Una citta' dell'elenco offline: nome, area di appartenenza per distinguere
/// gli omonimi, coordinate e fuso nominale. Nessuna chiamata di rete.
class City {
  const City({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.timeZoneId,
    required this.utcOffsetMinutes,
    this.aka = '',
  });

  final String name;

  /// L'area che distingue gli omonimi: la sigla della provincia per l'Italia,
  /// il nome della nazione in italiano per l'estero.
  final String country;

  /// Nome alternativo su cui la ricerca combacia comunque. Serve alle citta'
  /// che in italiano si chiamano in un altro modo: si mostra Londra, si trova
  /// anche digitando London. Vuoto per quasi tutte.
  final String aka;
  final double latitude;
  final double longitude;
  final String timeZoneId;

  /// Offset nominale dell'ora standard, in minuti. Segnaposto onesto: l'offset
  /// storico esatto, con l'ora legale del giorno di nascita, lo dara' il motore
  /// a effemeridi. Qui basta a orientare la carta.
  final int utcOffsetMinutes;

  /// Etichetta mostrata nel campo e nei suggerimenti.
  String get label => '$name, $country';

  /// Il luogo di nascita che ne deriva. [approximate] vero quando la citta' e'
  /// un ripiego (la piu' vicina, non una corrispondenza esatta cercata).
  BirthPlace toPlace({bool approximate = false}) => BirthPlace(
        city: name,
        latitude: latitude,
        longitude: longitude,
        timeZoneId: timeZoneId,
        utcOffsetMinutes: utcOffsetMinutes,
        isApproximate: approximate,
      );
}

/// Elenco offline dei luoghi di nascita, con coordinate e fuso.
///
/// I dati veri stanno in `assets/data/luoghi.csv`, generato da
/// `tool/genera_luoghi.py` a partire dai dump pubblici di GeoNames: tutti i
/// comuni italiani, le localita' italiane popolose che comune non sono, piu' le
/// citta' del mondo sopra i duecentomila abitanti e tutte le capitali. Si carica
/// una volta sola e resta indicizzato in memoria. Nessun geocoding online:
/// nessuna chiave, nessun costo, nessuna latenza, nessuna dipendenza dalla rete.
///
/// Finche' l'asset non e' caricato, e se il caricamento fallisce, resta in piedi
/// il seme compilato qui sotto: poche decine di citta', abbastanza perche' la
/// schermata non sia mai muta.
class CityCatalog {
  const CityCatalog._();

  static List<City> _cities = _seed;
  static Future<void>? _loading;

  /// Vero quando l'elenco pieno e' in memoria.
  static bool get isLoaded => _cities.length > _seed.length;

  /// Carica l'elenco una volta sola. Chiamate successive attendono la prima.
  /// Se l'asset manca o e' malformato non solleva: resta il seme.
  static Future<void> ensureLoaded({AssetBundle? bundle}) {
    return _loading ??= _load(bundle ?? rootBundle);
  }

  /// Mette in memoria un elenco gia' letto, senza passare dall'asset, e
  /// dichiara concluso il caricamento.
  ///
  /// Serve ai test di widget, che leggono il file dal disco in modo sincrono:
  /// li' dentro il tempo e' finto, quindi un'attesa su `rootBundle` non
  /// avanzerebbe mai, e resterebbe appesa anche per i test successivi, visto
  /// che il caricamento si ricorda di essere gia' partito.
  @visibleForTesting
  static void adotta(List<City> luoghi) {
    _cities = luoghi;
    _loading = Future<void>.value();
  }

  static Future<void> _load(AssetBundle bundle) async {
    try {
      final raw = await bundle.loadString('assets/data/luoghi.csv');
      final parsed = parse(raw);
      if (parsed.isNotEmpty) _cities = parsed;
    } catch (_) {
      // Il seme e' gia' in piedi: la schermata resta viva, con meno luoghi.
    }
  }

  /// Legge il formato dell'asset: versione, tabella dei fusi, poi una riga per
  /// luogo. Pura e senza effetti, cosi' i test la verificano da sola.
  static List<City> parse(String raw) {
    final lines = raw.split('\n');
    if (lines.length < 3) return const [];
    final zones = <String>[];
    final offsets = <int>[];
    for (final z in lines[1].split('|')) {
      final eq = z.lastIndexOf('=');
      if (eq <= 0) continue;
      zones.add(z.substring(0, eq));
      offsets.add(int.tryParse(z.substring(eq + 1)) ?? 0);
    }
    final out = <City>[];
    for (var i = 2; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;
      final f = line.split(';');
      if (f.length < 6) continue;
      final zi = int.tryParse(f[5]) ?? -1;
      if (zi < 0 || zi >= zones.length) continue;
      final lat = double.tryParse(f[3]);
      final lon = double.tryParse(f[4]);
      if (lat == null || lon == null) continue;
      out.add(City(
        name: f[0],
        aka: f[1],
        country: f[2],
        latitude: lat,
        longitude: lon,
        timeZoneId: zones[zi],
        utcOffsetMinutes: offsets[zi],
      ));
    }
    return out;
  }

  /// Toglie accenti e maiuscole per un confronto tollerante.
  static String _fold(String s) {
    final lower = s.toLowerCase().trim();
    const from = 'àáâäãèéêëìíîïòóôöõùúûüçñ';
    const to = 'aaaaaeeeeiiiiooooouuuucn';
    final buf = StringBuffer();
    for (final ch in lower.split('')) {
      final i = from.indexOf(ch);
      buf.write(i >= 0 ? to[i] : ch);
    }
    return buf.toString();
  }

  /// Chiavi di ricerca gia' normalizzate, una per luogo, nello stesso ordine di
  /// [cities]. Si calcolano una volta sola: normalizzare undicimila nomi a ogni
  /// battuta sulla tastiera costerebbe a ogni carattere digitato.
  static List<String> _keys = const [];
  static List<City> _keysOf = const [];

  static void _ensureKeys() {
    if (identical(_keysOf, _cities)) return;
    _keys = List<String>.generate(
      _cities.length,
      (i) => _cities[i].aka.isEmpty
          ? _fold(_cities[i].name)
          : '${_fold(_cities[i].name)}\t${_fold(_cities[i].aka)}',
      growable: false,
    );
    _keysOf = _cities;
  }

  /// Cerca i luoghi che combaciano con [query], quelli che iniziano col testo
  /// per primi. Elenco vuoto se [query] e' troppo corta.
  ///
  /// L'elenco e' ordinato per popolazione decrescente gia' nell'asset, quindi
  /// scorrendolo in ordine Roma esce prima di Romano di Lombardia senza dover
  /// portare la popolazione fin qui.
  static List<City> search(String query, {int limit = 8}) {
    final q = _fold(query);
    if (q.length < 2) return const [];
    _ensureKeys();
    final starts = <City>[];
    final contains = <City>[];
    for (var i = 0; i < _cities.length; i++) {
      final key = _keys[i];
      // Il nome vero e l'eventuale alternativo, separati da una tabulazione,
      // che nei nomi di luogo non compare mai: con uno spazio la separazione
      // sarebbe caduta dentro Busto Arsizio.
      final sep = key.indexOf('\t');
      final name = sep < 0 ? key : key.substring(0, sep);
      final alt = sep < 0 ? '' : key.substring(sep + 1);
      if (name.startsWith(q) || (alt.isNotEmpty && alt.startsWith(q))) {
        starts.add(_cities[i]);
        if (starts.length >= limit) break;
      } else if (name.contains(q) || _fold(_cities[i].country).startsWith(q)) {
        if (contains.length < limit) contains.add(_cities[i]);
      }
    }
    return [...starts, ...contains].take(limit).toList(growable: false);
  }

  /// L'UNICA citta' che porta esattamente questo nome, oppure nulla.
  ///
  /// **Un candidato solo non e' una scelta, e' gia' la risposta.** Chi scrive
  /// per intero il nome della propria citta' e poi preme il pulsante ha gia'
  /// detto tutto quello che c'era da dire: chiedergli di sceglierla da un
  /// elenco di uno e' un passaggio che serve solo a noi. Se il nome e'
  /// ambiguo, e Cattolica non lo e' ma San Giorgio si', qui non si sceglie
  /// niente e la scelta resta alla persona, che e' l'unica a sapere quale.
  ///
  /// Il confronto passa dalla stessa normalizzazione della ricerca, quindi
  /// combacia anche senza accenti e senza maiuscole, e guarda anche il nome
  /// alternativo: chi scrive London trova Londra.
  static City? unicaEsatta(String query) {
    final q = _fold(query);
    if (q.isEmpty) return null;
    City? trovata;
    for (final c in _cities) {
      final combacia =
          _fold(c.name) == q || (c.aka.isNotEmpty && _fold(c.aka) == q);
      if (!combacia) continue;
      if (trovata != null) return null; // due omonime: sceglie la persona
      trovata = c;
    }
    return trovata;
  }

  /// La citta' in elenco piu' vicina a un punto, per il ripiego quando la citta'
  /// cercata non c'e'. Distanza sulla sfera, formula dell'emisenoverso.
  static City nearest(double latitude, double longitude) {
    City best = cities.first;
    double bestD = double.infinity;
    for (final c in cities) {
      final d = _haversine(latitude, longitude, c.latitude, c.longitude);
      if (d < bestD) {
        bestD = d;
        best = c;
      }
    }
    return best;
  }

  static double _haversine(
      double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0; // km
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(lat1)) *
            math.cos(_rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static double _rad(double deg) => deg * math.pi / 180.0;

  /// I luoghi in memoria: l'elenco pieno dell'asset quando e' caricato, il seme
  /// altrimenti.
  static List<City> get cities => _cities;

  /// Il seme compilato: le citta' principali, che tengono in piedi la ricerca
  /// finche' l'asset non e' pronto. Coordinate in gradi decimali, offset
  /// standard in minuti.
  static const List<City> _seed = [
    // --- Italia ---
    City(name: 'Roma', country: 'Italia', latitude: 41.9028, longitude: 12.4964, timeZoneId: 'Europe/Rome', utcOffsetMinutes: 60),
    City(name: 'Milano', country: 'Italia', latitude: 45.4642, longitude: 9.1900, timeZoneId: 'Europe/Rome', utcOffsetMinutes: 60),
    City(name: 'Napoli', country: 'Italia', latitude: 40.8518, longitude: 14.2681, timeZoneId: 'Europe/Rome', utcOffsetMinutes: 60),
    City(name: 'Torino', country: 'Italia', latitude: 45.0703, longitude: 7.6869, timeZoneId: 'Europe/Rome', utcOffsetMinutes: 60),
    City(name: 'Palermo', country: 'Italia', latitude: 38.1157, longitude: 13.3615, timeZoneId: 'Europe/Rome', utcOffsetMinutes: 60),
    City(name: 'Genova', country: 'Italia', latitude: 44.4056, longitude: 8.9463, timeZoneId: 'Europe/Rome', utcOffsetMinutes: 60),
    City(name: 'Bologna', country: 'Italia', latitude: 44.4949, longitude: 11.3426, timeZoneId: 'Europe/Rome', utcOffsetMinutes: 60),
    City(name: 'Firenze', country: 'Italia', latitude: 43.7696, longitude: 11.2558, timeZoneId: 'Europe/Rome', utcOffsetMinutes: 60),
    City(name: 'Bari', country: 'Italia', latitude: 41.1171, longitude: 16.8719, timeZoneId: 'Europe/Rome', utcOffsetMinutes: 60),
    City(name: 'Catania', country: 'Italia', latitude: 37.5079, longitude: 15.0830, timeZoneId: 'Europe/Rome', utcOffsetMinutes: 60),
    City(name: 'Venezia', country: 'Italia', latitude: 45.4408, longitude: 12.3155, timeZoneId: 'Europe/Rome', utcOffsetMinutes: 60),
    City(name: 'Verona', country: 'Italia', latitude: 45.4384, longitude: 10.9916, timeZoneId: 'Europe/Rome', utcOffsetMinutes: 60),
    City(name: 'Cagliari', country: 'Italia', latitude: 39.2238, longitude: 9.1217, timeZoneId: 'Europe/Rome', utcOffsetMinutes: 60),
    City(name: 'Trieste', country: 'Italia', latitude: 45.6495, longitude: 13.7768, timeZoneId: 'Europe/Rome', utcOffsetMinutes: 60),
    City(name: 'Padova', country: 'Italia', latitude: 45.4064, longitude: 11.8768, timeZoneId: 'Europe/Rome', utcOffsetMinutes: 60),
    City(name: 'Bergamo', country: 'Italia', latitude: 45.6983, longitude: 9.6773, timeZoneId: 'Europe/Rome', utcOffsetMinutes: 60),
    City(name: 'Reggio Calabria', country: 'Italia', latitude: 38.1090, longitude: 15.6440, timeZoneId: 'Europe/Rome', utcOffsetMinutes: 60),
    // --- Europa ---
    City(name: 'Londra', country: 'Regno Unito', latitude: 51.5074, longitude: -0.1278, timeZoneId: 'Europe/London', utcOffsetMinutes: 0),
    City(name: 'Parigi', country: 'Francia', latitude: 48.8566, longitude: 2.3522, timeZoneId: 'Europe/Paris', utcOffsetMinutes: 60),
    City(name: 'Madrid', country: 'Spagna', latitude: 40.4168, longitude: -3.7038, timeZoneId: 'Europe/Madrid', utcOffsetMinutes: 60),
    City(name: 'Barcellona', country: 'Spagna', latitude: 41.3874, longitude: 2.1686, timeZoneId: 'Europe/Madrid', utcOffsetMinutes: 60),
    City(name: 'Berlino', country: 'Germania', latitude: 52.5200, longitude: 13.4050, timeZoneId: 'Europe/Berlin', utcOffsetMinutes: 60),
    City(name: 'Monaco di Baviera', country: 'Germania', latitude: 48.1351, longitude: 11.5820, timeZoneId: 'Europe/Berlin', utcOffsetMinutes: 60),
    City(name: 'Amsterdam', country: 'Paesi Bassi', latitude: 52.3676, longitude: 4.9041, timeZoneId: 'Europe/Amsterdam', utcOffsetMinutes: 60),
    City(name: 'Bruxelles', country: 'Belgio', latitude: 50.8503, longitude: 4.3517, timeZoneId: 'Europe/Brussels', utcOffsetMinutes: 60),
    City(name: 'Zurigo', country: 'Svizzera', latitude: 47.3769, longitude: 8.5417, timeZoneId: 'Europe/Zurich', utcOffsetMinutes: 60),
    City(name: 'Vienna', country: 'Austria', latitude: 48.2082, longitude: 16.3738, timeZoneId: 'Europe/Vienna', utcOffsetMinutes: 60),
    City(name: 'Lisbona', country: 'Portogallo', latitude: 38.7223, longitude: -9.1393, timeZoneId: 'Europe/Lisbon', utcOffsetMinutes: 0),
    City(name: 'Atene', country: 'Grecia', latitude: 37.9838, longitude: 23.7275, timeZoneId: 'Europe/Athens', utcOffsetMinutes: 120),
    City(name: 'Dublino', country: 'Irlanda', latitude: 53.3498, longitude: -6.2603, timeZoneId: 'Europe/Dublin', utcOffsetMinutes: 0),
    City(name: 'Stoccolma', country: 'Svezia', latitude: 59.3293, longitude: 18.0686, timeZoneId: 'Europe/Stockholm', utcOffsetMinutes: 60),
    City(name: 'Oslo', country: 'Norvegia', latitude: 59.9139, longitude: 10.7522, timeZoneId: 'Europe/Oslo', utcOffsetMinutes: 60),
    City(name: 'Copenaghen', country: 'Danimarca', latitude: 55.6761, longitude: 12.5683, timeZoneId: 'Europe/Copenhagen', utcOffsetMinutes: 60),
    City(name: 'Varsavia', country: 'Polonia', latitude: 52.2297, longitude: 21.0122, timeZoneId: 'Europe/Warsaw', utcOffsetMinutes: 60),
    City(name: 'Praga', country: 'Repubblica Ceca', latitude: 50.0755, longitude: 14.4378, timeZoneId: 'Europe/Prague', utcOffsetMinutes: 60),
    City(name: 'Budapest', country: 'Ungheria', latitude: 47.4979, longitude: 19.0402, timeZoneId: 'Europe/Budapest', utcOffsetMinutes: 60),
    City(name: 'Bucarest', country: 'Romania', latitude: 44.4268, longitude: 26.1025, timeZoneId: 'Europe/Bucharest', utcOffsetMinutes: 120),
    City(name: 'Mosca', country: 'Russia', latitude: 55.7558, longitude: 37.6173, timeZoneId: 'Europe/Moscow', utcOffsetMinutes: 180),
    City(name: 'Istanbul', country: 'Turchia', latitude: 41.0082, longitude: 28.9784, timeZoneId: 'Europe/Istanbul', utcOffsetMinutes: 180),
    // --- Americhe ---
    City(name: 'New York', country: 'Stati Uniti', latitude: 40.7128, longitude: -74.0060, timeZoneId: 'America/New_York', utcOffsetMinutes: -300),
    City(name: 'Los Angeles', country: 'Stati Uniti', latitude: 34.0522, longitude: -118.2437, timeZoneId: 'America/Los_Angeles', utcOffsetMinutes: -480),
    City(name: 'Chicago', country: 'Stati Uniti', latitude: 41.8781, longitude: -87.6298, timeZoneId: 'America/Chicago', utcOffsetMinutes: -360),
    City(name: 'Miami', country: 'Stati Uniti', latitude: 25.7617, longitude: -80.1918, timeZoneId: 'America/New_York', utcOffsetMinutes: -300),
    City(name: 'Toronto', country: 'Canada', latitude: 43.6532, longitude: -79.3832, timeZoneId: 'America/Toronto', utcOffsetMinutes: -300),
    City(name: 'Città del Messico', country: 'Messico', latitude: 19.4326, longitude: -99.1332, timeZoneId: 'America/Mexico_City', utcOffsetMinutes: -360),
    City(name: 'San Paolo', country: 'Brasile', latitude: -23.5505, longitude: -46.6333, timeZoneId: 'America/Sao_Paulo', utcOffsetMinutes: -180),
    City(name: 'Rio de Janeiro', country: 'Brasile', latitude: -22.9068, longitude: -43.1729, timeZoneId: 'America/Sao_Paulo', utcOffsetMinutes: -180),
    City(name: 'Buenos Aires', country: 'Argentina', latitude: -34.6037, longitude: -58.3816, timeZoneId: 'America/Argentina/Buenos_Aires', utcOffsetMinutes: -180),
    // --- Africa e Medio Oriente ---
    City(name: 'Il Cairo', country: 'Egitto', latitude: 30.0444, longitude: 31.2357, timeZoneId: 'Africa/Cairo', utcOffsetMinutes: 120),
    City(name: 'Casablanca', country: 'Marocco', latitude: 33.5731, longitude: -7.5898, timeZoneId: 'Africa/Casablanca', utcOffsetMinutes: 60),
    City(name: 'Tunisi', country: 'Tunisia', latitude: 36.8065, longitude: 10.1815, timeZoneId: 'Africa/Tunis', utcOffsetMinutes: 60),
    City(name: 'Lagos', country: 'Nigeria', latitude: 6.5244, longitude: 3.3792, timeZoneId: 'Africa/Lagos', utcOffsetMinutes: 60),
    City(name: 'Johannesburg', country: 'Sudafrica', latitude: -26.2041, longitude: 28.0473, timeZoneId: 'Africa/Johannesburg', utcOffsetMinutes: 120),
    City(name: 'Dubai', country: 'Emirati Arabi Uniti', latitude: 25.2048, longitude: 55.2708, timeZoneId: 'Asia/Dubai', utcOffsetMinutes: 240),
    City(name: 'Tel Aviv', country: 'Israele', latitude: 32.0853, longitude: 34.7818, timeZoneId: 'Asia/Jerusalem', utcOffsetMinutes: 120),
    // --- Asia e Oceania ---
    City(name: 'Tokyo', country: 'Giappone', latitude: 35.6762, longitude: 139.6503, timeZoneId: 'Asia/Tokyo', utcOffsetMinutes: 540),
    City(name: 'Pechino', country: 'Cina', latitude: 39.9042, longitude: 116.4074, timeZoneId: 'Asia/Shanghai', utcOffsetMinutes: 480),
    City(name: 'Shanghai', country: 'Cina', latitude: 31.2304, longitude: 121.4737, timeZoneId: 'Asia/Shanghai', utcOffsetMinutes: 480),
    City(name: 'Hong Kong', country: 'Cina', latitude: 22.3193, longitude: 114.1694, timeZoneId: 'Asia/Hong_Kong', utcOffsetMinutes: 480),
    City(name: 'Singapore', country: 'Singapore', latitude: 1.3521, longitude: 103.8198, timeZoneId: 'Asia/Singapore', utcOffsetMinutes: 480),
    City(name: 'Nuova Delhi', country: 'India', latitude: 28.6139, longitude: 77.2090, timeZoneId: 'Asia/Kolkata', utcOffsetMinutes: 330),
    City(name: 'Mumbai', country: 'India', latitude: 19.0760, longitude: 72.8777, timeZoneId: 'Asia/Kolkata', utcOffsetMinutes: 330),
    City(name: 'Bangkok', country: 'Thailandia', latitude: 13.7563, longitude: 100.5018, timeZoneId: 'Asia/Bangkok', utcOffsetMinutes: 420),
    City(name: 'Sydney', country: 'Australia', latitude: -33.8688, longitude: 151.2093, timeZoneId: 'Australia/Sydney', utcOffsetMinutes: 600),
    City(name: 'Melbourne', country: 'Australia', latitude: -37.8136, longitude: 144.9631, timeZoneId: 'Australia/Melbourne', utcOffsetMinutes: 600),
  ];
}
