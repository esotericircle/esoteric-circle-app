import 'dart:io';

import 'package:esoteric_circle/core/archetypes/archetype_history.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/astro/natal_chart_controller.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/aura/archetype/archetype_test_screen.dart';
import 'package:esoteric_circle/features/passport/cosmic_passport_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// OGNI TESSERA CHE APRE QUALCOSA LO DICE. Ordine BC voce 03.
///
/// **Fatto del fondatore**: "nel Passport adesso la bolla archetipo e'
/// cliccabile anche se in grigio, ma ci vorrebbe una freccettina come per le
/// altre bolle che invita al click."
///
/// **La regola esisteva gia', a due passi**, dentro `_ActiveFactCard`: *"Se la
/// tessera apre qualcosa al tocco, la freccia lo dice"*. La tessera Archetipo
/// non l'aveva perche' non usa quella card: usa quella delle voci **dietro il
/// velo**, nata per cose che non aprono niente. L'ordine BB voce 05 le ha
/// aggiunto un tocco **dall'esterno**, avvolgendola, e la card non ne ha mai
/// saputo nulla.
///
/// **E col velo c'era anche una contraddizione**: la stessa scatola diceva
/// "Dietro il velo" e "Tocca per fare il Test Archetipo". Il Test esiste ed e'
/// vivo da mesi, quindi la prima frase era falsa, e fra due frasi che si
/// smentiscono chi legge crede alla piu' scoraggiante.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> apri(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(const {});
    final storico = ArchetypeHistory();
    await storico.carica();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
        ChangeNotifierProvider(create: (_) => NatalChartController()),
        ChangeNotifierProvider<ArchetypeHistory>.value(value: storico),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MaestroScope(child: child!),
        home: const CosmicPassport(),
      ),
    ));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  testWidgets('BC.03: la tessera dell Archetipo mostra la freccia',
      (tester) async {
    await apri(tester);
    final tessera = find.byKey(const Key('passport_archetipo_vuoto_tocco'));
    expect(tessera, findsOneWidget,
        reason: 'la tessera dell Archetipo vuoto non c e');

    final frecce = find.descendant(
      of: tessera,
      matching: find.byIcon(Icons.chevron_right_rounded),
    );
    // ignore: avoid_print
    print('ORDINE BC VOCE 03: dentro la tessera dell Archetipo si contano '
        '${frecce.evaluate().length} frecce');
    expect(frecce, findsOneWidget,
        reason: 'la tessera apre il Test Archetipo e non lo dice: e il fatto '
            'del fondatore, "ci vorrebbe una freccettina che invita al click"');
  });

  testWidgets('BC.03: e non dice piu di essere dietro un velo che non c e',
      (tester) async {
    await apri(tester);
    final tessera = find.byKey(const Key('passport_archetipo_vuoto_tocco'));
    final velo = find.descendant(
      of: tessera,
      matching: find.text('Dietro il velo'),
    );
    // ignore: avoid_print
    print('ORDINE BC VOCE 03: dentro la tessera dell Archetipo il velo compare '
        '${velo.evaluate().length} volte');
    expect(velo, findsNothing,
        reason: 'la tessera dice "Dietro il velo" e "Tocca per fare il Test" '
            'nella stessa scatola: il Test esiste, quindi la prima frase e '
            'falsa e scoraggia chi legge');
  });

  testWidgets('BC.03: e il tocco porta ancora dove deve', (tester) async {
    // **LA CONTROPROVA.** Il tocco e passato da un `GestureDetector` che
    // avvolgeva la card a un `onTap` dentro di lei: e' proprio nei
    // trasferimenti cosi che un tocco si perde per strada, e nessuna prova
    // sulle icone se ne accorgerebbe.
    await apri(tester);
    expect(find.byType(ArchetypeTestScreen), findsNothing,
        reason: 'il Test e gia aperto prima di toccare, e la prova non '
            'direbbe niente');
    // **LA TESSERA STA SOTTO LA PIEGA**, a milleottocento punti: senza
    // portarla in vista il tocco cade sul vuoto, e la prova direbbe "non si
    // apre niente" per il motivo sbagliato.
    //
    // **`ensureVisible` e non `scrollUntilVisible`**, e la differenza qui
    // conta: il secondo si ferma appena il finder trova qualcosa, e un finder
    // per chiave trova la tessera anche mentre e' fuori dallo schermo, quindi
    // non scorreva di un punto.
    await tester
        .ensureVisible(find.byKey(const Key('passport_archetipo_vuoto_tocco')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('passport_archetipo_vuoto_tocco')));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    // **La schermata di prima resta sotto**, cioe nell albero: a dire che il
    // tocco e arrivato e quella che si e aperta sopra.
    expect(find.byType(ArchetypeTestScreen), findsOneWidget,
        reason: 'toccando la tessera non si apre il Test Archetipo: il tocco '
            'si e perso nel passaggio da fuori a dentro la card');
  });

  test('BC.03: e nessuna tessera del Passaporto apre in silenzio', () {
    // **LA REGOLA, NON IL CASO.** Se domani un altra tessera diventasse
    // toccabile, questa la prende. Si guardano le due card del Passaporto: in
    // tutte e due, dove c e un tocco deve esserci il chevron.
    final sorgente = File('lib/features/passport/cosmic_passport_screen.dart')
        .readAsLinesSync()
        .where((r) {
      final p = r.trimLeft();
      return !p.startsWith('//') && !p.startsWith('///');
    }).join('\n');
    final mute = <String>[];
    for (final card in const ['_ActiveFactCard', '_PassportEntryCard']) {
      final da = sorgente.indexOf('class $card extends');
      expect(da, greaterThan(0), reason: 'la card $card non esiste piu');
      // Fino alla classe successiva.
      var a = sorgente.indexOf('\nclass ', da + 1);
      if (a < 0) a = sorgente.length;
      final corpo = sorgente.substring(da, a);
      if (!corpo.contains('onTap')) continue;
      if (!corpo.contains('Icons.chevron_right_rounded')) {
        mute.add('$card accetta un tocco e non disegna nessuna freccia');
      }
    }
    // ignore: avoid_print
    print('ORDINE BC VOCE 03: card del Passaporto controllate 2, mute '
        '${mute.length}');
    expect(mute, isEmpty, reason: mute.join('; '));
  });
}
