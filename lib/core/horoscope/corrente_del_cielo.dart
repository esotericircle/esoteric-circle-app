import '../astro/aspetti_di_oggi.dart';
import '../astro/effemeridi.dart';
import '../astro/natal_chart.dart';
import 'cielo_di_oggi.dart';
import 'horoscope.dart';

/// LA CORRENTE DEL GIORNO SCRITTA DAL CIELO VERO, e non pescata da un pool.
///
/// **Cosa c'era prima.** La seconda meta' di ogni scheda usciva da
/// `HoroscopeData.dayPools`, un elenco di frasi generiche scelte da una hash su
/// segno, giorno e anno. Cambiava tutti i giorni, ma non perche' fosse
/// cambiato qualcosa in cielo: cambiava perche' cambiava un numero. E due
/// persone dello stesso segno, con carte natali diverse, leggevano la stessa
/// riga identica.
///
/// Qui la stessa riga nasce da [CieloDiOggi]: nomina il pianeta che si muove,
/// la casa che sta attraversando, il punto della carta natale che tocca, e se
/// e' retrogrado. Sono i quattro fatti che un astrologo previsionale dice per
/// primi.
///
/// **E QUANDO IL CIELO NON C'E', SI DICE.** Chi ha dato solo la data di nascita
/// non ha una carta, quindi non ha aspetti ne' case: il ripiego sulla hash
/// resta, ma smette di essere muto. La scheda porta [ripiegoDichiarato], e dice
/// a parole che senza ora e luogo di nascita quella riga parla al segno e non
/// al cielo di questa persona.
/// LE FORME IN CUI SI PUO' DIRE UN PASSAGGIO DEL CIELO.
///
/// **Il difetto che le ha fatte nascere.** Nella build 2148 tutte e quattro le
/// schede dell'Oroscopo dicevano il transito con la stessa identica sintassi:
/// pianeta, casa, glossa, "Forma un ASPETTO al tuo PUNTO che si sta
/// stringendo". Tre schede su tre uguali nella struttura, una dopo l'altra
/// nella stessa schermata: si vedeva il modello del testo invece del testo.
///
/// Cinque forme, e cinque non e' un numero tondo scelto a caso: i domini sono
/// quattro, quindi con cinque forme e un passo di uno le quattro schede
/// prendono quattro forme DIVERSE per costruzione, e ne avanza una. Con
/// quattro forme esatte l'ultima scheda ricadrebbe sulla prima.
enum FormaDellaFrase {
  /// Due periodi: la casa, poi l'aspetto. E' quella che c'era.
  periodo,

  /// Un periodo solo, col ponte dei due punti.
  duePunti,

  /// La casa in apertura, il pianeta dentro.
  dallaCasa,

  /// L'aspetto in apertura, e chi lo porta dopo.
  aspettoPrima,

  /// Il punto natale come soggetto, che riceve.
  riceve,
}

/// COSA E' GIA' STATO DETTO, quando una voce non e' la prima della scheda.
enum RipresaDelCielo {
  /// Niente di questa voce e' stato detto: la frase si dice per intero.
  nessuna,

  /// Lo STESSO pianeta era gia' entrato, nella stessa casa.
  stessoPianeta,

  /// La casa era gia' stata spiegata, ma da un ALTRO pianeta.
  stessaCasa,
}

class CorrenteDelCielo {
  const CorrenteDelCielo._();

  /// I PIANETI CHE OGNI DOMINIO ASCOLTA.
  ///
  /// **E' la tradizione, dichiarata come tradizione.** Le signorie planetarie
  /// occidentali assegnano Venere e Marte agli affetti, il Sole con Saturno e
  /// Mercurio alla costruzione e al lavoro, Giove con Venere ai benefici. Il
  /// Generale non filtra: ascolta tutto, e prende il passaggio piu' stretto,
  /// che e' quello che oggi pesa di piu'.
  static const Map<HoroscopeDomain, Set<CorpoCeleste>> pianetiDi = {
    HoroscopeDomain.generale: {},
    HoroscopeDomain.amore: {
      CorpoCeleste.venere,
      CorpoCeleste.marte,
      CorpoCeleste.luna,
    },
    HoroscopeDomain.carriera: {
      CorpoCeleste.sole,
      CorpoCeleste.saturno,
      CorpoCeleste.marte,
      CorpoCeleste.mercurio,
    },
    HoroscopeDomain.fortuna: {
      CorpoCeleste.giove,
      CorpoCeleste.venere,
      CorpoCeleste.sole,
    },
  };

  /// LE CASE CHE OGNI DOMINIO ASCOLTA, con la stessa tradizione.
  ///
  /// Quinta il piacere e gli amori, settima i legami stabili, ottava
  /// l'intimita' e cio' che si condivide: sono le tre case degli affetti.
  /// Seconda le risorse, sesta il lavoro di ogni giorno, decima la carriera:
  /// sono le tre del fare. Seconda, quinta e undicesima raccolgono guadagni,
  /// azzardo e desideri, che e' dove la tradizione mette la fortuna. La prima
  /// e' la persona stessa, quindi sta nel Generale.
  static const Map<HoroscopeDomain, Set<int>> caseDi = {
    // Il Generale non filtra: la prima casa E' la persona, quindi il suo
    // dominio e' il cielo intero, e prende il passaggio piu' stretto qualunque
    // sia. Scriverci {1} sembrava piu' preciso ed era il contrario: nessun
    // transito cadeva in prima casa, il filtro restava vuoto, e si finiva sul
    // ripiego all'elenco intero passando per una strada che non diceva niente.
    HoroscopeDomain.generale: {},
    HoroscopeDomain.amore: {5, 7, 8},
    HoroscopeDomain.carriera: {2, 6, 10},
    HoroscopeDomain.fortuna: {2, 5, 11},
  };

  /// Gli ordinali femminili delle dodici case: "la 7a casa" a video si legge
  /// male, e in un responso non si scrive un numero con l'apice.
  static const List<String> ordinaliDelleCase = [
    'prima',
    'seconda',
    'terza',
    'quarta',
    'quinta',
    'sesta',
    'settima',
    'ottava',
    'nona',
    'decima',
    'undicesima',
    'dodicesima',
  ];

  /// COSA E' UNA CASA, in una manciata di parole.
  ///
  /// La casa dice DOVE nella vita, ed e' la meta' che rende il transito una
  /// frase invece che geometria. Le definizioni sono quelle correnti della
  /// tradizione occidentale, tenute corte apposta: un responso non e' un
  /// manuale.
  static const List<String> materiaDelleCase = [
    'di come ti presenti',
    'delle tue risorse',
    'degli scambi vicini',
    'delle radici e della casa',
    'di ciò che ti dà gioia',
    'del lavoro di ogni giorno',
    'dei legami che contano',
    'di ciò che si condivide nel profondo',
    'degli orizzonti larghi',
    'di ciò che costruisci in pubblico',
    'degli amici e dei desideri',
    'del ritiro e del silenzio',
  ];

  /// L'ASPETTO COL SUO ARTICOLO, perche' "un opposizione" a video e' un errore
  /// di italiano e "un quadratura" pure. Cinque voci, quante ne ha
  /// [AspectType]: non si compone l'articolo a regola, si scrive.
  static const Map<AspectType, String> aspettoConArticolo = {
    AspectType.conjunction: 'una congiunzione',
    AspectType.sextile: 'un sestile',
    AspectType.square: 'una quadratura',
    AspectType.trine: 'un trigono',
    AspectType.opposition: 'un\'opposizione',
  };

  /// IL NOME DI UN PIANETA COL SUO ARTICOLO.
  ///
  /// **In italiano il Sole e la Luna l'articolo ce l'hanno, gli altri no.** Si
  /// dice "il Sole sta attraversando" e "la Luna forma", ma "Venere sta
  /// attraversando" e "Marte forma": Venere e Marte sono nomi propri. La prima
  /// stesura scriveva "Sole sta attraversando la tua decima casa", che a video
  /// suona come una traduzione fatta male, e nessuna prova lo prendeva perche'
  /// le prove guardavano i fatti e non la lingua.
  static String colSuoArticolo(CorpoCeleste corpo, {bool maiuscola = true}) {
    switch (corpo) {
      case CorpoCeleste.sole:
        return maiuscola ? 'Il Sole' : 'il Sole';
      case CorpoCeleste.luna:
        return maiuscola ? 'La Luna' : 'la Luna';
      default:
        return corpo.nome;
    }
  }

  /// I PIANETI DI GENERE FEMMINILE, per l'accordo dell'aggettivo.
  ///
  /// "Venere è retrogrado" era quello che usciva, ed e' lo stesso errore di
  /// "al tuo Luna di nascita": si scrive la lista, non si deduce dalla
  /// desinenza. Due su dieci, la Luna e Venere.
  static const Set<CorpoCeleste> pianetiFemminili = {
    CorpoCeleste.luna,
    CorpoCeleste.venere,
  };

  /// Come si dice che un corpo e' retrogrado, con l'accordo giusto.
  static String retrogradoDi(CorpoCeleste corpo) =>
      '${colSuoArticolo(corpo)} è '
      '${pianetiFemminili.contains(corpo) ? 'retrograda' : 'retrogrado'}.';

  /// IL PRONOME DI UN ASPETTO, per la forma che lo mette in apertura.
  ///
  /// "Un trigono: LO porta Venere", "Una quadratura: LA porta Saturno".
  static const Map<AspectType, String> pronomeDellAspetto = {
    AspectType.conjunction: 'la',
    AspectType.sextile: 'lo',
    AspectType.square: 'la',
    AspectType.trine: 'lo',
    AspectType.opposition: 'la',
  };

  /// I PUNTI NATALI DI GENERE FEMMINILE, per l'articolo del complemento.
  ///
  /// "al tuo Luna di nascita" era quello che usciva prima, e si legge come un
  /// errore perche' lo e'. Sono due su dieci corpi, piu' i due angoli che sono
  /// maschili tutti e due: si scrivono, non si indovinano da una regola sulle
  /// desinenze, che in italiano su questi nomi non regge.
  static const Set<String> bersagliFemminili = {'moon', 'venus'};

  /// LA GIUNTURA FRA LA FRASE DEL SEGNO E IL CIELO DI OGGI.
  ///
  /// **Il difetto che l'ha fatta nascere.** Nella build 2148 si leggeva "Ami
  /// con slancio e teatro, doni tanto e chiedi di essere visto" e poi, di
  /// colpo, "Marte sta attraversando la tua nona casa": due testi incollati,
  /// con un salto in mezzo che si sentiva.
  ///
  /// **E la fusione vera non si fa qui.** Le quarantotto frasi del segno sono
  /// materiale scritto, chiuso, senza punti d'innesto: farci entrare dentro il
  /// transito vorrebbe dire riscriverle una per una nel corpus, che e' un
  /// lavoro sui contenuti e non su questo generatore. Quella strada resta
  /// aperta come ordine a se'. Qui il transito smette di essere un blocco
  /// appiccicato e diventa il seguito di un discorso, con un connettivo che
  /// guarda indietro alla frase del segno.
  ///
  /// **Due famiglie, e la ragione e' grammaticale.** Dopo i due punti
  /// l'italiano vuole la minuscola, ma "Marte" e "Venere" la minuscola non la
  /// possono prendere: sono nomi propri. Quindi quando la frase comincia con
  /// un nome proprio di pianeta si usa la famiglia che chiude col punto, e
  /// negli altri casi quella che apre coi due punti.
  static const List<String> giunturaCoiDuePunti = [
    'Il cielo di oggi lo dice così:',
    'Sopra di te, intanto:',
    'Il cielo lo racconta da dove passa:',
    'E il giorno lo scrive così:',
    'Guarda cosa si muove mentre leggi:',
  ];

  /// LA GIUNTURA COL PUNTO, per le frasi che cominciano con un nome proprio.
  ///
  /// **Non e' piu' la stessa frase con un punto invece dei due punti**, ordine P
  /// voce 24. Lo era: a tre indici su cinque le due famiglie portavano parola
  /// per parola lo stesso testo, e agli altri due condividevano le prime sei.
  /// Cioe' la scelta fra le due forme era grammaticale, giusta, e invisibile:
  /// chi leggeva due schede dello stesso giorno trovava lo stesso attacco, e la
  /// ragione per cui esistono due famiglie andava perduta.
  ///
  /// Adesso a ogni indice le due famiglie non condividono nemmeno le prime tre
  /// parole, e `test/la_giuntura_non_si_ripete_test.dart` lo misura indice per
  /// indice. La sostanza resta la stessa: e' una cucitura fra il testo del segno
  /// e la riga del cielo, e non dice niente che non sia vero.
  static const List<String> giunturaColPunto = [
    'Intanto, sopra di te si muove questo.',
    'Il giorno, mentre lo leggi, porta anche questo.',
    'Da dove passa, il cielo racconta anche questo.',
    'Mentre leggi, sopra di te succede questo.',
    'E il cielo, adesso, scrive anche questo.',
  ];

  /// Vero se [frase] comincia con un nome proprio di pianeta, cioe' con una
  /// parola che la minuscola non la puo' prendere.
  static bool cominciaConNomeProprio(String frase) {
    final prima = frase.trimLeft().split(' ').first.replaceAll(',', '');
    return CorpoCeleste.values.any((c) => c.nome == prima);
  }

  /// SE QUESTA FRASE VUOLE LA GIUNTURA COL PUNTO invece che coi due punti.
  ///
  /// Due ragioni, tutte e due grammaticali. La prima: comincia con un nome
  /// proprio di pianeta, che la minuscola non la prende. La seconda: dentro
  /// ha gia' i due punti, e due volte i due punti nello stesso periodo si
  /// leggono come un inciampo. La prima stesura guardava solo la prima, e la
  /// forma coi due punti usciva con "così: un trigono ...: lo porta il Sole".
  static bool vuoleLaGiunturaColPunto(String frase) =>
      cominciaConNomeProprio(frase) || frase.contains(':');

  /// La frase con la sua giuntura davanti, pronta a seguire il testo del segno.
  static String conLaGiuntura(String frase, int indice) {
    if (vuoleLaGiunturaColPunto(frase)) {
      final g = giunturaColPunto[indice % giunturaColPunto.length];
      return '$g $frase';
    }
    final g = giunturaCoiDuePunti[indice % giunturaCoiDuePunti.length];
    final minuscola = frase.isEmpty
        ? frase
        : frase[0].toLowerCase() + frase.substring(1);
    return '$g $minuscola';
  }

  /// LA FORMA DI QUESTA SCHEDA, decisa dalla data e dal segno.
  ///
  /// **Deterministica, come tutto il resto dell'elemento oracolare.** Non si
  /// pesca a caso: due aperture nello stesso giorno devono dare la stessa
  /// pagina, altrimenti chi rilegge pensa di aver letto male.
  ///
  /// **E le quattro schede non possono coincidere.** Il passo e' l'indice del
  /// dominio, quindi le quattro schede prendono `base`, `base+1`, `base+2` e
  /// `base+3` modulo cinque: quattro resti distinti, sempre, perche' quattro
  /// e' minore di cinque. Non e' una probabilita' bassa, e' una garanzia.
  static FormaDellaFrase formaDellaScheda({
    required int giornoOrdinale,
    required int indiceDelSegno,
    required HoroscopeDomain dominio,
  }) {
    const forme = FormaDellaFrase.values;
    final base = (giornoOrdinale + indiceDelSegno) % forme.length;
    return forme[(base + dominio.index) % forme.length];
  }

  /// QUANTE VOCI ENTRANO NEL TESTO, per profondita'.
  ///
  /// **Una sola per la Breve, tre per la Profonda, e la differenza deve
  /// vedersi.** La Profonda era venduta e non consegnata: il selettore non era
  /// nemmeno collegato, quindi si pagava per un'etichetta. Qui la Profonda
  /// aggiunge fatti veri, non aggettivi.
  static int quanteVoci({required bool profonda}) => profonda ? 3 : 1;

  /// LE VOCI CHE PARLANO A QUESTO DOMINIO, gia' in ordine di peso.
  ///
  /// Il Generale non filtra, gli altri tre tengono le voci che nominano un
  /// loro pianeta oppure una loro casa. Se il filtro non lascia niente si
  /// ripiega sull'elenco intero invece di tacere: un dominio senza transiti
  /// suoi ha comunque un cielo sopra, ed e' meglio dire il passaggio piu'
  /// stretto che c'e' piuttosto che tornare alla hash.
  static List<VoceDelCielo> vociPer(
      CieloDiOggi cielo, HoroscopeDomain dominio) {
    final pianeti = pianetiDi[dominio]!;
    final case_ = caseDi[dominio]!;
    if (pianeti.isEmpty && case_.isEmpty) return cielo.voci;
    final sue = [
      for (final v in cielo.voci)
        if (pianeti.contains(v.transito) ||
            (v.casa != null && case_.contains(v.casa)))
          v,
    ];
    return sue.isEmpty ? cielo.voci : sue;
  }

  /// UNA VOCE DEL CIELO IN UNA FRASE.
  ///
  /// Nomina, nell'ordine: se e' retrogrado, la casa che attraversa con la sua
  /// materia, il punto natale che tocca e con quale aspetto, e se il passaggio
  /// sta arrivando oppure sta passando.
  ///
  /// **E NON DATA MAI IL TRANSITO AL GIORNO.** Quando
  /// [VoceDelCielo.ilGiornoSiPuoDire] e' falso, cioe' quando l'incertezza sul
  /// giorno esatto supera il giorno, la frase si allarga e lo dichiara: e' il
  /// caso di Saturno, che il motore posiziona benissimo e data malissimo, da
  /// 1,29 a 8,92 giorni di incertezza.
  /// [gia] contiene le case gia' nominate, per pianeta: quando una voce ripete
  /// un pianeta gia' introdotto nella stessa casa, la frase della casa si
  /// toglie e resta la ripresa. Senza questo, la Profonda scriveva due volte di
  /// fila "Venere sta attraversando la tua dodicesima casa, quella del ritiro e
  /// del silenzio", cioe' pagava tre voci per due frasi e mezza.
  static String frase(
    VoceDelCielo v, {
    Set<String> gia = const {},
    FormaDellaFrase forma = FormaDellaFrase.periodo,
  }) {
    final ripresa = _ripresaDi(v, gia);
    final righe = <String>[];
    if (v.retrogrado && !gia.contains(_chiaveRetro(v))) {
      righe.add(retrogradoDi(v.transito));
    }
    righe.add(_corpoDellaFrase(v, forma: forma, ripresa: ripresa));
    return righe.join(' ');
  }

  /// Cosa di questa voce e' gia' stato detto nella stessa scheda.
  static RipresaDelCielo _ripresaDi(VoceDelCielo v, Set<String> gia) {
    if (gia.contains(_chiavePianetaECasa(v))) {
      return RipresaDelCielo.stessoPianeta;
    }
    if (gia.contains(_chiaveCasa(v))) return RipresaDelCielo.stessaCasa;
    return RipresaDelCielo.nessuna;
  }

  /// IL CORPO DELLA FRASE, nella forma chiesta.
  static String _corpoDellaFrase(
    VoceDelCielo v, {
    required FormaDellaFrase forma,
    required RipresaDelCielo ripresa,
  }) {
    final pianeta = colSuoArticolo(v.transito);
    final aspetto = aspettoConArticolo[v.aspetto]!;
    final bersaglio = _alBersaglio(v);
    final coda = _coda(v);
    final chiusa = _chiusaDelPassaggio(v);

    // LA GLOSSA SI DICE UNA VOLTA SOLA PER SCHEDA.
    //
    // **Il difetto.** Nella scheda Generale della build 2148 "la tua decima
    // casa, quella di cio' che costruisci in pubblico" compariva due volte
    // nello stesso paragrafo, per il Sole e per Giove. Adesso il secondo
    // pianeta la nomina senza rispiegarla, e se e' lo stesso pianeta non la
    // nomina proprio.
    switch (ripresa) {
      case RipresaDelCielo.stessoPianeta:
        return '$pianeta forma anche $aspetto $bersaglio$coda$chiusa';
      case RipresaDelCielo.stessaCasa:
        return '$pianeta, nella stessa casa, forma $aspetto '
            '$bersaglio$coda$chiusa';
      case RipresaDelCielo.nessuna:
        break;
    }

    // IL LUOGO SENZA LA SUA PREPOSIZIONE.
    //
    // Nudo apposta: ogni forma ci mette davanti quello che le serve, "la tua"
    // oppure "dalla tua". La prima stesura lo teneva gia' articolato e
    // scriveva "Da la tua decima casa", che e' l'errore di italiano piu'
    // visibile di tutti.
    final dove = v.casa == null
        ? null
        : 'tua ${ordinaliDelleCase[v.casa! - 1]} casa, quella '
            '${materiaDelleCase[v.casa! - 1]}';

    if (dove == null) {
      // Senza ora di nascita non ci sono case: la forma si riduce, e non si
      // inventa un settore della vita per riempire lo schema.
      return '$pianeta è in transito nel tuo cielo. '
          'Forma $aspetto $bersaglio$coda$chiusa';
    }

    switch (forma) {
      case FormaDellaFrase.periodo:
        return '$pianeta sta attraversando la $dove. '
            'Forma $aspetto $bersaglio$coda$chiusa';
      case FormaDellaFrase.duePunti:
        return '$pianeta attraversa la $dove: da lì forma $aspetto '
            '$bersaglio$coda$chiusa';
      case FormaDellaFrase.dallaCasa:
        return 'Dalla $dove, ${colSuoArticolo(v.transito, maiuscola: false)} '
            'forma $aspetto $bersaglio$coda$chiusa';
      case FormaDellaFrase.aspettoPrima:
        final cap = aspetto[0].toUpperCase() + aspetto.substring(1);
        // Il pianeta qui sta in mezzo alla frase, quindi va minuscolo: "lo
        // porta il Sole", non "lo porta Il Sole". E la chiusa SOSTITUISCE il
        // punto invece di aggiungersene uno, che faceva "in pubblico..".
        return '$cap $bersaglio$coda: ${pronomeDellAspetto[v.aspetto]} porta '
            '${colSuoArticolo(v.transito, maiuscola: false)}, che attraversa '
            'la $dove$chiusa';
      case FormaDellaFrase.riceve:
        return '${_bersaglioSoggetto(v)} riceve $aspetto$coda da '
            '${colSuoArticolo(v.transito, maiuscola: false)}, che attraversa '
            'la $dove$chiusa';
    }
  }

  /// Se il passaggio sta arrivando oppure sta passando.
  static String _coda(VoceDelCielo v) => v.applicativo == true
      ? ' che si sta stringendo'
      : v.applicativo == false
          ? ' che si sta sciogliendo'
          : '';

  /// LA CHIUSA, che porta il punto e, quando serve, allarga la lingua.
  ///
  /// Quando il giorno non si sa la frase lo dichiara invece di tacerlo: e' il
  /// caso di Saturno, che il motore posiziona benissimo e data malissimo.
  static String _chiusaDelPassaggio(VoceDelCielo v) => v.ilGiornoSiPuoDire
      ? '.'
      : ', un passaggio lento che matura in questi giorni senza una data '
          'precisa.';

  /// Il punto natale come SOGGETTO, per la forma che lo mette in apertura.
  static String _bersaglioSoggetto(VoceDelCielo v) {
    if (v.idBersaglio == AspettiDiOggi.idAscendente) {
      return 'Il tuo Ascendente';
    }
    if (v.idBersaglio == AspettiDiOggi.idMedioCielo) {
      return 'Il tuo Medio Cielo';
    }
    return bersagliFemminili.contains(v.idBersaglio)
        ? 'La tua ${v.bersaglio} di nascita'
        : 'Il tuo ${v.bersaglio} di nascita';
  }

  /// La casa, senza il pianeta: e' la chiave della GLOSSA, che vale per la
  /// scheda intera e non per un pianeta solo.
  static String _chiaveCasa(VoceDelCielo v) => 'casa/${v.casa}';
  static String _chiavePianetaECasa(VoceDelCielo v) =>
      '${v.transito.id}/${v.casa}';
  static String _chiaveRetro(VoceDelCielo v) => 'retro/${v.transito.id}';

  /// Il complemento del punto natale toccato, con l'articolo del suo genere.
  static String _alBersaglio(VoceDelCielo v) {
    if (v.idBersaglio == AspettiDiOggi.idAscendente) {
      return 'al tuo Ascendente';
    }
    if (v.idBersaglio == AspettiDiOggi.idMedioCielo) {
      return 'al tuo Medio Cielo';
    }
    return bersagliFemminili.contains(v.idBersaglio)
        ? 'alla tua ${v.bersaglio} di nascita'
        : 'al tuo ${v.bersaglio} di nascita';
  }

  /// L'ARTICOLO DI UN ASPETTO, per nominarlo in una frase nuova.
  static const Map<AspectType, String> articoloDellAspetto = {
    AspectType.conjunction: 'una congiunzione',
    AspectType.sextile: 'un sestile',
    AspectType.square: 'una quadratura',
    AspectType.trine: 'un trigono',
    AspectType.opposition: 'un\'opposizione',
  };

  /// IL FATTO VERO DEL GIORNO, per la chiamata del mattino. Ordine M voce 2c.
  ///
  /// Una riga sola, presa dal transito piu' forte del giorno: "Oggi Marte
  /// forma un trigono al tuo Ascendente che si sta sciogliendo." Nullo quando
  /// il cielo non porta niente di vero da dire: in quel caso LA CHIAMATA NON
  /// PARTE, perche' un testo generico e' un volantino che consuma il permesso
  /// senza restituirlo. La regola vive qui, nel dato, e una prova la tiene.
  static String? fattoDelGiorno(CieloDiOggi cielo) {
    if (!cielo.ceCieloVero || cielo.voci.isEmpty) return null;
    final v = cielo.voci.first;
    final coda = switch (v.applicativo) {
      true => ' che si sta stringendo',
      false => ' che si sta sciogliendo',
      null => '',
    };
    // **L'ARTICOLO DEL PIANETA, e non e' un dettaglio.** Usciva "Oggi Sole
    // forma un trigono", che e' lo stesso errore che `colSuoArticolo` esiste
    // per impedire: in italiano il Sole e la Luna l'articolo ce l'hanno, Marte
    // e Venere no perche' sono nomi propri. Il mattone c'era e questa riga non
    // lo usava; nessuna prova la guardava perche' fino all'ordine BK nessuno
    // mostrava questa frase a video. L'ha trovata l'anteprima del secondo
    // momento, guardata: e' il motivo per cui le anteprime si guardano.
    return 'Oggi ${colSuoArticolo(v.transito, maiuscola: false)} forma '
        '${articoloDellAspetto[v.aspetto]} ${_alBersaglio(v)}$coda.';
  }

  /// IL TESTO DEL GIORNO PER UN DOMINIO, oppure nullo se il cielo non c'e'.
  ///
  /// Nullo vuol dire che chi compone deve ripiegare sulla hash E dichiararlo:
  /// vedi [ripiegoDichiarato].
  static String? componi({
    required CieloDiOggi cielo,
    required HoroscopeDomain dominio,
    required bool profonda,
    int giornoOrdinale = 0,
    int indiceDelSegno = 0,
  }) {
    if (!cielo.ceCieloVero) return null;
    final sue = vociPer(cielo, dominio);
    if (sue.isEmpty) return null;

    // **LA PROFONDA ATTINGE AL RESTO DEL CIELO QUANDO IL DOMINIO NON BASTA.**
    //
    // Registro voce 62, ordine 2168. Il selettore Profonda prende tre voci
    // invece di una, ma il filtro del dominio ne lascia spesso UNA SOLA:
    // misurato, su Amore e Carriera il testo profondo usciva IDENTICO al
    // breve, cioe' il comando non comandava niente proprio dove la persona
    // se lo aspettava di piu'. Non e' un difetto di cablaggio, e' che non
    // c'era altro da dire DENTRO il dominio.
    //
    // Le voci che si aggiungono sono transiti VERI dello stesso cielo, solo
    // non specifici di quel dominio: si mettono in coda, dopo le sue, e mai
    // al posto loro. Chi legge Amore trova prima l'amore, poi il resto del
    // cielo di oggi. Niente si inventa: se il cielo ha una voce sola, la
    // profonda dira' una cosa sola, e sara' la verita' del giorno.
    final quante = quanteVoci(profonda: profonda);
    final scelte = <VoceDelCielo>[...sue.take(quante)];
    if (profonda && scelte.length < quante) {
      for (final v in cielo.voci) {
        if (scelte.length >= quante) break;
        if (scelte.contains(v)) continue;
        scelte.add(v);
      }
    }
    final forma = formaDellaScheda(
      giornoOrdinale: giornoOrdinale,
      indiceDelSegno: indiceDelSegno,
      dominio: dominio,
    );
    final gia = <String>{};
    final pezzi = <String>[];
    for (final v in scelte) {
      final scritta = frase(v, gia: gia, forma: forma);
      // La GIUNTURA solo sulla prima: le altre seguono un discorso gia'
      // aperto, e un connettivo a ogni frase sarebbe una cantilena.
      // LA GIUNTURA VARIA SUL DOMINIO, ordine P voce 24.
      //
      // **Il difetto: variava sul GIORNO e non sul dominio.** L'indice era
      // `giornoOrdinale + indiceDelSegno`, cioe' lo stesso per tutte e quattro
      // le schede dello stesso oroscopo dello stesso giorno: Amore, Lavoro,
      // Fortuna e Salute aprivano la loro riga del cielo con la stessa identica
      // giuntura, una sotto l'altra. Chi scorreva le quattro schede leggeva
      // quattro volte "Il cielo di oggi lo dice cosi'", e a quel punto la
      // giuntura smette di essere una cucitura e diventa un tic.
      //
      // Con `dominio.index` dentro, le quattro schede prendono base, base+1,
      // base+2 e base+3 modulo cinque: quattro resti distinti, sempre, perche'
      // quattro e' minore di cinque. E' la stessa garanzia con cui
      // `formaDellaScheda` teneva distinte le forme, applicata al connettivo
      // che ne era rimasto fuori.
      pezzi.add(pezzi.isEmpty
          ? conLaGiuntura(
              scritta, giornoOrdinale + indiceDelSegno + dominio.index)
          : scritta);
      gia.add(_chiaveCasa(v));
      gia.add(_chiavePianetaECasa(v));
      if (v.retrogrado) gia.add(_chiaveRetro(v));
    }
    return pezzi.join(' ');
  }

  /// LA RIGA CHE DICHIARA IL RIPIEGO.
  ///
  /// **Un ripiego muto e' la cosa peggiore che questa schermata possa fare**,
  /// perche' una riga generica scritta con lo stesso carattere di una vera si
  /// legge come vera. Chi ha dato solo la data di nascita legge il suo segno,
  /// non il suo cielo, e va detto con parole sue insieme al modo di rimediare.
  static const String ripiegoDichiarato =
      'Questa lettura parla al tuo segno, non ancora al tuo cielo: senza ora '
      'e luogo di nascita i transiti sulla tua carta non si possono calcolare. '
      'Completa i dati di nascita e Medora leggerà i passaggi veri sopra di te.';

  /// La stessa riga per chi ha la carta ma non l'ora.
  static const String ripiegoSenzaOra =
      'Senza l\'ora di nascita le case non si possono calcolare: qui leggi i '
      'passaggi sui tuoi pianeti, non ancora sui settori della tua vita.';

  /// La nota da mostrare sotto le schede, per il livello raggiunto. Nulla
  /// quando il cielo e' completo: li' non c'e' niente da dichiarare.
  static String? notaDelLivello(CieloDiOggi cielo) {
    switch (cielo.livello) {
      case LivelloPersonalizzazione.soloSegno:
        return ripiegoDichiarato;
      case LivelloPersonalizzazione.cartaSenzaOra:
        return ripiegoSenzaOra;
      case LivelloPersonalizzazione.cartaCompleta:
        return null;
    }
  }
}
