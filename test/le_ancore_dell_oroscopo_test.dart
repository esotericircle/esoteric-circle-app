import 'package:esoteric_circle/core/horoscope/horoscope_data.dart';
import 'package:flutter_test/flutter_test.dart';

/// LE DUE LEGGI DELLE QUARANTOTTO ANCORE. Ordine BD voce 07.
///
/// Le ancore riscritte dall'Architetto obbediscono a una legge dichiarata nel
/// loro stesso file, e queste due guardie la tengono vera anche per ogni
/// frase futura:
///
/// 1. **L'ancora dice chi sei, non cosa fare oggi.** La parola "oggi"
///    appartiene al secondo strato, la corrente del giorno: quando stava in
///    tutte e due le meta', la ripetizione si sentiva a ogni scheda. Era il
///    difetto misurato nella build 2148 e registrato dall'ordine P.
///
/// 2. **Nessun innesto si ripete.** Ogni ancora chiude su una frase che apre
///    al cielo senza saperlo, e due schede non devono mai chiudere allo
///    stesso modo: le ultime cinque parole di due ancore qualsiasi non
///    possono coincidere.
void main() {
  final tutte = <String, String>{};
  HoroscopeData.anchors.forEach((segno, quattro) {
    for (var dominio = 0; dominio < quattro.length; dominio++) {
      tutte['$segno/$dominio "${quattro[dominio][0]}"'] = quattro[dominio][1];
    }
  });

  test('le ancore sono quarantotto, quattro per segno', () {
    expect(HoroscopeData.anchors, hasLength(12));
    expect(tutte, hasLength(48));
  });

  test('nessuna ancora contiene la parola "oggi"', () {
    final colpe = tutte.entries
        .where(
            (e) => RegExp(r'\boggi\b', caseSensitive: false).hasMatch(e.value))
        .map((e) => e.key)
        .toList();
    // ignore: avoid_print
    print('ORDINE BD VOCE 07: ancore lette ${tutte.length}, con "oggi" '
        '${colpe.length}');
    expect(colpe, isEmpty,
        reason: 'queste ancore dicono "oggi", che appartiene alla corrente '
            'del giorno, e la ripetizione tornerebbe a sentirsi: $colpe');
  });

  test('nessun innesto si ripete: le ultime cinque parole sono uniche', () {
    String coda(String testo) {
      final parole = testo
          .replaceAll(RegExp(r'[.,:;!?]'), '')
          .toLowerCase()
          .split(RegExp(r'\s+'))
        ..removeWhere((p) => p.isEmpty);
      return parole.length <= 5
          ? parole.join(' ')
          : parole.sublist(parole.length - 5).join(' ');
    }

    final viste = <String, String>{};
    final colpe = <String>[];
    tutte.forEach((dove, testo) {
      final chiusa = coda(testo);
      final prima = viste[chiusa];
      if (prima != null) {
        colpe.add('$dove chiude come $prima: "$chiusa"');
      }
      viste[chiusa] = dove;
    });
    // ignore: avoid_print
    print('ORDINE BD VOCE 07: chiuse distinte ${viste.length} su '
        '${tutte.length}');
    expect(colpe, isEmpty,
        reason: 'questi innesti si ripetono, e due schede chiuderebbero allo '
            'stesso modo:\n${colpe.join('\n')}');
  });
}
