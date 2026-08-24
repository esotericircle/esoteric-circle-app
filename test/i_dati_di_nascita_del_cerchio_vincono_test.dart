import 'package:esoteric_circle/core/cammino/cammino_da_custodire.dart';
import 'package:esoteric_circle/core/cammino/custode_del_cammino.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/astro/birth_details.dart';
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

/// I DATI DI NASCITA DEL CERCHIO VINCONO. Ordine AZ voce 04, fatto F6.
///
/// **Il fatto del fondatore**: dopo aver rifatto l'onboarding inserendo dati a
/// caso, nell'area account trova quei dati a caso.
///
/// **La fusione sul server e' innocente, e va detto.** In
/// `functions/lib/cammino.js` la regola e' scritta e verificata: l'identita' si
/// fonde campo per campo, e **se tutti e due ce l'hanno vince il server**, che
/// e' la copia che sopravvive ai telefoni. Quindi i dati a caso non hanno mai
/// potuto cancellare quelli veri.
///
/// **Il difetto e' che la fusione non avveniva.** `adotta` gira solo se
/// `sincronizza` risponde, e nella sequenza del fondatore non rispondeva: e'
/// il fatto F1, curato in AZ voce 01. I dati a caso restavano perche' nessuno
/// li aveva ancora sostituiti con quelli veri.
///
/// **Cosa si misura qui**: che quando il Cerchio risponde, cio' che c'era sul
/// telefono venga SOSTITUITO da cio' che il Cerchio custodisce. E' la meta'
/// che vive nell'app, l'unica che questo repository puo' provare.
void main() {
  testWidgets('il Cerchio che risponde sostituisce i dati a caso',
      (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await diario.carica();
    final identita = BirthIdentityController();
    // **I DATI A CASO DEL FONDATORE**, messi come li ha messi lui: una data
    // qualunque, per arrivare in fondo al rito.
    identita.setBirth(BirthDetails(date: DateTime(2000, 1, 1)), null);

    late BuildContext ctx;
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => QuestionAllowance(porta: _PortaCheCustodisce())),
        ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
        ChangeNotifierProvider<BirthIdentityController>.value(value: identita),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => OnboardingController()),
      ],
      child: MaterialApp(
        home: Builder(builder: (c) {
          ctx = c;
          return const Scaffold(body: SizedBox());
        }),
      ),
    ));

    final prima = identita.details;
    await CustodeDelCammino.custodisciEAdotta(ctx);
    final dopo = identita.details;
    // ignore: avoid_print
    print('ORDINE AZ VOCE 04: prima ${prima?.date}, dopo ${dopo?.date}');

    expect(prima?.date.year, 2000,
        reason: 'la prova non parte dai dati a caso: non sta riproducendo F6');
    expect(dopo?.date.year, 1975,
        reason: 'il Cerchio ha risposto con la nascita vera e il telefono '
            'tiene ancora quella a caso: e il fatto F6');
    expect(dopo?.date.day, 14);
    expect(dopo?.date.month, 3);
  });

  testWidgets('se il Cerchio non risponde, i dati del telefono NON si toccano',
      (tester) async {
    // **E QUESTA E' LA META' CHE NON VA CURATA.** Senza risposta non si
    // cancella niente: buttare la nascita che la persona ha appena scritto
    // perche' la rete non c'era sarebbe molto peggio del difetto.
    SharedPreferences.setMockInitialValues(const {});
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await diario.carica();
    final identita = BirthIdentityController();
    identita.setBirth(BirthDetails(date: DateTime(1975, 3, 14)), null);

    late BuildContext ctx;
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => QuestionAllowance(porta: _PortaMuta())),
        ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
        ChangeNotifierProvider<BirthIdentityController>.value(value: identita),
        ChangeNotifierProvider(create: (_) => ProfileController()),
        ChangeNotifierProvider(create: (_) => OnboardingController()),
      ],
      child: MaterialApp(
        home: Builder(builder: (c) {
          ctx = c;
          return const Scaffold(body: SizedBox());
        }),
      ),
    ));

    await CustodeDelCammino.custodisciEAdotta(ctx);
    // ignore: avoid_print
    print('ORDINE AZ VOCE 04: senza risposta la nascita resta '
'${identita.details?.date}');
    expect(identita.details?.date.year, 1975,
        reason: 'una rete assente ha cancellato la nascita di chi la aveva '
            'appena scritta');
  });
}

/// Un Cerchio che custodisce la nascita vera.
class _PortaCheCustodisce extends PortaDelCerchio {
  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato(
          {CamminoDaCustodire? cammino, bool azzeraIlCammino = false}) async =>
      StatoDelCerchio.daMappa({
        'giorno': '2026-08-22',
        'spesi': const {'domande': 0},
        'saldoEos': 445,
        'cammino': {
          'versione': 1,
          'identita': {
            'nome': 'Mauro',
            'giorno': '1975-03-14',
            'luogo': 'Milano',
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

/// Un Cerchio che non risponde.
class _PortaMuta extends _PortaCheCustodisce {
  @override
  Future<StatoDelCerchio?> stato(
          {CamminoDaCustodire? cammino, bool azzeraIlCammino = false}) async =>
      null;
}
