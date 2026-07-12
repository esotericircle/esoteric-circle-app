/// Piccoli aiuti di lingua italiana.
///
/// La "d" eufonica: davanti a parola che inizia per vocale la preposizione "a"
/// diventa "ad" (per esempio "ad Aura", "ad esempio"), davanti a consonante
/// resta "a".
library;

const Set<String> _vowels = {'a', 'e', 'i', 'o', 'u', 'à', 'è', 'é', 'ì', 'ò', 'ù'};

/// Restituisce "ad" se [next] inizia per vocale, altrimenti "a".
String aEuphonic(String next) {
  final trimmed = next.trimLeft();
  if (trimmed.isEmpty) return 'a';
  return _vowels.contains(trimmed[0].toLowerCase()) ? 'ad' : 'a';
}
