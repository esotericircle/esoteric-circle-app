import 'package:esoteric_circle/core/diagnosi/prova_crashlytics.dart';
import 'package:flutter_test/flutter_test.dart';

/// **NESSUNA BUILD DI CONSEGNA PARTE CON LA PROVA DI CRASHLYTICS ACCESA.**
/// Ordine GB voce 08, 22 ottobre 2026, stessa guardia di
/// `la_consegna_parte_a_diagnosi_spenta_test.dart`: `kProvaCrashlyticsAttiva`
/// resta nel codice dietro un flag spento, e si accende a mano solo per la
/// build con cui il fondatore vuole provare il canale su TestFlight. Una
/// consegna ordinaria passa dal verde, e questo verde cade se il flag e'
/// rimasto acceso: cosi' Crashlytics non riceve un errore di prova per
/// distrazione, su una build che nessuno aveva chiesto di provare.
void main() {
  test('kProvaCrashlyticsAttiva e\' spento nel codice consegnato', () {
    expect(kProvaCrashlyticsAttiva, isFalse,
        reason: 'La prova di Crashlytics e\' ACCESA nel codice: una build '
            'fatta da qui manderebbe un errore di prova a ogni avvio su '
            'iPhone. Se serve la prova, si accende a mano per quella sola '
            'build; per la consegna ordinaria questo flag torna falso.');
  });
}
