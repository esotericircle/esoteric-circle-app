// LA SCRITTA DELL'INDICATORE CEDE IL POSTO AI NOMI DEI PIANETI. Ordine FH
// voce 14.1.
//
// Quando la scritta copre il nome di un pianeta, o la Luna, si sposta sopra
// o sotto l'ostacolo, dalla parte dove c'e' piu' posto, e non lo copre piu'.

import 'dart:ui';

import 'package:esoteric_circle/features/real_time_cosmo/la_scritta_che_cede.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const w = 160.0, h = 50.0, altezza = 797.0;

  test('senza ostacoli la scritta resta dov\'e\'', () {
    expect(
        altezzaCheCede(
            left: 100,
            top: 300,
            w: w,
            h: h,
            altezza: altezza,
            ostacoli: 1,
            ostacolo: (_) => null),
        300);
  });

  test('sul nome di un pianeta in alto si sposta sotto, e non lo copre', () {
    const nome = Rect.fromLTWH(120, 200, 60, 18);
    final top = altezzaCheCede(
        left: 100,
        top: 190,
        w: w,
        h: h,
        altezza: altezza,
        ostacoli: 1,
        ostacolo: (_) => nome);
    expect(Rect.fromLTWH(100, top, w, h).overlaps(nome), isFalse);
    expect(top, greaterThan(nome.bottom));
  });

  test('sul nome di un pianeta in basso si sposta sopra', () {
    const nome = Rect.fromLTWH(120, 600, 60, 18);
    final top = altezzaCheCede(
        left: 100,
        top: 590,
        w: w,
        h: h,
        altezza: altezza,
        ostacoli: 1,
        ostacolo: (_) => nome);
    expect(Rect.fromLTWH(100, top, w, h).overlaps(nome), isFalse);
    expect(top + h, lessThan(nome.top));
  });

  test('spostandosi su un secondo nome, cede anche a quello', () {
    const primo = Rect.fromLTWH(120, 300, 60, 18);
    const secondo = Rect.fromLTWH(110, 324, 60, 18);
    final top = altezzaCheCede(
        left: 100,
        top: 290,
        w: w,
        h: h,
        altezza: altezza,
        ostacoli: 2,
        ostacolo: (i) => i == 0 ? primo : secondo);
    final scritta = Rect.fromLTWH(100, top, w, h);
    expect(scritta.overlaps(primo), isFalse);
    expect(scritta.overlaps(secondo), isFalse);
  });
}
