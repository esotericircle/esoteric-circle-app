// ignore_for_file: avoid_print
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/cerchio/le_icone_del_cerchio.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/cerchio/widgets/disegni_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **LE ICONE STANNO INTERE NEL TONDO, ordine EZ voce 01.**
///
/// Il fondatore il 4 ottobre 2026: "le immagini profilo proposte
/// all'interno del cerchio e tutte sono tagliate dalla cornice del cerchio,
/// vorrei che la figura o emblema si vedesse bene e non venga tagliato".
///
/// Due prove, perche' il difetto ha due strade per tornare.
/// - **La prima ENUMERA**: l'immagine di un'icona del profilo si legge in
///   un punto solo, `IconaTonda`. Un secondo punto che la disegna per conto
///   suo rifarebbe il ritaglio, e la prova cade col nome del file.
/// - **La seconda MISURA in pixel**: rende ciascuna delle 36 icone dentro il
///   tondo, a 112 punti come nel profilo e a 44 come nel tuo Cerchio, e
///   pretende che nella CORONA, cioe' dentro l'anello ma fuori dal quadrato
///   inscritto, non ci sia un pixel diverso dal fondo. Non conta widget:
///   guarda l'immagine resa.
void main() {
  test(
      'EZ.01: l\'immagine di un\'icona del profilo si legge solo nel '
      'componente comune', () {
    final fuori = <String>[];
    var chiamanti = 0;
    var fileCheChiamano = 0;
    for (final f in sorgentiDiLib()) {
      final percorso = f.path.replaceAll('\\', '/');
      if (percorso.endsWith('core/cerchio/le_icone_del_cerchio.dart')) {
        continue;
      }
      final testo = f.readAsStringSync();
      final chiama = RegExp(r'IconaTonda\(').allMatches(testo).length -
          (percorso.endsWith('widgets/disegni_del_cerchio.dart') ? 1 : 0);
      if (chiama > 0) {
        chiamanti += chiama;
        fileCheChiamano++;
      }
      if (!testo.contains('le_icone_del_cerchio.dart')) continue;
      final righe = f.readAsLinesSync();
      for (var i = 0; i < righe.length; i++) {
        final r = righe[i].trim();
        if (r.startsWith('//')) continue;
        // Il percorso dell'immagine di un'icona del profilo e' il getter
        // `asset` di IconaDelProfilo: chi lo legge sta per disegnarla.
        final leggeLAsset = RegExp(r'\.asset\b').hasMatch(r) &&
            !r.contains('Image.asset(') &&
            !r.contains('AssetImage(');
        final disegnaUnIcona = r.contains('IconaDelProfilo') &&
            (r.contains('Image.asset') || r.contains('AssetImage'));
        if (!leggeLAsset && !disegnaUnIcona) continue;
        final nelComponente =
            percorso.endsWith('widgets/disegni_del_cerchio.dart') &&
                r.startsWith('i.asset');
        if (!nelComponente) fuori.add('$percorso:${i + 1}: $r');
      }
    }
    cardinaleMinimo(chiamanti, 7,
        cosa: 'chiamate di IconaTonda',
        perche: 'Il 4 ottobre 2026 le icone del profilo si disegnano in sette '
            'punti di cinque file: senza chiamanti la prova non guarda '
            'niente.');
    print('EZ.01 IL PUNTO SOLO: chiamate di IconaTonda $chiamanti in '
        '$fileCheChiamano file, letture dell\'immagine fuori dal componente '
        '${fuori.length} $fuori');
    expect(fuori, isEmpty,
        reason: 'questi punti disegnano un\'icona del profilo per conto '
            'loro, fuori da IconaTonda: $fuori');
  });

  for (final lato in const [112.0, 44.0]) {
    testWidgets(
        'EZ.01: le 36 icone a $lato punti stanno nel quadrato '
        'inscritto', (tester) async {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(1200, 1600);
      addTearDown(tester.view.reset);
      final icone = [
        for (final f in FamigliaDelleIcone.values) ...IconaDelProfilo.di(f),
      ];
      // LAPIDE, ordine FA voce 01: erano 58 coi ventidue Arcani.
      cardinaleMinimo(icone.length, 36,
          cosa: 'icone del profilo',
          perche: 'I tre set sono 12, 12 e 12.');
      final fondo = MaestroPalette.neutral.deepest;
      const scala = 3.0;
      final cadute = <String>[];
      var guardati = 0;
      var maxNellaCorona = 0;
      for (final icona in icone) {
        final chiave = GlobalKey();
        await tester.pumpWidget(MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: fondo,
            body: Center(
              child: RepaintBoundary(
                key: chiave,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: IconaTonda(icona: icona.codice, lato: lato),
                ),
              ),
            ),
          ),
        ));
        await tester.runAsync(() async {
          await precacheImage(AssetImage(icona.asset), chiave.currentContext!);
        });
        await tester.pump();
        Uint8List? pixel;
        var largo = 0;
        await tester.runAsync(() async {
          final rb = chiave.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
          final img = await rb.toImage(pixelRatio: scala);
          largo = img.width;
          final dati = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
          pixel = dati!.buffer.asUint8List();
          img.dispose();
        });
        // Il centro del tondo e i suoi raggi, in pixel dell'immagine resa.
        final centro = (20 + lato / 2) * scala;
        final raggioUtile = (lato / 2 - IconaTonda.anelloDi(lato)) * scala - 2;
        final mezzoQuadrato = IconaTonda.quadratoInscritto(lato) / 2 * scala;
        var nellaCorona = 0;
        var soggettoNelQuadrato = 0;
        for (var y = 0; y < largo; y++) {
          for (var x = 0; x < largo; x++) {
            final dx = x + 0.5 - centro, dy = y + 0.5 - centro;
            final dentro = dx * dx + dy * dy <= raggioUtile * raggioUtile;
            if (!dentro) continue;
            final o = (y * largo + x) * 4;
            final diverso = (pixel![o] - fondo.r * 255).abs() > 10 ||
                (pixel![o + 1] - fondo.g * 255).abs() > 10 ||
                (pixel![o + 2] - fondo.b * 255).abs() > 10;
            final nelQuadrato =
                dx.abs() <= mezzoQuadrato + 1 && dy.abs() <= mezzoQuadrato + 1;
            if (nelQuadrato) {
              if (diverso) soggettoNelQuadrato++;
            } else if (diverso) {
              nellaCorona++;
            }
          }
        }
        guardati++;
        if (nellaCorona > maxNellaCorona) maxNellaCorona = nellaCorona;
        if (nellaCorona > 0) cadute.add('${icona.codice} ($nellaCorona px)');
        // Un'icona che non si e' disegnata lascerebbe la corona pulita per
        // niente: il soggetto nel quadrato deve esserci.
        expect(soggettoNelQuadrato, greaterThan(50),
            reason: '${icona.codice} non si e\' disegnata: la misura della '
                'corona non varrebbe niente');
      }
      print('EZ.01 LA CORONA a $lato punti: icone guardate $guardati, con '
          'pixel del soggetto nella corona ${cadute.length}, il massimo '
          '$maxNellaCorona; ${cadute.take(12).join(', ')}');
      expect(cadute, isEmpty,
          reason: 'queste icone escono dal quadrato inscritto e la cornice '
              'del tondo le taglia: $cadute');
    });
  }
}
