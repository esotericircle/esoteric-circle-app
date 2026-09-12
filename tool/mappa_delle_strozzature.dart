import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/sigilli/ancoraggi_dei_sentieri.dart';
import 'package:esoteric_circle/core/sigilli/forma_dell_elemento.dart';
import 'package:esoteric_circle/core/sigilli/regole_delle_tre_arti.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA MAPPA DELLE STROZZATURE DEL LOTO. Ordine AB voce 01.
///
/// **A cosa serve, e a chi.** Le due strade automatiche per chiudere i
/// trentatre ripieghi del Loto sono state escluse tutte e due con una misura:
/// chiudere la regione allarga i passaggi, saldare il muro taglia i petali in
/// due. Quel che resta tocca l'arte, che e' di Mauro. **Ma cio' che gli si
/// chiede deve essere piccolo e preciso**: non marcare cinquanta petali, bensi'
/// ingrossare un filo d'oro in sedici punti noti, ognuno con la sua larghezza.
///
/// **Il segno e' MAGENTA, e la scelta e' misurata e non estetica.** L'arte del
/// Loto e' oro e verde: il magenta e' il complementare del verde e nel disegno
/// non c'e', e lo strumento lo verifica contando quanti pixel dell'arte gli
/// somigliano prima di disegnare. Un segno dello stesso colore del disegno e'
/// una mappa che non si legge.
///
/// Si lancia a mano:
///
///     flutter test tool/mappa_delle_strozzature.dart
void main() {
  const dove = 'docs/preview/strozzature_loto.png';

  testWidgets('la mappa delle strozzature del Loto', (tester) async {
    // **DENTRO runAsync**, perche' il codec e la scrittura del PNG le completa
    // il motore sul tempo vero.
    await tester.runAsync(() async {
      final font = FontLoader('Cinzel')
        ..addFont(File('assets/fonts/Cinzel-variable.ttf')
            .readAsBytes()
            .then((b) => ByteData.view(b.buffer)));
      await font.load();

      final byte =
          await File(RegoleDelleTreArti.arteDi(Sentiero.loto)).readAsBytes();
      final codice = await ui.instantiateImageCodec(byte);
      final arte = (await codice.getNextFrame()).image;
      final w = arte.width, h = arte.height;
      final rgba =
          (await arte.toByteData(format: ui.ImageByteFormat.rawRgba))!
              .buffer
              .asUint8List();

      // **IL MAGENTA NON DEVE ESISTERE NELL'ARTE, e si conta invece di
      // affermarlo.**
      var somiglianti = 0;
      for (var p = 0; p < w * h; p++) {
        final i = p * 4;
        if (rgba[i + 3] > 128 &&
            rgba[i] > 140 &&
            rgba[i + 2] > 140 &&
            rgba[i + 1] < 90) {
          somiglianti++;
        }
      }
      // ignore: avoid_print
      print('MAPPA: pixel magenta gia\' presenti nell\'arte: $somiglianti '
          'su ${w * h}');
      expect(somiglianti * 1000, lessThan(w * h),
          reason: 'il magenta esiste gia\' nell\'arte: serve un\'altra tinta, '
              'perche\' un segno che si confonde col disegno non e\' una mappa');

      final ancoraggi = AncoraggiDeiSentieri.di(Sentiero.loto)!;
      final regola = RegoleDelleTreArti.formaDi(Sentiero.loto, w);

      // Le colate, con la loro regione: la crescita la lascia dichiarata.
      final regioni = <int, Set<int>>{};
      for (var i = 0; i < ancoraggi.length; i++) {
        final sx = (ancoraggi[i].x * w).round();
        final sy = (ancoraggi[i].y * h).round();
        CrescitaDellaForma.cresci(rgba, w, h, sx, sy, regola);
        if (!CrescitaDellaForma.ultimaEUscita) continue;
        regioni[i] = CrescitaDellaForma.ultimaRegione.toSet();
      }
      // ignore: avoid_print
      print('MAPPA: colate trovate ${regioni.length}');

      // **I SISTEMI: due colate che condividono la meta' della regione sono la
      // STESSA colata**, e Mauro deve ingrossare un filo solo, non due.
      final sistemi = <List<int>>[];
      for (final voce in regioni.entries) {
        var messo = false;
        for (final s in sistemi) {
          final altra = regioni[s.first]!;
          final comuni = voce.value.where(altra.contains).length;
          final piccola =
              voce.value.length < altra.length ? voce.value.length : altra.length;
          if (comuni * 2 > piccola) {
            s.add(voce.key);
            messo = true;
            break;
          }
        }
        if (!messo) sistemi.add([voce.key]);
      }
      // ignore: avoid_print
      print('MAPPA: sistemi distinti ${sistemi.length}');

      final punti = <(int, int, int, List<int>)>[];
      for (var n = 0; n < sistemi.length; n++) {
        final capofila = sistemi[n].first;
        final regione = regioni[capofila]!;
        final sx = (ancoraggi[capofila].x * w).round();
        final sy = (ancoraggi[capofila].y * h).round();
        final collo = _collo(regione, w, h, sx, sy);
        if (collo == null) continue;
        punti.add((n + 1, collo.$1, collo.$2, [collo.$3, ...sistemi[n]]));
      }

      // ignore: avoid_print
      print('MAPPA: punti disegnati ${punti.length}');
      expect(punti.length, sistemi.length,
          reason: 'un sistema non ha prodotto nessun punto: la mappa direbbe '
              'meno di quello che sa');

      final registratore = ui.PictureRecorder();
      final tela = Canvas(registratore);
      // L'arte attenuata: deve restare riconoscibile e non rubare l'occhio.
      tela.drawImageRect(
        arte,
        Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
        Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
        Paint()..color = const Color(0x59FFFFFF),
      );
      const magenta = Color(0xFFFF00FF);
      for (final (numero, x, y, _) in punti) {
        tela.drawCircle(
          Offset(x.toDouble(), y.toDouble()),
          22,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5
            ..color = magenta,
        );
        tela.drawCircle(
            Offset(x.toDouble(), y.toDouble()), 4, Paint()..color = magenta);
        final scritta = TextPainter(
          text: TextSpan(
            text: '$numero',
            // **IL FONT SI DICHIARA**, altrimenti in prova ogni cifra e' una
            // scatola: e' un difetto gia' uscito tre volte in questo progetto.
            style: const TextStyle(
              fontFamily: 'Cinzel',
              fontSize: 44,
              fontWeight: FontWeight.w700,
              color: magenta,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        scritta.paint(tela, Offset(x + 26, y - 52));
      }
      final immagine =
          await registratore.endRecording().toImage(w, h);
      final png = await immagine.toByteData(format: ui.ImageByteFormat.png);
      File(dove).writeAsBytesSync(png!.buffer.asUint8List());
      // ignore: avoid_print
      print('mappa: $dove');

      // L'ELENCO, che a Mauro serve piu' dell'immagine.
      for (final (numero, x, y, dati) in punti) {
        final larghezza = dati.first;
        final petali = dati.skip(1).map(_nome(ancoraggi)).join(', ');
        // ignore: avoid_print
        print('  $numero: strozzatura $larghezza pixel a ($x,$y), '
            'petali $petali');
      }
    });
  });
}

/// Il nome leggibile di un ancoraggio: fiore e petalo in senso orario.
String Function(int) _nome(List<dynamic> ancoraggi) => (int i) {
      final fiore = ancoraggi[i].gruppo;
      if (ancoraggi[i].eGrande) return '$fiore.centro';
      final petali = StrutturaDelLoto.petaliInSensoOrario(
        ancoraggi.cast(),
        fiore,
        larghezzaArte: 941,
        altezzaArte: 1672,
      );
      return '$fiore.${petali.indexOf(i) + 1}';
    };

/// **IL COLLO DELLA COLATA: dove passa, e quanto e' largo.**
///
/// Dentro la regione si misura quanto ogni pixel dista dal bordo della regione,
/// poi si cerca il cammino dal seme al bordo della finestra che tiene il valore
/// piu' alto nel suo punto peggiore. **Quel punto peggiore e' il collo**, la sua
/// larghezza e' il doppio piu' uno, e le sue coordinate sono cio' che Mauro deve
/// ritoccare.
(int, int, int)? _collo(Set<int> regione, int w, int h, int sx, int sy) {
  final distanza = <int, int>{};
  final coda = <int>[];
  for (final p in regione) {
    final x = p % w, y = p ~/ w;
    var bordo = false;
    for (final d in const [
      [1, 0],
      [-1, 0],
      [0, 1],
      [0, -1]
    ]) {
      final nx = x + d[0], ny = y + d[1];
      if (nx < 0 || ny < 0 || nx >= w || ny >= h ||
          !regione.contains(ny * w + nx)) {
        bordo = true;
        break;
      }
    }
    if (bordo) {
      distanza[p] = 0;
      coda.add(p);
    }
  }
  for (var i = 0; i < coda.length; i++) {
    final p = coda[i];
    final x = p % w, y = p ~/ w;
    for (final d in const [
      [1, 0],
      [-1, 0],
      [0, 1],
      [0, -1]
    ]) {
      final nx = x + d[0], ny = y + d[1];
      final n = ny * w + nx;
      if (!regione.contains(n) || distanza.containsKey(n)) continue;
      distanza[n] = distanza[p]! + 1;
      coda.add(n);
    }
  }
  // Il pixel della regione piu' vicino al seme, che il seme puo' non esserci.
  var partenza = -1, meglio = 1 << 30;
  for (final p in regione) {
    final dx = p % w - sx, dy = p ~/ w - sy;
    final q = dx * dx + dy * dy;
    if (q < meglio) {
      meglio = q;
      partenza = p;
    }
  }
  if (partenza < 0) return null;
  final massimo = distanza.values.fold<int>(0, (a, b) => a > b ? a : b);
  // Si scende di livello finche' il seme non raggiunge il bordo della finestra.
  for (var livello = massimo; livello >= 0; livello--) {
    if ((distanza[partenza] ?? -1) < livello) continue;
    final da = <int, int>{partenza: -1};
    final pila = <int>[partenza];
    int? arrivo;
    while (pila.isNotEmpty && arrivo == null) {
      final p = pila.removeLast();
      final x = p % w, y = p ~/ w;
      for (final d in const [
        [1, 0],
        [-1, 0],
        [0, 1],
        [0, -1]
      ]) {
        final nx = x + d[0], ny = y + d[1];
        final n = ny * w + nx;
        if (!regione.contains(n) || da.containsKey(n)) continue;
        if ((distanza[n] ?? -1) < livello) continue;
        da[n] = p;
        // Il bordo della finestra e' dove la regione tocca il limite del
        // riquadro che la contiene: qui basta l'estremo dell'immagine oppure un
        // pixel a piu' di cento dal seme, che e' il raggio massimo.
        final lontano = (nx - sx).abs() > 100 || (ny - sy).abs() > 100;
        if (lontano) {
          arrivo = n;
          break;
        }
        pila.add(n);
      }
    }
    if (arrivo == null) continue;
    // Il collo sta sul cammino, ed e' il suo punto piu' stretto.
    var p = arrivo, colloP = arrivo, colloD = distanza[arrivo] ?? 0;
    while (da[p] != null && da[p] != -1) {
      p = da[p]!;
      final d = distanza[p] ?? 0;
      if (d < colloD) {
        colloD = d;
        colloP = p;
      }
    }
    return (colloP % w, colloP ~/ w, 2 * colloD + 1);
  }
  return null;
}
