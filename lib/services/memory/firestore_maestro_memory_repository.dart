import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../core/chat/chat_message.dart';
import '../../core/chat/maestro_memory.dart';
import '../../core/chat/user_profile.dart';
import '../../core/maestro/maestro.dart';
import '../server/porta_del_cerchio.dart';
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
    PortaDelCerchio porta = const PortaSpentaDelCerchio(),
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _semanticIndex = semanticIndex,
        _archive = archive,
        _porta = porta;

  /// LA PORTA DEL SERVER, ordine N voce 2b.
  ///
  /// **La memoria si legge dritta e si scrive solo da la'.** Le regole di
  /// sicurezza vietano al telefono ogni scrittura sotto `users/{uid}`: una
  /// porta lasciata aperta su un ramo e' aperta su tutto il ramo, e su quel
  /// ramo ci sono anche i contatori e il saldo. Le letture restano dirette
  /// perche' sono quelle che devono essere veloci e funzionare con la cache.
  ///
  /// **Con la porta spenta si scrive dritto, e succede solo dove non ci sono
  /// regole a impedirlo: nelle prove.** Nell'app vera la porta e' sempre
  /// quella vera, e una guardia enumera i punti di `lib` che costruiscono
  /// questo repository perche' resti cosi'.
  final PortaDelCerchio _porta;

  /// CIO' CHE IL SERVER NON HA ANCORA PRESO, ordine N voce 2e.
  ///
  /// Senza rete la conversazione continua e la memoria di questa sessione
  /// resta viva in RAM: le scritture si accodano qui e partono alla prima
  /// che riesce. Se l'app muore prima del ritorno della rete, quei turni non
  /// sono ricordati: e' la perdita dichiarata, e si preferisce a un turno
  /// scritto sul telefono che il server non conoscera' mai.
  final List<Map<String, Object?>> _daMandare = [];

  int get scrittureInAttesa => _daMandare.length;

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
    await _scrivi(
      operazione: 'profilo',
      campi: {
        'displayName': profile.displayName,
        'courtesyForm': profile.courtesyForm.name,
        'disclaimerAcceptedAt': profile.disclaimerAcceptedAt?.toIso8601String(),
      },
      dritto: () => _userDoc.set({
        'displayName': profile.displayName,
        'courtesyForm': profile.courtesyForm.name,
        'disclaimerAcceptedAt': profile.disclaimerAcceptedAt == null
            ? null
            : Timestamp.fromDate(profile.disclaimerAcceptedAt!),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)),
    );
  }

  /// LA SCRITTURA PASSA DAL SERVER, e questa e' l'unica via.
  ///
  /// Se la porta e' viva ma non risponde (rete assente, funzione non ancora
  /// distribuita) la scrittura si accoda e si riprova alla prossima: non si
  /// ripiega MAI sulla scrittura diretta, che le regole respingerebbero e che
  /// comunque farebbe rientrare dalla finestra cio' che si e' chiuso.
  Future<void> _scrivi({
    required String operazione,
    required Map<String, Object?> campi,
    String? maestro,
    required Future<void> Function() dritto,
  }) async {
    if (!_porta.viva) {
      await dritto();
      return;
    }
    _daMandare.add({
      'operazione': operazione,
      'maestro': maestro,
      'campi': campi,
    });
    await _svuotaLaCoda();
  }

  Future<void> _svuotaLaCoda() async {
    while (_daMandare.isNotEmpty) {
      final primo = _daMandare.first;
      final fatto = await _porta.scriviLaMemoria(
        operazione: primo['operazione']! as String,
        maestro: primo['maestro'] as String?,
        campi: (primo['campi'] as Map).cast<String, Object?>(),
      );
      if (!fatto) return;
      _daMandare.removeAt(0);
    }
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
    await _scrivi(
      operazione: 'memoriaDelMaestro',
      maestro: maestro.id,
      campi: {
        'facts': memory.facts,
        'sessionSummary': memory.sessionSummary,
      },
      dritto: () => _maestroDoc(maestro).set({
        'facts': memory.facts,
        'sessionSummary': memory.sessionSummary,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true)),
    );
  }

  /// LE SINTESI SETTIMANALI SFOCATE DAL SERVER. Ordine CG voce 09.
  ///
  /// **Si legge l'ULTIMA settimana sfocata, non tutte.** Le vecchie stanno
  /// dietro a quella e non aggiungono niente al contesto di adesso: leggerle
  /// tutte costerebbe una lettura per settimana passata, per sempre.
  ///
  /// **Una lettura sola**, e il vuoto quando non c'e' niente: un server piu'
  /// vecchio dell'app, o una persona che non ha ancora una settimana passata,
  /// non devono spegnere la chat.
  @override
  Future<MemoryDigest> sintesiSfocate(Maestro maestro) async {
    try {
      const vuoto = MemoryDigest(summary: '', facts: []);
      final snap = await _db
          .collection('users')
          .doc(uid)
          .collection('maestri')
          .doc(maestro.id)
          .collection('sintesi')
          .orderBy('quando', descending: true)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return vuoto;
      final dati = snap.docs.first.data();
      final fatti = dati['fatti'];
      return MemoryDigest(
        summary: '${dati['sintesi'] ?? ''}',
        facts: fatti is List ? [for (final f in fatti) '$f'] : const [],
      );
    } catch (errore) {
      debugPrint('Memoria: le sintesi sfocate non si rileggono. $errore');
      return const MemoryDigest(summary: '', facts: []);
    }
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
    await _scrivi(
      operazione: 'messaggio',
      maestro: maestro.id,
      campi: _datiTrasportabili(message),
      dritto: () => _messagesCol(maestro).add(_datiDi(message)),
    );
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
    await _scrivi(
      operazione: 'ultimoMessaggio',
      maestro: maestro.id,
      campi: _datiTrasportabili(messaggio),
      dritto: () => ultimo.docs.first.reference.set(_datiDi(messaggio)),
    );
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
        if (m.seguito != null) 'seguito': m.seguito,
        if (m.autore != null) 'autore': m.autore!.id,
        if (m.intentId != null) 'intentId': m.intentId,
        if (m.tipo != null) 'tipo': m.tipo!.name,
        // **LA CONVERSAZIONE E' UNA MARCATURA, ordine CI voce 06.** Assente
        // sui messaggi vecchi, e vuol dire la prima conversazione: nessuna
        // migrazione, che a un milione di persone sarebbero quaranta milioni
        // di scritture per niente.
        if (m.conversazione != null) 'conversazione': m.conversazione,
      };

  /// GLI STESSI CAMPI, ma trasportabili in una chiamata.
  ///
  /// `FieldValue.serverTimestamp()` e' un ordine per Firestore, non un dato:
  /// dentro il corpo di una callable non ci sta. L'orario lo mette il server
  /// quando scrive, che e' anche l'unico orario di cui ci si puo' fidare.
  Map<String, Object?> _datiTrasportabili(ChatMessage m) {
    final dati = Map<String, Object?>.from(_datiDi(m));
    dati.remove('createdAt');
    return dati;
  }

  @override
  Future<int> quantiMomenti() async {
    var quanti = 0;
    for (final maestro in Maestro.values) {
      final messaggi = await _messagesCol(maestro).limit(500).get();
      quanti += messaggi.docs.length;
      final memoria = await _maestroDoc(maestro).get();
      final fatti = memoria.data()?['facts'];
      if (fatti is List) quanti += fatti.length;
    }
    return quanti;
  }

  @override
  Future<void> deleteAllData() async {
    // **IL RAMO SI AZZERA, L'ACCOUNT NON SI TOCCA. Ordine BH voce 06.**
    // Qui c'era `cancellaIlCerchio`, cioe' la cancellazione dell'ACCOUNT:
    // cosi' TUTTE le strade che promettevano "l'account resta tuo" (la voce
    // azzera del menu e quella delle Impostazioni) finivano per cancellare
    // anche l'accesso. Chi vuole l'oblio dell'account chiama la porta
    // dell'oblio per conto suo: questo metodo cancella i DATI, come dice il
    // nome, e il giro locale qui sotto resta per le prove e per quando il
    // server non risponde.
    if (_porta.viva && await _porta.azzeraIDati()) {
      _daMandare.clear();
      await _semanticIndex.forget(uid);
      await _archive.purge(uid);
      return;
    }
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
      seguito: data['seguito'] as String?,
      intentId: data['intentId'] as String?,
      autore: _primoDove(Maestro.values, (m) => m.id == data['autore']),
      tipo: _primoDove(TipoDiMessaggio.values, (t) => t.name == data['tipo']),
      conversazione: data['conversazione'] as String?,
    );
  }
}
