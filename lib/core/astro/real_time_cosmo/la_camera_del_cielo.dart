/// LA CAMERA DEL CIELO DEL REAL TIME COSMO. Ordine FG parte 2.
///
/// La persona sta al centro della sfera; la camera guarda in una direzione
/// dell'orizzonte locale e proietta sullo schermo i versori orizzontali che
/// prepara `CieloInUnIstante` (est, nord, alto). **Qui non si convertono
/// coordinate equatoriali**: quella porta e' una sola,
/// `Celestial.equatorialToHorizontal`, e questo file parte dal suo risultato.
///
/// **La proiezione e' stereografica**, non gnomonica: a campo largo (settanta
/// gradi di partenza, fino a cento) la gnomonica stira i bordi fino a rendere
/// irriconoscibili le figure, la stereografica conserva gli angoli e quindi la
/// forma delle costellazioni. Un punto a un angolo theta dall'asse della camera
/// cade a una distanza 2 f tan(theta / 2) dal centro dello schermo.
library;

import 'dart:math' as math;

/// I tre campi visivi dell'ordine (voce 2.6), in gradi orizzontali.
const double kCampoDiPartenza = 70;
const double kCampoMinimo = 18;
const double kCampoMassimo = 100;

/// LA COSTANTE DI TEMPO DEL FILTRO DEL MOVIMENTO, in secondi, ai due estremi
/// del campo (voce 2.6). Il tremolio della mano e' di un grado o due e non
/// cambia mai; quanti punti valgono quei gradi dipende dal campo, quindi il
/// filtro si fa piu' severo man mano che si stringe, in modo lineare fra i due
/// estremi. A cento gradi un grado e' poco piu' di tre punti e basta un filtro
/// leggero; a diciotto gradi un grado e' venti punti e serve un filtro lento.
const double kCostanteDiTempoCampoLargo = 0.08;
const double kCostanteDiTempoCampoStretto = 0.45;

/// La costante di tempo del filtro per un campo visivo.
double costanteDiTempoPerCampo(double campoGradi) {
  final c = campoGradi.clamp(kCampoMinimo, kCampoMassimo);
  final t = (kCampoMassimo - c) / (kCampoMassimo - kCampoMinimo);
  return kCostanteDiTempoCampoLargo +
      (kCostanteDiTempoCampoStretto - kCostanteDiTempoCampoLargo) * t;
}

/// L'orientamento della camera come matrice di rotazione: tre righe, i versori
/// destra, su e avanti della camera espressi nel sistema dell'orizzonte (est,
/// nord, alto). Un versore del cielo v cade nella camera in
/// (destra . v, su . v, avanti . v).
class OrientamentoDellaCamera {
  const OrientamentoDellaCamera(this.m);

  /// Nove numeri per righe: [dx, dy, dz, sx, sy, sz, ax, ay, az].
  final List<double> m;

  /// La camera che guarda all'azimut [azimutGradi] (da nord verso est) e
  /// all'altezza [altezzaGradi], con l'orizzonte dritto e ruotata di
  /// [rollioGradi] attorno al proprio asse.
  factory OrientamentoDellaCamera.daAngoli({
    required double azimutGradi,
    required double altezzaGradi,
    double rollioGradi = 0,
  }) {
    final az = azimutGradi * math.pi / 180;
    final alt = altezzaGradi * math.pi / 180;
    // Avanti: la direzione guardata.
    final ax = math.cos(alt) * math.sin(az);
    final ay = math.cos(alt) * math.cos(az);
    final azz = math.sin(alt);
    // Destra: orizzontale, a novanta gradi in senso orario dall'azimut.
    var dx = math.cos(az);
    var dy = -math.sin(az);
    const dz = 0.0;
    // Su = destra x avanti: a nord e all'orizzonte, est x nord = alto.
    var sx = dy * azz - dz * ay;
    var sy = dz * ax - dx * azz;
    var sz = dx * ay - dy * ax;
    if (rollioGradi != 0) {
      final r = rollioGradi * math.pi / 180;
      final c = math.cos(r), s = math.sin(r);
      final ndx = c * dx + s * sx, ndy = c * dy + s * sy, ndz = c * dz + s * sz;
      final nsx = -s * dx + c * sx, nsy = -s * dy + c * sy;
      final nsz = -s * dz + c * sz;
      return OrientamentoDellaCamera(
          [ndx, ndy, ndz, nsx, nsy, nsz, ax, ay, azz]);
    }
    return OrientamentoDellaCamera([dx, dy, dz, sx, sy, sz, ax, ay, azz]);
  }

  double get azimutGradi {
    final a = math.atan2(m[6], m[7]) * 180 / math.pi;
    return a < 0 ? a + 360 : a;
  }

  double get altezzaGradi => math.asin(m[8].clamp(-1.0, 1.0)) * 180 / math.pi;
}

/// La proiezione stereografica dalla camera allo schermo.
class ProiezioneDelCielo {
  ProiezioneDelCielo({
    required this.larghezza,
    required this.altezza,
    required this.campoGradi,
  }) : f = (larghezza / 2) /
            (2 * math.tan(campoGradi * math.pi / 180 / 4));

  final double larghezza;
  final double altezza;

  /// Il campo visivo ORIZZONTALE in gradi.
  final double campoGradi;

  /// La lunghezza focale in punti logici.
  final double f;

  /// Punti logici per grado al centro dello schermo.
  double get puntiPerGrado => f * math.pi / 180;

  /// Proietta il versore (x, y, z) dell'orizzonte con l'orientamento [o].
  /// Scrive in [fuori] la x e la y di schermo e restituisce falso se il punto
  /// sta dietro la camera (oltre i 150 gradi dall'asse, dove la stereografica
  /// esplode verso l'infinito).
  bool proietta(OrientamentoDellaCamera o, double x, double y, double z,
      List<double> fuori) {
    final m = o.m;
    final cx = m[0] * x + m[1] * y + m[2] * z;
    final cy = m[3] * x + m[4] * y + m[5] * z;
    final cz = m[6] * x + m[7] * y + m[8] * z;
    if (cz < -0.866) return false;
    final k = 2 * f / (1 + cz);
    fuori[0] = larghezza / 2 + cx * k;
    fuori[1] = altezza / 2 - cy * k;
    return true;
  }

  /// Il passaggio inverso: la direzione dell'orizzonte (versore est, nord,
  /// alto) che cade nel punto (sx, sy) dello schermo. E' la stessa
  /// stereografica letta all'indietro, non una conversione di coordinate
  /// celesti.
  ({double x, double y, double z})? direzione(
      OrientamentoDellaCamera o, double sx, double sy) {
    final u = (sx - larghezza / 2) / (2 * f);
    final v = (altezza / 2 - sy) / (2 * f);
    final r2 = u * u + v * v;
    final cx = 2 * u / (1 + r2);
    final cy = 2 * v / (1 + r2);
    final cz = (1 - r2) / (1 + r2);
    final m = o.m;
    // La trasposta della rotazione riporta dalla camera all'orizzonte.
    return (
      x: m[0] * cx + m[3] * cy + m[6] * cz,
      y: m[1] * cx + m[4] * cy + m[7] * cz,
      z: m[2] * cx + m[5] * cy + m[8] * cz,
    );
  }

  /// La distanza angolare in gradi fra l'asse della camera e il versore.
  static double distanzaDallAsse(
      OrientamentoDellaCamera o, double x, double y, double z) {
    final m = o.m;
    final cz = (m[6] * x + m[7] * y + m[8] * z).clamp(-1.0, 1.0);
    return math.acos(cz) * 180 / math.pi;
  }
}
