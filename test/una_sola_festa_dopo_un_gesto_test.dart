import 'dart:async';

import 'package:esoteric_circle/core/astro/natal_chart_controller.dart';
import 'package:esoteric_circle/core/cammino/cammino_da_custodire.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/sigilli/coda_delle_feste.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/sigilli/celebrazione.dart';
import 'package:esoteric_circle/features/sigilli/regia_del_cammino.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'istante_dichiarato.dart';

/// UNA SOLA FESTA DOPO UN GESTO. Ordine BW voce 02.
///
/// **Fatto osservato dal fondatore sulla build 2210, il 28 agosto.** Ha aperto
/// l'Oroscopo e ha ricevuto quattro feste consecutive: alle 03:01 "Il primo
/// oroscopo letto intero" con dieci Eos, poi alle 03:02 "Il transito sulla tua
/// Luna" con trenta, "La Luna piena sul tuo corpo" con cinquantacinque e
/// "Saturno torna indietro" con altri cinquantacinque. Centocinquanta Eos in
/// sessanta secondi, tre della famiglia legata al cielo e di due Maestri
/// diversi.
///
/// **Legge del fondatore**: non deve crearsi la condizione in cui una persona
/// vede piu' di una festa di seguito. Il premio va dato nel momento in cui e'
/// conseguito e il traguardo raggiunto deve restare leggibile.
///
/// **La grandezza misurata e' il numero di feste che arrivano in scena dopo
/// quel gesto**, e si legge da `Celebrazione.partite`, che le conta anche
/// quando si succedono: a schermo se ne vede sempre una sola, quindi contare
/// cio' che resta visibile direbbe uno anche nella raffica.
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
  }) =>
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => NatalChartController()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
          ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
          ChangeNotifierProvider<CodaDelleFeste>.value(value: coda),
          Provider<AppServices>.value(
              value: AppServices.offline(null, const _PortaMuta())),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (ctx, child) => MaestroScope(child: child!),
          home: GuardianoDelleFeste(child: scena),
        ),
      );

  setUp(() {
    FesteInCorso.azzera();
    RiflessioniInCorso.azzera();
    Celebrazione.partite = 0;
  });

  testWidgets(
      'BW.02: un gesto con quattro traguardi maturi apre UNA festa sola',
      (tester) async {
    // **IL CASO VERO, ricostruito com'e' successo sulla 2210.** Mentre
    // l'Oroscopo rifletteva, la scena era occupata: i tre del cielo, gia'
    // maturi, non potevano aprire la loro festa e finivano in coda. Finita la
    // riflessione la coda si svuotava, e la catena della chiusura apriva le
    // altre una dietro l'altra: quattro scene in sessanta secondi.
    final diario = await diarioPronto();
    final coda = CodaDelleFeste();
    await coda.carica();

    // I tre del cielo, di due Maestri diversi, come quelli che il fondatore ha
    // visto: due di Aura e uno di Medora.
    final delCielo = <Traguardo>[
      Sentieri.tuttiITraguardi.firstWhere((t) => t.id == 'aur_27'),
      Sentieri.tuttiITraguardi.firstWhere((t) => t.id == 'aur_47'),
      Sentieri.tuttiITraguardi.firstWhere((t) => t.id == 'med_47'),
    ];
    for (final t in delCielo) {
      await diario.accendi(t.id);
      await coda.accoda(t.id);
    }

    // LA RIFLESSIONE OCCUPA LA SCENA, ordine BU voce 03: finche' va, nessuna
    // festa si apre, ed e' la ragione per cui i tre erano ancora li'.
    var riflette = true;
    RiflessioniInCorso.entra(() => riflette);

    late BuildContext dentro;
    await tester.pumpWidget(attorno(
      diario: diario,
      coda: coda,
      scena: Builder(builder: (ctx) {
        dentro = ctx;
        return const Scaffold(body: Center(child: Text('una scena')));
      }),
    ));
    await tester.pump();

    // IL GESTO, uno solo: la lettura dell'oroscopo. Il suo traguardo matura
    // adesso, ma la scena e' ancora occupata dalla riflessione.
    await RegiaDelCammino.dopoUnGesto(dentro, 'oroscopo');
    await tester.pump();
    // ignore: avoid_print
    print('ORDINE BW VOCE 2: durante la riflessione, feste '
        '${Celebrazione.partite}, accesi ${diario.accesi.length}, in coda '
        '${coda.inAttesa.length}');
    expect(Celebrazione.partite, 0,
        reason: 'una festa si e\' aperta sopra la riflessione');

    // FINITA LA RIFLESSIONE, la scena si libera: e' il momento in cui
    // l'Oroscopo chiama la coda, riga per riga come fa in app.
    riflette = false;
    // Non si attende: in app la chiamata e' `unawaited`, e attenderla qui
    // vorrebbe dire restare fermi finche' la festa non si chiude.
    unawaited(RegiaDelCammino.svuotaLaCoda(dentro, appenaChiusaUna: true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final arrivate = Celebrazione.partite;
    // ignore: avoid_print
    print('ORDINE BW VOCE 2: liberata la scena, feste arrivate $arrivate, '
        'accesi ${diario.accesi.length}, in coda ${coda.inAttesa.length}');
    expect(diario.accesi.length, 4,
        reason: 'i traguardi maturi non sono quattro: la prova non sta '
            'misurando il caso del fondatore');
    expect(arrivate, 1,
        reason: 'sono arrivate $arrivate feste dopo un solo gesto: e\' la '
            'raffica che il fondatore ha visto sulla 2210');

    // **E ALLA CHIUSURA NON NE PARTE UN'ALTRA.** Era li' la catena: la festa
    // che si chiudeva chiamava la coda, e la coda apriva la successiva.
    await tester.tap(find.byKey(const Key('festa_salta')),
        warnIfMissed: false);
    await tester.pump();
    await tester.tap(find.byKey(const Key('celebrazione_continua')),
        warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    // ignore: avoid_print
    print('ORDINE BW VOCE 2: congedata la festa, feste totali '
        '${Celebrazione.partite}, in coda ${coda.inAttesa.length}');
    expect(Celebrazione.partite, 1,
        reason: 'congedata la festa ne e\' partita un\'altra: sono '
            '${Celebrazione.partite} in tutto, e la persona le vede una '
            'dietro l\'altra');

    // **E NESSUN PREMIO SI PERDE**: i Sigilli restano accesi e la coda resta
    // vuota, perche' quelli che aspettavano sono stati nominati.
    for (final t in delCielo) {
      expect(diario.accesi, contains(t.id),
          reason: 'il traguardo ${t.id} si e\' spento: unire la scena non '
              'deve togliere niente a nessuno');
    }
    expect(coda.inAttesa, isEmpty,
        reason: 'nella coda restano ${coda.inAttesa.length} traguardi: la '
            'loro festa non e\' stata data a nessuno');
  });

  testWidgets('BW.02: la festa unica nomina tutti e quattro i traguardi',
      (tester) async {
    // **IL TRAGUARDO RAGGIUNTO DEVE RESTARE LEGGIBILE**, e' la seconda meta'
    // della legge del fondatore: una scena sola non puo' voler dire che tre
    // nomi spariscono.
    final diario = await diarioPronto();
    final coda = CodaDelleFeste();
    await coda.carica();
    final quattro = <Traguardo>[
      for (final id in ['aur_27', 'aur_47', 'med_47'])
        Sentieri.tuttiITraguardi.firstWhere((t) => t.id == id),
    ];
    for (final t in quattro) {
      await diario.accendi(t.id);
      await coda.accoda(t.id);
    }

    late BuildContext dentro;
    await tester.pumpWidget(attorno(
      diario: diario,
      coda: coda,
      scena: Builder(builder: (ctx) {
        dentro = ctx;
        return const Scaffold(body: Center(child: Text('una scena')));
      }),
    ));
    await tester.pump();
    await RegiaDelCammino.dopoUnGesto(dentro, 'oroscopo');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final nominati = <String>[];
    for (final t in quattro) {
      if (find.text(nomeInTondo(t.nome)).evaluate().isNotEmpty) {
        nominati.add(t.id);
      }
    }
    // ignore: avoid_print
    print('ORDINE BW VOCE 2: la festa nomina ${nominati.length} dei '
        '${quattro.length} traguardi che aspettavano: $nominati');
    expect(nominati.length, quattro.length,
        reason: 'la festa nomina solo ${nominati.length} traguardi su '
            '${quattro.length}: gli altri sono spariti dalla scena');
  });
}

/// Una porta che non parla col server: qui si misurano le feste, non gli Eos.
class _PortaMuta extends PortaDelCerchio {
  const _PortaMuta();

  @override
  bool get viva => false;

  @override
  Future<StatoDelCerchio?> stato({
    CamminoDaCustodire? cammino,
    bool azzeraIlCammino = false,
  }) async =>
      null;

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
      true;

  @override
  Future<bool> cancellaIlCerchio() async => true;
}
