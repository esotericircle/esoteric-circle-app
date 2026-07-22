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
      luce: 'Porti uno sguardo pulito che sa ancora vedere il buono dove altri hanno smesso di cercarlo. La tua fiducia non è ingenuità ma una scelta coraggiosa, perché credere che le cose possano andare bene apre porte che la paura tiene chiuse. Dove arrivi porti leggerezza, speranza e la rara forza di ricominciare senza rancore.',
      ombra: 'Nega i problemi, resta ingenuo e dipendente.',
      amore: 'Si dona con fiducia.',
      lavoro: 'Porta entusiasmo, deve imparare il realismo.',
    ),
    Archetype.esploratore: ArchetypeRitratto(
      archetipo: Archetype.esploratore,
      essenza: 'L\'orizzonte è casa.',
      luce: 'Non ti accontenti di ciò che ti hanno detto, vuoi vederlo con i tuoi occhi. La libertà per te è un bisogno vitale: ogni orizzonte nuovo è una domanda a cui rispondi partendo. Cerchi esperienze vere, non comode. In quel cercare scopri chi sei, un pezzo di strada alla volta.',
      ombra: 'Fugge sempre, non si lega, sradicato.',
      amore: 'Ha bisogno di spazio e di un compagno di viaggio.',
      lavoro: 'Dà il meglio dove può muoversi e innovare.',
    ),
    Archetype.saggio: ArchetypeRitratto(
      archetipo: Archetype.saggio,
      essenza: 'La verità è la via.',
      luce: 'Prima di giudicare, guardi e capisci. Cerchi la verità delle cose, non la versione più comoda. Sai mettere ordine dove gli altri vedono confusione. Le persone vengono da te per un consiglio, perché dirai ciò che è vero e non ciò che fa piacere. La tua forza è vedere lontano.',
      ombra: 'Freddo e dogmatico, giudica e non agisce.',
      amore: 'Profondo, deve scaldare la testa col cuore.',
      lavoro: 'Il consigliere e lo stratega.',
    ),
    Archetype.eroe: ArchetypeRitratto(
      archetipo: Archetype.eroe,
      essenza: 'Il coraggio prima della paura.',
      luce: 'Quando arriva la prova non ti volti dall\'altra parte. La paura la senti come tutti, ma scegli di agire lo stesso. In quel gesto trovi la tua misura. Proteggi chi ti sta accanto, non ti arrendi. Trasformi una difficoltà in un riscatto. La tua forza è il coraggio che passa all\'azione.',
      ombra: 'Vede nemici ovunque, spietato e arrogante.',
      amore: 'Si batte per chi ama, deve imparare la dolcezza.',
      lavoro: 'Eccelle sotto pressione.',
    ),
    Archetype.ribelle: ArchetypeRitratto(
      archetipo: Archetype.ribelle,
      essenza: 'Rompere per liberare.',
      luce: 'Vedi ciò che è ingiusto e non riesci a far finta di niente. Dici le verità scomode che gli altri tacciono. Rompi le regole che hanno smesso di avere senso. Non distruggi per capriccio, ma per aprire spazio a qualcosa di più vero. La tua forza è il coraggio di cambiare ciò che tutti accettano.',
      ombra: 'Distrugge per distruggere, si autodanneggia.',
      amore: 'Rifiuta gli schemi, cerca autenticità.',
      lavoro: 'Innova, va incanalato.',
    ),
    Archetype.mago: ArchetypeRitratto(
      archetipo: Archetype.mago,
      essenza: 'Ciò che immagini può accadere.',
      luce: 'Dove gli altri vedono muri, tu vedi possibilità. Sai che le cose, tu stesso compreso, possono trasformarsi, mentre unisci la visione alla volontà per far accadere ciò che immagini. Leggi in profondità persone e situazioni. Sai cambiare il corso di ciò che sembrava già scritto. La tua forza è dare forma all\'invisibile.',
      ombra: 'Manipola per il potere, inganna.',
      amore: 'Intenso e trasformativo.',
      lavoro: 'Il visionario che apre strade.',
    ),
    Archetype.realista: ArchetypeRitratto(
      archetipo: Archetype.realista,
      essenza: 'Restare umani, insieme.',
      luce: 'Hai conosciuto la vita per quello che è. Ne sei uscito concreto e vero senza smettere di essere umano. Non ti servono maschere né piedistalli, stai tra gli altri da pari con empatia e buon senso. Sei quello su cui si può contare, che tiene i piedi per terra quando tutti perdono la testa. La tua forza è restare autentico e vicino.',
      ombra: 'Vittimismo e cinismo, si perde nella massa.',
      amore: 'Cerca appartenenza vera.',
      lavoro: 'Affidabile, tiene unito il gruppo.',
    ),
    Archetype.amante: ArchetypeRitratto(
      archetipo: Archetype.amante,
      essenza: 'Nel legame, la vita.',
      luce: 'Vivi le cose con intensità: il legame con gli altri è dove ti senti davvero vivo. Sai creare bellezza e intimità, ti doni con passione e fai sentire l\'altro visto e importante. Per te un rapporto non è un contorno della vita, è la vita stessa. La tua forza è la capacità di amare e di unire.',
      ombra: 'Ossessivo e geloso, si smarrisce nell\'altro.',
      amore: 'È il suo territorio, deve non annullarsi.',
      lavoro: 'Crea armonia e relazioni.',
    ),
    Archetype.giullare: ArchetypeRitratto(
      archetipo: Archetype.giullare,
      essenza: 'Vivere l\'attimo, col sorriso.',
      luce: 'Sai che la vita va vissuta adesso, così porti allegria dove c\'è pesantezza. Con l\'ironia dici verità che altri non oserebbero. Con una battuta sciogli le tensioni e riporti tutti al presente. Dietro il gioco c\'è intelligenza, non superficialità. La tua forza è alleggerire il mondo senza smettere di guardarlo.',
      ombra: 'Irresponsabile e sfuggente, evita tutto.',
      amore: 'Leggero, deve imparare la profondità.',
      lavoro: 'Allenta le tensioni, serve un\'ancora.',
    ),
    Archetype.custode: ArchetypeRitratto(
      archetipo: Archetype.custode,
      essenza: 'Prendersi cura è la forza.',
      luce: 'La tua forza è prenderti cura. Proteggi, sostieni e nutri chi ti sta intorno. Sai esserci senza chiedere nulla in cambio. Dove c\'è qualcuno in difficoltà, tu ci sei, con una presenza calda e affidabile. Il tuo dono è far sentire gli altri al sicuro: è una forza vera, non una debolezza.',
      ombra: 'Il martire che soffoca e ricatta col senso di colpa.',
      amore: 'Dedizione, deve imparare a ricevere.',
      lavoro: 'Il collante della squadra.',
    ),
    Archetype.sovrano: ArchetypeRitratto(
      archetipo: Archetype.sovrano,
      essenza: 'L\'ordine che protegge.',
      luce: 'Sai guidare, senza tirarti indietro davanti alla responsabilità. Metti ordine dove c\'è caos, crei stabilità intorno a te e ti prendi sulle spalle il peso delle decisioni. Le persone ti seguono perché sentono che sai dove andare. La tua forza è portare un ordine che protegge e fa crescere.',
      ombra: 'Il tiranno rigido, teme il caos e schiaccia.',
      amore: 'Leale e stabile, deve lasciare spazio.',
      lavoro: 'Il leader che fa crescere.',
    ),
    Archetype.creatore: ArchetypeRitratto(
      archetipo: Archetype.creatore,
      essenza: 'Dare forma a ciò che non c\'è.',
      luce: 'Hai bisogno di dare forma a ciò che non esiste ancora. Le idee in te diventano opere. Trasformi l\'immaginazione in qualcosa di reale che prima non c\'era. Vivi per creare bellezza e senso. Nel fare trovi te stesso. La tua forza è l\'immaginazione che si fa mano, poi mondo.',
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
