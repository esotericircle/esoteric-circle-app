// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/angels/angel_catalog.dart';
import 'package:esoteric_circle/core/angels/guardian_angels.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/oracolo_angeli/i_ruoli_e_l_estrazione.dart';
import 'package:esoteric_circle/core/oracolo_angeli/la_lettura_dell_oracolo.dart';
import 'package:esoteric_circle/core/oracolo_angeli/il_corpus_dell_oracolo.g.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sensi/la_suoneria.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/design_system/components/riquadro_arancione.dart';
import 'package:esoteric_circle/design_system/components/riquadro_in_evidenza.dart';
import 'package:esoteric_circle/design_system/components/segno_della_provenienza.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/angels/oracolo/la_geometria_dell_altare.dart';
import 'package:esoteric_circle/features/angels/oracolo/oracolo_degli_angeli_screen.dart';
import 'package:esoteric_circle/features/respiro_della_luna/i_comandi_dipinti.dart';
import 'package:esoteric_circle/features/scene/la_scena_in_video.dart';
import 'package:esoteric_circle/features/tarot/stesa_fan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';
import 'il_giro_dell_oracolo.dart';

/// **L'ORACOLO DEGLI ANGELI DELL'ORDINE FY**, 16 ottobre 2026: le correzioni
/// del fondatore sulla build 2312, voci FY.14-FY.20 per l'Oracolo.
///
/// FY.14 via la nascita prestata e la domanda per un amico; FY.15 le carte si
/// scelgono dal mazzo coperto col ventaglio della Stesa; FY.16 un pulsante
/// dipinto avvia la lettura e nulla parte da solo; FY.17 sotto le carte che
/// si girano l'altare e' vuoto (misurato sui pixel); FY.18 ogni carta porta
/// chi e' l'angelo e che cosa porta, da Lenain; FY.19 la risposta e' una
/// coppia sola; FY.20 la barra del titolo resta semitrasparente in ogni
/// stato. Il modello e' finto (R2).
///
/// **L'ORDINE GA**, 20 ottobre 2026. GA.08: all'apertura nessun dorso
/// sull'altare, i dorsi compaiono quando la persona li sceglie. GA.03, GA.04
/// e GA.05: la coppia sola di FY.19 diventa la forma nuova, una coppia nella
/// Breve (risposta e "Cosa fare adesso") e due nella Lunga (piu'
/// l'approfondimento e "Il salmo propiziatorio"), dall'Iniziato. Il gruppo
/// FY.19 qui sotto e' riscritto con la regola nuova, accanto alla vecchia.
class _Ferma implements LettoreDiScena {
  VoidCallback? _ascolta;
  bool _fallito = false;
  @override
  bool get pronto => false;
  @override
  bool get fallito => _fallito;
  @override
  bool get cominciato => false;
  @override
  bool get finito => false;
  @override
  void ascolta(VoidCallback? q) => _ascolta = q;
  @override
  Future<void> apri() async {
    _fallito = true;
    _ascolta?.call();
  }

  @override
  Future<void> volume(double q) async {}
  @override
  Future<void> avvia() async {}
  @override
  Future<void> sospendi() async {}
  @override
  Widget disegna() => const SizedBox.shrink();
  @override
  void chiudi() {}
}

final _nascita = BirthIdentity(
    birthMoment: DateTime(1990, 5, 12, 14, 30), hasBirthTime: true);
final _radice = GlobalKey();

Future<List<String>> _monta(WidgetTester tester,
    {Tier tier = Tier.tier1, double rapporto = 1}) async {
  SharedPreferences.setMockInitialValues({});
  // Una schermata nuova a ogni montaggio: lo stato di quella prima non resta.
  await tester.pumpWidget(const SizedBox());
  tester.view.physicalSize = Size(390 * rapporto, 844 * rapporto);
  tester.view.devicePixelRatio = rapporto;
  addTearDown(tester.view.reset);
  final chiamate = <String>[];
  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => MaestroController()),
      ChangeNotifierProvider(create: (_) => QualityTierController()),
      ChangeNotifierProvider(
          create: (_) => SettingsController(suonoEVibrazione: false)),
      ChangeNotifierProvider(create: (_) => EntitlementService(initial: tier)),
    ],
    child: RepaintBoundary(
      key: _radice,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        builder: (c, figlio) => MaestroScope(child: figlio!),
        home: OracoloDegliAngeliScreen(
          fabbricaDellaScena: _Ferma.new,
          caso: Random(7),
          adesso: () => DateTime(2026, 10, 15, 10, 5),
          identita: _nascita,
          chiamata: (i, r, c) async {
            chiamate.add(r);
            return jsonFintoDellOracolo(c);
          },
        ),
      ),
    ),
  ));
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  return chiamate;
}

/// Tutto il testo dipinto sotto [radice]. I paragrafi di lettura si
/// dipingono in piu' testi: si leggono uniti, con gli spazi ridotti a uno.
String _testoSotto(WidgetTester tester, Finder radice) => [
      for (final e in find
          .descendant(of: radice, matching: find.byType(RichText))
          .evaluate())
        (e.widget as RichText).text.toPlainText(),
    ].join(' ').replaceAll(RegExp(r'\s+'), ' ');

/// I numeri degli angeli che stanno sotto i dorsi del giro, nel mazzo
/// mescolato dallo stesso caso della schermata.
List<int> _angeliSotto(List<int> dorsi) {
  final mazzo = EstrazioneDellOracolo.mescola(Random(7));
  return [for (final d in dorsi) mazzo[d]];
}

void main() {
  setUp(() => LaSuoneria.spentaPerLeProve = true);
  tearDown(() => LaSuoneria.spentaPerLeProve = null);

  group('FY.14 via la nascita prestata e la domanda per un amico', () {
    testWidgets('l\'Oracolo non le offre piu\', a nessun piano',
        (tester) async {
      var viste = 0;
      for (final tier in Tier.values) {
        await _monta(tester, tier: tier);
        final tutto = _testoSotto(tester, find.byType(Scaffold).first);
        for (final cosa in const [
          'oracolo_chiedi_per_un_amico',
          'oracolo_presta_la_nascita',
        ]) {
          viste += find.byKey(Key(cosa)).evaluate().length;
        }
        expect(tutto, isNot(contains('per un amico')));
        expect(tutto, isNot(contains('Presta la tua nascita')));
      }
      print('FY.14 MISURA voci "Chiedi per un amico" e "Presta la tua '
          'nascita" sull\'Oracolo, ai quattro piani: $viste');
      expect(viste, 0);
    });

    test(
        'le loro schermate dentro l\'Oracolo non ci sono piu\', e il piano '
        'non le vende', () {
      final schermata =
          File('lib/features/angels/oracolo/oracolo_degli_angeli_screen.dart')
              .readAsStringSync();
      expect(schermata, isNot(contains('la_nascita_dell_altra_persona')));
      expect(schermata, isNot(contains('la_tua_nascita_per_una_lettura')));
      for (final f in const [
        'lib/features/synastry/la_tua_nascita_per_una_lettura.dart',
        'lib/features/synastry/la_nascita_dell_altra_persona.dart',
      ]) {
        expect(File(f).readAsStringSync(),
            isNot(contains('final bool perLOracolo')),
            reason: '$f tiene ancora la sua variante per l\'Oracolo');
      }
      final righe = [
        for (final r in PlanCatalog.matrix) r.label,
        for (final p in PlanCatalog.plans) ...[
          ...p.highlights,
          ...p.nellAnnuale.values,
        ],
      ];
      expect(righe.where((r) => r.contains('per un amico')), isEmpty,
          reason: 'il piano vende ancora la lettura per un amico');
    });
  });

  group('FY.15 e FY.16 le carte si scelgono, il pulsante avvia', () {
    testWidgets(
        'il mazzo coperto e\' il ventaglio della Stesa coi dorsi dei 72; '
        'ogni dorso scelto si posa sull\'altare nella sua posizione',
        (tester) async {
      await _monta(tester);
      // GA.08: a scena ferma l'altare e' vuoto, nessun dorso prima della
      // scelta (prima qui i tre dorsi del video erano sull'altare).
      for (var i = 0; i < 3; i++) {
        expect(find.byKey(Key('oracolo_dorso_$i')), findsNothing);
      }
      await affidaLaDomanda(tester, 'Devo cambiare lavoro?');
      final ventaglio = tester.widget<StesaFan>(find.byType(StesaFan));
      expect(ventaglio.carte, 72);
      expect(ventaglio.dorso, GeometriaDellAltare.dorso);
      expect(find.byKey(const Key('oracolo_dorso_0')), findsNothing,
          reason: 'mentre si sceglie, l\'altare aspetta i dorsi scelti');
      final guide = <String>[];
      String guida() => tester
          .widget<Text>(find.byKey(const Key('oracolo_guida_della_scelta')))
          .data!;
      guide.add(guida());
      for (var n = 0; n < 3; n++) {
        await toccaIlDorso(tester, dorsiDelGiro[n]);
        guide.add(guida());
        for (var i = 0; i < 3; i++) {
          expect(find.byKey(Key('oracolo_dorso_$i')),
              i <= n ? findsOneWidget : findsNothing,
              reason: 'dopo ${n + 1} scelte il dorso $i');
        }
      }
      print('FY.15 MISURA le righe che guidano la scelta: $guide');
      expect(guide[0], contains('prima carta, cosa fare'));
      expect(guide[1], contains('seconda carta, cosa sentire'));
      expect(guide[2], contains('terza carta, cosa capire'));
      expect(guide[3], contains('avvia la lettura'));
      // Un quarto tocco non sceglie niente.
      await toccaIlDorso(tester, 42);
      expect(find.byKey(const Key('oracolo_dorso_2')), findsOneWidget);
    });

    testWidgets(
        'le carte che escono sono quelle dei dorsi toccati: altri dorsi, '
        'altre carte', (tester) async {
      final uscite = <List<int>>[];
      for (final dorsi in const [
        [33, 36, 39],
        [32, 35, 38],
      ]) {
        await _monta(tester);
        await affidaLaDomanda(tester, 'Devo cambiare lavoro?');
        await scegliLeTreCarte(tester, dorsi);
        await avviaLaLettura(tester);
        await tester.drag(find.byType(ListView).first, const Offset(0, 5000));
        await tester.pump(const Duration(milliseconds: 300));
        final girate = [
          for (final r in const ['custode', 'cuore', 'intelletto'])
            tester
                .widget<LaCartaDellAngelo>(find.byKey(Key('oracolo_carta_$r')))
                .angelo
                .number,
        ];
        print('FY.15 MISURA dorsi $dorsi: attesi ${_angeliSotto(dorsi)}, '
            'girati $girate');
        expect(girate, _angeliSotto(dorsi));
        uscite.add(girate);
      }
      expect(uscite[0], isNot(uscite[1]));
    });

    testWidgets(
        'nulla parte da solo: senza le tre carte il pulsante e\' spento; con '
        'le tre carte la lettura aspetta il pulsante', (tester) async {
      final chiamate = await _monta(tester);
      await affidaLaDomanda(tester, 'Devo cambiare lavoro?');
      final pulsante = find.byKey(const Key('oracolo_avvia_la_lettura'));
      expect(tester.widget<PulsanteDipinto>(pulsante).onTap, isNull);
      await toccaIlDorso(tester, 33);
      await toccaIlDorso(tester, 36);
      expect(tester.widget<PulsanteDipinto>(pulsante).onTap, isNull);
      await toccaIlDorso(tester, 39);
      expect(tester.widget<PulsanteDipinto>(pulsante).onTap, isNotNull);
      // Dieci secondi con le tre carte scelte: niente parte.
      for (var i = 0; i < 100; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      final primaDelTocco = chiamate.length +
          find.byKey(const Key('oracolo_lettere_di_luce')).evaluate().length +
          find.byKey(const Key('oracolo_responso')).evaluate().length;
      await avviaLaLettura(tester);
      print('FY.16 MISURA cose partite da sole in 10 s con le tre carte '
          'scelte: $primaDelTocco; chiamate dopo il pulsante: '
          '${chiamate.length}');
      expect(primaDelTocco, 0);
      expect(chiamate, hasLength(1));
      expect(find.byKey(const Key('oracolo_responso')), findsOneWidget);
    });
  });

  group('FY.17 sotto le carte che si girano non resta il video', () {
    testWidgets(
        'a meta\' giro, ai lati della carta di taglio si vede l\'altare '
        'vuoto, non il dorso dipinto', (tester) async {
      await _monta(tester);
      await affidaLaDomanda(tester, 'Devo cambiare lavoro?');
      await scegliLeTreCarte(tester);
      final pulsante = find.byKey(const Key('oracolo_avvia_la_lettura'));
      await Scrollable.ensureVisible(tester.element(pulsante), alignment: 0.5);
      await tester.pump();
      await tester.tap(pulsante);
      // Le lettere salgono 2,4 s; poi la prima carta si gira in 0,5 s. Il
      // momento giusto si cerca, non si indovina: la carta e' di taglio
      // quando la sua larghezza a schermo scende sotto un quinto di quella
      // piatta.
      for (var i = 0; i < 22; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      final piatta =
          tester.getRect(find.byKey(const Key('oracolo_dorso_0'))).width;
      var larga = piatta;
      for (var i = 0; i < 200 && larga > piatta / 5; i++) {
        await tester.pump(const Duration(milliseconds: 8));
        for (final k in const ['oracolo_dorso_0', 'oracolo_carta_custode']) {
          final f = find.byKey(Key(k));
          if (f.evaluate().isNotEmpty) larga = tester.getRect(f).width;
        }
      }
      print('FY.17 MISURA larghezza della prima carta: piatta '
          '${piatta.toStringAsFixed(1)}, al momento della cattura '
          '${larga.toStringAsFixed(1)}');
      expect(larga, lessThan(piatta / 5), reason: 'la carta non e\' di taglio');
      expect(tester.getTopLeft(find.byKey(const Key('oracolo_scena'))).dy, 0.0,
          reason: 'la scena non e\' tornata in cima');
      await tester.runAsync(() async {
        for (final e in find.byType(Image).evaluate()) {
          await precacheImage((e.widget as Image).image, e);
        }
      });
      await tester.pump();
      final misura = await _lumiDelDorsoDipinto(tester);
      print('FY.17 MISURA luminanza media ai lati della prima carta di '
          'taglio: ${misura.cattura.toStringAsFixed(1)}; altare vuoto del '
          'primo fotogramma: ${misura.vuoto.toStringAsFixed(1)}; dorso '
          'dipinto dell\'ultimo fotogramma: '
          '${misura.dipinto.toStringAsFixed(1)}');
      expect((misura.cattura - misura.vuoto).abs(), lessThan(12),
          reason: 'sotto la carta che si gira non c\'e\' l\'altare vuoto');
      // **IL TAVOLO VUOTO STA NEL FILMATO**, GC Aggiunta, 22 ottobre 2026:
      // l'ultimo fotogramma del v2 non ha piu' i dorsi dipinti, e sull'altare
      // e' uguale al primo, sgombro. LAPIDE, FY.17: "sotto la carta che si
      // gira si vede il dorso del video" (oltre 30 livelli dal dorso dipinto)
      // e la toppa `AltareVuoto`.
      expect((misura.dipinto - misura.vuoto).abs(), lessThan(12),
          reason: 'l\'ultimo fotogramma del filmato porta ancora i dorsi '
              'dipinti sull\'altare');
    });
  });

  group('FY.18 ogni carta ha la sua descrizione', () {
    test('tutti i 72 hanno chi e\' e che cosa porta, dal Corpus', () {
      var conDescrizione = 0;
      final daLenain = <int>[];
      final daMedora = <int>[];
      for (var n = 1; n <= 72; n++) {
        final a = AngelCatalog.byNumber(n);
        final porta = OracoloDegliAngeliScreen.cosaPortaDi(a);
        if (porta == null || porta.testo.trim().isEmpty) continue;
        conDescrizione++;
        (porta.da == Provenienza.tradizione ? daLenain : daMedora).add(n);
      }
      cardinaleMinimo(conDescrizione, 72, cosa: 'angeli con la descrizione');
      print('FY.18 MISURA angeli del mazzo con chi e\' e che cosa porta: '
          '$conDescrizione su 72 (da Lenain ${daLenain.length}, dalla '
          'lettura di Medora ${daMedora.length}: $daMedora)');
      expect(daLenain.length + daMedora.length, 72);
    });

    testWidgets(
        'ogni carta estratta mostra chi e\', che cosa porta col segno di '
        'Lenain e il suo messaggio', (tester) async {
      await _monta(tester);
      await consultaLOracolo(tester, 'Devo cambiare lavoro?');
      final angeli = _angeliSotto(dorsiDelGiro);
      var descritte = 0;
      for (var i = 0; i < 3; i++) {
        final r = RuoloDellAngelo.values[i];
        final bolla = find.byKey(Key('oracolo_bolla_${r.name}'));
        await tester.ensureVisible(bolla);
        await tester.pump();
        final a = AngelCatalog.byNumber(angeli[i]);
        final tutto = _testoSotto(tester, bolla);
        expect(find.byKey(Key('oracolo_chi_e_${r.name}')), findsOneWidget);
        expect(tutto, contains(OracoloDegliAngeliScreen.chiEDi(a)));
        final porta = OracoloDegliAngeliScreen.cosaPortaDi(a)!;
        expect(tutto, contains(porta.testo));
        expect(
            tutto,
            contains(SegnoDellaProvenienza.rigaDi(porta.da,
                dettaglio: porta.fonte)));
        descritte++;
      }
      print('FY.18 MISURA carte estratte con la descrizione e la fonte: '
          '$descritte su 3');
      expect(descritte, 3);
    });
  });

  group('FY.19 una sola coppia di risposta, riscritta dall\'ordine GA', () {
    // **LA REGOLA VECCHIA, FY.19**: "il titolo e un riquadro solo", con la
    // Lunga dentro lo stesso riquadro (riquadri nel responso: 1). **LA REGOLA
    // NUOVA, GA.03 e GA.05**: il responso principale ha la forma nuova, una
    // coppia nella Breve e due nella Lunga, e la Lunga e' dall'Iniziato; ogni
    // carta ha il suo responso breve nella sua bolla. Il Viandante e'
    // nell'assaggio: la Breve della carta del Custode, senza modello.
    for (final (tier, riquadri, lunga) in const [
      (Tier.free, 1, false),
      (Tier.tier1, 2, true),
      (Tier.tier2, 2, true),
    ]) {
      testWidgets(
          '${tier.name}: il responso principale ha $riquadri riquadri '
          '(${lunga ? 'Lunga' : 'Breve'}), e i messaggi delle carte stanno '
          'nelle loro bolle', (tester) async {
        await _monta(tester, tier: tier);
        await consultaLOracolo(tester, 'Devo cambiare lavoro?');
        final principale = find.byKey(const Key('oracolo_responso_principale'));
        int quanti(Type t) => find
            .descendant(of: principale, matching: find.byType(t))
            .evaluate()
            .length;
        final visti = quanti(RiquadroInEvidenza) + quanti(RiquadroArancione);
        print('FY.19 GA MISURA ${tier.name}: riquadri nel responso '
            'principale $visti (attesi $riquadri)');
        expect(visti, riquadri);
        expect(quanti(RiquadroArancione), lunga ? 1 : 0,
            reason: 'il riquadro del salmo e\' solo della Lunga');
        expect(
            find.descendant(
                of: principale, matching: find.text('Il salmo propiziatorio')),
            lunga ? findsOneWidget : findsNothing);
        expect(
            find.descendant(
                of: principale,
                matching: find
                    .byKey(const Key('oracolo_principale_approfondimento'))),
            lunga ? findsOneWidget : findsNothing);
        // Niente si perde: il messaggio del Cuore e dell'Intelletto sta
        // nella loro bolla (il Custode dell'assaggio e' il responso stesso).
        final carte = EstrazioneDellOracolo.dalleScelte(
            GuardianAngels.forBirth(_nascita.toBirthDetails()),
            _angeliSotto(dorsiDelGiro));
        for (final c in [
          if (tier != Tier.free) ...[carte[0], carte[2]]
        ]) {
          final atteso =
              LaLetturaDellOracolo.messaggioDellaCarta(corpusDellOracolo, c, 0);
          final bolla = find.byKey(Key('oracolo_bolla_${c.ruolo.name}'));
          await tester.ensureVisible(bolla);
          await tester.pump();
          expect(_testoSotto(tester, bolla), contains(atteso));
        }
      });
    }
  });

  group('FY.20 la barra del titolo resta semitrasparente', () {
    testWidgets('in ogni stato e scorrendo, lo stesso velo, mai pieno',
        (tester) async {
      await _monta(tester);
      final opacita = <String, double>{};
      double velo() {
        final barra = find.byKey(const Key('oracolo_barra'));
        final m = tester.widget<Material>(
            find.descendant(of: barra, matching: find.byType(Material)).first);
        return m.color!.a;
      }

      opacita['domanda'] = velo();
      await tester.drag(find.byType(ListView).first, const Offset(0, -600));
      await tester.pump(const Duration(milliseconds: 300));
      opacita['domanda, scorrendo'] = velo();
      await tester.drag(find.byType(ListView).first, const Offset(0, 600));
      await tester.pump(const Duration(milliseconds: 300));
      await affidaLaDomanda(tester, 'Devo cambiare lavoro?');
      opacita['scelta'] = velo();
      await scegliLeTreCarte(tester);
      await avviaLaLettura(tester);
      opacita['risposta'] = velo();
      await tester.drag(find.byType(ListView).first, const Offset(0, -900));
      await tester.pump(const Duration(milliseconds: 300));
      opacita['risposta, scorrendo'] = velo();
      print('FY.20 MISURA opacita\' della barra: $opacita');
      for (final o in opacita.values) {
        expect(o, closeTo(OracoloDegliAngeliScreen.veloDellaBarra, 0.01));
        expect(o, lessThan(1));
      }
      // Il titolo sopra il testo che scorre: contrasto fra l'oro del titolo
      // e il testo piu' chiaro della lettura velato dalla barra.
      final p = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
      double contrasto(double a) {
        final sotto = Color.alphaBlend(
            p.deepest.withValues(alpha: a), const Color(0xFFF1ECE2));
        final l1 = p.goldSoft.computeLuminance();
        final l2 = sotto.computeLuminance();
        return (max(l1, l2) + 0.05) / (min(l1, l2) + 0.05);
      }

      print('FY.20 MISURA contrasto del titolo sul testo che scorre sotto: '
          'col velo di prima a 0,16 ${contrasto(0.16).toStringAsFixed(2)}, '
          'col velo di adesso a ${OracoloDegliAngeliScreen.veloDellaBarra} '
          '${contrasto(OracoloDegliAngeliScreen.veloDellaBarra).toStringAsFixed(2)}');
      expect(contrasto(OracoloDegliAngeliScreen.veloDellaBarra),
          greaterThan(contrasto(0.16)));
    });
  });
}

/// La luminanza media delle strisce ai lati del dorso dipinto della prima
/// carta (fra il 10 e il 25 per cento della sua larghezza da ogni lato,
/// nella meta' alta della carta), nella cattura e nei due fotogrammi.
Future<({double cattura, double vuoto, double dipinto})> _lumiDelDorsoDipinto(
    WidgetTester tester) async {
  late ({double cattura, double vuoto, double dipinto}) esito;
  await tester.runAsync(() async {
    final rb =
        _radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final img = await rb.toImage();
    final dati = (await img.toByteData())!;
    // La cattura si scrive solo a richiesta (--dart-define=CATTURE=si): la
    // misura si prende sempre, sui pixel in memoria.
    if (const String.fromEnvironment('CATTURE').isNotEmpty) {
      final png = (await img.toByteData(format: ui.ImageByteFormat.png))!;
      final dir = Directory('docs/collaudo/FY/oracolo');
      if (!dir.existsSync()) dir.createSync(recursive: true);
      File('${dir.path}/fy17_carta_di_taglio_sull_altare_vuoto.png')
          .writeAsBytesSync(png.buffer.asUint8List());
    }
    final w = img.width;
    final s = w / GeometriaDellAltare.fotogramma.width;
    // Le strisce in pixel del fotogramma.
    const centro = 274.5;
    const larga = 215.0;
    final colonne = <double>[
      for (var f = 0.10; f <= 0.25; f += 0.03) centro - larga * (0.5 - f),
      for (var f = 0.10; f <= 0.25; f += 0.03) centro + larga * (0.5 - f),
    ];
    final righe = [for (var y = 1560.0; y <= 1610; y += 5) y];
    double media(ByteData d, int largo, double scala) {
      var somma = 0.0;
      var n = 0;
      for (final x in colonne) {
        for (final y in righe) {
          final px = (x * scala).round();
          final py = (y * scala).round();
          final i = (py * largo + px) * 4;
          somma += 0.2126 * d.getUint8(i) +
              0.7152 * d.getUint8(i + 1) +
              0.0722 * d.getUint8(i + 2);
          n++;
        }
      }
      return somma / n;
    }

    Future<double> delFotogramma(String asset) async {
      final bytes = File(asset).readAsBytesSync();
      final codec = await ui.instantiateImageCodec(Uint8List.fromList(bytes));
      final fr = await codec.getNextFrame();
      final d = (await fr.image.toByteData())!;
      final v = media(d, fr.image.width, 1);
      fr.image.dispose();
      return v;
    }

    esito = (
      cattura: media(dati, w, s),
      vuoto: await delFotogramma(GeometriaDellAltare.primoFotogramma),
      dipinto: await delFotogramma(GeometriaDellAltare.ultimoFotogramma),
    );
    img.dispose();
  });
  return esito;
}
