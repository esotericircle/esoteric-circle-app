import 'package:esoteric_circle/core/astro/natal_chart_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/sigilli/regia_del_cammino.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/core/cammino/cammino_da_custodire.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'istante_dichiarato.dart';

/// IL NUMERO IN BARRA SI MUOVE DOPO UN TRAGUARDO. Ordine S voce 04, criterio di
/// chiusura.
///
/// **Il giro intero, dalla regia alla barra.** Le altre prove della voce misurano
/// i pezzi: che `applicaSaldo` muova il dato, che un guasto lasci traccia, che il
/// motivo del premio sia noto al server. Nessuna di loro prova la cosa che la
/// persona vede, cioe' che dopo un traguardo il numero cambi **a schermo, senza
/// riaprire la schermata**. Questa monta un albero vero, accende un traguardo con
/// una porta che risponde, e legge il numero a video.
///
/// **La porta finta risponde come quella vera quando le funzioni ci sono**: torna
/// il saldo nuovo dentro la risposta dell'accredito. Era esattamente il dato che
/// veniva buttato.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('dopo un traguardo il numero in barra CAMBIA a schermo',
      (tester) async {
    final porta = _PortaCheAccredita();
    final borsa = QuestionAllowance(porta: porta);
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await diario.carica();

    final servizi = AppServices.offline('prova della voce S.04', porta);

    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<AppServices>.value(value: servizi),
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => NatalChartController()),
        ChangeNotifierProvider<QuestionAllowance>.value(value: borsa),
        ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
      ],
      child: MaterialApp(
        home: MaestroScope(child: const _BarraDiProva()),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // IL NUMERO DI PARTENZA, letto a video e non nel dato.
    expect(find.text('Eos 0'), findsOneWidget,
        reason: 'la barra di prova non mostra il saldo: la prova non starebbe '
            'guardando quello che crede');

    // IL GESTO. La regia guarda cosa e' maturato, celebra e accredita: e' la
    // stessa porta che l'app attraversa dopo ogni gesto vero.
    // TRE STESE, perche' e' il traguardo `med_5` e chiede TRE gesti: uno solo
    // non accende niente, e una prova che chiama il gesto una volta sola
    // misurerebbe soltanto che non e' successo nulla.
    final contesto = tester.element(find.byType(_BarraDiProva));
    for (var i = 0; i < 3; i++) {
      await RegiaDelCammino.dopoUnGesto(contesto, 'stesa');
      // **NON `pumpAndSettle`**: la celebrazione porta animazioni che non si
      // assestano mai, e la prova cadrebbe per un tempo scaduto invece che per
      // il saldo. Si avanza a passi dichiarati, come per l'attesa di Medora.
      for (var passo = 0; passo < 8; passo++) {
        await tester.pump(const Duration(seconds: 1));
      }
    }

    expect(porta.movimenti, isNotEmpty,
        reason: 'nessun accredito e\' partito: con un gesto che accende un '
            'traguardo la regia deve chiedere il premio al server, e se non lo '
            'chiede la voce non ha niente da misurare');

    // **IL NUMERO A VIDEO, che e' la cosa che la persona vede.** Se restasse
    // "Eos 0" avremmo il saldo giusto nel dato e la barra che dice zero, cioe'
    // esattamente il difetto della voce.
    expect(find.text('Eos 0'), findsNothing,
        reason: 'il numero in barra e\' rimasto fermo dopo il traguardo: e\' il '
            'difetto della voce 04, la persona vede "+10 Eos" nella festa e zero '
            'nel borsellino');
    expect(find.text('Eos ${porta.saldo}'), findsOneWidget,
        reason: 'la barra non mostra il saldo che il server ha appena detto '
            '(${porta.saldo}): sta mostrando un altro numero');
  });

  testWidgets('se il server tace il numero resta fermo, e il guasto e\' scritto',
      (tester) async {
    // **Il contrario della prova di sopra, e serve.** Senza di lei si potrebbe
    // far passare la prima inventando un numero quando il server non risponde,
    // che e' peggio di un saldo fermo: la barra direbbe una cifra che sul server
    // non esiste.
    final porta = _PortaMuta();
    final borsa = QuestionAllowance(porta: porta);
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await diario.carica();
    final servizi = AppServices.offline('prova della voce S.04', porta);

    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<AppServices>.value(value: servizi),
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => NatalChartController()),
        ChangeNotifierProvider<QuestionAllowance>.value(value: borsa),
        ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
      ],
      child: MaterialApp(
        home: MaestroScope(child: const _BarraDiProva()),
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final contesto = tester.element(find.byType(_BarraDiProva));
    for (var i = 0; i < 3; i++) {
      await RegiaDelCammino.dopoUnGesto(contesto, 'stesa');
      // **NON `pumpAndSettle`**: la celebrazione porta animazioni che non si
      // assestano mai, e la prova cadrebbe per un tempo scaduto invece che per
      // il saldo. Si avanza a passi dichiarati, come per l'attesa di Medora.
      for (var passo = 0; passo < 8; passo++) {
        await tester.pump(const Duration(seconds: 1));
      }
    }

    expect(find.text('Eos 0'), findsOneWidget,
        reason: 'la barra mostra un saldo che il server non ha mai confermato: '
            'un numero inventato e\' peggio di un numero fermo');
    expect(servizi.guasti.haGuasti, isTrue,
        reason: 'il server ha taciuto e non e\' rimasta nessuna traccia: e\' il '
            'catch muto della voce 04, che rendeva la causa illeggibile');
    expect(servizi.guasti.ultimo!.operazione, contains('accredito del traguardo'),
        reason: 'il guasto registrato non dice di quale operazione si tratta');
  });
}

/// La barra di prova: mostra il saldo come lo mostra la barra vera, cioe'
/// ASCOLTANDO la borsa. Se ascoltasse una copia, la prova passerebbe anche col
/// difetto in piedi.
class _BarraDiProva extends StatelessWidget {
  const _BarraDiProva();

  @override
  Widget build(BuildContext context) {
    final saldo = context.watch<QuestionAllowance>().saldoEos;
    return Scaffold(
      body: Center(child: Text('Eos $saldo')),
    );
  }
}

/// La porta che accredita davvero, come quella vera con le funzioni distribuite:
/// torna il saldo nuovo DENTRO la risposta.
class _PortaCheAccredita extends PortaDelCerchio {
  _PortaCheAccredita();

  int saldo = 0;
  final List<String> movimenti = [];

  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato({CamminoDaCustodire? cammino}) async => null;

  @override
  Future<EsitoDelConsumo?> consuma({
    required String budget,
    required String idMovimento,
  }) async =>
      null;

  @override
  Future<int?> muoviGliEos({
    required String causale,
    required String motivo,
    required String idMovimento,
    int? quanti,
  }) async {
    if (movimenti.contains(idMovimento)) return saldo;
    movimenti.add(idMovimento);
    // Dieci Eos come il premio di un mini: il numero non conta, conta che ci sia.
    saldo += 10;
    return saldo;
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

/// La porta che risponde NULLA, come le funzioni non distribuite.
class _PortaMuta extends PortaDelCerchio {
  const _PortaMuta();

  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato({CamminoDaCustodire? cammino}) async => null;

  @override
  Future<EsitoDelConsumo?> consuma({
    required String budget,
    required String idMovimento,
  }) async =>
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
