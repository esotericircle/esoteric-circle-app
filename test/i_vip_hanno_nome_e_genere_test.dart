import 'dart:io';

import 'package:esoteric_circle/core/synastry/gemello_astrale.dart';
import 'package:esoteric_circle/core/synastry/vip_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

/// **I VIP HANNO IL LORO NOME E IL LORO GENERE.** Ordine ER voci 16 e 19, 27
/// settembre 2026.
///
/// ER.19: nella galleria si leggeva *"Beyonce"*; anche Kylian Mbappé e
/// Timothée Chalamet erano scritti senza il loro segno. Il nome fa da chiave
/// alle coppie salvate: si scrive giusto e si cerca per chiave.
///
/// ER.16: *"Il tuo gemello astrale è Margot Robbie, ma Snoop Dogg gli sta
/// addosso"*. Il catalogo non sapeva il genere dei suoi cinquanta.
void main() {
  const conIlSegno = {
    'Beyonce': 'Beyoncé',
    'Kylian Mbappe': 'Kylian Mbappé',
    'Timothee Chalamet': 'Timothée Chalamet',
  };
  const donne = {
    'Angelina Jolie',
    'Ariana Grande',
    'Beyoncé',
    'Billie Eilish',
    'Chiara Ferragni',
    'Emma Watson',
    'Kim Kardashian',
    'Kylie Jenner',
    'Lady Gaga',
    'Margot Robbie',
    'Michelle Obama',
    'Monica Bellucci',
    'Oprah Winfrey',
    'Priyanka Chopra',
    'Rihanna',
    'Scarlett Johansson',
    'Selena Gomez',
    'Serena Williams',
    'Shakira',
    'Taylor Swift',
    'Zendaya',
  };

  test('i nomi si scrivono col loro segno, anche nel corpus', () {
    final nomi = VipCatalog.vips.map((v) => v.name).toSet();
    final corpus = File('docs/corpus/vip.json').readAsStringSync();
    for (final e in conIlSegno.entries) {
      expect(nomi, contains(e.value), reason: 'manca "${e.value}"');
      expect(nomi, isNot(contains(e.key)),
          reason: '"${e.key}" e\' scritto senza il suo segno');
      expect(corpus, contains('"${e.value}"'),
          reason: 'il corpus del catalogo scrive ancora "${e.key}"');
    }
  });

  test('una coppia salvata col nome di prima si ritrova', () {
    for (final e in conIlSegno.entries) {
      expect(VipCatalog.conNome(e.key)?.name, e.value,
          reason: 'la coppia salvata con "${e.key}" non si ritrova piu\'');
    }
  });

  test('ogni VIP ha il suo genere, dichiarato', () {
    for (final v in VipCatalog.vips) {
      expect(v.femminile, donne.contains(v.name),
          reason: '${v.name}: il genere nel catalogo e\' sbagliato');
    }
  });

  test('la riga del distacco accorda il pronome col gemello, per tutti', () {
    final sbagliate = <String>[];
    for (final primo in VipCatalog.vips) {
      final secondo = VipCatalog.vips.firstWhere((v) => v.name != primo.name);
      final g = GemelloAstrale(
        vip: primo,
        punteggio: 72,
        secondo: secondo,
        punteggioDelSecondo: 71,
        terzo: secondo,
        punteggioDelTerzo: 60,
      );
      final atteso = primo.femminile ? ' le sta addosso' : ' gli sta addosso';
      if (!g.annuncio.contains(atteso)) sbagliate.add(g.annuncio);
    }
    expect(sbagliate, isEmpty,
        reason: 'frasi del distacco col pronome sbagliato:\n'
            '${sbagliate.join('\n')}');
  });
}
