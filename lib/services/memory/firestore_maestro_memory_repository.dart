import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/chat/chat_message.dart';
import '../../core/chat/maestro_memory.dart';
import '../../core/chat/user_profile.dart';
import '../../core/maestro/maestro.dart';
import 'maestro_memory_repository.dart';
import 'memory_hooks.dart';

/// Persistenza della memoria dei Maestri su Firestore, per la Demo.
///
/// Struttura, tutto sotto l'utente autenticato (anche in anonimo):
///   users/{uid}
///     displayName, courtesyForm, disclaimerAcceptedAt, updatedAt
///   users/{uid}/maestri/{maestroId}
///     facts (array), sessionSummary, updatedAt
///   users/{uid}/maestri/{maestroId}/messages/{autoId}
///     role, text, createdAt
///
/// I fatti astronomici non stanno qui: questa e' solo la memoria relazionale.
class FirestoreMaestroMemoryRepository implements MaestroMemoryRepository {
  FirestoreMaestroMemoryRepository({
    required this.uid,
    FirebaseFirestore? firestore,
    SemanticIndexHook semanticIndex = const NoopSemanticIndexHook(),
    HistoryArchiveHook archive = const NoopHistoryArchiveHook(),
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _semanticIndex = semanticIndex,
        _archive = archive;

  final String uid;
  final FirebaseFirestore _db;

  // Prese verso i livelli profondi (pgvector, Cloud Storage), a vuoto per
  // default: predisposte, non attive.
  final SemanticIndexHook _semanticIndex;
  final HistoryArchiveHook _archive;

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _db.collection('users').doc(uid);

  DocumentReference<Map<String, dynamic>> _maestroDoc(Maestro maestro) =>
      _userDoc.collection('maestri').doc(maestro.id);

  CollectionReference<Map<String, dynamic>> _messagesCol(Maestro maestro) =>
      _maestroDoc(maestro).collection('messages');

  @override
  Future<UserProfile> loadProfile() async {
    final snap = await _userDoc.get();
    final data = snap.data();
    if (data == null) return UserProfile.empty;
    return UserProfile(
      displayName: data['displayName'] as String?,
      courtesyForm: CourtesyForm.fromId(data['courtesyForm'] as String?),
      disclaimerAcceptedAt:
          (data['disclaimerAcceptedAt'] as Timestamp?)?.toDate(),
    );
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await _userDoc.set({
      'displayName': profile.displayName,
      'courtesyForm': profile.courtesyForm.name,
      'disclaimerAcceptedAt': profile.disclaimerAcceptedAt == null
          ? null
          : Timestamp.fromDate(profile.disclaimerAcceptedAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<MaestroMemory> loadMemory(Maestro maestro) async {
    final snap = await _maestroDoc(maestro).get();
    final data = snap.data();
    if (data == null) return MaestroMemory.empty;
    final rawFacts = data['facts'];
    return MaestroMemory(
      facts: <String>[
        if (rawFacts is List)
          for (final f in rawFacts)
            if (f != null) f.toString(),
      ],
      sessionSummary: (data['sessionSummary'] as String?) ?? '',
    );
  }

  @override
  Future<void> saveMemory(Maestro maestro, MaestroMemory memory) async {
    await _maestroDoc(maestro).set({
      'facts': memory.facts,
      'sessionSummary': memory.sessionSummary,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<List<ChatMessage>> recentMessages(Maestro maestro,
      {int limit = 40}) async {
    final snap = await _messagesCol(maestro)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    final messages = <ChatMessage>[
      for (final doc in snap.docs) _messageFromDoc(doc.data()),
    ];
    // La query e' dal piu' nuovo al piu' vecchio: la riportiamo in ordine di
    // lettura, dal piu' vecchio al piu' nuovo.
    return messages.reversed.toList();
  }

  @override
  Future<void> appendMessage(Maestro maestro, ChatMessage message) async {
    await _messagesCol(maestro).add(_datiDi(message));
    // Prese verso i livelli profondi: a vuoto per default.
    await _semanticIndex.index(uid, maestro, message);
    await _archive.archive(uid, maestro, message);
  }

  @override
  Future<void> sostituisciUltimoMessaggio(
      Maestro maestro, ChatMessage messaggio) async {
    final ultimo = await _messagesCol(maestro)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();
    if (ultimo.docs.isEmpty) {
      await appendMessage(maestro, messaggio);
      return;
    }
    // `set` e non `update`: il turno in attesa era stato scritto con gli stessi
    // campi, e qui li si riscrive tutti, compresi quelli che tornano falsi.
    await ultimo.docs.first.reference.set(_datiDi(messaggio));
    await _semanticIndex.index(uid, maestro, messaggio);
    await _archive.archive(uid, maestro, messaggio);
  }

  /// I CAMPI DI UN MESSAGGIO, TUTTI.
  ///
  /// Qui si salvavano `role` e `text` soltanto. Non e' un dettaglio di
  /// completezza: `failed` e' cio' che tiene attaccato il Riprova, `ripiego` e'
  /// cio' che distingue una lettura dell'app dalla voce del Maestro, e `autore`
  /// e' chi ha parlato. Senza, riaprendo la chat un ripiego passava per la
  /// parola del Maestro e un turno fallito perdeva il suo Riprova.
  Map<String, Object?> _datiDi(ChatMessage m) => {
        'role': m.role.name,
        'text': m.text,
        'createdAt': FieldValue.serverTimestamp(),
        'pending': m.pending,
        'failed': m.failed,
        'ripiego': m.ripiego,
        'approfondita': m.approfondita,
        if (m.autore != null) 'autore': m.autore!.id,
        if (m.intentId != null) 'intentId': m.intentId,
        if (m.tipo != null) 'tipo': m.tipo!.name,
      };

  @override
  Future<void> deleteAllData() async {
    // Diritto all'oblio: si cancella tutto e solo sotto questo utente. Prima la
    // cronologia di ogni Maestro, poi i documenti dei Maestri, infine il
    // profilo. Le prese profonde vengono ripulite in coda.
    for (final maestro in Maestro.values) {
      await _deleteCollection(_messagesCol(maestro));
      await _maestroDoc(maestro).delete();
    }
    await _userDoc.delete();
    await _semanticIndex.forget(uid);
    await _archive.purge(uid);
  }

  /// Cancella una collezione a blocchi, per non superare il limite del batch.
  Future<void> _deleteCollection(
    CollectionReference<Map<String, dynamic>> col, {
    int chunk = 300,
  }) async {
    while (true) {
      final snap = await col.limit(chunk).get();
      if (snap.docs.isEmpty) break;
      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      if (snap.docs.length < chunk) break;
    }
  }

  /// Il primo che soddisfa, oppure niente. `firstOrNull` vive in `collection`,
  /// che non e' una dipendenza diretta di questo progetto: si evita di
  /// aggiungerne una per tre righe.
  static T? _primoDove<T>(List<T> valori, bool Function(T) quando) {
    for (final v in valori) {
      if (quando(v)) return v;
    }
    return null;
  }

  ChatMessage _messageFromDoc(Map<String, dynamic> data) {
    final role = (data['role'] as String?) == ChatRole.user.name
        ? ChatRole.user
        : ChatRole.maestro;
    return ChatMessage(
      role: role,
      text: (data['text'] as String?) ?? '',
      at: (data['createdAt'] as Timestamp?)?.toDate(),
      pending: (data['pending'] as bool?) ?? false,
      failed: (data['failed'] as bool?) ?? false,
      ripiego: (data['ripiego'] as bool?) ?? false,
      approfondita: (data['approfondita'] as bool?) ?? false,
      intentId: data['intentId'] as String?,
      autore: _primoDove(Maestro.values, (m) => m.id == data['autore']),
      tipo: _primoDove(
          TipoDiMessaggio.values, (t) => t.name == data['tipo']),
    );
  }
}
