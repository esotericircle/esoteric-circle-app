import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/entitlement/esito_del_turno.dart';
import '../../../core/entitlement/plan_catalog.dart';
import '../../../core/entitlement/question_allowance.dart';
import '../../../core/entitlement/tier.dart';

import '../../../core/chat/altre_voci.dart';
import '../../../core/chat/chat_message.dart';
import '../../../core/chat/intent_classifier.dart';
import '../../../core/chat/maestro_memory.dart';
import '../../../core/chat/user_profile.dart';
import '../../../core/maestro/ancoraggio.dart';
import '../../../core/maestro/frase_del_limite.dart';
import '../../../core/maestro/frase_di_ripiego.dart';
import '../../../core/maestro/tempi_dell_attesa.dart';
import '../../../core/maestro/lettura_di_ripiego.dart';
import '../../../core/maestro/natal_context.dart';
import '../../../core/maestro/maestro.dart';
import '../../../services/ai/maestro_ai_provider.dart';
import '../../../services/ai/registro_dei_guasti.dart';
import '../../../services/memory/maestro_memory_repository.dart';

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
    Duration? attesaMinima,
  })  : _ai = ai,
        _attesaMinima = attesaMinima,
        _memory = memory,
        _classifier = classifier,
        _allowance = allowance,
        _tier = tier,
        _natal = natal;

  final Maestro maestro;

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

  /// Quante volte una risposta e' arrivata tronca e si e' rigenerata. Pubblico
  /// per la stessa ragione dell'ancoraggio: se cresce, il tetto e' di nuovo
  /// stretto, e lo si scopre dal numero invece che da uno screenshot.
  int rigenerazioniPerTroncatura = 0;

  /// Quante volte anche la seconda e' arrivata tronca e si e' consegnato un
  /// ripiego. Dovrebbe restare a zero: se sale, il difetto e' nella misura.
  int troncatureConsegnate = 0;

  /// Gli ancoraggi disponibili adesso per questa persona. Vuoto quando non c'e'
  /// niente da ancorare, e in quel caso il controllo NON scatta.
  List<Ancoraggio> get ancoraggiDisponibili => VerificaAncoraggio.disponibiliPer(
        natal: _natal?.call() ?? NatalContext.none,
        profile: _profile,
        memory: _memoryState,
      );

  /// Ogni quanti turni dell'utente rinfrescare il distillato di memoria.
  static const int _distillEvery = 3;

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  UserProfile _profile = UserProfile.empty;
  UserProfile get profile => _profile;

  MaestroMemory _memoryState = MaestroMemory.empty;

  /// La memoria del Maestro caricata, per il benvenuto deterministico del
  /// Premium, che riprende dalla sintesi di sessione.
  MaestroMemory get memory => _memoryState;

  bool _loading = true;
  bool get loading => _loading;

  bool _sending = false;
  bool get sending => _sending;

  /// Vero se il Maestro puo' rispondere davvero. Falso quando l'AI non e'
  /// configurata: la UI mostra un avviso in tono, non un errore.
  bool get aiReady => _ai.isReady;

  /// Il disclaimer si mostra una sola volta. Qui si decide se serve ancora.
  bool get needsDisclaimer => !_profile.hasSeenDisclaimer;

  int _turnsSinceDistill = 0;

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
      _messages
        ..clear()
        ..addAll(_chiudiIVoli(results[2] as List<ChatMessage>));
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

  /// Registra che l'utente ha visto e accettato il disclaimer, una volta sola.
  Future<void> acceptDisclaimer() async {
    if (_profile.hasSeenDisclaimer) return;
    _profile = _profile.copyWith(disclaimerAcceptedAt: DateTime.now());
    notifyListeners();
    try {
      await _memory.saveProfile(_profile);
    } catch (errore, traccia) {
      // Se la scrittura fallisce lo si riproporra' al prossimo avvio.
      annotaGuastoInnocuo(
          'salvando l\'accettazione del disclaimer', errore, traccia);
    }
  }

  /// Invia un messaggio dell'utente e attende la risposta del Maestro.
  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _sending) return;

    // Il limite del giorno vale su TUTTE le strade con cui si fa una domanda.
    // La schermata "Chiedi" consultava il contatore, la chat no: chi apriva la
    // chat aveva domande infinite qualunque piano avesse, cioe' il limite era
    // promesso e non imposto.
    final piano = _tier?.call();
    final contatore = _allowance;
    if (piano != null && contatore != null && !contatore.canAsk(piano)) {
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
      return;
    }

    final priorHistory = List<ChatMessage>.of(_messages);
    final userMessage = ChatMessage(
      role: ChatRole.user,
      text: trimmed,
      at: DateTime.now(),
    );
    _messages.add(userMessage);
    unawaited(_persist(userMessage));

    // Instradamento: se la richiesta e' un'esperienza immersiva dedicata, il
    // Maestro invita ad aprire la funzione, senza chiamare l'AI e senza
    // consumare la domanda del giorno. Il costo e la quota vivono dentro la
    // funzione immersiva, con le sue regole.
    final intent = _classifier.classify(maestro, trimmed);
    if (intent != null) {
      final invite = ChatMessage(
        role: ChatRole.maestro,
        text: intent.invite,
        at: DateTime.now(),
        intentId: intent.id,
      );
      _messages.add(invite);
      unawaited(_persist(invite));
      notifyListeners();
      // EsitoDelTurno.instradamento: il costo vive dentro la funzione immersiva.
      return;
    }

    // NON si consuma qui. Si consumava PRIMA di generare, quindi un guasto
    // costava una domanda: il 2 agosto un ripiego si e' preso l'unica domanda
    // del giorno. Adesso decide l'ESITO, e la regola vive in CostoDelTurno.
    final esito = await _generate(
      priorHistory: priorHistory,
      userText: trimmed,
    );
    if (piano != null && contatore != null && CostoDelTurno.consuma(esito)) {
      contatore.record(piano);
    }
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
  Future<void> chiediAgliAltri() async {
    if (!puoiChiedereAgliAltri) return;
    final domanda = ultimaDomanda;
    if (domanda == null) return;
    for (final altro in AltreVoci.altriDi(maestro)) {
      if (vociDelCerchio.contains(altro)) continue;
      await _generate(
        priorHistory: const [],
        userText: domanda,
        per: altro,
      );
    }
  }

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

  /// Chiede al Maestro di scendere piu' a fondo sulla STESSA risposta.
  ///
  /// Non consuma una domanda del giorno: consuma un approfondimento, che e' un
  /// budget suo. Se consumasse una domanda la persona esiterebbe prima di
  /// toccarlo, e l'esitazione uccide l'intimita'.
  ///
  /// La bolla non si aggiunge, si SOSTITUISCE: e' la stessa lettura portata
  /// piu' giu', non una seconda risposta alla stessa domanda.
  Future<void> approfondisci() async {
    if (!puoiChiedereDiApprofondire) return;
    final piano = _tier?.call();
    final contatore = _allowance;
    if (piano != null && contatore != null && !contatore.puoiApprofondire(piano)) {
      return;
    }

    // La domanda a cui la risposta si riferisce, per rigenerare sullo stesso
    // turno invece che su uno nuovo.
    final indiceRisposta = _messages.length - 1;
    final priorHistory = _messages.sublist(0, indiceRisposta).toList();
    final domanda = priorHistory.isNotEmpty && priorHistory.last.isUser
        ? priorHistory.last.text
        : null;
    if (domanda == null) return;

    _sending = true;
    final precedente = _messages[indiceRisposta];
    _messages[indiceRisposta] =
        const ChatMessage(role: ChatRole.maestro, text: '', pending: true);
    notifyListeners();

    try {
      final natal = _natal?.call() ?? NatalContext.none;
      final piu = await _ai.reply(
        maestro: maestro,
        profile: _profile,
        memory: _memoryState,
        history: priorHistory.sublist(0, priorHistory.length - 1),
        userMessage: domanda,
        natal: natal,
        approfondisci: true,
      );
      final risposta = ChatMessage(
        role: ChatRole.maestro,
        text: piu,
        at: DateTime.now(),
        approfondita: true,
      );
      _messages[indiceRisposta] = risposta;
      if (piano != null && contatore != null) {
        contatore.registraApprofondimento(piano);
      }
      // La bolla si SOSTITUISCE, non si aggiunge: e' la stessa lettura portata
      // piu' giu'. In cronologia vale lo stesso, altrimenti riaprendo si
      // leggerebbero due risposte alla stessa domanda.
      await _sostituisci(risposta);
    } catch (errore, traccia) {
      // L'approfondimento fallito NON deve far perdere la risposta che la
      // persona aveva gia' letto: si rimette quella, marcata come gia'
      // approfondita cosi' non si ritenta all'infinito.
      annotaGuastoInnocuo(
          'approfondendo la risposta di ${maestro.displayName}',
          errore,
          traccia);
      _messages[indiceRisposta] = precedente.copyWith(approfondita: true);
    } finally {
      _sending = false;
      maestroInAscolto = null;
      notifyListeners();
    }
  }

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
    final piano = _tier?.call();
    final contatore = _allowance;
    if (piano != null && contatore != null && CostoDelTurno.consuma(esito)) {
      contatore.record(piano);
    }
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
        role: ChatRole.maestro, text: '', pending: true, autore: chiRisponde);
    _messages.add(pending);
    await _persist(pending);
    notifyListeners();

    try {
      final natal = _natal?.call() ?? NatalContext.none;
      final disponibili = VerificaAncoraggio.disponibiliPer(
        natal: natal,
        profile: _profile,
        memory: _memoryState,
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
      String reply;
      try {
        reply = await _ai.reply(
          maestro: chiRisponde,
          profile: _profile,
          memory: _memoryState,
          history: priorHistory,
          userMessage: userText,
          natal: natal,
        );
      } on MaestroAiTroncata {
        rigenerazioniPerTroncatura++;
        try {
          reply = await _ai.reply(
            maestro: chiRisponde,
            profile: _profile,
            memory: _memoryState,
            history: priorHistory,
            userMessage: userText,
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
          await _consegna(pending.copyWith(
            text: LetturaDiRipiego.componi(
              maestro: chiRisponde,
              domanda: userText,
              natal: natal,
              profile: _profile,
              memory: _memoryState,
            ),
            pending: false,
            failed: true,
            ripiego: true,
          ), cronometro);
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
      if (!VerificaAncoraggio.eAncorata(reply, disponibili)) {
        rigenerazioniPerAncoraggio++;
        final secondo = await _ai.reply(
          maestro: chiRisponde,
          profile: _profile,
          memory: _memoryState,
          history: priorHistory,
          userMessage: userText,
          natal: natal,
          insistiSullAncoraggio: true,
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

      final answer = ChatMessage(
        role: ChatRole.maestro,
        text: reply,
        at: DateTime.now(),
        autore: chiRisponde,
      );
      await _consegna(answer, cronometro);
      // NON si aggiunge: `_consegna` ha gia' completato il turno che esisteva.
      // Aggiungerlo qui lo scriverebbe due volte, e riaprendo la chat si
      // leggerebbe la stessa risposta di seguito a se stessa.
      _turnsSinceDistill++;
      unawaited(_maybeDistill());
      return EsitoDelTurno.rispostaVera;
    } on MaestroAiUnavailable {
      await _consegna(pending.copyWith(
        text: RipiegoDelMaestro.nonConfiguratoDi(chiRisponde),
        pending: false,
        failed: true,
        ripiego: true,
      ), cronometro);
      return EsitoDelTurno.ripiego;
    } catch (errore, traccia) {
      // Il guasto e' gia' stato scritto nel registro da `VoceSorvegliata`, che
      // sta davanti a QUALUNQUE provider: qui non si inghiotte piu' niente, si
      // sceglie solo cosa mostrare. L'annotazione resta perche' l'errore vero
      // esista anche per chi guarda i log senza aprire il pannello.
      annotaGuastoInnocuo(
          'rispondendo nella chat di ${chiRisponde.displayName}', errore, traccia);
      // IL SILENZIO NON LASCIA A MANI VUOTE. Il Maestro non si scusa e basta:
      // consegna una lettura VERA costruita dai dati sul dispositivo, dichiarata
      // come lettura del cielo e non come la sua voce. Sotto, una via che porta
      // da qualche parte, dallo stesso instradamento deterministico che gia'
      // esiste. Dopo questa riga, nella chat non c'e' nessuno stato senza uscita.
      final natal = _natal?.call() ?? NatalContext.none;
      await _consegna(pending.copyWith(
        text: LetturaDiRipiego.componi(
          maestro: chiRisponde,
          domanda: userText,
          natal: natal,
          profile: _profile,
          memory: _memoryState,
        ),
        pending: false,
        failed: true,
        ripiego: true,
      ), cronometro);
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

  /// Ogni tot turni distilla la conversazione e aggiorna la memoria. Best
  /// effort: qualunque errore lascia la memoria com'era.
  Future<void> _maybeDistill() async {
    // La memoria dei Maestri e' venduta come esclusiva dell'Iniziato in su, e
    // veniva distillata anche per il gratuito: il valore usciva senza che
    // nessuno lo avesse comprato. Chi non ha diritto non paga il costo della
    // distillazione e non lascia traccia.
    final piano = _tier?.call();
    if (piano != null && !PlanCatalog.haMemoria(piano)) return;
    if (_turnsSinceDistill < _distillEvery) return;
    _turnsSinceDistill = 0;
    try {
      final digest = await _ai.distill(
        maestro: maestro,
        profile: _profile,
        previous: _memoryState,
        history: _messages.where((m) => !m.pending && !m.failed).toList(),
      );
      if (digest == null || digest.isEmpty) return;
      _memoryState = _memoryState.copyWith(
        sessionSummary:
            digest.summary.isNotEmpty ? digest.summary : _memoryState.sessionSummary,
        facts: _mergeFacts(_memoryState.facts, digest.facts),
      );
      await _memory.saveMemory(maestro, _memoryState);
    } catch (errore, traccia) {
      // Nessun impatto sulla conversazione in corso.
      annotaGuastoInnocuo(
          'distillando la memoria di ${maestro.displayName}', errore, traccia);
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
    final minima = _attesaMinima ??
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
    await _sostituisci(messaggio);
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
