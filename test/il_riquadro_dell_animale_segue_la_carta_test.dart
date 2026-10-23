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

/// **IL RIQUADRO DELL'ANIMALE SEGUE LA FORMA VERA DELLA CARTA.** Parola del
/// fondatore, 19 ottobre 2026, a video sul Realme: *"Vorrei che l'animale non
/// fosse tagliato alle gambe, anche perché con gli altri animali più
/// piccoli, ne verrebbe tagliato molto del corpo. Assicurati che tutti gli
/// animali si vedano interamente o quasi."*
///
/// Le dodici carte (`assets/img/mondo_di_sotto/carte/*_carta_da_grattare_v1.
/// webp`) sono tutte 1080x1920: un riquadro largo (1,35, l'opposto di
/// verticale) costringeva `BoxFit.cover` a mostrare solo una fetta stretta
/// centrale dell'immagine, tagliando le zampe del Cavallo e, su un animale
/// piu' raccolto nel fotogramma, molto di piu' del corpo.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
      'il riquadro della risalita ha la forma vera della carta (1080x1920), '
      'non un riquadro largo che le taglia le gambe', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    // **CINQUE DISCESE E NON QUATTRO**: come in DI.12, il diario di prova non
    // conta la discesa che si fa qui, e con quattro la risalita crederebbe
    // di essere quella della rivelazione (un lettore video diverso, non
    // questo riquadro).
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

    final animale = find.byKey(const Key('viaggio_animale_del_ritorno'));
    expect(animale, findsOneWidget,
        reason: 'la risalita non mostra l animale del ritorno');
    final riquadro =
        find.ancestor(of: animale, matching: find.byType(AspectRatio));
    expect(riquadro, findsOneWidget,
        reason: 'l animale del ritorno non sta dentro un AspectRatio');
    final misura = tester.getSize(riquadro);
    final rapporto = misura.width / misura.height;
    // **IL RAPPORTO VERO DELLA CARTA**: 1080/1920 = 0,5625. Un riquadro
    // largo come 1,35 (quello che tagliava le gambe) darebbe un rapporto
    // oltre il doppio di questo.
    expect(rapporto, closeTo(1080 / 1920, 0.01),
        reason: 'il riquadro ha un rapporto $rapporto, non quello vero '
            'della carta (0,5625): con BoxFit.cover questo taglia le '
            'gambe dell animale, o su un animale piu raccolto molto del '
            'corpo');
  });
}
