import 'package:flutter/foundation.dart';

import '../chat/user_profile.dart';
import 'birth_identity.dart';

/// Sorgente unica dell'identita' della persona per i testi che le si rivolgono.
///
/// Tiene insieme il profilo (nome, forma di cortesia) e i dati di nascita da cui
/// nascono i fatti deterministici (Sigillo, Numero della vita, segno). Ogni copy
/// che parla alla persona usa il suo nome reale tramite [vocative]. Il nome del
/// tier ("Viandante") resta solo etichetta del piano, mai vocativo: se il nome
/// non c'e', si usa un vocativo neutro di brand.
///
/// Per la Demo il profilo e' seminato con un'identita' d'esempio dichiarata, allo
/// stesso modo di `BirthIdentity.example`: l'onboarding reale la sostituira' con
/// `setProfile` e `setIdentity`.
class ProfileController extends ChangeNotifier {
  ProfileController({UserProfile? profile, BirthIdentity? identity})
      : _profile = profile ?? _demoProfile,
        _identity = identity ?? BirthIdentity.example;

  /// Vocativo neutro di brand, quando il nome reale non e' ancora noto.
  static const String neutralVocative = 'Anima del Cerchio';

  /// Profilo d'esempio della Demo, dichiarato: nome reale con cui il cerchio
  /// accoglie la persona nella presentazione. L'onboarding lo sovrascrive.
  static const UserProfile _demoProfile = UserProfile(
    displayName: 'Sofia',
    courtesyForm: CourtesyForm.feminine,
  );

  UserProfile _profile;
  BirthIdentity _identity;

  UserProfile get profile => _profile;
  BirthIdentity get identity => _identity;

  /// Vero se il profilo porta un nome reale utilizzabile come vocativo.
  bool get hasName => _profile.hasName;

  /// Il nome con cui rivolgersi alla persona. Mai il nome del tier: se il nome
  /// reale non c'e', un vocativo neutro di brand.
  String get vocative =>
      _profile.hasName ? _profile.displayName!.trim() : neutralVocative;

  void setProfile(UserProfile profile) {
    _profile = profile;
    notifyListeners();
  }

  void setIdentity(BirthIdentity identity) {
    _identity = identity;
    notifyListeners();
  }
}
