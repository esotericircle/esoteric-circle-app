import 'dart:convert';

import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart';
import 'package:esoteric_circle/core/astro/natal_chart_controller.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/services/free_astro_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

BirthDetails _details({TimeOfDay? time}) => BirthDetails(
      date: DateTime(1990, 8, 10),
      time: time,
      place: const BirthPlace(
        label: 'Roma',
        latitude: 41.9,
        longitude: 12.5,
        timezoneOffsetHours: 1,
      ),
    );

const _okBody = {
  'planets': [
    {'name': 'Sun', 'fullDegree': 137.5, 'sign': 'Leo'},
    {'name': 'Moon', 'fullDegree': 200.0, 'sign': 'Libra'},
    {'name': 'Mars', 'fullDegree': 45.0}, // segno derivato dalla longitudine
    {'name': 'Ascendant', 'fullDegree': 10.0, 'sign': 'Aries'},
  ],
};

void main() {
  group('FreeAstroClient con API simulata', () {
    test('interpreta la risposta e invia la chiave nell\'header', () async {
      String? sentKey;
      final mock = MockClient((req) async {
        sentKey = req.headers['x-api-key'];
        return http.Response(jsonEncode(_okBody), 200);
      });
      final client = FreeAstroClient(httpClient: mock, apiKey: 'segreto-test');

      final chart = await client.fetchNatalChart(_details(
        time: const TimeOfDay(hour: 14, minute: 30),
      ));

      expect(sentKey, 'segreto-test');
      expect(chart.sunSign, Zodiac.leo);
      expect(chart.moonSign, Zodiac.libra);
      expect(chart.ascendant, Zodiac.aries);
      expect(chart.hasTime, isTrue);
      // Sole, Luna, Marte (l'Ascendente non e' un pianeta disegnato).
      expect(chart.planets.length, 3);
      final mars = chart.planets.firstWhere((p) => p.name == 'Marte');
      expect(mars.sign, Zodiac.taurus); // 45 gradi -> Toro
    });

    test('senza ora l\'Ascendente resta velato', () async {
      final mock = MockClient(
          (req) async => http.Response(jsonEncode(_okBody), 200));
      final client = FreeAstroClient(httpClient: mock, apiKey: 'k');

      final chart = await client.fetchNatalChart(_details());
      expect(chart.hasTime, isFalse);
      expect(chart.ascendant, isNull);
      expect(chart.isPartial, isTrue);
    });

    test('senza chiave solleva un\'eccezione', () async {
      final mock = MockClient((req) async => http.Response('{}', 200));
      final client = FreeAstroClient(httpClient: mock, apiKey: null);
      expect(
        () => client.fetchNatalChart(_details()),
        throwsA(isA<AstroApiException>()),
      );
    });

    test('errore HTTP solleva un\'eccezione', () async {
      final mock = MockClient((req) async => http.Response('errore', 500));
      final client = FreeAstroClient(httpClient: mock, apiKey: 'k');
      expect(
        () => client.fetchNatalChart(_details()),
        throwsA(isA<AstroApiException>()),
      );
    });
  });

  group('NatalChartController', () {
    test('con API valida costruisce la carta completa', () async {
      final mock = MockClient(
          (req) async => http.Response(jsonEncode(_okBody), 200));
      final ctrl = NatalChartController(
        client: FreeAstroClient(httpClient: mock, apiKey: 'k'),
      );

      await ctrl.compute(_details(time: const TimeOfDay(hour: 9, minute: 0)));
      expect(ctrl.status, ChartStatus.ready);
      expect(ctrl.chart!.isEssential, isFalse);
      expect(ctrl.chart!.sunSign, Zodiac.leo);
      expect(ctrl.note, isNull);
    });

    test('se l\'API fallisce ripiega sul cielo essenziale, senza errori', () async {
      final mock = MockClient((req) async => http.Response('ko', 500));
      final ctrl = NatalChartController(
        client: FreeAstroClient(httpClient: mock, apiKey: 'k'),
      );

      await ctrl.compute(_details());
      expect(ctrl.status, ChartStatus.ready);
      expect(ctrl.chart, isNotNull);
      expect(ctrl.chart!.isEssential, isTrue);
      // Il segno solare resta corretto (calcolo locale dalla data).
      expect(ctrl.chart!.sunSign, Zodiac.leo);
      expect(ctrl.note, isNotNull);
    });
  });
}
