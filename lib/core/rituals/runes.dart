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
  Rune(name: 'Fehu', glyph: 'ᚠ', keyword: 'Abbondanza', meaning: 'Il bestiame, la ricchezza che scorre: raccogli senza trattenere.', stem: 'rune_bone_01_fehu_v1'),
  Rune(name: 'Uruz', glyph: 'ᚢ', keyword: 'Forza', meaning: 'L\'uro selvaggio, vigore grezzo: la forza che apre il varco.', stem: 'rune_bone_02_uruz_v1'),
  Rune(name: 'Thurisaz', glyph: 'ᚦ', keyword: 'Difesa', meaning: 'La spina, forza che reagisce: proteggi il confine con misura.', stem: 'rune_bone_03_thurisaz_v1'),
  Rune(name: 'Ansuz', glyph: 'ᚨ', keyword: 'Parola', meaning: 'Il soffio del dio, ispirazione: ascolta il messaggio che arriva.', stem: 'rune_bone_04_ansuz_v1'),
  Rune(name: 'Raidho', glyph: 'ᚱ', keyword: 'Cammino', meaning: 'Il viaggio, il ritmo giusto: muoviti con il tempo, non contro.', stem: 'rune_bone_05_raidho_v1'),
  Rune(name: 'Kenaz', glyph: 'ᚲ', keyword: 'Luce', meaning: 'La torcia, conoscenza che rivela: una scintilla illumina l\'opera.', stem: 'rune_bone_06_kenaz_v1'),
  Rune(name: 'Gebo', glyph: 'ᚷ', keyword: 'Dono', meaning: 'Il dono, lo scambio alla pari: dare apre a ricevere.', stem: 'rune_bone_07_gebo_v1'),
  Rune(name: 'Wunjo', glyph: 'ᚹ', keyword: 'Gioia', meaning: 'La gioia, l\'armonia raggiunta: gusta ciò che si è composto.', stem: 'rune_bone_08_wunjo_v1'),
  Rune(name: 'Hagalaz', glyph: 'ᚺ', keyword: 'Prova', meaning: 'La grandine, la scossa che passa: dopo la tempesta, terreno pulito.', stem: 'rune_bone_09_hagalaz_v1'),
  Rune(name: 'Nauthiz', glyph: 'ᚾ', keyword: 'Bisogno', meaning: 'La necessità, l\'attrito che tempra: la pazienza diventa forza.', stem: 'rune_bone_10_nauthiz_v1'),
  Rune(name: 'Isa', glyph: 'ᛁ', keyword: 'Sosta', meaning: 'Il ghiaccio, la pausa immobile: fermati, ascolta il silenzio.', stem: 'rune_bone_11_isa_v1'),
  Rune(name: 'Jera', glyph: 'ᛃ', keyword: 'Raccolto', meaning: 'L\'anno, il ciclo compiuto: ciò che hai seminato matura.', stem: 'rune_bone_12_jera_v1'),
  Rune(name: 'Eihwaz', glyph: 'ᛇ', keyword: 'Resilienza', meaning: 'Il tasso, l\'asse del mondo: radici salde reggono il vento.', stem: 'rune_bone_13_eihwaz_v1'),
  Rune(name: 'Perthro', glyph: 'ᛈ', keyword: 'Mistero', meaning: 'La sorte nascosta, il grembo: accogli ciò che ancora non sai.', stem: 'rune_bone_14_perthro_v1'),
  Rune(name: 'Algiz', glyph: 'ᛉ', keyword: 'Protezione', meaning: 'L\'alce, lo scudo alzato: sei difeso, resta connesso al sacro.', stem: 'rune_bone_15_algiz_v1'),
  Rune(name: 'Sowilo', glyph: 'ᛊ', keyword: 'Vittoria', meaning: 'Il sole, l\'energia che vince: la volontà ritrova la sua luce.', stem: 'rune_bone_16_sowilo_v1'),
  Rune(name: 'Tiwaz', glyph: 'ᛏ', keyword: 'Giustizia', meaning: 'Tyr, il coraggio giusto: agisci con onore, anche a un prezzo.', stem: 'rune_bone_17_tiwaz_v1'),
  Rune(name: 'Berkano', glyph: 'ᛒ', keyword: 'Nascita', meaning: 'La betulla, la crescita che cura: qualcosa di nuovo germoglia.', stem: 'rune_bone_18_berkano_v1'),
  Rune(name: 'Ehwaz', glyph: 'ᛖ', keyword: 'Fiducia', meaning: 'Il cavallo, il moto condiviso: procedi insieme a chi ti sostiene.', stem: 'rune_bone_19_ehwaz_v1'),
  Rune(name: 'Mannaz', glyph: 'ᛗ', keyword: 'Il sé', meaning: 'L\'uomo, l\'umanità: ritrova te stesso dentro la comunità.', stem: 'rune_bone_20_mannaz_v1'),
  Rune(name: 'Laguz', glyph: 'ᛚ', keyword: 'Intuizione', meaning: 'L\'acqua, il flusso profondo: fidati di ciò che senti sotto.', stem: 'rune_bone_21_laguz_v1'),
  Rune(name: 'Ingwaz', glyph: 'ᛜ', keyword: 'Potenziale', meaning: 'Ing, il seme in gestazione: forza che matura in silenzio.', stem: 'rune_bone_22_ingwaz_v1'),
  Rune(name: 'Dagaz', glyph: 'ᛞ', keyword: 'Risveglio', meaning: 'Il giorno, l\'alba che cambia: una svolta chiara si apre.', stem: 'rune_bone_23_dagaz_v1'),
  Rune(name: 'Othala', glyph: 'ᛟ', keyword: 'Radici', meaning: 'L\'eredità, la casa: ciò che sei viene da lontano, onoralo.', stem: 'rune_bone_24_othala_v1'),
];
