import 'package:esoteric_circle/core/arts/art_catalog.dart';
import 'package:esoteric_circle/core/arts/gli_sfondi_delle_schede.dart';
import 'package:esoteric_circle/core/arts/l_ordine_dei_domini.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/feature_flags/feature_flag_service.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/maestro_screen.dart';
import 'package:esoteric_circle/features/schede/la_riga_delle_schede.dart';
import 'package:esoteric_circle/features/schede/la_scheda_dell_arte.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';

/// **I DOMINI A SCHEDE.** Ordine EO voci 10, 12 e 13, 26 settembre 2026.
///
/// Si monta il dominio vero di ogni Maestro e si confronta cio' che c'e' a
/// video con l'elenco del fondatore, **scritto qui alla lettera coi nomi
/// delle arti come li ha scritti lui**: un titolo cambiato nel catalogo cade
/// qui come un'arte fuori posto.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// **L'elenco del fondatore.** LAPIDE: era quello della voce EO.10, trenta
  /// arti, e le altre ventiquattro finivano nella riga "In arrivo" in fondo
  /// (voce EO.13). **Dall'ordine ER voce 10**, alla lettera: ogni arte nella
  /// sezione del suo Maestro, dopo quelle che c'erano, comprese le dodici
  /// arti nuove del briefing. La riga "In arrivo" resta vuota e non si vede.
  const elencoDelFondatore = <Maestro, List<(String, List<String>)>>{
    Maestro.medora: [
      (
        'Astrologia',
        [
          // Il nome dall'ordine FC voce 01, 4 ottobre 2026.
          'Oroscopo Universale',
          'Pet Astrology',
          'Carta Natale interattiva',
          'Ritorni Planetari',
          'Astrocartografia',
          'Time Machine Astrologica',
        ]
      ),
      (
        'Cartomanzia',
        [
          'Stesa di Tarocchi',
          'Oracolo degli Angeli',
          'Carte Angeliche Oracolari',
          'Cosmic Scan',
        ]
      ),
      (
        'Compatibilità',
        [
          'Sinastria VIP',
          'Sinastria Approfondita',
          'Compatibilità tra Amici',
          'Cosmic Dating',
          'Sinastria NFC e QR',
        ]
      ),
      (
        'Lunologia',
        [
          'Il Respiro della Luna',
          'Affinità Lunare',
          'Finestre Fertili',
          'Calendario Lunare Personale',
        ]
      ),
      (
        'Destino',
        [
          'Destino Narrativo',
          'Lettura Karmica',
        ]
      ),
    ],
    Maestro.aura: [
      (
        'Energia',
        [
          'Meditazione',
          'Affermazioni del Giorno',
          'Sleep Stories',
          'La Soglia del Sonno',
          'Mood Tracker',
          'Bioritmo',
          'Mudra',
          'Arte delle Convinzioni',
          'Sogni Lucidi',
          'Breathwork',
          'Percorso di Risveglio',
        ]
      ),
      (
        'Chakra',
        [
          'Scan dei Chakra',
          "Analisi dell'Aura",
          'Oracolo dei Cristalli',
          'Purificazione Energetica',
          'Cristalloterapia',
          'Sfera di Cristallo',
          'Feng Shui',
        ]
      ),
      (
        'Fisiognomica',
        [
          'Mappa del Viso',
          'Chiromanzia Ibrida',
          'Grafologia Esoterica',
          'Cosmic Voice Analysis',
          "Specchio dell'Anima",
          // Ordine ER voce 20.
          "Il Segreto dell'Iride",
        ]
      ),
    ],
    Maestro.caligo: [
      (
        'Divinazione',
        [
          'Estrazione Rune',
          'Pendolo',
          'Interpretazione dei Sogni',
          'I-Ching',
          'Lettura dei Fondi di Caffè',
        ]
      ),
      (
        'Rituali',
        [
          'Il Viaggio dello Sciamano',
          'Micro-rituali',
          'Invocazione del Giorno',
          'Rituali Guidati Interattivi',
          'Rituali Collettivi',
        ]
      ),
      (
        'Magia',
        [
          "Sigillo dell'Intenzione",
          'Magia Rossa',
          'Magia Bianca',
          'Magia Verde',
          'Opera al Nero',
          'Alchimia',
        ]
      ),
      (
        'Numerologia',
        [
          'Numeri Ricorrenti',
          'Numerologia del Destino',
          'Cabala',
          'Human Design',
          'Cosmic Wrapped',
          'Albero della Vita',
          'Cosmic Academy',
        ]
      ),
    ],
  };

  Future<void> monta(WidgetTester tester, Maestro m, {bool demo = true}) async {
    SharedPreferences.setMockInitialValues(const {});
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1170, 2532);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MultiProvider(
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
          child: Scaffold(
            body: MaestroScreen(maestro: m, demo: demo),
          ),
        ),
      ),
    ));
    await tester.pump();
  }

  /// Le schede di una riga, nell'ordine in cui compaiono scorrendola.
  Future<List<String>> schedeDellaRiga(
      WidgetTester tester, LaRigaDelleSchede riga) async {
    final posizione = tester
        .state<ScrollableState>(find.descendant(
            of: find.byKey(Key('riga_scorre_${riga.chiave}')),
            matching: find.byType(Scrollable)))
        .position;
    final prefisso = 'riga_${riga.chiave}_';
    final viste = <String>[];
    for (var px = 0.0;; px += 120) {
      posizione.jumpTo(px.clamp(0, posizione.maxScrollExtent));
      await tester.pump();
      final qui = <(double, String)>[];
      for (final e in find
          .byWidgetPredicate((w) =>
              w.key is ValueKey<String> &&
              (w.key! as ValueKey<String>).value.startsWith(prefisso))
          .evaluate()) {
        final id = (e.widget.key! as ValueKey<String>)
            .value
            .substring(prefisso.length);
        qui.add((tester.getTopLeft(find.byKey(Key('$prefisso$id'))).dx, id));
      }
      qui.sort((a, b) => a.$1.compareTo(b.$1));
      for (final (_, id) in qui) {
        if (!viste.contains(id)) viste.add(id);
      }
      if (px >= posizione.maxScrollExtent) break;
    }
    return viste;
  }

  String titolo(String id) =>
      ArtCatalog.all.firstWhere((a) => a.id == id).title;

  for (final m in Maestro.values) {
    testWidgets(
        'ER.10: il dominio di ${m.displayName} a video, contro '
        'l\'elenco del fondatore, ogni scheda col suo sfondo', (tester) async {
      await monta(tester, m);
      final righe = tester
          .widgetList<LaRigaDelleSchede>(
              find.byType(LaRigaDelleSchede, skipOffstage: false))
          .toList();
      final atteso = elencoDelFondatore[m]!;

      // La scheda "Consulta" resta in cima, sopra la prima riga.
      final consulta = find.byKey(const Key('domain_consulta_card'));
      expect(consulta, findsOneWidget);
      expect(
          tester.getRect(consulta).bottom,
          lessThanOrEqualTo(tester
              .getRect(find.byKey(Key('riga_${righe.first.chiave}')))
              .top),
          reason: 'la scheda "Consulta" deve restare in cima al dominio');

      // Le righe dall'alto in basso: le sezioni, e nient'altro.
      final cime = [
        for (final r in righe)
          tester.getTopLeft(find.byKey(Key('riga_${r.chiave}'))).dy,
      ];
      for (var i = 1; i < cime.length; i++) {
        expect(cime[i], greaterThan(cime[i - 1]));
      }
      expect(
          [for (final r in righe) r.titolo], [for (final (t, _) in atteso) t],
          reason: 'le sezioni di ${m.id} non sono quelle del fondatore, in '
              'quell\'ordine, senza la riga "In arrivo"');

      var confrontate = 0;
      var senzaSfondo = 0;
      for (var i = 0; i < atteso.length; i++) {
        final ids = await schedeDellaRiga(tester, righe[i]);
        confrontate += ids.length;
        expect([for (final id in ids) titolo(id)], atteso[i].$2,
            reason: 'le schede della sezione ${atteso[i].$1}');
        // **OGNI SCHEDA COL SUO SFONDO**, ordine ER voce 10: prima le
        // ventiquattro arti senza sfondo si disegnavano con lo sfondo del
        // Maestro e l'icona in oro.
        for (final id in ids) {
          if (GliSfondiDelleSchede.perArte(id, FormatoDellaScheda.verticale) ==
              null) {
            senzaSfondo++;
          }
          expect(find.byKey(Key('scheda_icona_$id'), skipOffstage: false),
              findsNothing,
              reason: '$id: si disegna ancora con l\'icona sullo sfondo del '
                  'Maestro');
        }
      }
      // **LA RIGA "IN ARRIVO" E' VUOTA**, e vuota non si mostra.
      final inArrivo = LOrdineDeiDomini.inArrivo(m);
      expect(inArrivo, isEmpty,
          reason: 'arti di ${m.id} fuori dalle sezioni: '
              '${inArrivo.map((a) => a.id).toList()}');
      expect(
          find.byKey(const Key('riga_dominio_in_arrivo'), skipOffstage: false),
          findsNothing);

      // **IL TEST ARCHETIPO NON C'E'**, ordine EO voce 12.
      expect(
          find.byWidgetPredicate(
              (w) =>
                  w.key is ValueKey<String> &&
                  (w.key! as ValueKey<String>).value.contains('archetype_test'),
              skipOffstage: false),
          findsNothing,
          reason: 'il Test Archetipo e\' ancora nel dominio');
      // ignore: avoid_print
      print('ORDINE ER VOCE 10, ${m.id}: righe ${righe.length}, schede nelle '
          'sezioni $confrontate, senza sfondo $senzaSfondo, nella riga In '
          'arrivo ${inArrivo.length}');
      cardinaleMinimo(confrontate, 20,
          cosa: 'schede del dominio di ${m.id}',
          perche: 'il dominio piu\' piccolo, Medora, ne ha ventuno.');
    });
  }

  test('EO.12: il Test Archetipo vive solo nel Passaporto', () {
    final arte = ArtCatalog.all.firstWhere((a) => a.id == 'archetype_test');
    expect(arte.soloNelPassaporto, isTrue);
    expect(LOrdineDeiDomini.inArrivo(Maestro.aura).map((a) => a.id),
        isNot(contains('archetype_test')));
    expect(ArtCatalog.activeOf(Maestro.aura).map((a) => a.id),
        isNot(contains('archetype_test')),
        reason: 'nemmeno la striscia delle altre arti deve proporlo');
  });

  // LAPIDE, ordine ER voce 10: qui si misurava la soglia delle fasi sulla
  // riga "In arrivo", che adesso e' vuota. La soglia vale dentro le sezioni.
  test('EO.13: alla persona le sezioni si fermano alla soglia delle fasi', () {
    final astrologia = LOrdineDeiDomini.di(Maestro.medora)
        .firstWhere((s) => s.titolo == 'Astrologia');
    final persona = LOrdineDeiDomini.artiDi(astrologia, demo: false)
        .map((a) => a.id)
        .toList();
    final demo = LOrdineDeiDomini.artiDi(astrologia, demo: true)
        .map((a) => a.id)
        .toList();
    expect(demo, contains('astrocartography'));
    expect(persona, isNot(contains('astrocartography')),
        reason: 'la Fase 4 non si racconta alla persona');
    expect(persona, contains('natal_chart'));
  });

  // Le due regole della card di prima, che la scheda eredita.
  Future<void> montaUna(WidgetTester tester, String id,
      {bool mostraFase = true}) async {
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
      ],
      child: MaterialApp(
        home: MaestroScope(
          child: Scaffold(
            body: Center(
              child: LaSchedaDellArte(
                // Una scheda nuova a ogni montaggio: la stessa riusata
                // resterebbe girata, e il tocco sulla "i" la rigirerebbe.
                key: ValueKey('$id/$mostraFase'),
                art: ArtCatalog.all.firstWhere((a) => a.id == id),
                maestro: Maestro.medora,
                formato: FormatoDellaScheda.verticale,
                larghezza: 184,
                mostraFase: mostraFase,
                onApri: (_) async {},
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
    await tester.tap(find.byKey(Key('scheda_i_$id')));
    await tester.pumpAndSettle();
  }

  testWidgets('Alla persona si dice solo "In arrivo", la fase resta in Demo',
      (tester) async {
    await montaUna(tester, 'pet_astrology', mostraFase: false);
    expect(
        tester
            .widget<Text>(find.byKey(const Key('scheda_fase_pet_astrology')))
            .data,
        'In arrivo');
    await montaUna(tester, 'pet_astrology');
    expect(
        tester
            .widget<Text>(find.byKey(const Key('scheda_fase_pet_astrology')))
            .data,
        'In arrivo, Fase 2');
  });

  testWidgets('La Premium dice "si apre con l\'Adepto", non "col"',
      (tester) async {
    await montaUna(tester, 'synastry_depth');
    expect(
        tester
            .widget<Text>(find.byKey(const Key('scheda_fase_synastry_depth')))
            .data,
        'Si apre con l\'Adepto');
  });
}
