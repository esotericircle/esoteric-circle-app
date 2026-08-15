library;

import 'dart:math' as math;

import 'forma_dell_elemento.dart';
import 'lettura_degli_ancoraggi.dart';
import 'sentieri.dart';

/// COME SI RICONOSCE UN TRAGUARDO SU CIASCUNA DELLE TRE ARTI. Ordine T voce 01.
///
/// **Una regola per sentiero, perche' le tre arti non si somigliano.** Sul
/// sentiero di Caligo le sfere sono GRIGIE in mezzo all'oro e al rosso: il segno
/// e' l'assenza di colore, non la sua presenza. Sui due sentieri che passano
/// dalla strada dei pallini il segno e' il colore pieno di un pallino.
///
/// **La regola sta qui e non dentro il lettore**, cosi' un sentiero nuovo si
/// aggiunge in un punto solo e il codice che conta non si tocca.
class RegoleDelleTreArti {
  const RegoleDelleTreArti._();

  /// DOVE STA L'ARTE di un sentiero.
  static String arteDi(Sentiero sentiero) =>
      'brand_assets/sentieri/${_nomeDelFile(sentiero)}.png';

  /// DOVE STAREBBE IL LIVELLO DEI PALLINI, se quel sentiero ne ha bisogno.
  static String palliniDi(Sentiero sentiero) =>
      'brand_assets/sentieri/${_nomeDelFile(sentiero)}_pallini.png';

  static String _nomeDelFile(Sentiero sentiero) => switch (sentiero) {
        Sentiero.costellazione => 'costellazione',
        Sentiero.albero => 'albero',
        Sentiero.loto => 'loto',
      };

  /// **L'ALBERO DELLA VITA: le sfere sono NEUTRE in mezzo a un'arte calda.**
  ///
  /// Misurato sull'arte vera prima di scrivere la regola: una sfera vale
  /// rgb 195/175/173 oppure 163/149/137, cioe' rosso e blu quasi uguali; l'oro
  /// che le circonda vale 130/62/15, con centoquindici punti fra rosso e blu.
  /// **Il segno e' l'assenza di colore, e regge su tutte e cinquantacinque.**
  ///
  /// La luminanza minima toglie l'ombra: il nero fra un ramo e l'altro e' neutro
  /// anche lui, ma non e' una sfera.
  static final RegolaDiRiconoscimento albero = RegolaDiRiconoscimento(
    nome: 'albero, le sfere neutre in mezzo all\'oro',
    riconosci: (r, g, b, a) {
      if (a <= 200) return false;
      final massimo = r > g ? (r > b ? r : b) : (g > b ? g : b);
      final minimo = r < g ? (r < b ? r : b) : (g < b ? g : b);
      final luminanza = (r * 299 + g * 587 + b * 114) ~/ 1000;
      if (luminanza <= 45) return false;
      // Croma sotto il trenta per cento del canale piu' alto: neutro.
      return (massimo - minimo) * 100 < 30 * (massimo < 1 ? 1 : massimo);
    },
    // **VENTI PIXEL, e non viene da cio' che si e' misurato.** Sull'arte a 941
    // di larghezza venti pixel sono poco piu' di un fiammifero: sotto questa
    // misura non si sta guardando una sfera ma un riflesso su un ramo. La sfera
    // piccola vera ne misura una trentina, la grande una sessantina.
    diametroMinimo: 20,
  );

  /// **LA REGOLA DEI PALLINI**, quella della strada B.
  ///
  /// Il livello dei pallini e' un PNG alla stessa misura dell'arte, con
  /// cinquantacinque pallini pieni su fondo trasparente. Qui basta l'opacita':
  /// tutto cio' che e' opaco e' un pallino, e il colore dice a quale gruppo
  /// appartiene. **Il gruppo NON si ricava dal colore in questo punto**, si
  /// ricava dalla vicinanza al grande come sugli altri sentieri: il colore resta
  /// il modo con cui Mauro tiene il conto mentre disegna, e una prova lo
  /// confronta col gruppo trovato.
  static final RegolaDiRiconoscimento pallini = RegolaDiRiconoscimento(
    nome: 'pallini, un livello a parte',
    riconosci: (r, g, b, a) => a > 128,
    diametroMinimo: 12,
    // Un pallino pieno riempie il suo riquadro quasi del tutto: chiedere di
    // piu' che sull'arte e' giusto, perche' qui non ci sono ombre.
    pienoMinimo: 0.60,
    quadroMinimo: 0.70,
  );

  /// LA REGOLA IN USO per un sentiero, oggi.
  static RegolaDiRiconoscimento per(Sentiero sentiero) =>
      switch (sorgenteDi(sentiero)) {
        SorgenteDegliAncoraggi.arte => albero,
        SorgenteDegliAncoraggi.pallini => pallini,
      };

  /// **DA DOVE VENGONO GLI ANCORAGGI DI CIASCUN SENTIERO, e il perche' di
  /// ognuno.** Ordine T voce 02.
  ///
  /// **E' un dato, non un "se" sparso nel codice**: se un giorno l'Albero avesse
  /// il suo file di pallini, si cambia questa riga e nient'altro.
  ///
  /// - **Albero, dall'arte**: le sfere sono grigie in mezzo a un disegno caldo,
  ///   e la lettura automatica trova le cinquantacinque macchie con un baratro
  ///   fra grandi e piccoli. Chiusa nella voce T.01 e non si tocca.
  /// - **Costellazione e Loto, dai pallini**: sulla costellazione gli orbi di
  ///   lapis sono spezzati dai riflessi dorati e le mezzelune portano lo stesso
  ///   smalto blu; sul loto i petali si toccano fra loro e le foglie decorative
  ///   hanno lo stesso verde e la stessa forma. Cinque strade automatiche
  ///   misurate, nessuna arriva: il file dei pallini non e' un ripiego, e' il
  ///   dato che l'arte non porta.
  static SorgenteDegliAncoraggi sorgenteDi(Sentiero sentiero) =>
      switch (sentiero) {
        Sentiero.albero => SorgenteDegliAncoraggi.arte,
        Sentiero.costellazione => SorgenteDegliAncoraggi.pallini,
        Sentiero.loto => SorgenteDegliAncoraggi.pallini,
      };

  /// **COME CRESCE UNA FORMA SU CIASCUNA ARTE.** Ordine T voce 02.
  ///
  /// **Il muro e' sempre l'oro, riconosciuto dalla TINTA**, e questa parte e'
  /// uguale per tutte e tre. Cio' che cambia e' se all'oro serve un aiuto, e i
  /// numeri vengono da una misura fatta prima di scriverli.
  ///
  /// - **Albero: solo l'oro, con una chiusura di 3.** La sfera e' cinta da un
  ///   anello d'oro che chiude da solo; la chiusura scavalca le sottili nervature
  ///   dorate che attraversano la pietra. Cosi' le forme sono 55 su 55, mediana
  ///   1.686 pixel. Senza chiusura sarebbero 54.
  /// - **Costellazione: solo l'oro, nessuna chiusura.** L'orbo di lapis sta
  ///   dentro un castone d'oro chiuso: 55 forme su 55, mediana 1.788 pixel.
  /// - **Loto: l'oro NON basta, e serve anche la materia, con tolleranza 110.**
  ///   I petali si toccano e dove il contorno inciso si assottiglia la crescita
  ///   passa nel petalo accanto e poi nelle foglie: col solo oro escono 4 forme
  ///   su 55, con l'oro piu' la materia diventano 22, mediana 4.297 pixel, che
  ///   e' l'ordine di grandezza di un petalo.
  ///
  /// **I TRENTATRE RIPIEGHI DEL LOTO NON SI NASCONDONO, e la loro causa e' stata
  /// riscritta il 15 agosto 2026 con l'ordine Y voce 02, perche' quella che stava
  /// qui era FALSA.** Diceva che i semi del file dei pallini cadono sulla
  /// filigrana d'oro fra un petalo e l'altro. Misurato seme per seme: **solo
  /// CINQUE semi stanno sull'oro, e sono i cinque centri dei fiori**; nessuno dei
  /// ventotto petali caduti ha il seme sull'oro, e ventidue semi altrettanto
  /// verdi crescono benissimo. La posizione dei semi spiega cinque ripieghi su
  /// trentatre e nessuno dei petali.
  ///
  /// **LE TRENTATRE CAUSE, CONTATE UNA A UNA strumentando la crescita:** 28 escono
  /// dalla finestra, cioe' la regione non si chiude e corre via; 4 non trovano un
  /// pixel libero vicino al seme; 1 chiude su un'area di un pixel solo. Le ultime
  /// cinque sono i centri, e non sono correggibili spostando un pallino: il
  /// bottone centrale e' d'oro, cioe' e' il muro, e la materia di riferimento
  /// viene letta SUL SEME, quindi la crescita va a cercare materia dorata mentre
  /// la regola dell'oro gliela vieta. E' una contraddizione che puo' solo
  /// ripiegare.
  ///
  /// **PERCHE' LA CHIUSURA NON E' LA CURA, e va scritto perche' il conteggio dice
  /// il contrario.** Portando la chiusura del Loto a 1, 2, 3, 4 o 5 le forme
  /// diventano 50 su 55 a ogni valore, e sembra la soluzione. Non lo e': l'area
  /// mediana passa da 4.297 a 14.613 col valore piu' piccolo e a 21.327 col piu'
  /// grande, cioe' da un petalo a tre volte e mezzo un petalo. **Il conteggio
  /// migliora perche' la chiusura SPEGNE LA GUARDIA DELLA COLATA**: l'erosione
  /// azzera l'anello esterno della finestra, perche' i vicini fuori bordo contano
  /// come vuoto, quindi dopo una chiusura la maschera non tocca piu' il bordo e
  /// il controllo "esce dalla finestra" non puo' piu' essere vero. Misurato: a
  /// chiusura 0 quella guardia spara 28 volte, a chiusura 1 spara zero volte.
  /// **Una forma che invade il petalo vicino e' peggio di un ripiego, perche' il
  /// ripiego si dichiara e l'invasione no.**
  ///
  /// **La stessa guardia e' spenta anche sull'Albero**, che la chiusura ce l'ha a
  /// 3 dalla voce T.02, e li' si vede: la sua area massima e' 13.045 pixel contro
  /// una mediana di 1.700, cioe' sette volte e mezzo. Senza chiusura quella forma
  /// misura 9.703 contro una mediana di 1.479, quindi l'invasione c'era gia' e la
  /// chiusura l'ha ingrassata. Non e' stato toccato niente: qui si dichiara e
  /// basta, perche' l'Albero non era l'oggetto dell'ordine.
  ///
  /// Il raggio massimo e' il **dodici per cento della larghezza dell'arte**, e
  /// non viene dalle misure: viene da cosa e' un elemento. Un Journal ne porta
  /// cinquantacinque, quindi nessuno puo' allontanarsi dal proprio seme piu' di
  /// una frazione della figura; oltre, non si sta illuminando un elemento ma il
  /// disegno.
  static RegolaDellaForma formaDi(Sentiero sentiero, int larghezzaArte) =>
      RegolaDellaForma(
        tolleranza: switch (sentiero) {
          Sentiero.loto => 110,
          Sentiero.costellazione => 0,
          Sentiero.albero => 0,
        },
        chiusura: switch (sentiero) {
          Sentiero.loto => 0,
          Sentiero.costellazione => 0,
          Sentiero.albero => 3,
        },
        raggioMassimo: (larghezzaArte * 0.12).round(),
        areaMinima: CrescitaDellaForma.areaDelRipiego,
      );

  /// Il file da cui si leggono gli ancoraggi: l'arte stessa oppure i pallini.
  static String daDoveSiLegge(Sentiero sentiero) =>
      switch (sorgenteDi(sentiero)) {
        SorgenteDegliAncoraggi.arte => arteDi(sentiero),
        SorgenteDegliAncoraggi.pallini => palliniDi(sentiero),
      };
}

/// **LA STRUTTURA DEL LOTO, dichiarata da chi ha disegnato l'arte.** Ordine Y
/// voce 01.
///
/// **Non e' un'ipotesi ricavata dai pixel: e' un fatto detto da Mauro.** Il Loto
/// e' fatto di CINQUE FIORI, e ogni fiore ha UN CENTRO e DIECI PETALI attorno.
/// Cinque piu' cinquanta fa cinquantacinque, che e' il numero dei traguardi, e
/// la coincidenza non e' una coincidenza: i traguardi sono stati disposti su
/// questa struttura.
///
/// **A cosa serve avere la struttura come DATO invece che come commento.** Fino
/// a ieri il difetto del Loto si riportava come "22 forme su 55", che dice che
/// c'e' un problema e non dice dove. Con i fiori e i petali si dice quale fiore
/// e quale petalo, e chi deve correggere a mano ne marca pochi invece di
/// cinquanta al buio.
///
/// **UNA TRAPPOLA, e sta scritta qui perche' non ci caschi il prossimo.**
/// Attorno al bottone centrale di ogni fiore c'e' una corona interna di petali
/// piccoli, tutti d'oro, che NON sono i dieci. I dieci sono i petali VERDI e
/// grandi, ognuno con la sua venatura dorata al centro. Un conteggio fatto sui
/// pixel dell'arte che ne trovasse venti per fiore starebbe contando anche la
/// corona dorata. **Qui non si contano i petali sull'arte**: si contano gli
/// ancoraggi, che vengono dal file dei pallini, quindi la trappola non morde da
/// questa parte. Morderebbe il giorno in cui qualcuno provasse a ricavare la
/// struttura dall'immagine.
class StrutturaDelLoto {
  const StrutturaDelLoto._();

  /// Quanti fiori porta il Loto.
  static const int quantiFiori = 5;

  /// Quanti petali ha ogni fiore, oltre al centro.
  static const int petaliPerFiore = 10;

  /// **I PETALI DI UN FIORE, IN SENSO ORARIO DAL PIU' IN ALTO**, come indici
  /// dentro la lista intera degli ancoraggi.
  ///
  /// **Il verso e il punto di partenza si dichiarano perche' un numero di petalo
  /// senza di essi non vuol dire niente**: chi legge "fiore 2, petalo 7" deve
  /// poterlo trovare sull'immagine senza chiedere.
  ///
  /// L'angolo si misura in PIXEL e non nelle coordinate relative: l'arte e' alta
  /// quasi il doppio di quanto e' larga, e su coordinate relative un fiore tondo
  /// sembrerebbe schiacciato e l'ordine attorno al giro cambierebbe.
  static List<int> petaliInSensoOrario(
    List<AncoraggioDelSentiero> ancoraggi,
    int fiore, {
    required int larghezzaArte,
    required int altezzaArte,
  }) {
    final centro = centroDi(ancoraggi, fiore);
    if (centro < 0) return const [];
    final cx = ancoraggi[centro].x * larghezzaArte;
    final cy = ancoraggi[centro].y * altezzaArte;
    final petali = <int>[];
    for (var i = 0; i < ancoraggi.length; i++) {
      if (ancoraggi[i].gruppo != fiore || ancoraggi[i].eGrande) continue;
      petali.add(i);
    }
    petali.sort((a, b) {
      // Zero in cima, e cresce girando in senso orario.
      double giro(int i) {
        final dx = ancoraggi[i].x * larghezzaArte - cx;
        final dy = ancoraggi[i].y * altezzaArte - cy;
        final ang = math.atan2(dx, -dy);
        return ang < 0 ? ang + 2 * math.pi : ang;
      }

      return giro(a).compareTo(giro(b));
    });
    return petali;
  }

  /// Il centro di un fiore, come indice dentro la lista intera.
  static int centroDi(List<AncoraggioDelSentiero> ancoraggi, int fiore) =>
      ancoraggi.indexWhere((a) => a.gruppo == fiore && a.eGrande);
}

/// Le due strade per sapere dove stanno i cinquantacinque elementi.
enum SorgenteDegliAncoraggi {
  /// Si riconoscono dentro l'arte stessa.
  arte,

  /// Si leggono da un secondo PNG con cinquantacinque dischi pieni, cinque
  /// colori per i cinque gruppi, il grande di diametro doppio.
  pallini,
}
