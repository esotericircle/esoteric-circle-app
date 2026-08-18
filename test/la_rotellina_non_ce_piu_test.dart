import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA ROTELLINA LASCIA IL PASSPORT. Ordine AK voce 03, voce di Mauro.
///
/// La rotellina delle Impostazioni non c'e' piu'. **La via alle Impostazioni
/// e' cambiata di casa con l'ordine AL voce 08, decisione di Mauro**: la
/// testata del Passaporto ha perso porta e pillola, e il volto vive nella
/// capsula dell'identita' sopra il Navigator, presente anche sul Passaporto.
/// La via resta INTERA: capsula, AccountScreen, voce Impostazioni,
/// SettingsScreen, e la presenza della capsula sul Passaporto la sorveglia
/// la_capsula_su_ogni_schermata.
void main() {
  test("la chiave passport_settings non esiste piu' nella testata", () {
    final sorgente =
        File('lib/features/passport/cosmic_passport_screen.dart')
            .readAsStringSync();
    expect(sorgente.contains('passport_settings'), isFalse,
        reason: 'la rotellina delle Impostazioni e\' tornata nella testata '
            'del Passaporto: Mauro l\'ha eliminata il 17 agosto');
    // **LA CASA E' CAMBIATA ANCORA, ordine AM voce 04**: la capsula se n'e'
    // andata per decisione di Mauro e la porta dell'account vive nella barra
    // sottile in alto, che sta su ogni schermata, Passaporto compreso. La
    // via resta INTERA: barra, "Il tuo account", voce Impostazioni.
    final barra = File('lib/features/shell/barra_dell_identita.dart')
        .readAsStringSync();
    expect(barra.contains('PortaDellAccount'), isTrue,
        reason: 'senza la porta dell\'account nella barra il Passaporto '
            'resterebbe senza via alle Impostazioni');
  });

  test('la via alle Impostazioni resta intera', () {
    final porta =
        File('lib/design_system/components/porta_dell_account.dart')
            .readAsStringSync();
    expect(porta.contains('AccountScreen.route()'), isTrue,
        reason: 'la porta dell\'account non apre piu\' AccountScreen');
    final account = File('lib/features/account/account_screen.dart')
        .readAsStringSync();
    expect(account.contains("title: 'Impostazioni'"), isTrue,
        reason: 'AccountScreen non elenca piu\' la voce Impostazioni');
    expect(account.contains('SettingsScreen.route()'), isTrue,
        reason: 'la voce Impostazioni non apre piu\' SettingsScreen');
  });
}
