import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// LE VOCI BLOCCATE DELLA STESA INVITANO, MAI UN VICOLO CIETO. Ordine GA voce
/// 09, verifica indipendente sul Realme del 21 ottobre 2026.
///
/// **Il fatto riportato dal collaudatore**: tre selettori della Stesa di
/// Tarocchi (Chiave di lettura, Tipo di stesa, Mazzo), toccando una voce col
/// lucchetto, chiudono la tendina senza mostrare nessun invito: ne' foglio,
/// ne' snackbar. Riprodotto qui, col tocco vero su `PopupMenuButton` e la
/// stessa `_showComingSoon` che gira sul telefono, **l'invito compare**: la
/// via del codice e' sana. L'ipotesi piu' probabile e' il tempismo della
/// cattura sul device (il foglio ha una sua animazione d'entrata, e una
/// cattura presa nello stesso istante del tocco la perde): resta una prova
/// qui, cosi' una vera regressione del codice non torni inosservata.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> loadFonts() async {
    for (final f in const [
      ['Cinzel', 'assets/fonts/Cinzel-variable.ttf'],
      ['EBGaramond', 'assets/fonts/EBGaramond-variable.ttf'],
    ]) {
      final loader = FontLoader(f[0]);
      loader.addFont(
          Future.value(ByteData.view(File(f[1]).readAsBytesSync().buffer)));
      await loader.load();
    }
  }

  Future<void> pumpScreen(WidgetTester tester, {int seed = 2}) async {
    await loadFonts();
    tester.view.physicalSize = const Size(390, 5200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
      ],
      child: MaterialApp(
        home: MaestroScope(
          child: StesaTreCarteScreen(seed: seed),
        ),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
  }

  Future<void> colpi(WidgetTester tester, int n) async {
    for (var i = 0; i < n; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  Future<void> apriIlPannello(WidgetTester tester) async {
    final titoloAperto = find.byKey(const Key('stesa_setup_titolo_aperto'));
    if (titoloAperto.evaluate().isNotEmpty) return;
    final riga = find.byKey(const Key('stesa_setup_riga'));
    if (riga.evaluate().isNotEmpty) {
      await tester.tap(riga.first);
      await colpi(tester, 5);
    }
  }

  /// Apre la tendina [chiaveSelettore], tocca la voce col testo [etichetta]
  /// (deve essere una voce bloccata su un Viandante) e dice se, dopo averle
  /// dato il tempo della sua animazione, e' comparso l'invito.
  Future<bool> toccaEVerificaInvito(
    WidgetTester tester, {
    required String chiaveSelettore,
    required String etichetta,
  }) async {
    final selettore = find.byKey(Key(chiaveSelettore));
    expect(selettore, findsOneWidget,
        reason: 'il selettore $chiaveSelettore non c\'e\' nel pannello');
    await tester.tap(selettore);
    await colpi(tester, 5);
    final voce = find.text(etichetta);
    expect(voce, findsOneWidget,
        reason: 'la voce "$etichetta" non e\' nella tendina $chiaveSelettore');
    await tester.tap(voce);
    await tester.pump();
    expect(tester.takeException(), isNull,
        reason: 'il tocco su "$etichetta" ha lanciato un\'eccezione');
    await colpi(tester, 6);
    return find.byKey(const Key('upgrade_invite')).evaluate().isNotEmpty;
  }

  testWidgets(
      'la Chiave di lettura bloccata invita, non chiude in silenzio',
      (tester) async {
    await pumpScreen(tester);
    await apriIlPannello(tester);
    final invito = await toccaEVerificaInvito(tester,
        chiaveSelettore: 'stesa_chiave', etichetta: 'Esoterica');
    expect(invito, isTrue,
        reason: 'toccando "Esoterica" (bloccata per il Viandante) non '
            'compare `upgrade_invite`: e\' il vicolo cieco silenzioso che '
            'l\'ordine vuole escluso');
  });

  testWidgets('il Tipo di stesa bloccato invita, non chiude in silenzio',
      (tester) async {
    await pumpScreen(tester);
    await apriIlPannello(tester);
    final invito = await toccaEVerificaInvito(tester,
        chiaveSelettore: 'stesa_tipo', etichetta: 'Quattro Carte');
    expect(invito, isTrue,
        reason: 'toccando "Quattro Carte" (bloccata per il Viandante) non '
            'compare `upgrade_invite`');
  });

  testWidgets('il Mazzo bloccato invita, non chiude in silenzio',
      (tester) async {
    await pumpScreen(tester);
    await apriIlPannello(tester);
    final invito = await toccaEVerificaInvito(tester,
        chiaveSelettore: 'stesa_mazzo', etichetta: 'Marsiglia');
    expect(invito, isTrue,
        reason: 'toccando "Marsiglia" (bloccato per il Viandante) non '
            'compare `upgrade_invite`');
  });
}
