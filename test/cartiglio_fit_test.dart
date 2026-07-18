import 'dart:io';

import 'package:esoteric_circle/design_system/components/vip_frame.dart';
import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Il testo dei cartigli VIP entra sempre su una riga, dentro la larghezza del
/// cartiglio, senza troncare, andare a capo o sbordare. Qui si verifica la scala
/// progressiva coi casi peggiori, misurando col font reale Cinzel.
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

  void expectFits(String text, double maxWidth, double maxHeight) {
    final fit = resolveCartiglioFit(
        text: text.toUpperCase(),
        base: base,
        maxWidth: maxWidth,
        maxHeight: maxHeight);
    final w = measuredWidth(text, fit);
    final h = measuredHeight(text, fit);
    // Entra in larghezza, una riga, con un filo di tolleranza sub-pixel.
    expect(w, lessThanOrEqualTo(maxWidth + 0.5),
        reason: '"$text" largo $w oltre $maxWidth (fit: fs ${fit.fontSize.toStringAsFixed(1)} ls ${fit.letterSpacing.toStringAsFixed(2)} ws ${fit.wordSpacing.toStringAsFixed(2)} xs ${fit.scaleX.toStringAsFixed(2)})');
    expect(h, lessThanOrEqualTo(maxHeight + 0.5),
        reason: '"$text" alto $h oltre $maxHeight');
    // I limiti della scala progressiva sono rispettati.
    expect(fit.scaleX, greaterThanOrEqualTo(0.80 - 1e-6));
    expect(fit.letterSpacing, greaterThanOrEqualTo(-1.0 - 1e-6));
    expect(fit.letterSpacing, lessThanOrEqualTo(1.0 + 1e-6));
  }

  // Dimensioni reali dei due cartigli a una larghezza di polo rappresentativa,
  // piu' stretta di quella a schermo, per stare dal lato conservativo.
  const frameWidth = 140.0;
  const frameHeight = frameWidth / VipFrame.aspect;
  final nomeW = (VipFrame.cartiglioNome.right - VipFrame.cartiglioNome.left) *
      frameWidth;
  final nomeH = (VipFrame.cartiglioNome.bottom - VipFrame.cartiglioNome.top) *
      frameHeight;
  final dataW = (VipFrame.cartiglioData.right - VipFrame.cartiglioData.left) *
      frameWidth;
  final dataH = (VipFrame.cartiglioData.bottom - VipFrame.cartiglioData.top) *
      frameHeight;

  group('Nomi nel cartiglio alto, sempre su una riga', () {
    for (final name in const [
      'ANGELINA JOLIE',
      'SCARLETT JOHANSSON',
      'TIMOTHEE CHALAMET',
      'TU',
    ]) {
      test('"$name" entra', () => expectFits(name, nomeW, nomeH));
    }
  });

  group('Date nel cartiglio basso, sempre su una riga', () {
    for (final date in const [
      '15 SETTEMBRE 1990',
      '30 SETTEMBRE 1964',
      '4 GIUGNO 1975',
    ]) {
      test('"$date" entra', () => expectFits(date, dataW, dataH));
    }
  });

  test('Un testo corto non viene compresso senza motivo', () {
    final fit = resolveCartiglioFit(
        text: 'TU', base: base, maxWidth: nomeW, maxHeight: nomeH);
    expect(fit.scaleX, 1.0);
    expect(fit.letterSpacing, 1.0);
    expect(fit.wordSpacing, 0.0);
  });
}
