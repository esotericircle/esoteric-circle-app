/// Profilo dell'utente noto ai Maestri.
///
/// Per ora contiene i pochi fatti identitari raccolti finora (nome e forma di
/// cortesia dell'onboarding, quando ci sara'). E' il primo dei tre strati della
/// memoria descritti nei briefing (profilo, fatti, sintesi di sessione). Resta
/// un modello puro, la persistenza vive nel repository di memoria.
library;
import '../identity/nome_proprio.dart';


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

  /// Etichetta della scelta all'onboarding, come la vede la persona.
  String get vocativeLabel {
    switch (this) {
      case CourtesyForm.masculine:
        return 'Lui';
      case CourtesyForm.feminine:
        return 'Lei';
      case CourtesyForm.neutral:
      case CourtesyForm.unknown:
        return 'Neutro';
    }
  }

  /// Concorda un testo al vocativo scelto. Al maschile usa [masculine], al
  /// femminile [feminine]; per il neutro e per la scelta non ancora fatta usa
  /// [neutral], una forma senza desinenza di genere (per esempio "ti do il
  /// benvenuto" invece di "benvenuto/benvenuta"). Cosi' il vocativo pilota le
  /// concordanze dei testi in tutta l'app.
  String agree({
    required String masculine,
    required String feminine,
    required String neutral,
  }) {
    switch (this) {
      case CourtesyForm.masculine:
        return masculine;
      case CourtesyForm.feminine:
        return feminine;
      case CourtesyForm.neutral:
      case CourtesyForm.unknown:
        return neutral;
    }
  }

  /// Il benvenuto concordato: "Benvenuto", "Benvenuta", o la forma neutra "Ti
  /// do il benvenuto". Scorciatoia dell'uso piu' frequente di [agree].
  String get welcome => agree(
        masculine: 'Benvenuto',
        feminine: 'Benvenuta',
        neutral: 'Ti do il benvenuto',
      );
}

/// Profilo persistente dell'utente, condiviso fra tutti i Maestri.
class UserProfile {
  /// Il nome si normalizza QUI, all'ingresso nel modello, non in chi lo
  /// scrive. Le porte da cui un nome entra sono due, `IdentityController` e
  /// questo profilo, e coprirne una sola e' esattamente l'errore che lasciava
  /// "mauro" minuscolo nella home mentre i test dichiaravano la cosa chiusa.
  UserProfile({
    String? displayName,
    this.courtesyForm = CourtesyForm.unknown,
    this.disclaimerAcceptedAt,
  }) : displayName = (displayName == null || displayName.trim().isEmpty)
            ? null
            : normalizzaNomeProprio(displayName);

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

  /// Non piu' const: il nome passa dalla normalizzazione, che e' codice, e
  /// un valore costante non puo' eseguire codice. Il prezzo e' una istanza
  /// invece di una costante, ed e' un prezzo che vale la certezza.
  static final UserProfile empty = UserProfile();
}
