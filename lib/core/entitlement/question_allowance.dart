import 'dart:convert';

import 'il_consenso_della_spesa.dart';
import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'plan_catalog.dart';
import '../cammino/cammino_da_custodire.dart';
import '../../services/ai/registro_dei_guasti.dart';
import '../../services/server/porta_del_cerchio.dart';
import '../tempo/confine_del_giorno.dart';
import 'budget_del_giorno.dart';
import 'tier.dart';
import '../synastry/vip_catalog.dart';
import '../sigilli/bonus_della_condivisione.dart';

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
    this.quandoIlServerDiceIlPiano,
  })  : _clock = clock ?? DateTime.now,
        _porta = porta;

  /// **DOVE VA A FINIRE IL PIANO CHE IL SERVER DICHIARA.** Ordine CQ voce
  /// 1.01.
  ///
  /// Questa classe conta i budget e non tiene il piano: il piano vive in
  /// `EntitlementService`. Il campo `piano` pero' arriva nella stessa
  /// risposta dei residui, ed e' l'unico momento in cui il telefono lo sente
  /// dire dal server. Senza questo ponte quel campo si perdeva, e il
  /// telefono restava convinto di un piano che il server non gli riconosceva.
  ///
  /// **E' facoltativo**: una prova che monta i contatori da sola non deve
  /// dover portarsi dietro il servizio del piano.
  final void Function(String piano)? quandoIlServerDiceIlPiano;

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

  /// Quanti inviti accolti il server dichiara. Ordine BX voce 02.
  int _invitiAccolti = 0;

  int get invitiAccolti => _invitiAccolti;

  Map<String, int> _invitiPerMaestro = const {};

  Map<String, int> get invitiPerMaestro => _invitiPerMaestro;
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
      _listinoDellaCondivisione[motivo] ??
      // **L'INVITO HA IL SUO NUMERO ALTROVE, ordine BX.** Il premio
      // dell'invito accolto e' uscito dal listino della condivisione con la
      // voce BX.02, perche' non si paga piu' condividendo: il valore vive
      // in `EOS_DELL_INVITO_ACCOLTO` sul server e arriva con lo stato.
      // Senza questa riga la card diceva "Eos quando il tuo amico entra nel
      // Cerchio", senza cifra, e l'ha visto l'anteprima.
      (motivo == ModoDellaCondivisione.invitoConDownload.motivo
          ? _premioDellInvitoAccolto
          : null);

  int? _premioDellInvitoAccolto;

  /// **QUANTO VALE UN INVITO ACCOLTO, per tutti e due.** Ordine DW voce 05:
  /// la cifra la dice il server (`EOS_DELL_INVITO_ACCOLTO`, uguale a
  /// `EOS_A_CHI_ARRIVA_CON_UN_INVITO`), e i messaggi d'invito la leggono da
  /// qui invece di scriverla a mano. Nulla finche' il server non ha risposto.
  int? get premioDellInvito => _premioDellInvitoAccolto;

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
    _steseDaDieci = 0;
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

  /// **DICHIARA CHE IL SERVER HA PARLATO, solo per le prove.** Ordine CF
  /// voce 11.
  ///
  /// Dalla voce CF.11 la riga del residuo TACE finche' il server non ha
  /// risposto, perche' un numero locale spacciato per vero e' peggio di
  /// nessun numero. Le prove che vogliono misurare la riga hanno quindi
  /// bisogno di una borsa che abbia sentito il server, e l'unica via era
  /// montare una porta finta: questa seconda porta esiste per non
  /// obbligare ogni prova di schermata a montarne una.
  ///
  /// **Nell'app non la chiama nessuno**, e una prova lo verifica.
  @visibleForTesting
  void ilServerHaParlato([String giorno = '2026-08-31']) {
    _giornoDelServer = giorno;
  }

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

  /// **QUANTE STESE RIDA' IL RISCATTO: UNA.** Ordine GA voce 01: il limite
  /// torna a contare le stese, e il giro in piu' a Eos ridà una stesa,
  /// qualunque sia il numero delle sue carte. Era tre carte dall'ordine EX
  /// voce 02. Il server ha lo stesso numero in `functions/src/budget.ts`,
  /// `UNITA_DEL_RISCATTO`.
  static const int kSteseDelRiscatto = 1;

  /// **IL RISCATTO DELLA STESA A DIECI CARTE**, decisione del fondatore del
  /// 14 ottobre 2026 ("2 400 EOS"): la Croce Celtica si riscatta col suo
  /// prezzo, e dall'ordine GA voce 01 ridà una stesa, come ogni riscatto
  /// ("Il giro in piu' a Eos dopo l'ultima stesa del giorno resta com'e'
  /// oggi": cambia l'unita', non il prezzo). E' il nome che il server usa nel
  /// listino e nel motivo (`riscatto_steseDieci`, in
  /// `RISCATTI_DELLA_STESA_INTERA` di `functions/src/borsellino.ts`); il
  /// PREZZO non sta qui, arriva dal listino come ogni altro.
  ///
  /// **E SOLO SE LA CROCE CELTICA DEL GIORNO E' ANCORA LIBERA, ordine GA voce
  /// 02**, 20 ottobre 2026, sera: il fondatore, *"Limitiamo la stesa
  /// tarocchi a 10 carte: sarà disponibile solo per Tier 2 e 3 e solo 1 al
  /// giorno."* Il riscatto da 400 resta (la decisione del 14 ottobre) per chi
  /// ha finito le stese del giorno senza aver fatto la Croce Celtica; fatta
  /// quella, la Croce Celtica non si ricompra (vedi [laStesaSiRiscattaIntera]).
  static const String kRiscattoDellaStesaIntera = 'steseDieci';

  /// **IL BUDGET DELLA STESA A DIECI CARTE, ordine GA voce 02.** Il nome e'
  /// quello del server (`functions/src/budget.ts`), e non e' `steseDieci`:
  /// quel nome e' gia' il riscatto qui sopra, e il server leggerebbe
  /// `riscatto_steseDieci` come il riscatto di questo budget.
  static const String kSteseDaDieci = 'steseDaDieci';

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
  static const _kStese = 'allowance.stese';
  static const _kSteseDaDieci = 'allowance.stese_da_dieci';
  static const _kServerContaLaDieci = 'allowance.server_conta_la_dieci';
  static const _kSinastrie = 'allowance.sinastrie';
  static const _kEvolutive = 'allowance.sinastrie_evolutive';
  static const _kOracoli = 'allowance.oracoli_angeli';
  static const _kGiornoDelServer = 'allowance.giornoDelServer';
  static const _kCoda = 'allowance.coda';
  static const _kSaldo = 'allowance.saldoEos';

  int _count = 0;
  int _approfondimenti = 0;
  int _confronti = 0;
  int _gettate = 0;

  /// LE STESE COMPLETE DI TAROCCHI CONSUMATE OGGI, ordine BN voce 09.
  ///
  /// Sta qui e non in un contatore suo per la stessa ragione delle
  /// gettate: il confine del giorno e' uno solo, e un secondo contatore
  /// con un giorno proprio divergerebbe alla prima ora legale. E' un
  /// budget SEPARATO da quello delle gettate perche' il listino tiene le
  /// due cose su due righe distinte.
  int _stese = 0;

  /// **LE STESE A DIECI CARTE FATTE OGGI, ordine GA voce 02.** Un tetto in
  /// piu' sopra quello delle stese: la Croce Celtica consuma una stesa E una
  /// di queste. Stesso confine del giorno degli altri contatori.
  int _steseDaDieci = 0;

  /// Vero se il server ha dichiarato di conoscere il budget `steseDaDieci`
  /// (vedi `StatoDelCerchio.budgetDelServer`): solo allora la Croce Celtica
  /// gli si manda, e solo allora il suo conto vince su quello del telefono.
  /// Finche' le funzioni nuove non sono pubblicate il telefono tiene il conto
  /// da solo, e la Croce Celtica resta comunque una al giorno.
  bool _serverContaLaDieci = false;

  /// LE SINASTRIE CELEB CONSUMATE OGGI, ordine BO voce 13. Budget suo,
  /// separato da quello dei confronti nel Cerchio: sono due righe diverse
  /// del listino e promettono cose diverse.
  int _sinastrie = 0;

  /// LE SINASTRIE EVOLUTIVE di coppie nuove consumate oggi, ordine FT
  /// voce FT.13. Budget suo, separato da quello della VIP.
  int _evolutive = 0;

  /// LE CONSULTAZIONI DELL'ORACOLO DEGLI ANGELI di oggi, ordine FU voce
  /// FU.10. Budget suo, sullo stesso confine del giorno degli altri.
  int _oracoli = 0;
  String _day = '';

  /// Il giorno d'uso, dal punto SOLO in cui e' definito.
  ///
  /// Era scritto qui dentro, e quando l'Eco ha avuto bisogno dello stesso
  /// confine copiarlo avrebbe voluto dire due definizioni dello stesso giorno
  /// che devono restare d'accordo. Vedi `ConfineDelGiorno`, dove sta anche la
  /// ragione per cui il confine RITUALE, a mezzogiorno, e' un'altra cosa.
  String _today() => _giornoDelServer ?? ConfineDelGiorno.chiaveDi(_clock());

  // Se e' cambiato il giorno, azzera il conteggio.
  void _rollover() {
    final t = _today();
    if (t != _day) {
      _day = t;
      _count = 0;
      // I SEI budget ribaltano INSIEME, perche' il giorno e' lo stesso.
      //
      // Un secondo confine del giorno accanto a questo divergerebbe alla prima
      // ora legale: `ConfineDelGiorno` e' uno, e questi contatori lo
      // guardano tutti da qui. Le gettate di rune stanno qui per lo stesso
      // motivo, ordine I voce 3: il reset e' quello gia' in uso, non un
      // contatore nuovo con un giorno suo.
      _approfondimenti = 0;
      _confronti = 0;
      _gettate = 0;
      _stese = 0;
      _steseDaDieci = 0;
      _sinastrie = 0;
      _evolutive = 0;
      _oracoli = 0;
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

  /// **IL CREDITO COMPRATO, per chi lo deve provare.** Ordine EE voce 08.
  ///
  /// Il riscatto porta il contatore sotto zero, ed e' cosi' che un credito
  /// comprato vive fuori dal proprio piano. Una prova non puo' passare da
  /// `riscatta`, che vuole il server: qui si mette il contatore dove il
  /// riscatto lo lascerebbe, e si misura cio' che ne segue.
  @visibleForTesting
  set confrontiPerLaProva(int quanti) {
    // Prima il cambio di giorno, o sarebbe lui a riazzerare il credito un
    // istante dopo: il primo lettore chiama `_rollover` e su preferenze
    // vuote il giorno non c'e' ancora.
    _rollover();
    _confronti = quanti;
    notifyListeners();
  }

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
  ///
  /// **E DICE DI CHE COSA E' IL RESIDUO, ordine EQ voce 07.** Accanto alla
  /// testata, che conta le domande, *"Oggi te ne restano 20 su 20"* si
  /// leggeva come una contraddizione: adesso la frase e' quella di ogni
  /// altro residuo dell'app (`residuoDiCosa`), con le parole del suo budget.
  String? residuoDeiConfronti(Tier tier) {
    if (!canCompare(tier)) return null;
    final limite = limiteConfronti(tier);
    if (limite == null) return null;
    return residuoDiCosa(confrontiRimasti(tier), limite,
        uno: BudgetDelGiorno.confronti.uno,
        molti: BudgetDelGiorno.confronti.molti,
        femminile: BudgetDelGiorno.confronti.femminile);
  }

  // **LAPIDE: `comeSiDiceIlResiduo`.** Qui c'era l'accordo della sola riga
  // dei confronti, "Oggi te ne restano 3 su 3": teneva il numero ma non
  // diceva di che cosa, ordine EQ voce 07. L'accordo vive in
  // [residuoDiCosa], che lo tiene per tutti i residui dell'app.

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
    // **CHI NON HA CONSUMATO NIENTE NON HA UN RESTO.** Ordine CO voce 11, 3
    // settembre 2026. Il fondatore ha letto "Ti restano 50 gettate di rune su
    // 50, oggi" e "30 su 30", e sono le gettate del Tier 3 e del Tier 2 a
    // giornata appena aperta.
    //
    // **Il numero era giusto e la frase era una tautologia.** "Restare" dice
    // che qualcosa e' stato tolto da qualcos'altro: davanti a un budget
    // intatto non c'e' niente da cui restare, e il "su" diventa una frazione
    // che vale sempre uno. Peggio, suggerisce una sottrazione che non e'
    // avvenuta, quindi la riga sembra un avviso mentre e' una buona notizia.
    //
    // Cosi' la stessa riga dice due cose diverse nei due momenti: **prima del
    // primo gesto e' una dotazione, dopo e' un residuo.** E' l'unico
    // cambiamento: la legge dell'ordine CE voce 04 resta intera, chi guarda
    // sa sempre quanti gliene mancano.
    if (quanti >= limite) {
      return limite == 1 ? 'Oggi hai 1 $uno' : 'Oggi hai $limite $molti';
    }
    if (quanti == 1) return 'Ti resta 1 $uno su $limite, oggi';
    return 'Ti restano $quanti $molti su $limite, oggi';
  }

  /// Quante gettate di rune al giorno prevede il piano, oppure null se
  /// illimitate. Il numero sta nella matrice, riga [PlanCatalog.rigaGettate].
  int? limiteGettate(Tier tier) =>
      PlanCatalog.limiteGiornaliero(PlanCatalog.rigaGettate, tier);

  /// **QUANTE GETTATE RISULTANO SPESE OGGI.** Ordine CQ voce 1.01: serve
  /// alla guardia che pretende che il no del server chiuda il conto sul tetto
  /// vero e non su una bandiera da un milione. Senza questa porta la prova
  /// avrebbe dovuto guardare un campo privato, cioe' misurare una copia.
  int get gettateSpese => _gettate;

  /// **IL TETTO DEL PIANO NUOVO NASCE INTERO. Ordine CQ voce 6.21,
  /// 4 settembre 2026.**
  ///
  /// Parole del fondatore, dopo aver attivato l'Illuminato con una gettata
  /// gia' fatta: *non dovrebbero essere 50 nel momento in cui torni alla
  /// funzionalita' rune dopo aver attivato il piano? la prima era gratis
  /// cioe' compresa.*
  ///
  /// **Ha ragione, e la ragione e' di sostanza.** Chi sale di piano sta
  /// comprando QUEL tetto adesso: trovarlo gia' eroso da consumi fatti
  /// sotto un tetto piu' basso e' una promessa non mantenuta, e capita nel
  /// momento in cui uno ha appena pagato. Il conto restava perche' e'
  /// giornaliero e non sapeva niente dei piani.
  ///
  /// **Come si condona, e perche' cosi'.** Si condona il consumo fatto
  /// SOTTO il tetto vecchio, e mai piu' di quello: chi aveva un tetto di
  /// uno e ne aveva fatta una si ritrova il piano nuovo intero, chi ne aveva
  /// fatte trenta con un tetto di trenta pure. **Non e' un azzeramento**: se
  /// il tetto vecchio era piu' alto del consumo, si condona solo il consumo,
  /// e chi scende di piano non guadagna niente.
  ///
  /// **Il limite di questo ragionamento, dichiarato.** In Demo il piano si
  /// cambia con un tocco, quindi salire e scendere piu' volte condona piu
  /// volte. Nel prodotto vero il piano lo cambia il pagamento, non un
  /// pulsante, e li' il giro non esiste. Se un giorno la Demo dovesse
  /// difendersi da questo, il posto e' qui.
  int? gettateRimaste(Tier tier) {
    final limite = limiteGettate(tier);
    if (limite == null) return null;
    _rollover();
    _condonaSalendo(limite);
    final resta = limite - _gettate;
    return resta < 0 ? 0 : resta;
  }

  /// Il tetto delle gettate **PIU' ALTO** visto oggi.
  ///
  /// **E' il piu' alto e non l'ultimo, e la differenza e' una porta
  /// aperta.** La prima stesura ricordava l'ultimo, e la guardia di questa
  /// voce lo ha preso al primo giro: con tre gettate fatte da Illuminato si
  /// scendeva alla Demo e si risaliva, e il condono scattava di nuovo
  /// regalando una gettata. Misurato: 47 prima, 48 dopo il giro.
  ///
  /// Ricordando il piu' alto, salire dove si e' gia' stati non condona
  /// niente, e il giro non paga.
  int? _tettoGettateMax;

  /// Condona il consumo fatto sotto un tetto piu' basso, quando il tetto
  /// sale sopra ogni tetto gia' visto oggi. Vedi [gettateRimaste].
  void _condonaSalendo(int limite) {
    final max = _tettoGettateMax;
    if (max == null) {
      _tettoGettateMax = limite;
      return;
    }
    if (limite <= max) return;
    _tettoGettateMax = limite;
    // Si toglie il consumo fatto sotto il tetto vecchio, mai piu' di quello.
    final condonate = _gettate < max ? _gettate : max;
    if (condonate <= 0) return;
    _gettate -= condonate;
    notifyListeners();
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

  /// Quante STESE COMPLETE di tarocchi al giorno prevede il piano, oppure
  /// null se sono illimitate. Il numero sta nella matrice, riga
  /// [PlanCatalog.rigaStese], e non si scrive mai a mano in una schermata.
  ///
  /// **E' la riga delle stese complete, non quella della carta singola.** Il
  /// briefing chiama la tre carte la piu' piccola delle stese complete, e le
  /// due righe promettono cose diverse: la carta singola e' il gesto gratis
  /// del giorno del Viandante, la stesa completa la compra in Eos.
  int? limiteStese(Tier tier) =>
      PlanCatalog.limiteGiornaliero(PlanCatalog.rigaStese, tier);

  /// **LE STESE, NON LE CARTE. Ordine GA voce 01.** Il fondatore, 19 ottobre
  /// 2026: *"nei tarocchi, per quanto riguarda i limiti per free e gli
  /// abbonamenti, bisogna tornare a conteggio per stesa e non per numero di
  /// carte scelte ed estratte"*. Una stesa da 1, da 3, da 4 o da 10 carte
  /// vale una stesa. Dall'ordine EX voce 02 il contatore contava le carte.
  /// Quante stese restano oggi, oppure null se sono illimitate.
  int? steseRimaste(Tier tier) {
    final limite = limiteStese(tier);
    if (limite == null) return null;
    _rollover();
    final resta = limite - _stese;
    return resta < 0 ? 0 : resta;
  }

  /// Se si puo' stendere adesso. Come per la gettata, il cancello guarda i
  /// RIMASTI e non il piano: chi ha riscattato una stesa con gli Eos ha il
  /// contatore sotto zero e quindi un rimasto, anche dove il piano non ne
  /// prevede nessuna.
  bool puoiStendere(Tier tier) {
    final resta = steseRimaste(tier);
    return resta == null || resta >= 1;
  }

  /// **QUANTE STESE A DIECI CARTE PREVEDE IL PIANO OGNI GIORNO.** Ordine GA
  /// voce 02, il fondatore la sera del 20 ottobre 2026: *"Limitiamo la stesa
  /// tarocchi a 10 carte: sarà disponibile solo per Tier 2 e 3 e solo 1 al
  /// giorno."* Il numero sta nella matrice, riga
  /// [PlanCatalog.rigaStesaDaDieci]: zero al Viandante e all'Iniziato, uno
  /// all'Adepto e all'Illuminato.
  int limiteStesaDaDieci(Tier tier) =>
      PlanCatalog.limiteGiornaliero(PlanCatalog.rigaStesaDaDieci, tier) ?? 0;

  /// Quante stese a dieci carte restano oggi. Non va mai sotto zero e non
  /// sale mai sopra il tetto: questo budget non si riscatta, quindi non ha
  /// credito comprato.
  int steseDaDieciRimaste(Tier tier) {
    _rollover();
    final resta = limiteStesaDaDieci(tier) - _steseDaDieci;
    return resta < 0 ? 0 : resta;
  }

  /// **LA CROCE CELTICA DI OGGI E' GIA' STATA FATTA.** Vero solo per un piano
  /// che la stesa a dieci la comprende e l'ha gia' usata oggi: a chi non ce
  /// l'ha nel piano si dice da quale piano si apre, non che e' fatta. Ordine
  /// GA voce 02: in quel caso la Croce Celtica non si apre nemmeno con gli
  /// Eos, e l'invito dice che torna domani e propone un'altra stesa.
  bool laCroceCelticaDiOggiEFatta(Tier tier) =>
      limiteStesaDaDieci(tier) > 0 && steseDaDieciRimaste(tier) == 0;

  /// **QUANTI RISCATTI SERVONO PERCHE' QUESTA STESA SI APRA**: uno se le
  /// stese del giorno sono finite, zero se ne resta una o se non c'e'
  /// limite. Ordine GA voce 01: un riscatto ridà una stesa, qualunque sia il
  /// numero delle sue carte. Dall'ordine EX voce 02 servivano tanti riscatti
  /// da tre carte quante ne mancavano.
  ///
  /// **Ordine GA voce 02**: conta i riscatti del budget delle stese. Per la
  /// Croce Celtica gia' fatta oggi nessun riscatto basta, e chi la apre lo
  /// chiede prima a [laCroceCelticaDiOggiEFatta]: la schermata in quel caso
  /// non offre nessun riscatto.
  int riscattiPerLaStesa(Tier tier) => puoiStendere(tier) ? 0 : 1;

  /// **SE QUESTA STESA SI RISCATTA COL PREZZO DELLA STESA A DIECI CARTE.**
  /// Ordine GA voce 01: *"Il giro in piu' a Eos dopo l'ultima stesa del
  /// giorno resta com'e' oggi"*. Oggi la Croce Celtica a stese finite si
  /// riscatta col suo prezzo ([kRiscattoDellaStesaIntera], 400 Eos sul
  /// server), e le altre stese col riscatto da 150: si tiene cosi'. Vero
  /// quando la stesa e' a dieci carte, le stese del giorno sono finite e il
  /// server ha mandato quel riscatto nel listino; un server che non lo manda
  /// lascia il riscatto di sempre.
  ///
  /// **E SOLO SE LA CROCE CELTICA DI OGGI E' ANCORA LIBERA, ordine GA voce
  /// 02.** Fatta quella del giorno la Croce Celtica non si riscatta a nessun
  /// prezzo: qui si torna falso, e la schermata non offre nessun riscatto.
  bool laStesaSiRiscattaIntera(Tier tier, {required int carte}) =>
      carte >= 10 &&
      steseDaDieciRimaste(tier) > 0 &&
      riscattiPerLaStesa(tier) > 0 &&
      _listinoDelRiscatto[kRiscattoDellaStesaIntera] != null;

  /// Registra una stesa consumata. Chi ha l'illimitato non intacca niente.
  ///
  /// Si chiama UNA volta per stesa e non una per carta, nel momento in cui la
  /// stesa e' compiuta: una stesa cominciata e abbandonata non consuma
  /// niente. Ordine GA voce 01: vale una stesa, quante che siano le sue
  /// carte.
  ///
  /// **[daDieci], ordine GA voce 02**: la Croce Celtica consuma una stesa E
  /// la stesa a dieci del giorno. Non e' il numero delle carte (la stesa
  /// vale sempre una stesa): e' il secondo tetto, quello della dieci.
  void registraStesa(Tier tier, {bool daDieci = false}) {
    if (limiteStese(tier) == null) return;
    _rollover();
    _stese += 1;
    if (daDieci) _steseDaDieci += 1;
    notifyListeners();
    _persist();
    _chiediAlServer('stese', quanti: 1);
    if (daDieci && _serverContaLaDieci) _chiediAlServer(kSteseDaDieci);
  }

  /// Quante SINASTRIE CELEB al giorno prevede il piano, oppure null se sono
  /// illimitate. Il numero sta nella matrice, riga [PlanCatalog.rigaSinastria].
  ///
  /// **E' la riga della Sinastria VIP, non quella dei confronti nel Cerchio**,
  /// ordine BO voce 13: la prima promette tre al giorno al Viandante perche'
  /// e' la leva virale e deve girare, la seconda gliene nega.
  int? limiteSinastrie(Tier tier) =>
      PlanCatalog.limiteGiornaliero(PlanCatalog.rigaSinastria, tier);

  /// Quante sinastrie restano oggi, oppure null se illimitate.
  int? sinastrieRimaste(Tier tier) {
    final limite = limiteSinastrie(tier);
    if (limite == null) return null;
    _rollover();
    final resta = limite - _sinastrie;
    return resta < 0 ? 0 : resta;
  }

  /// Se si puo' comporre una coppia NUOVA adesso. Il cancello guarda i
  /// rimasti e non il piano, cosi' il credito comprato apre anche fuori piano.
  bool puoiComporreUnaCoppia(Tier tier) {
    final resta = sinastrieRimaste(tier);
    return resta == null || resta > 0;
  }

  /// Registra una sinastria consumata.
  ///
  /// **Si chiama alla PRIMA scoperta di una coppia e mai alla riapertura**,
  /// decisione del fondatore, parole sue: "no, non deve consumare". Chi
  /// riapre dalla collezione sta rileggendo una cosa che ha gia' pagato.
  void registraSinastria(Tier tier) {
    if (limiteSinastrie(tier) == null) return;
    _rollover();
    _sinastrie++;
    notifyListeners();
    _persist();
    _chiediAlServer('sinastrie');
  }

  /// **IL BUDGET DELLA SINASTRIA EVOLUTIVA, ordine FT voce FT.13.**
  static const String kSinastrieEvolutive = 'sinastrieEvolutive';

  /// **SI CONTA SOLO QUANDO IL SERVER LO CONOSCE.** La coda dei gesti si
  /// ferma al primo che il server rifiuta: mandare un budget che le
  /// funzioni pubblicate non conoscono bloccherebbe dietro di lui le
  /// domande, le stese e tutto il resto. Il server nuovo
  /// (`functions/src/budget.ts`, scritto e non pubblicato: la
  /// pubblicazione la decide il fondatore) manda il prezzo del riscatto
  /// di questo budget nel listino; finche' non lo manda, la Sinastria
  /// evolutiva non si conta, come il riscatto da 400 Eos della Croce
  /// Celtica (ordine FS voce 13).
  bool get contaLeSinastrieEvolutive =>
      _listinoDelRiscatto.containsKey(kSinastrieEvolutive);

  /// Quante coppie nuove al giorno prevede il piano, oppure null se il
  /// conto non e' ancora acceso (vedi [contaLeSinastrieEvolutive]).
  int? limiteSinastrieEvolutive(Tier tier) => contaLeSinastrieEvolutive
      ? PlanCatalog.limiteGiornaliero(PlanCatalog.rigaSinastriaEvolutiva, tier)
      : null;

  /// Quante coppie nuove restano oggi, oppure null se non si contano.
  int? sinastrieEvolutiveRimaste(Tier tier) {
    final limite = limiteSinastrieEvolutive(tier);
    if (limite == null) return null;
    _rollover();
    final resta = limite - _evolutive;
    return resta < 0 ? 0 : resta;
  }

  /// Se si puo' leggere una coppia nuova adesso.
  bool puoiLeggereUnaCoppiaNuova(Tier tier) {
    final resta = sinastrieEvolutiveRimaste(tier);
    return resta == null || resta > 0;
  }

  /// Registra una coppia nuova letta. Come per la VIP, si chiama alla
  /// prima lettura di una coppia, mai a una riapertura.
  void registraSinastriaEvolutiva(Tier tier) {
    if (limiteSinastrieEvolutive(tier) == null) return;
    _rollover();
    _evolutive++;
    notifyListeners();
    _persist();
    _chiediAlServer(kSinastrieEvolutive);
  }

  /// **IL BUDGET DELL'ORACOLO DEGLI ANGELI, ordine FU voce FU.10.**
  static const String kOracoliAngeli = 'oracoliAngeli';

  /// **SI CONTA SOLO QUANDO IL SERVER LO CONOSCE**, come la Sinastria
  /// evolutiva ([contaLeSinastrieEvolutive]): il server nuovo
  /// (`functions/src/budget.ts`, scritto e non pubblicato, la pubblicazione
  /// la decide il fondatore) manda il prezzo del riscatto di questo budget
  /// nel listino; finche' non lo manda, le consultazioni non si contano e
  /// la coda dei gesti non si blocca su un budget che il server non conosce.
  bool get contaGliOracoli => _listinoDelRiscatto.containsKey(kOracoliAngeli);

  /// Quante consultazioni al giorno prevede il piano, oppure null se il
  /// conto non e' ancora acceso (vedi [contaGliOracoli]).
  int? limiteOracoli(Tier tier) => contaGliOracoli
      ? PlanCatalog.limiteGiornaliero(PlanCatalog.rigaOracoli, tier)
      : null;

  /// Quante consultazioni restano oggi, oppure null se non si contano.
  int? oracoliRimasti(Tier tier) {
    final limite = limiteOracoli(tier);
    if (limite == null) return null;
    _rollover();
    final resta = limite - _oracoli;
    return resta < 0 ? 0 : resta;
  }

  /// Se si puo' consultare gli angeli adesso. Il cancello guarda i rimasti
  /// e non il piano, cosi' il credito comprato con gli Eos apre subito.
  bool puoiConsultareGliAngeli(Tier tier) {
    final resta = oracoliRimasti(tier);
    return resta == null || resta > 0;
  }

  /// Registra una consultazione compiuta: si chiama quando le carte sono
  /// estratte, mai per una domanda delicata (che non estrae carte).
  void registraOracolo(Tier tier) {
    if (limiteOracoli(tier) == null) return;
    _rollover();
    _oracoli++;
    notifyListeners();
    _persist();
    _chiediAlServer(kOracoliAngeli);
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
      _stese = prefs.getInt(_kStese) ?? 0;
      _steseDaDieci = prefs.getInt(_kSteseDaDieci) ?? 0;
      _serverContaLaDieci = prefs.getBool(_kServerContaLaDieci) ?? false;
      _sinastrie = prefs.getInt(_kSinastrie) ?? 0;
      _evolutive = prefs.getInt(_kEvolutive) ?? 0;
      _oracoli = prefs.getInt(_kOracoli) ?? 0;
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
    // **IL PIANO PRIMA DEI RESIDUI, ordine CQ voce 1.01.** I residui che
    // seguono sono contati dal server sul piano che il server crede attivo:
    // applicarli senza applicare anche il piano vuol dire mostrare i numeri
    // di un piano dentro i tetti di un altro, che e' esattamente cio' che il
    // fondatore ha visto sul telefono.
    quandoIlServerDiceIlPiano?.call(stato.piano);
    _tierDelServer = switch (stato.piano) {
      'tier1' => Tier.tier1,
      'tier2' => Tier.tier2,
      'tier3' => Tier.tier3,
      _ => Tier.free,
    };
    _giornoDelServer = stato.giorno;
    final giornoNuovo = _day != stato.giorno;
    if (_day != stato.giorno) _day = stato.giorno;
    // **LA STESA A DIECI DEL GIORNO, ordine GA voce 02.** Se il server la
    // conosce, vince il suo conto come per ogni altro budget; se non la
    // conosce ancora (funzioni non pubblicate), il conto resta quello del
    // telefono, e ricomincia solo col giorno nuovo.
    _serverContaLaDieci = stato.budgetDelServer.contains(kSteseDaDieci);
    if (_serverContaLaDieci) {
      _steseDaDieci = stato.spesi[kSteseDaDieci] ?? 0;
    } else if (giornoNuovo) {
      _steseDaDieci = 0;
    }
    _count = stato.spesi['domande'] ?? 0;
    // Ordine BG voce 04: quante condivisioni premiate sono gia' state
    // pagate oggi. Serve al pulsante, per non promettere un bonus che il
    // tetto anti farming non pagherebbe.
    _condivisioniPremiateOggi = stato.spesi['condivisioni_premiate'] ?? 0;
    _approfondimenti = stato.spesi['approfondimenti'] ?? 0;
    _confronti = stato.spesi['confronti'] ?? 0;
    _gettate = stato.spesi['gettate'] ?? 0;
    _stese = stato.spesi['stese'] ?? 0;
    _sinastrie = stato.spesi['sinastrie'] ?? 0;
    _evolutive = stato.spesi[kSinastrieEvolutive] ?? 0;
    _oracoli = stato.spesi[kOracoliAngeli] ?? 0;
    _saldoEos = stato.saldoEos;
    // **QUANTI INVITI SONO STATI ACCOLTI, ordine BX voce 02.** Il telefono non
    // lo puo' sapere: lo sa il server, quando la persona invitata riscatta il
    // codice. Qui si tiene il numero, e la regia lo porta al cammino, dove tre
    // voci lo aspettano.
    _invitiAccolti = stato.invitiAccolti;
    _invitiPerMaestro = stato.invitiPerMaestro;
    // Come ogni listino: si sostituisce solo se il server lo ha mandato.
    if (stato.premioDellInvitoAccolto != null) {
      _premioDellInvitoAccolto = stato.premioDellInvitoAccolto;
    }
    // **LE CORREZIONI DEL CATALOGO DEI VIP, ordine BX voce 09.** Il catalogo
    // dei 50 personaggi e' una costante compilata: senza questa riga, lo
    // stato in vita di una persona puo' cambiare solo pubblicando una
    // versione nuova dell'app.
    //
    // **Si applica sempre, anche vuoto**: una mappa vuota vuol dire che
    // vale il catalogo compilato, che e' l'ultima verita' conosciuta e cio'
    // che era vero prima di quest'ordine. Non e' come i listini, dove il
    // vuoto di un server vecchio cancellerebbe un prezzo giusto: qui il
    // vuoto non cancella niente, riporta al catalogo.
    CorrezioniDeiVip.applica(stato.correzioniDeiVip);
    // **E L'ATTUALITA', dalla stessa risposta. Ordine CA voce 05.** Un fatto
    // pubblico e professionale per personaggio, con la data di verifica: entra
    // come dato, non come frase generata, e il testo lo salta quando e' piu'
    // vecchio di novanta giorni.
    CorrezioniDeiVip.applicaAttualita(stato.attualitaDeiVip);
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
    // **IL PREMIO DELLA REGISTRAZIONE, ordine BH voce 01**: il numero che
    // gli inviti a registrarsi scrivono sul foglio. Come ogni listino, si
    // tiene solo se il server ha parlato.
    if (stato.premioDellaRegistrazione != null) {
      _premioDellaRegistrazione = stato.premioDellaRegistrazione;
    }
    // **SE IL BENVENUTO E' DI QUESTA CHIAMATA, IL CERCHIO E' APPENA NATO.**
    // Ordine BG voce 01: il fondatore e' entrato con "Faccio gia' parte del
    // Cerchio" su un account cancellato, Google ne ha creato uno nuovo in
    // silenzio (coi provider federati non esiste "email gia' in uso"), e la
    // scena del ritrovamento gli ha dato il Bentornato mostrando la dote di
    // nascita come cosa tenuta. Il benvenuto si accredita UNA volta nella
    // vita di un Cerchio: se e' arrivato adesso, questo Cerchio e' nato
    // adesso, e nessuno deve dirgli bentornato.
    // **Nota di BH.01**: da quando il benvenuto e' il premio della prima
    // registrazione, questo segnale scatta anche quando un Cerchio anonimo
    // gia' vissuto si registra. I punti che lo leggono (il ritrovamento
    // della porta piccola) stanno tutti su strade dove accesso e benvenuto
    // coincidono, e la festa della registrazione lo usa apposta.
    _benvenutoAppenaArrivato =
        stato.accreditati.any((a) => a.motivo == 'benvenuto');
    // **Il segnale del server vince (BH.01)**: la lapide antifrode puo'
    // fermare il benvenuto su un Cerchio nuovo di zecca, e senza questo
    // segnale il ritrovamento mostrerebbe i 20 del giorno come cosa tenuta.
    // Il ripiego sul benvenuto resta per un server piu' vecchio dell'app.
    _cerchioAppenaNato = stato.cerchioNuovo ?? _benvenutoAppenaArrivato;
    notifyListeners();
    await _persist();
    return stato.cammino;
  }

  bool _benvenutoAppenaArrivato = false;

  /// Vero se l'ultima sincronia ha accreditato il benvenuto: e' il segnale
  /// della festa della registrazione (BH.02) e della riga onesta quando la
  /// lapide lo ferma.
  bool get benvenutoAppenaArrivato => _benvenutoAppenaArrivato;

  int? _premioDellaRegistrazione;

  /// Il premio della prima registrazione, come il server lo dichiara.
  /// Nullo finche' il server non ha parlato: gli inviti allora promettono
  /// il dono senza scrivere un numero, mai un numero inventato.
  int? get premioDellaRegistrazione => _premioDellaRegistrazione;

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
  ///
  /// **Pretende il consenso della conferma**, ordine FD voce 01: nessun
  /// riscatto parte al primo tocco.
  Future<int?> riscatta(String budget,
      {required ConsensoDellaSpesa consenso}) async {
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
      case 'stese':
      case kRiscattoDellaStesaIntera:
        // Ordine GA voce 01: ogni riscatto ridà una stesa, come
        // `UNITA_DEL_RISCATTO` e `unita` sul server.
        _stese -= kSteseDelRiscatto;
      case 'sinastrie':
        _sinastrie--;
      case kSinastrieEvolutive:
        _evolutive--;
      case kOracoliAngeli:
        _oracoli--;
    }
    notifyListeners();
    await _persist();
    return prezzo;
  }

  /// **PIU' RISCATTI SOTTO UN CONSENSO SOLO.** Serve alla stesa che chiede
  /// piu' carte di quante un riscatto ne ridia (vedi [riscattiPerLaStesa]):
  /// la persona conferma una volta il prezzo intero, e qui si chiama il
  /// server [volte] volte in sequenza, come [riscatta] fa una volta, ognuna
  /// col suo identificativo.
  ///
  /// Non parte niente se il consenso non copre il prezzo intero o se il
  /// saldo non basta per tutti: mai mezza stesa pagata per scelta. Se il
  /// server cade a meta' ci si ferma li', e l'esito dice quanti riscatti
  /// sono andati e quanto si e' pagato davvero: chi chiama lo racconta.
  Future<({int fatti, int pagato})> riscattaPiuVolte(String budget,
      {required int volte, required ConsensoDellaSpesa consenso}) async {
    final prezzo = _listinoDelRiscatto[budget];
    if (volte <= 0 || prezzo == null || !_porta.viva) {
      return (fatti: 0, pagato: 0);
    }
    final totale = prezzo * volte;
    if (consenso.quanti < totale || _saldoEos < totale) {
      return (fatti: 0, pagato: 0);
    }
    var fatti = 0;
    var pagato = 0;
    for (var i = 0; i < volte; i++) {
      final questo = await riscatta(budget, consenso: consenso);
      if (questo == null) break;
      fatti++;
      pagato += questo;
    }
    return (fatti: fatti, pagato: pagato);
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
  void _chiediAlServer(String budget, {int quanti = 1}) {
    if (!_porta.viva) return;
    _daMandare.add({
      'budget': budget,
      'id': PortaDelCerchio.nuovoIdentificativo('$_day-$budget'),
      if (quanti > 1) 'quanti': '$quanti',
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

  /// **NON LANCIA MAI**, ordine GA voce 11. Chi la chiama e' [sincronizza],
  /// che deve leggere lo stato del Cerchio comunque vada la coda, e
  /// [_chiediAlServer], che non la aspetta: un errore che uscisse di qui
  /// fermerebbe la sincronia o diventerebbe un errore senza padrone.
  Future<void> _svuotaLaCoda() async {
    if (!_porta.viva || _stoSvuotando) return;
    _stoSvuotando = true;
    try {
      await _svuotaDavvero();
    } catch (errore, traccia) {
      // Si ignora per chi usa l'app, non per chi guarda il cruscotto: la
      // coda resta com'e' e riparte alla prossima occasione.
      annotaGuastoInnocuo('la coda dei consumi si ferma', errore, traccia);
    } finally {
      _stoSvuotando = false;
    }
  }

  /// **I RIFIUTI CHE RIGUARDANO LA VOCE, NON IL MOMENTO.** Ordine GA voce 11,
  /// 20 ottobre 2026. Il server ha guardato il consumo e ha detto che cosi'
  /// non lo prendera' mai: `invalid-argument` ("Budget sconosciuto." di un
  /// server pubblicato prima del budget) e `failed-precondition`. Ripetere
  /// quella voce a ogni apertura non cambia la risposta, e tenerla in testa
  /// ferma tutte quelle dietro di lei.
  ///
  /// **Gli altri rifiuti non sono qui, ed e' voluto.** `unauthenticated` e
  /// `permission-denied` dicono che adesso il telefono non e' riconosciuto
  /// (l'accesso che torna, il gettone di App Check): il consumo e' giusto e
  /// passera' dopo, buttarlo vorrebbe dire non contarlo mai.
  static const Set<String> _rifiutiDellaVoce = {
    'invalid-argument',
    'failed-precondition',
  };

  /// **LA CODA SI AVVELENAVA**, ordine GA voce 11, difetto 1 della
  /// ricognizione. Qui un rifiuto definitivo del server usciva come
  /// eccezione: la voce restava in testa alla coda (che e' salvata e
  /// sopravvive ai riavvii), le voci dietro non partivano piu', e
  /// [sincronizza] cadeva prima di leggere piano, residui, saldo Eos, inviti
  /// e cammino. Sul telefono del fondatore e su tre iPhone dei tester dalla
  /// build 2312, coi budget `oracoliAngeli` e `sinastrieEvolutive` che il
  /// `consumaDelGiorno` pubblicato non conosce. Padre: ordine FT voce FT.13 e
  /// ordine FU voce FU.10 (i budget nuovi senza la pubblicazione della porta),
  /// e questo ciclo, che trattava il rifiuto definitivo come la rete assente.
  ///
  /// Adesso la voce rifiutata in modo definitivo esce dalla coda, il guasto
  /// va al cruscotto, e si continua con le altre. Il conto locale non si
  /// tocca: il server quella voce non l'ha contata, e la lettura dello stato
  /// che segue porta il telefono sul numero del server.
  Future<void> _svuotaDavvero() async {
    while (_daMandare.isNotEmpty) {
      final primo = _daMandare.first;
      final EsitoDelConsumo? esito;
      try {
        esito = await _porta.consumaQuanti(
          budget: primo['budget']!,
          idMovimento: primo['id']!,
          quanti: int.tryParse(primo['quanti'] ?? '') ?? 1,
        );
      } on FirebaseException catch (rifiuto, traccia) {
        if (!_rifiutiDellaVoce.contains(rifiuto.code)) {
          // Un rifiuto del momento: la voce resta, e ci si ferma qui come
          // senza rete. Lo stato si legge lo stesso.
          annotaGuastoInnocuo(
              'il consumo ${primo['budget']} aspetta: ${rifiuto.code}',
              rifiuto,
              traccia);
          await _persist();
          return;
        }
        annotaGuastoInnocuo(
            'il server rifiuta il consumo ${primo['budget']}, esce dalla coda',
            rifiuto,
            traccia);
        _daMandare.removeAt(0);
        continue;
      }
      if (esito == null) break;
      _daMandare.removeAt(0);
      if (!esito.concesso) {
        // IL SERVER HA DETTO DI NO: il conto locale si allinea a lui, anche
        // se vuol dire togliere qualcosa che il telefono si era gia' preso.
        await _allineaAlNo(primo['budget']!);
      }
    }
    await _persist();
  }

  /// **IL SERVER HA DETTO DI NO: il conto locale si chiude, e si chiude sul
  /// numero vero.** Ordine CQ voce 1.01.
  ///
  /// **Qui c'era `1 << 20`**, cioe' un milione di gesti consumati. Non era un
  /// allineamento, era una bandiera: serviva solo a far tornare zero il
  /// residuo, e portava con se' una bugia. Il fondatore ha letto sul telefono
  /// "ti restano 29 gettate su 30" e, dopo UNA gettata, "le 30 gettate del
  /// giorno sono state fatte": il salto da uno a un milione e' questo.
  ///
  /// Adesso il contatore si porta esattamente al tetto del piano, quindi il
  /// residuo e' zero e il numero speso e' un numero vero. Dove il tetto non
  /// c'e', il contatore non si tocca: un piano senza tetto che riceve un no
  /// dal server e' un disaccordo sul PIANO, e si cura leggendo il piano dal
  /// server, non gonfiando un contatore.
  Future<void> _allineaAlNo(String budget) async {
    final tetto = _tettoDelBudget(budget);
    if (tetto == null) return;
    switch (budget) {
      case 'domande':
        _count = tetto;
      case 'approfondimenti':
        _approfondimenti = tetto;
      case 'confronti':
        _confronti = tetto;
      case 'gettate':
        _gettate = tetto;
      case 'stese':
        _stese = tetto;
      case kSteseDaDieci:
        _steseDaDieci = tetto;
      case 'sinastrie':
        _sinastrie = tetto;
      case kSinastrieEvolutive:
        _evolutive = tetto;
      case kOracoliAngeli:
        _oracoli = tetto;
    }
    notifyListeners();
  }

  /// Il tetto che il piano corrente promette per quel budget, oppure nullo se
  /// quel budget non ha un tetto su questo piano.
  ///
  /// **Il piano si chiede a chi lo tiene**, e da CQ.1.01 quello e' il server:
  /// se il ponte del piano non e' stato collegato, questa classe non sa su
  /// quale piano contare, e allora non tocca niente invece di indovinare.
  int? _tettoDelBudget(String budget) {
    final tier = _tierDelServer;
    if (tier == null) return null;
    return switch (budget) {
      'domande' => PlanCatalog.limiteGiornaliero(PlanCatalog.rigaDomande, tier),
      'approfondimenti' =>
        PlanCatalog.limiteGiornaliero(PlanCatalog.rigaApprofondimenti, tier),
      'confronti' =>
        PlanCatalog.limiteGiornaliero(PlanCatalog.rigaConfronti, tier),
      'gettate' => PlanCatalog.limiteGiornaliero(PlanCatalog.rigaGettate, tier),
      'stese' => PlanCatalog.limiteGiornaliero(PlanCatalog.rigaStese, tier),
      kSteseDaDieci =>
        PlanCatalog.limiteGiornaliero(PlanCatalog.rigaStesaDaDieci, tier),
      'sinastrie' =>
        PlanCatalog.limiteGiornaliero(PlanCatalog.rigaSinastria, tier),
      kSinastrieEvolutive =>
        PlanCatalog.limiteGiornaliero(PlanCatalog.rigaSinastriaEvolutiva, tier),
      kOracoliAngeli =>
        PlanCatalog.limiteGiornaliero(PlanCatalog.rigaOracoli, tier),
      _ => null,
    };
  }

  /// Il piano che il server ha dichiarato l'ultima volta, tradotto in tier.
  Tier? _tierDelServer;

  static List<Map<String, String>> _codaDaTesto(String? testo) {
    if (testo == null || testo.isEmpty) return const [];
    try {
      final letta = jsonDecode(testo);
      if (letta is! List) return const [];
      return [
        for (final voce in letta)
          if (voce is Map && voce['budget'] is String && voce['id'] is String)
            {
              'budget': '${voce['budget']}',
              'id': '${voce['id']}',
              if (voce['quanti'] is String) 'quanti': '${voce['quanti']}',
            },
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
      await prefs.setInt(_kStese, _stese);
      await prefs.setInt(_kSteseDaDieci, _steseDaDieci);
      await prefs.setBool(_kServerContaLaDieci, _serverContaLaDieci);
      await prefs.setInt(_kSinastrie, _sinastrie);
      await prefs.setInt(_kEvolutive, _evolutive);
      await prefs.setInt(_kOracoli, _oracoli);
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
