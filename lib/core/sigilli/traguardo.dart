import '../maestro/maestro.dart';

/// LE OTTO FAMIGLIE DEI TRAGUARDI, e non sono un'etichetta.
///
/// Ogni famiglia risponde a modo suo alla domanda che governa tutto questo
/// lavoro, "perche' torno domani". La prova che enumera i traguardi conta le
/// famiglie e cade se una scende sotto il suo minimo: senza quel conteggio, un
/// sentiero potrebbe riempirsi di cinquanta compiti da sbrigare in un
/// pomeriggio e sembrare comunque completo.
enum FamigliaDelTraguardo {
  /// Il cielo comanda: si compiono solo dentro una finestra astronomica vera.
  /// Sono i migliori che questa app possa avere, perche' non si affrettano.
  cielo,

  /// Il ritorno nel tempo: giorni di seguito, il rientro dopo un'assenza.
  ritorno,

  /// La giornata chiusa: tutti i doni del giorno nello stesso giorno.
  giornata,

  /// La profondita' in un'arte sola.
  profondita,

  /// L'ampiezza fra le arti e fra i Maestri.
  ampiezza,

  /// L'identita' che si completa.
  identita,

  /// La memoria: cio' che il Cerchio si ricorda di te.
  memoria,

  /// Il Cerchio: condivisione e invito. Premio, mai pedaggio.
  cerchio;

  /// PERCHE' CONTA UN TRAGUARDO DI QUESTA FAMIGLIA. Ordine P voce 19.
  ///
  /// **Da dove viene questo testo, dichiarato.** La correzione del 12 agosto
  /// 2026 rende il "perche' conta" obbligatorio su tutti e 165, compresi quelli
  /// che restano interamente dell'ordine O perche' nell'Allegato A non esiste
  /// un accostamento sensato. Per quelli il testo NON si inventa uno per uno:
  /// si prende da qui, cioe' dalla famiglia, che e' il dato che gia' dice
  /// perche' quel traguardo esiste. Otto ragioni scritte una volta valgono piu'
  /// di centotredici frasi scritte a mano che nessuno rileggera' mai.
  String get percheContaLaFamiglia {
    switch (this) {
      case FamigliaDelTraguardo.cielo:
        return 'Il cielo comanda e non si affretta: questo traguardo si compie '
            'solo dentro una finestra astronomica vera, quindi arriva quando '
            'arriva. È il tipo di traguardo che nessun\'altra app può dare.';
      case FamigliaDelTraguardo.ritorno:
        return 'Non conta la volta, conta la seconda volta: è tornare che '
            'trasforma un\'app aperta per curiosità in un appuntamento.';
      case FamigliaDelTraguardo.giornata:
        return 'Una giornata chiusa vale più di cinque aperture sparse: i '
            'doni si tengono per mano solo se stanno nello stesso giorno.';
      case FamigliaDelTraguardo.profondita:
        return 'La stessa arte ripetuta smette di essere una prova e comincia a '
            'essere una pratica: è lì che i responsi cominciano a parlarsi.';
      case FamigliaDelTraguardo.ampiezza:
        return 'Due arti sullo stesso cielo dicono cose diverse e la terza le '
            'lega: l\'ampiezza è il modo in cui il Cerchio smette di essere '
            'una funzione sola.';
      case FamigliaDelTraguardo.identita:
        return 'È il momento in cui l\'app smette di parlare al tuo segno e '
            'comincia a parlare a te: senza questi pezzi ogni lettura resta '
            'generica.';
      case FamigliaDelTraguardo.memoria:
        return 'Il Cerchio si ricorda di te: quello che hai già detto non '
            'devi ridirlo ed è la differenza fra un servizio e una '
            'relazione.';
      case FamigliaDelTraguardo.cerchio:
        return 'Ciò che si condivide torna indietro: il Cerchio è premio, '
            'mai pedaggio e nessun traguardo di questa famiglia si può '
            'raggiungere per obbligo.';
    }
  }
}

/// IL NOME DI UN TRAGUARDO, COL SUO PLURALE COME DATO. Ordine P voce 38.
///
/// **Perche' il plurale e' un dato e non una lettera aggiunta a mano.** Nel
/// Cosmic Passport si leggeva "I tuoi Stella", "I tuoi Frutto", "I tuoi
/// Petalo": qualcuno aveva incollato il nome SINGOLARE dentro una frase al
/// plurale, e nessuna prova poteva accorgersene perche' il nome non diceva
/// che forma fosse. E' la stessa famiglia gia' chiusa a inizio agosto con
/// "Ne hai uno oggi" contro "Ne hai una oggi".
///
/// Da qui in poi un nome porta con se' le due forme e chi lo usa dichiara
/// quale sta chiedendo. Le due forme sono gli unici modi di leggerlo: non
/// esiste un accesso "al nome e basta" da cui possa ripartire il difetto.
class NomeDelTraguardo {
  const NomeDelTraguardo(this.singolare, this.plurale);

  /// Uno solo: "Stella", "Frutto", "Petalo".
  final String singolare;

  /// Piu' di uno: "Stelle", "Frutti", "Petali".
  final String plurale;
}

/// I TRE SENTIERI, con l'identita' gia' decisa da Mauro.
enum Sentiero {
  /// Costellazione personale: le Stelle del Cammino e le Costellazioni.
  costellazione(
    Maestro.medora,
    'Costellazione personale',
    NomeDelTraguardo('Stella', 'Stelle'),
    NomeDelTraguardo('Costellazione', 'Costellazioni'),
    'Ogni gesto che compi accende una stella e le stelle accese si uniscono '
        'in una figura che nel cielo di nessun altro esiste.',
  ),

  /// Albero della Vita: i Frutti dell'Albero e le Sefirot Maggiori.
  albero(
    Maestro.caligo,
    'Albero della Vita',
    NomeDelTraguardo('Frutto', 'Frutti'),
    NomeDelTraguardo('Sefira', 'Sefirot'),
    'Ogni gesto che compi matura un frutto su un ramo e di ramo in ramo '
        'l\'Albero sale fino alla corona.',
  ),

  /// Fiore di Loto: le Perle del Risveglio e le Fioriture. Si chiamano PERLE
  /// dall'ordine AF: l'arte nuova porta una perla su ogni petalo, e la legge
  /// delle luci accende quella.
  loto(
    Maestro.aura,
    'Fiore di Loto',
    NomeDelTraguardo('Perla', 'Perle'),
    NomeDelTraguardo('Fioritura', 'Fioriture'),
    'Ogni gesto che compi accende una perla e il loto si schiude quando il '
        'respiro ha smesso di essere una decisione.',
  );

  const Sentiero(
    this.maestro,
    this.titolo,
    this.mini,
    this.grande,
    this.promessa,
  );

  final Maestro maestro;
  final String titolo;

  /// Come si chiama un traguardo piccolo su questo sentiero, nelle due forme.
  final NomeDelTraguardo mini;

  /// Come si chiama un traguardo grande su questo sentiero, nelle due forme.
  final NomeDelTraguardo grande;

  /// LA FRASE INTERA che dice a cosa serve il sentiero.
  ///
  /// Scritta per intero e non composta incollando pezzi: e' una frase che si
  /// legge, non un segnaposto riempito a runtime. Dice a cosa serve il
  /// cammino, non quanti pezzi ha, perche' "cinquanta piccoli con cinque
  /// grandi" e' un inventario e nessuno torna domani per un inventario.
  final String promessa;
}

/// LE CONDIZIONI, TIPIZZATE E NON SCRITTE A MANO OGNI VOLTA.
///
/// **Perche' un tipo e non una funzione qualunque.** I criteri di accettazione
/// dell'ordine si misurano sulla CONDIZIONE, non sull'intenzione: quanti
/// traguardi non si possono chiudere nello stesso giorno, quanti dipendono dal
/// cielo vero, se due traguardi dicono la stessa cosa con parole diverse. Con
/// una funzione anonima nessuna prova potrebbe rispondere; con un tipo che
/// dichiara `chiedeUnAltroGiorno`, `chiedeIlCielo` e una `firma`, la prova
/// legge i dati e conta.
sealed class CondizioneDelTraguardo {
  const CondizioneDelTraguardo();

  /// Vero se il traguardo NON si puo' chiudere nello stesso giorno in cui
  /// diventa visibile: e' cio' che distingue un traguardo di ritorno da un
  /// compito.
  bool get chiedeUnAltroGiorno;

  /// Vero se serve un evento del cielo reale.
  bool get chiedeIlCielo => false;

  /// L'impronta della condizione, per la prova che pretende che nessun
  /// traguardo sia la riformulazione di un altro. Due condizioni con la stessa
  /// firma sono lo stesso traguardo detto in due modi.
  String get firma;

  /// Se il traguardo e' raggiunto, guardando lo stato del cammino.
  bool raggiunto(StatoDelCammino stato);
}

/// **IL GRADINO CHE DORME. Ordine AR voce 05.**
///
/// Un dormiente non e' un traguardo tolto ne' un traguardo finto: e' una voce
/// del dato che oggi NON si puo' raggiungere, perche' chiede un gesto che
/// l'app non registra o un dettaglio che nessuna scena manda. Resta nel
/// Cammino, il Journal la mostra come in arrivo, e non arma mai: `raggiunto`
/// risponde falso a qualunque stato, per costruzione.
///
/// **Il perche' viaggia col dato.** Non e' un commento: e' il campo che il
/// manifesto e il rapporto leggono, e il giorno che il motore mancante
/// arriva basta cambiare la condizione nel corpus e rigenerare.
class Dormiente extends CondizioneDelTraguardo {
  const Dormiente(this.di, this.perche);

  /// L'id del traguardo che dorme. **Sta nella firma**, e la ragione e' che
  /// diciotto dormienti con la stessa ragione avevano la stessa firma, e la
  /// guardia della legge li accusava di accendersi tutti insieme sullo stesso
  /// gesto: dormono insieme, ma ognuno e' un gradino suo.
  final String di;

  /// Cosa manca perche' questo gradino si svegli.
  final String perche;

  @override
  bool get chiedeUnAltroGiorno => true;

  /// **LA FIRMA E' UNICA PER RAGIONE**, cosi' due dormienti non sembrano lo
  /// stesso traguardo detto due volte: dormono per motivi loro.
  @override
  String get firma => 'dormiente:$di:$perche';

  @override
  bool raggiunto(StatoDelCammino stato) => false;
}

/// **LA VARIETA' DENTRO UN'ARTE. Ordine AR voce 02, famiglia Profondita'.**
///
/// "Tutti e quattro i semi", "otto dei sedici argomenti", "tutte le
/// ventiquattro rune": non e' quante volte si ripete un gesto, e' quante cose
/// DIVERSE si sono incontrate facendolo. Poggia sui dettagli che la scena
/// porta col gesto (ordine AR voce 11): senza quelli non matura mai, ed e' il
/// modo giusto di non maturare.
class VarietaDelDettaglio extends CondizioneDelTraguardo {
  const VarietaDelDettaglio(this.gesto, this.chiave, this.quanti);

  final String gesto;
  final String chiave;
  final int quanti;

  /// La varieta' non si fa in un pomeriggio quando ne chiede piu' di due.
  @override
  bool get chiedeUnAltroGiorno => quanti > 2;

  @override
  String get firma => 'varieta:$gesto.$chiave:$quanti';

  @override
  bool raggiunto(StatoDelCammino stato) =>
      (stato.valoriDistinti['$gesto.$chiave'] ?? 0) >= quanti;
}

/// **LA COINCIDENZA. Ordine AR voce 02, famiglia Coincidenza.**
///
/// "La stessa carta esce in due stese diverse": non si puo' cercare, si puo'
/// solo notare, ed e' per questo che vale. Poggia anche lei sui dettagli.
class CoincidenzaDelDettaglio extends CondizioneDelTraguardo {
  const CoincidenzaDelDettaglio(this.gesto, this.chiave, this.quanteVolte);

  final String gesto;
  final String chiave;
  final int quanteVolte;

  @override
  bool get chiedeUnAltroGiorno => true;

  @override
  String get firma => 'coincidenza:$gesto.$chiave:$quanteVolte';

  @override
  bool raggiunto(StatoDelCammino stato) =>
      (stato.massimeRipetizioni['$gesto.$chiave'] ?? 0) >= quanteVolte;
}

/// **I GRADINI ALLE SPALLE. Ordine AR voce 02, famiglia Dedizione.**
///
/// "Dieci gradini alle spalle: si accende col primo gesto di Medora dopo il
/// decimo". E' l'unico posto dove il conteggio sopravvive, ed e' un conteggio
/// di TRAGUARDI e non di gesti: misura quanta strada si e' fatta, non quante
/// volte si e' toccato lo stesso pulsante.
class GradiniAlleSpalle extends CondizioneDelTraguardo {
  const GradiniAlleSpalle(this.sentiero, this.quanti);

  /// Il sentiero i cui gradini si contano, per nome (`costellazione`,
  /// `albero`, `loto`).
  final String sentiero;
  final int quanti;

  @override
  bool get chiedeUnAltroGiorno => true;

  @override
  String get firma => 'gradini:$sentiero:$quanti';

  @override
  bool raggiunto(StatoDelCammino stato) =>
      (stato.gradiniAlleSpalle[sentiero] ?? 0) >= quanti;
}

/// GIORNI DI SEGUITO in un rito. Non si affretta per definizione.
class GiorniDiSeguito extends CondizioneDelTraguardo {
  const GiorniDiSeguito(this.rito, this.quanti);

  final String rito;
  final int quanti;

  @override
  bool get chiedeUnAltroGiorno => quanti > 1;

  @override
  String get firma => 'seguito:$rito:$quanti';

  @override
  bool raggiunto(StatoDelCammino stato) =>
      (stato.seriePerRito[rito] ?? 0) >= quanti;
}

/// QUANTE VOLTE si e' compiuto un gesto, da sempre.
class GestiCompiuti extends CondizioneDelTraguardo {
  const GestiCompiuti(this.gesto, this.quanti, {this.inGiorniDiversi = false});

  final String gesto;
  final int quanti;

  /// Se i gesti devono cadere in giorni DIVERSI: e' cio' che impedisce di
  /// chiudere dieci stese in dieci minuti.
  final bool inGiorniDiversi;

  @override
  bool get chiedeUnAltroGiorno => inGiorniDiversi && quanti > 1;

  @override
  String get firma => 'gesti:$gesto:$quanti:$inGiorniDiversi';

  @override
  bool raggiunto(StatoDelCammino stato) => inGiorniDiversi
      ? (stato.giorniConGesto[gesto] ?? 0) >= quanti
      : (stato.gestiCompiuti[gesto] ?? 0) >= quanti;
}

/// GESTI DIVERSI nello stesso giorno: l'ampiezza e la giornata chiusa.
class GestiNelloStessoGiorno extends CondizioneDelTraguardo {
  const GestiNelloStessoGiorno(this.gesti, {this.quantiBastano});

  final List<String> gesti;

  /// Quanti dei gesti elencati bastano. Nullo vuol dire tutti.
  final int? quantiBastano;

  int get _soglia => quantiBastano ?? gesti.length;

  @override
  bool get chiedeUnAltroGiorno => false;

  @override
  String get firma => 'insieme:${(List.of(gesti)..sort()).join("+")}:$_soglia';

  @override
  bool raggiunto(StatoDelCammino stato) =>
      gesti.where(stato.oggiHaFatto.contains).length >= _soglia;
}

/// IL RITORNO DOPO UN'ASSENZA: chi torna dopo giorni di silenzio.
class RitornoDopoAssenza extends CondizioneDelTraguardo {
  const RitornoDopoAssenza(this.giorniDiAssenza);

  final int giorniDiAssenza;

  @override
  bool get chiedeUnAltroGiorno => true;

  @override
  String get firma => 'ritorno:$giorniDiAssenza';

  @override
  bool raggiunto(StatoDelCammino stato) =>
      stato.giorniDiAssenzaPrimaDiOggi >= giorniDiAssenza;
}

/// UN GESTO DENTRO UN'ORA RITUALE: l'alba vera, il tramonto vero, la notte.
class GestoNellOraGiusta extends CondizioneDelTraguardo {
  const GestoNellOraGiusta(this.gesto, this.ora, {this.quanteVolte = 1});

  final String gesto;

  /// 'alba', 'tramonto' oppure 'notte', misurate sull'ora vera del luogo.
  final String ora;
  final int quanteVolte;

  @override
  bool get chiedeUnAltroGiorno => quanteVolte > 1;

  @override
  bool get chiedeIlCielo => true;

  @override
  String get firma => 'ora:$gesto:$ora:$quanteVolte';

  @override
  bool raggiunto(StatoDelCammino stato) =>
      (stato.gestiNellOraGiusta['$gesto@$ora'] ?? 0) >= quanteVolte;
}

/// LA FINESTRA DEL CIELO: si apre quando il cielo vuole, non quando vuoi tu.
class FinestraDelCielo extends CondizioneDelTraguardo {
  const FinestraDelCielo(this.evento, {this.conGesto});

  /// Il nome dell'evento, dal catalogo di `EventiDelCielo`.
  final String evento;

  /// Il gesto da compiere dentro la finestra. Nullo vuol dire che basta
  /// esserci: aprire l'app quel giorno.
  final String? conGesto;

  @override
  bool get chiedeUnAltroGiorno => true;

  @override
  bool get chiedeIlCielo => true;

  @override
  String get firma => 'cielo:$evento:${conGesto ?? "presenza"}';

  @override
  bool raggiunto(StatoDelCammino stato) {
    if (!stato.eventiDelCieloDiOggi.contains(evento)) return false;
    if (conGesto == null) return true;
    return stato.oggiHaFatto.contains(conGesto);
  }
}

/// UN PEZZO DELL'IDENTITA' che si completa.
class PezzoDellIdentita extends CondizioneDelTraguardo {
  const PezzoDellIdentita(this.pezzo);

  final String pezzo;

  @override
  bool get chiedeUnAltroGiorno => false;

  @override
  String get firma => 'identita:$pezzo';

  @override
  bool raggiunto(StatoDelCammino stato) =>
      stato.pezziDellIdentita.contains(pezzo);
}

/// LA MEMORIA: cio' che il Cerchio si ricorda di te, e che il tempo costruisce.
class MemoriaDelCerchio extends CondizioneDelTraguardo {
  const MemoriaDelCerchio(this.cosa, this.quanti, {this.dopoGiorni = 0});

  /// 'momenti', 'fatti', 'ripresa' (il Maestro riprende una cosa detta),
  /// 'rilettura' (rileggere un consulto vecchio), 'tema' (un tema che torna).
  final String cosa;
  final int quanti;

  /// Quanti giorni devono essere passati perche' conti.
  final int dopoGiorni;

  @override
  bool get chiedeUnAltroGiorno => dopoGiorni > 0 || quanti > 1;

  @override
  String get firma => 'memoria:$cosa:$quanti:$dopoGiorni';

  @override
  bool raggiunto(StatoDelCammino stato) {
    final quanto = stato.memoria[cosa] ?? 0;
    if (quanto < quanti) return false;
    if (dopoGiorni == 0) return true;
    return stato.giorniDalPrimoGiorno >= dopoGiorni;
  }
}

/// IL CERCHIO: condivisione e invito. Premio, mai pedaggio.
class GestoDelCerchio extends CondizioneDelTraguardo {
  const GestoDelCerchio(this.gesto, this.quanti);

  final String gesto;
  final int quanti;

  @override
  bool get chiedeUnAltroGiorno => quanti > 1;

  @override
  String get firma => 'cerchio:$gesto:$quanti';

  @override
  bool raggiunto(StatoDelCammino stato) =>
      (stato.gestiCompiuti[gesto] ?? 0) >= quanti;
}

/// UN TRAGUARDO DEL CAMMINO.
///
/// Vive nei file di dati dei tre sentieri, mai sparso nel codice: chi vuole
/// aggiungerne uno tocca un file solo, e le prove che contano famiglie, Eos e
/// ripetizioni lo vedono subito.
class Traguardo {
  const Traguardo({
    required this.id,
    required this.nome,
    required this.famiglia,
    required this.condizione,
    required this.frase,
    required this.posizione,
    required this.percheConta,
    required this.cosaApre,
    this.eGrande = false,
    this.eos = 0,
    this.fascia = '',
    this.dormiente = false,
  });

  /// PERCHE' CONTA, il terzo dei quattro campi. Ordine P voce 19.
  ///
  /// Non e' la [frase] della festa: quella si legge una volta sola, al momento
  /// in cui il Sigillo si accende. Questa si legge PRIMA, sul sentiero, e deve
  /// far venire voglia di raggiungerlo.
  final String percheConta;

  /// COSA APRE, il quarto campo, ED E' LA REGOLA DI AMMISSIONE.
  ///
  /// **Un traguardo che non apre niente non entra nell'elenco.** E' il filtro
  /// con cui i 165 sono stati scritti e va usato per ogni traguardo che verra'
  /// aggiunto dopo. Il campo e' obbligatorio su tutti e 165, anche su quelli
  /// che restano interamente dell'ordine O: non e' decorativo, e' il
  /// collegamento di ritorno. Dove nomina un traguardo successivo, quel
  /// traguardo diventa visibile in anticipo; dove nomina una funzione, il
  /// traguardo raggiunto ci porta con un tocco; dove nomina un momento della
  /// giornata, il richiamo arriva in quel momento.
  final String cosaApre;

  /// Identificativo stabile: entra nel salvataggio del progresso, quindi
  /// cambiarlo vuol dire far ricominciare qualcuno da capo.
  final String id;

  /// Il nome proprio del traguardo, quello che si legge sul sentiero.
  final String nome;

  final FamigliaDelTraguardo famiglia;
  final CondizioneDelTraguardo condizione;

  /// LA FRASE WOW, nel tono del Maestro del sentiero.
  ///
  /// Deve NOMINARE il traguardo che festeggia: "Congratulazioni" da solo e' un
  /// difetto, e una prova lo cerca. Una frase che vale per tutti non festeggia
  /// nessuno.
  final String frase;

  /// La posizione sul sentiero, da 1 a 50 per i mini. I grandi stanno a 10,
  /// 20, 30, 40 e 50 e portano la posizione del mini che chiudono.
  final int posizione;

  /// SE E' UN GRANDE, e lo dice il dato, non la posizione.
  ///
  /// **Perche' un campo e non un calcolo.** La prima stesura ricavava
  /// "e' grande" dal fatto che la posizione fosse 10, 20, 30, 40 o 50: cosi'
  /// i cinque traguardi PICCOLI che stanno su quelle posizioni venivano
  /// scambiati per grandi, sparivano dai cinquanta e prendevano il premio
  /// sbagliato. Lo ha trovato la prova, che contava 45 piccoli e 1.480 Eos di
  /// troppo. La posizione resta sorvegliata da una prova: un grande fuori
  /// dalle cinque posizioni non entra.
  final bool eGrande;

  /// **GLI EOS VENGONO DAL DATO, ordine AR voce 02.** Prima si ricavavano
  /// dalla grandezza; adesso ogni voce porta il suo numero, e la somma per
  /// sentiero (2.010) e' una pretesa della guardia.
  final int eos;

  /// La fascia del cammino a cui appartiene: Primi giorni, Prima settimana,
  /// Primo mese, La stagione, L'anno.
  final String fascia;

  /// **UN DORMIENTE E' DICHIARATO, non finto. Ordine AR voce 05.** Chiede un
  /// gesto che oggi non esiste o un dettaglio che nessuna scena manda: resta
  /// nel dato, non arma mai, non accredita mai, e il Journal lo mostra come
  /// in arrivo.
  final bool dormiente;

  /// **LE POSIZIONI DEI GRANDI VENGONO DAL CORPUS, ordine AR voce 02.** Nella
  /// revisione C chiudono le decine da dentro l'unica fila che esiste: 11, 22,
  /// 33, 44 e 55. Prima erano 10, 20, 30, 40 e 50 su una fila di soli mini, e
  /// i due elenchi si sovrapponevano.
  static const List<int> posizioniDeiGrandi = [11, 22, 33, 44, 55];

  /// LA CURVA DEGLI EOS, decisa da Mauro e scritta in un punto solo.
  ///
  /// I primi tre mini valgono venti invece di dieci: il primo premio deve
  /// arrivare presto e sembrare generoso, altrimenti il cammino non comincia.
  /// I cinque grandi salgono 80, 150, 250, 400, 600, cosi' la distanza fra un
  /// grande e l'altro si sente.

  /// **GLI EOS NON SI CALCOLANO PIU', VENGONO DAL DATO. Ordine AR voce 02.**
  ///
  /// Qui c'era una formula (venti ai primi tre, dieci agli altri, la scala
  /// dei grandi) che diceva quanto vale un traguardo. Adesso lo dice il
  /// corpus, voce per voce, e la somma per sentiero e' una pretesa della
  /// guardia: 2.010 per sentiero, 6.030 in tutto. Una formula e un dato che
  /// dicono la stessa cosa sono due verita' che un giorno divergono.
  static const List<int> eosDeiGrandiStorici = [80, 150, 250, 400, 600];
}

/// LO STATO DEL CAMMINO: la fotografia su cui si misurano i traguardi.
///
/// **Perche' una fotografia e non tanti controlli sparsi.** Un traguardo deve
/// essere una funzione pura di cio' che e' successo: cosi' si prova senza
/// montare l'app, si valuta tutto in un colpo solo quando qualcosa cambia, e
/// non esiste il caso in cui due traguardi guardano la stessa cosa in due modi
/// diversi. Chi costruisce questa fotografia e' `DiarioDelCammino`, che e' il
/// solo posto che sa leggere il disco e il cielo.
class StatoDelCammino {
  const StatoDelCammino({
    this.gestiCompiuti = const {},
    this.giorniConGesto = const {},
    this.oggiHaFatto = const {},
    this.seriePerRito = const {},
    this.gestiNellOraGiusta = const {},
    this.eventiDelCieloDiOggi = const {},
    this.pezziDellIdentita = const {},
    this.memoria = const {},
    this.giorniDiAssenzaPrimaDiOggi = 0,
    this.giorniDalPrimoGiorno = 0,
    this.valoriDistinti = const {},
    this.massimeRipetizioni = const {},
    this.gradiniAlleSpalle = const {},
  });

  /// Quante volte un gesto e' stato compiuto, da sempre.
  final Map<String, int> gestiCompiuti;

  /// In quanti giorni DIVERSI un gesto e' stato compiuto.
  final Map<String, int> giorniConGesto;

  /// I gesti compiuti oggi.
  final Set<String> oggiHaFatto;

  /// La continuita' corrente per rito.
  final Map<String, int> seriePerRito;

  /// Quante volte un gesto e' caduto nella sua ora rituale.
  final Map<String, int> gestiNellOraGiusta;

  /// Gli eventi del cielo veri di oggi, dal catalogo `EventiDelCielo`.
  final Set<String> eventiDelCieloDiOggi;

  /// I pezzi dell'identita' gia' completi.
  final Set<String> pezziDellIdentita;

  /// I numeri della memoria: momenti, fatti, riprese, riletture, temi.
  final Map<String, int> memoria;

  /// Quanti giorni di silenzio ci sono stati prima di oggi.
  final int giorniDiAssenzaPrimaDiOggi;

  /// Da quanti giorni questa persona e' nel Cerchio.
  final int giorniDalPrimoGiorno;

  /// **LA VARIETA', ordine AR voce 11.** Per `gesto.chiave`, quanti valori
  /// DIVERSI si sono visti: quattro semi, sedici argomenti, ventiquattro
  /// rune. Senza i dettagli del gesto questa mappa resta vuota e nessuna
  /// condizione di profondita' puo' maturare, che e' il modo giusto di non
  /// maturare.
  final Map<String, int> valoriDistinti;

  /// **LA COINCIDENZA, ordine AR voce 11.** Per `gesto.chiave`, quante volte
  /// e' tornato il valore piu' insistente: la stessa carta in due stese.
  final Map<String, int> massimeRipetizioni;

  /// **LA SCALA, ordine AR voce 03.** Per sentiero, quanti gradini sono gia'
  /// alle spalle: e' cio' su cui poggiano i traguardi di Dedizione, che si
  /// accendono col primo gesto di quel Maestro DOPO l'ennesimo gradino.
  final Map<String, int> gradiniAlleSpalle;
}
