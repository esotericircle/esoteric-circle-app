/// Testi localizzati per chiave, con l'italiano di default.
///
/// La UI legge i testi per chiave, mai come stringa fissa: aggiungere l'inglese
/// (o un'altra lingua) significa riempire la colonna della lingua in queste
/// mappe, senza toccare il codice delle schermate. E' un primo strato leggero e
/// senza dipendenze: puo' migrare a `gen_l10n` con file ARB quando serve, con le
/// stesse chiavi.
///
/// La lingua corrente e' `languageCode`, italiano di default. Se una lingua non
/// ha la voce, si ripiega sull'italiano, e infine sulla chiave stessa.
class AppStrings {
  const AppStrings._();

  /// Lingua corrente. Italiano di default; l'inglese si attiva mettendo 'en'.
  static String languageCode = 'it';

  static const String _fallbackLanguage = 'it';

  /// Le voci della barra di navigazione.
  static const Map<String, Map<String, String>> _nav = {
    'nav.santuario': {'it': 'Il Cerchio', 'en': 'The Circle'},
    // "Passport" resta come termine di brand: Mauro conferma se in italiano
    // diventa "Passaporto" o resta invariato.
    'nav.passport': {'it': 'Passport', 'en': 'Passport'},
  };

  /// I nomi delle funzioni, per id dello scaffale del Santuario.
  static const Map<String, Map<String, String>> _functions = {
    'tarot_spread_three': {'it': 'Stesa a Tre Carte', 'en': 'Three Card Spread'},
    'synastry_vip': {'it': 'Sinastria VIP', 'en': 'VIP Synastry'},
    'archetype_test': {'it': 'Test Archetipo', 'en': 'Archetype Test'},
    'face_constellation': {'it': 'Costellazione del Viso', 'en': 'Face Constellation'},
    'day_oracle': {'it': 'Oracolo del Giorno', 'en': 'Oracle of the Day'},
    'sunset_rune': {'it': 'Runa del Tramonto', 'en': 'Sunset Rune'},
    'meditation': {'it': 'Meditazione', 'en': 'Meditation'},
  };

  static String _pick(Map<String, String>? byLang, String key) {
    if (byLang == null) return key;
    return byLang[languageCode] ?? byLang[_fallbackLanguage] ?? key;
  }

  static String get navSantuario => _pick(_nav['nav.santuario'], 'Il Cerchio');
  static String get navPassport => _pick(_nav['nav.passport'], 'Passport');

  /// Il nome localizzato di una funzione dello scaffale, per id. Se la chiave non
  /// c'e', usa il [fallback] passato dalla configurazione.
  static String functionTitle(String id, {required String fallback}) {
    final byLang = _functions[id];
    if (byLang == null) return fallback;
    return byLang[languageCode] ?? byLang[_fallbackLanguage] ?? fallback;
  }
}
