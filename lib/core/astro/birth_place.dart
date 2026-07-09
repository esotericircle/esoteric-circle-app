/// Un luogo di nascita con le coordinate e il fuso, necessari al motore
/// astrologico.
///
/// In C2 si sceglie da un elenco curato di citta' (senza servizi di
/// geocodifica esterni, quindi senza altri segreti). Il fuso e' l'offset
/// standard: il calcolo esatto dell'ora legale storica arrivera' col motore
/// completo.
class BirthPlace {
  const BirthPlace({
    required this.label,
    required this.latitude,
    required this.longitude,
    required this.timezoneOffsetHours,
  });

  final String label;
  final double latitude;
  final double longitude;

  /// Offset standard dal UTC in ore (per esempio +1 per l'Italia).
  final double timezoneOffsetHours;

  @override
  bool operator ==(Object other) =>
      other is BirthPlace &&
      other.label == label &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(label, latitude, longitude);
}

/// Elenco curato di citta' selezionabili nell'onboarding.
///
/// Copre i principali capoluoghi italiani piu' alcune citta' del mondo, cosi'
/// da coprire il primo mercato (Italia) e permettere qualche test estero.
/// L'ampliamento e l'eventuale ricerca geografica arriveranno piu' avanti.
class BirthPlaces {
  BirthPlaces._();

  static const List<BirthPlace> all = [
    // Italia
    BirthPlace(label: 'Roma', latitude: 41.9028, longitude: 12.4964, timezoneOffsetHours: 1),
    BirthPlace(label: 'Milano', latitude: 45.4642, longitude: 9.19, timezoneOffsetHours: 1),
    BirthPlace(label: 'Napoli', latitude: 40.8518, longitude: 14.2681, timezoneOffsetHours: 1),
    BirthPlace(label: 'Torino', latitude: 45.0703, longitude: 7.6869, timezoneOffsetHours: 1),
    BirthPlace(label: 'Palermo', latitude: 38.1157, longitude: 13.3615, timezoneOffsetHours: 1),
    BirthPlace(label: 'Genova', latitude: 44.4056, longitude: 8.9463, timezoneOffsetHours: 1),
    BirthPlace(label: 'Bologna', latitude: 44.4949, longitude: 11.3426, timezoneOffsetHours: 1),
    BirthPlace(label: 'Firenze', latitude: 43.7696, longitude: 11.2558, timezoneOffsetHours: 1),
    BirthPlace(label: 'Bari', latitude: 41.1171, longitude: 16.8719, timezoneOffsetHours: 1),
    BirthPlace(label: 'Catania', latitude: 37.5079, longitude: 15.083, timezoneOffsetHours: 1),
    BirthPlace(label: 'Venezia', latitude: 45.4408, longitude: 12.3155, timezoneOffsetHours: 1),
    BirthPlace(label: 'Verona', latitude: 45.4384, longitude: 10.9916, timezoneOffsetHours: 1),
    BirthPlace(label: 'Cagliari', latitude: 39.2238, longitude: 9.1217, timezoneOffsetHours: 1),
    BirthPlace(label: 'Bolzano', latitude: 46.4983, longitude: 11.3548, timezoneOffsetHours: 1),
    BirthPlace(label: 'Reggio Calabria', latitude: 38.1113, longitude: 15.6619, timezoneOffsetHours: 1),
    // Mondo
    BirthPlace(label: 'Londra', latitude: 51.5074, longitude: -0.1278, timezoneOffsetHours: 0),
    BirthPlace(label: 'Parigi', latitude: 48.8566, longitude: 2.3522, timezoneOffsetHours: 1),
    BirthPlace(label: 'Madrid', latitude: 40.4168, longitude: -3.7038, timezoneOffsetHours: 1),
    BirthPlace(label: 'Berlino', latitude: 52.52, longitude: 13.405, timezoneOffsetHours: 1),
    BirthPlace(label: 'New York', latitude: 40.7128, longitude: -74.006, timezoneOffsetHours: -5),
    BirthPlace(label: 'Los Angeles', latitude: 34.0522, longitude: -118.2437, timezoneOffsetHours: -8),
    BirthPlace(label: 'Buenos Aires', latitude: -34.6037, longitude: -58.3816, timezoneOffsetHours: -3),
    BirthPlace(label: 'Tokyo', latitude: 35.6762, longitude: 139.6503, timezoneOffsetHours: 9),
    BirthPlace(label: 'Sydney', latitude: -33.8688, longitude: 151.2093, timezoneOffsetHours: 10),
  ];
}
