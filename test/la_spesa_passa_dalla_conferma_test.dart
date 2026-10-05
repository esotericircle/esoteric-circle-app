import 'dart:io';

import 'package:esoteric_circle/core/cammino/cammino_da_custodire.dart';
import 'package:esoteric_circle/core/entitlement/il_consenso_della_spesa.dart';
import 'package:esoteric_circle/core/entitlement/listino_degli_eos.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/components/la_conferma_della_spesa.dart';
import 'package:esoteric_circle/design_system/components/porta_della_spesa.dart';
import 'package:esoteric_circle/features/maestri/live/l_entrata_nel_vivo.dart';
import 'package:esoteric_circle/features/maestri/live/schermata_live.dart';
import 'package:esoteric_circle/features/pricing/upgrade_invite.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/live/porta_del_live.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// LA SPESA PASSA DALLA CONFERMA. Ordine FD voce 01.
///
/// **Il difetto.** Tredici punti dell'app consumavano Eos o minuti senza una
/// conferma che dicesse costo e saldo con due pulsanti, e il LIVE apriva una
/// sessione a pagamento al primo tocco. L'elenco sta nel rapporto FD.
///
/// **Cosa si prova.**
/// a) ogni famiglia di punti di spesa apre la conferma, e niente si consuma
///    finche' non si tocca il pulsante di conferma;
/// b) "Non ora" lascia saldo e minuti come erano, misurati prima e dopo;
/// c) col saldo corto il pulsante di conferma e' spento e non si consuma;
/// d) la guardia: ogni porta di spesa pretende il consenso, e il consenso lo
///    crea solo la conferma.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  final titolo = find.byKey(const Key('conferma_spesa_titolo'));
  final corpo = find.byKey(const Key('conferma_spesa_corpo'));
  final procedi = find.byKey(const Key('conferma_spesa_procedi'));
  final nonOra = find.byKey(const Key('conferma_spesa_non_ora'));

  String testoDi(WidgetTester tester, Finder f) =>
      tester.widget<Text>(f).data ?? '';

  Future<QuestionAllowance> borsaCon(_PortaCheSpende porta) async {
    final borsa = QuestionAllowance(porta: porta);
    await borsa.sincronizza();
    return borsa;
  }

  Future<void> monta(WidgetTester tester, QuestionAllowance borsa,
      PortaDelCerchio porta, Widget figlio) async {
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider<QuestionAllowance>.value(value: borsa),
        Provider<AppServices>.value(value: AppServices.offline(null, porta)),
      ],
      child: MaterialApp(home: Scaffold(body: Center(child: figlio))),
    ));
    await tester.pump();
  }

  group('a) e b) la porta della spesa', () {
    testWidgets('il tocco apre la conferma, Non ora non spende niente',
        (tester) async {
      final porta = _PortaCheSpende(saldo: 300);
      final borsa = await borsaCon(porta);
      var fatta = 0;
      final voce = ListinoDegliEos.oroscopoLungaDelGiorno;
      await monta(
          tester,
          borsa,
          porta,
          PortaDellaSpesa(
              voce: voce, etichetta: 'Leggi', suSpesaFatta: () => fatta++));

      final prima = borsa.saldoEos;
      await tester.tap(find.byKey(const Key('porta_della_spesa_conferma')));
      await tester.pumpAndSettle();
      expect(testoDi(tester, titolo), 'Stai per usare i tuoi Eos.');
      expect(testoDi(tester, corpo),
          'Questa richiesta costa ${voce.costo} Eos. Nel tuo borsellino ce ne sono 300.');
      expect(find.text('Procedi'), findsOneWidget);
      expect(find.text('Non ora'), findsOneWidget);
      expect(porta.chieste, isEmpty,
          reason: 'la porta ha speso prima della conferma');

      await tester.tap(nonOra);
      await tester.pumpAndSettle();
      // ignore: avoid_print
      print('ORDINE FD VOCE 01, Non ora: saldo prima $prima, dopo '
          '${borsa.saldoEos}, movimenti ${porta.chieste.length}');
      expect(borsa.saldoEos, prima, reason: 'Non ora ha cambiato il saldo');
      expect(porta.chieste, isEmpty, reason: 'Non ora ha speso');
      expect(fatta, 0);

      await tester.tap(find.byKey(const Key('porta_della_spesa_conferma')));
      await tester.pumpAndSettle();
      await tester.tap(procedi);
      await tester.pumpAndSettle();
      expect(porta.chieste, [('spesa', voce.costo)]);
      expect(borsa.saldoEos, prima - voce.costo);
      expect(fatta, 1);
    });

    testWidgets('c) col saldo corto il pulsante e\' spento e non si spende',
        (tester) async {
      final porta = _PortaCheSpende(saldo: 10);
      final borsa = await borsaCon(porta);
      final voce = ListinoDegliEos.oroscopoLungaDelGiorno;
      await monta(tester, borsa, porta,
          PortaDellaSpesa(voce: voce, etichetta: 'Leggi', suSpesaFatta: () {}));

      await tester.tap(find.byKey(const Key('porta_della_spesa_conferma')));
      await tester.pumpAndSettle();
      expect(testoDi(tester, corpo),
          'Questa richiesta costa ${voce.costo} Eos e nel tuo borsellino ce ne sono 10.');
      expect(tester.widget<FilledButton>(procedi).onPressed, isNull,
          reason: 'col saldo corto il pulsante di conferma e\' acceso');
      await tester.tap(procedi, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(porta.chieste, isEmpty);
      expect(borsa.saldoEos, 10);
    });
  });

  group('a) e b) il riscatto del foglio dell\'invito', () {
    Widget pulsante() => Builder(
        builder: (c) => TextButton(
            key: const Key('riscatta'),
            onPressed: () =>
                corredoDelRiscatto(c, budget: 'gettate', cosaUna: 'una gettata')
                    .azione
                    ?.call(),
            child: const Text('Riscatta')));

    testWidgets('il riscatto apre la conferma, Non ora non spende',
        (tester) async {
      final porta = _PortaCheSpende(saldo: 300);
      final borsa = await borsaCon(porta);
      await monta(tester, borsa, porta, pulsante());

      await tester.tap(find.byKey(const Key('riscatta')));
      await tester.pumpAndSettle();
      expect(testoDi(tester, corpo),
          'Questa richiesta costa 60 Eos. Nel tuo borsellino ce ne sono 300.');
      expect(porta.chieste, isEmpty);
      await tester.tap(nonOra);
      await tester.pumpAndSettle();
      expect(porta.chieste, isEmpty, reason: 'Non ora ha riscattato');
      expect(borsa.saldoEos, 300);

      await tester.tap(find.byKey(const Key('riscatta')));
      await tester.pumpAndSettle();
      await tester.tap(procedi);
      await tester.pumpAndSettle();
      expect(porta.chieste, [('spesa', 60)]);
      expect(borsa.saldoEos, 240);
    });

    testWidgets('c) col saldo corto il riscatto apre la conferma spenta',
        (tester) async {
      final porta = _PortaCheSpende(saldo: 20);
      final borsa = await borsaCon(porta);
      await monta(tester, borsa, porta, pulsante());

      await tester.tap(find.byKey(const Key('riscatta')));
      await tester.pumpAndSettle();
      expect(testoDi(tester, corpo),
          'Questa richiesta costa 60 Eos e nel tuo borsellino ce ne sono 20.');
      expect(tester.widget<FilledButton>(procedi).onPressed, isNull);
      expect(porta.chieste, isEmpty);
    });
  });

  group('a) e b) il LIVE', () {
    late List<String> chiamate;
    late Map<Object?, Object?>? minuti;

    setUp(() {
      chiamate = [];
      minuti = {'rimasti': 37, 'durataMassimaSecondi': 1200, 'apribile': true};
      PortaDelLive.chiama = (porta, dati) async {
        chiamate.add(porta);
        if (porta == 'iMinutiDelLive') {
          final m = minuti;
          if (m == null) throw StateError('il server non risponde');
          return m;
        }
        throw StateError('$porta non doveva partire');
      };
    });

    Widget pulsante() => Builder(
        builder: (c) => TextButton(
            key: const Key('entra'),
            onPressed: () => entraNelVivo(c, maestro: Maestro.medora),
            child: const Text('LIVE')));

    testWidgets('il tocco apre la conferma dei minuti e nessuna sessione',
        (tester) async {
      final porta = _PortaCheSpende(saldo: 300);
      await monta(tester, await borsaCon(porta), porta, pulsante());

      await tester.tap(find.byKey(const Key('entra')));
      await tester.pumpAndSettle();
      expect(testoDi(tester, titolo), 'Stai per aprire una sessione dal vivo.');
      expect(testoDi(tester, corpo),
          'Questa sessione consuma 20 minuti dei tuoi 37 minuti disponibili.');
      expect(find.text('Apri la sessione'), findsOneWidget);
      expect(chiamate, ['iMinutiDelLive'],
          reason: 'prima della conferma e\' partito altro che la lettura');

      await tester.tap(nonOra);
      await tester.pumpAndSettle();
      // ignore: avoid_print
      print('ORDINE FD VOCE 01, LIVE con Non ora: chiamate $chiamate');
      expect(chiamate, ['iMinutiDelLive'],
          reason: 'Non ora ha aperto una sessione');
      expect(find.byType(SchermataLive), findsNothing);
    });

    testWidgets('c) senza minuti il pulsante e\' spento', (tester) async {
      minuti = {'rimasti': 0, 'durataMassimaSecondi': 12, 'apribile': false};
      final porta = _PortaCheSpende(saldo: 300);
      await monta(tester, await borsaCon(porta), porta, pulsante());
      await tester.tap(find.byKey(const Key('entra')));
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(procedi).onPressed, isNull);
      expect(find.byType(SchermataLive), findsNothing);
    });

    testWidgets('se i minuti non si leggono la sessione non parte',
        (tester) async {
      minuti = null;
      final porta = _PortaCheSpende(saldo: 300);
      await monta(tester, await borsaCon(porta), porta, pulsante());
      await tester.tap(find.byKey(const Key('entra')));
      await tester.pumpAndSettle();
      expect(titolo, findsNothing);
      expect(find.byKey(const Key('live_minuti_muti')), findsOneWidget);
      expect(chiamate, ['iMinutiDelLive']);
    });
  });

  test('i testi della conferma sono quelli dell\'ordine, alla lettera', () {
    expect(LaConfermaDellaSpesa.corpoDeiMinuti(20, 37),
        'Questa sessione consuma 20 minuti dei tuoi 37 minuti disponibili.');
    expect(LaConfermaDellaSpesa.corpoDegliEos(50, 300),
        'Questa richiesta costa 50 Eos. Nel tuo borsellino ce ne sono 300.');
    expect(LaConfermaDellaSpesa.corpoDegliEosCheNonBastano(50, 10),
        'Questa richiesta costa 50 Eos e nel tuo borsellino ce ne sono 10.');
    expect(LaConfermaDellaSpesa.confermaDeiMinuti, 'Apri la sessione');
    expect(LaConfermaDellaSpesa.confermaDegliEos, 'Procedi');
    expect(LaConfermaDellaSpesa.nonOra, 'Non ora');
  });

  // d) LA GUARDIA.
  test('d) ogni porta di spesa pretende il consenso, e lo crea la conferma',
      () {
    const conferma =
        'lib/design_system/components/la_conferma_della_spesa.dart';
    const consenso = 'lib/core/entitlement/il_consenso_della_spesa.dart';
    // Le porte che consumano, ciascuna nel suo file, con la firma che
    // pretende il consenso.
    const porte = {
      'lib/core/entitlement/spesa_degli_eos.dart': 1,
      'lib/core/entitlement/question_allowance.dart': 1,
      'lib/core/cerchio/il_cerchio_sociale.dart': 3,
      'lib/features/maestri/live/schermata_live.dart': 1,
    };
    // I nomi delle funzioni del server che consumano, e il solo file che li
    // puo' chiamare.
    const callable = {
      "'apriUnaSessioneLive'": 'lib/services/live/porta_del_live.dart',
      "'compraUnPostoNelCerchio'": 'lib/core/cerchio/il_cerchio_sociale.dart',
      "'regalaGliEos'": 'lib/core/cerchio/il_cerchio_sociale.dart',
      "'mandaUnDono'": 'lib/core/cerchio/il_cerchio_sociale.dart',
    };
    final fuori = <String>[];
    var file = 0;
    var spese = 0;
    for (final f in righeDiLib()) {
      file++;
      final testo = senzaCommenti(f.righe.join('\n'));
      final righe = testo.split('\n');
      for (var i = 0; i < righe.length; i++) {
        final r = righe[i];
        final dove = '${f.percorso}:${i + 1}: ${r.trim()}';
        if (r.contains('ConsensoDellaSpesa.dato(') && f.percorso != conferma) {
          fuori.add('consenso creato fuori dalla conferma, $dove');
        }
        if (r.contains('ConsensoDellaSpesa._(') && f.percorso != consenso) {
          fuori.add('costruttore privato chiamato fuori, $dove');
        }
        if (r.contains('perLeProve(') && f.percorso != consenso) {
          fuori.add('il consenso delle prove usato in lib, $dove');
        }
        if (r.contains("causale: 'spesa'")) {
          spese++;
          if (f.percorso != 'lib/core/entitlement/spesa_degli_eos.dart' &&
              f.percorso != 'lib/core/entitlement/question_allowance.dart') {
            fuori.add('una spesa di Eos fuori dalle due porte, $dove');
          }
        }
        for (final e in callable.entries) {
          if (r.contains(e.key) && f.percorso != e.value) {
            fuori.add('la funzione ${e.key} chiamata fuori, $dove');
          }
        }
      }
    }
    cardinaleMinimo(file, quantiFileHaLib, cosa: 'file di lib');
    cardinaleMinimo(spese, 2,
        cosa: "spese con causale: 'spesa'",
        perche: 'Le due porte degli Eos non spendono piu\' da dove le cerca.');
    expect(fuori, isEmpty, reason: fuori.join('\n'));

    for (final p in porte.entries) {
      final firme = 'required ConsensoDellaSpesa consenso'
          .allMatches(File(p.key).readAsStringSync())
          .length;
      expect(firme, p.value,
          reason: '${p.key}: le porte di spesa che pretendono il consenso '
              'dovevano essere ${p.value}, sono $firme');
    }
  });
}

/// Un server finto che spende davvero e tiene il conto delle richieste.
class _PortaCheSpende extends PortaDelCerchio {
  _PortaCheSpende({required int saldo}) : _saldo = saldo;

  int _saldo;
  final List<(String, int?)> chieste = [];

  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato(
          {CamminoDaCustodire? cammino, bool azzeraIlCammino = false}) async =>
      StatoDelCerchio(
          giorno: '2026-10-05',
          piano: 'free',
          spesi: const {},
          saldoEos: _saldo,
          listinoDelRiscatto: const {'gettate': 60});

  @override
  Future<EsitoDelConsumo?> consuma(
          {required String budget, required String idMovimento}) async =>
      null;

  @override
  Future<int?> muoviGliEos({
    required String causale,
    required String motivo,
    required String idMovimento,
    int? quanti,
  }) async {
    chieste.add((causale, quanti));
    _saldo -= quanti ?? 0;
    return _saldo;
  }

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
