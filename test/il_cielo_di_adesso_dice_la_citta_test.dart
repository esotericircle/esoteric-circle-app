import 'dart:io';

import 'package:esoteric_circle/core/astro/city_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

/// **IL CIELO DI ADESSO DICE LA CITTA' PRIMA DELLE COORDINATE.**
/// Ordine FS, 13 ottobre 2026.
///
/// Il fondatore, sulla build 2308, vicino a Busto Arsizio: nel cielo di
/// adesso si leggeva solo "45.6736, 8.8348". La riga metteva gia' la citta'
/// prima delle coordinate, ma dal GPS il posto arriva senza nome e nessuno
/// glielo dava.
void main() {
  const cassano = City(
    name: 'Cassano Magnago',
    country: 'VA',
    latitude: 45.6747,
    longitude: 8.8237,
    timeZoneId: 'Europe/Rome',
    utcOffsetMinutes: 60,
  );
  const roma = City(
    name: 'Roma',
    country: 'RM',
    latitude: 41.9028,
    longitude: 12.4964,
    timeZoneId: 'Europe/Rome',
    utcOffsetMinutes: 60,
  );

  setUp(() => CityCatalog.adotta(const [roma, cassano]));

  test('il punto del fondatore prende il nome del comune piu vicino', () {
    expect(CityCatalog.vicina(45.6736, 8.8348)?.name, 'Cassano Magnago');
  });

  test('in mezzo al mare non si inventa una citta', () {
    expect(CityCatalog.vicina(40.0, 5.0), isNull,
        reason: 'oltre trenta chilometri il nome deve mancare, e una riga '
            'senza nome mostra le sole coordinate');
  });

  test('la schermata da\' il nome a ogni posto che arriva senza', () {
    final s = File('lib/features/real_time_cosmo/cielo_reale_screen.dart')
        .readAsStringSync();
    expect('unawaited(_daiIlNomeAlLuogo());'.allMatches(s).length,
        greaterThanOrEqualTo(3),
        reason: 'il luogo salvato, quello concesso e quello chiesto col '
            'pulsante devono passare tutti dal catalogo delle citta');
    expect(s, contains('CityCatalog.vicina('));
  });
}
