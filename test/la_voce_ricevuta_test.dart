import 'package:esoteric_circle/features/maestri/live/la_voce_ricevuta.dart';
import 'package:flutter_test/flutter_test.dart';

/// **DOVE SI ROMPE LA VOCE. Ordine FE voce 05.** La misura sulla traccia che
/// il telefono riceve dal volto: una pausa lunga a meta' risposta e' una
/// rottura, la pausa fra due frasi no, e il silenzio prima della prima voce
/// e dopo l'ultima nemmeno.
void main() {
  /// Una risposta finta: [voce] dice per ogni passo di 100 ms se c'e' voce.
  LaVoceRicevuta conLaVoce(List<bool> voce, {int nascosti = 0}) {
    final m = LaVoceRicevuta();
    var energia = 0.0, durata = 0.0;
    for (var i = 0; i <= voce.length; i++) {
      m.punto(Duration(milliseconds: i * 100),
          durata: durata,
          energia: energia,
          nascosti: i == voce.length ? nascosti : 0,
          nascostiMuti: 0);
      if (i < voce.length) {
        durata += 0.1;
        energia += voce[i] ? 0.1 * 1e-2 : 0.1 * 1e-6;
      }
    }
    return m;
  }

  List<bool> tratto(String s) => [for (final c in s.split('')) c == 'v'];

  test('una pausa di un secondo e mezzo a meta\' risposta e\' una rottura', () {
    final m =
        conLaVoce(tratto('...vvvvvvvvvv' '...............' 'vvvvvvvv...'));
    expect(m.rotture, hasLength(1));
    expect(m.rotture.single.$2, const Duration(milliseconds: 1500));
    expect(m.rotture.single.$1, const Duration(milliseconds: 1300));
    expect(m.riga('risposta'), contains('1 rotture: 1500 ms al secondo 1.3'));
  });

  test('la pausa fra due frasi non e\' una rottura', () {
    final m = conLaVoce(tratto('vvvvvvvv' '.....' 'vvvvvvvv'));
    expect(m.rotture, isEmpty);
  });

  test('il silenzio prima e dopo la voce non e\' una rottura', () {
    final m =
        conLaVoce(tratto('....................vvvvv....................'));
    expect(m.rotture, isEmpty);
    expect(m.secondiDiVoce, closeTo(0.5, 0.01));
  });

  test('i campioni inventati dal ricevitore si contano in millisecondi', () {
    final m = conLaVoce(tratto('vvvv'), nascosti: 4800);
    expect(m.millisecondiNascosti, 100);
  });
}
