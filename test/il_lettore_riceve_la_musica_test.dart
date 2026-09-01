import 'dart:io';

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/onboarding/onboarding_controller.dart';
import 'package:esoteric_circle/core/sensi/regia_della_musica.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **COSA ARRIVA DAVVERO AL LETTORE.** Ordine CN, 2 settembre 2026.
///
/// **Il buco che questa prova chiude, e quanto e' costato.** Fra la decisione
/// della regia e il suono che esce non c'era piu' niente di sorvegliato: sotto
/// `flutter test` la regia salta il lettore, quindi ogni prova si fermava un
/// passo prima del punto dove il difetto viveva. **La build 2218 e' uscita
/// muta con quattromiladuecento prove verdi.**
///
/// **Il difetto, per chi legge fra un anno.** `play` di `audioplayers` non e'
/// una chiamata che finisce: dentro attende un evento `prepared` che deve
/// arrivare dalla piattaforma. Attendendola, il motore non tornava ne' vero ne'
/// falso, la regia restava sospesa a meta', e **il `catch` non scattava perche'
/// non c'era nessun errore: c'era un'attesa infinita**. Silenzio, senza una
/// riga di log.
///
/// **Cosa questa prova puo' vedere.** Che l'app CHIEDA al lettore di suonare, e
/// che la catena arrivi in fondo. Che dal telefono esca un suono lo dice solo
/// il telefono, e nessuna prova puo' sostituirlo.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<MethodCall> chiamate;

  setUp(() {
    chiamate = <MethodCall>[];
    RegiaDellaMusica.lettoreForzato = false;
    RegiaDellaMusica.sola.dimentica();

    final messaggeria =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final canale in const [
      MethodChannel('xyz.luan/audioplayers'),
      MethodChannel('xyz.luan/audioplayers.global'),
    ]) {
      messaggeria.setMockMethodCallHandler(canale, (call) async {
        chiamate.add(call);
        return null;
      });
    }
    // **ANCHE I CANALI DEGLI EVENTI, o il lettore muore prima di
    // partire.** `audioplayers` si mette in ascolto di due flussi
    // appena nasce, e l'errore di un flusso non passa da nessun
    // `catch`: arriva come eccezione di piattaforma e fa cadere la
    // prova. E' la stessa cosa che il 1 settembre ha fatto cadere sette
    // prove che col suono non c'entravano.
    for (final n in const [
      'xyz.luan/audioplayers.global/events',
      'xyz.luan/audioplayers/events/cerchio_musica',
      'xyz.luan/audioplayers/events/cerchio_effetti',
      'xyz.luan/audioplayers/events/cerchio_toni',
    ]) {
      messaggeria.setMockStreamHandler(
          EventChannel(n), MockStreamHandler.inline(onListen: (a, e) {}));
    }

    // La cartella temporanea: `audioplayers` non passa l'asset al lettore, lo
    // COPIA prima in un file, e per sapere dove lo chiede a un plugin.
    messaggeria.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (c) async => Directory.systemTemp.path);

    // I sensori tacciono, come in ogni prova che monta l'app vera.
    messaggeria.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (c) async => null);
    for (final n in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messaggeria.setMockStreamHandler(
          EventChannel(n), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  });

  tearDown(() => RegiaDellaMusica.lettoreForzato = null);

  testWidgets('la catena arriva fino al lettore e non si blocca',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues(const {});
    await tester.runAsync(() async {
      await OnboardingController().complete();
    });

    await tester.pumpWidget(
      EsotericCircleApp(conIntro: false, services: AppServices.offline()),
    );
    // Il lettore vero lavora con dei Future veri: senza `runAsync` la catena
    // fra la regia e il canale non arriva mai in fondo, e questa prova
    // guarderebbe un elenco vuoto credendo di aver misurato qualcosa.
    for (var giro = 0; giro < 3; giro++) {
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump(const Duration(milliseconds: 300));
    }

    final nomi = chiamate.map((c) => c.method).toList();
    expect(nomi, isNotEmpty,
        reason: 'IL LETTORE NON HA RICEVUTO NIENTE. Fra la decisione della '
            'regia e il plugin non e\' passata nessuna chiamata: o il motore '
            'non e\' stato chiamato, o si e\' fermato prima, e in tutti e due '
            'i casi l\'app e\' muta.');
    expect(nomi, contains('create'),
        reason: 'nessun lettore e\' stato costruito per la musica');

    // **LA RAMPA DEL VOLUME E' LA PROVA CHE LA CATENA VA IN FONDO.**
    //
    // Dopo aver chiesto al lettore di suonare, la regia sfuma il volume a
    // passi: una ventina di `setVolume` in mezzo secondo. Quella rampa arriva
    // SOLO se la richiesta di suonare e' tornata.
    //
    // Nella build 2218 non tornava mai, e le chiamate si fermavano a DUE
    // `setVolume`, uno per tentativo. **Questo numero e' la differenza fra
    // un'app che suona e una muta.**
    final volumi = nomi.where((n) => n == 'setVolume').length;
    expect(volumi, greaterThan(4),
        reason: 'al lettore sono arrivati solo $volumi comandi di volume, '
            'quindi la sfumatura non e\' mai partita e la regia e\' rimasta '
            'appesa dentro `play`.\n'
            'Chiamate arrivate: $nomi\n'
            'E\' il difetto della build 2218: `play` di audioplayers attende '
            'un evento della piattaforma, e attenderla blocca tutto senza '
            'sollevare nessun errore.');
  });
}
