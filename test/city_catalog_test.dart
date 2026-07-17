import 'package:esoteric_circle/core/astro/city_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

/// La ricerca del luogo e' interamente offline: un elenco compilato di citta'
/// con coordinate e fuso. Quando una citta' manca, si sceglie la piu' vicina e
/// la si marca provvisoria. Nessuna chiamata di rete.
void main() {
  test('l\'elenco e\' compilato, con coordinate e fuso per ogni citta\'', () {
    expect(CityCatalog.cities, isNotEmpty);
    for (final c in CityCatalog.cities) {
      expect(c.name, isNotEmpty);
      expect(c.timeZoneId, isNotEmpty);
      expect(c.latitude, inInclusiveRange(-90, 90));
      expect(c.longitude, inInclusiveRange(-180, 180));
    }
  });

  group('Ricerca', () {
    test('trova per prefisso, la corrispondenza esatta per prima', () {
      final r = CityCatalog.search('Rom');
      expect(r, isNotEmpty);
      expect(r.first.name, 'Roma');
    });

    test('ignora maiuscole e accenti', () {
      final lower = CityCatalog.search('torino');
      expect(lower.first.name, 'Torino');
      // "Citta del Messico" si trova anche scritto senza accento.
      final noAccent = CityCatalog.search('citta del messico');
      expect(noAccent.any((c) => c.name == 'Città del Messico'), isTrue);
    });

    test('una query troppo corta non propone nulla', () {
      expect(CityCatalog.search('r'), isEmpty);
      expect(CityCatalog.search(''), isEmpty);
    });

    test('trova anche per paese', () {
      final r = CityCatalog.search('Giappone');
      expect(r.any((c) => c.name == 'Tokyo'), isTrue);
    });
  });

  group('Ripiego alla citta piu vicina', () {
    test('per un punto senza citta in elenco sceglie la piu vicina', () {
      // Un punto in Toscana, vicino a Firenze ma non una citta dell'elenco.
      final near = CityCatalog.nearest(43.6, 11.0);
      expect(near.name, 'Firenze');
    });

    test('il luogo dal ripiego si marca provvisorio', () {
      final near = CityCatalog.nearest(43.6, 11.0);
      final place = near.toPlace(approximate: true);
      expect(place.isApproximate, isTrue);
      expect(place.city, near.name);
      expect(place.timeZoneId, near.timeZoneId);
    });

    test('una scelta esatta non e provvisoria', () {
      final place = CityCatalog.cities
          .firstWhere((c) => c.name == 'Napoli')
          .toPlace();
      expect(place.isApproximate, isFalse);
    });
  });
}
