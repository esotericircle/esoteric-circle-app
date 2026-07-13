import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/services/memory/firestore_maestro_memory_repository.dart';
import 'package:esoteric_circle/services/memory/in_memory_maestro_memory_repository.dart';
import 'package:esoteric_circle/services/memory/maestro_memory_repository.dart';
import 'package:esoteric_circle/services/memory/memory_hooks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

/// Il memory layer a livelli: profilo e fatti e sintesi (memoria calda),
/// cronologia completa per la rilettura, cancellazione GDPR isolata all'utente,
/// e le prese verso i livelli profondi (pgvector, Cloud Storage) predisposte.
/// Provato sul falso in memoria e sul falso Firestore.
class _RecordingSemantic implements SemanticIndexHook {
  final List<String> indexed = [];
  final List<String> forgotten = [];
  @override
  Future<void> index(String uid, Maestro maestro, ChatMessage message) async {
    indexed.add('$uid/${maestro.id}/${message.text}');
  }

  @override
  Future<void> forget(String uid) async => forgotten.add(uid);
}

class _RecordingArchive implements HistoryArchiveHook {
  final List<String> archived = [];
  final List<String> purged = [];
  @override
  Future<void> archive(String uid, Maestro maestro, ChatMessage message) async {
    archived.add('$uid/${maestro.id}/${message.text}');
  }

  @override
  Future<void> purge(String uid) async => purged.add(uid);
}

void main() {
  void sharedContract(
    String name,
    ({MaestroMemoryRepository repo, _RecordingSemantic sem, _RecordingArchive arc})
        Function() make,
  ) {
    group(name, () {
      test('Profilo, memoria calda e cronologia fanno il giro completo',
          () async {
        final repo = make().repo;

        // Profilo.
        await repo.saveProfile(const UserProfile(
          displayName: 'Sofia',
          courtesyForm: CourtesyForm.feminine,
        ));
        final p = await repo.loadProfile();
        expect(p.displayName, 'Sofia');
        expect(p.courtesyForm, CourtesyForm.feminine);

        // Memoria calda: fatti e sintesi.
        await repo.saveMemory(
          Maestro.medora,
          const MaestroMemory(
            facts: ['Segno solare Gemelli'],
            sessionSummary: 'Parlato del lavoro.',
          ),
        );
        final m = await repo.loadMemory(Maestro.medora);
        expect(m.facts, contains('Segno solare Gemelli'));
        expect(m.sessionSummary, 'Parlato del lavoro.');
        // Isolata per Maestro.
        expect((await repo.loadMemory(Maestro.aura)).isEmpty, isTrue);

        // Cronologia completa, in ordine di lettura.
        await repo.appendMessage(
            Maestro.medora, const ChatMessage(role: ChatRole.user, text: 'ciao'));
        await repo.appendMessage(Maestro.medora,
            const ChatMessage(role: ChatRole.maestro, text: 'ti accolgo'));
        final msgs = await repo.recentMessages(Maestro.medora);
        expect(msgs.length, 2);
        expect(msgs.map((e) => e.text), containsAll(['ciao', 'ti accolgo']));
      });

      test('Le prese profonde vengono chiamate, a vuoto per default', () async {
        final made = make();
        await made.repo.appendMessage(Maestro.caligo,
            const ChatMessage(role: ChatRole.user, text: 'una runa'));
        expect(made.sem.indexed, isNotEmpty);
        expect(made.arc.archived, isNotEmpty);
      });

      test('La cancellazione GDPR azzera tutto e pulisce le prese', () async {
        final made = make();
        final repo = made.repo;
        await repo.saveProfile(const UserProfile(displayName: 'Sofia'));
        await repo.saveMemory(Maestro.medora,
            const MaestroMemory(facts: ['x'], sessionSummary: 's'));
        await repo.appendMessage(Maestro.medora,
            const ChatMessage(role: ChatRole.user, text: 'ciao'));

        await repo.deleteAllData();

        expect((await repo.loadProfile()).displayName, isNull);
        expect((await repo.loadMemory(Maestro.medora)).isEmpty, isTrue);
        expect(await repo.recentMessages(Maestro.medora), isEmpty);
        expect(made.sem.forgotten, isNotEmpty);
        expect(made.arc.purged, isNotEmpty);
      });
    });
  }

  sharedContract('InMemory', () {
    final sem = _RecordingSemantic();
    final arc = _RecordingArchive();
    return (
      repo: InMemoryMaestroMemoryRepository(
          uid: 'u1', semanticIndex: sem, archive: arc),
      sem: sem,
      arc: arc,
    );
  });

  sharedContract('Firestore (falso)', () {
    final sem = _RecordingSemantic();
    final arc = _RecordingArchive();
    return (
      repo: FirestoreMaestroMemoryRepository(
        uid: 'u1',
        firestore: FakeFirebaseFirestore(),
        semanticIndex: sem,
        archive: arc,
      ),
      sem: sem,
      arc: arc,
    );
  });

  test('Firestore isola i dati per utente', () async {
    final db = FakeFirebaseFirestore();
    final u1 = FirestoreMaestroMemoryRepository(uid: 'u1', firestore: db);
    final u2 = FirestoreMaestroMemoryRepository(uid: 'u2', firestore: db);

    await u1.saveProfile(const UserProfile(displayName: 'Sofia'));
    await u1.appendMessage(Maestro.medora,
        const ChatMessage(role: ChatRole.user, text: 'segreto'));

    // u2 non vede nulla di u1.
    expect((await u2.loadProfile()).displayName, isNull);
    expect(await u2.recentMessages(Maestro.medora), isEmpty);

    // La cancellazione di u1 non tocca u2.
    await u2.saveProfile(const UserProfile(displayName: 'Bruno'));
    await u1.deleteAllData();
    expect((await u2.loadProfile()).displayName, 'Bruno');
  });

  test('Firestore rilegge la cronologia dal piu vecchio al piu nuovo',
      () async {
    final db = FakeFirebaseFirestore();
    final repo = FirestoreMaestroMemoryRepository(uid: 'u1', firestore: db);
    // Timestamp espliciti crescenti per un ordine deterministico.
    await db
        .collection('users/u1/maestri/medora/messages')
        .add({'role': 'user', 'text': 'prima', 'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1, 10))});
    await db
        .collection('users/u1/maestri/medora/messages')
        .add({'role': 'maestro', 'text': 'poi', 'createdAt': Timestamp.fromDate(DateTime(2026, 1, 1, 11))});
    final msgs = await repo.recentMessages(Maestro.medora);
    expect(msgs.map((e) => e.text).toList(), ['prima', 'poi']);
  });
}
