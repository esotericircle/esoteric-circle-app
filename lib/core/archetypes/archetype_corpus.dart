import 'package:flutter/foundation.dart';

import 'archetype.dart';

/// Il ritratto di un archetipo, in cinque campi.
///
/// L'Ombra non e' un personaggio nuovo: e' lo stesso archetipo distorto, quindi
/// vive qui dentro come campo e non come voce a se'. A video si rende con la
/// stessa statua trattata in ombra, mai con un'immagine diversa.
@immutable
class ArchetypeRitratto {
  const ArchetypeRitratto({
    required this.archetipo,
    required this.essenza,
    required this.luce,
    required this.ombra,
    required this.amore,
    required this.lavoro,
  });

  final Archetype archetipo;

  /// Una riga sola, quella che sta sulla card e sotto il nome.
  final String essenza;

  final String luce;
  final String ombra;
  final String amore;
  final String lavoro;
}

/// Il corpus dei dodici, come dati e non come testo sparso nelle schermate.
///
/// Zero AI a runtime: quel che si legge nel responso e' scritto qui, uguale a
/// se stesso su ogni dispositivo e a ogni esecuzione.
class ArchetypeCorpus {
  const ArchetypeCorpus._();

  static const Map<Archetype, ArchetypeRitratto> _per = {
    Archetype.innocente: ArchetypeRitratto(
      archetipo: Archetype.innocente,
      essenza: 'La fiducia che apre il mondo.',
      luce: 'Vive con ottimismo e purezza, si fida della vita e vede il buono, '
          'porta speranza e la forza di ricominciare.',
      ombra: 'Nega i problemi, resta ingenuo e dipendente.',
      amore: 'Si dona con fiducia.',
      lavoro: 'Porta entusiasmo, deve imparare il realismo.',
    ),
    Archetype.esploratore: ArchetypeRitratto(
      archetipo: Archetype.esploratore,
      essenza: 'L\'orizzonte è casa.',
      luce: 'Cerca libertà, esperienze e autenticità.',
      ombra: 'Fugge sempre, non si lega, sradicato.',
      amore: 'Ha bisogno di spazio e di un compagno di viaggio.',
      lavoro: 'Dà il meglio dove può muoversi e innovare.',
    ),
    Archetype.saggio: ArchetypeRitratto(
      archetipo: Archetype.saggio,
      essenza: 'La verità è la via.',
      luce: 'Cerca conoscenza e comprensione, guida con mente lucida.',
      ombra: 'Freddo e dogmatico, giudica e non agisce.',
      amore: 'Profondo, deve scaldare la testa col cuore.',
      lavoro: 'Il consigliere e lo stratega.',
    ),
    Archetype.eroe: ArchetypeRitratto(
      archetipo: Archetype.eroe,
      essenza: 'Il coraggio prima della paura.',
      luce: 'Affronta le prove con forza, protegge, trasforma la sfida in '
          'riscatto.',
      ombra: 'Vede nemici ovunque, spietato e arrogante.',
      amore: 'Si batte per chi ama, deve imparare la dolcezza.',
      lavoro: 'Eccelle sotto pressione.',
    ),
    Archetype.ribelle: ArchetypeRitratto(
      archetipo: Archetype.ribelle,
      essenza: 'Rompere per liberare.',
      luce: 'Sfida l\'ingiusto, dice le verità scomode.',
      ombra: 'Distrugge per distruggere, si autodanneggia.',
      amore: 'Rifiuta gli schemi, cerca autenticità.',
      lavoro: 'Innova, va incanalato.',
    ),
    Archetype.mago: ArchetypeRitratto(
      archetipo: Archetype.mago,
      essenza: 'Ciò che immagini può accadere.',
      luce: 'Vede possibilità, trasforma sé e le situazioni.',
      ombra: 'Manipola per il potere, inganna.',
      amore: 'Intenso e trasformativo.',
      lavoro: 'Il visionario che apre strade.',
    ),
    Archetype.realista: ArchetypeRitratto(
      archetipo: Archetype.realista,
      essenza: 'Restare umani, insieme.',
      luce: 'Concreto, empatico e solidale, sta tra gli altri da pari.',
      ombra: 'Vittimismo e cinismo, si perde nella massa.',
      amore: 'Cerca appartenenza vera.',
      lavoro: 'Affidabile, tiene unito il gruppo.',
    ),
    Archetype.amante: ArchetypeRitratto(
      archetipo: Archetype.amante,
      essenza: 'Nel legame, la vita.',
      luce: 'Vive di passione, bellezza e connessione.',
      ombra: 'Ossessivo e geloso, si smarrisce nell\'altro.',
      amore: 'È il suo territorio, deve non annullarsi.',
      lavoro: 'Crea armonia e relazioni.',
    ),
    Archetype.giullare: ArchetypeRitratto(
      archetipo: Archetype.giullare,
      essenza: 'Vivere l\'attimo, col sorriso.',
      luce: 'Porta gioia e ironia, dice verità ridendo.',
      ombra: 'Irresponsabile e sfuggente, evita tutto.',
      amore: 'Leggero, deve imparare la profondità.',
      lavoro: 'Allenta le tensioni, serve un\'ancora.',
    ),
    Archetype.custode: ArchetypeRitratto(
      archetipo: Archetype.custode,
      essenza: 'Prendersi cura è la forza.',
      luce: 'Protegge, nutre e sostiene, dona senza chiedere.',
      ombra: 'Il martire che soffoca e ricatta col senso di colpa.',
      amore: 'Dedizione, deve imparare a ricevere.',
      lavoro: 'Il collante della squadra.',
    ),
    Archetype.sovrano: ArchetypeRitratto(
      archetipo: Archetype.sovrano,
      essenza: 'L\'ordine che protegge.',
      luce: 'Guida con responsabilità, crea ordine, si assume il peso.',
      ombra: 'Il tiranno rigido, teme il caos e schiaccia.',
      amore: 'Leale e stabile, deve lasciare spazio.',
      lavoro: 'Il leader che fa crescere.',
    ),
    Archetype.creatore: ArchetypeRitratto(
      archetipo: Archetype.creatore,
      essenza: 'Dare forma a ciò che non c\'è.',
      luce: 'Immagina e realizza, crea bellezza e senso.',
      ombra: 'Perfezionismo ossessivo, non finisce, o crea per fuggire.',
      amore: 'Immaginazione e profondità.',
      lavoro: 'L\'innovatore e l\'artigiano.',
    ),
  };

  /// Il ritratto di un archetipo. C'e' sempre, per tutti e dodici.
  static ArchetypeRitratto di(Archetype a) => _per[a]!;

  /// I dodici ritratti nell'ordine canonico.
  static List<ArchetypeRitratto> get tutti =>
      [for (final a in Archetype.values) _per[a]!];

  /// La riga di trasparenza, aperta dalla piccola icona "Fonti e metodo".
  ///
  /// Non e' un disclaimer che si ripete: quello legale sta una volta sola
  /// all'onboarding. Questa dice da dove viene il metodo e cosa non e'.
  static const String fontiEMetodo =
      'La teoria degli archetipi è di Carl Gustav Jung. I dodici archetipi e la '
      'forma del test vengono dalla tradizione di Carol Pearson e Margaret Mark '
      '(Pearson-Marr Archetype Indicator). Non è una diagnosi: indica gli '
      'archetipi più attivi in te adesso.';
}
