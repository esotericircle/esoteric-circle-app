// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/chat/la_risposta_che_chiede.dart';
import 'package:esoteric_circle/core/entitlement/esito_del_turno.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **IL CHIARIMENTO NON COSTA.** Ordine EE voce 07, 23 settembre 2026.
///
/// **Decisione del fondatore, verbatim**: *"Chiede lui i dati"*, con
/// l'opzione scelta *"Nessun consumo finche' non risponde davvero"*.
///
/// **E' uno scarto con l'ordine EB voce 06, dichiarato.** Quell'ordine diceva
/// il contrario: *"Una domanda del Maestro e' una risposta vera, quindi
/// consuma"*, e il suo catalogo segnava `consuma: si'` per il messaggio
/// incomprensibile. **Padre dello scarto: EB voce 06.** La parola del
/// fondatore e' del 22 settembre e prevale.
///
/// **IL CANCELLO E' LARGO APPOSTA.** I due errori non pesano uguale: non
/// riconoscere un chiarimento fa pagare una risposta mai ricevuta, cioe' il
/// difetto che questa voce cura; riconoscerne uno che non c'era regala una
/// risposta. **In dubbio, non si paga.**
void main() {
  test('un chiarimento chiesto non fa scendere nessun contatore', () {
    print('ORDINE EE VOCE 07: il chiarimento consuma '
        '${CostoDelTurno.consuma(EsitoDelTurno.chiarimentoChiesto)}');
    expect(CostoDelTurno.consuma(EsitoDelTurno.chiarimentoChiesto), isFalse,
        reason: 'chi si sente chiedere cosa intendeva non ha ricevuto nessuna '
            'lettura, e pagarla sarebbe pagare un malinteso');
    // E l'altra meta': una risposta vera continua a costare, o l'app sarebbe
    // gratis per tutti.
    expect(CostoDelTurno.consuma(EsitoDelTurno.rispostaVera), isTrue,
        reason: 'una risposta vera non costa piu\' niente: non e\' cio\' che '
            'questa voce chiede');
  });

  test('si riconosce chi chiude chiedendo, e non chi chiede per strada', () {
    /// Le risposte vere dei Maestri, dal collaudo dell'ordine ED.
    const casi = <String, bool>{
      // Chiarimenti: chiudono chiedendo, e non costano.
      'Non riesco a comprendere il significato di cio\' che hai scritto. Se '
          'desideri, puoi provare a riformulare la tua domanda?': true,
      'Le tue parole non sono un segno chiaro per me. Cosa cerchi di '
          'comprendere?': true,
      'Per leggere il tuo cielo mi serve il giorno in cui sei nato. Me lo '
          'vuoi dire?': true,
      // Risposte vere: una domanda in mezzo non le rende chiarimenti.
      'Il Papa parla di una regola accettata. Ti sei mai chiesto chi l\'ha '
              'scritta? La risposta sta nel Dieci di Spade, che chiude un peso.':
          false,
      'Uruz indica forza primitiva. La tua situazione richiede di ascoltare '
          'la voce interiore.': false,
      'Senti il respiro che entra ed esce, in questo momento.': false,
    };
    cardinaleMinimo(casi.length, 6,
        cosa: 'risposte vere dei Maestri, dal collaudo',
        perche: 'Servono i casi che chiedono E quelli che rispondono: senza '
            'i secondi, un riconoscimento che dice sempre di si\' passerebbe.');

    final storti = <String>[];
    casi.forEach((testo, atteso) {
      final visto = LaRispostaCheChiede.eUnaDomanda(testo);
      if (visto != atteso) {
        storti.add('${atteso ? "chiarimento" : "risposta"} letto come '
            '${visto ? "chiarimento" : "risposta"}: "${testo.substring(0, 40)}..."');
      }
    });
    print('ORDINE EE VOCE 07: casi ${casi.length}, '
        'letti male ${storti.length}');
    expect(storti, isEmpty, reason: storti.join('\n'));
  });

  test('e la chiusura col gesto non nasconde la domanda', () {
    // I Maestri chiudono spesso con una riga di gesto o una virgoletta: se la
    // domanda sta prima di quella, il chiarimento resta un chiarimento.
    const conVirgolette = 'Cosa intendi con questo? ';
    print('ORDINE EE VOCE 07, con lo spazio in coda: '
        '${LaRispostaCheChiede.eUnaDomanda(conVirgolette)}');
    expect(LaRispostaCheChiede.eUnaDomanda(conVirgolette), isTrue,
        reason: 'uno spazio in coda fa pagare un chiarimento');
    expect(LaRispostaCheChiede.eUnaDomanda('Cosa intendi con questo?»'), isTrue,
        reason: 'una virgoletta di chiusura fa pagare un chiarimento');
  });
}
