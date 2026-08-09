import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// QUALE SISTEMA DI CASE USIAMO, SCRITTO E SORVEGLIATO.
///
/// Ordine 2169, voce 6. Non era dichiarato da nessuna parte. Placidus, Koch e
/// Case Uguali danno cuspidi diverse per la stessa nascita: senza sapere quale
/// sia il nostro, un confronto con una fonte terza non e' nemmeno possibile,
/// perche' uno scarto di tre gradi puo' voler dire "abbiamo un difetto" oppure
/// "stiamo confrontando due cose diverse".
///
/// **Il dato non e' un'ipotesi**: la risposta del motore lo porta scritto, e
/// questa prova lo legge dalla risposta vera conservata nel repository.
///
/// **Noi non lo chiediamo.** Nella richiesta non c'e' nessun parametro di
/// sistema, quindi riceviamo il default del motore. Se il motore cambiasse
/// default, tutte le carte cambierebbero senza che nessuno tocchi una riga di
/// codice: questa prova non puo' impedirlo, ma la fixture che sorveglia dice
/// quale sistema era in vigore quando la carta e' stata calcolata, e la
/// dichiarazione nel codice smette di essere vera in silenzio.
void main() {
  const sistemaDichiarato = 'placidus';

  Map<String, dynamic> risposta() => jsonDecode(
          File('assets/data/sample_natal_rome.json').readAsStringSync())
      as Map<String, dynamic>;

  test('la risposta del motore dichiara Placidus', () {
    final subject = risposta()['subject'] as Map<String, dynamic>;
    final settings = subject['settings'] as Map<String, dynamic>;
    expect(settings['house_system'], sistemaDichiarato,
        reason: 'il motore restituisce un sistema di case diverso da quello '
            'dichiarato nel codice: le cuspidi che mostriamo non sono piu\' '
            'quelle che diciamo di mostrare');
    expect(settings['zodiac_type'], 'Tropical',
        reason: 'lo zodiaco non e\' piu\' tropicale: cambia il segno di ogni '
            'pianeta, non solo le case');
  });

  test('il codice dichiara lo stesso sistema che il motore restituisce', () {
    // Se qualcuno cambiasse la fixture senza aggiornare la nota accanto al
    // parsing, resterebbero due verita' diverse in due file diversi.
    final sorgente =
        File('lib/services/free_astro_client.dart').readAsStringSync();
    expect(sorgente.toLowerCase().contains(sistemaDichiarato), isTrue,
        reason: 'il sistema di case non e\' scritto accanto al parsing delle '
            'cuspidi: chi legge quel codice non ha modo di sapere che numeri '
            'sta interpretando');
  });

  test('le cuspidi hanno la FORMA di un sistema a quadranti, non uguali', () {
    // La conferma indipendente dalla dichiarazione: se un giorno il campo
    // sparisse dalla risposta, questa misura direbbe comunque che le case non
    // sono uguali.
    final case_ = (risposta()['houses'] as List)
        .cast<Map<String, dynamic>>()
        .map((h) => (h['abs_pos'] as num).toDouble())
        .toList();
    expect(case_.length, 12);

    double ampiezza(int i) {
      final d = case_[(i + 1) % 12] - case_[i];
      return d < 0 ? d + 360 : d;
    }

    final ampiezze = [for (var i = 0; i < 12; i++) ampiezza(i)];
    final minima = ampiezze.reduce((a, b) => a < b ? a : b);
    final massima = ampiezze.reduce((a, b) => a > b ? a : b);
    // ignore: avoid_print
    print('CASE: ampiezza minima ${minima.toStringAsFixed(1)} gradi, massima '
        '${massima.toStringAsFixed(1)}; somma '
        '${ampiezze.reduce((a, b) => a + b).toStringAsFixed(1)}');

    expect(massima - minima, greaterThan(1.0),
        reason: 'le dodici case sono tutte larghe uguali: allora il sistema e\' '
            'Case Uguali o Whole Sign, non Placidus come dichiarato');
    // Le opposte a 180 gradi esatti: e' vero in tutti i sistemi a quadranti e
    // falso in nessuno di quelli che ci interessano, quindi e' il controllo
    // che dice che la risposta non e' semplicemente sbagliata.
    for (var i = 0; i < 6; i++) {
      final opposta = (case_[i + 6] - case_[i] + 360) % 360;
      expect((opposta - 180).abs(), lessThan(0.01),
          reason: 'la casa ${i + 1} e la ${i + 7} non sono opposte: la '
              'risposta non e\' una carta a quadranti');
    }
  });

  test('la richiesta NON impone un sistema, e questo va saputo', () {
    // Il fatto scomodo, scritto invece che scoperto fra un anno: il sistema
    // che usiamo e' quello che il motore decide di usare.
    final funzione = File('functions/src/index.ts').readAsStringSync();
    expect(funzione.contains('house_system'), isFalse,
        reason: 'adesso la callable impone un sistema di case: se e\' una '
            'scelta voluta va scritta qui, perche\' questa prova esisteva per '
            'dichiarare il contrario');
  });
}
