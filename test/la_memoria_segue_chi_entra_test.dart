// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/chat/chat_message.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/services/memory/firestore_maestro_memory_repository.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA MEMORIA SEGUE CHI ENTRA. Ordine EA voce 13, 20 settembre 2026.
///
/// **Il fatto, dal fondatore**: *"quando finalmente riconosce l'email, non mi
/// vengono aggiornati i miei dati, traguardi, EOS, ecc."*.
///
/// **Due cose diverse, e vanno separate.** Il fondatore aveva **cancellato i
/// suoi dati** prima di uscire dal Cerchio, quindi ritrovare zero eventi e il
/// saldo di un Cerchio vuoto **e' il comportamento previsto**: la
/// cancellazione toglie i dati dal server, e rientrare non li resuscita.
///
/// **Ma sul ramo c'era anche un difetto vero**, ed e' questo: il registro
/// della memoria nasce una volta sola, all'avvio, e si teneva l'uid di
/// allora. Chi entrava nel proprio Cerchio **dopo** l'avvio cambiava
/// identita', e la memoria continuava a leggere e a scrivere sotto quella
/// anonima di prima: i propri turni non comparivano, e quelli nuovi finivano
/// nel posto sbagliato, finche' l'app non veniva riavviata.
void main() {
  test('dopo l\'ingresso legge e scrive sotto la nuova identita\'', () async {
    final db = FakeFirebaseFirestore();
    var chiSono = 'anonimo-di-questo-telefono';
    final memoria = FirestoreMaestroMemoryRepository(
      uid: 'anonimo-di-questo-telefono',
      uidVivo: () => chiSono,
      firestore: db,
    );

    await memoria.appendMessage(Maestro.medora,
        const ChatMessage(role: ChatRole.user, text: 'da anonimo'));

    // La persona entra nel proprio Cerchio: l'uid cambia, e l'app non
    // riparte.
    chiSono = 'il-mio-cerchio';
    await memoria.appendMessage(
        Maestro.medora, const ChatMessage(role: ChatRole.user, text: 'da me'));

    final miei = await memoria.recentMessages(Maestro.medora);
    print('ORDINE EA VOCE 13: dopo l\'ingresso i messaggi letti sono '
        '${miei.length}: ${miei.map((m) => m.text).toList()}');
    expect(miei.map((m) => m.text), ['da me'],
        reason: 'la memoria sta ancora leggendo sotto l\'identita\' di '
            'prima: i turni di chi e\' entrato non compaiono');

    final dentroIlMio = await db
        .collection('users')
        .doc('il-mio-cerchio')
        .collection('maestri')
        .doc(Maestro.medora.id)
        .collection('messages')
        .get();
    expect(dentroIlMio.docs.length, 1,
        reason: 'il turno nuovo non e\' finito nel Cerchio di chi e\' '
            'entrato');
  });

  test('senza risposta su chi e\' adesso, vale quella di partenza', () async {
    // **LA RETE**: un nullo vuol dire "non lo so", non "nessuno". Senza
    // questa riga una risposta vuota porterebbe a scrivere sotto un uid
    // vuoto, che e' peggio del difetto che stiamo curando.
    final db = FakeFirebaseFirestore();
    final memoria = FirestoreMaestroMemoryRepository(
      uid: 'quello-di-partenza',
      uidVivo: () => null,
      firestore: db,
    );
    await memoria.appendMessage(
        Maestro.aura, const ChatMessage(role: ChatRole.user, text: 'ciao'));
    final dove = await db
        .collection('users')
        .doc('quello-di-partenza')
        .collection('maestri')
        .doc(Maestro.aura.id)
        .collection('messages')
        .get();
    expect(dove.docs.length, 1);
  });

  test('e l\'app gli dice chi e\' adesso, non chi era all\'avvio', () {
    // **LA GUARDIA CAMMINA FINO AL PUNTO IN CUI IL REGISTRO NASCE**: senza
    // questa riga il repository saprebbe seguire l'identita' e nessuno
    // gliela passerebbe, che e' il modo piu' silenzioso di non curare
    // niente.
    final servizi = File('lib/services/app_services.dart').readAsStringSync();
    expect(servizi.contains('uidVivo:'), isTrue,
        reason: 'l\'app costruisce la memoria senza dirle chi e\' adesso');
    expect(servizi.contains('uidVivo: () => identita?.uid'), isTrue,
        reason: 'la memoria non chiede l\'identita\' viva alla porta');
  });
}
