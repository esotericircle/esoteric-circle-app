import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// IL SISTEMA ANTI ABUSO, CENSITO. Ordine BE voce 08.
///
/// **Richiesta del fondatore**: "controlla il sistema anti abuso per ogni
/// possibile situazione". Il censimento intero, strada per strada e con le
/// decisioni, sta nel manifesto dell'ordine BE. Qui vivono le guardie che
/// tengono vere le quattro difese portanti.
void main() {
  final server = File('functions/src/cerchio.ts').readAsStringSync();

  test('BE.08: il tetto delle condivisioni premiate e\' vivo, e vale 3', () {
    final borsellino =
        File('functions/src/borsellino.ts').readAsStringSync();
    expect(borsellino.contains('TETTO_CONDIVISIONI_PREMIATE = 3'), isTrue,
        reason: 'il tetto delle condivisioni premiate non vale piu\' 3');
    expect(server.contains('gia >= TETTO_CONDIVISIONI_PREMIATE'), isTrue,
        reason: 'il tetto non morde piu\' dentro muoviGliEos');
  });

  test('BE.08: il tetto vive DENTRO la transazione del saldo', () {
    // Contarlo fuori vorrebbe dire aggirarlo con due richieste insieme.
    final transazione = server.substring(
        server.indexOf('db.runTransaction'),
        server.indexOf('SCRIVE LA MEMORIA'));
    expect(transazione.contains('TETTO_CONDIVISIONI_PREMIATE'), isTrue,
        reason: 'il tetto delle condivisioni e\' uscito dalla transazione: '
            'due richieste simultanee lo aggirerebbero');
    expect(transazione.contains('if (gia.exists) return'), isTrue,
        reason: 'l\'idempotenza sul movimento e\' sparita: un accredito '
            'ripetuto verrebbe contato due volte');
  });

  test('BE.08: i tetti giornalieri usano il giorno del SERVER', () {
    // L'orologio del telefono spostato non deve spostare i tetti.
    expect(server.contains('chiaveDelGiorno()'), isTrue,
        reason: 'il server non calcola piu\' il giorno per conto suo: i '
            'tetti seguirebbero l\'orologio del telefono');
    final giorno = File('functions/src/giorno.ts').readAsStringSync();
    expect(giorno.contains('new Date()'), isTrue,
        reason: 'chiaveDelGiorno non parte piu\' dall\'orologio del server');
  });

  test('BE.08: il telefono non scrive mai il proprio ramo', () {
    final regole = File('firestore.rules').readAsStringSync();
    expect('allow write: if false;'.allMatches(regole).length,
        greaterThanOrEqualTo(2),
        reason: 'le regole di Firestore concedono di nuovo scritture dal '
            'telefono: saldo e contatori si potrebbero riscrivere a mano');
    // Si guardano le RIGHE ATTIVE: il commento di testa cita la regola
    // vecchia apposta, per raccontare cosa e' cambiato.
    final attive = regole
        .split('\n')
        .where((r) => !r.trimLeft().startsWith('//'))
        .join('\n');
    expect(attive.contains('allow write: if proprietario'), isFalse,
        reason: 'il proprietario puo\' di nuovo scrivere il proprio ramo: '
            'e\' la porta d\'abuso chiusa dall\'ordine N');
  });
}
