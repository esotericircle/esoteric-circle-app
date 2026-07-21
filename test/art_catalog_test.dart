import 'package:esoteric_circle/core/arts/art_catalog.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/feature_flags/feature_flag_service.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/santuario/function_shelf.dart';
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
    test('Ogni Maestro ha le sue tre sottocategorie, nell\'ordine', () {
      expect(ArtCatalog.forMaestro(Maestro.medora).map((s) => s.title),
          ['Astrologia', 'Cartomanzia', 'Destino']);
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
      expect(find('vedic_astrology').phase, 'Fase 3');
      expect(find('astrocartography').phase, 'Fase 4');
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
      // Gli altri due riquadri sono piu' in basso nella lista pigra.
      for (final t in const ['cartomanzia', 'destino']) {
        await tester.scrollUntilVisible(
          find.byKey(Key('art_section_$t')),
          260,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.byKey(Key('art_section_$t')), findsOneWidget);
      }
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

    testWidgets('L\'arte in arrivo resta leggibile e dice la fase',
        (tester) async {
      await tester.pumpWidget(domain(Maestro.medora));
      await tester.pump();
      await tester.scrollUntilVisible(
        find.byKey(const Key('art_natal_chart')),
        260,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.byKey(const Key('art_state_arrivo_natal_chart')),
          findsOneWidget);
      expect(find.text('In arrivo, MVP'), findsOneWidget);
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
  });
}
