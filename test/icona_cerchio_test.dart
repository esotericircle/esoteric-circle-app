import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/components/icona_del_cerchio.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/shell/navigation_controller.dart';
import 'package:esoteric_circle/features/shell/santuario_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// LA VOCE DEL CERCHIO PORTA LA MEZZALUNA DENTRO IL CERCHIO.
///
/// Chiesta dal fondatore il 30 luglio: la mezzaluna da sola dice la Luna e
/// basta, dentro il cerchio dice la luce e l'oscurita' insieme.
void main() {
  Future<void> monta(WidgetTester tester, {required ShellView view}) async {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2340);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => MaestroController())],
      child: MaterialApp(
        home: MaestroScope(
          child: Scaffold(
            body: Align(
              alignment: Alignment.bottomCenter,
              child: SantuarioBottomBar(
                view: view,
                onSantuario: () {},
                onMaestro: (_) {},
                onPassport: () {},
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('La voce del Cerchio non e\' piu\' una mezzaluna sola',
      (tester) async {
    await monta(tester, view: ShellView.santuario);
    expect(find.byType(IconaDelCerchio), findsOneWidget,
        reason: 'la voce del Cerchio non porta la mezzaluna dentro il cerchio');
    expect(find.byIcon(Icons.brightness_3), findsNothing,
        reason: 'la mezzaluna sola e\' ancora li\': dice la Luna e basta');
  });

  testWidgets('Regge anche da spenta, non solo da accesa', (tester) async {
    // Nello stato attivo il fondo si riempie del colore del Maestro, e una
    // falce troppo magra ci sparisce dentro. Da spenta il fondo e' trasparente:
    // sono due condizioni diverse, e l'icona deve esserci in tutte e due.
    await monta(tester, view: ShellView.passport);
    expect(find.byType(IconaDelCerchio), findsOneWidget);
  });

  testWidgets('Sta nella misura delle altre quattro', (tester) async {
    await monta(tester, view: ShellView.santuario);
    final lato = tester.getSize(find.byType(IconaDelCerchio));
    expect(lato.width, 21,
        reason: 'l\'icona del Cerchio ha una misura sua, quindi nella barra si '
            'vede piu\' grande o piu\' piccola delle altre');
    expect(lato.height, 21);
  });

  test('Il disegno vive nel design system, non dentro la barra', () {
    // La domanda di chiusura: la regola dove vive. Se il disegno stesse nella
    // barra, il giorno in cui il Cerchio comparisse altrove, in un menu o in
    // una scorciatoia, ci arriverebbe di nuovo la mezzaluna sola. E' la
    // famiglia di difetti che questo progetto ha contato quattordici volte.
    expect(
      const IconaDelCerchio(colore: Color(0xFFD9B65C)).dimensione,
      21,
      reason: 'il componente non nasce gia\' della misura della barra',
    );
  });
}
