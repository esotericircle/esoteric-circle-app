/// **I DUE ELENCHI DEL NOME INIZIATICO, ordine EY voce 01.** Un file di dati e
/// non righe sparse: gli appellativi e le qualita' con cui il Cerchio compone
/// il nome che propone a chi arriva.
///
/// **Il registro**: parole della natura e della luce, quelle con cui le arti
/// del Cerchio parlano gia'. **Nessuna parola promette un grado iniziatico
/// vero**: niente Maestro, Adepto, Iniziato, Illuminato, Sacerdote, Gran,
/// Magister, Ierofante; una prova le cerca.
///
/// **Le qualita' sono aggettivi in -e**, che in italiano non cambiano col
/// genere: il nome vale per chiunque, senza indovinare chi lo portera'.
///
/// I simboli NON stanno qui: si pescano dai set che il progetto possiede gia'
/// (i dodici segni, i dodici animali guida, i ventidue Arcani, le ventiquattro
/// rune, i dodici archetipi), in `il_nome_iniziatico.dart`.
abstract final class INomiIniziatici {
  static const List<String> appellativi = [
    'Eco', 'Voce', 'Passo', 'Soffio', 'Lume', 'Velo', 'Seme', 'Ombra', //
    'Fiamma', 'Brace', 'Onda', 'Fonte', 'Rugiada', 'Alba', 'Vespro', //
    'Brezza', 'Cenere', 'Ambra', 'Selce', 'Spiga', 'Ramo', 'Radice', //
    'Nube', 'Neve', 'Stilla', 'Scia', 'Orma', 'Soglia', 'Rotta', 'Faro', //
    'Candela', 'Quarzo', 'Opale', 'Perla', 'Giada', 'Edera', 'Salvia', //
    'Mirto', 'Alloro', 'Cedro', 'Quercia', 'Tiglio', 'Vela', 'Riva', //
    'Cometa', 'Bruma', 'Fuoco', 'Vento', 'Sale', 'Miele', 'Torcia', //
    'Corda', 'Arpa', 'Eclisse', 'Nodo', 'Prisma',
  ];

  static const List<String> qualita = [
    'Lieve', 'Gentile', 'Fedele', 'Ardente', 'Celeste', 'Silente', //
    'Lucente', 'Docile', 'Agile', 'Tenace', 'Audace', 'Vivace', 'Sagace', //
    'Fugace', 'Verace', 'Perenne', 'Solenne', 'Dolce', 'Forte', //
    'Costante', 'Paziente', 'Prudente', 'Nascente', 'Errante', 'Vagante', //
    'Raggiante', 'Vibrante', 'Danzante', 'Sognante', 'Fluente', 'Ridente', //
    'Crescente', 'Calante', 'Rovente', 'Possente', 'Ribelle', 'Fiorente', //
    'Sapiente', 'Brillante', 'Mutevole', 'Cangiante', 'Sottile', 'Umile', //
    'Mite', 'Stellare', 'Lunare', 'Solare', 'Astrale', 'Boreale', //
    'Australe', 'Autunnale', 'Invernale', 'Silvestre', 'Alpestre', //
    'Campestre', 'Vigile', 'Felice', 'Veloce', 'Tenue', 'Insonne', 'Leale', //
    'Serale',
  ];

  /// I nomi brevi dei ventidue Arcani Maggiori per numero, da 0 a 21, senza
  /// l'articolo: stanno nei venti caratteri del nome. **La Morte e il
  /// Diavolo restano fuori dal nome proposto**, e si dichiara: sono carte
  /// della tradizione, ma un nome che il Cerchio regala a chi arriva non le
  /// porta addosso senza che la persona le scelga. Chi le vuole le scrive.
  static const Map<int, String> arcaniBrevi = {
    0: 'Matto',
    1: 'Mago',
    2: 'Papessa',
    3: 'Imperatrice',
    4: 'Imperatore',
    5: 'Papa',
    6: 'Amanti',
    7: 'Carro',
    8: 'Forza',
    9: 'Eremita',
    10: 'Ruota',
    11: 'Giustizia',
    12: 'Appeso',
    14: 'Temperanza',
    16: 'Torre',
    17: 'Stella',
    18: 'Luna',
    19: 'Sole',
    20: 'Giudizio',
    21: 'Mondo',
  };
}
