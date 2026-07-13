import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/services/ai/maestro_oracle.dart';
import 'package:flutter_test/flutter_test.dart';

/// L'oracolo locale in ripiego di "Chiedi ai Maestri": una lente per Maestro,
/// la sintesi comparativa quando sono piu' di uno, tutto deterministico.
void main() {
  const oracle = MaestroOracle();

  test('Un solo Maestro: una lente, nessuna sintesi', () {
    final r = oracle.consult(theme: 'il lavoro', maestri: [Maestro.aura]);
    expect(r.lenses.length, 1);
    expect(r.lenses.single.maestro, Maestro.aura);
    expect(r.isComparative, isFalse);
    expect(r.synthesis, isNull);
  });

  test('Piu\' Maestri: sintesi comparativa e lenti in ordine fisso', () {
    // Ordine di richiesta sparso: l'esito segue sempre l'ordine del cerchio.
    final r = oracle.consult(
      theme: 'una scelta d\'amore',
      maestri: [Maestro.caligo, Maestro.medora, Maestro.aura],
    );
    expect(r.lenses.map((l) => l.maestro).toList(),
        [Maestro.medora, Maestro.caligo, Maestro.aura]);
    expect(r.isComparative, isTrue);
    expect(r.synthesis, isNotNull);
    // La sintesi nomina le tre lenti e riprende il tema.
    expect(r.synthesis, contains('una scelta d\'amore'));
    expect(r.synthesis, contains('Medora'));
    expect(r.synthesis, contains('Aura'));
    expect(r.synthesis, contains('Caligo'));
  });

  test('Due Maestri: sintesi presente con due lenti', () {
    final r = oracle.consult(
      theme: 'la fortuna',
      maestri: [Maestro.medora, Maestro.caligo],
    );
    expect(r.lenses.length, 2);
    expect(r.synthesis, isNotNull);
  });

  test('Deterministico: stesso tema, stesso esito', () {
    final a = oracle.consult(theme: 'il futuro', maestri: Maestro.values);
    final b = oracle.consult(theme: 'il futuro', maestri: Maestro.values);
    for (var i = 0; i < a.lenses.length; i++) {
      expect(a.lenses[i].glance, b.lenses[i].glance);
      expect(a.lenses[i].reading, b.lenses[i].reading);
      expect(a.lenses[i].invite, b.lenses[i].invite);
    }
    expect(a.synthesis, b.synthesis);
  });

  test('Ogni lente ha i tre strati pieni e riprende il tema', () {
    final r = oracle.consult(theme: 'la relazione', maestri: Maestro.values);
    for (final lens in r.lenses) {
      expect(lens.glance, contains('la relazione'));
      expect(lens.glance, isNotEmpty);
      expect(lens.reading, isNotEmpty);
      expect(lens.invite, isNotEmpty);
    }
  });
}
