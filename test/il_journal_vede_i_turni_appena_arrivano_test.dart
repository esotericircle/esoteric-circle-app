import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/ricordi/registro_dei_ricordi.dart';
import 'package:esoteric_circle/core/ricordi/scrigno_dei_custoditi.dart';
import 'package:esoteric_circle/core/ricordi/voce_del_ricordo.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/ricordi/ricordi_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **IL JOURNAL VEDE I TURNI APPENA ARRIVANO.** Ordine DZ voce 02.
///
/// Il fatto, dal fondatore e poi sul Realme con la 2271: da *I giorni
/// prima* il Cosmic Journal si apre col filtro Medora e la griglia dell'anno
/// dice 0 in tutti i mesi, settembre compreso, mentre le conversazioni con
/// Medora ci sono. Toccando un filtro la griglia si ridisegna e settembre
/// dice 5: il conto era giusto, il disegno era fermo. La causa: la griglia
/// ascoltava la vista e non il registro, quindi cio' che il registro riceve
/// dopo il primo disegno non arriva a video finche' qualcuno non tocca la
/// vista.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<RegistroDeiRicordi> apri(WidgetTester tester) async {
    final registro = RegistroDeiRicordi(orologio: () => DateTime(2026, 9, 18));
    await registro.carica();
    final scrigno = ScrignoDeiCustoditi();
    await scrigno.carica();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<RegistroDeiRicordi>.value(value: registro),
        ChangeNotifierProvider<ScrignoDeiCustoditi>.value(value: scrigno),
      ],
      child: MaterialApp(
        home: MaestroScope(
          maestro: Maestro.medora,
          // Come dalla chat di Medora: sui Ricordi, col suo filtro.
          child: RicordiScreen(
            vistaIniziale: VistaDelJournal.ricordi,
            maestroIniziale: Maestro.medora,
            orologio: () => DateTime(2026, 9, 18),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    return registro;
  }

  String conto(WidgetTester tester, int mese) {
    final testi = tester
        .widgetList<Text>(find.descendant(
            of: find.byKey(Key('ricordi_mese_$mese')),
            matching: find.byType(Text)))
        .map((t) => t.data ?? '')
        .toList();
    return testi.join(' ');
  }

  testWidgets('DZ.02: un turno con Medora arriva nella griglia senza toccarla',
      (tester) async {
    final registro = await apri(tester);
    expect(conto(tester, 9), contains('0'));

    for (var i = 0; i < 5; i++) {
      await registro.segna(VoceDelRicordo(
        quando: DateTime(2026, 9, 18, 17, i),
        arte: 'chat',
        maestro: 'medora',
        titolo: 'Domanda numero $i',
        tipo: TipoDelRicordo.conversazione,
      ));
    }
    await tester.pumpAndSettle();

    expect(conto(tester, 9), contains('5'),
        reason: 'il registro ha cinque turni con Medora a settembre e la '
            'griglia dice ancora "${conto(tester, 9)}": e\' il Journal fermo '
            'visto sul Realme, che fa credere che le chat non si tengano');
  });
}
