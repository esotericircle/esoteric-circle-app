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
///
/// **LE PAROLE VIETATE NON ENTRANO NEMMENO QUI**, ordine del 7 agosto 2026:
/// guarigione, salute, malattia, fertilita', longevita', vittoria,
/// protezione dalle armi, ricchezza, ritrovamento di tesori. Il catalogo e'
/// parte del corpus che arriva a video: la prova del corpus lo scandisce
/// insieme a docs/corpus/rune.md, e il generatore del corpus si rifiuta di
/// generare se le trova. Sostanza identica, promesse mai.
const List<Rune> kElderFuthark = [
  Rune(name: 'Fehu', glyph: 'ᚠ', keyword: 'Abbondanza', meaning: 'Il bestiame, l\'abbondanza che scorre: raccogli senza trattenere.', stem: 'rune_bone_01_fehu_v1', upright: 'Fai muovere ciò che hai: fermo si consuma.', shadow: 'Apri la mano: ciò che trattieni troppo si perde.'),
  Rune(name: 'Uruz', glyph: 'ᚢ', keyword: 'Forza', meaning: 'L\'uro selvaggio, vigore grezzo: la forza che apre il varco.', stem: 'rune_bone_02_uruz_v1', upright: 'Hai la forza per rialzarti: usala adesso.', shadow: 'Ritrova il ritmo prima di caricare di nuovo.'),
  Rune(name: 'Thurisaz', glyph: 'ᚦ', keyword: 'Difesa', meaning: 'La spina, forza che reagisce: proteggi il confine con misura.', stem: 'rune_bone_03_thurisaz_v1', upright: 'Dirigi la forza con misura, senza temerla.', shadow: 'Fermati un istante: qui la fretta ferisce.'),
  Rune(name: 'Ansuz', glyph: 'ᚨ', keyword: 'Parola', meaning: 'Il soffio del dio, ispirazione: ascolta il messaggio che arriva.', stem: 'rune_bone_04_ansuz_v1', upright: 'Ascolta il segno: una voce ti raggiunge.', shadow: 'Ascolta meglio prima di dar peso a ciò che senti.'),
  Rune(name: 'Raidho', glyph: 'ᚱ', keyword: 'Cammino', meaning: 'Il viaggio, il ritmo giusto: muoviti con il tempo, non contro.', stem: 'rune_bone_05_raidho_v1', upright: 'Muoviti con la tua cadenza, dentro e fuori.', shadow: 'Rallenta: ritrovata la cadenza, la strada si spiana.'),
  Rune(name: 'Kenaz', glyph: 'ᚲ', keyword: 'Luce', meaning: 'La torcia, conoscenza che rivela: una scintilla illumina l\'opera.', stem: 'rune_bone_06_kenaz_v1', upright: 'Una luce si accende dove prima era buio.', shadow: 'La fiamma c’è: dalle tempo di prendere.'),
  Rune(name: 'Gebo', glyph: 'ᚷ', keyword: 'Dono', meaning: 'Il dono, lo scambio alla pari: dare apre a ricevere.', stem: 'rune_bone_07_gebo_v1', upright: 'Tieni in equilibrio ciò che dai con ciò che ricevi.', shadow: 'Riporta equilibrio: lo scambio pende da un lato.'),
  Rune(name: 'Wunjo', glyph: 'ᚹ', keyword: 'Gioia', meaning: 'La gioia, l\'armonia raggiunta: gusta ciò che si è composto.', stem: 'rune_bone_08_wunjo_v1', upright: 'Un momento di pienezza vera: prendilo.', shadow: 'Cura il legame: la pienezza torna.'),
  Rune(name: 'Hagalaz', glyph: 'ᚺ', keyword: 'Prova', meaning: 'La grandine, la scossa che passa: dopo la tempesta, terreno pulito.', stem: 'rune_bone_09_hagalaz_v1', upright: 'Ciò che crolla libera spazio per il nuovo.', shadow: 'È un passaggio, non una fine: lascialo passare.'),
  Rune(name: 'Nauthiz', glyph: 'ᚾ', keyword: 'Bisogno', meaning: 'La necessità, l\'attrito che tempra: la pazienza diventa forza.', stem: 'rune_bone_10_nauthiz_v1', upright: 'Qui la pazienza è potere: aspetta con metodo.', shadow: 'La prova insegna: la pazienza è la chiave.'),
  Rune(name: 'Isa', glyph: 'ᛁ', keyword: 'Sosta', meaning: 'Il ghiaccio, la pausa immobile: fermati, ascolta il silenzio.', stem: 'rune_bone_11_isa_v1', upright: 'Tempo di attesa e di chiarezza: non forzare.', shadow: 'Attendi senza forzare: l’acqua torna a scorrere.'),
  Rune(name: 'Jera', glyph: 'ᛃ', keyword: 'Raccolto', meaning: 'L\'anno, il ciclo compiuto: ciò che hai seminato matura.', stem: 'rune_bone_12_jera_v1', upright: 'Ciò che hai seminato matura a suo tempo.', shadow: 'Il tempo lavora: non anticiparlo.'),
  Rune(name: 'Eihwaz', glyph: 'ᛇ', keyword: 'Resilienza', meaning: 'Il tasso, l\'asse del mondo: radici salde reggono il vento.', stem: 'rune_bone_13_eihwaz_v1', upright: 'Reggi: ciò che sembra piegarti non ti spezza.', shadow: 'Reggi la tensione: il tasso non si spezza.'),
  Rune(name: 'Perthro', glyph: 'ᛈ', keyword: 'Mistero', meaning: 'La sorte nascosta, il grembo: accogli ciò che ancora non sai.', stem: 'rune_bone_14_perthro_v1', upright: 'Qualcosa si muove sotto, non ancora visibile.', shadow: 'Non forzare la sorte: lasciala maturare.'),
  Rune(name: 'Algiz', glyph: 'ᛉ', keyword: 'Protezione', meaning: 'L\'alce, lo scudo alzato: sei difeso, resta connesso al sacro.', stem: 'rune_bone_15_algiz_v1', upright: 'Sei più difeso di quanto credi: alza lo sguardo.', shadow: 'Rialza la guardia e riascolta ciò che senti.'),
  Rune(name: 'Sowilo', glyph: 'ᛊ', keyword: 'Luce', meaning: 'Il sole, l\'energia che guida: la volontà ritrova la sua luce.', stem: 'rune_bone_16_sowilo_v1', upright: 'Energia piena: tieni la rotta che hai scelto.', shadow: 'L’energia c’è: aspetta che la nube passi.'),
  Rune(name: 'Tiwaz', glyph: 'ᛏ', keyword: 'Giustizia', meaning: 'Tyr, il coraggio giusto: agisci con onore, anche a un prezzo.', stem: 'rune_bone_17_tiwaz_v1', upright: 'Prendi ciò che ti spetta, non ciò che si strappa.', shadow: 'Ritrova il tuo giusto: la mira torna ferma.'),
  Rune(name: 'Berkano', glyph: 'ᛒ', keyword: 'Nascita', meaning: 'La betulla, la crescita che cura: qualcosa di nuovo germoglia.', stem: 'rune_bone_18_berkano_v1', upright: 'Qualcosa di nuovo germoglia: dagli cura.', shadow: 'Nutri la radice: il germoglio riparte.'),
  Rune(name: 'Ehwaz', glyph: 'ᛖ', keyword: 'Fiducia', meaning: 'Il cavallo, il moto condiviso: procedi insieme a chi ti sostiene.', stem: 'rune_bone_19_ehwaz_v1', upright: 'Si va lontano solo in armonia con l’altro.', shadow: 'Ritrova il ritmo comune, poi riprendete la corsa.'),
  Rune(name: 'Mannaz', glyph: 'ᛗ', keyword: 'Il sé', meaning: 'L\'uomo, l\'umanità: ritrova te stesso dentro la comunità.', stem: 'rune_bone_20_mannaz_v1', upright: 'Conosci te stesso attraverso gli altri.', shadow: 'Torna al legame: negli altri ti riconosci meglio.'),
  Rune(name: 'Laguz', glyph: 'ᛚ', keyword: 'Intuizione', meaning: 'L\'acqua, il flusso profondo: fidati di ciò che senti sotto.', stem: 'rune_bone_21_laguz_v1', upright: 'Fidati di ciò che senti sotto la superficie.', shadow: 'Lascia posare la corrente: il fondo si vede.'),
  Rune(name: 'Ingwaz', glyph: 'ᛜ', keyword: 'Potenziale', meaning: 'Ing, il seme in gestazione: forza che matura in silenzio.', stem: 'rune_bone_22_ingwaz_v1', upright: 'Un lavoro interiore si compie prima di mostrarsi.', shadow: 'Il lavoro continua: si mostra a suo tempo.'),
  Rune(name: 'Dagaz', glyph: 'ᛞ', keyword: 'Risveglio', meaning: 'Il giorno, l\'alba che cambia: una svolta chiara si apre.', stem: 'rune_bone_23_dagaz_v1', upright: 'Un nuovo giorno: cambia stato con lui.', shadow: 'Il giorno arriva: tieni la soglia.'),
  Rune(name: 'Othala', glyph: 'ᛟ', keyword: 'Radici', meaning: 'L\'eredità, la casa: ciò che sei viene da lontano, onoralo.', stem: 'rune_bone_24_othala_v1', upright: 'Ciò che viene da lontano ti sostiene: appoggiati.', shadow: 'Tieni ciò che sostiene, lascia ciò che trattiene.'),
];
