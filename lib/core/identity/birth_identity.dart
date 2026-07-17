import 'birth_place.dart';

/// I dati identitari fissi dell'utente, da cui nascono i fatti deterministici
/// del Cosmic Passport.
///
/// Il momento di nascita regge i fatti che non dipendono da servizi esterni: il
/// Numero della vita (dalla sola data) e la Fase lunare di nascita (dal
/// momento). L'ora precisa e il luogo servono alla carta natale completa
/// (Ascendente e case), che resta dietro il velo del motore a effemeridi. Qui
/// l'ora puo' mancare ([hasBirthTime] falso): in quel caso il momento usa
/// mezzogiorno come punto stabile, dichiarato, senza spacciarlo per l'ora vera.
///
/// Finche' l'onboarding non raccoglie il dato reale si usa
/// `BirthIdentity.example`, dichiarato in-world: passando un'identita' reale
/// (`isExample` falso) le tessere si popolano da sole.
class BirthIdentity {
  const BirthIdentity({
    required this.birthMoment,
    this.hasBirthTime = true,
    this.birthPlace,
    this.isExample = false,
  });

  /// Costruisce l'identita' dai pezzi raccolti a onboarding: la data (sempre),
  /// l'ora (che puo' mancare) e il luogo (che puo' mancare). Se l'ora non c'e',
  /// il momento si ancora a mezzogiorno e [hasBirthTime] resta falso.
  factory BirthIdentity.fromParts({
    required DateTime birthDate,
    int? birthHour,
    int? birthMinute,
    BirthPlace? birthPlace,
    bool isExample = false,
  }) {
    final hasTime = birthHour != null;
    return BirthIdentity(
      birthMoment: DateTime(
        birthDate.year,
        birthDate.month,
        birthDate.day,
        hasTime ? birthHour : 12,
        hasTime ? (birthMinute ?? 0) : 0,
      ),
      hasBirthTime: hasTime,
      birthPlace: birthPlace,
      isExample: isExample,
    );
  }

  /// Momento di nascita. Per i fatti odierni conta la data; l'ora affina la
  /// fase lunare quando c'e' il dato reale, e serve all'Ascendente futuro.
  final DateTime birthMoment;

  /// Se l'ora di nascita e' nota. Quando e' falsa il momento e' ancorato a
  /// mezzogiorno e l'Ascendente non si puo' calcolare: si salta con grazia.
  final bool hasBirthTime;

  /// Il luogo di nascita, quando raccolto. Serve ad ancorare il cielo alla
  /// Terra per l'Ascendente e le case. Null finche' non c'e'.
  final BirthPlace? birthPlace;

  /// Se e' il dato d'esempio in attesa di quello reale dall'onboarding.
  final bool isExample;

  /// La sola data di nascita, senza l'ora.
  DateTime get birthDate =>
      DateTime(birthMoment.year, birthMoment.month, birthMoment.day);

  BirthIdentity copyWith({
    DateTime? birthMoment,
    bool? hasBirthTime,
    BirthPlace? birthPlace,
    bool? isExample,
  }) {
    return BirthIdentity(
      birthMoment: birthMoment ?? this.birthMoment,
      hasBirthTime: hasBirthTime ?? this.hasBirthTime,
      birthPlace: birthPlace ?? this.birthPlace,
      isExample: isExample ?? this.isExample,
    );
  }

  /// Dato d'esempio, dichiarato in-world, finche' non arriva la data vera.
  static final BirthIdentity example = BirthIdentity(
    birthMoment: DateTime(1990, 6, 15, 2, 30),
    isExample: true,
  );
}
