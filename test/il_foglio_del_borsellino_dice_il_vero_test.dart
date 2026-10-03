import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/registro_degli_eos.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/design_system/components/borsellino.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL FOGLIO DEL BORSELLINO DICE IL VERO, E SI LEGGE INTERO. Ordine BG
/// voce 02, dai due fatti del fondatore sulla 2201 (screenshot agli atti).
///
/// 1. "Il numero degli Eos e' coperto dalla barra sottile": il foglio a
///    scorrimento libero saliva fino in cima allo schermo e il saldo finiva
///    sotto la barra. Adesso il foglio ha un tetto che lascia liberi la
///    fascia di stato, la barra e un respiro.
/// 2. "Il conteggio di cio' che posso fare e' errato": il piano Viandante
///    non porta approfondimenti ne' confronti, e il foglio diceva "Non ti
///    resta nessun approfondimento. Domani torna intero", falso due volte
///    (non li hai finiti, e domani torna zero). Un limite a zero non e' un
///    esaurimento: e' una cosa che il piano non porta, e si dice cosi'.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues(const {}));

  test('un limite a zero non si racconta come un esaurimento', () {
    final borsa = QuestionAllowance();
    final righe = PortafoglioDelCerchio.tuttiILimiti(borsa, Tier.free);
    final approfondimenti =
        righe.firstWhere((r) => r.toLowerCase().contains('approfondiment'));
    final confronti =
        righe.firstWhere((r) => r.toLowerCase().contains('confront'));
    for (final riga in [approfondimenti, confronti]) {
      expect(riga.contains('non nel tuo piano'), isTrue,
          reason: 'il piano gratuito non porta questa cosa e la riga non lo '
              'dice: "$riga"');
      expect(riga.contains('Domani torna intero'), isFalse,
          reason: 'la riga promette che domani torna intero cio\' che il '
              'piano non porta affatto: "$riga"');
      expect(riga.contains('Non ti resta'), isFalse,
          reason: 'la riga racconta come esaurito cio\' che non e\' mai '
              'stato disponibile: "$riga"');
    }
    // E cio' che il piano porta davvero resta raccontato come prima.
    expect(
        righe.any((r) =>
            r.toLowerCase().contains('domand') && r.contains('Domani torna')),
        isTrue,
        reason: 'le domande del giorno hanno perso il loro racconto');
  });

  testWidgets('il foglio non sale sotto la barra sottile', (tester) async {
    tester.view.physicalSize = const Size(390, 500);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => QuestionAllowance()),
        ChangeNotifierProvider(create: (_) => RegistroDegliEos()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark(),
        home: MaestroScope(
          child: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  key: const Key('apri_il_portafoglio'),
                  onPressed: () => PortafoglioDelCerchio.apri(context),
                  child: const Text('apri'),
                ),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.byKey(const Key('apri_il_portafoglio')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Su uno schermo BASSO apposta (500 punti) il contenuto vorrebbe tutta
    // l'altezza: il tetto deve fermarlo sotto la fascia della barra. Trenta
    // punti di barra piu' il respiro: la cima del foglio non sale mai sopra.
    final foglio = tester.getRect(find.byKey(const Key('portafoglio')));
    expect(foglio.top, greaterThanOrEqualTo(30.0),
        reason: 'il foglio sale fin sotto la barra sottile e il saldo si '
            'legge a meta\', che e\' lo screenshot del fondatore');
  });
}
