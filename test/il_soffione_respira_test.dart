// ignore_for_file: avoid_print
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/rituals/breath_destiny_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// **A RESPIRARE E' IL SOFFIONE, NON UN CERCHIO SOPRA DI LUI.** Ordine EE
/// voce 02, 23 settembre 2026.
///
/// **Il fatto del fondatore, verbatim**: *"avevo gia' chiesto di non fare
/// vedere un Cerchio sovrapposto che si allarga e si riduce per simulare il
/// respiro, ma deve essere il soffione sotto ad allargarsi e ridursi"*.
///
/// **QUESTA PROVA PRENDE IL POSTO DI `il_cerchio_del_soffio_riempie_la_scena`,
/// e non la spegne: le cambia il soggetto.** Quella guardia nasce dall'ordine
/// DD voce 03, che pretendeva che il cerchio occupasse almeno il settanta per
/// cento della larghezza. **La misura era giusta, il soggetto no**: adesso
/// quella quota la deve prendere il soffione, che e' cio' che il fondatore
/// voleva far respirare fin dall'inizio. Decisione presa dal fondatore il 23
/// settembre 2026, messo davanti al conflitto fra i due ordini.
///
/// **SI DIPINGE IL PITTORE, e non poteva essere altrimenti.** Il soffione non
/// e' un widget ma un dipinto, quindi `getRect` non lo vedrebbe. Montare la
/// schermata intera non basta: l'immagine del soffione arriva da un asset
/// PNG che nelle prove non si carica, e il pittore senza immagine **esce
/// subito**, lasciando una tela vuota da misurare. Qui si da' al pittore
/// un'immagine sintetica e **si misura il disegno vero** che ne esce.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const lato = 390.0;
  const altezza = 844.0;

  /// Un soffione finto **con le proporzioni di quello vero**, 768 per 1376.
  ///
  /// **Le proporzioni non sono un dettaglio**: il pittore ricava la larghezza
  /// disegnata dall'altezza per il rapporto dell'immagine, quindi un quadrato
  /// al posto del PNG darebbe una figura larga il doppio e la quota del
  /// settanta per cento risulterebbe presa quando non lo e'. La prima
  /// stesura di questa prova usava un quadrato e dichiarava il cento per
  /// cento: era la misura dell'immagine finta, non del soffione.
  ///
  /// La testa sta nella parte alta, come nel PNG vero: il pittore la ritaglia
  /// con `headBottomFy`, e un'immagine bianca per intero renderebbe la riga
  /// della testa larga quanto tutta la figura.
  Future<ui.Image> soffioneFinto() async {
    const w = 768.0, h = 1376.0;
    final registratore = ui.PictureRecorder();
    Canvas(registratore).drawOval(
        // La testa: un ovale attorno al centro dichiarato dal pittore.
        Rect.fromCircle(
            center: const Offset(w * 0.501, h * 0.440), radius: w * 0.244),
        Paint()..color = const Color(0xFFFFFFFF));
    return registratore.endRecording().toImage(w.round(), h.round());
  }

  /// Dipinge la scena col respiro a [respiro] e torna i pixel.
  Future<ByteData> dipingi(ui.Image soffione, double respiro) async {
    final registratore = ui.PictureRecorder();
    final canvas = Canvas(registratore);
    BreathScenePainterDiProva(
      progress: 0,
      ambient: 0,
      reduceMotion: true,
      palette: MaestroPalette.medora,
      dandelion: soffione,
      respiro: respiro,
    ).paint(canvas, const Size(lato, altezza));
    final immagine = await registratore
        .endRecording()
        .toImage(lato.round(), altezza.round());
    final dati =
        (await immagine.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    immagine.dispose();
    return dati;
  }

  /// Quanto e' larga, in punti, la macchia chiara sulla riga [y].
  double larghezzaSullaRiga(ByteData pixel, int y) {
    var primo = -1, ultimo = -1;
    for (var x = 0; x < lato.round(); x++) {
      final i = (y * lato.round() + x) * 4;
      final r = pixel.getUint8(i);
      final g = pixel.getUint8(i + 1);
      final b = pixel.getUint8(i + 2);
      // Chiaro su tutti e tre i canali: l'alone verde di Aura e' luminoso sul
      // solo verde e non deve contare.
      if (r > 140 && g > 140 && b > 140) {
        if (primo < 0) primo = x;
        ultimo = x;
      }
    }
    return primo < 0 ? 0 : (ultimo - primo + 1).toDouble();
  }

  test('il soffione si allarga e si stringe col respiro', () async {
    final soffione = await soffioneFinto();
    addTearDown(soffione.dispose);
    // La testa sta al 46 per cento dell'altezza, ordine EE voce 02.
    final y = (altezza * 0.46).round();

    final aperto = larghezzaSullaRiga(await dipingi(soffione, 1.0), y);
    final chiuso = larghezzaSullaRiga(await dipingi(soffione, 0.6), y);
    print('ORDINE EE VOCE 02: il soffione va da '
        '${chiuso.toStringAsFixed(0)} a ${aperto.toStringAsFixed(0)} punti '
        'su ${lato.toStringAsFixed(0)}');
    expect(aperto, greaterThan(0),
        reason: 'a quell\'altezza il pittore non disegna niente di chiaro: '
            'la misura guarderebbe il vuoto');
    expect(aperto - chiuso, greaterThan(8),
        reason: 'il soffione e\' largo uguale col respiro aperto e chiuso: '
            'non respira, e il respiro lo sta facendo qualcos\'altro');
  });

  test('e al culmine prende almeno il settanta per cento dello schermo',
      () async {
    // **La quota dell'ordine DD voce 03, sul soggetto nuovo.** Quella misura
    // nasce da un fatto del fondatore, *"il cerchio del respiro e' piccolo"*,
    // e vale identica per il soffione: una figura che respira e non si vede
    // non guida nessun respiro.
    final soffione = await soffioneFinto();
    addTearDown(soffione.dispose);
    final y = (altezza * 0.46).round();
    final aperto = larghezzaSullaRiga(await dipingi(soffione, 1.0), y);
    final quota = aperto / lato;
    print('ORDINE EE VOCE 02: al culmine il soffione prende '
        '${(quota * 100).toStringAsFixed(1)} per cento dello schermo');
    expect(quota, greaterThanOrEqualTo(0.70),
        reason: 'al culmine il soffione prende il '
            '${(quota * 100).toStringAsFixed(1)} per cento della larghezza, '
            'e la quota chiesta dall\'ordine DD voce 03 e\' il settanta');
  });
}
