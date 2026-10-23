// ignore_for_file: avoid_print
import 'dart:math' as math;

import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/tokens/color_tokens.dart';
import 'package:esoteric_circle/features/shell/barra_dell_identita.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **I CONTATORI DELLA BARRA SI LEGGONO SEMPRE.** Ordine EU voce 19, 1 ottobre
/// 2026, dall'Architetto sulle catture del fondatore: scorrendo l'Oroscopo il
/// nome grande del segno passava sotto la barra in alto e si sovrapponeva al
/// livello, a "ONLINE 1" e agli Eos.
///
/// Si misura il contrasto WCAG di ogni colore con cui la barra scrive i suoi
/// contatori (l'oro chiaro, il testo primario, la lucina verde) sul fondo
/// della barra nel caso peggiore: il velo della palette di ogni Maestro e
/// della neutra sopra il colore piu' chiaro che puo' scorrere sotto (il
/// bianco e l'oro piu' chiaro dell'app). Il minimo che si pretende e' 4,5 a 1.
void main() {
  double canale(double c) =>
      c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  double luce(Color c) =>
      0.2126 * canale(c.r) + 0.7152 * canale(c.g) + 0.0722 * canale(c.b);
  double contrasto(Color a, Color b) {
    final l1 = luce(a), l2 = luce(b);
    final alta = math.max(l1, l2), bassa = math.min(l1, l2);
    return (alta + 0.05) / (bassa + 0.05);
  }

  test(
      'i contatori della barra hanno almeno 4,5 di contrasto con qualunque '
      'cosa scorra sotto', () {
    final palette = [
      MaestroPalette.medora,
      MaestroPalette.aura,
      MaestroPalette.caligo,
      MaestroPalette.neutral,
    ];
    final testi = <String, Color>{
      'oro chiaro': ColorTokens.goldLight,
      'testo primario': ColorTokens.textPrimary,
      'lucina': ColorTokens.lucinaOnline,
    };
    final sotto = <String, Color>{
      'bianco': const Color(0xFFFFFFFF),
      'oro piu\' chiaro': ColorTokens.goldBright,
    };
    var peggiore = double.infinity;
    var coppie = 0;
    final sotto45 = <String>[];
    for (final p in palette) {
      for (final s in sotto.entries) {
        final fondo = Color.alphaBlend(
            p.deepest.withValues(alpha: BarraDellIdentita.velo), s.value);
        for (final t in testi.entries) {
          coppie++;
          final c = contrasto(t.value, fondo);
          if (c < peggiore) peggiore = c;
          if (c < 4.5) {
            sotto45.add('${t.key} su ${s.key}: ${c.toStringAsFixed(2)}');
          }
        }
      }
    }
    cardinaleMinimo(coppie, 24, cosa: 'coppie di colori misurate');
    print('ORDINE EU VOCE 19: velo della barra ${BarraDellIdentita.velo}, '
        'contrasto peggiore dei contatori ${peggiore.toStringAsFixed(2)} su '
        '$coppie coppie');
    expect(sotto45, isEmpty, reason: sotto45.join('\n'));
    // Il velo deve anche coprire: cio' che passa sotto si vede appena.
    expect(BarraDellIdentita.velo, greaterThanOrEqualTo(0.9),
        reason: 'il velo lascia vedere cio\' che scorre sotto la barra');
  });
}
