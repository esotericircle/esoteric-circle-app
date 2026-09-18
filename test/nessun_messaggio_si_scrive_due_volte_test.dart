import 'dart:async';

import 'package:esoteric_circle/core/cammino/cammino_da_custodire.dart';
import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/services/memory/firestore_maestro_memory_repository.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

/// **NESSUN MESSAGGIO SI SCRIVE DUE VOLTE.** Ordine DV, 18 settembre 2026.
///
/// **Il fatto, dalle catture del fondatore**: aprendo le chat dei tre Maestri
/// comparivano domande che non aveva mai scritto, e comparivano in coppia.
/// *"Carta del giorno"* quattro volte in due coppie, *"Estrai una runa per
/// me"* due volte di fila, la domanda del soffio di Aura due volte di fila.
///
/// **La causa sta nel salvataggio.** Nell'app vera ogni scrittura della
/// memoria passa dal server: si accoda e parte da `_svuotaLaCoda`. La chat
/// salva la domanda senza aspettare e subito dopo salva il turno del Maestro;
/// le due chiamate svuotavano la coda **insieme**, ognuna leggeva il primo
/// elemento, cioe' la stessa domanda, e la mandava. Poi ognuna toglieva il
/// primo: la seconda toglieva il turno del Maestro, che al server non
/// arrivava mai. **La domanda raddoppiava e la risposta spariva.**
///
/// Al banco il difetto non si vedeva perche' le prove della chat usano il
/// repository in memoria, che non ha coda. Qui si usa quello vero, con una
/// porta viva come nell'app e un server che risponde con un ritardo, come la
/// rete.
class _ServerLento extends PortaDelCerchio {
  _ServerLento({this.ritardo = const Duration(milliseconds: 20)});

  final Duration ritardo;

  /// Cio' che il server ha scritto davvero, nell'ordine in cui l'ha scritto.
  final List<String> scritti = [];

  @override
  bool get viva => true;

  @override
  Future<bool> scriviLaMemoria({
    required String operazione,
    String? maestro,
    Map<String, Object?> campi = const {},
  }) async {
    await Future<void>.delayed(ritardo);
    scritti.add('$operazione:${campi['text'] ?? ''}');
    return true;
  }

  @override
  Future<StatoDelCerchio?> stato(
          {CamminoDaCustodire? cammino, bool azzeraIlCammino = false}) async =>
      null;

  @override
  Future<EsitoDelConsumo?> consuma({
    required String budget,
    required String idMovimento,
  }) async =>
      null;

  @override
  Future<int?> muoviGliEos({
    required String causale,
    required String motivo,
    required String idMovimento,
    int? quanti,
  }) async =>
      null;

  @override
  Future<bool> cancellaIlCerchio() async => true;
}

void main() {
  FirestoreMaestroMemoryRepository memoriaCon(_ServerLento server) =>
      FirestoreMaestroMemoryRepository(
        uid: 'chi-chiede',
        firestore: FakeFirebaseFirestore(),
        porta: server,
      );

  test(
      'LA DOMANDA E IL TURNO DEL MAESTRO arrivano al server una volta sola, '
      'e tutti e due', () async {
    // E' esattamente cio' che fa la chat: la domanda si salva senza
    // aspettare, e il turno del Maestro subito dopo.
    final server = _ServerLento();
    final memoria = memoriaCon(server);
    final domanda = memoria.appendMessage(
      Maestro.medora,
      const ChatMessage(role: ChatRole.user, text: 'Carta del giorno'),
    );
    await memoria.appendMessage(
      Maestro.medora,
      const ChatMessage(role: ChatRole.maestro, text: 'La tua carta di oggi'),
    );
    await domanda;

    expect(server.scritti, [
      'messaggio:Carta del giorno',
      'messaggio:La tua carta di oggi',
    ],
        reason: 'il server ha ricevuto ${server.scritti}: una domanda scritta '
            'due volte e' ' un turno perso sono il difetto che il fondatore ha '
            'visto sul telefono');
    expect(memoria.scrittureInAttesa, 0,
        reason: 'la coda non si e\' svuotata del tutto');
  });

  test('DIECI SCRITTURE INSIEME: ognuna una volta, nell\'ordine', () async {
    final server = _ServerLento(ritardo: const Duration(milliseconds: 5));
    final memoria = memoriaCon(server);
    final inCorso = [
      for (var i = 0; i < 10; i++)
        memoria.appendMessage(
          Maestro.caligo,
          ChatMessage(role: ChatRole.user, text: 'domanda $i'),
        ),
    ];
    await Future.wait(inCorso);
    expect(server.scritti, [
      for (var i = 0; i < 10; i++) 'messaggio:domanda $i',
    ]);
    expect(memoria.scrittureInAttesa, 0);
  });

  test('una scrittura che arriva mentre la coda si sta svuotando non resta '
      'indietro', () async {
    // Il caso di confine: la corsa sta finendo quando arriva la scrittura
    // nuova. Non deve restare in coda fino alla prossima domanda.
    final server = _ServerLento(ritardo: const Duration(milliseconds: 10));
    final memoria = memoriaCon(server);
    final prima = memoria.appendMessage(
      Maestro.aura,
      const ChatMessage(role: ChatRole.user, text: 'prima'),
    );
    await Future<void>.delayed(const Duration(milliseconds: 9));
    final seconda = memoria.appendMessage(
      Maestro.aura,
      const ChatMessage(role: ChatRole.user, text: 'seconda'),
    );
    await Future.wait([prima, seconda]);
    expect(server.scritti, ['messaggio:prima', 'messaggio:seconda']);
    expect(memoria.scrittureInAttesa, 0);
  });
}
