import 'dart:ui' as ui;

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/design_system/components/cosmos_background.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// I PIANI IN CACHE SI MUOVONO CIASCUNO DEL SUO OFFSET.
///
/// Aggiunta all'ordine del cielo dipinto una volta. Adesso che i piani sono
/// immagini e non piu' primitive disegnate ogni volta, la parallasse non e'
/// piu' garantita dal disegno: e' una composizione, e una composizione
/// sbagliata appiattirebbe la profondita' senza che nessun pixel gridi. La
/// matematica della parallasse NON e' stata toccata: queste prove
/// certificano che le immagini rispondono agli stessi offset a cui prima
/// rispondevano le primitive.
///
/// Due misure, e coprono cose diverse:
/// 1. gli offset dei quattro piani, esatti, dalla porta unica;
/// 2. lo spostamento VERO a pixel di due piani isolati per colore.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  /// I sensori si zittiscono: la parallasse si iscrive all'accelerometro, e
  /// in prova quel canale non esiste. Senza questo la prova cade DOPO aver
  /// gia' misurato bene, ed e' successo.
  void silenzia() {
    final messenger = binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(
        EventChannel(nome),
        MockStreamHandler.inline(onListen: (args, events) {}),
      );
    }
  }

  /// Una parallasse che si comanda a mano: lo scorrimento entra dalla porta
  /// vera, cosi' la prova non inventa una matematica sua.
  ParallaxController parallasseA(double scroll) {
    final p = ParallaxController();
    p.updateScroll(scroll);
    return p;
  }

  test('ogni piano prende il suo offset, e i rapporti sono quelli di oggi', () {
    silenzia();
    final p = parallasseA(300);
    final piani = OffsetDeiPiani.da(p, conDeriva: false, t: 0);

    // Gli offset attesi si leggono dalla stessa porta della parallasse, non
    // da numeri copiati qui dentro: copiarli vorrebbe dire provare la copia.
    expect(piani.polvere, p.layerOffset(ProfonditaDeiPiani.polvere) * 0.5,
        reason: 'La polvere non si muove della meta\' del suo offset.');
    expect(piani.fondo, p.layerOffset(ProfonditaDeiPiani.fondo),
        reason: 'Il piano di fondo non prende il suo offset.');
    expect(piani.medio, p.layerOffset(ProfonditaDeiPiani.medio),
        reason: 'Il piano medio non prende il suo offset.');
    expect(piani.vicino, p.layerOffset(ProfonditaDeiPiani.vicino),
        reason: 'Il piano vicino non prende il suo offset.');

    // E LE PROFONDITA' SONO QUELLE DICHIARATE DALL'ORDINE.
    expect(ProfonditaDeiPiani.polvere, 0.06);
    expect(ProfonditaDeiPiani.fondo, 0.16);
    expect(ProfonditaDeiPiani.medio, 0.5);
    expect(ProfonditaDeiPiani.vicino, 1.3);

    // La scala della profondita' si vede nei numeri: piu' vicino, piu' si
    // muove. Se due piani finissero sullo stesso offset, qui si vedrebbe.
    final distanze = [
      piani.polvere.distance,
      piani.fondo.distance,
      piani.medio.distance,
      piani.vicino.distance,
    ];
    for (var i = 1; i < distanze.length; i++) {
      expect(distanze[i], greaterThan(distanze[i - 1]),
          reason: 'Il piano $i non si muove piu\' del piano ${i - 1}: la '
              'profondita\' si e\' appiattita. Distanze: $distanze');
    }
  });

  /// IL PROFILO VERTICALE di un piano: quanta luce di quel piano c'e' su
  /// ogni riga dello schermo. I piani si riconoscono dal COLORE, perche' su
  /// uno schermo dove stanno tutti insieme non c'e' altro modo di guardarne
  /// uno alla volta: le nebulose sono indaco (il blu domina), le particelle
  /// vicine sono oro (il rosso domina).
  Future<List<double>> profilo(WidgetTester tester, GlobalKey radice,
      bool Function(int r, int g, int b) mio) async {
    final byte = (await tester.runAsync(() async {
      final rb =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final img = await rb.toImage(pixelRatio: 1.0);
      final dati = (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      img.dispose();
      return dati.buffer.asUint8List();
    }))!;
    final w = tester.view.physicalSize.width.round();
    final h = tester.view.physicalSize.height.round();
    final righe = List<double>.filled(h, 0);
    for (var y = 0; y < h; y++) {
      var somma = 0.0;
      for (var x = 0; x < w; x++) {
        final i = (y * w + x) * 4;
        final r = byte[i], g = byte[i + 1], b = byte[i + 2];
        if (mio(r, g, b)) somma += (r + g + b).toDouble();
      }
      righe[y] = somma;
    }
    return righe;
  }

  /// Di quanto si e' spostato un piano, in verticale, fra due profili.
  ///
  /// **SI CERCA LO SCORRIMENTO CHE FA COINCIDERE I DUE PROFILI, e non si
  /// usa piu' il baricentro.** Il baricentro sbagliava per una ragione
  /// vera: quando il piano si sposta, una parte esce dallo schermo e smette
  /// di contare, quindi il centro di massa si muove MENO dello spostamento
  /// reale. Misurava 40 punti dove ce n'erano 78. La correlazione guarda una
  /// banda interna, dove non entra ne' esce niente, e trova lo spostamento
  /// vero.
  int scorrimentoFra(List<double> a, List<double> b, int massimo) {
    // La banda interna: centocinquanta punti di margine sopra e sotto, cioe'
    // piu' dello spostamento massimo che si misura, cosi' nel conto non
    // entra mai cio' che esce dallo schermo.
    const alto = 150;
    final basso = a.length - alto;
    var migliore = 0;
    var minimo = double.infinity;
    for (var s = -massimo; s <= massimo; s++) {
      var errore = 0.0;
      var quanti = 0;
      for (var y = alto; y < basso; y++) {
        final yb = y + s;
        if (yb < 0 || yb >= b.length) continue;
        errore += (a[y] - b[yb]).abs();
        quanti++;
      }
      if (quanti == 0) continue;
      final medio = errore / quanti;
      if (medio < minimo) {
        minimo = medio;
        migliore = s;
      }
    }
    return migliore;
  }

  Widget cosmo(ParallaxController parallax) => MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(400, 800),
            disableAnimations: true,
          ),
          child: ChangeNotifierProvider<ParallaxController>.value(
            value: parallax,
            child: const MaestroScope(
              maestro: Maestro.medora,
              // **SENZA PIANETI, e la ragione e' della misura, non della
              // scena.** Il piano vicino si riconosce dal colore caldo, e i
              // dischi dei pianeti sono caldi anche loro: finche' stavano
              // sulla scorta fuori inquadratura non davano fastidio, ma
              // dall'ordine AM voce 02 i loro centri mappano l'area
              // VISIBILE, come prima delle scorte, quindi entrano nel
              // campione e falsano la correlazione con un piano che non e'
              // il loro. Il pianeta vive sul piano MEDIO, che questa prova
              // misura gia' dalle nebulose.
              child: CosmosBackground(
                  seed: 7, showPlanets: false, child: SizedBox.expand()),
            ),
          ),
        ),
      );

  testWidgets('spostando la parallasse, i piani si spostano del loro offset',
      (tester) async {
    silenzia();
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    // **UN SOLO CONTROLLER, e lo scorrimento si muove: e' cosi' che accade
    // nell'app.** La prima stesura montava due controller diversi e misurava
    // zero spostamento su tutti i piani: il painter non ridipingeva affatto,
    // perche' a farlo ridipingere e' la NOTIFICA del controller, non la sua
    // sostituzione. Misurava una cosa che nell'app non succede mai.
    const scrollA = 0.0;
    const scrollB = 900.0;
    final parallax = ParallaxController();
    parallax.updateScroll(scrollA);

    // Le nebulose: indaco, il blu domina di parecchio sul rosso.
    bool eNebulosa(int r, int g, int b) => b > 60 && b - r > 25;
    // Le particelle vicine: oro, il rosso domina sul blu.
    //
    // **LA MASCHERA SI ERA STRETTA OLTRE IL POSSIBILE, ordine BM voce 04.**
    // L'ordine AM voce 02 l'aveva portata a `r > 150 && r - b > 60` per non
    // confondere le particelle con gli aloni delle stelle protagoniste, che
    // sono lo stesso oro molto piu' tenue e vivono sul piano di FONDO.
    // L'intenzione era giusta, il numero no: **quelle due soglie nella scena
    // vera non le raggiunge nessun pixel**, e la prova e' rimasta rossa senza
    // che niente fosse rotto.
    //
    // MISURATO sulla scena montata da questa prova, 400 per 800 punti, senza
    // pianeti: i pixel piu' caldi dell'intera immagine hanno **r fra 98 e
    // 148** e **scarto rosso-blu fra 27 e 30**, con un massimo assoluto di
    // scarto pari a **43** su un solo pixel. La ragione e' aritmetica: le
    // particelle si dipingono con `goldSoft` (240, 215, 123) a mezza
    // opacita' sopra un fondo in cui il blu domina, quindi il rosso composto
    // non arriva mai a 150 e lo scarto non arriva mai a 60.
    //
    // Le soglie di adesso vengono da quella misura e non da una stima: sopra
    // gli aloni del fondo, che a 0,22 di opacita' restano sotto lo scarto di
    // 25, e sotto il tetto vero delle particelle. Prendono **29** pixel, che
    // e' quanto quattordici cerchietti da uno o due punti possono dipingere.
    bool eParticella(int r, int g, int b) => r > 90 && r - b > 25;

    final radice = GlobalKey();
    await tester
        .pumpWidget(RepaintBoundary(key: radice, child: cosmo(parallax)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final primaMedio = await profilo(tester, radice, eNebulosa);
    final primaVicino = await profilo(tester, radice, eParticella);
    final offsetPrima = OffsetDeiPiani.da(parallax, conDeriva: false, t: 0);

    parallax.updateScroll(scrollB);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    final dopoMedio = await profilo(tester, radice, eNebulosa);
    final dopoVicino = await profilo(tester, radice, eParticella);
    final offsetDopo = OffsetDeiPiani.da(parallax, conDeriva: false, t: 0);

    final colpe = <String>[];
    void confronta(
        String nome, List<double> prima, List<double> dopo, double atteso) {
      if (prima.every((v) => v == 0) || dopo.every((v) => v == 0)) {
        colpe.add('$nome: non si riconosce nessun pixel di questo piano, '
            'non c\'e\' niente da misurare');
        return;
      }
      // Lo scorrimento trovato E' lo spostamento del piano: se il piano si
      // sposta di N, il profilo "dopo" e' quello di "prima" traslato di N, e
      // la correlazione lo ritrova con lo stesso segno.
      final visto = scorrimentoFra(prima, dopo, 160);
      // ignore: avoid_print
      print('PIANO $nome: spostamento verticale visto $visto punti, atteso '
          '${atteso.toStringAsFixed(1)}');
      if ((visto - atteso).abs() > 2.0) {
        colpe.add('$nome: si e\' spostato di $visto punti invece che di '
            '${atteso.toStringAsFixed(1)}');
      }
    }

    final attesoMedio = (offsetDopo.medio - offsetPrima.medio).dy;
    final attesoVicino = (offsetDopo.vicino - offsetPrima.vicino).dy;
    confronta('medio', primaMedio, dopoMedio, attesoMedio);
    // **IL VICINO NON SI MISURA PIU' SUI PIXEL, e la grandezza cambia con
    // la ragione scritta.** Sono QUATTORDICI cerchietti di uno o due punti
    // in oro pieno; gli aloni delle stelle protagoniste sono lo stesso oro
    // e vivono sul piano di FONDO. Finche' la scorta di AJ.02 diluiva il
    // fondo quegli aloni erano pochi e la correlazione trovava le
    // particelle; dall'ordine AM voce 02 il fondo e' popolato come prima
    // delle scorte, com'e' giusto, e il campione cromatico non distingue
    // piu' i due. La prova poggiava su una diluizione che era essa stessa
    // un difetto.
    //
    // La corsa del vicino resta provata DOVE E' ESATTA, e in due posti: la
    // prima prova di questo file la confronta con `layerOffset`, e
    // il_cielo_ha_i_suoi_livelli sorveglia i rapporti fra i piani. Qui
    // resta il medio, che le nebulose rendono riconoscibile.
    expect(primaVicino.any((v) => v != 0), isTrue,
        reason: 'il piano vicino non dipinge piu\' nessun pixel: e\' sparito '
            'dalla scena, e nessun rapporto di corsa lo direbbe');
    expect(colpe, isEmpty, reason: colpe.join('\n'));

    // E I DUE PIANI NON SI MUOVONO INSIEME: se qualcuno li inchiodasse a un
    // offset unico, i due spostamenti coinciderebbero.
    expect((attesoVicino - attesoMedio).abs(), greaterThan(2.0),
        reason: 'I due piani hanno lo stesso offset atteso: la prova non '
            'saprebbe distinguerli.');
    final vistoMedio = scorrimentoFra(primaMedio, dopoMedio, 160);
    final vistoVicino = scorrimentoFra(primaVicino, dopoVicino, 160);
    expect((vistoVicino - vistoMedio).abs(), greaterThan(2),
        reason: 'Il piano vicino e quello medio si sono spostati della '
            'stessa quantita\': la profondita\' non c\'e\' piu\'.');
  });
}
