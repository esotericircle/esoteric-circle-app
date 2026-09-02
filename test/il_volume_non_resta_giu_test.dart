import 'dart:io';

import 'package:esoteric_circle/core/sensi/catalogo_musiche.dart';
import 'package:esoteric_circle/core/sensi/motore_audio.dart';
import 'package:esoteric_circle/core/sensi/regia_della_musica.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL VOLUME NON RESTA GIU'.** Ordine CN, coda del 2 settembre 2026.
///
/// **Il fatto che l'ha fatta nascere.** Nella 2219 la musica partiva davvero,
/// **ma a volume quasi zero**, e il fondatore la sentiva comparire solo dopo il
/// login, quando un altro passaggio riscriveva il volume per intero.
///
/// **La causa.** La voce dell'intro fa scendere la musica sotto un effetto
/// **mentre la musica sta ancora salendo da zero**. Due sfumature correvano
/// insieme scrivendosi il volume a vicenda, e chi finiva per ultimo lo lasciava
/// dove capitava. Il campo che avrebbe dovuto annullare la prima non veniva mai
/// assegnato: `cancel()` girava a vuoto.
///
/// **Cosa misura questa prova.** L'ultimo volume che arriva al lettore dopo che
/// tutto si e' calmato. Non e' un dettaglio di implementazione: **e' l'unica
/// differenza fra un tappeto che si sente e uno che non si sente.**
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<double> volumi;

  setUp(() {
    volumi = <double>[];
    MotoreAudio.lettoriForzati = false;
    RegiaDellaMusica.lettoreForzato = false;
    RegiaDellaMusica.sola.dimentica();

    final messaggeria =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final canale in const [
      MethodChannel('xyz.luan/audioplayers'),
      MethodChannel('xyz.luan/audioplayers.global'),
    ]) {
      messaggeria.setMockMethodCallHandler(canale, (call) async {
        if (call.method == 'setVolume') {
          final v = (call.arguments as Map?)?['volume'];
          if (v is num) volumi.add(v.toDouble());
        }
        return null;
      });
    }
    messaggeria.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (c) async => Directory.systemTemp.path);
    for (final n in const [
      'xyz.luan/audioplayers.global/events',
      'xyz.luan/audioplayers/events/cerchio_musica',
      'xyz.luan/audioplayers/events/cerchio_effetti',
      'xyz.luan/audioplayers/events/cerchio_toni',
    ]) {
      messaggeria.setMockStreamHandler(
          EventChannel(n), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  });

  tearDown(() {
    // La sentinella e' un temporizzatore che gira ogni due secondi:
    // lasciarlo acceso fa cadere la prova dopo, e non per colpa sua.
    RegiaDellaMusica.sola.dimentica();
    MotoreAudio.lettoriForzati = null;
    RegiaDellaMusica.lettoreForzato = null;
  });

  test('un effetto che arriva mentre la musica sale non la lascia giu\'',
      () async {
    final impostazioni = SettingsController();
    final regia = RegiaDellaMusica.sola;

    // La musica parte, e mentre sta ancora salendo arriva la voce dell'intro:
    // e' esattamente la sequenza della 2219.
    final partenza = regia.vaiA(MusicaDelCerchio.home, impostazioni);
    await Future<void>.delayed(const Duration(milliseconds: 120));
    await regia.scendiSottoUnEffetto(const Duration(milliseconds: 300));
    await partenza;

    // Si lascia passare l'effetto e la risalita.
    await Future<void>.delayed(const Duration(milliseconds: 1600));

    expect(volumi, isNotEmpty,
        reason: 'nessun volume e\' arrivato al lettore: la musica non e\' '
            'nemmeno partita');
    final ultimo = volumi.last;
    // ignore: avoid_print
    print('ORDINE CN: dopo l\'effetto il volume si e\' fermato a '
        '${ultimo.toStringAsFixed(3)}, con il voluto a '
        '${impostazioni.volumeMusica}');
    expect(ultimo, greaterThan(impostazioni.volumeMusica * 0.8),
        reason: 'IL TAPPETO E\' RIMASTO GIU\' A '
            '${ultimo.toStringAsFixed(3)} invece di tornare a '
            '${impostazioni.volumeMusica}.\n'
            'E\' il difetto della 2219: un effetto che arriva mentre la '
            'musica sta salendo la lascia dove capita, e dove capita e\' '
            'quasi sempre in basso. Il fondatore la sentiva comparire solo '
            'dopo il login, quando un altro passaggio riscriveva il volume '
            'per intero.\n'
            'Volumi arrivati al lettore: $volumi');
  });
}
