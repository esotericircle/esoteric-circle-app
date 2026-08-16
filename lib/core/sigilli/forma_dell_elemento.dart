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
    this.colore,
  });

  /// Le strisce, a terne: riga, primo x, ultimo x. **In pixel dell'arte**, non
  /// in coordinate relative: sono interi, pesano meno e non perdono precisione.
  final List<int> strisce;

  /// **VERO QUANDO LA CRESCITA NON SI E' CHIUSA e si e' ripiegati sul bagliore
  /// tondo attorno al seme.** Non si inventa una forma: si dichiara.
  final bool eRipiego;

  /// Quanti pixel dell'arte copre la forma.
  final int area;

  /// **IL COLORE DELLA MATERIA DI QUESTO ELEMENTO**, tre canali fra 0 e 255,
  /// oppure nulla quando non e' ricavabile. Ordine X voce 01.
  ///
  /// **A cosa serve: a dare alla luce il colore di cio' che accende.** L'oro e'
  /// complementare al blu, quindi qualunque luce dorata su un lapislazzuli lo
  /// porta verso il grigio, a qualunque opacita': misurato, sulla Costellazione
  /// il 73,8 per cento dei pixel che cambiano accendendo porta la firma dell'oro
  /// e perde saturazione da 0,75 a 0,59, mentre sul Loto gli stessi pixel dorati
  /// sono il 69,8 per cento e non perdono niente, perche' la materia del Loto e'
  /// calda. **Non e' una taratura, e' la scelta del colore della luce.**
  ///
  /// **E' MEDIANO PER CANALE, non medio, ed e' la stessa ragione di [materia]**:
  /// dentro un elemento passano venature d'oro incise, e una media le tirerebbe
  /// dentro riportando nella luce proprio il colore che si vuole togliere. La
  /// mediana le ignora finche' restano una minoranza.
  ///
  /// **Nulla vuol dire nulla, e chi disegna torna all'oro dichiarandolo.** Sui
  /// ripieghi non c'e' un elemento cresciuto sotto: il colore di un disco
  /// attorno a un seme caduto sulla filigrana sarebbe il colore della filigrana,
  /// cioe' un valore plausibile e falso.
  final List<int>? colore;

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
    this.saldaturaDelMuro = 0,
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

  /// **DI QUANTO SI DILATA IL MURO PRIMA DI CRESCERE.** Ordine AA voce 01.
  ///
  /// **E' l'opposto di [chiusura] e le due non vanno confuse.** La chiusura
  /// gonfia il LIBERO, quindi allarga i passaggi fra due elementi che si toccano;
  /// questa gonfia il MURO, quindi li restringe fino a chiuderli. Una saldatura
  /// di n salda una strozzatura larga fino a 2n.
  ///
  /// **Zero vuol dire non saldare niente**, ed e' il valore di tutti e tre i
  /// sentieri finche' una misura non dimostra che un altro valore fa meglio su
  /// due gambe insieme, il conteggio delle forme E l'area, perche' saldando
  /// troppo un elemento si taglia in due e il conteggio salirebbe rimpicciolendo
  /// la cosa contata.
  final int saldaturaDelMuro;
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

  /// **QUANTI PIXEL DI MURO CI SONO SU UN'ARTE, prima e dopo la saldatura.**
  /// Ordine AA voce 01 lettera d.
  ///
  /// **Serve a verificare che la saldatura sia ENTRATA prima di leggere il
  /// conteggio delle forme.** E' la regola del rosso applicata a una correzione
  /// invece che a un difetto: se questi due numeri sono uguali, la dilatazione
  /// non ha fatto niente e il conteggio che si legge dopo non dice niente.
  static (int, int) muroPrimaEDopo(
    Uint8List rgba,
    int larghezza,
    int altezza,
    int saldatura,
  ) {
    var muro = Uint8List(larghezza * altezza);
    var prima = 0;
    for (var p = 0; p < larghezza * altezza; p++) {
      final i = p * 4;
      if (rgba[i + 3] <= 128) continue;
      if (!eOro(rgba[i], rgba[i + 1], rgba[i + 2])) continue;
      muro[p] = 1;
      prima++;
    }
    for (var g = 0; g < saldatura; g++) {
      muro = _gonfia(muro, larghezza, altezza);
    }
    var dopo = 0;
    for (var p = 0; p < muro.length; p++) {
      if (muro[p] == 1) dopo++;
    }
    return (prima, dopo);
  }

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

    // **IL MURO SI SALDA PRIMA DI CRESCERE.** Ordine AA voce 01.
    //
    // **E' l'operazione OPPOSTA alla chiusura, e l'ordine Z ha dimostrato
    // perche' serve quella e non questa.** Chiudere la REGIONE gonfia il libero,
    // quindi allarga i passaggi fra un petalo e l'altro invece di sigillarli.
    // Dilatare il MURO li restringe: una saldatura di n chiude una strozzatura
    // fino a 2n, e sul Loto le strozzature misurate vanno da 1 a 5 pixel con
    // mediana 3.
    //
    // **Il muro dilatato non entra mai nella forma**, perche' il libero lo
    // esclude: non c'e' niente da togliere alla fine, e l'area non si gonfia.
    // Il pericolo e' l'opposto ed e' dichiarato: nel Loto il muro passa anche
    // DENTRO il petalo, perche' la venatura e' oro e ha spessore mediano 5, e
    // saldandola troppo il petalo si taglia in due. Per questo il criterio ha
    // due gambe, il conteggio e l'area, e non basta il conteggio.
    var muro = Uint8List(lf * af);
    if (regola.saldaturaDelMuro > 0) {
      for (var y = y0; y <= y1; y++) {
        for (var x = x0; x <= x1; x++) {
          final i = (y * larghezza + x) * 4;
          if (rgba[i + 3] <= 128) continue;
          if (eOro(rgba[i], rgba[i + 1], rgba[i + 2])) {
            muro[(y - y0) * lf + (x - x0)] = 1;
          }
        }
      }
      for (var g = 0; g < regola.saldaturaDelMuro; g++) {
        muro = _gonfia(muro, lf, af);
      }
    }

    // LA MASCHERA DEL LIBERO, calcolata solo dentro la finestra.
    var libero = Uint8List(lf * af);
    for (var y = y0; y <= y1; y++) {
      for (var x = x0; x <= x1; x++) {
        final i = (y * larghezza + x) * 4;
        if (rgba[i + 3] <= 128) continue;
        if (regola.saldaturaDelMuro > 0) {
          if (muro[(y - y0) * lf + (x - x0)] == 1) continue;
        } else if (eOro(rgba[i], rgba[i + 1], rgba[i + 2])) {
          continue;
        }
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
      colore: _colore(rgba, punti),
    );
  }

  /// **QUANTI PIXEL SERVONO PERCHE' UN COLORE SIA UN COLORE.** Sotto questa
  /// soglia la mediana la decidono pochi pixel e un elemento minuscolo mezzo
  /// coperto dall'oro darebbe il colore dell'oro. Venti e' la stessa soglia che
  /// [CrescitaDellaForma.materia] usa attorno al seme, e vale per la stessa
  /// ragione: non e' un numero nuovo.
  static const int pixelMinimiPerIlColore = 20;

  /// IL COLORE DELLA MATERIA DENTRO LA FORMA, mediano per canale.
  ///
  /// **L'oro si esclude prima di misurare.** Le venature incise stanno dentro la
  /// forma, e sono esattamente il colore che questa luce non deve avere: se
  /// entrassero nel conto la cura riporterebbe la malattia.
  static List<int>? _colore(Uint8List rgba, List<int> punti) {
    final r = <int>[], g = <int>[], b = <int>[];
    for (final p in punti) {
      final i = p * 4;
      if (rgba[i + 3] <= 128) continue;
      if (eOro(rgba[i], rgba[i + 1], rgba[i + 2])) continue;
      r.add(rgba[i]);
      g.add(rgba[i + 1]);
      b.add(rgba[i + 2]);
    }
    if (r.length < pixelMinimiPerIlColore) return null;
    r.sort();
    g.sort();
    b.sort();
    return [r[r.length ~/ 2], g[g.length ~/ 2], b[b.length ~/ 2]];
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

  /// **FUORI DALLA FINESTRA VALE PIENO, NON VUOTO.** Ordine Z voce 01.
  ///
  /// **Il difetto che questa riga aveva, e non era del Loto ma del meccanismo.**
  /// Prima un vicino fuori dai bordi contava come assenza, quindi ogni pixel
  /// sull'anello di bordo veniva eroso SEMPRE. Insieme alla gonfiatura che lo
  /// precede, questo voleva dire che con una chiusura qualunque la maschera del
  /// libero **non toccava piu' il bordo della finestra**, e il controllo che
  /// dichiara una colata, cioe' "la regione arriva fino al bordo", non poteva
  /// piu' accendersi.
  ///
  /// **Un parametro che migliorava il numero da guardare togliendo la corrente
  /// al termometro.** Sul Loto il conteggio saliva da 22 forme a 50 non perche'
  /// le forme si chiudessero, ma perche' ventotto colate smettevano di essere
  /// respinte: misurato, a chiusura 0 quella guardia sparava 28 volte, a
  /// chiusura 1 zero volte.
  ///
  /// **Fuori dalla finestra non c'e' il vuoto, c'e' il resto dell'arte**, che la
  /// finestra ha tagliato via per non far costare troppo la crescita. Contarlo
  /// come materia e' la lettura giusta: cosi' l'erosione non si mangia l'anello
  /// di bordo, la chiusura continua a sigillare le fessure interne che e' cio'
  /// per cui esiste, e una maschera che tocca il bordo davvero continua a
  /// toccarlo. Una maschera piena resta piena, ed e' la riga che lo sorveglia in
  /// `test/la_chiusura_non_si_mangia_il_bordo_test.dart`.
  static Uint8List _sgonfia(Uint8List m, int w, int h) {
    final f = Uint8List(w * h);
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final i = y * w + x;
        if (m[i] == 0) continue;
        final su = y > 0 ? m[i - w] : 1;
        final giu = y + 1 < h ? m[i + w] : 1;
        final sin = x > 0 ? m[i - 1] : 1;
        final des = x + 1 < w ? m[i + 1] : 1;
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
      // **IL RIPIEGO NON HA COLORE, e si scrive invece di lasciarlo capire.**
      // Qui sotto non c'e' un elemento cresciuto: c'e' un disco tirato attorno
      // al seme perche' la crescita non si e' chiusa. Misurare il colore dentro
      // quel disco darebbe il colore di cio' su cui il seme e' caduto, che sul
      // Loto e' spesso la filigrana d'oro fra due petali. Sarebbe un valore
      // plausibile e falso, e chi disegna deve poter tornare all'oro sapendolo.
      colore: null,
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
