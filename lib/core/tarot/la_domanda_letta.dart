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

/// **LE SITUAZIONI PIU' COMUNI.** Ordine GA voce GA.06: il lettore cieco ha
/// trovato il "Cosa fare adesso" scritto su pochi modelli che non guardavano
/// la domanda (*"Metti un numero [...] quanto costa, quanto rende"* su
/// un'operazione al ginocchio). Ogni situazione ha i suoi gesti SCRITTI per
/// tono in `gestiDellaDomanda` (il nome della situazione e' la chiave); la
/// si riconosce dalle radici delle parole, confrontate senza accenti.
///
/// L'ordine dell'elenco e' la precedenza: *"Devo lasciare il lavoro per
/// tornare a studiare?"* e' un lavoro da lasciare prima che un ritorno.
enum Situazione {
  colloquio(['colloqui']),
  esame(['esame', 'esami', 'concorso', 'interrogazion']),
  promozione(['promozion', 'aumento di stipendio', 'avanzamento']),
  offerta(['offerta', 'nuova azienda', 'proposta di lavoro']),
  lasciareIlLavoro([
    'lasciare il lavoro',
    'lasciare il mio lavoro',
    'licenziarm',
    'dimetterm',
    'dimission'
  ]),
  attivita([
    'aprire',
    'attività',
    'impresa',
    'negozio',
    'avviare',
    'mettermi in proprio'
  ]),
  progetto(['progett', 'approvat', 'proposta che ho']),
  capo(['capo', 'colleg', 'responsabile']),
  ritorno([
    'tornerà',
    'tornare da me',
    'ritorno',
    'riprovarci',
    'la mia ex',
    'il mio ex',
    'tornare insieme'
  ]),
  fiducia([
    'fidarmi',
    'fidar',
    'fiducia',
    'tradi',
    'nasconde',
    'mi mente',
    'sincer'
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
  ]),
  dichiararsi(['innamorat', 'dirle', 'dirgli', 'dichiararmi', 'dichiarar']),
  // **ANDARE A VIVERE DA SOLI VIENE PRIMA DELLA DISTANZA**: *"E' giusto andare
  // a vivere lontano dai miei genitori?"* leggeva "lontan" e riceveva i gesti
  // di una coppia a distanza (*"Fissate una sera senza telefoni, voi due"*).
  // Le domande sul rapporto con i genitori, senza il trasloco, non sono qui:
  // vanno alla lente della famiglia. PADRE: ordine GA voce GA.06, commit
  // 9b2d2d29 (l'elenco delle radici, scritto senza provarlo sulle domande).
  genitori([
    'andare a vivere',
    'vivere da sol',
    'uscire di casa',
    'lasciare casa dei',
    'casa dei miei'
  ]),
  // **LA RELAZIONE A DISTANZA HA I SUOI GESTI**, ordine GA voce GA.06: il
  // lettore cieco indipendente ha trovato *"Proponi una sera senza telefoni,
  // solo voi due"* detto a una coppia che vive a distanza (tarocchi-37), e
  // *"Fissate insieme la data del prossimo incontro"* detto a chi vive col
  // marito (tarocchi-25): le due situazioni stavano in un elenco solo.
  // PADRE: ordine GA voce GA.06, commit 9b2d2d29.
  distanza(['a distanza', 'distanza']),
  coppia([
    'marito',
    'moglie',
    'compagn',
    'fidanzat',
    'intesa',
    'relazione',
    'coppia'
  ]),
  incontro([
    'incontrer',
    'incontro',
    'conoscer',
    'qualcuno di importante',
    'anima gemella'
  ]),
  pace(['pace', 'sorell', 'fratell', 'litigat', 'lite']),
  figli(['figli']),
  famigliaDiLui([
    'pranzo',
    'cena',
    'suoceri',
    'famiglia di lui',
    'famiglia di lei',
    'natale'
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
  ]),
  casa(['casa', 'compro', 'comprare', 'affitto', 'appartamento']),
  amicizia(['amicizia', 'amic']),
  studi(['corso', 'corsi', 'laurea', 'universit', 'studiare', 'facoltà']),
  attesa(['risposta', 'notizi', 'aspetto', 'attesa']),
  stallo(['stallo', 'bloccat', 'fermo', 'ferma']),
  cambiamento(['cambiamento', 'cambiare', 'cambia', 'svolta']);

  const Situazione(this.radici);

  /// Le radici che la riconoscono, scritte con gli accenti veri.
  final List<String> radici;
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
    this.primaParte,
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

  /// Nella domanda doppia, la prima domanda come l'ha scritta la persona,
  /// col punto di domanda: *"Lui mi ama ancora?"*.
  final String? primaParte;

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
    // **COMPRARE CASA E' UNA DECISIONE DI DENARO**, ordine GA voce GA.06: il
    // lettore cieco indipendente ha letto *"Le carte inclinano ad aspettare,
    // per ora"* a chi chiedeva se comprare casa adesso, senza il limite e
    // senza rimandare a chi e' competente (tarocchi-28). PADRE: ordine GA
    // voce GA.06, commit 9b2d2d29, che riconosceva il denaro solo dal mutuo.
    'comprare casa',
    'compro casa',
    'comprare la casa',
    'comprare una casa',
    'acquistare casa',
    'acquistare una casa',
    'acquisto della casa',
    'acquisto di una casa',
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
    String? primaParte;
    final m = RegExp(r' e (se |[a-z]+(ro|ra|ranno|remo) )').firstMatch(tutta);
    if (m != null && m.start > 4) {
      doppia = true;
      n = '${tutta.substring(0, m.start)} ';
      // **LA PRIMA DOMANDA, CON LE SUE PAROLE**: il lettore cieco
      // indipendente ha trovato che le doppie dicevano *"le carte rispondono
      // alla prima"* senza mai dire quale fosse (tarocchi-3, 34, 38).
      final o = RegExp(r'\s+e\s+(se\s|[a-zàèéìòù]+(rò|rà|ro|ra|ranno|remo)\s)',
              caseSensitive: false)
          .firstMatch('$t ');
      if (o != null && o.start > 4) {
        primaParte =
            '${t.substring(0, o.start).trim().replaceAll(RegExp(r'[\s,;:.?!]+$'), '')}?';
      }
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
    // **VAGA E' SOLO LA DOMANDA CHE NON NOMINA NIENTE.** *"Come andra' il
    // colloquio?"* contiene *"come andra'"*, ma nomina il colloquio: prima
    // dell'ordine GA voce GA.06 (cura del 21 ottobre) bastava la formula
    // per dirla vaga. PADRE: ordine GA voce GA.06, commit 9b2d2d29.
    final vaga = situazione == null &&
        lente == null &&
        sensibile == null &&
        (_vaghe.any((v) => tutta.contains(_senzaAccenti(v))) ||
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
      primaParte: primaParte,
      distacco: _haUna(n, _distacco),
      timore: _haUna(n, _timori),
      sceltaFraMuoversiERestare: restare,
    );
  }

  /// **IL GRUPPO DEI GESTI SCRITTI di questa domanda**, la chiave di
  /// `gestiDellaDomanda` (`la_carta_nella_risposta_scritta.dart`): la domanda
  /// vaga ha i suoi gesti, che non nominano nessun ambito (il lettore cieco
  /// indipendente ha trovato gesti sull'amicizia e sulla famiglia sotto
  /// *"Che cosa mi aspetta?"*, tarocchi-29 e 31); poi la situazione; poi la
  /// lente della domanda, o quella scelta dalla persona ([argomento]).
  String gruppoDeiGesti(TarotTopic argomento) {
    if (vaga) return 'vaga';
    final s = situazione;
    if (s != null) return s.name;
    return switch (lente ?? argomento) {
      TarotTopic.amoreQuadro => 'amoreQuadro',
      TarotTopic.cosaProva => Situazione.sentimenti.name,
      TarotTopic.ritornoAmore => Situazione.ritorno.name,
      TarotTopic.fiducia => Situazione.fiducia.name,
      TarotTopic.nuovoIncontro => Situazione.incontro.name,
      TarotTopic.scegliereTraDue => 'scegliereTraDue',
      TarotTopic.lavoroTrovare => 'lavoroTrovare',
      TarotTopic.carriera => Situazione.promozione.name,
      TarotTopic.denaro => 'denaro',
      TarotTopic.affare => 'affare',
      TarotTopic.momentoCheVivo => 'momentoCheVivo',
      TarotTopic.bivio => 'bivio',
      TarotTopic.cambiamento => Situazione.cambiamento.name,
      TarotTopic.famiglia => 'famiglia',
      TarotTopic.amicizia => 'amiciziaLente',
      TarotTopic.progetto => 'progettoLente',
    };
  }

  /// **IL GRUPPO CON CUI SI LEGGONO LE CARTE SINGOLE.** Ordine GA voce GA.06,
  /// terzo giro: il lettore cieco ha trovato le singole *"scritte sul tema
  /// della lente e non sulla domanda"*: a chi chiede dei risparmi in borsa
  /// "Il Papa" diceva *"Cerca un mentore"*, perche' l'argomento scelto era
  /// del gruppo Lavoro. Il gruppo viene dalla domanda quando la domanda lo
  /// dice (la situazione riconosciuta), e dall'argomento scelto quando non
  /// lo dice. Su salute, legge e denaro il registro e' quello della vita,
  /// mai quello del lavoro o dell'amore. PADRE: ordine FI voce 20 (i
  /// registri per gruppo dell'argomento scelto, mai per domanda).
  TarotTopicGroup gruppoDelleSingole(TarotTopic argomento) {
    if (sensibile != null) return TarotTopicGroup.vita;
    final s = situazione;
    if (s != null) {
      return switch (s) {
        Situazione.sentimenti ||
        Situazione.ritorno ||
        Situazione.fiducia ||
        Situazione.dichiararsi ||
        Situazione.distanza ||
        Situazione.coppia ||
        Situazione.incontro =>
          TarotTopicGroup.amore,
        Situazione.colloquio ||
        Situazione.promozione ||
        Situazione.offerta ||
        Situazione.lasciareIlLavoro ||
        Situazione.attivita ||
        Situazione.progetto ||
        Situazione.capo =>
          TarotTopicGroup.lavoro,
        _ => TarotTopicGroup.vita,
      };
    }
    return (lente ?? argomento).group;
  }

  /// **I GESTI DEL TEMA SENSIBILE**: su salute, legge e denaro il "Cosa fare"
  /// rimanda a chi e' competente, e nessun gesto di una carta lo accompagna.
  /// Le altre domande hanno i gesti SCRITTI per la loro situazione e per il
  /// tono del verdetto (`gestiDellaDomanda`, [gruppoDeiGesti]). LAPIDE: qui
  /// vivevano i gesti delle situazioni e delle lenti, due per situazione e
  /// senza tono, scritti dalla prima cura dell'ordine GA voce GA.06 (commit
  /// 9b2d2d29): *"Proponi una sera senza telefoni, solo voi due"* detto a una
  /// coppia a distanza, *"Passa un fine settimana nella citta' che valuti"*
  /// a chi non nominava una citta' (lettore cieco indipendente, tarocchi-37 e
  /// 34). [argomento] resta per la firma.
  List<String> azioni(TarotTopic argomento) => switch (sensibile) {
        TemaSensibile.salute => const [
            'Scrivi le domande da fare al medico, una per riga; portale con te alla prossima visita.',
            'Chiedi al medico di spiegarti con calma i tempi, il recupero e '
                'che cosa puoi fare tu.',
            'Se hai un dubbio, chiedi un secondo parere a un altro medico '
                'specialista.',
          ],
        TemaSensibile.legge => const [
            'Raccogli i documenti in ordine cronologico e confrontati con un '
                'avvocato.',
            'Chiedi a un avvocato una stima onesta dei tempi, dei costi e dei '
                'rischi.',
            'Scrivi una cronologia dei fatti, con le date, da consegnare a un '
                'avvocato.',
          ],
        TemaSensibile.denaro => const [
            'Prima di muovere i risparmi, parla con un consulente finanziario '
                'abilitato e indipendente.',
            'Metti per iscritto cifre, rischi e scadenze dell\'operazione e'
                'portali con te.',
            'Scrivi quanto puoi permetterti di perdere senza cambiare la tua '
                'vita; poi porta il foglio al consulente.',
          ],
        null => const [],
      };

  /// **LE COSE DA NON FARE di questa domanda**, nello stesso ordine.
  List<String> nonFare(TarotTopic argomento) => switch (sensibile) {
        TemaSensibile.salute => const [
            'Non prendere decisioni sulla salute in base alle carte: le carte '
                'non sostituiscono una visita.',
            'Non cambiare cure o tempi senza il parere di un medico.',
            'Non decidere nulla prima di aver sentito un medico.',
          ],
        TemaSensibile.legge => const [
            'Non prendere decisioni legali in base alle carte: decide chi '
                'conosce la legge.',
            'Non basare le tue scelte su ciò che dicono altri senza un parere '
                'competente.',
            'Non decidere sulla vicenda prima di aver sentito un professionista '
                'abilitato.',
          ],
        TemaSensibile.denaro => const [
            'Non investire in base alle carte: le carte non leggono i mercati.',
            'Non impegnare somme che non puoi permetterti di perdere.',
            'Non lasciarti convincere da chi promette guadagni sicuri.',
          ],
        null => const [],
      };
}
