import 'package:cloud_functions/cloud_functions.dart';
import 'package:esoteric_circle/core/cammino/cammino_da_custodire.dart';
import 'package:esoteric_circle/core/cammino/custode_del_cammino.dart';
import 'package:esoteric_circle/core/cammino/ritrovamento.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/onboarding/onboarding_controller.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'istante_dichiarato.dart';

/// IL BORSELLINO NON ASPETTA IL RIAVVIO. Ordine AZ voce 03, fatti F5 e F8.
///
/// **Segnalato quattro volte dal fondatore**: il borsellino si aggiorna solo
/// entrando nel Passport, cioe' non si aggiorna quando dovrebbe.
///
/// **Il difetto era gia' scritto in un commento di `lib/app.dart`, e nessuno
/// lo aveva letto come un difetto**: "se la sincronia dell'avvio non riesce,
/// perche' la rete e' lenta nel primo secondo o perche' l'autenticazione non
/// e' ancora pronta, il saldo resta quello locale finche' l'app non viene
/// riavviata: e' il caso del fondatore, zero in barra con
/// quattrocentoquarantacinque sul server."
///
/// **E il momento della chiamata e' proprio quello sbagliato.** Parte dopo il
/// primo fotogramma, cioe' quando Firebase puo' non avere ancora ripristinato
/// la sessione: il server risponde `unauthenticated`, e **non si riprova mai
/// piu'** fino al riavvio o al ritorno in primo piano.
///
/// **Cosa si misura qui**: che un primo tentativo andato storto non sia
/// l'ultimo. La ripetizione vera vive in `lib/app.dart` e usa attese di due e
/// cinque secondi; qui si misura la condizione che la governa, cioe' che
/// l'esito del giro dica se vale la pena riprovare, **e che smetta di dirlo
/// appena il Cerchio risponde**.
void main() {
  Future<BuildContext> montaIlGiro(
      WidgetTester tester, PortaDelCerchio porta) async {
    SharedPreferences.setMockInitialValues(const {});
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await diario.carica();
    late BuildContext preso;
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuestionAllowance(porta: porta)),
        ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
        ChangeNotifierProvider(create: (_) => OnboardingController()),
      ],
      child: MaterialApp(
        home: Builder(builder: (ctx) {
          preso = ctx;
          return const Scaffold(body: SizedBox());
        }),
      ),
    ));
    return preso;
  }

  testWidgets('il primo tentativo andato storto non e l ultimo',
      (tester) async {
    // **LA SEQUENZA DEL FONDATORE, riprodotta**: il primo giro cade su
    // `unauthenticated` perche' la sessione non e' ancora pronta, il secondo
    // riesce. Prima di questa voce il secondo non partiva mai.
    final porta = _PortaCheSiSveglia(quantiNo: 1);
    final ctx = await montaIlGiro(tester, porta);

    final primo = await CustodeDelCammino.custodisciEAdotta(ctx);
    // ignore: avoid_print
    print('ORDINE AZ VOCE 03: primo giro, rifiutato ${primo.rifiutatoDalServer}'
        ', senza risposta ${primo.senzaRisposta}, saldo in borsa '
        '${ctx.read<QuestionAllowance>().saldoEos}');
    expect(primo.rifiutatoDalServer, isTrue,
        reason: 'il primo giro doveva cadere: la prova non sta riproducendo '
            'la sequenza del fondatore');
    expect(ctx.read<QuestionAllowance>().saldoEos, 0,
        reason: 'il saldo e gia arrivato al primo giro: non c e niente da '
            'misurare');

    final secondo = await CustodeDelCammino.custodisciEAdotta(ctx);
    // ignore: avoid_print
    print('ORDINE AZ VOCE 03: secondo giro, rifiutato '
        '${secondo.rifiutatoDalServer}, saldo in borsa '
        '${ctx.read<QuestionAllowance>().saldoEos}, tentativi fatti '
        '${porta.tentativi}');

    expect(secondo.rifiutatoDalServer, isFalse,
        reason: 'il secondo giro cade come il primo');
    expect(ctx.read<QuestionAllowance>().saldoEos, 445,
        reason: 'il saldo del Cerchio non e arrivato al secondo giro: e lo '
            'zero in barra con 445 sul server');
  });

  testWidgets('quando il Cerchio risponde subito, non si riprova',
      (tester) async {
    // **LA CONTROPROVA.** Una ripetizione che parte sempre sarebbe una
    // chiamata in piu' a ogni avvio, pagata da tutti per il caso di uno.
    final porta = _PortaCheSiSveglia(quantiNo: 0);
    final ctx = await montaIlGiro(tester, porta);
    final esito = await CustodeDelCammino.custodisciEAdotta(ctx);
    // ignore: avoid_print
    print('ORDINE AZ VOCE 03: col Cerchio sveglio, tentativi ${porta.tentativi}'
        ', vale la pena riprovare '
        '${esito.rifiutatoDalServer || esito.senzaRisposta}');
    expect(esito.rifiutatoDalServer || esito.senzaRisposta, isFalse,
        reason: 'il giro dice di riprovare anche quando e andato bene: si '
            'chiamerebbe il server due volte a ogni avvio');
    expect(porta.tentativi, 1);
  });

  testWidgets('anche la rete assente chiede di riprovare', (tester) async {
    // Le due strade di AZ.01 devono valere tutte e due come motivo per
    // riprovare: distinguerle serve a cosa si DICE, non a cosa si fa.
    final porta = _PortaCheSiSveglia(quantiNo: 1, muta: true);
    final ctx = await montaIlGiro(tester, porta);
    final esito = await CustodeDelCammino.custodisciEAdotta(ctx);
    // ignore: avoid_print
    print('ORDINE AZ VOCE 03: con la rete assente, senza risposta '
        '${esito.senzaRisposta}, rifiutato ${esito.rifiutatoDalServer}');
    expect(esito.senzaRisposta, isTrue);
    expect(esito.rifiutatoDalServer, isFalse);
  });
}

/// Una porta che dice di no le prime volte e poi si sveglia: e' la sessione
/// di Firebase che non e' ancora pronta al primo fotogramma.
class _PortaCheSiSveglia extends PortaDelCerchio {
  _PortaCheSiSveglia({required this.quantiNo, this.muta = false});

  final int quantiNo;
  final bool muta;
  int tentativi = 0;

  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato(
      {CamminoDaCustodire? cammino, bool azzeraIlCammino = false}) async {
    tentativi++;
    if (tentativi <= quantiNo) {
      if (muta) return null;
      throw FirebaseFunctionsException(
          code: 'unauthenticated', message: 'sessione non pronta');
    }
    return StatoDelCerchio.daMappa({
      'giorno': '2026-08-22',
      'spesi': const {'domande': 0},
      'saldoEos': 445,
      'cammino': {
        'versione': 1,
        'identita': {'nome': 'Mauro', 'giorno': '1975-03-14'},
      },
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
