import 'dart:math' as math;

import 'package:mediapipe_face_mesh/mediapipe_face_mesh.dart';

import 'punti_del_volto.dart';

/// **QUANTO IL CAPO E' ALZATO O ABBASSATO, MISURATO DAI PUNTI.**
/// Ordine CR voce 03, seconda stesura, 6 settembre 2026.
///
/// **Parole del fondatore dopo la prova sul telefono**: *"gira il volto a
/// destra e sinistra ok. in basso NON FUNZIONA e ho dovuto alzare il viso"*.
///
/// **PERCHE' NON SI USA PIU' IL PITCH DEL MOTORE.** Il pacchetto restituisce
/// `pitchDegrees` con una sola riga di documentazione, *"Up/down head rotation
/// in degrees"*, e **non dichiara da che parte cresce**. La prima stesura ha
/// dato per buono che positivo volesse dire mento alzato: era una supposizione
/// mia, non un fatto, e sul telefono si e' rivelata sbagliata. Chiedere "guarda
/// in basso" e accettare il gesto opposto e' il modo piu' sicuro di far
/// sentire rotta una funzione che sta misurando benissimo.
///
/// **QUI IL SEGNO E' NOSTRO, E SI PUO' PROVARE.** L'inclinazione si ricava
/// dalla PROFONDITA' di due punti che stanno agli estremi verticali del volto,
/// la fronte e il mento: quando il capo si alza, il mento si avvicina alla
/// fotocamera e la fronte si allontana; quando si abbassa, succede il
/// contrario. E' una relazione geometrica, non una convenzione: si costruisce
/// una testa sintetica, la si ruota di un angolo noto, e si legge il segno che
/// esce. **Una prova cosi' non esisteva, ed e' per questo che l'errore e'
/// arrivato fino al telefono del fondatore.**
///
/// **LE COORDINATE Z DELLA MESH.** MediaPipe le da' nella stessa scala della
/// x, con l'origine circa sul piano del volto e **valori piu' piccoli piu'
/// vicino alla fotocamera**. Qui non si dipende da quella convenzione in
/// assoluto: si guarda la DIFFERENZA fra due punti, e la differenza cambia
/// segno con la rotazione qualunque sia lo zero.
class InclinazioneDelCapo {
  const InclinazioneDelCapo._();

  /// Il punto in cima alla fronte, nel gruppo dell'ovale.
  static const int fronte = 10;

  /// Il punto del mento, nel gruppo dell'ovale.
  static const int mento = 152;

  /// **Gradi di alzata del capo: positivo quando il mento sale.**
  ///
  /// Zero vuol dire volto di fronte. Restituisce zero anche quando i punti
  /// non ci sono: **senza dati non si inventa un angolo**, e chi chiama
  /// vedra' semplicemente una posa che non si compie.
  static double gradi(List<FaceMeshLandmark> punti) {
    if (punti.length <= math.max(fronte, mento)) return 0;
    final f = punti[fronte];
    final m = punti[mento];

    // L'altezza del volto sullo schermo, che e' la scala con cui la
    // profondita' va confrontata: senza normalizzare, un volto vicino e uno
    // lontano darebbero angoli diversi a parita' di rotazione.
    final altezza = (m.y - f.y).abs();
    if (altezza <= 0) return 0;

    // **LA PROFONDITA' DEL MENTO RISPETTO ALLA FRONTE.** Il mento piu' vicino
    // alla fotocamera della fronte vuol dire capo alzato. Con z piu' piccola
    // verso la fotocamera, "mento piu' vicino" e' `m.z < f.z`, quindi la
    // differenza che cresce col capo alzato e' `f.z - m.z`.
    final avanzamento = (f.z - m.z) / altezza;

    // Dall'avanzamento all'angolo: il rapporto fra lo spostamento in
    // profondita' e l'altezza del volto e' la tangente dell'inclinazione.
    return math.atan(avanzamento) * 180 / math.pi;
  }

  /// I gradi di rotazione a destra e sinistra, con lo stesso metodo.
  ///
  /// **Positivo quando la persona gira la testa verso la propria destra.** Il
  /// motore lo calcolava gia' e sul telefono funzionava, ma tenerlo qui
  /// insieme all'altro vuol dire che i due angoli hanno la stessa origine e
  /// la stessa prova: due misure fatte in due modi diversi sono due modi
  /// diversi di sbagliare.
  static double gradiDiProfilo(List<FaceMeshLandmark> punti) {
    final sinistra = _centro(punti, PuntiDelVolto.guanciaSinistra);
    final destra = _centro(punti, PuntiDelVolto.guanciaDestra);
    if (sinistra == null || destra == null) return 0;
    final larghezza = (destra.$1 - sinistra.$1).abs();
    if (larghezza <= 0) return 0;
    // Girando verso la propria destra, la guancia destra del soggetto si
    // allontana dalla fotocamera e la sinistra si avvicina.
    final avanzamento = (destra.$3 - sinistra.$3) / larghezza;
    return math.atan(avanzamento) * 180 / math.pi;
  }

  static (double, double, double)? _centro(
      List<FaceMeshLandmark> punti, List<int> indici) {
    var x = 0.0;
    var y = 0.0;
    var z = 0.0;
    var quanti = 0;
    for (final i in indici) {
      if (i >= punti.length) continue;
      x += punti[i].x;
      y += punti[i].y;
      z += punti[i].z;
      quanti++;
    }
    if (quanti == 0) return null;
    return (x / quanti, y / quanti, z / quanti);
  }
}
