import 'package:esoteric_circle/core/entitlement/il_consenso_della_spesa.dart';
import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **FT.13: I PIANI DELLA SINASTRIA APPROFONDITA E IL SUO CONTO.** Ordine
/// FT, 14 ottobre 2026.
///
/// Il conto delle coppie nuove vive sul server (`sinastrieApprofondite` in
/// `functions/src/budget.ts`), scritto e non pubblicato: la pubblicazione la
/// decide il fondatore. **Con le funzioni di oggi il telefono non deve
/// mandare quel budget**: la coda dei gesti si fermerebbe al primo rifiuto e
/// dietro di lei resterebbero ferme domande e stese. Si conta solo quando il
/// listino del server porta il prezzo del budget.
class _Porta extends PortaDelCerchio {
  _Porta({required this.conIlBudget});

  final bool conIlBudget;
  final List<String> motivi = [];
  int _saldo = 1000;

  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato(
      {Object? cammino, bool azzeraIlCammino = false}) async {
    return StatoDelCerchio.daMappa({
      'giorno': '2026-10-14',
      'spesi': const {'domande': 0},
      'saldoEos': _saldo,
      'listinoDelRiscatto': {
        'domande': 80,
        'stese': 150,
        'sinastrie': 150,
        if (conIlBudget) 'sinastrieApprofondite': 150,
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
    _saldo -= 150;
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('con le funzioni di oggi non si conta e non si manda niente', () async {
    final borsa = QuestionAllowance(porta: _Porta(conIlBudget: false));
    await borsa.sincronizza();
    expect(borsa.contaLeSinastrieApprofondite, isFalse);
    expect(borsa.limiteSinastrieApprofondite(Tier.free), isNull);
    final prima = borsa.gestiInAttesa;
    for (var i = 0; i < 5; i++) {
      expect(borsa.puoiLeggereUnaCoppiaNuova(Tier.free), isTrue);
      borsa.registraSinastriaApprofondita(Tier.free);
    }
    expect(borsa.gestiInAttesa, prima,
        reason: 'un budget che il server non conosce non entra nella coda');
  });

  test('col server nuovo il Viandante legge una coppia nuova al giorno, '
      'e la seconda si riscatta a 150 Eos', () async {
    final porta = _Porta(conIlBudget: true);
    final borsa = QuestionAllowance(porta: porta);
    await borsa.sincronizza();
    expect(borsa.contaLeSinastrieApprofondite, isTrue);
    expect(borsa.limiteSinastrieApprofondite(Tier.free), 1);
    expect(borsa.limiteSinastrieApprofondite(Tier.tier1), 2);
    expect(borsa.limiteSinastrieApprofondite(Tier.tier2), 5);
    expect(borsa.limiteSinastrieApprofondite(Tier.tier3), 15);
    expect(borsa.puoiLeggereUnaCoppiaNuova(Tier.free), isTrue);
    borsa.registraSinastriaApprofondita(Tier.free);
    expect(borsa.puoiLeggereUnaCoppiaNuova(Tier.free), isFalse);
    expect(
        borsa.prezzoDelRiscatto(QuestionAllowance.kSinastrieApprofondite), 150);
    final pagato = await borsa.riscatta(
        QuestionAllowance.kSinastrieApprofondite,
        consenso: ConsensoDellaSpesa.perLeProve(150));
    expect(pagato, 150);
    expect(porta.motivi.single, 'riscatto_sinastrieApprofondite');
    expect(borsa.puoiLeggereUnaCoppiaNuova(Tier.free), isTrue);
  });

  test('le righe della matrice dicono le scelte dichiarate', () {
    // Le tre esclusive del fondatore: dall'Adepto, e quindi all'Illuminato.
    expect(PlanCatalog.apre(RigaDelPiano.compositoRitrattoMomento, Tier.free),
        isFalse);
    expect(PlanCatalog.apre(RigaDelPiano.compositoRitrattoMomento, Tier.tier1),
        isFalse);
    expect(PlanCatalog.apre(RigaDelPiano.compositoRitrattoMomento, Tier.tier2),
        isTrue);
    expect(PlanCatalog.apre(RigaDelPiano.compositoRitrattoMomento, Tier.tier3),
        isTrue);
    expect(
        PlanCatalog.dalPiano(
            (t) => PlanCatalog.apre(RigaDelPiano.compositoRitrattoMomento, t)),
        'Dall’Adepto');
    // L'assaggio del Viandante: Oggi fra voi intero, due capitoli su cinque,
    // niente Keplero.
    expect(PlanCatalog.apre(RigaDelPiano.oggiFraVoi, Tier.free), isTrue);
    expect(PlanCatalog.apre(RigaDelPiano.capitoliDellaSinastria, Tier.free),
        isFalse);
    expect(PlanCatalog.apre(RigaDelPiano.capitoliDellaSinastria, Tier.tier1),
        isTrue);
    expect(PlanCatalog.apre(RigaDelPiano.intervalliDiKeplero, Tier.free),
        isFalse);
    expect(PlanCatalog.apre(RigaDelPiano.intervalliDiKeplero, Tier.tier1),
        isTrue);
  });
}
