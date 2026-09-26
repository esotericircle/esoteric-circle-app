import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **I DIRITTI DI iOS HANNO IL LORO PASSO SUL PORTALE APPLE.** Nata il 26
/// settembre 2026, dopo la build iOS dell'ordine EO fallita su Codemagic.
///
/// **IL FATTO CHE HA FATTO NASCERE QUESTA GUARDIA.** Il passo "L'archivio" di
/// Codemagic si e' fermato con:
///
/// > Provisioning profile "Esoteric Circle ios_app_store 1786051735" doesn't
/// > include the com.apple.developer.associated-domains entitlement.
///
/// Il diritto `com.apple.developer.associated-domains` era entrato in
/// `ios/Runner/Runner.entitlements` con l'ordine EA voce 19, il 20 settembre
/// 2026 (commit `6953694f`), per far aprire l'app dal link d'ingresso. **Un
/// diritto nel file non basta**: Apple firma solo se la stessa capacita' e'
/// accesa sull'identificativo dell'app, sul portale developer.apple.com, e il
/// profilo di distribuzione viene rigenerato dopo. Quel passo lo puo' fare
/// solo il fondatore, e **il rapporto dell'ordine EA non lo nominava**: fra i
/// passi in console c'erano Firebase e il dominio, non il portale Apple.
///
/// **Perche' nessuna prova l'ha preso prima.** Da Windows non si firma per
/// iOS: il primo posto dove il file e il profilo si incontrano e' il Mac di
/// Codemagic, dopo due minuti di build e un giro del fondatore. Questa guardia
/// sposta la domanda qui: chi aggiunge un diritto deve scrivere accanto quale
/// capacita' del portale gli corrisponde, e quindi deve sapere che c'e' un
/// passo da chiedere al fondatore prima di lanciare la build.
void main() {
  /// **LA TAVOLA DEI DIRITTI.** Per ogni chiave di `Runner.entitlements`, il
  /// nome della capacita' come la mostra il portale Apple in Certificates,
  /// Identifiers & Profiles, alla voce dell'identificativo
  /// `com.esotericircle.esotericCircle`, e chi l'ha fatta entrare.
  const tavola = <String, String>{
    // Ordine S voce 14: sul portale era gia' accesa quando il diritto e'
    // entrato nel file.
    'com.apple.developer.applesignin': 'Sign In with Apple',
    // Ordine EA voce 19. La capacita' sul portale l'ha chiesta al fondatore
    // la build fallita del 26 settembre 2026, sei giorni dopo.
    'com.apple.developer.associated-domains': 'Associated Domains',
  };

  test('ogni diritto di Runner.entitlements ha la sua capacita\' sul portale',
      () {
    final file = File('ios/Runner/Runner.entitlements');
    expect(file.existsSync(), isTrue,
        reason: 'ios/Runner/Runner.entitlements non c\'e\' piu\'.');
    // I commenti del file nominano altre parole: si leggono solo le chiavi.
    final senzaCommenti = file
        .readAsStringSync()
        .replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '');
    final chiavi = RegExp(r'<key>([^<]+)</key>')
        .allMatches(senzaCommenti)
        .map((m) => m.group(1)!.trim())
        .toList();

    // Oggi le chiavi sono due, Apple e i domini del link.
    cardinaleMinimo(chiavi.length, 2,
        cosa: 'chiavi in Runner.entitlements',
        perche: 'Il file dichiara Sign In with Apple e Associated Domains.');

    final senzaPasso = [
      for (final c in chiavi)
        if (!tavola.containsKey(c)) c,
    ];
    expect(senzaPasso, isEmpty,
        reason: 'Questi diritti sono in Runner.entitlements ma non nella '
            'tavola di questa guardia: $senzaPasso.\n'
            'Ogni diritto vuole la stessa capacita\' accesa sul portale Apple, '
            'sull\'identificativo com.esotericircle.esotericCircle, e poi un '
            'profilo di distribuzione nuovo. Senza, la build di Codemagic '
            'cade al passo "L\'archivio" con "Provisioning profile ... '
            'doesn\'t include the ... entitlement". Scrivi il diritto nella '
            'tavola e metti il passo del portale nel rapporto, fra i passi '
            'del fondatore, PRIMA che lanci la build.');
  });
}
