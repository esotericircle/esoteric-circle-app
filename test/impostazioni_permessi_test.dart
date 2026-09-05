import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Le Impostazioni portano ai permessi di sistema.
///
/// Un permesso negato una volta non si puo' richiedere di nuovo dall'app: il
/// sistema smette di mostrare la richiesta. Senza una via dichiarata, chi aveva
/// detto no al microfono restava senza soffio per sempre, senza sapere dove
/// rimediare.
void main() {
  // **I PERMESSI VIVONO NEL SOTTO MENU'. Ordine CE voce 03.**
  final s =
      File('lib/features/settings/permessi_di_sistema.dart').readAsStringSync();

  test('Esiste la voce dei permessi', () {
    expect(s.contains("Key('settings_permessi')"), isTrue,
        reason: 'nelle Impostazioni non c\'e\' nessuna via ai permessi');
  });

  test('La voce apre le impostazioni di sistema dell\'app', () {
    expect(s.contains('Geolocator.openAppSettings()'), isTrue,
        reason: 'la voce non porta da nessuna parte');
  });

  test('Dichiara che tutto funziona anche col solo tocco', () {
    // La regola dei sensori: sempre un ripiego a gesto tattile, e va detto
    // proprio qui, dove si parla di permessi negati.
    expect(s.contains('col solo tocco'), isTrue,
        reason: 'la voce non dice che negare un permesso non chiude nulla');
  });
}
