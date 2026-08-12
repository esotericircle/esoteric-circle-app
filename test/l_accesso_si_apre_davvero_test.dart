import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// L'ACCESSO SI APRE DAVVERO. Ordine S voce 14.
///
/// **Le tre cause sono state accertate leggendo i file, non ipotizzate.** In
/// console Firebase i fornitori sono tutti abilitati e sul portale Apple
/// l'identificativo ha gia' la capacita' Sign In with Apple: non mancava niente
/// lato configurazione, mancava dentro il progetto.
///
/// **QUESTE PROVE GIRANO SENZA UN MAC**, perche' sono prove sui file. Non dicono
/// che l'accesso funziona su un telefono: dicono che nel progetto c'e' cio' che
/// senza il quale non puo' funzionare. La verifica a video la fa Mauro dopo le due
/// build nuove, e il rapporto lo dice invece di dare per riuscito cio' che nessuno
/// ha acceso.
void main() {
  /// Lo schema di ritorno dichiarato dentro un Info.plist, se c'e'.
  String? schemaDiRitorno(String plist) {
    final dentro = RegExp(
            r'<key>CFBundleURLSchemes</key>\s*<array>(.*?)</array>',
            dotAll: true)
        .firstMatch(plist);
    if (dentro == null) return null;
    final valore =
        RegExp(r'<string>(.*?)</string>').firstMatch(dentro.group(1)!);
    return valore?.group(1);
  }

  test('IPHONE E GOOGLE: lo schema di ritorno c\'e\', ed e\' quello vero', () {
    // **Senza CFBundleURLTypes il giro di accesso apre Safari e non rientra mai
    // nell'app**: la persona si autentica e resta fuori. Non e' un errore che si
    // vede in un log: si vede solo provando ad accedere da un iPhone.
    final info = File('ios/Runner/Info.plist').readAsStringSync();
    final schema = schemaDiRitorno(info);
    expect(schema, isNotNull,
        reason: 'ios/Runner/Info.plist non dichiara nessun CFBundleURLSchemes: '
            'l\'accesso Google su iPhone apre Safari e non torna piu\' dentro');
    expect(schema, startsWith('com.googleusercontent.apps.'),
        reason: 'lo schema di ritorno dichiarato non e\' un client Google: '
            '«$schema»');

    // **IL VALORE NON SI SCRIVE A MANO IN DUE POSTI.** Il GoogleService-Info.plist
    // e' escluso dal repository, quindi qui puo' non esserci: se c'e', i due
    // valori DEVONO combaciare, perche' sono due porte sullo stesso dato.
    final google = File('ios/Runner/GoogleService-Info.plist');
    if (!google.existsSync()) {
      // ignore: avoid_print
      print('ACCESSO: GoogleService-Info.plist assente (escluso dal '
          'repository). Schema dichiarato in Info.plist: $schema');
      return;
    }
    final atteso = RegExp(
            r'<key>REVERSED_CLIENT_ID</key>\s*<string>(.*?)</string>',
            dotAll: true)
        .firstMatch(google.readAsStringSync())
        ?.group(1);
    // ignore: avoid_print
    print('ACCESSO: REVERSED_CLIENT_ID = $atteso, schema in Info.plist = '
        '$schema');
    expect(schema, atteso,
        reason: 'lo schema di ritorno e il REVERSED_CLIENT_ID divergono:\n'
            '  Info.plist:               $schema\n'
            '  GoogleService-Info.plist: $atteso\n'
            'sono due porte sullo stesso dato, e chi accede da iPhone finisce '
            'fuori dall\'app');
  });

  test('IPHONE E APPLE: le entitlements esistono e sono agganciate a TUTTE le '
      'configurazioni', () {
    // **Senza questo file la capacita' non e' dichiarata dentro l'app**, e il
    // fornitore rifiuta anche col portale a posto.
    final file = File('ios/Runner/Runner.entitlements');
    expect(file.existsSync(), isTrue,
        reason: 'ios/Runner/Runner.entitlements non esiste: Sign in with Apple '
            'non e\' dichiarato nell\'app');
    final testo = file.readAsStringSync();
    expect(testo, contains('com.apple.developer.applesignin'),
        reason: 'le entitlements non dichiarano Sign in with Apple');
    expect(testo, contains('<string>Default</string>'),
        reason: 'la capacita\' Sign in with Apple non ha il valore Default');

    // **TUTTE le configurazioni, non solo Release.** Una sola configurazione
    // agganciata e' il modo in cui questa cosa funziona in TestFlight e non in
    // debug, o viceversa: due comportamenti diversi dello stesso accesso, e la
    // differenza non la vede nessuno finche' non capita.
    final progetto =
        File('ios/Runner.xcodeproj/project.pbxproj').readAsStringSync();
    // Le configurazioni del bersaglio Runner si riconoscono dal suo Info.plist:
    // gli altri bersagli (le prove) hanno il loro.
    final configurazioniDelRunner =
        RegExp(r'INFOPLIST_FILE = Runner/Info\.plist;').allMatches(progetto).length;
    final agganci = RegExp(
            r'CODE_SIGN_ENTITLEMENTS = Runner/Runner\.entitlements;')
        .allMatches(progetto)
        .length;
    // ignore: avoid_print
    print('ACCESSO: configurazioni del Runner = $configurazioniDelRunner, '
        'agganci delle entitlements = $agganci');
    expect(configurazioniDelRunner, greaterThan(0),
        reason: 'nel progetto Xcode non si riconosce nessuna configurazione del '
            'bersaglio Runner: questa prova non sa piu\' cosa contare');
    expect(agganci, configurazioniDelRunner,
        reason: 'le entitlements sono agganciate a $agganci configurazioni su '
            '$configurazioniDelRunner: quelle scoperte accedono con Apple in un '
            'modo diverso dalle altre');
  });

  test('ANDROID E GOOGLE: si riferisce cosa c\'e\' nel file di Mauro', () {
    // **QUESTA CAUSA L'HA GIA' CHIUSA MAURO, e non si riapre.** Il file e'
    // escluso dal repository e Code non deve toccarlo: questa prova RIFERISCE, e
    // cade solo se il file c'e' ed e' tornato indietro, cioe' se non contiene
    // nessun client di tipo 1, quello Android legato all'impronta della chiave di
    // firma.
    final file = File('android/app/google-services.json');
    if (!file.existsSync()) {
      // ignore: avoid_print
      print('ACCESSO: android/app/google-services.json assente in questo '
          'albero (e\' di Mauro, escluso dal repository): niente da riferire.');
      return;
    }
    final dati = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final client = (dati['client'] as List).first as Map<String, dynamic>;
    final oauth = (client['oauth_client'] as List).cast<Map<String, dynamic>>();
    final tipoUno = oauth.where((c) => c['client_type'] == 1).toList();
    final impronte = tipoUno
        .map((c) => (c['android_info'] as Map?)?['certificate_hash'])
        .toList();
    // ignore: avoid_print
    print('ACCESSO: client_type 1 nel google-services.json = '
        '${tipoUno.length}, impronte: $impronte');
    expect(tipoUno, isNotEmpty,
        reason: 'google-services.json non contiene nessun oauth_client di tipo '
            '1: e\' stato sostituito con una versione piu\' vecchia, e l\'accesso '
            'Google su Android torna a non funzionare');
  });
}
