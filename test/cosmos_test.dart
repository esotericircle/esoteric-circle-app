import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/components/cosmos_background.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:flutter_test/flutter_test.dart';

/// Il cosmo di fondo: densita' del campo stellare per tier, nebulose che
/// contrastano davvero e qualita' alta di default.
void main() {
  group('Densita\' del campo stellare per tier', () {
    test('Fitto in alta, presente in media, ridotto in bassa', () {
      expect(QualityTierController.fieldStarsFor(QualityTier.high), 120);
      expect(QualityTierController.fieldStarsFor(QualityTier.medium), 70);
      expect(QualityTierController.fieldStarsFor(QualityTier.low), 24);
    });

    test('La densita\' cresce col tier, mai al contrario', () {
      final high = QualityTierController.fieldStarsFor(QualityTier.high);
      final medium = QualityTierController.fieldStarsFor(QualityTier.medium);
      final low = QualityTierController.fieldStarsFor(QualityTier.low);
      expect(high, greaterThan(medium));
      expect(medium, greaterThan(low));
    });
  });

  group('Qualita\' alta di default', () {
    test('Il controller nasce in qualita\' alta', () {
      expect(QualityTierController().tier, QualityTier.high);
    });

    test('In alta gli effetti pieni sono attivi', () {
      final q = QualityTierController();
      expect(q.richEffects, isTrue);
      expect(q.starDensity, 120);
    });
  });

  group('Nebulose contrastate', () {
    test('Il nucleo e\' una tinta fredda e chiara, non un accento del dominio',
        () {
      // Nucleo chiaro: luminanza alta, cosi' stacca dal fondo scuro.
      expect(CosmosNebula.core.computeLuminance(), greaterThan(0.4));

      // Nessuna delle tre tinte coincide con l'accento primario di un Maestro,
      // cosi' le nebulose non si confondono col fondo tinto del dominio.
      for (final m in Maestro.values) {
        final accent = MaestroPalette.forKey(ThemeKey.of(m)).primary;
        expect(CosmosNebula.core == accent, isFalse, reason: m.id);
        expect(CosmosNebula.mid == accent, isFalse, reason: m.id);
        expect(CosmosNebula.cool == accent, isFalse, reason: m.id);
      }
    });
  });
}
