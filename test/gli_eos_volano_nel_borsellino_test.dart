import 'package:esoteric_circle/core/astro/natal_chart_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/design_system/components/borsellino.dart';
import 'package:esoteric_circle/design_system/components/volo_degli_eos.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/sigilli/regia_del_cammino.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'istante_dichiarato.dart';

/// GLI EOS VOLANO DALLA CELEBRAZIONE AL BORSELLINO. Ordine S voce 07.
///
/// **Le due cose che si misurano sono due perche' possono rompersi da sole.** Il
/// numero che sale contando e' la notizia; il volo delle scintille e' il modo in
/// cui si vede arrivare. Con Riduci Movimento la seconda si toglie e la prima
/// deve restare, e sono percio' misure distinte.
///
/// **NON SI MISURA CHE ESISTA UN WIDGET, SI MISURA DOVE ARRIVA.** Una prova che
/// cercasse `VoloDegliEos` nel sorgente passerebbe con le scintille che volano
/// nell'angolo sbagliato: qui si legge la posizione dell'ultima scintilla e si
/// confronta con la scatola del borsellino, chiesta a chi la dichiara.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  /// Il banco: una barra con dentro il segno del borsellino, come nell'app.
  Future<QuestionAllowance> montaIlBanco(
    WidgetTester tester, {
    int saldo = 0,
    bool riduciMovimento = false,
  }) async {
    final borsa = QuestionAllowance();
    await borsa.applicaSaldo(saldo);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider<QuestionAllowance>.value(value: borsa),
      ],
      child: MediaQuery(
        // **LA MISURA VERA DELLO SCHERMO, e non una MediaQueryData nuda.**
        // MaterialApp inserisce la sua MediaQuery solo se non ce n'e' gia' una:
        // con una vuota qui, la misura dello schermo valeva zero per tutta
        // l'app.
        data: MediaQueryData.fromView(tester.view)
            .copyWith(disableAnimations: riduciMovimento),
        child: MaterialApp(
          home: MaestroScope(
            child: Scaffold(
              appBar: AppBar(actions: const [SegnoDelBorsellino()]),
              body: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
    return borsa;
  }

  int numeroAVideo(WidgetTester tester) {
    final testo = tester
        .widget<Text>(find.byKey(const Key('saldo_eos_numero')))
        .data!;
    return int.parse(testo.split(' ').first);
  }

  testWidgets('il numero non conta all\'apertura, e conta quando arrivano',
      (tester) async {
    final borsa = await montaIlBanco(tester, saldo: 30);
    // **ALL'APERTURA NON SI CONTA.** Un saldo che parte da zero a ogni apertura
    // racconterebbe un premio che non e' appena arrivato: il conto e' il racconto
    // di un cambiamento.
    expect(numeroAVideo(tester), 30,
        reason: 'aprendo la schermata il numero conta da capo, come se i trenta '
            'Eos fossero appena arrivati');

    // ADESSO ARRIVANO DIECI EOS: il saldo del server sale, e il volo lo annuncia.
    await borsa.applicaSaldo(40);
    ArrivoDegliEos.annuncia(10);
    await tester.pump();
    // A META' DELLA CORSA il numero deve stare IN MEZZO: se fosse gia' quaranta
    // il numero sarebbe scattato, non salito, e non ci sarebbe niente da vedere.
    await tester.pump(VoloDegliEos.durata * 0.4);
    final aMeta = numeroAVideo(tester);
    expect(aMeta, greaterThan(30),
        reason: 'a meta\' della corsa il numero e\' ancora quello di prima: non '
            'sta contando');
    expect(aMeta, lessThan(40),
        reason: 'il numero e\' scattato subito a 40: e\' cambiato senza che si '
            'veda cambiare, che e\' il difetto della voce');

    await tester.pump(VoloDegliEos.durata);
    expect(numeroAVideo(tester), 40,
        reason: 'il conto non e\' arrivato al saldo del server');
  });

  testWidgets('le scintille arrivano DOVE STA il borsellino', (tester) async {
    await montaIlBanco(tester, saldo: 5);
    final contesto = tester.element(find.byType(SegnoDelBorsellino));
    final scatola = DoveStaIlBorsellino.scatola();
    expect(scatola, isNotNull,
        reason: 'il borsellino non dichiara dove sta, quindi il volo non ha un '
            'punto d\'arrivo e finirebbe in un angolo scritto a mano');

    expect(VoloDegliEos.lancia(contesto, quanti: 12), isTrue,
        reason: 'il volo non e\' partito');
    await tester.pump();
    expect(find.byKey(const Key('eos_in_volo_0')), findsOneWidget);

    // ALL'INIZIO le scintille stanno al centro dello schermo, lontane.
    final schermo = tester.getSize(find.byType(MaterialApp));
    final partenza = tester.getCenter(find.byKey(const Key('eos_in_volo_0')));
    expect((partenza - Offset(schermo.width / 2, schermo.height / 2)).distance,
        lessThan(60),
        reason: 'le scintille non partono dal centro della scena, cioe\' da dove '
            'la celebrazione mostra il premio');

    // QUASI ALLA FINE devono essere arrivate: si misura la distanza dal centro
    // della scatola del borsellino, non da un punto scritto qui.
    await tester.pump(VoloDegliEos.durata * 0.95);
    final arrivo = tester.getCenter(find.byKey(const Key('eos_in_volo_0')));
    final distanza = (arrivo - scatola!.center).distance;
    expect(distanza, lessThan(scatola.longestSide,),
        reason: 'la prima scintilla finisce a ${distanza.toStringAsFixed(1)} '
            'punti dal borsellino, che e\' largo ${scatola.width.toStringAsFixed(1)}: '
            'gli Eos volano da qualche altra parte');

    // E NON RESTANO A SCHERMO: una scintilla ferma sopra il numero sarebbe uno
    // sporco permanente.
    await tester.pump(VoloDegliEos.durata);
    await tester.pump();
    expect(find.byKey(const Key('eos_in_volo_0')), findsNothing,
        reason: 'le scintille sono rimaste a schermo dopo il volo');
  });

  testWidgets('con Riduci Movimento non vola niente e il numero sale comunque',
      (tester) async {
    final borsa = await montaIlBanco(tester, saldo: 0, riduciMovimento: true);
    final contesto = tester.element(find.byType(SegnoDelBorsellino));

    await borsa.applicaSaldo(10);
    expect(VoloDegliEos.lancia(contesto, quanti: 10), isFalse,
        reason: 'con Riduci Movimento le scintille volano comunque');
    await tester.pump();
    expect(find.byKey(const Key('eos_in_volo_0')), findsNothing);

    // **IL NUMERO NON SCOMPARE MAI, e sale.** L'ordine lo chiede per intero: si
    // toglie il moto, non la notizia. Si guarda a ogni passo, perche' un numero
    // che sparisce per due fotogrammi e' un numero che sparisce.
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byKey(const Key('saldo_eos_numero')), findsOneWidget,
          reason: 'il numero e\' scomparso durante il conto');
    }
    expect(numeroAVideo(tester), 10,
        reason: 'con Riduci Movimento il numero non e\' salito: si toglie il '
            'volo, non la notizia');
  });

  testWidgets('il volo parte QUANDO LA FESTA SE NE VA, non prima',
      (tester) async {
    // **IL GIRO INTERO, e serve.** Le prove di sopra misurano i pezzi con un
    // annuncio scritto a mano. Questa fa il gesto vero: la regia accende un
    // traguardo, celebra, accredita, e il volo deve partire alla CHIUSURA della
    // festa. Lanciato prima attraverserebbe una celebrazione a schermo pieno per
    // arrivare a un borsellino coperto, e non lo vedrebbe nessuno.
    // **LA MISURA DEL TELEFONO, e serve.** Su 800 per 600, che e' la finestra di
    // prova per difetto, il tasto che chiude la festa a schermo pieno resta fuori
    // e il tocco non lo raggiunge: la prova cadeva dicendo che la festa non se ne
    // andava, e la festa stava solo aspettando un tocco che non arrivava.
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    final porta = _PortaCheAccredita();
    final borsa = QuestionAllowance(porta: porta);
    final diario = DiarioDelCammino(orologio: orologioDelleProve);
    await diario.carica();
    final servizi = AppServices.offline('prova della voce S.07', porta);

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
        home: MaestroScope(
          child: Scaffold(
            appBar: AppBar(actions: const [SegnoDelBorsellino()]),
            body: const SizedBox.expand(),
          ),
        ),
      ),
    ));
    await tester.pump();

    final contesto = tester.element(find.byType(SegnoDelBorsellino));
    // **SI FANNO I GESTI FINCHE' UNA FESTA COMPARE, e non si conta a mano
    // quanti ne serviranno.** Il traguardo che si accende per primo ha le sue
    // condizioni, e scrivere qui "tre stese" vorrebbe dire tenere d'accordo la
    // prova con l'elenco dei traguardi per sempre: quando la festa c'e', la
    // prova comincia a misurare.
    var comparsa = false;
    for (var gesto = 0; gesto < 5 && !comparsa; gesto++) {
      await RegiaDelCammino.dopoUnGesto(contesto, 'stesa');
      for (var passo = 0; passo < 4 && !comparsa; passo++) {
        await tester.pump(const Duration(milliseconds: 200));
        comparsa = find.byKey(const Key('eos_che_volano')).evaluate().isNotEmpty;
      }
    }
    expect(comparsa, isTrue,
        reason: 'nessuna festa e\' comparsa in cinque gesti: la prova non ha '
            'niente da misurare');
    expect(porta.movimenti, isNotEmpty, reason: 'nessun accredito e\' partito');

    // **MENTRE LA FESTA E' A SCHERMO NON DEVE VOLARE NIENTE.** E' il difetto che
    // questa voce evita: le scintille attraverserebbero la celebrazione per
    // arrivare a un borsellino coperto, e non le vedrebbe nessuno.
    for (var passo = 0; passo < 6; passo++) {
      if (find.byKey(const Key('eos_che_volano')).evaluate().isEmpty) break;
      expect(find.byKey(const Key('eos_in_volo_0')), findsNothing,
          reason: 'gli Eos volano mentre la festa copre ancora la barra');
      await tester.pump(const Duration(milliseconds: 500));
    }

    // LA FESTA SE NE VA, e allora partono.
    //
    // **IL PRIMO SIGILLO IN ASSOLUTO SI FESTEGGIA A SCHERMO PIENO, e quella
    // scena NON se ne va da se':** aspetta che la persona la chiuda, ed e' la
    // scelta della voce P.20. La prima stesura di questa prova aspettava dieci
    // secondi e cadeva dicendo che la festa non se ne era andata: non era un
    // difetto del volo, era una festa che stava aspettando un tocco.
    final continua = find.byKey(const Key('celebrazione_continua'));
    if (continua.evaluate().isNotEmpty) {
      await tester.tap(continua);
    }
    for (var passo = 0; passo < 24; passo++) {
      if (find.byKey(const Key('eos_che_volano')).evaluate().isEmpty) break;
      await tester.pump(const Duration(milliseconds: 500));
    }
    expect(find.byKey(const Key('eos_che_volano')), findsNothing,
        reason: 'la festa non se ne e\' andata da se\'');
    expect(find.byKey(const Key('eos_in_volo_0')), findsOneWidget,
        reason: 'la festa si e\' chiusa e non e\' volato niente: il gancio della '
            'chiusura non lancia il volo');

    // E IL NUMERO ARRIVA AL SALDO DEL SERVER, contando.
    await tester.pump(VoloDegliEos.durata * 2);
    expect(numeroAVideo(tester), porta.saldo,
        reason: 'dopo la festa il numero in barra non e\' arrivato al saldo del '
            'server: l\'annuncio della chiusura non ha fatto contare niente');
  });
}

/// La porta che accredita davvero: torna il saldo nuovo dentro la risposta.
class _PortaCheAccredita extends PortaDelCerchio {
  _PortaCheAccredita();

  int saldo = 0;
  final List<String> movimenti = [];

  @override
  bool get viva => true;

  @override
  Future<StatoDelCerchio?> stato() async => null;

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
