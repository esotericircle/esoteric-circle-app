import 'domanda_della_persona.dart';
import 'tarot_topic.dart';

/// **CHE COSA CHIEDE LA DOMANDA, nella forma.** Ordine GA voce GA.06, 21
/// ottobre 2026. Il fondatore, 19 ottobre 2026: *"risposte dirette
/// immediatamente [...] L'utente deve avere una risposta o una guida, deve
/// sapere cosa fare o non fare"*. Una risposta diretta dipende da che cosa si
/// chiede: a *"Andra' bene?"* si risponde si' o no, a *"Come lo aiuto?"* col
/// modo, a *"Quando finira'?"* col tempo, a *"Milano o Bari?"* con una delle
/// due o col criterio.
enum FormaDellaDomanda {
  /// Si risponde si', no o a una condizione: *"Il colloquio andra' bene?"*.
  siNo,

  /// Si risponde col modo: *"Come posso fare pace con mia sorella?"*.
  come,

  /// Si risponde con cio' che le carte vedono: *"Cosa prova Marco?"*.
  cosa,

  /// Si risponde col tempo, come tendenza: *"Quando finira' lo stallo?"*.
  quando,

  /// Si risponde con una delle due strade, o col criterio per sceglierla.
  scelta,

  /// Nessuna domanda scritta: la lettura dell'argomento scelto.
  nessuna,
}

/// **I TEMI CHE LE CARTE NON DECIDONO.** Ordine S voce 17, ribadito da
/// GA.06: *"Nessun consiglio su salute, denaro o questioni legali: dove la
/// domanda tocca questi temi il responso lo dice chiaramente e rimanda a chi
/// e' competente (medico, legale, consulente), senza promettere l'esito"*.
enum TemaSensibile { salute, legge, denaro }

/// **LE SITUAZIONI PIU' COMUNI, con il gesto concreto che le riguarda.**
/// Ordine GA voce GA.06: il lettore cieco ha trovato il "Cosa fare adesso"
/// scritto su pochi modelli che non guardavano la domanda (*"Metti un numero
/// [...] quanto costa, quanto rende"* su un'operazione al ginocchio). Qui
/// ogni situazione porta le sue azioni e le sue cose da non fare, scritte per
/// lei; la si riconosce dalle radici delle parole (minuscole, senza accenti).
///
/// L'ordine dell'elenco e' la precedenza: *"Devo lasciare il lavoro per
/// tornare a studiare?"* e' un lavoro da lasciare prima che un ritorno.
enum Situazione {
  colloquio([
    'colloqui'
  ], [
    'Prima del colloquio scrivi tre risultati concreti che puoi raccontare e '
        'ripetili davanti allo specchio.',
    'Informati sull\'azienda e prepara due domande da fare tu alla fine del '
        'colloquio.',
  ], [
    'Non presentarti senza aver riletto l\'annuncio e il tuo curriculum.',
    'Non sminuire quello che sai fare quando ti chiedono di raccontarlo.',
  ]),
  esame([
    'esame',
    'esami',
    'concorso',
    'interrogazion'
  ], [
    'Fissa ogni giorno, fino all\'esame, un blocco di ripasso con un orario '
        'preciso.',
    'Fai una simulazione completa della prova, col tempo misurato, entro '
        'questa settimana.',
  ], [
    'Non studiare tutta la notte prima della prova.',
    'Non rimandare a fine mese la parte che ti spaventa di più.',
  ]),
  promozione([
    'promozion',
    'aumento di stipendio',
    'avanzamento'
  ], [
    'Chiedi un incontro breve con chi decide e porta due risultati misurabili '
        'del tuo lavoro.',
    'Scrivi su una pagina che cosa hai ottenuto quest\'anno e consegnala a chi '
        'decide.',
  ], [
    'Non aspettare che qualcuno si accorga del tuo lavoro senza dirlo.',
    'Non chiedere la promozione nel mezzo di una giornata storta.',
  ]),
  offerta([
    'offerta',
    'nuova azienda',
    'proposta di lavoro'
  ], [
    'Metti su un foglio, una accanto all\'altra, le condizioni dell\'offerta e '
        'quelle di oggi.',
    'Chiedi all\'azienda un colloquio in più per chiarire compiti, orari e '
        'prospettive.',
  ], [
    'Non firmare niente prima di aver letto con calma ogni condizione.',
    'Non decidere sull\'entusiasmo del primo giorno.',
  ]),
  lasciareIlLavoro([
    'lasciare il lavoro',
    'lasciare il mio lavoro',
    'licenziarm',
    'dimetterm',
    'dimission'
  ], [
    'Parla con due persone che hanno fatto lo stesso cambio e chiedi che '
        'cosa rifarebbero.',
    'Metti per iscritto un piano di sei mesi con spese, orari e '
        'obiettivi.',
  ], [
    'Non lasciare il posto attuale prima di avere il piano scritto.',
    'Non decidere in una giornata di stanchezza.',
  ]),
  attivita([
    'aprire',
    'attività',
    'impresa',
    'negozio',
    'avviare',
    'mettermi in proprio'
  ], [
    'Scrivi su una pagina chi comprerebbe, a quale prezzo e perché; poi '
        'mostrala a una persona competente.',
    'Prova l\'idea in piccolo per un mese, con pochi clienti veri, prima di '
        'impegnare tutto.',
  ], [
    'Non fare spese grandi prima di aver provato l\'idea in piccolo.',
    'Non ascoltare solo chi ti dice quello che vuoi sentire.',
  ]),
  progetto([
    'progett',
    'approvat',
    'proposta che ho'
  ], [
    'Prepara una risposta breve alle due obiezioni più probabili sul '
        'progetto.',
    'Chiedi a chi decide quando arriva la valutazione e che cosa serve '
        'ancora.',
  ], [
    'Non riscrivere il progetto da capo mentre aspetti la risposta.',
    'Non dare per persa la cosa prima della decisione.',
  ]),
  capo([
    'capo',
    'colleg',
    'responsabile'
  ], [
    'Chiedi un incontro a quattr\'occhi e porta un solo argomento, detto con '
        'calma.',
    'Scrivi i fatti del conflitto in tre righe, senza aggettivi, prima di '
        'parlarne.',
  ], [
    'Non affrontare la questione davanti ai colleghi.',
    'Non rispondere a caldo a un messaggio che ti ha ferito.',
  ]),
  ritorno([
    'tornerà',
    'tornare da me',
    'ritorno',
    'riprovarci',
    'la mia ex',
    'il mio ex',
    'tornare insieme'
  ], [
    'Prima di cercare un contatto, metti per iscritto che cosa dovrebbe essere '
        'diverso questa volta.',
    'Aspetta tre giorni prima di scrivere e rileggi il messaggio a mente '
        'fredda.',
  ], [
    'Non scrivere di notte o dopo una giornata storta.',
    'Non fingere che quello che è successo non conti.',
  ]),
  fiducia([
    'fidarmi',
    'fidar',
    'fiducia',
    'tradi',
    'nasconde',
    'mi mente',
    'sincer'
  ], [
    'Chiedi spiegazioni con calma su un fatto preciso e ascolta la risposta '
        'fino in fondo.',
    'Scrivi i fatti che ti fanno dubitare in una colonna e le supposizioni in un\'altra.',
  ], [
    'Non controllare di nascosto il telefono dell\'altra persona.',
    'Non accusare prima di aver chiesto e ascoltato una spiegazione.',
  ]),
  sentimenti([
    'cosa prova',
    'prova per me',
    'mi ama',
    'pensa a me',
    'sente per me',
    'interesso',
    'gli piaccio',
    'le piaccio'
  ], [
    'Fai una domanda diretta e semplice a quattr\'occhi, poi ascolta la risposta senza interrompere.',
    'Guarda i gesti degli ultimi giorni più delle parole: scrivi tre fatti '
        'concreti.',
  ], [
    'Non cercare la risposta nei messaggi o nei social.',
    'Non chiedere conferme a chi non c\'entra.',
  ]),
  dichiararsi([
    'innamorat',
    'dirle',
    'dirgli',
    'dichiararmi',
    'dichiarar'
  ], [
    'Scegli un momento tranquillo e dillo con una frase semplice, senza '
        'preparare discorsi.',
    'Proponi un caffè a due e di\' quello che senti in poche parole.',
  ], [
    'Non dichiararti per messaggio o davanti ad altri.',
    'Non pretendere una risposta immediata: lascia all\'altra persona il suo tempo.',
  ]),
  coppia([
    'marito',
    'moglie',
    'compagn',
    'fidanzat',
    'intesa',
    'relazione',
    'distanza',
    'coppia'
  ], [
    'Proponi una sera senza telefoni, solo voi due; fissatela oggi stesso.',
    'Parlate di una cosa sola che vorreste cambiare, a turno e senza '
        'interrompervi.',
    'Fissate insieme la data del prossimo incontro e scrivetela nel '
        'calendario.',
  ], [
    'Non tenere il conto di chi ha dato di più.',
    'Non lasciare che i silenzi parlino al posto vostro.',
  ]),
  incontro([
    'incontrer',
    'incontro',
    'conoscer',
    'qualcuno di importante',
    'anima gemella'
  ], [
    'Questa settimana accetta un invito o iscriviti a un\'attività con persone nuove che condividono un tuo interesse.',
    'Scegli un ambiente che ti piace davvero e frequentalo con regolarità.',
  ], [
    'Non chiuderti in casa aspettando che succeda qualcosa.',
    'Non giudicare una persona dal primo minuto di conversazione.',
  ]),
  pace([
    'pace',
    'sorell',
    'fratell',
    'litigat',
    'lite'
  ], [
    'Manda un messaggio breve che riconosca la tua parte, senza chiedere niente '
        'in cambio.',
    'Proponi un incontro in un posto neutro, per un caffè e non per un '
        'processo.',
  ], [
    'Non riaprire la lite su chi aveva ragione.',
    'Non coinvolgere altri parenti nella vostra questione.',
  ]),
  figli([
    'figli'
  ], [
    'Trova un momento a due, senza domande dirette; ascolta più di quanto parli.',
    'Proponi un\'attività da fare insieme questa settimana, scelta da chi ha '
        'bisogno di aiuto.',
  ], [
    'Non riempire il silenzio di consigli che nessuno ti ha chiesto.',
    'Non fare paragoni con fratelli, cugini o compagni di scuola.',
  ]),
  genitori([
    'genitori',
    'andare a vivere',
    'vivere da sol',
    'mamma',
    'papa ',
    'madre',
    'padre'
  ], [
    'Metti su un foglio spese, distanza e tempi di un anno vissuto per conto '
        'tuo.',
    'Parlane con calma a cena, dicendo che cosa cambia e che cosa resta come '
        'prima.',
  ], [
    'Non annunciarlo nel mezzo di una discussione.',
    'Non rimandare la scelta solo per paura di deludere.',
  ]),
  famigliaDiLui([
    'pranzo',
    'cena',
    'suoceri',
    'famiglia di lui',
    'famiglia di lei',
    'natale'
  ], [
    'Prepara due argomenti leggeri e decidi prima a che ora andare via.',
    'Porta un piccolo dono e fai una domanda sincera a chi ti accoglie.',
  ], [
    'Non entrare in discussioni su politica o vecchie questioni di famiglia.',
    'Non bere un bicchiere in più per allentare la tensione.',
  ]),
  trasferimento([
    'trasferir',
    'trasloc',
    'città',
    'milano',
    'roma',
    'bari',
    'estero',
    'paese'
  ], [
    'Passa un fine settimana nella città che valuti, facendo la vita di un '
        'giorno normale.',
    'Scrivi tre cose che ti trattengono e tre che ti chiamano, poi confronta '
        'le liste.',
  ], [
    'Non decidere senza aver visto la città in un giorno qualunque.',
    'Non partire solo per scappare da qualcosa.',
  ]),
  casa([
    'casa',
    'compro',
    'comprare',
    'affitto',
    'appartamento'
  ], [
    'Fatti fare due conti precisi, la rata possibile e lo stato della casa, da '
        'chi è del mestiere.',
    'Visita almeno tre case simili prima di decidere sul prezzo.',
  ], [
    'Non firmare una proposta d\'acquisto nello stesso giorno della visita.',
    'Non decidere sotto la pressione di chi vende.',
  ]),
  amicizia([
    'amicizia',
    'amic'
  ], [
    'Di\' a quella persona, a quattr\'occhi, che cosa ti ha ferito e guarda '
        'come risponde.',
    'Prenditi due settimane di distanza e osserva se ti manca o ti alleggerisce.',
  ], [
    'Non sparire senza una parola: anche una chiusura merita rispetto.',
    'Non parlarne male con gli amici comuni.',
  ]),
  studi([
    'corso',
    'corsi',
    'laurea',
    'universit',
    'studiare',
    'facoltà'
  ], [
    'Scrivi per ogni corso tre materie che seguiresti volentieri e confronta le '
        'due liste.',
    'Parla con uno studente di ciascun corso e chiedi com\'è una settimana '
        'normale.',
  ], [
    'Non scegliere solo in base a ciò che fanno gli amici.',
    'Non decidere guardando soltanto le voci che girano.',
  ]),
  attesa([
    'risposta',
    'notizi',
    'aspetto',
    'attesa'
  ], [
    'Scrivi sul calendario la data oltre la quale chiedi tu notizie, con un messaggio breve e cortese.',
    'Occupa l\'attesa con una cosa utile che dipende solo da te e che puoi finire in pochi giorni.',
  ], [
    'Non controllare il telefono ogni ora: l\'attesa diventa solo più lunga.',
    'Non leggere il silenzio come un rifiuto prima di averne le prove.',
  ]),
  stallo([
    'stallo',
    'bloccat',
    'fermo',
    'ferma'
  ], [
    'Cambia una sola abitudine questa settimana, una che dipende solo da te.',
    'Scegli una cosa ferma da tempo e dedicale mezz\'ora ogni mattina.',
  ], [
    'Non aspettare che il cambiamento arrivi da fuori.',
    'Non rifare ogni giorno le stesse mosse sperando in un esito diverso.',
  ]),
  cambiamento([
    'cambiamento',
    'cambiare',
    'cambia',
    'svolta'
  ], [
    'Scrivi che cosa vuoi tenere e che cosa puoi lasciare, prima che il '
        'cambiamento arrivi.',
    'Prepara una cosa concreta per accogliere il cambiamento: un\'agenda, un '
        'posto, un orario.',
  ], [
    'Non resistere per abitudine a ciò che sta già cambiando.',
    'Non giudicare il cambiamento dal primo giorno.',
  ]);

  const Situazione(this.radici, this.azioni, this.nonFare);

  /// Le radici che la riconoscono, minuscole e senza accenti.
  final List<String> radici;

  /// I gesti concreti, frasi intere all'imperativo.
  final List<String> azioni;

  /// Le cose da non fare, frasi intere che cominciano con "Non".
  final List<String> nonFare;
}

/// **LA DOMANDA LETTA**: forma, tema sensibile, situazione, e se e' vaga o
/// doppia. Ordine GA voce GA.06. Deterministica e sul telefono, come
/// `DomandaDellaPersona`: a parita' di domanda la lettura e' sempre la stessa.
class LaDomandaLetta {
  const LaDomandaLetta._({
    required this.testo,
    required this.forma,
    this.sensibile,
    this.situazione,
    this.lente,
    this.vaga = false,
    this.doppia = false,
    this.distacco = false,
    this.timore = false,
    this.sceltaFraMuoversiERestare,
  });

  /// La domanda come l'ha scritta la persona, o nulla.
  final String? testo;
  final FormaDellaDomanda forma;
  final TemaSensibile? sensibile;
  final Situazione? situazione;

  /// La lente che la domanda nomina (`DomandaDellaPersona.lenteDedotta`).
  final TarotTopic? lente;

  /// La domanda non nomina niente di preciso: *"Dimmi qualcosa"*.
  final bool vaga;

  /// La domanda ne contiene due: *"Lui mi ama ancora e trovero' lavoro?"*.
  /// Si risponde alla prima e lo si dice.
  final bool doppia;

  /// La domanda chiede se lasciare, chiudere o andarsene.
  final bool distacco;

  /// **LA DOMANDA DI TIMORE**: il si' e' la cosa temuta (*"Il mio compagno
  /// mi sta nascondendo qualcosa?"*). Una carta che apre risponde no, e una
  /// che chiude non conferma il timore come un fatto: dice che c'e' qualcosa
  /// da chiarire.
  final bool timore;

  /// Nella scelta fra due, quale delle due e' restare o aspettare:
  /// `'restare'` o `'aspettare'`; nulla se nessuna delle due lo e'.
  final String? sceltaFraMuoversiERestare;

  /// Il testo minuscolo, senza accenti e senza punteggiatura, fra due spazi:
  /// le radici si cercano come inizio di parola.
  static String normale(String testo) {
    const accenti = {
      'à': 'a', 'á': 'a', 'è': 'e', 'é': 'e', 'ì': 'i', 'í': 'i', //
      'ò': 'o', 'ó': 'o', 'ù': 'u', 'ú': 'u',
    };
    final b = StringBuffer(' ');
    for (final ch in testo.toLowerCase().split('')) {
      final c = accenti[ch] ?? ch;
      b.write(RegExp(r"[a-z0-9]").hasMatch(c) ? c : ' ');
    }
    b.write(' ');
    return b.toString().replaceAll(RegExp(r' +'), ' ');
  }

  /// Le radici si scrivono con gli accenti veri, come le scrive chi parla, e
  /// si confrontano senza: il testo della domanda e' gia' senza accenti
  /// ([normale]), perche' chi scrive dal telefono spesso li perde.
  static String _senzaAccenti(String s) {
    const accenti = {
      'à': 'a', 'á': 'a', 'è': 'e', 'é': 'e', 'ì': 'i', 'í': 'i', //
      'ò': 'o', 'ó': 'o', 'ù': 'u', 'ú': 'u',
    };
    return s.split('').map((c) => accenti[c] ?? c).join();
  }

  static bool _ha(String n, String radice) =>
      n.contains(' ${_senzaAccenti(radice)}');

  static bool _haUna(String n, List<String> radici) =>
      radici.any((r) => _ha(n, r));

  static const List<String> _salute = [
    'operazion',
    'intervento',
    'chirurg',
    'medico',
    'medici',
    'malatt',
    'salute',
    'diagnos',
    'terapi',
    'ospedal',
    'guarir',
    'gravidanz',
    'tumor',
    'cancro',
    'sintom',
    'farmac',
    'esami del sangue',
    'visita medica',
  ];
  static const List<String> _legge = [
    'avvocat',
    'tribunal',
    'denunc',
    'giudice',
    'sentenz',
    'ricorso',
    'querel',
    'causa contro',
    'causa legale',
    'la causa',
    'una causa',
    'vincerò la causa',
    'legale',
  ];
  static const List<String> _denaro = [
    'investi',
    'in borsa',
    'borsa',
    'risparmi',
    'azioni in',
    'criptovalut',
    'bitcoin',
    'trading',
    'mutuo',
    'prestito',
    'debit',
    'finanziament',
  ];
  static const List<String> _distacco = [
    'lasciar',
    'chiuder',
    'andarmene',
    'andare via',
    'separar',
    'divorz',
    'trasferir',
    'andare a vivere',
    'mollar',
    'lasciare roma',
  ];
  static const List<String> _timori = [
    'nasconde',
    'tradi',
    'mi mente',
    'mentendo',
    'inganna',
    'mi lascera',
    'lasciarmi',
    'mi lascia',
    'perderò',
    'fallir',
    'andrà male',
    'finirà tra',
    'finirà la nostra',
  ];
  static const List<String> _vaghe = [
    ' dimmi qualcosa ',
    ' che cosa mi aspetta ',
    ' cosa mi aspetta ',
    ' andrà tutto bene ',
    ' come andrà ',
    ' cosa devo sapere ',
    ' cosa succederà ',
    ' cosa vedi ',
    ' parlami ',
    ' che mi dici ',
  ];

  /// **LEGGE LA DOMANDA [testo].** Nulla o vuota: la forma e' [nessuna].
  static LaDomandaLetta di(String? testo) {
    final t = (testo ?? '').trim();
    if (t.isEmpty) {
      return const LaDomandaLetta._(
          testo: null, forma: FormaDellaDomanda.nessuna);
    }
    final tutta = normale(t);
    // **LA DOMANDA DOPPIA**: due domande unite da "e". Si riconosce quando la
    // seconda parte ha un verbo suo al futuro o comincia con "se".
    var n = tutta;
    var doppia = false;
    final m = RegExp(r' e (se |[a-z]+(ro|ra|ranno|remo) )').firstMatch(tutta);
    if (m != null && m.start > 4) {
      doppia = true;
      n = '${tutta.substring(0, m.start)} ';
    }
    TemaSensibile? sensibile;
    if (_haUna(tutta, _salute)) {
      sensibile = TemaSensibile.salute;
    } else if (_haUna(tutta, _legge)) {
      sensibile = TemaSensibile.legge;
    } else if (_haUna(tutta, _denaro)) {
      sensibile = TemaSensibile.denaro;
    }
    Situazione? situazione;
    for (final s in Situazione.values) {
      if (_haUna(n, s.radici)) {
        situazione = s;
        break;
      }
    }
    final lente = DomandaDellaPersona.lenteDedotta(n);
    // **LA FORMA.**
    var forma = FormaDellaDomanda.siNo;
    String? restare;
    final o = RegExp(r' o ').allMatches(n).toList();
    if (n.startsWith(' come ') ||
        _ha(n, 'come posso') ||
        _ha(n, 'come faccio') ||
        RegExp(r' come (lo|la|li|gli|le|mi|ti|ci|ne)? ?[a-z]+o $')
            .hasMatch(n)) {
      forma = FormaDellaDomanda.come;
    } else if (n.startsWith(' quando ')) {
      forma = FormaDellaDomanda.quando;
    } else if ((o.isNotEmpty && !_ha(n, 'o no')) ||
        n.startsWith(' quale ') ||
        n.startsWith(' quali ') ||
        _ha(n, 'tra i due') ||
        _ha(n, 'fra i due') ||
        _ha(n, 'tra le due') ||
        _ha(n, 'fra le due')) {
      forma = FormaDellaDomanda.scelta;
      if (o.isNotEmpty) {
        final prima = n.substring(0, o.first.start);
        final seconda = n.substring(o.first.end - 1);
        for (final parte in [prima, seconda]) {
          if (_haUna(parte, const ['aspett', 'attend'])) restare = 'aspettare';
          if (_haUna(parte, const ['rest', 'riman'])) restare = 'restare';
        }
      }
    } else if (n.startsWith(' cosa ') ||
        n.startsWith(' che cosa ') ||
        n.startsWith(' cos ') ||
        n.startsWith(' che ') ||
        n.startsWith(' chi ') ||
        n.startsWith(_senzaAccenti(' perché '))) {
      forma = FormaDellaDomanda.cosa;
    }
    final vaga = _vaghe.any((v) => tutta.contains(_senzaAccenti(v))) ||
        (situazione == null &&
            lente == null &&
            sensibile == null &&
            DomandaDellaPersona.portanti(t).length <= 3);
    // "Dimmi qualcosa" non chiede un si' o un no: chiede che cosa le carte
    // vedono.
    if (tutta.contains(' dimmi ') || tutta.contains(' parlami ')) {
      forma = FormaDellaDomanda.cosa;
    }
    return LaDomandaLetta._(
      testo: t,
      forma: forma,
      sensibile: sensibile,
      situazione: situazione,
      lente: lente,
      vaga: vaga,
      doppia: doppia,
      distacco: _haUna(n, _distacco),
      timore: _haUna(n, _timori),
      sceltaFraMuoversiERestare: restare,
    );
  }

  /// **I GESTI CONCRETI di questa domanda**: quelli del tema sensibile, poi
  /// quelli della situazione, poi quelli della lente; [argomento] e' la lente
  /// scelta dalla persona quando la domanda non ne nomina una.
  List<String> azioni(TarotTopic argomento) => switch (sensibile) {
        TemaSensibile.salute => const [
            'Scrivi le domande da fare al medico, una per riga; portale con te alla prossima visita.',
            'Chiedi al medico di spiegarti con calma i tempi, il recupero e '
                'che cosa puoi fare tu.',
            'Se hai un dubbio, chiedi un secondo parere a un altro medico '
                'specialista.',
          ],
        TemaSensibile.legge => const [
            'Raccogli i documenti in ordine cronologico e fissa un incontro '
                'con il tuo avvocato.',
            'Chiedi al tuo legale una stima onesta dei tempi, dei costi e dei '
                'rischi.',
            'Scrivi una cronologia dei fatti, con le date, da consegnare al tuo '
                'avvocato.',
          ],
        TemaSensibile.denaro => const [
            'Prima di muovere i risparmi, parla con un consulente finanziario '
                'abilitato e indipendente.',
            'Chiedi a un consulente abilitato di spiegarti rischi e costi per '
                'iscritto, prima di firmare.',
            'Scrivi quanto puoi permetterti di perdere senza cambiare la tua '
                'vita; poi porta il foglio al consulente.',
          ],
        null => situazione?.azioni ?? _azioniDellaLente(lente ?? argomento),
      };

  /// **LE COSE DA NON FARE di questa domanda**, nello stesso ordine.
  List<String> nonFare(TarotTopic argomento) => switch (sensibile) {
        TemaSensibile.salute => const [
            'Non prendere decisioni sulla salute in base alle carte: le carte '
                'non sostituiscono una visita.',
            'Non cambiare cure o tempi senza il parere del medico che ti segue.',
          ],
        TemaSensibile.legge => const [
            'Non prendere decisioni legali in base alle carte: decide chi '
                'conosce la legge.',
            'Non parlare della causa con la controparte senza il tuo '
                'avvocato.',
          ],
        TemaSensibile.denaro => const [
            'Non investire in base alle carte: le carte non leggono i mercati.',
            'Non muovere i risparmi per paura di perdere un\'occasione.',
          ],
        null => situazione?.nonFare ?? _nonFareDellaLente(lente ?? argomento),
      };

  static List<String> _azioniDellaLente(TarotTopic t) => switch (t) {
        TarotTopic.amoreQuadro => const [
            'Scrivi che cosa cerchi davvero in un legame e tienilo come '
                'bussola nelle scelte.',
            'Dedica questa settimana una sera intera a ciò che conta nella tua '
                'vita affettiva.',
          ],
        TarotTopic.cosaProva => Situazione.sentimenti.azioni,
        TarotTopic.ritornoAmore => Situazione.ritorno.azioni,
        TarotTopic.fiducia => Situazione.fiducia.azioni,
        TarotTopic.nuovoIncontro => Situazione.incontro.azioni,
        TarotTopic.scegliereTraDue => const [
            'Scrivi per ciascuna delle due persone che cosa ti fa stare bene e '
                'che cosa no.',
            'Immagina di aver già scelto e osserva quale delle due ti dà '
                'sollievo.',
          ],
        TarotTopic.lavoroTrovare => const [
            'Manda oggi una candidatura mirata o un messaggio a chi può '
                'presentarti.',
            'Aggiorna il curriculum con i risultati concreti degli ultimi due anni, uno per riga.',
          ],
        TarotTopic.carriera => Situazione.promozione.azioni,
        TarotTopic.denaro => const [
            'Metti in ordine i conti di casa, cioè bollette, scadenze e ricevute, in un\'ora sola.',
            'Scrivi che cosa vuoi davvero ottenere col denaro e perché ti '
                'importa.',
            'Fai l\'elenco delle spese fisse del mese e segna quella che puoi '
                'ridurre per prima.',
          ],
        TarotTopic.affare => const [
            'Leggi ogni clausola con calma e fatti spiegare quelle che non '
                'capisci.',
            'Chiedi un giorno in più prima di dare la risposta.',
          ],
        TarotTopic.momentoCheVivo => const [
            'Scegli una cosa sola su cui concentrarti questa settimana e scrivila dove la vedi ogni mattina.',
            'Prenditi un\'ora per mettere in ordine le priorità del mese.',
          ],
        TarotTopic.bivio => const [
            'Scrivi per ogni opzione che cosa guadagni e che cosa perdi.',
            'Immagina di aver già scelto e osserva quale delle due ti dà '
                'sollievo.',
          ],
        TarotTopic.cambiamento => Situazione.cambiamento.azioni,
        TarotTopic.famiglia => const [
            'Organizza questa settimana una cena o una passeggiata con le persone di casa, senza telefoni a tavola.',
            'Telefona a un familiare che senti poco e chiedi come sta davvero, senza fretta di chiudere.',
          ],
        TarotTopic.amicizia => const [
            'Scrivi a una persona amica che senti poco e proponi di vedervi.',
            'Di\' a un\'amicizia che conta quanto tieni a lei, con un gesto '
                'concreto.',
          ],
        TarotTopic.progetto => const [
            'Scrivi il primo obiettivo del progetto, fissane la data e mettila dove la vedi ogni giorno.',
            'Mostra il progetto a una persona competente e chiedi un parere '
                'sincero.',
          ],
      };

  static List<String> _nonFareDellaLente(TarotTopic t) => switch (t) {
        TarotTopic.amoreQuadro => const [
            'Non accontentarti di attenzioni a metà.',
            'Non decidere del tuo cuore per paura di restare senza.',
          ],
        TarotTopic.cosaProva => Situazione.sentimenti.nonFare,
        TarotTopic.ritornoAmore => Situazione.ritorno.nonFare,
        TarotTopic.fiducia => Situazione.fiducia.nonFare,
        TarotTopic.nuovoIncontro => Situazione.incontro.nonFare,
        TarotTopic.scegliereTraDue => const [
            'Non tenere aperte due porte per paura di scegliere.',
            'Non lasciare che decida il senso di colpa.',
          ],
        TarotTopic.lavoroTrovare => const [
            'Non mandare lo stesso messaggio a tutte le aziende.',
            'Non aspettare il momento perfetto per candidarti: non arriva da solo.',
          ],
        TarotTopic.carriera => Situazione.promozione.nonFare,
        TarotTopic.denaro => const [
            'Non prendere decisioni economiche importanti in base alle carte.',
            'Non fare acquisti grandi per consolarti.',
            'Non prestare denaro per senso di colpa o per non dire di no.',
          ],
        TarotTopic.affare => const [
            'Non firmare niente sotto pressione, neppure se ti dicono che '
                'l\'offerta scade.',
            'Non decidere prima di aver letto tutto, comprese le righe in '
                'piccolo.',
          ],
        TarotTopic.momentoCheVivo => const [
            'Non disperdere le energie in dieci direzioni.',
            'Non rimandare ancora la cosa che sai di dover fare.',
          ],
        TarotTopic.bivio => const [
            'Non lasciare che a decidere sia la paura di sbagliare.',
            'Non chiedere il parere di tutti: alla fine scegli comunque tu.',
          ],
        TarotTopic.cambiamento => Situazione.cambiamento.nonFare,
        TarotTopic.famiglia => const [
            'Non riaprire a tavola vecchie liti che nessuno ha voglia di affrontare.',
            'Non dare per scontato chi ti sta vicino ogni giorno.',
          ],
        TarotTopic.amicizia => const [
            'Non tenere un rancore senza dirlo a chi riguarda.',
            'Non misurare l\'amicizia sul numero dei messaggi.',
          ],
        TarotTopic.progetto => const [
            'Non aspettare che tutto sia perfetto per cominciare.',
            'Non disperdere l\'idea in troppe direzioni nello stesso momento.',
          ],
      };
}
