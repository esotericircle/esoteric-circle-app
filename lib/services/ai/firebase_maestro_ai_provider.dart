import 'dart:convert';

import 'package:firebase_ai/firebase_ai.dart';

import '../../core/chat/chat_message.dart';
import '../../core/chat/maestro_memory.dart';
import '../../core/chat/user_profile.dart';
import '../../core/maestro/consult_depth.dart';
import '../../core/maestro/maestro.dart';
import '../../core/maestro/maestro_reply.dart';
import '../../core/maestro/natal_context.dart';
import 'maestro_ai_provider.dart';
import 'maestro_oracle.dart';
import 'maestro_persona.dart';

/// Implementazione dell'AI dei Maestri su Gemini via Firebase AI Logic.
///
/// Usa il backend Vertex AI protetto da App Check: nessuna chiave Gemini nel
/// client, nessun gateway Cloud Run per ora. Resta dietro `MaestroAiProvider`,
/// cosi' il domani (gateway di caching, altro fornitore) non tocca la UI.
///
/// Riferimento: regola d'oro dello stack e note di runtime C3.
class FirebaseMaestroAiProvider implements MaestroAiProvider {
  FirebaseMaestroAiProvider({
    FirebaseAI? ai,
    this.chatModel = kMaestroChatModel,
    this.distillModel = kMaestroDistillModel,
  }) : _ai = ai ?? FirebaseAI.vertexAI(location: kVertexLocation);

  /// Regione del backend Vertex. Allineata al progetto (europe-west1). Se un
  /// modello non fosse servito qui, si cambia in un solo punto.
  static const String kVertexLocation = 'europe-west1';

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

  /// Tetto duro di token in uscita per profondita': la Breve contenuta, la
  /// Profonda circa il triplo, adattiva ma mai oltre.
  static const int kBreveMaxTokens = 260;
  static const int kProfondaMaxTokens = 780;

  /// Ragionamento interno del modello per profondita': spento sulle Breve, cosi'
  /// non si spende in pensiero dove serve una risposta rapida; un margine minimo
  /// sulla Profonda.
  static const int kBreveThinkingBudget = 0;
  static const int kProfondaThinkingBudget = 512;

  /// Tetto di token per la Sintesi comparativa: contenuta, in linea con la Breve.
  static const int kSynthesisMaxTokens = 260;

  /// Il modello giusto per la profondita', in un punto solo.
  static String modelForDepth(ConsultDepth depth) =>
      depth == ConsultDepth.profonda ? kMaestroProfondaModel : kMaestroBreveModel;

  /// Il tetto di token per la profondita'.
  static int maxTokensForDepth(ConsultDepth depth) =>
      depth == ConsultDepth.profonda ? kProfondaMaxTokens : kBreveMaxTokens;

  /// Il budget di ragionamento per la profondita'.
  static int thinkingBudgetForDepth(ConsultDepth depth) =>
      depth == ConsultDepth.profonda
          ? kProfondaThinkingBudget
          : kBreveThinkingBudget;

  /// Quanti messaggi recenti passare come storia al modello. Oltre questa
  /// soglia il filo lo tiene la sintesi di sessione, non la cronologia piena.
  static const int kHistoryWindow = 20;

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
  }) async {
    final model = _ai.generativeModel(
      model: chatModel,
      systemInstruction: Content.system(
        MaestroPersona.systemInstruction(
          maestro: maestro,
          profile: profile,
          memory: memory,
        ),
      ),
      generationConfig: GenerationConfig(
        temperature: 0.9,
        topP: 0.95,
        maxOutputTokens: 800,
      ),
    );

    final chat = model.startChat(history: _toHistory(history));
    final response = await chat.sendMessage(Content.text(userMessage));
    final text = response.text?.trim();
    if (text == null || text.isEmpty) {
      throw const MaestroAiUnavailable('Il Maestro non ha trovato le parole.');
    }
    return text;
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
      systemInstruction: Content.system(
        MaestroPersona.consultInstruction(
          maestro: maestro,
          profile: profile,
          memory: memory,
          natal: natal,
          depth: depth,
        ),
      ),
      generationConfig: GenerationConfig(
        temperature: 0.9,
        topP: 0.95,
        maxOutputTokens: maxTokensForDepth(depth),
        thinkingConfig: ThinkingConfig.withThinkingBudget(
            thinkingBudgetForDepth(depth)),
        // Uscita nei tre strati come JSON, cosi' l'app la mostra come qualunque
        // altra risposta. Parsing difensivo, come nel distillato.
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
  }) async {
    final t = theme.trim();
    if (t.isEmpty || lenses.length < 2) {
      throw const MaestroAiUnavailable('Niente da mettere a confronto.');
    }

    // Flash, ragionamento spento, tetto contenuto: la sintesi e' breve.
    final model = _ai.generativeModel(
      model: kMaestroProfondaModel,
      systemInstruction: Content.system(
        MaestroPersona.synthesisInstruction(natal: natal),
      ),
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topP: 0.95,
        maxOutputTokens: kSynthesisMaxTokens,
        thinkingConfig: ThinkingConfig.withThinkingBudget(0),
      ),
    );

    // Le lenti gia' ottenute, nell'ordine fisso del cerchio, come materiale.
    final buffer = StringBuffer('Domanda della persona: «$t».\n\n');
    for (final l in lenses) {
      buffer
        ..writeln('${l.maestro.displayName} (${l.maestro.domainTitle}):')
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
    return text;
  }

  @override
  Future<MemoryDigest?> distill({
    required Maestro maestro,
    required UserProfile profile,
    required MaestroMemory previous,
    required List<ChatMessage> history,
  }) async {
    if (history.isEmpty) return null;
    try {
      final model = _ai.generativeModel(
        model: distillModel,
        systemInstruction: Content.system(
          MaestroPersona.distillInstruction(maestro),
        ),
        generationConfig: GenerationConfig(
          temperature: 0.2,
          maxOutputTokens: 400,
          responseMimeType: 'application/json',
        ),
      );

      final transcript = StringBuffer();
      if (previous.sessionSummary.trim().isNotEmpty) {
        transcript.writeln('Sintesi precedente: ${previous.sessionSummary.trim()}');
      }
      for (final m in history) {
        final who = m.isUser ? 'Utente' : maestro.displayName;
        transcript.writeln('$who: ${m.text}');
      }

      final response =
          await model.generateContent([Content.text(transcript.toString())]);
      final raw = response.text?.trim();
      if (raw == null || raw.isEmpty) return null;
      return _parseDigest(raw, previous);
    } catch (_) {
      // Il distillato e' best effort: se fallisce, la memoria resta com'era.
      return null;
    }
  }

  /// Traduce la storia di dominio nella forma attesa da Gemini, tenendo solo la
  /// finestra recente e lasciando fuori i messaggi ancora in sospeso o falliti.
  List<Content> _toHistory(List<ChatMessage> history) {
    final clean = history
        .where((m) => !m.pending && !m.failed && m.text.trim().isNotEmpty)
        .toList();
    final windowed = clean.length > kHistoryWindow
        ? clean.sublist(clean.length - kHistoryWindow)
        : clean;
    return [
      for (final m in windowed)
        m.isUser
            ? Content.text(m.text)
            : Content.model([TextPart(m.text)]),
    ];
  }

  /// Estrae i tre strati dal JSON del modello, in modo difensivo: qualunque
  /// forma inattesa torna null, e chi chiama cade sul ripiego. Mai un'eccezione
  /// di parsing che arrivi cruda a video.
  MaestroReply? _parseReply(String raw) {
    try {
      final start = raw.indexOf('{');
      final end = raw.lastIndexOf('}');
      if (start < 0 || end <= start) return null;
      final decoded = jsonDecode(raw.substring(start, end + 1));
      if (decoded is! Map) return null;
      final glance = (decoded['glance'] as Object?)?.toString().trim() ?? '';
      final reading = (decoded['reading'] as Object?)?.toString().trim() ?? '';
      final invite = (decoded['invite'] as Object?)?.toString().trim() ?? '';
      return MaestroReply(glance: glance, reading: reading, invite: invite);
    } catch (_) {
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
            if (f != null && f.toString().trim().isNotEmpty) f.toString().trim(),
      ];
      final digest = MemoryDigest(summary: summary, facts: facts);
      return digest.isEmpty ? null : digest;
    } catch (_) {
      return null;
    }
  }
}
