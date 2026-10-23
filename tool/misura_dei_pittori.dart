import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/onboarding/widgets/ritual_object.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL METRO DEI PITTORI. Ordine AJ voce 01.
///
/// Monta una scena che ridipinge per fotogramma e cronometra SESSANTA
/// fotogrammi pompati: in prova il paint gira sulla CPU come sul telefono
/// (manca solo il raster), quindi il costo per fotogramma si confronta prima
/// e dopo la cura sulla stessa macchina.
///
/// Si lancia a mano:
///
///     flutter test tool/misura_dei_pittori.dart
void main() {
  Future<double> cronometra(WidgetTester tester, Widget scena) async {
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Material(child: Center(child: scena)),
    ));
    await tester.pump();
    // Riscaldamento: le prime passate pagano allocazioni una tantum.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    final orologio = Stopwatch()..start();
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    orologio.stop();
    return orologio.elapsedMicroseconds / 60 / 1000.0;
  }

  for (final maestro in Maestro.values) {
    testWidgets('oggetto rituale di ${maestro.id}', (tester) async {
      final palette = switch (maestro) {
        Maestro.medora => MaestroPalette.medora,
        Maestro.caligo => MaestroPalette.caligo,
        Maestro.aura => MaestroPalette.aura,
      };
      final ms = await cronometra(
          tester,
          RitualObject(
              maestro: maestro, palette: palette, progress: 0.6, level: 2));
      // ignore: avoid_print
      print('METRO ritual_object ${maestro.id}: ${ms.toStringAsFixed(2)} ms '
          'per fotogramma');
    });
  }
}
