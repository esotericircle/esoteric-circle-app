/// Profilo dell'utente noto ai Maestri.
///
/// Per ora contiene i pochi fatti identitari raccolti finora (nome e forma di
/// cortesia dell'onboarding, quando ci sara'). E' il primo dei tre strati della
/// memoria descritti nei briefing (profilo, fatti, sintesi di sessione). Resta
/// un modello puro, la persistenza vive nel repository di memoria.
library;

/// Forma di cortesia scelta all'onboarding, per rivolgersi all'utente nella
/// lingua giusta. In attesa dell'onboarding resta sconosciuta e i Maestri usano
/// formulazioni neutre.
enum CourtesyForm {
  feminine,
  masculine,
  neutral,
  unknown;

  static CourtesyForm fromId(String? id) {
    for (final f in CourtesyForm.values) {
      if (f.name == id) return f;
    }
    return CourtesyForm.unknown;
  }
}

/// Profilo persistente dell'utente, condiviso fra tutti i Maestri.
class UserProfile {
  const UserProfile({
    this.displayName,
    this.courtesyForm = CourtesyForm.unknown,
    this.disclaimerAcceptedAt,
  });

  /// Nome con cui il cerchio si rivolge all'utente. Null finche' l'onboarding
  /// non lo raccoglie.
  final String? displayName;

  /// Forma di cortesia per la lingua dei Maestri.
  final CourtesyForm courtesyForm;

  /// Istante in cui l'utente ha visto e accettato il disclaimer. Null se non
  /// ancora mostrato: il disclaimer si presenta una sola volta.
  final DateTime? disclaimerAcceptedAt;

  bool get hasSeenDisclaimer => disclaimerAcceptedAt != null;

  bool get hasName => displayName != null && displayName!.trim().isNotEmpty;

  UserProfile copyWith({
    String? displayName,
    CourtesyForm? courtesyForm,
    DateTime? disclaimerAcceptedAt,
  }) {
    return UserProfile(
      displayName: displayName ?? this.displayName,
      courtesyForm: courtesyForm ?? this.courtesyForm,
      disclaimerAcceptedAt: disclaimerAcceptedAt ?? this.disclaimerAcceptedAt,
    );
  }

  static const UserProfile empty = UserProfile();
}
