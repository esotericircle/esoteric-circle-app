import 'package:esoteric_circle/core/astro/natal_chart_controller.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/registro_degli_eos.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/libro_degli_accrediti.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
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

/// I PREMI DEI TRAGUARDI ARRIVANO TUTTI. Ordine AO voce 04.
///
/// **Il difetto, dichiarato da Mauro sul collaudo della 2182**: non tutti i
/// premi finiscono nel borsellino. Non un premio, non nessuno: ALCUNI.
///
/// **L'INDAGINE E' PER ENUMERAZIONE, e questo file e' l'enumerazione.** Il
/// filo che porta un premio dal gesto al saldo ha sette passi, e ognuno qui
/// ha la sua prova che dice se e' vivo o rotto:
///   1. il gesto matura un traguardo;
///   2. il Sigillo si accende nel diario;
///   3. il premio si chiede al server PER NOME, mai per importo;
///   4. il server risponde col saldo nuovo;
///   5. il saldo si applica al borsellino;
///   6. il libro degli accrediti segna cio' che e' arrivato DAVVERO;
///   7. la sincronia riprende cio' che il libro non ha segnato.
///
/// **I quattro candidati dell'ordine, provati uno per uno e non presunti**:
/// i premi maturati mentre la rete manca; i traguardi accesi dentro una
/// FESTA UNITA, dove il premio potrebbe partire per uno solo; il libro che
/// segna come arrivato un premio che il server ha rifiutato; e le corse fra
/// due premi chiesti nello stesso istante.
///
/// **Il criterio di accettazione, dall'ordine**: dato un insieme di
/// traguardi accesi, la somma accreditata e' uguale alla somma dei loro
/// valori, provato su un caso con festa unita.
///
/// **NESSUN TETTO GIORNALIERO**, e non e' una dimenticanza: la premessa P4
/// lo ha verificato sul server, dove l'unico tetto riguarda le condivisioni,
/// e Mauro ha dichiarato il 18 agosto che il tetto sui traguardi non si fa.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    RegiaDelCammino.ripresaTentata = false;
  });

  Widget attorno({
    required Widget scena,
    required DiarioDelCammino diario,
    required PortaDelCerchio porta,
    required QuestionAllowance borsa,
  }) =>
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          // **SENZA LA CARTA NATALE LA REGIA ESCE IN SILENZIO**, e la prima
          // stesura di questa prova ne e' stata vittima: sei gesti fatti,
          // zero Sigilli accesi e nessun errore da nessuna parte. La regia
          // legge `NatalChartController` per sapere se i traguardi del cielo
          // sono maturi, e senza quel provider si ferma prima di guardare
          // qualsiasi cosa.
          ChangeNotifierProvider(create: (_) => NatalChartController()),
          ChangeNotifierProvider(create: (_) => RegistroDegliEos()),
          ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
          ChangeNotifierProvider<QuestionAllowance>.value(value: borsa),
          Provider<AppServices>.value(
              value: AppServices.offline('prova AO.04', porta)),
        ],
        child: MaterialApp(
          builder: (ctx, child) => MaestroScope(child: child!),
          home: Scaffold(body: scena),
        ),
      );


  /// **SI FANNO I GESTI FINCHE' QUALCOSA SI ACCENDE, e non si conta a mano
  /// quanti ne servono.** I traguardi hanno le loro soglie, e scrivere qui
  /// "tre stese" vorrebbe dire tenere d'accordo questa prova con l'elenco
  /// dei traguardi per sempre. Si smette appena il diario ha qualcosa da
  /// mostrare, cosi' la prova misura cio' che c'e' davvero.
  Future<void> faiIGesti(WidgetTester tester, GlobalKey chiave,
      DiarioDelCammino diario) async {
    for (var giro = 0; giro < 6 && diario.accesi.isEmpty; giro++) {
      await RegiaDelCammino.dopoUnGesto(chiave.currentContext!, 'stesa');
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      // ignore: avoid_print
      print('ORDINE AO VOCE 04 DIAG: giro $giro, ha fatto la stesa '
          '${diario.haFatto('stesa')}, accesi ${diario.accesi}');
    }
  }

  testWidgets('PASSI 1-5: un gesto accende, chiede per nome e il saldo arriva',
      (tester) async {
    final porta = _PortaCheRisponde();
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await diario.carica();
    final borsa = QuestionAllowance(porta: porta);
    final chiave = GlobalKey();
    await tester.pumpWidget(attorno(
      scena: SizedBox(key: chiave),
      diario: diario,
      porta: porta,
      borsa: borsa,
    ));

    await faiIGesti(tester, chiave, diario);

    // ignore: avoid_print
    print('ORDINE AO VOCE 04: accesi ${diario.accesi}, movimenti '
        '${porta.movimenti}, saldo ${borsa.saldoEos}');
    expect(diario.accesi, isNotEmpty, reason: 'PASSO 2: niente si e\' acceso');
    expect(porta.causali, everyElement('premio_sigillo'),
        reason: 'PASSO 3: il premio non e\' stato chiesto come premio di un '
            'Sigillo: ${porta.causali}');
    expect(porta.importiChiesti, isEmpty,
        reason: 'PASSO 3: il client ha chiesto un IMPORTO al server, e il '
            'borsellino non si apre da solo: ${porta.importiChiesti}');
    expect(borsa.saldoEos, greaterThan(0),
        reason: 'PASSO 5: il server ha risposto ma il borsellino e\' a zero');
  });

  testWidgets('IL CRITERIO DI ACCETTAZIONE: nella festa unita la somma '
      'accreditata e\' la somma dei valori', (tester) async {
    final porta = _PortaCheRisponde();
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await diario.carica();
    final borsa = QuestionAllowance(porta: porta);
    final chiave = GlobalKey();
    await tester.pumpWidget(attorno(
      scena: SizedBox(key: chiave),
      diario: diario,
      porta: porta,
      borsa: borsa,
    ));

    await RegiaDelCammino.dopoUnGesto(chiave.currentContext!, 'sogno');
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    porta.azzera();
    await RegiaDelCammino.dopoUnGesto(chiave.currentContext!, 'gettata');
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    // Quali si sono accesi davvero CON L'ULTIMO GESTO, e quanto valgono.
    final accesi = [
      for (final t in Sentieri.tuttiITraguardi)
        if (porta.movimenti.contains('traguardo-${t.id}')) t,
    ];
    final attesa = accesi.fold<int>(0, (somma, t) => somma + t.eos);
    // ignore: avoid_print
    print('ORDINE AO VOCE 04: accesi ${accesi.length}, somma dei valori '
        '$attesa, accreditato dal server ${porta.accreditato}, movimenti '
        '${porta.movimenti.length}');
    expect(accesi.length, greaterThan(1),
        reason: 'questa prova ha bisogno di una FESTA UNITA: col gesto '
            'scelto si accende un traguardo solo e non misura niente');
    expect(porta.movimenti.toSet().length, accesi.length,
        reason: 'i movimenti chiesti al server sono '
            '${porta.movimenti.toSet().length} contro ${accesi.length} '
            'traguardi accesi: dentro una festa unita il premio parte per '
            'alcuni e non per tutti');
    expect(porta.accreditato, attesa,
        reason: 'la somma accreditata e\' ${porta.accreditato} contro '
            '${attesa} dei traguardi accesi');
    expect(borsa.saldoEos, porta.accreditato,
        reason: 'il borsellino mostra ${borsa.saldoEos} mentre il server ha '
            'accreditato ${porta.accreditato}');
  });

  testWidgets('PASSO 6: cio\' che il server rifiuta NON si segna nel libro',
      (tester) async {
    // **IL CANDIDATO PIU' PERICOLOSO DEI QUATTRO.** Un premio segnato come
    // arrivato mentre il server lo ha rifiutato e' un premio perso PER
    // SEMPRE: la sincronia guarda il libro e non lo riprende mai piu'.
    final porta = _PortaCheRifiuta();
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await diario.carica();
    final borsa = QuestionAllowance(porta: porta);
    final chiave = GlobalKey();
    await tester.pumpWidget(attorno(
      scena: SizedBox(key: chiave),
      diario: diario,
      porta: porta,
      borsa: borsa,
    ));

    await faiIGesti(tester, chiave, diario);

    final libro = await LibroDegliAccrediti.accreditati();
    // ignore: avoid_print
    print('ORDINE AO VOCE 04: col server che rifiuta, accesi '
        '${diario.accesi.length}, libro $libro');
    expect(diario.accesi, isNotEmpty,
        reason: 'il Sigillo doveva accendersi lo stesso: il premio e\' un '
            'premio, non il permesso di aver fatto la cosa');
    expect(libro, isEmpty,
        reason: 'il libro ha segnato come arrivati premi che il server ha '
            'rifiutato: quei premi non li riprendera\' piu\' nessuno');
  });

  testWidgets('PASSO 7: cio\' che non e\' arrivato si riprende all\'avvio',
      (tester) async {
    // Prima sessione: la rete non risponde, i Sigilli si accendono e i premi
    // restano indietro.
    final muta = _PortaMuta();
    final primo = DiarioDelCammino(orologio: orologioDelleProve);
    await primo.carica();
    final chiave = GlobalKey();
    await tester.pumpWidget(attorno(
      scena: SizedBox(key: chiave),
      diario: primo,
      porta: muta,
      borsa: QuestionAllowance(porta: muta),
    ));
    await faiIGesti(tester, chiave, primo);
    final accesi = [
      for (final t in Sentieri.tuttiITraguardi)
        if (primo.eAcceso(t.id)) t,
    ];
    final attesa = accesi.fold<int>(0, (somma, t) => somma + t.eos);
    expect(await LibroDegliAccrediti.accreditati(), isEmpty,
        reason: 'la rete non ha risposto e il libro ha segnato lo stesso');

    // Seconda sessione: la rete c'e', e la sincronia riprende TUTTI i premi
    // rimasti indietro, non uno.
    RegiaDelCammino.ripresaTentata = false;
    final porta = _PortaCheRisponde();
    final borsa = QuestionAllowance(porta: porta);
    final dopo = DiarioDelCammino(orologio: orologioDelleProve);
    final chiaveDue = GlobalKey();
    await tester.pumpWidget(attorno(
      scena: SizedBox(key: chiaveDue),
      diario: dopo,
      porta: porta,
      borsa: borsa,
    ));
    final lettura = dopo.carica();
    final corsa = RegiaDelCammino.riprendiIPremiPersi(chiaveDue.currentContext!);
    await tester.runAsync(() async {
      await lettura;
      await corsa;
    });
    await tester.pump(const Duration(milliseconds: 100));

    // ignore: avoid_print
    print('ORDINE AO VOCE 04: ripresi ${porta.movimenti.length} premi su '
        '${accesi.length}, accreditato ${porta.accreditato} contro $attesa');
    expect(porta.movimenti.toSet().length, accesi.length,
        reason: 'la sincronia ha ripreso ${porta.movimenti.toSet().length} '
            'premi su ${accesi.length}: alcuni restano perduti');
    expect(porta.accreditato, attesa,
        reason: 'la somma ripresa non e\' quella dei traguardi accesi');
  });

  test('CANDIDATO 4: due premi chiesti insieme finiscono tutti e due nel '
      'libro', () async {
    // **LA CORSA, e perche' e' un candidato serio.** Il libro fa
    // leggi-modifica-scrivi su disco: se due accrediti lo scrivono nello
    // stesso istante, il secondo puo' partire dalla lista vecchia e
    // cancellare il primo. Un premio che sparisce dal libro non e' perduto,
    // perche' la sincronia lo riprende e il server lo riconosce dal suo
    // identificativo, ma il libro smette di dire il vero e la sincronia
    // bussa a vuoto a ogni avvio.
    SharedPreferences.setMockInitialValues({});
    await Future.wait([
      LibroDegliAccrediti.segna('primo'),
      LibroDegliAccrediti.segna('secondo'),
      LibroDegliAccrediti.segna('terzo'),
    ]);
    final libro = await LibroDegliAccrediti.accreditati();
    // ignore: avoid_print
    print('ORDINE AO VOCE 04: dopo tre segni insieme, il libro dice $libro');
    expect(libro, {'primo', 'secondo', 'terzo'},
        reason: 'tre premi segnati nello stesso istante e il libro ne '
            'ricorda ${libro.length}: la corsa fra due scritture ne perde '
            'per strada');
  });
}

/// La porta che risponde come il server vero: accredita il valore del
/// traguardo e torna il saldo nuovo, ripetendo la risposta di allora per lo
/// stesso identificativo.
class _PortaCheRisponde extends PortaDelCerchio {
  final List<String> movimenti = [];
  final List<String> causali = [];
  final List<int> importiChiesti = [];
  final Map<String, int> _giaFatti = {};
  int accreditato = 0;

  /// Dimentica cio' che e' passato, per misurare un gesto solo.
  void azzera() {
    movimenti.clear();
    causali.clear();
    accreditato = 0;
    _giaFatti.clear();
  }

  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato({CamminoDaCustodire? cammino}) async => StatoDelCerchio(
      giorno: '2026-08-18',
      piano: 'free',
      spesi: const {},
      saldoEos: accreditato);

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
  }) async {
    movimenti.add(idMovimento);
    causali.add(causale);
    if (quanti != null) importiChiesti.add(quanti);
    // IDEMPOTENZA: lo stesso movimento ripete la risposta di allora.
    final gia = _giaFatti[idMovimento];
    if (gia != null) return gia;
    // Il valore lo decide il server dalla posizione del traguardo, come nel
    // vero: qui si legge dall'elenco per non copiare i numeri.
    final id = idMovimento.replaceFirst('traguardo-', '');
    final traguardo =
        Sentieri.tuttiITraguardi.where((t) => t.id == id).firstOrNull;
    accreditato += traguardo?.eos ?? 0;
    _giaFatti[idMovimento] = accreditato;
    return accreditato;
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

/// La porta che rifiuta: il server c'e' e dice di no.
class _PortaCheRifiuta extends PortaDelCerchio {
  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato({CamminoDaCustodire? cammino}) async => null;

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
      throw Exception('il server rifiuta il movimento');

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

/// La porta muta: viva, ma non risponde. E' la rete che manca.
class _PortaMuta extends PortaDelCerchio {
  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato({CamminoDaCustodire? cammino}) async => null;

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
