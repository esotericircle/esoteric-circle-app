// ignore_for_file: avoid_print
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/rituals/breath_destiny_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA FIGURA CHE RESPIRA SI VEDE DAVVERO.** Ordine DD voce 03, riportata sul
/// soggetto vero dall'ordine EF voce 01, 23 settembre 2026.
///
/// ## LA LAPIDE: COSA MISURAVA QUESTA PROVA FINO AL 23 SETTEMBRE, E PERCHE'
/// ERA FALSA
///
/// Dall'ordine EE voce 02 questo file si chiamava *"a respirare e' il
/// soffione, non un cerchio sopra di lui"* e dichiarava, con un numero:
/// **"al culmine il soffione prende il 71,0 per cento dello schermo"**.
///
/// **Quel numero descriveva una combinazione che a video non esiste mai.** Il
/// pittore veniva dipinto con `progress: 0`, cioe' soffio non ancora fatto, e
/// insieme un respiro in corso. Ma nel rito **prima si soffia e poi si
/// respira**: `_reveal()` scatta a soffio finito
/// (`breath_destiny_screen.dart`), e solo allora compare la guida del
/// respiro. Quando la persona respira, `progress` vale uno e l'opacita' della
/// testa e' `1 - progress`, cioe' zero: **il soffione di semi non e' a
/// schermo**. La prova misurava un soffione pieno che respira; la persona
/// vedeva un riquadro sopra una scena senza soffione.
///
/// **Padre: ordine EE voce 02.** Ed e' la lezione della memoria *misurare il
/// prodotto intero*: dipingere un pittore da solo, con una terna di parametri
/// scelta da chi scrive la prova, misura il pittore e non la schermata.
///
/// ## COSA SI MISURA ADESSO
///
/// La quota dell'ordine DD voce 03 resta intera, e nasce da un fatto del
/// fondatore, *"il cerchio del respiro e' piccolo"*: **la figura che sta a
/// schermo MENTRE si respira deve prendere almeno il settanta per cento della
/// larghezza al culmine.** In quel momento quella figura e' il dono, che e'
/// gia' di suo un soffione di luce d'oro, e il soffio e' finito: si dipinge
/// con `progress: 1`, che e' la sola combinazione vera.
///
/// E si misura anche il soffione inciso nella fase che gli appartiene, prima
/// del soffio, perche' li' c'e' lui e deve vedersi.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const lato = 411.0;
  const altezza = 914.0;

  /// Dipinge la scena e torna i pixel.
  ///
  /// **Nessuna immagine da passare, ed e' la cura della voce 03.** Finche' il
  /// soffione era una fotografia, il pittore usciva subito quando l'asset
  /// mancava, e sotto `flutter test` mancava sempre: questa prova doveva
  /// fabbricargli un PNG sintetico per avere qualcosa da guardare. Adesso il
  /// soffione e' disegnato, quindi **quello che si misura qui e' esattamente
  /// quello che il telefono dipinge**.
  Future<ByteData> dipingi({
    required double soffio,
    required double respiro,
  }) async {
    final registratore = ui.PictureRecorder();
    final canvas = Canvas(registratore);
    BreathScenePainterDiProva(
      progress: soffio,
      ambient: 0,
      reduceMotion: false,
      palette: MaestroPalette.medora,
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

  /// Quanto e' larga, in punti, la macchia d'oro piu' larga fra le righe
  /// [daY] e [aY].
  ///
  /// **Si guarda una fascia e non una riga sola.** Una riga sola e' una
  /// scommessa sul fatto che la figura sia centrata proprio li': se la
  /// geometria si sposta di dieci punti la misura cade sul vuoto e la prova
  /// diventa verde per il motivo sbagliato, oppure rossa senza nessun
  /// difetto.
  double larghezzaNellaFascia(ByteData pixel, int daY, int aY) {
    var massimo = 0.0;
    for (var y = daY; y <= aY; y++) {
      var primo = -1, ultimo = -1;
      for (var x = 0; x < lato.round(); x++) {
        final i = (y * lato.round() + x) * 4;
        final r = pixel.getUint8(i);
        final g = pixel.getUint8(i + 1);
        final b = pixel.getUint8(i + 2);
        // L'oro e' chiaro sul rosso e sul verde e meno sul blu. L'alone verde
        // di Aura e' luminoso sul solo verde e non deve contare.
        if (r > 120 && g > 100 && r > b + 20) {
          if (primo < 0) primo = x;
          ultimo = x;
        }
      }
      final larga = primo < 0 ? 0.0 : (ultimo - primo + 1).toDouble();
      if (larga > massimo) massimo = larga;
    }
    return massimo;
  }

  test('il dono si allarga e si stringe col respiro', () async {
    // La fascia attorno al disco, dove il dono si compone.
    const misura = Size(lato, altezza);
    final centro = SuperficiDelSoffio.discoDentro(misura).dy.round();
    final da = centro - 40, a = centro + 40;

    final aperto =
        larghezzaNellaFascia(await dipingi(soffio: 1, respiro: 1.0), da, a);
    final chiuso =
        larghezzaNellaFascia(await dipingi(soffio: 1, respiro: 0.55), da, a);
    print('ORDINE EF VOCE 01: il dono va da ${chiuso.toStringAsFixed(0)} '
        'a ${aperto.toStringAsFixed(0)} punti su ${lato.toStringAsFixed(0)}');
    expect(aperto, greaterThan(0),
        reason: 'in quella fascia il pittore non disegna niente d\'oro: la '
            'misura guarderebbe il vuoto');
    expect(aperto - chiuso, greaterThan(8),
        reason: 'il dono e\' largo uguale col respiro aperto e chiuso: non '
            'respira, e il respiro lo sta facendo qualcos\'altro');
  });

  test('e al culmine prende almeno il settanta per cento dello schermo',
      () async {
    const misura = Size(lato, altezza);
    final centro = SuperficiDelSoffio.discoDentro(misura).dy.round();
    final aperto = larghezzaNellaFascia(
        await dipingi(soffio: 1, respiro: 1.0), centro - 40, centro + 40);
    final quota = aperto / lato;
    print('ORDINE EF VOCE 01: al culmine il dono prende '
        '${(quota * 100).toStringAsFixed(1)} per cento dello schermo');
    expect(quota, greaterThanOrEqualTo(0.70),
        reason: 'al culmine la figura che respira prende il '
            '${(quota * 100).toStringAsFixed(1)} per cento della larghezza, '
            'e la quota chiesta dall\'ordine DD voce 03 e\' il settanta');
  });

  test('e prima del soffio il soffione inciso si vede', () async {
    const misura = Size(lato, altezza);
    final centro = SuperficiDelSoffio.testaDentro(misura).dy.round();
    final testa = larghezzaNellaFascia(
        await dipingi(soffio: 0, respiro: 1.0), centro - 60, centro + 60);
    final quota = testa / lato;
    print('ORDINE EF VOCE 03: prima del soffio il soffione inciso prende '
        '${(quota * 100).toStringAsFixed(1)} per cento dello schermo');
    // **La soglia e' piu' bassa di quella del respiro, e si dichiara.** Qui
    // non si sta guidando nessun fiato: si sta mostrando la figura che la
    // persona sta per soffiare via, e deve vedersi bene senza riempire lo
    // schermo.
    expect(quota, greaterThanOrEqualTo(0.45),
        reason: 'prima del soffio il soffione prende il '
            '${(quota * 100).toStringAsFixed(1)} per cento: e\' la figura del '
            'gesto, e cosi\' non si vede');
  });
}
