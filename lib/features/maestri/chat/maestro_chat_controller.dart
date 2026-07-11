import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../core/chat/chat_message.dart';
import '../../../core/chat/maestro_memory.dart';
import '../../../core/chat/user_profile.dart';
import '../../../core/maestro/maestro.dart';
import '../../../services/ai/maestro_ai_provider.dart';
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
  })  : _ai = ai,
        _memory = memory;

  final Maestro maestro;
  final MaestroAiProvider _ai;
  final MaestroMemoryRepository _memory;

  /// Ogni quanti turni dell'utente rinfrescare il distillato di memoria.
  static const int _distillEvery = 3;

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  UserProfile _profile = UserProfile.empty;
  UserProfile get profile => _profile;

  MaestroMemory _memoryState = MaestroMemory.empty;

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
        ..addAll(results[2] as List<ChatMessage>);
    } catch (_) {
      // Un errore di lettura non deve impedire di iniziare a parlare.
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Registra che l'utente ha visto e accettato il disclaimer, una volta sola.
  Future<void> acceptDisclaimer() async {
    if (_profile.hasSeenDisclaimer) return;
    _profile = _profile.copyWith(disclaimerAcceptedAt: DateTime.now());
    notifyListeners();
    try {
      await _memory.saveProfile(_profile);
    } catch (_) {
      // Se la scrittura fallisce lo si riproporra' al prossimo avvio.
    }
  }

  /// Invia un messaggio dell'utente e attende la risposta del Maestro.
  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || _sending) return;

    final priorHistory = List<ChatMessage>.of(_messages);
    final userMessage = ChatMessage(
      role: ChatRole.user,
      text: trimmed,
      at: DateTime.now(),
    );
    _messages.add(userMessage);
    unawaited(_persist(userMessage));

    await _generate(priorHistory: priorHistory, userText: trimmed);
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
    await _generate(
      priorHistory: List<ChatMessage>.of(priorHistory),
      userText: userText,
    );
  }

  Future<void> _generate({
    required List<ChatMessage> priorHistory,
    required String userText,
  }) async {
    _sending = true;
    final pending = ChatMessage(role: ChatRole.maestro, text: '', pending: true);
    _messages.add(pending);
    notifyListeners();

    try {
      final reply = await _ai.reply(
        maestro: maestro,
        profile: _profile,
        memory: _memoryState,
        history: priorHistory,
        userMessage: userText,
      );
      final answer = ChatMessage(
        role: ChatRole.maestro,
        text: reply,
        at: DateTime.now(),
      );
      _replaceLast(answer);
      unawaited(_persist(answer));
      _turnsSinceDistill++;
      unawaited(_maybeDistill());
    } on MaestroAiUnavailable {
      _replaceLast(pending.copyWith(
        text:
            'Il cerchio non e\' ancora acceso. Serve la configurazione AI per farmi parlare.',
        pending: false,
        failed: true,
      ));
    } catch (_) {
      _replaceLast(pending.copyWith(
        text: 'Le stelle si sono velate un istante. Possiamo riprovare.',
        pending: false,
        failed: true,
      ));
    } finally {
      _sending = false;
      notifyListeners();
    }
  }

  Future<void> _persist(ChatMessage message) async {
    try {
      await _memory.appendMessage(maestro, message);
    } catch (_) {
      // La cronologia persistente e' un di piu': un errore non blocca la chat.
    }
  }

  /// Ogni tot turni distilla la conversazione e aggiorna la memoria. Best
  /// effort: qualunque errore lascia la memoria com'era.
  Future<void> _maybeDistill() async {
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
    } catch (_) {
      // Nessun impatto sulla conversazione in corso.
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

  void _replaceLast(ChatMessage message) {
    if (_messages.isEmpty) {
      _messages.add(message);
    } else {
      _messages[_messages.length - 1] = message;
    }
  }
}
