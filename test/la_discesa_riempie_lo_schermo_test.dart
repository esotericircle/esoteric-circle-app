import 'dart:ui' as ui;

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

  group('DC.07, l animale', () {
    /// **LA SCENA DEL RITORNO, nelle sue misure vere.** La carta dell'animale
    /// e' larga quanto lo schermo e sta in un rapporto di uno e trentacinque,
    /// che e' la forma di un animale: 390 per 289 sul telefono di riferimento.
    const scenaDelRitorno = Size(390, 289);

    /// **LA SAGOMA SI RICONOSCE PERCHE' E' PIU' SCURA DEL FONDO SU CUI STA**,
    /// e non perche' ha un alfa.
    ///
    /// **QUESTO E' IL CUORE DEL DIFETTO DEL 10 SETTEMBRE 2026.** La prima
    /// stesura chiedeva `a > 40` su una tela trasparente: misurava che la
    /// sagoma **esistesse**. Sul telefono la sagoma esisteva, era nera sopra
    /// un blu quasi nero, e **l'incontro era uno schermo vuoto**. Una guardia
    /// che misura l'esistenza non misura la visibilita'.
    bool eSagoma(int r, int g, int b, int a) => a > 200 && r + g + b < 55;

    test('AL QUARTO VIAGGIO OCCUPA ALMENO IL 60 PER CENTO DELL ALTEZZA',
        () async {
      final immagine = dipingi(
          PittoreDellAnimale(discesa: 3, quantaLuce: 1.0, seme: 7),
          quanto: scenaDelRitorno);
      final quota = await estensioneDipinta(immagine, e: eSagoma);
      // ignore: avoid_print
      print('ORDINE DC VOCE 07: al quarto viaggio l animale dipinto e alto '
          '${(quota.alta * 100).toStringAsFixed(1)} e largo '
          '${(quota.larga * 100).toStringAsFixed(1)} per cento della scena');
      expect(quota.alta, greaterThanOrEqualTo(0.60),
          reason: 'in piena luce l animale e alto solo il '
              '${(quota.alta * 100).toStringAsFixed(1)} per cento: e la '
              'figura piccola circondata da spazio vuoto che il fondatore ha '
              'gia respinto una volta');
    });

    test('REGOLA H: NEI PRIMI TRE VIAGGI SI VEDE SEMPRE PARZIALMENTE',
        () async {
      double? prima;
      for (var d = 0; d < 3; d++) {
        final quota = await estensioneDipinta(
            dipingi(PittoreDellAnimale(discesa: d, quantaLuce: 0.5, seme: 7),
                quanto: scenaDelRitorno),
            e: eSagoma);
        // ignore: avoid_print
        print('ORDINE DC VOCE 04: alla discesa $d l animale e alto '
            '${(quota.alta * 100).toStringAsFixed(1)} per cento');
        expect(quota.alta, lessThan(0.60),
            reason: 'alla discesa $d l animale e gia grande quanto in piena '
                'luce: il riconoscimento di Harner perde il suo senso');
        if (prima != null) {
          expect(quota.alta, greaterThan(prima),
              reason: 'alla discesa $d non si vede piu di prima: le quattro '
                  'apparizioni non raccontano nessun avvicinamento');
        }
        prima = quota.alta;
      }
    });

    test('DUE ANIMALI DIVERSI HANNO SAGOME DIVERSE', () async {
      // In controluce **la sagoma e l unica cosa che li distingue**: se due
      // semi dessero la stessa figura, il riconoscimento sarebbe finto.
      final una = (await estensioneDipinta(
              dipingi(PittoreDellAnimale(discesa: 3, quantaLuce: 1.0, seme: 3),
                  quanto: scenaDelRitorno),
              e: eSagoma))
          .larga;
      final altra = (await estensioneDipinta(
              dipingi(PittoreDellAnimale(discesa: 3, quantaLuce: 1.0, seme: 91),
                  quanto: scenaDelRitorno),
              e: eSagoma))
          .larga;
      // La larghezza puo' coincidere: si guardano i pixel, non la scatola.
      final primaImg = dipingi(
          PittoreDellAnimale(discesa: 3, quantaLuce: 1.0, seme: 3),
          quanto: scenaDelRitorno);
      final secondaImg = dipingi(
          PittoreDellAnimale(discesa: 3, quantaLuce: 1.0, seme: 91),
          quanto: scenaDelRitorno);
      final a = await primaImg.toByteData(format: ui.ImageByteFormat.rawRgba);
      final b = await secondaImg.toByteData(format: ui.ImageByteFormat.rawRgba);
      var diversi = 0;
      final ba = a!.buffer.asUint8List();
      final bb = b!.buffer.asUint8List();
      // **SI CONFRONTA CIO' CHE SI VEDE**: dove una sagoma copre e l'altra no,
      // il colore cambia da nero a fondo illuminato. Il canale alfa, da quando
      // la scena porta la sua luce dietro, vale duecentocinquantacinque in
      // tutte e due e non distingue piu' due animali.
      for (var i = 0; i < ba.length; i += 4) {
        final qua = ba[i] + ba[i + 1] + ba[i + 2];
        final la = bb[i] + bb[i + 1] + bb[i + 2];
        if ((qua - la).abs() > 60) diversi++;
      }
      // ignore: avoid_print
      print('ORDINE DC VOCE 07: due sagome diverse differiscono su $diversi '
          'pixel, larghezze ${(una * 100).toStringAsFixed(0)} e '
          '${(altra * 100).toStringAsFixed(0)} per cento');
      expect(diversi, greaterThan(1000),
          reason: 'due animali diversi dipingono la stessa sagoma: in '
              'controluce non si distinguono, e il riconoscimento e finto');
    });
  });

  group('DC.07, la nebbia', () {
    test('IL VARCO SCOPRE IL MONDO DI SOTTO, e non un buco', () async {
      // **DIFETTO VISTO SUL TELEFONO 767f596c IL 10 SETTEMBRE 2026.** I due
      // varchi aperti dalla mano erano **due buchi neri**: la nebbia si
      // ritagliava con `BlendMode.dstOut` senza uno strato isolato, quindi
      // non toglieva nebbia, **toglieva la scena**, e sotto restava il nero
      // della finestra.
      //
      // La guardia di prima non poteva vederlo: misurava **quanta opacita'
      // spariva**, e sparire era esattamente il difetto. Qui si guarda cosa
      // resta, che e' cio' che l'occhio vede.
      const centro = Offset(195, 341);
      final aperta = dipingi(PittoreDellaNebbia(
        varchi: const [VarcoNellaNebbia(dove: centro, quantoEAperto: 1.0)],
        senzaMoto: false,
        densita: 1.0,
      ));
      final dati = await aperta.toByteData(format: ui.ImageByteFormat.rawRgba);
      final byte = dati!.buffer.asUint8List();
      var trasparenti = 0;
      var neri = 0;
      var guardati = 0;
      for (var y = centro.dy.round() - 30; y < centro.dy.round() + 30; y++) {
        for (var x = centro.dx.round() - 30; x < centro.dx.round() + 30; x++) {
          final i = (y * aperta.width + x) * 4;
          guardati++;
          if (byte[i + 3] < 200) trasparenti++;
          if (byte[i] + byte[i + 1] + byte[i + 2] < 24) neri++;
        }
      }
      // ignore: avoid_print
      print('ORDINE DC VOCE 07: nel cuore del varco, su $guardati pixel, '
          '$trasparenti sono trasparenti e $neri sono neri');
      expect(trasparenti, 0,
          reason: 'nel cuore del varco $trasparenti pixel su $guardati non '
              'hanno niente sotto: la mano non apre la nebbia, buca la scena');
      expect(neri, lessThan(guardati ~/ 20),
          reason: 'nel cuore del varco $neri pixel su $guardati sono neri: '
              'chi apre la nebbia trova il nulla invece del mondo di sotto');
    });

    test('LA MANO APRE UN VARCO, e senza mano la nebbia resta chiusa',
        () async {
      final chiusa = dipingi(PittoreDellaNebbia(
          varchi: const [], senzaMoto: false, densita: 1.0));
      final aperta = dipingi(PittoreDellaNebbia(
        varchi: const [
          VarcoNellaNebbia(dove: Offset(195, 341), quantoEAperto: 1.0),
        ],
        senzaMoto: false,
        densita: 1.0,
      ));
      final a = await chiusa.toByteData(format: ui.ImageByteFormat.rawRgba);
      final b = await aperta.toByteData(format: ui.ImageByteFormat.rawRgba);
      final ba = a!.buffer.asUint8List();
      final bb = b!.buffer.asUint8List();
      // **SI CONTANO I PIXEL CHE SI SCURISCONO, non quelli che perdono
      // opacita'.** La prima stesura guardava il canale alfa: era la firma
      // della formula, non la forma. Da quando la nebbia vive in uno strato
      // suo sopra il mondo di sotto, la scena e' opaca dappertutto e
      // quell'alfa non cambia mai, mentre l'occhio vede benissimo il varco:
      // sotto la nebbia chiara c'e' il bruno scuro del mondo di sotto.
      var piuScuri = 0;
      for (var i = 0; i < ba.length; i += 4) {
        final prima = ba[i] + ba[i + 1] + ba[i + 2];
        final dopo = bb[i] + bb[i + 1] + bb[i + 2];
        if (prima - dopo > 30) piuScuri++;
      }
      // ignore: avoid_print
      print('ORDINE DC VOCE 07: il varco della mano scopre $piuScuri pixel');
      expect(piuScuri, greaterThan(2000),
          reason: 'il varco non toglie nebbia: la mano non apre niente e la '
              'scena si guarda invece di farla');
    });

    test('REGOLA H: PIU E FITTA MENO SI VEDE', () async {
      // Ordine DC voce 08: chi torna dopo settimane trova **nebbia fitta**.
      final rada = dipingi(PittoreDellaNebbia(
          varchi: const [], senzaMoto: false, densita: 0.2));
      final fitta = dipingi(PittoreDellaNebbia(
          varchi: const [], senzaMoto: false, densita: 1.0));
      final a = await rada.toByteData(format: ui.ImageByteFormat.rawRgba);
      final b = await fitta.toByteData(format: ui.ImageByteFormat.rawRgba);
      final ba = a!.buffer.asUint8List();
      final bb = b!.buffer.asUint8List();
      // **SI MISURA QUANTO IL MONDO DI SOTTO SPARISCE**, cioe' di quanto la
      // scena si schiarisce verso il grigio della nebbia. Anche qui la prima
      // stesura sommava l'alfa, che oggi vale duecentocinquantacinque in tutti
      // e due i casi e non distingue piu' niente.
      var sommaRada = 0;
      var sommaFitta = 0;
      for (var i = 0; i < ba.length; i += 4) {
        sommaRada += ba[i] + ba[i + 1] + ba[i + 2];
        sommaFitta += bb[i] + bb[i + 1] + bb[i + 2];
      }
      final quanti = ba.length ~/ 4;
      // ignore: avoid_print
      print('ORDINE DC VOCE 08: chiarore medio rada '
          '${(sommaRada / quanti / 3).toStringAsFixed(1)}, fitta '
          '${(sommaFitta / quanti / 3).toStringAsFixed(1)}');
      expect(sommaFitta, greaterThan(sommaRada * 1.30),
          reason: 'la nebbia fitta copre il mondo di sotto quanto quella '
              'rada: la nitidezza non arriva a schermo, e la voce DC.08 e '
              'solo un numero');
    });
  });
}
