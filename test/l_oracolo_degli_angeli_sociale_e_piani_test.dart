// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:esoteric_circle/core/angels/guardian_angels.dart';
import 'package:esoteric_circle/core/astro/birth_details.dart';
import 'package:esoteric_circle/core/cerchio/il_cerchio_sociale.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/il_consenso_della_spesa.dart';
import 'package:esoteric_circle/core/entitlement/listino_degli_eos.dart';
import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/identity/birth_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/oracolo_angeli/i_ruoli_e_l_estrazione.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sensi/la_suoneria.dart';
import 'package:esoteric_circle/core/settings/settings_controller.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/angels/oracolo/oracolo_degli_angeli_screen.dart';
import 'package:esoteric_circle/features/angels/oracolo/oracolo_share_card.dart';
import 'package:esoteric_circle/features/scene/la_scena_in_video.dart';
import 'package:esoteric_circle/features/synastry/la_nascita_dell_altra_persona.dart';
import 'package:esoteric_circle/features/synastry/la_tua_nascita_per_una_lettura.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'porta_finta_del_cerchio_sociale.dart';

/// **L'ORACOLO DEGLI ANGELI: IL SOCIALE, I PIANI E GLI EOS.** Ordine FU voci
/// FU.09 e FU.10, 15 ottobre 2026.
///
/// FU.09: la carta in dono a un amico del Cerchio col prezzo detto prima del
/// gesto, la domanda per un amico coi suoi tre angeli dalla nascita prestata
/// col suo consenso (lo stesso gesto della lettura a due telefoni, ordine
/// FT), la card condivisibile con le tre carte e il titolo, mai la domanda e
/// mai la nascita.
///
/// FU.10: l'assaggio del Viandante (solo il Custode, senza modello, Cuore e
/// Intelletto col lucchetto), le consultazioni al giorno contate col budget
/// del server, la consultazione in piu' a Eos, la Lunga e la domanda per un
/// amico dall'Adepto.

// ---------------------------------------------------------------------------
// Le finte
// ---------------------------------------------------------------------------

class _Finta implements LettoreDiScena {
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
  Widget disegna() => const SizedBox();
  @override
  void chiudi() {}
}

/// Il borsellino del server: il listino del riscatto porta il budget
/// dell'Oracolo solo quando [conIlBudget] (il server nuovo, non pubblicato).
class _PortaDelBorsellino extends PortaDelCerchio {
  _PortaDelBorsellino({this.conIlBudget = true});

  final bool conIlBudget;
  final List<String> motivi = [];
  int _saldo = 1000;

  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato(
      {Object? cammino, bool azzeraIlCammino = false}) async {
    return StatoDelCerchio.daMappa({
      'giorno': '2026-10-15',
      'spesi': const {'domande': 0},
      'saldoEos': _saldo,
      'listinoDelRiscatto': {
        'domande': 80,
        if (conIlBudget) 'oracoliAngeli': 100,
      },
    });
  }

  @override
  Future<int?> muoviGliEos({
    required String causale,
    required String motivo,
    required String idMovimento,
    int? quanti,
  }) async {
    motivi.add(motivo);
    _saldo -= quanti ?? 0;
    return _saldo;
  }

  @override
  Future<EsitoDelConsumo?> consuma(
          {required String budget, required String idMovimento}) async =>
      null;

  @override
  Future<bool> scriviLaMemoria({
    required String operazione,
    String? maestro,
    Map<String, Object?> campi = const {},
  }) async =>
      false;

  @override
  Future<bool> cancellaIlCerchio() async => false;
}

/// Il Cerchio sociale finto, che accetta il dono e presta una nascita per
/// l'Oracolo col minuto locale.
class _PortaSociale extends PortaFintaDelCerchioSociale {
  @override
  Future<EsitoSociale?> sociale(String porta,
      [Map<String, Object?> corpo = const {}]) async {
    if (porta == 'mandaUnDono') {
      chieste.add((porta, corpo));
      return const EsitoSociale(dati: {'ok': true});
    }
    if (porta == 'condividiLaNascita') {
      chieste.add((porta, corpo));
      return EsitoSociale(dati: {
        'codice': 'K7Q2AB',
        'scade': DateTime.utc(2100).millisecondsSinceEpoch,
      });
    }
    if (porta == 'leggiLaNascita') {
      chieste.add((porta, corpo));
      return const EsitoSociale(dati: {
        'nascita': '1992-09-03T06:15:00.000Z',
        'giorno': '1992-09-03',
        'oraNota': true,
        'nome': 'Giulia',
        'scopo': 'oracolo',
        'minutoLocale': 8 * 60 + 15,
        'amoreApribile': false,
      });
    }
    return super.sociale(porta, corpo);
  }
}

final _palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));
final _nascita = BirthIdentity(
    birthMoment: DateTime(1990, 5, 12, 14, 30), hasBirthTime: true);
const _domanda = 'Devo lasciare il mio lavoro a Torino?';

Future<
        ({
          List<(String, Set<String>)> chiamate,
          _PortaSociale sociale,
          _PortaDelBorsellino borsello,
        })>
    _monta(WidgetTester tester,
        {Tier tier = Tier.tier1, bool conIlBudget = true}) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final chiamate = <(String, Set<String>)>[];
  final portaSociale = _PortaSociale();
  final sociale = IlCerchioSociale(porta: portaSociale);
  final borsello = _PortaDelBorsellino(conIlBudget: conIlBudget);
  final borsa = QuestionAllowance(porta: borsello);
  await tester.runAsync(() async {
    await sociale.sincronizza(identita: _nascita, oggi: DateTime(2026, 10, 15));
    await sociale.caricaIlCerchio();
    await borsa.sincronizza();
  });
  await tester.pumpWidget(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => MaestroController()),
      ChangeNotifierProvider(create: (_) => QualityTierController()),
      ChangeNotifierProvider(
          create: (_) => SettingsController(suonoEVibrazione: true)),
      ChangeNotifierProvider(create: (_) => EntitlementService(initial: tier)),
      ChangeNotifierProvider<QuestionAllowance>.value(value: borsa),
      ChangeNotifierProvider<IlCerchioSociale>.value(value: sociale),
      ChangeNotifierProvider(
          create: (_) => ProfileController(identity: _nascita)),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: (context, figlio) => MaestroScope(child: figlio!),
      home: OracoloDegliAngeliScreen(
        fabbricaDellaScena: _Finta.new,
        caso: Random(7),
        adesso: () => DateTime(2026, 10, 15, 10, 5),
        identita: _nascita,
        chiamata: (i, r, c) async {
          chiamate.add((r, c.keys.toSet()));
          return jsonEncode({
            'titolo': 'Gli angeli ti chiedono un passo lento',
            'riquadro': 'Senti dove il cuore si apre e lascia che sia lui a '
                'scegliere il ritmo di oggi.',
            if (c.containsKey('approfondimento1')) ...{
              'approfondimento1': 'Il primo passo e\' fermarti a guardare.',
              'approfondimento2': 'Poi scegli un gesto piccolo e fallo oggi.',
            },
          });
        },
      ),
    ),
  ));
  for (var i = 0; i < 4; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  return (chiamate: chiamate, sociale: portaSociale, borsello: borsello);
}

Future<void> _affida(WidgetTester tester, [String domanda = _domanda]) async {
  await tester.enterText(
      find.byKey(const Key('oracolo_campo_domanda')), domanda);
  await tester.pump();
  await tester.tap(find.byKey(const Key('oracolo_affida')));
  for (var i = 0; i < 50; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _alCentro(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await Scrollable.ensureVisible(tester.element(f), alignment: 0.5);
  await tester.pump();
}

/// Tutto il testo dipinto sotto [radice], letto dai `Text` e dai `RichText`.
List<String> _testiSotto(WidgetTester tester, Finder radice) => [
      for (final e in find
          .descendant(of: radice, matching: find.byType(RichText))
          .evaluate())
        (e.widget as RichText).text.toPlainText(),
    ];

void main() {
  setUp(() => LaSuoneria.spentaPerLeProve = false);
  tearDown(() => LaSuoneria.spentaPerLeProve = null);

  group('FU.09 la card condivisibile', () {
    testWidgets(
        'le tre carte e il titolo; mai la domanda, mai i tre angeli della '
        'persona, mai una data o un\'ora', (tester) async {
      final triade = GuardianAngels.forBirth(_nascita.toBirthDetails());
      // Un caso in cui nessuna delle tre carte estratte e' uno dei tre angeli
      // della persona: cosi' un loro nome sulla card si vedrebbe.
      late List<CartaDellOracolo> carte;
      for (var seme = 0;; seme++) {
        carte = EstrazioneDellOracolo.estrai(triade, Random(seme));
        final suoi = {
          triade.guardian.name,
          triade.heart.name,
          triade.intellect!.name
        };
        if (!carte.any((c) => suoi.contains(c.angelo.name))) break;
      }
      tester.view.physicalSize = const Size(500, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: OracoloShareCard(
              key: const Key('la_card'),
              carte: carte,
              titolo: OracoloShareCard.titoloPerLaCard(
                  'Gli angeli ti chiedono un passo lento', _domanda),
              palette: _palette,
            ),
          ),
        ),
      ));
      await tester.pump();
      final testi = _testiSotto(tester, find.byKey(const Key('la_card')));
      final tutto = testi.join(' | ');
      print('FU.09 MISURA card: testi ${testi.length}: $tutto');
      for (final c in carte) {
        expect(find.byKey(Key('card_oracolo_carta_${c.ruolo.name}')),
            findsOneWidget);
        expect(tutto, contains(c.angelo.name));
      }
      expect(find.byKey(const Key('card_oracolo_titolo')), findsOneWidget);
      expect(tutto, contains('Gli angeli ti chiedono un passo lento'));
      // MAI LA DOMANDA: ne' intera ne' un suo pezzo riconoscibile.
      expect(tutto.toLowerCase(), isNot(contains('torino')));
      expect(tutto.toLowerCase(), isNot(contains('lavoro')));
      // MAI LA NASCITA: ne' i tre angeli che la dicono, ne' data o ora.
      for (final suo in [
        triade.guardian.name,
        triade.heart.name,
        triade.intellect!.name
      ]) {
        expect(tutto, isNot(contains(suo)),
            reason: 'il nome di un angelo della persona dice la sua nascita');
      }
      expect(tutto, isNot(contains('La porta')));
      expect(RegExp(r'1990|\b12/5\b|14:30|maggio').hasMatch(tutto), isFalse);
    });

    test('un titolo che ripete la domanda lascia il posto al titolo del tema',
        () {
      expect(
          OracoloShareCard.titoloPerLaCard(
              'Devo lasciare il mio lavoro a Torino? Sì, piano', _domanda),
          isNot(contains('Torino')));
      expect(
          OracoloShareCard.titoloPerLaCard(
              'Gli angeli ti chiedono un passo lento', _domanda),
          'Gli angeli ti chiedono un passo lento');
    });

    test('la schermata dell\'Oracolo condivide la card, non un testo', () {
      final sorgente =
          File('lib/features/angels/oracolo/oracolo_degli_angeli_screen.dart')
              .readAsStringSync();
      expect(sorgente, contains('shareOracoloCard('));
      expect(sorgente, contains('OracoloShareCard('));
      // Il titolo della card passa dalla regola che non ripete la domanda.
      expect(sorgente, contains('titolo: OracoloShareCard.titoloPerLaCard('));
    });
  });

  group('FU.09 la carta in dono', () {
    testWidgets(
        'il prezzo si legge sul pulsante prima del gesto, e il dono viaggia '
        'col numero della carta e nient\'altro', (tester) async {
      final m = await _monta(tester);
      await _affida(tester);
      final dono = find.byWidgetPredicate((w) =>
          w is TextButton &&
          (w.key is ValueKey<String>) &&
          (w.key as ValueKey<String>).value.startsWith('oracolo_dono_'));
      expect(dono, findsNWidgets(3), reason: 'una per carta scoperta');
      final prezzo = ListinoDegliEos.prezzo(
          ListinoDegliEos.cartaDegliAngeliDaDonare.costo);
      expect(find.textContaining('Mandala in dono, $prezzo'), findsNWidgets(3));
      final primo = dono.first;
      await _alCentro(tester, primo);
      // Prima del gesto non e' partito niente.
      expect(m.sociale.chieste.where((c) => c.$1 == 'mandaUnDono'), isEmpty);
      await tester.tap(primo);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('oracolo_dono_a_u-stella')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('conferma_spesa')), findsOneWidget,
          reason: 'il dono costa Eos: la conferma unica della spesa');
      await tester.tap(find.byKey(const Key('conferma_spesa_procedi')));
      await tester.pumpAndSettle();
      final mandato =
          m.sociale.chieste.singleWhere((c) => c.$1 == 'mandaUnDono').$2;
      print('FU.09 MISURA dono: $mandato');
      expect(mandato['dono'], 'angelo');
      expect(mandato['a'], 'u-stella');
      expect(mandato['carta'], isA<int>());
      expect(mandato.keys.toSet(), {'a', 'dono', 'carta', 'idMovimento'},
          reason: 'col dono non viaggia ne\' la domanda ne\' la nascita');
    });
  });

  group('FU.09 la domanda per un amico', () {
    test('i tre angeli dell\'amico vengono dalla sua nascita prestata', () {
      final giorno = DateTime(1992, 9, 3);
      final attesa = GuardianAngels.forBirth(
          BirthDetails(
              date: giorno, time: const TimeOfDay(hour: 8, minute: 15)),
          sunLongitude: 160.7);
      final letta = GliAngeliDiUnAmico.daNascitaPrestata(
          giorno: giorno, longitudineDelSole: 160.7, minutoLocale: 495);
      expect(letta.guardian.number, attesa.guardian.number);
      expect(letta.heart.number, attesa.heart.number);
      expect(letta.intellect?.number, attesa.intellect?.number);
      final senzaOra = GliAngeliDiUnAmico.daNascitaPrestata(
          giorno: giorno, longitudineDelSole: 160.7);
      expect(senzaOra.intellect, isNull,
          reason: 'senza l\'ora l\'Intelletto resta coperto');
    });

    testWidgets(
        'chi presta la nascita all\'Oracolo legge prima a che cosa serve, e il '
        'consenso dichiara lo scopo', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final porta = _PortaSociale();
      final sociale = IlCerchioSociale(porta: porta);
      await tester.runAsync(() => sociale.sincronizza(
          identita: _nascita, oggi: DateTime(2026, 10, 15)));
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<IlCerchioSociale>.value(value: sociale),
          ChangeNotifierProvider(
              create: (_) => ProfileController(identity: _nascita)),
          ChangeNotifierProvider(create: (_) => MaestroController()),
        ],
        child: MaterialApp(
          builder: (context, figlio) => MaestroScope(child: figlio!),
          home: LaTuaNascitaPerUnaLettura(palette: _palette, perLOracolo: true),
        ),
      ));
      await tester.pumpAndSettle();
      final perche =
          _testiSotto(tester, find.byKey(const Key('la_tua_nascita_perche')))
              .join(' ');
      expect(perche, contains('Oracolo degli Angeli'),
          reason: 'prima del gesto si legge a che cosa serve la nascita');
      expect(perche, isNot(contains('Sinastria')));
      expect(porta.chieste.where((c) => c.$1 == 'condividiLaNascita'), isEmpty);
      await tester.tap(find.byKey(const Key('la_tua_nascita_consenso')));
      await tester.pump();
      await tester.pump();
      final mandata =
          porta.chieste.singleWhere((c) => c.$1 == 'condividiLaNascita').$2;
      print('FU.09 MISURA consenso per l\'Oracolo: ${mandata.keys.toList()}');
      expect(mandata['scopo'], 'oracolo');
      expect(mandata['minutoLocale'], 14 * 60 + 30);
      expect(mandata.keys.toSet(),
          {'nascita', 'giorno', 'oraNota', 'nome', 'scopo', 'minutoLocale'});
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets(
        'per l\'Oracolo la nascita passa solo col codice: niente strada a '
        'mano, e la lettura chiede i consensi dati per l\'Oracolo',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final porta = _PortaSociale();
      final sociale = IlCerchioSociale(porta: porta);
      await tester.runAsync(() => sociale.sincronizza(
          identita: _nascita, oggi: DateTime(2026, 10, 15)));
      NascitaLetta? letta;
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider<IlCerchioSociale>.value(value: sociale),
          ChangeNotifierProvider(
              create: (_) => ProfileController(identity: _nascita)),
          ChangeNotifierProvider(create: (_) => MaestroController()),
        ],
        child: MaterialApp(
          builder: (context, figlio) => MaestroScope(child: figlio!),
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async => letta =
                    await LaNascitaDellAltraPersona.chiedi(context, _palette,
                        perLOracolo: true),
                child: const Text('apri'),
              ),
            ),
          ),
        ),
      ));
      await tester.tap(find.text('apri'));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('nascita_altra_nome')), findsNothing,
          reason: 'per l\'Oracolo la nascita non si scrive a mano');
      expect(find.byKey(const Key('nascita_altra_conferma')), findsNothing);
      await tester.enterText(
          find.byKey(const Key('nascita_altra_codice')), 'k7q2ab');
      await tester.pump();
      await tester.tap(find.byKey(const Key('nascita_altra_leggi')));
      await tester.pumpAndSettle();
      final chiesta =
          porta.chieste.singleWhere((c) => c.$1 == 'leggiLaNascita').$2;
      expect(chiesta['scopo'], 'oracolo');
      expect(letta?.nome, 'Giulia');
      expect(letta?.minutoLocale, 8 * 60 + 15);
    });
  });

  group('FU.10 i piani', () {
    testWidgets(
        'il Viandante: l\'assaggio scopre il Custode senza modello, Cuore e '
        'Intelletto col lucchetto e l\'invito', (tester) async {
      final m = await _monta(tester, tier: Tier.free);
      await _affida(tester);
      print('FU.10 MISURA Viandante: chiamate al modello ${m.chiamate.length}');
      expect(m.chiamate, isEmpty, reason: 'l\'assaggio non chiama il modello');
      expect(find.byKey(const Key('oracolo_bolla_custode')), findsOneWidget);
      expect(find.byKey(const Key('oracolo_bolla_cuore')), findsNothing);
      expect(find.byKey(const Key('oracolo_lucchetto_cuore')), findsOneWidget);
      expect(find.byKey(const Key('oracolo_lucchetto_intelletto')),
          findsOneWidget);
      expect(
          find.byKey(const Key('oracolo_riga_dell_assaggio')), findsOneWidget);
      await _alCentro(tester, find.byKey(const Key('oracolo_lucchetto_cuore')));
      await tester.tap(find.byKey(const Key('oracolo_lucchetto_cuore')));
      await tester.pumpAndSettle();
      expect(find.textContaining('dell’Iniziato'), findsWidgets,
          reason: 'il lucchetto dice da quale piano si apre');
    });

    testWidgets(
        'l\'Iniziato: tre carte e una chiamata Breve; la Lunga e la domanda '
        'per un amico col lucchetto e l\'invito', (tester) async {
      final m = await _monta(tester, tier: Tier.tier1);
      await tester.tap(find.byKey(const Key('oracolo_chiedi_per_un_amico')));
      await tester.pumpAndSettle();
      expect(find.textContaining('La domanda per un amico è dell’Adepto'),
          findsOneWidget);
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      final indietro = find.text('Non ora');
      if (indietro.evaluate().isNotEmpty) {
        await tester.tap(indietro.first);
        await tester.pumpAndSettle();
      }
      await _affida(tester);
      expect(m.chiamate, hasLength(1));
      expect(m.chiamate.single.$2.contains('approfondimento1'), isFalse,
          reason: 'la Lunga e\' dell\'Adepto');
      for (final r in ['custode', 'cuore', 'intelletto']) {
        expect(find.byKey(Key('oracolo_bolla_$r')), findsOneWidget);
      }
      expect(find.byKey(const Key('oracolo_lucchetto_lunga')), findsOneWidget);
    });

    testWidgets('l\'Adepto: la Lunga, senza lucchetto', (tester) async {
      final m = await _monta(tester, tier: Tier.tier2);
      await _affida(tester);
      expect(m.chiamate.single.$2.contains('approfondimento1'), isTrue);
      expect(find.byKey(const Key('oracolo_lucchetto_lunga')), findsNothing);
    });

    testWidgets(
        'finite le consultazioni del giorno, l\'invito con le due strade: '
        'una in piu\' a Eos, o salire di piano', (tester) async {
      final m = await _monta(tester, tier: Tier.tier1);
      for (var i = 0; i < 3; i++) {
        await _affida(tester);
        await _alCentro(tester, find.byKey(const Key('oracolo_nuova_domanda')));
        await tester.tap(find.byKey(const Key('oracolo_nuova_domanda')));
        for (var j = 0; j < 8; j++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
      }
      expect(m.chiamate, hasLength(3));
      await tester.enterText(
          find.byKey(const Key('oracolo_campo_domanda')), _domanda);
      await tester.pump();
      await tester.tap(find.byKey(const Key('oracolo_affida')));
      await tester.pumpAndSettle();
      expect(find.text('Le consultazioni di oggi sono finite'), findsOneWidget);
      expect(find.textContaining('100 Eos'), findsWidgets,
          reason: 'il prezzo della consultazione in piu\' si dice prima');
      expect(m.chiamate, hasLength(3),
          reason: 'oltre il limite nessuna chiamata parte senza il riscatto');
    });
  });

  group('FU.10 i numeri', () {
    test(
        'il budget del telefono si accende col server, e il riscatto ridà '
        'la consultazione', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      final spento =
          QuestionAllowance(porta: _PortaDelBorsellino(conIlBudget: false));
      await spento.sincronizza();
      expect(spento.contaGliOracoli, isFalse);
      final prima = spento.gestiInAttesa;
      spento.registraOracolo(Tier.free);
      expect(spento.puoiConsultareGliAngeli(Tier.free), isTrue);
      expect(spento.gestiInAttesa, prima,
          reason: 'un budget che il server non conosce non entra nella coda');

      final porta = _PortaDelBorsellino();
      final borsa = QuestionAllowance(porta: porta);
      await borsa.sincronizza();
      expect(
          [for (final t in Tier.values) borsa.limiteOracoli(t)], [1, 3, 5, 6]);
      borsa.registraOracolo(Tier.free);
      expect(borsa.puoiConsultareGliAngeli(Tier.free), isFalse);
      final pagato = await borsa.riscatta(QuestionAllowance.kOracoliAngeli,
          consenso: ConsensoDellaSpesa.perLeProve(100));
      expect(pagato, 100);
      expect(porta.motivi.single, 'riscatto_oracoliAngeli');
      expect(borsa.puoiConsultareGliAngeli(Tier.free), isTrue);
    });

    test('il listino, la matrice e il conto del tetto dicono gli stessi numeri',
        () {
      const voce = ListinoDegliEos.consultazioneDegliAngeliInPiu;
      final dallaMatrice = [
        for (final t in Tier.values)
          PlanCatalog.limiteGiornaliero(PlanCatalog.rigaOracoli, t)
      ];
      final dalListino = [for (final t in Tier.values) voce.gratisAlGiorno[t]];
      print('FU.10 MISURA: matrice $dallaMatrice, listino $dalListino, '
          'prezzo ${voce.costo}');
      expect(dalListino, dallaMatrice);
      final strumento =
          File('tool/i_limiti_degli_annuali.py').readAsStringSync();
      final oracoli = RegExp(r'^ORACOLI = \[([^\]]*)\]', multiLine: true)
          .firstMatch(strumento);
      expect(oracoli, isNotNull,
          reason: 'il conto del tetto non conta le consultazioni');
      expect(
          [for (final x in oracoli!.group(1)!.split(',')) int.parse(x.trim())],
          dallaMatrice.sublist(1),
          reason: 'il conto del tetto del costo conta numeri diversi da quelli '
              'della matrice');
      // Le voci chiuse dicono da quale piano si aprono.
      expect(
          PlanCatalog.apre(RigaDelPiano.oracoloTreCarte, Tier.free), isFalse);
      expect(
          PlanCatalog.apre(RigaDelPiano.oracoloTreCarte, Tier.tier1), isTrue);
      expect(PlanCatalog.apre(RigaDelPiano.oracoloLungaEAmico, Tier.tier1),
          isFalse);
      expect(PlanCatalog.apre(RigaDelPiano.oracoloLungaEAmico, Tier.tier2),
          isTrue);
      expect(PlanCatalog.apre(RigaDelPiano.oracoloLungaEAmico, Tier.tier3),
          isTrue);
    });

    test('la Lunga dello schermo si legge dalla matrice, non dal tier a mano',
        () {
      final sorgente =
          File('lib/features/angels/oracolo/oracolo_degli_angeli_screen.dart')
              .readAsStringSync();
      expect(sorgente, isNot(contains('Tier.tier2.index')));
      expect(sorgente, contains('RigaDelPiano.oracoloLungaEAmico'));
    });
  });
}
