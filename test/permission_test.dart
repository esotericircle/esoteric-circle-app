import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/permissions/app_permission.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Schema dei permessi', () {
    test('ogni permesso ha un pre-avviso completo', () {
      for (final p in AppPermission.values) {
        final c = permissionCopy(p);
        expect(c.title, isNotEmpty);
        expect(c.body, isNotEmpty);
        expect(c.cta, isNotEmpty);
      }
    });

    test('il pre-avviso del microfono nomina il Maestro ed e\' onesto', () {
      final c = permissionCopy(AppPermission.microphone, maestro: Maestro.medora);
      expect(c.body, contains('Medora'));
      expect(c.body.toLowerCase(), contains('non registra'));
    });
  });
}
