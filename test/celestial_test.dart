import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart';
import 'package:esoteric_circle/core/astro/celestial.dart';
import 'package:esoteric_circle/core/astro/sky.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Motore astronomico', () {
    test('il giorno giuliano di J2000 e\' corretto', () {
      final jd = Celestial.julianDay(DateTime.utc(2000, 1, 1, 12, 0, 0));
      expect(jd, closeTo(2451545.0, 1e-6));
    });

    test('il tempo siderale resta nell\'intervallo [0, 360)', () {
      final jd = Celestial.julianDay(DateTime.utc(1990, 6, 15, 12, 30));
      final gmst = Celestial.gmstDegrees(jd);
      expect(gmst, greaterThanOrEqualTo(0));
      expect(gmst, lessThan(360));
    });

    test('una stella allo zenit ha altezza vicina a 90 gradi', () {
      // Angolo orario nullo e declinazione pari alla latitudine: e\' allo zenit.
      final jd = Celestial.julianDay(DateTime.utc(2000, 1, 1, 12));
      final lst = Celestial.localSiderealDegrees(jd, 0);
      final h = Celestial.equatorialToHorizontal(
          raDeg: lst, decDeg: 45, latDeg: 45, lstDeg: lst);
      expect(h.altDeg, closeTo(90, 0.5));
    });

    test('la frazione illuminata della Luna resta tra 0 e 1', () {
      final jd = Celestial.julianDay(DateTime.utc(1990, 6, 15, 22));
      final m = Celestial.moonIllumination(jd);
      expect(m.fraction, inInclusiveRange(0.0, 1.0));
    });
  });

  group('Istantanea del cielo', () {
    test('proietta le costellazioni e colloca la Luna', () {
      final catalog = SkyCatalog([
        const CatalogConstellation(
          name: 'Prova',
          stars: [
            [101.29, -16.72, -1.46],
            [95.67, -17.96, 2.0],
          ],
          lines: [
            [0, 1]
          ],
        ),
      ]);
      final details = BirthDetails(
        date: DateTime(1990, 6, 15),
        time: const TimeOfDay(hour: 22, minute: 0),
        place: const BirthPlace(
          label: 'Roma',
          latitude: 41.9,
          longitude: 12.5,
          timezone: 'Europe/Rome',
        ),
      );
      final snap = buildSkySnapshot(catalog, details);
      expect(snap.hasTime, isTrue);
      // La fase della Luna e\' sempre calcolata (la Luna puo\' essere sotto
      // l\'orizzonte a quell\'ora, e allora non si disegna).
      expect(snap.moonPhase.fraction, inInclusiveRange(0.0, 1.0));
      // L\'azimut di centratura e\' un valore valido.
      expect(snap.centerAzDeg, inInclusiveRange(0.0, 360.0));
    });

    test('senza ora usa la notte simbolica', () {
      final catalog = SkyCatalog([
        const CatalogConstellation(
          name: 'Prova',
          stars: [
            [101.29, -16.72, -1.46]
          ],
          lines: [],
        ),
      ]);
      final details = BirthDetails(
        date: DateTime(1990, 6, 15),
        place: const BirthPlace(
          label: 'Roma',
          latitude: 41.9,
          longitude: 12.5,
          timezone: 'Europe/Rome',
        ),
      );
      final snap = buildSkySnapshot(catalog, details);
      expect(snap.hasTime, isFalse);
    });
  });
}
