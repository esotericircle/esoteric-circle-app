import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// **LE CHIAVI DI iOS CI SONO TUTTE.** Ordine CU voce 03, 7 settembre 2026.
///
/// **IL FATTO CHE HA FATTO NASCERE QUESTA GUARDIA.** Il caricamento della build
/// 2229 su App Store Connect e' stato **rifiutato**:
///
/// > 90683: Missing purpose string in Info.plist. [...] The Info.plist file for
/// > the 'Runner.app' bundle should contain a NSSpeechRecognitionUsageDescription
/// > key with a user-facing purpose string.
///
/// **Codemagic aveva costruito e firmato senza un errore**: il controllo di
/// Apple avviene al CARICAMENTO, non alla compilazione. Senza questa guardia il
/// prossimo caricamento rifiutato costa un altro giro di Codemagic, e nessuno
/// se ne accorge prima.
///
/// **COME FUNZIONA, e perche' non guarda la cache dei pacchetti.** Una prova
/// che frugasse in `.pub-cache` dipenderebbe da dove quella cartella sta su
/// ogni macchina, e sui costruttori in cloud non c'e' affatto. Qui invece
/// vivono due cose nel repository:
///
/// - **la tavola**, che per ogni dipendenza diretta dice se raggiunge un'API
///   sensibile di Apple e quale chiave chiede;
/// - **il confronto**, che pretende due cose insieme: che ogni chiave della
///   tavola stia in `Info.plist`, e che **ogni dipendenza diretta del pubspec
///   sia stata classificata**.
///
/// La seconda meta' e' quella che difende davvero: chi aggiunge una libreria
/// nuova senza dire se tocca il microfono, la fotocamera o la voce **fa cadere
/// questa prova**, e lo scopre qui invece che da Apple.
///
/// **IL CENSIMENTO DA CUI NASCE LA TAVOLA.** Fatto il 7 settembre 2026
/// leggendo le cartelle native di tutti i pacchetti del lockfile, non a
/// memoria. Il primo passaggio guardava solo `ios/` e non trovava niente:
/// diversi pacchetti moderni mettono il codice Apple in `darwin/`, condiviso
/// fra iOS e macOS, e **`speech_to_text` e' uno di quelli**, cioe' proprio il
/// pacchetto che Apple ha nominato nel rifiuto.
void main() {
  /// **LA TAVOLA DELLE DIPENDENZE DIRETTE.**
  ///
  /// Chiave nulla vuol dire: verificata, non tocca nessuna API sensibile di
  /// Apple. Non vuol dire "non guardata".
  const tavola = <String, String?>{
    // --- il cuore di Flutter e le cose senza permessi ---
    'flutter': null,
    'cupertino_icons': null,
    'provider': null,
    'shared_preferences': null,
    'path_provider': null,
    'timezone': null,
    'video_player': null,
    'audioplayers': null,
    'geocoding': null,
    'share_plus': null,
    // --- Firebase ---
    'firebase_core': null,
    'firebase_ai': null,
    'firebase_app_check': null,
    'firebase_crashlytics': null,
    'firebase_auth': null,
    'cloud_firestore': null,
    'cloud_functions': null,
    'google_sign_in': null,
    // Le notifiche NON vogliono una purpose string: il permesso si chiede a
    // runtime con UNUserNotificationCenter, e Apple non pretende una riga in
    // Info.plist. Verificato nel censimento.
    'firebase_messaging': null,
    'flutter_local_notifications': null,
    // --- le API sensibili, una per una ---
    'sensors_plus': 'NSMotionUsageDescription',
    'geolocator': 'NSLocationWhenInUseUsageDescription',
    'record': 'NSMicrophoneUsageDescription',
    // record_linux NON sta fra le dipendenze: e' un blocco in
    // dependency_overrides, messo per un guasto di risoluzione a monte, e
    // su iOS non esiste affatto.
    'speech_to_text': 'NSSpeechRecognitionUsageDescription',
    'image_picker': 'NSPhotoLibraryUsageDescription',
    'camera': 'NSCameraUsageDescription',
    'google_mlkit_face_detection': 'NSCameraUsageDescription',
    'mediapipe_face_mesh': 'NSCameraUsageDescription',
  };

  late final String plist =
      File('ios/Runner/Info.plist').readAsStringSync();
  late final Set<String> presenti = RegExp(r'NS[A-Za-z]+UsageDescription')
      .allMatches(plist)
      .map((m) => m.group(0)!)
      .toSet();

  /// Le dipendenze dirette, lette dal pubspec e non copiate a mano.
  late final List<String> dirette = () {
    final righe = File('pubspec.yaml').readAsLinesSync();
    final fuori = <String>[];
    var dentro = false;
    for (final r in righe) {
      if (r.startsWith('dependencies:')) {
        dentro = true;
        continue;
      }
      if (dentro && r.isNotEmpty && !r.startsWith(' ')) break;
      if (!dentro) continue;
      final m = RegExp(r'^  ([a-z0-9_]+):').firstMatch(r);
      if (m != null) fuori.add(m.group(1)!);
    }
    return fuori;
  }();

  test('ogni dipendenza diretta e\' stata classificata', () {
    // **LA META\' CHE DIFENDE DAVVERO.** Chi aggiunge una libreria e non dice
    // se tocca un'API sensibile fa cadere qui, non su App Store Connect.
    final ignote = dirette.where((d) => !tavola.containsKey(d)).toList();
    expect(ignote, isEmpty,
        reason: 'queste dipendenze non sono nella tavola delle API sensibili: '
            '$ignote. Prima di consegnare, guarda le loro cartelle ios/ e '
            'darwin/ e dichiara se raggiungono un framework di Apple che '
            'vuole una purpose string');
  });

  test('la tavola non elenca dipendenze che non esistono piu\'', () {
    // Una tavola che parla di librerie tolte invecchia in silenzio.
    final sparite =
        tavola.keys.where((k) => !dirette.contains(k)).toList();
    expect(sparite, isEmpty,
        reason: 'la tavola classifica dipendenze che il pubspec non ha piu\': '
            '$sparite');
  });

  test('ogni chiave richiesta sta in Info.plist', () {
    final mancanti = <String>[];
    tavola.forEach((pacchetto, chiave) {
      if (chiave == null) return;
      if (!presenti.contains(chiave)) mancanti.add('$chiave (per $pacchetto)');
    });
    expect(mancanti, isEmpty,
        reason: 'Info.plist non porta queste chiavi, e il caricamento su App '
            'Store Connect sara\' rifiutato con l\'errore 90683: $mancanti');
  });

  test('nessuna chiave ha una stringa vuota o generica', () {
    // **APPLE RIFIUTA LE STRINGHE GENERICHE**, del tipo "serve per il
    // funzionamento dell'app": la frase deve dire la cosa vera.
    final generiche = <String>[];
    for (final chiave in presenti) {
      final m = RegExp('<key>$chiave</key>\\s*<string>([^<]*)</string>')
          .firstMatch(plist);
      // **LE ENTITA' XML SI SCIOLGONO PRIMA DI CONFRONTARE.** Nel plist
      // l'apostrofo si scrive `&apos;`, quindi cercare «funzionamento
      // dell'app» non trovava niente: misurato con la Regola A, l'innesto
      // della stringa generica restava verde.
      final testo = (m?.group(1) ?? '')
          .replaceAll('&apos;', "'")
          .replaceAll('&quot;', '"')
          .replaceAll('&amp;', '&')
          .trim();
      if (testo.length < 40) {
        generiche.add('$chiave: «$testo»');
        continue;
      }
      for (final vuota in const [
        'funzionamento dell\'app',
        'per il corretto funzionamento',
        'richiesto dal sistema',
      ]) {
        if (testo.toLowerCase().contains(vuota)) generiche.add(chiave);
      }
    }
    expect(generiche, isEmpty,
        reason: 'queste stringhe non dicono a cosa serve davvero il permesso, '
            'e Apple le rifiuta: $generiche');
  });

  test('le chiavi presenti sono tutte giustificate da qualcosa', () {
    // **DICHIARARE UN PERMESSO CHE NON SI USA E\' UN RISCHIO IN REVISIONE**,
    // non un di piu' innocuo: Apple chiede conto delle chiavi che l'app non
    // esercita mai.
    final richieste = tavola.values.whereType<String>().toSet();
    final orfane = presenti.difference(richieste);
    expect(orfane, isEmpty,
        reason: 'Info.plist dichiara permessi che nessuna dipendenza chiede: '
            '$orfane. O si toglie la chiave, o si dichiara nella tavola quale '
            'libreria la richiede');
  });
}
