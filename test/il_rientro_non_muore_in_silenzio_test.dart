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

/// IL RIENTRO NON MUORE IN SILENZIO. Ordine AZ voce 01, fatto F1.
///
/// **Il fatto del fondatore sulla 2192**: tocca "Continua con Google", sceglie
/// il suo account abituale, **non entra, la schermata torna indietro senza
/// alcun messaggio, e l'azione si puo' ripetere all'infinito**.
///
/// **L'ingresso in se' riesce**, ed e' il fatto F10 a dimostrarlo: il
/// borsellino viene poi recuperato, quindi il server lo ha riconosciuto. Cio'
/// che si rompe viene DOPO l'ingresso, nel giro del Custode, e sono due strade
/// diverse che finiscono nello stesso silenzio.
///
/// **STRADA UNO, l'eccezione che nessuno cattura.** `PortaVeraDelCerchio`
/// **rilancia** apposta su `unauthenticated`, `permission-denied`,
/// `invalid-argument` e `failed-precondition`, per distinguere il no dal non
/// lo so. Ma `custodisciEAdotta` chiama `borsa.sincronizza(...)` **fuori da
/// qualsiasi try**: quell'eccezione risale fino al gestore del tocco e muore
/// li'. Nessun messaggio, e il tocco dopo fa la stessa identica cosa.
///
/// **STRADA DUE, il nulla che vale come risposta.** Se il server non risponde,
/// `sincronizza` torna nullo, `custodisciEAdotta` torna nullo, e
/// `Ritrovamento.da(null)` dice che mancano tutti e quattro i passi del rito e
/// che non c'e' **niente da mostrare**. Quindi nessuna scena, nessun
/// messaggio, e si resta dentro il rito.
///
/// **Le due strade sono diverse e vanno distinte**: la prima e' un no del
/// server, la seconda e' una rete che non c'e'. Chi torna deve sapere in quale
/// dei due e' finito, perche' nel primo caso deve fare qualcosa e nel secondo
/// deve solo riprovare.
void main() {
  Future<BuildContext> montaIlGiro(
    WidgetTester tester,
    PortaDelCerchio porta,
  ) async {
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

  testWidgets('STRADA UNO: il no del server non deve morire nel gesto',
      (tester) async {
    final porta = _PortaCheDiceNo('unauthenticated');
    final ctx = await montaIlGiro(tester, porta);

    Object? scappata;
    Ritrovamento? esito;
    try {
      esito = await CustodeDelCammino.dopoIlRiconoscimento(ctx,
          mostraLaScena: false);
    } catch (errore) {
      scappata = errore;
    }
    // ignore: avoid_print
    print('ORDINE AZ VOCE 01: col server che dice "unauthenticated", '
        'l eccezione scappata e ${scappata.runtimeType}, esito ${esito == null
            ? "nessuno" : "passi da chiedere ${esito.passiDaChiedere.length}"}');

    expect(scappata, isNull,
        reason: 'il no del server scappa dal giro del Custode e muore nel '
            'gesto che lo ha chiamato: nessuno lo cattura, e la persona non '
            'vede niente. E il fatto F1');
    expect(esito, isNotNull,
        reason: 'il giro non ha risposto niente a chi lo ha chiamato: senza '
            'una risposta non si puo nemmeno decidere cosa dire');
    expect(esito!.rifiutatoDalServer, isTrue,
        reason: 'il giro non distingue il NO del server dalla rete assente, e '
            'sono due cose che la persona deve poter distinguere');
  });

  testWidgets('STRADA DUE: la rete assente si distingue dal no', (tester) async {
    final porta = _PortaMuta();
    final ctx = await montaIlGiro(tester, porta);

    final esito = await CustodeDelCammino.dopoIlRiconoscimento(ctx,
        mostraLaScena: false);
    // ignore: avoid_print
    print('ORDINE AZ VOCE 01: col server che non risponde, esito '
        '${esito == null ? "nessuno" : "passi ${esito.passiDaChiedere.length}, "
            "qualcosa da mostrare ${esito.qualcosaDaMostrare}, "
            "rifiutato ${esito.rifiutatoDalServer}, "
            "senzaRisposta ${esito.senzaRisposta}"}');

    expect(esito, isNotNull);
    expect(esito!.senzaRisposta, isTrue,
        reason: 'il giro non sa dire che il server non ha risposto, quindi chi '
            'lo chiama non puo dire "riprova" invece di tacere');
    expect(esito.rifiutatoDalServer, isFalse,
        reason: 'una rete assente viene raccontata come un rifiuto del server: '
            'sono due cose diverse');
  });

  testWidgets('quando il Cerchio risponde, il rito si salta e non si ripete',
      (tester) async {
    // **IL CONTROPROVA**: con un server che riconosce davvero, il giro deve
    // dire che non resta niente da chiedere. Senza questa riga le due prove
    // qui sopra sarebbero verdi anche su un giro che non funziona mai.
    final porta = _PortaCheRiconosce();
    final ctx = await montaIlGiro(tester, porta);

    final esito = await CustodeDelCammino.dopoIlRiconoscimento(ctx,
        mostraLaScena: false);
    // ignore: avoid_print
    print('ORDINE AZ VOCE 01: col Cerchio che riconosce, passi da chiedere '
        '${esito!.passiDaChiedere.length}, si salta ${esito.siSalta}, '
        'rifiutato ${esito.rifiutatoDalServer}, '
        'senzaRisposta ${esito.senzaRisposta}');

    expect(esito.siSalta, isTrue,
        reason: 'il Cerchio ha restituito una nascita intera e il rito si '
            'rifa lo stesso: e il fatto F2');
    expect(esito.rifiutatoDalServer, isFalse);
    expect(esito.senzaRisposta, isFalse);
  });

  testWidgets('la frase arriva davvero a schermo, in tutti e due i modi',
      (tester) async {
    // **NON BASTA CHE IL GIRO SAPPIA.** Fin qui si e' misurato che il dominio
    // distingue i due modi; questa prova guarda cio' che la persona LEGGE, che
    // e' l'unica cosa che il fondatore puo' vedere sul telefono.
    for (final caso in <String, PortaDelCerchio>{
      'il server dice no': _PortaCheDiceNo('unauthenticated'),
      'il server non risponde': _PortaMuta(),
    }.entries) {
      final ctx = await montaIlGiro(tester, caso.value);
      await CustodeDelCammino.dopoIlRiconoscimento(ctx, mostraLaScena: false);
      await tester.pump();

      final avviso = find.byKey(const Key('rientro_andato_storto'));
      expect(avviso, findsOneWidget,
          reason: 'con "${caso.key}" la persona non legge niente: e il '
              'silenzio del fatto F1');
      // **IL TESTO DEL MESSAGGIO, non l'etichetta del pulsante.** Da quando
      // c'e' il "Riprova" i testi dentro l'avviso sono due, e prenderli
      // insieme faceva cadere la prova per un motivo che non era il suo.
      final testo = tester.widget<Text>(find
          .descendant(of: avviso, matching: find.byType(Text))
          .evaluate()
          .where((e) =>
              find.ancestor(of: find.byWidget(e.widget),
                  matching: find.byType(SnackBarAction)).evaluate().isEmpty)
          .map((e) => find.byWidget(e.widget))
          .first);
      // ignore: avoid_print
      print('ORDINE AZ VOCE 01: con "${caso.key}" si legge: ${testo.data}');

      // **NIENTE CODICI TECNICI A SCHERMO**, che e' la terza garanzia gia'
      // pretesa in AX.01 e vale identica qui.
      expect(testo.data, isNot(contains('unauthenticated')));
      expect(testo.data, isNot(contains('null')));
      expect(testo.data!.length, greaterThan(40),
          reason: 'la frase e troppo corta per dire cosa fare');

      // **E C'E' UNA VIA D'USCITA CHE NON SIA INVENTARSI UNA NASCITA.** Senza
      // il "Riprova", l'unica strada che resta e' rifare il rito da capo: e'
      // cio' che il fondatore ha fatto ai punti F2 e F3, e i dati a caso di
      // F6 nascono li'.
      expect(find.widgetWithText(SnackBarAction, 'Riprova'), findsOneWidget,
          reason: 'con "${caso.key}" non c e niente da toccare per riprovare: '
              'resta solo rifare il rito da capo');
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('quando va bene, non si avvisa nessuno', (tester) async {
    // Una prova che accende sempre l'avviso sarebbe peggio del silenzio: chi
    // entra e arriva a casa non deve leggere un guasto.
    final ctx = await montaIlGiro(tester, _PortaCheRiconosce());
    await CustodeDelCammino.dopoIlRiconoscimento(ctx, mostraLaScena: false);
    await tester.pump();
    // ignore: avoid_print
    print('ORDINE AZ VOCE 01: col Cerchio che riconosce, avvisi a schermo '
        '${find.byKey(const Key('rientro_andato_storto')).evaluate().length}');
    expect(find.byKey(const Key('rientro_andato_storto')), findsNothing,
        reason: 'si avvisa di un guasto anche quando non c e stato nessun '
            'guasto');
  });
  testWidgets('AZ.13: tutti i codici di rifiuto sono coperti, enumerati',
      (tester) async {
    // **I QUATTRO CODICI CHE LA PORTA RILANCIA, uno per uno.** Sono quelli
    // che `PortaVeraDelCerchio._chiama` distingue apposta dal silenzio della
    // rete, e comprendono il caso del token scaduto mentre si e' dentro, che
    // e' la situazione S31 del censimento: Firebase risponde
    // `unauthenticated` quando la sessione non vale piu'.
    //
    // **Nessuno di questi deve piu' scappare**, e ognuno deve avere una
    // frase. Prima ne scappavano quattro su quattro.
    const codici = [
      'unauthenticated',
      'permission-denied',
      'invalid-argument',
      'failed-precondition',
    ];
    var scappate = 0;
    var mute = 0;
    for (final codice in codici) {
      final ctx = await montaIlGiro(tester, _PortaCheDiceNo(codice));
      Ritrovamento? esito;
      try {
        esito = await CustodeDelCammino.dopoIlRiconoscimento(ctx,
            mostraLaScena: false);
      } catch (_) {
        scappate++;
      }
      if (esito?.cosaDireAllaPersona == null) mute++;
      await tester.pump();
      await tester.pumpWidget(const SizedBox());
    }
    // ignore: avoid_print
    print('ORDINE AZ VOCE 13: sui ${codici.length} codici di rifiuto, '
        'eccezioni scappate $scappate, rami muti $mute');
    expect(scappate, 0,
        reason: 'qualche codice di rifiuto scappa ancora dal giro e muore nel '
            'gesto');
    expect(mute, 0,
        reason: 'qualche codice di rifiuto non dice niente alla persona');
  });
}

/// Una porta che dice NO col codice che il server usa davvero.
class _PortaCheDiceNo extends PortaDelCerchio {
  _PortaCheDiceNo(this.codice);

  final String codice;

  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato(
      {CamminoDaCustodire? cammino, bool azzeraIlCammino = false}) async {
    throw FirebaseFunctionsException(code: codice, message: 'no');
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

/// Una porta viva che non risponde: e' la rete assente, non un rifiuto.
class _PortaMuta extends _PortaCheDiceNo {
  _PortaMuta() : super('');

  @override
  Future<StatoDelCerchio?> stato(
          {CamminoDaCustodire? cammino, bool azzeraIlCammino = false}) async =>
      null;
}

/// Una porta che riconosce chi torna e restituisce una nascita intera.
class _PortaCheRiconosce extends _PortaCheDiceNo {
  _PortaCheRiconosce() : super('');

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
            'ora': '07:30',
            'luogo': 'Milano',
          },
        },
      });
}
