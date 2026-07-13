/// Una runa dell'antico Futhark, con nome, glifo e presagio simbolico reale.
///
/// Il glifo e' il carattere runico Unicode: e' testo, non un asset, quindi qui e'
/// gia' quello vero. L'eventuale arte incisa di brand vive sul bucket e non e'
/// disponibile in questo ambiente: dove servisse, si dichiara segnaposto.
class Rune {
  const Rune({
    required this.name,
    required this.glyph,
    required this.keyword,
    required this.meaning,
  });

  final String name;
  final String glyph;

  /// Una parola chiave del presagio.
  final String keyword;

  /// Riga breve di significato, nella tradizione del Futhark antico.
  final String meaning;
}

/// L'Elder Futhark, i ventiquattro segni nell'ordine tradizionale.
const List<Rune> kElderFuthark = [
  Rune(name: 'Fehu', glyph: 'ᚠ', keyword: 'Abbondanza', meaning: 'Il bestiame, la ricchezza che scorre: raccogli senza trattenere.'),
  Rune(name: 'Uruz', glyph: 'ᚢ', keyword: 'Forza', meaning: 'L\'uro selvaggio, vigore grezzo: la forza che apre il varco.'),
  Rune(name: 'Thurisaz', glyph: 'ᚦ', keyword: 'Difesa', meaning: 'La spina, forza che reagisce: proteggi il confine con misura.'),
  Rune(name: 'Ansuz', glyph: 'ᚨ', keyword: 'Parola', meaning: 'Il soffio del dio, ispirazione: ascolta il messaggio che arriva.'),
  Rune(name: 'Raidho', glyph: 'ᚱ', keyword: 'Cammino', meaning: 'Il viaggio, il ritmo giusto: muoviti con il tempo, non contro.'),
  Rune(name: 'Kenaz', glyph: 'ᚲ', keyword: 'Luce', meaning: 'La torcia, conoscenza che rivela: una scintilla illumina l\'opera.'),
  Rune(name: 'Gebo', glyph: 'ᚷ', keyword: 'Dono', meaning: 'Il dono, lo scambio alla pari: dare apre a ricevere.'),
  Rune(name: 'Wunjo', glyph: 'ᚹ', keyword: 'Gioia', meaning: 'La gioia, l\'armonia raggiunta: gusta ciò che si è composto.'),
  Rune(name: 'Hagalaz', glyph: 'ᚺ', keyword: 'Prova', meaning: 'La grandine, la scossa che passa: dopo la tempesta, terreno pulito.'),
  Rune(name: 'Nauthiz', glyph: 'ᚾ', keyword: 'Bisogno', meaning: 'La necessità, l\'attrito che tempra: la pazienza diventa forza.'),
  Rune(name: 'Isa', glyph: 'ᛁ', keyword: 'Sosta', meaning: 'Il ghiaccio, la pausa immobile: fermati, ascolta il silenzio.'),
  Rune(name: 'Jera', glyph: 'ᛃ', keyword: 'Raccolto', meaning: 'L\'anno, il ciclo compiuto: ciò che hai seminato matura.'),
  Rune(name: 'Eihwaz', glyph: 'ᛇ', keyword: 'Resilienza', meaning: 'Il tasso, l\'asse del mondo: radici salde reggono il vento.'),
  Rune(name: 'Perthro', glyph: 'ᛈ', keyword: 'Mistero', meaning: 'La sorte nascosta, il grembo: accogli ciò che ancora non sai.'),
  Rune(name: 'Algiz', glyph: 'ᛉ', keyword: 'Protezione', meaning: 'L\'alce, lo scudo alzato: sei difeso, resta connesso al sacro.'),
  Rune(name: 'Sowilo', glyph: 'ᛊ', keyword: 'Vittoria', meaning: 'Il sole, l\'energia che vince: la volontà ritrova la sua luce.'),
  Rune(name: 'Tiwaz', glyph: 'ᛏ', keyword: 'Giustizia', meaning: 'Tyr, il coraggio giusto: agisci con onore, anche a un prezzo.'),
  Rune(name: 'Berkano', glyph: 'ᛒ', keyword: 'Nascita', meaning: 'La betulla, la crescita che cura: qualcosa di nuovo germoglia.'),
  Rune(name: 'Ehwaz', glyph: 'ᛖ', keyword: 'Fiducia', meaning: 'Il cavallo, il moto condiviso: procedi insieme a chi ti sostiene.'),
  Rune(name: 'Mannaz', glyph: 'ᛗ', keyword: 'Il sé', meaning: 'L\'uomo, l\'umanità: ritrova te stesso dentro la comunità.'),
  Rune(name: 'Laguz', glyph: 'ᛚ', keyword: 'Intuizione', meaning: 'L\'acqua, il flusso profondo: fidati di ciò che senti sotto.'),
  Rune(name: 'Ingwaz', glyph: 'ᛜ', keyword: 'Potenziale', meaning: 'Ing, il seme in gestazione: forza che matura in silenzio.'),
  Rune(name: 'Dagaz', glyph: 'ᛞ', keyword: 'Risveglio', meaning: 'Il giorno, l\'alba che cambia: una svolta chiara si apre.'),
  Rune(name: 'Othala', glyph: 'ᛟ', keyword: 'Radici', meaning: 'L\'eredità, la casa: ciò che sei viene da lontano, onoralo.'),
];
