import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/sigilli/journal_dall_arte.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// LE ANTEPRIME DEI TRE JOURNAL. Ordine T voce 02.
///
/// **Sei immagini, due stati per sentiero**: a due traguardi accesi, che e'
/// quello che Mauro vede oggi, e a cinquantacinque. Alla larghezza vera del suo
/// telefono, 360 per 797, rigenerate insieme e alla stessa risoluzione.
///
/// Si lancia a mano:
///
///     flutter test tool/anteprime_dei_journal.dart
void main() {
  const larghezza = 360.0;
  const altezza = 797.0;

  /// **LA QUOTA DEL DISEGNO, decisa dall'Architetto il 15 agosto**: dal 58 al 73
  /// per cento dell'altezza utile, perche' la figura E' il Journal.
  const quota = 0.73;

  final arti = <Sentiero, ui.Image>{};

  setUpAll(() async {
    final font = FontLoader('Cinzel')
      ..addFont(File('assets/fonts/Cinzel-variable.ttf')
          .readAsBytes()
          .then((b) => ByteData.view(b.buffer)));
    await font.load();
    // **LE IMMAGINI SI APRONO QUI E NON DENTRO LA PROVA.** Dentro `testWidgets`
    // il tempo e' finto e `instantiateImageCodec` non completa mai: la prima
    // stesura ci ha girato dieci minuti e poi e' scaduta.
    for (final sentiero in Sentieri.tutti) {
      final codec = await ui.instantiateImageCodec(
          await File(ArteDelSentiero.file(sentiero)).readAsBytes());
      arti[sentiero] = (await codec.getNextFrame()).image;
    }
  });

  Future<void> scatta(
    WidgetTester tester,
    Sentiero sentiero,
    Set<String> accesi,
    String nome,
  ) async {
    final chiave = GlobalKey();
    await tester.pumpWidget(MediaQuery(
      data: const MediaQueryData(size: Size(larghezza, altezza)),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: MaestroScope(
          maestro: switch (sentiero) {
            Sentiero.costellazione => Maestro.medora,
            Sentiero.albero => Maestro.caligo,
            Sentiero.loto => Maestro.aura,
          },
          child: RepaintBoundary(
            key: chiave,
            child: Container(
              width: larghezza,
              height: altezza,
              color: const Color(0xFF0B0D1A),
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: larghezza - 32,
                height: altezza * quota,
                // **L'ARTE SI CARICA DA DISCO E NON DALL'ASSET.** In
                // `flutter test` il pacchetto degli asset non c'e': la suite di
                // questo progetto lo dice gia' a voce alta ogni giro, con
                // "precache non riuscito per AssetImage". Qui l'immagine si apre
                // col codec e si dipinge, cosi' l'anteprima mostra i due strati
                // veri invece di un rettangolo vuoto.
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(painter: _FondoDaDisco(arti[sentiero]!)),
                    LuciDelSentiero(sentiero: sentiero, accesi: accesi),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ));
    // Tre giri, perche' l'immagine dell'asset arriva in un secondo momento.
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    // **LA CATTURA STA DENTRO runAsync, ed e' la riga che toglieva il blocco.**
    // `toImage` e `toByteData` li completa il MOTORE sul tempo vero, mentre
    // dentro `testWidgets` il tempo e' finto: fuori da `runAsync` quella
    // promessa non viene mai osservata e la prova resta appesa fino al tetto,
    // **dopo che il file e' gia' stato scritto**.
    await tester.runAsync(() async {
      final scatola =
          chiave.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final immagine = await scatola.toImage(pixelRatio: 2.0);
      final png = await immagine.toByteData(format: ui.ImageByteFormat.png);
      final dove = File('docs/preview/$nome.png');
      dove.parent.createSync(recursive: true);
      dove.writeAsBytesSync(png!.buffer.asUint8List());
      // ignore: avoid_print
      print('anteprima: ${dove.path}');
    });
  }

  // **UN TEST PER IMMAGINE**, come nel corredo: sei prove da una cattura, non
  // un ciclo dentro una prova sola.
  for (final sentiero in Sentieri.tutti) {
    for (final stato in const ['due', 'cinquantacinque']) {
      testWidgets('journal ${sentiero.name} $stato', (tester) async {
        tester.view.physicalSize = const Size(larghezza * 2, altezza * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.reset);
        final ordinati = Sentieri.di(sentiero).toList()
          ..sort((a, b) => Sentieri.ordineNelCammino(a)
              .compareTo(Sentieri.ordineNelCammino(b)));
        final accesi = stato == 'due'
            ? ordinati.take(2).map((t) => t.id).toSet()
            : ordinati.map((t) => t.id).toSet();
        await scatta(tester, sentiero, accesi, 'journal_${sentiero.name}_$stato');
      });
    }
  }
}

/// Il fondo dipinto da un'immagine gia' aperta, per le anteprime.
class _FondoDaDisco extends CustomPainter {
  const _FondoDaDisco(this.arte);
  final ui.Image arte;

  @override
  void paint(Canvas tela, Size misura) {
    final scala = math.min(
        misura.width / arte.width, misura.height / arte.height);
    final w = arte.width * scala, h = arte.height * scala;
    tela.drawImageRect(
      arte,
      Rect.fromLTWH(0, 0, arte.width.toDouble(), arte.height.toDouble()),
      Rect.fromLTWH((misura.width - w) / 2, (misura.height - h) / 2, w, h),
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(covariant _FondoDaDisco vecchio) => vecchio.arte != arte;
}
