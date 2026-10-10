/// Il luogo di nascita, ridotto a cio' che serve per ancorare il cielo alla
/// Terra: nome della citta', coordinate e fuso orario.
///
/// Le coordinate e il fuso restano sul dispositivo. Il fuso e' quello nominale
/// della citta' (per esempio "Europe/Rome" con offset +60 minuti): basta a
/// orientare il segnaposto della carta e a mostrarlo alla persona. Il calcolo
/// storico esatto con le regole dell'ora legale, che serve alla carta natale
/// vera, arrivera' dal motore a effemeridi, mai inventato qui.
class BirthPlace {
  const BirthPlace({
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.timeZoneId,
    required this.utcOffsetMinutes,
    this.isApproximate = false,
  });

  /// Nome della citta', come mostrato alla persona.
  final String city;

  final double latitude;
  final double longitude;

  /// Fuso nominale, forma IANA ("Europe/Rome"). Etichetta stabile del luogo.
  final String timeZoneId;

  /// Offset nominale dal tempo universale, in minuti. Segnaposto per il
  /// posizionamento: l'offset storico esatto lo dara' il motore a effemeridi.
  final int utcOffsetMinutes;

  /// Vero se il luogo scelto e' un ripiego (la citta' piu' vicina in elenco,
  /// non una corrispondenza esatta). Cosi' la carta puo' marcarsi provvisoria.
  final bool isApproximate;

  BirthPlace copyWith({bool? isApproximate}) => BirthPlace(
        city: city,
        latitude: latitude,
        longitude: longitude,
        timeZoneId: timeZoneId,
        utcOffsetMinutes: utcOffsetMinutes,
        isApproximate: isApproximate ?? this.isApproximate,
      );

  Map<String, Object> toJson() => {
        'city': city,
        'lat': latitude,
        'lon': longitude,
        'tz': timeZoneId,
        'off': utcOffsetMinutes,
        'approx': isApproximate,
      };

  static BirthPlace? fromJson(Map<String, Object?> json) {
    final city = json['city'];
    final lat = json['lat'];
    final lon = json['lon'];
    final tz = json['tz'];
    final off = json['off'];
    if (city is! String || lat is! num || lon is! num || tz is! String) {
      return null;
    }
    return BirthPlace(
      city: city,
      latitude: lat.toDouble(),
      longitude: lon.toDouble(),
      timeZoneId: tz,
      utcOffsetMinutes: off is num ? off.toInt() : 0,
      isApproximate: json['approx'] == true,
    );
  }
}
