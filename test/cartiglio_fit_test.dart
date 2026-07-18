import 'dart:io';

import 'package:esoteric_circle/design_system/components/vip_frame.dart';
import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Il testo dei cartigli VIP entra sempre su una riga, dentro la banda blu
/// piatta reale della cornice, senza toccare l'oro ai lati ne sopra e sotto,
/// senza troncare ne andare a capo. L'area consentita e' la banda misurata
/// dall'immagine (`VipFrame.flatBand*`), non un rettangolo largo indovinato.
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

  double measuredWidth(String t, CartiglioFit fit) {
    final tp = TextPainter(
      text: TextSpan(
        text: t.toUpperCase(),
        style: base.copyWith(
          fontSize: fit.fontSize,
          letterSpacing: fit.letterSpacing,
          wordSpacing: fit.wordSpacing,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return tp.width * fit.scaleX;
  }

  double measuredHeight(String t, CartiglioFit fit) {
    final tp = TextPainter(
      text: TextSpan(
        text: t.toUpperCase(),
        style: base.copyWith(fontSize: fit.fontSize),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return tp.height;
  }

  // Un polo rappresentativo, piu' stretto di quello a schermo, dal lato
  // conservativo. La cornice e' 2:3.
  const frameWidth = 140.0;
  const frameHeight = frameWidth / VipFrame.aspect;

  Rect pxOf(Rect n) => Rect.fromLTRB(
      n.left * frameWidth, n.top * frameHeight, n.right * frameWidth, n.bottom * frameHeight);

  // Il testo, centrato nel cartiglio, non deve mai uscire dalla banda blu piatta
  // (il confine dell'oro): ne ai lati ne sopra e sotto.
  void expectInsideBand(
      String text, Rect cartiglioN, Rect flatBandN) {
    final cart = pxOf(cartiglioN);
    final band = pxOf(flatBandN);

    // Il cartiglio del testo sta dentro la banda piatta, con margine.
    expect(cart.left, greaterThanOrEqualTo(band.left - 1e-6),
        reason: 'cartiglio sfora l\'oro a sinistra');
    expect(cart.right, lessThanOrEqualTo(band.right + 1e-6),
        reason: 'cartiglio sfora l\'oro a destra');
    expect(cart.top, greaterThanOrEqualTo(band.top - 1e-6),
        reason: 'cartiglio sfora l\'oro in alto');
    expect(cart.bottom, lessThanOrEqualTo(band.bottom + 1e-6),
        reason: 'cartiglio sfora l\'oro in basso');

    final fit = resolveCartiglioFit(
        text: text.toUpperCase(),
        base: base,
        maxWidth: cart.width,
        maxHeight: cart.height);
    final w = measuredWidth(text, fit);
    final h = measuredHeight(text, fit);

    // Il testo entra nel cartiglio, su una riga.
    expect(w, lessThanOrEqualTo(cart.width + 0.5),
        reason: '"$text" largo $w oltre ${cart.width} (fs ${fit.fontSize.toStringAsFixed(1)} ls ${fit.letterSpacing.toStringAsFixed(2)} ws ${fit.wordSpacing.toStringAsFixed(2)} xs ${fit.scaleX.toStringAsFixed(2)})');
    expect(h, lessThanOrEqualTo(cart.height + 0.5),
        reason: '"$text" alto $h oltre ${cart.height}');

    // Il testo centrato nel cartiglio resta dentro la banda blu, non sull'oro.
    final cx = cart.center.dx;
    expect(cx - w / 2, greaterThanOrEqualTo(band.left - 0.5),
        reason: '"$text" tocca l\'oro a sinistra');
    expect(cx + w / 2, lessThanOrEqualTo(band.right + 0.5),
        reason: '"$text" tocca l\'oro a destra');

    // I limiti della scala progressiva sono rispettati.
    expect(fit.scaleX, greaterThanOrEqualTo(0.80 - 1e-6));
    expect(fit.letterSpacing, greaterThanOrEqualTo(-1.0 - 1e-6));
    expect(fit.letterSpacing, lessThanOrEqualTo(1.0 + 1e-6));
  }

  group('Nomi nel cartiglio alto, dentro la banda blu', () {
    for (final name in const [
      'ANGELINA JOLIE',
      'SCARLETT JOHANSSON',
      'TIMOTHEE CHALAMET',
      'TU',
    ]) {
      test('"$name" resta sul blu', () {
        expectInsideBand(name, VipFrame.cartiglioNome, VipFrame.flatBandNome);
      });
    }
  });

  group('Date nel cartiglio basso, dentro la banda blu', () {
    for (final date in const [
      '15 SETTEMBRE 1990',
      '30 SETTEMBRE 1964',
      '4 GIUGNO 1975',
    ]) {
      test('"$date" resta sul blu', () {
        expectInsideBand(date, VipFrame.cartiglioData, VipFrame.flatBandData);
      });
    }
  });

  test('Un testo corto non viene compresso senza motivo', () {
    final cart = pxOf(VipFrame.cartiglioNome);
    final fit = resolveCartiglioFit(
        text: 'TU', base: base, maxWidth: cart.width, maxHeight: cart.height);
    expect(fit.scaleX, 1.0);
    expect(fit.letterSpacing, 1.0);
    expect(fit.wordSpacing, 0.0);
  });
}
