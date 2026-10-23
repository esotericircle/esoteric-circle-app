import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// **IL MANIFESTO DELLA PRIVACY C'E', STA NEL PACCHETTO E DICE IL VERO.**
/// Ordine DQ voce 12, 15 settembre 2026.
///
/// **IL FATTO.** Nel progetto non c'era nessun `PrivacyInfo.xcprivacy`. Dal
/// 2024 Apple lo pretende e, senza, la pubblicazione viene rifiutata con
/// ITMS-91053. Sulle build interne non si vede, e infatti non se n'era accorto
/// nessuno.
///
/// **COSA DICHIARA L'APP E COSA NO.** Il motore di Flutter e i pacchetti che
/// ne portano uno proprio (Firebase 12.15.0 via Swift Package Manager, ML Kit
/// 9.0, e fra i plugin camera_avfoundation, firebase_messaging, gal,
/// geocoding_ios, geolocator_apple, google_sign_in_ios, image_picker_ios,
/// record_darwin, sensors_plus, share_plus, shared_preferences_foundation,
/// video_player_avfoundation e flutter_local_notifications) si dichiarano da
/// soli, e non si riscrivono qui. Il manifesto dell'app dichiara cio' che
/// l'app stessa raccoglie sui suoi server, preso dalla privacy policy di
/// `lib/core/legal/privacy_policy.dart`, che una guardia sua ancora al codice.
///
/// **PERCHE' SI GUARDA ANCHE IL PROGETTO XCODE.** Un file nella cartella non
/// entra nel pacchetto: ci entra solo se il bersaglio Runner lo copia fra le
/// risorse. Su Windows Xcode non c'e', e fra la modifica e l'archivio del Mac
/// in cloud c'e' soltanto questa prova.
void main() {
  final manifesto = File('ios/Runner/PrivacyInfo.xcprivacy');
  final pbx = File('ios/Runner.xcodeproj/project.pbxproj');
  const nome = 'PrivacyInfo.xcprivacy';

  /// I tipi di dato che Apple ammette, dalla sua documentazione
  /// `NSPrivacyCollectedDataType`, letta il 15 settembre 2026. Xcode non
  /// compone il rapporto se un tipo e' inventato.
  const tipiDiApple = {
    'Name', 'EmailAddress', 'PhoneNumber', 'PhysicalAddress',
    'OtherUserContactInfo', 'Health', 'Fitness', 'PaymentInfo', 'CreditInfo',
    'OtherFinancialInfo', 'PreciseLocation', 'CoarseLocation',
    'SensitiveInfo', 'Contacts', 'EmailsOrTextMessages', 'PhotosorVideos',
    'AudioData', 'GameplayContent', 'CustomerSupport', 'OtherUserContent',
    'BrowsingHistory', 'SearchHistory', 'UserID', 'DeviceID',
    'PurchaseHistory', 'ProductInteraction', 'AdvertisingData',
    'OtherUsageData', 'CrashData', 'PerformanceData', 'OtherDiagnosticData',
    'EnvironmentScanning', 'Hands', 'Head', 'OtherDataTypes',
  };
  const motiviDiApple = {
    'ThirdPartyAdvertising', 'DeveloperAdvertising', 'Analytics',
    'ProductPersonalization', 'AppFunctionality', 'Other',
  };

  /// Il valore di una chiave, cercato dopo la chiave stessa.
  String? dopo(String testo, String chiave) {
    final m = RegExp('<key>$chiave</key>\\s*<([a-z]+)\\s*/?>').firstMatch(testo);
    return m?.group(1);
  }

  /// Il testo senza i commenti XML, che qui spiegano ogni voce a parole e
  /// non devono poter far passare una chiave che nel dato non c'e'.
  String nudo() => manifesto
      .readAsStringSync()
      .replaceAll(RegExp(r'<!--.*?-->', dotAll: true), '');

  String blocco(String testo, String identificativo) {
    final da = testo.indexOf(identificativo);
    expect(da, greaterThanOrEqualTo(0),
        reason: 'L\'oggetto $identificativo non esiste piu\' nel pbxproj.');
    return testo.substring(da, testo.indexOf('};', da));
  }

  test('il manifesto esiste accanto a Info.plist', () {
    expect(manifesto.existsSync(), isTrue,
        reason: 'Senza ios/Runner/PrivacyInfo.xcprivacy la pubblicazione su '
            'App Store viene rifiutata con ITMS-91053.');
  });

  test('nessun tracciamento e nessun dominio di tracciamento', () {
    // La privacy policy lo dice: non vendiamo i dati e non li condividiamo
    // con terzi per pubblicita'. Il manifesto deve dire lo stesso.
    final testo = nudo();
    expect(dopo(testo, 'NSPrivacyTracking'), 'false',
        reason: 'il manifesto dichiara un tracciamento che l\'app non fa');
    final domini = RegExp(
            r'<key>NSPrivacyTrackingDomains</key>\s*(<array\s*/>|<array>\s*</array>)')
        .hasMatch(testo);
    expect(domini, isTrue,
        reason: 'il manifesto elenca domini di tracciamento, e l\'app non ne '
            'ha nessuno');
  });

  test('ogni dato raccolto ha le quattro chiavi e parole di Apple', () {
    final testo = nudo();
    final voci = RegExp(
            r'<key>NSPrivacyCollectedDataType</key>\s*<string>NSPrivacyCollectedDataType(\w+)</string>(.*?)</dict>',
            dotAll: true)
        .allMatches(testo)
        .toList();
    // Il cardinale: l'app raccoglie almeno email, nome, identificativo,
    // conversazioni, cammino, gettone delle notifiche e dati di nascita.
    expect(voci.length, greaterThanOrEqualTo(7),
        reason: 'il manifesto dichiara ${voci.length} tipi di dato raccolto, '
            'e la privacy policy ne nomina sette');
    final colpe = <String>[];
    for (final v in voci) {
      final tipo = v.group(1)!;
      final resto = v.group(2)!;
      if (!tipiDiApple.contains(tipo)) colpe.add('$tipo non e\' un tipo di Apple');
      if (dopo(resto, 'NSPrivacyCollectedDataTypeLinked') == null) {
        colpe.add('$tipo non dice se e\' legato alla persona');
      }
      if (dopo(resto, 'NSPrivacyCollectedDataTypeTracking') != 'false') {
        colpe.add('$tipo e\' dichiarato per il tracciamento');
      }
      // Si leggono i VALORI: la chiave NSPrivacyCollectedDataTypePurposes
      // comincia con le stesse parole, e senza le stringhe intorno la prima
      // stesura leggeva "s" come un motivo.
      final motivi = RegExp(
              r'<string>NSPrivacyCollectedDataTypePurpose(\w+)</string>')
          .allMatches(resto)
          .map((m) => m.group(1)!)
          .toList();
      if (motivi.isEmpty) colpe.add('$tipo non ha un motivo');
      for (final m in motivi) {
        if (!motiviDiApple.contains(m)) colpe.add('$tipo: $m non e\' di Apple');
        if (m.contains('Advertising')) {
          colpe.add('$tipo e\' raccolto per la pubblicita\', e la privacy '
              'policy dice di no');
        }
      }
    }
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });

  test('la posizione non e\' dichiarata raccolta, perche\' resta sul telefono',
      () {
    // Le coordinate del cielo non lasciano mai il telefono per arrivare a noi:
    // dichiararle raccolte sarebbe falso quanto tacerle se partissero.
    final testo = nudo();
    expect(testo.contains('NSPrivacyCollectedDataTypePreciseLocation'), isFalse);
    expect(testo.contains('NSPrivacyCollectedDataTypeCoarseLocation'), isFalse);
  });

  test('il manifesto e\' un riferimento, sta nel gruppo e nella copia di Runner',
      () {
    final testo = pbx.readAsStringSync();
    final riga = RegExp(
            r'([0-9A-F]{24}) /\* PrivacyInfo\.xcprivacy in Resources \*/ = \{isa = PBXBuildFile; fileRef = ([0-9A-F]{24})')
        .firstMatch(testo);
    expect(riga, isNotNull,
        reason: 'Non esiste una voce PBXBuildFile per $nome: il manifesto non '
            'viene copiato nel pacchetto');
    final idCopia = riga!.group(1)!;
    final idFile = riga.group(2)!;
    expect(testo.contains('$idFile /* $nome */ = {isa = PBXFileReference'),
        isTrue,
        reason: 'la copia punta a $idFile, che non e\' il riferimento di $nome');
    expect(
        blocco(testo, '97C146F01CF9000F007C117D /* Runner */ = {')
            .contains('$idFile /* $nome */'),
        isTrue,
        reason: '$nome non sta nel gruppo Runner');
    expect(
        blocco(testo, '97C146EC1CF9000F007C117D /* Resources */ = {')
            .contains('$idCopia /* $nome in Resources */'),
        isTrue,
        reason: '$nome non e\' nella fase di copia delle risorse di Runner: '
            'resta nella cartella e non entra nel pacchetto');
    expect(
        blocco(testo, '331C807F294A63A400263BE5 /* Resources */ = {')
            .contains(nome),
        isFalse,
        reason: '$nome sta nella copia di RunnerTests, dove non serve');
  });
}
