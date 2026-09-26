import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/permissions/app_permission.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// La richiesta di un permesso non sparisce da sola.
///
/// Il foglio che spiega perche' serve il microfono era un bottom sheet
/// ordinario: `isDismissible` e `enableDrag` valgono true per difetto, quindi un
/// tocco fuori o uno sfioramento lo chiudevano. Succedeva proprio dove
/// succede di piu', cioe' nella schermata del soffio, dove si tocca e si
/// trascina per far muovere la scena: la spiegazione spariva prima di essere
/// letta, e il permesso restava non concesso senza che nessuno capisse perche'.
void main() {
  Future<bool?> apriRichiesta(WidgetTester tester) async {
    bool? esito;
    var chiamateSistema = 0;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (ctx) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () async {
                esito = await requestPermissionWithPrelude(
                  ctx,
                  permission: AppPermission.microphone,
                  palette: MaestroPalette.neutral,
                  maestro: Maestro.medora,
                  systemRequest: () async {
                    chiamateSistema++;
                    return true;
                  },
                );
              },
              child: const Text('chiedi'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('chiedi'));
    await tester.pumpAndSettle();
    expect(chiamateSistema, 0, reason: 'il sistema e\' stato chiamato subito');
    return esito;
  }

  testWidgets('Un tocco fuori non fa sparire la spiegazione', (tester) async {
    await apriRichiesta(tester);
    expect(find.textContaining('microfono'), findsWidgets);

    // Un tocco in alto, sulla tendina scura fuori dal foglio.
    await tester.tapAt(const Offset(200, 40));
    await tester.pumpAndSettle();

    expect(find.textContaining('microfono'), findsWidgets,
        reason:
            'la spiegazione e\' sparita per un tocco fuori: nella schermata '
            'del soffio i tocchi arrivano continuamente');
  });

  testWidgets('Un trascinamento verso il basso non la fa sparire',
      (tester) async {
    await apriRichiesta(tester);
    await tester.drag(
        find.textContaining('microfono').first, const Offset(0, 400));
    await tester.pumpAndSettle();

    expect(find.textContaining('microfono'), findsWidgets,
        reason: 'la spiegazione si trascina via, e nella schermata del soffio '
            'si trascina per far muovere la scena');
  });

  testWidgets('Si chiude solo con una scelta esplicita', (tester) async {
    await apriRichiesta(tester);
    expect(find.byKey(const Key('permesso_non_ora')), findsOneWidget,
        reason: 'senza una via d\'uscita dichiarata il foglio diventa una '
            'trappola');

    await tester.tap(find.byKey(const Key('permesso_non_ora')));
    await tester.pumpAndSettle();
    expect(find.textContaining('microfono'), findsNothing);
  });
}
