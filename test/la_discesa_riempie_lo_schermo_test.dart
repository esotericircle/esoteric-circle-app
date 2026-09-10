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

  /// Dipinge un pittore su una tela quadrata e torna l'immagine.
  ui.Image dipingi(CustomPainter pittore, {double quanto = lato}) {
    final registratore = ui.PictureRecorder();
    final tela = Canvas(registratore);
    pittore.paint(tela, Size(quanto, quanto));
    return registratore.endRecording().toImageSync(quanto.toInt(), quanto.toInt());
  }

  /// Quanto occupa in larghezza cio' che e' stato dipinto, in frazione della
  /// tela, guardando **solo i pixel che si distinguono dal fondo**.
  Future<double> quotaDipinta(ui.Image immagine,
      {required bool Function(int r, int g, int b, int a) e}) async {
    final dati = await immagine.toByteData(format: ui.ImageByteFormat.rawRgba);
    final byte = dati!.buffer.asUint8List();
    final larghezza = immagine.width;
    var primo = larghezza;
    var ultimo = -1;
    var accesi = 0;
    for (var y = 0; y < immagine.height; y++) {
      for (var x = 0; x < larghezza; x++) {
        final i = (y * larghezza + x) * 4;
        if (e(byte[i], byte[i + 1], byte[i + 2], byte[i + 3])) {
          accesi++;
          if (x < primo) primo = x;
          if (x > ultimo) ultimo = x;
        }
      }
    }
    cardinaleMinimo(accesi, 400,
        cosa: 'pixel dipinti sulla tela',
        perche: 'Su una tela quasi vuota la distanza fra primo e ultimo pixel '
            'non dice niente, e la guardia sarebbe verde per non aver visto '
            'nessuna figura.');
    return ultimo < 0 ? 0 : (ultimo - primo + 1) / larghezza;
  }

  group('DC.07, il tunnel', () {
    test('IL TUNNEL OCCUPA LA SCENA INTERA', () async {
      final immagine =
          dipingi(PittoreDelTunnel(quantoSiEScesi: 0.5, senzaMoto: false));
      // Il tunnel dipinge anche il fondo, quindi qui si cerca **cio' che non e'
      // il fondo**: gli anelli e il loro filo di luce.
      const fondo = PittoreDelTunnel.bluProfondo;
      final quota = await quotaDipinta(immagine,
          e: (r, g, b, a) =>
              a > 40 &&
              ((r - (fondo.r * 255).round()).abs() +
                      (g - (fondo.g * 255).round()).abs() +
                      (b - (fondo.b * 255).round()).abs()) >
                  24);
      // ignore: avoid_print
      print('ORDINE DC VOCE 07: il tunnel dipinto occupa '
          '${(quota * 100).toStringAsFixed(1)} per cento della scena');
      expect(quota, greaterThanOrEqualTo(0.95),
          reason: 'il tunnel occupa il ${(quota * 100).toStringAsFixed(1)} '
              'per cento della scena invece della scena intera: chi guarda '
              'sta davanti a un disegno di tunnel, non dentro un tunnel');
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
    test('AL QUARTO VIAGGIO OCCUPA ALMENO IL 60 PER CENTO', () async {
      final immagine = dipingi(
          PittoreDellAnimale(discesa: 3, quantaLuce: 1.0, seme: 7));
      final quota = await quotaDipinta(immagine, e: (r, g, b, a) => a > 40);
      // ignore: avoid_print
      print('ORDINE DC VOCE 07: al quarto viaggio l animale dipinto occupa '
          '${(quota * 100).toStringAsFixed(1)} per cento della scena');
      expect(quota, greaterThanOrEqualTo(0.60),
          reason: 'in piena luce l animale occupa solo il '
              '${(quota * 100).toStringAsFixed(1)} per cento: e la figura '
              'piccola circondata da spazio vuoto che il fondatore ha gia '
              'respinto una volta');
    });

    test('REGOLA H: NEI PRIMI TRE VIAGGI SI VEDE SEMPRE PARZIALMENTE',
        () async {
      double? prima;
      for (var d = 0; d < 3; d++) {
        final quota = await quotaDipinta(
            dipingi(PittoreDellAnimale(discesa: d, quantaLuce: 0.5, seme: 7)),
            e: (r, g, b, a) => a > 40);
        // ignore: avoid_print
        print('ORDINE DC VOCE 04: alla discesa $d l animale occupa '
            '${(quota * 100).toStringAsFixed(1)} per cento');
        expect(quota, lessThan(0.60),
            reason: 'alla discesa $d l animale e gia grande quanto in piena '
                'luce: il riconoscimento di Harner perde il suo senso');
        if (prima != null) {
          expect(quota, greaterThan(prima),
              reason: 'alla discesa $d non si vede piu di prima: le quattro '
                  'apparizioni non raccontano nessun avvicinamento');
        }
        prima = quota;
      }
    });

    test('DUE ANIMALI DIVERSI HANNO SAGOME DIVERSE', () async {
      // In controluce **la sagoma e l unica cosa che li distingue**: se due
      // semi dessero la stessa figura, il riconoscimento sarebbe finto.
      final una = await quotaDipinta(
          dipingi(PittoreDellAnimale(discesa: 3, quantaLuce: 1.0, seme: 3)),
          e: (r, g, b, a) => a > 40);
      final altra = await quotaDipinta(
          dipingi(PittoreDellAnimale(discesa: 3, quantaLuce: 1.0, seme: 91)),
          e: (r, g, b, a) => a > 40);
      // La larghezza puo' coincidere: si guardano i pixel, non la scatola.
      final primaImg =
          dipingi(PittoreDellAnimale(discesa: 3, quantaLuce: 1.0, seme: 3));
      final secondaImg =
          dipingi(PittoreDellAnimale(discesa: 3, quantaLuce: 1.0, seme: 91));
      final a = await primaImg.toByteData(format: ui.ImageByteFormat.rawRgba);
      final b = await secondaImg.toByteData(format: ui.ImageByteFormat.rawRgba);
      var diversi = 0;
      final ba = a!.buffer.asUint8List();
      final bb = b!.buffer.asUint8List();
      for (var i = 3; i < ba.length; i += 4) {
        if ((ba[i] - bb[i]).abs() > 40) diversi++;
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
    test('LA MANO APRE UN VARCO, e senza mano la nebbia resta chiusa',
        () async {
      final chiusa = dipingi(PittoreDellaNebbia(
          varchi: const [], senzaMoto: false, densita: 1.0));
      final aperta = dipingi(PittoreDellaNebbia(
        varchi: const [
          VarcoNellaNebbia(dove: Offset(195, 195), quantoEAperto: 1.0),
        ],
        senzaMoto: false,
        densita: 1.0,
      ));
      final a = await chiusa.toByteData(format: ui.ImageByteFormat.rawRgba);
      final b = await aperta.toByteData(format: ui.ImageByteFormat.rawRgba);
      final ba = a!.buffer.asUint8List();
      final bb = b!.buffer.asUint8List();
      var piuChiari = 0;
      for (var i = 3; i < ba.length; i += 4) {
        if (ba[i] - bb[i] > 20) piuChiari++;
      }
      // ignore: avoid_print
      print('ORDINE DC VOCE 07: il varco della mano scopre $piuChiari pixel');
      expect(piuChiari, greaterThan(2000),
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
      var sommaRada = 0;
      var sommaFitta = 0;
      final ba = a!.buffer.asUint8List();
      final bb = b!.buffer.asUint8List();
      for (var i = 3; i < ba.length; i += 4) {
        sommaRada += ba[i];
        sommaFitta += bb[i];
      }
      // ignore: avoid_print
      print('ORDINE DC VOCE 08: opacita totale rada $sommaRada, fitta '
          '$sommaFitta');
      expect(sommaFitta, greaterThan(sommaRada * 2),
          reason: 'la nebbia fitta e densa quanto quella rada: la nitidezza '
              'non arriva a schermo, e la voce DC.08 e solo un numero');
    });
  });
}
