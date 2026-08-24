import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esoteric_circle/design_system/tokens/color_tokens.dart';
import 'package:flutter_test/flutter_test.dart';

/// L ICONA E QUELLA DEL CERCHIO. Ordine BB voce 13.
///
/// **Il fatto del fondatore**: l icona dell app era ancora quella predefinita
/// di Flutter. Chi installa il Cerchio si trovava sulla schermata di casa il
/// logo di un altro prodotto.
///
/// **Cosa era rotto sotto, e non si vedeva.** Non mancava solo il disegno.
/// Mancava l **icona adattiva**: Android dalla versione 8 compone due strati e
/// poi ci passa sopra la maschera del lanciatore, tonda o smussata o a goccia.
/// Senza i due strati il sistema prende l immagine piena e la ritaglia dove
/// capita. Un medaglione tondo con le rune sul bordo, ritagliato dove capita,
/// perde proprio le rune.
///
/// **Come e stata fatta.** `tool/genera_icona.py` ritaglia il medaglione da
/// `assets/brand/logo.png`, gli toglie il fondo bianco e lo posa sul cielo del
/// Cerchio. Il ritaglio **si misura, non si scrive a mano**, e questa prova
/// sorveglia il risultato di quella misura.
///
/// **DUE VOLTE IL RITAGLIO HA SBAGLIATO, e nessuna prova lo avrebbe visto.**
/// Prima cercava una riga vuota sotto la meta del logo, e la trovava fra la
/// scritta e il fregio: si portava dentro "Esoteric Circle". Poi cercava il
/// punto piu largo, e lo trovava sulla scritta, che e larga 590 punti contro i
/// 580 del cerchio. In tutti e due i casi il file c era, pesava, si apriva, e
/// aveva la misura giusta. **Una prova che conta i file sarebbe stata verde.**
/// Per questo qui sotto si guarda dentro l immagine.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const res = 'android/app/src/main/res';

  /// Il lato dichiarato dal PNG, letto dall intestazione IHDR.
  ///
  /// Sta nei byte 16..23 di ogni PNG, in big endian. Si legge cosi invece di
  /// decodificare tutto perche per contare le misure non serve la pittura.
  List<int> misuraDelPng(String percorso) {
    final b = File(percorso).readAsBytesSync();
    int quattro(int da) =>
        (b[da] << 24) | (b[da + 1] << 16) | (b[da + 2] << 8) | b[da + 3];
    return [quattro(16), quattro(20)];
  }

  /// I pixel veri, decodificati.
  Future<(int, int, Uint8List)> pittura(String percorso) async {
    final codec = await ui.instantiateImageCodec(
        File(percorso).readAsBytesSync());
    final frame = await codec.getNextFrame();
    final dati = await frame.image.toByteData(
        format: ui.ImageByteFormat.rawRgba);
    return (frame.image.width, frame.image.height, dati!.buffer.asUint8List());
  }

  test('BB.13: le cinque misure di Android ci sono tutte, e sono giuste', () {
    const attese = {
      'mipmap-mdpi': 48,
      'mipmap-hdpi': 72,
      'mipmap-xhdpi': 96,
      'mipmap-xxhdpi': 144,
      'mipmap-xxxhdpi': 192,
    };
    final guasti = <String>[];
    attese.forEach((cartella, lato) {
      for (final nome in const ['ic_launcher', 'ic_launcher_foreground']) {
        final percorso = '$res/$cartella/$nome.png';
        if (!File(percorso).existsSync()) {
          guasti.add('$percorso non esiste');
          continue;
        }
        final m = misuraDelPng(percorso);
        if (m[0] != lato || m[1] != lato) {
          guasti.add('$percorso e ${m[0]}x${m[1]} invece di ${lato}x$lato');
        }
      }
    });
    // ignore: avoid_print
    print('ORDINE BB VOCE 13: misure Android controllate '
        '${attese.length * 2}, guaste ${guasti.length}');
    expect(guasti, isEmpty, reason: guasti.join('; '));
  });

  test('BB.13: l adattiva e DICHIARATA, se no i due strati sono file muti',
      () {
    final xml = File('$res/mipmap-anydpi-v26/ic_launcher.xml');
    expect(xml.existsSync(), isTrue,
        reason: 'senza questo XML Android ignora i due strati e continua a '
            'ritagliare l immagine piena dove capita');
    final t = xml.readAsStringSync();
    for (final strato in const [
      '<background',
      '<foreground',
      '<monochrome',
    ]) {
      expect(t, contains(strato),
          reason: 'manca lo strato "$strato": senza monochrome il Cerchio '
              'resta l unica icona a colori per chi intona la schermata di '
              'casa allo sfondo');
    }

    // **LA TINTA VIENE DAL CODICE.** Se il cielo del Cerchio cambia, questa
    // cade e l icona va rigenerata: e cio che deve succedere.
    final colore = File('$res/values/ic_launcher_background.xml')
        .readAsStringSync();
    final atteso = ColorTokens.neutralDeep.toARGB32() & 0xFFFFFF;
    final scritto =
        '#${atteso.toRadixString(16).toUpperCase().padLeft(6, '0')}';
    // ignore: avoid_print
    print('ORDINE BB VOCE 13: il fondo dichiarato e $scritto');
    expect(colore, contains(scritto),
        reason: 'il fondo dell icona non e il cielo del Cerchio: rilancia '
            'tool/genera_icona.py');
  });

  test('BB.13: il manifest punta all icona, e non a un nome qualunque', () {
    final manifest =
        File('android/app/src/main/AndroidManifest.xml').readAsStringSync();
    expect(manifest, contains('android:icon="@mipmap/ic_launcher"'),
        reason: 'l applicazione non dichiara la sua icona');
  });

  test('BB.13: iOS ha ogni misura che il suo catalogo promette', () {
    const cartella = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';
    final catalogo = jsonDecode(
        File('$cartella/Contents.json').readAsStringSync()) as Map;
    final immagini = (catalogo['images'] as List).cast<Map>();
    final guasti = <String>[];
    for (final voce in immagini) {
      final nome = voce['filename'] as String?;
      if (nome == null) {
        guasti.add('una voce del catalogo non nomina nessun file');
        continue;
      }
      final percorso = '$cartella/$nome';
      if (!File(percorso).existsSync()) {
        guasti.add('$nome e promesso dal catalogo e non esiste');
        continue;
      }
      // Il lato vero: la misura in punti moltiplicata per la scala.
      final punti = double.parse((voce['size'] as String).split('x').first);
      final scala = int.parse((voce['scale'] as String).replaceAll('x', ''));
      final lato = (punti * scala).round();
      final m = misuraDelPng(percorso);
      if (m[0] != lato || m[1] != lato) {
        guasti.add('$nome e ${m[0]}x${m[1]} invece di ${lato}x$lato');
      }
    }
    // ignore: avoid_print
    print('ORDINE BB VOCE 13: voci del catalogo iOS ${immagini.length}, '
        'guaste ${guasti.length}');
    expect(immagini, hasLength(19),
        reason: 'il catalogo iOS ha perso delle voci');
    expect(guasti, isEmpty, reason: guasti.join('; '));
  });

  testWidgets('BB.13: dentro l icona c e il medaglione, e NON la scritta',
      (tester) async {
    // **QUESTA E LA PROVA CHE GUARDA.** Tutte le altre contano file e leggono
    // testo: sarebbero state verdi tutte e due le volte che il ritaglio ha
    // preso la scritta.
    //
    // **Il primo tentativo di prova non mordeva, ed e stato buttato.** Diceva:
    // un medaglione e tondo, quindi alto e largo devono coincidere. Rimesso il
    // ritaglio sbagliato, l ha dichiarato tondo allo 0,9 per cento. Il motivo:
    // il ritaglio, largo 598 e alto 643, viene poi **ridimensionato a un
    // quadrato**, e il ridimensionamento cancella proprio la sproporzione che
    // quella prova cercava. Misurava una cosa che non poteva piu esistere.
    //
    // **Cosa distingue davvero un medaglione da un medaglione con la scritta
    // sotto: il profilo.** Un cerchio, riga per riga, si allarga fino a meta e
    // poi si stringe fino a sparire, e non torna mai indietro. Una scritta
    // sotto al cerchio si vede come un secondo blocco che **risale** dopo la
    // strozzatura. Si cerca quella risalita.
    late double risalita;
    late int doveSiStringe;
    await tester.runAsync(() async {
      final (w, h, px) = await pittura('$res/mipmap-xxxhdpi/'
          'ic_launcher_foreground.png');
      // Quanto e largo il contenuto, riga per riga.
      final larghezze = List<int>.filled(h, 0);
      for (var y = 0; y < h; y++) {
        var sx = -1, dx = -1;
        for (var x = 0; x < w; x++) {
          // Opaco per meta: sotto quella soglia e l alone del bordo.
          if (px[(y * w + x) * 4 + 3] > 128) {
            if (sx < 0) sx = x;
            dx = x;
          }
        }
        larghezze[y] = sx < 0 ? 0 : dx - sx;
      }
      final massimo = larghezze.reduce((a, b) => a > b ? a : b);
      expect(massimo, greaterThan(0), reason: 'il primo piano e tutto vuoto');
      final yMax = larghezze.indexOf(massimo);

      // La strozzatura: dove il profilo scende a un settimo del suo massimo.
      final soglia = massimo * 0.15;
      doveSiStringe = h;
      for (var y = yMax; y < h; y++) {
        if (larghezze[y] < soglia) {
          doveSiStringe = y;
          break;
        }
      }
      // **E sotto la strozzatura non deve esserci piu niente.**
      var dopo = 0;
      for (var y = doveSiStringe; y < h; y++) {
        if (larghezze[y] > dopo) dopo = larghezze[y];
      }
      risalita = dopo / massimo;
      // ignore: avoid_print
      print('ORDINE BB VOCE 13: il profilo e largo al massimo $massimo alla '
          'riga $yMax, si stringe alla riga $doveSiStringe, e sotto risale '
          'fino al ${(risalita * 100).toStringAsFixed(1)} per cento');
    });
    expect(risalita, lessThan(0.15),
        reason: 'sotto il medaglione il disegno RISALE: il ritaglio si e '
            'preso un secondo blocco, e la sola cosa che sta sotto al '
            'medaglione nel logo e la scritta "Esoteric Circle". '
            'Rilancia tool/genera_icona.py');
  });

  testWidgets('BB.13: e il fondo e il cielo, non il bianco del logo',
      (tester) async {
    // **IL BIANCO ERA IL VERO PERICOLO.** Il logo di partenza ha fondo bianco.
    // Un fondo bianco su una schermata di casa scura e un francobollo, e nella
    // maschera tonda lascia un alone agli angoli.
    late int r, g, b, a;
    await tester.runAsync(() async {
      final (w, _, px) = await pittura('$res/mipmap-xxxhdpi/ic_launcher.png');
      // L angolo in alto a sinistra: piu lontano possibile dal medaglione.
      r = px[0];
      g = px[1];
      b = px[2];
      a = px[3];
      expect(w, 192);
    });
    const atteso = ColorTokens.neutralDeep;
    // ignore: avoid_print
    print('ORDINE BB VOCE 13: l angolo dell icona e rgba($r, $g, $b, $a)');
    expect(a, 255, reason: 'l icona piena ha un angolo trasparente');
    expect([r, g, b], [
      (atteso.r * 255).round(),
      (atteso.g * 255).round(),
      (atteso.b * 255).round(),
    ], reason: 'il fondo dell icona non e il cielo del Cerchio');
  });
}
