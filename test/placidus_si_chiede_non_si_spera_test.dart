import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart';
import 'package:esoteric_circle/services/free_astro_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// PLACIDUS SI CHIEDE, E LA SEQUENZA E' COMPLETA.
///
/// Ordine 2170 voce 4, chiuso dall'ordine 2171 voce 3. Il sistema di case
/// arrivava come default del fornitore: il giorno che lo cambia, tutte le
/// carte cambiano sotto i piedi delle persone e nessuno se ne accorge.
///
/// **LA SEQUENZA, eseguita in quest'ordine il 10 agosto 2026:**
///  1. la funzione con la validazione nuova e' stata DEPLOYATA in produzione
///     (`firebase deploy --only functions:natalChart`, aggiornamento riuscito
///     su `natalChart(europe-west1)`);
///  2. il deploy e' stato VERIFICATO chiamando la callable vera: senza il
///     campo risponde `placidus`, con `house_system: P` risponde `placidus`,
///     con una sigla ignota risponde 400 "Il sistema di case Z non e' fra
///     quelli noti";
///  3. solo allora l'app ha cominciato a SPEDIRE il campo, e una carta vera
///     chiesta al motore con quel payload ha risposto
///     `subject.settings.house_system = placidus`.
///
/// L'ordine dei tre passi non era un dettaglio: la funzione precedente
/// rifiutava i campi che non conosceva, quindi un'app che avesse spedito il
/// campo prima del deploy sarebbe stata respinta a ogni carta.
void main() {
  Map<String, dynamic> rispostaDiRoma() =>
      jsonDecode(File('assets/data/sample_natal_rome.json').readAsStringSync())
          as Map<String, dynamic>;

  final dettagli = BirthDetails(
    date: DateTime(1990, 6, 15),
    time: const TimeOfDay(hour: 12, minute: 30),
    place: const BirthPlace(
      latitude: 41.9028,
      longitude: 12.4964,
      timezone: 'UTC',
      label: 'Roma',
    ),
  );

  test('il sistema atteso e\' dichiarato, e non e\' una stringa sparsa', () {
    expect(sistemaDiCaseAtteso, 'placidus',
        reason: 'il sistema di case atteso non e\' piu\' Placidus: se e\' una '
            'scelta voluta vanno rifatti tutti i riferimenti delle cuspidi in '
            'carta_natale_contro_fonte_terza_test');
  });

  test('una risposta Placidus passa', () {
    final carta = FreeAstroClient().parseResponse(rispostaDiRoma(), dettagli);
    expect(carta.houses, hasLength(12));
  });

  test('una risposta con un ALTRO sistema viene rifiutata', () {
    // **E' il presidio vero.** Prima questa risposta sarebbe stata
    // interpretata senza un lamento, e la persona avrebbe visto dodici
    // cuspidi diverse da quelle che le abbiamo sempre mostrato.
    final risposta = rispostaDiRoma();
    (risposta['subject'] as Map<String, dynamic>)['settings']['house_system'] =
        'koch';

    expect(
      () => FreeAstroClient().parseResponse(risposta, dettagli),
      throwsA(isA<AstroApiException>()),
      reason: 'una carta calcolata con Koch passa per una carta Placidus: le '
          'cuspidi sono altre, e nessuno lo dice',
    );
  });

  test('una risposta senza il campo passa, e si dichiara perche\'', () {
    // Le risposte vecchie, gia' conservate su un telefono, possono non
    // portare il campo: rifiutarle vorrebbe dire togliere la carta a chi ce
    // l'ha gia'. Si accettano, ed e' una scelta scritta, non una svista.
    final risposta = rispostaDiRoma();
    (risposta['subject'] as Map<String, dynamic>)['settings']
        .remove('house_system');
    final carta = FreeAstroClient().parseResponse(risposta, dettagli);
    expect(carta.houses, hasLength(12));
  });

  test('il lato server e\' pronto ad accettare il sistema di case', () {
    // Il deploy non e' in questo ordine, ma il codice che lo rendera' vero
    // c'e', e questa prova impedisce che venga tolto per distrazione.
    final validate = File('functions/src/validate.ts').readAsStringSync();
    expect(validate.contains('house_system'), isTrue,
        reason: 'la validazione lato server non conosce piu\' il sistema di '
            'case: senza, la callable continuera\' a rifiutare il campo e '
            'l\'app non potra\' mai chiederlo');
    final index = File('functions/src/index.ts').readAsStringSync();
    expect(index.contains('sistema di case inatteso'), isTrue,
        reason: 'la funzione non controlla piu\' il sistema di case della '
            'risposta: torna a valere il default del fornitore, in silenzio');
  });

  test('l\'app SPEDISCE il sistema di case, e chiede quello che controlla', () {
    // **I DUE LATI DEVONO PARLARE DELLA STESSA COSA.** Chiedere Placidus e
    // controllare Koch sarebbe peggio che non chiedere niente: la richiesta
    // direbbe una cosa e il presidio un'altra, e nessuno se ne accorgerebbe
    // finche' le carte non fossero gia' sbagliate.
    final client =
        File('lib/services/free_astro_client.dart').readAsStringSync();
    expect(
        client.contains("'house_system': sigla(sistemaDiCaseAtteso)"), isTrue,
        reason: 'l\'app non spedisce piu\' il sistema di case nel payload: si '
            'torna al default del fornitore, che era il difetto da chiudere');
    expect(sigla(sistemaDiCaseAtteso), 'P',
        reason: 'la sigla spedita non corrisponde al sistema atteso: si '
            'chiede una cosa e se ne controlla un\'altra');
  });
}
