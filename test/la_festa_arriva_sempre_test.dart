import 'dart:async';

import 'package:esoteric_circle/core/astro/natal_chart_controller.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/sigilli/coda_delle_feste.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/sigilli/regia_del_cammino.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'istante_dichiarato.dart';

/// LA FESTA ARRIVA SEMPRE, ordine P voce 34.
///
/// **Il fatto da cui e' nata la voce.** Sul telefono risultavano accesi almeno
/// due traguardi, "Sotto la Luna nuova" e "Tre gettate", e nessuna
/// celebrazione era mai comparsa. Un Sigillo che si accende in silenzio e' un
/// premio che non esiste.
///
/// **La causa, verificata e non dedotta.** In `regia_del_cammino.dart` la riga
///
///     final saldo = await PremioDelTraguardo.accredita(porta, traguardo);
///
/// stava PRIMA di `Celebrazione.festeggia`, senza protezione. La porta del
/// server RILANCIA su `unauthenticated`, `permission-denied`,
/// `invalid-argument` e `failed-precondition`, e l'attesa non ha un tetto
/// proprio: con le funzioni non ancora distribuite quella chiamata poteva
/// sollevare o restare appesa, e il ciclo non arrivava mai alla festa.
///
/// **La regola che queste prove sorvegliano.** Si accende, SI CELEBRA, e solo
/// dopo si accredita. E se non c'e' dove ospitare la festa, la festa non si
/// perde: entra in coda e arriva al primo momento utile.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// UNA PORTA CHE SOLLEVA, come fa quella vera su `unauthenticated`.
  const porta = _PortaCheSolleva();

  /// UNA PORTA CHE NON RISPONDE MAI, finche' la prova non finisce.
  final appesa = _PortaAppesa();
  tearDown(appesa.sblocca);

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
    required PortaDelCerchio quale,
  }) =>
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => NatalChartController()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
          ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
          ChangeNotifierProvider<CodaDelleFeste>.value(value: coda),
          Provider<AppServices>.value(value: AppServices.offline(null, quale)),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (ctx, child) => MaestroScope(child: child!),
          // IL GUARDIANO STA SOTTO IL NAVIGATOR, come nell'app vera: e' li'
          // che esiste l'Overlay in cui una festa in attesa puo' finalmente
          // comparire.
          home: GuardianoDelleFeste(child: scena),
        ),
      );

  /// Il gesto che accende il primo traguardo delle rune: e' quello che sul
  /// telefono si era acceso in silenzio.
  const gesto = 'gettata';

  bool laFestaSiVede(WidgetTester tester) =>
      find.byKey(const Key('sovrimpressione_del_traguardo')).evaluate().isNotEmpty ||
      find.byKey(const Key('celebrazione_nome')).evaluate().isNotEmpty;

  testWidgets('la festa arriva anche se la porta del server SOLLEVA',
      (tester) async {
    final diario = await diarioPronto();
    final coda = CodaDelleFeste();
    late BuildContext dentro;
    await tester.pumpWidget(attorno(
      diario: diario,
      coda: coda,
      quale: porta,
      scena: Builder(builder: (ctx) {
        dentro = ctx;
        return const Scaffold(body: Center(child: Text('una scena qualunque')));
      }),
    ));
    await tester.pump();

    await RegiaDelCammino.dopoUnGesto(dentro, gesto);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(laFestaSiVede(tester), isTrue,
        reason: 'la porta ha sollevato e la celebrazione non e\' comparsa: '
            'l\'accredito si e\' portato via la festa. La festa non deve mai '
            'attendere la rete, e non deve mai poter essere saltata da un '
            'errore di rete');
    expect(diario.accesi, isNotEmpty,
        reason: 'nemmeno il Sigillo si e\' acceso');
  });

  testWidgets('la festa arriva anche se la porta NON RISPONDE MAI',
      (tester) async {
    final diario = await diarioPronto();
    final coda = CodaDelleFeste();
    late BuildContext dentro;
    await tester.pumpWidget(attorno(
      diario: diario,
      coda: coda,
      quale: appesa,
      scena: Builder(builder: (ctx) {
        dentro = ctx;
        return const Scaffold(body: Center(child: Text('una scena qualunque')));
      }),
    ));
    await tester.pump();

    // Non si attende la regia: se la festa fosse a valle dell'attesa, questa
    // riga non tornerebbe mai, ed e' proprio il caso da prendere.
    unawaited(RegiaDelCammino.dopoUnGesto(dentro, gesto));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(laFestaSiVede(tester), isTrue,
        reason: 'la porta e\' rimasta appesa e la celebrazione non e\' '
            'comparsa: la festa sta ancora a valle dell\'attesa di rete');
  });

  testWidgets(
      'un traguardo acceso senza schermata montata si celebra al primo '
      'momento utile', (tester) async {
    final diario = await diarioPronto();
    final coda = CodaDelleFeste();

    // NESSUNA SCHERMATA: l'albero non ha Overlay ne' Navigator, quindi non
    // c'e' dove ospitare la sovrimpressione. E' il caso in cui prima si usciva
    // in silenzio e la festa spariva per sempre.
    late BuildContext senzaScena;
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => NatalChartController()),
        ChangeNotifierProvider(create: (_) => QuestionAllowance()),
        ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
        ChangeNotifierProvider<CodaDelleFeste>.value(value: coda),
        Provider<AppServices>.value(value: AppServices.offline(null, porta)),
      ],
      child: Builder(builder: (ctx) {
        senzaScena = ctx;
        return const SizedBox.shrink();
      }),
    ));
    await tester.pump();

    await RegiaDelCammino.dopoUnGesto(senzaScena, gesto);
    await tester.pump();

    expect(diario.accesi, isNotEmpty,
        reason: 'il Sigillo deve accendersi comunque: senza schermata si '
            'rimanda la festa, non il traguardo');
    expect(coda.inAttesa, isNotEmpty,
        reason: 'la festa non e\' entrata in coda: e\' andata persa, ed e\' '
            'esattamente il difetto della voce 34');

    final primaDelMomentoUtile = coda.inAttesa.length;
    // IL PRIMO MOMENTO UTILE: adesso una schermata c'e'.
    await tester.pumpWidget(attorno(
      diario: diario,
      coda: coda,
      quale: porta,
      scena: const Scaffold(body: Center(child: Text('finalmente una scena'))),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(laFestaSiVede(tester), isTrue,
        reason: 'al primo momento utile la festa in attesa non e\' arrivata: '
            'una coda che non si svuota e\' una festa persa con un passaggio '
            'in piu\'');
    // **LE FESTE IN CODA POSSONO ESSERE PIÙ DI UNA, e non è un difetto.**
    // Ordine U voce 01, seconda coda: un gesto accende al massimo un traguardo
    // A CIELO VUOTO, ma sotto un cielo può accenderne due, e sono due fatti
    // diversi che meritano due feste. L'istante dichiarato di queste prove, il
    // 14 agosto, è un giorno di luna nuova: una gettata accende la PRIMA
    // GETTATA e la GETTATA A LUNA NUOVA.
    //
    // **La coda ne consegna UNA per momento utile, ed è ciò per cui esiste:**
    // due scene a schermo pieno spinte insieme si accavallerebbero. Quindi non
    // si pretende più che la coda sia vuota, perché sarebbe pretendere che due
    // feste arrivino nello stesso istante. Si pretende che si sia ACCORCIATA,
    // cioè che il momento utile ne abbia consegnata almeno una.
    //
    // **La grandezza misurata cambia, la cosa sorvegliata no: nessuna festa va
    // persa.** Quelle che restano tornano al prossimo momento utile, ed è la
    // prova qui sotto, quella della coda che sopravvive al riavvio, a dirlo.
    // ignore: avoid_print
    print('ORDINE U VOCE 01: in coda ne restano ${coda.inAttesa.length} dopo '
        'il primo momento utile, da $primaDelMomentoUtile che erano');
    expect(coda.inAttesa.length, lessThan(primaDelMomentoUtile),
        reason: 'il momento utile non ha consegnato nessuna festa: la coda è '
            'rimasta lunga ${coda.inAttesa.length} come prima');
  });

  test('la coda sopravvive alla chiusura dell\'app', () async {
    SharedPreferences.setMockInitialValues(const {});
    final primo = CodaDelleFeste();
    await primo.carica();
    final traguardo = Sentieri.miniDi(Sentiero.albero).first;
    await primo.accoda(traguardo.id);

    // Un'altra istanza e' cio' che succede al riavvio: se la coda vivesse in
    // memoria, qui sarebbe vuota e la festa sarebbe morta con l'app.
    final dopoIlRiavvio = CodaDelleFeste();
    await dopoIlRiavvio.carica();
    expect(dopoIlRiavvio.inAttesa, contains(traguardo.id),
        reason: 'la coda non e\' sopravvissuta alla chiusura dell\'app');

    expect((await dopoIlRiavvio.prendiLaProssima())?.id, traguardo.id);
    expect(dopoIlRiavvio.vuota, isTrue);
  });
}

/// La porta che rilancia, come quella vera su `unauthenticated`.
class _PortaCheSolleva extends PortaDelCerchio {
  const _PortaCheSolleva();

  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato() async => throw StateError('unauthenticated');

  @override
  Future<EsitoDelConsumo?> consuma({
    required String budget,
    required String idMovimento,
  }) async =>
      throw StateError('unauthenticated');

  @override
  Future<int?> muoviGliEos({
    required String causale,
    required String motivo,
    required String idMovimento,
    int? quanti,
  }) async =>
      throw StateError('unauthenticated');

  @override
  Future<bool> scriviLaMemoria({
    required String operazione,
    String? maestro,
    Map<String, Object?> campi = const {},
  }) async =>
      throw StateError('unauthenticated');

  @override
  Future<bool> cancellaIlCerchio() async =>
      throw StateError('unauthenticated');
}

/// La porta che non risponde mai: le funzioni non distribuite si comportano
/// cosi' finche' il tetto della chiamata non scade, che sono decine di secondi.
class _PortaAppesa extends PortaDelCerchio {
  _PortaAppesa();

  final Completer<void> _mai = Completer<void>();

  /// A fine prova si scioglie l'attesa, e si scioglie con una risposta e non
  /// con un errore: un errore su un'attesa che nessuno guarda piu' farebbe
  /// cadere il corridore invece della prova.
  void sblocca() {
    if (!_mai.isCompleted) _mai.complete();
  }

  Future<T?> _appesa<T>() async {
    await _mai.future;
    return null;
  }

  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato() => _appesa<StatoDelCerchio>();

  @override
  Future<EsitoDelConsumo?> consuma({
    required String budget,
    required String idMovimento,
  }) =>
      _appesa<EsitoDelConsumo>();

  @override
  Future<int?> muoviGliEos({
    required String causale,
    required String motivo,
    required String idMovimento,
    int? quanti,
  }) =>
      _appesa<int>();

  @override
  Future<bool> scriviLaMemoria({
    required String operazione,
    String? maestro,
    Map<String, Object?> campi = const {},
  }) async =>
      await _appesa<bool>() ?? false;

  @override
  Future<bool> cancellaIlCerchio() async => await _appesa<bool>() ?? false;
}
