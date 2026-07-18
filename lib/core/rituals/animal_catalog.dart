import '../assets/family_image.dart';

/// Un animale guida, nella voce di Caligo: nome, sintesi, riga di significato e
/// l'arte del totem bundlata (famiglia `animali`).
class GuideAnimal {
  const GuideAnimal({
    required this.name,
    required this.summary,
    required this.meaning,
    required this.stem,
  });

  final String name;
  final String summary;
  final String meaning;
  final String stem;

  String get thumbPath => FamilyImage.thumb(AssetFamily.animali, stem);
  String get fullPath => FamilyImage.full(AssetFamily.animali, stem);
}

/// Il catalogo degli animali guida con arte pronta per la Demo, dal corpus
/// `docs/corpus/animali.md`. I cinque senza arte (Leone, Farfalla, Ragno,
/// Delfino, Ape) restano nel corpus e non entrano qui finche' non hanno il file.
class AnimalCatalog {
  const AnimalCatalog._();

  static const List<GuideAnimal> animals = [
    GuideAnimal(name: 'Aquila', summary: 'La visione dall\'alto.', meaning: 'Prospettiva, spirito, coraggio: l\'Aquila ti porta a guardare lontano e a osare l\'altezza.', stem: 'ani_aquila_v1'),
    GuideAnimal(name: 'Cavallo', summary: 'La libertà in corsa.', meaning: 'Forza, movimento, indipendenza: il Cavallo ti insegna a portare la tua energia lontano.', stem: 'ani_cavallo_v1'),
    GuideAnimal(name: 'Cervo', summary: 'La gentilezza vigile.', meaning: 'Grazia, sensibilità, nobiltà: il Cervo ti insegna a muoverti nel mondo con dolcezza e attenzione.', stem: 'ani_cervo_v1'),
    GuideAnimal(name: 'Corvo', summary: 'Il messaggero della soglia.', meaning: 'Magia, mistero, intelligenza: il Corvo porta segni e custodisce i passaggi.', stem: 'ani_corvo_v1'),
    GuideAnimal(name: 'Falco', summary: 'Il messaggero del cielo.', meaning: 'Attenzione, segni, mira: il Falco ti chiama a leggere i messaggi e a concentrare lo sguardo.', stem: 'ani_falco_v1'),
    GuideAnimal(name: 'Gufo', summary: 'Il veggente della notte.', meaning: 'Saggezza, mistero, intuizione: il Gufo vede ciò che è nascosto nel buio.', stem: 'ani_gufo_v1'),
    GuideAnimal(name: 'Lince', summary: 'Il segreto svelato.', meaning: 'Percezione sottile, sguardo su ciò che è nascosto: la Lince vede l\'invisibile e ti invita a fidarti del tuo sesto senso.', stem: 'ani_lince_v1'),
    GuideAnimal(name: 'Lupo', summary: 'L\'istinto e il branco.', meaning: 'Fedeltà, libertà, fiducia nell\'istinto: il Lupo ti insegna a stare nel gruppo senza perdere te stesso.', stem: 'ani_lupo_v1'),
    GuideAnimal(name: 'Orso', summary: 'La forza e il ritiro.', meaning: 'Potere calmo, guarigione, introspezione: l\'Orso ti insegna quando agire e quando ritirarti.', stem: 'ani_orso_v1'),
    GuideAnimal(name: 'Serpente', summary: 'La muta e la rinascita.', meaning: 'Trasformazione, energia vitale, guarigione: il Serpente ti insegna a lasciare la vecchia pelle.', stem: 'ani_serpente_v1'),
    GuideAnimal(name: 'Tartaruga', summary: 'La saggezza lenta.', meaning: 'Pazienza, radici, protezione: la Tartaruga porta la casa con sé e non teme il tempo.', stem: 'ani_tartaruga_v1'),
    GuideAnimal(name: 'Volpe', summary: 'L\'astuzia e l\'agilità.', meaning: 'Intelligenza, adattamento, ingegno: la Volpe ti insegna a risolvere con furbizia, non con la forza.', stem: 'ani_volpe_v1'),
  ];
}
