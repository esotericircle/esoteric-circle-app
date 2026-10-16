import 'package:esoteric_circle/core/astro/luogo_attuale.dart';
import 'package:esoteric_circle/core/astro/sky_location.dart';
import 'package:esoteric_circle/core/lunario/la_consultazione_della_luna.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/respiro_della_luna/i_pezzi_della_consultazione.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'cardinale_minimo.dart';

/// **OGNI DATO STA AL CENTRO DELLA SUA RIGA.** Ordine FY voce FY.10, 16
/// ottobre 2026. Il fondatore: "Le info che attualmente scorrono non sono
/// tutte allineate verticalmente al centro del proprio riquadro".
///
/// Per ogni riga dei dati della Luna di quest'ora si misura lo scarto fra il
/// centro verticale del testo (e del medaglione) e il centro della striscia
/// dipinta, a 320, 360, 390 e 430 punti col testo a 1,0 e a 1,3: sotto i due
/// punti, riga per riga.
void main() {
  final luogo = LuogoAttuale.dalDispositivo(
      const SkyPlace(latitude: 45.05, longitude: 9.69, citta: 'Piacenza'));
  final consultazione =
      LaConsultazioneDellaLuna.calcola(DateTime(2026, 10, 16, 10), luogo);

  for (final larghezza in const [320.0, 360.0, 390.0, 430.0]) {
    for (final scala in const [1.0, 1.3]) {
      testWidgets('le righe dei dati sono centrate, $larghezza, testo a $scala',
          (tester) async {
        tester.view.physicalSize = Size(larghezza, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => MaestroController())
          ],
          child: MaterialApp(
            builder: (c, child) => MediaQuery(
                data: MediaQuery.of(c)
                    .copyWith(textScaler: TextScaler.linear(scala)),
                child: child!),
            home: MaestroScope(
              child: Scaffold(
                body: SingleChildScrollView(
                  child: IDatiDellaLuna(
                      consultazione: consultazione,
                      palette: MaestroPalette.forKey(
                          const ThemeKey.of(Maestro.medora))),
                ),
              ),
            ),
          ),
        ));
        await tester.pump();

        final scarti = <String>[];
        final righe = find.byType(RigaDelDato).evaluate().toList();
        cardinaleMinimo(righe.length, 8,
            cosa: 'righe dei dati della Luna',
            perche: 'Senza righe la misura non guarda niente.');
        for (final e in righe) {
          final riga = find.byWidget(e.widget);
          final striscia = tester.getRect(
              find.descendant(of: riga, matching: find.byType(Stack)).first);
          final testo = tester.getRect(
              find.descendant(of: riga, matching: find.byType(RichText)).first);
          final scarto = (testo.center.dy - striscia.center.dy).abs();
          if (scarto > 2) {
            scarti.add('${(e.widget as RigaDelDato).etichetta}: '
                '${scarto.toStringAsFixed(1)} punti');
          }
        }
        expect(scarti, isEmpty,
            reason: 'righe col testo fuori dal centro della striscia: $scarti');
      });
    }
  }
}
