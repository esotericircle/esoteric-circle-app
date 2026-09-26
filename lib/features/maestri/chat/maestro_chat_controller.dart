import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/entitlement/esito_del_turno.dart';
import '../../../core/entitlement/plan_catalog.dart';
import '../../../core/entitlement/question_allowance.dart';
import '../../../core/entitlement/tier.dart';

import '../../../core/chat/altre_voci.dart';
import '../../../core/maestro/consiglio_finale.dart';
import '../../../core/maestro/seguito_della_lettura.dart';
import '../../../core/chat/chat_message.dart';
import '../../../core/chat/la_risposta_che_chiede.dart';
import '../../../core/chat/cronologia_senza_doppioni.dart';
import '../../../core/chat/intent_classifier.dart';
import '../../../core/chat/la_richiesta_di_un_arte.dart';
import '../../../core/chat/maestro_memory.dart';
import '../../../core/chat/user_profile.dart';
import '../../../core/maestro/ancoraggio.dart';
import '../../../core/maestro/frase_del_limite.dart';
import '../../../core/maestro/frase_di_ripiego.dart';
import '../../../core/maestro/tempi_dell_attesa.dart';
import '../../../core/maestro/lettura_di_ripiego.dart';
import '../../../core/maestro/memoria_del_respiro.dart';
import '../../../core/maestro/natal_context.dart';
import '../../../core/chat/la_carta_del_giorno_in_chat.dart';
import '../../../core/rituals/arcano_dell_alba/archivio_dell_alba.dart';
import '../../../core/chat/la_lettura_del_giorno.dart';
import '../../../core/chat/la_risposta_ripetuta.dart';
import '../../../core/chat/la_risposta_da_programma.dart';
import '../../../core/chat/chi_di_dovere.dart';
import '../../../core/chat/i_ricordi_degli_altri.dart';
import '../../../services/ai/la_richiesta_del_turno.dart';
import '../../../core/astro/il_cielo_detto.dart';
import '../../../core/chat/immersive_intents.dart';
import '../../../core/maestro/maestro.dart';
import '../../../services/ai/maestro_ai_provider.dart';
import '../../../services/ai/registro_dei_guasti.dart';
import '../../../services/memory/maestro_memory_repository.dart';
import '../../../core/config/app_flags.dart';
import '../../../core/chat/le_conversazioni_passate.dart';

/// Stato della conversazione con un Maestro.
///
/// Tiene i messaggi, coordina l'invio verso il provider AI e aggiorna la
/// memoria (profilo, fatti, sintesi di sessione). Non conosce Firebase ne'
/// Gemini: dipende solo dalle astrazioni, cosi' resta testabile e sostituibile.
class MaestroChatController extends ChangeNotifier {
  MaestroChatController({
    required this.maestro,
    required MaestroAiProvider ai,
    required MaestroMemoryRepository memory,
    IntentClassifier classifier = const IntentClassifier(),
    QuestionAllowance? allowance,
    Tier Function()? tier,
    NatalContext Function()? natal,
    DateTime Function()? orologio,
    Duration? attesaMinima,
    bool? demo,
    this.segnaNeiRicordi,
    this.conversazioneNuova = false,
    ScrittoreDeiTitoli titoli = const ScrittoreDeiTitoliSpento(),
  })  : _ai = ai,
        _titoli = titoli,
        _demo = demo ?? AppFlags.isDemo,
        _attesaMinima = attesaMinima,
        _memory = memory,
        _classifier = classifier,
        _allowance = allowance,
        _tier = tier,
        _natal = natal,
        _orologio = orologio;

  /// L'ora di adesso: in app e' l'orologio, nelle prove si fissa.
  final DateTime Function()? _orologio;

  DateTime get _adesso => _orologio?.call() ?? DateTime.now();

  /// **TUTTA LA CRONOLOGIA CARICATA, non solo la conversazione corrente.**
  /// Ordine DS voce 08: una domanda gia' fatta oggi in un'altra conversazione
  /// e' la stessa domanda, e la sua lettura e' gia' stata data.
  List<ChatMessage> _cronologiaCaricata = const [];

  /// **SI COMINCIA PULITI. Ordine DZ voce 01.** Vero quando la chat si apre
  /// da un pulsante di approfondimento: la persona viene a chiedere di quel
  /// responso, e la conversazione di prima sotto la domanda confondeva, parola
  /// del fondatore. Quella di prima non si perde: resta fra le passate.
  final bool conversazioneNuova;

  /// Chi scrive il titolo delle conversazioni. Ordine DZ voce 04.
  final ScrittoreDeiTitoli _titoli;

  /// **LE CONVERSAZIONI PASSATE. Ordine DZ voce 03.** L'archivio dei
  /// messaggi da cui si raccolgono, i titoli gia' scritti, e le ultime
  /// cinque pronte per il menu'.
  List<ChatMessage> _archivio = const [];
  Map<String, String> _titoliScritti = const {};
  Set<String> _nascoste = const {};
  List<ConversazionePassata> _passate = const [];
  List<ConversazionePassata> get conversazioniPassate => _passate;
  final Set<String> _titoliInCorso = {};

  /// Quante letture sono state ridette invece di chiedere di nuovo al modello.
  int lettureRidette = 0;

  /// Quante frasi sul cielo sono state tolte perche' il calcolo le smentiva.
  int frasiDelCieloSmentite = 0;

  final Maestro maestro;

  /// La demo tiene la memoria accesa (BG.03): in app vale il flag di casa,
  /// nelle prove si inietta, cosi' la legge del listino (memoria esclusiva
  /// di chi paga) resta vera FUORI demo e si puo' ancora misurare.
  final bool _demo;

  /// QUANTO DURA COME MINIMO LA PAUSA, e qui c'e' solo il modo di scavalcarla
  /// in una prova.
  ///
  /// Il valore vive in [TempiDellAttesa], insieme agli altri tempi. Questo
  /// varco esiste perche' portando la pausa da 1800 a 3200 millisecondi una
  /// prova che fa dieci turni ha cominciato a impiegare trentadue secondi e a
  /// cadere per timeout: chi misura i contatori non sta misurando la pausa, e
  /// non deve pagarla. E' lo stesso varco che la vista ha gia' per la durata
  /// della battuta, con la stessa ragione.
  final Duration? _attesaMinima;

  final MaestroAiProvider _ai;
  final MaestroMemoryRepository _memory;
  final IntentClassifier _classifier;

  /// **LE ARTI CHE LA PERSONA HA RIFIUTATO in questa conversazione.** Ordine
  /// EB voce 05, 21 settembre 2026. Un rifiuto non si dimentica al messaggio
  /// dopo: il fondatore ha detto di non volere una stesa e se l'e' vista
  /// offrire di nuovo, con la stessa identica frase.
  final Set<String> _artiRifiutate = <String>{};

  /// Vero se in questa conversazione l'invito a quell'arte e' gia' stato
  /// dato. **Un invito non si ripete mai.** Ordine EB voce 05: l'invito e'
  /// una frase sola, e ridirla identica e' il modo piu' rapido di far capire
  /// a una persona che sta parlando con una macchina.
  bool _invitoGiaDato(String intentId) =>
      _messages.any((m) => m.intentId == intentId);

  /// **La regola del costo, applicata da un punto solo.** Ordine EB voce 04.
  ///
  /// Prima i rami che non generavano tornavano con un `return` nudo, e la
  /// regola non li vedeva: l'effetto era giusto, ma a tenerlo in piedi era il
  /// `return` e non `CostoDelTurno`. Adesso ogni strada del turno passa di
  /// qui, e chi ne aprira' una nuova dovra' dire come finisce.
  /// **VERO MENTRE LA CONVERSAZIONE PASSA DALLA VOCE VIVA.** Ordine EG voce
  /// 06: *"Il LIVE consuma solo i suoi minuti."*
  ///
  /// Il LIVE usa **questo stesso controller**, cioe' lo stesso Maestro, la
  /// stessa memoria e le stesse regole della chat scritta, che e' cio' che la
  /// voce EG.01 pretende; e ogni turno detto a voce resta scritto nella
  /// conversazione. Ma il conto non e' lo stesso: i minuti li conta il server
  /// all'apertura della sessione, e far scendere anche le domande del giorno
  /// vorrebbe dire far pagare due volte lo stesso turno.
  bool nelLive = false;

  void _applicaIlCosto(EsitoDelTurno esito) {
    if (nelLive) return;
    final piano = _tier?.call();
    final contatore = _allowance;
    if (piano != null && contatore != null && CostoDelTurno.consuma(esito)) {
      contatore.record(piano);
    }
  }

  /// Il contatore delle domande del giorno. Esiste, ed era usato da una sola
  /// delle due strade con cui si fa una domanda a un Maestro: la schermata
  /// "Chiedi" lo consultava, la chat no.
  final QuestionAllowance? _allowance;

  /// Il piano attivo, letto quando serve. Una funzione e non un valore:
  /// l'abbonamento puo' cambiare mentre la chat e' aperta.
  final Tier Function()? _tier;

  /// Il contesto natale corrente. Una funzione e non un valore, per la stessa
  /// ragione del piano: la persona puo' completare i dati di nascita mentre la
  /// chat e' aperta, e il Maestro deve accorgersene al turno dopo.
  ///
  /// Prima questo campo NON esisteva: la chat mandava al provider profilo e
  /// memoria, e i dati natali finivano nella sola frase di benvenuto. Il Maestro
  /// parlava senza sapere di chi.
  final NatalContext Function()? _natal;

  /// Vero se questa persona ha chiesto di non vedere movimento.
  ///
  /// Lo scrive la schermata da `MediaQuery`, perche' il controller non ha un
  /// contesto e non deve averlo. Serve QUI e non solo nella vista: chi non
  /// vuole movimento non ha chiesto di aspettare di piu', quindi la pausa
  /// minima si accorcia, e la pausa la governa il turno, non il disegno.
  bool riduciMovimento = false;

  /// CHI si sta consultando adesso, mentre la scena dell'attesa e' a schermo.
  ///
  /// Serve perche' la scena dica il vero: quando rispondono gli altri Maestri
  /// la riga e il corpo devono essere i LORO, altrimenti la persona vede Medora
  /// che consulta il cielo e poi arriva una bolla di Caligo.
  Maestro? maestroInAscolto;

  /// Quante attese sono passate. Fa ruotare le frasi del consulto, cosi' due
  /// domande vicine non fanno rileggere la stessa riga.
  int rotazioneDelConsulto = 0;

  /// Quanto e' durata l'ultima pausa prima che la risposta comparisse, in
  /// millisecondi. Pubblica perche' e' IL numero dell'ordine E: il tempo dalla
  /// domanda alla prima parola si legge da qui invece che da un cronometro
  /// tenuto a mano fuori.
  int ultimaAttesaMs = 0;

  /// Quante volte il controllo dell'ancoraggio ha fatto rigenerare una
  /// risposta. Pubblico perche' e' la MISURA di quanto la persona funziona da
  /// sola: se cresce, il difetto sta nel prompt e non nel controllo.
  int rigenerazioniPerAncoraggio = 0;

  /// Quante volte la seconda risposta e' rimasta senza ancoraggio e si e'
  /// consegnata comunque. Mai due rigenerazioni: qui finisce il conto.
  int consegneSenzaAncoraggio = 0;

  /// Quante risposte si sono richieste perche' ne ricalcavano una gia' data.
  /// Ordine EN voce 06.
  int rigenerazioniPerRipetizione = 0;

  /// Quante risposte si sono richieste perche' parlavano da programma.
  /// Ordine EN voce 06.
  int rigenerazioniPerProgramma = 0;

  /// **IL TESTO DEL LIVE MENTRE IL MODELLO LO SCRIVE.** Ordine EO voce 14.
  /// Solo nel LIVE: ogni domanda al modello lo riparte da vuoto, e la
  /// schermata lo mostra finche' la risposta intera non arriva. Senza il
  /// segno del chiarimento, che la persona non legge mai.
  final ValueNotifier<String> testoInArrivo = ValueNotifier<String>('');

  /// **CIO' CHE LA PERSONA HA DETTO AGLI ALTRI DUE MAESTRI.** Ordine EN voce
  /// 09: le righe di [IRicordiDegliAltri], lette all'apertura. Non entrano
  /// nella memoria di questo Maestro, che si salva: si aggiungono ai fatti
  /// soltanto nel contesto che parte verso il modello.
  List<String> _ricordiDegliAltri = const [];
  List<String> get ricordiDegliAltri => List.unmodifiable(_ricordiDegliAltri);

  /// La memoria come la riceve il modello: quella di questo Maestro, piu'
  /// cio' che la persona ha detto agli altri due.
  MaestroMemory get _memoriaPerIlModello => _ricordiDegliAltri.isEmpty
      ? _memoryState
      : _memoryState
          .copyWith(facts: [..._memoryState.facts, ..._ricordiDegliAltri]);

  /// **IL SALVATAGGIO DEL TURNO IN ATTESA, CHE NON FA PIU' ASPETTARE IL
  /// MODELLO.** Ordine EN voce 01: si salvava prima di chiamare Gemini, da
  /// 206 a 259 millesimi sul Realme e 1.866 una volta con la rete lenta. Adesso
  /// parte insieme alla chiamata, e la consegna lo aspetta prima di sostituire
  /// il turno: nella cronologia l'ordine resta quello di prima.
  Future<void>? _salvataggioInAttesa;

  /// Quante volte una risposta e' arrivata tronca e si e' rigenerata. Pubblico
  /// per la stessa ragione dell'ancoraggio: se cresce, il tetto e' di nuovo
  /// stretto, e lo si scopre dal numero invece che da uno screenshot.
  int rigenerazioniPerTroncatura = 0;

  /// Quante volte anche la seconda e' arrivata tronca e si e' consegnato un
  /// ripiego. Dovrebbe restare a zero: se sale, il difetto e' nella misura.
  int troncatureConsegnate = 0;

  /// Gli ancoraggi disponibili adesso per questa persona. Vuoto quando non c'e'
  /// niente da ancorare, e in quel caso il controllo NON scatta.
  List<Ancoraggio> get ancoraggiDisponibili =>
      VerificaAncoraggio.disponibiliPer(
        natal: _natal?.call() ?? NatalContext.none,
        profile: _profile,
        memory: _memoriaPerIlModello,
      );

  /// Ogni quanti turni dell'utente rinfrescare il distillato di memoria.
  static const int _distillEvery = 3;

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  UserProfile _profile = UserProfile.empty;
  UserProfile get profile => _profile;

  MaestroMemory _memoryState = MaestroMemory.empty;

  /// **CIO' CHE LA MEDITAZIONE RICORDA.** Ordine DB voce 08: il riassunto
  /// entra fra i fatti che il modello riceve gia', e il dato grezzo resta sul
  /// telefono.
  final MemoriaDelRespiro _respiro = MemoriaDelRespiro();

  /// La memoria del Maestro caricata, per il benvenuto deterministico del
  /// Premium, che riprende dalla sintesi di sessione.
  MaestroMemory get memory => _memoryState;

  bool _loading = true;
  bool get loading => _loading;

  bool _sending = false;
  bool get sending => _sending;

  /// Vero mentre si sta generando il SEGUITO di una risposta gia' letta.
  bool _seguitoInVolo = false;

  /// SE LA SCENA DI ATTESA A SCHERMO INTERO DEVE COMPARIRE.
  ///
  /// **La regola vive qui, e non nella schermata.** La schermata guardava
  /// `sending`, che vale per QUALUNQUE chiamata: al tocco di "Vai piu' a
  /// fondo" ripartiva la scena piena col simbolo e le frasi, la conversazione
  /// si accorciava sotto, e sembrava di essere tornati indietro. La scena e'
  /// per una risposta che ancora non esiste; il seguito invece scende sotto
  /// un testo che la persona sta leggendo, e mentre lo legge non le si toglie
  /// lo schermo.
  bool get mostraLaScenaDiAttesa => _sending && !_seguitoInVolo;

  /// Vero se il Maestro puo' rispondere davvero. Falso quando l'AI non e'
  /// configurata: la UI mostra un avviso in tono, non un errore.
  bool get aiReady => _ai.isReady;

  /// **DOVE FINISCE UN TURNO DI CHAT, ordine CI voce 06 vincolo d.**
  ///
  /// **Il buco trovato verificando invece di dare per scontato.** L'ordine
  /// chiedeva che una conversazione chiusa restasse raggiungibile dai Ricordi
  /// costruiti da CG, e di **verificare che ci arrivi davvero, non che
  /// dovrebbe arrivarci**. Verificato: nei Ricordi esistono
  /// `TipoDelRicordo.conversazione` e il filtro `Conversazioni`, e **nessuno
  /// ci scriveva niente**. La pastiglia era vuota per costruzione, e dopo un
  /// "Ricomincia" la conversazione di prima sarebbe stata irraggiungibile.
  ///
  /// E' la stessa famiglia del custode delle push: una cosa dichiarata,
  /// provata, e non agganciata a niente.
  ///
  /// **Una funzione e non il registro**, perche' il controllore non deve
  /// conoscere Firestore ne' i provider: chi lo costruisce sa dove scrivere.
  /// Nulla nelle prove, e allora non si scrive niente.
  final void Function(ChatMessage domanda)? segnaNeiRicordi;

  int _turnsSinceDistill = 0;

  /// **LA CONVERSAZIONE CORRENTE. Ordine CI voce 06.**
  ///
  /// Nulla vuol dire la prima, quella di sempre: e' il valore che hanno tutti
  /// i messaggi scritti prima di questa voce.
  String? _conversazione;
  String? get conversazione => _conversazione;

  /// **APRE UNA CONVERSAZIONE NUOVA, e non e' un comando di pulizia.**
  ///
  /// Cosa fa: da qui in avanti i messaggi portano una marcatura nuova, e a
  /// schermo la chat riparte pulita.
  ///
  /// **Cosa NON fa, ed e' la parte che conta.**
  ///
  /// 1. **Non cancella niente.** I messaggi di prima restano dove sono, e
  ///    restano leggibili: si ritrovano dai Ricordi del Cerchio, che li hanno
  ///    indicizzati turno per turno.
  /// 2. **Non azzera la memoria del Maestro.** `_memoryState` non si tocca:
  ///    la memoria e' la cosa per cui l'abbonato paga, e un comando che la
  ///    spegnesse senza dirlo sarebbe il difetto piu' costoso dell'app. Il
  ///    Maestro dimentica il FILO del discorso, non la persona.
  /// 3. **Non consuma nessuna domanda.** Non passa dal budget del giorno:
  ///    cominciare a parlare non e' parlare.
  ///
  /// **Zero letture e zero scritture.** La marcatura viaggia col prossimo
  /// messaggio: finche' non si scrive niente, non e' successo niente.
  void iniziaUnaConversazioneNuova({DateTime? adesso}) {
    final quando = adesso ?? DateTime.now();
    _mettiInArchivio();
    _conversazione = 'c${quando.millisecondsSinceEpoch}';
    _messages.clear();
    _turnsSinceDistill = 0;
    _aggiornaLePassate();
    notifyListeners();
  }

  /// **RIAPRE UNA CONVERSAZIONE PASSATA. Ordine DZ voce 03.** Come una
  /// chatbot: dal menu' si tocca il titolo e la chat torna a quel filo, coi
  /// suoi messaggi, e da li' si continua. Zero letture: i messaggi sono gia'
  /// nell'archivio da cui il menu' e' stato composto.
  void apriLaConversazione(String? id) {
    if (LeConversazioniPassate.chiave(id) ==
        LeConversazioniPassate.chiave(_conversazione)) {
      return;
    }
    _mettiInArchivio();
    _conversazione = id;
    _messages
      ..clear()
      ..addAll(_chiudiIVoli(LeConversazioniPassate.di(_archivio, id)));
    _turnsSinceDistill = 0;
    _aggiornaLePassate();
    notifyListeners();
  }

  /// **CANCELLA UNA CONVERSAZIONE PASSATA. Ordine EA voce 07.** Esce subito
  /// dal menu' e dal telefono; sul server la toglie la funzione
  /// `cancellaLaConversazione`. Se il server non risponde, il telefono la
  /// tiene nascosta, e non torna alla prossima apertura.
  Future<void> cancellaLaConversazione(String? id) async {
    final k = LeConversazioniPassate.chiave(id);
    _nascoste = {..._nascoste, k};
    _archivio = [
      for (final m in _archivio)
        if (LeConversazioniPassate.chiave(m.conversazione) != k) m,
    ];
    _aggiornaLePassate();
    notifyListeners();
    await LeConversazioniPassate.nascondi(maestro, id);
    try {
      await _memory.cancellaLaConversazione(maestro, id);
    } catch (errore, traccia) {
      annotaGuastoInnocuo(
          'cancellando una conversazione con '
          '${maestro.displayName}',
          errore,
          traccia);
    }
  }

  /// I messaggi detti in questa sessione entrano nell'archivio prima di
  /// cambiare conversazione, altrimenti quella appena lasciata sparirebbe
  /// dal menu' fino alla prossima apertura della chat.
  void _mettiInArchivio() {
    String firma(ChatMessage m) =>
        '${m.role.name}|${m.at?.millisecondsSinceEpoch}|${m.text}';
    final gia = {for (final m in _archivio) firma(m)};
    final nuovi = [
      for (final m in _messages)
        if (!m.pending && !gia.contains(firma(m))) m,
    ];
    if (nuovi.isEmpty) return;
    _archivio = [..._archivio, ...nuovi]..sort((a, b) {
        final x = a.at, y = b.at;
        if (x == null || y == null) return 0;
        return x.compareTo(y);
      });
  }

  void _aggiornaLePassate() {
    _passate = LeConversazioniPassate.raccogli(
      _archivio,
      titoli: _titoliScritti,
      corrente: _conversazione,
      nascoste: _nascoste,
    );
  }

  /// **L'ARCHIVIO SI LEGGE UNA VOLTA, dopo l'apertura, e non la trattiene.**
  /// Centocinquanta messaggi bastano per cinque conversazioni; un guasto qui
  /// lascia il menu' con le sole voci di sempre, mai una chat che non parte.
  Future<void> _caricaLePassate() async {
    try {
      final letti = await _memory.recentMessages(maestro,
          limit: LeConversazioniPassate.messaggiDaLeggere);
      _archivio = CronologiaSenzaDoppioni.di(letti);
      _titoliScritti = await LeConversazioniPassate.titoli(maestro);
      _nascoste = await LeConversazioniPassate.nascoste(maestro);
      _mettiInArchivio();
      _aggiornaLePassate();
      notifyListeners();
    } catch (errore, traccia) {
      annotaGuastoInnocuo(
          'raccogliendo le conversazioni passate di '
          '${maestro.displayName}',
          errore,
          traccia);
    }
  }

  /// **IL TITOLO, DOPO LA PRIMA RISPOSTA VERA. Ordine DZ voce 04.** Una volta
  /// per conversazione: se c'e' gia', non si richiama il modello.
  Future<void> _forseIlTitolo() async {
    final id = _conversazione;
    final k = LeConversazioniPassate.chiave(id);
    if (_titoliScritti.containsKey(k) || !_titoliInCorso.add(k)) return;
    try {
      final domanda = _messages.firstWhere((m) => m.isUser,
          orElse: () => const ChatMessage(role: ChatRole.user, text: ''));
      final risposta = _messages.firstWhere(
          (m) => m.isMaestro && m.portaUnResponso,
          orElse: () => const ChatMessage(role: ChatRole.maestro, text: ''));
      if (domanda.text.isEmpty || risposta.text.isEmpty) return;
      final scritto = LeConversazioniPassate.pulisci(await _titoli.scrivi(
          maestro: maestro, domanda: domanda.text, risposta: risposta.text));
      if (scritto == null) return;
      await LeConversazioniPassate.salvaIlTitolo(maestro, id, scritto);
      _titoliScritti = {..._titoliScritti, k: scritto};
      _aggiornaLePassate();
      notifyListeners();
    } finally {
      _titoliInCorso.remove(k);
    }
  }

  /// **I MESSAGGI DELLA CONVERSAZIONE CORRENTE, e nient'altro.**
  ///
  /// Si taglia dalla coda: la cronologia arriva dal piu' recente al piu'
  /// vecchio, e appena compare un messaggio di un'altra conversazione si
  /// smette. **Nessuna lettura in piu'**: e' lo stesso `limit(40)` di sempre,
  /// filtrato a schermo.
  List<ChatMessage> _soloLaCorrente(List<ChatMessage> tutti) {
    if (_conversazione == null) {
      // Prima conversazione: si tengono i messaggi senza marcatura e quelli
      // marcati non esistono ancora.
      return tutti;
    }
    return [
      for (final m in tutti)
        if (m.conversazione == _conversazione) m,
    ];
  }

  /// Carica profilo, memoria e cronologia recente all'apertura della chat.
  Future<void> init() async {
    try {
      final results = await Future.wait([
        _memory.loadProfile(),
        _memory.loadMemory(maestro),
        _memory.recentMessages(maestro),
      ]);
      _profile = results[0] as UserProfile;
      _memoryState = results[1] as MaestroMemory;
      // **CIO' CHE LA MEDITAZIONE RICORDA ENTRA QUI, E IN UN PUNTO SOLO.**
      // Ordine DB voce 08, 9 settembre 2026.
      //
      // **Il censimento che l'ordine chiede**: il contesto passato al modello
      // si compone in **otto punti** di questo file, e sono otto chiamate con
      // gli stessi quattro parametri, profilo, memoria, cronologia e cielo di
      // nascita. Aggiungere un quinto parametro vorrebbe dire toccarli tutti
      // e otto, e **al primo che qualcuno dimentica due Maestri saprebbero
      // cose diverse della stessa persona**, che e' proprio il difetto che
      // l'ordine teme.
      //
      // **Allora non si aggiunge un parametro: il riassunto entra fra i
      // FATTI**, che al modello arrivano gia' da tutte e otto le strade. Il
      // dato grezzo resta sul telefono, dove nasce; qui passa una riga sola,
      // ed e' cio' che la voce chiede per nome: *"non il dato grezzo di ogni
      // sessione: il riassunto, breve, in una forma che il modello possa
      // usare senza doverla interpretare"*.
      //
      // **Vale per tutti e tre i Maestri e non solo per Aura**, perche' questo
      // controllore e' lo stesso per tutti: Medora che parla di un transito
      // difficile sapendo che la persona respira tutte le sere conosce chi ha
      // davanti.
      // **E LA CHAT NON ASPETTA IL RESPIRO, ed e' una correzione di oggi.**
      //
      // La prima stesura metteva `await _respiro.carica()` qui, sul percorso
      // che apre la chat. **Undici prove sono diventate rosse**, e non per un
      // giro d'attesa in piu': in `flutter test` senza il finto archivio,
      // `SharedPreferences.getInstance()` **non completa mai**, quindi l'apertura
      // restava appesa e il Maestro taceva. Fra quelle prove c'era proprio
      // quella che pretende che un Maestro non resti mai muto.
      //
      // **Nessuna funzione dell'app puo' tenere in ostaggio l'apertura della
      // chat per un dato che le e' solo utile.** Il riassunto arriva quando
      // arriva, si aggiunge ai fatti e la scena si aggiorna: se il telefono
      // e' lento, il primo turno parte senza e il secondo ce l'ha.
      unawaited(_respiro.carica().then((_) {
        final riassunto = _respiro.riassuntoPerIMaestri;
        if (riassunto.isEmpty) return;
        _memoryState = _memoryState.copyWith(
          facts: [..._memoryState.facts, 'Pratica del respiro: $riassunto'],
        );
        notifyListeners();
      }));
      // **SENZA I DOPPIONI CHE LA CODA HA LASCIATO.** Ordine DV: dall'11
      // agosto al 18 settembre 2026 la coda verso il server mandava le
      // domande due volte, e il server le ha scritte due volte. Si leggono
      // una volta sola, sia a schermo sia nel contesto che torna al modello.
      final cronologia =
          CronologiaSenzaDoppioni.di(results[2] as List<ChatMessage>);
      _cronologiaCaricata = cronologia;
      // **LA CONVERSAZIONE CORRENTE E' QUELLA DEL MESSAGGIO PIU' RECENTE.**
      // Ordine CI voce 06: non si conserva da nessuna parte, si legge da cio'
      // che c'e' gia'. Un posto in piu' dove tenerla sarebbe un secondo conto
      // della stessa cosa.
      _conversazione =
          cronologia.isEmpty ? null : cronologia.last.conversazione;
      _messages
        ..clear()
        ..addAll(_chiudiIVoli(_soloLaCorrente(cronologia)));
      // **DA UN APPROFONDIMENTO SI COMINCIA PULITI. Ordine DZ voce 01.** La
      // conversazione appena letta resta nell'archivio, quindi nel menu'.
      if (conversazioneNuova) {
        _archivio = [...cronologia];
        _conversazione = 'c${_adesso.millisecondsSinceEpoch}';
        _messages.clear();
      }
      unawaited(_caricaLePassate());
      await _caricaCioCheSannoGliAltri();
    } catch (errore, traccia) {
      // Un errore di lettura non deve impedire di iniziare a parlare, ma non
      // deve nemmeno sparire: senza annotazione una memoria che non si carica
      // mai e' indistinguibile da una memoria vuota.
      annotaGuastoInnocuo(
          'caricando la memoria di ${maestro.displayName}', errore, traccia);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Legge cio' che la persona ha detto agli altri due Maestri. Ordine EN
  /// voce 09. Vale la stessa legge della memoria: la ricorda chi ha un piano
  /// con la memoria, e la demo.
  Future<void> _caricaCioCheSannoGliAltri() async {
    final piano = _tier?.call();
    final memoriaViva = _demo || piano == null || PlanCatalog.haMemoria(piano);
    if (!memoriaViva) return;
    final altri = [
      for (final m in Maestro.values)
        if (m != maestro) m
    ];
    final letti = await Future.wait([
      for (final altro in altri)
        _memory
            .recentMessages(altro, limit: IRicordiDegliAltri.messaggiDaLeggere)
            .then<List<ChatMessage>>((m) => m)
            .catchError((Object errore, StackTrace traccia) {
          annotaGuastoInnocuo(
              'leggendo ciò che la persona ha detto a ${altro.displayName}',
              errore,
              traccia);
          return const <ChatMessage>[];
        }),
    ]);
    _ricordiDegliAltri = [
      for (var i = 0; i < altri.length; i++)
        ...IRicordiDegliAltri.righe(
            altri[i], CronologiaSenzaDoppioni.di(letti[i]),
            adesso: _adesso),
    ];
  }

  /// **LA DOMANDA AL MODELLO, CON CIO' CHE IL TURNO CHIEDE.** Ordine EN voci
  /// 01 e 06: nel LIVE la misura della voce, e la risposta da non ripetere,
  /// viaggiano nella zona della chiamata (`LaRichiestaDelTurno`).
  Future<String> _chiediAlMaestro({
    required Maestro chi,
    required List<ChatMessage> storia,
    required String domanda,
    required NatalContext natal,
    bool insisti = false,
    String? daNonRipetere,
    String? daProgramma,
  }) =>
      LaRichiestaDelTurno(
        nelLive: nelLive,
        daNonRipetere: daNonRipetere,
        daProgramma: daProgramma,
        suTesto: nelLive ? _mostraMentreArriva : null,
      ).per(() => _ai.reply(
            maestro: chi,
            profile: _profile,
            memory: _memoriaPerIlModello,
            history: storia,
            userMessage: domanda,
            natal: natal,
            insistiSullAncoraggio: insisti,
          ));

  @override
  void dispose() {
    testoInArrivo.dispose();
    super.dispose();
  }

  void _mostraMentreArriva(String scrittoFinora) {
    testoInArrivo.value =
        scrittoFinora.replaceAll(RegExp(r'\[\[[A-Z]+\]\]'), '').trimLeft();
  }

  /// NESSUN TURNO TORNA IN ATTESA.
  ///
  /// Un turno salvato come in attesa vuol dire una cosa sola: l'app si e'
  /// chiusa mentre quella risposta era in volo. Riaprendo non puo' restare in
  /// attesa, perche' aspetterebbe per sempre qualcosa che nessuno sta piu'
  /// generando, e non puo' sparire, perche' allora la domanda resterebbe sola,
  /// che e' esattamente il difetto delle sette domande di fila.
  ///
  /// Si presenta per quello che e': interrotto, dichiarato, col suo Riprova.
  List<ChatMessage> _chiudiIVoli(List<ChatMessage> salvati) => [
        for (final m in salvati)
          if (m.isMaestro && m.pending)
            m.copyWith(
              text: RipiegoDelMaestro.interrottoDi(m.autoreEffettivo(maestro)),
              pending: false,
              failed: true,
              ripiego: true,
            )
          else
            m,
      ];

  // IL DISCLAIMER NON PASSA PIU' DA QUI, e non e' un pezzo tolto a meta'.
  //
  // C'erano `needsDisclaimer` e `acceptDisclaimer`: servivano alla
  // finestra modale che si apriva sopra la chat e che bisognava chiudere
  // per poter parlare col Maestro. Era uno di NOVE disclaimer a schermo,
  // e l'unico che sbarrava la strada. Adesso ne esiste uno solo,
  // nell'area privacy, e non ha bisogno di essere accettato: sta li' per
  // chi lo cerca.
  //
  // `disclaimerAcceptedAt` resta nel profilo: e' la data in cui una
  // persona vera ha accettato una cosa vera, e cancellarla sarebbe
  // riscrivere il passato.

  /// Invia un messaggio dell'utente e attende la risposta del Maestro.
  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _sending || _ricevendo) return;
    // **UN INVIO ALLA VOLTA, SU TUTTE LE STRADE.** Ordine DV. `_sending` si
    // alza soltanto dentro la generazione, quindi le strade che non generano,
    // cioe' gli instradamenti e la lettura gia' data, accettavano un secondo
    // invio mentre il primo era ancora in corso: un doppio tocco sul pannello
    // dei suggerimenti diventava due domande. Si alza qui, all'ingresso, e si
    // abbassa all'uscita qualunque strada si prenda.
    _ricevendo = true;
    try {
      await _ricevi(trimmed);
    } finally {
      _ricevendo = false;
    }
  }

  /// Vero mentre un invio della persona e' in corso, su qualunque strada.
  bool _ricevendo = false;

  Future<void> _ricevi(String trimmed) async {
    // **LA STESSA DOMANDA NELLO STESSO GIORNO: LA STESSA LETTURA.** Ordine DS
    // voce 08. Viene prima del limite del giorno: ridire una lettura gia' data
    // non costa niente e non chiama il modello, quindi non consuma una
    // domanda, e negarla a chi ha finito le domande sarebbe negargli cio' che
    // ha gia' ricevuto.
    final giaData = LaLetturaDelGiorno.giaData(
      domanda: trimmed,
      messaggi: [..._cronologiaCaricata, ..._messages],
      oggi: _adesso,
    );
    if (giaData != null) {
      final domanda = ChatMessage(
        role: ChatRole.user,
        text: trimmed,
        at: _adesso,
        conversazione: _conversazione,
      );
      _messages.add(domanda);
      unawaited(_persist(domanda));
      segnaNeiRicordi?.call(domanda);
      final ridetta = ChatMessage(
        role: ChatRole.maestro,
        text: LaLetturaDelGiorno.ridetta(giaData, maestro),
        at: _adesso,
        autore: maestro,
        conversazione: _conversazione,
      );
      _messages.add(ridetta);
      unawaited(_persist(ridetta));
      lettureRidette++;
      notifyListeners();
      _applicaIlCosto(EsitoDelTurno.letturaGiaData);
      return;
    }

    // Il limite del giorno vale su TUTTE le strade con cui si fa una domanda.
    // La schermata "Chiedi" consultava il contatore, la chat no: chi apriva la
    // chat aveva domande infinite qualunque piano avesse, cioe' il limite era
    // promesso e non imposto.
    final piano = _tier?.call();
    final contatore = _allowance;
    // Nel LIVE il limite delle domande non vale: vale quello dei minuti, che
    // il server ha gia' controllato aprendo la sessione.
    if (!nelLive &&
        piano != null &&
        contatore != null &&
        !contatore.canAsk(piano)) {
      _messages.add(ChatMessage(
        role: ChatRole.maestro,
        // La frase viene dal DATO, e il numero pure: se domani il limite
        // diventa cinque, la frase lo dice da sola. Ed e' diversa per i tre
        // Maestri, perche' e' il messaggio che l'utente gratuito vede piu'
        // spesso di ogni altro.
        text: FraseDelLimite.per(maestro, limite: contatore.dailyLimit(piano)),
        at: DateTime.now(),
        tipo: TipoDiMessaggio.limiteRaggiunto,
      ));
      notifyListeners();
      _applicaIlCosto(EsitoDelTurno.limiteRaggiunto);
      return;
    }

    final priorHistory = List<ChatMessage>.of(_messages);
    final userMessage = ChatMessage(
      role: ChatRole.user,
      text: trimmed,
      at: _adesso,
      // La marcatura viaggia col messaggio: e' cosi' che una conversazione
      // nuova comincia a esistere, senza scrivere niente prima.
      conversazione: _conversazione,
    );
    _messages.add(userMessage);
    unawaited(_persist(userMessage));
    // **IL TURNO ENTRA NEI RICORDI, ordine CI voce 06 vincolo d.** Si segna
    // la DOMANDA e non la risposta: e' quello che la persona riconosce
    // scorrendo la sua storia, ed e' anche cio' su cui la ricerca dei Ricordi
    // lavora, perche' Firestore non sa cercare dentro un testo lungo.
    segnaNeiRicordi?.call(userMessage);

    // Instradamento: se la persona CHIEDE un'esperienza immersiva dedicata,
    // aprirla e' la risposta nel merito, e il Maestro la apre senza chiamare
    // l'AI e senza consumare la domanda del giorno. Il costo e la quota
    // vivono dentro la funzione immersiva, con le sue regole.
    //
    // **NOMINARE UN'ARTE NON E' CHIEDERLA. Ordine EB voce 03.** Il cancello
    // sta in `LaRichiestaDiUnArte`: qui bastava la presenza della parola, e
    // *"non voglio una stesa"* apriva la Stesa come *"fammi una stesa"*.
    final nominata = _classifier.riconosci(maestro, trimmed);
    // **UN RIFIUTO VALE PER TUTTA LA CONVERSAZIONE. Ordine EB voce 05.** Il
    // fondatore ha detto di non volere una stesa e se l'e' vista offrire di
    // nuovo, con la stessa identica frase. Da qui in avanti un'arte rifiutata
    // resta chiusa: il Maestro risponde, e basta.
    if (nominata?.modo == ModoDiNominareUnArte.rifiuto) {
      _artiRifiutate.add(nominata!.intento.id);
    }
    final intent = nominata?.modo == ModoDiNominareUnArte.richiesta &&
            !_artiRifiutate.contains(nominata!.intento.id) &&
            !_invitoGiaDato(nominata.intento.id)
        ? nominata.intento
        : null;
    if (intent != null) {
      final invite = ChatMessage(
        role: ChatRole.maestro,
        // **LA CARTA DEL GIORNO SI NOMINA. Ordine DS voce 08.** Per la carta
        // l'invito non e' una frase fissa: dice QUALE carta, la stessa del
        // Dono, perche' la persona l'ha chiesta e non va rimandata altrove
        // per sapere il nome.
        text: intent.target == ImmersiveTarget.arcanoDellAlba
            ? LaCartaDelGiornoInChat.invito(
                await ArchivioDellAlba.diOggi(_adesso))
            : intent.invite,
        at: DateTime.now(),
        intentId: intent.id,
      );
      _messages.add(invite);
      unawaited(_persist(invite));
      notifyListeners();
      // **L'ESITO SI COSTRUISCE, non si nomina in un commento.** Ordine
      // EB voce 04: qui c'era il nome di un valore che nessuno
      // produceva, e a tenere in piedi la regola era il `return`.
      _applicaIlCosto(EsitoDelTurno.instradamento);
      return;
    }

    // NON si consuma qui. Si consumava PRIMA di generare, quindi un guasto
    // costava una domanda: il 2 agosto un ripiego si e' preso l'unica domanda
    // del giorno. Adesso decide l'ESITO, e la regola vive in CostoDelTurno.
    final esito = await _generate(
      priorHistory: priorHistory,
      userText: trimmed,
    );
    // **Anche questa strada passa dal punto unico.** Qui si addebitava a
    // mano, e il LIVE, che il costo lo spegne in `_applicaIlCosto`, pagava lo
    // stesso ogni turno detto a voce con una domanda del giorno: il fondatore
    // si e' trovato senza domande dopo una prova a voce. Ordine EG voce 06.
    _applicaIlCosto(esito);
    // Il titolo nasce dopo una risposta vera, e mai sulla strada del turno:
    // chi aspetta la risposta non aspetta anche il titolo.
    if (CostoDelTurno.consuma(esito)) unawaited(_forseIlTitolo());
  }

  /// Vero se l'ultima bolla e' una risposta VERA del Maestro, non ancora
  /// approfondita: solo li' l'invito ha senso. Non su un ripiego, non su una
  /// bolla fallita, non su un instradamento.
  /// Le voci che hanno gia' risposto in questa conversazione.
  List<Maestro> get vociDelCerchio => AltreVoci.vociNella(_messages, maestro);

  /// Vero se ha senso chiedere anche agli altri: c'e' una lettura VERA da cui
  /// partire, e almeno una voce non si e' ancora espressa.
  ///
  /// La prima meta' della regola non e' nuova ed e' la stessa di "Vai piu' a
  /// fondo": vive nel dato del messaggio, `portaUnResponso`. Sotto un ripiego,
  /// sotto una risposta tronca e sotto il messaggio del limite non c'e' niente
  /// da portare a nessuno.
  bool get puoiChiedereAgliAltri {
    if (_sending || _messages.isEmpty) return false;
    if (!_messages.last.isMaestro || !_messages.last.portaUnResponso) {
      return false;
    }
    return AltreVoci.altriDi(maestro)
        .any((altro) => !vociDelCerchio.contains(altro));
  }

  /// L'ultima domanda della persona, che e' quella a cui rispondono gli altri.
  String? get ultimaDomanda {
    for (var i = _messages.length - 1; i >= 0; i--) {
      if (_messages[i].isUser && _messages[i].text.trim().isNotEmpty) {
        return _messages[i].text.trim();
      }
    }
    return null;
  }

  /// Porta la STESSA domanda alle altre due voci, qui dentro.
  ///
  /// **Non ricomincia niente.** Le risposte arrivano come bolle nuove sotto
  /// quella appena letta, ognuna col suo autore: nessuna schermata nuova,
  /// nessuna domanda da riscrivere.
  ///
  /// **Ognuno riceve la domanda, non il filo.** Chi non era nella
  /// conversazione non puo' rispondere come se ci fosse stato: passargli i
  /// turni gia' avvenuti lo farebbe commentare la lettura di un altro invece di
  /// darne una sua, e un confronto fra una voce e l'eco di un'altra non e' un
  /// confronto. E' la stessa indipendenza che la schermata della sintesi ha
  /// sempre avuto fra le sue lenti.
  ///
  /// **Non intacca il limite del giorno**, esattamente come il confronto di
  /// oggi: il costo si decide fuori da `_generate`, quindi qui basta non
  /// chiederlo. Il gating del piano lo tiene la schermata, che e' dove vive gia'.
  // IL METODO CHE INCOLLAVA LE ALTRE VOCI QUI DENTRO E' STATO TOLTO.
  //
  // Chiedeva la stessa domanda agli altri due Maestri e le loro risposte
  // finivano in QUESTA conversazione: negli screenshot del fondatore la chat
  // di Medora conteneva bolle rosse di Caligo e verdi di Aura. Nella chat di
  // un Maestro parla soltanto quel Maestro, sempre, e le altre voci si
  // ascoltano nel Consiglio dei Maestri.
  /// Vero quando a questa persona, oggi, si puo' scrivere la lettura intera.
  ///
  /// **Il budget degli approfondimenti non e' sparito: si e' spostato.** Prima
  /// contava quante volte al giorno si poteva chiedere al modello una SECONDA
  /// risposta, e si consumava al tocco della freccia. Adesso decide quante
  /// letture INTERE si producono, e si consuma quando la lettura arriva.
  ///
  /// Il posto conta. Contarlo al tocco vorrebbe dire scrivere centottanta
  /// parole e poi negarne centotrenta a chi le ha gia' nel telefono: il piano
  /// e il giorno governano cio' che si SCRIVE, e tutto cio' che e' scritto si
  /// legge. Cosi' la riga del listino resta vera e nessuno paga per parole che
  /// non vedra'.
  /// SE LA FRECCIA SI VEDE. **Si vede sempre**, e non e' un muro.
  ///
  /// **Non dipende piu' dal piano, ed e' una correzione.** Nell'ordine
  /// precedente il secondo strato era diventato accessibile a chiunque, perche'
  /// il budget era stato spostato a governare la produzione invece
  /// dell'accesso: a un Viandante si chiedevano cinquanta parole, ma il modello
  /// non obbedisce al numero e ci si avvicina da sopra, quindi con
  /// settantatre parole il secondo strato esisteva davvero e nessuno
  /// controllava il piano al momento del tocco. Misurato.
  ///
  /// Adesso il piano governa di nuovo l'ACCESSO, e lo fa altrove: qui si
  /// decide solo se la freccia ESISTE. Si vede a tutti, perche' un lucchetto
  /// muto e' un vicolo cieco: chi non ha il secondo strato nel piano, al tocco,
  /// arriva agli abbonamenti.
  bool get puoiChiedereDiApprofondire {
    if (_sending || _messages.isEmpty) return false;
    final ultima = _messages.last;
    // La regola vive nel DATO del messaggio, non qui: `portaUnResponso` sa da
    // solo che una frase sul limite raggiunto non e' una lettura.
    return ultima.isMaestro &&
        !ultima.pending &&
        ultima.portaUnResponso &&
        !ultima.approfondita;
  }

  /// SE QUESTA PERSONA, OGGI, PUO' LEGGERE IL SECONDO STRATO.
  ///
  /// **Un solo meccanismo, quello che esiste gia'.** `puoiApprofondire` legge
  /// `PlanCatalog`, cioe' la stessa matrice che dice chi ha la memoria dei
  /// Maestri e chi ha la profondita' dell'oroscopo. Scriverne un secondo
  /// accanto vorrebbe dire due sistemi che decidono chi puo' cosa, e due
  /// sistemi cosi' divergono sempre.
  ///
  /// Viandante no. Iniziato tre al giorno, Adepto dieci, Illuminato senza
  /// limite col tetto di correttezza. **E il conto sta sull'ACCESSO, non sulla
  /// produzione**: si consuma quando la persona legge, non quando il Maestro
  /// scrive.
  bool get puoiLeggereIlSecondoStrato {
    final piano = _tier?.call();
    final contatore = _allowance;
    if (piano == null || contatore == null) return true;
    return contatore.puoiApprofondire(piano);
  }

  /// Se il piano di questa persona comprende il secondo strato, a prescindere
  /// da quanti ne restano oggi. Serve a distinguere DUE cose che non vanno
  /// confuse: chi non ce l'ha riceve l'invito a salire, chi ce l'ha e li ha
  /// finiti riceve il numero vero e l'ora in cui torna.
  bool get ilPianoComprendeIlSecondoStrato {
    final piano = _tier?.call();
    final contatore = _allowance;
    if (piano == null || contatore == null) return true;
    return contatore.pianoConApprofondimento(piano);
  }

  /// CHIEDE AL MAESTRO IL SEGUITO, cioe' SOLO il testo che manca.
  ///
  /// **Perche' si genera adesso e non prima.** Se un Premium non tocca mai la
  /// freccia, la spesa per il testo lungo e' gia' stata sostenuta per niente.
  /// I numeri stanno in `MisuraDellaRisposta.seguito`: il pareggio e' intorno
  /// all'11,5 per cento di risposte approfondite, e quel numero non lo
  /// sappiamo.
  ///
  /// **Non e' la risposta rifatta.** Il modello riceve cio' che ha gia' detto
  /// e continua da li', quindi resta coerente con l'elemento oracolare gia'
  /// consegnato, la runa o la carta, che sta dentro quel testo. E cio' che
  /// torna viene ripulito dalle frasi gia' lette: l'istruzione dice di non
  /// ripetersi, e un'istruzione non e' una garanzia.
  ///
  /// **FUNZIONA ANCHE SE IL LIVELLO E' CAMBIATO DOPO LA DOMANDA**, ed e' il
  /// percorso vero: da Viandante si tocca la freccia, si arriva agli
  /// abbonamenti, ci si abbona, si torna indietro e si ritocca. Con la
  /// generazione del seguito quel percorso funziona sempre, perche' non serve
  /// che il testo lungo esistesse gia'.
  Future<void> approfondisci() async {
    if (!puoiChiedereDiApprofondire) return;
    // Il piano decide QUI, e il livello si rilegge adesso: chi si e' abbonato
    // un istante fa lo trova gia' cambiato.
    if (!puoiLeggereIlSecondoStrato) return;

    final indice = _messages.length - 1;
    final prima = _messages[indice];
    final domanda = indice > 0 && _messages[indice - 1].isUser
        ? _messages[indice - 1].text
        : null;
    if (domanda == null) return;

    _sending = true;
    _seguitoInVolo = true;
    // IL TESTO GIA' LETTO NON SI TOCCA.
    //
    // Qui il messaggio veniva sostituito con uno vuoto in attesa: il primo
    // strato spariva da sotto gli occhi di chi lo stava leggendo, per tornare
    // qualche secondo dopo. Adesso resta dov'e', e porta soltanto il segno che
    // sotto sta scendendo dell'altro.
    _messages[indice] = prima.copyWith(seguitoInArrivo: true);
    notifyListeners();

    try {
      final natal = _natal?.call() ?? NatalContext.none;
      final grezzo = await _ai.reply(
        maestro: prima.autoreEffettivo(maestro),
        profile: _profile,
        memory: _memoriaPerIlModello,
        history: _messages.sublist(0, indice - 1).toList(),
        userMessage: domanda,
        natal: natal,
        // CIO' CHE LA PERSONA HA GIA' LETTO, per intero: senza il corpo il
        // modello non saprebbe da dove continuare, e senza la riga finale
        // rischierebbe di riscriverla.
        rispostaGiaData: prima.text,
      );
      // L'APP CONTROLLA, invece di fidarsi dell'istruzione.
      final corpoGia = ConsiglioFinale.corpoDa(prima.text);
      final pulito =
          SeguitoDellaLettura.pulisci(gia: corpoGia, seguito: grezzo);
      frasiRipetuteNelSeguito +=
          SeguitoDellaLettura.quanteRipetute(gia: corpoGia, seguito: grezzo);
      if (pulito.trim().isEmpty) {
        // Un seguito che era tutto ripetizione non e' un seguito: si rimette
        // la risposta com'era, senza marcarla approfondita, cosi' la freccia
        // resta e la persona puo' riprovare. Nessun budget consumato.
        _messages[indice] = prima.copyWith(seguitoInArrivo: false);
        return;
      }
      final conSeguito = prima.copyWith(
          approfondita: true, seguito: pulito, seguitoInArrivo: false);
      _messages[indice] = conSeguito;
      // IL CONTO STA SULL'ACCESSO, e si paga quando il seguito arriva.
      final piano = _tier?.call();
      if (piano != null) _allowance?.registraApprofondimento(piano);
      await _sostituisci(conSeguito);
    } catch (errore, traccia) {
      // Il seguito fallito NON deve far perdere la risposta gia' letta: si
      // rimette quella com'era, e la freccia resta, perche' riprovare e'
      // esattamente cio' che una persona vuole fare qui.
      annotaGuastoInnocuo(
          'chiedendo il seguito a ${maestro.displayName}', errore, traccia);
      _messages[indice] = prima;
    } finally {
      _sending = false;
      _seguitoInVolo = false;
      // Il segno si spegne SEMPRE, anche quando il seguito non arriva: una
      // riga che dice "sta scendendo dell'altro" e resta li' per sempre e'
      // peggio di nessuna riga.
      if (indice < _messages.length && _messages[indice].seguitoInArrivo) {
        _messages[indice] = _messages[indice].copyWith(seguitoInArrivo: false);
      }
      notifyListeners();
    }
  }

  /// Quante frasi del seguito ripetevano cio' che era gia' stato letto, in
  /// questa sessione. Un numero che cresce dice che l'istruzione non regge, e
  /// va corretta nel prompt invece che nel filtro.
  int frasiRipetuteNelSeguito = 0;

  /// Riprova l'ultimo turno fallito, senza duplicare il messaggio dell'utente.
  Future<void> retryLast() async {
    if (_sending || _messages.isEmpty) return;
    final last = _messages.last;
    if (!(last.isMaestro && last.failed)) return;

    _messages.removeLast(); // toglie la bolla fallita
    if (_messages.isEmpty || !_messages.last.isUser) {
      notifyListeners();
      return;
    }
    final userText = _messages.last.text;
    final priorHistory = _messages.sublist(0, _messages.length - 1);
    final esito = await _generate(
      priorHistory: List<ChatMessage>.of(priorHistory),
      userText: userText,
    );
    // Un Riprova RIUSCITO costa, perche' il Maestro ha risposto davvero, e il
    // tentativo fallito che lo precede non aveva pagato niente: si paga una
    // domanda per una risposta, mai per un errore.
    _applicaIlCosto(esito);
  }

  /// Genera la risposta e dice COM'E' ANDATA. Restituisce l'esito invece di
  /// non restituire niente: chi chiama deve poter decidere se costa, e non puo'
  /// dedurlo guardando l'ultima bolla.
  Future<EsitoDelTurno> _generate({
    required List<ChatMessage> priorHistory,
    required String userText,
    Maestro? per,
  }) async {
    // CHI risponde a questo turno. Di norma il Maestro della chat; quando la
    // persona chiede anche agli altri, uno dei due altri, e la sua risposta
    // porta il SUO nome nel messaggio invece di prendere quello della
    // schermata.
    final chiRisponde = per ?? maestro;
    maestroInAscolto = chiRisponde;
    _sending = true;
    // LA PAUSA COMINCIA QUI, con la domanda, e non quando la rete risponde:
    // il tempo che conta e' quello che aspetta la persona.
    final cronometro = Stopwatch()..start();
    rotazioneDelConsulto++;
    // LA DOMANDA E IL SUO TURNO NASCONO INSIEME, E SI SALVANO INSIEME.
    //
    // **Il dato che ha fatto nascere questa regola.** Negli screenshot del
    // fondatore del 2 agosto 2026, riaprendo la chat si leggevano SETTE
    // domande di fila e nessuna risposta, come se avesse parlato al muro. La
    // causa: la domanda si salvava subito, il turno del Maestro solo quando la
    // risposta era VERA. Dei quattro punti in cui un turno si consegna, uno
    // solo passava dalla persistenza; ripiego, troncatura ed errore vivevano
    // nella sessione e morivano con l'app.
    //
    // Salvare alla fine non basta e non puo' bastare: se la fine non arriva,
    // perche' il sistema chiude l'app mentre la rete e' aperta, non c'e'
    // nessuna fine in cui salvare. Per questo il turno si salva QUI, in
    // attesa, e alla consegna si SOSTITUISCE invece di aggiungerne un altro.
    // Non esiste piu' uno stato in cui una domanda e' salvata e il suo turno
    // no.
    final pending = ChatMessage(
        role: ChatRole.maestro,
        text: '',
        pending: true,
        autore: chiRisponde,
        conversazione: _conversazione);
    _messages.add(pending);
    // **I TEMPI DEL TURNO, PEZZO PER PEZZO, NEL LIVE.** Ordine EM voce 11: il
    // fondatore aspetta "circa 4" secondi, e sul Realme la chat ne prendeva
    // da 3,1 a 4,7. Si scrive quanto costa ogni passo, perche' si sappia
    // quale accorciare.
    // **IL MODELLO NON ASPETTA PIU' IL SALVATAGGIO.** Ordine EN voce 01.
    var salvataInAttesa = -1;
    _salvataggioInAttesa = _persist(pending)
        .then((_) => salvataInAttesa = cronometro.elapsedMilliseconds);
    notifyListeners();

    try {
      final natal = _natal?.call() ?? NatalContext.none;
      final disponibili = VerificaAncoraggio.disponibiliPer(
        natal: natal,
        profile: _profile,
        memory: _memoriaPerIlModello,
      );

      // UNA RISPOSTA TRONCA NON SI CONSEGNA, e non si fa pagare.
      //
      // Il 2 agosto 2026 la chat consegnava "Un velo" come risposta compiuta,
      // prendendosi una delle tre domande del giorno. Adesso il provider lo
      // dichiara, e qui si riprova UNA volta sola: la seconda ha piu' spazio
      // per pura varianza, non perche' cambi la configurazione, quindi
      // insistere una terza volta sarebbe far aspettare la persona per un
      // difetto nostro. Se tronca di nuovo, la misura e' sbagliata, e va
      // corretta nel dato, non a forza di tentativi.
      // LA PRIMA RISPOSTA E' BREVE PER TUTTI, e il seguito si chiede al
      // tocco.
      //
      // Se un Premium non tocca mai la freccia, la spesa per il testo lungo
      // sarebbe gia' stata sostenuta per niente. Generare sempre intero costa
      // 2157 token a risposta, sempre; generare il seguito al tocco costa 1923
      // subito, piu' una seconda chiamata solo per chi approfondisce.
      String reply;
      try {
        reply = await _chiediAlMaestro(
          chi: chiRisponde,
          storia: priorHistory,
          domanda: userText,
          natal: natal,
        );
      } on MaestroAiTroncata {
        rigenerazioniPerTroncatura++;
        try {
          reply = await _chiediAlMaestro(
            chi: chiRisponde,
            storia: priorHistory,
            domanda: userText,
            natal: natal,
          );
        } on MaestroAiTroncata catch (errore, traccia) {
          troncatureConsegnate++;
          annotaGuastoInnocuo(
            'risposta tronca due volte di fila da ${chiRisponde.displayName}: '
            'la misura della risposta è troppo stretta',
            errore,
            traccia,
          );
          // Si consegna una lettura vera e DICHIARATA, come per ogni altro
          // silenzio della voce: meglio un ripiego riconoscibile che un
          // moncone scambiato per la parola del Maestro.
          await _consegna(
              pending.copyWith(
                text: LetturaDiRipiego.componi(
                  maestro: chiRisponde,
                  domanda: userText,
                  natal: natal,
                  profile: _profile,
                  memory: _memoriaPerIlModello,
                ),
                pending: false,
                failed: true,
                ripiego: true,
              ),
              cronometro);
          return EsitoDelTurno.rispostaTroncata;
        }
      }

      // IL CONTROLLO DELL'ANCORAGGIO, a valle e puro.
      //
      // Non scatta quando non c'e' niente da ancorare: senza dati di nascita
      // `disponibili` e' vuoto e `eAncorata` risponde sempre di si', perche'
      // pretendere un segno da chi non lo ha dato porterebbe a inventarlo, e un
      // ancoraggio falso e' peggio di nessun ancoraggio.
      //
      // UNA rigenerazione sola, mai due: alla seconda si consegna cio' che c'e'
      // e si registra. Far aspettare la persona una terza volta per una regola
      // nostra sarebbe farle pagare il nostro difetto.
      // **SOLO NELLA PRIMA RISPOSTA.** Ordine EJ voce 05: dopo, un dato
      // della persona torna solo se serve, e rigenerare chi non lo nomina
      // riportava i tre dati in ogni risposta.
      final primaRisposta = !priorHistory.any((m) => m.isMaestro);
      // **NEL LIVE NON SI RIGENERA PER L'ANCORAGGIO.** Ordine EN voce 01: la
      // seconda chiamata intera raddoppiava l'attesa di chi sta parlando e
      // ascoltando. La regola resta nell'istruzione, e il modello la segue
      // quasi sempre; nella chat scritta la rete resta.
      if (!nelLive &&
          primaRisposta &&
          !VerificaAncoraggio.eAncorata(reply, disponibili)) {
        rigenerazioniPerAncoraggio++;
        final secondo = await _chiediAlMaestro(
          chi: chiRisponde,
          storia: priorHistory,
          domanda: userText,
          natal: natal,
          insisti: true,
        );
        reply = secondo;
        if (!VerificaAncoraggio.eAncorata(secondo, disponibili)) {
          consegneSenzaAncoraggio++;
          annotaGuastoInnocuo(
            'risposta senza ancoraggio consegnata comunque, '
            '${chiRisponde.displayName}, ancoraggi disponibili: '
            '${disponibili.map((a) => a.nome).join(', ')}',
            StateError('ancoraggio mancante dopo una rigenerazione'),
          );
        }
      }

      // **UN MAESTRO NON PARLA DA PROGRAMMA. Ordine EN voce 06.** Nel
      // collaudo con Gemini vero, alla richiesta di riprovare, Calìgo ha
      // risposto "Non ho memoria delle conversazioni precedenti" con la
      // regola gia' scritta nell'istruzione. Una richiesta sola, nominando la
      // risposta da non dare; se anche la seconda parla da programma, resta
      // la prima e il guasto resta nel registro.
      if (LaRispostaDaProgramma.segno(reply) != null) {
        rigenerazioniPerProgramma++;
        final altra = await _chiediAlMaestro(
          chi: chiRisponde,
          storia: priorHistory,
          domanda: userText,
          natal: natal,
          daProgramma: reply,
        );
        if (LaRispostaDaProgramma.segno(altra) == null) {
          reply = altra;
        } else {
          annotaGuastoInnocuo(
            'risposta da programma consegnata comunque, '
            '${chiRisponde.displayName}',
            StateError('la risposta parla da programma dopo una seconda '
                'richiesta'),
          );
        }
      }

      // **UNA RISPOSTA GIA' DATA NON SI RIDA'. Ordine EN voce 06.** Medora ha
      // restituito al fondatore la stessa risposta parola per parola: la
      // regola nell'istruzione c'era e non e' bastata. Una richiesta sola,
      // nominando la risposta da non ripetere; se anche la seconda ricalca,
      // passa la meno simile e il guasto resta nel registro.
      final giaDate = [
        for (final m in priorHistory)
          if (m.isMaestro && m.portaUnResponso && m.text.trim().isNotEmpty)
            m.text
      ];
      final ripetuta = LaRispostaRipetuta.quale(reply, giaDate);
      if (ripetuta != null) {
        rigenerazioniPerRipetizione++;
        final altra = await _chiediAlMaestro(
          chi: chiRisponde,
          storia: priorHistory,
          domanda: userText,
          natal: natal,
          daNonRipetere: ripetuta,
        );
        if (LaRispostaRipetuta.inComune(altra, ripetuta) <
            LaRispostaRipetuta.inComune(reply, ripetuta)) {
          reply = altra;
        }
        if (LaRispostaRipetuta.quale(reply, giaDate) != null) {
          annotaGuastoInnocuo(
            'risposta ripetuta consegnata comunque, '
            '${chiRisponde.displayName}',
            StateError('la risposta ricalca una già data dopo una '
                'seconda richiesta'),
          );
        }
      }

      // **CHI DI DOVERE, SEMPRE. Ordine EN voce 08.** Se la persona ha
      // nominato un avvocato, un medico o il denaro e la risposta non le dice
      // a chi rivolgersi, la frase si aggiunge, con la voce di chi parla.
      reply = ChiDiDovere.conLaFrase(
          maestro: chiRisponde, domanda: userText, risposta: reply);

      // **IL CIELO DETTO E' IL CIELO CALCOLATO. Ordine DS voce 08.** Una frase
      // sulla Luna che il calcolo smentisce non arriva a schermo: il modello
      // interpreta il cielo, non lo decide.
      final smentite = IlCieloDetto.smentite(reply, adesso: _adesso);
      if (smentite.isNotEmpty) {
        frasiDelCieloSmentite += smentite.length;
        annotaGuastoInnocuo(
          'frasi sul cielo smentite dal calcolo nella risposta di '
          '${chiRisponde.displayName}: ${smentite.join('; ')}',
          StateError('cielo detto diverso dal cielo calcolato'),
        );
        reply = IlCieloDetto.senzaLeSmentite(reply, adesso: _adesso);
      }
      // **IL MARCATORE DEL CHIARIMENTO SI LEGGE QUI E NON ARRIVA A VIDEO.**
      // Ordine EI voce 02, 23 settembre 2026. Il Maestro dichiara lui quando
      // sta chiedendo invece di rispondere, mettendo `[[CHIEDO]]` in cima; si
      // decide il costo sul testo **con** il marcatore e si mostra quello
      // **senza**, cosi' la persona non vede mai un segno tecnico.
      final haChiesto = LaRispostaCheChiede.eUnaDomanda(reply);
      reply = LaRispostaCheChiede.senzaIlMarcatore(reply);
      final answer = ChatMessage(
        role: ChatRole.maestro,
        text: reply,
        at: _adesso,
        autore: chiRisponde,
      );
      final risposta = cronometro.elapsedMilliseconds;
      await _consegna(answer, cronometro);
      if (nelLive) {
        debugPrint('CHAT TEMPI: in attesa salvata a $salvataInAttesa ms, '
            'risposta del modello a $risposta ms, consegnata e salvata a '
            '${cronometro.elapsedMilliseconds} ms, ${reply.length} caratteri');
      }
      // NON si aggiunge: `_consegna` ha gia' completato il turno che esisteva.
      // Aggiungerlo qui lo scriverebbe due volte, e riaprendo la chat si
      // leggerebbe la stessa risposta di seguito a se stessa.
      _turnsSinceDistill++;
      unawaited(_maybeDistill());
      // **SE HA CHIESTO, NON HA ANCORA RISPOSTO.** Ordine EE voce 07,
      // decisione del fondatore: *"Nessun consumo finche' non risponde
      // davvero"*. Il criterio sta in `LaRispostaCheChiede` ed e' largo
      // apposta: in dubbio non si paga, perche' far pagare un malinteso e'
      // un danno per chi paga, e non farlo e' un danno per noi.
      return haChiesto
          ? EsitoDelTurno.chiarimentoChiesto
          : EsitoDelTurno.rispostaVera;
    } on MaestroAiUnavailable {
      await _consegna(
          pending.copyWith(
            text: RipiegoDelMaestro.nonConfiguratoDi(chiRisponde),
            pending: false,
            failed: true,
            ripiego: true,
          ),
          cronometro);
      return EsitoDelTurno.ripiego;
    } catch (errore, traccia) {
      // Il guasto e' gia' stato scritto nel registro da `VoceSorvegliata`, che
      // sta davanti a QUALUNQUE provider: qui non si inghiotte piu' niente, si
      // sceglie solo cosa mostrare. L'annotazione resta perche' l'errore vero
      // esista anche per chi guarda i log senza aprire il pannello.
      annotaGuastoInnocuo(
          'rispondendo nella chat di ${chiRisponde.displayName}',
          errore,
          traccia);
      // IL SILENZIO NON LASCIA A MANI VUOTE. Il Maestro non si scusa e basta:
      // consegna una lettura VERA costruita dai dati sul dispositivo, dichiarata
      // come lettura del cielo e non come la sua voce. Sotto, una via che porta
      // da qualche parte, dallo stesso instradamento deterministico che gia'
      // esiste. Dopo questa riga, nella chat non c'e' nessuno stato senza uscita.
      final natal = _natal?.call() ?? NatalContext.none;
      await _consegna(
          pending.copyWith(
            text: LetturaDiRipiego.componi(
              maestro: chiRisponde,
              domanda: userText,
              natal: natal,
              profile: _profile,
              memory: _memoriaPerIlModello,
            ),
            pending: false,
            failed: true,
            ripiego: true,
          ),
          cronometro);
      // L'attestazione fallita si distingue dagli altri guasti: non costa
      // niente lo stesso, ma chi legge il registro deve poterla riconoscere.
      return errore.toString().contains('attestation')
          ? EsitoDelTurno.erroreDiAttestazione
          : EsitoDelTurno.erroreGenerico;
    } finally {
      _sending = false;
      notifyListeners();
    }
  }

  Future<void> _persist(ChatMessage message) async {
    try {
      await _memory.appendMessage(maestro, message);
    } catch (errore, traccia) {
      // La cronologia persistente e' un di piu': un errore non blocca la chat.
      annotaGuastoInnocuo(
          'salvando un turno nella cronologia di ${maestro.displayName}',
          errore,
          traccia);
    }
  }

  /// LA DISTILLAZIONE E' PASSATA AI LOTTI SETTIMANALI. Ordine CG voce 09.
  ///
  /// **Quale decisione supera.** Fino all'ordine CG la conversazione si
  /// distillava ogni tre turni, dentro la chat, a spese di chi stava
  /// parlando. La voce CG.09 la sposta a un lavoro settimanale sul server, e
  /// il conto e' la ragione: a ogni conversazione costa circa 0,029 dollari
  /// per utente al mese, a lotti settimanali circa 0,0084, cioe' un terzo e
  /// mezzo in meno.
  ///
  /// **E non serve piu' qui, ed e' la parte che conta piu' del costo.** Il
  /// primo dei quattro strati dice che dentro la finestra le conversazioni
  /// entrano nel contesto PER INTERO, parola per parola: finche' i turni veri
  /// ci sono, una sintesi degli stessi turni non aggiunge niente. La sintesi
  /// serve DOPO la finestra, ed e' esattamente quando il lavoro settimanale
  /// l'ha gia' prodotta.
  ///
  /// **Il metodo resta e non chiama piu' il modello**: i fatti che arrivano
  /// dal server continuano ad aggiornare la memoria calda, e il turno in
  /// corso non paga niente.
  Future<void> _maybeDistill() async {
    // La memoria dei Maestri e' venduta come esclusiva dell'Iniziato in su, e
    // veniva distillata anche per il gratuito: il valore usciva senza che
    // nessuno lo avesse comprato.
    //
    // **IN DEMO LA MEMORIA E' ACCESA, ordine BG voce 03.** La demo esiste per
    // far vedere il prodotto vero, e il prodotto vero ricorda.
    final piano = _tier?.call();
    final memoriaViva = _demo || piano == null || PlanCatalog.haMemoria(piano);
    if (!memoriaViva) return;
    if (_turnsSinceDistill < _distillEvery) return;
    _turnsSinceDistill = 0;
    try {
      // **SI RILEGGE cio' che il server ha gia' sfocato, non si distilla di
      // nuovo.** Ordine CG voce 09: distillare qui cio' che il lavoro
      // settimanale ha gia' distillato vorrebbe dire pagare due volte lo
      // stesso riassunto.
      final digest = await _memory.sintesiSfocate(maestro);
      if (digest.isEmpty) return;
      _memoryState = _memoryState.copyWith(
        sessionSummary: digest.summary.isNotEmpty
            ? digest.summary
            : _memoryState.sessionSummary,
        facts: _mergeFacts(_memoryState.facts, digest.facts),
      );
      await _memory.saveMemory(maestro, _memoryState);
    } catch (errore, traccia) {
      // Nessun impatto sulla conversazione in corso.
      annotaGuastoInnocuo(
          'rileggendo la memoria di ${maestro.displayName}', errore, traccia);
    }
  }

  /// Unisce i fatti nuovi ai vecchi senza duplicati, tenendo i piu' recenti e
  /// un tetto ragionevole per non far crescere la memoria all'infinito.
  List<String> _mergeFacts(List<String> previous, List<String> fresh) {
    final seen = <String>{};
    final merged = <String>[];
    for (final f in [...fresh, ...previous]) {
      final key = f.trim().toLowerCase();
      if (key.isEmpty || seen.contains(key)) continue;
      seen.add(key);
      merged.add(f.trim());
      if (merged.length >= 12) break;
    }
    return merged;
  }

  /// Consegna il messaggio, ma NON prima che la pausa sia durata abbastanza.
  ///
  /// **La pausa la governa il turno, non il disegno.** Metterla nella vista
  /// avrebbe voluto dire una scena che finge di durare mentre sotto il testo
  /// e' gia' li': basta un rebuild e il trucco si vede. Qui invece il messaggio
  /// non esiste ancora, quindi non c'e' niente da nascondere.
  ///
  /// Vale per tutte e quattro le uscite del turno, la risposta vera, la
  /// troncatura, il ripiego e l'errore: **una risposta che fallisce non fa
  /// sparire la scena di colpo**, la fa arrivare al suo tempo come le altre.
  Future<void> _consegna(ChatMessage messaggio, Stopwatch da) async {
    // **Nel LIVE la scena non c'e', e la pausa sarebbe attesa pura.** Quattro
    // secondi di minimo a ogni turno detto a voce, anche quando Gemini ha
    // risposto in uno: al banco non si vedevano, perche' il telefono di
    // collaudo ha le animazioni spente e la pausa scende a 0,7. Ordine EG voce
    // 05, dopo la prova del fondatore: "la risposta arriva molti secondi dopo".
    final minima = nelLive
        ? Duration.zero
        : _attesaMinima ??
            (riduciMovimento
                ? TempiDellAttesa.durataMinimaRidotta
                : TempiDellAttesa.durataMinima);
    final mancante = minima.inMilliseconds - da.elapsedMilliseconds;
    if (mancante > 0) {
      await Future<void>.delayed(Duration(milliseconds: mancante));
    }
    ultimaAttesaMs = da.elapsedMilliseconds;
    _replaceLast(messaggio);
    // OGNI consegna passa di qui, non solo quella riuscita: il ripiego, la
    // troncatura e l'errore sono turni quanto una lettura vera, e riaprendo
    // devono esserci.
    // **PRIMA IL TURNO IN ATTESA, POI LA SUA SOSTITUZIONE.** Ordine EN voce
    // 01: il turno in attesa si salva in parallelo al modello, e qui lo si
    // aspetta, perche' la sostituzione non arrivi prima di lui.
    final inAttesa = _salvataggioInAttesa;
    _salvataggioInAttesa = null;
    Future<void> salva() async {
      if (inAttesa != null) await inAttesa;
      await _sostituisci(messaggio);
    }

    // **NEL LIVE LA VOCE NON ASPETTA FIRESTORE.** Ordine EN voce 01: la
    // voce partiva dopo il salvataggio della risposta, da 250 a 300
    // millesimi sul Realme. Il salvataggio continua dietro, nello stesso
    // ordine.
    if (nelLive) {
      unawaited(salva());
    } else {
      await salva();
    }
  }

  /// Completa nella cronologia il turno che era rimasto in attesa.
  Future<void> _sostituisci(ChatMessage messaggio) async {
    try {
      await _memory.sostituisciUltimoMessaggio(maestro, messaggio);
    } catch (errore, traccia) {
      annotaGuastoInnocuo(
          'completando un turno nella cronologia di ${maestro.displayName}',
          errore,
          traccia);
    }
  }

  void _replaceLast(ChatMessage message) {
    if (_messages.isEmpty) {
      _messages.add(message);
    } else {
      _messages[_messages.length - 1] = message;
    }
  }
}
