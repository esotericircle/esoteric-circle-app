import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/condivisione/il_titolo_in_immagine.dart';
import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/condividi_la_rivelazione_in_video.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA RIVELAZIONE IN VIDEO: IL COMANDO A FFMPEG, FINO DOVE SI PUO'
/// PROVARE SENZA FFMPEG VERO.** Ordine FZ voce FZ.08, 17 ottobre 2026.
///
/// FFmpeg e' codice nativo: nessuna prova qui lo fa girare davvero. **Ed e'
/// proprio cio' che ha nascosto il difetto**: con un FFmpeg finto la prima
/// stesura era verde, e sul Realme 767f596c, il 20 ottobre 2026, "Condividi
/// come video" non faceva niente, perche' il comando usava `drawtext`, un
/// filtro che la libreria Android della variante `min-gpl` non ha. Da quel
/// giorno la prova guarda anche **quali filtri** il comando chiede, contro
/// l'elenco di quelli che la libreria vera ha
/// (`IlTitoloInImmagine.filtriDisponibili`). Padre: ordine FZ voce FZ.08.
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

  /// Un titolo finto, che ricorda che cosa gli e' stato chiesto.
  final chiesto = <String>[];
  Future<Uint8List> titoloFinto(
      {required String rigaUno,
      required String rigaDue,
      required String data}) async {
    chiesto
      ..clear()
      ..addAll([rigaUno, rigaDue, data]);
    return Uint8List.fromList([137, 80, 78, 71]);
  }

  /// I nomi dei filtri dentro un comando FFmpeg: quello che sta fra
  /// virgolette dopo `-vf` o `-filter_complex`, spezzato sui separatori.
  Set<String> filtriDi(String comando) {
    final m = RegExp(r'-(?:vf|filter_complex) "([^"]*)"').allMatches(comando);
    final fuori = <String>{};
    for (final x in m) {
      for (final pezzo in x.group(1)!.split(RegExp(r'[,;]'))) {
        final senzaEtichette = pezzo.replaceAll(RegExp(r'\[[^\]]*\]'), '');
        final nome = senzaEtichette.split('=').first.trim();
        if (nome.isNotEmpty) fuori.add(nome);
      }
    }
    return fuori;
  }

  test(
      'IL COMANDO USA SOLO FILTRI CHE LA LIBRERIA ANDROID HA, e porta il '
      'centro, l\'immagine del titolo, libx264 e l\'audio copiato', () async {
    String? comandoVisto;
    await condividiLaRivelazioneInVideo(
      animale: lupo,
      quando: DateTime(2026, 10, 17),
      percorsoDelCentro: percorsoCentro,
      cartella: () async => tempDir,
      titolo: titoloFinto,
      esecutore: (comando) async {
        comandoVisto = comando;
        return false;
      },
    );
    expect(comandoVisto, isNotNull);
    final filtri = filtriDi(comandoVisto!);
    expect(filtri, isNotEmpty,
        reason: 'il comando non ha filtri: la misura non guarda niente');
    expect(filtri.difference(IlTitoloInImmagine.filtriDisponibili), isEmpty,
        reason: 'il comando chiede filtri che la libreria Android della '
            'variante min-gpl non ha: $filtri. Sul telefono FFmpeg cade e '
            'il pulsante non fa niente (drawtext, 20 ottobre 2026)');
    expect(comandoVisto, contains(percorsoCentro));
    expect(comandoVisto, contains('rivelazione_titolo.png'));
    expect(comandoVisto, contains('libx264'));
    expect(comandoVisto, contains('-c:a copy'),
        reason: 'l\'audio di Flow non va ricodificato, solo copiato');
    expect(chiesto, ['MI HA TROVATO', 'IL LUPO', 'mi ha trovato il 17 ottobre 2026']);
  });

  test('UN FFMPEG CHE FALLISCE NON LANCIA, TORNA FALSO', () async {
    final esito = await condividiLaRivelazioneInVideo(
      animale: lupo,
      quando: DateTime(2026, 10, 17),
      percorsoDelCentro: percorsoCentro,
      cartella: () async => tempDir,
      titolo: titoloFinto,
      esecutore: (comando) async => false,
    );
    expect(esito, isFalse);
  });

  test(
      'UN FILE DI USCITA VUOTO NON SI CONDIVIDE: e\' cio\' che lasciava '
      'FFmpeg sul telefono quando il filtro mancava', () async {
    var condiviso = false;
    final esito = await condividiLaRivelazioneInVideo(
      animale: lupo,
      quando: DateTime(2026, 10, 17),
      percorsoDelCentro: percorsoCentro,
      cartella: () async => tempDir,
      titolo: titoloFinto,
      esecutore: (comando) async {
        File('${tempDir.path}/rivelazione_Lupo.mp4').writeAsBytesSync([]);
        return true;
      },
      condividi: (p, t) async => condiviso = true,
    );
    expect(esito, isFalse);
    expect(condiviso, isFalse,
        reason: 'si condivide un video vuoto: chi lo riceve non vede niente');
  });

  test('UN VIDEO VERO SI CONDIVIDE, col testo della rivelazione', () async {
    String? testoVisto;
    final esito = await condividiLaRivelazioneInVideo(
      animale: lupo,
      quando: DateTime(2026, 10, 17),
      percorsoDelCentro: percorsoCentro,
      cartella: () async => tempDir,
      titolo: titoloFinto,
      esecutore: (comando) async {
        File('${tempDir.path}/rivelazione_Lupo.mp4')
            .writeAsBytesSync(List.filled(1000, 1));
        return true;
      },
      condividi: (p, t) async {
        testoVisto = t;
        return true;
      },
    );
    expect(esito, isTrue);
    expect(testoVisto, 'Mi ha trovato il Lupo.');
  });

  test(
      'L\'IMMAGINE DEL TITOLO E\' GRANDE QUANTO IL VIDEO, piena dove ci sono '
      'le righe e trasparente sotto', () async {
    late ui.Image img;
    await TestAsyncUtils.guard(() async {
      final png = await IlTitoloInImmagine.png(
          rigaUno: 'MI HA TROVATO',
          rigaDue: 'IL LUPO',
          data: 'mi ha trovato il 17 ottobre 2026');
      final codec = await ui.instantiateImageCodec(png);
      img = (await codec.getNextFrame()).image;
    });
    expect(img.width, 1080);
    expect(img.height, 1920);
    final px = (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!
        .buffer
        .asUint8List();
    int alfaNellaFascia(int da, int a) {
      var n = 0;
      for (var y = da; y < a; y++) {
        for (var x = 0; x < 1080; x += 2) {
          if (px[(y * 1080 + x) * 4 + 3] > 0) n++;
        }
      }
      return n;
    }

    expect(alfaNellaFascia(140, 400), greaterThan(1000),
        reason: 'nella fascia del titolo non c\'e\' niente di disegnato');
    expect(alfaNellaFascia(600, 1920), 0,
        reason: 'sotto il titolo l\'immagine copre il video');
  });
}
