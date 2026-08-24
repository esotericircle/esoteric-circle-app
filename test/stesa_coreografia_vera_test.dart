import 'package:esoteric_circle/features/tarot/stesa_choreography.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA SCENA RACCONTA IL GESTO, ordine H voce 5: la coreografia approvata il 3
/// agosto 2026 si verifica sulla geometria pura, senza montare nulla.
void main() {
  const sede = Offset(200, 40);
  const mazzo = Offset(160, 90);

  test('Mischia: raccolta, mescola sul mazzo, ristesa', () {
    // Agli estremi la carta sta nella sua sede: il gesto parte e finisce
    // dal ventaglio.
    for (final t in [0.0, 1.0]) {
      final p = MischiaPose.of(
          sede: sede, mazzo: mazzo, index: 2, count: 9, t: t);
      expect(p.offset, sede);
    }
    // A fine raccolta ogni carta sta SUL mazzo: il ventaglio si e' ricomposto.
    for (var i = 0; i < 9; i++) {
      final p = MischiaPose.of(
          sede: sede, mazzo: mazzo, index: i, count: 9,
          t: MischiaPose.fineRaccolta - 0.001);
      expect((p.offset - mazzo).distance, lessThan(30),
          reason: 'carta $i lontana dal mazzo a fine raccolta');
    }
    // In piena mescola le carte restano ATTORNO al mazzo, non sul ventaglio.
    const mezzo = (MischiaPose.fineRaccolta + MischiaPose.fineMescola) / 2;
    for (var i = 0; i < 9; i++) {
      final p = MischiaPose.of(
          sede: sede, mazzo: mazzo, index: i, count: 9, t: mezzo);
      expect((p.offset - mazzo).distance, lessThan(60),
          reason: 'carta $i fuori dal mazzo durante la mescola');
    }
    // ROSSO ESEGUITO: azzerando la convergenza dell'atto uno (e restituendo la
    // sede), la prova e' caduta con "carta 0 lontana dal mazzo a fine
    // raccolta", distanza 64 contro i 30 chiesti.
  });

  test('Taglia: raccolta, meta che si scostano, ricomposizione, ristesa', () {
    for (final t in [0.0, 1.0]) {
      final p = TaglioPose.of(
          sede: sede, mazzo: mazzo, index: 2, count: 9, taglioA: 4, t: t);
      expect(p.offset, sede);
    }
    // In piena divisione le due meta' stanno da parti OPPOSTE del mazzo.
    final mezzo = (TaglioPose.fineRaccolta + TaglioPose.fineDivisione) / 2;
    final sotto = TaglioPose.of(
        sede: sede, mazzo: mazzo, index: 1, count: 9, taglioA: 4, t: mezzo);
    final sopra = TaglioPose.of(
        sede: sede, mazzo: mazzo, index: 7, count: 9, taglioA: 4, t: mezzo);
    expect(sotto.offset.dx, lessThan(mazzo.dx),
        reason: 'la meta bassa non si scosta a sinistra');
    expect(sopra.offset.dx, greaterThan(mazzo.dx),
        reason: 'la meta alta non si scosta a destra');
    // A fine ricomposizione tutte tornate sul mazzo.
    for (var i = 0; i < 9; i++) {
      final p = TaglioPose.of(
          sede: sede, mazzo: mazzo, index: i, count: 9, taglioA: 4,
          t: TaglioPose.fineRicomposizione - 0.001);
      expect((p.offset - mazzo).distance, lessThan(12),
          reason: 'carta $i non ricomposta');
    }
  });
}
