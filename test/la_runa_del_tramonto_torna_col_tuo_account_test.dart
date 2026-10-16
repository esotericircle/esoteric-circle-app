import 'dart:convert';

import 'package:esoteric_circle/core/archetypes/archetype_history.dart';
import 'package:esoteric_circle/core/arts/arti_preferite.dart';
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

/// **LA RUNA DEL TRAMONTO TORNA COL TUO ACCOUNT.** Ordine EV, il fondatore:
/// *"Avevo già accumulato 5 "runa del tramonto" e adesso devo ricominciare da
/// 1"*. Due meta', con la porta del Cerchio finta: il telefono **manda** le
/// sue sere nelle memorie del cammino, e un telefono reinstallato **riprende**
/// quelle che il Cerchio custodisce, insieme all'ultimo giorno di ogni rito
/// che rende visibile la serie.
void main() {
  String sere(List<String> giorni) => jsonEncode([
        for (final g in giorni) {'giorno': g, 'rune': 'Algiz', 'ombra': false},
      ]);

  Future<BuildContext> monta(WidgetTester tester, _Porta porta) async {
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await diario.carica();
    final preferite = ArtiPreferiteController();
    await tester.runAsync(preferite.carica);
    late BuildContext ctx;
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuestionAllowance(porta: porta)),
        ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
        ChangeNotifierProvider(create: (_) => BirthIdentityController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => OnboardingController()),
        ChangeNotifierProvider(create: (_) => ArchetypeHistory()),
        ChangeNotifierProvider<ArtiPreferiteController>.value(value: preferite),
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

  testWidgets('le sere del Tramonto partono verso il Cerchio', (tester) async {
    SharedPreferences.setMockInitialValues({
      'sunset_rune.settimana': sere(['2026-09-26', '2026-09-27']),
    });
    final porta = _Porta(const {});
    final ctx = await monta(tester, porta);
    await tester.runAsync(() => CustodeDelCammino.custodisciEAdotta(ctx));
    final memorie = porta.ricevuto?.memorie;
    // ignore: avoid_print
    print('ORDINE EV, TRAMONTO: famiglie mandate al Cerchio '
        '${memorie?.keys.toList()}');
    expect(memorie, isNotNull,
        reason: 'il telefono non manda le memorie: dopo una reinstallazione '
            'le sere del Tramonto non possono tornare');
    expect(jsonEncode(memorie), contains('sunset_rune.settimana'));
  });

  testWidgets('il telefono reinstallato riprende le sere e l\'ultimo giorno',
      (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    final cinque = sere(
        ['2026-09-26', '2026-09-27', '2026-09-28', '2026-09-29', '2026-09-30']);
    final porta = _Porta({
      'memorie': {
        'tramonto': {
          'sunset_rune.settimana': {'t': 's', 'v': cinque},
        },
        'cammino': {
          'cammino.ultimoPerRito': {
            't': 's',
            'v': jsonEncode({'runa_tramonto': '2026-09-30'}),
          },
        },
      },
    });
    final ctx = await monta(tester, porta);
    await tester.runAsync(() => CustodeDelCammino.custodisciEAdotta(ctx));
    final prefs = await SharedPreferences.getInstance();
    final tornate =
        (jsonDecode(prefs.getString('sunset_rune.settimana') ?? '[]') as List)
            .length;
    // ignore: avoid_print
    print('ORDINE EV, TRAMONTO: sere sul telefono reinstallato prima 0, dopo '
        '$tornate; ultimo giorno per rito '
        '${prefs.getString('cammino.ultimoPerRito')}');
    expect(tornate, 5,
        reason: 'il Cerchio custodiva cinque sere e il telefono riparte da '
            'zero: e\' il fatto del fondatore');
    expect(prefs.getString('cammino.ultimoPerRito'), contains('2026-09-30'));
  });

  _artiPreferite();
}

/// Le arti preferite, dallo stesso censimento: il telefono mandava anche il
/// seme, e il server teneva le sue per prime. Ora il seme non parte, e le
/// scelte della persona si'.
void _artiPreferite() {
  testWidgets('ORDINE EV, ARTI: il seme non parte, le scelte si\'',
      (tester) async {
    final mandate = <String, List<String>>{};
    for (final caso in ['seme', 'scelte']) {
      SharedPreferences.setMockInitialValues({
        if (caso == 'scelte') 'arti_preferite_v1': ['rune_draw'],
      });
      final porta = _Porta(const {});
      final preferite = ArtiPreferiteController();
      await tester.runAsync(preferite.carica);
      late BuildContext ctx;
      // La chiave per caso: senza, il secondo giro terrebbe il borsellino
      // del primo, con la sua porta.
      await tester.pumpWidget(MultiProvider(
        key: ValueKey(caso),
        providers: [
          ChangeNotifierProvider(
              create: (_) => QuestionAllowance(porta: porta)),
          ChangeNotifierProvider<ArtiPreferiteController>.value(
              value: preferite),
        ],
        child: MaterialApp(
          home: Builder(builder: (c) {
            ctx = c;
            return const SizedBox();
          }),
        ),
      ));
      await tester.runAsync(() => CustodeDelCammino.custodisciEAdotta(ctx));
      mandate[caso] = porta.ricevuto?.artiPreferite ?? const [];
    }
    // ignore: avoid_print
    print('ORDINE EV, ARTI: arti mandate al Cerchio $mandate');
    expect(mandate['seme'], isEmpty,
        reason: 'un telefono appena reinstallato manda il seme, e il seme '
            'cancellerebbe le scelte custodite');
    expect(mandate['scelte'], ['rune_draw']);
  });
}

/// Un Cerchio che rimanda il cammino scritto qui e ricorda cio' che riceve.
class _Porta extends PortaDelCerchio {
  _Porta(this.cammino);

  final Map<String, Object?> cammino;
  CamminoDaCustodire? ricevuto;

  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato(
      {CamminoDaCustodire? cammino, bool azzeraIlCammino = false}) async {
    ricevuto = cammino;
    return StatoDelCerchio.daMappa({
      'giorno': '2026-10-01',
      'spesi': const {'domande': 0},
      'saldoEos': 445,
      'cammino': {'versione': 1, ...this.cammino},
    });
  }

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
