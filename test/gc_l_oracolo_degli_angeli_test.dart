// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';

import 'package:esoteric_circle/core/angels/angel_catalog.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/oracolo_angeli/i_ruoli_e_l_estrazione.dart';
import 'package:esoteric_circle/core/oracolo_angeli/il_corpus_dell_oracolo.g.dart';
import 'package:esoteric_circle/core/oracolo_angeli/la_lettura_dell_oracolo.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sensi/catalogo_suoni.dart';
import 'package:esoteric_circle/core/sensi/la_suoneria.dart';
import 'package:esoteric_circle/core/sensi/palette_sensoriale.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/design_system/components/cosmos_background.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/angels/oracolo/la_geometria_dell_altare.dart';
import 'package:esoteric_circle/features/angels/oracolo/oracolo_degli_angeli_screen.dart';
import 'package:esoteric_circle/features/respiro_della_luna/i_comandi_dipinti.dart';
import 'package:esoteric_circle/features/scene/la_scena_in_video.dart';
import 'package:esoteric_circle/features/tarot/attesa_di_medora.dart';
import 'package:esoteric_circle/features/tarot/stesa_fan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';
import 'il_giro_dell_oracolo.dart';

/// **ORDINE GC, PARTE B: L'ORACOLO DEGLI ANGELI.** 22 ottobre 2026.
///
/// Le prove delle voci da GC.08 a GC.19. Il modello e' finto (R2); il
/// filmato non si apre (la scena e' ferma da subito), cosi' tutto cio' che
/// sta sotto la scena e' in vista.
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

Future<({List<String> richieste, List<Map<String, Object?>> campi})> _monta(
    WidgetTester tester,
    {Tier tier = Tier.tier1,
    double rapporto = 1,
    bool suono = false}) async {
  SharedPreferences.setMockInitialValues({});
  await tester.pumpWidget(const SizedBox());
  tester.view.physicalSize = Size(390 * rapporto, 844 * rapporto);
  tester.view.devicePixelRatio = rapporto;
  addTearDown(tester.view.reset);
  final richieste = <String>[];
  final campi = <Map<String, Object?>>[];
  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => MaestroController()),
      ChangeNotifierProvider(create: (_) => QualityTierController()),
      ChangeNotifierProvider(
          create: (_) => SettingsController(
              suonoEVibrazione: suono, effettiSonori: suono)),
      ChangeNotifierProvider(create: (_) => EntitlementService(initial: tier)),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (c, figlio) => MaestroScope(child: figlio!),
      home: OracoloDegliAngeliScreen(
        fabbricaDellaScena: _Ferma.new,
        caso: Random(7),
        adesso: () => DateTime(2026, 10, 15, 10, 5),
        identita: _nascita,
        chiamata: (i, r, c) async {
          richieste.add(r);
          campi.add(c);
          return jsonFintoDellOracolo(c);
        },
      ),
    ),
  ));
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  return (richieste: richieste, campi: campi);
}

bool _spento(WidgetTester tester, String chiave) =>
    tester.widget<PulsanteDipinto>(find.byKey(Key(chiave))).onTap == null;

void main() {
  setUp(() {
    LaSuoneria.spentaPerLeProve = false;
    // GC.16: il cosmo dietro l'Oracolo ascolta i sensori.
    silenziaISensoriDelCosmo();
  });
  tearDown(() {
    LaSuoneria.spentaPerLeProve = null;
    PaletteSensoriale.spia = null;
  });

  group('GC.08 all\'apertura non si vede la carta ne\' il messaggio', () {
    testWidgets('nessuna carta e nessun messaggio, finche\' non si legge',
        (tester) async {
      await _monta(tester);
      for (final chiave in const [
        'oracolo_angelo_dell_ora',
        'oracolo_messaggio_del_giorno',
        'oracolo_nome_dell_ora',
        'oracolo_responso',
      ]) {
        expect(find.byKey(Key(chiave)), findsNothing,
            reason: 'all\'apertura si vede $chiave');
      }
      expect(find.byType(LaCartaDellAngelo), findsNothing,
          reason: 'all\'apertura si vede una carta');
      await consultaLOracolo(tester, 'Devo cambiare lavoro?');
      expect(find.byKey(const Key('oracolo_angelo_dell_ora')), findsOneWidget,
          reason: 'dopo la lettura l\'angelo dell\'ora non torna');
    });
  });

  group('GC.09 l\'ordine della schermata sotto il tavolo', () {
    testWidgets(
        'domanda, una carta o tre, ventaglio coi gesti, pulsante: in '
        'quest\'ordine, spenti finche\' non servono', (tester) async {
      await _monta(tester);
      final scena = tester.getRect(find.byKey(const Key('oracolo_scena')));
      final ordine = [
        for (final k in const [
          'oracolo_domanda',
          'oracolo_opzioni',
          'oracolo_mazzo_coperto',
          'oracolo_avvia_la_lettura',
        ])
          tester.getRect(find.byKey(Key(k))).top,
      ];
      print('GC.09: scena fino a ${scena.bottom.toStringAsFixed(0)}, '
          'domanda ${ordine[0].toStringAsFixed(0)}, opzioni '
          '${ordine[1].toStringAsFixed(0)}, mazzo ${ordine[2].toStringAsFixed(0)}, '
          'pulsante ${ordine[3].toStringAsFixed(0)}');
      expect(ordine.first, greaterThanOrEqualTo(scena.bottom - 0.5),
          reason: 'la domanda non sta sotto il tavolo');
      for (var i = 1; i < ordine.length; i++) {
        expect(ordine[i], greaterThan(ordine[i - 1]),
            reason: 'l\'ordine sotto il tavolo e\' cambiato');
      }
      // All'apertura: il ventaglio velato e senza tocchi, il pulsante spento.
      expect(_spento(tester, 'oracolo_avvia_la_lettura'), isTrue);
      final velo = tester.widget<AnimatedOpacity>(find
          .ancestor(
              of: find.byKey(const Key('stesa_fan')),
              matching: find.byType(AnimatedOpacity))
          .first);
      expect(velo.opacity, lessThan(1), reason: 'il ventaglio non e\' grigio');
      // Affidata la domanda il ventaglio si accende, ma il pulsante resta
      // spento finche' le carte non sono tutte scelte.
      await affidaLaDomanda(tester, 'Devo partire?');
      expect(_spento(tester, 'oracolo_avvia_la_lettura'), isTrue);
      await scegliLeTreCarte(tester, dorsiDelGiro.take(2).toList());
      expect(_spento(tester, 'oracolo_avvia_la_lettura'), isTrue);
      // Il cambio di stesa a meta' scelta rimette le carte nel mazzo e lo
      // dice.
      await scegliQuanteCarte(tester, 1);
      expect(find.byKey(const Key('oracolo_riga_del_cambio')), findsOneWidget);
      await toccaIlDorso(tester, dorsiDelGiro.first);
      expect(_spento(tester, 'oracolo_avvia_la_lettura'), isFalse,
          reason: 'una carta scelta nella stesa a una carta, e il pulsante '
              'resta spento');
    });
  });

  group('il tavolo resta in vista mentre si scelgono le carte', () {
    // Il fondatore, 22 ottobre 2026 alle 21:30, sul Realme: "quando l'utente
    // sceglie le carte, sia visibile anche il piano dove vanno a poggiare le
    // carte scelte". La finestra e' quella vera del Realme sotto la fascia
    // dell'app: 360 punti per 690 (1080 per 2158 pixel a densita' 3, meno
    // la fascia col cammino e gli Eos). Dopo l'affido, il posto delle carte
    // sull'altare sta sotto la barra del titolo e il ventaglio sta tutto
    // dentro la finestra.
    for (final finestra in const [Size(360, 690), Size(390, 760)]) {
      testWidgets('a ${finestra.width.toInt()} per ${finestra.height.toInt()}',
          (tester) async {
        await _monta(tester);
        tester.view.physicalSize = finestra * 3;
        tester.view.devicePixelRatio = 3;
        for (var i = 0; i < 6; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        await affidaLaDomanda(tester, 'Devo cambiare lavoro?');
        for (var i = 0; i < 12; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        final barra = tester.getRect(find.byType(AppBar)).bottom;
        final scena = tester.getRect(find.byKey(const Key('oracolo_scena')));
        final posto = GeometriaDellAltare.sullAltare(0, scena.width)
            .shift(scena.topLeft);
        final ventaglio = tester.getRect(find.byType(StesaFan));
        print('Il tavolo in vista, ${finestra.width.toInt()} per '
            '${finestra.height.toInt()}: posto delle carte da '
            '${posto.top.toStringAsFixed(0)} a '
            '${posto.bottom.toStringAsFixed(0)}, barra fino a '
            '${barra.toStringAsFixed(0)}, ventaglio da '
            '${ventaglio.top.toStringAsFixed(0)} a '
            '${ventaglio.bottom.toStringAsFixed(0)}');
        expect(posto.top, greaterThanOrEqualTo(barra),
            reason: 'il posto delle carte sta sotto la barra del titolo');
        expect(ventaglio.bottom, lessThanOrEqualTo(finestra.height),
            reason: 'il ventaglio esce dalla finestra');
      });
    }
  });

  group('GC.10 il video sale di dieci pixel del telefono', () {
    for (final rapporto in const [1.0, 3.0]) {
      testWidgets('a densita\' $rapporto la scena sale di 10 pixel fisici',
          (tester) async {
        await _monta(tester, rapporto: rapporto);
        final fotogramma =
            tester.getRect(find.byKey(const Key('oracolo_fotogramma'))).top;
        // I dieci pixel del fondatore ("1 del telefono"), scritti qui come
        // numero: letti dalla costante, la prova seguiva la costante anche
        // quando la costante era zero (Regola A, vista cieca con l'innesto).
        const pixelDelFondatore = 10;
        final attesa = -pixelDelFondatore / rapporto;
        print('GC.10: densita\' $rapporto, la scena comincia a '
            '${fotogramma.toStringAsFixed(3)} punti (attesi '
            '${attesa.toStringAsFixed(3)})');
        expect(fotogramma, closeTo(attesa, 0.01));
      });
    }
  });

  group('GC.11 la tendina si chiude e il pulsante ha la freccia di invio', () {
    testWidgets('scelta la domanda la tendina sparisce', (tester) async {
      await _monta(tester);
      final unTema = find.byKey(const Key('oracolo_tema_amore'));
      await Scrollable.ensureVisible(tester.element(unTema.first),
          alignment: 0.3);
      await tester.pump();
      await tester.tap(unTema.first);
      await tester.pump();
      expect(find.byKey(const Key('oracolo_proposte')), findsOneWidget);
      await tester.tap(find.byKey(const Key('oracolo_proposta_0')));
      await tester.pump();
      expect(find.byKey(const Key('oracolo_proposte')), findsNothing,
          reason: 'scelta la domanda la tendina resta aperta');
      final campo = tester
          .widget<TextField>(find.byKey(const Key('oracolo_campo_domanda')));
      expect(campo.controller!.text, isNotEmpty);
      final icona = tester
          .widget<Icon>(find.byKey(const Key('oracolo_simbolo_dell_invio')));
      expect(icona.icon, Icons.keyboard_return_rounded);
    });
  });

  group('GC.12 la carta toccata vola dal mazzo alla sua posizione', () {
    testWidgets('parte dal dorso toccato, arriva al suo posto, suona una volta',
        (tester) async {
      await _monta(tester, suono: true);
      final sentiti = <SuonoDelCerchio>[];
      PaletteSensoriale.spia = sentiti.add;
      await affidaLaDomanda(tester, 'Devo partire?');
      final dorso = find.byKey(Key('stesa_fan_${dorsiDelGiro.first}'));
      await Scrollable.ensureVisible(tester.element(dorso), alignment: 0.5);
      await tester.pump();
      final da = tester.getRect(dorso);
      await tester.tapAt(Offset(da.left + 12, da.center.dy));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));
      final volo = find.byKey(const Key('oracolo_carta_in_volo'));
      expect(volo, findsOneWidget, reason: 'la carta toccata non vola');
      final partenza = tester.getRect(volo);
      expect((partenza.center - da.center).distance, lessThan(da.width),
          reason: 'la carta in volo non parte dal dorso toccato');
      for (var i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(volo, findsNothing);
      expect(find.byKey(const Key('oracolo_dorso_0')), findsOneWidget,
          reason: 'il dorso non e\' arrivato al primo posto');
      expect(sentiti.where((s) => s == SuonoDelCerchio.carta).length, 1,
          reason: 'il volo deve suonare una volta: $sentiti');
    });
  });

  group('GC.13 e GC.14 riflessione, suono, carte che si girano e si alzano',
      () {
    testWidgets(
        'la sequenza dopo l\'invio, i suoni, le scritte e la carta che '
        'si apre', (tester) async {
      await _monta(tester, suono: true);
      await affidaLaDomanda(tester, 'Devo partire?');
      await scegliLeTreCarte(tester);
      final sentiti = <SuonoDelCerchio>[];
      PaletteSensoriale.spia = sentiti.add;
      final pulsante = find.byKey(const Key('oracolo_avvia_la_lettura'));
      await Scrollable.ensureVisible(tester.element(pulsante), alignment: 0.5);
      await tester.pump();
      await tester.tap(pulsante);
      var vistaLaRiflessione = false;
      for (var i = 0;
          i < 400 &&
              find.byKey(const Key('oracolo_responso')).evaluate().isEmpty;
          i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (find.byType(AttesaDiMedora).evaluate().isNotEmpty) {
          vistaLaRiflessione = true;
          expect(sentiti, isEmpty,
              reason: 'un suono parte prima della fine della riflessione');
        }
      }
      expect(vistaLaRiflessione, isTrue,
          reason: 'dopo l\'invio non c\'e\' la riflessione della Stesa');
      expect(sentiti.first, SuonoDelCerchio.rivelazione,
          reason: 'dopo la riflessione non suona la rivelazione: $sentiti');
      expect(sentiti.where((s) => s == SuonoDelCerchio.rivelazione).length, 1);
      expect(sentiti.where((s) => s == SuonoDelCerchio.carta).length, 3,
          reason: 'ogni carta che si gira suona: $sentiti');
      for (final (posto, parola) in const [
        (0, 'FARE'),
        (1, 'SENTIRE'),
        (2, 'CAPIRE'),
      ]) {
        expect(
            tester.widget<Text>(find.byKey(Key('oracolo_parola_$posto'))).data,
            parola);
      }
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 4000));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.tap(find.byKey(const Key('oracolo_in_piedi_1')),
          warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byKey(const Key('oracolo_carta_aperta')), findsOneWidget,
          reason: 'la carta in piedi non si apre');
      expect(
          find.byKey(const Key('oracolo_carta_aperta_nome')), findsOneWidget);
    });
  });

  group('GC.15 il responso come nella Stesa', () {
    test('ogni carta singola e\' il titolo e il suo messaggio, senza riquadro',
        () {
      var carte = 0;
      final guasti = <String>[];
      for (final a in AngelCatalog.all) {
        for (final r in RuoloDellAngelo.values) {
          final c = CartaDellOracolo(ruolo: r, angelo: a, portatore: a);
          final s =
              LaLetturaDellOracolo.responsoDellaCarta(corpusDellOracolo, c, 0)!;
          carte++;
          if (!s.singola || s.cosaFare.isNotEmpty || s.paragrafi.length != 1) {
            guasti.add('Oracolo, ${a.name} ${r.name}: ${s.paragrafi.length} '
                'paragrafi');
          }
        }
      }
      cardinaleMinimo(carte, 216, cosa: 'carte singole dell\'Oracolo');
      expect(guasti, isEmpty, reason: guasti.take(6).join('\n'));
    });

    testWidgets(
        'prima le carte uscite, poi il colpo d\'occhio, poi il titolo; '
        'la bolla senza "Cosa fare adesso"', (tester) async {
      await _monta(tester);
      await consultaLOracolo(tester, 'Devo cambiare casa?');
      double cima(String k) => tester.getRect(find.byKey(Key(k))).top;
      final quante = cima('oracolo_quante_nel_responso');
      final uscite = cima('oracolo_carte_uscite');
      final colpo = cima('oracolo_colpo_d_occhio');
      final titolo = cima('oracolo_principale_titolo');
      expect(quante < uscite && uscite < colpo && colpo < titolo, isTrue,
          reason: 'l\'ordine del responso e\' cambiato: $quante $uscite '
              '$colpo $titolo');
      for (final r in RuoloDellAngelo.values) {
        expect(
            find.byKey(Key('oracolo_carta_singola_${r.name}_titolo_cosa_fare')),
            findsNothing,
            reason: 'la carta ${r.name} ha il riquadro "Cosa fare adesso"');
      }
    });
  });

  group('GC.16 lo sfondo e\' cosmico', () {
    testWidgets('il cosmo sta dietro tutta la schermata', (tester) async {
      await _monta(tester);
      final cosmo = find.byKey(const Key('oracolo_sfondo'));
      expect(cosmo, findsOneWidget);
      expect(tester.widget(cosmo), isA<CosmosBackground>());
      expect(
          find.descendant(
              of: cosmo, matching: find.byKey(const Key('oracolo_scena'))),
          findsOneWidget,
          reason: 'la scena non sta sopra il cosmo');
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.backgroundColor, Colors.transparent);
    });
  });

  group('GC.17 la stesa a una carta e la consultazione', () {
    test('la carta del momento non ha ruolo ne\' portatore e si scopre', () {
      final c = EstrazioneDellOracolo.dallaScelta(12).single;
      expect(c.delMomento, isTrue);
      expect(c.coperta, isFalse);
      expect(c.portatore, isNull);
      final r = LaLetturaDellOracolo.richiesta(
          domanda: 'Devo partire?',
          carte: [c],
          corpus: corpusDellOracolo,
          variante: 0);
      expect(r, contains(LaLetturaDellOracolo.etichettaDellaCartaDelMomento));
      expect(r, isNot(contains('CUSTODE')),
          reason: 'la carta del momento si nomina col ruolo del Custode');
    });

    testWidgets('la stesa a una carta: la scritta, il responso, un gradino',
        (tester) async {
      final esito = await _monta(tester);
      await scegliQuanteCarte(tester, 1);
      await affidaLaDomanda(tester, 'Devo partire?');
      await toccaIlDorso(tester, dorsiDelGiro.first);
      await avviaLaLettura(tester);
      expect(esito.richieste, hasLength(1),
          reason: 'la stesa a una carta non chiede la sua lettura');
      expect(esito.richieste.single,
          contains(LaLetturaDellOracolo.etichettaDellaCartaDelMomento));
      expect(
          tester.widget<Text>(find.byKey(const Key('oracolo_parola_1'))).data,
          'LA CARTA DEL MOMENTO');
      expect(
          tester
              .widget<Text>(
                  find.byKey(const Key('oracolo_quante_nel_responso')))
              .data,
          'STESA A UNA CARTA');
      expect(find.byKey(const Key('oracolo_gradino_1')), findsOneWidget);
      expect(find.byKey(const Key('oracolo_gradino_0')), findsNothing);
      expect(find.byKey(const Key('oracolo_gradino_2')), findsNothing);
    });

    test('la stesa a una carta conta come una consultazione', () {
      // Nel codice la consultazione si registra prima della scelta fra una
      // carta e tre, una volta sola, senza condizioni sul numero di carte.
      final s =
          File('lib/features/angels/oracolo/oracolo_degli_angeli_screen.dart')
              .readAsStringSync();
      final avvio = s.substring(s.indexOf('Future<void> _avviaLaLettura()'),
          s.indexOf('Future<void> _leCarteSiGiranoESiAlzano'));
      expect('registraOracolo('.allMatches(avvio).length, 1);
      final riga =
          avvio.split('\n').firstWhere((r) => r.contains('registraOracolo('));
      expect(riga.trim(), '_forse<QuestionAllowance>()?.registraOracolo(tier);',
          reason: 'la consultazione non si registra per ogni stesa');
    });
  });

  group('GC.18 il livello visivo del responso dell\'Oracolo', () {
    testWidgets('i gradini accesi seguono le carte uscite', (tester) async {
      await _monta(tester);
      await consultaLOracolo(tester, 'Devo cambiare casa?');
      for (final g in [0, 1, 2]) {
        expect(find.byKey(Key('oracolo_gradino_$g')), findsOneWidget,
            reason: 'il gradino $g non si accende');
      }
      for (final r in RuoloDellAngelo.values) {
        expect(find.byKey(Key('oracolo_coro_${r.name}')), findsOneWidget,
            reason: 'la carta ${r.name} non porta il suo coro');
      }
    });

    testWidgets('l\'assaggio del Viandante accende solo il Custode',
        (tester) async {
      await _monta(tester, tier: Tier.free);
      await consultaLOracolo(tester, 'Devo cambiare casa?');
      expect(find.byKey(const Key('oracolo_gradino_0')), findsOneWidget);
      expect(find.byKey(const Key('oracolo_gradino_1')), findsNothing);
      expect(find.byKey(const Key('oracolo_gradino_2')), findsNothing);
    });
  });

  group('GC.19 la profondita\' Lunga nell\'Oracolo', () {
    testWidgets('scelta la Lunga, due paragrafi al solo responso principale',
        (tester) async {
      final esito = await _monta(tester, tier: Tier.tier1);
      final tendina = find.byKey(const Key('oracolo_profondita'));
      await Scrollable.ensureVisible(tester.element(tendina), alignment: 0.2);
      await tester.pump();
      await tester.tap(tendina);
      // Il menu si apre in piu' fotogrammi: si tocca la voce a menu aperto.
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.tap(find.text('Lunga').last);
      await tester.pump(const Duration(milliseconds: 400));
      await consultaLOracolo(tester, 'Devo cambiare casa?');
      expect(esito.campi.single.containsKey('approfondimento'), isTrue,
          reason: 'la Lunga scelta non chiede l\'approfondimento');
      expect(find.byKey(const Key('oracolo_principale_titolo_rito')),
          findsOneWidget,
          reason: 'la Lunga non ha "Il salmo propiziatorio"');
      for (final r in RuoloDellAngelo.values) {
        expect(
            find.byKey(Key('oracolo_carta_singola_${r.name}_approfondimento')),
            findsNothing,
            reason: 'la carta ${r.name} ha ricevuto la Lunga');
      }
    });

    testWidgets('all\'apertura e\' Breve: nessun approfondimento chiesto',
        (tester) async {
      final esito = await _monta(tester, tier: Tier.tier1);
      await consultaLOracolo(tester, 'Devo cambiare casa?');
      expect(esito.campi.single.containsKey('approfondimento'), isFalse);
    });
  });
}
