import '../assets/family_image.dart';

/// Una runa dell'antico Futhark, con nome, glifo, presagio simbolico reale e
/// l'arte incisa bundlata.
///
/// Il glifo e' il carattere runico Unicode: e' testo, non un asset, quindi qui e'
/// gia' quello vero. L'arte incisa della pietra e' ora bundlata nella famiglia
/// `rune_bone`: [stem] e' il nome del file senza estensione, e i percorsi si
/// risolvono da [FamilyImage] (piena quando la runa e' a fuoco, miniatura nelle
/// viste con piu' rune).
class Rune {
  const Rune({
    required this.name,
    required this.glyph,
    required this.keyword,
    required this.meaning,
    this.stem,
    this.upright = '',
    this.shadow = '',
  });

  final String name;
  final String glyph;

  /// Una parola chiave del presagio.
  final String keyword;

  /// Riga breve di significato, nella tradizione del Futhark antico.
  final String meaning;

  /// Nome del file dell'arte incisa senza estensione, oppure null se non
  /// agganciata.
  final String? stem;

  /// Il verso dritto e il verso d'ombra (merkstave), dal corpus.
  final String upright;
  final String shadow;

  /// Percorso della pietra piena, per la runa a fuoco.
  String? get fullPath =>
      stem == null ? null : FamilyImage.full(AssetFamily.rune, stem!);

  /// Percorso della miniatura, per le viste con piu' rune.
  String? get thumbPath =>
      stem == null ? null : FamilyImage.thumb(AssetFamily.rune, stem!);

  /// Vero se la runa ha l'arte incisa caricabile.
  bool get hasImage => stem != null;
}

/// L'Elder Futhark, i ventiquattro segni nell'ordine tradizionale.
const List<Rune> kElderFuthark = [
  Rune(name: 'Fehu', glyph: 'ᚠ', keyword: 'Abbondanza', meaning: 'Il bestiame, la ricchezza che scorre: raccogli senza trattenere.', stem: 'rune_bone_01_fehu_v1', upright: 'L\'abbondanza che scorre. Ricchezza ed energia che circolano: non da trattenere, ma da far muovere perché fruttino.', shadow: 'L\'abbondanza che sfugge. Ricchezza che si disperde, o un attaccamento a ciò che hai: apri la mano, ciò che trattieni troppo si consuma.'),
  Rune(name: 'Uruz', glyph: 'ᚢ', keyword: 'Forza', meaning: 'L\'uro selvaggio, vigore grezzo: la forza che apre il varco.', stem: 'rune_bone_02_uruz_v1', upright: 'La forza che sale. Vigore grezzo, salute, coraggio primordiale: la potenza che ti rimette in piedi.', shadow: 'La forza mal spesa. Vigore speso di slancio, oppure un\'energia che cala: ritrova il ritmo prima di caricare.'),
  Rune(name: 'Thurisaz', glyph: 'ᚦ', keyword: 'Difesa', meaning: 'La spina, forza che reagisce: proteggi il confine con misura.', stem: 'rune_bone_03_thurisaz_v1', upright: 'La spina che difende. Una forza aspra, un ostacolo che protegge: energia da dirigere con misura, non da temere.', shadow: 'La spina rivolta a te. Una reazione impulsiva, un ostacolo che ti punge: fermati un istante, la fretta qui ferisce.'),
  Rune(name: 'Ansuz', glyph: 'ᚨ', keyword: 'Parola', meaning: 'Il soffio del dio, ispirazione: ascolta il messaggio che arriva.', stem: 'rune_bone_04_ansuz_v1', upright: 'Il soffio della parola. Ispirazione, messaggio, saggezza che arriva: ascolta il segno, una voce ti raggiunge.', shadow: 'La parola confusa. Un messaggio frainteso, un consiglio da soppesare: ascolta meglio prima di dare peso a ciò che senti.'),
  Rune(name: 'Raidho', glyph: 'ᚱ', keyword: 'Cammino', meaning: 'Il viaggio, il ritmo giusto: muoviti con il tempo, non contro.', stem: 'rune_bone_05_raidho_v1', upright: 'Il cammino giusto. Il viaggio e il suo ritmo: muoviti con la cadenza giusta, dentro e fuori di te.', shadow: 'Il cammino accidentato. Un viaggio a scatti, un ritmo perso: rallenta e ritrova la cadenza, la strada torna piana.'),
  Rune(name: 'Kenaz', glyph: 'ᚲ', keyword: 'Luce', meaning: 'La torcia, conoscenza che rivela: una scintilla illumina l\'opera.', stem: 'rune_bone_06_kenaz_v1', upright: 'La torcia che rivela. La fiamma della conoscenza e dell\'ingegno: una luce si accende dove prima era buio.', shadow: 'La torcia che vacilla. Un\'idea ancora al buio, una chiarezza che tarda: la fiamma c\'è, dalle tempo di prendere.'),
  Rune(name: 'Gebo', glyph: 'ᚷ', keyword: 'Dono', meaning: 'Il dono, lo scambio alla pari: dare apre a ricevere.', stem: 'rune_bone_07_gebo_v1', upright: 'Il dono e il patto. Scambio, generosità, alleanza: l\'equilibrio sacro tra ciò che dai e ciò che ricevi.', shadow: 'Il dono sbilanciato. Uno scambio che pende da un lato solo: riporta equilibrio tra ciò che offri e ciò che accetti.'),
  Rune(name: 'Wunjo', glyph: 'ᚹ', keyword: 'Gioia', meaning: 'La gioia, l\'armonia raggiunta: gusta ciò che si è composto.', stem: 'rune_bone_08_wunjo_v1', upright: 'La gioia che corona. Armonia, appartenenza, il frutto dolce di uno sforzo: un momento di pienezza vera.', shadow: 'La gioia rimandata. Un\'armonia incrinata, un frutto non ancora dolce: cura il legame, la pienezza torna.'),
  Rune(name: 'Hagalaz', glyph: 'ᚺ', keyword: 'Prova', meaning: 'La grandine, la scossa che passa: dopo la tempesta, terreno pulito.', stem: 'rune_bone_09_hagalaz_v1', upright: 'La grandine che purifica. Una forza che scuote per rinnovare: ciò che crolla libera spazio per il nuovo.', shadow: 'La grandine che tarda a passare. Una scossa che ancora scuote: è passaggio, non fine, presto libera il campo.'),
  Rune(name: 'Nauthiz', glyph: 'ᚾ', keyword: 'Bisogno', meaning: 'La necessità, l\'attrito che tempra: la pazienza diventa forza.', stem: 'rune_bone_10_nauthiz_v1', upright: 'Il bisogno che insegna. Il vincolo, la prova, l\'attrito che accende il fuoco: qui la pazienza è potere.', shadow: 'Il bisogno che stringe. Un vincolo che pesa, un\'impazienza: la prova insegna, la pazienza qui è la chiave.'),
  Rune(name: 'Isa', glyph: 'ᛁ', keyword: 'Sosta', meaning: 'Il ghiaccio, la pausa immobile: fermati, ascolta il silenzio.', stem: 'rune_bone_11_isa_v1', upright: 'Il ghiaccio che ferma. Sosta, silenzio, immobilità: tempo di attesa e di chiarezza, prima che l\'acqua torni a scorrere.', shadow: 'Il ghiaccio che dura. Una sosta che si prolunga, un gelo dentro: attendi senza forzare, l\'acqua tornerà a scorrere.'),
  Rune(name: 'Jera', glyph: 'ᛃ', keyword: 'Raccolto', meaning: 'L\'anno, il ciclo compiuto: ciò che hai seminato matura.', stem: 'rune_bone_12_jera_v1', upright: 'Il raccolto del tempo. Il ciclo che si compie: ciò che hai seminato con pazienza ora matura, a suo tempo.', shadow: 'Il raccolto che tarda. Un ciclo lento, un frutto non ancora maturo: il tempo lavora, non anticiparlo.'),
  Rune(name: 'Eihwaz', glyph: 'ᛇ', keyword: 'Resilienza', meaning: 'Il tasso, l\'asse del mondo: radici salde reggono il vento.', stem: 'rune_bone_13_eihwaz_v1', upright: 'L\'asse tra i mondi. Resistenza e trasformazione: il tasso che regge le tempeste, il ponte tra ciò che è e ciò che sarà.', shadow: 'L\'asse sotto sforzo. Una tensione tra ciò che è e ciò che sarà: reggi, il tasso non si spezza.'),
  Rune(name: 'Perthro', glyph: 'ᛈ', keyword: 'Mistero', meaning: 'La sorte nascosta, il grembo: accogli ciò che ancora non sai.', stem: 'rune_bone_14_perthro_v1', upright: 'La coppa del destino. Il mistero, la sorte ancora nascosta: qualcosa si muove sotto, non ancora visibile.', shadow: 'La coppa capovolta. Un mistero che resiste, un caso che non svela: non forzare la sorte, lasciala maturare.'),
  Rune(name: 'Algiz', glyph: 'ᛉ', keyword: 'Protezione', meaning: 'L\'alce, lo scudo alzato: sei difeso, resta connesso al sacro.', stem: 'rune_bone_15_algiz_v1', upright: 'Lo scudo del sacro. Protezione, istinto, il legame con l\'alto: sei più difeso di quanto credi, alza lo sguardo.', shadow: 'Lo scudo abbassato. Una difesa allentata, un istinto ignorato: rialza la guardia e riascolta ciò che senti.'),
  Rune(name: 'Sowilo', glyph: 'ᛊ', keyword: 'Vittoria', meaning: 'Il sole, l\'energia che vince: la volontà ritrova la sua luce.', stem: 'rune_bone_16_sowilo_v1', upright: 'Il sole della vittoria. La luce che guida e la volontà che vince: energia piena, la via si illumina.', shadow: 'Il sole dietro le nubi. Una volontà stanca, una luce velata: l\'energia c\'è, aspetta che la nube passi.'),
  Rune(name: 'Tiwaz', glyph: 'ᛏ', keyword: 'Giustizia', meaning: 'Tyr, il coraggio giusto: agisci con onore, anche a un prezzo.', stem: 'rune_bone_17_tiwaz_v1', upright: 'La lancia della giustizia. Coraggio, onore, sacrificio per il giusto: la vittoria che si merita, non quella che si strappa.', shadow: 'La lancia che devia. Un coraggio incerto, un\'energia che cala: ritrova il tuo giusto e la mira torna ferma.'),
  Rune(name: 'Berkano', glyph: 'ᛒ', keyword: 'Nascita', meaning: 'La betulla, la crescita che cura: qualcosa di nuovo germoglia.', stem: 'rune_bone_18_berkano_v1', upright: 'La betulla che genera. Nascita, crescita, nutrimento: qualcosa di nuovo germoglia e chiede cura.', shadow: 'La crescita rallentata. Un germoglio che stenta, una cura da riprendere: nutri la radice, la betulla riparte.'),
  Rune(name: 'Ehwaz', glyph: 'ᛖ', keyword: 'Fiducia', meaning: 'Il cavallo, il moto condiviso: procedi insieme a chi ti sostiene.', stem: 'rune_bone_19_ehwaz_v1', upright: 'I due cavalli. Movimento insieme, fiducia, alleanza: si va lontano solo in armonia con l\'altro.', shadow: 'I cavalli fuori passo. Un\'alleanza sfasata, una fiducia da riallineare: ritrova il ritmo comune, poi riprendete la corsa.'),
  Rune(name: 'Mannaz', glyph: 'ᛗ', keyword: 'Il sé', meaning: 'L\'uomo, l\'umanità: ritrova te stesso dentro la comunità.', stem: 'rune_bone_20_mannaz_v1', upright: 'L\'uomo tra gli uomini. Il sé e la comunità, l\'intelligenza e il limite umano: conosci te stesso attraverso gli altri.', shadow: 'Lo specchio appannato. Una distanza dagli altri, un giudizio severo su di te: torna al legame, ti riconosci meglio negli altri.'),
  Rune(name: 'Laguz', glyph: 'ᛚ', keyword: 'Intuizione', meaning: 'L\'acqua, il flusso profondo: fidati di ciò che senti sotto.', stem: 'rune_bone_21_laguz_v1', upright: 'L\'acqua che intuisce. Il flusso, l\'emozione, l\'inconscio: fidati della corrente e di ciò che senti sotto la superficie.', shadow: 'L\'acqua torbida. Un\'emozione confusa, un intuito da schiarire: lascia posare la corrente, il fondo tornerà visibile.'),
  Rune(name: 'Ingwaz', glyph: 'ᛜ', keyword: 'Potenziale', meaning: 'Ing, il seme in gestazione: forza che matura in silenzio.', stem: 'rune_bone_22_ingwaz_v1', upright: 'Il seme in attesa. Il potenziale che matura in silenzio: un lavoro interiore si compie prima di mostrarsi.', shadow: 'Il seme in lunga attesa. Un potenziale non ancora uscito: il lavoro interiore continua, si mostrerà a suo tempo.'),
  Rune(name: 'Dagaz', glyph: 'ᛞ', keyword: 'Risveglio', meaning: 'Il giorno, l\'alba che cambia: una svolta chiara si apre.', stem: 'rune_bone_23_dagaz_v1', upright: 'L\'alba che risveglia. La svolta, il chiarore che rompe il buio: un nuovo giorno, un cambio di stato luminoso.', shadow: 'L\'alba trattenuta. Una svolta a un passo, un chiarore che tarda: il giorno arriva, tieni la soglia.'),
  Rune(name: 'Othala', glyph: 'ᛟ', keyword: 'Radici', meaning: 'L\'eredità, la casa: ciò che sei viene da lontano, onoralo.', stem: 'rune_bone_24_othala_v1', upright: 'L\'eredità e la casa. Le radici, ciò che ti appartiene nel profondo: il valore che viene da lontano e ti sostiene.', shadow: 'L\'eredità da sciogliere. Un legame col passato che pesa, una radice da rivedere: tieni ciò che sostiene, lascia ciò che trattiene.'),
];
