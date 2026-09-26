import 'package:esoteric_circle/core/astro/moon_phase.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/rituals/rito_alba.dart';
import 'package:flutter_test/flutter_test.dart';

/// COME SI DICE LA LUNA, E COME NON SI DICE.
///
/// **Le due rotture che questa prova tiene chiuse, viste a video e non nel
/// sorgente.** I riti del giorno compongono tredici frasi della forma
/// `La Luna e' {fase}.`, e al posto del segnaposto arrivava il NOME della fase.
/// Ne uscivano `La Luna è Luna calante`, che ripete la parola Luna, e
/// `La Luna è Ultimo quarto`, che a un quarto non mette la preposizione. La
/// seconda l'ha segnalata Mauro, la prima si legge nell'anteprima
/// `soffio-destino-dono.png`: sono la stessa rottura su fasi diverse, e per
/// questo la prova le enumera tutte e otto invece di provarne una.
///
/// E il respiro finiva con `(6 tempi, 3 giri)`, che ripete in cifre cio' che la
/// frase ha appena detto in parole.
void main() {
  /// Tutti i nomi che la nomenclatura della Luna sa produrre. Enumerati da
  /// li' e non riscritti a mano: se un giorno ne nasce un nono, questa prova
  /// lo prende invece di ignorarlo.
  final nomi = <String>{
    for (var i = 0; i <= 1000; i++) MoonPhase.nomeItaliano(i / 1000.0),
  };

  test('la nomenclatura produce otto nomi, e li conosco tutti', () {
    expect(nomi, hasLength(8),
        reason: 'le fasi sono $nomi: la prova qui sotto ne copre otto, e se '
            'ne sono nate altre non le sta guardando');
  });

  test('nessuna frase del rito dice "La Luna e Luna" ne salta la preposizione',
      () {
    final rotte = <String>[];
    for (final nome in nomi) {
      for (final m in Maestro.values) {
        // Trenta giorni per Maestro: il seme cambia la forma e la variante, e
        // una sola data proverebbe una frase su decine.
        for (var g = 1; g <= 30; g++) {
          final cielo = CieloDiStamattina(
            faseLunare: nome,
            segnoLunare: Zodiac.leo,
            oraDellAlba: DateTime(2026, 8, 6, 6, 12),
          );
          final rito = RitoAlba.componi(DateTime(2026, 8, g), m, cielo);
          if (rito == null) continue;
          for (final testo in [rito.gesto, rito.respiro]) {
            // LA FRASE COME LA LEGGE LA PERSONA, non la riga di sorgente.
            if (testo.contains('La Luna è Luna')) {
              rotte.add('[$nome] ripete la parola Luna: $testo');
            }
            for (final quarto in const ['Primo quarto', 'Ultimo quarto']) {
              if (testo.contains('La Luna è $quarto')) {
                rotte.add('[$nome] manca la preposizione: $testo');
              }
            }
            if (testo.contains('La Luna è Gibbosa')) {
              rotte.add('[$nome] maiuscola in mezzo alla frase: $testo');
            }
          }
        }
      }
    }
    expect(rotte, isEmpty,
        reason: 'queste frasi non sono italiano:\n${rotte.take(6).join('\n')}');
  });

  test('il respiro non ripete in cifre cio che ha detto in parole', () {
    final rotte = <String>[];
    for (final m in Maestro.values) {
      for (var g = 1; g <= 30; g++) {
        final cielo = CieloDiStamattina(
          faseLunare: 'Luna piena',
          segnoLunare: Zodiac.leo,
          oraDellAlba: DateTime(2026, 8, 6, 6, 12),
        );
        final rito = RitoAlba.componi(DateTime(2026, 8, g), m, cielo);
        if (rito == null) continue;
        // Sul FATTO: una coda fra parentesi che contiene una cifra, quale che
        // sia il numero e quale che sia la parola accanto.
        if (RegExp(r'\(\s*\d+\s+\w+').hasMatch(rito.respiro)) {
          rotte.add(rito.respiro);
        }
      }
    }
    expect(rotte, isEmpty,
        reason: 'il respiro ripete i numeri in cifre:\n'
            '${rotte.take(3).join('\n')}');
  });

  test('il predicato di ogni fase sta bene dopo il verbo', () {
    // Il modello puro, senza comporre niente: e' la porta sola dove la
    // nomenclatura diventa predicato.
    for (final nome in nomi) {
      final detto = MoonPhase.comeSiDice(nome);
      final frase = 'La Luna è $detto.';
      expect(detto, isNotEmpty, reason: 'la fase $nome non ha un predicato');
      expect(frase.contains('La Luna è Luna'), isFalse, reason: frase);
      expect(detto[0], detto[0].toLowerCase(),
          reason: 'il predicato di $nome comincia in maiuscola: "$frase"');
    }
    // E i due quarti prendono la preposizione, che e' il caso in cui il nome
    // da solo non funziona.
    expect(MoonPhase.comeSiDice('Primo quarto'), 'al primo quarto');
    expect(MoonPhase.comeSiDice('Ultimo quarto'), "all'ultimo quarto");
  });
}
