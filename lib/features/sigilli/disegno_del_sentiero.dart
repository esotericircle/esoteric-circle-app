import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/sigilli/ancoraggi_dei_sentieri.dart';
import '../../core/sigilli/sentieri.dart';
import 'journal_dall_arte.dart';
import '../../design_system/theme/maestro_scope.dart';

/// IL DISEGNO DEI TRE SENTIERI, ordine P voce 33.
///
/// **Il fatto che ha aperto la voce.** `sentiero_screen.dart` montava un
/// `ListView.builder` di `ListTile` con le icone di serie del framework, e i
/// tre sentieri si distinguevano per due cose sole: la palette del Maestro e
/// lo stesso `CosmosBackground(seed: 19)`, cioe' lo stesso campo di stelle
/// soltanto tinto. Nel file non esisteva nessun `CustomPainter`. La sezione 13
/// del Briefing di Progetto non era costruita: i file di dati dei 55 traguardi
/// c'erano, il disegno no.
///
/// **Cosa disegna, e perche' tre disegni e non uno ricolorato.**
///
///   - COSTELLAZIONE DI MEDORA. Ogni mini e' una stella; le stelle accese si
///     uniscono con una linea luminosa; ogni dieci stelle la figura si chiude
///     in una Costellazione, che e' il grande. Le stelle spente esistono nel
///     disegno, in trasparenza, cosi' si vede la forma che manca.
///   - ALBERO DELLA VITA DI CALIGO. Ogni mini e' un frutto su un ramo; i
///     cinque grandi sono le Sefirot che si accendono salendo, fino a Keter
///     come cinquantesimo. Rami e sentieri si vedono anche a frutti spenti.
///   - FIORE DI LOTO DI AURA. Ogni mini e' un petalo che si apre lungo lo
///     stelo; i cinque grandi sono le Fioriture, cinque livelli di apertura.
///     I petali chiusi si vedono.
///
/// **Una geometria sola per il disegno e per il tocco.** I punti si calcolano
/// qui una volta e li leggono sia il pittore sia il riconoscimento del tocco:
/// se fossero due elenchi, prima o poi il tocco cadrebbe accanto alla stella
/// invece che su di lei, e nessuno saprebbe dire quale dei due ha ragione.
/// LE TRE GRANDEZZE DI UN PUNTO, dichiarate come DATO e non scelte a caso.
///
/// **Ordine S voce 02.** Le costellazioni che tutti riconoscono hanno poche
/// stelle principali e decine di stelle deboli attorno: Orione si riconosce da
/// sette punti. Senza gerarchia cinquantacinque punti diventano un groviglio.
/// Quale punto sia di quale grandezza fa parte del disegno della figura, e sta
/// scritto nella geometria accanto al punto.
enum GrandezzaDelPunto {
  /// I CINQUE GRANDI: le stelle che reggono la forma. Ogni grande che si accende
  /// cambia visibilmente la figura, non aggiunge un punto fra tanti.
  principale(0.0290),

  /// Le medie: articolano la figura, cioe' dicono dove una parte comincia.
  media(0.0165),

  /// Le piccole: la riempiono.
  piccola(0.0098);

  const GrandezzaDelPunto(this.raggio);

  /// Quanto e' grande, in frazione del lato corto della tela.
  final double raggio;
}

/// UN SEGMENTO DELL'OSSATURA: due indici nella lista dei punti.
///
/// **Si disegna SOLO se i suoi due capi sono accesi**, ordine S voce 02: con il
/// reticolo intero visibile da subito la forma finale si vede prima di
/// meritarla, e non resta niente da scoprire.
class SegmentoDelSentiero {
  const SegmentoDelSentiero(this.da, this.a, {this.spessore = 1.0});

  final int da;
  final int a;

  /// QUANTO E' SPESSO, in frazione dello spessore normale.
  ///
  /// **Serve all'Albero e non e' un vezzo.** Un ramo con lo spessore costante
  /// dal tronco alla punta non e' un ramo, e' un filo: l'ordine chiede rami che
  /// si assottiglino allontanandosi. Lo spessore fa parte del disegno, quindi
  /// sta nel dato accanto al segmento e non in un conto dentro il pittore.
  final double spessore;
}

class GeometriaDelSentiero {
  const GeometriaDelSentiero._();

  /// I punti del disegno, in coordinate normalizzate fra 0 e 1.
  ///
  /// Deterministici e senza caso: un disegno che cambia a ogni montaggio non
  /// si puo' provare a pixel, e soprattutto non e' piu' il TUO cammino.
  ///
  /// **L'ordine della lista e' quello del cammino**: per ciascuna delle cinque
  /// parti i dieci mini e poi il grande che la chiude. Quindi il punto del
  /// grande della parte i sta all'indice `i * 11 + 10`, e l'ossatura ci conta
  /// sopra.
  /// **NESSUN PUNTO SI NASCONDE SOTTO UN ALTRO.** Ordine AU voce 09.
  ///
  /// **Il censimento ha smentito in parte la premessa, e va detto.** Il
  /// fondatore riferisce che le sfere al centro del fiore non rispondono al
  /// tocco. Misurati tutti e centosessantacinque i bersagli dei tre sentieri,
  /// con un tocco esattamente sul proprio centro, **i cinque grandi rispondono
  /// su tutti e tre**. Chi non risponde e' l'opposto: **dieci mini del Loto e
  /// quattro della Costellazione**, che hanno il proprio centro DENTRO il
  /// cerchio disegnato di un grande. Toccandoli si prende il grande, e a occhio
  /// sembra che il fiore non risponda dove uno crede di toccarlo.
  ///
  /// **La cura non sta nella regola del tocco, sta nella geometria.** L'ordine
  /// AS voce 04 aveva gia' deciso, dopo una misura, che fra due cerchi che
  /// contengono il dito vince il PIU' GRANDE, perche' e' quello che l'occhio
  /// vede: invertire quella regola rimetterebbe il difetto di allora, quattro
  /// grandi su quindici irraggiungibili. Ma un punto il cui centro cade dentro
  /// un altro punto non e' un difetto del tocco: e' un punto **disegnato dove
  /// non si vede**, e nessuna regola di tocco puo' rimediare a una perla
  /// nascosta sotto un'altra.
  ///
  /// Qui i punti si scostano del minimo che serve a uscire, lungo la direzione
  /// che gia' hanno rispetto al vicino piu' grande: la forma resta quella, e
  /// nessuno resta sepolto. Chi e' esattamente sovrapposto si sposta in
  /// diagonale, perche' una direzione bisogna sceglierla.
  static List<PuntoDelSentiero> _nessunoSepolto(List<PuntoDelSentiero> punti) {
    // Si lavora in frazioni di tela, come le posizioni: il lato corto e' 1.
    const aria = 0.004;
    // **PIU' PASSATE, e la prima stesura ne faceva una sola.** Spostare un
    // mini fuori dal grande che lo copriva lo spingeva DENTRO un medio poco
    // piu' in la', e sul Loto i sepolti passavano da dieci a dodici: la cura
    // peggiorava il difetto. Con il rilassamento ogni spostamento si rimisura,
    // e ci si ferma quando nessuno e' piu' sotto nessuno.
    const passate = 24;
    final dove = [for (final p in punti) p.dove];
    for (var giro = 0; giro < passate; giro++) {
      var mosso = false;
      for (var i = 0; i < punti.length; i++) {
        for (var j = 0; j < punti.length; j++) {
          if (i == j) continue;
          // Si sposta il PIU' PICCOLO: la forma la reggono i grandi, e
          // muovere loro sposterebbe la figura invece di liberare un punto.
          // **A PARITA' DI GRANDEZZA SI SPOSTA IL SECONDO**, e serve: sul
          // Loto due perle uguali stavano a un decimo di punto l'una
          // dall'altra, cioe' erano una sola perla a vedersi, e quale delle
          // due rispondesse al dito era una lotteria. La prova le contava
          // buone tutte e due, perche' ciascuna vince sul proprio centro
          // esatto: e' un caso in cui il numero verde nasconde il difetto.
          final piuGrande = punti[j].grandezza.raggio > punti[i].grandezza.raggio;
          final pari = punti[j].grandezza.raggio == punti[i].grandezza.raggio;
          if (!piuGrande && !(pari && j < i)) continue;
          final scarto = dove[i] - dove[j];
          final distanza = scarto.distance;
          // **FRA PARI IL VINCOLO E' MEZZO RAGGIO, e non e' un compromesso
          // al ribasso: e' l'unico risolvibile.** Chiedendo il raggio pieno
          // anche fra uguali, sul Loto una perla veniva spinta fuori da una
          // pari e finiva DENTRO il grande centrale, e il rilassamento non
          // convergeva piu': cinquantaquattro su cinquantacinque. Con mezzo
          // raggio due perle uguali non sono mai la stessa perla, e nessuna
          // finisce sepolta sotto un grande.
          final minima = piuGrande
              ? punti[j].grandezza.raggio + aria
              : punti[j].grandezza.raggio / 2 + aria;
          if (distanza >= minima) continue;
          final verso = distanza < 1e-6
              ? const Offset(0.7071, 0.7071)
              : scarto / distanza;
          dove[i] = dove[j] + verso * minima;
          mosso = true;
        }
      }
      if (!mosso) break;
    }
    // **L'ULTIMA PAROLA E' DEI GRANDI.** Nel rilassamento i due vincoli si
    // rincorrono: una perla spinta via da una pari puo' finire dentro il
    // grande che le sta accanto, ed e' cosi' che `aur_51` restava sepolta
    // sotto `aur_55`. Qui si ripassa una volta sola sul vincolo che conta per
    // l'accettazione, cioe' che nessun punto stia dentro uno piu' grande:
    // l'ultimo movimento libera sempre.
    for (var giro = 0; giro < passate; giro++) {
      var mosso = false;
      for (var i = 0; i < punti.length; i++) {
        for (var j = 0; j < punti.length; j++) {
          if (i == j) continue;
          if (punti[j].grandezza.raggio <= punti[i].grandezza.raggio) continue;
          final scarto = dove[i] - dove[j];
          final distanza = scarto.distance;
          final minima = punti[j].grandezza.raggio + aria;
          if (distanza >= minima) continue;
          final verso = distanza < 1e-6
              ? const Offset(0.7071, 0.7071)
              : scarto / distanza;
          dove[i] = dove[j] + verso * minima;
          mosso = true;
        }
      }
      if (!mosso) break;
    }
    return [
      for (var i = 0; i < punti.length; i++)
        if (dove[i] == punti[i].dove)
          punti[i]
        else
          PuntoDelSentiero(
            traguardo: punti[i].traguardo,
            dove: dove[i],
            grandezza: punti[i].grandezza,
            gruppo: punti[i].gruppo,
            angolo: punti[i].angolo,
          ),
    ];
  }

  static List<PuntoDelSentiero> punti(Sentiero sentiero) =>
      _nessunoSepolto(switch (sentiero) {
        Sentiero.costellazione => _costellazione(),
        Sentiero.albero => _albero(),
        Sentiero.loto => _loto(),
      });

  /// L'OSSATURA della figura: quali punti si uniscono quando sono accesi.
  static List<SegmentoDelSentiero> ossatura(Sentiero sentiero) =>
      switch (sentiero) {
        Sentiero.costellazione => _ossaturaCostellazione(),
        Sentiero.albero => _ossaturaAlbero(),
        Sentiero.loto => _ossaturaLoto(),
      };

  /// L'indice del grande che chiude la parte [parte].
  static int indiceDelGrande(int parte) => parte * 11 + 10;

  /// L'indice del mini [k] della parte [parte].
  static int indiceDelMini(int parte, int k) => parte * 11 + k;

  /// LA TELA E' PIU' ALTA CHE LARGA, e le coordinate sono normalizzate sui due
  /// lati separatamente: uno spostamento di un decimo verso il basso vale piu'
  /// pixel dello stesso spostamento verso destra. Senza questa compressione le
  /// figure si allungherebbero in verticale e nessuna somiglierebbe a se stessa
  /// su uno schermo diverso.
  static const double compressioneVerticale = 0.70;

  /// Per il Loto la conversione e' un'altra: il pittore prende le lunghezze dal
  /// lato corto su tutti e due gli assi, quindi il punto deve fare lo stesso.
  /// Il numero e' il rapporto fra il lato corto e l'altezza della tela del
  /// disegno, 360 su 462 punti: e' la tela vera della voce 01, non una stima.
  static const double misuraQuadra = 0.78;

  /// LA SPINA DORSALE DELLA COSTELLAZIONE: i cinque punti principali.
  ///
  /// **Una figura sola, non cinque figurine.** Prima erano cinque gruppi da
  /// dieci con una forma chiusa ciascuno, sparsi nel cielo: a schermo si
  /// leggevano come cinque figurine slegate, e i cinque grandi come cinque
  /// disegni invece che come i cinque momenti in cui una parte della STESSA
  /// figura si chiude. Adesso i cinque principali stanno su una spina che sale,
  /// e ogni parte cresce da lei.
  ///
  /// La figura e' INVENTATA, perche' e' la costellazione personale e nel cielo
  /// di nessun altro esiste, ma ha la grammatica di una vera: una spina, un
  /// centro (il terzo punto, il piu' alto in luce), e proporzioni credibili.
  static const List<Offset> spinaDellaCostellazione = [
    Offset(0.355, 0.870),
    Offset(0.545, 0.710),
    Offset(0.430, 0.520),
    Offset(0.630, 0.350),
    Offset(0.480, 0.150),
  ];

  /// LE DUE BRACCIA DI OGNI PARTE, in radianti, e la loro lunghezza.
  ///
  /// Zero punta a destra, mezzo pi greco punta in basso. Le direzioni non sono
  /// casuali: la base si allarga come due piedi, il fianco si apre quasi
  /// orizzontale, il cuore alza due ali, la corona si stringe.
  static const List<List<double>> direzioniDelleBraccia = [
    [2.70, 0.50],
    [3.10, 0.05],
    [3.55, -0.45],
    [3.35, 0.60],
    [3.30, -0.20],
  ];

  /// Quanto e' lunga ogni braccia, parte per parte: la figura si stringe
  /// salendo, come tutte le figure che stanno in piedi.
  static const List<double> lunghezzaDelleBraccia = [
    1.00,
    0.92,
    1.08,
    0.84,
    0.66,
  ];

  /// Le cinque distanze dei punti lungo una braccia, dal principale in fuori.
  static const List<double> passiDellaBraccia = [
    0.052,
    0.086,
    0.116,
    0.142,
    0.164,
  ];

  /// L'ARRICCIATURA DI OGNI PARTE, e i due numeri sono per le due braccia.
  ///
  /// **Senza questa tabella le cinque parti erano cinque coppe identiche**, e si
  /// vede nell'anteprima: con la stessa arricciatura specchiata su tutte e cinque
  /// la figura diventava un ritmo, cioe' un motivo decorativo che si ripete, non
  /// una figura. Una costellazione vera non ha due meta' uguali da nessuna parte.
  /// Numeri diversi e segni diversi: una parte si chiude, un'altra si apre, una
  /// terza piega da un lato solo.
  static const List<List<double>> arricciaturaDelleBraccia = [
    [0.16, -0.05],
    [-0.06, 0.14],
    [0.20, 0.20],
    [-0.13, -0.02],
    [0.07, -0.17],
  ];

  /// QUANTO E' LUNGA CIASCUNA DELLE DUE BRACCIA, parte per parte.
  ///
  /// Mai uguali fra loro: due braccia della stessa lunghezza fanno una figura
  /// simmetrica, e nessuna costellazione lo e'.
  static const List<List<double>> respiroDelleBraccia = [
    [1.00, 0.72],
    [0.68, 1.00],
    [0.94, 0.80],
    [1.00, 0.62],
    [0.74, 0.96],
  ];

  static List<PuntoDelSentiero> _costellazione() {
    final mini = Sentieri.miniDi(Sentiero.costellazione);
    final grandi = Sentieri.grandiDi(Sentiero.costellazione);
    final punti = <PuntoDelSentiero>[];
    for (var parte = 0; parte < 5; parte++) {
      final centro = spinaDellaCostellazione[parte];
      final scala = lunghezzaDelleBraccia[parte];
      for (var k = 0; k < 10; k++) {
        final indice = parte * 10 + k;
        // Due braccia da cinque: la prima cresce, poi la seconda. Cosi' la
        // figura si allunga in una direzione e poi nell'altra, e a meta' si
        // capisce da che parte sta andando.
        final quale = k < 5 ? 0 : 1;
        final passo = k % 5;
        // L'arricciatura e il respiro vengono dalle due tabelle: sono il
        // CARATTERE di questa parte, e sono la ragione per cui le cinque non si
        // somigliano.
        final angolo = direzioniDelleBraccia[parte][quale] +
            arricciaturaDelleBraccia[parte][quale] * passo;
        final quanto = passiDellaBraccia[passo] *
            scala *
            respiroDelleBraccia[parte][quale];
        punti.add(PuntoDelSentiero(
          traguardo: mini[indice],
          dove: Offset(
            centro.dx + quanto * math.cos(angolo),
            centro.dy + quanto * math.sin(angolo) * compressioneVerticale,
          ),
          // Il primo punto di ogni braccia e' medio: dice dove la parte
          // comincia. Gli altri quattro la riempiono.
          grandezza:
              passo == 0 ? GrandezzaDelPunto.media : GrandezzaDelPunto.piccola,
          gruppo: parte,
        ));
      }
      punti.add(PuntoDelSentiero(
        traguardo: grandi[parte],
        dove: centro,
        grandezza: GrandezzaDelPunto.principale,
        gruppo: parte,
      ));
    }
    return punti;
  }

  static List<SegmentoDelSentiero> _ossaturaCostellazione() {
    final ossa = <SegmentoDelSentiero>[];
    for (var parte = 0; parte < 5; parte++) {
      final principale = indiceDelGrande(parte);
      // LA SPINA: il principale di questa parte col principale della prossima.
      if (parte < 4) {
        ossa.add(SegmentoDelSentiero(principale, indiceDelGrande(parte + 1)));
      }
      for (final quale in const [0, 1]) {
        // Ogni braccia parte dal principale e si allunga di punto in punto.
        var precedente = principale;
        for (var passo = 0; passo < 5; passo++) {
          final punto = indiceDelMini(parte, quale * 5 + passo);
          ossa.add(SegmentoDelSentiero(precedente, punto));
          precedente = punto;
        }
      }
    }
    return ossa;
  }

  /// Le cinque Sefirot Maggiori sul pilastro centrale, dal Regno alla Corona.
  static const List<double> altezzeDelleSefirot = [0.86, 0.68, 0.50, 0.30, 0.10];

  /// IL CARATTERE DEI CINQUE RAMI: quanto sono lunghi i due lati e quanto
  /// pendono.
  ///
  /// **Senza questa tabella l'Albero era un abete**, e si vede nell'anteprima:
  /// cinque coppie di rami orizzontali, tutte della stessa lunghezza e con la
  /// stessa piega, cioe' uno stampino di albero di Natale. Un albero vero ha rami
  /// disuguali, e i piu' bassi pendono piu' dei piu' alti perche' portano piu'
  /// peso.
  static const List<List<double>> respiroDeiRami = [
    [1.00, 0.78],
    [0.74, 1.00],
    [0.96, 0.86],
    [0.80, 1.00],
    [0.66, 0.72],
  ];

  /// Quanto pende ogni ramo, dal basso in alto: i bassi portano piu' peso.
  static const List<double> pendenzaDeiRami = [0.030, 0.024, 0.017, 0.011, 0.006];

  static List<PuntoDelSentiero> _albero() {
    final mini = Sentieri.miniDi(Sentiero.albero);
    final grandi = Sentieri.grandiDi(Sentiero.albero);
    final punti = <PuntoDelSentiero>[];
    for (var ramo = 0; ramo < 5; ramo++) {
      final cima = altezzeDelleSefirot[ramo];
      // **UN ALBERO SOLO, con le Sefirot sullo stesso tronco.** I dieci frutti
      // di ogni parte stanno su DUE rami che nascono dalla sua Sefirah, non
      // sparsi lungo il fusto: quando la Sefirah si accende, i due rami si
      // attaccano al tronco tutti insieme.
      for (var k = 0; k < 10; k++) {
        final indice = ramo * 10 + k;
        final quale = k < 5 ? 0 : 1;
        final lato = quale == 0 ? -1.0 : 1.0;
        final passo = k % 5;
        // Il ramo si allontana e scende: un frutto pesa, e i rami bassi
        // portano piu' peso.
        final apertura = (0.075 + 0.052 * passo) *
            (1.0 - 0.24 * ramo / 4) *
            respiroDeiRami[ramo][quale];
        // **I RAMI SI ALTERNANO invece di specchiarsi.** Due rami che partono
        // dalla stessa altezza a destra e a sinistra fanno una croce, e cinque
        // croci in colonna fanno un'antenna: l'anteprima lo ha mostrato. Uno
        // parte sotto il nodo e l'altro sopra, e da un ramo all'altro il verso
        // si scambia.
        final scarto = (quale == 0 ? -1.0 : 1.0) *
            (ramo.isEven ? 1.0 : -1.0) *
            0.026 *
            compressioneVerticale;
        final caduta = scarto +
            pendenzaDeiRami[ramo] * passo * compressioneVerticale;
        punti.add(PuntoDelSentiero(
          traguardo: mini[indice],
          dove: Offset(0.5 + lato * apertura, cima + caduta),
          grandezza:
              passo == 0 ? GrandezzaDelPunto.media : GrandezzaDelPunto.piccola,
          gruppo: ramo,
        ));
      }
      punti.add(PuntoDelSentiero(
        traguardo: grandi[ramo],
        dove: Offset(0.5, cima),
        grandezza: GrandezzaDelPunto.principale,
        gruppo: ramo,
      ));
    }
    return punti;
  }

  static List<SegmentoDelSentiero> _ossaturaAlbero() {
    final ossa = <SegmentoDelSentiero>[];
    for (var ramo = 0; ramo < 5; ramo++) {
      // NESSUN SEGMENTO FRA LE SEFIROT: quello e' il TRONCO, che si accende
      // fino a dove sei arrivato. Una linea sopra il tronco sarebbe una seconda
      // spina disegnata sulla prima.
      final sefirah = indiceDelGrande(ramo);
      for (final lato in const [0, 1]) {
        var precedente = sefirah;
        for (var passo = 0; passo < 5; passo++) {
          final frutto = indiceDelMini(ramo, lato * 5 + passo);
          // IL RAMO SI ASSOTTIGLIA: pieno all'attacco col tronco, sottile in
          // punta. Un ramo di spessore costante e' un filo.
          ossa.add(SegmentoDelSentiero(precedente, frutto,
              spessore: 1.45 - 0.22 * passo));
          precedente = frutto;
        }
      }
    }
    return ossa;
  }

  /// IL CUORE DEL LOTO, e sta in BASSO perche' il fiore si guarda di lato.
  ///
  /// **Il loto era un soffione, ed era un guaio doppio.** Cinquanta petali
  /// identici irraggiati da un centro sono una margherita vista dall'alto, e il
  /// soffione nell'app esiste gia': e' il Soffio del Destino, e due soffioni si
  /// pestano i piedi. Un loto ha POCHI PETALI LARGHI E APPUNTITI su pochi giri,
  /// e si guarda di lato, perche' e' un fiore che si apre verso l'alto.
  /// **IL CUORE STA IN BASSO, e lo stelo e' corto.** Ordine S voce 02, punto D:
  /// lo stelo si prendeva mezza tela e il fiore restava un francobollo in cima.
  /// Il 58 per cento dell'altezza conquistato con la voce 01 deve andare al
  /// FIORE, quindi il cuore scende quasi in fondo e lo stelo diventa il dettaglio
  /// che era: sotto di lui resta un ottavo della tela.
  static const Offset cuoreDelLoto = Offset(0.5, 0.84);

  /// QUANTI MINI PER GIRO, dal giro piu' esterno al piu' interno.
  ///
  /// Sei piu' otto piu' dieci piu' dodici piu' quattordici fa cinquanta: i
  /// cinquanta mini ci stanno esatti, e ogni giro porta in piu' il suo grande,
  /// che e' il petalo CENTRALE del giro.
  static const List<int> miniPerGiro = [6, 8, 10, 12, 14];

  /// Quanto e' lungo un petalo di ogni giro: i giri esterni sono i piu' grandi.
  /// Quanto e' lungo un petalo di ogni giro, in frazione del lato CORTO: il giro
  /// esterno arriva a mezza tela, perche' il fiore e' il disegno.
  /// **I NUMERI STANNO DENTRO LA TELA, e la prova della voce P.33 lo pretende.**
  /// Col giro esterno a 0,52 i petali estremi, che stanno quasi in orizzontale,
  /// uscivano dal riquadro e venivano tagliati di netto: cinquanta pixel sui
  /// fianchi, misurati. Il fiore resta grande e ci sta dentro.
  static const List<double> lunghezzaDelGiro = [0.40, 0.335, 0.275, 0.21, 0.15];

  /// Quanto e' largo un petalo, in frazione della sua lunghezza. **I petali dei
  /// giri diversi hanno FORMA diversa e non la stessa forma ruotata**: i piu'
  /// esterni sono larghi e distesi, i piu' interni stretti ed eretti.
  static const List<double> larghezzaDelGiro = [0.42, 0.36, 0.30, 0.24, 0.18];

  /// Quanto si apre il ventaglio di ogni giro, in radianti da una parte sola del
  /// verticale: il giro esterno si distende quasi in orizzontale, quello interno
  /// resta raccolto attorno al centro.
  static const List<double> aperturaDelGiro = [1.16, 0.99, 0.80, 0.57, 0.33];

  /// QUANTO UN PETALO CHIUSO E' PIU' STRETTO, PIU' CORTO E PIU' ERETTO.
  ///
  /// **Ordine S voce 02, ed e' il difetto piu' grave che l'anteprima ha
  /// mostrato**: a zero traguardi la corolla era tutta li', solo in grigio, e
  /// non c'era niente da scoprire. "I petali si aprono" era stato letto come "i
  /// petali sono disegnati spenti". Un petalo chiuso e' STRETTO, CORTO e tirato
  /// verso il verticale: a zero traguardi si vede un BOCCIOLO.
  static const double corpoDelPetaloChiuso = 0.52;
  static const double larghezzaDelPetaloChiuso = 0.30;
  static const double erezioneDelPetaloChiuso = 0.78;

  /// L'angolo di un petalo, aperto oppure chiuso: da qui passano il disegno e la
  /// prova, cosi' non esistono due conti dello stesso angolo.
  static double angoloDelPetalo(double angoloAperto, {required bool aperto}) {
    if (aperto) return angoloAperto;
    // Verso l'alto, cioe' verso meno mezzo pi greco: il bocciolo e' raccolto.
    const eretto = -math.pi / 2;
    return angoloAperto +
        (eretto - angoloAperto) * erezioneDelPetaloChiuso;
  }

  static List<PuntoDelSentiero> _loto() {
    final mini = Sentieri.miniDi(Sentiero.loto);
    final grandi = Sentieri.grandiDi(Sentiero.loto);
    final punti = <PuntoDelSentiero>[];
    var presi = 0;
    for (var giro = 0; giro < 5; giro++) {
      final quanti = miniPerGiro[giro] + 1;
      final centrale = quanti ~/ 2;
      final apertura = aperturaDelGiro[giro];
      final lungo = lunghezzaDelGiro[giro];
      for (var k = 0; k < quanti; k++) {
        // Il ventaglio, da un lato all'altro del verticale.
        final angolo = -math.pi / 2 +
            (quanti == 1
                ? 0.0
                : (k - (quanti - 1) / 2) * (2 * apertura / (quanti - 1)));
        final eIlGrande = k == centrale;
        final traguardo = eIlGrande ? grandi[giro] : mini[presi++];
        // Il vicino del petalo centrale articola il giro; gli altri lo
        // riempiono.
        final vicino = (k - centrale).abs() == 1;
        punti.add(PuntoDelSentiero(
          traguardo: traguardo,
          // **NIENTE COMPRESSIONE QUI**, e il perche' e' che il pittore non la
          // usa: il petalo si disegna con le lunghezze prese dal lato corto su
          // tutti e due gli assi. Comprimere solo il punto lo staccherebbe dal
          // suo petalo, e il tocco cadrebbe accanto invece che sopra.
          dove: Offset(
            cuoreDelLoto.dx + lungo * math.cos(angolo),
            cuoreDelLoto.dy +
                lungo * math.sin(angolo) * misuraQuadra,
          ),
          grandezza: eIlGrande
              ? GrandezzaDelPunto.principale
              : (vicino
                  ? GrandezzaDelPunto.media
                  : GrandezzaDelPunto.piccola),
          angolo: angolo,
          gruppo: giro,
        ));
      }
    }
    return punti;
  }

  static List<SegmentoDelSentiero> _ossaturaLoto() => const [];

}

/// UN PUNTO DEL DISEGNO: una stella, un frutto, un petalo.
class PuntoDelSentiero {
  const PuntoDelSentiero({
    required this.traguardo,
    required this.dove,
    required this.grandezza,
    required this.gruppo,
    this.angolo = 0,
  });

  final Traguardo traguardo;

  /// Dove sta, fra 0 e 1 sui due lati della tela.
  final Offset dove;

  /// Quale delle tre grandezze e', e da lei viene il raggio.
  final GrandezzaDelPunto grandezza;

  /// Quanto e' grande, in frazione del lato corto della tela.
  double get raggio => grandezza.raggio;

  /// Verso dove punta, per i petali del loto.
  final double angolo;

  /// A quale delle cinque parti appartiene.
  final int gruppo;

  bool get eGrande => traguardo.eGrande;
}

/// IL DISEGNO A SCHERMO, con i suoi punti toccabili.
/// **CHI RISPONDE A UN TOCCO SUL DISEGNO.** Ordine AS voce 04.
///
/// **Il fatto di Mauro**: la perla grande dell'Albero non porta al traguardo
/// mentre le piccole funzionano. **La causa, misurata invece che supposta**:
/// prima vinceva il punto piu' vicino al dito entro un raggio UGUALE PER
/// TUTTI, cinquantacinque millesimi del lato corto, cioe' 19,8 punti su una
/// tela da 360. Ma sui tre sentieri ci sono OTTANTAQUATTRO coppie di punti
/// piu' vicine di meta' di quel raggio, e la coppia piu' stretta, `aur_47` e
/// `aur_55`, dista 2,5 punti. Toccando una perla grande bastava sbagliare di
/// due pixel per prendere il mini accanto: il grande rispondeva solo se il
/// dito cadeva sul suo centro esatto, e a occhio sembrava che non rispondesse
/// mai.
///
/// **La cura: ogni punto attrae quanto e' disegnato.** Il raggio del tocco non
/// e' piu' uno per tutti ma viene dalla `GrandezzaDelPunto`, la stessa che il
/// pittore usa per disegnare: un principale e' tre volte una piccola sul
/// disegno, e adesso lo e' anche sotto il dito. Si sceglie il punto con la
/// distanza piu' piccola IN PROPORZIONE al proprio raggio, cosi' la perla
/// grande vince nella sua area e la piccola resta prendibile fuori.
///
/// Il minimo resta il polpastrello: sotto una certa misura un bersaglio non si
/// prende, per quanto piccolo sia disegnato.
PuntoDelSentiero? quiHaToccato(
    List<PuntoDelSentiero> punti, Offset tocco, Size misura) {
  final corto = math.min(misura.width, misura.height);
  // Il bersaglio minimo, quello di prima: sotto questa misura nessun punto e'
  // prendibile, e vale per i piu' piccoli.
  const minimoDelPolpastrello = 0.055;
  Offset centroDi(PuntoDelSentiero p) =>
      Offset(p.dove.dx * misura.width, p.dove.dy * misura.height);

  // **PRIMA PASSATA: il dito e' DENTRO un punto disegnato**, e allora vince
  // quel punto. Fra due cerchi che contengono il dito vince il PIU' GRANDE, e
  // a parita' di grandezza il piu' vicino al centro.
  //
  // **Perche' il piu' grande e non il piu' interno**, e la misura lo ha
  // imposto. Sul Loto ci sono punti quasi sovrapposti: `aur_47` sta a 2,5
  // punti da `aur_55` su una tela da 360, cioe' dentro la perla grande.
  // Scegliendo il piu' interno in proporzione al proprio raggio, il mini
  // vinceva sempre e la perla grande restava irraggiungibile: quattro grandi
  // su quindici, misurato. Il grande e' disegnato SOPRA e piu' largo, quindi
  // e' cio' che l'occhio vede sotto il dito, ed e' giusto che risponda lui.
  // Il mini che gli sta sotto resta raggiungibile dalla riga della lista, che
  // e' la via principale e non ha sovrapposizioni.
  PuntoDelSentiero? dentro;
  var raggioDelVinto = -1.0;
  var distanzaDelVinto = double.infinity;
  for (final punto in punti) {
    final raggio = punto.grandezza.raggio * corto;
    final distanza = (centroDi(punto) - tocco).distance;
    if (distanza > raggio) continue;
    if (raggio > raggioDelVinto ||
        (raggio == raggioDelVinto && distanza < distanzaDelVinto)) {
      raggioDelVinto = raggio;
      distanzaDelVinto = distanza;
      dentro = punto;
    }
  }
  if (dentro != null) return dentro;

  // **SECONDA PASSATA: il dito e' fuori da tutti**, e allora vale il
  // polpastrello, cioe' il piu' vicino entro una zona larga uguale per tutti.
  // Senza questa, un punto da undici millesimi di tela sarebbe piu' piccolo di
  // un dito e non si prenderebbe mai.
  PuntoDelSentiero? vicino;
  var minima = double.infinity;
  for (final punto in punti) {
    final distanza = (centroDi(punto) - tocco).distance;
    if (distanza < minima) {
      minima = distanza;
      vicino = punto;
    }
  }
  if (vicino != null && minima <= corto * minimoDelPolpastrello) return vicino;
  return null;
}

class DisegnoDelSentiero extends StatelessWidget {
  const DisegnoDelSentiero({
    super.key,
    required this.sentiero,
    required this.accesi,
    this.evidenziato,
    this.suTocco,
  });

  final Sentiero sentiero;

  /// Gli identificativi dei traguardi gia' accesi.
  final Set<String> accesi;

  /// Il traguardo che l'elenco sta evidenziando: il disegno gli mette attorno
  /// un alone, cosi' elenco e disegno si parlano nei due versi.
  final String? evidenziato;

  /// Toccando un punto si va al suo traguardo.
  final void Function(Traguardo traguardo)? suTocco;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    // **LA SCELTA E' PER SENTIERO E NON GLOBALE.** Se quel sentiero ha la sua
    // arte con gli ancoraggi e le forme, il Journal si disegna da li'; se non
    // ce l'ha, resta il procedurale di prima, intatto.
    if (ArteDelSentiero.disponibile(sentiero)) {
      return _dallArte(context);
    }
    final punti = GeometriaDelSentiero.punti(sentiero);
    return LayoutBuilder(
      builder: (context, vincoli) {
        final misura = Size(vincoli.maxWidth, vincoli.maxHeight);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: suTocco == null
              ? null
              : (dettaglio) {
                  final tocco = dettaglio.localPosition;
                  final vicino = quiHaToccato(punti, tocco, misura);
                  if (vicino != null) suTocco!(vicino.traguardo);
                },
          child: CustomPaint(
            key: Key('disegno_${sentiero.name}'),
            size: Size.infinite,
            painter: switch (sentiero) {
              Sentiero.costellazione => PittoreDellaCostellazione(
                  punti: punti,
                  accesi: accesi,
                  evidenziato: evidenziato,
                  oro: palette.gold,
                  oroTenue: palette.goldSoft,
                ),
              Sentiero.albero => PittoreDellAlbero(
                  punti: punti,
                  accesi: accesi,
                  evidenziato: evidenziato,
                  oro: palette.gold,
                  oroTenue: palette.goldSoft,
                ),
              Sentiero.loto => PittoreDelLoto(
                  punti: punti,
                  accesi: accesi,
                  evidenziato: evidenziato,
                  oro: palette.gold,
                  oroTenue: palette.goldSoft,
                ),
            },
          ),
        );
      },
    );
  }

  /// IL JOURNAL DALL'ARTE: due strati, il fondo che non sa niente del cammino e
  /// le luci sopra.
  Widget _dallArte(BuildContext context) {
    final mq = MediaQuery.maybeOf(context);
    final pieni = !(mq?.disableAnimations ?? false);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: suTocco == null ? null : (d) => _toccoSullArte(context, d),
      child: Stack(
        key: Key('journal_arte_${sentiero.name}'),
        fit: StackFit.expand,
        children: [
          FondoDelSentiero(sentiero: sentiero),
          LuciDelSentiero(
            sentiero: sentiero,
            accesi: accesi,
            evidenziato: evidenziato,
            effettiPieni: pieni,
          ),
        ],
      ),
    );
  }

  void _toccoSullArte(BuildContext context, TapUpDetails dettaglio) {
    final ancoraggi = AncoraggiDeiSentieri.di(sentiero);
    if (ancoraggi == null) return;
    final traguardi = Sentieri.di(sentiero).toList()
      ..sort((a, b) =>
          Sentieri.ordineNelCammino(a).compareTo(Sentieri.ordineNelCammino(b)));
    final scatola = context.findRenderObject();
    if (scatola is! RenderBox) return;
    final misura = scatola.size;
    final wArte = ArteDelSentiero.larghezzaArte(sentiero).toDouble();
    final hArte = ArteDelSentiero.altezzaArte(sentiero).toDouble();
    final scala = math.min(misura.width / wArte, misura.height / hArte);
    final dx = (misura.width - wArte * scala) / 2;
    final dy = (misura.height - hArte * scala) / 2;
    final tocco = dettaglio.localPosition;
    var quale = -1;
    var minima = double.infinity;
    for (var i = 0; i < ancoraggi.length; i++) {
      final centro = Offset(
          dx + ancoraggi[i].x * wArte * scala, dy + ancoraggi[i].y * hArte * scala);
      final d = (centro - tocco).distance;
      if (d < minima) {
        minima = d;
        quale = i;
      }
    }
    // La zona toccabile e' piu' larga del disegno: un bersaglio piu' piccolo di
    // un polpastrello non e' un bersaglio.
    final corto = math.min(misura.width, misura.height);
    if (quale >= 0 && minima <= corto * 0.055 && quale < traguardi.length) {
      suTocco!(traguardi[quale]);
    }
  }
}

/// La parte comune ai tre pittori: cosa e' acceso, con che oro si dipinge.
abstract class _PittoreDelSentiero extends CustomPainter {
  const _PittoreDelSentiero({
    required this.punti,
    required this.accesi,
    required this.evidenziato,
    required this.oro,
    required this.oroTenue,
  });

  final List<PuntoDelSentiero> punti;
  final Set<String> accesi;
  final String? evidenziato;
  final Color oro;
  final Color oroTenue;

  bool acceso(PuntoDelSentiero p) => accesi.contains(p.traguardo.id);

  /// LA FIGURA E' COMPIUTA: l'ULTIMO grande e' acceso.
  ///
  /// **Ordine S voce 02, la regola che mancava.** L'ultimo grande traguardo deve
  /// dare alla figura qualcosa che prima non aveva, non un pezzo in piu': un
  /// petalo su cinquanta non si vede, e infatti da meta' a completo il Loto
  /// cambiava poco. Sull'Albero era gia' vero senza avere un nome, perche' Keter
  /// porta una corona di luce che le altre Sefirot non hanno: quella e' il
  /// modello, e da qui vale per tutti e tre.
  bool get figuraCompiuta => punti.any((p) => p.eGrande && p.gruppo == 4 && acceso(p));

  Offset assoluto(PuntoDelSentiero p, Size s) =>
      Offset(p.dove.dx * s.width, p.dove.dy * s.height);

  double corto(Size s) => math.min(s.width, s.height);

  /// L'OSSATURA, e si disegna SOLO fra punti accesi. Ordine S voce 02.
  ///
  /// **Il reticolo intero era il difetto.** Con tutti i segmenti visibili da
  /// subito, a zero traguardi la forma finale si vedeva prima di meritarla e non
  /// restava niente da scoprire. Adesso un segmento esiste quando esistono i
  /// suoi due capi: la figura si compone davanti alla persona.
  void ossatura(Canvas tela, Size misura, List<SegmentoDelSentiero> ossa) {
    final c = corto(misura);
    final viva = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = c * 0.0040
      ..color = oro.withValues(alpha: 0.82);
    // La spina, cioe' i segmenti fra due principali, e' piu' spessa: e' quella
    // che tiene la figura insieme.
    final spina = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = c * 0.0062
      ..color = oro.withValues(alpha: 0.92);
    for (final osso in ossa) {
      final a = punti[osso.da];
      final b = punti[osso.a];
      if (!acceso(a) || !acceso(b)) continue;
      final dueGrandi = a.eGrande && b.eGrande;
      final penna = dueGrandi ? spina : viva;
      tela.drawLine(assoluto(a, misura), assoluto(b, misura),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = penna.strokeWidth * osso.spessore
            ..color = penna.color);
    }
  }

  /// L'OSSATURA CURVA: la stessa regola dell'ossatura, con una piega.
  ///
  /// Serve ai rami dell'Albero, che dritti sono segmenti. La piega e' la
  /// distanza del punto di controllo dalla corda, in frazione della lunghezza del
  /// segmento: il verso lo da' la posizione del punto rispetto al tronco, cosi'
  /// i rami di destra e di sinistra si piegano in modo speculare.
  void ossaturaCurva(
      Canvas tela, Size misura, List<SegmentoDelSentiero> ossa,
      {required double piega}) {
    final c = corto(misura);
    for (final osso in ossa) {
      final a = punti[osso.da];
      final b = punti[osso.a];
      if (!acceso(a) || !acceso(b)) continue;
      final da = assoluto(a, misura);
      final ad = assoluto(b, misura);
      final verso = b.dove.dx >= 0.5 ? 1.0 : -1.0;
      final meta = Offset((da.dx + ad.dx) / 2, (da.dy + ad.dy) / 2);
      final lunghezza = (ad - da).distance;
      // Il controllo sta sopra la corda, dal lato in cui il ramo cresce.
      final controllo = Offset(
          meta.dx, meta.dy - verso * 0 - lunghezza * piega);
      tela.drawPath(
          Path()
            ..moveTo(da.dx, da.dy)
            ..quadraticBezierTo(controllo.dx, controllo.dy, ad.dx, ad.dy),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = c * 0.0040 * osso.spessore
            ..color = oro.withValues(alpha: 0.82));
    }
  }

  /// UN PUNTO SPENTO E' UN PUNTO, NON UN ANELLO. Ordine S voce 02.
  ///
  /// **Un cerchio col bordo e il centro vuoto si legge come una casella da
  /// spuntare**, e a video era esattamente cosi': cinquantacinque caselle su un
  /// cielo. Una stella non ancora accesa e' un punto tenue, piccolo, senza
  /// contorno: si intuisce la forma senza vederla.
  void puntoSpento(Canvas tela, Offset centro, double raggio) {
    tela.drawCircle(centro, raggio * 0.52,
        Paint()..color = oroTenue.withValues(alpha: 0.42));
  }

  /// L'ALONE del punto che l'elenco sta evidenziando: e' il modo in cui il
  /// traguardo scelto nell'elenco si fa riconoscere dentro il disegno.
  void alone(Canvas tela, Offset centro, double raggio) {
    tela.drawCircle(
      centro,
      raggio * 2.6,
      Paint()
        ..color = oro.withValues(alpha: 0.28)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, raggio * 1.4),
    );
  }

  @override
  bool shouldRepaint(covariant _PittoreDelSentiero vecchio) =>
      vecchio.accesi.length != accesi.length ||
      vecchio.evidenziato != evidenziato ||
      vecchio.oro != oro;
}

/// LA COSTELLAZIONE DI MEDORA: stelle che si uniscono in figure.
class PittoreDellaCostellazione extends _PittoreDelSentiero {
  const PittoreDellaCostellazione({
    required super.punti,
    required super.accesi,
    required super.evidenziato,
    required super.oro,
    required super.oroTenue,
  });

  @override
  void paint(Canvas tela, Size misura) {
    final c = corto(misura);

    final ossa = GeometriaDelSentiero.ossatura(Sentiero.costellazione);

    // 1. QUANDO L'ULTIMA STELLA PRINCIPALE SI ACCENDE, LA FIGURA SI CHIUDE.
    //
    // Ordine S voce 02: prima restava una somma di cinquantaquattro segmenti
    // piu' uno. Adesso, compiuta, tutta l'ossatura porta un alone continuo
    // sotto le linee, e a quel punto si legge come UNA cosa e non come tanti
    // tratti che si toccano. Si dipinge PRIMA delle linee, cosi' e' luce che
    // esce da loro e non una vernice sopra.
    if (figuraCompiuta) {
      final alone = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = c * 0.0175
        ..color = oro.withValues(alpha: 0.30)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, c * 0.012);
      for (final osso in ossa) {
        tela.drawLine(assoluto(punti[osso.da], misura),
            assoluto(punti[osso.a], misura), alone);
      }
    }

    // 2. L'OSSATURA, solo fra stelle accese: la figura si compone.
    ossatura(tela, misura, ossa);

    // 2. LE STELLE, dalle piccole alle principali, cosi' le grandi restano
    // sopra e la gerarchia si legge anche dove i punti si avvicinano.
    for (final grandezza in GrandezzaDelPunto.values.reversed) {
      for (final punto in punti.where((p) => p.grandezza == grandezza)) {
        final centro = assoluto(punto, misura);
        final r = punto.raggio * c;
        if (punto.traguardo.id == evidenziato) alone(tela, centro, r);
        if (!acceso(punto)) {
          puntoSpento(tela, centro, r);
          continue;
        }
        // L'alone, il corpo bianco, e i quattro raggi solo sulle stelle che
        // reggono la figura: quattro raggi su cinquanta punti sarebbero un
        // istrice.
        tela.drawCircle(
            centro,
            r * 2.2,
            Paint()
              ..color = oro.withValues(alpha: 0.30)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, r));
        tela.drawCircle(centro, r, Paint()..color = Colors.white);
        if (grandezza != GrandezzaDelPunto.piccola) {
          final raggio = Paint()
            ..strokeWidth = c * 0.0020
            ..color = oro.withValues(alpha: 0.85);
          final lungo = r * (grandezza == GrandezzaDelPunto.principale ? 2.4 : 1.9);
          tela.drawLine(centro.translate(-lungo, 0), centro.translate(lungo, 0),
              raggio);
          tela.drawLine(centro.translate(0, -lungo), centro.translate(0, lungo),
              raggio);
        }
      }
    }
  }
}

/// L'ALBERO DELLA VITA DI CALIGO: rami, frutti e Sefirot che salgono.
class PittoreDellAlbero extends _PittoreDelSentiero {
  const PittoreDellAlbero({
    required super.punti,
    required super.accesi,
    required super.evidenziato,
    required super.oro,
    required super.oroTenue,
  });

  @override
  void paint(Canvas tela, Size misura) {
    final c = corto(misura);
    // 1. IL TRONCO, e finisce dove finisce l'albero.
    //
    // **Era una retta di spessore costante che sporgeva sopra Keter e sotto la
    // prima Sefirah**, e a video si leggeva come un'antenna. Adesso si
    // assottiglia salendo come i rami, e va dal primo nodo all'ultimo senza
    // monconi: un tronco che sbuca oltre la cima non e' un tronco.
    final principali = punti.where((p) => p.eGrande).toList()
      ..sort((a, b) => b.dove.dy.compareTo(a.dove.dy));
    final base = assoluto(principali.first, misura);
    final cima = assoluto(principali.last, misura);
    final largoInBasso = c * 0.019;
    final largoInCima = c * 0.0045;
    final tronco = Path()
      ..moveTo(base.dx - largoInBasso, base.dy)
      ..quadraticBezierTo(base.dx - largoInBasso * 0.55,
          (base.dy + cima.dy) / 2, cima.dx - largoInCima, cima.dy)
      ..lineTo(cima.dx + largoInCima, cima.dy)
      ..quadraticBezierTo(base.dx + largoInBasso * 0.55,
          (base.dy + cima.dy) / 2, base.dx + largoInBasso, base.dy)
      ..close();
    tela.drawPath(tronco, Paint()..color = oroTenue.withValues(alpha: 0.46));

    // 1b. IL TRONCO SI ACCENDE FINO A DOVE SEI ARRIVATO: e' la spina, e cresce.
    // Per questo l'ossatura dell'Albero non porta segmenti fra le Sefirot: sono
    // il tronco, e disegnarci sopra una linea sarebbe una seconda spina.
    final accese = principali.where(acceso).toList();
    if (accese.isNotEmpty) {
      final fin = assoluto(accese.last, misura);
      tela.drawLine(
          Offset(base.dx, base.dy),
          Offset(fin.dx, fin.dy),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = c * 0.0075
            ..color = oro.withValues(alpha: 0.55));
    }

    // 1c. LE RADICI: un albero che finisce nel vuoto galleggia.
    for (final verso in const [-1.0, -0.45, 0.45, 1.0]) {
      final radice = Path()
        ..moveTo(base.dx, base.dy)
        ..quadraticBezierTo(
            base.dx + verso * c * 0.06,
            base.dy + c * 0.035,
            base.dx + verso * c * 0.135,
            base.dy + c * 0.075);
      tela.drawPath(
          radice,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = c * (verso.abs() == 1.0 ? 0.0060 : 0.0042)
            ..color = oroTenue.withValues(alpha: 0.40));
    }

    // 2. L'OSSATURA DEI RAMI, solo fra punti accesi, e CURVA.
    //
    // **Un ramo dritto e' un segmento, non un ramo**: si piega dalla parte in
    // cui cresce, e la piega e' proporzionale alla sua lunghezza.
    ossaturaCurva(tela, misura, GeometriaDelSentiero.ossatura(Sentiero.albero),
        piega: 0.22);

    // 3. I FRUTTI e le Sefirot, dai piccoli ai principali.
    for (final grandezza in GrandezzaDelPunto.values.reversed) {
      for (final punto in punti.where((p) => p.grandezza == grandezza)) {
        final centro = assoluto(punto, misura);
        final r = punto.raggio * c;
        if (punto.traguardo.id == evidenziato) alone(tela, centro, r);
        if (!acceso(punto)) {
          puntoSpento(tela, centro, r);
          continue;
        }
        tela.drawCircle(
            centro,
            r * 2.0,
            Paint()
              ..color = oro.withValues(alpha: 0.26)
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, r));
        tela.drawCircle(centro, r, Paint()..color = oro);
        // **NESSUN GLIFO DENTRO IL NODO.** Qui c'era un cerchietto bianco
        // spostato in alto a sinistra, pensato come riflesso: sui nodi grandi si
        // leggeva come una mezzaluna appiccicata, cioe' un distintivo dentro il
        // disegno. Il rilievo si fa col centro piu' chiaro, che e' luce e non un
        // segno.
        tela.drawCircle(centro, r * 0.46,
            Paint()..color = Colors.white.withValues(alpha: 0.42));
        if (grandezza == GrandezzaDelPunto.principale) {
          // **KETER SI VEDE CHE E' L'ULTIMA**, come l'ordine chiede: la Sefirah
          // in cima porta una corona di luce che le altre non hanno. Senza
          // questo le cinque erano identiche e la salita non finiva da nessuna
          // parte.
          if (punto.gruppo == 4) {
            tela.drawCircle(
                centro,
                r * 1.55,
                Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = c * 0.0024
                  ..color = oro.withValues(alpha: 0.75));
            tela.drawCircle(
                centro,
                r * 2.9,
                Paint()
                  ..color = oro.withValues(alpha: 0.22)
                  ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 1.2));
          }
        }
      }
    }
  }
}

/// IL FIORE DI LOTO DI AURA, visto di lato: pochi petali larghi che si aprono.
class PittoreDelLoto extends _PittoreDelSentiero {
  const PittoreDelLoto({
    required super.punti,
    required super.accesi,
    required super.evidenziato,
    required super.oro,
    required super.oroTenue,
  });

  /// UN PETALO: una goccia appuntita che parte dal cuore e si apre in punta.
  ///
  /// **Non e' un ovale ruotato.** La larghezza sta al terzo della lunghezza, non
  /// a meta': e' quello che da' la punta, e un petalo di loto e' appuntito.
  Path _petalo(Offset cuore, double lungo, double largo, double angolo) {
    final punta = Offset(cuore.dx + lungo * math.cos(angolo),
        cuore.dy + lungo * math.sin(angolo));
    final normale = angolo + math.pi / 2;
    final fianco =
        Offset(largo * math.cos(normale), largo * math.sin(normale));
    final terzo = Offset(cuore.dx + lungo * 0.34 * math.cos(angolo),
        cuore.dy + lungo * 0.34 * math.sin(angolo));
    return Path()
      ..moveTo(cuore.dx, cuore.dy)
      ..quadraticBezierTo(terzo.dx + fianco.dx, terzo.dy + fianco.dy, punta.dx,
          punta.dy)
      ..quadraticBezierTo(
          terzo.dx - fianco.dx, terzo.dy - fianco.dy, cuore.dx, cuore.dy)
      ..close();
  }

  @override
  void paint(Canvas tela, Size misura) {
    final c = corto(misura);
    final cuore = Offset(GeometriaDelSentiero.cuoreDelLoto.dx * misura.width,
        GeometriaDelSentiero.cuoreDelLoto.dy * misura.height);

    // 1. LO STELO, CORTO: e' un dettaglio in fondo e non la meta' del disegno.
    //
    // **Prima si prendeva mezza tela** e il fiore restava un francobollo in
    // cima: il 58 per cento dell'altezza conquistato con la voce 01 deve andare
    // al FIORE.
    final fondo = misura.height * 0.98;
    final stelo = Path()
      ..moveTo(cuore.dx, fondo)
      ..quadraticBezierTo(
          cuore.dx + c * 0.05, (fondo + cuore.dy) / 2, cuore.dx, cuore.dy);
    tela.drawPath(
        stelo,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = c * 0.011
          ..strokeCap = StrokeCap.round
          ..color = oroTenue.withValues(alpha: 0.55));
    // Due foglie alla base dello stelo: un fiore esce da qualcosa.
    for (final lato in const [-1.0, 1.0]) {
      final foglia = _petalo(Offset(cuore.dx, fondo - c * 0.03), c * 0.10,
          c * 0.030, lato > 0 ? -0.25 : math.pi + 0.25);
      tela.drawPath(foglia, Paint()..color = oroTenue.withValues(alpha: 0.34));
    }

    // 2. I PETALI, dal giro piu' esterno al piu' interno: i vicini coprono i
    // lontani, come in un fiore vero guardato di fronte.
    final ordinati = punti.toList()
      ..sort((a, b) => a.gruppo.compareTo(b.gruppo));
    for (final p in ordinati) {
      final aperto = acceso(p);
      final giro = p.gruppo;
      final lungo = GeometriaDelSentiero.lunghezzaDelGiro[giro] *
          c *
          (aperto ? 1.0 : GeometriaDelSentiero.corpoDelPetaloChiuso);
      final largo = lungo *
          GeometriaDelSentiero.larghezzaDelGiro[giro] *
          (aperto ? 1.0 : GeometriaDelSentiero.larghezzaDelPetaloChiuso);
      final angolo =
          GeometriaDelSentiero.angoloDelPetalo(p.angolo, aperto: aperto);
      final via = _petalo(cuore, lungo, largo, angolo);
      if (p.traguardo.id == evidenziato) {
        alone(tela, assoluto(p, misura), p.raggio * c);
      }
      if (aperto) {
        tela.drawPath(via, Paint()..color = oro.withValues(alpha: 0.34));
        tela.drawPath(
            via,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth =
                  c * (p.eGrande ? 0.0044 : 0.0028)
              ..color = p.eGrande
                  ? Colors.white.withValues(alpha: 0.92)
                  : oro.withValues(alpha: 0.92));
      } else {
        // **CHIUSO E' CHIUSO**: forma piena e tenue, stretta ed eretta. A zero
        // traguardi tutti insieme fanno un bocciolo.
        tela.drawPath(via,
            Paint()..color = oroTenue.withValues(alpha: p.eGrande ? 0.38 : 0.26));
      }
    }

    // 3. QUANDO IL CUORE SI APRE, LA LUCE NASCE DAL CENTRO.
    //
    // **Ordine S voce 02, ed e' la ragione per cui il cuore si apre per
    // ULTIMO**: e' come si schiude un loto vero, e lo dice la riga del Passport,
    // il loto si schiude quando il respiro ha smesso di essere una decisione. Il
    // fiore completo non e' un petalo in piu' aperto, e' un fiore ACCESO: la
    // luce parte dal centro e si propaga verso i petali, e la differenza da
    // meta' si legge da lontano.
    if (figuraCompiuta) {
      final quanto = GeometriaDelSentiero.lunghezzaDelGiro.first * c * 1.15;
      tela.drawCircle(
          cuore,
          quanto,
          Paint()
            ..shader = RadialGradient(
              colors: [
                Colors.white.withValues(alpha: 0.62),
                oro.withValues(alpha: 0.34),
                oro.withValues(alpha: 0.0),
              ],
              stops: const [0.0, 0.42, 1.0],
            ).createShader(Rect.fromCircle(center: cuore, radius: quanto)));
    }

    // 4. IL CUORE del fiore, sempre: e' il punto da cui tutto parte.
    tela.drawCircle(
        cuore,
        c * (figuraCompiuta ? 0.020 : 0.013),
        Paint()
          ..color = figuraCompiuta
              ? Colors.white.withValues(alpha: 0.92)
              : oro.withValues(alpha: 0.72));
  }
}
