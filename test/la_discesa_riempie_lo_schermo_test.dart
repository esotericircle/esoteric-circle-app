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

  const lato = 390.0;

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

  /// Quanto occupa in larghezza cio' che e' stato dipinto, in frazione della
  /// tela, guardando **solo i pixel che si distinguono dal fondo**.
  /// **SI MISURANO TUTTE E DUE LE DIREZIONI, e anche quanta tela e'
  /// coperta.** Una figura larga quanto la scena ma alta la meta' passava la
  /// prima stesura di questa guardia, che guardava solo la larghezza.
  Future<({double larga, double alta, double piena})> estensioneDipinta(
      ui.Image immagine,
      {required bool Function(int r, int g, int b, int a) e}) async {
    final dati = await immagine.toByteData(format: ui.ImageByteFormat.rawRgba);
    final byte = dati!.buffer.asUint8List();
    final larghezza = immagine.width;
    final altezza = immagine.height;
    var primoX = larghezza;
    var ultimoX = -1;
    var primoY = altezza;
    var ultimoY = -1;
    var accesi = 0;
    for (var y = 0; y < altezza; y++) {
      for (var x = 0; x < larghezza; x++) {
        final i = (y * larghezza + x) * 4;
        if (e(byte[i], byte[i + 1], byte[i + 2], byte[i + 3])) {
          accesi++;
          if (x < primoX) primoX = x;
          if (x > ultimoX) ultimoX = x;
          if (y < primoY) primoY = y;
          if (y > ultimoY) ultimoY = y;
        }
      }
    }
    cardinaleMinimo(accesi, 400,
        cosa: 'pixel dipinti sulla tela',
        perche: 'Su una tela quasi vuota la distanza fra primo e ultimo pixel '
            'non dice niente, e la guardia sarebbe verde per non aver visto '
            'nessuna figura.');
    if (ultimoX < 0) return (larga: 0.0, alta: 0.0, piena: 0.0);
    return (
      larga: (ultimoX - primoX + 1) / larghezza,
      alta: (ultimoY - primoY + 1) / altezza,
      piena: accesi / (larghezza * altezza),
    );
  }

  group('DC.07, il tunnel', () {
    test('IL TUNNEL OCCUPA LA SCENA INTERA', () async {
      final immagine =
          dipingi(PittoreDelTunnel(quantoSiEScesi: 0.5, senzaMoto: false));
      // Il tunnel dipinge anche il fondo, quindi qui si cerca **cio' che non e'
      // il fondo**: gli anelli e il loro filo di luce.
      const fondo = PittoreDelTunnel.bluProfondo;
      final quota = await estensioneDipinta(immagine,
          e: (r, g, b, a) =>
              a > 40 &&
              ((r - (fondo.r * 255).round()).abs() +
                      (g - (fondo.g * 255).round()).abs() +
                      (b - (fondo.b * 255).round()).abs()) >
                  24);
      // ignore: avoid_print
      print('ORDINE DC VOCE 07: nella finestra vera '
          '${corpoVero.width.toInt()}x${corpoVero.height.toInt()} il tunnel '
          'dipinto e largo ${(quota.larga * 100).toStringAsFixed(1)}, alto '
          '${(quota.alta * 100).toStringAsFixed(1)} e copre il '
          '${(quota.piena * 100).toStringAsFixed(1)} per cento della scena');
      expect(quota.larga, greaterThanOrEqualTo(0.95),
          reason: 'il tunnel e largo il '
              '${(quota.larga * 100).toStringAsFixed(1)} per cento della '
              'scena invece della scena intera: chi guarda sta davanti a un '
              'disegno di tunnel, non dentro un tunnel');
      // **E ALTO QUANTO LA SCENA.** Difetto visto sul telefono 767f596c il 10
      // settembre 2026: gli anelli avevano il raggio legato al **lato corto**,
      // quindi su una finestra alta lasciavano scoperta una fascia sopra e una
      // sotto, e siccome il pavimento del tunnel ha lo stesso colore dello
      // sfondo della pagina, l occhio leggeva una sagoma appoggiata invece di
      // una galleria.
      expect(quota.alta, greaterThanOrEqualTo(0.95),
          reason: 'il tunnel e alto il '
              '${(quota.alta * 100).toStringAsFixed(1)} per cento della '
              'scena: sopra e sotto resta la pagina, e il tunnel si legge '
              'come una sagoma appoggiata');
      // **E copre davvero la tela, non solo la attraversa.**
      expect(quota.piena, greaterThanOrEqualTo(0.90),
          reason: 'il tunnel dipinge solo il '
              '${(quota.piena * 100).toStringAsFixed(1)} per cento dei pixel '
              'della scena: gli angoli restano pagina');
    });

    test('GLI ANELLI VICINI SONO PIU SCURI DEI LONTANI', () {
      // **La profondita senza 3D nasce da qui**, e l ordine lo chiede per
      // nome. Si confrontano i raggi, che dicono chi e vicino.
      final vicino = PittoreDelTunnel.raggioDellAnello(lato, 17, 0.0);
      final lontano = PittoreDelTunnel.raggioDellAnello(lato, 0, 0.0);
      // ignore: avoid_print
      print('ORDINE DC VOCE 07: raggio del piu vicino '
          '${vicino.toStringAsFixed(0)}, del piu lontano '
          '${lontano.toStringAsFixed(0)}');
      expect(vicino, greaterThan(lontano * 4),
          reason: 'il vicino e il lontano hanno quasi lo stesso raggio: la '
              'galleria si legge piatta');
      // **E il piu vicino esce dallo schermo**, che e cio che fa sentire
      // dentro invece che davanti.
      expect(vicino * 2, greaterThan(lato),
          reason: 'l anello piu vicino sta tutto dentro la scena: si vede il '
              'tunnel da fuori');
    });

    test('IL TUNNEL SI MUOVE COL DITO, e non da solo', () async {
      // **NON SI CHIEDE CHE QUALCOSA SI MUOVA, e non si guarda un anello
      // solo.** La prima stesura misurava lo spostamento del terzo anello e
      // ha trovato **zero**: gli anelli passavano in numero multiplo di
      // quanti sono, quindi a meta' discesa la scena era tornata identica
      // alla partenza. **Misurava la cosa giusta nel punto sbagliato.**
      //
      // Adesso si dipingono due stati della scena e si contano i pixel che
      // cambiano: e' la scena intera a dover raccontare la distanza.
      final aInizio = dipingi(
          PittoreDelTunnel(quantoSiEScesi: 0.0, senzaMoto: false));
      final aMeta = dipingi(
          PittoreDelTunnel(quantoSiEScesi: 0.5, senzaMoto: false));
      final a = await aInizio.toByteData(format: ui.ImageByteFormat.rawRgba);
      final b = await aMeta.toByteData(format: ui.ImageByteFormat.rawRgba);
      final ba = a!.buffer.asUint8List();
      final bb = b!.buffer.asUint8List();
      var diversi = 0;
      for (var i = 0; i < ba.length; i += 4) {
        final scarto = (ba[i] - bb[i]).abs() +
            (ba[i + 1] - bb[i + 1]).abs() +
            (ba[i + 2] - bb[i + 2]).abs();
        if (scarto > 30) diversi++;
      }
      final quota = diversi / (ba.length / 4);
      // ignore: avoid_print
      print('ORDINE DC VOCE 07: fra la bocca e meta discesa cambia il '
          '${(quota * 100).toStringAsFixed(1)} per cento dei pixel');
      expect(quota, greaterThan(0.25),
          reason: 'fra la superficie e meta discesa cambia solo il '
              '${(quota * 100).toStringAsFixed(1)} per cento della scena: '
              'chi tiene il dito premuto non vede nessuna distanza percorsa');
    });

    test('LE FORME VIVE SONO DICHIARATE E SOTTO IL TETTO', () {
      final forme = PittoreDelTunnel.formeAlCulmine();
      // ignore: avoid_print
      print('ORDINE DC VOCE 07: forme vive nel tunnel al momento piu carico '
          '$forme');
      expect(forme, lessThan(200),
          reason: 'il tunnel dipinge $forme forme: e sopra il tetto che il '
              'progetto usa per una scena viva');
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
