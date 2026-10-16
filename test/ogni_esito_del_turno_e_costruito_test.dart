// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/entitlement/esito_del_turno.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **OGNI ESITO DEL TURNO E' COSTRUITO DA QUALCUNO.** Ordine EB voce 04, 21
/// settembre 2026.
///
/// **Il fatto, misurato durante il censimento dei consumi.**
/// `EsitoDelTurno` si dichiara *"l'elenco CHIUSO di tutti gli esiti
/// possibili: chi ne aggiunge uno viene costretto dal compilatore a dire se
/// costa una domanda, invece di dimenticarlo"*. Ma **due dei suoi sette
/// valori non li costruiva nessuno**, `limiteRaggiunto` e `instradamento`: i
/// due rami tornavano prima, con un `return` nudo, e la regola del costo non
/// li vedeva mai.
///
/// **Perche' conta, visto che l'effetto era lo stesso.** L'effetto coincideva
/// per caso, non per costruzione: a tenere in piedi la regola era il `return`
/// anticipato, non l'elenco chiuso. Il giorno che qualcuno toglie quel
/// `return` per aggiungere una riga dopo, **il costo cambia senza che nessuna
/// prova se ne accorga**, ed e' esattamente il difetto del 2 agosto 2026, in
/// cui un messaggio d'errore si prese l'unica domanda del giorno.
///
/// **Cosa misura.** Che per ogni valore dell'elenco esista almeno un punto di
/// `lib/` che lo costruisce. Un valore che nessuno costruisce e' un commento
/// con la sintassi di Dart.
void main() {
  test('nessun esito resta un valore che nessuno produce', () {
    const esiti = EsitoDelTurno.values;
    cardinaleMinimo(esiti.length, 7,
        cosa: 'esiti possibili di un turno con un Maestro',
        perche: 'Se l\'elenco si svuotasse, questa prova direbbe di si\' a '
            'niente.');

    // **Si legge il codice senza i commenti**: questo file stesso nomina i
    // due valori che mancavano, e un commento che li cita non li costruisce.
    final sorgenti = sorgentiDiLib()
        .map((f) => senzaCommenti(f.readAsStringSync()))
        .toList();
    cardinaleMinimo(sorgenti.length, 300,
        cosa: 'sorgenti di lib',
        perche: 'Se la cartella non si leggesse, nessun esito risulterebbe '
            'costruito e la prova cadrebbe per la ragione sbagliata.');

    final mai = <String>[];
    final conto = <String, int>{};
    for (final e in esiti) {
      // La costruzione e' `EsitoDelTurno.nome`, ovunque compaia: la
      // dichiarazione dell'enum non conta, perche' li' il nome sta da solo.
      final quante = sorgenti
          .map((s) => 'EsitoDelTurno.${e.name}'.allMatches(s).length)
          .fold<int>(0, (a, b) => a + b);
      conto[e.name] = quante;
      if (quante == 0) mai.add(e.name);
    }
    print('ORDINE EB VOCE 04: esiti costruiti $conto');
    expect(mai, isEmpty,
        reason: 'questi esiti sono dichiarati e non li costruisce nessuno: '
            '$mai. Un valore che nessuno produce non passa dalla regola del '
            'costo, e l\'elenco chiuso non protegge piu\' niente');
  });

  test('e la regola del costo resta una sola, e dice una cosa sola', () {
    // Se un giorno `consuma` cominciasse a dire di si' a due esiti, la
    // persona pagherebbe per qualcosa che non e' una risposta.
    final costano =
        EsitoDelTurno.values.where(CostoDelTurno.consuma).map((e) => e.name);
    print('ORDINE EB VOCE 04: esiti che costano $costano');
    expect(costano, ['rispostaVera'],
        reason: 'costa qualcosa che non e\' una risposta vera: $costano');
  });
}
