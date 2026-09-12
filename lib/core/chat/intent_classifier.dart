import '../maestro/maestro.dart';
import 'immersive_intents.dart';

/// Classificatore d'intento leggero e deterministico, senza AI.
///
/// Normalizza il testo (minuscolo, accenti ridotti) e cerca le parole chiave
/// dell'allow-list del Maestro. Se trova un intento immersivo lo restituisce,
/// cosi' la chat apre la funzione dedicata invece di generare una lettura a
/// testo. La logica sta qui, le parole chiave nel file di configurazione.
class IntentClassifier {
  const IntentClassifier();

  /// Restituisce l'intento immersivo per il testo, oppure null se e' una
  /// domanda normale del dominio, da rispondere a testo.
  ImmersiveIntent? classify(Maestro maestro, String text) {
    final norm = _normalize(text);
    if (norm.isEmpty) return null;

    ImmersiveIntent? best;
    var bestLen = 0;
    for (final intent in ImmersiveIntents.forMaestro(maestro)) {
      for (final keyword in intent.keywords) {
        final k = _normalize(keyword);
        if (k.isEmpty) continue;
        if (_containsWord(norm, k) && k.length > bestLen) {
          best = intent;
          bestLen = k.length;
        }
      }
    }
    return best;
  }

  // Minuscolo e accenti ridotti alle vocali semplici, cosi' "affinità" e
  // "affinita" combaciano senza sorprese.
  static String _normalize(String s) {
    final lower = s.toLowerCase();
    const map = {
      'à': 'a',
      'è': 'e',
      'é': 'e',
      'ì': 'i',
      'ò': 'o',
      'ù': 'u',
    };
    final buffer = StringBuffer();
    for (final ch in lower.split('')) {
      buffer.write(map[ch] ?? ch);
    }
    return buffer.toString();
  }

  // La chiave deve comparire come parola o frase intera, non dentro un'altra
  // parola: "rune" non scatta dentro "prune".
  static bool _containsWord(String haystack, String needle) {
    var from = 0;
    while (true) {
      final i = haystack.indexOf(needle, from);
      if (i < 0) return false;
      final before = i == 0 ? ' ' : haystack[i - 1];
      final afterIndex = i + needle.length;
      final after = afterIndex >= haystack.length ? ' ' : haystack[afterIndex];
      if (!_isWordChar(before) && !_isWordChar(after)) return true;
      from = i + 1;
    }
  }

  static bool _isWordChar(String c) {
    if (c.isEmpty) return false;
    final code = c.codeUnitAt(0);
    final isDigit = code >= 48 && code <= 57;
    final isLower = code >= 97 && code <= 122;
    final isUpper = code >= 65 && code <= 90;
    return isDigit || isLower || isUpper;
  }
}
