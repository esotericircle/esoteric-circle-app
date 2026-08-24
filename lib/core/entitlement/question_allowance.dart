import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'plan_catalog.dart';
import '../cammino/cammino_da_custodire.dart';
import '../../services/server/porta_del_cerchio.dart';
import '../tempo/confine_del_giorno.dart';
import 'tier.dart';

/// Contatore locale delle domande ai Maestri, per tier.
///
/// Il limite giornaliero di risposte Breve a un Maestro segue la mappa dei
/// piani: Viandante 3, Iniziato 5, Adepto 10, Illuminato illimitate. Le tre del
/// Free sono spendibili anche su Maestri diversi. Il conteggio si azzera al
/// cambio di giorno. Il confronto a piu' Maestri (sintesi comparativa) resta
/// riservato al Tier a pagamento.
///
/// L'orologio e' iniettabile per i test; la persistenza e' best effort su
/// `SharedPreferences`, senza crash se non e' disponibile.
class QuestionAllowance extends ChangeNotifier {
  QuestionAllowance({
    DateTime Function()? clock,
    this.freeDailyLimit,
    PortaDelCerchio porta = const PortaSpentaDelCerchio(),
  })  : _clock = clock ?? DateTime.now,
        _porta = porta;

  final DateTime Function() _clock;

  /// LA PORTA DEL SERVER, ordine N voce 2c.
  final PortaDelCerchio _porta;

  /// IL GIORNO LO DICE IL SERVER, e finche' lo dice l'orologio del telefono
  /// non conta piu' niente.
  ///
  /// **Perche'.** Fino a oggi il giorno nasceva da `DateTime.now()`: spostando
  /// l'ora del telefono avanti di un giorno tutti e quattro i budget tornavano
  /// interi, verificato eseguendo. Adesso questa stringa arriva dal server ed
  /// e' OPACA: non si ricalcola e non si interpreta, si confronta. Resta nulla
  /// solo finche' il server non ha mai risposto, e in quel caso vale il
  /// ripiego locale, che e' meglio di un'app che non conta niente.
  String? _giornoDelServer;

  /// IL SALDO EOS, che il client non scrive mai: lo legge e lo mostra.
  int _saldoEos = 0;
  int get saldoEos => _saldoEos;

  /// **QUANTI EOS VALE OGNI MODO DI CONDIVIDERE, detto dal server.**
  /// Ordine BB voce 04.
  ///
  /// **Vuoto finche' il server non ha parlato**, e chi lo legge deve reggere
  /// il vuoto: il pulsante dice quando arriva il premio anche senza dire
  /// quanto. **Mai un numero di ripiego scritto nel client**: se il listino
  /// cambiasse sul server, un ripiego resterebbe a promettere il vecchio.
  Map<String, int> _listinoDellaCondivisione = const {};
  Map<String, int> get listinoDellaCondivisione => _listinoDellaCondivisione;

  /// Quanti Eos vale quel modo, oppure nullo se il server non lo ha ancora
  /// detto.
  int? eosPerLaCondivisione(String motivo) =>
      _listinoDellaCondivisione[motivo];

  int _condivisioniPremiateOggi = 0;

  /// **SE UNA CONDIVISIONE, ADESSO, VERREBBE PREMIATA.** Ordine BG voce 04:
  /// oltre il tetto del giorno il server non paga, e il pulsante non deve
  /// promettere. Il conto arriva dal server con lo stato; chi paga davvero
  /// resta il server, questo e' solo il permesso di promettere.
  bool get condivisioneAncoraPremiata =>
      _condivisioniPremiateOggi < tettoCondivisioniPremiate;

  /// Il tetto anti farming del server, dichiarato qui per il pulsante. La
  /// prova del sistema anti abuso tiene allineato questo numero al suo.
  static const int tettoCondivisioniPremiate = 3;

  /// Registra che il server ha appena premiato una condivisione: il conto
  /// locale segue, senza aspettare la prossima sincronia.
  void condivisionePremiata() {
    _condivisioniPremiateOggi++;
    notifyListeners();
  }

  /// **QUANDO QUALCUNO ESCE, I SUOI NUMERI NON RESTANO A SCHERMO.**
  /// Ordine AZ voce 15.
  ///
  /// **Il disco non basta.** Uscire cancella le chiavi delle preferenze, ma
  /// questo oggetto vive in memoria per tutta la sessione: senza questa riga
  /// il saldo di chi se ne e' andato **resterebbe in barra** davanti a chi
  /// arriva dopo, fino al riavvio dell'app. Su un telefono prestato e' il
  /// saldo di un altro; su un telefono proprio e' un numero che non torna.
  ///
  /// Non si tocca il server: qui si dimentica soltanto cio' che si ricorda.
  void dimenticaChiSeNeVa() {
    _saldoEos = 0;
    _count = 0;
    _approfondimenti = 0;
    _confronti = 0;
    _gettate = 0;
    _giornoDelServer = null;
    _daMandare.clear();
    notifyListeners();
  }

  /// I GESTI CHE IL SERVER NON HA ANCORA PRESO, ordine N voce 2e.
  ///
  /// Senza rete il gesto si compie lo stesso e si segna qui col suo
  /// identificativo: al ritorno partono tutti, e il server li conta una volta
  /// sola perche' l'identificativo e' la sua garanzia. Se nel frattempo il
  /// budget era finito, al ritorno il server dice di no e il conto locale si
  /// allinea al suo: **in caso di disaccordo vince sempre il server**, anche
  /// quando la risposta e' "hai gia' finito".
  final List<Map<String, String>> _daMandare = [];

  int get gestiInAttesa => _daMandare.length;

  /// Vero se i numeri che si stanno mostrando vengono dal server.
  bool get dalServer => _giornoDelServer != null;

  /// Un limite imposto dall'esterno, solo per i test: nell'app resta nullo e
  /// il numero arriva dalla matrice.
  final int? freeDailyLimit;

  /// Il limite giornaliero per tier, oppure null se illimitato.
  ///
  /// LO LEGGE DALLA MATRICE dei piani, che e' la fonte di cio' che si promette
  /// alla persona. Prima i numeri erano scritti qui: la matrice prometteva al
  /// Viandante una domanda al giorno e questo file ne concedeva tre, quindi la
  /// promessa e l'imposizione erano due cose diverse, e a rimetterci era solo
  /// una delle due parti.
  int? dailyLimit(Tier tier) {
    if (tier == Tier.free && freeDailyLimit != null) return freeDailyLimit;
    return PlanCatalog.limiteGiornaliero(PlanCatalog.rigaDomande, tier);
  }

  /// Il limite giornaliero degli APPROFONDIMENTI, cioe' di quante volte si puo'
  /// chiedere "Vai più a fondo" sulla stessa risposta.
  ///
  /// E' un budget diverso da quello delle domande, e vive nella stessa classe
  /// apposta: il giorno e' lo stesso, quindi il ribaltamento a mezzanotte deve
  /// essere lo stesso. Due classi avrebbero avuto due rollover, e due rollover
  /// prima o poi divergono.
  ///
  /// **L'approfondimento non consuma una domanda.** Se la consumasse, la
  /// persona esiterebbe prima di toccarlo, e l'esitazione uccide l'intimita'.
  int? limiteApprofondimenti(Tier tier) =>
      PlanCatalog.limiteGiornaliero(PlanCatalog.rigaApprofondimenti, tier);

  /// Il tetto di CORRETTEZZA per chi non ha limite: non e' una restrizione
  /// commerciale, e' la difesa contro un tocco ripetuto per sbaglio o per
  /// gioco. Chi arriva qui in un giorno solo non sta piu' leggendo.
  static const int kTettoDiCorrettezza = 30;

  /// Quanti approfondimenti restano oggi.
  int approfondimentiRimasti(Tier tier) {
    _rollover();
    final limite = limiteApprofondimenti(tier);
    if (limite == null) {
      final left = kTettoDiCorrettezza - _approfondimenti;
      return left < 0 ? 0 : left;
    }
    final left = limite - _approfondimenti;
    return left < 0 ? 0 : left;
  }

  /// Vero se questo piano prevede l'approfondimento, a prescindere da quanti ne
  /// restano oggi. Serve alla UI per distinguere DUE cose che non vanno
  /// confuse: chi non ce l'ha nel piano riceve l'invito a salire, chi ce l'ha e
  /// li ha finiti riceve il numero vero e l'ora in cui torna.
  bool pianoConApprofondimento(Tier tier) {
    final limite = limiteApprofondimenti(tier);
    return limite == null || limite > 0;
  }

  /// Se si puo' approfondire adesso.
  ///
  /// **IL CREDITO DEL RISCATTO VALE ANCHE FUORI DAL PIANO, ordine BG voce
  /// 05.** Sul piano che non porta approfondimenti il limite e' zero e i
  /// rimasti sono zero; chi RISCATTA un uso con gli Eos porta il contatore
  /// sotto zero e i rimasti a uno: il cancello guarda i rimasti, non il
  /// piano, cosi' l'uso comprato si puo' spendere davvero.
  bool puoiApprofondire(Tier tier) => approfondimentiRimasti(tier) > 0;

  /// Registra un approfondimento consumato. Anche i tier senza limite lo
  /// contano, perche' il tetto di correttezza vale per tutti.
  void registraApprofondimento(Tier tier) {
    // Niente ritorno anticipato sul piano senza approfondimenti: chi arriva
    // qui fuori piano ci arriva con un credito riscattato, e il credito si
    // consuma contandolo (da -1 a 0), o sarebbe infinito. Ordine BG voce 05.
    _rollover();
    _approfondimenti++;
    notifyListeners();
    _persist();
    _chiediAlServer('approfondimenti');
  }

  static const _kDay = 'allowance.day';
  static const _kCount = 'allowance.count';
  static const _kApprofondimenti = 'allowance.approfondimenti';
  static const _kConfronti = 'allowance.confronti';
  static const _kGettate = 'allowance.gettate';
  static const _kGiornoDelServer = 'allowance.giornoDelServer';
  static const _kCoda = 'allowance.coda';
  static const _kSaldo = 'allowance.saldoEos';

  int _count = 0;
  int _approfondimenti = 0;
  int _confronti = 0;
  int _gettate = 0;
  String _day = '';

  /// Il giorno d'uso, dal punto SOLO in cui e' definito.
  ///
  /// Era scritto qui dentro, e quando l'Eco ha avuto bisogno dello stesso
  /// confine copiarlo avrebbe voluto dire due definizioni dello stesso giorno
  /// che devono restare d'accordo. Vedi `ConfineDelGiorno`, dove sta anche la
  /// ragione per cui il confine RITUALE, a mezzogiorno, e' un'altra cosa.
  String _today() =>
      _giornoDelServer ?? ConfineDelGiorno.chiaveDi(_clock());

  // Se e' cambiato il giorno, azzera il conteggio.
  void _rollover() {
    final t = _today();
    if (t != _day) {
      _day = t;
      _count = 0;
      // I QUATTRO budget ribaltano INSIEME, perche' il giorno e' lo stesso.
      //
      // Un secondo confine del giorno accanto a questo divergerebbe alla prima
      // ora legale: `ConfineDelGiorno` e' uno, e questi contatori lo
      // guardano tutti da qui. Le gettate di rune stanno qui per lo stesso
      // motivo, ordine I voce 3: il reset e' quello gia' in uso, non un
      // contatore nuovo con un giorno suo.
      _approfondimenti = 0;
      _confronti = 0;
      _gettate = 0;
    }
  }

  /// Domande consumate oggi.
  int usedToday() {
    _rollover();
    return _count;
  }

  /// Domande singole ancora disponibili oggi. Per un tier illimitato restituisce
  /// un numero molto alto.
  int remaining(Tier tier) {
    final limit = dailyLimit(tier);
    if (limit == null) return 1 << 30;
    _rollover();
    final left = limit - _count;
    return left < 0 ? 0 : left;
  }

  /// Se l'utente puo' porre un'altra domanda singola adesso.
  bool canAsk(Tier tier) {
    final limit = dailyLimit(tier);
    if (limit == null) return true;
    _rollover();
    return _count < limit;
  }

  /// Se il PIANO comprende il confronto a piu' Maestri.
  ///
  /// **Adesso lo legge dalla matrice, e prima lo decideva da solo.** Diceva
  /// `tier != Tier.free`, cioe' era un secondo posto dove si stabiliva chi
  /// puo' cosa, accanto a quello vero. Un secondo sistema diverge sempre dal
  /// primo, ed e' la stessa correzione gia' fatta per la memoria dei Maestri.
  bool canCompare(Tier tier) =>
      PlanCatalog.limiteGiornaliero(PlanCatalog.rigaConfronti, tier) != 0;

  /// Quanti confronti al giorno prevede il piano, oppure null se illimitato.
  int? limiteConfronti(Tier tier) =>
      PlanCatalog.limiteGiornaliero(PlanCatalog.rigaConfronti, tier);

  /// Quanti confronti restano oggi.
  ///
  /// **Perche' esiste un tetto separato.** Un confronto non consuma domande in
  /// piu' di quella gia' pagata nella chat, ed e' misurato: aprendo il
  /// Consiglio dalla conversazione le altre due letture arrivano senza
  /// contare, quindi il numero e' zero e non tre. Senza un tetto suo il gesto
  /// sarebbe gratuito e ripetibile all'infinito, mentre ogni tocco sono due
  /// chiamate al modello.
  int confrontiRimasti(Tier tier) {
    _rollover();
    final limite = limiteConfronti(tier);
    if (limite == null) {
      final resta = kTettoDiCorrettezza - _confronti;
      return resta < 0 ? 0 : resta;
    }
    final resta = limite - _confronti;
    return resta < 0 ? 0 : resta;
  }

  /// Se si puo' fare un altro confronto adesso.
  ///
  /// Come per gli approfondimenti: il cancello guarda i rimasti e non il
  /// piano, cosi' il credito riscattato con gli Eos si spende davvero.
  /// Ordine BG voce 05.
  bool puoiConfrontare(Tier tier) => confrontiRimasti(tier) > 0;

  /// Registra un confronto consumato.
  void registraConfronto(Tier tier) {
    // Come sopra: il credito fuori piano si consuma contandolo. BG voce 05.
    _rollover();
    _confronti++;
    notifyListeners();
    _persist();
    _chiediAlServer('confronti');
  }

  /// COME SI DICE IL RESIDUO, prima del tocco.
  ///
  /// **La formula unica era sgrammaticata, e il commento che la difendeva
  /// diceva il falso.** C'era scritto che "Oggi te ne resta 1 su 3" vale per
  /// uno come per tre, quindi non c'era nessun plurale da dimenticare. Non e'
  /// cosi': "te ne resta" concorda con UNO, e con tre ci vuole "te ne
  /// restano". Nell'anteprima della build 2148 si leggeva "Oggi te ne resta 3
  /// su 3", che e' un errore di italiano nella riga che dice a una persona
  /// quanto le rimane. Evitare l'accordo non lo aveva reso invisibile: lo
  /// aveva reso sempre sbagliato tranne quando il numero era uno.
  ///
  /// Le tre forme, e sono tre perche' l'italiano ne chiede tre:
  ///
  /// - zero, e non e' un residuo ma la fine: "Oggi non te ne resta nessuno";
  /// - uno: "Oggi te ne resta 1 su 3";
  /// - due o piu': "Oggi te ne restano 3 su 3".
  ///
  /// Nullo quando non c'e' un numero da dire: senza il piano non e' un
  /// residuo, e' un lucchetto, e lo dice la porta. Senza limite non e' un
  /// residuo, e' un cammino senza conto da tenere.
  String? residuoDeiConfronti(Tier tier) {
    if (!canCompare(tier)) return null;
    final limite = limiteConfronti(tier);
    if (limite == null) return null;
    return comeSiDiceIlResiduo(confrontiRimasti(tier), limite);
  }

  /// L'ACCORDO, in un posto solo.
  ///
  /// Sta fuori da [residuoDeiConfronti] perche' la prova che lo sorveglia deve
  /// poter chiedere lo zero, l'uno e il molti senza dover prima costruire tre
  /// contatori in tre stati diversi: la regola della lingua e' questa
  /// funzione, e si guarda da sola.
  static String comeSiDiceIlResiduo(int quanti, int limite) {
    if (quanti <= 0) return 'Oggi non te ne resta nessuno';
    if (quanti == 1) return 'Oggi te ne resta 1 su $limite';
    return 'Oggi te ne restano $quanti su $limite';
  }

  /// **LA STESSA COSA, DETTA COME LA DIREBBE UNA PERSONA.** Ordine BB voce 02.
  ///
  /// **Il fondatore l'ha letta e non gli e' suonata bene**: "Oggi te ne
  /// restano 3 su 3 domande ai Maestri" mette il numero prima della cosa che
  /// conta, e chi legge deve tornare indietro per capire di cosa si parla.
  /// Parole sue: "l'italiano non e' il massimo, dovrebbe esserci scritto ti
  /// restano 3 su 3 domande ai Maestri".
  ///
  /// **Qui la cosa viene prima del conto**, e l'"oggi" va in coda, dove fa da
  /// promemoria invece che da premessa: "Ti restano 3 domande su 3, oggi."
  ///
  /// **La vecchia forma resta e non e' un doppione**: la usa chi nomina la
  /// cosa da un'altra parte, per esempio accanto a un'icona che gia' dice di
  /// cosa si tratta. Questa serve dove la cosa va detta nella frase.
  /// **[uno] e' come si chiama UNA di quelle cose, [molti] come se ne
  /// chiamano tante, e [femminile] serve al "nessuna".**
  ///
  /// **Tre argomenti e non uno, e la prova ha spiegato perche'.** La prima
  /// stesura ne prendeva uno solo e produceva "Non ti resta nessun domanda",
  /// "Non ti resta nessun approfondimenti" e "Ti resta 1 gettate di rune su
  /// 1": **il numero era giusto e la frase era rotta in tre modi diversi**.
  /// Una lingua che si accorda da sola non esiste: o si dichiara come si
  /// declina, o si scrive male.
  static String residuoDiCosa(
    int quanti,
    int limite, {
    required String uno,
    required String molti,
    bool femminile = false,
  }) {
    if (quanti <= 0) {
      return 'Non ti resta ${femminile ? 'nessuna' : 'nessun'} $uno, oggi';
    }
    if (quanti == 1) return 'Ti resta 1 $uno su $limite, oggi';
    return 'Ti restano $quanti $molti su $limite, oggi';
  }

  /// Quante gettate di rune al giorno prevede il piano, oppure null se
  /// illimitate. Il numero sta nella matrice, riga [PlanCatalog.rigaGettate].
  int? limiteGettate(Tier tier) =>
      PlanCatalog.limiteGiornaliero(PlanCatalog.rigaGettate, tier);

  /// Quante gettate restano oggi, oppure null se sono illimitate.
  int? gettateRimaste(Tier tier) {
    final limite = limiteGettate(tier);
    if (limite == null) return null;
    _rollover();
    final resta = limite - _gettate;
    return resta < 0 ? 0 : resta;
  }

  /// Se si puo' gettare adesso. La gettata e' un calcolo locale, quindi per
  /// chi non ha limite non serve nemmeno il tetto di correttezza: non c'e'
  /// nessun modello da difendere da un tocco ripetuto.
  bool puoiGettare(Tier tier) {
    final resta = gettateRimaste(tier);
    return resta == null || resta > 0;
  }

  /// Registra una gettata consumata. Chi ha l'illimitato non intacca niente.
  void registraGettata(Tier tier) {
    if (limiteGettate(tier) == null) return;
    _rollover();
    _gettate++;
    notifyListeners();
    _persist();
    _chiediAlServer('gettate');
  }

  /// Registra una domanda consumata. I tier con un limite finito intaccano il
  /// contatore; quello illimitato no.
  void record(Tier tier) {
    if (dailyLimit(tier) == null) return;
    _rollover();
    _count++;
    notifyListeners();
    _persist();
    _chiediAlServer('domande');
  }

  /// Carica il conteggio salvato, best effort.
  ///
  /// Il conto locale e' una COPIA di cio' che il server sa, non la verita': la
  /// verita' arriva con [sincronizza], e quello che c'e' qui serve a non
  /// restare senza numeri prima che la rete risponda e a non perdere i gesti
  /// compiuti offline.
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _day = prefs.getString(_kDay) ?? '';
      _count = prefs.getInt(_kCount) ?? 0;
      _approfondimenti = prefs.getInt(_kApprofondimenti) ?? 0;
      _confronti = prefs.getInt(_kConfronti) ?? 0;
      _gettate = prefs.getInt(_kGettate) ?? 0;
      _giornoDelServer = prefs.getString(_kGiornoDelServer);
      _saldoEos = prefs.getInt(_kSaldo) ?? 0;
      _daMandare
        ..clear()
        ..addAll(_codaDaTesto(prefs.getString(_kCoda)));
      _rollover();
      notifyListeners();
    } catch (_) {
      // Nessuna persistenza: si resta sui valori in memoria.
    }
  }

  /// APPLICA UN SALDO CHE IL SERVER HA GIA' DETTO. Ordine S voce 04.
  ///
  /// **Perche' esiste, ed e' la meta' del difetto del borsellino a zero.** Chi
  /// accredita un premio riceve dal server il saldo nuovo nella risposta: e' la
  /// verita', ed e' gia' in mano. Prima quel numero veniva buttato e si chiamava
  /// [sincronizza], cioe' si chiedeva al server TUTTO lo stato con una seconda
  /// chiamata: se quella non rispondeva, il saldo a schermo restava quello
  /// vecchio anche se l'accredito era andato a buon fine. La persona vedeva
  /// "+10 Eos" nella festa e zero in barra.
  ///
  /// Non sostituisce [sincronizza], che resta la verita' periodica su tutto lo
  /// stato del giorno: questa applica UN dato che si conosce, subito.
  Future<void> applicaSaldo(int saldo) async {
    if (saldo == _saldoEos) return;
    _saldoEos = saldo;
    notifyListeners();
    await _persist();
  }

  /// CHIEDE AL SERVER COM'E' MESSO IL GIORNO, e si allinea a cio' che dice.
  ///
  /// Si chiama all'avvio e al ritorno in primo piano. Se il server non
  /// risponde non cambia niente: si resta sui numeri locali, che e' la scelta
  /// dichiarata per l'assenza di rete.
  /// [cammino] e' cio' che questo telefono ha da custodire, ordine AP voce
  /// 02: viaggia con la richiesta dello stato invece di aprire un secondo
  /// canale sullo stesso momento. Torna il cammino che il Cerchio ha fuso,
  /// oppure nullo se il server non ha risposto o non lo conosce ancora.
  Future<CamminoDaCustodire?> sincronizza(
      {CamminoDaCustodire? cammino, bool azzeraIlCammino = false}) async {
    await _svuotaLaCoda();
    final stato =
        await _porta.stato(cammino: cammino, azzeraIlCammino: azzeraIlCammino);
    // **SENZA RISPOSTA NON SI TOCCA NIENTE**: si resta sui numeri locali, che
    // e' la scelta dichiarata per l'assenza di rete, e non si cancella
    // nessuna storia.
    if (stato == null) return null;
    _giornoDelServer = stato.giorno;
    if (_day != stato.giorno) _day = stato.giorno;
    _count = stato.spesi['domande'] ?? 0;
    // Ordine BG voce 04: quante condivisioni premiate sono gia' state
    // pagate oggi. Serve al pulsante, per non promettere un bonus che il
    // tetto anti farming non pagherebbe.
    _condivisioniPremiateOggi = stato.spesi['condivisioni_premiate'] ?? 0;
    _approfondimenti = stato.spesi['approfondimenti'] ?? 0;
    _confronti = stato.spesi['confronti'] ?? 0;
    _gettate = stato.spesi['gettate'] ?? 0;
    _saldoEos = stato.saldoEos;
    // **IL LISTINO DELLA CONDIVISIONE, cosi' come il server lo dichiara.**
    // Ordine BB voce 04. Vive qui perche' qui vive gia' tutto cio' che il
    // Cerchio dice sul denaro: una seconda casa per tre numeri sarebbe la
    // seconda porta sullo stesso dato.
    //
    // **Si sostituisce solo se il server lo ha mandato**: un server piu'
    // vecchio dell'app non deve cancellare quello che si sa gia'.
    if (stato.listinoDellaCondivisione.isNotEmpty) {
      _listinoDellaCondivisione = stato.listinoDellaCondivisione;
    }
    // **LA DOTE RACCONTA LA SUA STORIA, ordine BF voce 01.** Gli accrediti
    // che il server ha compiuto in questa chiamata si mettono da parte per
    // chi tiene il registro dei movimenti: questo servizio non conosce i
    // provider dell'albero, e pretenderli da qui fu il difetto che fece
    // cadere quaranta prove altrove.
    if (stato.accreditati.isNotEmpty) {
      _accreditiDaRaccontare.addAll(stato.accreditati);
    }
    // **IL LISTINO DEL RISCATTO, come quello della condivisione**: si
    // sostituisce solo se il server lo ha mandato. Ordine BG voce 05.
    if (stato.listinoDelRiscatto.isNotEmpty) {
      _listinoDelRiscatto = stato.listinoDelRiscatto;
    }
    // **SE IL BENVENUTO E' DI QUESTA CHIAMATA, IL CERCHIO E' APPENA NATO.**
    // Ordine BG voce 01: il fondatore e' entrato con "Faccio gia' parte del
    // Cerchio" su un account cancellato, Google ne ha creato uno nuovo in
    // silenzio (coi provider federati non esiste "email gia' in uso"), e la
    // scena del ritrovamento gli ha dato il Bentornato mostrando la dote di
    // nascita come cosa tenuta. Il benvenuto si accredita UNA volta nella
    // vita di un Cerchio: se e' arrivato adesso, questo Cerchio e' nato
    // adesso, e nessuno deve dirgli bentornato.
    _cerchioAppenaNato =
        stato.accreditati.any((a) => a.motivo == 'benvenuto');
    notifyListeners();
    await _persist();
    return stato.cammino;
  }

  final List<AccreditoDellaDote> _accreditiDaRaccontare = [];

  bool _cerchioAppenaNato = false;

  /// **IL LISTINO DEL RISCATTO, detto dal server.** Ordine BG voce 05.
  Map<String, int> _listinoDelRiscatto = const {};

  /// Quanto costa riscattare un uso di quel budget, oppure nullo se il
  /// server non lo ha ancora detto: senza prezzo non si promette niente.
  int? prezzoDelRiscatto(String budget) => _listinoDelRiscatto[budget];

  /// **COMPRA UN USO DI UN BUDGET FINITO, spendendo Eos.** Ordine BG voce
  /// 05: e' la strada degli Eos del gating a due strade. Il PREZZO lo
  /// decide il server (il numero passato qui e' solo dichiarativo), e nella
  /// stessa transazione il server scala il contatore del giorno: al ritorno
  /// il gesto si puo' rifare subito. Torna il prezzo pagato, oppure nullo
  /// se non si e' pagato niente (saldo corto, server muto, prezzo ignoto):
  /// chi chiama decide cosa dire, ma nessuno paga due volte perche' ogni
  /// movimento porta il suo identificativo.
  Future<int?> riscatta(String budget) async {
    final prezzo = _listinoDelRiscatto[budget];
    if (prezzo == null || !_porta.viva) return null;
    if (_saldoEos < prezzo) return null;
    final saldo = await _porta.muoviGliEos(
      causale: 'spesa',
      motivo: 'riscatto_$budget',
      idMovimento: PortaDelCerchio.nuovoIdentificativo('riscatto-$budget'),
      quanti: prezzo,
    );
    if (saldo == null) return null;
    _saldoEos = saldo;
    // Il contatore locale segue quello del server, che e' appena sceso di
    // uno nella stessa transazione del saldo: puo' andare sotto zero, ed e'
    // il credito comprato in anticipo sul proprio limite.
    switch (budget) {
      case 'domande':
        _count--;
      case 'approfondimenti':
        _approfondimenti--;
      case 'confronti':
        _confronti--;
      case 'gettate':
        _gettate--;
    }
    notifyListeners();
    await _persist();
    return prezzo;
  }

  /// Vero se l'ULTIMA sincronia ha accreditato il benvenuto: il Cerchio di
  /// questa persona e' nato in quella chiamata, non e' un ritorno.
  bool get cerchioAppenaNato => _cerchioAppenaNato;

  /// Gli accrediti del server non ancora scritti nel registro dei movimenti.
  /// Chi li prende se li porta via: e' una consegna, non una lettura, cosi'
  /// nessun accredito viene raccontato due volte.
  List<AccreditoDellaDote> prendiGliAccreditiDaRaccontare() {
    final presi = List<AccreditoDellaDote>.unmodifiable(_accreditiDaRaccontare);
    _accreditiDaRaccontare.clear();
    return presi;
  }

  /// Segna il gesto per il server e prova a mandarlo subito.
  void _chiediAlServer(String budget) {
    if (!_porta.viva) return;
    _daMandare.add({
      'budget': budget,
      'id': PortaDelCerchio.nuovoIdentificativo('$_day-$budget'),
    });
    _persist();
    _svuotaLaCoda();
  }

  /// Manda i gesti in attesa, uno alla volta e in ordine. Al primo che non
  /// passa ci si ferma: la coda tiene l'ordine dei gesti, e mandarne uno
  /// fuori ordine cambierebbe chi ha esaurito cosa.
  /// UNA SVUOTATA PER VOLTA, e non e' prudenza eccessiva: due gesti di
  /// seguito ne avviavano due, e la seconda toglieva dalla coda un elemento
  /// che la prima aveva gia' tolto. Trovato dalla prova, non ragionato.
  bool _stoSvuotando = false;

  Future<void> _svuotaLaCoda() async {
    if (!_porta.viva || _stoSvuotando) return;
    _stoSvuotando = true;
    try {
      await _svuotaDavvero();
    } finally {
      _stoSvuotando = false;
    }
  }

  Future<void> _svuotaDavvero() async {
    while (_daMandare.isNotEmpty) {
      final primo = _daMandare.first;
      final esito = await _porta.consuma(
        budget: primo['budget']!,
        idMovimento: primo['id']!,
      );
      if (esito == null) return;
      _daMandare.removeAt(0);
      if (!esito.concesso) {
        // IL SERVER HA DETTO DI NO: il conto locale si allinea a lui, anche
        // se vuol dire togliere qualcosa che il telefono si era gia' preso.
        await _allineaAlNo(primo['budget']!);
      }
    }
    await _persist();
  }

  Future<void> _allineaAlNo(String budget) async {
    switch (budget) {
      case 'domande':
        _count = 1 << 20;
      case 'approfondimenti':
        _approfondimenti = 1 << 20;
      case 'confronti':
        _confronti = 1 << 20;
      case 'gettate':
        _gettate = 1 << 20;
    }
    notifyListeners();
  }

  static List<Map<String, String>> _codaDaTesto(String? testo) {
    if (testo == null || testo.isEmpty) return const [];
    try {
      final letta = jsonDecode(testo);
      if (letta is! List) return const [];
      return [
        for (final voce in letta)
          if (voce is Map && voce['budget'] is String && voce['id'] is String)
            {'budget': '${voce['budget']}', 'id': '${voce['id']}'},
      ];
    } catch (errore) {
      // Si ignora: una coda illeggibile (preferenze corrotte, formato
      // vecchio) vale come coda vuota. Il conto vero e' quello del server, e
      // alla prima sincronia torna tutto a posto.
      return const [];
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kDay, _day);
      await prefs.setInt(_kCount, _count);
      await prefs.setInt(_kApprofondimenti, _approfondimenti);
      await prefs.setInt(_kConfronti, _confronti);
      await prefs.setInt(_kGettate, _gettate);
      await prefs.setInt(_kSaldo, _saldoEos);
      await prefs.setString(_kCoda, jsonEncode(_daMandare));
      if (_giornoDelServer != null) {
        await prefs.setString(_kGiornoDelServer, _giornoDelServer!);
      }
    } catch (_) {
      // Best effort.
    }
  }
}
