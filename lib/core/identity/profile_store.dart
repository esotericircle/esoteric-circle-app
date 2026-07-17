import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../chat/user_profile.dart';
import 'birth_identity.dart';
import 'birth_place.dart';

/// Cio' che l'onboarding raccoglie e che va ritrovato al riavvio: il profilo
/// (nome e vocativo) e l'identita' di nascita (data, ora se nota, luogo).
class StoredIdentity {
  const StoredIdentity({this.profile, this.identity});

  final UserProfile? profile;
  final BirthIdentity? identity;

  bool get isEmpty => profile == null && identity == null;
}

/// Salva e ritrova in locale il profilo e i dati di nascita, come lo streak dei
/// riti: `SharedPreferences`, best effort. Se la persistenza manca (test o
/// anteprima headless) tutto degrada a vuoto, senza mai sollevare un errore.
///
/// Nessun segreto e nessun dato sensibile lascia il dispositivo: resta qui, a
/// disposizione dei testi che si rivolgono alla persona.
class ProfileStore {
  const ProfileStore();

  static const _kName = 'profile.name';
  static const _kCourtesy = 'profile.courtesy';
  static const _kBirthDate = 'profile.birthDate'; // yyyy-mm-dd
  static const _kHasTime = 'profile.hasBirthTime';
  static const _kHour = 'profile.birthHour';
  static const _kMinute = 'profile.birthMinute';
  static const _kPlace = 'profile.place'; // JSON

  static String _stampDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static DateTime? _parseDate(String? s) {
    if (s == null) return null;
    final parts = s.split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }

  /// Ritrova quel che c'e'. Ritorna un [StoredIdentity] vuoto se non c'e' nulla
  /// o se la persistenza non e' disponibile.
  Future<StoredIdentity> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      UserProfile? profile;
      final name = prefs.getString(_kName);
      final courtesyId = prefs.getString(_kCourtesy);
      if (name != null || courtesyId != null) {
        profile = UserProfile(
          displayName: name,
          courtesyForm: CourtesyForm.fromId(courtesyId),
        );
      }

      BirthIdentity? identity;
      final date = _parseDate(prefs.getString(_kBirthDate));
      if (date != null) {
        final hasTime = prefs.getBool(_kHasTime) ?? false;
        BirthPlace? place;
        final placeRaw = prefs.getString(_kPlace);
        if (placeRaw != null) {
          try {
            final decoded = jsonDecode(placeRaw);
            if (decoded is Map<String, Object?>) {
              place = BirthPlace.fromJson(decoded);
            }
          } catch (_) {
            place = null;
          }
        }
        identity = BirthIdentity.fromParts(
          birthDate: date,
          birthHour: hasTime ? prefs.getInt(_kHour) : null,
          birthMinute: hasTime ? prefs.getInt(_kMinute) : null,
          birthPlace: place,
        );
      }

      return StoredIdentity(profile: profile, identity: identity);
    } catch (_) {
      return const StoredIdentity();
    }
  }

  /// Salva il profilo. Best effort: senza persistenza resta solo in memoria.
  Future<void> saveProfile(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (profile.hasName) {
        await prefs.setString(_kName, profile.displayName!.trim());
      }
      await prefs.setString(_kCourtesy, profile.courtesyForm.name);
    } catch (_) {
      // Best effort.
    }
  }

  /// Salva i dati di nascita. Best effort.
  Future<void> saveIdentity(BirthIdentity identity) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kBirthDate, _stampDate(identity.birthDate));
      await prefs.setBool(_kHasTime, identity.hasBirthTime);
      if (identity.hasBirthTime) {
        await prefs.setInt(_kHour, identity.birthMoment.hour);
        await prefs.setInt(_kMinute, identity.birthMoment.minute);
      } else {
        await prefs.remove(_kHour);
        await prefs.remove(_kMinute);
      }
      final place = identity.birthPlace;
      if (place != null) {
        await prefs.setString(_kPlace, jsonEncode(place.toJson()));
      } else {
        await prefs.remove(_kPlace);
      }
    } catch (_) {
      // Best effort.
    }
  }
}
