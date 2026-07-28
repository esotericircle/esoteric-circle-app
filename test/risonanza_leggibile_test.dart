import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/onboarding/resonance_screen.dart';
import 'package:flutter_test/flutter_test.dart';

/// "Chi risuona con te" deve essere leggibile e non contraddittorio.
///
/// A schermo: MEDORA andava a capo con la A da sola sulla seconda riga, le tre
/// percentuali ballavano su tre linee di base diverse perche' il nome del
/// vincitore e' piu' grande degli altri, e con l'arrotondamento a intero due
/// Maestri mostravano 35 e 35 mentre uno dei due vinceva. Due numeri uguali e
/// un vincitore sono una contraddizione: chi legge pensa a un errore.
void main() {
  test('Due punteggi vicini non diventano mai due numeri uguali', () {
    // Valori veri diversi, che arrotondati a intero collidono entrambi su 35.
    final etichette = PercentualiRisonanza.formatta(const {
      Maestro.medora: 0.3538,
      Maestro.caligo: 0.3492,
      Maestro.aura: 0.2970,
    });
    expect(etichette[Maestro.medora], isNot(etichette[Maestro.caligo]),
        reason: 'due Maestri diversi mostrano la stessa percentuale: '
            '${etichette[Maestro.medora]} e ${etichette[Maestro.caligo]}');
  });

  test('Quando non collidono restano numeri interi, senza decimali inutili',
      () {
    final etichette = PercentualiRisonanza.formatta(const {
      Maestro.medora: 0.52,
      Maestro.caligo: 0.31,
      Maestro.aura: 0.17,
    });
    expect(etichette[Maestro.medora], '52%');
    expect(etichette[Maestro.caligo], '31%');
    expect(etichette[Maestro.aura], '17%');
  });

  test('Un pareggio vero resta uguale e si dichiara altrove', () {
    // Se i valori sono davvero identici il decimale non li separa: qui la
    // schermata non deve inventare una differenza che non c'e'.
    final etichette = PercentualiRisonanza.formatta(const {
      Maestro.medora: 0.35,
      Maestro.caligo: 0.35,
      Maestro.aura: 0.30,
    });
    expect(etichette[Maestro.medora], etichette[Maestro.caligo]);
    expect(PercentualiRisonanza.pareggioVero(const {
      Maestro.medora: 0.35,
      Maestro.caligo: 0.35,
      Maestro.aura: 0.30,
    }), isTrue);
    expect(PercentualiRisonanza.pareggioVero(const {
      Maestro.medora: 0.3538,
      Maestro.caligo: 0.3492,
      Maestro.aura: 0.2970,
    }), isFalse);
  });

  test('La somma resta cento, o quasi: non si mostrano numeri incoerenti', () {
    final etichette = PercentualiRisonanza.formatta(const {
      Maestro.medora: 0.3538,
      Maestro.caligo: 0.3492,
      Maestro.aura: 0.2970,
    });
    var somma = 0.0;
    for (final e in etichette.values) {
      somma += double.parse(e.replaceAll('%', '').replaceAll(',', '.'));
    }
    expect(somma, closeTo(100, 0.6), reason: 'le percentuali sommano $somma');
  });
}
