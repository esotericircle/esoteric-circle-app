import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/maestri/live/il_parlato_del_maestro.dart';
import 'package:esoteric_circle/features/maestri/live/stato_della_schermata_live.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA RISPOSTA SCRITTA CHE DIVENTA VOCE.** Ordine EG voci 01 e 02, 23
/// settembre 2026.
///
/// Nella 2277 il volto del Maestro restava fermo e muto perche' nessuno gli
/// mandava la voce. Adesso la risposta della chat si prepara per la voce e si
/// chiede al server a pezzi: qui si prova che i pezzi **non perdono parole**,
/// che non portano segni che la voce leggerebbe ad alta voce, e che nessuno
/// supera il tetto, perche' un pezzo lungo fa aspettare la persona.
void main() {
  const risposta = '✦ **Il cielo di stasera** ti parla chiaro.\n\n'
      'La Luna in Cancro chiede di tornare a casa, di ascoltare quello che '
      'senti prima di quello che pensi. Non e\' un invito alla fuga: e\' un '
      'invito al ritorno. Marte invece spinge avanti, e la tensione fra i due '
      'e\' la tua settimana. _Respira_, poi scegli. Domani il Sole entra in '
      'un segno d\'aria, e le parole tornano leggere. Scrivimi com\'e\' '
      'andata, quando vuoi.';

  test('I PEZZI NON PERDONO PAROLE, non portano segni e stanno sotto il tetto',
      () {
    final pezzi = IlParlatoDelMaestro.pezzi(risposta);
    // ignore: avoid_print
    print('EG.01: ${pezzi.length} pezzi, lunghezze '
        '${pezzi.map((p) => p.length).toList()}');
    expect(pezzi.length, greaterThanOrEqualTo(2),
        reason: 'una risposta di sei frasi deve partire a pezzi');
    for (final p in pezzi) {
      expect(p.length, lessThanOrEqualTo(IlParlatoDelMaestro.pezzoMassimo),
          reason: 'pezzo troppo lungo: $p');
      expect(p, isNot(matches(RegExp(r'[*_#`>✦]'))),
          reason: 'la voce leggerebbe questi segni: $p');
    }
    expect(pezzi.join(' '), IlParlatoDelMaestro.daDire(risposta),
        reason: 'unire i pezzi deve ridare tutto il testo, parola per parola');
    // Si taglia alla fine di una frase, mai a meta'.
    for (final p in pezzi.take(pezzi.length - 1)) {
      expect(p, matches(RegExp(r'[.!?…]$')), reason: 'tagliato a meta\': $p');
    }
  });

  test('UNA RISPOSTA VUOTA NON CHIEDE NESSUNA VOCE', () {
    expect(IlParlatoDelMaestro.pezzi(''), isEmpty);
    expect(IlParlatoDelMaestro.pezzi('  ✦ ** \n '), isEmpty);
  });

  test('OGNI MAESTRO SALUTA A VOCE CON UNA FRASE SUA', () {
    final saluti = {for (final m in Maestro.values) ilSalutoDellaVoceViva(m)};
    expect(saluti.length, Maestro.values.length,
        reason: 'due Maestri direbbero la stessa frase');
    for (final s in saluti) {
      expect(IlParlatoDelMaestro.pezzi(s), hasLength(1),
          reason: 'il saluto deve partire in una chiamata sola: $s');
    }
  });
}
