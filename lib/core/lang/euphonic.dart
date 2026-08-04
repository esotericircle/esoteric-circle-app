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

/// LE PREPOSIZIONI ARTICOLATE, per i nomi che portano gia' il loro articolo.
///
/// **Il difetto che l'ha fatta nascere.** Il benvenuto della chat componeva
/// "Il tuo cammino di il Creativo ti accompagna": i titoli del numero della
/// vita portano il proprio articolo, "il Creativo", "l'Iniziatore", e la
/// preposizione ci veniva incollata davanti invece di fondersi. Non e' un caso
/// singolo: succede a ogni frase che accosti una preposizione a un dato che
/// arriva gia' articolato, e i dati articolati in questa app sono decine, dai
/// titoli del numero della vita ai nomi dei piani agli archetipi.
///
/// La tavola completa delle sette preposizioni italiane che si articolano.
const Map<String, Map<String, String>> _articolate = {
  'di': {'il': 'del', 'lo': 'dello', 'la': 'della', 'i': 'dei', 'gli': 'degli', 'le': 'delle', "l'": "dell'"},
  'a': {'il': 'al', 'lo': 'allo', 'la': 'alla', 'i': 'ai', 'gli': 'agli', 'le': 'alle', "l'": "all'"},
  'da': {'il': 'dal', 'lo': 'dallo', 'la': 'dalla', 'i': 'dai', 'gli': 'dagli', 'le': 'dalle', "l'": "dall'"},
  'in': {'il': 'nel', 'lo': 'nello', 'la': 'nella', 'i': 'nei', 'gli': 'negli', 'le': 'nelle', "l'": "nell'"},
  'su': {'il': 'sul', 'lo': 'sullo', 'la': 'sulla', 'i': 'sui', 'gli': 'sugli', 'le': 'sulle', "l'": "sull'"},
  'con': {'il': 'col', 'lo': 'con lo', 'la': 'con la', 'i': 'coi', 'gli': 'con gli', 'le': 'con le', "l'": "con l'"},
  'per': {'il': 'per il', 'lo': 'per lo', 'la': 'per la', 'i': 'per i', 'gli': 'per gli', 'le': 'per le', "l'": "per l'"},
};

/// Gli articoli riconosciuti, dal piu' lungo al piu' corto: "gli" prima di "i",
/// altrimenti "gli Angeli" verrebbe letto come articolo "i".
const List<String> _articoli = ['gli', 'lo', 'la', 'le', 'il', 'i'];

/// Unisce [preposizione] a [nome] fondendo l'articolo che il nome gia' porta.
///
/// "di" + "il Creativo" da' "del Creativo". "di" + "l'Iniziatore" da'
/// "dell'Iniziatore". Un nome senza articolo resta accostato: "di Medora".
/// La maiuscola del nome non si tocca mai: e' un nome proprio.
String preposizioneArticolata(String preposizione, String nome) {
  final prep = preposizione.trim().toLowerCase();
  final testo = nome.trim();
  if (testo.isEmpty) return prep;
  final tavola = _articolate[prep];
  if (tavola == null) return '$prep $testo';

  // L'apostrofo per primo: "l'Iniziatore" non comincia con nessuna delle
  // parole intere dell'elenco.
  final minuscolo = testo.toLowerCase();
  if (minuscolo.startsWith("l'") || minuscolo.startsWith('l\u2019')) {
    return '${tavola["l'"]}${testo.substring(2)}';
  }
  for (final art in _articoli) {
    if (minuscolo.startsWith('$art ')) {
      return '${tavola[art]} ${testo.substring(art.length + 1)}';
    }
  }
  return '$prep $testo';
}
