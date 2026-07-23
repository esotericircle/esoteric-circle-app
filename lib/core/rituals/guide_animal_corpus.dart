import '../archetypes/archetype.dart';
import '../archetypes/archetype_corpus.dart';
import '../archetypes/archetype_transits.dart' show Pianeta;
import 'animal_catalog.dart';

/// La lettura piena di un animale guida, nella voce grave di Caligo.
class AnimalRitratto {
  const AnimalRitratto({
    required this.natura,
    required this.dono,
    required this.lezione,
    required this.quando,
    required this.invito,
    required this.messaggi,
  });

  /// La natura dell'animale, chi e' nel simbolo.
  final String natura;

  /// Il dono che porta.
  final String dono;

  /// La lezione che insegna.
  final String lezione;

  /// Quando si presenta come guida.
  final String quando;

  /// Un invito concreto, per oggi.
  final String invito;

  /// Le righe del Messaggio dall'Animale, che ruotano coi giorni.
  final List<String> messaggi;
}

/// Il corpus degli animali guida, fedele alla simbologia sciamanica di Ted
/// Andrews, Steven Farmer, Jamie Sams e David Carson. Contenuto curato,
/// deterministico, su dispositivo: nessuna AI a runtime, nessun tratto inventato
/// fuori tradizione. Le fonti sono dichiarate in `fontiEMetodo` e documentate in
/// `docs/corpus/Corpus_Animale_Guida.md`.
class GuideAnimalCorpus {
  const GuideAnimalCorpus._();

  static const Map<String, AnimalRitratto> _ritratti = {
    "Falco": AnimalRitratto(
      natura:
          "Il Falco e' il messaggero del cielo, occhio che vede da lontano e colpisce nel segno. Vola alto e tiene la preda a fuoco senza sprecare un solo battito d'ala.",
      dono:
          "Il suo dono e' l'attenzione: cogliere i segni che agli altri sfuggono e concentrare tutta la forza su un punto solo.",
      lezione:
          "La sua lezione e' la mira: non basta vedere lontano, bisogna scegliere dove scendere.",
      quando:
          "Si presenta come guida quando la vita ti chiede di alzarti sopra il rumore e leggere il messaggio nascosto in un momento di svolta.",
      invito:
          "Oggi scegli un solo bersaglio e portalo a termine, senza disperderti.",
      messaggi: [
        "guarda piu' in alto, il quadro intero ti aspetta.",
        "un segno ti sta arrivando, tieni gli occhi aperti.",
        "scegli un bersaglio e non mollarlo.",
      ],
    ),
    "Orso": AnimalRitratto(
      natura:
          "L'Orso e' la forza calma che non ha bisogno di gridare. Conosce il tempo del ritiro nella tana e quello del risveglio, si muove secondo la sua stagione interiore.",
      dono:
          "Il suo dono e' il potere tranquillo: una forza che guarisce, radicata nella terra e nella pazienza.",
      lezione:
          "La sua lezione e' l'introspezione: c'e' un tempo per agire e un tempo per rientrare in se stessi e ascoltare.",
      quando:
          "Si presenta come guida quando hai speso troppo e ti serve il coraggio di fermarti, di curarti, di tornare alla tua forza.",
      invito:
          "Oggi concediti un ritiro, anche breve, per ascoltare cosa chiede il tuo corpo.",
      messaggi: [
        "rallenta, la forza vera nasce nella calma.",
        "un ritiro ti rimette al centro, concediti la tana.",
        "guarisci prima di ripartire, non c'e' fretta.",
      ],
    ),
    "Volpe": AnimalRitratto(
      natura:
          "La Volpe e' l'astuzia che si muove nell'ombra, veloce e silenziosa. Sa mimetizzarsi, cambiare strada e leggere il terreno prima di ogni passo.",
      dono:
          "Il suo dono e' l'ingegno: risolvere con l'intelligenza e l'agilita', non con la forza.",
      lezione:
          "La sua lezione e' l'adattamento: quando la via diretta e' chiusa, la Volpe ne trova un'altra.",
      quando:
          "Si presenta come guida quando ti serve furbizia e leggerezza per uscire da una situazione bloccata.",
      invito:
          "Oggi aggira l'ostacolo invece di sfondarlo, cerca la via laterale.",
      messaggi: [
        "cambia strada, la via laterale e' libera.",
        "usa l'ingegno, non la forza.",
        "osserva prima di muoverti, poi scatta.",
      ],
    ),
    "Lupo": AnimalRitratto(
      natura:
          "Il Lupo e' l'istinto che non tradisce e la fedelta' al branco. Sa correre libero e tornare ai suoi, insegna a stare nel gruppo senza sciogliersi in esso.",
      dono:
          "Il suo dono e' la fiducia nell'istinto: sente il pericolo e la via giusta prima che la mente li nomini.",
      lezione:
          "La sua lezione e' l'appartenenza: la vera liberta' non spezza i legami, li sceglie.",
      quando:
          "Si presenta come guida quando devi difendere i tuoi o ritrovare la tua tribu' senza perdere te stesso.",
      invito:
          "Oggi fidati di un'intuizione forte e proteggi cio' che ami.",
      messaggi: [
        "fidati dell'istinto, sa gia' la strada.",
        "torna ai tuoi, il branco ti aspetta.",
        "difendi cio' che conta, con lealta'.",
      ],
    ),
    "Aquila": AnimalRitratto(
      natura:
          "L'Aquila e' lo spirito che tocca il sole e guarda la terra dall'alto. Non teme l'altezza, anzi la cerca, perche' da lassu' ogni cosa trova il suo posto.",
      dono:
          "Il suo dono e' la prospettiva: salire tanto in alto da vedere il disegno intero della tua vita.",
      lezione:
          "La sua lezione e' il coraggio dello spirito: osare la vetta anche quando il vuoto sotto spaventa.",
      quando:
          "Si presenta come guida quando sei chiamato a una visione piu' grande e a governare te stesso con nobilta'.",
      invito:
          "Oggi guarda la tua vita dall'alto come l'Aquila, poi scegli con ampiezza.",
      messaggi: [
        "sali piu' in alto, la vista cambia tutto.",
        "osa la vetta, lo spirito ti regge.",
        "guarda il disegno intero, non il dettaglio.",
      ],
    ),
    "Gufo": AnimalRitratto(
      natura:
          "Il Gufo e' il veggente della notte, che vede dove gli altri sono ciechi. Vola in silenzio e coglie la verita' nascosta sotto le apparenze.",
      dono:
          "Il suo dono e' la saggezza silenziosa: distinguere il vero dal falso e ascoltare cio' che non viene detto.",
      lezione:
          "La sua lezione e' il discernimento: non farsi ingannare dal buio, ma imparare a vederci dentro.",
      quando:
          "Si presenta come guida quando una verita' scomoda chiede di essere guardata, senza fughe.",
      invito:
          "Oggi ascolta il silenzio e osserva cio' che di solito ti sfugge.",
      messaggi: [
        "guarda oltre l'apparenza, la verita' e' sotto.",
        "il silenzio ti parla, ascoltalo.",
        "fidati di cio' che intuisci nel buio.",
      ],
    ),
    "Cervo": AnimalRitratto(
      natura:
          "Il Cervo e' la gentilezza vigile, la grazia che non alza la voce. Si muove con dolcezza e attenzione, tiene la sua forza nella mitezza.",
      dono:
          "Il suo dono e' la sensibilita': toccare il cuore degli altri con delicatezza, senza ferire.",
      lezione:
          "La sua lezione e' che la dolcezza non e' debolezza: si puo' essere gentili e fermi insieme.",
      quando:
          "Si presenta come guida quando la durezza non serve e la via si apre con la grazia.",
      invito:
          "Oggi tratta te stesso e gli altri con una gentilezza nuova.",
      messaggi: [
        "la dolcezza apre porte che la forza chiude.",
        "muoviti con grazia, senza fretta.",
        "ascolta il cuore, tuo e degli altri.",
      ],
    ),
    "Serpente": AnimalRitratto(
      natura:
          "Il Serpente e' la trasformazione che passa per la muta. Lascia la vecchia pelle senza rimpianto e rinasce, portando in se' l'energia vitale che guarisce.",
      dono:
          "Il suo dono e' la rinascita: morire a cio' che eri per diventare cio' che sei.",
      lezione:
          "La sua lezione e' il lasciare andare: nulla di nuovo cresce finche' tieni stretta la pelle vecchia.",
      quando:
          "Si presenta come guida quando una fase e' finita e chiede di essere lasciata per rinascere.",
      invito:
          "Oggi lascia andare una cosa che hai gia' superato, fai spazio al nuovo.",
      messaggi: [
        "lascia la vecchia pelle, adesso e' tempo.",
        "una fase muore perche' un'altra nasca.",
        "l'energia torna quando lasci andare.",
      ],
    ),
    "Cavallo": AnimalRitratto(
      natura:
          "Il Cavallo e' la liberta' in corsa, la potenza che porta lontano. Ha bisogno di spazio e di orizzonte, mal sopporta le briglie che spengono lo slancio.",
      dono:
          "Il suo dono e' il movimento: trasformare l'energia in cammino e portarti dove vuoi arrivare.",
      lezione:
          "La sua lezione e' che la liberta' vera ha una direzione: la corsa senza meta stanca, la corsa scelta libera.",
      quando:
          "Si presenta come guida quando ti serve slancio per partire e coraggio per allargare i confini.",
      invito:
          "Oggi fai un passo verso un tuo orizzonte, muoviti davvero.",
      messaggi: [
        "parti, l'orizzonte ti chiama.",
        "porta la tua energia lontano.",
        "scegli la direzione, poi corri.",
      ],
    ),
    "Tartaruga": AnimalRitratto(
      natura:
          "La Tartaruga porta la casa con se' e non teme il tempo. Va piano ma non si ferma, arriva dove i veloci si perdono.",
      dono:
          "Il suo dono e' la pazienza radicata: la forza lenta della terra, che dura.",
      lezione:
          "La sua lezione e' la costanza: il passo piccolo, ripetuto, batte lo scatto che si spegne.",
      quando:
          "Si presenta come guida quando la fretta ti danneggia e ti serve tornare al passo giusto.",
      invito:
          "Oggi scegli un passo piccolo e sostenibile da ripetere domani.",
      messaggi: [
        "va' piano, arriverai lo stesso.",
        "la costanza batte la fretta.",
        "porta con te la tua casa, sei protetto.",
      ],
    ),
    "Corvo": AnimalRitratto(
      natura:
          "Il Corvo e' il messaggero della soglia, che vola fra il visibile e cio' che non si vede. Custodisce i passaggi e porta segni dal mistero.",
      dono:
          "Il suo dono e' la magia: cogliere che il mondo e' piu' vasto di quanto sembra e muoversi ai suoi bordi.",
      lezione:
          "La sua lezione e' il coraggio del vuoto: dal nulla apparente nasce il nuovo.",
      quando:
          "Si presenta come guida quando sei a una soglia e un cambiamento profondo chiede di essere attraversato.",
      invito:
          "Oggi accogli un segno o una coincidenza, non liquidarlo come caso.",
      messaggi: [
        "un segno ti cerca, non ignorarlo.",
        "sei a una soglia, attraversala.",
        "dal vuoto nasce il nuovo, fidati.",
      ],
    ),
    "Lince": AnimalRitratto(
      natura:
          "La Lince e' il segreto svelato, l'occhio che vede l'invisibile. Silenziosa e appartata, custodisce cio' che gli altri non colgono.",
      dono:
          "Il suo dono e' la percezione sottile: sentire la verita' di una persona o di un luogo prima delle parole.",
      lezione:
          "La sua lezione e' fidarsi del sesto senso: cio' che percepisci ha valore, anche se non lo sai spiegare.",
      quando:
          "Si presenta come guida quando un segreto, tuo o altrui, chiede di essere visto e onorato.",
      invito:
          "Oggi fidati di una percezione sottile, anche senza prove.",
      messaggi: [
        "fidati del sesto senso, vede giusto.",
        "un segreto ti si sta svelando.",
        "cio' che senti conta, ascoltalo.",
      ],
    ),
  };

  /// Il ritratto pieno di un animale. C'e' sempre, per tutti e dodici.
  static AnimalRitratto di(String animalName) => _ritratti[animalName]!;

  /// La sezione che intreccia la medicina dell'animale con l'archetipo
  /// dominante del Test Archetipo. Deterministica, generica su ogni coppia:
  /// l'archetipo indica la strada, il totem porta la forza. L'animale NON cambia
  /// col Test, per fedelta' e per evitare accoppiamenti forzati.
  static String intreccioArchetipo(GuideAnimal animal, Archetype dominante) {
    final essenza = ArchetypeCorpus.di(dominante).essenza;
    final chiusa = essenza.isEmpty
        ? essenza
        : essenza[0].toLowerCase() + essenza.substring(1);
    return "Nel Test Archetipo e' emerso ${dominante.conArticolo}, $chiusa "
        "Il tuo totem ne raccoglie la medicina: dove l'archetipo ti indica la "
        "strada, l'animale ti da' la forza di percorrerla. ${animal.summary}";
  }

  /// Il Messaggio dall'Animale del giorno: deterministico dal giorno e dai
  /// pianeti (Sole sempre, Luna quando e' abbastanza piena), come i Doni del
  /// Giorno. Non una promessa, un'intenzione o un segno nella voce dell'animale.
  static String messaggioDelGiorno(
      GuideAnimal animal, DateTime giorno, Set<Pianeta> pianeti) {
    final r = di(animal.name);
    final ordinale = DateTime.utc(giorno.year, giorno.month, giorno.day)
            .millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;
    final scelto = r.messaggi[ordinale % r.messaggi.length];
    final cielo = pianeti.contains(Pianeta.luna)
        ? "Con la Luna che veglia stanotte"
        : "Con il Sole a scaldare il giorno";
    return "$cielo, il tuo totem ti porta un segno: $scelto";
  }

  /// Il testo del pannello "Fonti e metodo", che cita le opere e distingue
  /// tradizione e curatela.
  static const String fontiEMetodo =
      "L'Animale Guida poggia sullo sciamanesimo e sul core shamanism di Michael "
      "Harner, insieme alla letteratura degli animali di potere: Ted Andrews "
      "(Animal Speak), Steven Farmer (Animal Spirit Guides), Jamie Sams e David "
      "Carson (Medicine Cards). Un'onesta' e' dovuta: nella tradizione l'animale "
      "di potere si trova col viaggio sciamanico, non si calcola dall'astrologia. "
      "La nostra derivazione dal segno solare e' un ponte di curatela, dichiarato: "
      "un modo per offrirti un totem coerente col tuo cielo, non un responso della "
      "tradizione. I significati vengono dalla simbologia di quelle opere, con la "
      "nostra scrittura. Non e' una diagnosi ne' una previsione: e' intrattenimento "
      "e crescita, uno specchio. Le tue scelte restano tue.";
}
