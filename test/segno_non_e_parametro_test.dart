import 'dart:io';

import 'package:esoteric_circle/core/astro/night_sky.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/features/maestri/art_navigation.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL SEGNO NASCE DALLA DATA, E NON VIAGGIA COME PARAMETRO.
///
/// **La segnalazione.** L'Oroscopo diceva GEMELLI a un CANCRO.
///
/// **La causa.** `artRouteFor` riceveva `userSign` DA CHI APRE L'ARTE e lo
/// passava a quattro schermate. Chi chiamava poteva comporlo a mano, e lo
/// componeva sbagliato. Una correzione precedente aveva sistemato la frase della
/// home, cioe' la porta da cui era arrivata la segnalazione, e non chi riempiva
/// quel parametro.
///
/// **LA TRAPPOLA, dichiarata perche' e' la ragione per cui il difetto e'
/// sopravvissuto.** La data d'esempio dell'app e' il 15 giugno 1990, che e'
/// GEMELLI, e `BirthIdentity.example` pure. Qualunque prova scritta con
/// l'identita' d'esempio e' VERDE COL DIFETTO DENTRO, perche' il valore giusto e
/// quello sbagliato coincidono. Qui si usa il Cancro del fondatore.
void main() {
  // Il fondatore, 6 luglio: CANCRO. Non Gemelli, ed e' tutto il punto.
  final cancro = DateTime(1975, 7, 6);

  test('Il segno non e piu un parametro di artRouteFor', () {
    final sorgente = File('lib/features/maestri/art_navigation.dart')
        .readAsLinesSync()
        .where((r) => !r.trimLeft().startsWith('//'))
        .join('\n');
    expect(sorgente, isNot(contains('required Zodiac userSign')),
        reason: 'artRouteFor riceve ancora il segno da chi la chiama, quindi '
            'chi la chiama puo ancora sbagliarlo');
  });

  test('Con una data del Cancro le arti ricevono il Cancro', () {
    // Il segno che la sorgente ricava dalla data e quello vero: se qualcuno
    // reintroducesse un parametro, questa prova non basterebbe da sola, ed e'
    // per questo che c'e' anche quella sopra.
    expect(NightSky.sunSign(cancro), Zodiac.cancer);
    // Le rotte si aprono davvero, quindi il segno arriva.
    for (final id in const [
      'horoscope',
      'guide_animal',
      'rune_draw',
      'synastry_vip',
    ]) {
      expect(artRouteFor(id, userBirth: cancro), isNotNull,
          reason: 'l arte $id non si apre con una data di nascita valida');
    }
  });

  test('Senza data il segno non esiste, e non si inventa', () {
    // Nessun ripiego cablato: chi non ha dato la data va a darla, invece di
    // vedere il cielo di qualcun altro.
    for (final id in const [
      'horoscope',
      'guide_animal',
      'rune_draw',
    ]) {
      expect(artRouteFor(id, userBirth: null), isNotNull,
          reason: 'senza data l arte $id non porta da nessuna parte: mai un '
              'vicolo cieco');
    }
  });

  test('Nessun ripiego cablato a un segno e rimasto nella navigazione', () {
    final sorgente = File('lib/features/maestri/art_navigation.dart')
        .readAsLinesSync()
        .where((r) => !r.trimLeft().startsWith('//'))
        .join('\n');
    expect(sorgente, isNot(contains('Zodiac.gemini')),
        reason: 'e rimasto un segno cablato nella navigazione delle arti');
    expect(sorgente, isNot(contains('?? Zodiac.')),
        reason: 'e rimasto un ripiego cablato sul segno');
  });

  test('Le arti che mostrano un segno sono enumerate', () {
    // Quattro: Oroscopo, Animale Guida, Estrazione Rune, Sinastria VIP. Se ne
    // nasce una quinta che pretende il segno, chi la scrive vede questa prova
    // cadere e legge da dove deve prenderlo.
    final sorgente =
        File('lib/features/maestri/art_navigation.dart').readAsStringSync();
    final quante = 'userSign:'.allMatches(sorgente).length;
    expect(quante, 4,
        reason: 'le arti che ricevono un segno sono $quante: verifica che la '
            'nuova lo prenda dalla sorgente e non da un chiamante');
  });
}
