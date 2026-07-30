import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:esoteric_circle/design_system/tokens/spacing_tokens.dart';
import 'package:esoteric_circle/features/santuario/daily_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Il quarto Dono deve sporgere, altrimenti nessuno scorre.
///
/// **La regola, e dove vive.** Un elenco che scorre lo dichiara mostrando che
/// c'e' dell'altro: il mezzo oggetto tagliato dal bordo e' l'invito piu' antico
/// che esista. A 390 punti il quarto Dono faceva capolino per fortuna, non per
/// scelta, perche' la larghezza della casella era una costante che su quello
/// schermo tornava. A 360 spariva, e restavano tre icone con una barretta
/// sottile che nessuno legge come "scorri".
///
/// La quantita' minima visibile e' un DATO, `DailyStrip.sbirciaturaMinima`, e la
/// larghezza della casella si RICAVA da quel dato. Prima era il contrario, e la
/// sbirciatura era quello che avanzava.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silence() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (c) async => null);
  }

  /// Quanto sporge il quarto Dono dentro lo schermo, in punti.
  ///
  /// Si ricava dal LAYOUT e non da un widget interno: il cerchio "?" sta al
  /// centro della casella, quindi quando la casella sporge di poco quel cerchio
  /// e' gia' fuori, e misurarlo direbbe zero anche con la sbirciatura presente.
  /// Era il difetto della prima stesura di questa prova.
  double sporgenzaDelQuarto(double larghezzaSchermo) {
    final casella = DailyStrip.larghezzaCasella(larghezzaSchermo);
    final bordoSinistro = SpacingTokens.md;
    return larghezzaSchermo - (bordoSinistro + casella * 3);
  }

  /// Se la lista pigra costruisce davvero il quarto Dono.
  Future<bool> quartoCostruito(WidgetTester tester, double larghezza) async {
    silence();
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = Size(larghezza, 797);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: DailyStrip(clock: () => DateTime(2026, 7, 30, 21)),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final quarto = DailyElement.values[3];
    return find
        .byKey(Key('daily_help_button_${quarto.name}'))
        .evaluate()
        .isNotEmpty;
  }

  test('La sbirciatura minima e\' un dato dichiarato', () {
    expect(DailyStrip.sbirciaturaMinima, greaterThanOrEqualTo(20),
        reason: 'sotto i venti punti non si legge come "c\'e\' dell\'altro"');
  });

  for (final larghezza in const [360.0, 390.0]) {
    test('A $larghezza il quarto Dono sporge dentro lo schermo', () {
      final sporge = sporgenzaDelQuarto(larghezza);
      expect(sporge, greaterThanOrEqualTo(DailyStrip.sbirciaturaMinima),
          reason: 'a $larghezza punti del quarto Dono si vedono '
              '${sporge.toStringAsFixed(1)} punti, meno della sbirciatura '
              'dichiarata: restano tre icone e nessun motivo di scorrere');
    });

    testWidgets('A $larghezza il quarto Dono entra nell\'albero',
        (tester) async {
      expect(await quartoCostruito(tester, larghezza), isTrue,
          reason: 'a $larghezza il quarto Dono non viene nemmeno costruito, '
              'quindi non c\'e\' niente da sbirciare');
    });
  }
}
