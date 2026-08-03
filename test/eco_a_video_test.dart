import 'package:esoteric_circle/core/eco/archivio_dell_eco.dart';
import 'package:esoteric_circle/core/eco/eco_del_maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/voce_del_maestro.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/santuario/widgets/sigillo_dell_eco.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// L'ECO A VIDEO, a 360 per 797.
///
/// La regola pura sta in `eco_del_maestro_test.dart`. Qui si guarda cio' che la
/// persona vede: **la parola, e la riga che dice da dove viene**. Una parola
/// che ricompare senza dire da dove viene e' magia inspiegata.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  const eco = EcoDelMaestro(
    maestro: Maestro.caligo,
    parola: 'Laguz',
    chiusura: 'Ti affido il sigillo di Laguz.',
    domanda: 'ho paura di sbagliare',
    giorno: '2026-8-3',
  );

  Future<void> monta(WidgetTester tester, {VoidCallback? onApri}) async {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1080, 2392);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QualityTierController()),
      ],
      child: MaterialApp(
        home: MaestroScope(
          maestro: Maestro.caligo,
          child: Scaffold(
            body: Center(
              child: SigilloDellEco(
                eco: eco,
                larghezza: 110,
                onApri: onApri ?? () {},
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
  }

  testWidgets('Il sigillo mostra la PAROLA, non un\'etichetta di funzione',
      (tester) async {
    await monta(tester);
    expect(find.text('Laguz'), findsOneWidget);
    // Non "Eco", non "Dono": la parola E' la cosa.
    expect(find.text('Eco'), findsNothing);
  });

  testWidgets('E dice da CHI viene, gia\' nella striscia', (tester) async {
    await monta(tester);
    expect(find.text('da Caligo'), findsOneWidget,
        reason: 'una parola che ricompare senza dire da dove viene è magia '
            'inspiegata');
  });

  testWidgets('Al tocco riporta da dove viene', (tester) async {
    var aperto = false;
    await monta(tester, onApri: () => aperto = true);
    await tester.tap(find.byKey(const Key('sigillo_eco')));
    await tester.pump();
    expect(aperto, isTrue);
  });

  testWidgets('"Da dove nasce questo dono" dichiara TUTTE E TRE le cose',
      (tester) async {
    await monta(tester);
    await tester.longPress(find.byKey(const Key('sigillo_eco')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('eco_da_dove_nasce')), findsOneWidget);
    // 1. Che viene dalla CHIUSURA del Maestro, e da quale tipo di chiusura.
    expect(find.textContaining('l\'ha nominata Caligo'), findsOneWidget);
    expect(find.textContaining('un segno da portare'), findsOneWidget,
        reason: 'il tipo di chiusura esiste già nel dato, e si dichiara');
    // 2. La riga vera da cui viene, leggibile.
    expect(find.textContaining('Ti affido il sigillo di Laguz.'),
        findsOneWidget,
        reason: 'una provenienza che non si può leggere non è una provenienza');
    // 3. Da quale conversazione.
    expect(find.textContaining('ho paura di sbagliare'), findsOneWidget);
    // E si puo' condividere.
    expect(find.byKey(const Key('eco_condividi')), findsOneWidget);
  });

  testWidgets('La riga con cui la lascia porta la parola e il domani',
      (tester) async {
    // A video la riga la compone la bolla dal dato del Maestro: qui si guarda
    // che il dato produca una riga leggibile per tutti e tre.
    for (final maestro in Maestro.values) {
      final riga = VoceDelMaestro.di(maestro).ecoCon('Laguz');
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: Text(riga))));
      await tester.pump();
      expect(find.textContaining('Laguz'), findsOneWidget);
      expect(find.textContaining('mezzanotte'), findsOneWidget,
          reason: '${maestro.displayName} non dice cosa succede domani');
    }
  });

  testWidgets('L\'archivio vuoto non mostra nessun sigillo', (tester) async {
    // 3d a video: quando non c'e', non si finge.
    final archivio = ArchivioDellEco(clock: () => DateTime(2026, 8, 3));
    await archivio.carica();
    expect(archivio.viva, isNull);
  });
}
