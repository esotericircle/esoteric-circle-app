import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/sigilli/sentieri.dart';
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
  static List<PuntoDelSentiero> punti(Sentiero sentiero) =>
      switch (sentiero) {
        Sentiero.costellazione => _costellazione(),
        Sentiero.albero => _albero(),
        Sentiero.loto => _loto(),
      };

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
        final caduta =
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
      final sefirah = indiceDelGrande(ramo);
      if (ramo < 4) {
        ossa.add(SegmentoDelSentiero(sefirah, indiceDelGrande(ramo + 1)));
      }
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

  /// Il cuore del loto e i raggi delle cinque corone di petali.
  static const Offset cuoreDelLoto = Offset(0.5, 0.46);
  static const List<double> raggiDelLoto = [0.095, 0.155, 0.215, 0.275, 0.335];

  static List<PuntoDelSentiero> _loto() {
    final mini = Sentieri.miniDi(Sentiero.loto);
    final grandi = Sentieri.grandiDi(Sentiero.loto);
    final punti = <PuntoDelSentiero>[];
    for (var corona = 0; corona < 5; corona++) {
      final raggio = raggiDelLoto[corona];
      for (var k = 0; k < 10; k++) {
        final indice = corona * 10 + k;
        // **UN FIORE SOLO**: giri concentrici attorno allo stesso cuore, ognuno
        // ruotato sul precedente, cosi' i petali si incastrano invece di
        // allinearsi in raggi dritti.
        final angolo = 2 * math.pi * k / 10 + corona * 0.314 - math.pi / 2;
        punti.add(PuntoDelSentiero(
          traguardo: mini[indice],
          dove: Offset(
            cuoreDelLoto.dx + raggio * math.cos(angolo),
            cuoreDelLoto.dy + raggio * math.sin(angolo) * compressioneVerticale,
          ),
          grandezza: k.isEven
              ? GrandezzaDelPunto.media
              : GrandezzaDelPunto.piccola,
          angolo: angolo,
          gruppo: corona,
        ));
      }
      // LA FIORITURA, il petalo che regge il suo giro. Le cinque sono
      // distribuite sui cinque quinti del cerchio: tutte in cima si
      // impilavano in una torre di losanghe che sbilanciava il fiore.
      final direzione = -math.pi / 2 + corona * 2 * math.pi / 5;
      final quanto = raggio * 1.05;
      punti.add(PuntoDelSentiero(
        traguardo: grandi[corona],
        dove: Offset(
          cuoreDelLoto.dx + quanto * math.cos(direzione),
          cuoreDelLoto.dy + quanto * math.sin(direzione) * compressioneVerticale,
        ),
        grandezza: GrandezzaDelPunto.principale,
        angolo: direzione,
        gruppo: corona,
      ));
    }
    return punti;
  }

  /// IL LOTO NON HA OSSATURA, e non e' una rinuncia.
  ///
  /// **Guardando l'anteprima: le catene fra petali disegnavano poligoni.** Legare
  /// i dieci petali di un giro con dei segmenti dritti produce un decagono, e
  /// cinque giri producevano cinque decagoni sovrapposti piu' le corde della
  /// spina: a schermo non era un fiore, era un mandala geometrico con dei
  /// quadrati dentro. Un fiore non ha spigoli.
  ///
  /// La figura sola, che l'ordine chiede, il Loto la ha per costruzione: giri
  /// concentrici attorno allo STESSO cuore, con lo stelo che li tiene. E la
  /// crescita si vede nei petali, che sono forme piene e tenui quando sono chiusi
  /// e si aprono accendendosi: non serve nessuna linea per dirlo, e ogni linea
  /// che si aggiunge toglie al fiore.
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
                  final corto = math.min(misura.width, misura.height);
                  PuntoDelSentiero? vicino;
                  var minima = double.infinity;
                  for (final punto in punti) {
                    final centro = Offset(punto.dove.dx * misura.width,
                        punto.dove.dy * misura.height);
                    final distanza = (centro - tocco).distance;
                    if (distanza < minima) {
                      minima = distanza;
                      vicino = punto;
                    }
                  }
                  // La zona toccabile e' piu' larga del disegno: un punto da
                  // undici millesimi di tela e' piu' piccolo di un polpastrello,
                  // e un bersaglio che non si prende non e' un bersaglio.
                  if (vicino != null && minima <= corto * 0.055) {
                    suTocco!(vicino.traguardo);
                  }
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

    // 1. L'OSSATURA, solo fra stelle accese: la figura si compone.
    ossatura(tela, misura, GeometriaDelSentiero.ossatura(Sentiero.costellazione));

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
    final asse = misura.width * 0.5;

    // 1. IL TRONCO, sempre visibile: e' la struttura, e un albero senza tronco
    // non e' un albero. Si assottiglia salendo.
    final tronco = Path()..moveTo(asse - c * 0.011, misura.height * 1.02);
    tronco
      ..lineTo(asse - c * 0.0028, misura.height * 0.05)
      ..lineTo(asse + c * 0.0028, misura.height * 0.05)
      ..lineTo(asse + c * 0.011, misura.height * 1.02)
      ..close();
    tela.drawPath(tronco, Paint()..color = oroTenue.withValues(alpha: 0.46));

    // 2. L'OSSATURA, solo fra punti accesi: i rami crescono davvero.
    //
    // **La regola nuova supera la prima stesura della voce**, che teneva i rami
    // e i sentieri fra le Sefirot visibili anche a frutti spenti: con tutto il
    // reticolo li' dall'inizio l'albero era gia' fatto, e restava solo da
    // colorarlo. Il tronco resta, perche' quello e' l'albero; i rami sono la
    // crescita.
    ossatura(tela, misura, GeometriaDelSentiero.ossatura(Sentiero.albero));

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
        // Il riflesso: un frutto e' una cosa tonda che prende luce.
        tela.drawCircle(centro.translate(-r * 0.3, -r * 0.3), r * 0.34,
            Paint()..color = Colors.white.withValues(alpha: 0.80));
        if (grandezza == GrandezzaDelPunto.principale) {
          tela.drawCircle(
              centro,
              r * 0.58,
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = c * 0.0028
                ..color = Colors.white.withValues(alpha: 0.85));
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

/// IL FIORE DI LOTO DI AURA: lo stelo, le corone di petali, le Fioriture.
class PittoreDelLoto extends _PittoreDelSentiero {
  const PittoreDelLoto({
    required super.punti,
    required super.accesi,
    required super.evidenziato,
    required super.oro,
    required super.oroTenue,
  });

  /// UN PETALO, ordine P voce 33.
  ///
  /// **La prima stesura non era un loto.** Tutti i petali partivano dal cuore
  /// e la loro lunghezza cresceva con la corona: le corone esterne uscivano
  /// dalla tela e si accavallavano, e a schermo si vedeva un groviglio di
  /// raggi, non un fiore. L'anteprima lo ha mostrato, la lettura del codice
  /// no.
  ///
  /// **Come si costruisce un loto.** Ogni corona di petali PARTE dove finisce
  /// la precedente, non dal cuore: petali corti e larghi, che si sovrappongono
  /// come le squame di un fiore vero. Aperto quando il traguardo e' raggiunto,
  /// stretto e piu' corto quando non lo e' ancora, perche' **i petali chiusi
  /// si vedono**: sono la parte di loto che deve ancora aprirsi.
  Path _petalo(
    Offset cuore,
    double da,
    double a,
    double largo,
    double angolo,
  ) {
    final base = Offset(
        cuore.dx + da * math.cos(angolo), cuore.dy + da * math.sin(angolo) * 0.92);
    final punta = Offset(
        cuore.dx + a * math.cos(angolo), cuore.dy + a * math.sin(angolo) * 0.92);
    final normale = angolo + math.pi / 2;
    final fianco = Offset(largo * math.cos(normale), largo * math.sin(normale));
    final meta = Offset((base.dx + punta.dx) / 2, (base.dy + punta.dy) / 2);
    return Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(
          meta.dx + fianco.dx, meta.dy + fianco.dy, punta.dx, punta.dy)
      ..quadraticBezierTo(
          meta.dx - fianco.dx, meta.dy - fianco.dy, base.dx, base.dy)
      ..close();
  }

  @override
  void paint(Canvas tela, Size misura) {
    final c = corto(misura);
    final cuore = Offset(GeometriaDelSentiero.cuoreDelLoto.dx * misura.width,
        GeometriaDelSentiero.cuoreDelLoto.dy * misura.height);

    double raggioDi(int corona) => GeometriaDelSentiero.raggiDelLoto[corona] * c;
    double partenzaDi(int corona) =>
        corona == 0 ? c * 0.030 : raggioDi(corona - 1) * 0.86;

    // 1. LO STELO, sempre visibile: il loto non galleggia da solo.
    final stelo = Path()
      ..moveTo(cuore.dx, misura.height)
      ..quadraticBezierTo(
          cuore.dx + c * 0.06, misura.height * 0.78, cuore.dx, cuore.dy);
    tela.drawPath(
        stelo,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = c * 0.010
          ..strokeCap = StrokeCap.round
          ..color = oroTenue.withValues(alpha: 0.50));

    // 2. L'OSSATURA, solo fra petali aperti: il giro si chiude man mano.
    ossatura(tela, misura, GeometriaDelSentiero.ossatura(Sentiero.loto));

    // 3. I PETALI, dalla corona piu' esterna verso il cuore, cosi' i vicini
    // coprono i lontani come in un fiore vero.
    final mini = punti.where((p) => !p.eGrande).toList()
      ..sort((a, b) => b.gruppo.compareTo(a.gruppo));
    for (final p in mini) {
      final aperto = acceso(p);
      final da = partenzaDi(p.gruppo);
      final a = raggioDi(p.gruppo) * (aperto ? 1.0 : 0.84);
      final largo = (a - da) * (aperto ? 0.62 : 0.34);
      final via = _petalo(cuore, da, a, largo, p.angolo);
      if (aperto) {
        tela.drawPath(via, Paint()..color = oro.withValues(alpha: 0.30));
        tela.drawPath(
            via,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = c * 0.0030
              ..color = oro.withValues(alpha: 0.95));
      } else {
        // **UN PETALO CHIUSO E' UNA FORMA PIENA E TENUE, non un contorno
        // vuoto**, ordine S voce 02: il contorno si legge come una casella da
        // spuntare, e un fiore non ha caselle.
        tela.drawPath(via, Paint()..color = oroTenue.withValues(alpha: 0.26));
      }
      if (p.traguardo.id == evidenziato) {
        alone(tela, assoluto(p, misura), p.raggio * c);
      }
    }

    // 3. LE CINQUE FIORITURE: un petalo piu' grande in cima alla sua corona,
    // e non piu' un anello geometrico intero. L'anello tagliava il fiore da
    // parte a parte e si leggeva come una circonferenza, non come un livello
    // di apertura.
    for (final p in punti.where((p) => p.eGrande)) {
      final centro = assoluto(p, misura);
      final r = p.raggio * c;
      if (p.traguardo.id == evidenziato) alone(tela, centro, r);
      final da = partenzaDi(p.gruppo);
      final a = raggioDi(p.gruppo) * 1.05;
      final via = _petalo(cuore, da, a, (a - da) * 0.44, p.angolo);
      if (acceso(p)) {
        tela.drawPath(via, Paint()..color = oro.withValues(alpha: 0.42));
        tela.drawPath(
            via,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = c * 0.0044
              ..color = Colors.white.withValues(alpha: 0.90));
      } else {
        // La Fioritura chiusa e' piu' presente delle altre, perche' e' una delle
        // cinque che reggono il fiore, ma resta una forma piena.
        tela.drawPath(via, Paint()..color = oroTenue.withValues(alpha: 0.38));
      }
    }

    // 4. IL CUORE del fiore, sempre.
    tela.drawCircle(
        cuore, c * 0.022, Paint()..color = oro.withValues(alpha: 0.70));
    tela.drawCircle(
        cuore,
        c * 0.022,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = c * 0.003
          ..color = Colors.white.withValues(alpha: 0.55));
  }
}
