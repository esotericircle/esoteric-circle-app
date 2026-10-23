import 'package:esoteric_circle/core/diagnosi/briciole.dart';
import 'package:flutter_test/flutter_test.dart';

/// NESSUNA BUILD DI CONSEGNA PARTE CON LA DIAGNOSI ACCESA.
///
/// Ordine 2161: la 2160 era una build diagnostica DICHIARATA, con le
/// briciole su disco e il racconto della corsa. Quella impalcatura resta nel
/// codice dietro kDiagnosiAttiva, che si accende A MANO solo per una build
/// diagnostica col suo numero. Una consegna ordinaria passa dal verde, e
/// questo verde cade se il flag e' rimasto acceso: cosi' la distrazione non
/// puo' arrivare al telefono di Mauro.
void main() {
  test('kDiagnosiAttiva e\' spento nel codice consegnato', () {
    expect(kDiagnosiAttiva, isFalse,
        reason: 'La diagnosi e\' ACCESA nel codice: una build fatta da qui '
            'sarebbe una build diagnostica travestita da consegna. Se serve '
            'una diagnostica, si accende a mano e si consegna col suo '
            'numero; per la consegna ordinaria questo flag torna falso.');
  });
}
