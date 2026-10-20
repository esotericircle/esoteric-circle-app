import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/viaggio_dello_sciamano_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'la_soglia_si_guarda_prima_di_leggerla_test.dart'
    show DiarioDelloSciamanoDiProva;

/// **IL RESPONSO SI VEDE APPENA SI RISALE.** Ordine FZ, trovato dalla
/// simulazione da persona del 20 ottobre 2026 sul Realme 767f596c, al terzo
/// giorno simulato (22 ottobre sulla data spostata del telefono di collaudo).
///
/// **Il fatto**: dopo Risali la schermata mostrava solo l'ombra dell'animale,
/// grande quanto tutto lo schermo, senza una parola e senza un segno che
/// invitasse a scorrere
/// (`docs/collaudo/FZ/simulazioni/catture/v2_d3_risalita3.png`). Il titolo e
/// la risposta c'erano, ma sotto la piega: chi prova crede che l'app si sia
/// fermata. La regola di casa vuole il colpo d'occhio visivo e la sintesi in
/// una frase **insieme**, ed e' la prima cosa che si guarda.
///
/// **La causa**: il riquadro dell'animale ha preso la forma vera della carta,
/// 1080x1920, a tutta larghezza (ordine FZ voce FZ.14): su un telefono largo
/// 360 punti fa piu' di cinquecento punti di altezza, e il titolo scende sotto
/// lo schermo. Padre: ordine FZ voce FZ.14.
///
/// **Cosa misura**: sulle misure vere del Realme (1080x2400, densita' 3, con
/// le barre di sistema) e di un telefono piu' basso, il titolo del responso
/// sta per intero dentro lo schermo appena si arriva alla risalita, senza
/// scorrere; e l'animale resta intero, col rapporto vero della carta.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// Le misure su cui si guarda: il Realme di collaudo e un telefono basso.
  ///
  /// **LE MISURE VERE DELLA FINESTRA, non dello schermo.** Lette sul Realme
  /// con `uiautomator dump` il 20 ottobre 2026: la finestra dell'app e' alta
  /// 2158 pixel e non 2400 (la barra di navigazione sta fuori), e sopra la
  /// barra del titolo del Viaggio ci sono la barra di stato e la striscia del
  /// Cerchio (account, Eos), 221 pixel in tutto. La prima stesura della
  /// guardia usava lo schermo intero con barre di sistema da manuale, ed era
  /// verde sul Realme mentre il Realme vero mostrava il difetto: misurava un
  /// telefono che non esiste.
  const telefoni = <String, (Size, double, double, double)>{
    'Realme 767f596c': (Size(1080, 2158), 3.0, 221, 0),
    'telefono basso 720x1360': (Size(720, 1360), 2.0, 148, 0),
  };

  for (final MapEntry(key: nome, value: (fisico, densita, sopra, sotto))
      in telefoni.entries) {
    testWidgets(
        'sul $nome il titolo del responso si legge appena si risale, senza '
        'scorrere, e l\'animale resta intero', (tester) async {
      tester.view.physicalSize = fisico;
      tester.view.devicePixelRatio = densita;
      tester.view.padding = FakeViewPadding(top: sopra, bottom: sotto);
      tester.view.viewPadding = FakeViewPadding(top: sopra, bottom: sotto);
      addTearDown(tester.view.reset);
      // **CINQUE DISCESE E NON QUATTRO**, come nella guardia del riquadro:
      // con quattro la risalita sarebbe quella della rivelazione.
      final diario = DiarioDelloSciamanoDiProva(5, nome: 'Cavallo');
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
        ],
        child: MaterialApp(
          home: MaestroScope(
            child: ViaggioDelloSciamanoScreen(
              userSign: Zodiac.sagittarius,
              now: DateTime(2026, 9, 12, 12),
              diario: diario,
            ),
          ),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byKey(const Key('viaggio_azione_scendi')));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.ensureVisible(find.text('Una scelta da fare'));
      await tester.tap(find.text('Una scelta da fare'));
      await tester.pump();
      await tester.ensureVisible(find.byKey(const Key('viaggio_scendi')));
      await tester.tap(find.byKey(const Key('viaggio_scendi')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1600));
      await tester.tap(find.byKey(const Key('viaggio_salta_la_discesa')));
      await tester.pump(const Duration(seconds: 1));
      final nebbia = find.byKey(const Key('viaggio_nebbia'));
      for (var i = 0; i < 80 && nebbia.evaluate().isNotEmpty; i++) {
        await tester.drag(nebbia, const Offset(120, 40));
        await tester.pump(const Duration(milliseconds: 60));
      }
      await tester.pump(const Duration(milliseconds: 300));
      final ombra = find.byKey(const Key('viaggio_ombra_Cavallo'));
      expect(ombra, findsOneWidget, reason: 'la nebbia non porta all incontro');
      await tester.tap(ombra);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final altezza = fisico.height / densita;
      final fondo = altezza - sotto / densita;
      final titolo = find.byKey(const Key('viaggio_titolo_della_risposta'));
      expect(titolo, findsOneWidget,
          reason: 'la risalita non ha il titolo del responso');
      final r = tester.getRect(titolo);
      // **IL TITOLO PER INTERO SOPRA LA BARRA DI SISTEMA**, senza scorrere:
      // nessuno ha toccato lo schermo dopo l'arrivo.
      expect(r.bottom, lessThanOrEqualTo(fondo),
          reason: 'sul $nome il titolo del responso finisce a '
              '${r.bottom.toStringAsFixed(0)} punti, sotto il fondo visibile '
              '(${fondo.toStringAsFixed(0)}): chi risale vede solo l ombra '
              'e crede che l app si sia fermata');
      // **E L'ANIMALE RESTA INTERO**: la cura non deve tornare a tagliarlo.
      final animale = find.byKey(const Key('viaggio_animale_del_ritorno'));
      final riquadro =
          find.ancestor(of: animale, matching: find.byType(AspectRatio));
      final q = tester.getRect(riquadro);
      expect(q.width / q.height, closeTo(1080 / 1920, 0.01),
          reason: 'il riquadro non ha piu il rapporto vero della carta');
      expect(q.top, greaterThanOrEqualTo(0),
          reason: 'il riquadro dell animale comincia fuori dallo schermo');
      // **IL CARDINALE**: un riquadro minuscolo farebbe stare il titolo a
      // schermo senza mostrare l'animale. Almeno un terzo dello schermo.
      expect(q.height, greaterThan(altezza / 3),
          reason: 'l animale del ritorno e alto solo '
              '${q.height.toStringAsFixed(0)} punti: non si vede piu');
    });
  }
}
