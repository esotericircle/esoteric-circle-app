// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/pricing/pricing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// **IL BADGE "PIANO ATTUALE" STA SUL PIANO CHE E' DAVVERO ATTIVO.**
///
/// ## IL FATTO DEL FONDATORE, 23 settembre 2026
///
/// > *"Attivo il piano Premium e i contatori nella chat effettivamente vengono
/// > aggiornati e premium, ma se torno al menu' abbonamenti c'e' scritto che
/// > il piano attualmente e' DEMO"*
///
/// Aveva ragione, **e il piano era attivo davvero**: verificato sui log del
/// server (`attivaIlPianoInDemo: piano scritto`, tier3), sul documento di
/// Firestore (`piano: "tier3"`) e sulla sincronizzazione che l'app chiama
/// quattro decimi di secondo dopo. **A mentire era solo questa schermata.**
///
/// ## LA CAUSA, E PERCHE' ERA GIUSTA PRIMA
///
/// La riga diceva `isCurrent: !isDemo && plan.tier == current`: in Demo il
/// badge non compariva **mai** sui livelli e restava sulla card Demo.
///
/// **Era corretto finche' in Demo nessun livello era davvero attivo.**
/// L'ordine CQ voce 1.01 ha cambiato quel fatto, dando alla Demo un piano vero
/// scritto sul server, e questa riga e' rimasta indietro. **Padre: ordine CQ
/// voce 1.01.**
///
/// E' la stessa forma di difetto dell'ordine EH: **una cosa che era vera ieri
/// e che nessuno ha rimisurato quando il fatto sotto e' cambiato.**
void main() {
  Widget conPiano(Tier tier, {required bool isDemo}) {
    final servizio = EntitlementService()..setTier(tier);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: servizio),
        // Il tema dei Maestri vuole sapere chi presiede la schermata.
        ChangeNotifierProvider(create: (_) => MaestroController()),
        // Le card con la profondita' chiedono il livello di qualita'.
        ChangeNotifierProvider(create: (_) => QualityTierController()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (ctx, child) => MaestroScope(child: child!),
        home: PricingScreen(isDemo: isDemo),
      ),
    );
  }

  /// **LA FINESTRA E' ALTA APPOSTA.** La schermata dei piani e' una
  /// `ListView`, e una lista pigra **non costruisce cio' che sta fuori
  /// schermo**: con la finestra di serie il badge del livello attivo non
  /// esisteva affatto nell'albero, e la prova leggeva zero senza che il
  /// difetto c'entrasse niente.
  void unaFinestraCheTieneTuttiIPiani(WidgetTester t) {
    t.view.physicalSize = const Size(1170, 7000);
    t.view.devicePixelRatio = 3.0;
    addTearDown(t.view.reset);
  }

  /// **SI SCORRE FINO ALL'ULTIMO PIANO, come farebbe una persona.** La
  /// `ListView` e' pigra e con la sola finestra alta la card dell'Illuminato
  /// **non veniva costruita affatto**: la prova leggeva zero badge e il
  /// difetto non c'entrava niente. Chi guarda a video scorre, e qui si scorre.
  Future<void> finoAlPiano(WidgetTester t, Tier quale) async {
    await t.scrollUntilVisible(
      find.byKey(Key('plan_${quale.name}')),
      400,
      scrollable: find.byType(Scrollable).first,
      maxScrolls: 30,
    );
    await t.pump();
  }

  /// Quante volte compare il badge, e su quale card.
  Future<({int quanti, bool sullaDemo})> badge(WidgetTester t) async {
    final tutti = find.text('Piano Attuale');
    final quanti = tutti.evaluate().length;
    final sullaDemo = find
        .descendant(of: find.byKey(const Key('plan_demo')), matching: tutti)
        .evaluate()
        .isNotEmpty;
    return (quanti: quanti, sullaDemo: sullaDemo);
  }

  // **LAPIDE, 1 ottobre 2026, ordine EU voce 07.** Qui si pretendeva il badge
  // sulla card Demo quando il piano e' "free". Ma nella demo il piano "free"
  // e' il Viandante, coi suoi lucchetti (la Lunga, la Cinese, la Vedica, gli
  // amici), e da quando il fondatore lo sceglie dal telefono per le prove
  // (*"Per ora è necessario rendere disponibile il cambio di abbonamento in
  // "viandante" per fare le prove."*) il badge sta sulla scheda del
  // Viandante, e la card Demo resta la presentazione.
  testWidgets('in Demo col Viandante, il badge sta sul Viandante', (t) async {
    unaFinestraCheTieneTuttiIPiani(t);
    await t.pumpWidget(conPiano(Tier.free, isDemo: true));
    await t.pump();
    final b = await badge(t);
    print('ORDINE EU: badge in Demo col Viandante, quanti ${b.quanti}, '
        'sulla card Demo ${b.sullaDemo}');
    expect(b.sullaDemo, isFalse,
        reason: 'col Viandante la card Demo dice di essere il piano attuale');
    expect(
        find.descendant(
            of: find.byKey(const Key('plan_free')),
            matching: find.text('Piano Attuale')),
        findsOneWidget,
        reason: 'il Viandante attivo non porta il badge');
    expect(find.byKey(const Key('choose_free')), findsNothing,
        reason: 'il Viandante gia\' attivo offre ancora di passarci');
  });

  testWidgets(
      'in Demo, da un piano a pagamento si passa al Viandante e si '
      'torna indietro', (t) async {
    unaFinestraCheTieneTuttiIPiani(t);
    await t.pumpWidget(conPiano(Tier.tier3, isDemo: true));
    await t.pump();
    final viandante = find.byKey(const Key('choose_free'));
    expect(viandante, findsOneWidget,
        reason: 'nella demo il Viandante non si sceglie dal telefono');
    await t.ensureVisible(viandante);
    await t.tap(viandante);
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));
    final servizio = t
        .element(find.byKey(const Key('plan_free')))
        .read<EntitlementService>();
    expect(servizio.tier, Tier.free, reason: 'il tocco non porta al Viandante');
    // L'avviso del cambio se ne va da solo: finche' c'e', copre il fondo.
    await t.pump(const Duration(seconds: 5));
    await t.pumpAndSettle();
    // E indietro: l'Illuminato si sceglie col suo pulsante, come sempre.
    final illuminato = find.byKey(const Key('choose_tier3'));
    // Sotto la lista c'e' la striscia fissa della demo: si scorre finche' il
    // dito prende davvero il pulsante.
    for (var i = 0;
        i < 12 && illuminato.hitTestable().evaluate().isEmpty;
        i++) {
      await t.drag(
          find.byKey(const Key('pricing_list')), const Offset(0, -250));
      await t.pumpAndSettle();
    }
    await t.tap(illuminato);
    await t.pumpAndSettle();
    await t.tap(find.byKey(const Key('activate_demo')));
    await t.pump();
    await t.pump(const Duration(milliseconds: 300));
    expect(servizio.tier, Tier.tier3, reason: 'non si torna al piano di prima');
    print('ORDINE EU: piani raggiungibili dal telefono nella demo 4 su 4');
  });

  testWidgets('fuori dalla demo il Viandante non si sceglie', (t) async {
    unaFinestraCheTieneTuttiIPiani(t);
    await t.pumpWidget(conPiano(Tier.tier3, isDemo: false));
    await t.pump();
    expect(find.byKey(const Key('choose_free')), findsNothing,
        reason: 'il pulsante del Viandante esiste nella versione per il '
            'pubblico');
  });

  testWidgets('attivato un piano, il badge lascia la card Demo e lo segue',
      (t) async {
    unaFinestraCheTieneTuttiIPiani(t);
    await t.pumpWidget(conPiano(Tier.tier3, isDemo: true));
    await t.pump();
    await finoAlPiano(t, Tier.tier3);
    final b = await badge(t);
    print('ORDINE EG: badge in Demo col tier3 attivo, quanti ${b.quanti}, '
        'sulla card Demo ${b.sullaDemo}');

    // **LA COSA CHE IL FONDATORE HA VISTO.** Col piano attivo la card Demo
    // continuava a portare il badge, e i livelli non ne avevano nessuno: la
    // schermata diceva che il piano attuale era la Demo mentre il server, i
    // contatori e la chat dicevano Illuminato.
    expect(b.sullaDemo, isFalse,
        reason: 'col piano attivo la card Demo dice ancora di essere il piano '
            'attuale, e il fondatore legge "DEMO" mentre i contatori della '
            'chat sono gia\' quelli dell\'Illuminato');

    // **E uno ci deve essere**, perche' un badge che sparisce del tutto
    // lascerebbe la schermata senza dire quale piano e' attivo.
    expect(b.quanti, 1,
        reason: 'i badge "Piano Attuale" a video sono ${b.quanti}: uno solo '
            'dice la verita\', zero non dice niente e due si contraddicono');
  });

  testWidgets('fuori dalla Demo niente cambia: il badge sta sul piano',
      (t) async {
    unaFinestraCheTieneTuttiIPiani(t);
    await t.pumpWidget(conPiano(Tier.tier2, isDemo: false));
    await t.pump();
    await finoAlPiano(t, Tier.tier2);
    final b = await badge(t);
    expect(b.quanti, 1);
    expect(b.sullaDemo, isFalse,
        reason: 'fuori dalla Demo la card Demo non esiste nemmeno');
  });

  test('la prova resta scritta su disco', () {
    final b = StringBuffer()
      ..writeln('IL BADGE "PIANO ATTUALE" STA SUL PIANO CHE E\' DAVVERO ATTIVO')
      ..writeln()
      ..writeln('IL FATTO, 23 settembre 2026, parole del fondatore:')
      ..writeln('  "Attivo il piano Premium e i contatori nella chat')
      ..writeln(
          '   effettivamente vengono aggiornati e premium, ma se torno al')
      ..writeln(
          '   menu abbonamenti c\'e\' scritto che il piano attualmente e\'')
      ..writeln('   DEMO"')
      ..writeln()
      ..writeln('IL PIANO ERA ATTIVO DAVVERO, verificato in quattro punti:')
      ..writeln('  1. log del server: "attivaIlPianoInDemo: piano scritto",')
      ..writeln('     uid gRKTAtqFdHUK6u5yNUm6LR2EkGZ2, piano tier3')
      ..writeln('  2. Firestore, users/<uid>/stato/abbonamento: piano "tier3"')
      ..writeln('  3. la funzione statodelcerchio chiamata 0,4 secondi dopo')
      ..writeln('  4. i contatori della chat diventati quelli dell\'Illuminato')
      ..writeln()
      ..writeln('A MENTIRE ERA SOLO LA SCHERMATA DEI PIANI.')
      ..writeln()
      ..writeln('LA CAUSA: isCurrent: !isDemo && plan.tier == current')
      ..writeln('  In Demo il badge non compariva MAI sui livelli.')
      ..writeln('  Era giusto finche\' in Demo nessun livello era davvero')
      ..writeln('  attivo; l\'ordine CQ voce 1.01 ha cambiato quel fatto e')
      ..writeln('  questa riga e\' rimasta indietro.')
      ..writeln('  PADRE: ordine CQ voce 1.01.')
      ..writeln()
      ..writeln('LA CURA: il badge segue il piano vero anche in Demo, e la')
      ..writeln('card Demo lo porta solo finche\' nessun livello e\' attivo.')
      ..writeln('Mai due badge insieme, mai zero.');
    final cartella = Directory('docs/collaudo/EG')..createSync(recursive: true);
    final f = File('${cartella.path}/il_piano_attuale.txt')
      ..writeAsStringSync(b.toString());
    expect(f.lengthSync(), greaterThan(700));
  });
}
