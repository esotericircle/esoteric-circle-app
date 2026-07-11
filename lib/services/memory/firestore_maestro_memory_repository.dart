import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/chat/chat_message.dart';
import '../../core/chat/maestro_memory.dart';
import '../../core/chat/user_profile.dart';
import '../../core/maestro/maestro.dart';
import 'maestro_memory_repository.dart';

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
  }) : _db = firestore ?? FirebaseFirestore.instance;

  final String uid;
  final FirebaseFirestore _db;

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
    await _messagesCol(maestro).add({
      'role': message.role.name,
      'text': message.text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  ChatMessage _messageFromDoc(Map<String, dynamic> data) {
    final role = (data['role'] as String?) == ChatRole.user.name
        ? ChatRole.user
        : ChatRole.maestro;
    return ChatMessage(
      role: role,
      text: (data['text'] as String?) ?? '',
      at: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
