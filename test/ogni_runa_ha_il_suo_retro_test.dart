import 'dart:io';

import 'package:esoteric_circle/core/rituals/runes.dart';
import 'package:esoteric_circle/features/rituals/sunset_rune_screen.dart';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

/// OGNI RUNA HA IL SUO RETRO, ED E' LA SUA PIETRA.
///
/// **Perche' non basta contare i file.** Ventiquattro retri esistono anche se
/// sono ventiquattro copie dello stesso sasso, e sarebbe il difetto peggiore:
/// girando la pietra la persona vedrebbe cambiare il sasso, proprio nel momento
/// in cui il rito deve essere credibile. Questa prova pretende che il retro sia
/// quello della SUA runa, e lo misura confrontando la SAGOMA: il retro nasce
/// dalla runa incisa, quindi ha lo stesso alpha, cioe' lo stesso contorno
/// irregolare, e due pietre diverse non ce l'hanno mai uguale.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// La sagoma di un'immagine, ridotta a una griglia grossolana di pieni e
  /// vuoti: basta a distinguere due sassi rotti a mano, e non dipende dalla
  /// misura, che fra fronte e retro e' diversa apposta.
  ///
  /// Si decodifica col motore di Flutter, che i WebP li apre: il pacchetto
  /// `image` in questo progetto non c'e', e aggiungerne uno per una prova
  /// sarebbe una dipendenza che entra nell'archivio per sempre.
  Future<List<bool>> sagoma(String percorso, {int lato = 24}) async {
    final bytes = await File(percorso).readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes,
        targetWidth: lato, targetHeight: lato);
    final frame = await codec.getNextFrame();
    final dati =
        await frame.image.toByteData(format: ui.ImageByteFormat.rawRgba);
    final px = dati!.buffer.asUint8List();
    final out = <bool>[];
    for (var i = 3; i < px.length; i += 4) {
      out.add(px[i] > 96);
    }
    return out;
  }

  double quantoSiSomigliano(List<bool> a, List<bool> b) {
    var uguali = 0;
    for (var i = 0; i < a.length; i++) {
      if (a[i] == b[i]) uguali++;
    }
    return uguali / a.length;
  }

  testWidgets('nessuna runa resta senza retro', (tester) async {
    final senza = <String>[];
    for (final runa in kElderFuthark) {
      final percorso = pathVergineDi(runa.stem);
      if (percorso == null || !File(percorso).existsSync()) {
        senza.add(runa.name);
      }
    }
    expect(senza, isEmpty,
        reason: 'Queste rune non hanno il retro: $senza. Senza retro non si '
            'puo\' mostrare la pietra coperta, e il lancio non ha un prima.');
  });

  testWidgets('il retro di ogni runa e\' la SUA pietra', (tester) async {
    // Si confronta la sagoma del retro con quella della sua faccia incisa: se
    // il retro fosse di un'altra pietra, o uno solo per tutte, il contorno non
    // combacerebbe.
    final colpevoli = <String>[];
    for (final runa in kElderFuthark) {
      final retro = pathVergineDi(runa.stem);
      final fronte = runa.fullPath;
      if (retro == null || fronte == null) continue;
      if (!File(retro).existsSync() || !File(fronte).existsSync()) continue;
      late double somiglianza;
      await tester.runAsync(() async {
        somiglianza =
            quantoSiSomigliano(await sagoma(retro), await sagoma(fronte));
      });
      if (somiglianza < 0.96) {
        colpevoli.add('${runa.name} (${(somiglianza * 100).toStringAsFixed(1)}'
            ' per cento)');
      }
    }
    expect(colpevoli, isEmpty,
        reason: 'Il retro di queste rune non e\' la loro pietra: $colpevoli. '
            'Girandola, la persona vedrebbe cambiare il sasso.');
  });

  testWidgets('i retri non sono tutti uguali fra loro', (tester) async {
    // La guardia contro il caso peggiore, che la prova sopra non prenderebbe
    // se anche i fronti fossero uguali: due rune qualunque devono avere retri
    // distinguibili.
    var diverse = 0;
    await tester.runAsync(() async {
      final prima = await sagoma(pathVergineDi(kElderFuthark.first.stem)!);
      for (final runa in kElderFuthark.skip(1)) {
        final p = pathVergineDi(runa.stem);
        if (p == null || !File(p).existsSync()) continue;
        if (quantoSiSomigliano(prima, await sagoma(p)) < 0.98) diverse++;
      }
    });
    expect(diverse, greaterThanOrEqualTo(20),
        reason: 'Solo $diverse retri su ventitre si distinguono dal primo: '
            'sono quasi tutti lo stesso sasso.');
  });

  test('il retro pesa meno della faccia incisa', () {
    // Il retro si vede coperto o in volo, mai a fuoco: non deve pesare come la
    // faccia che si guarda da vicino, perche' ventiquattro file in piu' entrano
    // tutti nell'archivio.
    var pesoRetri = 0;
    var pesoFronti = 0;
    for (final runa in kElderFuthark) {
      final retro = pathVergineDi(runa.stem);
      final fronte = runa.fullPath;
      if (retro != null && File(retro).existsSync()) {
        pesoRetri += File(retro).lengthSync();
      }
      if (fronte != null && File(fronte).existsSync()) {
        pesoFronti += File(fronte).lengthSync();
      }
    }
    expect(pesoRetri, lessThan(pesoFronti),
        reason: 'I ventiquattro retri pesano $pesoRetri byte contro i '
            '$pesoFronti delle facce incise.');
  });
}
