import 'package:flutter/material.dart';
import 'package:mediapipe_face_mesh/mediapipe_face_mesh.dart';

/// **LA MASCHERA CHE SEGUE IL VOLTO.** Ordine CR voce 09, 6 settembre 2026.
///
/// **Parole del fondatore, riportate nell'ordine**: *"Mentre la testa gira, la
/// rete dei punti resta incollata al volto in tre dimensioni. E' l'effetto che
/// dice, senza una parola, che la scansione e' vera"*, e del fascio: *"dove
/// passa lascia accesi i punti che ha trovato"*.
///
/// **PERCHE' QUESTA CLASSE E' LA PROVA VISIVA DELL'ORDINE INTERO.** Prima
/// sopra l'anteprima si disegnava una costellazione **ricavata dai contorni**,
/// cioe' una figura che esisteva anche quando il volto non c'era. Qui si
/// disegnano i punti che il motore ha misurato in QUESTO fotogramma: se il
/// volto si sposta, si spostano; se il volto esce, spariscono. Non c'e' modo di
/// far sembrare viva questa maschera davanti a un muro, ed e' esattamente il
/// motivo per cui vale piu' di un'animazione.
///
/// **I PUNTI ARRIVANO NORMALIZZATI, e vanno portati sulla tela.** Il motore
/// restituisce coordinate da zero a uno sul fotogramma. La tela ha un'altra
/// forma, e l'anteprima e' ritagliata con `BoxFit.cover`: il ritaglio si rifa'
/// qui, o i punti scivolerebbero via dal viso proprio mentre la persona gira
/// la testa, che e' il momento in cui la maschera deve convincere.
///
/// **RIDUCI MOVIMENTO.** L'ordine chiede che tutto regga col movimento
/// ridotto, e che in quel caso *il fascio non scorre, i punti compaiono*. Qui
/// [scorre] falso vuol dire: nessuna soglia di luce che scende, tutti i punti
/// accesi insieme. Il disegno resta lo stesso, cambia cosa si accende quando.
class MascheraCheSegue extends CustomPainter {
  const MascheraCheSegue({
    required this.punti,
    required this.colore,
    required this.quota,
    required this.scorre,
    this.proporzioneFotogramma,
  });

  /// I punti della mesh in coordinate normalizzate, come li da' il motore.
  final List<FaceMeshLandmark> punti;

  /// L'oro del Maestro.
  final Color colore;

  /// Dove sta la lama del fascio, da zero in alto a uno in basso.
  final double quota;

  /// Falso col movimento ridotto: i punti compaiono tutti invece di accendersi
  /// al passaggio della luce.
  final bool scorre;

  /// Larghezza diviso altezza del fotogramma da cui vengono i punti. Serve a
  /// rifare lo stesso ritaglio dell'anteprima. Nullo vuol dire che il
  /// fotogramma ha gia' la forma della tela.
  final double? proporzioneFotogramma;

  static const double _raggioSpento = 0.9;
  static const double _raggioAcceso = 1.9;

  /// **QUANTO SOPRA LA LAMA UN PUNTO E' ANCORA "APPENA ACCESO".** Sotto questa
  /// distanza il punto brilla di piu': e' la scia che fa leggere il movimento
  /// come una scansione invece che come un elenco di pallini.
  static const double _scia = 0.06;

  @override
  void paint(Canvas canvas, Size size) {
    if (punti.isEmpty || size.isEmpty) return;

    // Il ritaglio di `BoxFit.cover`: si riempie la tela e si perde il resto.
    var scalaX = size.width;
    var scalaY = size.height;
    var spostaX = 0.0;
    var spostaY = 0.0;
    final proporzione = proporzioneFotogramma;
    if (proporzione != null && proporzione > 0) {
      final proporzioneTela = size.width / size.height;
      if (proporzione > proporzioneTela) {
        // Il fotogramma e' piu' largo: si taglia ai lati.
        scalaX = size.height * proporzione;
        spostaX = (size.width - scalaX) / 2;
      } else {
        scalaY = size.width / proporzione;
        spostaY = (size.height - scalaY) / 2;
      }
    }

    final spento = Paint()..color = colore.withValues(alpha: 0.20);
    final acceso = Paint()..color = colore.withValues(alpha: 0.95);
    final alone = Paint()
      ..color = colore.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    for (final p in punti) {
      final x = spostaX + p.x * scalaX;
      final y = spostaY + p.y * scalaY;
      if (x < 0 || y < 0 || x > size.width || y > size.height) continue;

      final quotaDelPunto = size.height <= 0 ? 0.0 : y / size.height;
      // **IL PUNTO SI ACCENDE QUANDO LA LUCE LO HA GIA' SUPERATO**, non
      // quando la luce lo raggiungera': la scansione lascia dietro di se'
      // cio' che ha trovato, e chi guarda legge il progresso senza che
      // nessuno glielo scriva.
      final trovato = !scorre || quotaDelPunto <= quota;
      if (!trovato) {
        canvas.drawCircle(Offset(x, y), _raggioSpento, spento);
        continue;
      }
      final vicino = scorre && (quota - quotaDelPunto).abs() <= _scia;
      if (vicino) canvas.drawCircle(Offset(x, y), _raggioAcceso + 1.6, alone);
      canvas.drawCircle(
          Offset(x, y), vicino ? _raggioAcceso : _raggioSpento + 0.5, acceso);
    }
  }

  @override
  bool shouldRepaint(MascheraCheSegue vecchio) =>
      vecchio.quota != quota ||
      vecchio.scorre != scorre ||
      vecchio.colore != colore ||
      vecchio.proporzioneFotogramma != proporzioneFotogramma ||
      !identical(vecchio.punti, punti);
}
