import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/sensi/respiro_che_dirada.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/la_lente_che_scopre.dart';
import 'package:flutter/rendering.dart';

import 'package:esoteric_circle/features/maestri/caligo/viaggio/il_tunnel_che_scende.dart';
import 'package:esoteric_circle/features/maestri/caligo/viaggio/la_nebbia_e_l_animale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LA DISCESA RIEMPIE LO SCHERMO, E LO SI MISURA SUI PIXEL.**
/// Ordine DC voce 07, sotto la Regola I. 10 settembre 2026.
///
/// **LA REGOLA I NASCE DA UN DIFETTO MIO, e questa guardia e' la prima scritta
/// sotto di lei.** Nell'ordine DB il loto prometteva il cinquantaquattro per
/// cento e ne dipingeva diciotto, perche' **la guardia interrogava la formula
/// invece della forma**. Poi, riparato, occupava il cinquantaquattro per cento
/// **del suo riquadro** e il trentacinque **dello schermo**, perche' la
/// seconda misura non esisteva. Due giri interi per lo stesso errore in due
/// livelli.
///
/// **Qui si dipinge su una tela vera e si contano i pixel accesi**, e la
/// misura e' sulla finestra intera, non su un riquadro.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// **LA FINESTRA VERA, non una tela quadrata di comodo.** Regola I.
  ///
  /// Trecentonovanta per ottocentoquarantaquattro e' il telefono su cui
  /// questo progetto misura da sempre; tolte la barra di sistema, la barra
  /// del Cosmo e la barra del titolo, al corpo restano **seicentottantadue**
  /// punti di altezza. E' quella la scena che il tunnel deve riempire.
  ///
  /// **QUESTO NUMERO E' NATO DA UN DIFETTO.** La prima stesura di questa
  /// guardia dipingeva su 390 per 390: su un quadrato gli anelli, che hanno
  /// il raggio legato al lato corto, coprivano tutto, e la guardia era verde.
  /// Sul telefono 767f596c, il 10 settembre 2026, la stessa scena lasciava
  /// scoperti **sopra e sotto**. Una guardia che sceglie la propria finestra
  /// sceglie anche il proprio esito.
  const corpoVero = Size(390, 682);

  /// Dipinge un pittore su una tela e torna l'immagine.
  ui.Image dipingi(CustomPainter pittore, {Size quanto = corpoVero}) {
    final registratore = ui.PictureRecorder();
    final tela = Canvas(registratore);
    pittore.paint(tela, quanto);
    return registratore
        .endRecording()
        .toImageSync(quanto.width.toInt(), quanto.height.toInt());
  }

  group('DC.07, il tunnel della riserva', () {
    // **DAL 12 SETTEMBRE 2026 IL TUNNEL DISEGNATO E' LA RISERVA**, ordine DI
    // voce 09: la discesa e' il filmato del fondatore, e questo tunnel si vede
    // solo se il filmato non si carica.
    //
    // **QUI C'ERANO QUATTRO PROVE, e due se ne sono andate con cio' che
    // misuravano.** *"Gli anelli vicini sono piu' scuri dei lontani"* e *"le
    // forme vive sono dichiarate e sotto il tetto"* misuravano i diciotto
    // anelli del pittore, che si disegnavano **solo quando sotto non c'era la
    // roccia**: e la roccia c'era sempre. Dipingevano il pittore in un ramo che
    // la produzione non percorre, ed erano la difesa di un codice che nessuna
    // persona ha mai visto. L'ordine l'ha chiamato *"peso morto che mente a
    // chi legge"*, e il codice e le sue due prove sono stati tolti insieme.
    //
    // **Le altre due misuravano una cosa vera**, e adesso la misurano sul
    // widget vero, roccia compresa, invece che sul pittore da solo.
    Future<Uint8List> fotografa(WidgetTester tester, double quota) async {
      late Uint8List byte;
      await tester.runAsync(() async {
        await tester.pumpWidget(MaterialApp(
          home: RepaintBoundary(
            key: const Key('foglio'),
            child: SizedBox(
              width: corpoVero.width,
              height: corpoVero.height,
              child: TunnelCheScende(quantoSiEScesi: quota, senzaMoto: false),
            ),
          ),
        ));
        await precacheImage(const AssetImage(TunnelCheScende.parete),
            tester.element(find.byType(SizedBox).first));
        await tester.pump(const Duration(milliseconds: 50));
        final foglio = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const Key('foglio')));
        final img = await foglio.toImage();
        final dati = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
        byte = dati!.buffer.asUint8List();
      });
      return byte;
    }

    testWidgets('IL TUNNEL OCCUPA LA SCENA INTERA', (tester) async {
      await tester.binding.setSurfaceSize(corpoVero);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final b = await fotografa(tester, 0.5);
      // **LA MISURA E' IL PIXEL DIPINTO**, cioe' non trasparente: nella
      // finestra vera, alta il doppio di quanto e' larga, sopra e sotto non
      // deve restare la pagina.
      var dipinti = 0;
      for (var i = 3; i < b.length; i += 4) {
        if (b[i] > 200) dipinti++;
      }
      final quota = dipinti / (b.length / 4);
      // ignore: avoid_print
      print('ORDINE DC VOCE 07: nella finestra vera '
          '${corpoVero.width.toInt()}x${corpoVero.height.toInt()} il tunnel '
          'della riserva dipinge il ${(quota * 100).toStringAsFixed(1)} per '
          'cento dei pixel');
      expect(quota, greaterThanOrEqualTo(0.95),
          reason: 'il tunnel della riserva dipinge solo il '
              '${(quota * 100).toStringAsFixed(1)} per cento della scena: '
              'resta la pagina, e chi guarda sta davanti a un disegno di '
              'tunnel, non dentro un tunnel');
    });

    testWidgets('IL TUNNEL SI MUOVE COL DITO, e non da solo', (tester) async {
      await tester.binding.setSurfaceSize(corpoVero);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      // **SI MISURA LA PARETE, FUORI DAL CERCHIO DELLA LUCE.** Al primo giro
      // questa prova contava i pixel cambiati su tutta la finestra fra la bocca
      // e meta' discesa, e trovava il 14 per cento: la roccia si ripete sei
      // volte, e a meta' discesa ha fatto tre giri esatti, cioe' e' tornata
      // dov'era. **Il confronto misurava la sola luce che si stringe.** Anche
      // un quarto di piastrella non bastava a separare le due cose: la luce da
      // sola, con la roccia ferma, cambiava il 15 per cento della finestra.
      //
      // **Si cambia la grandezza, non la soglia.** Fuori dal cerchio piu'
      // largo che la luce possa avere, meta' del lato corto, cambia solo cio'
      // che fa la roccia. Sonda del 12 settembre 2026: con un quarto di
      // piastrella cambia circa un terzo di quella zona; con la roccia tornata
      // al suo posto, un giro intero, **cambia lo zero virgola zero**. Una
      // soglia al dieci per cento sta lontana da tutte e due.
      final ba = await fotografa(tester, 0.0);
      final bb = await fotografa(tester, 0.25 / TunnelCheScende.quantiGiri);
      final larghezza = corpoVero.width.toInt();
      final centro = Offset(corpoVero.width / 2, corpoVero.height / 2);
      final raggioDellaLuce = corpoVero.shortestSide / 2;
      var guardati = 0;
      var diversi = 0;
      for (var i = 0; i < ba.length; i += 4) {
        final p = i ~/ 4;
        final punto = Offset((p % larghezza) + 0.5, (p ~/ larghezza) + 0.5);
        if ((punto - centro).distance < raggioDellaLuce) continue;
        guardati++;
        final scarto = (ba[i] - bb[i]).abs() +
            (ba[i + 1] - bb[i + 1]).abs() +
            (ba[i + 2] - bb[i + 2]).abs();
        if (scarto > 30) diversi++;
      }
      cardinaleMinimo(guardati, 100000,
          cosa: 'pixel della parete fuori dal cerchio della luce',
          perche: 'Nella finestra vera la parete fuori dalla luce e oltre la '
              'meta dei pixel: se ne restano pochi, la finestra non e quella '
              'del telefono.');
      final quota = diversi / guardati;
      // ignore: avoid_print
      print('ORDINE DC VOCE 07: in un quarto di piastrella cambia il '
          '${(quota * 100).toStringAsFixed(1)} per cento della parete');
      expect(quota, greaterThan(0.10),
          reason: 'in un quarto di piastrella cambia solo il '
              '${(quota * 100).toStringAsFixed(1)} per cento della parete: '
              'chi tiene il dito premuto non vede nessuna distanza percorsa');
    });
  });

  group('DG.02, l ombra del suo animale', () {
    /// La scena del ritorno: il riquadro dell'animale, non la finestra intera.
    const scenaDelRitorno = Size(390, 289);

    /// **QUANTO RIEMPIE LA SAGOMA DIPINTA**, cioe' il maggiore fra la sua
    /// altezza e la sua larghezza, in frazione della scena.
    ///
    /// **Perche' il maggiore delle due e non l'altezza.** La scena del ritorno
    /// e' larga, 390 per 289, e i dodici hanno forme diverse: con
    /// `BoxFit.contain` la volpe, che e' 894 per 575, riempie la larghezza e
    /// resta bassa; il gufo, che e' 537 per 865, fa il contrario. Misurata
    /// sull'altezza, la stessa figura grande dava 74 per cento su un animale
    /// e 21 su un altro, e il numero parlava della forma del file, non di
    /// quanto si vede.
    ///
    /// Si rasterizza il widget vero con l'immagine vera dentro: e' la Regola
    /// I, pixel dipinti in una finestra vera.
    Future<double> quantoRiempie(WidgetTester tester, String immagine,
        {required double luce}) async {
      await tester.binding.setSurfaceSize(scenaDelRitorno);
      late Uint8List byte;
      late int larga;
      await tester.runAsync(() async {
        await tester.pumpWidget(MaterialApp(
          home: RepaintBoundary(
            key: const Key('foglio'),
            child: SizedBox(
              width: scenaDelRitorno.width,
              height: scenaDelRitorno.height,
              child: OmbraDellAnimale(
                immagine: immagine,
                giaSagoma: true,
                quantaLuce: luce,
              ),
            ),
          ),
        ));
        await precacheImage(
            AssetImage(immagine), tester.element(find.byType(SizedBox).first));
        await tester.pump(const Duration(milliseconds: 400));
        final foglio = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const Key('foglio')));
        final img = await foglio.toImage();
        larga = img.width;
        byte = (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!
            .buffer
            .asUint8List();
      });
      // **LA SAGOMA E' PIU' SCURA DEL FONDO SU CUI STA**, e non si riconosce
      // dall'alfa: e' la lezione del 10 settembre 2026, quando una sagoma nera
      // su un blu quasi nero passava la prova e a schermo non si vedeva.
      var alto = -1;
      var basso = -1;
      var sinistra = larga;
      var destra = -1;
      for (var y = 0; y < scenaDelRitorno.height.toInt(); y++) {
        for (var x = 0; x < larga; x++) {
          final i = (y * larga + x) * 4;
          if (i + 3 >= byte.length) continue;
          final somma = byte[i] + byte[i + 1] + byte[i + 2];
          // **CENTOCINQUANTA E NON SESSANTA.** Sessanta prendeva solo il
          // nero pieno, ed era la misura giusta per il pittore procedurale
          // che dipingeva nero su nero. L'ombra vera e' **sfocata** di nove
          // punti di sigma, ed e' voluto: i suoi bordi sono grigi, e su una
          // sagoma sottile come il serpente il cuore nero e' una striscia.
          // Misurata a sessanta, la stessa figura che riempie l'ottanta per
          // cento della sua tela risultava al trenta.
          if (byte[i + 3] > 200 && somma < 150) {
            if (alto < 0) alto = y;
            basso = y;
            if (x < sinistra) sinistra = x;
            if (x > destra) destra = x;
          }
        }
      }
      await tester.binding.setSurfaceSize(null);
      if (alto < 0) return 0;
      final quantoAlta = (basso - alto + 1) / scenaDelRitorno.height;
      final quantoLarga = (destra - sinistra + 1) / scenaDelRitorno.width;
      return quantoAlta > quantoLarga ? quantoAlta : quantoLarga;
    }

    testWidgets('IN PIENA LUCE RIEMPIE ALMENO IL 60 PER CENTO DELLA SCENA',
        (tester) async {
      // **RISCRITTA DALL'ORDINE DG VOCE 02.** Prima misurava
      // `PittoreDellAnimale`, il disegno procedurale che l'ordine ha mandato
      // via: faceva sempre un quadrupede, e aquila, corvo, falco, gufo e
      // serpente non lo sono.
      final lupo = AnimalCatalog.animals.firstWhere((a) => a.name == 'Lupo');
      final quota = await quantoRiempie(tester, lupo.ombraPath, luce: 1.0);
      // ignore: avoid_print
      print('ORDINE DG VOCE 02: l ombra del Lupo riempie '
          '${(quota * 100).toStringAsFixed(1)} per cento del lato che occupa');
      expect(quota, greaterThanOrEqualTo(0.60),
          reason: 'l ombra riempie solo il '
              '${(quota * 100).toStringAsFixed(1)} per cento: e la figura '
              'piccola circondata da spazio vuoto che il fondatore ha gia '
              'respinto una volta');
    });

    testWidgets('DODICI ANIMALI, DODICI SAGOME, e nessuna vuota',
        (tester) async {
      // **LA SECONDA META', e senza di lei la prima non direbbe niente**: se
      // il file non si caricasse, l'altezza sarebbe zero e la prova sopra
      // cadrebbe; se fosse un rettangolo pieno, sarebbe cento e passerebbe.
      final alte = <String, double>{};
      for (final a in AnimalCatalog.animals) {
        alte[a.name] = await quantoRiempie(tester, a.ombraPath, luce: 1.0);
      }
      // ignore: avoid_print
      print('ORDINE DG VOCE 02: dodici ombre riempiono da '
          '${(alte.values.reduce((x, y) => x < y ? x : y) * 100).toStringAsFixed(0)} '
          'a ${(alte.values.reduce((x, y) => x > y ? x : y) * 100).toStringAsFixed(0)} '
          'per cento');
      // **QUARANTA QUI, SESSANTA SUL CASO DI RIFERIMENTO, e la differenza
      // ha una ragione misurata.** La sfocatura dell'ombra e' proporzionale
      // al lato corto della scena e **mangia piu' bordo alle sagome
      // sottili**: il serpente e il cervo perdono piu' del lupo. Pretendere
      // da tutti e dodici il numero del Lupo vorrebbe dire pretendere che
      // dodici animali abbiano la stessa forma.
      //
      // Cio' che questa prova difende e' che **nessuno dei dodici sia un
      // francobollo perso nel vuoto**: quaranta per cento di 289 punti fanno
      // centosedici punti di figura.
      for (final e in alte.entries) {
        expect(e.value, greaterThan(0.40),
            reason: '${e.key}: la sua ombra riempie solo il '
                '${(e.value * 100).toStringAsFixed(0)} per cento, ed e la '
                'figura piccola persa nel vuoto');
        expect(e.value, lessThan(1.0),
            reason: '${e.key}: la sua ombra riempie tutta la scena, cioe e un '
                'rettangolo e non una sagoma');
      }
    });
  });

  group('DG.05, la nebbia che si dirada col dito', () {
    test('PIU LA MANO PASSA, PIU LA NEBBIA SI ALZA', () async {
      // **RISCRITTA DALL'ORDINE DG VOCE 05.** Le tre prove di prima
      // misuravano i **varchi**: erano la prova che i tre tocchi
      // funzionassero, cioe' difendevano il difetto che il fondatore ha
      // segnalato, *"per diradare la nebbia devo fare 3 tap"*.
      final chiusa = dipingi(
          PittoreDellaNebbia(apertura: 0, senzaMoto: false, densita: 1.0));
      final mezza = dipingi(
          PittoreDellaNebbia(apertura: 0.5, senzaMoto: false, densita: 1.0));
      final aperta = dipingi(
          PittoreDellaNebbia(apertura: 1, senzaMoto: false, densita: 1.0));
      Future<double> chiarore(ui.Image img) async {
        final dati = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
        final b = dati!.buffer.asUint8List();
        var somma = 0;
        for (var i = 0; i < b.length; i += 4) {
          somma += b[i] + b[i + 1] + b[i + 2];
        }
        return somma / (b.length / 4) / 3;
      }

      final c0 = await chiarore(chiusa);
      final c5 = await chiarore(mezza);
      final c1 = await chiarore(aperta);
      // ignore: avoid_print
      print('ORDINE DG VOCE 05: chiarore medio a nebbia chiusa '
          '${c0.toStringAsFixed(1)}, a meta ${c5.toStringAsFixed(1)}, '
          'aperta ${c1.toStringAsFixed(1)}');
      expect(c5, lessThan(c0),
          reason: 'a meta strada la nebbia copre quanto all inizio: il dito '
              'non sta diradando niente');
      expect(c1, lessThan(c5),
          reason: 'alla fine la nebbia copre quanto a meta strada');
    });

    test('IL RESPIRO SALE COL MOVIMENTO E SCENDE SE IL DITO SI FERMA', () {
      // **LA TARATURA E' QUELLA DEL SIGILLO DEL SOGNO**, e vive in un posto
      // solo: `RespiroCheDirada`. Due copie si sarebbero separate alla prima
      // ritoccata, e allora una nebbia si diraderebbe in un modo e l altra in
      // un altro.
      var apertura = 0.0;
      var spinta = 0.0;
      // Il dito si muove: in un secondo circa la nebbia si apre.
      var passi = 0;
      while (apertura < 1 && passi < 200) {
        spinta = RespiroCheDirada.spintaDopo(spinta, 30);
        final (a, s2) = RespiroCheDirada.unPasso(apertura, spinta);
        apertura = a;
        spinta = s2;
        passi++;
      }
      // ignore: avoid_print
      print('ORDINE DG VOCE 05: con la mano che si muove la nebbia si apre in '
          '$passi passi da ${RespiroCheDirada.passo.inMilliseconds} ms, cioe '
          '${(passi * RespiroCheDirada.passo.inMilliseconds / 1000).toStringAsFixed(1)} '
          'secondi');
      expect(apertura, 1.0, reason: 'la mano non arriva mai ad aprirla');
      expect(passi, lessThan(100),
          reason: 'ci vogliono piu di sei secondi di movimento continuo');

      // E se il dito si ferma, la nebbia torna piano.
      var ferma = 0.5;
      var senza = 0.0;
      for (var i = 0; i < 10; i++) {
        final (a, s3) = RespiroCheDirada.unPasso(ferma, senza);
        ferma = a;
        senza = s3;
      }
      expect(ferma, lessThan(0.5),
          reason: 'a dito fermo la nebbia resta aperta: il gesto varrebbe una '
              'volta sola');
    });
  });
}
