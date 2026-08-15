library;

import 'dart:math' as math;
import 'dart:typed_data';

/// LEGGERE I CINQUANTACINQUE ANCORAGGI DALL'ARTE. Ordine T voce 01.
///
/// **Perche' esiste.** I tre Journal si disegnano da immagini prodotte da Mauro.
/// L'immagine porta i cinquantacinque elementi gia' disegnati SPENTI: il codice
/// deve sapere DOVE sono, per accenderli. Fin qui le posizioni erano calcolate
/// da una formula dentro `GeometriaDelSentiero`: una formula non sa dove Mauro
/// ha messo una sfera, quindi le posizioni si ricavano dall'immagine.
///
/// **Il lavoro NON si fa a ogni apertura della schermata.** Riconoscere le
/// macchie su un milione e mezzo di pixel costa troppo per farlo mentre qualcuno
/// guarda: si fa una volta con `tool/ancoraggi_dai_sentieri.dart`, che scrive il
/// dato, e una prova rifa' la lettura e confronta. E' lo stesso patto dei
/// documenti generati (`docs/responsi/lunghezze.md`): il dato sta nel repository,
/// e chi lo cambia senza rifare la lettura trova una riga rossa.
///
/// **Due strade, e la seconda costa lavoro a Mauro.** La strada AUTOMATICA
/// riconosce gli elementi dall'arte stessa. Dove l'arte non lo consente, la
/// strada DEI PALLINI legge un secondo PNG con cinquantacinque pallini pieni,
/// cinque colori per i cinque gruppi. Si chiede solo dove serve davvero.

/// UN ANCORAGGIO: dove sta un traguardo sull'immagine, e chi e'.
class AncoraggioDelSentiero {
  const AncoraggioDelSentiero({
    required this.x,
    required this.y,
    required this.gruppo,
    required this.eGrande,
  });

  /// **COORDINATE RELATIVE fra 0 e 1**, non pixel: l'immagine si monta a
  /// qualunque misura di schermo e l'ancoraggio la segue senza conti nuovi.
  final double x;
  final double y;

  /// Il gruppo di appartenenza, da 0 a 4, contato **dal basso verso l'alto**
  /// perche' il cammino sale.
  final int gruppo;

  /// Vero per l'undicesimo elemento del gruppo, quello che lo chiude.
  final bool eGrande;

  @override
  String toString() => 'Ancoraggio(${x.toStringAsFixed(4)}, '
      '${y.toStringAsFixed(4)}, gruppo $gruppo, '
      '${eGrande ? "grande" : "piccolo"})';
}

/// QUANDO LA LETTURA NON TORNA, si cade PARLANDO.
///
/// **Il messaggio serve a Mauro, non a Code.** Dice quale gruppo e quanti
/// elementi ci ha trovato dentro, perche' e' l'unica informazione con cui si
/// corregge un'immagine: "non ho trovato cinquantacinque punti" non si corregge.
class AncoraggiNonValidi implements Exception {
  AncoraggiNonValidi(this.messaggio);
  final String messaggio;
  @override
  String toString() => 'AncoraggiNonValidi: $messaggio';
}

/// UNA MACCHIA trovata sull'immagine, prima di sapere chi e'.
class MacchiaDellArte {
  const MacchiaDellArte({
    required this.area,
    required this.cx,
    required this.cy,
    required this.larghezza,
    required this.altezza,
    required this.rosso,
    required this.verde,
    required this.blu,
  });

  final int area;
  final double cx;
  final double cy;
  final int larghezza;
  final int altezza;

  /// Il colore MEDIO della macchia: serve alla strada dei pallini, dove il
  /// colore E' il gruppo.
  final int rosso;
  final int verde;
  final int blu;

  /// Quanto la macchia riempie il suo riquadro: un tondo sta sopra 0,5, una
  /// linea sottile molto sotto.
  double get pieno => area / (larghezza * altezza);

  /// Quanto il riquadro e' quadrato: un tondo vale quasi 1, un ramo quasi 0.
  double get quadro =>
      math.min(larghezza, altezza) / math.max(larghezza, altezza);

  /// Il diametro, cioe' il lato lungo del riquadro.
  int get diametro => math.max(larghezza, altezza);
}

/// COME SI RICONOSCE UN ELEMENTO SU QUESTA IMMAGINE.
///
/// Una regola per sentiero, perche' le tre arti non si somigliano: sull'Albero
/// le sfere sono grigie in mezzo all'oro, sui pallini il segno e' il colore
/// pieno. **La regola sta nel dato e non dentro il lettore**, cosi' aggiungere
/// un sentiero non tocca il codice che conta.
class RegolaDiRiconoscimento {
  const RegolaDiRiconoscimento({
    required this.nome,
    required this.riconosci,
    required this.diametroMinimo,
    this.pienoMinimo = 0.45,
    this.quadroMinimo = 0.55,
  });

  /// Come si chiama questa regola, e finisce nei messaggi di errore.
  final String nome;

  /// Vero se questo pixel appartiene a un elemento.
  final bool Function(int r, int g, int b, int a) riconosci;

  /// **IL DIAMETRO MINIMO IN PIXEL, e non deriva da cio' che si e' misurato.**
  /// Dice quanto e' piccolo un elemento che ha ancora senso chiamare elemento:
  /// sotto questa misura si sta guardando un riflesso su un ramo, non una sfera.
  final int diametroMinimo;

  final double pienoMinimo;
  final double quadroMinimo;

  /// L'area minima che segue dal diametro: il cerchio inscritto nel riquadro.
  int get areaMinima =>
      (math.pi * diametroMinimo * diametroMinimo / 4).floor();
}

/// IL LETTORE.
class LetturaDegliAncoraggi {
  const LetturaDegliAncoraggi._();

  /// Quanti gruppi, e quanti elementi per gruppo. **Non sono numeri liberi:**
  /// sono i cinquantacinque traguardi di un sentiero, dieci piccoli piu' il
  /// grande che li chiude, cinque volte.
  static const int gruppi = 5;
  static const int piccoliPerGruppo = 10;
  static const int perGruppo = piccoliPerGruppo + 1;
  static const int quantiInTutto = gruppi * perGruppo;

  /// **QUANTO E' PIU' GRANDE UN GRANDE**, in rapporto e non in pixel: almeno una
  /// volta e mezzo il diametro mediano dei piccoli. Un rapporto vale a qualunque
  /// risoluzione dell'arte, un numero di pixel no.
  static const double quanteVolteIlGrande = 1.5;

  /// LE MACCHIE dell'immagine, secondo la regola. Componenti connesse a quattro
  /// vicini, senza ricorsione perche' una macchia puo' essere grande.
  static List<MacchiaDellArte> macchie(
    Uint8List rgba,
    int larghezza,
    int altezza,
    RegolaDiRiconoscimento regola,
  ) {
    final dentro = Uint8List(larghezza * altezza);
    for (var i = 0; i < larghezza * altezza; i++) {
      final p = i * 4;
      if (regola.riconosci(rgba[p], rgba[p + 1], rgba[p + 2], rgba[p + 3])) {
        dentro[i] = 1;
      }
    }
    final visto = Uint8List(larghezza * altezza);
    final fuori = <MacchiaDellArte>[];
    final pila = <int>[];
    for (var inizio = 0; inizio < dentro.length; inizio++) {
      if (dentro[inizio] == 0 || visto[inizio] == 1) continue;
      pila
        ..clear()
        ..add(inizio);
      visto[inizio] = 1;
      var area = 0;
      var sommaX = 0, sommaY = 0;
      var sommaR = 0, sommaG = 0, sommaB = 0;
      var minX = larghezza, maxX = -1, minY = altezza, maxY = -1;
      while (pila.isNotEmpty) {
        final i = pila.removeLast();
        final x = i % larghezza, y = i ~/ larghezza;
        area++;
        sommaX += x;
        sommaY += y;
        final p = i * 4;
        sommaR += rgba[p];
        sommaG += rgba[p + 1];
        sommaB += rgba[p + 2];
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
        if (x > 0 && dentro[i - 1] == 1 && visto[i - 1] == 0) {
          visto[i - 1] = 1;
          pila.add(i - 1);
        }
        if (x + 1 < larghezza && dentro[i + 1] == 1 && visto[i + 1] == 0) {
          visto[i + 1] = 1;
          pila.add(i + 1);
        }
        final su = i - larghezza, giu = i + larghezza;
        if (su >= 0 && dentro[su] == 1 && visto[su] == 0) {
          visto[su] = 1;
          pila.add(su);
        }
        if (giu < dentro.length && dentro[giu] == 1 && visto[giu] == 0) {
          visto[giu] = 1;
          pila.add(giu);
        }
      }
      fuori.add(MacchiaDellArte(
        area: area,
        cx: sommaX / area,
        cy: sommaY / area,
        larghezza: maxX - minX + 1,
        altezza: maxY - minY + 1,
        rosso: sommaR ~/ area,
        verde: sommaG ~/ area,
        blu: sommaB ~/ area,
      ));
    }
    return fuori;
  }

  /// LE MACCHIE CHE SONO ELEMENTI: abbastanza grandi, abbastanza tonde.
  static List<MacchiaDellArte> elementi(
    List<MacchiaDellArte> tutte,
    RegolaDiRiconoscimento regola,
  ) =>
      tutte
          .where((m) =>
              m.area >= regola.areaMinima &&
              m.pieno >= regola.pienoMinimo &&
              m.quadro >= regola.quadroMinimo)
          .toList();

  /// **LA LETTURA INTERA**, dall'immagine ai cinquantacinque ancoraggi ordinati.
  ///
  /// Cade parlando a ogni passo in cui il conto non torna.
  static List<AncoraggioDelSentiero> leggi(
    Uint8List rgba,
    int larghezza,
    int altezza,
    RegolaDiRiconoscimento regola, {
    bool raggruppaPerColore = false,
  }) {
    final trovate = elementi(macchie(rgba, larghezza, altezza, regola), regola);
    if (trovate.length != quantiInTutto) {
      throw AncoraggiNonValidi(
          'la regola "${regola.nome}" ha trovato ${trovate.length} elementi '
          'invece di $quantiInTutto. I diametri trovati, dal più grande: '
          '${(trovate.map((m) => m.diametro).toList()..sort((a, b) => b - a)).take(12).join(", ")}');
    }
    return componi(trovate, larghezza, altezza, regola.nome,
        raggruppaPerColore: raggruppaPerColore);
  }

  /// DAI CINQUANTACINQUE ELEMENTI AGLI ANCORAGGI: chi e' grande, di che gruppo
  /// e' e in che ordine viene. **Mauro non numera niente: l'ordine si ricava.**
  static List<AncoraggioDelSentiero> componi(
    List<MacchiaDellArte> trovate,
    int larghezza,
    int altezza,
    String nome, {
    bool raggruppaPerColore = false,
  }) {
    // CHI E' GRANDE. Il confine e' un RAPPORTO col diametro mediano, non una
    // misura in pixel: cosi' la regola vale anche se l'arte cambia risoluzione.
    final diametri = trovate.map((m) => m.diametro).toList()..sort();
    final mediana = diametri[diametri.length ~/ 2];
    final confine = mediana * quanteVolteIlGrande;
    final grandi = trovate.where((m) => m.diametro >= confine).toList();
    final piccoli = trovate.where((m) => m.diametro < confine).toList();
    if (grandi.length != gruppi) {
      throw AncoraggiNonValidi(
          '"$nome": gli elementi grandi sono ${grandi.length} invece di '
          '$gruppi. Grande vuol dire largo almeno $quanteVolteIlGrande volte il '
          'diametro mediano, che qui è $mediana pixel, cioè almeno '
          '${confine.toStringAsFixed(0)}. I diametri: '
          '${(trovate.map((m) => m.diametro).toList()..sort((a, b) => b - a)).join(", ")}');
    }

    // I GRUPPI, in due modi e non uno solo, perche' le due strade portano due
    // informazioni diverse.
    //
    // **SULL'ARTE la vicinanza e' l'unica cosa che c'e'**: ogni piccolo va al
    // grande piu' vicino, e il grande e' il centro della sua parte per
    // costruzione del disegno.
    //
    // **SUL FILE DEI PALLINI il gruppo e' DICHIARATO dal colore**, ed e' un dato
    // migliore di una distanza: chi ha disegnato quel file sa quale pallino
    // appartiene a quale figura, e su un loto due petali di fiori diversi
    // possono essere piu' vicini fra loro che al proprio cuore.
    final diChi = <int, List<MacchiaDellArte>>{
      for (var i = 0; i < gruppi; i++) i: <MacchiaDellArte>[]
    };
    for (final p in piccoli) {
      var quale = 0;
      if (raggruppaPerColore) {
        var minima = 1 << 30;
        for (var i = 0; i < grandi.length; i++) {
          final d = (p.rosso - grandi[i].rosso).abs() +
              (p.verde - grandi[i].verde).abs() +
              (p.blu - grandi[i].blu).abs();
          if (d < minima) {
            minima = d;
            quale = i;
          }
        }
      } else {
        var minima = double.infinity;
        for (var i = 0; i < grandi.length; i++) {
          final d = (p.cx - grandi[i].cx) * (p.cx - grandi[i].cx) +
              (p.cy - grandi[i].cy) * (p.cy - grandi[i].cy);
          if (d < minima) {
            minima = d;
            quale = i;
          }
        }
      }
      diChi[quale]!.add(p);
    }
    for (var i = 0; i < gruppi; i++) {
      if (diChi[i]!.length != piccoliPerGruppo) {
        throw AncoraggiNonValidi(
            '"$nome": il gruppo attorno al grande in '
            '(${grandi[i].cx.toStringAsFixed(0)}, '
            '${grandi[i].cy.toStringAsFixed(0)}) ha ${diChi[i]!.length} '
            'elementi piccoli invece di $piccoliPerGruppo. Gli altri gruppi ne '
            'hanno ${[
          for (var k = 0; k < gruppi; k++)
            if (k != i) diChi[k]!.length
        ].join(", ")}');
      }
    }

    // L'ORDINE DEI GRUPPI: dal basso verso l'alto, perche' il cammino sale.
    final ordineDeiGruppi = List.generate(gruppi, (i) => i)
      ..sort((a, b) => grandi[b].cy.compareTo(grandi[a].cy));

    final fuori = <AncoraggioDelSentiero>[];
    for (var g = 0; g < gruppi; g++) {
      final quale = ordineDeiGruppi[g];
      final grande = grandi[quale];
      // DENTRO UN GRUPPO: in senso orario attorno al grande, dal piu' in alto.
      // L'angolo si misura da mezzogiorno e cresce verso destra, che e' il verso
      // dell'orologio su uno schermo, dove la y cresce verso il basso.
      final ordinati = diChi[quale]!.toList()
        ..sort((a, b) =>
            _oraDellOrologio(a, grande).compareTo(_oraDellOrologio(b, grande)));
      for (final p in ordinati) {
        fuori.add(AncoraggioDelSentiero(
          x: p.cx / larghezza,
          y: p.cy / altezza,
          gruppo: g,
          eGrande: false,
        ));
      }
      fuori.add(AncoraggioDelSentiero(
        x: grande.cx / larghezza,
        y: grande.cy / altezza,
        gruppo: g,
        eGrande: true,
      ));
    }
    convalida(fuori, larghezza, altezza, nome);
    return fuori;
  }

  /// L'angolo dell'orologio, da mezzogiorno in senso orario, fra 0 e 2 pi.
  static double _oraDellOrologio(MacchiaDellArte p, MacchiaDellArte centro) {
    final dx = p.cx - centro.cx;
    // La y cresce verso il basso, quindi "in alto" e' dy negativo.
    final dy = p.cy - centro.cy;
    final a = math.atan2(dx, -dy);
    return a < 0 ? a + 2 * math.pi : a;
  }

  /// **LE QUATTRO COSE CHE NON POSSONO ESSERE VERE INSIEME AGLI ANCORAGGI.**
  ///
  /// Si cade parlando: il messaggio dice quale gruppo e quanti punti ha, perche'
  /// serve a Mauro per correggere l'immagine.
  static void convalida(
    List<AncoraggioDelSentiero> ancoraggi,
    int larghezza,
    int altezza,
    String nome,
  ) {
    if (ancoraggi.length != quantiInTutto) {
      throw AncoraggiNonValidi(
          '"$nome": gli ancoraggi sono ${ancoraggi.length} invece di '
          '$quantiInTutto');
    }
    final perGruppoConto = <int, int>{};
    final grandiPerGruppo = <int, int>{};
    for (final a in ancoraggi) {
      perGruppoConto[a.gruppo] = (perGruppoConto[a.gruppo] ?? 0) + 1;
      if (a.eGrande) {
        grandiPerGruppo[a.gruppo] = (grandiPerGruppo[a.gruppo] ?? 0) + 1;
      }
    }
    if (perGruppoConto.length != gruppi) {
      throw AncoraggiNonValidi('"$nome": i gruppi sono '
          '${perGruppoConto.length} invece di $gruppi. Sono '
          '${perGruppoConto.keys.toList()}');
    }
    for (var g = 0; g < gruppi; g++) {
      if (perGruppoConto[g] != perGruppo) {
        throw AncoraggiNonValidi('"$nome": il gruppo $g ha '
            '${perGruppoConto[g]} punti invece di $perGruppo');
      }
      if (grandiPerGruppo[g] != 1) {
        throw AncoraggiNonValidi('"$nome": il gruppo $g ha '
            '${grandiPerGruppo[g] ?? 0} elementi grandi invece di uno solo');
      }
    }
    for (var i = 0; i < ancoraggi.length; i++) {
      final a = ancoraggi[i];
      if (a.x < 0 || a.x > 1 || a.y < 0 || a.y > 1) {
        throw AncoraggiNonValidi('"$nome": il punto numero ${i + 1}, gruppo '
            '${a.gruppo}, cade fuori dalla tela: '
            '(${a.x.toStringAsFixed(3)}, ${a.y.toStringAsFixed(3)})');
      }
    }
    // NESSUNA SOVRAPPOSIZIONE. La distanza si misura in pixel dell'arte, perche'
    // e' li' che due elementi si toccano davvero.
    for (var i = 0; i < ancoraggi.length; i++) {
      for (var k = i + 1; k < ancoraggi.length; k++) {
        final dx = (ancoraggi[i].x - ancoraggi[k].x) * larghezza;
        final dy = (ancoraggi[i].y - ancoraggi[k].y) * altezza;
        final d = math.sqrt(dx * dx + dy * dy);
        if (d < distanzaMinimaInPixel) {
          throw AncoraggiNonValidi('"$nome": i punti numero ${i + 1} (gruppo '
              '${ancoraggi[i].gruppo}) e ${k + 1} (gruppo '
              '${ancoraggi[k].gruppo}) distano ${d.toStringAsFixed(1)} pixel, '
              'meno di $distanzaMinimaInPixel: sono lo stesso elemento contato '
              'due volte, oppure due elementi che si toccano');
        }
      }
    }
  }

  /// **QUANTO DEVONO DISTARE DUE ELEMENTI, dichiarato e non misurato.**
  ///
  /// Venti pixel sull'arte a 941 di larghezza: e' la misura sotto la quale due
  /// centri non sono due elementi vicini ma lo stesso elemento riconosciuto due
  /// volte. Non viene dalla distanza piu' corta trovata, che sarebbe una soglia
  /// ricavata dalla grandezza che deve giudicare.
  static const double distanzaMinimaInPixel = 20.0;
}
