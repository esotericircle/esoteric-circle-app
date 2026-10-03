// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/astro/il_cielo_detto.dart';
import 'package:esoteric_circle/core/maestro/consiglio_finale.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:flutter_test/flutter_test.dart';

/// **UNA FRASE SUL CIELO CHE IL CALCOLO SMENTISCE NON ARRIVA A SCHERMO.**
/// Ordine DS voce 08, 17 settembre 2026.
///
/// Sulle catture di un fondatore Medora diceva, in due risposte dello stesso
/// minuto, *"il Primo Quarto di Luna che si avvicina"* e *"Ripassa quando
/// sara' luna crescente"*. La seconda non era del modello: era la chiusa
/// composta dall'app, uguale per tutti e per tutto il giorno, e prometteva
/// per dopo una fase che era gia' in corso.
void main() {
  final notte = DateTime(2026, 9, 17, 0, 21);

  group('IL VERIFICATORE PRENDE CIO\' CHE IL FONDATORE HA VISTO', () {
    test('la chiusa del 17 settembre promette una fase gia in corso', () {
      final smentite = IlCieloDetto.smentite(
          'Ripassa quando sarà luna crescente: quel che vedi cambia con lei.',
          adesso: notte);
      expect(smentite, hasLength(1));
      print('ORDINE DS VOCE 08: ${smentite.single}');
    });

    test('un ingresso detto nel giorno sbagliato cade, quello giusto passa',
        () {
      // La Luna entra in Capricorno il 19 settembre verso le 8.
      expect(
          IlCieloDetto.smentite('Domani la Luna entra in Capricorno.',
              adesso: notte),
          hasLength(1));
      expect(
          IlCieloDetto.smentite('Fra 2 giorni la Luna entra in Capricorno.',
              adesso: notte),
          isEmpty);
    });

    test('una fase detta per adesso che adesso non e cade', () {
      expect(IlCieloDetto.smentite('Oggi la Luna è calante.', adesso: notte),
          hasLength(1));
      expect(IlCieloDetto.smentite('La Luna è crescente.', adesso: notte),
          isEmpty);
    });

    test('una fase principale detta col suo quando si controlla', () {
      // Il Primo quarto comincia il 18 alle 10.
      expect(
          IlCieloDetto.smentite('Il Primo quarto arriva domani.',
              adesso: notte),
          isEmpty);
      expect(
          IlCieloDetto.smentite('Il Primo quarto arriva fra 3 giorni.',
              adesso: notte),
          hasLength(1));
    });

    test('le due forme della chiusa nuova si leggono e si smentiscono', () {
      // Dal 17 settembre la Luna piena comincia il 26, fra nove giorni.
      expect(
          IlCieloDetto.smentite('Ripassa fra 5 giorni, per la Luna piena.',
              adesso: notte),
          hasLength(1));
      expect(
          IlCieloDetto.smentite('Ripassa fra 9 giorni, per la Luna piena.',
              adesso: notte),
          isEmpty);
      expect(
          IlCieloDetto.smentite(
              'Rivediamoci domani: la Luna entra in Capricorno.',
              adesso: notte),
          hasLength(1));
    });

    test('una frase senza nulla da controllare non si giudica', () {
      expect(
          IlCieloDetto.smentite(
              'Il cielo si vela di un\'ombra sottile. Saturno ti chiede pazienza.',
              adesso: notte),
          isEmpty);
    });

    test('senza le smentite il resto del testo resta com\'era', () {
      final pulito = IlCieloDetto.senzaLeSmentite(
          'La tua Luna ti chiede ascolto. Domani la Luna entra in Capricorno. '
          'Tieni il passo lento.',
          adesso: notte);
      expect(pulito, 'La tua Luna ti chiede ascolto. Tieni il passo lento.');
    });
  });

  test(
      'PER UN ANNO, due volte al giorno, la chiusa di Medora non dice mai un '
      'cielo che il calcolo smentisce, e dice sempre un cielo controllabile',
      () {
    var guardate = 0;
    final smentite = <String>[];
    final vaghe = <String>[];
    for (var g = 0; g < 366; g++) {
      for (final ora in const [0, 18]) {
        final quando = DateTime(2026, 1, 1 + g, ora, 21);
        final invito = ConsiglioFinale.invitoDelRitorno(Maestro.medora,
            quando: quando, identita: 'prova');
        guardate++;
        for (final s in IlCieloDetto.smentite(invito, adesso: quando)) {
          smentite.add('${quando.day}/${quando.month} ore $ora: $s');
        }
        final piano = invito.toLowerCase();
        final dice = (piano.contains('entra in') ||
                RegExp(r"per (la luna piena|la luna nuova|il primo quarto|"
                        r"l'ultimo quarto)")
                    .hasMatch(piano)) &&
            (piano.contains('domani') ||
                piano.contains('oggi') ||
                RegExp(r'fra \d+ giorni').hasMatch(piano));
        if (!dice) vaghe.add('${quando.day}/${quando.month}: "$invito"');
      }
    }
    print('ORDINE DS VOCE 08: chiuse di Medora guardate $guardate, smentite '
        '${smentite.length}, senza un cielo controllabile ${vaghe.length}');
    expect(guardate, 732);
    expect(smentite, isEmpty, reason: smentite.take(10).join('\n'));
    expect(vaghe, isEmpty, reason: vaghe.take(10).join('\n'));
  });
}
