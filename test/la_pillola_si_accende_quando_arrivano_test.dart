import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/components/borsellino.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// LA PILLOLA SI ACCENDE D'ORO QUANDO GLI EOS ATTERRANO. Coda all'ordine AI,
/// decisione di Mauro del 17 agosto 2026.
///
/// **La veste mista**: la pillola vive col VELO di riposo; quando il volo
/// degli Eos le atterra dentro si accende d'ORO per un tempo dichiarato nel
/// componente (abbastanza da vedersi, mai un lampeggio) e poi torna velo. Il
/// guadagno si celebra da solo. Niente sfocature ne' blend additivi: solo le
/// due vesti che gia' esistono.
///
/// La prova legge la VESTE RESA dal riquadro animato (la decorazione di
/// arrivo, che e' lo stato vero del componente) nei tre momenti: riposo, oro
/// dopo l'annuncio, ritorno al velo. E con Riduci Movimento pretende il
/// cambio secco, transizione a durata zero.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget attorno({required bool riduciMovimento}) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(ctx)
                .copyWith(disableAnimations: riduciMovimento),
            child: MaestroScope(child: child!),
          ),
          home: const Material(
            type: MaterialType.transparency,
            child: Center(child: SegnoDelBorsellino()),
          ),
        ),
      );

  Color bordo(WidgetTester tester) {
    final riquadro = tester.widget<AnimatedContainer>(find.descendant(
        of: find.byKey(const Key('borsellino')),
        matching: find.byType(AnimatedContainer)));
    final decorazione = riquadro.decoration! as BoxDecoration;
    return (decorazione.border! as Border).top.color;
  }

  Duration durataDellaTransizione(WidgetTester tester) {
    final riquadro = tester.widget<AnimatedContainer>(find.descendant(
        of: find.byKey(const Key('borsellino')),
        matching: find.byType(AnimatedContainer)));
    return riquadro.duration;
  }

  testWidgets('riposo, oro all\'atterraggio, e ritorno al velo',
      (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    await tester.pumpWidget(attorno(riduciMovimento: false));
    await tester.pump();

    final velo = bordo(tester);

    // L'ATTERRAGGIO: il volo annuncia, come fa VoloDegliEos.lancia.
    ArrivoDegliEos.annuncia(10);
    await tester.pump();
    final oro = bordo(tester);
    // ignore: avoid_print
    print('CODA AI: bordo a riposo $velo, dopo l\'atterraggio $oro');
    expect(oro, isNot(velo),
        reason: 'gli Eos sono atterrati e la pillola non si e\' accesa: la '
            'veste resa e\' rimasta quella di riposo');

    // LA DORATURA NON E' UN LAMPEGGIO: a meta' del tempo dichiarato e'
    // ancora oro.
    await tester.pump(const Duration(milliseconds: 1300));
    expect(bordo(tester), oro,
        reason: 'la doratura si e\' spenta a meta\' del tempo dichiarato: '
            'un lampeggio, non una celebrazione');

    // E POI TORNA VELO, trascorsa la durata.
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(milliseconds: 500));
    expect(bordo(tester), velo,
        reason: 'trascorsa la durata la pillola doveva tornare al velo di '
            'riposo, e resta d\'oro');
  });

  testWidgets('con Riduci Movimento il cambio e\' secco', (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    await tester.pumpWidget(attorno(riduciMovimento: true));
    await tester.pump();
    expect(durataDellaTransizione(tester), Duration.zero,
        reason: 'con Riduci Movimento la transizione fra le vesti deve '
            'essere un cambio secco, senza animazione');
    ArrivoDegliEos.annuncia(5);
    await tester.pump();
    expect(durataDellaTransizione(tester), Duration.zero);
  });
}
