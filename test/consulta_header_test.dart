import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:flutter_test/flutter_test.dart';

/// L'header di Consulta: nome e sottotitolo centrati, e il sottotitolo con le
/// tre arti del Maestro formattate con "e" prima dell'ultima.
void main() {
  test('domainArtsPhrase mostra le tre arti con "e" prima dell\'ultima', () {
    expect(
        Maestro.medora.domainArtsPhrase, 'Astrologia, Cartomanzia e Destino');
    // **LAPIDE: fino all'ordine EN** Aura era "Chakra, Energia e Archetipi"
    // e Caligo "Rune, Rituali e Numerologia". **Dall'ordine EO voce 11** le
    // sezioni seguono i nomi e l'ordine del fondatore.
    expect(Maestro.aura.domainArtsPhrase, 'Energia, Chakra e Fisiognomica');
    expect(
        Maestro.caligo.domainArtsPhrase, 'Divinazione, Rituali e Numerologia');
  });

  test('La frase delle arti non ha virgola davanti alla "e"', () {
    for (final m in Maestro.values) {
      expect(m.domainArtsPhrase.contains(', e '), isFalse,
          reason: 'virgola davanti alla e in ${m.displayName}');
      expect(m.domainArtsPhrase.contains('—'), isFalse);
    }
  });
}
