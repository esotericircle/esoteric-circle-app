import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import '../../core/chat/chat_message.dart';
import '../../core/config/la_regione_dei_dati.dart';
import '../../core/chat/maestro_memory.dart';
import '../../core/chat/testo_del_responso.dart';
import '../../core/chat/user_profile.dart';
import '../../core/maestro/consult_depth.dart';
import '../../core/maestro/maestro.dart';
import '../../core/maestro/maestro_reply.dart';
import '../../core/rituals/la_lettura_delle_rune.dart';
import '../../core/rituals/rune_cast.dart';
import '../../core/responsi/anatomia_del_responso.dart';
import '../../core/maestro/misura_della_risposta.dart';
import '../../core/maestro/natal_context.dart';
import 'maestro_ai_provider.dart';
import 'maestro_oracle.dart';
import 'la_cache_del_contesto.dart';
import 'le_funzioni_del_cielo.dart';
import '../../core/chat/i_responsi_di_oggi.dart';
import 'maestro_persona.dart';
import 'la_richiesta_del_turno.dart';
import 'registro_dei_guasti.dart';
import 'l_etichetta_della_funzione.dart';

/// Implementazione dell'AI dei Maestri su Gemini via Firebase AI Logic.
///
/// Usa il backend Vertex AI protetto da App Check: nessuna chiave Gemini nel
/// client, nessun gateway Cloud Run per ora. Resta dietro `MaestroAiProvider`,
/// cosi' il domani (gateway di caching, altro fornitore) non tocca la UI.
///
/// Riferimento: regola d'oro dello stack e note di runtime C3.
class FirebaseMaestroAiProvider
    implements MaestroAiProvider, LaCorrezioneCorta {
  FirebaseMaestroAiProvider({
    FirebaseAI? ai,
    this.chatModel = kMaestroChatModel,
    this.distillModel = kMaestroDistillModel,
    this.finestraDellaStoria = kHistoryWindow,
    this.conIlRiassunto = true,
  }) : _ai = ai ?? FirebaseAI.vertexAI(location: kVertexLocation);

  /// Quanti messaggi recenti arrivano come storia: di serie
  /// [kHistoryWindow]. Il banco della memoria compatta
  /// (`tool/la_memoria_compatta_a_confronto.dart`) ci rimette la regola di
  /// prima dell'ordine EX, venti messaggi e nessun riassunto, sullo stesso
  /// codice.
  final int finestraDellaStoria;

  /// Se la persona ritrova nell'istruzione cio' che ha scritto prima della
  /// finestra: vedi [scrittoPrimaDellaFinestra].
  final bool conIlRiassunto;

  /// Regione del backend Vertex: **quella dei dati**, `LaRegioneDeiDati`,
  /// ordine DJ voce 03. Un modello che li' non risponde non si usa.
  static const String kVertexLocation = LaRegioneDeiDati.regione;

  /// Modello di Medora e dei Maestri per la chat. Flash tiene bassi costo e
  /// latenza per la Demo. Per la voce piu' ricca dei Maestri si puo' alzare a
  /// un modello Pro cambiando questa sola costante.
  static const String kMaestroChatModel = 'gemini-2.5-flash';

  /// Modello per il distillato di memoria: task ripetitivo e breve, sempre
  /// Flash.
  static const String kMaestroDistillModel = 'gemini-2.5-flash';

  /// Modello per le risposte Breve e per il Free: Flash-Lite, il piu' economico,
  /// per le tante risposte a costo basso.
  static const String kMaestroBreveModel = 'gemini-2.5-flash-lite';

  /// Modello per la risposta Profonda del Premium: Flash, piu' ricco.
  static const String kMaestroProfondaModel = 'gemini-2.5-flash';

  /// **LA LETTURA DELLE RUNE: FLASH.** Ordine ER voce 01, 27 settembre 2026.
  /// Era Flash-Lite dall'ordine S voce 19, quando il presagio era una bolla
  /// di tre righe. Adesso legge ogni pietra nella sua posizione e sulla
  /// domanda: al banco del 27 settembre, giudicato alla cieca, Flash-Lite
  /// rispondeva in modo diretto 9 e 11 volte su 20, leggeva tutte le pietre 3
  /// e 2 volte su 24, e con piu' testo faceva piu' errori di italiano (12 e
  /// 13). E' il modello che la Stesa dei Tarocchi usa gia' per la stessa
  /// ragione (ordine EQ voce 04, *"Sì, con Flash"*), verificato nella regione
  /// dei dati.
  static const String kMaestroRuneModel = 'gemini-2.5-flash';

  /// **IL MODELLO DEL TURNO, IN UN PUNTO SOLO. Ordine EO voce 14.** Nella
  /// chat scritta resta [chatModel]. Lo usano il provider vero e il collaudo.
  ///
  /// **Nel LIVE Flash, dall'ordine EQ voce 03**, 27 settembre 2026. L'ordine
  /// EO l'aveva messo a Flash-Lite per l'attesa; l'ordine EQ ha chiesto *"per
  /// il LIVE resta il modello che risponde nel merito; fra due che rispondono
  /// nel merito, il più veloce"*. Stesse dodici domande di seguito, due giri
  /// per Maestro, lette con la regola scritta
  /// (`docs/collaudo/EQ/eq03_nel_merito.txt`): Flash-Lite nel merito 18 su 72
  /// prima della cura, 36 e 27 su 72 nei due giri dopo; Flash 52 e 54 su 72.
  /// Il tempo del modello mediano sale da 781 a 1175 millesimi.
  static const String kMaestroLiveModel = 'gemini-2.5-flash';

  static String modelloDelTurno({
    required bool nelLive,
    String chatModel = kMaestroChatModel,
  }) =>
      nelLive ? kMaestroLiveModel : chatModel;

  /// Il modello giusto per la profondita', in un punto solo.
  static String modelForDepth(ConsultDepth depth) =>
      depth == ConsultDepth.profonda
          ? kMaestroProfondaModel
          : kMaestroBreveModel;

  /// L'UNICA PORTA alla configurazione di generazione, per tutte e quattro le
  /// chiamate di questo file.
  ///
  /// **Il dato che ha fatto nascere questa funzione.** Prima ogni chiamata si
  /// costruiva la sua `GenerationConfig` a mano, e due su quattro, `reply` e
  /// `distill`, **si dimenticavano di dichiarare il ragionamento**. Chi non lo
  /// dichiara non lo spegne: prende il ragionamento dinamico del modello, che
  /// si mangia il tetto delle uscite prima che il modello scriva. E' il difetto
  /// misurato il 2 agosto 2026, `thoughtsTokenCount: 150` su un tetto di 160.
  ///
  /// Una dimenticanza cosi' non si corregge chiamante per chiamante: si toglie
  /// la porta. Da qui il tetto e il ragionamento arrivano ENTRAMBI dalla stessa
  /// [MisuraDellaRisposta], e non esiste piu' un modo di scrivere l'uno senza
  /// l'altro. Pubblica apposta: una prova costruisce la configurazione vera e
  /// ne legge i due campi, invece di fidarsi del sorgente.
  static GenerationConfig configurazionePer(
    MisuraDellaRisposta misura, {
    required double temperature,
    double? topP,
    String? responseMimeType,
    Schema? responseSchema,
    int tettoInPiu = 0,
  }) =>
      GenerationConfig(
        temperature: temperature,
        topP: topP,
        maxOutputTokens: misura.tetto + tettoInPiu,
        thinkingConfig: ThinkingConfig.withThinkingBudget(misura.ragionamento),
        responseMimeType: responseMimeType,
        responseSchema: responseSchema,
      );

  /// Vero se il modello si e' fermato perche' ha finito lo spazio.
  ///
  /// La SDK non solleva niente per `MAX_TOKENS`, a differenza di `SAFETY` e
  /// `RECITATION`: torna il testo scritto fino a li' come se fosse compiuto.
  /// Chi non guarda questo campo non ha modo di distinguere una risposta breve
  /// da un moncone, ed e' esattamente cio' che e' successo.
  static bool eTroncata(GenerateContentResponse response) =>
      response.candidates.any((c) => c.finishReason == FinishReason.maxTokens);

  /// Quanti messaggi recenti passare come storia al modello. Oltre questa
  /// soglia il filo lo tiene la sintesi di sessione, non la cronologia piena.
  ///
  /// **OTTO, cioe' quattro scambi, dall'ordine EX voce 09** (erano venti):
  /// *"Nella richiesta, al posto degli ultimi 20 turni della conversazione: un
  /// riassunto breve più gli ultimi 4-6 turni."* Il riassunto e' la sintesi
  /// della memoria, che l'istruzione porta gia' insieme ai fatti, piu' cio'
  /// che la persona ha scritto prima della finestra in questa conversazione
  /// ([scrittoPrimaDellaFinestra]): la memoria che il Maestro conosce non
  /// cambia, cambia come gli arriva.
  static const int kHistoryWindow = 8;

  final FirebaseAI _ai;
  final String chatModel;
  final String distillModel;

  @override
  bool get isReady => true;

  @override
  Future<String> reply({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory memory,
    required List<ChatMessage> history,
    required String userMessage,
    NatalContext natal = NatalContext.none,
    bool insistiSullAncoraggio = false,
    String? rispostaGiaData,
  }) async {
    // **CIO' CHE IL TURNO CHIEDE E LA FIRMA NON PORTA.** Ordine EN voci 01
    // e 06: nel LIVE la misura della voce, e la risposta da non ripetere.
    final turno = LaRichiestaDelTurno.corrente;
    // Ordine EX Aggiunta 4, voce EX.07: il cielo dei giorni che la domanda
    // nomina, gia' calcolato.
    // Nel seguito la domanda e' l'ultima della persona nella storia: la
    // richiesta del tocco non nomina giorni.
    final laDomanda = turno.domanda ??
        (rispostaGiaData == null
            ? userMessage
            : history
                .lastWhere((m) => !m.isMaestro,
                    orElse: () =>
                        ChatMessage(role: ChatRole.user, text: userMessage))
                .text);
    final cieloDeiGiorni = LeFunzioniDelCielo.cieloDeiGiorniNominati(laDomanda,
        carta: natal.carta);
    final istruzione = MaestroPersona.systemInstruction(
      maestro: maestro,
      profile: profile,
      memory: memory,
      natal: natal,
      insistiSullAncoraggio: insistiSullAncoraggio,
      rispostaGiaData: rispostaGiaData,
      primaRisposta: !history.any((m) => m.isMaestro),
      testiGiaDetti: [
        for (final m in history)
          if (m.isMaestro) m.text
      ],
      nelLive: turno.nelLive,
      daNonRipetere: turno.daNonRipetere,
      daProgramma: turno.daProgramma,
      daAttesa: turno.daAttesa,
      domandaDiAdesso: turno.domanda,
      correzione: turno.daCorreggere,
      conSeguito: turno.conSeguito,
      // Ordine EX Aggiunta 4, voce EX.07: il cielo dei giorni che la
      // domanda nomina, gia' calcolato.
      cieloDeiGiorni: cieloDeiGiorni,
      scrittoPrima: conIlRiassunto
          ? scrittoPrimaDellaFinestra(history, finestra: finestraDellaStoria)
          : const [],
    );
    // La PRIMA risposta arriva sempre alla stessa misura per tutti: la
    // profondita' non si sceglie prima, si chiede dopo aver letto.
    final configurazione = _conLoSpazioDelSeguito(
      configurazionePer(
        rispostaGiaData == null
            ? MisuraDellaRisposta.perIlTurno(nelLive: turno.nelLive)
            : MisuraDellaRisposta.perIlSeguito,
        temperature: 0.9,
        topP: 0.95,
      ),
      conSeguito: turno.conSeguito && rispostaGiaData == null && !turno.nelLive,
    );
    // **LA CACHE DEL CONTESTO, QUANDO E' ACCESA.** Ordine EX Aggiunta 4, voce
    // EX.05: la prima risposta della chat scritta, se la cache della sua
    // variante e' viva, passa dal template con la cache; altrimenti, o se
    // qualcosa non va, dalla via di sempre qui sotto.
    if (rispostaGiaData == null &&
        !turno.nelLive &&
        turno.suTesto == null &&
        turno.daCorreggere == null) {
      final dallaCache = await _conLaCache(
        maestro: maestro,
        istruzione: istruzione,
        conSeguito: turno.conSeguito,
        configurazione: configurazione,
        history: history,
        userMessage: userMessage,
        laDomanda: laDomanda,
        natal: natal,
      );
      if (dallaCache != null) return dallaCache;
    }
    final model = _ai.generativeModel(
      model: modelloDelTurno(nelLive: turno.nelLive, chatModel: chatModel),
      // L'etichetta della funzione, ordine EW voce EW.03: la risposta della
      // chat, il seguito ("Vai piu' a fondo") o la risposta del LIVE.
      httpClient: ClientConEtichetta(turno.nelLive
          ? LeFunzioniDelModello.chatLive
          : rispostaGiaData == null
              ? LeFunzioniDelModello.chatRisposta
              : LeFunzioniDelModello.chatSeguito),
      systemInstruction: Content.system(istruzione),
      generationConfig: configurazione,
      // **IL CIELO SI CHIEDE ALL'APP. Ordine EV voce 03.** Il modello riceve
      // le funzioni del cielo e, quando la domanda tocca il cielo di un
      // giorno o di un periodo, le chiama: la libreria le esegue sul
      // telefono e gli rimanda i fatti, prima che scriva. Chat e LIVE
      // passano da qui.
      tools: LeFunzioniDelCielo.perIlMaestro(carta: natal.carta),
      // **COL CIELO GIA' DAVANTI, LA FUNZIONE NON SI CHIAMA.** Ordine EX
      // Aggiunta 4, voce EX.07: al banco (giro ex07c) il modello chiamava la
      // funzione per il giorno che aveva gia' nell'istruzione in sei domande
      // su sei, anche con la descrizione che glielo diceva. Quando la
      // domanda nomina dei giorni e il loro cielo e' calcolato, il turno non
      // chiama funzioni.
      toolConfig: cieloDeiGiorni.isEmpty
          ? null
          : ToolConfig(functionCallingConfig: FunctionCallingConfig.none()),
    );

    final chat = model.startChat(history: _toHistory(history));
    final chiamateDelCielo = LeFunzioniDelCielo.registro.length;
    // **A FLUSSO QUANDO QUALCUNO ASPETTA IL TESTO. Ordine EO voce 14.** Nel
    // LIVE la risposta si mostra mentre il modello la scrive: il testo
    // arriva a video un secondo e piu' prima. La voce aspetta la risposta
    // intera, con le sue reti, come ha deciso il fondatore con l'ordine EM.
    final suTesto = turno.suTesto;
    GenerateContentResponse? response;
    String? text;
    if (suTesto == null) {
      response = await chat.sendMessage(Content.text(userMessage));
      text = response.text?.trim();
    } else {
      final scritto = StringBuffer();
      await for (final pezzo
          in chat.sendMessageStream(Content.text(userMessage))) {
        response = pezzo;
        final t = pezzo.text;
        if (t == null || t.isEmpty) continue;
        scritto.write(t);
        suTesto(scritto.toString());
      }
      text = scritto.toString().trim();
    }
    // **SE RIMANDA, SI CHIEDE UNA VOLTA ANCORA.** Ordine EV voce 03: la
    // domanda sul cielo a cui il modello risponde "devo consultare il cielo"
    // senza chiamare la funzione riceve il sollecito, nella stessa
    // conversazione, e la risposta vera prende il posto del rinvio.
    // **COL CIELO GIA' DATO, NIENTE SOLLECITO.** Ordine EX Aggiunta 4, voce
    // EX.07: al banco (giro ex07d), con la funzione spenta per il turno, il
    // sollecito chiedeva di chiamarla, e il modello rispondeva "ho bisogno
    // che tu mi dica quale data": quella frase prendeva il posto della
    // risposta buona in quattro domande su quattro. Padre: questa voce.
    if (text != null &&
        cieloDeiGiorni.isEmpty &&
        LeFunzioniDelCielo.registro.length == chiamateDelCielo &&
        LeFunzioniDelCielo.rimanda(domanda: userMessage, risposta: text)) {
      debugPrint('Cielo per il Maestro: la risposta rimanda, sollecito.');
      final seconda =
          await chat.sendMessage(Content.text(LeFunzioniDelCielo.sollecito));
      final t = seconda.text?.trim();
      if (t != null && t.isNotEmpty) {
        response = seconda;
        text = t;
        suTesto?.call(t);
      }
    }
    // **E SE CHIEDE QUALE RESPONSO, CON I RESPONSI DAVANTI**, ordine EV voce
    // 04: una volta ancora, col sollecito di `IResponsiDiOggi`.
    if (text != null &&
        natal.responsiDiOggi != null &&
        IResponsiDiOggi.chiedeQuale(text)) {
      debugPrint('Responsi di oggi: il Maestro chiede quale, sollecito.');
      final seconda =
          await chat.sendMessage(Content.text(IResponsiDiOggi.sollecito));
      final t = seconda.text?.trim();
      if (t != null && t.isNotEmpty) {
        response = seconda;
        text = t;
        suTesto?.call(t);
      }
    }
    if (text == null || text.isEmpty) {
      throw const MaestroAiUnavailable('Il Maestro non ha trovato le parole.');
    }
    // La troncatura si controlla DOPO aver visto che il testo c'e': un moncone
    // e' testo a tutti gli effetti, e senza questa riga arrivava a video come
    // una risposta compiuta. A flusso la dice l'ultimo pezzo.
    if (response != null && eTroncata(response)) {
      throw const MaestroAiTroncata();
    }
    // LA RIPULITURA AL CONFINE. Il vincolo nella persona regge quasi sempre, e
    // "quasi" non basta per una cosa che dipende da un modello: qui e' l'ultima
    // riga prima dello schermo.
    return TestoDelResponso.pulisci(text);
  }

  /// **LO SPAZIO DEL SEGUITO, quando si scrive insieme alla risposta.**
  /// Ordine EX voce 04: al tetto della risposta si aggiunge quello del
  /// seguito, cosi' nessuno dei due arriva troncato.
  static GenerationConfig _conLoSpazioDelSeguito(GenerationConfig c,
          {required bool conSeguito}) =>
      !conSeguito
          ? c
          : configurazionePer(
              MisuraDellaRisposta.perIlTurno(nelLive: false),
              temperature: 0.9,
              topP: 0.95,
              tettoInPiu: MisuraDellaRisposta.perIlSeguito.tetto,
            );

  @override
  bool get correggeCorto => true;

  /// **LA CORREZIONE CORTA. Ordine EX voce 07.** Una chiamata sola, senza
  /// conversazione e senza funzioni del cielo: l'istruzione della
  /// correzione (`MaestroPersona.istruzioneDellaCorrezione`), la domanda e la
  /// risposta da riscrivere. Al banco della qualita' una richiesta intera
  /// della chat portava da 8.600 a 8.900 token in ingresso, e le reti ne
  /// chiedevano una seconda in 18 casi su 30.
  @override
  Future<String> correggi({
    required Maestro maestro,
    required UserProfile profile,
    required String domanda,
    required String risposta,
    required String correzione,
    MaestroMemory memory = MaestroMemory.empty,
    bool nelLive = false,
    String? cieloDelTurno,
    bool conSeguito = false,
  }) async {
    final model = _ai.generativeModel(
      model: modelloDelTurno(nelLive: nelLive, chatModel: chatModel),
      httpClient: ClientConEtichetta(LeFunzioniDelModello.chatCorrezione),
      systemInstruction: Content.system(
        MaestroPersona.istruzioneDellaCorrezione(
          maestro: maestro,
          profile: profile,
          correzione: correzione,
          memory: memory,
          nelLive: nelLive,
          cieloDelTurno: cieloDelTurno,
          conSeguito: conSeguito && !nelLive,
        ),
      ),
      generationConfig: _conLoSpazioDelSeguito(
        configurazionePer(
          MisuraDellaRisposta.perIlTurno(nelLive: nelLive),
          temperature: 0.9,
          topP: 0.95,
        ),
        conSeguito: conSeguito && !nelLive,
      ),
    );
    final r = await model.generateContent([
      Content.text('LA DOMANDA DELLA PERSONA:\n$domanda\n\n'
          'LA TUA RISPOSTA DA CORREGGERE:\n$risposta'),
    ]);
    final text = r.text?.trim();
    if (text == null || text.isEmpty) {
      throw const MaestroAiUnavailable('Il Maestro non ha trovato le parole.');
    }
    if (eTroncata(r)) throw const MaestroAiTroncata();
    return TestoDelResponso.pulisci(text);
  }

  @override
  Future<MaestroReply> consult({
    required Maestro maestro,
    required String theme,
    required UserProfile profile,
    MaestroMemory memory = MaestroMemory.empty,
    NatalContext? natal,
    ConsultDepth depth = ConsultDepth.breve,
  }) async {
    final t = theme.trim();
    if (t.isEmpty) {
      throw const MaestroAiUnavailable('Nessuna domanda da porre.');
    }

    // Modello, tetto di token e ragionamento seguono la profondita', in un punto
    // solo: Flash-Lite e ragionamento spento per la Breve, Flash per la Profonda.
    final model = _ai.generativeModel(
      model: modelForDepth(depth),
      httpClient: ClientConEtichetta(depth == ConsultDepth.profonda
          ? LeFunzioniDelModello.interrogaProfonda
          : LeFunzioniDelModello.interrogaBreve),
      systemInstruction: Content.system(
        MaestroPersona.consultInstruction(
          maestro: maestro,
          profile: profile,
          memory: memory,
          natal: natal,
          depth: depth,
        ),
      ),
      // Uscita nei tre strati come JSON, cosi' l'app la mostra come qualunque
      // altra risposta. Parsing difensivo, come nel distillato.
      generationConfig: configurazionePer(
        MisuraDellaRisposta.perProfondita(depth),
        temperature: 0.9,
        topP: 0.95,
        responseMimeType: 'application/json',
      ),
    );

    final response = await model.generateContent([
      Content.text('La persona chiede, sul tema: «$t». '
          'Rispondi solo su questo tema, nella tua lente di dominio.'),
    ]);
    final raw = response.text?.trim();
    if (raw == null || raw.isEmpty) {
      throw const MaestroAiUnavailable('Il Maestro non ha trovato le parole.');
    }
    // Un JSON troncato non e' un JSON: senza questa riga cadeva sul parsing
    // difensivo, che dice solo "non ha trovato le parole" e nasconde il perche'.
    if (eTroncata(response)) throw const MaestroAiTroncata();
    final reply = _parseReply(raw);
    if (reply == null || !reply.isComplete) {
      throw const MaestroAiUnavailable('Il Maestro non ha trovato le parole.');
    }
    return reply;
  }

  @override
  Future<String> synthesize({
    required String theme,
    required List<MaestroLens> lenses,
    NatalContext? natal,
    UserProfile? profile,
  }) async {
    final t = theme.trim();
    if (t.isEmpty || lenses.length < 2) {
      throw const MaestroAiUnavailable('Niente da mettere a confronto.');
    }

    // Flash, ragionamento spento, tetto contenuto: la sintesi e' breve.
    final model = _ai.generativeModel(
      model: kMaestroProfondaModel,
      httpClient: ClientConEtichetta(LeFunzioniDelModello.interrogaSintesi),
      systemInstruction: Content.system(
        // Ordine EE voce 09: il profilo arriva fin qui, o la sintesi
        // dichiara di non conoscere un nome che l'app conosce.
        MaestroPersona.synthesisInstruction(natal: natal, profilo: profile),
      ),
      generationConfig: configurazionePer(
        MisuraDellaRisposta.sintesi,
        temperature: 0.7,
        topP: 0.95,
      ),
    );

    // Le lenti gia' ottenute, nell'ordine fisso del cerchio, come materiale.
    final buffer = StringBuffer('Domanda della persona: «$t».\n\n');
    for (final l in lenses) {
      buffer
        ..writeln('${l.maestro.displayName} (${l.maestro.domainArtsPhrase}):')
        ..writeln('- Colpo d\'occhio: ${l.glance.trim()}')
        ..writeln('- Lettura: ${l.reading.trim()}')
        ..writeln();
    }

    final response =
        await model.generateContent([Content.text(buffer.toString())]);
    final text = response.text?.trim();
    if (text == null || text.isEmpty) {
      throw const MaestroAiUnavailable('La sintesi non ha trovato le parole.');
    }
    // Anche la sintesi la legge la persona: una sintesi tronca chiuderebbe
    // senza la frase che deve chiudere sempre.
    if (eTroncata(response)) throw const MaestroAiTroncata();
    return TestoDelResponso.pulisci(text);
  }

  @override
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<ChatMessage> history,
  }) async {
    if (history.isEmpty) return null;
    // Nessun `catch` qui dentro: il distillato resta best effort, ma a decidere
    // che un guasto e' innocuo e' `VoceSorvegliata`, che prima lo scrive. Un
    // errore inghiottito nel punto piu' profondo non lo vede piu' nessuno.
    final model = _ai.generativeModel(
      model: distillModel,
      httpClient: ClientConEtichetta(LeFunzioniDelModello.distillatoMemoria),
      systemInstruction: Content.system(
        MaestroPersona.distillInstruction(maestro, profile),
      ),
      generationConfig: configurazionePer(
        MisuraDellaRisposta.distillato,
        temperature: 0.2,
        responseMimeType: 'application/json',
      ),
    );

    final transcript = StringBuffer();
    if (previous.sessionSummary.trim().isNotEmpty) {
      transcript
          .writeln('Sintesi precedente: ${previous.sessionSummary.trim()}');
    }
    for (final m in history) {
      final who = m.isUser ? 'Utente' : maestro.displayName;
      transcript.writeln('$who: ${m.text}');
    }

    final response =
        await model.generateContent([Content.text(transcript.toString())]);
    final raw = response.text?.trim();
    if (raw == null || raw.isEmpty) return null;
    // Il distillato non lo legge nessuno, quindi una sua troncatura non si
    // vede: il parsing difensivo tornerebbe null, la memoria non si
    // aggiornerebbe, e il fondatore direbbe soltanto che i Maestri non
    // ricordano. Qui non si solleva, si SCRIVE, perche' un guasto muto in
    // fondo alla catena e' quello che costa di piu' a trovare.
    if (eTroncata(response)) {
      annotaGuastoInnocuo(
        'distillando la memoria di ${maestro.displayName}',
        const MaestroAiTroncata(
            'il distillato si è fermato prima di chiudere il JSON'),
      );
    }
    return _parseDigest(raw, previous);
  }

  /// Traduce la storia di dominio nella forma attesa da Gemini, tenendo solo la
  /// finestra recente e lasciando fuori i messaggi ancora in sospeso o falliti.
  /// **CIO' CHE LA PERSONA HA SCRITTO PRIMA DELLA FINESTRA. Ordine EX voce
  /// 09.** Fino a venti messaggi indietro (la finestra di prima
  /// dell'ordine EX), i messaggi della persona che la finestra di otto non
  /// porta piu', accorciati a centosessanta caratteri: il riassunto breve
  /// che l'ordine chiede, senza un modello che lo scriva.
  static const int kFinestraDelRiassunto = 20;

  static List<String> scrittoPrimaDellaFinestra(List<ChatMessage> history,
      {int finestra = kHistoryWindow}) {
    final pulita = history
        .where((m) => !m.pending && !m.failed && m.text.trim().isNotEmpty)
        .toList();
    if (pulita.length <= finestra) return const [];
    final da = pulita.length > kFinestraDelRiassunto
        ? pulita.length - kFinestraDelRiassunto
        : 0;
    return [
      for (final m in pulita.sublist(da, pulita.length - finestra))
        if (m.isUser)
          m.text.trim().length <= 160
              ? m.text.trim()
              : '${m.text.trim().substring(0, 157)}...',
    ];
  }

  /// **LA RISPOSTA DAL TEMPLATE CON LA CACHE**, o null per la via di
  /// sempre. Ordine EX Aggiunta 4, voce EX.05: vedi [LaCacheDelContesto].
  /// Nel banco ([LaCacheDelContesto.simulataNelBanco]) la stessa richiesta
  /// va a Vertex senza cache: l'istruzione comune come istruzione di
  /// sistema e il resto come testo, cioe' cio' che il modello legge col
  /// template, per misurarne il merito senza creare niente su Google.
  Future<String?> _conLaCache({
    required Maestro maestro,
    required String istruzione,
    required bool conSeguito,
    required GenerationConfig configurazione,
    required List<ChatMessage> history,
    required String userMessage,
    required String laDomanda,
    required NatalContext natal,
  }) async {
    // La cache e' di gemini-2.5-flash: un altro modello non la legge.
    if (chatModel != LaCacheDelContesto.modello) return null;
    // Il cielo di un periodo vuole la funzione, che il template non ha.
    if (LeFunzioniDelCielo.serveUnaFunzione(laDomanda)) return null;
    final comune =
        MaestroPersona.parteComune(maestro: maestro, conSeguito: conSeguito);
    if (!istruzione.startsWith(comune)) return null;
    final simulata = LaCacheDelContesto.simulataNelBanco;
    final nome = simulata
        ? 'simulata'
        : await LaCacheDelContesto.nomePer(
            LaCacheDelContesto.variante(maestro, conSeguito: conSeguito));
    if (nome == null) return null;
    final richiesta = LaCacheDelContesto.richiesta(
      parteDellaPersona: istruzione.substring(comune.length),
      cieloDiOggi:
          LeFunzioniDelCielo.cieloDiOggiPerIlModello(carta: natal.carta),
      storia: _finestra(history),
      domanda: userMessage,
    );
    try {
      final GenerateContentResponse r;
      if (simulata) {
        r = await _ai
            .generativeModel(
          model: chatModel,
          httpClient: ClientConEtichetta(LeFunzioniDelModello.chatRisposta),
          systemInstruction: Content.system(comune),
          generationConfig: configurazione,
        )
            .generateContent([Content.text(richiesta)]);
      } else {
        // I template di Firebase AI Logic sono ancora sperimentali nel
        // pacchetto: sono la sola strada per la cache esplicita dal telefono,
        // e se cambiano la chiamata cade nel catch e risponde la via di
        // sempre.
        // ignore: experimental_member_use
        r = await _ai.templateGenerativeModel().generateContent(
            LaCacheDelContesto.template,
            inputs: {'cache': nome, 'richiesta': richiesta});
      }
      final t = r.text?.trim();
      if (t == null || t.isEmpty || eTroncata(r)) return null;
      LaCacheDelContesto.risposteDallaCache++;
      return TestoDelResponso.pulisci(t);
    } catch (errore) {
      // La cache non e' mai la sola strada: risponde la via di sempre.
      debugPrint('Cache del contesto: via di sempre dopo $errore');
      return null;
    }
  }

  /// I messaggi della storia che arrivano al modello: gli ultimi
  /// [finestraDellaStoria], interi e non in attesa.
  List<ChatMessage> _finestra(List<ChatMessage> history) {
    final clean = history
        .where((m) => !m.pending && !m.failed && m.text.trim().isNotEmpty)
        .toList();
    return clean.length > finestraDellaStoria
        ? clean.sublist(clean.length - finestraDellaStoria)
        : clean;
  }

  List<Content> _toHistory(List<ChatMessage> history) {
    final clean = history
        .where((m) => !m.pending && !m.failed && m.text.trim().isNotEmpty)
        .toList();
    final windowed = clean.length > finestraDellaStoria
        ? clean.sublist(clean.length - finestraDellaStoria)
        : clean;
    return [
      for (final m in windowed)
        m.isUser ? Content.text(m.text) : Content.model([TextPart(m.text)]),
    ];
  }

  /// Estrae i tre strati dal JSON del modello, in modo difensivo: qualunque
  /// forma inattesa torna null, e chi chiama cade sul ripiego. Mai un'eccezione
  /// di parsing che arrivi cruda a video.
  @override
  Future<Responso> presagioDelleRune({
    required EsitoGettata esito,
    required String domanda,
    required UserProfile profile,
  }) async {
    final d = domanda.trim();
    // **FLASH, dall'ordine ER voce 01**: vedi [kMaestroRuneModel]. Era
    // Flash-Lite, come le risposte brevi.
    final model = _ai.generativeModel(
      model: kMaestroRuneModel,
      httpClient: ClientConEtichetta(LeFunzioniDelModello.letturaRune),
      systemInstruction: Content.system(
        MaestroPersona.presagioInstruction(
          profile: profile,
          memory: MaestroMemory.empty,
          conDomanda: d.isNotEmpty,
        ),
      ),
      // **I CAMPI OBBLIGATORI**, ordine ER voce 01: la lettura ha una forma, e
      // lo schema la chiede al modello invece di sperarla dal testo.
      // Dalla stessa porta delle altre chiamate: il tetto e il ragionamento
      // arrivano insieme dalla misura (ordine ER voce 01, vista rossa da
      // `consulta_maestro_test` quando qui si scriveva la configurazione a
      // mano).
      generationConfig: configurazionePer(
        MisuraDellaRisposta.letturaDellaChat,
        temperature: LaLetturaDelleRune.temperatura,
        topP: 0.95,
        responseMimeType: 'application/json',
        responseSchema: Schema.object(properties: {
          'posizione':
              Schema.enumString(enumValues: LaLetturaDelleRune.posizioni),
          // La risposta in poche parole, prima di scriverla (ordine ET voce
          // 07).
          'inBreve': Schema.string(),
          'risposta': Schema.string(),
          // Ogni pietra in due campi: la runa nella sua posizione, e che
          // cosa indica sulla domanda (ordine ER voce 01).
          'pietre': Schema.array(
              items: Schema.object(properties: {
            'lettura': Schema.string(),
            'sullaDomanda': Schema.string(),
          }, propertyOrdering: const [
            'lettura',
            'sullaDomanda'
          ])),
          'legame': Schema.string(),
          'cosaPuoiFare': Schema.string(),
        }, propertyOrdering: LaLetturaDelleRune.campi),
      ),
    );

    // **I FATTI, non il prompt.** Dall'ordine ER voce 01 ogni pietra arriva
    // con la sua posizione e la sua riga del corpus nel verso uscito, e la
    // domanda con la sua cornice dell'allegato B: la richiesta la compone
    // `LaLetturaDelleRune`, la stessa che usa il banco del collaudo.
    final richiesta = LaLetturaDelleRune.richiesta(esito, d);
    // **UNA LETTURA CHE NON REGGE NON SI MOSTRA**: si chiede una seconda
    // volta, poi parla la lettura di casa.
    String? motivo;
    for (var tentativo = 0;
        tentativo < LaLetturaDelleRune.tentativi;
        tentativo++) {
      // **LA SECONDA CHIAMATA SA PERCHE' LA PRIMA E' STATA SCARTATA**, come
      // nel Viaggio (ordine DQ voce 06): al banco di Flash quaranta letture
      // su cento cadevano perche' nominavano una runa nella risposta.
      final response = await model.generateContent([
        Content.text(LaLetturaDelleRune.conLaCorrezione(richiesta, motivo)),
      ]);
      final raw = response.text?.trim();
      if (raw == null || raw.isEmpty) {
        motivo = 'vuota';
        continue;
      }
      if (eTroncata(response)) {
        motivo = 'troncata';
        continue;
      }
      final j = _jsonDelPresagio(raw);
      motivo = LaLetturaDelleRune.scarto(j, esito, domanda: d);
      // All'ultima chiamata una lettura scartata per la forma si mostra:
      // la lettura di casa resta per cio' che non si puo' mostrare (ordine
      // ET voce 07).
      final ultima = tentativo == LaLetturaDelleRune.tentativi - 1;
      if (motivo != null &&
          !(ultima && LaLetturaDelleRune.siMostraComunque(motivo))) {
        continue;
      }
      final responso = LaLetturaDelleRune.daJson(j, esito)!;
      // Le tre parti passano da una funzione sola, come prima dell'ordine ER:
      // un punto di ripulitura per il presagio, non tre.
      String pezzo(String t) => TestoDelResponso.pulisci(t);
      return Responso(
        risposta: pezzo(responso.risposta),
        cosaPuoiFare: pezzo(responso.cosaPuoiFare),
        daDoveViene: pezzo(responso.daDoveViene),
      );
    }
    throw MaestroAiUnavailable('Il presagio non ha retto: $motivo.');
  }

  /// L'oggetto JSON dell'uscita, o null se non c'e': mai un'eccezione di
  /// parsing che arrivi cruda a video.
  Map<dynamic, dynamic>? _jsonDelPresagio(String raw) {
    try {
      final start = raw.indexOf('{');
      final end = raw.lastIndexOf('}');
      if (start < 0 || end <= start) return null;
      final decoded = jsonDecode(raw.substring(start, end + 1));
      return decoded is Map ? decoded : null;
    } catch (errore, traccia) {
      annotaGuastoInnocuo('leggendo la lettura delle rune', errore, traccia);
      return null;
    }
  }

  // **LAPIDE, ordine ER voce 01.** Qui viveva `_parsePresagio`, che leggeva
  // tre campi di testo senza schema: la lettura adesso ha i suoi campi e le
  // sue guardie in `LaLetturaDelleRune`.

  MaestroReply? _parseReply(String raw) {
    try {
      final start = raw.indexOf('{');
      final end = raw.lastIndexOf('}');
      if (start < 0 || end <= start) return null;
      final decoded = jsonDecode(raw.substring(start, end + 1));
      if (decoded is! Map) return null;
      // Puliti tutti e tre: i tre strati arrivano a video come qualunque
      // altra risposta, quindi passano dallo stesso confine.
      final glance = TestoDelResponso.pulisci(
          (decoded['glance'] as Object?)?.toString().trim() ?? '');
      final reading = TestoDelResponso.pulisci(
          (decoded['reading'] as Object?)?.toString().trim() ?? '');
      final invite = TestoDelResponso.pulisci(
          (decoded['invite'] as Object?)?.toString().trim() ?? '');
      return MaestroReply(glance: glance, reading: reading, invite: invite);
    } catch (errore, traccia) {
      annotaGuastoInnocuo(
          'leggendo i tre strati dalla risposta del Maestro', errore, traccia);
      return null;
    }
  }

  /// Estrae il distillato dal JSON del modello, in modo difensivo: qualunque
  /// forma inattesa non deve mai far crollare la chat.
  MemoryDigest? _parseDigest(String raw, MaestroMemory previous) {
    try {
      final start = raw.indexOf('{');
      final end = raw.lastIndexOf('}');
      if (start < 0 || end <= start) return null;
      final decoded = jsonDecode(raw.substring(start, end + 1));
      if (decoded is! Map) return null;

      final summary = (decoded['summary'] as Object?)?.toString().trim() ??
          previous.sessionSummary;
      final rawFacts = decoded['facts'];
      final facts = <String>[
        if (rawFacts is List)
          for (final f in rawFacts)
            if (f != null && f.toString().trim().isNotEmpty)
              f.toString().trim(),
      ];
      final digest = MemoryDigest(summary: summary, facts: facts);
      return digest.isEmpty ? null : digest;
    } catch (errore, traccia) {
      annotaGuastoInnocuo('leggendo il distillato di memoria', errore, traccia);
      return null;
    }
  }
}
