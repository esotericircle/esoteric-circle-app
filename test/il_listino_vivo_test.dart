import 'dart:io';

import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/listino_degli_eos.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/spesa_degli_eos.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/components/costo_in_chiaro.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/core/cammino/cammino_da_custodire.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL LISTINO VIVO. Ordine AN voce 05.
///
/// I costi in Eos vivono in UN dato, non sparsi per le schermate; il residuo
/// del giorno si dice prima di spendere; la spesa la scala il SERVER e mai un
/// conteggio locale; a saldo insufficiente si dice la verita' invece di
/// lasciar toccare a vuoto.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('i cinque numeri del listino sono quelli approvati', () {
    // I quattro dei briefing piu' il 120 deciso da Mauro il 18 agosto: si
    // scrivono qui perche' un ritocco silenzioso li faccia cadere.
    expect(ListinoDegliEos.cartaExtra.costo, 50);
    expect(ListinoDegliEos.stesaTreCarte.costo, 120);
    expect(ListinoDegliEos.sinastriaExtra.costo, 150);
    expect(ListinoDegliEos.domandaExtra.costo, 80);
    expect(ListinoDegliEos.stesaCompleta.costo, 250);
    // ignore: avoid_print
    print('ORDINE AN VOCE 05: listino ${[
      for (final v in ListinoDegliEos.tutte) '${v.nome} ${v.costo}'
    ]}');
  });

  test('nessun costo in Eos vive fuori dal listino', () {
    // **UNA PORTA SOLA PER I PREZZI.** Una schermata che scrive "120 Eos" a
    // mano diverge dal listino al primo ritocco, e nessuno se ne accorge.
    final colpevoli = <String>[];
    final prezzo = RegExp(r'''['"]\s*\d{2,4}\s*Eos''');
    var osservati = 0;
    for (final voce in Directory('lib').listSync(recursive: true)) {
      if (voce is! File || !voce.path.endsWith('.dart')) continue;
      final percorso = voce.path.replaceAll('\\', '/');
      if (percorso.endsWith('listino_degli_eos.dart')) continue;
      osservati++;
      final testo = voce.readAsStringSync();
      for (final trovato in prezzo.allMatches(testo)) {
        colpevoli.add('$percorso: ${trovato.group(0)}');
      }
    }
    // ignore: avoid_print
    print('ORDINE AN VOCE 05: sorgenti osservati $osservati');
    expect(osservati, greaterThan(100));
    expect(colpevoli, isEmpty,
        reason: 'questi prezzi sono scritti a mano fuori dal listino:\n'
            '${colpevoli.join("\n")}');
  });

  test('il residuo del giorno dice il vero, per ogni piano', () {
    final stesa = ListinoDegliEos.stesaTreCarte;
    expect(stesa.quanteRestano(Tier.free, 0), 1,
        reason: 'il Viandante ha una stesa gratis al giorno');
    expect(stesa.quanteRestano(Tier.free, 1), 0,
        reason: 'usata quella, non ne restano');
    expect(stesa.quanteRestano(Tier.free, 5), 0,
        reason: 'il residuo non va mai sotto zero');
    expect(stesa.quanteRestano(Tier.tier1, 3), isNull,
        reason: 'chi non ha tetto non ha un residuo da dire');
  });

  testWidgets('col gratuito ancora disponibile si legge il residuo, dopo il '
      'costo in chiaro', (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    final borsa = QuestionAllowance();
    await borsa.applicaSaldo(500);

    Future<void> monta(int giaUsate) async {
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => EntitlementService()),
          ChangeNotifierProvider<QuestionAllowance>.value(value: borsa),
        ],
        child: MaterialApp(
          home: MaestroScope(
            maestro: Maestro.medora,
            child: Scaffold(
              body: CostoInChiaro(
                voce: ListinoDegliEos.stesaTreCarte,
                cosa: 'stesa',
                giaUsateOggi: giaUsate,
              ),
            ),
          ),
        ),
      ));
      await tester.pump(const Duration(milliseconds: 200));
    }

    await monta(0);
    expect(find.byKey(const Key('costo_residuo_del_giorno')), findsOneWidget,
        reason: 'col gratuito ancora buono non si legge il residuo');
    expect(find.text('1 stesa rimasta oggi'), findsOneWidget);

    await monta(1);
    expect(find.byKey(const Key('costo_in_chiaro')), findsOneWidget,
        reason: 'finito il gratuito non si legge il costo: sarebbe una '
            'sorpresa dopo il tocco');
    expect(find.textContaining('120 Eos'), findsOneWidget,
        reason: 'il costo mostrato non viene dal listino');
  });

  testWidgets('a saldo insufficiente si dice la verita\', non si tace',
      (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    final borsa = QuestionAllowance();
    await borsa.applicaSaldo(30);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider<QuestionAllowance>.value(value: borsa),
      ],
      child: MaterialApp(
        home: MaestroScope(
          maestro: Maestro.medora,
          child: Scaffold(
            body: CostoInChiaro(
              voce: ListinoDegliEos.stesaTreCarte,
              cosa: 'stesa',
              giaUsateOggi: 1,
            ),
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.textContaining('ne hai 30'), findsOneWidget,
        reason: 'col saldo insufficiente non si dice quanto manca');
  });

  test('la spesa passa dal server e scala il saldo che il server dice',
      () async {
    SharedPreferences.setMockInitialValues(const {});
    final porta = _PortaCheSpende(saldo: 300);
    final borsa = QuestionAllowance(porta: porta);
    await borsa.applicaSaldo(300);

    final esito = await SpesaDegliEos.perLaVoce(
      porta: porta,
      borsa: borsa,
      voce: ListinoDegliEos.stesaTreCarte,
      idMovimento: 'prova-1',
    );
    // ignore: avoid_print
    print('ORDINE AN VOCE 05: chiesto al server ${porta.chieste}');
    expect(esito, EsitoDellaSpesa.fatta);
    expect(porta.chieste.single.$1, 'spesa',
        reason: 'la spesa non passa dalla causale del server');
    expect(porta.chieste.single.$2, 120,
        reason: 'la cifra chiesta non e\' quella del listino');
    expect(borsa.saldoEos, 180,
        reason: 'il saldo non e\' quello che il server ha risposto');
  });

  test('senza Eos abbastanza non si chiede niente al server', () async {
    SharedPreferences.setMockInitialValues(const {});
    final porta = _PortaCheSpende(saldo: 10);
    final borsa = QuestionAllowance(porta: porta);
    await borsa.applicaSaldo(10);
    final esito = await SpesaDegliEos.perLaVoce(
      porta: porta,
      borsa: borsa,
      voce: ListinoDegliEos.stesaTreCarte,
      idMovimento: 'prova-2',
    );
    expect(esito, EsitoDellaSpesa.saldoInsufficiente);
    expect(porta.chieste, isEmpty,
        reason: 'si e\' chiesto al server un movimento che non poteva '
            'riuscire');
  });

  test('se il server tace non si spende e non si procede', () async {
    SharedPreferences.setMockInitialValues(const {});
    final porta = _PortaCheSpende(saldo: 300, muta: true);
    final borsa = QuestionAllowance(porta: porta);
    await borsa.applicaSaldo(300);
    final esito = await SpesaDegliEos.perLaVoce(
      porta: porta,
      borsa: borsa,
      voce: ListinoDegliEos.stesaTreCarte,
      idMovimento: 'prova-3',
    );
    expect(esito, EsitoDellaSpesa.nonRiuscita);
    expect(borsa.saldoEos, 300,
        reason: 'il server non ha risposto e il saldo locale e\' calato lo '
            'stesso: e\' il secondo saldo che il progetto evita');
  });
}

class _PortaCheSpende extends PortaDelCerchio {
  _PortaCheSpende({required int saldo, this.muta = false}) : _saldo = saldo;

  final bool muta;
  int _saldo;
  final List<(String, int?)> chieste = [];

  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato({CamminoDaCustodire? cammino}) async => StatoDelCerchio(
      giorno: '2026-08-18', piano: 'free', spesi: const {}, saldoEos: _saldo);

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
    if (muta) return null;
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
