import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart';
import 'package:esoteric_circle/core/astro/natal_chart_controller.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/services/free_astro_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Il client della carta natale ora passa dalla callable Firebase: la chiave e'
/// lato server. Qui la callable e' simulata (nessuna rete, nessun Firebase): si
/// verifica il successo col parsing, l'errore col ripiego essenziale, e che
/// nessuna chiave resti nel codice.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final details = BirthDetails(
    date: DateTime(1990, 6, 15),
    time: const TimeOfDay(hour: 2, minute: 30),
    place: const BirthPlace(
      label: 'Roma',
      latitude: 41.9,
      longitude: 12.5,
      timezone: 'Europe/Rome',
    ),
    gender: Gender.female,
  );

  Map<String, dynamic> loadFixture() {
    final raw =
        File('assets/data/sample_natal_rome.json').readAsStringSync();
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  group('FreeAstroClient sulla callable simulata', () {
    test('successo: interpreta il JSON della callable nella carta', () async {
      Map<String, Object?>? sent;
      final client = FreeAstroClient(caller: (data) async {
        sent = data;
        return loadFixture();
      });

      final chart = await client.fetchNatalChart(details);

      // Il payload dei dati di nascita e' quello atteso dal motore.
      expect(sent, isNotNull);
      expect(sent!['year'], 1990);
      expect(sent!['lat'], 41.9);
      expect(sent!['tz_str'], 'Europe/Rome');
      // Il parsing resta quello di prima: pianeti e segno solare presenti.
      expect(chart.planets, isNotEmpty);
      expect(chart.sunSign, isNotNull);
      expect(chart.hasTime, isTrue);
    });

    test('errore della callable: solleva AstroApiException', () async {
      final client = FreeAstroClient(
          caller: (_) async => throw Exception('callable giu'));
      expect(
        () => client.fetchNatalChart(details),
        throwsA(isA<AstroApiException>()),
      );
    });

    test('risposta illeggibile: solleva AstroApiException', () async {
      final client = FreeAstroClient(caller: (_) async => 'non una mappa');
      expect(
        () => client.fetchNatalChart(details),
        throwsA(isA<AstroApiException>()),
      );
    });
  });

  group('Ripiego sul cielo essenziale', () {
    test('se la callable fallisce, il controller ripiega senza bloccare',
        () async {
      final controller = NatalChartController(
        client: FreeAstroClient(
            caller: (_) async => throw Exception('rete assente')),
      );

      await controller.compute(details);

      expect(controller.status, ChartStatus.ready);
      expect(controller.chart, isNotNull);
      // Cielo essenziale: il Sole reale dalla data, senza pianeti dall'API.
      expect(controller.chart!.sunSign, Zodiac.fromDate(details.date));
      expect(controller.note, isNotNull);
    });

    test('con la callable buona, il controller ha la carta completa', () async {
      final controller = NatalChartController(
        client: FreeAstroClient(caller: (_) async => loadFixture()),
      );
      await controller.compute(details);
      expect(controller.status, ChartStatus.ready);
      expect(controller.chart!.planets, isNotEmpty);
      expect(controller.note, isNull); // nessun ripiego
    });
  });

  test('nessuna chiave API resta nel codice dell\'app', () {
    final dartFiles = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    for (final f in dartFiles) {
      final src = f.readAsStringSync();
      expect(src.contains('FREEASTRO_API_KEY'), isFalse,
          reason: 'La chiave non deve comparire in ${f.path}');
      expect(src.contains('x-api-key'), isFalse,
          reason: 'L\'header con la chiave non deve comparire in ${f.path}');
    }
  });
}
