import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA ROTELLINA LASCIA IL PASSPORT. Ordine AK voce 03, voce di Mauro.
///
/// La testata del Passaporto tiene porta dell'account, titolo e pillola: la
/// rotellina delle Impostazioni non c'e' piu'. La via alle Impostazioni
/// resta INTERA e si legge sul sorgente delle due porte: la testata monta la
/// PortaDellAccount, che apre AccountScreen, e AccountScreen elenca la voce
/// Impostazioni che apre SettingsScreen.
void main() {
  test("la chiave passport_settings non esiste piu' nella testata", () {
    final sorgente =
        File('lib/features/passport/cosmic_passport_screen.dart')
            .readAsStringSync();
    expect(sorgente.contains('passport_settings'), isFalse,
        reason: 'la rotellina delle Impostazioni e\' tornata nella testata '
            'del Passaporto: Mauro l\'ha eliminata il 17 agosto');
    expect(sorgente.contains('PortaDellAccount'), isTrue,
        reason: 'senza la porta dell\'account il Passaporto resterebbe senza '
            'via alle Impostazioni');
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
