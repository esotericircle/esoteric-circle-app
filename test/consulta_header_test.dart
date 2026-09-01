import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:flutter_test/flutter_test.dart';

/// L'header di Consulta: nome e sottotitolo centrati, e il sottotitolo con le
/// tre arti del Maestro formattate con "e" prima dell'ultima.
void main() {
  test('domainArtsPhrase mostra le tre arti con "e" prima dell\'ultima', () {
    expect(
        Maestro.medora.domainArtsPhrase, 'Astrologia, Cartomanzia e Destino');
    expect(Maestro.aura.domainArtsPhrase, 'Chakra, Energia e Archetipi');
    expect(Maestro.caligo.domainArtsPhrase, 'Rune, Rituali e Numerologia');
  });

  test('La frase delle arti non ha virgola davanti alla "e"', () {
    for (final m in Maestro.values) {
      expect(m.domainArtsPhrase.contains(', e '), isFalse,
          reason: 'virgola davanti alla e in ${m.displayName}');
      expect(m.domainArtsPhrase.contains('—'), isFalse);
    }
  });
}
