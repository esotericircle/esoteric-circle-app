import 'package:esoteric_circle/core/arts/art_catalog.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/feature_flags/feature_flag_service.dart';
import 'package:esoteric_circle/core/horoscope/astro_tradition.dart';
import 'package:esoteric_circle/core/lang/euphonic.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/santuario/function_shelf.dart';
import 'package:esoteric_circle/design_system/components/art_card.dart';
import 'package:esoteric_circle/design_system/components/scroll_reveal.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/art_navigation.dart';
import 'package:esoteric_circle/features/maestri/maestro_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Il catalogo delle arti e il dominio del Maestro.
///
/// Qui si verifica la regola che tiene in piedi tutto il dominio: lo stato di
/// un'arte lo dice il catalogo, uno solo, e nessuna schermata lo forza. Le arti
/// attive si aprono davvero, le Premium mostrano il lucchetto, quelle in arrivo
/// restano leggibili e dicono la loro fase.
void main() {
  Widget domain(Maestro m) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => EntitlementService()),
          ChangeNotifierProvider(create: (_) => ProfileController()),
          ChangeNotifierProvider(create: (_) => BirthIdentityController()),
          ChangeNotifierProvider(
            create: (ctx) =>
                FeatureFlagService(entitlement: ctx.read<EntitlementService>())
                  ..initialize(),
          ),
        ],
        child: MaterialApp(
          home: MaestroScope(child: Scaffold(body: MaestroScreen(maestro: m))),
        ),
      );

  group('Catalogo delle arti', () {
    test('Ogni Maestro ha le sue sottocategorie, nell\'ordine', () {
      expect(ArtCatalog.forMaestro(Maestro.medora).map((s) => s.title),
          ['Astrologia', 'Cartomanzia', 'Lunologia', 'Destino']);
      expect(ArtCatalog.forMaestro(Maestro.aura).map((s) => s.title),
          ['Chakra', 'Energia', 'Archetipi']);
      expect(ArtCatalog.forMaestro(Maestro.caligo).map((s) => s.title),
          ['Rune', 'Rituali', 'Cabala']);
    });

    test('Nessuna arte compare due volte, in nessun dominio', () {
      final ids = ArtCatalog.all.map((a) => a.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('Lo stato dichiarato e\' quello atteso, voce per voce', () {
      ArtEntry find(String id) =>
          ArtCatalog.all.firstWhere((a) => a.id == id);

      // Vive adesso.
      expect(find('horoscope').state, ArtState.attiva);
      expect(find('synastry_vip').state, ArtState.attiva);
      expect(find('tarot_spread_three').state, ArtState.attiva);
      expect(find('meditation').state, ArtState.attiva);
      // Chiusa dietro il Cerchio, non in arrivo: e' fatta, si sblocca.
      expect(find('synastry_depth').state, ArtState.premium);
      // In cammino, ciascuna con la sua fase.
      expect(find('natal_chart').state, ArtState.inArrivo);
      expect(find('natal_chart').phase, 'MVP');
      expect(find('guardian_angel').phase, 'MVP');
      expect(find('astrocartography').phase, 'Fase 4');
    });

    test('La Lunologia e\' la quarta sottocategoria di Medora, con quattro arti',
        () {
      final luna = ArtCatalog.forMaestro(Maestro.medora)
          .firstWhere((s) => s.title == 'Lunologia');
      expect(luna.arts.length, 4);
      expect(luna.arts.map((a) => a.id), [
        'lunology',
        'fertility_windows',
        'lunar_affinity',
        'lunar_calendar',
      ]);
      // Nessuna e' attiva in Demo: sono tutte in cammino, ognuna con la sua
      // fase, e la loro rotta cade sull'anticipo invece che su una schermata.
      for (final a in luna.arts) {
        expect(a.state, ArtState.inArrivo, reason: a.id);
        expect(a.phase, isNotNull, reason: a.id);
        expect(artRouteFor(a.id, userSign: Zodiac.aries), isNull, reason: a.id);
      }
      expect(luna.arts.firstWhere((a) => a.id == 'lunology').phase, 'Fase 2');
      expect(
          luna.arts.firstWhere((a) => a.id == 'lunar_affinity').phase, 'Fase 2');
    });

    test('Compatibilità tra Amici sta in Astrologia, distinta dalle altre', () {
      final astro = ArtCatalog.forMaestro(Maestro.medora)
          .firstWhere((s) => s.title == 'Astrologia');
      final amici =
          astro.arts.firstWhere((a) => a.id == 'friends_compatibility');
      expect(amici.title, 'Compatibilità tra Amici');
      expect(amici.state, ArtState.inArrivo);
      expect(amici.phase, 'Fase viralità sociale');
      // Non e' la Sinastria VIP e non e' l'Affinità Lunare.
      expect(astro.arts.map((a) => a.id), contains('synastry_vip'));
      expect(astro.arts.map((a) => a.id), isNot(contains('lunar_affinity')));
    });

    test('Le astrologie non occidentali non hanno una card propria', () {
      // Vivono come tradizioni dentro l'Oroscopo, non come arti del dominio.
      final ids = ArtCatalog.all.map((a) => a.id);
      for (final id in const ['vedic_astrology', 'bazi', 'other_traditions']) {
        expect(ids, isNot(contains(id)));
      }
      for (final t in AstroTradition.values) {
        if (t == AstroTradition.occidentale) continue;
        expect(t.unlocked, isFalse, reason: t.name);
        expect(t.phase, isNotNull, reason: t.name);
        expect(t.invito.trim(), isNotEmpty, reason: t.name);
      }
      expect(AstroTradition.predefinita, AstroTradition.occidentale);
      expect(AstroTradition.occidentale.unlocked, isTrue);
    });

    test('Il nome del livello si accorda alla preposizione', () {
      // "col L'Adepto" era sbagliato: l'articolo si fonde nella preposizione e
      // il nome resta maiuscolo.
      expect(conPiano('L\'Adepto'), 'con l\'Adepto');
      expect(conPiano('L\'Iniziato'), 'con l\'Iniziato');
      expect(conPiano('Viandante'), 'con il Viandante');
      expect(conPiano(PlanCatalog.forTier(Tier.tier2).name), 'con l\'Adepto');
    });

    test('Il nome a video della stesa e\' Stesa di Tarocchi', () {
      expect(
        ArtCatalog.all.firstWhere((a) => a.id == 'tarot_spread_three').title,
        'Stesa di Tarocchi',
      );
      expect(
        FunctionShelf.functions.firstWhere((f) => f.id == 'tarot_spread_three').title,
        'Stesa di Tarocchi',
      );
    });

    test('Ogni arte attiva ha una rotta vera, nessuna attiva a vuoto', () {
      for (final m in Maestro.values) {
        for (final a in ArtCatalog.activeOf(m)) {
          expect(
            artRouteFor(a.id, userSign: Zodiac.aries),
            isNotNull,
            reason: 'l\'arte attiva ${a.id} non ha una rotta',
          );
        }
      }
    });

    test('Ogni arte in arrivo dichiara la fase, ogni Premium il livello', () {
      for (final a in ArtCatalog.all) {
        if (a.state == ArtState.inArrivo) {
          expect(a.phase, isNotNull, reason: '${a.id} senza fase');
        }
        if (a.state == ArtState.premium) {
          expect(a.requiredTier, isNotNull, reason: '${a.id} senza livello');
        }
        // Il teaser esiste sempre: lo stato non e' mai una scusa per una card
        // muta, nemmeno per le arti che devono ancora arrivare.
        expect(a.teaser.trim(), isNotEmpty);
      }
    });

    test('La Numerologia e\' di Caligo, sotto Cabala', () {
      final cabala = ArtCatalog.forMaestro(Maestro.caligo)
          .firstWhere((s) => s.title == 'Cabala');
      expect(cabala.arts.map((a) => a.id), contains('numerology'));
      expect(
        ArtCatalog.forMaestro(Maestro.medora)
            .expand((s) => s.arts)
            .map((a) => a.id),
        isNot(contains('numerology')),
      );
    });

    test('Lo scaffale del Santuario e il dominio usano la stessa mappa', () {
      // Ogni funzione dello scaffale che nel dominio e' attiva si apre anche
      // dallo scaffale: una sola mappa, nessuna divergenza possibile.
      for (final f in FunctionShelf.functions) {
        final art =
            ArtCatalog.all.where((a) => a.id == f.id).cast<ArtEntry?>().firstOrNull;
        if (art != null && art.state == ArtState.attiva) {
          expect(artRouteFor(f.id, userSign: Zodiac.aries), isNotNull);
        }
      }
    });
  });

  group('Il dominio del Maestro', () {
    testWidgets('Mostra i riquadri per sottocategoria', (tester) async {
      await tester.pumpWidget(domain(Maestro.medora));
      await tester.pump();
      expect(find.byKey(const Key('art_section_astrologia')), findsOneWidget);
      // Gli altri riquadri sono piu' in basso nella lista pigra.
      for (final t in const ['cartomanzia', 'lunologia', 'destino']) {
        await tester.scrollUntilVisible(
          find.byKey(Key('art_section_$t')),
          260,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.byKey(Key('art_section_$t')), findsOneWidget);
      }
    });

    testWidgets('Ogni sottocategoria conta le arti che contiene',
        (tester) async {
      await tester.pumpWidget(domain(Maestro.medora));
      await tester.pump();
      for (final s in ArtCatalog.forMaestro(Maestro.medora)) {
        final chiave = Key('art_section_count_${s.title.toLowerCase()}');
        await tester.scrollUntilVisible(
          find.byKey(chiave),
          260,
          scrollable: find.byType(Scrollable).first,
        );
        final conta = tester.widget<Text>(find.byKey(chiave));
        expect(conta.data, '· ${s.arts.length}',
            reason: 'contatore sbagliato su ${s.title}');
      }
      // La Lunologia ne conta quattro.
      expect(
        tester
            .widget<Text>(find.byKey(const Key('art_section_count_lunologia')))
            .data,
        '· 4',
      );
    });

    testWidgets('Consulta e\' una voce sola, e non c\'e\' piu\' Parla con',
        (tester) async {
      for (final m in Maestro.values) {
        await tester.pumpWidget(domain(m));
        await tester.pump();
        expect(find.byKey(const Key('domain_consulta_card')), findsOneWidget);
        expect(find.text('Consulta ${m.displayName}'), findsOneWidget);
        expect(find.text('Parla con ${m.displayName}'), findsNothing);
        expect(find.byKey(const Key('domain_ask_card')), findsNothing);
      }
    });

    testWidgets('L\'arte attiva e\' viva, la Premium ha il lucchetto',
        (tester) async {
      await tester.pumpWidget(domain(Maestro.medora));
      await tester.pump();
      // Attiva: badge Attiva, nessun lucchetto.
      expect(find.byKey(const Key('art_state_attiva_horoscope')),
          findsOneWidget);
      expect(find.byKey(const Key('art_lock_horoscope')), findsNothing);
      // Premium: lucchetto e riga che dice come si apre.
      await tester.scrollUntilVisible(
        find.byKey(const Key('art_synastry_depth')),
        260,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byKey(const Key('art_lock_synastry_depth')), findsOneWidget);
      expect(find.byKey(const Key('art_state_premium_synastry_depth')),
          findsOneWidget);
    });

    testWidgets('L\'arte in arrivo resta leggibile', (tester) async {
      await tester.pumpWidget(domain(Maestro.medora));
      await tester.pump();
      await tester.scrollUntilVisible(
        find.byKey(const Key('art_natal_chart')),
        260,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byKey(const Key('art_state_arrivo_natal_chart')),
          findsOneWidget);
      // Velo leggero: il testo resta ben oltre la soglia della leggibilita'.
      final veli = tester
          .widgetList<Opacity>(find.descendant(
            of: find.byKey(const Key('art_natal_chart')),
            matching: find.byType(Opacity),
          ))
          .map((o) => o.opacity);
      for (final v in veli) {
        expect(v, greaterThanOrEqualTo(0.8));
      }
    });

    testWidgets('Alla persona si dice solo "In arrivo", la fase resta in Demo',
        (tester) async {
      const arte = ArtEntry(
        id: 'prova',
        title: 'Arte di prova',
        teaser: 'Un teaser qualunque.',
        icon: Icons.star,
        state: ArtState.inArrivo,
        phase: 'Fase 2',
      );
      final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));

      Future<void> mount(bool showPhase) => tester.pumpWidget(MaterialApp(
            home: Scaffold(
              body: ArtCard(art: arte, palette: palette, showPhase: showPhase),
            ),
          ));

      // Vista utente: nessuna fase, mai.
      await mount(false);
      expect(find.text('In arrivo'), findsOneWidget);
      expect(find.textContaining('Fase 2'), findsNothing);

      // Vista Demo per gli investitori: la fase si vede.
      await mount(true);
      expect(find.text('In arrivo, Fase 2'), findsOneWidget);
    });

    testWidgets('La Premium dice "si apre con l\'Adepto", non "col"',
        (tester) async {
      final arte = ArtCatalog.all.firstWhere((a) => a.id == 'synastry_depth');
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: ArtCard(
              art: arte, palette: MaestroPalette.forKey(const ThemeKey.of(Maestro.medora))),
        ),
      ));
      expect(find.text('Si apre con l\'Adepto'), findsOneWidget);
    });

    testWidgets('Con Riduci Movimento la comparsa non anima nulla',
        (tester) async {
      // Riduci Movimento va acceso DENTRO l'app: MaterialApp costruisce il suo
      // MediaQuery dalla vista e coprirebbe uno messo piu' in alto.
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => EntitlementService()),
          ChangeNotifierProvider(create: (_) => ProfileController()),
          ChangeNotifierProvider(create: (_) => BirthIdentityController()),
          ChangeNotifierProvider(
            create: (ctx) =>
                FeatureFlagService(entitlement: ctx.read<EntitlementService>())
                  ..initialize(),
          ),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: true),
              child: const MaestroScope(
                child: Scaffold(
                    body: MaestroScreen(maestro: Maestro.medora)),
              ),
            ),
          ),
        ),
      ));
      await tester.pump();
      // Nessuna dissolvenza in corso: il testo e' subito pienamente leggibile.
      final veli = tester
          .widgetList<Opacity>(find.descendant(
            of: find.byKey(const Key('art_horoscope')),
            matching: find.byType(Opacity),
          ))
          .map((o) => o.opacity);
      for (final v in veli) {
        expect(v, 1.0);
      }
      expect(
        find.descendant(
          of: find.byKey(const Key('art_section_astrologia')),
          matching: find.byType(ScrollReveal),
        ),
        findsWidgets,
      );
    });
  });
}
