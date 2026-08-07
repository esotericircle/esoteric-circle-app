import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// CRASHLYTICS HA GLI OCCHI, E NESSUNO GLIELI TOGLIE IN SILENZIO.
///
/// La 2157 iOS moriva MUTA sull'iPhone di Mauro, crash deterministico
/// all'ingresso del trionfo dell'Animale Guida, e il telefono non esponeva
/// rapporti leggibili. Questo corredo tiene ferme le quattro cose che danno
/// gli occhi: la dipendenza inchiodata, l'aggancio nel main, i simboli dSYM
/// nel workflow, la dichiarazione di crittografia esente.
void main() {
  test('la dipendenza e\' inchiodata alla versione misurata, senza caret', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec.contains('firebase_crashlytics: 5.2.4'), isTrue,
        reason: 'firebase_crashlytics non e\' 5.2.4 fissata: quella versione '
            'e\' MISURATA, stesso giorno di firebase_core 4.11.0 e ultima a '
            'chiedere ^4.11.0. Un caret qui romperebbe la compilazione alla '
            'prossima patch, come il commento del set spiega.');
    expect(pubspec.contains('firebase_crashlytics: ^'), isFalse,
        reason: 'Il caret e\' comparso su firebase_crashlytics: il set '
            'Firebase e\' inchiodato senza caret, tutte le voci insieme.');
  });

  test('il main aggancia i tre canali, dietro la guardia di Firebase', () {
    final main = File('lib/main.dart').readAsStringSync();
    expect(main.contains('FlutterError.onError'), isTrue,
        reason: 'Gli errori del framework non arrivano piu\' a Crashlytics.');
    expect(main.contains('recordFlutterFatalError'), isTrue,
        reason: 'Gli errori del framework non si registrano come fatali.');
    expect(main.contains('PlatformDispatcher.instance.onError'), isTrue,
        reason: 'Gli errori fuori dal framework non arrivano piu\' a '
            'Crashlytics.');
    expect(main.contains('Firebase.apps.isNotEmpty'), isTrue,
        reason: 'La guardia su Firebase.apps e\' sparita: senza, un main '
            'eseguito senza Firebase toccherebbe Crashlytics e morirebbe. '
            'Il ramo di prova non deve toccare Crashlytics.');
    // E la console non si spegne: il rapporto si AGGIUNGE al comportamento
    // di sempre, non lo sostituisce.
    expect(main.contains('FlutterError.presentError'), isTrue,
        reason: 'presentError e\' sparito: gli occhi nuovi hanno spento '
            'quelli vecchi, e in sviluppo gli errori non si vedono piu\' a '
            'console.');
  });

  test('l\'Info.plist dichiara la crittografia esente, e dichiara false', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    final chiave = plist.indexOf('ITSAppUsesNonExemptEncryption');
    expect(chiave, greaterThanOrEqualTo(0),
        reason: 'La chiave ITSAppUsesNonExemptEncryption e\' sparita: App '
            'Store Connect torna a fare la domanda sulla crittografia a '
            'OGNI caricamento su TestFlight, a mano.');
    // Il valore che segue la chiave deve essere <false/>: l'app usa solo
    // l'HTTPS di sistema, esente. Un <true/> qui dichiarerebbe crittografia
    // propria che non esiste, con gli obblighi che si porta dietro.
    // Il ritaglio si ferma alla fine del file: la chiave sta in coda al
    // plist, e un ritaglio fisso oltre la fine solleva invece di misurare.
    final fine = chiave + 200 > plist.length ? plist.length : chiave + 200;
    final dopo = plist.substring(chiave, fine);
    expect(dopo.contains('<false/>'), isTrue,
        reason: 'La chiave della crittografia non dice piu\' false: o e\' '
            'diventata true, che dichiara il falso, o il valore si e\' '
            'staccato dalla chiave.');
  });

  test('il workflow carica i dSYM dopo l\'archivio, senza ripieghi muti', () {
    final yaml = File('codemagic.yaml').readAsStringSync();
    final archivio = yaml.indexOf('flutter build ipa');
    final simboli = yaml.indexOf('upload-symbols');
    expect(simboli, greaterThanOrEqualTo(0),
        reason: 'Il passo dei dSYM e\' sparito dal workflow: i rapporti iOS '
            'arrivano come indirizzi esadecimali, cioe\' un secondo modo di '
            'restare muti.');
    expect(simboli, greaterThan(archivio),
        reason: 'Il caricamento dei simboli sta PRIMA dell\'archivio: i '
            'dSYM nascono con l\'archivio, prima non c\'e\' niente da '
            'caricare.');
    // Niente ripieghi muti: se i dSYM mancano, il passo muore dicendolo.
    final passo = yaml.substring(yaml.indexOf('I simboli dSYM'));
    expect(passo.contains('exit 1'), isTrue,
        reason: 'Il passo dei dSYM non muore piu\' quando i simboli mancano: '
            'un caricamento saltato in silenzio e\' un ripiego muto.');
  });

  test('il caricatore dei simboli SI CERCA nel checkout SPM, non si dichiara',
      () {
    // LA LEZIONE DELLA 2158, morta con status 127: il passo dichiarava
    // ios/Pods/FirebaseCrashlytics/upload-symbols, ma Firebase viaggia con
    // Swift Package Manager e quella cartella non esiste e non esistera'
    // mai. Era una costante che dichiarava il falso: adesso il binario si
    // TROVA, e questa prova tiene ferma la forma della ricerca.
    final yaml = File('codemagic.yaml').readAsStringSync();
    final passo = yaml.substring(yaml.indexOf('I simboli dSYM'));
    // SI GUARDA IL CODICE, NON I COMMENTI: il passo racconta nella propria
    // storia il percorso che ha ucciso la 2158, e bocciarlo perche' spiega
    // la propria regola guarderebbe la cosa sbagliata, come la prova delle
    // credenziali ha gia' imparato.
    final codice = passo
        .split('\n')
        .where((r) => !r.trimLeft().startsWith('#'))
        .join('\n');
    // Il percorso finto di CocoaPods non deve tornare, nemmeno per scorciatoia.
    expect(codice.contains('ios/Pods/FirebaseCrashlytics'), isFalse,
        reason: 'Il percorso di CocoaPods e\' tornato nel passo dei dSYM: '
            'Firebase passa da Swift Package Manager e quella cartella non '
            'esiste, e\' la costante falsa che ha ucciso la 2158.');
    // La ricerca: un find sul checkout SPM di firebase-ios-sdk.
    expect(
        passo.contains('find') && passo.contains('firebase-ios-sdk'),
        isTrue,
        reason: 'Il passo non CERCA piu\' upload-symbols nel checkout SPM di '
            'firebase-ios-sdk: senza ricerca si torna a un percorso '
            'dichiarato, cioe\' a una costante che prima o poi mente.');
    // Il fallimento parlante nei DUE versi: zero trovati, e piu' d'uno.
    expect(passo.contains('NON TROVATO'), isTrue,
        reason: 'Il ramo dello zero non parla piu\': se il binario manca, il '
            'passo deve dire dove ha cercato e cosa c\'era.');
    // LA GRANDEZZA E' CAMBIATA, e va detto: la prima stesura cercava la
    // frase "a caso", che vive anche nel COMMENTO del passo, quindi il rosso
    // non scattava togliendo il ramo vero. Si misura il CODICE: il ramo
    // dell'ambiguita' esiste solo se il confronto -gt 1 esiste.
    expect(codice.contains('-gt 1'), isTrue,
        reason: 'Il ramo del piu\' d\'uno e\' sparito dal codice: con due '
            'caricatori trovati il passo ne sceglierebbe uno a caso, cioe\' '
            'un\'altra dichiarazione non misurata.');
    // E i due rami muoiono davvero: due exit 1 oltre a quello dei dSYM.
    final quantiExit = 'exit 1'.allMatches(passo).length;
    expect(quantiExit, greaterThanOrEqualTo(3),
        reason: 'Il passo ha $quantiExit uscite di errore invece di almeno '
            'tre: dSYM assenti, caricatore assente, caricatore ambiguo '
            'devono morire tutti e tre dicendolo.');
  });
}
