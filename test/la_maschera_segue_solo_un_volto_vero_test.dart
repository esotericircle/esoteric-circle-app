import 'dart:ui' as ui;

import 'package:esoteric_circle/features/maestri/aura/face/maschera_che_segue.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mediapipe_face_mesh/mediapipe_face_mesh.dart';

/// **LA MASCHERA SEGUE UN VOLTO VERO, E SENZA VOLTO NON DISEGNA.**
/// Ordine CR voce 09, 6 settembre 2026.
///
/// **IL DIFETTO CHE QUESTA GUARDIA CHIUDE, ed era il gemello grafico del
/// muro.** Sopra l'anteprima dal vivo la schermata disegnava questo:
///
///     final cost = FaceConstellation.da(volto ?? FaceSilhouette.contorni());
///
/// cioe' una costellazione costruita dai contorni **con la sagoma disegnata a
/// mano come ripiego**. Davanti a una parete il rilevatore non trova niente,
/// il ripiego entrava, e sullo schermo compariva una figura accesa sopra il
/// nulla: la stessa bugia del responso, in forma di disegno. Il cancello di
/// CR.01 aveva tolto il `??` dal responso e questo era rimasto.
///
/// **COME SI MISURA UN DISEGNO.** Non si guarda il codice, si dipinge davvero
/// su una tela e si contano i pixel accesi. Una guardia che cercasse
/// `MascheraCheSegue` nel sorgente sarebbe verde anche con un pennello che non
/// tocca la tela.
void main() {
  /// Dipinge il pittore su una tela vera e conta i pixel non trasparenti.
  Future<int> pixelAccesi(CustomPainter pittore, {Size lato = const Size(200, 200)}) async {
    final registratore = ui.PictureRecorder();
    final tela = Canvas(registratore, Offset.zero & lato);
    pittore.paint(tela, lato);
    final immagine = await registratore
        .endRecording()
        .toImage(lato.width.toInt(), lato.height.toInt());
    final dati = await immagine.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (dati == null) return 0;
    var accesi = 0;
    for (var i = 3; i < dati.lengthInBytes; i += 4) {
      if (dati.getUint8(i) != 0) accesi++;
    }
    return accesi;
  }

  /// Punti finti ma con la forma vera: normalizzati, dentro il fotogramma.
  List<FaceMeshLandmark> punti(int quanti, {double da = 0.2, double a = 0.8}) {
    return [
      for (var i = 0; i < quanti; i++)
        FaceMeshLandmark(
          x: da + (a - da) * (i % 10) / 9,
          y: da + (a - da) * (i ~/ 10) / ((quanti ~/ 10) + 1),
          z: 0,
        ),
    ];
  }

  test('senza punti la maschera non tocca la tela', () async {
    final accesi = await pixelAccesi(const MascheraCheSegue(
      punti: [],
      colore: Color(0xFFFFD700),
      quota: 1.0,
      scorre: true,
    ));
    expect(accesi, 0,
        reason: 'la maschera disegna qualcosa senza nessun punto: e\' la '
            'figura accesa sopra il nulla che questa voce esiste per togliere');
  });

  test('con punti veri la maschera disegna davvero', () async {
    final accesi = await pixelAccesi(MascheraCheSegue(
      punti: punti(100),
      colore: const Color(0xFFFFD700),
      quota: 1.0,
      scorre: true,
    ));
    expect(accesi, greaterThan(100),
        reason: 'con cento punti la maschera non accende niente: il pennello '
            'non tocca la tela, e la guardia di sopra sarebbe verde per caso');
  });

  test('il fascio lascia accesi i punti che ha gia\' superato', () async {
    // La stessa nuvola, la lama in cima e la lama in fondo. Cio' che e' gia'
    // stato trovato resta acceso, quindi il secondo caso deve brillare di
    // piu' del primo. **E' un confronto fra due misure**, non un valore
    // assoluto scelto a mano: cosi' la pretesa regge anche se domani si
    // cambia il raggio dei punti.
    final nuvola = punti(120);
    final inCima = await pixelAccesi(MascheraCheSegue(
      punti: nuvola,
      colore: const Color(0xFFFFD700),
      quota: 0.0,
      scorre: true,
    ));
    final inFondo = await pixelAccesi(MascheraCheSegue(
      punti: nuvola,
      colore: const Color(0xFFFFD700),
      quota: 1.0,
      scorre: true,
    ));
    expect(inFondo, greaterThan(inCima),
        reason: 'la lama scende e non lascia dietro niente: il '
            'passaggio della luce non accende i punti trovati, quindi il '
            'fascio e\' un ornamento invece di una misura');
  });

  test('col movimento ridotto i punti compaiono tutti insieme', () async {
    // **IL VINCOLO DICHIARATO DALL'ORDINE**: *"tutto questo deve reggere con
    // Riduci Movimento acceso, e in quel caso il fascio non scorre, i punti
    // compaiono"*. Con la lama in cima, che scorrendo accenderebbe quasi
    // niente, il movimento ridotto deve accendere quanto la lama in fondo.
    final nuvola = punti(120);
    final scorrendo = await pixelAccesi(MascheraCheSegue(
      punti: nuvola,
      colore: const Color(0xFFFFD700),
      quota: 0.0,
      scorre: true,
    ));
    final fermo = await pixelAccesi(MascheraCheSegue(
      punti: nuvola,
      colore: const Color(0xFFFFD700),
      quota: 0.0,
      scorre: false,
    ));
    expect(fermo, greaterThan(scorrendo),
        reason: 'col movimento ridotto i punti non compaiono: chi ha spento '
            'le animazioni resta davanti a uno schermo quasi vuoto');
  });
}
