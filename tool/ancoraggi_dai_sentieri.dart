import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/sigilli/forma_dell_elemento.dart';
import 'package:esoteric_circle/core/sigilli/lettura_degli_ancoraggi.dart';
import 'package:esoteric_circle/core/sigilli/regole_delle_tre_arti.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// LO STRUMENTO CHE RICAVA GLI ANCORAGGI DALL'ARTE. Ordine T voce 01.
///
/// **Sta fuori dalla suite di proposito**, come `tool/attribuzione_cieca.dart`:
/// `flutter test` senza argomenti guarda solo `test/`, quindi questo non parte
/// mai da solo. Si lancia a mano quando l'arte cambia.
///
/// Come si lancia, dal PC:
///
///     flutter test tool/ancoraggi_dai_sentieri.dart
///
/// Cosa fa, in quest'ordine:
///   1. legge le tre immagini di `brand_assets/sentieri/`;
///   2. per ogni sentiero che ha una regola, ricava i cinquantacinque ancoraggi;
///   3. scrive il dato in `lib/core/sigilli/ancoraggi_dei_sentieri.dart`;
///   4. disegna l'IMMAGINE DI VERIFICA in `docs/preview/`, cioe' l'arte con
///      sopra i punti trovati numerati da 1 a 55.
///
/// **Il passo 4 non e' un di piu'.** E' l'unica cosa che permette a Mauro di
/// dire in due secondi se i punti sono giusti: una prova verde dice che sono
/// cinquantacinque, non che sono i cinquantacinque giusti.
void main() {
  testWidgets('ricava gli ancoraggi dall\'arte e scrive il dato',
      (tester) async {
    await tester.runAsync(() async {
      // **IL FONT VA CARICATO A MANO.** In `flutter test` il font predefinito
      // disegna un rettangolo al posto di ogni cifra: senza questa riga
      // l'immagine di verifica mostra scatole colorate invece dei numeri, e
      // l'unica cosa che serviva a Mauro non c'e' piu'.
      final font = FontLoader('Cinzel')
        ..addFont(File('assets/fonts/Cinzel-variable.ttf')
            .readAsBytes()
            .then((b) => ByteData.view(b.buffer)));
      await font.load();
      final righe = <String>[];
      final formeDart = <String>[];
      final saltati = <String>[];
      for (final sentiero in Sentieri.tutti) {
        final regola = RegoleDelleTreArti.per(sentiero);
        final sorgente = RegoleDelleTreArti.sorgenteDi(sentiero);
        final daLeggere = File(RegoleDelleTreArti.daDoveSiLegge(sentiero));
        final arteFile = File(RegoleDelleTreArti.arteDi(sentiero));
        if (!daLeggere.existsSync() || !arteFile.existsSync()) {
          saltati.add(sentiero.name);
          // ignore: avoid_print
          print('${sentiero.name}: manca ${daLeggere.path} oppure '
              '${arteFile.path}, saltato');
          continue;
        }
        final arte = await _apri(await arteFile.readAsBytes());
        final sorgenteImmagine = sorgente == SorgenteDegliAncoraggi.arte
            ? arte
            : await _apri(await daLeggere.readAsBytes());
        // **LE DUE IMMAGINI DEVONO AVERE LA STESSA MISURA**, altrimenti i
        // pallini non dicono dove stanno gli elementi dell'arte ma dove
        // starebbero su un'altra tela.
        if (sorgenteImmagine.width != arte.width ||
            sorgenteImmagine.height != arte.height) {
          throw StateError('${sentiero.name}: i pallini sono '
              '${sorgenteImmagine.width}x${sorgenteImmagine.height} mentre '
              'l\'arte misura ${arte.width}x${arte.height}. Misure diverse: i '
              'pallini non valgono');
        }
        final crudo = (await sorgenteImmagine.toByteData(
                format: ui.ImageByteFormat.rawRgba))!
            .buffer
            .asUint8List();
        final ancoraggi = LetturaDegliAncoraggi.leggi(
            crudo, sorgenteImmagine.width, sorgenteImmagine.height, regola,
            raggruppaPerColore: sorgente == SorgenteDegliAncoraggi.pallini);
        // ignore: avoid_print
        print('${sentiero.name}: ${ancoraggi.length} ancoraggi da '
            '${sorgenteImmagine.width}x${sorgenteImmagine.height}, '
            'sorgente ${sorgente.name}');
        righe.add(_dartDi(sentiero, ancoraggi));

        // **LE CINQUANTACINQUE FORME, calcolate qui e non a ogni fotogramma.**
        final crudoArte = (await arte.toByteData(
                format: ui.ImageByteFormat.rawRgba))!
            .buffer
            .asUint8List();
        final materia = RegoleDelleTreArti.formaDi(sentiero, arte.width);
        final forme = <FormaDellElemento>[];
        for (final a in ancoraggi) {
          forme.add(CrescitaDellaForma.cresci(
            crudoArte,
            arte.width,
            arte.height,
            (a.x * arte.width).round(),
            (a.y * arte.height).round(),
            materia,
          ));
        }
        final ripieghi = forme.where((f) => f.eRipiego).length;
        final aree = forme.where((f) => !f.eRipiego).map((f) => f.area).toList()
          ..sort();
        // ignore: avoid_print
        print('  forme ${forme.length - ripieghi}, ripieghi $ripieghi'
            '${aree.isEmpty ? "" : ", aree min ${aree.first} mediana "
                "${aree[aree.length ~/ 2]} max ${aree.last}"}');
        formeDart.add(_formeDart(sentiero, forme));
        await _immagineDiVerifica(sentiero, arte, ancoraggi, forme);
      }
      _scriviIlDato(righe, saltati);
      _scriviLeForme(formeDart);
    });
  });
}

Future<ui.Image> _apri(Uint8List byte) async {
  final codice = await ui.instantiateImageCodec(byte);
  return (await codice.getNextFrame()).image;
}

String _dartDi(Sentiero sentiero, List<AncoraggioDelSentiero> a) {
  final b = StringBuffer();
  b.writeln('    Sentiero.${sentiero.name}: [');
  for (final p in a) {
    b.writeln('      AncoraggioDelSentiero(x: ${p.x.toStringAsFixed(5)}, '
        'y: ${p.y.toStringAsFixed(5)}, gruppo: ${p.gruppo}, '
        'eGrande: ${p.eGrande}),');
  }
  b.writeln('    ],');
  return b.toString();
}

void _scriviIlDato(List<String> righe, List<String> saltati) {
  final b = StringBuffer()
    ..writeln('library;')
    ..writeln()
    ..writeln("import 'lettura_degli_ancoraggi.dart';")
    ..writeln("import 'sentieri.dart';")
    ..writeln()
    ..writeln('/// GLI ANCORAGGI DEI TRE SENTIERI. Ordine T voce 01.')
    ..writeln('///')
    ..writeln('/// **QUESTO FILE NON SI SCRIVE A MANO.** Lo produce')
    ..writeln('/// `tool/ancoraggi_dai_sentieri.dart` leggendo le immagini di')
    ..writeln('/// `brand_assets/sentieri/`, e')
    ..writeln('/// `test/gli_ancoraggi_vengono_dall_arte_test.dart` rifa\' la')
    ..writeln('/// lettura a ogni giro e confronta: se l\'arte cambia e questo')
    ..writeln('/// file no, una riga cade.')
    ..writeln('///')
    ..writeln('/// **Perche\' il dato sta qui invece di ricavarsi ogni volta.**')
    ..writeln('/// Riconoscere le macchie su un milione e mezzo di pixel costa')
    ..writeln('/// troppo per farlo mentre qualcuno guarda la schermata.');
  if (saltati.isNotEmpty) {
    b
      ..writeln('///')
      ..writeln('/// **Sentieri senza ancoraggi, oggi: ${saltati.join(", ")}.**')
      ..writeln('/// Non hanno una regola di riconoscimento perche\' la loro')
      ..writeln('/// arte non consente di ricavarli da sola: la ragione,')
      ..writeln('/// misurata, sta in `docs/ordini/ORDINE_T_MANIFESTO.md`.')
      ..writeln('/// Chi chiede gli ancoraggi di un sentiero senza arte')
      ..writeln('/// riceve nulla, e il disegno resta quello procedurale.');
  }
  b
    ..writeln('class AncoraggiDeiSentieri {')
    ..writeln('  const AncoraggiDeiSentieri._();')
    ..writeln()
    ..writeln('  static const Map<Sentiero, List<AncoraggioDelSentiero>> '
        'tutti = {')
    ..write(righe.join())
    ..writeln('  };')
    ..writeln()
    ..writeln('  /// Gli ancoraggi di un sentiero, o nulla se la sua arte non')
    ..writeln('  /// e\' ancora leggibile.')
    ..writeln('  static List<AncoraggioDelSentiero>? di(Sentiero sentiero) =>')
    ..writeln('      tutti[sentiero];')
    ..writeln('}');
  File('lib/core/sigilli/ancoraggi_dei_sentieri.dart')
      .writeAsStringSync(b.toString());
  // ignore: avoid_print
  print('scritto lib/core/sigilli/ancoraggi_dei_sentieri.dart');
}

/// L'ARTE COI PUNTI SOPRA, numerati nel loro ordine.
Future<void> _immagineDiVerifica(
  Sentiero sentiero,
  ui.Image arte,
  List<AncoraggioDelSentiero> ancoraggi,
  List<FormaDellElemento> forme,
) async {
  final registratore = ui.PictureRecorder();
  final tela = Canvas(registratore);
  final w = arte.width.toDouble(), h = arte.height.toDouble();
  tela.drawRect(Rect.fromLTWH(0, 0, w, h),
      Paint()..color = const Color(0xFF0B0D1A));
  tela.drawImage(arte, Offset.zero, Paint());
  // I cinque gruppi hanno cinque colori, cosi' si vede a colpo d'occhio se un
  // punto e' finito nel gruppo sbagliato.
  const colori = [
    Color(0xFFFF4D4D),
    Color(0xFF4DFF88),
    Color(0xFF4DC3FF),
    Color(0xFFFFD24D),
    Color(0xFFC77DFF),
  ];
  for (var i = 0; i < ancoraggi.length; i++) {
    final a = ancoraggi[i];
    final centro = Offset(a.x * w, a.y * h);
    final raggio = a.eGrande ? 46.0 : 30.0;
    final colore = colori[a.gruppo % colori.length];
    // **LA FORMA TROVATA, velata sotto il cerchio.** Serve a Mauro per vedere
    // se la crescita ha preso il petalo giusto o se ha ripiegato sul tondo.
    if (i < forme.length) {
      final f = forme[i];
      final pennello = Paint()
        ..color = (f.eRipiego ? const Color(0xFFFFFFFF) : colore)
            .withValues(alpha: f.eRipiego ? 0.20 : 0.42);
      for (var k = 0; k + 2 < f.strisce.length; k += 3) {
        tela.drawRect(
            Rect.fromLTWH(f.strisce[k + 1].toDouble(), f.strisce[k].toDouble(),
                (f.strisce[k + 2] - f.strisce[k + 1] + 1).toDouble(), 1),
            pennello);
      }
    }
    tela.drawCircle(
        centro,
        raggio,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = a.eGrande ? 7 : 5
          ..color = colore);
    final testo = TextPainter(
      text: TextSpan(
        text: '${i + 1}',
        style: TextStyle(
          color: colore,
          fontFamily: 'Cinzel',
          fontSize: a.eGrande ? 46 : 34,
          fontWeight: FontWeight.w900,
          shadows: const [
            Shadow(color: Color(0xFF000000), blurRadius: 8),
            Shadow(color: Color(0xFF000000), blurRadius: 3),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    testo.paint(tela,
        centro + Offset(raggio * 0.75, -raggio * 0.75 - testo.height / 2));
  }
  final immagine = await registratore
      .endRecording()
      .toImage(arte.width, arte.height);
  final png = await immagine.toByteData(format: ui.ImageByteFormat.png);
  final dove = File('docs/preview/ancoraggi_${sentiero.name}.png');
  dove.parent.createSync(recursive: true);
  dove.writeAsBytesSync(png!.buffer.asUint8List());
  // ignore: avoid_print
  print('  immagine di verifica: ${dove.path}');
}

String _formeDart(Sentiero sentiero, List<FormaDellElemento> forme) {
  final b = StringBuffer();
  b.writeln('    Sentiero.${sentiero.name}: [');
  for (final f in forme) {
    b.writeln('      FormaDellElemento(eRipiego: ${f.eRipiego}, '
        'area: ${f.area}, strisce: [${f.strisce.join(",")}]),');
  }
  b.writeln('    ],');
  return b.toString();
}

void _scriviLeForme(List<String> righe) {
  final b = StringBuffer()
    ..writeln('library;')
    ..writeln()
    ..writeln("import 'forma_dell_elemento.dart';")
    ..writeln("import 'sentieri.dart';")
    ..writeln()
    ..writeln('/// LE FORME DEI CINQUANTACINQUE ELEMENTI. Ordine T voce 02.')
    ..writeln('///')
    ..writeln('/// **QUESTO FILE NON SI SCRIVE A MANO.** Lo produce')
    ..writeln('/// `tool/ancoraggi_dai_sentieri.dart` crescendo ogni forma dal')
    ..writeln('/// suo seme sulla MATERIA dell\'elemento, e una prova rifa\' la')
    ..writeln('/// crescita a ogni giro e confronta.')
    ..writeln('///')
    ..writeln('/// **Le strisce sono in pixel dell\'arte**, a terne: riga,')
    ..writeln('/// primo x, ultimo x. Chi disegna le riscala alla tela vera.')
    ..writeln('///')
    ..writeln('/// `eRipiego` vero vuol dire che la crescita non si è chiusa e')
    ..writeln('/// al suo posto c\'è il bagliore tondo attorno al seme. **Non')
    ..writeln('/// si inventa una forma: si dichiara.**')
    ..writeln('class FormeDeiSentieri {')
    ..writeln('  const FormeDeiSentieri._();')
    ..writeln()
    ..writeln('  static const Map<Sentiero, List<FormaDellElemento>> tutte = {')
    ..write(righe.join())
    ..writeln('  };')
    ..writeln()
    ..writeln('  static List<FormaDellElemento>? di(Sentiero sentiero) =>')
    ..writeln('      tutte[sentiero];')
    ..writeln('}');
  File('lib/core/sigilli/forme_dei_sentieri.dart')
      .writeAsStringSync(b.toString());
  // ignore: avoid_print
  print('scritto lib/core/sigilli/forme_dei_sentieri.dart');
}
