import 'package:esoteric_circle/core/archetypes/archetype.dart';
import 'package:esoteric_circle/core/archetypes/archetype_history.dart';
import 'package:esoteric_circle/core/archetypes/archetype_sky.dart';
import 'package:esoteric_circle/core/archetypes/ripetizione_del_test.dart';
import 'package:esoteric_circle/core/astro/natal_chart_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
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

/// L'ARCHETIPO SI RILEGGE A SCHERMO. Ordine AO voce 06.
///
/// Le prove del cuore, cioe' la lettura del giorno e la regola dei tre mesi,
/// stanno in `test/l_archetipo_si_rilegge_test.dart`. Qui si guarda cio' che
/// la persona VEDE riaprendo il Test: il suo emblema, la lettura di oggi, e
/// l'attesa dichiarata con la data invece di un pulsante spento.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Un disco che porta un test gia' fatto, nel giorno dato.
  void discoConTestDel(DateTime quando) {
    // La chiave e il formato sono quelli veri di `ArchetypeHistory`: una
    // riga JSON per esito, sotto `archetipo.storico`. Scriverne un altro
    // vorrebbe dire provare una cosa che l'app non legge.
    SharedPreferences.setMockInitialValues({
      'archetipo.storico': <String>[
        '{"quando":"${quando.toIso8601String()}","dominante":"mago",'
            '"secondo":"saggio","percentuali":{"mago":60.0,"saggio":40.0}}',
      ],
    });
  }

  Future<void> apri(WidgetTester tester, {required DateTime adesso}) async {
    final storico = ArchetypeHistory();
    await storico.carica();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider<ArchetypeHistory>.value(value: storico),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MaestroScope(child: child!),
        home: ArchetypeTestScreen(
          clock: () => adesso,
          pianetiDelGiorno: ArchetypeSky.pianetiDelGiorno,
        ),
      ),
    ));
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  testWidgets('chi lo ha gia\' fatto vede il suo emblema e la lettura di oggi',
      (tester) async {
    discoConTestDel(DateTime(2026, 8, 1));
    await apri(tester, adesso: DateTime(2026, 8, 18));

    expect(find.byKey(const Key('archetype_lettura_di_oggi')), findsOneWidget,
        reason: 'riaprendo il Test non si vede la lettura di oggi: e\' il '
            'difetto del collaudo, dove non si poteva fare piu\' nulla');
    expect(find.byKey(const Key('archetype_emblema')), findsOneWidget,
        reason: 'manca l\'emblema, che e\' la cosa piu\' sua che ci sia');
    final nome =
        tester.widget<Text>(find.byKey(const Key('archetype_nome_dominante')));
    // ignore: avoid_print
    print('ORDINE AO VOCE 06: riaprendo si legge "${nome.data}"');
    expect(nome.data, contains(Archetype.mago.nome),
        reason: 'l\'archetipo mostrato non e\' quello salvato');
  });

  testWidgets('e la lettura cambia col giorno, a parita\' di archetipo',
      (tester) async {
    // **DUE GIORNI, e la stessa persona.** Se la scena mostrasse una frase
    // fissa, questa prova non se ne accorgerebbe guardando un giorno solo.
    discoConTestDel(DateTime(2026, 8, 1));
    await apri(tester, adesso: DateTime(2026, 8, 18));
    final primo = tester
        .widgetList<Text>(find.descendant(
            of: find.byKey(const Key('archetype_lettura_di_oggi')),
            matching: find.byType(Text)))
        .map((t) => t.data)
        .join(' ');

    discoConTestDel(DateTime(2026, 8, 1));
    await apri(tester, adesso: DateTime(2026, 8, 26));
    final secondo = tester
        .widgetList<Text>(find.descendant(
            of: find.byKey(const Key('archetype_lettura_di_oggi')),
            matching: find.byType(Text)))
        .map((t) => t.data)
        .join(' ');

    // ignore: avoid_print
    print('ORDINE AO VOCE 06: il 18 agosto e il 26 agosto dicono la stessa '
        'cosa? ${primo == secondo}');
    expect(primo, isNot(secondo),
        reason: 'la lettura di oggi non cambia fra il 18 e il 26 agosto: e\' '
            'una frase fissa con un nome che promette altro');
  });

  testWidgets('prima dei tre mesi non si comincia, e la data si legge',
      (tester) async {
    discoConTestDel(DateTime(2026, 8, 1));
    await apri(tester, adesso: DateTime(2026, 8, 18));

    expect(find.byKey(const Key('archetype_start')), findsNothing,
        reason: 'si puo\' ricominciare diciassette giorni dopo l\'ultimo '
            'test: la decisione del 18 agosto dice tre mesi');
    final attesa =
        tester.widget<Text>(find.byKey(const Key('archetype_attesa')));
    // ignore: avoid_print
    print('ORDINE AO VOCE 06: a schermo si legge "${attesa.data}"');
    expect(attesa.data, contains('30 ottobre 2026'),
        reason: 'l\'attesa non dichiara la data in cui si potra\': '
            '"${attesa.data}"');
  });

  testWidgets('passati i tre mesi si comincia di nuovo', (tester) async {
    final ultimo = DateTime(2026, 8, 1);
    discoConTestDel(ultimo);
    await apri(tester,
        adesso: RipetizioneDelTest.quandoSiPotra(ultimo)
            .add(const Duration(days: 1)));
    expect(find.byKey(const Key('archetype_start')), findsOneWidget,
        reason: 'passati tre mesi il test non si puo\' rifare: era il '
            'contrario della decisione');
  });

  testWidgets('chi non lo ha mai fatto trova l\'invito di sempre',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await apri(tester, adesso: DateTime(2026, 8, 18));
    expect(find.byKey(const Key('archetype_start')), findsOneWidget,
        reason: 'il primo test non aspetta nessuno');
    expect(find.byKey(const Key('archetype_lettura_di_oggi')), findsNothing,
        reason: 'senza un test fatto non c\'e\' nessuna lettura da dare');
  });

  testWidgets('dal Passaporto l\'emblema si tocca e apre il Test',
      (tester) async {
    // **LA TERZA COSA DELLA VOCE.** L'emblema era un'immagine e basta,
    // verificato nella premessa P7: nessun InkWell, nessun tocco, nessuna
    // navigazione. Era la figura piu' personale del Passaporto e l'unica
    // tessera che non portava da nessuna parte.
    discoConTestDel(DateTime(2026, 8, 1));
    final storico = ArchetypeHistory();
    await storico.carica();
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => NatalChartController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider<ArchetypeHistory>.value(value: storico),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MaestroScope(child: child!),
        home: const Scaffold(body: CosmicPassport()),
      ),
    ));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }

    final tessera = find.byKey(const Key('passport_archetipo_tocco'));
    expect(tessera, findsOneWidget,
        reason: 'la tessera dell\'archetipo non si tocca: e\' rimasta '
            'un\'immagine e basta');
    // **PRIMA SI PORTA IN VISTA, poi si tocca.** La tessera vive in fondo a
    // un passaporto lungo: un tocco su un widget fuori schermo non colpisce
    // niente e la prova accuserebbe il tocco di non funzionare.
    await tester.scrollUntilVisible(tessera, 200,
        scrollable: find.byType(Scrollable).first);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(tessera, warnIfMissed: false);
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    expect(find.byType(ArchetypeTestScreen), findsOneWidget,
        reason: 'toccando l\'emblema il Test non si apre');
    // E dentro si trova la lettura, non una soglia muta.
    expect(find.byKey(const Key('archetype_lettura_di_oggi')), findsOneWidget,
        reason: 'il Test aperto dal Passaporto non mostra la lettura di oggi');
  });
}
