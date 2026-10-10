// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **LE PORTE DI APPROFONDIMENTO NON MANDANO DA SOLE.** Ordine DX voci 01 e 03.
///
/// Il censimento della voce DX.03 sta nel manifesto
/// `docs/ordini/ORDINE_DX_MANIFESTO.md`: tredici porte che aprono la chat di
/// un Maestro con una domanda preimpostata. Questa guardia pretende due cose.
/// Le porte che il codice ha davvero sono quelle che il censimento elenca,
/// cosi' una funzione nuova col pulsante Parlane non resta fuori dalle
/// verifiche. E nessuna di loro manda la domanda: la chat la scrive nel
/// campo, e parte solo quando la persona tocca la freccia.
void main() {
  final manifesto = File('docs/ordini/ORDINE_DX_MANIFESTO.md');

  /// **LE PORTE DEL CODICE SONO QUELLE DEL CENSIMENTO.** Voce DX.03.
  ///
  /// Si misura l'insieme dei FILE, non le righe: le righe cambiano a ogni
  /// lavoro sopra di loro, e una guardia legata al numero di riga cadrebbe
  /// alla prossima consegna senza che niente di vero fosse cambiato.
  test('DX.03: ogni porta di approfondimento del codice sta nel censimento',
      () {
    final sorgenti = righeDiLib();
    final conAzioni = <String>{};
    final conDomanda = <String>{};
    for (final s in sorgenti) {
      final codice = senzaCommenti(s.righe.join('\n'));
      if (RegExp(r'(?<!class |const )\bAzioniDelResponso\(').hasMatch(codice) &&
          !s.percorso
              .endsWith('lib/features/ricordi/azioni_del_responso.dart')) {
        conAzioni.add(s.percorso.substring(s.percorso.indexOf('lib/')));
      }
      if (RegExp(r'initialUserMessage:\s*[^,)\s]').hasMatch(codice) &&
          !s.percorso.endsWith('maestro_chat_screen.dart')) {
        conDomanda.add(s.percorso.substring(s.percorso.indexOf('lib/')));
      }
    }
    cardinaleMinimo(conAzioni.length, 12,
        cosa: 'funzioni col pulsante Parlane',
        perche: 'Il censimento DX.03 ne ha contate dodici il 18 settembre '
            '2026, piu\' il Consiglio.');

    final testo = manifesto.readAsStringSync();
    final nelCensimento = {
      for (final m
          in RegExp(r'^\| [^|]+\| `(lib/[^:`]+)(?::\d+)?`', multiLine: true)
              .allMatches(testo))
        m.group(1)!,
    };
    print('DX.03: porte nel codice ${conAzioni.length} col Parlane, '
        '${conDomanda.length} che aprono con la domanda; '
        'nel censimento ${nelCensimento.length}');

    expect(conAzioni.difference(nelCensimento), isEmpty,
        reason: 'una funzione ha il pulsante Parlane e il censimento non la '
            'conosce: va aggiunta al manifesto e verificata voce per voce');
    expect(
        conDomanda,
        {
          'lib/features/ricordi/azioni_del_responso.dart',
          'lib/features/maestri/ask/ask_maestri_screen.dart',
        },
        reason: 'una porta nuova apre la chat con una domanda preimpostata: '
            'non e\' nel censimento DX.03');
    expect(nelCensimento.difference(conAzioni),
        {'lib/features/maestri/ask/ask_maestri_screen.dart'},
        reason:
            'il censimento nomina una porta che nel codice non c\'e\' piu\'');
  });

  /// **NESSUNA PORTA MANDA DA SE'.** Voce DX.01, su tutte e tredici.
  ///
  /// Tutte passano la domanda a `MaestroChatScreen.route`, e la chat e'
  /// l'unico posto che la puo' mandare. Qui si pretende che la mandi solo al
  /// campo di scrittura, e mai a `send`.
  test('DX.01: la chat scrive la domanda nel campo e non la manda mai', () {
    final codice = senzaCommenti(
        File('lib/features/maestri/chat/maestro_chat_screen.dart')
            .readAsStringSync());
    // La RIGA intera, non cio' che segue il nome: `send(` sta prima.
    final usi = RegExp(r'[^\n]*widget\.initialUserMessage[^\n]*')
        .allMatches(codice)
        .map((m) => m.group(0)!)
        .toList();
    cardinaleMinimo(usi.length, 1,
        cosa: 'usi della domanda di approfondimento nella chat');
    for (final uso in usi) {
      expect(uso, isNot(contains('send')),
          reason: 'la chat manda la domanda di approfondimento da sola: '
              '"$uso"');
    }
    expect(codice, contains('initialText: widget.initialUserMessage'),
        reason: 'la domanda di approfondimento non arriva piu\' al campo');
  });
}
