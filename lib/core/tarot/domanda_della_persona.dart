import 'tarot_topic.dart';

/// LA DOMANDA CHE HA SCRITTO LA PERSONA, e cosa il responso ne fa.
///
/// **Ordine CQ voce 6.10, 4 settembre 2026, e il fondatore la chiama la piu'
/// grave.** Parole sue: *"COSA MOLTO GRAVE: ho fatto una domanda libera e il
/// responso ha alcun riferimento alla mia domanda, le risposte sono
/// generiche."*
///
/// **Il difetto, misurato prima di curarlo.** Su una domanda di cinque parole
/// portanti, nel testo del responso ne arrivavano **zero**. Il campo esisteva,
/// raccoglieva il testo e lo mostrava; poi la lettura chiudeva con una domanda
/// pescata dal corpus, identica che tu avessi scritto qualcosa o no. **Un
/// campo che raccoglie una domanda e non la usa e' peggio che non averlo,
/// perche' promette e non mantiene.**
///
/// **Il difetto era doppio, e la parola "generiche" lo dice.** Nominare la
/// domanda non basta: chi chiede di un ritorno d'amore e legge il responso del
/// "momento che vivo" riceve un testo generale con la sua frase incollata
/// sopra. Percio' qui la domanda fa due cose: **si fa nominare** e **sceglie
/// la lente**.
///
/// **PERCHE' NON PASSA DA UN MODELLO.** Questo motore e' deterministico e gira
/// nel telefono: a parita' di carte, argomento e domanda il testo e' sempre lo
/// stesso, e questo lo rende ripetibile e misurabile da una prova. Chiedere a
/// un modello di rispondere alla domanda e' un'altra funzione, che vive nella
/// chat dei Maestri e ha il suo costo. Qui la domanda entra dove il testo
/// nasce, e non e' poco: sceglie la lente con cui tutte e tre le carte vengono
/// lette.
class DomandaDellaPersona {
  const DomandaDellaPersona._();

  /// Le parole troppo comuni per dire di cosa parla una domanda.
  ///
  /// **Sono un dato dichiarato e non una soglia sulla lunghezza.** Filtrare
  /// per lunghezza avrebbe tenuto "quando" e buttato "ex", cioe' avrebbe
  /// tenuto il rumore e perso il senso.
  static const Set<String> vuote = {
    'che', 'chi', 'come', 'cosa', 'quando', 'dove', 'perche', 'perché',
    'quale', 'quali', 'quanto', 'devo', 'posso', 'sono', 'essere', 'avere',
    'fare', 'stare', 'della', 'delle', 'degli', 'dello', 'nella', 'nelle',
    'sulla', 'sulle', 'questo', 'questa', 'quello', 'quella', 'molto',
    'anche', 'ancora', 'sempre', 'adesso', 'oggi', 'domani', 'ieri', 'con',
    'per', 'una', 'uno', 'del', 'dei', 'nel', 'nei', 'sul', 'mio', 'mia',
    'miei', 'mie', 'suo', 'sua', 'loro', 'non', 'piu', 'più', 'gli', 'lei',
    'lui', 'noi', 'voi', 'sara', 'sarà', 'ho', 'mi', 'si', 'ti', 'ci',
  };

  /// Le parole portanti di una domanda: quelle che restano tolte le vuote.
  ///
  /// L'ordine di apparizione si conserva, perche' la prima parola portante e'
  /// quasi sempre quella di cui la domanda parla.
  static List<String> portanti(String domanda) {
    final viste = <String>{};
    final fuori = <String>[];
    for (final parola in domanda
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-zàèéìòùA-Z ]'), ' ')
        .split(RegExp(r'\s+'))) {
      if (parola.length < 2) continue;
      if (vuote.contains(parola)) continue;
      if (!viste.add(parola)) continue;
      fuori.add(parola);
    }
    return fuori;
  }

  /// Le parole che nominano ognuna delle sedici lenti.
  ///
  /// **E' un dato e non un indovinello.** Una prova lo enumera e cade se una
  /// lente resta senza parole: una lente che nessuna parola raggiunge non
  /// verrebbe mai scelta, e nessuno se ne accorgerebbe.
  static const Map<TarotTopic, List<String>> parolePerLente = {
    TarotTopic.amoreQuadro: ['amore', 'sentimenti', 'relazione', 'coppia'],
    TarotTopic.cosaProva: ['prova', 'sente', 'pensa', 'ama', 'interessa'],
    TarotTopic.ritornoAmore: ['torna', 'tornera', 'tornerà', 'ritorno', 'ex',
      'riavvicin', 'ricomincia'],
    TarotTopic.fiducia: ['fiducia', 'tradimento', 'tradisce', 'nasconde',
      'nascondendo', 'bugia', 'mente', 'sincero'],
    TarotTopic.nuovoIncontro: ['incontro', 'conoscere', 'conoscero',
      'incontrero', 'nuovo', 'nuova'],
    TarotTopic.scegliereTraDue: ['due', 'scegliere', 'entrambi', 'altra',
      'altro'],
    TarotTopic.lavoroTrovare: ['lavoro', 'lavorare', 'assunzione',
      'licenzio', 'licenziare', 'dimission', 'impiego', 'posto'],
    TarotTopic.carriera: ['carriera', 'crescita', 'promozione', 'studio',
      'studiare', 'esame', 'laurea'],
    TarotTopic.denaro: ['denaro', 'soldi', 'guadagn', 'debito', 'debiti',
      'stipendio', 'fortuna', 'vincita', 'investimento'],
    TarotTopic.affare: ['affare', 'decisione', 'contratto', 'accordo',
      'vendere', 'comprare', 'firmare'],
    TarotTopic.momentoCheVivo: ['momento', 'periodo', 'vita', 'generale'],
    TarotTopic.bivio: ['bivio', 'scelta', 'strada', 'direzione', 'dubbio'],
    TarotTopic.cambiamento: ['cambiamento', 'cambiare', 'cambia', 'trasferi',
      'trasloco', 'svolta'],
    TarotTopic.famiglia: ['famiglia', 'casa', 'madre', 'padre', 'figlio',
      'figlia', 'genitori', 'fratello', 'sorella'],
    TarotTopic.amicizia: ['amicizia', 'amico', 'amica', 'amici'],
    TarotTopic.progetto: ['progetto', 'sogno', 'aprire', 'avviare', 'idea',
      'impresa', 'libreria', 'negozio', 'attivita', 'attività'],
  };

  /// La lente che la domanda nomina, o nulla se non ne nomina nessuna.
  ///
  /// **Vince la lente con piu' parole trovate**, e a parita' vince quella che
  /// la domanda nomina per prima: chi scrive "devo lasciare il lavoro per
  /// aprire una libreria" parla di un progetto, e "libreria" arriva dopo
  /// "lavoro" ma pesa uguale, quindi la prima parola decide. E' una regola
  /// dichiarata, non un caso.
  static TarotTopic? lenteDedotta(String domanda) {
    final parole = portanti(domanda);
    if (parole.isEmpty) return null;
    TarotTopic? migliore;
    var miglioreQuante = 0;
    var migliorePrima = parole.length;
    for (final voce in parolePerLente.entries) {
      var quante = 0;
      var prima = parole.length;
      for (var i = 0; i < parole.length; i++) {
        for (final chiave in voce.value) {
          if (!parole[i].startsWith(chiave)) continue;
          quante++;
          if (i < prima) prima = i;
          break;
        }
      }
      if (quante == 0) continue;
      if (quante > miglioreQuante ||
          (quante == miglioreQuante && prima < migliorePrima)) {
        migliore = voce.key;
        miglioreQuante = quante;
        migliorePrima = prima;
      }
    }
    return migliore;
  }

  /// La domanda ripulita e chiusa col punto interrogativo.
  ///
  /// Nulla quando non c'e' niente da ripulire: un campo di soli spazi non e'
  /// una domanda, e chi non ha scritto niente deve ricevere il responso di
  /// prima, identico.
  static String? pulita(String? domanda) {
    final t = (domanda ?? '').trim();
    if (t.isEmpty) return null;
    // Una domanda che gia' finisce col suo segno non ne prende un secondo.
    final senzaCoda = t.replaceAll(RegExp(r'[?.!\s]+$'), '');
    if (senzaCoda.isEmpty) return null;
    return '$senzaCoda?';
  }

  /// La riga che apre il consiglio riprendendo la domanda.
  ///
  /// **Nomina la domanda per intero e non un suo riassunto.** Un riassunto
  /// sarebbe una mia interpretazione della sua frase, e chi legge non
  /// riconoscerebbe piu' la propria domanda: il punto di questa voce e' che
  /// la persona veda che la sua domanda e' stata letta.
  static String? apertura(String? domanda) {
    final pulitaOra = pulita(domanda);
    if (pulitaOra == null) return null;
    return 'Hai chiesto: "$pulitaOra" Le tre carte rispondono a questa e non '
        'a una domanda in generale.';
  }
}
