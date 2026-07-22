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

/// Compone la preposizione "con" col nome di un livello del Cerchio.
///
/// I nomi dei piani portano gia' il loro articolo ("L'Adepto", "L'Iniziato"),
/// quindi accostarli a una preposizione articolata dava "col L'Adepto". Qui
/// l'articolo si fonde nella preposizione e il nome resta maiuscolo: "con
/// l'Adepto". Un nome senza articolo prende il suo: "con il Viandante".
String conPiano(String plan) {
  final nome = plan.trim();
  if (nome.isEmpty) return 'con il Cerchio';
  final apostrofo = nome.length > 1 && nome[0].toLowerCase() == 'l' &&
      (nome[1] == '\'' || nome[1] == '’');
  if (apostrofo) return 'con l\'${nome.substring(2)}';
  // Articolo gia' staccato ("Il Cerchio", "La Soglia"): basta minuscolarlo.
  for (final art in const ['Il ', 'Lo ', 'La ', 'I ', 'Gli ', 'Le ']) {
    if (nome.startsWith(art)) {
      return 'con ${art.toLowerCase()}${nome.substring(art.length)}';
    }
  }
  return 'con il $nome';
}
