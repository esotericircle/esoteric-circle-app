import 'dart:io';

import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/condividi_la_rivelazione_in_video.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA RIVELAZIONE IN VIDEO: IL COMANDO A FFMPEG, FINO DOVE SI PUO'
/// PROVARE SENZA FFMPEG VERO.** Ordine FZ voce FZ.08, 17 ottobre 2026.
///
/// FFmpeg e' codice nativo: nessuna prova qui lo fa girare davvero (lo fara'
/// la simulazione sul telefono di collaudo, ordine FZ voce FZ.09). Si prova
/// che il comando porti il nome dell'animale e la data, e che un fallimento
/// di FFmpeg (o un file che non arriva) non lanci: la condivisione via
/// `PortaDellaCondivisione`, che chiama un canale di piattaforma vero, resta
/// fuori da questa prova.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tempDir;
  late String percorsoCentro;

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('rivelazione_video_');
    percorsoCentro = '${tempDir.path}/lupo_centro.mp4';
    File(percorsoCentro).writeAsBytesSync([1, 2, 3]);
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  final lupo = AnimalCatalog.animals.firstWhere((a) => a.name == 'Lupo');

  test(
      'IL COMANDO PORTA IL PERCORSO DEL CENTRO, IL NOME IN MAIUSCOLO E LA '
      'DATA', () async {
    String? comandoVisto;
    await condividiLaRivelazioneInVideo(
      animale: lupo,
      quando: DateTime(2026, 10, 17),
      percorsoDelCentro: percorsoCentro,
      cartella: () async => tempDir,
      esecutore: (comando) async {
        comandoVisto = comando;
        return false; // non serve il file per questa prova
      },
    );
    expect(comandoVisto, isNotNull);
    expect(comandoVisto, contains(percorsoCentro));
    expect(comandoVisto, contains('MI HA TROVATO'));
    expect(comandoVisto, contains('IL LUPO'));
    expect(comandoVisto, contains('17 ottobre 2026'));
    expect(comandoVisto, contains('libx264'));
    expect(comandoVisto, contains('-c:a copy'),
        reason: 'l\'audio di Flow non va ricodificato, solo copiato');
  });

  test('UN FFMPEG CHE FALLISCE NON LANCIA, TORNA FALSO', () async {
    final esito = await condividiLaRivelazioneInVideo(
      animale: lupo,
      quando: DateTime(2026, 10, 17),
      percorsoDelCentro: percorsoCentro,
      cartella: () async => tempDir,
      esecutore: (comando) async => false,
    );
    expect(esito, isFalse);
  });

  test(
      'FFMPEG DICE DI ESSERE RIUSCITO MA IL FILE NON C E\': torna falso, '
      'non lancia e non prova a condividere niente', () async {
    final esito = await condividiLaRivelazioneInVideo(
      animale: lupo,
      quando: DateTime(2026, 10, 17),
      percorsoDelCentro: percorsoCentro,
      cartella: () async => tempDir,
      // **Riuscito per bugia**: non scrive davvero il file di uscita.
      esecutore: (comando) async => true,
    );
    expect(esito, isFalse,
        reason: 'senza il file vero non c e niente da condividere');
  });
}
