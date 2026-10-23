import 'package:esoteric_circle/core/archetypes/archetype.dart';
import 'package:esoteric_circle/core/archetypes/archetype_history.dart';
import 'package:esoteric_circle/core/archetypes/archetype_scoring.dart';
import 'package:esoteric_circle/core/cammino/cammino_da_custodire.dart';
import 'package:esoteric_circle/core/cammino/custode_del_cammino.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/identity/natal_identity.dart';
import 'package:esoteric_circle/core/identity/profile_controller.dart';
import 'package:esoteric_circle/core/onboarding/onboarding_controller.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'istante_dichiarato.dart';

/// **L'ARCHETIPO TORNA DAL CERCHIO.** Ordine EV, il fondatore: *"Dopo la
/// reinstallazione e dopo la registrazione con mia email, però, ho perso
/// l'emblema dell'archetipo e mi chiede di rifarlo."*
///
/// Il Cerchio custodiva l'archetipo e lo rimandava; `CustodeDelCammino.adotta`
/// riprendeva gli Eos, i Sigilli, l'Alba e il Viaggio, e l'archetipo no.
/// Difetto dell'ordine CF voce 07, che lo aveva messo nella custodia senza la
/// strada del ritorno.
///
/// Si misura il telefono reinstallato (storico vuoto) che riceve dal Cerchio
/// il Mago: prima lo storico restava vuoto e il Passaporto chiedeva il Test.
/// E l'altra meta': chi ha gia' un esito sul telefono tiene il suo.
void main() {
  Future<BuildContext> monta(
      WidgetTester tester, ArchetypeHistory storico) async {
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await diario.carica();
    late BuildContext ctx;
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => QuestionAllowance(porta: _PortaColMago())),
        ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => OnboardingController()),
        ChangeNotifierProvider<ArchetypeHistory>.value(value: storico),
      ],
      child: MaterialApp(
        home: Builder(builder: (c) {
          ctx = c;
          return const Scaffold(body: SizedBox());
        }),
      ),
    ));
    return ctx;
  }

  testWidgets('il telefono reinstallato ritrova il suo archetipo',
      (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    final storico = ArchetypeHistory();
    await storico.carica();
    final ctx = await monta(tester, storico);
    final prima = storico.ultimo?.dominante;
    await tester.runAsync(() => CustodeDelCammino.custodisciEAdotta(ctx));
    final dopo = storico.ultimo?.dominante;
    // Sul disco, perche' il Test rilegge il disco aprendosi.
    final riletto = ArchetypeHistory();
    await riletto.carica();
    // ignore: avoid_print
    print('ORDINE EV, ARCHETIPO: prima $prima, dopo $dopo, sul disco '
        '${riletto.ultimo?.dominante}');
    expect(prima, isNull);
    expect(dopo, Archetype.mago,
        reason: 'il Cerchio ha rimandato il Mago e il telefono non lo ha '
            'ripreso: il Passaporto chiede di rifare il Test');
    expect(riletto.ultimo?.dominante, Archetype.mago);
    expect(riletto.ultimo?.quando, DateTime.parse('2026-09-20T10:00:00.000'));
  });

  testWidgets('chi ha gia\' un archetipo sul telefono tiene il suo',
      (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    final storico = ArchetypeHistory();
    await storico.carica();
    await storico.registra(ArchetypeProfile(
      percentuali: {
        for (final a in Archetype.values) a: a == Archetype.saggio ? 100.0 : 0.0,
      },
      dominante: Archetype.saggio,
    ));
    final ctx = await monta(tester, storico);
    await tester.runAsync(() => CustodeDelCammino.custodisciEAdotta(ctx));
    expect(storico.ultimo?.dominante, Archetype.saggio);
    expect(storico.esiti.length, 1);
  });

  test('lo storico che sta ancora leggendo il disco non si calpesta', () async {
    // All'avvio la memoria e' vuota finche' `carica` non finisce: il ritorno
    // dal Cerchio non deve scrivere sopra il disco che ha gia' un esito.
    SharedPreferences.setMockInitialValues(const {});
    final vecchio = ArchetypeHistory();
    await vecchio.registra(ArchetypeProfile(
      percentuali: {
        for (final a in Archetype.values) a: a == Archetype.eroe ? 100.0 : 0.0,
      },
      dominante: Archetype.eroe,
    ));
    final appenaNato = ArchetypeHistory();
    final entrato = await appenaNato.adottaDalCerchio(
        'mago', DateTime.parse('2026-09-20T10:00:00.000'));
    await appenaNato.carica();
    expect(entrato, isFalse);
    expect(appenaNato.ultimo?.dominante, Archetype.eroe);
  });
}

/// Un Cerchio che custodisce il Mago.
class _PortaColMago extends PortaDelCerchio {
  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato(
          {CamminoDaCustodire? cammino, bool azzeraIlCammino = false}) async =>
      StatoDelCerchio.daMappa({
        'giorno': '2026-09-30',
        'spesi': const {'domande': 0},
        'saldoEos': 445,
        'cammino': {
          'versione': 1,
          'archetipo': {
            'dominante': 'mago',
            'quando': '2026-09-20T10:00:00.000',
          },
        },
      });

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
  }) async =>
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
