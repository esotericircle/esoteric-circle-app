import 'package:esoteric_circle/core/arts/art_catalog.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
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
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/santuario/function_shelf.dart';
import 'package:esoteric_circle/design_system/components/art_card.dart';
import 'package:esoteric_circle/design_system/components/scroll_reveal.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/tokens/color_tokens.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/art_navigation.dart';
import 'package:esoteric_circle/features/maestri/domain_screen.dart';
import 'package:esoteric_circle/features/maestri/maestro_screen.dart';
import 'package:esoteric_circle/features/maestri/widgets/domain_pillars.dart';
import 'package:esoteric_circle/features/maestri/widgets/maestro_presence.dart';
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
  // Il tema del dominio lo decide il Maestro attivo, come nell'app vera, dove
  // si entra nel dominio dopo aver selezionato il Maestro nel Santuario.
  Widget domain(Maestro m, {bool demo = true}) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => MaestroController(initial: ThemeKey.of(m))),
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
          home: MaestroScope(
            child: Scaffold(body: MaestroScreen(maestro: m, demo: demo)),
          ),
        ),
      );

  /// Porta un comando dentro la finestra e lo tocca: la lista del dominio e'
  /// piu' alta della viewport dei test, quindi senza questo il tocco cade fuori.
  Future<void> tocca(WidgetTester tester, Key chiave) async {
    await tester.scrollUntilVisible(
      find.byKey(chiave),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(find.byKey(chiave));
    await tester.pump();
    await tester.tap(find.byKey(chiave));
  }

  group('Catalogo delle arti', () {
    test('Ogni Maestro ha le sue sottocategorie, nell\'ordine', () {
      expect(ArtCatalog.forMaestro(Maestro.medora).map((s) => s.title),
          ['Astrologia', 'Compatibilità', 'Cartomanzia', 'Lunologia', 'Destino']);
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

    test('Il Destino di Medora ha tre arti, col Destino Narrativo', () {
      final destino = ArtCatalog.forMaestro(Maestro.medora)
          .firstWhere((s) => s.title == 'Destino');
      expect(destino.arts.length, 3);
      expect(destino.arts.map((a) => a.id),
          ['guardian_angel', 'karmic_reading', 'narrative_destiny']);
      final narrativo =
          destino.arts.firstWhere((a) => a.id == 'narrative_destiny');
      expect(narrativo.title, 'Destino Narrativo');
      expect(narrativo.state, ArtState.inArrivo);
      expect(narrativo.phase, ArtPhase.faseSuccessiva);
      // Nessuna schermata vera dietro: la rotta cade sull'anticipo.
      expect(artRouteFor(narrativo.id, userSign: Zodiac.aries), isNull);
      // La sottocategoria resta tutta in cammino, quindi chiusa ed esente.
      expect(ArtCatalog.hasActive(destino), isFalse);
    });

    test('Il dominio di Aura ha le sue tre sottocategorie piene', () {
      Map<String, int> conta(bool demo) => {
            for (final s in ArtCatalog.visibleFor(Maestro.aura, demo: demo))
              s.title: s.arts.length,
          };
      // Le vive davanti, la sottocategoria tutta in cammino in fondo.
      expect(ArtCatalog.visibleFor(Maestro.aura, demo: true).map((s) => s.title),
          ['Energia', 'Archetipi', 'Chakra']);
      // In Demo tutto; alla persona si accorciano solo le due miste, mentre
      // Chakra resta intera perche' e' tutta in cammino, quindi esente.
      expect(conta(true), {'Energia': 8, 'Archetipi': 6, 'Chakra': 6});
      expect(conta(false), {'Energia': 7, 'Archetipi': 4, 'Chakra': 6});

      List<ArtEntry> arti(String titolo) => ArtCatalog.forMaestro(Maestro.aura)
          .firstWhere((s) => s.title == titolo)
          .arts;

      // Energia: una sola viva, la Meditazione con Voce.
      final energia = arti('Energia');
      expect(
        energia.where((a) => a.state == ArtState.attiva).map((a) => a.id),
        ['meditation'],
      );
      expect(energia.firstWhere((a) => a.id == 'meditation').title,
          'Meditazione con Voce');
      expect(energia.map((a) => a.id), [
        'meditation',
        'frequencies',
        'sleep_stories',
        'daily_affirmations',
        'mudra',
        'belief_art',
        'biorhythm',
        'lucid_dreams',
      ]);
      expect(energia.firstWhere((a) => a.id == 'lucid_dreams').phase,
          ArtPhase.fase5);

      // Archetipi: due vive.
      final archetipi = arti('Archetipi');
      expect(
        archetipi.where((a) => a.state == ArtState.attiva).map((a) => a.id),
        ['archetype_test', 'face_constellation'],
      );
      expect(archetipi.map((a) => a.id), [
        'archetype_test',
        'face_constellation',
        'mood_tracker',
        'palmistry',
        'graphology',
        'voice_analysis',
      ]);
      // La Compatibilita' Archetipica e' passata dentro la Sinastria
      // Approfondita di Medora, come livello archetipico.
      expect(archetipi.map((a) => a.id), isNot(contains('archetype_affinity')));

      // Chakra: sei arti, nessuna viva, quindi chiusa ed esente.
      final chakra = arti('Chakra');
      expect(chakra.length, 6);
      expect(
        ArtCatalog.hasActive(ArtCatalog.forMaestro(Maestro.aura)
            .firstWhere((s) => s.title == 'Chakra')),
        isFalse,
      );
      expect(chakra.map((a) => a.id), [
        'chakra_scan',
        'crystal_therapy',
        'crystal_oracle',
        'crystal_ball',
        'energy_cleansing',
        'aura_analysis',
      ]);
    });

    test('Le arti di Aura e di Caligo portano la cornice onesta', () {
      for (final m in const [Maestro.aura, Maestro.caligo]) {
        for (final a in ArtCatalog.forMaestro(m).expand((s) => s.arts)) {
          expect(a.cornice, isTrue, reason: a.id);
        }
      }
      expect(ArtCatalog.disclaimerCornice, contains('non cura medica'));
      expect(ArtCatalog.disclaimerCornice, contains('previsione certa'));
      // Nessuna promessa di guarigione ne' di potere su altri nel testo che si
      // mostra: i riti accompagnano chi li chiede, non agiscono su terzi.
      for (final a in ArtCatalog.all) {
        final testo = '${a.title} ${a.teaser}'.toLowerCase();
        for (final parola in const [
          'guarisc',
          'terapia medica',
          'diagnos',
          'legamento',
          'malocchio',
          'fattura',
        ]) {
          expect(testo, isNot(contains(parola)), reason: a.id);
        }
      }
    });

    test('Il dominio di Caligo ha le sue tre sottocategorie piene', () {
      Map<String, int> conta(bool demo) => {
            for (final s in ArtCatalog.visibleFor(Maestro.caligo, demo: demo))
              s.title: s.arts.length,
          };
      // Rune e Rituali hanno la loro distintiva viva. La Cabala no: uscito
      // l'Albero della Vita dalla Demo, le restano solo arti in cammino.
      expect(
          ArtCatalog.visibleFor(Maestro.caligo, demo: true).map((s) => s.title),
          ['Rune', 'Rituali', 'Cabala']);
      expect(conta(true), {'Rune': 5, 'Rituali': 6, 'Cabala': 4});
      // Nella vista della persona cadono le fasi oltre la Fase 2: i Rituali
      // perdono i Rituali Guidati. La Cabala no: senza piu' nulla di vivo e'
      // esente dalla soglia delle fasi, quindi si mostra intera dietro il suo
      // tocco, come vuole la regola del catalogo.
      expect(conta(false), {'Rune': 5, 'Rituali': 5, 'Cabala': 4});

      List<ArtEntry> arti(String titolo) => ArtCatalog.forMaestro(Maestro.caligo)
          .firstWhere((s) => s.title == titolo)
          .arts;

      // Una sola distintiva viva per sottocategoria, dove c'e'. La Cabala non
      // ne ha piu': l'Albero della Vita e' uscito dalla Demo.
      for (final t in const ['Rune', 'Rituali']) {
        expect(arti(t).where((a) => a.state == ArtState.attiva).length, 1,
            reason: t);
      }
      expect(arti('Cabala').where((a) => a.state == ArtState.attiva), isEmpty);
      expect(arti('Rune').map((a) => a.id), [
        'rune_draw',
        'i_ching',
        'pendulum',
        'coffee_reading',
        'dream_reading',
      ]);
      expect(arti('Rituali').map((a) => a.id), [
        'guide_animal',
        'animal_message',
        'magic_sigil',
        'micro_rituals',
        'daily_invocation',
        'guided_rituals',
      ]);
      expect(arti('Cabala').map((a) => a.id), [
        'angel_numbers',
        'numerology',
        'human_design',
        'cosmic_wrapped',
      ]);
      // L'Albero della Vita e' uscito dalla Demo, e con lui i settantadue nomi
      // che ne erano contenuto. La Compatibilita' Angelica e' passata alla
      // Sinastria Approfondita.
      expect(arti('Cabala').map((a) => a.id), isNot(contains('tree_of_life')));
      expect(arti('Cabala').map((a) => a.id), isNot(contains('angels_72')));
      expect(
          arti('Cabala').map((a) => a.id), isNot(contains('angel_compatibility')));
      expect(arti('Cabala').firstWhere((a) => a.id == 'angel_numbers').title,
          'Numeri Ricorrenti');
      // Nessuna arte di Caligo nomina piu' gli Angeli.
      for (final a in ArtCatalog.forMaestro(Maestro.caligo).expand((s) => s.arts)) {
        expect('${a.title} ${a.teaser}'.toLowerCase(), isNot(contains('angel')),
            reason: a.id);
      }
      // Le vecchie voci scheletriche non esistono piu'.
      final ids = ArtCatalog.all.map((a) => a.id);
      expect(ids, isNot(contains('extended_oracles')));
      expect(ids, isNot(contains('candle_ritual')));
    });

    test('Le arti vive senza esperienza aprono la soglia, non il vuoto', () {
      // Ogni voce dichiarata viva ha una rotta: o la sua schermata, o la
      // soglia dell'arte. Il debito e' dichiarato in un punto solo.
      for (final id in artiSullaSoglia.keys) {
        final art = ArtCatalog.all.firstWhere((a) => a.id == id);
        expect(art.state, ArtState.attiva, reason: id);
        expect(artRouteFor(id, userSign: Zodiac.aries), isNotNull, reason: id);
      }
      // Nessuna arte resta sulla soglia: l'Albero della Vita e' uscito dalla
      // Demo, tutte le arti attive hanno la loro esperienza vera.
      expect(artiSullaSoglia, isEmpty);
      expect(artRouteFor('tree_of_life', userSign: Zodiac.aries), isNull);
      // L'Animale Guida ha ora la sua esperienza vera: non e' piu' sulla soglia
      // e ha una rotta reale.
      expect(artiSullaSoglia.containsKey('guide_animal'), isFalse);
      expect(artRouteFor('guide_animal', userSign: Zodiac.aries), isNotNull);
      // L'Estrazione Rune ha ora la sua esperienza vera: fuori dalla soglia,
      // con una rotta reale.
      expect(artiSullaSoglia.containsKey('rune_draw'), isFalse);
      expect(artRouteFor('rune_draw', userSign: Zodiac.aries), isNotNull);
    });

    test('La Compatibilità di Medora raccoglie le tre sinastrie', () {
      final comp = ArtCatalog.forMaestro(Maestro.medora)
          .firstWhere((s) => s.title == 'Compatibilità');
      expect(comp.arts.map((a) => a.id),
          ['synastry_vip', 'synastry_depth', 'friends_compatibility']);
      expect(comp.arts[0].state, ArtState.attiva);
      expect(comp.arts[1].state, ArtState.premium);

      final amici =
          comp.arts.firstWhere((a) => a.id == 'friends_compatibility');
      expect(amici.title, 'Compatibilità tra Amici');
      expect(amici.state, ArtState.inArrivo);
      expect(amici.phase, ArtPhase.viralita);

      // La Sinastria Approfondita e' la compatibilita' unificata: i tre livelli
      // stanno dentro di lei, non piu' sparsi su tre Maestri.
      final profonda = comp.arts.firstWhere((a) => a.id == 'synastry_depth');
      for (final livello in const ['astrale', 'angelico', 'archetipico']) {
        expect(profonda.teaser.toLowerCase(), contains(livello));
      }

      // Astrologia non tiene piu' nessuna sinastria, e l'Affinità Lunare resta
      // dove e' sempre stata, in Lunologia.
      final astro = ArtCatalog.forMaestro(Maestro.medora)
          .firstWhere((s) => s.title == 'Astrologia');
      for (final id in const [
        'synastry_vip',
        'synastry_depth',
        'friends_compatibility',
        'lunar_affinity',
      ]) {
        expect(astro.arts.map((a) => a.id), isNot(contains(id)), reason: id);
      }
      expect(astro.arts.map((a) => a.id),
          ['horoscope', 'natal_chart', 'planetary_returns', 'pet_astrology',
           'astrocartography']);
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

    test('Ogni fase usata nel catalogo e\' una di quelle dichiarate', () {
      for (final a in ArtCatalog.all) {
        if (a.phase == null) continue;
        expect(ArtPhase.ordine, contains(a.phase),
            reason: '${a.id} usa una fase sconosciuta: ${a.phase}');
      }
      // L'ordine delle fasi e' quello che decide cosa si mostra.
      expect(ArtPhase.rank(ArtPhase.mvp), lessThan(ArtPhase.rank(ArtPhase.fase2)));
      expect(ArtPhase.rank(ArtPhase.fase2),
          lessThan(ArtPhase.rank(ArtPhase.faseSuccessiva)));
      expect(ArtPhase.rank(ArtPhase.faseSuccessiva),
          lessThan(ArtPhase.rank(ArtPhase.fase3)));
      expect(ArtPhase.rank(ArtPhase.fase3), lessThan(ArtPhase.rank(ArtPhase.fase4)));
      expect(ArtPhase.rank(ArtPhase.fase4),
          lessThan(ArtPhase.rank(ArtPhase.viralita)));
      // Una fase sconosciuta finisce in fondo, quindi resta nascosta.
      expect(ArtPhase.rank('Fase inventata'),
          greaterThan(ArtPhase.rank(ArtPhase.viralita)));
    });

    test('Alla persona si mostra fino alla Fase 2, in Demo tutto', () {
      ArtEntry find(String id) => ArtCatalog.all.firstWhere((a) => a.id == id);

      // Attive e Premium non hanno fase e si vedono sempre.
      expect(ArtCatalog.isVisible(find('horoscope'), demo: false), isTrue);
      expect(ArtCatalog.isVisible(find('synastry_depth'), demo: false), isTrue);
      // Fino alla soglia si vedono.
      expect(ArtCatalog.isVisible(find('natal_chart'), demo: false), isTrue);
      expect(ArtCatalog.isVisible(find('planetary_returns'), demo: false), isTrue);
      expect(ArtCatalog.isVisible(find('pet_astrology'), demo: false), isTrue);
      // Oltre la soglia no, ma restano tutte nel catalogo.
      for (final id in const [
        'astrocartography',
        'friends_compatibility',
        'fertility_windows',
        'lunar_calendar',
        'angel_cards',
      ]) {
        expect(ArtCatalog.isVisible(find(id), demo: false), isFalse, reason: id);
        expect(ArtCatalog.isVisible(find(id), demo: true), isTrue, reason: id);
        expect(ArtCatalog.all.map((a) => a.id), contains(id));
      }
      // L'esenzione toglie di mezzo la soglia: e' quel che vale dentro una
      // sottocategoria dove non c'e' ancora nulla di vivo.
      expect(
        ArtCatalog.isVisible(find('fertility_windows'),
            demo: false, esente: true),
        isTrue,
      );
    });

    test('Una sottocategoria tutta in cammino si mostra intera', () {
      List<String> arti(String titolo, bool demo) => ArtCatalog.visibleArts(
            ArtCatalog.forMaestro(Maestro.medora)
                .firstWhere((s) => s.title == titolo),
            demo: demo,
          ).map((a) => a.id).toList();

      // Lunologia non ha nulla di vivo: sta chiusa dietro un tocco, quindi si
      // mostra intera anche alla persona, fasi lontane comprese.
      const tutta = [
        'lunology',
        'fertility_windows',
        'lunar_affinity',
        'lunar_calendar',
      ];
      expect(arti('Lunologia', true), tutta);
      expect(arti('Lunologia', false), tutta);
      // Anche il Destino, dove il Destino Narrativo e' di fase successiva e
      // senza l'esenzione sparirebbe alla persona.
      const destino = ['guardian_angel', 'karmic_reading', 'narrative_destiny'];
      expect(arti('Destino', true), destino);
      expect(arti('Destino', false), destino);

      // Astrologia e Cartomanzia hanno del vivo: li' la soglia vale ancora.
      expect(arti('Astrologia', false), isNot(contains('astrocartography')));
      expect(arti('Astrologia', false),
          isNot(contains('friends_compatibility')));
      expect(arti('Cartomanzia', false), isNot(contains('angel_cards')));
    });

    test('Le sottocategorie visibili cambiano col punto di vista', () {
      Map<String, int> conta(bool demo) => {
            for (final s in ArtCatalog.visibleFor(Maestro.medora, demo: demo))
              s.title: s.arts.length,
          };
      expect(conta(true), {
        'Astrologia': 5,
        'Compatibilità': 3,
        'Cartomanzia': 3,
        'Lunologia': 4,
        'Destino': 3,
      });
      // Solo le miste si accorciano: le tutte in cammino restano intere.
      expect(conta(false), {
        'Astrologia': 4,
        'Compatibilità': 2,
        'Cartomanzia': 2,
        'Lunologia': 4,
        'Destino': 3,
      });
      // Nessuna sottocategoria vuota arriva a video.
      for (final m in Maestro.values) {
        for (final demo in const [true, false]) {
          for (final s in ArtCatalog.visibleFor(m, demo: demo)) {
            expect(s.arts, isNotEmpty, reason: '${s.title} vuota');
          }
        }
      }
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

    testWidgets('Nella vista utente le fasi lontane non compaiono',
        (tester) async {
      await tester.pumpWidget(domain(Maestro.medora, demo: false));
      await tester.pump();
      // Il contatore conta quel che si vede davvero in questa vista.
      expect(
        tester
            .widget<Text>(find.byKey(const Key('art_section_count_astrologia')))
            .data,
        '· 4',
      );
      // Aprendo il gruppo delle in cammino non spuntano le fasi lontane.
      await tocca(tester, const Key('art_soon_toggle_astrologia'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const Key('art_natal_chart')), findsOneWidget);
      expect(find.byKey(const Key('art_astrocartography')), findsNothing);
      expect(find.byKey(const Key('art_friends_compatibility')), findsNothing);
      // E la fase non si scrive da nessuna parte.
      expect(find.textContaining('Fase '), findsNothing);
      expect(find.text('In arrivo'), findsWidgets);
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

    testWidgets('Stati di partenza: le vive aperte, le altre chiuse',
        (tester) async {
      await tester.pumpWidget(domain(Maestro.medora));
      await tester.pump();

      // Astrologia, Compatibilità e Cartomanzia hanno del vivo: le attive e la
      // Premium si vedono subito, le in cammino stanno dietro l'apri e chiudi.
      expect(find.byKey(const Key('art_horoscope')), findsOneWidget);
      expect(find.byKey(const Key('art_natal_chart')), findsNothing);
      await tester.scrollUntilVisible(
        find.byKey(const Key('art_section_compatibilità')),
        260,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byKey(const Key('art_synastry_vip')), findsOneWidget);
      expect(find.byKey(const Key('art_synastry_depth')), findsOneWidget);
      expect(find.byKey(const Key('art_friends_compatibility')), findsNothing);
      expect(find.byKey(const Key('art_soon_toggle_astrologia')),
          findsOneWidget);
      // Un'intestazione senza freccetta: le sezioni vive non si richiudono.
      expect(find.byKey(const Key('art_section_header_astrologia')),
          findsNothing);
      expect(find.byKey(const Key('art_section_soon_astrologia')), findsNothing);

      // Lunologia e Destino non hanno nulla di vivo: chiuse, con la dicitura.
      for (final t in const ['lunologia', 'destino']) {
        await tester.scrollUntilVisible(
          find.byKey(Key('art_section_$t')),
          260,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.byKey(Key('art_section_soon_$t')), findsOneWidget);
        expect(find.byKey(Key('art_section_header_$t')), findsOneWidget);
      }
      expect(find.byKey(const Key('art_lunology')), findsNothing);
      expect(find.byKey(const Key('art_guardian_angel')), findsNothing);

      // Al tocco dell'intestazione la sottocategoria si apre.
      await tocca(tester, const Key('art_section_header_lunologia'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const Key('art_lunology')), findsOneWidget);
    });

    testWidgets('Le sottocategorie vive vengono prima di quelle in cammino',
        (tester) async {
      // L'ordine e' del catalogo, non della schermata: si verifica li'.
      expect(
        ArtCatalog.visibleFor(Maestro.medora, demo: true).map((s) => s.title),
        ['Astrologia', 'Compatibilità', 'Cartomanzia', 'Lunologia', 'Destino'],
      );
      for (final m in Maestro.values) {
        final sezioni = ArtCatalog.visibleFor(m, demo: true);
        var vistaUnaSenzaVivo = false;
        for (final s in sezioni) {
          if (!ArtCatalog.hasActive(s)) {
            vistaUnaSenzaVivo = true;
          } else {
            expect(vistaUnaSenzaVivo, isFalse,
                reason: '${s.title} viva dopo una tutta in cammino');
          }
        }
      }
    });

    testWidgets('I pilastri sono un sottotitolo, non un comando',
        (tester) async {
      for (final m in Maestro.values) {
        await tester.pumpWidget(ChangeNotifierProvider(
          create: (_) => MaestroController(),
          child: MaterialApp(
            home: MaestroScope(
              child: Scaffold(body: Center(child: DomainPillars(maestro: m))),
            ),
          ),
        ));
        await tester.pump();
        final riga = find.byKey(const Key('domain_pillars'));
        expect(riga, findsOneWidget);
        // I tre pilastri del Maestro, separati dal punto mediano.
        expect(tester.widget<Text>(riga).data,
            m.domainArts.split(',').map((s) => s.trim()).join(' · '));
        // Nessun comando dentro: e' testo e basta.
        for (final tipo in [InkWell, GestureDetector, TextButton]) {
          expect(
            find.descendant(of: riga, matching: find.byType(tipo)),
            findsNothing,
            reason: '${m.displayName}: i pilastri non si toccano',
          );
        }
      }
    });

    testWidgets('I pilastri stanno sotto il nome, in cima alla schermata',
        (tester) async {
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => EntitlementService()),
          ChangeNotifierProvider(create: (_) => ProfileController()),
          ChangeNotifierProvider(create: (_) => BirthIdentityController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
          ChangeNotifierProvider(
            create: (ctx) =>
                FeatureFlagService(entitlement: ctx.read<EntitlementService>())
                  ..initialize(),
          ),
        ],
        child: const MaterialApp(
          home: MaestroScope(child: DomainScreen(maestro: Maestro.medora)),
        ),
      ));
      await tester.pump();

      // Dentro la barra in cima: il nome, e sotto di lui i pilastri.
      final barra = find.byType(AppBar);
      expect(
        find.descendant(of: barra, matching: find.text('Medora')),
        findsOneWidget,
      );
      final pilastri = find.descendant(
          of: barra, matching: find.byKey(const Key('domain_pillars')));
      expect(pilastri, findsOneWidget);
      expect(tester.getCenter(pilastri).dy,
          greaterThan(tester.getCenter(find.text('Medora')).dy));
      // E sopra l'immagine dell'eroe.
      expect(tester.getBottomLeft(pilastri).dy,
          lessThan(tester.getTopLeft(find.byType(MaestroPresence)).dy));

      // Centrati sulla larghezza della SCHERMATA, non sullo spazio che avanza
      // accanto alla freccia: il centro dei due testi cade sulla meta' esatta.
      final meta = tester.view.physicalSize.width / tester.view.devicePixelRatio / 2;
      expect(tester.getCenter(find.text('Medora')).dx, closeTo(meta, 1.0));
      expect(tester.getCenter(pilastri).dx, closeTo(meta, 1.0));

      // La freccia sta a sinistra, sovrapposta, e non sposta il centro.
      final freccia = find.byIcon(Icons.arrow_back_rounded);
      expect(freccia, findsOneWidget);
      expect(tester.getCenter(freccia).dx, lessThan(meta / 2));
    });

    testWidgets('La barra centrata vale per tutti e tre i domini',
        (tester) async {
      for (final m in Maestro.values) {
        await tester.pumpWidget(MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => MaestroController()),
            ChangeNotifierProvider(create: (_) => QualityTierController()),
            ChangeNotifierProvider(create: (_) => EntitlementService()),
            ChangeNotifierProvider(create: (_) => ProfileController()),
            ChangeNotifierProvider(create: (_) => BirthIdentityController()),
            ChangeNotifierProvider(create: (_) => ParallaxController()),
            ChangeNotifierProvider(create: (_) => ZodiacController()),
            ChangeNotifierProvider(
              create: (ctx) =>
                  FeatureFlagService(entitlement: ctx.read<EntitlementService>())
                    ..initialize(),
            ),
          ],
          child: MaterialApp(
            home: MaestroScope(child: DomainScreen(maestro: m)),
          ),
        ));
        await tester.pump();
        final meta =
            tester.view.physicalSize.width / tester.view.devicePixelRatio / 2;
        expect(tester.getCenter(find.text(m.displayName)).dx, closeTo(meta, 1.0),
            reason: 'il nome di ${m.displayName} non e\' centrato');
        expect(
          tester.getCenter(find.byKey(const Key('domain_pillars'))).dx,
          closeTo(meta, 1.0),
          reason: 'i pilastri di ${m.displayName} non sono centrati',
        );
      }
    });

    testWidgets('Il dominio di Aura si compone da solo, senza nulla di cablato',
        (tester) async {
      await tester.pumpWidget(domain(Maestro.aura));
      await tester.pump();

      // Il sottotitolo dei pilastri e' quello di Aura.
      expect(DomainPillars.of(Maestro.aura).join(' · '),
          'Chakra · Energia · Archetipi');

      // Energia per prima, con la sola Meditazione in vista.
      expect(find.byKey(const Key('art_section_energia')), findsOneWidget);
      expect(find.byKey(const Key('art_meditation')), findsOneWidget);
      expect(find.byKey(const Key('art_state_attiva_meditation')),
          findsOneWidget);
      expect(find.byKey(const Key('art_sleep_stories')), findsNothing);
      expect(find.byKey(const Key('art_soon_toggle_energia')), findsOneWidget);

      // Archetipi: due vive in mostra, le altre raccolte.
      await tester.scrollUntilVisible(
        find.byKey(const Key('art_section_archetipi')),
        260,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byKey(const Key('art_archetype_test')), findsOneWidget);
      expect(find.byKey(const Key('art_face_constellation')), findsOneWidget);
      expect(find.byKey(const Key('art_mood_tracker')), findsNothing);

      // Chakra in fondo, chiusa, con la dicitura e il contatore a sei.
      await tester.scrollUntilVisible(
        find.byKey(const Key('art_section_chakra')),
        260,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byKey(const Key('art_section_soon_chakra')), findsOneWidget);
      expect(
        tester
            .widget<Text>(find.byKey(const Key('art_section_count_chakra')))
            .data,
        '· 6',
      );
      expect(find.byKey(const Key('art_chakra_scan')), findsNothing);
      await tocca(tester, const Key('art_section_header_chakra'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byKey(const Key('art_chakra_scan')), findsOneWidget);
      expect(find.byKey(const Key('art_aura_analysis')), findsOneWidget);
    });

    testWidgets('Il verde di Aura cade solo sulle arti vive', (tester) async {
      await tester.pumpWidget(domain(Maestro.aura));
      await tester.pump();
      final verde = MaestroPalette.forKey(const ThemeKey.of(Maestro.aura));

      List<Color> sfondoDi(String id) {
        final box = tester.widget<Container>(find.byKey(Key('art_surface_$id')));
        final deco = box.decoration! as BoxDecoration;
        return (deco.gradient! as LinearGradient).colors;
      }

      // L'attiva porta il verde smeraldo di Aura.
      expect(sfondoDi('meditation').first.toARGB32(),
          verde.surfaceElevated.withValues(alpha: 0.95).toARGB32());

      // Un'arte in cammino no: sta sulla superficie neutra.
      await tocca(tester, const Key('art_soon_toggle_energia'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(sfondoDi('sleep_stories').first.toARGB32(),
          ColorTokens.neutralSurface.withValues(alpha: 0.42).toARGB32());
      expect(sfondoDi('sleep_stories').first.toARGB32(),
          isNot(verde.surfaceElevated.withValues(alpha: 0.95).toARGB32()));
    });

    testWidgets('Il dominio di Caligo mostra le sue distintive vive',
        (tester) async {
      await tester.pumpWidget(domain(Maestro.caligo));
      await tester.pump();

      expect(DomainPillars.of(Maestro.caligo).join(' · '),
          'Rune · Rituali · Cabala');

      final rosso = MaestroPalette.forKey(const ThemeKey.of(Maestro.caligo));
      List<Color> sfondoDi(String id) {
        final box = tester.widget<Container>(find.byKey(Key('art_surface_$id')));
        final deco = box.decoration! as BoxDecoration;
        return (deco.gradient! as LinearGradient).colors;
      }

      // Rune: la distintiva viva col rosso di Caligo, le altre raccolte.
      expect(find.byKey(const Key('art_rune_draw')), findsOneWidget);
      expect(find.byKey(const Key('art_state_attiva_rune_draw')),
          findsOneWidget);
      expect(sfondoDi('rune_draw').first.toARGB32(),
          rosso.surfaceElevated.withValues(alpha: 0.95).toARGB32());
      expect(find.byKey(const Key('art_i_ching')), findsNothing);
      expect(find.byKey(const Key('art_soon_toggle_rune')), findsOneWidget);

      // I Rituali con la loro viva in mostra. La Cabala non ne ha piu'.
      for (final voce in const [
        ('rituali', 'guide_animal'),
      ]) {
        await tester.scrollUntilVisible(
          find.byKey(Key('art_section_${voce.$1}')),
          260,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.byKey(Key('art_${voce.$2}')), findsOneWidget,
            reason: voce.$2);
        expect(find.byKey(Key('art_state_attiva_${voce.$2}')), findsOneWidget);
        expect(find.byKey(Key('art_soon_toggle_${voce.$1}')), findsOneWidget);
      }
      // Rune e Rituali hanno la loro viva, quindi nessuna dicitura. La Cabala,
      // uscito l'Albero della Vita dalla Demo, e' tutta in cammino: porta la
      // dicitura onesta e non il toggle, che vale solo dove c'e' gia' del vivo.
      for (final t in const ['rune', 'rituali']) {
        expect(find.byKey(Key('art_section_soon_$t')), findsNothing);
      }
      await tester.scrollUntilVisible(
        find.byKey(const Key('art_section_cabala')),
        260,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byKey(const Key('art_section_soon_cabala')), findsOneWidget);
      expect(find.byKey(const Key('art_soon_toggle_cabala')), findsNothing);

      // Un'arte in cammino non porta l'accento del Maestro: si apre la Cabala
      // dalla sua intestazione, che qui e' tutta l'area di tocco.
      await tocca(tester, const Key('art_section_header_cabala'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(sfondoDi('angel_numbers').first.toARGB32(),
          ColorTokens.neutralSurface.withValues(alpha: 0.42).toARGB32());
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
      // Le arti in cammino stanno dietro il loro apri e chiudi: prima si apre.
      await tocca(tester, const Key('art_soon_toggle_astrologia'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
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
                    body: MaestroScreen(maestro: Maestro.medora, demo: true)),
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

      // E l'apertura di un gruppo e' istantanea: un solo frame, senza aspettare
      // la durata di nessuna animazione.
      expect(find.byKey(const Key('art_natal_chart')), findsNothing);
      await tocca(tester, const Key('art_soon_toggle_astrologia'));
      await tester.pump();
      expect(find.byKey(const Key('art_natal_chart')), findsOneWidget);
      final freccia = tester.widget<AnimatedRotation>(find
          .descendant(
            of: find.byKey(const Key('art_soon_toggle_astrologia')),
            matching: find.byType(AnimatedRotation),
          )
          .first);
      expect(freccia.duration, Duration.zero);
      expect(freccia.turns, 0.5);
    });
  });
}
