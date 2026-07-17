import 'package:flutter/foundation.dart';

import '../chat/user_profile.dart';
import 'birth_identity.dart';
import 'profile_store.dart';

/// Sorgente unica dell'identita' della persona per i testi che le si rivolgono.
///
/// Tiene insieme il profilo (nome, vocativo) e i dati di nascita da cui nascono
/// i fatti deterministici (Sigillo, Numero della vita, segno). Ogni copy che
/// parla alla persona usa il suo nome reale tramite [vocative] e concorda al
/// genere tramite [courtesy]. Il nome del tier ("Viandante") resta solo
/// etichetta del piano, mai vocativo: se il nome non c'e', un vocativo neutro di
/// brand.
///
/// Quel che l'onboarding raccoglie e' persistito in locale da [ProfileStore] e
/// ritrovato al riavvio con [load]: prima di allora vale il profilo d'esempio
/// della Demo, dichiarato, come `BirthIdentity.example`.
class ProfileController extends ChangeNotifier {
  ProfileController({
    UserProfile? profile,
    BirthIdentity? identity,
    ProfileStore store = const ProfileStore(),
  })  : _profile = profile ?? _demoProfile,
        _identity = identity ?? BirthIdentity.example,
        _store = store;

  /// Vocativo neutro di brand, quando il nome reale non e' ancora noto.
  static const String neutralVocative = 'Anima del Cerchio';

  /// Profilo d'esempio della Demo, dichiarato: nome reale con cui il cerchio
  /// accoglie la persona nella presentazione. L'onboarding lo sovrascrive.
  static const UserProfile _demoProfile = UserProfile(
    displayName: 'Sofia',
    courtesyForm: CourtesyForm.feminine,
  );

  final ProfileStore _store;
  UserProfile _profile;
  BirthIdentity _identity;

  UserProfile get profile => _profile;
  BirthIdentity get identity => _identity;

  /// Il vocativo di genere scelto, che pilota le concordanze dei testi.
  CourtesyForm get courtesy => _profile.courtesyForm;

  /// Vero se il profilo porta un nome reale utilizzabile come vocativo.
  bool get hasName => _profile.hasName;

  /// Il nome con cui rivolgersi alla persona. Mai il nome del tier: se il nome
  /// reale non c'e', un vocativo neutro di brand.
  String get vocative =>
      _profile.hasName ? _profile.displayName!.trim() : neutralVocative;

  /// Idrata profilo e identita' dal locale. Se c'e' un dato salvato sostituisce
  /// il seme della Demo; altrimenti resta il seme, senza mai bloccarsi.
  Future<void> load() async {
    final stored = await _store.load();
    var changed = false;
    if (stored.profile != null) {
      _profile = stored.profile!;
      changed = true;
    }
    if (stored.identity != null) {
      _identity = stored.identity!;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  void setProfile(UserProfile profile) {
    _profile = profile;
    notifyListeners();
    _store.saveProfile(profile);
  }

  void setIdentity(BirthIdentity identity) {
    _identity = identity;
    notifyListeners();
    _store.saveIdentity(identity);
  }
}
