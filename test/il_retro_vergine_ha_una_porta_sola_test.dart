import 'dart:io';
import 'dart:math' as math;

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/rune/rune_draw_screen.dart';
import 'package:esoteric_circle/features/rituals/retro_della_runa.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL RETRO VERGINE HA UNA PORTA SOLA, E LA SAGOMA DEL FRONTE NON ESISTE PIU'.
///
/// Il difetto visto da Mauro: sul telo, dove doveva vedersi la pietra vergine,
/// una runa coperta mostrava la miniatura del FRONTE a opacita' 0,35. Peggio
/// di uno slot: anticipava la runa che la persona doveva ancora scoprire.
/// Adesso ogni runa coperta mostra il retro della SUA pietra, e chiunque lo
/// disegni passa da RetroDellaRuna: queste prove enumerano i punti invece di
/// visitarne uno.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('la porta e\' una: rune_bone_vergine vive in un file solo di lib', () {
    // L'ENUMERAZIONE: ogni punto che mostra una runa coperta risolve il
    // percorso del retro, e il percorso nomina la cartella. Se la cartella
    // compare in un secondo file, quella e' una seconda porta.
    final colpevoli = <String>[];
    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      if (!f.readAsStringSync().contains('rune_bone_vergine')) continue;
      if (!f.path.endsWith('retro_della_runa.dart')) colpevoli.add(f.path);
    }
    expect(colpevoli, isEmpty,
        reason: 'La cartella dei retri vergini compare anche in: $colpevoli. '
            'La porta e\' retro_della_runa.dart, una sola.');
  });

  testWidgets('sul telo nessuna pietra e\' coperta: ogni runa mostra il suo '
      'simbolo', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) =>
                MaestroController(initial: const ThemeKey.of(Maestro.caligo))),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
        ChangeNotifierProvider(create: (_) => SettingsController()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: RuneDrawScreen(userSign: Zodiac.aries, random: math.Random(5)),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 400));

    // Il getto sul telo, l'unica gettata con pietre coperte.
    await tester.ensureVisible(find.byKey(const Key('rune_segment_telo')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('rune_segment_telo')));
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('rune_cast_button')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('rune_cast_button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // DALL'ORDINE H sul telo non esistono piu' pietre coperte: ogni pietra
    // gettata mostra il suo simbolo, dritta o rovesciata. La prova e'
    // CAMBIATA DI GRANDEZZA con la regola, non allentata: prima pretendeva
    // il retro vergine sulle coperte, adesso pretende che NESSUNA pietra
    // posata passi dal retro, perche' un dorso sul telo vorrebbe dire una
    // pietra tornata muta. La porta unica del retro resta sorvegliata dalle
    // prove statiche qui sopra e sotto, e serve ancora alla Runa del
    // Tramonto prima del giro.
    final atteso = RuneCast.getta(gettataTelo, random: math.Random(5));
    expect(atteso.sparse.where((s) => s.coperta), isEmpty,
        reason: 'Il modello ha prodotto pietre coperte sul telo: la regola '
            'dell\'ordine H, ogni pietra mostra il suo simbolo, non sta '
            'girando.');

    for (var i = 0; i < atteso.sparse.length; i++) {
      final pietra = find.byKey(Key('runa_posata_$i'));
      expect(pietra, findsOneWidget,
          reason: 'La pietra $i non e\' sul telo.');
      expect(
          find.descendant(
              of: pietra, matching: find.byType(RetroDellaRuna)),
          findsNothing,
          reason: 'La pietra $i mostra il dorso: dall\'ordine H sul telo '
              'ogni pietra mostra il suo simbolo.');
      // E il volto e' quello della SUA runa: la miniatura del fronte porta
      // lo stem giusto, o in sua assenza c'e' il glifo dipinto.
      final immagini = find
          .descendant(of: pietra, matching: find.byType(Image))
          .evaluate()
          .map((e) => ((e.widget as Image).image as AssetImage).assetName)
          .toList();
      final glifi = find
          .descendant(of: pietra, matching: find.byType(CustomPaint))
          .evaluate();
      expect(immagini.isNotEmpty || glifi.isNotEmpty, isTrue,
          reason: 'La pietra $i non mostra ne\' miniatura ne\' glifo: una '
              'pietra nuda sul telo.');
      final stem = atteso.sparse[i].rune.stem;
      if (stem != null) {
        for (final nome in immagini) {
          expect(nome.contains(stem), isTrue,
              reason: 'Sotto la pietra $i c\'e\' l\'immagine $nome, che non '
                  'e\' la sua runa.');
        }
      }
    }
  });

  test('il percorso del retro coincide con la runa, per tutte e ventiquattro',
      () {
    // Gia' sorvegliato da osso_vergine_path_test, che cade col nome della
    // runa quando il retro e' di un'altra: qui si tiene il legame stem ->
    // percorso per la porta nuova, cosi' un cambio di casa non lo perde.
    expect(pathVergineDi('rune_bone_07_gebo_v1'),
        'assets/img/rune_bone_vergine/rune_bone_07_gebo_vergine_v1.webp');
    expect(pathVergineDi(null), isNull);
  });
}
