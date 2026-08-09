import 'dart:convert';
import 'dart:io';

import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/astro/birth_place.dart';
import 'package:esoteric_circle/services/free_astro_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// PLACIDUS SI CHIEDE, NON SI SPERA.
///
/// Ordine 2170, voce 4. Il sistema di case arrivava come default del
/// fornitore: il giorno che lo cambia, tutte le carte cambiano sotto i piedi
/// delle persone e nessuno se ne accorge, perche' nessun numero nel nostro
/// codice dice quale ci aspettiamo.
///
/// **LA CALLABLE OGGI NON ACCETTA IL PARAMETRO, ed e' stato verificato
/// chiamandola.** Con `house_system`, `houses_system_identifier` e
/// `houses_system` risponde 400 "Campi non ammessi": la validazione lato
/// server ricostruisce il corpo campo per campo, apposta, e un campo che non
/// conosce non passa.
///
/// Quindi si e' fatto quello che l'ordine prescrive in questo caso, e in piu'
/// si e' preparato il lato server:
///  - `functions/src/validate.ts` adesso ACCETTA `house_system`, facoltativo,
///    con "P" come valore quando manca;
///  - `functions/src/index.ts` CONTROLLA che la risposta porti il sistema
///    chiesto, e fallisce se non lo porta;
///  - l'app RIFIUTA una risposta con un sistema diverso da quello atteso, ed
///    e' quello che queste prove misurano.
///
/// **L'app non spedisce ancora il campo, e non e' una dimenticanza:** la
/// funzione in produzione e' ancora quella vecchia, che i campi sconosciuti li
/// respinge. Una versione dell'app che lo mandasse oggi verrebbe rifiutata a
/// ogni carta. Il campo si aggiunge al payload il giorno del deploy.
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
    (risposta['subject'] as Map<String, dynamic>)['settings']
        ['house_system'] = 'koch';

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
}
