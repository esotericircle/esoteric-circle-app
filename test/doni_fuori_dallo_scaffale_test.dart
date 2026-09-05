import 'package:esoteric_circle/core/santuario/function_shelf.dart';
import 'package:flutter_test/flutter_test.dart';

/// I Doni del giorno vivono nella striscia in cima, non nell'elenco sotto.
///
/// L'Oracolo del Giorno e la Runa del Tramonto stavano in due posti: nella
/// striscia del giorno, che e' la loro casa, e di nuovo nell'elenco delle
/// funzioni sotto l'eroe. La stessa cosa due volte nella stessa schermata fa
/// sembrare l'elenco piu' pieno di quello che e', e sottrae posto alle arti che
/// invece hanno solo quella strada.
void main() {
  /// Gli identificativi che corrispondono a un Dono del giorno, cioe' a un
  /// elemento della striscia in cima.
  const doni = ['day_oracle', 'sunset_rune'];

  test('Nessun Dono compare nell\'elenco delle funzioni', () {
    final presenti =
        FunctionShelf.functions.map((f) => f.id).where(doni.contains).toList();
    expect(presenti, isEmpty,
        reason:
            'questi Doni stanno anche nell\'elenco sotto, mentre sono gia\' '
            'nella striscia del giorno: $presenti');
  });

  test('Lo scaffale resta abitato', () {
    // Togliere non deve svuotare: se restasse un elenco magro, avremmo
    // scambiato un doppione con un buco.
    expect(FunctionShelf.functions.length, greaterThanOrEqualTo(6));
    expect(FunctionShelf.functions.where((f) => f.live).length,
        greaterThanOrEqualTo(6),
        reason: 'l\'elenco sotto e\' rimasto con troppe poche voci vive');
  });

  test('Ogni Maestro resta rappresentato nell\'elenco', () {
    final maestri = FunctionShelf.functions.map((f) => f.maestro).toSet();
    expect(maestri.length, 3,
        reason: 'togliendo i Doni un Maestro e\' scomparso dall\'elenco');
  });
}
