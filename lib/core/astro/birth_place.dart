/// Un luogo di nascita con coordinate e fuso, necessari al motore astrologico.
///
/// Il fuso e' l'identificatore IANA (per esempio Europe/Rome), come richiesto
/// da FreeAstroAPI nel campo `tz_str`.
class BirthPlace {
  const BirthPlace({
    required this.label,
    required this.latitude,
    required this.longitude,
    required this.timezone,
    this.province,
  });

  final String label;

  /// Sigla di provincia per i comuni italiani (per disambiguare i nomi uguali).
  final String? province;
  final double latitude;
  final double longitude;

  /// Fuso IANA, per esempio Europe/Rome.
  final String timezone;

  /// Etichetta completa mostrata all'utente.
  String get displayLabel =>
      province != null && province!.isNotEmpty ? '$label ($province)' : label;

  @override
  bool operator ==(Object other) =>
      other is BirthPlace &&
      other.label == label &&
      other.province == province &&
      other.latitude == latitude &&
      other.longitude == longitude;

  @override
  int get hashCode => Object.hash(label, province, latitude, longitude);
}

/// Alcune citta' internazionali di riserva, in attesa dell'estensione completa
/// oltre i comuni italiani (via la ricerca geografica dell'API).
class BirthPlaces {
  BirthPlaces._();

  static const List<BirthPlace> international = [
    BirthPlace(
        label: 'Londra',
        latitude: 51.5074,
        longitude: -0.1278,
        timezone: 'Europe/London'),
    BirthPlace(
        label: 'Parigi',
        latitude: 48.8566,
        longitude: 2.3522,
        timezone: 'Europe/Paris'),
    BirthPlace(
        label: 'Madrid',
        latitude: 40.4168,
        longitude: -3.7038,
        timezone: 'Europe/Madrid'),
    BirthPlace(
        label: 'Berlino',
        latitude: 52.52,
        longitude: 13.405,
        timezone: 'Europe/Berlin'),
    BirthPlace(
        label: 'New York',
        latitude: 40.7128,
        longitude: -74.006,
        timezone: 'America/New_York'),
    BirthPlace(
        label: 'Los Angeles',
        latitude: 34.0522,
        longitude: -118.2437,
        timezone: 'America/Los_Angeles'),
    BirthPlace(
        label: 'Buenos Aires',
        latitude: -34.6037,
        longitude: -58.3816,
        timezone: 'America/Argentina/Buenos_Aires'),
    BirthPlace(
        label: 'Tokyo',
        latitude: 35.6762,
        longitude: 139.6503,
        timezone: 'Asia/Tokyo'),
    BirthPlace(
        label: 'Sydney',
        latitude: -33.8688,
        longitude: 151.2093,
        timezone: 'Australia/Sydney'),
  ];
}
