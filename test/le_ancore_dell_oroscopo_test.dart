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
///
/// **ORDINE ER VOCE 14, 27 settembre 2026.** Le ancore non si mostrano piu':
/// titolo e prima parte vengono dal giorno nelle dodici case, e cambiano ogni
/// giorno. **Le due leggi restano, e si applicano alle 144 prime parti che
/// hanno preso il posto delle 48 ancore**: la prima parte sta sempre davanti
/// alla corrente del giorno. Con loro una terza legge dell'anatomia: la
/// prima frase della scheda non nomina astri, li nomina la corrente.
void main() {
  final tutte = <String, String>{};
  HoroscopeData.primeDelGiorno.forEach((dominio, case_) {
    for (var casa = 0; casa < case_.length; casa++) {
      for (var v = 0; v < case_[casa].length; v++) {
        tutte['$dominio/casa ${casa + 1}/$v'] = case_[casa][v];
      }
    }
  });

  test('le prime parti sono centoquarantaquattro, tre per casa', () {
    expect(HoroscopeData.primeDelGiorno, hasLength(4));
    expect(tutte, hasLength(144));
  });

  test('nessuna prima parte nomina un astro', () {
    final astri = RegExp(
        r'\b(sole|luna|mercurio|venere|marte|giove|saturno|urano|nettuno|'
        r'plutone|stelle|cielo|astri)\b',
        caseSensitive: false);
    final colpe = [
      for (final e in tutte.entries)
        if (astri.hasMatch(e.value)) e.key,
    ];
    expect(colpe, isEmpty, reason: 'nominano un astro: $colpe');
  });

  test('nessuna ancora contiene la parola "oggi"', () {
    final colpe = tutte.entries
        .where(
            (e) => RegExp(r'\boggi\b', caseSensitive: false).hasMatch(e.value))
        .map((e) => e.key)
        .toList();
    // ignore: avoid_print
    print('ORDINE BD VOCE 07 (ER.14): prime parti lette ${tutte.length}, con "oggi" '
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
