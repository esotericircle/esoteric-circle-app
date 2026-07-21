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
  Uint8List? _avatarPhoto;

  UserProfile get profile => _profile;
  BirthIdentity get identity => _identity;

  /// I byte della foto dell'avatar dell'utente, se ne ha scelta una. Tenuta SOLO
  /// in locale, mai caricata. Null quando l'avatar e' quello di default (il
  /// segno, le iniziali o il sigillo neutro).
  Uint8List? get avatarPhoto => _avatarPhoto;

  /// Vero se l'utente ha messo una sua foto come avatar.
  bool get hasAvatarPhoto => _avatarPhoto != null && _avatarPhoto!.isNotEmpty;

  /// Il vocativo di genere scelto, che pilota le concordanze dei testi.
  CourtesyForm get courtesy => _profile.courtesyForm;

  /// Vero se il profilo porta un nome reale utilizzabile come vocativo.
  bool get hasName => _profile.hasName;

  /// Il nome con cui rivolgersi alla persona. Mai il nome del tier: se il nome
  /// reale non c'e', un vocativo neutro di brand.
  String get vocative =>
      _profile.hasName ? _profile.displayName!.trim() : neutralVocative;

  /// Idrata profilo, identita' e avatar dal locale. Se c'e' un dato salvato
  /// sostituisce il seme della Demo; altrimenti resta il seme, senza mai
  /// bloccarsi.
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
    final photo = await _store.loadAvatarPhoto();
    if (photo != null && photo.isNotEmpty) {
      _avatarPhoto = photo;
      changed = true;
    }
    if (changed) notifyListeners();
  }

  /// Imposta la foto dell'avatar dell'utente, tenuta solo in locale. Sostituisce
  /// l'avatar di default finche' non viene rimossa.
  void setAvatarPhoto(Uint8List bytes) {
    _avatarPhoto = bytes;
    notifyListeners();
    _store.saveAvatarPhoto(bytes);
  }

  /// Toglie la foto dell'avatar e torna al default a tema (il segno, le iniziali
  /// o il sigillo neutro).
  void clearAvatarPhoto() {
    if (_avatarPhoto == null) return;
    _avatarPhoto = null;
    notifyListeners();
    _store.saveAvatarPhoto(null);
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
