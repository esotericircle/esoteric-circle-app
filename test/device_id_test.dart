import 'package:esoteric_circle/core/identity/device_id.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// L'id del dispositivo per i Doni deterministici di chi non ha dato la nascita.
void main() {
  test('Genera un id esadecimale, lo persiste e lo tiene stabile', () async {
    SharedPreferences.setMockInitialValues({});
    final primo = await DeviceId.corrente();
    // Sedici byte in esadecimale minuscolo: trentadue cifre.
    expect(primo.length, 32);
    expect(RegExp(r'^[0-9a-f]{32}$').hasMatch(primo), isTrue);
    // Stabile: la seconda lettura torna lo stesso, dalla cache o dallo store.
    final secondo = await DeviceId.corrente();
    expect(secondo, primo);
    // Ed e' finito davvero nelle preferenze.
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('device.id'), primo);
  });
}
