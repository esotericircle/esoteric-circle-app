import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/astro/natal_chart_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/sigilli/coda_delle_feste.dart';
import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/sigilli/celebrazione.dart';
import 'package:esoteric_circle/features/sigilli/regia_del_cammino.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// UNA FESTA ALLA VOLTA, E IL FONDO SI OSCURA. Ordine S voce 09.
///
/// **Il difetto, visto sulla 2177.** Due celebrazioni si dipingevano nello stesso
/// istante, una sopra l'altra, con due "+10 Eos" sovrapposti e il testo della
/// schermata sotto che si leggeva attraverso. Illeggibile: e due premi illeggibili
/// non sono due premi, sono un disturbo.
///
/// **DUE MISURE DISTINTE, perche' sono due difetti distinti.** Il primo si misura
/// contando le feste a ogni fotogramma; il secondo si misura SUI PIXEL, perche'
/// "il fondo si oscura" a occhio e' un'opinione e in numeri e' un fatto.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FesteInCorso.azzera();
  });

  /// Quante celebrazioni ci sono a schermo, in QUESTO fotogramma.
  int quanteFesteAVideo() =>
      find.byKey(const Key('sovrimpressione_del_traguardo')).evaluate().length +
      find.byType(CelebrazioneAScermoPieno).evaluate().length;

  testWidgets('tre traguardi nello stesso istante non si sovrappongono mai',
      (tester) async {
    // **IL GESTO CHE ACCENDE PIU' SIGILLI INSIEME esiste davvero**: la regia
    // guarda tutto l'elenco dopo ogni gesto, e piu' condizioni possono maturare
    // con lo stesso gesto. Qui si accendono a mano tre traguardi vicini e si
    // chiede alla regia di guardare: e' la stessa strada dell'app.
    final porta = _PortaCheAccredita();
    final diario = DiarioDelCammino();
    await diario.carica();
    final servizi = AppServices.offline('prova della voce S.09', porta);

    await tester.pumpWidget(MultiProvider(
      providers: [
        Provider<AppServices>.value(value: servizi),
        ChangeNotifierProvider(create: (_) => MaestroController()),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => NatalChartController()),
        ChangeNotifierProvider(create: (_) => QuestionAllowance(porta: porta)),
        ChangeNotifierProvider(create: (_) => CodaDelleFeste()..carica()),
        ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MaestroScope(child: child!),
        home: const GuardianoDelleFeste(
          child: Scaffold(body: Center(child: Text('quello che stavo facendo'))),
        ),
      ),
    ));
    await tester.pump();

    final contesto = tester.element(find.text('quello che stavo facendo'));
    // **SI MISURA ALLA PORTA, e le due stesure precedenti misuravano altro.**
    // La prima chiamava `dopoUnGesto` tre volte: ogni chiamata guarda l'elenco
    // per conto suo, i traguardi maturavano uno per passaggio e due feste non si
    // incontravano mai. La seconda segnava sei gesti e chiedeva un solo
    // passaggio: con quei gesti matura UN traguardo, verificato stampando il
    // diario, quindi neanche cosi' due feste si incontravano. Entrambe restavano
    // verdi togliendo il presidio, cioe' passavano per la ragione sbagliata, e si
    // sono buttate.
    //
    // Il ciclo della regia fa esattamente questo: per ogni Sigillo maturato
    // chiama `festeggia`, una dopo l'altra, senza attendere la precedente. Qui si
    // chiama due volte di fila, che e' quel ciclo con due Sigilli.
    final due = Sentieri.miniDi(Sentiero.costellazione).take(2).toList();
    final prima = await Celebrazione.festeggia(contesto,
        traguardo: due.first,
        sentiero: Sentiero.costellazione,
        primoInAssoluto: false);
    final seconda = await Celebrazione.festeggia(contesto,
        traguardo: due.last,
        sentiero: Sentiero.costellazione,
        primoInAssoluto: false);
    await tester.pump();

    expect(prima, isTrue, reason: 'la prima festa non e\' comparsa');
    expect(seconda, isFalse,
        reason: 'la seconda festa si e\' dipinta sopra la prima: chi chiama deve '
            'riceverne un no, e metterla in coda');

    // SI GUARDA FOTOGRAMMA PER FOTOGRAMMA per venti secondi di scena: se a un
    // qualsiasi istante ce ne sono due, la voce non e' chiusa.
    var massimo = 0;
    for (var passo = 0; passo < 200; passo++) {
      await tester.pump(const Duration(milliseconds: 100));
      final quante = quanteFesteAVideo();
      if (quante > massimo) massimo = quante;
      expect(quante, lessThanOrEqualTo(1),
          reason: 'al fotogramma $passo ci sono $quante celebrazioni a schermo: '
              'due feste nello stesso istante sono illeggibili, e i premi di '
              'entrambe si perdono');
    }
    expect(massimo, 1,
        reason: 'nessuna festa e\' mai comparsa: la prova non ha misurato '
            'niente');
  });

  testWidgets('sotto il velo il testo di sotto SPARISCE, misurato sui pixel',
      (tester) async {
    // **LA GRANDEZZA MISURATA E' UN DIFFERENZIALE, e la prima stesura era piu'
    // grezza.** Leggere il contrasto della fascia con la festa sopra mescola due
    // cose: quanto del testo di sotto passa attraverso il velo, e la variazione
    // di luce del bagliore, che e' della festa e non di sotto. Misurate insieme
    // danno un numero che non risponde alla domanda della voce.
    //
    // Qui si scattano QUATTRO immagini: la schermata col testo e senza velo, la
    // stessa senza il testo, e le due gemelle col velo sopra. La differenza fra
    // le due gemelle, pixel per pixel, e' esattamente cio' che del testo passa:
    // tutto il resto e' identico nelle due, quindi si cancella.
    //
    // **IL CONFINE STA SOPRA L'APP, e non dentro la schermata**: la fascia vive
    // nell'Overlay del Navigator, e un RepaintBoundary messo dentro la pagina non
    // la dipingerebbe affatto.
    final chiave = GlobalKey();
    final diario = DiarioDelCammino();
    await diario.carica();
    final mini = Sentieri.miniDi(Sentiero.loto).first;
    final mostraIlTesto = ValueNotifier<bool>(true);

    await tester.pumpWidget(RepaintBoundary(
      key: chiave,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => QuestionAllowance()),
          ChangeNotifierProvider<DiarioDelCammino>.value(value: diario),
        ],
        child: MaterialApp(
          // **VIA LA FASCETTA DEBUG, e non e' un dettaglio.** Il nastro rosso in
          // alto a destra e' dipinto SOPRA tutto, velo compreso: il pixel piu'
          // luminoso della fascia guardata era il suo, a (769, 24), e la misura
          // accusava il velo di non coprire un testo che invece copriva.
          debugShowCheckedModeBanner: false,
          builder: (ctx, child) => MaestroScope(child: child!),
          // **IL TESTO DI SOTTO STA IN ALTO, e non al centro**, dove la festa
          // scrive il proprio: al centro si misurerebbe il contrasto della
          // celebrazione invece di quello che sta sotto.
          home: ColoredBox(
            key: const Key('quello_che_sta_sotto'),
            color: Colors.black,
            child: Align(
              alignment: const Alignment(0, -0.82),
              child: ValueListenableBuilder<bool>(
                valueListenable: mostraIlTesto,
                builder: (_, mostra, __) => Opacity(
                  opacity: mostra ? 1 : 0,
                  child: const Text(
                    'IL GIORNO PIENO',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.pump();

    /// I byte della fascia alta, dove il testo di sotto e' scritto.
    Future<List<int>> fasciaAlta() async {
      final immagine = await tester.runAsync(() async {
        final confine =
            chiave.currentContext!.findRenderObject() as RenderRepaintBoundary;
        return confine.toImage(pixelRatio: 1);
      });
      final dati = await tester.runAsync(
          () => immagine!.toByteData(format: ui.ImageByteFormat.rawRgba));
      final byte = dati!.buffer.asUint8List();
      final largo = immagine!.width;
      final alto = immagine.height;
      final da = (alto * 0.04).round();
      final a = (alto * 0.16).round();
      return byte.sublist(da * largo * 4, a * largo * 4);
    }

    double luce(List<int> b, int i) =>
        0.2126 * b[i] + 0.7152 * b[i + 1] + 0.0722 * b[i + 2];

    double differenzaMassima(List<int> uno, List<int> due) {
      var massima = 0.0;
      for (var i = 0; i < uno.length; i += 4) {
        final scarto = (luce(uno, i) - luce(due, i)).abs();
        if (scarto > massima) massima = scarto;
      }
      return massima;
    }

    final nudoConTesto = await fasciaAlta();
    mostraIlTesto.value = false;
    await tester.pump();
    final nudoSenzaTesto = await fasciaAlta();
    final scoperto = differenzaMassima(nudoConTesto, nudoSenzaTesto);
    expect(scoperto, greaterThan(200),
        reason: 'senza velo il testo di prova cambia i pixel di soli '
            '${scoperto.toStringAsFixed(1)} livelli: non c\'e\' abbastanza da '
            'coprire, e la prova non misurerebbe niente');

    // ADESSO LA FESTA, dalla sua porta vera.
    mostraIlTesto.value = true;
    await tester.pump();
    final contesto =
        tester.element(find.byKey(const Key('quello_che_sta_sotto')));
    expect(
        mostraLaSovrimpressione(contesto,
            traguardo: mini, sentiero: Sentiero.loto),
        isTrue,
        reason: 'la sovrimpressione non e\' comparsa: niente da misurare');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    final copertoConTesto = await fasciaAlta();
    mostraIlTesto.value = false;
    await tester.pump();
    final copertoSenzaTesto = await fasciaAlta();
    final passa = differenzaMassima(copertoConTesto, copertoSenzaTesto);

    // **LA SOGLIA NON PUO' DERIVARE DAL VELO, e la prova del rosso lo ha
    // dimostrato.** La prima stesura calcolava il massimo ammesso come
    // `1 - VeloDellaCelebrazione.opacita`: diluendo il velo da 0,92 a 0,35 la
    // soglia si allargava insieme al difetto, e la prova restava VERDE col testo
    // di sotto perfettamente leggibile. Una misura che si tara su cio' che deve
    // giudicare non giudica niente, e si butta.
    //
    // Il numero qui e' una soglia di LEGGIBILITA', dichiarata: ventiquattro
    // livelli di luce su 255, meno del dieci per cento. Sotto quella differenza
    // un testo bianco in grassetto da quaranta punti non si legge piu': resta
    // un'ombra, e un'ombra e' quello che il velo puo' lasciare.
    const massimoCheSiVede = 24.0;
    expect(passa, lessThan(massimoCheSiVede),
        reason: 'del testo di sotto passano ${passa.toStringAsFixed(1)} livelli '
            'di luce su ${scoperto.toStringAsFixed(1)}, e il massimo concesso '
            'e\' $massimoCheSiVede: si legge attraverso, ed e\' il difetto della '
            'voce. Il velo dichiara ${VeloDellaCelebrazione.opacita} di '
            'opacita\'');
  });

  test('il velo e\' un numero solo, e nessuno lo riscrive a mano', () {
    // La forma grande aveva `0xCC05060A` dentro la rotta e la fascia un
    // gradiente che finiva trasparente: due numeri per la stessa promessa, e uno
    // la tradiva. Se qualcuno ne riscrive uno a mano, questa cade.
    // **UN COMMENTO NON DIPINGE NIENTE.** La riga che spiega quale numero c'era
    // prima lo nomina per forza, e la prima stesura di questa misura accusava
    // se stessa: si guarda il codice, non cio' che il codice racconta. E' la
    // stessa correzione della voce S.05.
    final sorgente = File('lib/features/sigilli/celebrazione.dart')
        .readAsLinesSync()
        .where((r) => !r.trimLeft().startsWith('//'))
        .join(String.fromCharCode(10));
    expect(sorgente.contains('0xCC05060A'), isFalse,
        reason: 'la barriera della forma grande e\' tornata un numero scritto a '
            'mano, che nessuno tiene d\'accordo col velo della fascia');
    // **DUE LETTURE, una per forma.** Non basta che la costante esista: se una
    // delle due tornasse a scriversi il numero da se', le due forme
    // divergerebbero di nuovo. `Colors.transparent` non si puo' vietare in
    // blocco, perche' in questo file serve a mezza dozzina di cose che non sono
    // veli: si guarda percio' che il velo dichiarato sia LETTO due volte.
    // Si contano le letture del VELO, non quelle della sola opacita': la forma
    // grande legge il numero, la fascia legge il colore che da quel numero nasce,
    // e sono due modi di leggere la stessa dichiarazione.
    final letture = 'VeloDellaCelebrazione.'.allMatches(sorgente).length;
    expect(letture, greaterThanOrEqualTo(2),
        reason: 'il velo dichiarato viene letto $letture volte: le due forme '
            'della celebrazione devono leggerlo entrambe, altrimenti una delle '
            'due torna a scriversi la sua opacita\'');
  });
}

/// La porta che accredita: il premio arriva, e la voce non lo misura.
class _PortaCheAccredita extends PortaDelCerchio {
  int saldo = 0;

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
