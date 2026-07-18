import 'dart:io';

import 'package:esoteric_circle/design_system/components/vip_frame.dart';
import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Il testo dei cartigli VIP entra sempre su una riga, dentro la banda blu
/// piatta reale della cornice, senza toccare l'oro. Sul cartiglio del nome il
/// divario fra due parole resta sempre percepibile: non collassa mai, cosi'
/// "ANGELINA JOLIE" non diventa "ANGELINAJOLIE".
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Font reale, cosi' le misure coincidono con quelle a video.
    final loader = FontLoader('Cinzel');
    final bytes = File('assets/fonts/Cinzel-variable.ttf').readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
    await loader.load();
  });

  final base = TypographyTokens.display(size: 40)
      .copyWith(letterSpacing: 1.0, color: const Color(0xFFFFFFFF));

  double rawWidth(String t, double fs, double ls, double ws) {
    final tp = TextPainter(
      text: TextSpan(
        text: t.toUpperCase(),
        style: base.copyWith(fontSize: fs, letterSpacing: ls, wordSpacing: ws),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return tp.width;
  }

  double textHeight(String t, double fs) {
    final tp = TextPainter(
      text: TextSpan(text: t.toUpperCase(), style: base.copyWith(fontSize: fs)),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return tp.height;
  }

  // Divario reso fra due parole (avanzamento medio per spazio), col fit dato.
  double perSpaceGap(String t, CartiglioFit fit) {
    final spaces = ' '.allMatches(t).length;
    if (spaces == 0) return 0;
    final withSpaces =
        rawWidth(t, fit.fontSize, fit.letterSpacing, fit.wordSpacing);
    final noSpaces = rawWidth(
        t.replaceAll(' ', ''), fit.fontSize, fit.letterSpacing, fit.wordSpacing);
    return (withSpaces - noSpaces) / spaces;
  }

  // Divario naturale fra due parole, senza compressione (letter e word a zero).
  double naturalGap(String t, double fs) {
    final spaces = ' '.allMatches(t).length;
    if (spaces == 0) return 0;
    return (rawWidth(t, fs, 0, 0) - rawWidth(t.replaceAll(' ', ''), fs, 0, 0)) /
        spaces;
  }

  // Un polo rappresentativo, piu' stretto di quello a schermo, dal lato
  // conservativo. La cornice e' 2:3.
  const frameWidth = 140.0;
  const frameHeight = frameWidth / VipFrame.aspect;
  Rect pxOf(Rect n) => Rect.fromLTRB(n.left * frameWidth, n.top * frameHeight,
      n.right * frameWidth, n.bottom * frameHeight);

  void expectInsideBand(
    String text,
    Rect cartiglioN,
    Rect flatBandN, {
    required bool preserveWordGap,
  }) {
    final cart = pxOf(cartiglioN);
    final band = pxOf(flatBandN);

    // Il cartiglio del testo sta dentro la banda piatta reale (confine dell'oro).
    expect(cart.left, greaterThanOrEqualTo(band.left - 1e-6));
    expect(cart.right, lessThanOrEqualTo(band.right + 1e-6));
    expect(cart.top, greaterThanOrEqualTo(band.top - 1e-6));
    expect(cart.bottom, lessThanOrEqualTo(band.bottom + 1e-6));

    final fit = resolveCartiglioFit(
        text: text.toUpperCase(),
        base: base,
        maxWidth: cart.width,
        maxHeight: cart.height,
        preserveWordGap: preserveWordGap);
    final w = rawWidth(text, fit.fontSize, fit.letterSpacing, fit.wordSpacing) *
        fit.scaleX;
    final h = textHeight(text, fit.fontSize);

    // Entra su una riga, in larghezza e in altezza.
    expect(w, lessThanOrEqualTo(cart.width + 0.5),
        reason:
            '"$text" largo $w oltre ${cart.width} (fs ${fit.fontSize.toStringAsFixed(1)} ls ${fit.letterSpacing.toStringAsFixed(2)} ws ${fit.wordSpacing.toStringAsFixed(2)} xs ${fit.scaleX.toStringAsFixed(2)})');
    expect(h, lessThanOrEqualTo(cart.height + 0.5));

    // Il testo centrato resta dentro la banda blu, non sull'oro.
    final cx = cart.center.dx;
    expect(cx - w / 2, greaterThanOrEqualTo(band.left - 0.5),
        reason: '"$text" tocca l\'oro a sinistra');
    expect(cx + w / 2, lessThanOrEqualTo(band.right + 0.5),
        reason: '"$text" tocca l\'oro a destra');

    // Limiti della scala progressiva.
    expect(fit.scaleX, greaterThanOrEqualTo(0.80 - 1e-6));
    expect(fit.letterSpacing, greaterThanOrEqualTo(-1.0 - 1e-6));
    expect(fit.letterSpacing, lessThanOrEqualTo(1.0 + 1e-6));
  }

  group('Nomi nel cartiglio alto, gap fra parole sempre percepibile', () {
    const names = [
      'ANGELINA JOLIE',
      'SCARLETT JOHANSSON',
      'TIMOTHEE CHALAMET',
      'MICHELLE OBAMA',
      'GIORGIO ARMANI',
      'MONICA BELLUCCI',
      'VALENTINO ROSSI',
      // Il cartiglio del polo utente: default e un nome lungo di prova.
      'TU',
      'MASSIMILIANO PROSPERI',
    ];
    for (final name in names) {
      test('"$name" entra e non tocca l\'oro', () {
        expectInsideBand(name, VipFrame.cartiglioNome, VipFrame.flatBandNome,
            preserveWordGap: true);
      });

      if (name.contains(' ')) {
        test('"$name" tiene il divario fra parole', () {
          final cart = pxOf(VipFrame.cartiglioNome);
          final fit = resolveCartiglioFit(
              text: name,
              base: base,
              maxWidth: cart.width,
              maxHeight: cart.height,
              preserveWordGap: true);
          // Invariante 1: lo spazio tra le parole non scende mai sotto il
          // pavimento (per i nomi, zero: non si sottrae mai spazio).
          expect(fit.wordSpacing,
              greaterThanOrEqualTo(fit.wordSpacingFloor - 1e-6),
              reason: 'word-spacing sotto il pavimento per "$name"');
          // Invariante 2: il divario reso resta pieno, non collassa (almeno il
          // 90 per cento del divario naturale), le parole non si attaccano.
          final gap = perSpaceGap(name, fit);
          final natural = naturalGap(name, fit.fontSize);
          expect(gap, greaterThanOrEqualTo(0.90 * natural),
              reason:
                  '"$name" ha il divario fra parole collassato: reso $gap contro naturale $natural');
        });
      }
    }
  });

  group('Date nel cartiglio basso, dentro la banda blu', () {
    for (final date in const [
      '15 SETTEMBRE 1990',
      '30 SETTEMBRE 1964',
      '4 GIUGNO 1975',
    ]) {
      test('"$date" resta sul blu', () {
        expectInsideBand(date, VipFrame.cartiglioData, VipFrame.flatBandData,
            preserveWordGap: false);
      });
    }
  });

  test('Un testo corto non viene compresso senza motivo', () {
    final cart = pxOf(VipFrame.cartiglioNome);
    final fit = resolveCartiglioFit(
        text: 'TU',
        base: base,
        maxWidth: cart.width,
        maxHeight: cart.height,
        preserveWordGap: true);
    expect(fit.scaleX, 1.0);
    expect(fit.letterSpacing, 1.0);
    expect(fit.wordSpacing, 0.0);
  });
}
