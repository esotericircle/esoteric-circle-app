import 'dart:io';

import 'package:esoteric_circle/core/permissions/app_permission.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LE PUSH ARRIVANO SU IPHONE.** Ordine FF voce 09, 7 ottobre 2026.
///
/// Il rapporto dell'ordine FE aveva trovato che la build iOS non dichiarava
/// `aps-environment`: senza, iOS non da' all'app il recapito APNs e nessuna
/// push arriva. L'ordine chiedeva di misurare anche il resto della catena:
/// a) il permesso chiesto alla persona, al momento giusto e non all'avvio;
/// b) il recapito registrato presso Firebase Messaging; c) il server che
/// spinge a quel recapito. Questa guardia tiene i tre pezzi e la riga del
/// diritto, perche' a toglierne uno la catena si rompe senza che nessuna
/// prova sul telefono lo veda: da Windows iOS non si prova.
String _leggi(String percorso) => File(percorso).readAsStringSync();

String _senzaCommentiXml(String s) =>
    s.replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '');

void main() {
  test('a) Runner.entitlements dichiara le push di produzione', () {
    final f = _senzaCommentiXml(_leggi('ios/Runner/Runner.entitlements'));
    expect(
        RegExp(r'<key>aps-environment</key>\s*<string>production</string>')
            .hasMatch(f),
        isTrue,
        reason: 'senza aps-environment iOS non da\' il recapito APNs e '
            'nessuna push arriva; production perche\' Codemagic firma con '
            'un profilo App Store e la build va a TestFlight');
  });

  test('a) Info.plist accetta la spinta silenziosa dei Doni', () {
    final f = _senzaCommentiXml(_leggi('ios/Runner/Info.plist'));
    expect(
        RegExp(r'<key>UIBackgroundModes</key>\s*<array>[^<]*'
                r'(<string>[^<]*</string>\s*)*?<string>remote-notification'
                r'</string>')
            .hasMatch(f),
        isTrue,
        reason: 'la spinta dei Doni e\' silenziosa (content-available): '
            'senza il modo remote-notification iOS la scarta');
  });

  test('b) il permesso si chiede su iOS, e non all\'avvio', () {
    final avvisi = _leggi('lib/services/avvisi_locali.dart');
    expect(avvisi, contains('IOSFlutterLocalNotificationsPlugin'));
    expect(avvisi, contains('darwin.requestPermissions(alert: true'));
    final main = _leggi('lib/main.dart');
    for (final vietata in ['requestPermission', 'chiediPermesso']) {
      expect(main, isNot(contains(vietata)),
          reason: 'il permesso delle notifiche chiesto all\'avvio');
    }
  });

  test('b) il recapito si rilegge appena la persona dice si\'', () {
    final avvisi = _leggi('lib/services/avvisi_locali.dart');
    expect(avvisi, contains('if (concesso) IlPermessoConcesso.annuncia();'));
    final custode = _leggi('lib/features/push/custode_montato.dart');
    expect(custode, contains('IlPermessoConcesso.flusso.listen'));
    expect(custode, contains('messaggi.getAPNSToken()'));
    expect(custode, contains('return await messaggi.getToken();'));
    expect(_leggi('lib/app.dart'), contains('RecapitoVero()'));
  });

  test('FF.09.4 su iPhone il foglio del permesso dice la frase del fondatore',
      () {
    // iOS non lascia testo all'app nella finestra di sistema: la frase sta
    // nel foglio che la precede. Su Android resta l'elenco dei Doni.
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final ios = permissionCopy(AppPermission.notifications).body;
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final android = permissionCopy(AppPermission.notifications).body;
    debugDefaultTargetPlatformOverride = null;
    expect(ios, 'I Doni del Giorno arrivano all’ora giusta e nulla di più.');
    expect(android, startsWith('Un avviso per ciascun Dono del giorno'));
  });

  test('c) il server spinge al recapito, anche su iPhone', () {
    final push = _leggi('functions/src/push.ts');
    expect(push, contains('await getMessaging().send({'));
    expect(push, contains('token: String(dati.token),'));
    expect(push, contains('payload: {aps: {contentAvailable: true}},'));
  });
}
