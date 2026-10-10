import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:esoteric_circle/core/sensi/motore_audio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// **SU IPHONE IL TONO E' UN FILE .WAV VERO.** 8 ottobre 2026.
///
/// Il fondatore: *"Si iPhone il suono non si sente"*, nella Meditazione. Su
/// iOS audioplayers non suona i byte: li scrive in un file senza estensione e
/// senza tipo, e AVPlayer non lo apre. Nessuna prova arriva al lettore nativo,
/// quindi qui si misura la cosa che decide: la sorgente che il motore gli
/// consegna. Su iPhone un file `.wav` col suo tipo; su Android i byte.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final wav = Uint8List.fromList(List.generate(64, (i) => i));
  late Directory cartella;

  setUp(() {
    cartella = Directory.systemTemp.createTempSync('toni');
    MotoreAudio.cartellaDeiToni = () async => cartella;
  });
  tearDown(() => cartella.deleteSync(recursive: true));

  test('su iPhone il tono e\' un file .wav col suo tipo, coi byte del tono',
      () async {
    final s =
        await MotoreAudio.sorgenteDelTono(wav, piattaforma: TargetPlatform.iOS);
    expect(s, isA<DeviceFileSource>());
    final f = s as DeviceFileSource;
    expect(f.path, endsWith('.wav'));
    expect(f.mimeType, 'audio/wav');
    expect(File(f.path).readAsBytesSync(), wav);
    // Il tono dopo non riscrive il file che sta suonando.
    final dopo =
        await MotoreAudio.sorgenteDelTono(wav, piattaforma: TargetPlatform.iOS)
            as DeviceFileSource;
    expect(dopo.path, isNot(f.path));
  });

  test('su Android il tono resta byte, come prima', () async {
    final s = await MotoreAudio.sorgenteDelTono(wav,
        piattaforma: TargetPlatform.android);
    expect(s, isA<BytesSource>());
  });
}
