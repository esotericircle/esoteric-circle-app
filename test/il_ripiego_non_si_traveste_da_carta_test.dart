import 'dart:io';

import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart';
import 'package:esoteric_circle/core/astro/natal_chart.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL RIPIEGO NON SI TRAVESTE DA CARTA.
///
/// Ordine 2169, voce 4. Quando il calcolo fallisce, `NatalChart.essential`
/// fabbrica un cielo col solo Sole. E' giusto che esista, ed e' giusto
/// mostrarlo: quello che non va bene e' che sia INDISTINGUIBILE da una carta
/// vera. Da `chart != null` in poi il ponte, l'Oroscopo e i riti credevano di
/// avere il cielo, e nessuno riprovava mai.
///
/// **Il ripiego non si toglie, si etichetta.** Chi ha bisogno del cielo vero
/// chiede `cartaCompleta`, che col ripiego torna nulla; chi ha bisogno del
/// solo segno continua a usare `sunSign`, che il ripiego ce l'ha giusto.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // `setBirth` conserva la carta appena nata: senza le preferenze finte la
  // scrittura fallisce a meta' prova e la caduta arriva su quella dopo.
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final dettagli = BirthDetails(
    date: DateTime(1975, 7, 6),
    time: const TimeOfDay(hour: 9, minute: 30),
    place: const BirthPlace(
      latitude: 41.9,
      longitude: 12.5,
      timezone: 'Europe/Rome',
      label: 'Roma',
    ),
  );

  NatalChart cartaVera() => const NatalChart(
        sunSign: Zodiac.cancer,
        moonSign: Zodiac.pisces,
        ascendant: Zodiac.leo,
        ascendantLongitude: 130.0,
        hasTime: true,
        planets: [
          PlanetPosition(
              id: 'sun',
              name: 'Sole',
              glyph: '☉',
              longitude: 104.0,
              sign: Zodiac.cancer),
          PlanetPosition(
              id: 'moon',
              name: 'Luna',
              glyph: '☾',
              longitude: 350.0,
              sign: Zodiac.pisces),
        ],
      );

  test('col ripiego in mano, la porta dice che il cielo vero NON c\'e\'', () {
    final porta = BirthIdentityController()
      ..setBirth(
          dettagli,
          NatalChart.essential(sunSign: Zodiac.cancer, hasTime: true));

    expect(porta.chart, isNotNull,
        reason: 'il ripiego resta una carta e si continua a mostrare: '
            'toglierlo lascerebbe la persona senza niente');
    expect(porta.cartaEssenziale, isTrue,
        reason: 'la porta non sa di avere in mano un ripiego');
    expect(porta.cartaCompleta, isNull,
        reason: 'IL RIPIEGO PASSA PER CIELO VERO. Chi chiede la carta '
            'completa per leggerci transiti, case e aspetti si ritrova un '
            'cielo con un astro solo e lo tratta come se fosse il suo.');
    expect(porta.sunSign, Zodiac.cancer,
        reason: 'il segno il ripiego ce l\'ha giusto, e va restituito: e\' '
            'l\'unica cosa che sa, ma quella la sa');
  });

  test('col cielo vero in mano, la porta lo consegna', () {
    final porta = BirthIdentityController()..setBirth(dettagli, cartaVera());
    expect(porta.cartaEssenziale, isFalse);
    expect(porta.cartaCompleta, isNotNull,
        reason: 'una carta vera viene rifiutata da chi ha bisogno del cielo');
    expect(porta.cartaCompleta!.planets.length, 2);
  });

  test('senza nessuna carta, nessuna delle due mente', () {
    final porta = BirthIdentityController()..setBirth(dettagli, null);
    expect(porta.cartaEssenziale, isFalse,
        reason: 'nessuna carta non e\' un ripiego: sono due stati diversi');
    expect(porta.cartaCompleta, isNull);
  });

  test('CHI HA BISOGNO DEL CIELO VERO passa dalla porta giusta', () {
    // **PROVA ENUMERANTE, non un elenco scritto a mano.** Si guardano tutti i
    // file che leggono la carta dalla porta di lettura, e si pretende che
    // ciascuno dichiari da che parte sta: o chiede `cartaCompleta`, perche'
    // gli servono transiti, case o aspetti, oppure si accontenta del segno e
    // lo DICE con un marcatore. Il giorno che qualcuno aggiunge un lettore e
    // non dichiara niente, questa prova cade.
    const marcatore = 'basta-il-segno';
    final colpe = <String>[];
    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final percorso = f.path.replaceAll('\\', '/');
      // La porta stessa e' esclusa: e' lei a definire le due letture.
      if (percorso.endsWith('core/identity/natal_identity.dart')) continue;
      final testo = f.readAsStringSync();
      final righe = testo.split('\n').map((r) => r.replaceAll('\r', ''));
      for (final r in righe) {
        final nuda = r.trim();
        if (nuda.startsWith('//') || nuda.startsWith('///')) continue;
        // Solo le letture dalla PORTA, non quelle dal motore, che e' un altro
        // oggetto con un'altra vita.
        if (!nuda.contains('BirthIdentityController>()')) continue;
        if (!nuda.contains('.chart')) continue;
        if (nuda.contains('cartaCompleta') || nuda.contains('cartaEssenziale')) {
          continue;
        }
        if (testo.contains(marcatore)) continue;
        colpe.add('$percorso: legge .chart dalla porta senza dire se le basta '
            'il segno; se le serve il cielo vero deve chiedere cartaCompleta, '
            'altrimenti dichiari "$marcatore"');
      }
    }
    expect(colpe, isEmpty, reason: colpe.join('\n'));
  });

  test('il ripiego resta etichettato anche dopo un giro dal disco', () {
    // Il travestimento tornerebbe identico se l'etichetta si perdesse nella
    // conservazione: la carta riletta all'avvio sembrerebbe vera.
    final ripiego =
        NatalChart.essential(sunSign: Zodiac.cancer, hasTime: true);
    expect(ripiego.isEssential, isTrue,
        reason: 'il cielo essenziale nasce senza etichetta: da qui in poi '
            'nessuno puo\' piu\' distinguerlo da una carta vera');
  });
}
