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

  /// Voce EO.10, alla lettera.
  const elencoDelFondatore = <Maestro, List<(String, List<String>)>>{
    Maestro.medora: [
      ('Astrologia', ['Oroscopo Personalizzato', 'Pet Astrology']),
      ('Cartomanzia', ['Stesa di Tarocchi', 'Oracolo degli Angeli']),
      (
        'Compatibilità',
        ['Sinastria VIP', 'Sinastria Approfondita', 'Compatibilità tra Amici']
      ),
      ('Lunologia', ['Il Respiro della Luna', 'Affinità Lunare']),
      ('Destino', ['Destino Narrativo']),
    ],
    Maestro.aura: [
      (
        'Energia',
        [
          'Meditazione',
          'Affermazioni del Giorno',
          'Sleep Stories',
          'Mood Tracker',
          'Bioritmo'
        ]
      ),
      (
        'Chakra',
        [
          'Scan dei Chakra',
          "Analisi dell'Aura",
          'Oracolo dei Cristalli',
          'Purificazione Energetica'
        ]
      ),
      ('Fisiognomica', ['Mappa del Viso']),
    ],
    Maestro.caligo: [
      (
        'Divinazione',
        [
          'Estrazione Rune',
          'Pendolo',
          'Interpretazione dei Sogni',
          'I-Ching',
          'Lettura dei Fondi di Caffè'
        ]
      ),
      ('Rituali', ['Il Viaggio dello Sciamano', 'Micro-rituali']),
      ('Magia', ["Sigillo dell'Intenzione"]),
      ('Numerologia', ['Numeri Ricorrenti', 'Numerologia del Destino']),
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
        'EO.10 e EO.13: il dominio di ${m.displayName} a video, contro '
        'l\'elenco del fondatore', (tester) async {
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

      // Le righe dall'alto in basso: le sezioni, poi "In arrivo".
      final cime = [
        for (final r in righe)
          tester.getTopLeft(find.byKey(Key('riga_${r.chiave}'))).dy,
      ];
      for (var i = 1; i < cime.length; i++) {
        expect(cime[i], greaterThan(cime[i - 1]));
      }
      expect([for (final r in righe) r.titolo],
          [for (final (t, _) in atteso) t, 'In arrivo'],
          reason: 'le sezioni di ${m.id} non sono quelle del fondatore, in '
              'quell\'ordine, con "In arrivo" in fondo');

      var confrontate = 0;
      for (var i = 0; i < atteso.length; i++) {
        final ids = await schedeDellaRiga(tester, righe[i]);
        confrontate += ids.length;
        expect([for (final id in ids) titolo(id)], atteso[i].$2,
            reason: 'le schede della sezione ${atteso[i].$1}');
      }

      // **LA RIGA "IN ARRIVO"**: le arti del Maestro che non stanno
      // nell'elenco, che la regola mostra, e mai chi vive nel Passaporto.
      // L'atteso si ricava dal catalogo e dall'elenco del fondatore, non
      // dalla funzione che la schermata usa.
      final nellElenco = {for (final (_, t) in atteso) ...t};
      final inArrivoAtteso = [
        for (final s in ArtCatalog.forMaestro(m))
          for (final a in s.arts)
            if (!nellElenco.contains(a.title) && !a.soloNelPassaporto) a.id,
      ];
      final inArrivo = await schedeDellaRiga(tester, righe.last);
      expect(inArrivo, inArrivoAtteso,
          reason: 'la riga "In arrivo" di ${m.id}');
      for (final id in inArrivo) {
        final scheda = find.byKey(Key('riga_dominio_in_arrivo_$id'));
        await tester.pump();
        final posizione = tester
            .state<ScrollableState>(find.descendant(
                of: find.byKey(const Key('riga_scorre_dominio_in_arrivo')),
                matching: find.byType(Scrollable)))
            .position;
        posizione.jumpTo(0);
        await tester.pump();
        for (var px = 0.0;
            scheda.evaluate().isEmpty && px <= posizione.maxScrollExtent;
            px += 120) {
          posizione.jumpTo(px);
          await tester.pump();
        }
        final immagine = tester.widget<Image>(find.descendant(
            of: scheda, matching: find.byKey(Key('scheda_immagine_$id'))));
        // `Image.asset` con `cacheWidth` avvolge l'asset in un ResizeImage.
        final fornitore = immagine.image;
        final asset = (fornitore is ResizeImage
            ? fornitore.imageProvider
            : fornitore) as AssetImage;
        expect(asset.assetName,
            GliSfondiDelleSchede.delMaestro(m, FormatoDellaScheda.quadrata),
            reason: '$id: lo sfondo del Maestro senza emblema');
        expect(
            find.descendant(
                of: scheda, matching: find.byKey(Key('scheda_icona_$id'))),
            findsOneWidget,
            reason: '$id: l\'icona dell\'arte in oro');
        expect(
            find.descendant(
                of: scheda, matching: find.byKey(Key('scheda_clessidra_$id'))),
            findsOneWidget,
            reason: '$id: la clessidra');
      }
      confrontate += inArrivo.length;

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
      print('EO.10 MISURA ${m.id}: righe ${righe.length}, schede nelle sezioni '
          '${confrontate - inArrivo.length}, in arrivo ${inArrivo.length}');
      cardinaleMinimo(confrontate, 8,
          cosa: 'schede del dominio di ${m.id}',
          perche: 'il dominio piu\' piccolo, Aura, ne ha dieci nelle sezioni.');
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

  test(
      'EO.13: alla persona la riga "In arrivo" si ferma alla soglia delle '
      'fasi', () {
    final persona = LOrdineDeiDomini.inArrivo(Maestro.medora, demo: false)
        .map((a) => a.id)
        .toList();
    final demo =
        LOrdineDeiDomini.inArrivo(Maestro.medora).map((a) => a.id).toList();
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
