import '../assets/family_image.dart';

/// Un cristallo, nella voce di Aura: nome, chakra principale, elemento, sintesi,
/// riga di significato e l'arte della pietra bundlata (famiglia `cristalli`).
class Crystal {
  const Crystal({
    required this.name,
    required this.chakra,
    required this.element,
    required this.summary,
    required this.meaning,
    required this.stem,
  });

  final String name;
  final String chakra;
  final String element;
  final String summary;
  final String meaning;
  final String stem;

  String get thumbPath => FamilyImage.thumb(AssetFamily.cristalli, stem);
  String get fullPath => FamilyImage.full(AssetFamily.cristalli, stem);
}

/// Il catalogo dei dodici cristalli con arte, dal corpus
/// `docs/corpus/cristalli.md`.
class CrystalCatalog {
  const CrystalCatalog._();

  static const List<Crystal> crystals = [
    Crystal(
        name: 'Ametista',
        chakra: 'terzo occhio e corona',
        element: 'aria',
        summary: 'La calma viola.',
        meaning:
            'Intuizione e pace: acquieta la mente, apre la visione interiore e favorisce un sonno sereno.',
        stem: 'cri_01_ametista_v1'),
    Crystal(
        name: 'Quarzo rosa',
        chakra: 'del cuore',
        element: 'acqua',
        summary: 'La dolcezza del cuore.',
        meaning:
            'Amore e tenerezza: scioglie le durezze e riporta gentilezza verso te e verso gli altri.',
        stem: 'cri_02_quarzo-rosa_v1'),
    Crystal(
        name: 'Citrino',
        chakra: 'del plesso solare',
        element: 'fuoco',
        summary: 'Il sole interiore.',
        meaning:
            'Fiducia e abbondanza: accende energia, ottimismo e la volontà di agire.',
        stem: 'cri_03_citrino_v1'),
    Crystal(
        name: 'Quarzo trasparente',
        chakra: 'tutti i chakra',
        element: 'luce',
        summary: 'Il cristallo maestro.',
        meaning:
            'Chiarezza e amplificazione: pulisce, mette a fuoco e potenzia ogni intenzione.',
        stem: 'cri_04_quarzo-trasparente_v1'),
    Crystal(
        name: 'Ossidiana',
        chakra: 'della radice',
        element: 'terra',
        summary: 'Lo specchio scuro.',
        meaning:
            'Protezione e verità: radica, scioglie le tensioni e mostra ciò che va guardato.',
        stem: 'cri_05_ossidiana_v1'),
    Crystal(
        name: 'Malachite',
        chakra: 'del cuore',
        element: 'terra',
        summary: 'La trasformazione verde.',
        meaning:
            'Cambiamento e cura: assorbe il pesante e accompagna la crescita.',
        stem: 'cri_06_malachite_v1'),
    Crystal(
        name: 'Corniola',
        chakra: 'sacrale',
        element: 'fuoco',
        summary: 'Il fuoco creativo.',
        meaning:
            'Vitalità e coraggio: accende passione, motivazione e creatività.',
        stem: 'cri_07_corniola_v1'),
    Crystal(
        name: 'Lapislazzuli',
        chakra: 'della gola e terzo occhio',
        element: 'aria',
        summary: 'La verità che parla.',
        meaning:
            'Comunicazione e saggezza: aiuta a dire il vero con chiarezza e misura.',
        stem: 'cri_08_lapislazzuli_v1'),
    Crystal(
        name: 'Occhio di tigre',
        chakra: 'del plesso solare',
        element: 'terra',
        summary: 'Lo sguardo fermo.',
        meaning:
            'Forza e protezione: dona coraggio, equilibrio e concentrazione.',
        stem: 'cri_09_occhio-di-tigre_v1'),
    Crystal(
        name: 'Acquamarina',
        chakra: 'della gola',
        element: 'acqua',
        summary: 'L\'onda serena.',
        meaning:
            'Calma e fluidità: rasserena le emozioni e favorisce un\'espressione limpida.',
        stem: 'cri_10_acquamarina_v1'),
    Crystal(
        name: 'Turchese',
        chakra: 'della gola',
        element: 'aria',
        summary: 'Il cielo protettore.',
        meaning:
            'Equilibrio e protezione: unisce cielo e terra, guarisce l\'animo e rasserena.',
        stem: 'cri_11_turchese_v1'),
    Crystal(
        name: 'Selenite',
        chakra: 'della corona',
        element: 'luce',
        summary: 'La luce che purifica.',
        meaning:
            'Pulizia e pace: rischiara l\'aura e porta una serenità luminosa.',
        stem: 'cri_12_selenite_v1'),
  ];
}
