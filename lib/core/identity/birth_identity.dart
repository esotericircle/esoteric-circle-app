/// I dati identitari fissi dell'utente, da cui nascono i fatti deterministici
/// del Cosmic Passport.
///
/// Oggi bastano il momento di nascita per i fatti che non dipendono da servizi
/// esterni: il Numero della vita (dalla sola data) e la Fase lunare di nascita
/// (dal solo momento). Luogo e ora precisa serviranno per la carta natale
/// completa, che resta dietro il velo. Finche' l'onboarding non raccoglie il
/// dato reale, si usa `BirthIdentity.example`, dichiarato in-world: passando
/// un'identita' reale (`isExample` falso) le tessere si popolano da sole.
class BirthIdentity {
  const BirthIdentity({required this.birthMoment, this.isExample = false});

  /// Momento di nascita. Per i fatti odierni conta la data; l'ora affinera' la
  /// fase lunare quando ci sara' il dato reale.
  final DateTime birthMoment;

  /// Se e' il dato d'esempio in attesa di quello reale dall'onboarding.
  final bool isExample;

  /// Dato d'esempio, dichiarato in-world, finche' non arriva la data vera.
  static final BirthIdentity example =
      BirthIdentity(birthMoment: DateTime(1990, 6, 15, 2, 30), isExample: true);
}
