import '../assets/family_image.dart';

/// Un animale guida, nella voce di Caligo: nome, sintesi, riga di significato e
/// l'arte del totem bundlata (famiglia `animali`).
class GuideAnimal {
  const GuideAnimal({
    required this.name,
    required this.summary,
    required this.meaning,
    required this.stem,
    this.femminile = false,
  });

  final String name;
  final String summary;
  final String meaning;
  final String stem;

  /// **IL GENERE DEL NOME, e serve a chi scrive l'articolo.** Ordine DE voce
  /// 08, 11 settembre 2026.
  ///
  /// La schermata della rivelazione diceva *"E' il Lince. Adesso lo conosci."*
  /// I testi del corpus lo sapevano gia' (*"la Lince vede l'invisibile"*): a
  /// non saperlo era il codice, ed era il codice a comporre la frase che la
  /// persona legge alla fine di quattro discese.
  ///
  /// **Quattro su dodici sono femmine**: Aquila, Lince, Tartaruga, Volpe.
  final bool femminile;

  /// **L'ARTICOLO DETERMINATIVO DEL NOME**, gia' spaziato, e **elide davanti a
  /// vocale**: `l'Orso`, `l'Aquila`, `il Lupo`, `la Lince`.
  ///
  /// **L'elisione non e' un ornamento.** Senza di lei il maschile davanti a
  /// vocale diventa *"il Orso"*, che e' lo stesso genere di errore di *"il
  /// Lince"* e si legge peggio. Lo sapeva gia' la tabella della chat, e per
  /// questo il genere adesso vive qui e quella tabella e' sparita: due
  /// tabelle sullo stesso fatto sono due verita'.
  String get articolo {
    const vocali = {'A', 'E', 'I', 'O', 'U'};
    if (name.isNotEmpty && vocali.contains(name[0].toUpperCase())) {
      return 'l$_apostrofo';
    }
    return femminile ? 'la ' : 'il ';
  }

  /// L'apostrofo, composto: nelle stringhe di `lib` vale la regola di casa.
  static const String _apostrofo = "'";

  /// **IL PRONOME DIRETTO**, per *"adesso lo conosci"* e *"adesso la
  /// conosci"*.
  String get pronome => femminile ? 'la' : 'lo';

  String get thumbPath => FamilyImage.thumb(AssetFamily.animali, stem);
  String get fullPath => FamilyImage.full(AssetFamily.animali, stem);

  /// **LA SUA OMBRA, ordine DG dell'11 settembre 2026.**
  ///
  /// Non e' un disegno nuovo: e' **la sagoma esatta di `fullPath`**, presa dal
  /// suo canale alpha, riempita di quasi nero con un filo di luce oro sul
  /// bordo. Percio' l'ombra che si segue nel Mondo di Sotto **e' l'animale che
  /// tocca a quella persona, al pixel**.
  ///
  /// Lo stem e' `ani_<nome>_v1` e l'ombra e' `ani_ombra_<nome>_v1`: il nome si
  /// ricava da li' e non si scrive una seconda tabella.
  String get ombraPath =>
      'assets/img/mondo_di_sotto/ani_ombra_${stem.substring(4)}.webp';
}

/// Il catalogo degli animali guida con arte pronta per la Demo, dal corpus
/// `docs/corpus/animali.md`. I cinque senza arte (Leone, Farfalla, Ragno,
/// Delfino, Ape) restano nel corpus e non entrano qui finche' non hanno il file.
class AnimalCatalog {
  const AnimalCatalog._();

  static const List<GuideAnimal> animals = [
    GuideAnimal(
        name: 'Aquila',
        summary: 'La visione dall\'alto.',
        meaning:
            'Prospettiva, spirito, coraggio: l\'Aquila ti porta a guardare lontano e a osare l\'altezza.',
        stem: 'ani_aquila_v1', femminile: true),
    GuideAnimal(
        name: 'Cavallo',
        summary: 'La libertà in corsa.',
        meaning:
            'Forza, movimento, indipendenza: il Cavallo ti insegna a portare la tua energia lontano.',
        stem: 'ani_cavallo_v1'),
    GuideAnimal(
        name: 'Cervo',
        summary: 'La gentilezza vigile.',
        meaning:
            'Grazia, sensibilità, nobiltà: il Cervo ti insegna a muoverti nel mondo con dolcezza e attenzione.',
        stem: 'ani_cervo_v1'),
    GuideAnimal(
        name: 'Corvo',
        summary: 'Il messaggero della soglia.',
        meaning:
            'Magia, mistero, intelligenza: il Corvo porta segni e custodisce i passaggi.',
        stem: 'ani_corvo_v1'),
    GuideAnimal(
        name: 'Falco',
        summary: 'Il messaggero del cielo.',
        meaning:
            'Attenzione, segni, mira: il Falco ti chiama a leggere i messaggi e a concentrare lo sguardo.',
        stem: 'ani_falco_v1'),
    GuideAnimal(
        name: 'Gufo',
        summary: 'Il veggente della notte.',
        meaning:
            'Saggezza, mistero, intuizione: il Gufo vede ciò che è nascosto nel buio.',
        stem: 'ani_gufo_v1'),
    GuideAnimal(
        name: 'Lince',
        summary: 'Il segreto svelato.',
        meaning:
            'Percezione sottile, sguardo su ciò che è nascosto: la Lince vede l\'invisibile e ti invita a fidarti del tuo sesto senso.',
        stem: 'ani_lince_v1', femminile: true),
    GuideAnimal(
        name: 'Lupo',
        summary: 'L\'istinto e il branco.',
        meaning:
            'Fedeltà, libertà, fiducia nell\'istinto: il Lupo ti insegna a stare nel gruppo senza perdere te stesso.',
        stem: 'ani_lupo_v1'),
    GuideAnimal(
        name: 'Orso',
        summary: 'La forza e il ritiro.',
        meaning:
            'Potere calmo, guarigione, introspezione: l\'Orso ti insegna quando agire e quando ritirarti.',
        stem: 'ani_orso_v1'),
    GuideAnimal(
        name: 'Serpente',
        summary: 'La muta e la rinascita.',
        meaning:
            'Trasformazione, energia vitale, guarigione: il Serpente ti insegna a lasciare la vecchia pelle.',
        stem: 'ani_serpente_v1'),
    GuideAnimal(
        name: 'Tartaruga',
        summary: 'La saggezza lenta.',
        meaning:
            'Pazienza, radici, protezione: la Tartaruga porta la casa con sé e non teme il tempo.',
        stem: 'ani_tartaruga_v1', femminile: true),
    GuideAnimal(
        name: 'Volpe',
        summary: 'L\'astuzia e l\'agilità.',
        meaning:
            'Intelligenza, adattamento, ingegno: la Volpe ti insegna a risolvere con furbizia, non con la forza.',
        stem: 'ani_volpe_v1', femminile: true),
  ];
}
