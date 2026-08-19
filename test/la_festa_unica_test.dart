import 'package:esoteric_circle/core/astro/natal_chart_controller.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/sigilli/coda_delle_feste.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/sigilli/celebrazione.dart';
import 'package:esoteric_circle/features/sigilli/regia_del_cammino.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/core/cammino/cammino_da_custodire.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'istante_dichiarato.dart';

/// LA FESTA UNICA. Ordine AC voce 04, decisione di Mauro del 16 agosto 2026:
/// due celebrazioni di seguito danno gia' fastidio, quindi non se ne devono
/// mai vedere due di fila. Un traguardo, una festa, un pagamento.
///
/// **Il caso non e' teorico e non nasce da due Maestri**: due traguardi dello
/// STESSO sentiero maturano sullo stesso gesto, come `cal_1` e `cal_8` su una
/// gettata col sogno gia' fatto, e ogni volta che un gesto cade dentro una
/// finestra del cielo. La raffica vista da Mauro il 16 sera dopo l'onboarding
/// e' la conferma sul campo.
///
/// **La regola, per costruzione e non per fortuna**: quando nello stesso
/// momento ci sono due o piu' feste in attesa, si celebra UNA volta sola, e
/// quella celebrazione le nomina tutte, con la somma degli Eos. Si unisce la
/// FESTA, non il premio: ogni Sigillo si accende nel Journal uno per uno e
/// ogni premio si accredita per traguardo.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<DiarioDelCammino> diarioPronto() async {
    SharedPreferences.setMockInitialValues(const {});
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await diario.carica();
    return diario;
  }

  Widget attorno({
    required Widget scena,
    required DiarioDelCammino diario,
    required CodaDelleFeste coda,
    required PortaDelCerchio porta,
  }) =>
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => NatalChartController()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
          ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
          ChangeNotifierProvider<CodaDelleFeste>.value(value: coda),
          Provider<AppServices>.value(value: AppServices.offline(null, porta)),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (ctx, child) => MaestroScope(child: child!),
          home: GuardianoDelleFeste(child: scena),
        ),
      );

  setUp(() {
    FesteInCorso.azzera();
    Celebrazione.partite = 0;
  });

  testWidgets('prova 1: una sola festa in attesa, la celebrazione di oggi',
      (tester) async {
    final diario = await diarioPronto();
    final coda = CodaDelleFeste();
    await coda.carica();
    final solo = Sentieri.miniDi(Sentiero.albero).first;
    // Nel flusso vero un traguardo entra in coda GIA' acceso nel diario: la
    // coda ricorda le feste da mostrare, non i Sigilli da accendere.
    await diario.accendi(solo.id);
    await coda.accoda(solo.id);

    await tester.pumpWidget(attorno(
      diario: diario,
      coda: coda,
      porta: const _PortaCheAccredita(),
      scena: const Scaffold(body: Center(child: Text('una scena'))),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // ignore: avoid_print
    print('ORDINE AC VOCE 04, prova 1: celebrazioni partite '
        '${Celebrazione.partite}');
    expect(Celebrazione.partite, 1);
    expect(find.text(solo.nome), findsOneWidget,
        reason: 'la festa singola deve portare il suo nome, come oggi');
    // Si salta l'animazione: il conto degli Eos a fine corsa e' il premio
    // intero, e con un traguardo solo e' il SUO premio e non una somma.
    await tester.tap(find.byKey(const Key('festa_salta')),
        warnIfMissed: false);
    await tester.pump();
    expect(find.text('+${solo.eos} Eos'), findsOneWidget,
        reason: 'con una festa sola gli Eos sono quelli del traguardo, '
            'identici a oggi');
    expect(coda.vuota, isTrue);
  });

  testWidgets(
      'prova 2: tre feste in attesa, UNA celebrazione che le nomina tutte',
      (tester) async {
    final diario = await diarioPronto();
    final coda = CodaDelleFeste();
    await coda.carica();
    final tre = Sentieri.miniDi(Sentiero.albero).take(3).toList();
    for (final t in tre) {
      await diario.accendi(t.id);
      await coda.accoda(t.id);
    }

    await tester.pumpWidget(attorno(
      diario: diario,
      coda: coda,
      porta: const _PortaCheAccredita(),
      scena: const Scaffold(body: Center(child: Text('una scena'))),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // **QUANTE CELEBRAZIONI SONO PARTITE, dichiarato e non dedotto**: e' il
    // numero che la prova del rosso deve leggere quando la coda tornasse a
    // servirne una alla volta.
    // ignore: avoid_print
    print('ORDINE AC VOCE 04, prova 2: celebrazioni partite '
        '${Celebrazione.partite} con ${tre.length} feste in attesa');
    expect(Celebrazione.partite, 1,
        reason: 'con tre feste in attesa deve partire UNA celebrazione, '
            'non una raffica: ne sono partite ${Celebrazione.partite}');
    for (final t in tre) {
      expect(find.text(t.nome), findsOneWidget,
          reason: 'la festa unita deve nominare anche "${t.nome}"');
    }
    await tester.tap(find.byKey(const Key('festa_salta')),
        warnIfMissed: false);
    await tester.pump();
    final somma = tre.fold<int>(0, (s, t) => s + t.eos);
    expect(find.text('+$somma Eos'), findsOneWidget,
        reason: 'la festa unita porta la SOMMA degli Eos dei tre');
    expect(coda.vuota, isTrue,
        reason: 'la festa unita consegna tutta la coda in una volta');

    // E DOPO LA CHIUSURA NON NE PARTE UN'ALTRA: si chiude la festa e si
    // lascia respirare il guardiano, il conto resta a uno.
    await tester.tap(find.byKey(const Key('celebrazione_continua')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    // ignore: avoid_print
    print('ORDINE AC VOCE 04, prova 2 dopo la chiusura: partite '
        '${Celebrazione.partite}');
    expect(Celebrazione.partite, 1,
        reason: 'dopo la chiusura della festa unita ne e\' partita '
            'un\'altra: la raffica e\' tornata');
  });

  testWidgets(
      'prova 3: tre traguardi maturano su un gesto, una festa e tre premi',
      (tester) async {
    final diario = await diarioPronto();
    final coda = CodaDelleFeste();
    await coda.carica();
    const porta = _PortaCheAccredita();
    _PortaCheAccredita.movimenti.clear();

    // Il sogno e' gia' segnato nel diario: cosi' la gettata del 14 agosto,
    // che e' un giorno di Luna nuova nell'istante dichiarato delle prove,
    // matura TRE traguardi insieme: cal_1 (la prima gettata), cal_6 (la
    // gettata sotto la Luna nuova) e cal_8 (gettata e sogno nello stesso
    // giorno). E' l'esempio dal codice citato dall'ordine, non un caso
    // costruito.
    await diario.segna('sogno');

    late BuildContext dentro;
    await tester.pumpWidget(attorno(
      diario: diario,
      coda: coda,
      porta: porta,
      scena: Builder(builder: (ctx) {
        dentro = ctx;
        return const Scaffold(body: Center(child: Text('una scena')));
      }),
    ));
    await tester.pump();

    await RegiaDelCammino.dopoUnGesto(dentro, 'gettata');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    const attesi = ['cal_1', 'cal_6', 'cal_8'];
    // **QUANTE OSSERVAZIONI, e cade se non sono tre.**
    // ignore: avoid_print
    print('ORDINE AC VOCE 04, prova 3: accesi ${diario.accesi.length}, '
        'celebrazioni partite ${Celebrazione.partite}, premi accreditati '
        '${_PortaCheAccredita.movimenti.length}');
    for (final id in attesi) {
      expect(diario.accesi, contains(id),
          reason: 'il traguardo $id doveva accendersi nel diario: la festa '
              'unita non deve togliere niente a nessuno');
      expect(_PortaCheAccredita.movimenti, contains('traguardo-$id'),
          reason: 'il premio di $id non e\' stato accreditato: si unisce la '
              'festa, non il pagamento');
    }
    expect(Celebrazione.partite, 1,
        reason: 'tre traguardi maturati su un gesto devono dare UNA '
            'celebrazione: ne sono partite ${Celebrazione.partite}');
  });
}

/// Una porta che accredita davvero: risponde con un saldo che cresce e tiene
/// il registro degli identificativi dei movimenti, che e' cio' che la prova 3
/// conta per dire che nessun premio si e' perso.
class _PortaCheAccredita extends PortaDelCerchio {
  const _PortaCheAccredita();

  static final List<String> movimenti = [];

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
    movimenti.add(idMovimento);
    return movimenti.length * 10;
  }

  @override
  Future<bool> scriviLaMemoria({
    required String operazione,
    String? maestro,
    Map<String, Object?> campi = const {},
  }) async =>
      true;

  @override
  Future<bool> cancellaIlCerchio() async => true;
}
