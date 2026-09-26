import 'package:esoteric_circle/core/arts/art_catalog.dart';
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
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/art_navigation.dart';
import 'package:esoteric_circle/features/maestri/domain_screen.dart';
import 'package:esoteric_circle/features/maestri/maestro_screen.dart';
import 'package:esoteric_circle/features/maestri/widgets/domain_pillars.dart';
import 'package:esoteric_circle/features/maestri/widgets/busto_del_maestro.dart';
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

  group('Catalogo delle arti', () {
    test('Ogni Maestro ha le sue sottocategorie, nell\'ordine', () {
      // **LAPIDE: fino all'ordine EN** Medora era Astrologia, Compatibilita',
      // Cartomanzia, Lunologia, Destino; Aura Chakra, Energia, Archetipi;
      // Caligo Rune, Rituali, Magia, Numerologia. **Dall'ordine EO voci 10 e
      // 11** l'ordine e' quello del fondatore, e due sezioni hanno un nome
      // nuovo: Rune e' Divinazione, Archetipi e' Fisiognomica.
      expect(ArtCatalog.forMaestro(Maestro.medora).map((s) => s.title), [
        'Astrologia',
        'Cartomanzia',
        'Compatibilità',
        'Lunologia',
        'Destino'
      ]);
      expect(ArtCatalog.forMaestro(Maestro.aura).map((s) => s.title),
          ['Energia', 'Chakra', 'Fisiognomica']);
      // Magia e' la terza distintiva di Caligo, nata col Sigillo
      // dell'Intenzione: senza, aveva due sottocategorie vive contro le
      // tre di Medora e di Aura.
      expect(ArtCatalog.forMaestro(Maestro.caligo).map((s) => s.title),
          ['Divinazione', 'Rituali', 'Magia', 'Numerologia']);
    });

    test('Nessuna arte compare due volte, in nessun dominio', () {
      final ids = ArtCatalog.all.map((a) => a.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('Lo stato dichiarato e\' quello atteso, voce per voce', () {
      ArtEntry find(String id) => ArtCatalog.all.firstWhere((a) => a.id == id);

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

    test(
        'La Lunologia e\' la quarta sottocategoria di Medora, con quattro arti',
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
        expect(artRouteFor(a.id), isNull, reason: a.id);
      }
      // **IN MVP DALL'ORDINE EN, voce 12**: la scelta del fondatore, *"Ok,
      // Respiro della Luna e Affinità Lunare"*. Le altre due restano dove
      // erano.
      expect(luna.arts.firstWhere((a) => a.id == 'lunology').phase, 'MVP');
      expect(
          luna.arts.firstWhere((a) => a.id == 'lunar_affinity').phase, 'MVP');
      expect(luna.arts.firstWhere((a) => a.id == 'fertility_windows').phase,
          'Fase successiva');
      expect(luna.arts.firstWhere((a) => a.id == 'lunar_calendar').phase,
          'Fase successiva');
    });

    test('Il Destino di Medora ha tre arti, col Destino Narrativo', () {
      final destino = ArtCatalog.forMaestro(Maestro.medora)
          .firstWhere((s) => s.title == 'Destino');
      expect(destino.arts.length, 3);
      // **L'Angelo e' ancora QUI, nel catalogo grezzo**, ed e' giusto cosi':
      // l'ordine DC voce 12 lo toglie dalle VISTE del dominio, non dal
      // catalogo. La schermata esiste, funziona, e si apre dal Passaporto.
      expect(destino.arts.map((a) => a.id),
          ['guardian_angel', 'karmic_reading', 'narrative_destiny']);
      final narrativo =
          destino.arts.firstWhere((a) => a.id == 'narrative_destiny');
      expect(narrativo.title, 'Destino Narrativo');
      expect(narrativo.state, ArtState.inArrivo);
      expect(narrativo.phase, ArtPhase.faseSuccessiva);
      // Nessuna schermata vera dietro: la rotta cade sull'anticipo.
      expect(artRouteFor(narrativo.id), isNull);
      // **IL DESTINO NON E' PIU' TUTTO IN CAMMINO.** Ordine CS, voce S3
      // della scansione, 6 settembre 2026.
      //
      // L'Angelo Custode era dichiarato in arrivo mentre la sua schermata
      // era **viva e raggiungibile** da due punti dell'app, e il fondatore
      // l'ha aperta lui stesso: e' da quella schermata che nasce l'ordine
      // CS. Adesso il catalogo dice cio' che l'app fa.
      final custode = destino.arts.firstWhere((a) => a.id == 'guardian_angel');
      expect(custode.state, ArtState.attiva,
          reason: 'l\'Angelo Custode e\' vivo e il catalogo lo rimette in '
              'arrivo: una funzione viva marcata «in arrivo» e\' un pezzo '
              'di prodotto che nessuno trova');
      expect(destino.arts.any((a) => a.state == ArtState.attiva), isTrue);
      // E dallo scaffale ci si arriva davvero: senza rotta, un'arte
      // dichiarata attiva e' una promessa che si rompe al primo tocco.
      expect(artRouteFor('guardian_angel', userBirth: DateTime(1986, 7, 21)),
          isNotNull,
          reason: 'l\'arte e\' attiva e non ha una rotta');
    });

    test('Il dominio di Aura ha le sue tre sottocategorie piene', () {
      // **LAPIDE: fino all'ordine EN questa prova contava anche le viste**
      // (`ArtCatalog.visibleFor`, le vive davanti). **Dall'ordine EO voce 10**
      // il dominio legge l'ordine del fondatore (`LOrdineDeiDomini`), e le
      // sue viste le misura `i_domini_a_schede_test`. Qui resta il catalogo.
      List<ArtEntry> arti(String titolo) => ArtCatalog.forMaestro(Maestro.aura)
          .firstWhere((s) => s.title == titolo)
          .arts;

      // Energia: una sola viva, la Meditazione con Voce.
      final energia = arti('Energia');
      expect(
        energia.where((a) => a.state == ArtState.attiva).map((a) => a.id),
        ['meditation'],
      );
      expect(
          energia.firstWhere((a) => a.id == 'meditation').title, 'Meditazione');
      expect(energia.map((a) => a.id), [
        'meditation',
        // 'frequencies' e' uscita: non e' un'arte a parte, 432, 528 e i battiti
        // binaurali sono dentro la Meditazione, e due voci sulla stessa
        // schermata sono una bugia.
        'sleep_stories',
        'daily_affirmations',
        'mudra',
        'belief_art',
        // **IL MOOD TRACKER E' QUI DALL'ORDINE EO VOCE 10**: stava negli
        // Archetipi.
        'mood_tracker',
        'biorhythm',
        'lucid_dreams',
      ]);
      expect(energia.firstWhere((a) => a.id == 'lucid_dreams').phase,
          ArtPhase.fase5);

      // Fisiognomica, che fino all'ordine EN si chiamava Archetipi.
      final fisiognomica = arti('Fisiognomica');
      expect(
        fisiognomica.where((a) => a.state == ArtState.attiva).map((a) => a.id),
        ['archetype_test', 'face_constellation'],
      );
      expect(fisiognomica.map((a) => a.id), [
        'archetype_test',
        'face_constellation',
        'palmistry',
        'graphology',
        'voice_analysis',
      ]);
      // **Il Test Archetipo e' nel catalogo e vive solo nel Passaporto**,
      // ordine EO voce 12, come l'Angelo Custode.
      expect(
          fisiognomica
              .firstWhere((a) => a.id == 'archetype_test')
              .soloNelPassaporto,
          isTrue);
      // La Compatibilita' Archetipica e' passata dentro la Sinastria
      // Approfondita di Medora, come livello archetipico.
      expect(
          fisiognomica.map((a) => a.id), isNot(contains('archetype_affinity')));

      // Chakra: sei arti, nessuna viva.
      final chakra = arti('Chakra');
      expect(chakra.length, 6);
      expect(chakra.where((a) => a.state == ArtState.attiva), isEmpty);
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
      // **LAPIDE: fino all'ordine EN qui si contavano anche le viste**
      // (`ArtCatalog.visibleFor`): Rune 5, Rituali 4, Magia 5, Numerologia 5
      // in Demo, e alla persona i Rituali scendevano a tre. **Dall'ordine EO
      // voce 10** il dominio legge l'ordine del fondatore, e le viste le
      // misura `i_domini_a_schede_test`. **E la sezione Rune si chiama
      // Divinazione**, ordine EO voce 11.
      List<ArtEntry> arti(String titolo) =>
          ArtCatalog.forMaestro(Maestro.caligo)
              .firstWhere((s) => s.title == titolo)
              .arts;

      // Una sola distintiva viva per sottocategoria, dove c'e'. La Numerologia non
      // ne ha piu': l'Albero della Vita e' uscito dalla Demo.
      for (final t in const ['Divinazione', 'Rituali', 'Magia']) {
        expect(arti(t).where((a) => a.state == ArtState.attiva).length, 1,
            reason: t);
      }
      expect(arti('Numerologia').where((a) => a.state == ArtState.attiva),
          isEmpty);
      expect(arti('Divinazione').map((a) => a.id), [
        'rune_draw',
        'i_ching',
        'pendulum',
        'coffee_reading',
        'dream_reading',
      ]);
      // Il Sigillo non e' piu' qui: e' passato in Magia, dove e' la
      // distintiva viva. Spostato, non duplicato.
      // **UNA VOCE SOLA DOVE CE N'ERANO DUE.** Ordine DC voci 01 e 03: il
      // Messaggio dall'Animale e' stato ASSORBITO dal Viaggio dello Sciamano
      // e non esiste piu' come funzione separata, perche' il messaggio e' il
      // risultato del viaggio.
      expect(arti('Rituali').map((a) => a.id), [
        'guide_animal',
        'micro_rituals',
        'daily_invocation',
        'guided_rituals',
      ]);
      expect(arti('Magia').map((a) => a.id), [
        'magic_sigil',
        'magia_rossa',
        'magia_bianca',
        'magia_verde',
        'opera_al_nero',
      ]);
      // Mai 'Magia Nera': la nigredo e' dissoluzione, non maleficio.
      for (final a in arti('Magia')) {
        expect(a.title.toLowerCase().contains('magia nera'), isFalse,
            reason: a.title);
      }
      // **LA CABALA E' ENTRATA COME ARTE.** Ordine CC voce 01, decisione del
      // fondatore del 30 agosto 2026: la macro categoria si chiama
      // Numerologia e la Cabala e' una delle arti che ci stanno dentro.
      expect(arti('Numerologia').map((a) => a.id), [
        'angel_numbers',
        'numerology',
        'kabbalah',
        'human_design',
        'cosmic_wrapped',
      ]);
      // L'Albero della Vita e' uscito dalla Demo, e con lui i settantadue nomi
      // che ne erano contenuto. La Compatibilita' Angelica e' passata alla
      // Sinastria Approfondita.
      expect(arti('Numerologia').map((a) => a.id),
          isNot(contains('tree_of_life')));
      expect(
          arti('Numerologia').map((a) => a.id), isNot(contains('angels_72')));
      expect(arti('Numerologia').map((a) => a.id),
          isNot(contains('angel_compatibility')));
      expect(
          arti('Numerologia').firstWhere((a) => a.id == 'angel_numbers').title,
          'Numeri Ricorrenti');
      // Nessuna arte di Caligo nomina piu' gli Angeli.
      for (final a
          in ArtCatalog.forMaestro(Maestro.caligo).expand((s) => s.arts)) {
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
        expect(artRouteFor(id), isNotNull, reason: id);
      }
      // Nessuna arte resta sulla soglia: l'Albero della Vita e' uscito dalla
      // Demo, tutte le arti attive hanno la loro esperienza vera.
      expect(artiSullaSoglia, isEmpty);
      expect(artRouteFor('tree_of_life'), isNull);
      // L'Animale Guida ha ora la sua esperienza vera: non e' piu' sulla soglia
      // e ha una rotta reale.
      expect(artiSullaSoglia.containsKey('guide_animal'), isFalse);
      expect(artRouteFor('guide_animal'), isNotNull);
      // L'Estrazione Rune ha ora la sua esperienza vera: fuori dalla soglia,
      // con una rotta reale.
      expect(artiSullaSoglia.containsKey('rune_draw'), isFalse);
      expect(artRouteFor('rune_draw'), isNotNull);
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
      expect(astro.arts.map((a) => a.id), [
        'horoscope',
        'natal_chart',
        'planetary_returns',
        'pet_astrology',
        'astrocartography'
      ]);
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
      expect(
          ArtPhase.rank(ArtPhase.mvp), lessThan(ArtPhase.rank(ArtPhase.fase2)));
      expect(ArtPhase.rank(ArtPhase.fase2),
          lessThan(ArtPhase.rank(ArtPhase.faseSuccessiva)));
      expect(ArtPhase.rank(ArtPhase.faseSuccessiva),
          lessThan(ArtPhase.rank(ArtPhase.fase3)));
      expect(ArtPhase.rank(ArtPhase.fase3),
          lessThan(ArtPhase.rank(ArtPhase.fase4)));
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
      expect(
          ArtCatalog.isVisible(find('planetary_returns'), demo: false), isTrue);
      expect(ArtCatalog.isVisible(find('pet_astrology'), demo: false), isTrue);
      // Oltre la soglia no, ma restano tutte nel catalogo.
      for (final id in const [
        'astrocartography',
        'friends_compatibility',
        'fertility_windows',
        'lunar_calendar',
        'angel_cards',
      ]) {
        expect(ArtCatalog.isVisible(find(id), demo: false), isFalse,
            reason: id);
        expect(ArtCatalog.isVisible(find(id), demo: true), isTrue, reason: id);
        expect(ArtCatalog.all.map((a) => a.id), contains(id));
      }
      // **LAPIDE: qui si provava l'esenzione dalla soglia** per le
      // sottocategorie tutte in cammino. E' uscita col dominio a riquadri,
      // ordine EO voce 10: la riga "In arrivo" segue la soglia per tutte.
    });

    // **LAPIDE: qui vivevano due prove delle viste del dominio**, "Una
    // sottocategoria tutta in cammino si mostra intera" e "Le sottocategorie
    // visibili cambiano col punto di vista": la regola dell'esenzione e le
    // sezioni vive davanti (`ArtCatalog.visibleFor`, `visibleArts`,
    // `hasActive`). **Dall'ordine EO voce 10** il dominio legge l'ordine del
    // fondatore anche contro quella regola, e le arti in cammino hanno la loro
    // riga "In arrivo", che alla persona si ferma alla soglia delle fasi: lo
    // misura `i_domini_a_schede_test`. Le tre funzioni sono uscite dal codice.

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
        FunctionShelf.functions
            .firstWhere((f) => f.id == 'tarot_spread_three')
            .title,
        'Stesa di Tarocchi',
      );
    });

    test('Ogni arte attiva ha una rotta vera, nessuna attiva a vuoto', () {
      for (final m in Maestro.values) {
        for (final a in ArtCatalog.activeOf(m)) {
          expect(
            artRouteFor(a.id),
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

    // **LA SEZIONE E L'ARTE PORTANO LO STESSO NOME, ed e' voluto.** Ordine
    // CC voce 01: la macro categoria di Caligo si chiama Numerologia dal 29
    // agosto 2026, e dentro ci vive "Numerologia del Destino", che era gia'
    // li' quando la sezione si chiamava Cabala. Non sono due nomi per la
    // stessa cosa: uno e' il ripiano, l'altra e' una delle quattro arti che
    // ci stanno sopra.
    test('La Numerologia del Destino e\' di Caligo, sotto Numerologia', () {
      final numerologia = ArtCatalog.forMaestro(Maestro.caligo)
          .firstWhere((s) => s.title == 'Numerologia');
      expect(numerologia.arts.map((a) => a.id), contains('numerology'));
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
        final art = ArtCatalog.all
            .where((a) => a.id == f.id)
            .cast<ArtEntry?>()
            .firstOrNull;
        if (art != null && art.state == ArtState.attiva) {
          expect(artRouteFor(f.id), isNotNull);
        }
      }
    });
  });

  group('Il dominio del Maestro', () {
    // **LAPIDE: qui vivevano sei prove del dominio a riquadri** (titoli delle
    // sottocategorie della stessa misura, riquadri, fasi lontane, contatori,
    // stati di partenza coi collassi, sottocategorie vive davanti). **Dall'ordine
    // EO voce 10** le sezioni sono righe di schede nell'ordine del fondatore:
    // le misurano `i_domini_a_schede_test` (righe e schede contro l'elenco) e
    // `le_schede_dell_arte_test` (titoli mai rimpiccioliti, angoli, tocco).

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
        // IL DOMINIO IN UNA FORMA SOLA, ed e' quella con le virgole.
        //
        // Qui si leggeva "Astrologia · Cartomanzia · Destino" coi punti medi e
        // in chat "Astrologia, Cartomanzia e Destino": la stessa informazione
        // in due composizioni. Nasce da `domainArtsPhrase`, punto unico.
        expect(tester.widget<Text>(riga).data, m.domainArtsPhrase);
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
          lessThan(tester.getTopLeft(find.byType(BustoDelMaestro)).dy));

      // Centrati sulla larghezza della SCHERMATA, non sullo spazio che avanza
      // accanto alla freccia: il centro dei due testi cade sulla meta' esatta.
      final meta =
          tester.view.physicalSize.width / tester.view.devicePixelRatio / 2;
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
              create: (ctx) => FeatureFlagService(
                  entitlement: ctx.read<EntitlementService>())
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
        expect(
            tester.getCenter(find.text(m.displayName)).dx, closeTo(meta, 1.0),
            reason: 'il nome di ${m.displayName} non e\' centrato');
        expect(
          tester.getCenter(find.byKey(const Key('domain_pillars'))).dx,
          closeTo(meta, 1.0),
          reason: 'i pilastri di ${m.displayName} non sono centrati',
        );
      }
    });

    // **LAPIDE: qui vivevano tre prove del dominio a riquadri di Aura e di
    // Caligo** (le sottocategorie e il verde o il rosso del Maestro sulle sole
    // arti vive). Dall'ordine EO voce 10 le misura `i_domini_a_schede_test`.

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

    // **LAPIDE: qui vivevano cinque prove della card di prima** (`ArtCard`:
    // attiva e Premium, in arrivo leggibile, la fase solo in Demo, "si apre
    // con l'Adepto", la comparsa con Riduci Movimento). La card e' uscita dal
    // codice con l'ordine EO voce 10: le due regole di testo le eredita la
    // scheda e le prova `i_domini_a_schede_test`; lucchetto, clessidra e
    // Riduci Movimento li prova `le_schede_dell_arte_test`.
  });
}
