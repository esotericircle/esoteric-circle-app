library;

import 'dart:math' as math;
import 'dart:typed_data';

/// LA FORMA DI UN ELEMENTO, RICAVATA DAL SUO SEME. Ordine T voce 02.
///
/// **Perche' non basta un bagliore tondo.** Sulla sfera dell'Albero e sull'orbo
/// della Costellazione un tondo luminoso nel punto giusto funziona, perche' li'
/// l'elemento E' tondo. **Sul petalo del Loto no**: il petalo e' una forma
/// grande e allungata, e un puntino luminoso in mezzo si legge come un puntino,
/// non come un petalo acceso. Quindi l'ancoraggio e' un SEME, e da quel seme si
/// ricava la forma.
///
/// **LA VOCE DICEVA CHE IL MURO E' SEMPRE LO STESSO, il bordo dorato inciso, e
/// misurato non e' vero.** Con la regola "opaco e non oro luminoso" la crescita
/// sul Loto scappa dal petalo e arriva al tetto su tutti e cinquantacinque, e
/// sull'Albero fa lo stesso, perche' fra un ramo e l'altro il fondo scuro e'
/// libero quanto la sfera. Il muro unico non c'e'.
///
/// **QUELLO CHE FUNZIONA e' crescere sulla MATERIA dell'elemento**, cioe' sul
/// colore che sta attorno al seme: il bordo dorato diventa un muro non perche'
/// e' dorato, ma perche' e' di un'altra materia. E' la stessa idea vista dal
/// verso giusto, e regge su tutte e tre le arti invece che su una.
///
/// **Il lavoro si fa UNA VOLTA, non a ogni fotogramma**: lo strumento
/// `tool/ancoraggi_dai_sentieri.dart` calcola le cinquantacinque forme e le
/// scrive come dato, e il disegno le rilegge. Vale la regola dell'8 agosto, il
/// cielo si dipinge una volta.

/// UNA FORMA, conservata a STRISCE ORIZZONTALI.
///
/// **Perche' a strisce e non come contorno.** Un contorno va inseguito lungo il
/// bordo e ogni errore di percorso produce una forma chiusa male; una striscia
/// e' un fatto, la riga y va da x1 a x2. Ricomporre le strisce da' la stessa
/// regione esatta, e il bagliore sfumato che ci si posa sopra non lascia vedere
/// gli scalini.
class FormaDellElemento {
  const FormaDellElemento({
    required this.strisce,
    required this.eRipiego,
    required this.area,
  });

  /// Le strisce, a terne: riga, primo x, ultimo x. **In pixel dell'arte**, non
  /// in coordinate relative: sono interi, pesano meno e non perdono precisione.
  final List<int> strisce;

  /// **VERO QUANDO LA CRESCITA NON SI E' CHIUSA e si e' ripiegati sul bagliore
  /// tondo attorno al seme.** Non si inventa una forma: si dichiara.
  final bool eRipiego;

  /// Quanti pixel dell'arte copre la forma.
  final int area;

  int get quanteStrisce => strisce.length ~/ 3;
}

/// COME CRESCE UNA FORMA su una certa arte.
///
/// **IL MURO E' L'ORO, E SI RICONOSCE DALLA TINTA E NON DALLA LUMINOSITA'.**
/// Prima questa regola guardava quanto un pixel fosse chiaro, e sbagliava: il
/// contorno inciso di un petalo e' oro di mezzo tono, scuro quanto lo smalto
/// che racchiude. Guardato dalla tinta invece e' netto: nell'oro il rosso sta
/// sopra il verde e il verde sopra il blu, con uno stacco fra il primo e
/// l'ultimo; nello smalto verde e nel lapis blu quell'ordine non c'e'.
class RegolaDellaForma {
  const RegolaDellaForma({
    required this.tolleranza,
    required this.chiusura,
    required this.raggioMassimo,
    required this.areaMinima,
  });

  /// **QUANTO PUO' ALLONTANARSI UN COLORE DALLA MATERIA del seme e restare lo
  /// stesso elemento**, sommando le differenze dei tre canali. **Zero vuol dire
  /// che non si guarda la materia**, e basta l'oro a fare da muro: sull'Albero e
  /// sulla Costellazione il contorno chiude da solo, sul Loto no, perche' i
  /// petali si toccano e passano l'uno nell'altro dove il contorno si assottiglia.
  final int tolleranza;

  /// **QUANTE VOLTE SI CHIUDE LA MASCHERA prima di crescere, cioe' quanto e'
  /// spessa una venatura che NON e' un muro.** Una venatura sottile dentro un
  /// elemento lo spezzerebbe in due; il contorno vero e' piu' spesso e regge la
  /// chiusura. Zero vuol dire non chiudere niente.
  final int chiusura;

  /// **FIN DOVE PUO' ARRIVARE una forma dal suo seme, in pixel.** Non deriva da
  /// cio' che si e' misurato: viene da cosa e' un elemento. Un Journal ne porta
  /// cinquantacinque, quindi nessuno puo' occupare piu' di una frazione della
  /// figura; oltre, non si sta illuminando un elemento ma il disegno. Uscire da
  /// questo raggio vuol dire che la crescita non si e' chiusa.
  final int raggioMassimo;

  /// **SOTTO QUESTA AREA la forma non e' una forma**: e' piu' piccola del
  /// bagliore tondo che dovrebbe sostituire, quindi non aggiunge niente.
  final int areaMinima;
}

/// LA CRESCITA.
class CrescitaDellaForma {
  const CrescitaDellaForma._();

  /// **IL RAGGIO DEL BAGLIORE TONDO DEL RIPIEGO**, in pixel dell'arte: dieci,
  /// che e' meta' del diametro minimo di un elemento dichiarato nella voce T.01.
  static const int raggioDelRipiego = 10;

  /// Quanti pixel copre il ripiego: e' anche il pavimento sotto cui una forma
  /// non vale la pena.
  static int get areaDelRipiego =>
      (math.pi * raggioDelRipiego * raggioDelRipiego).floor();

  /// **IL MURO: l'oro, riconosciuto dalla tinta.** Rosso sopra verde sopra blu,
  /// con almeno trenta punti fra il primo e l'ultimo.
  static bool eOro(int r, int g, int b) => r > g && g >= b && (r - b) > 30;

  /// LA MATERIA ATTORNO AL SEME: il colore mediano dei pixel opachi in un
  /// quadretto attorno al punto. **Mediano e non medio**, perche' il seme puo'
  /// cadere accanto a una venatura d'oro e una media la porterebbe dentro.
  static List<int>? materia(
    Uint8List rgba,
    int larghezza,
    int altezza,
    int sx,
    int sy, {
    int lato = 10,
  }) {
    final r = <int>[], g = <int>[], b = <int>[];
    for (var y = math.max(0, sy - lato);
        y <= math.min(altezza - 1, sy + lato);
        y++) {
      for (var x = math.max(0, sx - lato);
          x <= math.min(larghezza - 1, sx + lato);
          x++) {
        final i = (y * larghezza + x) * 4;
        if (rgba[i + 3] <= 128) continue;
        r.add(rgba[i]);
        g.add(rgba[i + 1]);
        b.add(rgba[i + 2]);
      }
    }
    if (r.length < 20) return null;
    r.sort();
    g.sort();
    b.sort();
    return [r[r.length ~/ 2], g[g.length ~/ 2], b[b.length ~/ 2]];
  }

  /// LA FORMA di un elemento, o il ripiego dichiarato.
  static FormaDellElemento cresci(
    Uint8List rgba,
    int larghezza,
    int altezza,
    int semeX,
    int semeY,
    RegolaDellaForma regola,
  ) {
    final m = regola.tolleranza > 0
        ? materia(rgba, larghezza, altezza, semeX, semeY)
        : const <int>[0, 0, 0];
    if (m == null) return _ripiego(semeX, semeY, larghezza, altezza);

    final x0 = math.max(0, semeX - regola.raggioMassimo);
    final x1 = math.min(larghezza - 1, semeX + regola.raggioMassimo);
    final y0 = math.max(0, semeY - regola.raggioMassimo);
    final y1 = math.min(altezza - 1, semeY + regola.raggioMassimo);
    final lf = x1 - x0 + 1;
    final af = y1 - y0 + 1;

    // LA MASCHERA DEL LIBERO, calcolata solo dentro la finestra.
    var libero = Uint8List(lf * af);
    for (var y = y0; y <= y1; y++) {
      for (var x = x0; x <= x1; x++) {
        final i = (y * larghezza + x) * 4;
        if (rgba[i + 3] <= 128) continue;
        if (eOro(rgba[i], rgba[i + 1], rgba[i + 2])) continue;
        if (regola.tolleranza > 0) {
          final d = (rgba[i] - m[0]).abs() +
              (rgba[i + 1] - m[1]).abs() +
              (rgba[i + 2] - m[2]).abs();
          if (d > regola.tolleranza) continue;
        }
        libero[(y - y0) * lf + (x - x0)] = 1;
      }
    }
    if (regola.chiusura > 0) {
      libero = _chiudi(libero, lf, af, regola.chiusura);
    }

    // **IL SEME PUO' CADERE FUORI DALLA SUA MATERIA**, e sul Loto succede: certi
    // semi stanno sulla filigrana d'oro fra un petalo e l'altro. Si cerca il
    // pixel libero piu' vicino: non e' inventare una forma, e' capire a quale
    // elemento il seme sta puntando.
    var sx = semeX, sy = semeY;
    if (libero[(sy - y0) * lf + (sx - x0)] == 0) {
      var trovato = false;
      for (var raggio = 1; raggio <= 14 && !trovato; raggio++) {
        for (var dy = -raggio; dy <= raggio && !trovato; dy++) {
          for (var dx = -raggio; dx <= raggio && !trovato; dx++) {
            final nx = semeX + dx, ny = semeY + dy;
            if (nx < x0 || nx > x1 || ny < y0 || ny > y1) continue;
            if (libero[(ny - y0) * lf + (nx - x0)] == 1) {
              sx = nx;
              sy = ny;
              trovato = true;
            }
          }
        }
      }
      if (!trovato) return _ripiego(semeX, semeY, larghezza, altezza);
    }

    final visto = Uint8List(lf * af);
    final pila = <int>[(sy - y0) * lf + (sx - x0)];
    visto[pila.first] = 1;
    final punti = <int>[];
    var esce = false;
    while (pila.isNotEmpty) {
      final i = pila.removeLast();
      final x = x0 + i % lf;
      final y = y0 + i ~/ lf;
      punti.add(y * larghezza + x);
      if (x == x0 || x == x1 || y == y0 || y == y1) esce = true;
      for (final d in const [
        [1, 0],
        [-1, 0],
        [0, 1],
        [0, -1]
      ]) {
        final nx = x + d[0], ny = y + d[1];
        if (nx < x0 || nx > x1 || ny < y0 || ny > y1) continue;
        final k = (ny - y0) * lf + (nx - x0);
        if (visto[k] == 1 || libero[k] == 0) continue;
        visto[k] = 1;
        pila.add(k);
      }
    }

    // **DUE MODI DI NON CHIUDERSI, e tutti e due portano al ripiego dichiarato:**
    // la forma esce dalla finestra, cioe' non e' un elemento ma una colata; la
    // forma e' piu' piccola del bagliore tondo, cioe' non aggiunge niente.
    if (esce || punti.length < regola.areaMinima) {
      return _ripiego(semeX, semeY, larghezza, altezza);
    }
    return FormaDellElemento(
      strisce: _strisce(punti, larghezza),
      eRipiego: false,
      area: punti.length,
    );
  }

  /// CHIUSURA: si gonfia e poi si sgonfia. Serve a scavalcare una venatura
  /// sottile senza scavalcare un contorno.
  static Uint8List _chiudi(Uint8List m, int w, int h, int quante) {
    var a = m;
    for (var giro = 0; giro < quante; giro++) {
      a = _gonfia(a, w, h);
    }
    for (var giro = 0; giro < quante; giro++) {
      a = _sgonfia(a, w, h);
    }
    return a;
  }

  static Uint8List _gonfia(Uint8List m, int w, int h) {
    final f = Uint8List(w * h);
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final i = y * w + x;
        if (m[i] == 1 ||
            (x > 0 && m[i - 1] == 1) ||
            (x + 1 < w && m[i + 1] == 1) ||
            (y > 0 && m[i - w] == 1) ||
            (y + 1 < h && m[i + w] == 1)) {
          f[i] = 1;
        }
      }
    }
    return f;
  }

  static Uint8List _sgonfia(Uint8List m, int w, int h) {
    final f = Uint8List(w * h);
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final i = y * w + x;
        if (m[i] == 0) continue;
        final su = y > 0 ? m[i - w] : 0;
        final giu = y + 1 < h ? m[i + w] : 0;
        final sin = x > 0 ? m[i - 1] : 0;
        final des = x + 1 < w ? m[i + 1] : 0;
        if (su == 1 && giu == 1 && sin == 1 && des == 1) f[i] = 1;
      }
    }
    return f;
  }

  /// Il ripiego: il disco attorno al seme, scritto con le stesse strisce, cosi'
  /// chi disegna non deve sapere quale delle due cose sta guardando.
  static FormaDellElemento _ripiego(
      int sx, int sy, int larghezza, int altezza) {
    final punti = <int>[];
    for (var dy = -raggioDelRipiego; dy <= raggioDelRipiego; dy++) {
      for (var dx = -raggioDelRipiego; dx <= raggioDelRipiego; dx++) {
        if (dx * dx + dy * dy > raggioDelRipiego * raggioDelRipiego) continue;
        final x = sx + dx, y = sy + dy;
        if (x < 0 || y < 0 || x >= larghezza || y >= altezza) continue;
        punti.add(y * larghezza + x);
      }
    }
    return FormaDellElemento(
      strisce: _strisce(punti, larghezza),
      eRipiego: true,
      area: punti.length,
    );
  }

  /// Dai pixel alle strisce: riga, primo x, ultimo x.
  static List<int> _strisce(List<int> punti, int larghezza) {
    final perRiga = <int, List<int>>{};
    for (final p in punti) {
      final y = p ~/ larghezza, x = p % larghezza;
      (perRiga[y] ??= <int>[]).add(x);
    }
    final righe = perRiga.keys.toList()..sort();
    final fuori = <int>[];
    for (final y in righe) {
      final xs = perRiga[y]!..sort();
      var inizio = xs.first, precedente = xs.first;
      for (var i = 1; i < xs.length; i++) {
        if (xs[i] == precedente + 1) {
          precedente = xs[i];
          continue;
        }
        fuori.addAll([y, inizio, precedente]);
        inizio = xs[i];
        precedente = xs[i];
      }
      fuori.addAll([y, inizio, precedente]);
    }
    return fuori;
  }
}
