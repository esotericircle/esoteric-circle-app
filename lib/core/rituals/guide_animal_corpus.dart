import '../archetypes/archetype.dart';
import '../archetypes/archetype_corpus.dart';
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
          "Il Falco è il messaggero del cielo, occhio che vede da lontano e colpisce nel segno. Vola alto e tiene la preda a fuoco senza sprecare un solo battito d'ala.",
      dono:
          "Il suo dono è l'attenzione: cogliere i segni che agli altri sfuggono e concentrare tutta la forza su un punto solo.",
      lezione:
          "La sua lezione è la mira: non basta vedere lontano, bisogna scegliere dove scendere.",
      quando:
          "Si presenta come guida quando la vita ti chiede di alzarti sopra il rumore e leggere il messaggio nascosto in un momento di svolta.",
      invito:
          "Oggi scegli un solo bersaglio e portalo a termine, senza disperderti.",
      messaggi: [
        "guarda più in alto, il quadro intero ti aspetta.",
        "un segno ti sta arrivando, tieni gli occhi aperti.",
        "scegli un bersaglio e non mollarlo.",
        "sali sopra il rumore, da lassù si vede chiaro.",
        "ciò che cerchi è già in vista, aguzza lo sguardo.",
        "un solo colpo ben mirato vale mille tentativi.",
        "leggi il messaggio nascosto in un incontro di oggi.",
        "la fretta acceca, la mira paziente colpisce.",
        "alza lo sguardo dal dettaglio, torna alla rotta.",
        "una notizia arriva dall'alto, accoglila senza paura.",
        "concentra la forza dove conta, lascia cadere il resto.",
        "il cielo ti chiama a osare un volo più ampio.",
      ],
    ),
    "Orso": AnimalRitratto(
      natura:
          "L'Orso è la forza calma che non ha bisogno di gridare. Conosce il tempo del ritiro nella tana e quello del risveglio, si muove secondo la sua stagione interiore.",
      dono:
          "Il suo dono è il potere tranquillo: una forza che guarisce, radicata nella terra e nella pazienza.",
      lezione:
          "La sua lezione è l'introspezione: c'è un tempo per agire e un tempo per rientrare in se stessi e ascoltare.",
      quando:
          "Si presenta come guida quando hai speso troppo e ti serve il coraggio di fermarti, di curarti, di tornare alla tua forza.",
      invito:
          "Oggi concediti un ritiro, anche breve, per ascoltare cosa chiede il tuo corpo.",
      messaggi: [
        "rallenta, la forza vera nasce nella calma.",
        "un ritiro ti rimette al centro, concediti la tana.",
        "guarisci prima di ripartire, non c'è fretta.",
        "la tua potenza non ha bisogno di gridare.",
        "entra nel silenzio, lì trovi la risposta.",
        "ascolta il corpo, ti dice quando fermarti.",
        "c'è un tempo per dormire e un tempo per agire.",
        "una ferita chiede cura, non un'altra corsa.",
        "torna alle radici, la terra ti sostiene.",
        "la pazienza dell'inverno prepara la primavera.",
        "difendi il tuo spazio con calma, senza rabbia.",
        "la solitudine scelta è medicina, non fuga.",
      ],
    ),
    "Volpe": AnimalRitratto(
      natura:
          "La Volpe è l'astuzia che si muove nell'ombra, veloce e silenziosa. Sa mimetizzarsi, cambiare strada e leggere il terreno prima di ogni passo.",
      dono:
          "Il suo dono è l'ingegno: risolvere con l'intelligenza e l'agilità, non con la forza.",
      lezione:
          "La sua lezione è l'adattamento: quando la via diretta è chiusa, la Volpe ne trova un'altra.",
      quando:
          "Si presenta come guida quando ti serve furbizia e leggerezza per uscire da una situazione bloccata.",
      invito:
          "Oggi aggira l'ostacolo invece di sfondarlo, cerca la via laterale.",
      messaggi: [
        "cambia strada, la via laterale è libera.",
        "usa l'ingegno, non la forza.",
        "osserva prima di muoverti, poi scatta.",
        "mimetizzati oggi, il momento giusto verrà.",
        "la furbizia gentile apre ciò che la forza chiude.",
        "leggi il terreno prima di ogni passo.",
        "un problema ha sempre una porta di servizio.",
        "sii veloce nel pensiero, lento nel giudizio.",
        "non mostrare tutte le carte, tieni un asso.",
        "l'ostacolo si aggira, raramente si sfonda.",
        "adattati alla corrente senza perdere la meta.",
        "una piccola astuzia oggi ti risparmia una fatica domani.",
      ],
    ),
    "Lupo": AnimalRitratto(
      natura:
          "Il Lupo è l'istinto che non tradisce e la fedeltà al branco. Sa correre libero e tornare ai suoi, insegna a stare nel gruppo senza sciogliersi in esso.",
      dono:
          "Il suo dono è la fiducia nell'istinto: sente il pericolo e la via giusta prima che la mente li nomini.",
      lezione:
          "La sua lezione è l'appartenenza: la vera libertà non spezza i legami, li sceglie.",
      quando:
          "Si presenta come guida quando devi difendere i tuoi o ritrovare la tua tribù senza perdere te stesso.",
      invito: "Oggi fidati di un'intuizione forte e proteggi ciò che ami.",
      messaggi: [
        "fidati dell'istinto, sa già la strada.",
        "torna ai tuoi, il branco ti aspetta.",
        "difendi ciò che conta, con lealtà.",
        "la libertà vera sceglie i suoi legami.",
        "ascolta il primo sentire, prima che la mente parli.",
        "insegna con l'esempio, il branco impara guardando.",
        "corri libero, ma non dimenticare chi ami.",
        "un confine chiaro protegge il legame.",
        "la fedeltà non è catena ma scelta.",
        "annusa il pericolo, la prudenza è saggezza.",
        "la tua voce chiama i tuoi, non aver paura di alzarla.",
        "cammina in gruppo senza sciogliere te stesso.",
      ],
    ),
    "Aquila": AnimalRitratto(
      natura:
          "L'Aquila è lo spirito che tocca il sole e guarda la terra dall'alto. Non teme l'altezza, anzi la cerca, perché da lassù ogni cosa trova il suo posto.",
      dono:
          "Il suo dono è la prospettiva: salire tanto in alto da vedere il disegno intero della tua vita.",
      lezione:
          "La sua lezione è il coraggio dello spirito: osare la vetta anche quando il vuoto sotto spaventa.",
      quando:
          "Si presenta come guida quando sei chiamato a una visione più grande e a governare te stesso con nobiltà.",
      invito:
          "Oggi guarda la tua vita dall'alto come l'Aquila, poi scegli con ampiezza.",
      messaggi: [
        "sali più in alto, la vista cambia tutto.",
        "osa la vetta, lo spirito ti regge.",
        "guarda il disegno intero, non il dettaglio.",
        "lo spirito ti chiama, non abbassare lo sguardo.",
        "dall'alto ogni cosa trova il suo posto.",
        "governa te stesso prima di guidare gli altri.",
        "il sole non teme l'altezza, tu come lui.",
        "lascia la valle stretta, allarga l'orizzonte.",
        "la nobiltà è un modo di stare, non un trono.",
        "ciò che pesa in basso si alleggerisce in volo.",
        "una visione grande merita un passo coraggioso.",
        "spicca il volo anche col vuoto sotto le ali.",
      ],
    ),
    "Gufo": AnimalRitratto(
      natura:
          "Il Gufo è il veggente della notte, che vede dove gli altri sono ciechi. Vola in silenzio e coglie la verità nascosta sotto le apparenze.",
      dono:
          "Il suo dono è la saggezza silenziosa: distinguere il vero dal falso e ascoltare ciò che non viene detto.",
      lezione:
          "La sua lezione è il discernimento: non farsi ingannare dal buio, ma imparare a vederci dentro.",
      quando:
          "Si presenta come guida quando una verità scomoda chiede di essere guardata, senza fughe.",
      invito: "Oggi ascolta il silenzio e osserva ciò che di solito ti sfugge.",
      messaggi: [
        "guarda oltre l'apparenza, la verità è sotto.",
        "il silenzio ti parla, ascoltalo.",
        "fidati di ciò che intuisci nel buio.",
        "una verità scomoda chiede di essere guardata.",
        "non farti ingannare dalle luci, cerca l'ombra.",
        "sai già la risposta, smetti di negarla.",
        "la saggezza tace e osserva, poi parla.",
        "distingui il vero dal comodo, poi scegli il vero.",
        "vola in silenzio, la preda del sapere è timida.",
        "la notte rivela ciò che il giorno nasconde.",
        "una domanda giusta vale più di cento risposte.",
        "guarda dentro, lì è custodito il segreto.",
      ],
    ),
    "Cervo": AnimalRitratto(
      natura:
          "Il Cervo è la gentilezza vigile, la grazia che non alza la voce. Si muove con dolcezza e attenzione, tiene la sua forza nella mitezza.",
      dono:
          "Il suo dono è la sensibilità: toccare il cuore degli altri con delicatezza, senza ferire.",
      lezione:
          "La sua lezione è che la dolcezza non è debolezza: si può essere gentili e fermi insieme.",
      quando:
          "Si presenta come guida quando la durezza non serve e la via si apre con la grazia.",
      invito: "Oggi tratta te stesso e gli altri con una gentilezza nuova.",
      messaggi: [
        "la dolcezza apre porte che la forza chiude.",
        "muoviti con grazia, senza fretta.",
        "ascolta il cuore, tuo e degli altri.",
        "la mitezza non è debolezza ma forza quieta.",
        "tocca chi soffre con delicatezza, non ferire.",
        "la tua sensibilità è un dono, non un difetto.",
        "resta gentile anche quando intorno si indurisce.",
        "la grazia trova la via dove la durezza si blocca.",
        "avvicina l'altro con calma, come al cervo si va piano.",
        "proteggi la tua tenerezza, non è ingenuità.",
        "un gesto gentile oggi cura più di mille parole.",
        "cammina leggero, lascia il mondo un po' più dolce.",
      ],
    ),
    "Serpente": AnimalRitratto(
      natura:
          "Il Serpente è la trasformazione che passa per la muta. Lascia la vecchia pelle senza rimpianto e rinasce, portando in se' l'energia vitale che guarisce.",
      dono:
          "Il suo dono è la rinascita: morire a ciò che eri per diventare ciò che sei.",
      lezione:
          "La sua lezione è il lasciare andare: nulla di nuovo cresce finché tieni stretta la pelle vecchia.",
      quando:
          "Si presenta come guida quando una fase è finita e chiede di essere lasciata per rinascere.",
      invito:
          "Oggi lascia andare una cosa che hai già superato, fai spazio al nuovo.",
      messaggi: [
        "lascia la vecchia pelle, adesso è tempo.",
        "una fase muore perché un'altra nasca.",
        "l'energia torna quando lasci andare.",
        "ciò che trattieni ti blocca, sciogli la presa.",
        "la ferita che curi diventa forza.",
        "rinnovati senza rimpianto, la muta è vita.",
        "scendi in profondità, lì rinasce la potenza.",
        "un veleno conosciuto diventa medicina.",
        "non temere la fine, dietro c'è il nuovo.",
        "striscia fuori dal vecchio, la terra è calda.",
        "la trasformazione chiede coraggio, non fretta.",
        "lascia morire ciò che non sei più.",
      ],
    ),
    "Cavallo": AnimalRitratto(
      natura:
          "Il Cavallo è la libertà in corsa, la potenza che porta lontano. Ha bisogno di spazio e di orizzonte, mal sopporta le briglie che spengono lo slancio.",
      dono:
          "Il suo dono è il movimento: trasformare l'energia in cammino e portarti dove vuoi arrivare.",
      lezione:
          "La sua lezione è che la libertà vera ha una direzione: la corsa senza meta stanca, la corsa scelta libera.",
      quando:
          "Si presenta come guida quando ti serve slancio per partire e coraggio per allargare i confini.",
      invito: "Oggi fai un passo verso un tuo orizzonte, muoviti davvero.",
      messaggi: [
        "parti, l'orizzonte ti chiama.",
        "porta la tua energia lontano.",
        "scegli la direzione, poi corri.",
        "la corsa senza meta stanca, dalle uno scopo.",
        "rompi le briglie che spengono il tuo slancio.",
        "il movimento scioglie ciò che il fermo blocca.",
        "hai la forza per arrivare, manca solo il primo passo.",
        "cerca spazio e aria, non sopporti le gabbie.",
        "cavalca la tua potenza, non lasciarla ferma.",
        "un viaggio chiama, non rimandarlo ancora.",
        "la libertà vera ha una rotta, scegli la tua.",
        "slancia il cuore avanti, il corpo segue.",
      ],
    ),
    "Tartaruga": AnimalRitratto(
      natura:
          "La Tartaruga porta la casa con se' e non teme il tempo. Va piano ma non si ferma, arriva dove i veloci si perdono.",
      dono:
          "Il suo dono è la pazienza radicata: la forza lenta della terra, che dura.",
      lezione:
          "La sua lezione è la costanza: il passo piccolo, ripetuto, batte lo scatto che si spegne.",
      quando:
          "Si presenta come guida quando la fretta ti danneggia e ti serve tornare al passo giusto.",
      invito: "Oggi scegli un passo piccolo e sostenibile da ripetere domani.",
      messaggi: [
        "va' piano, arriverai lo stesso.",
        "la costanza batte la fretta.",
        "porta con te la tua casa, sei protetto.",
        "un passo piccolo, ripetuto, muove montagne.",
        "non gareggiare col tempo, camminaci insieme.",
        "la lentezza saggia vede ciò che la corsa perde.",
        "radicati, la terra non ti abbandona.",
        "proteggi ciò che è tenero sotto il guscio.",
        "la pazienza è una forza, non una resa.",
        "costruisci basi solide, il resto verrà.",
        "quando tutto corre, tu tieni il passo giusto.",
        "il guscio non è prigione ma riparo.",
      ],
    ),
    "Corvo": AnimalRitratto(
      natura:
          "Il Corvo è il messaggero della soglia, che vola fra il visibile e ciò che non si vede. Custodisce i passaggi e porta segni dal mistero.",
      dono:
          "Il suo dono è la magia: cogliere che il mondo è più vasto di quanto sembra e muoversi ai suoi bordi.",
      lezione:
          "La sua lezione è il coraggio del vuoto: dal nulla apparente nasce il nuovo.",
      quando:
          "Si presenta come guida quando sei a una soglia e un cambiamento profondo chiede di essere attraversato.",
      invito:
          "Oggi accogli un segno o una coincidenza, non liquidarlo come caso.",
      messaggi: [
        "un segno ti cerca, non ignorarlo.",
        "sei a una soglia, attraversala.",
        "dal vuoto nasce il nuovo, fidati.",
        "una coincidenza ti parla, ascoltala.",
        "il mondo è più vasto di quanto sembra.",
        "ciò che sembra caso è un messaggio.",
        "attraversa il buio, dall'altra parte c'è luce.",
        "la magia vive ai bordi, non al centro.",
        "lascia andare il vecchio mondo, si apre un varco.",
        "custodisci il tuo segreto, dentro c'è potere.",
        "un sogno di stanotte porta una risposta.",
        "il corvo posa dove c'è un passaggio, guardalo.",
      ],
    ),
    "Lince": AnimalRitratto(
      natura:
          "La Lince è il segreto svelato, l'occhio che vede l'invisibile. Silenziosa e appartata, custodisce ciò che gli altri non colgono.",
      dono:
          "Il suo dono è la percezione sottile: sentire la verità di una persona o di un luogo prima delle parole.",
      lezione:
          "La sua lezione è fidarsi del sesto senso: ciò che percepisci ha valore, anche se non lo sai spiegare.",
      quando:
          "Si presenta come guida quando un segreto, tuo o altrui, chiede di essere visto e onorato.",
      invito: "Oggi fidati di una percezione sottile, anche senza prove.",
      messaggi: [
        "fidati del sesto senso, vede giusto.",
        "un segreto ti si sta svelando.",
        "ciò che senti conta, ascoltalo.",
        "guarda ciò che gli altri non colgono.",
        "il silenzio custodisce ciò che sai.",
        "una verità nascosta chiede i tuoi occhi.",
        "non spiegare tutto, alcune cose si sentono.",
        "la percezione sottile precede le parole.",
        "osserva appartato, lì cogli il vero.",
        "un sospetto giusto merita ascolto, non prova.",
        "ciò che intravedi nell'ombra è reale.",
        "custodisci il segreto altrui come il tuo.",
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
    return "Nel Test Archetipo è emerso ${dominante.conArticolo}, $chiusa "
        "Il tuo totem ne raccoglie la medicina: dove l'archetipo ti indica la "
        "strada, l'animale ti da' la forza di percorrerla. ${animal.summary}";
  }

  /// Il testo del pannello "Fonti e metodo", che cita le opere e distingue
  /// tradizione e curatela.
  static const String fontiEMetodo =
      "L'Animale Guida poggia sullo sciamanesimo e sul core shamanism di Michael "
      "Harner, insieme alla letteratura degli animali di potere: Ted Andrews "
      "(Animal Speak), Steven Farmer (Animal Spirit Guides), Jamie Sams e David "
      "Carson (Medicine Cards). Un'onestà è dovuta: nella tradizione l'animale "
      "di potere si trova col viaggio sciamanico, non si calcola dall'astrologia. "
      "La nostra derivazione dal segno solare è un ponte di curatela, dichiarato: "
      "un modo per offrirti un totem coerente col tuo cielo, non un responso della "
      "tradizione. I significati vengono dalla simbologia di quelle opere, con la "
      "nostra scrittura. Non è una diagnosi né una previsione: è intrattenimento "
      "e crescita, uno specchio. Le tue scelte restano tue.";
}
