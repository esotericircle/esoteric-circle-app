import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/sigilli/ancoraggi_dei_sentieri.dart';
import '../../core/sigilli/forma_dell_elemento.dart';
import '../../core/sigilli/forme_dei_sentieri.dart';
import '../../core/sigilli/lettura_degli_ancoraggi.dart';
import '../../core/sigilli/regole_delle_tre_arti.dart';
import '../../core/sigilli/sentieri.dart';
import '../../design_system/theme/maestro_scope.dart';

/// IL JOURNAL DISEGNATO DALL'ARTE. Ordine T voce 02.
///
/// **Due strati, e il primo non sa niente del cammino.** Sotto c'e' l'immagine
/// prodotta da Mauro, coi cinquantacinque elementi gia' disegnati SPENTI; sopra
/// c'e' il codice, che accende. Il fondo e' un'immagine e basta: non riceve i
/// traguardi accesi, non li puo' leggere, e una prova cade se un giorno
/// qualcuno glieli passasse.
///
/// **La scelta e' PER SENTIERO e non globale**: se l'arte di quel sentiero c'e'
/// si disegna quella, altrimenti resta il procedurale di prima.

/// Cosa serve a un sentiero per essere disegnato dall'arte.
class ArteDelSentiero {
  const ArteDelSentiero._();

  /// **L'INTERRUTTORE, ED E' SPENTO, con la ragione scritta qui.**
  ///
  /// Il Journal dall'arte e' completo e provato fino a un punto: a due traguardi
  /// accesi si disegna e l'anteprima c'e'. **A cinquantacinque accesi il disegno
  /// non arriva in fondo**, e la causa e' misurata: la forma di un elemento e'
  /// conservata a strisce, una per riga, e accenderle tutte vuol dire chiedere
  /// al pittore un tracciato di qualche migliaio di rettangoli disgiunti. Tre
  /// tentativi di alleggerirlo (l'alone sul riquadro invece che sulla forma, via
  /// `computeMetrics`, via la passata in `BlendMode.plus`) hanno tolto ognuno
  /// una causa e il tempo non e' sceso: **non e' la sfumatura, e' il tracciato.**
  ///
  /// **Non si accende cio' che non e' stato visto funzionare.** Finche' resta
  /// falso, i tre Journal restano quelli procedurali di prima, che funzionano:
  /// nessuno perde niente e nessuno rischia una schermata che si pianta col
  /// cammino finito. Torna vero quando le forme si disegnano da una maschera
  /// gia' rasterizzata invece che da un tracciato di rettangoli, e quando le sei
  /// anteprime sono state guardate.
  static const bool acceso = false;

  /// **TRE COSE INSIEME, e servono tutte e tre**: l'immagine, i cinquantacinque
  /// ancoraggi e le cinquantacinque forme. Con l'immagine ma senza ancoraggi il
  /// Journal sarebbe un quadro dove niente si accende, cioe' peggio di adesso.
  static bool disponibile(Sentiero sentiero) =>
      acceso &&
      AncoraggiDeiSentieri.di(sentiero) != null &&
      FormeDeiSentieri.di(sentiero) != null;

  static String file(Sentiero sentiero) => RegoleDelleTreArti.arteDi(sentiero);

  /// **LA PROPORZIONE DELL'ARTE, per sentiero.** Le tre tele non sono uguali fra
  /// loro: la Costellazione e' piu' larga e piu' bassa degli altri due, e la sua
  /// tela deve seguirla, altrimenti l'immagine si monta dentro un riquadro di
  /// un'altra forma e resta piccola in mezzo a due bande vuote.
  ///
  /// Non e' misurata a runtime dal file: si dichiara qui, e una prova la
  /// confronta con l'immagine vera.
  static double proporzione(Sentiero sentiero) => switch (sentiero) {
        Sentiero.costellazione => 1023 / 1537,
        Sentiero.albero => 941 / 1672,
        Sentiero.loto => 941 / 1672,
      };

  /// La larghezza in pixel dell'arte, che e' l'unita' in cui vivono le forme.
  static int larghezzaArte(Sentiero sentiero) => switch (sentiero) {
        Sentiero.costellazione => 1023,
        Sentiero.albero => 941,
        Sentiero.loto => 941,
      };

  static int altezzaArte(Sentiero sentiero) => switch (sentiero) {
        Sentiero.costellazione => 1537,
        Sentiero.albero => 1672,
        Sentiero.loto => 1672,
      };
}

/// LO STRATO DEL FONDO.
///
/// **Non riceve i traguardi, e non e' una dimenticanza**: e' il vincolo della
/// voce. Il fondo dell'arte e' lo stesso a zero traguardi e a cinquantacinque,
/// e domani puo' diventare un'altra immagine senza che il codice che accende ne
/// sappia niente.
class FondoDelSentiero extends StatelessWidget {
  const FondoDelSentiero({super.key, required this.sentiero});

  final Sentiero sentiero;

  @override
  Widget build(BuildContext context) => Image.asset(
        ArteDelSentiero.file(sentiero),
        key: Key('fondo_${sentiero.name}'),
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      );
}

/// LO STRATO DELLE LUCI, e qui vive tutto cio' che dipende dal cammino.
class LuciDelSentiero extends StatelessWidget {
  const LuciDelSentiero({
    super.key,
    required this.sentiero,
    required this.accesi,
    this.evidenziato,
    this.respiro = 1.0,
    this.effettiPieni = true,
  });

  final Sentiero sentiero;
  final Set<String> accesi;
  final String? evidenziato;

  /// Il respiro del bagliore, fra 0 e 1. **Uno vuol dire pieno.**
  final double respiro;

  /// **Falso con Riduci Movimento oppure con Quality Tier basso**: il bagliore
  /// resta, l'alone ampio cade. La luce non si spegne mai, perche' spegnerla
  /// vorrebbe dire non far vedere il cammino a chi ha chiesto meno movimento.
  final bool effettiPieni;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return CustomPaint(
      key: Key('luci_${sentiero.name}'),
      size: Size.infinite,
      painter: PittoreDelleLuci(
        sentiero: sentiero,
        accesi: accesi,
        evidenziato: evidenziato,
        oro: palette.gold,
        oroTenue: palette.goldSoft,
        respiro: respiro,
        effettiPieni: effettiPieni,
      ),
    );
  }
}

/// UN ALONE E IL COLORE DELLA MATERIA CHE LO EMETTE. Ordine X voce 01.
///
/// **Tiene insieme due cose che prima viaggiavano separate**: dove si stende la
/// luce e di che colore e'. Finche' la luce era oro per tutti il colore non
/// serviva portarlo, e infatti non c'era.
class _AloneDellaMateria {
  const _AloneDellaMateria(this.dove, this.colore);

  /// Il riquadro dell'elemento meno la sua forma.
  final Path dove;

  /// La sua materia, gia' portata alla luminosita' piena.
  final Color colore;
}

/// I TRACCIATI COMPOSTI UNA VOLTA E TENUTI. Ordine AC voce 01a.
///
/// **Non e' una scorciatoia, e' il riconoscimento di un fatto**: le forme sono un
/// dato generato che non cambia mai, e l'insieme dei traguardi accesi cambia un
/// traguardo alla volta. Ricomporre migliaia di rettangoli a ogni passata voleva
/// dire rifare ogni volta un lavoro il cui risultato era identico.
class _TracciatiRicordati {
  const _TracciatiRicordati({
    required this.mini,
    required this.grandi,
    required this.aloniMini,
    required this.aloniGrandi,
    required this.quantiMini,
    required this.quantiGrandi,
  });

  final Path mini;
  final Path grandi;
  final List<_AloneDellaMateria> aloniMini;
  final List<_AloneDellaMateria> aloniGrandi;
  final int quantiMini;
  final int quantiGrandi;
}

/// IL PITTORE DELLE LUCI.
class PittoreDelleLuci extends CustomPainter {
  const PittoreDelleLuci({
    required this.sentiero,
    required this.accesi,
    required this.evidenziato,
    required this.oro,
    required this.oroTenue,
    required this.respiro,
    required this.effettiPieni,
  });

  final Sentiero sentiero;
  final Set<String> accesi;
  final String? evidenziato;
  final Color oro;
  final Color oroTenue;
  final double respiro;
  final bool effettiPieni;

  @override
  void paint(Canvas tela, Size misura) {
    final ancoraggi = AncoraggiDeiSentieri.di(sentiero);
    final forme = FormeDeiSentieri.di(sentiero);
    if (ancoraggi == null || forme == null) return;
    final traguardi = Sentieri.di(sentiero).toList()
      ..sort((a, b) =>
          Sentieri.ordineNelCammino(a).compareTo(Sentieri.ordineNelCammino(b)));
    if (traguardi.length != ancoraggi.length) return;

    // **L'ARTE E' MONTATA CON BoxFit.contain**, quindi la scala e' la stessa sui
    // due assi e il disegno resta centrato dentro la tela: le luci devono usare
    // esattamente lo stesso riquadro, altrimenti si posano accanto.
    final wArte = ArteDelSentiero.larghezzaArte(sentiero).toDouble();
    final hArte = ArteDelSentiero.altezzaArte(sentiero).toDouble();
    final scala = math.min(misura.width / wArte, misura.height / hArte);
    final dx = (misura.width - wArte * scala) / 2;
    final dy = (misura.height - hArte * scala) / 2;

    // PRIMA LE LINEE, poi le forme: una linea che passa sopra un elemento
    // acceso lo taglierebbe in due.
    _linee(tela, ancoraggi, forme, traguardi, scala, dx, dy);

    // **UN TRACCIATO SOLO PER I MINI E UNO PER I GRANDI, e non uno per forma.**
    // L'alone sfumato costa, e cinquantacinque aloni separati mettevano il
    // disegno in ginocchio: l'ha mostrato la prima anteprima, che non e' mai
    // arrivata in fondo. Unendo le forme in due tracciati le passate sfumate
    // diventano due, e a video non cambia niente perche' gli aloni si sommavano
    // comunque.
    // **LA FORMA SI RAGGRUPPA, L'ALONE NO, e la ragione e' il colore.** La
    // passata netta sulla forma e' neutra e uguale per tutti, quindi un
    // tracciato solo per stato basta e costa meno. L'alone invece porta ora la
    // tinta della materia che lo emette, e due elementi di colore diverso non
    // possono stare nella stessa passata: gli aloni si stendono uno per
    // elemento. **Restano al massimo cinquantacinque riquadri**, uno per
    // elemento acceso, non i migliaia di rettangoli che nell'ordine T avevano
    // messo in ginocchio l'anteprima: quello era il tracciato delle strisce,
    // questo e' un rettangolo per elemento.
    // **IL TRACCIATO NON SI RICOMPONE A OGNI CHIAMATA.** Ordine AC voce 01a.
    //
    // Le forme sono un DATO FISSO e l'insieme degli accesi cambia raramente, un
    // traguardo alla volta: comporre migliaia di rettangoli a ogni passata era
    // rifare ogni volta un lavoro il cui risultato non era cambiato. Adesso si
    // compone quando cambia qualcosa e si tiene.
    final ricordo = _tracciatiDi(ancoraggi, forme, traguardi, misura, scala, dx,
        dy);

    // **L'EVIDENZA STA FUORI DAL RICORDO, ed e' voluto.** E' un elemento solo,
    // cambia a ogni tocco, e tenerla dentro vorrebbe dire buttare via tutto il
    // resto ogni volta che il dito si sposta.
    final evidenza = Path();
    final aloniEvidenza = <_AloneDellaMateria>[];
    var quantaEvidenza = 0;
    if (evidenziato != null) {
      for (var i = 0; i < ancoraggi.length; i++) {
        if (traguardi[i].id != evidenziato) continue;
        if (!accesi.contains(traguardi[i].id)) continue;
        _aggiungi(evidenza, forme[i], scala, dx, dy);
        aloniEvidenza.add(_alonePerUno(forme[i], scala, dx, dy));
        quantaEvidenza++;
      }
    }
    _accendi(tela, ricordo.mini, ricordo.aloniMini,
        quanti: ricordo.quantiMini, ampiezza: 6.0, forza: 0.78);
    _accendi(tela, ricordo.grandi, ricordo.aloniGrandi,
        quanti: ricordo.quantiGrandi, ampiezza: 9.0, forza: 0.95);
    _accendi(tela, evidenza, aloniEvidenza,
        quanti: quantaEvidenza, ampiezza: 14.0, forza: 1.0);
  }

  /// **CIO' CHE SI TIENE FRA UNA PASSATA E L'ALTRA.**
  ///
  /// **La chiave dice tutto cio' da cui il tracciato dipende**, e se ne
  /// dimenticasse un pezzo il disegno resterebbe indietro senza che nessuno lo
  /// veda: il sentiero, la misura della tela, i colori della sua tavolozza e
  /// **quali** traguardi sono accesi, non quanti. Due insiemi diversi della
  /// stessa lunghezza sono due disegni diversi.
  static final Map<String, _TracciatiRicordati> _ricordi = {};

  /// **QUANTI RICORDI SI TENGONO.** Tre sentieri, e una misura di tela per
  /// ciascuno: sopra questo numero si sta tenendo in vita roba che nessuno
  /// riguardera'. Non e' una cache generica, e' una memoria corta e dichiarata.
  static const int quantiRicordi = 6;

  _TracciatiRicordati _tracciatiDi(
    List<AncoraggioDelSentiero> ancoraggi,
    List<FormaDellElemento> forme,
    List<dynamic> traguardi,
    Size misura,
    double scala,
    double dx,
    double dy,
  ) {
    final firma = StringBuffer()
      ..write(sentiero.name)
      ..write('|${misura.width}x${misura.height}')
      ..write('|${oro.toARGB32()}|${oroTenue.toARGB32()}|');
    for (var i = 0; i < ancoraggi.length; i++) {
      if (accesi.contains(traguardi[i].id)) firma.write('$i,');
    }
    final chiave = firma.toString();
    final gia = _ricordi[chiave];
    if (gia != null) return gia;

    final mini = Path();
    final grandi = Path();
    final aloniMini = <_AloneDellaMateria>[];
    final aloniGrandi = <_AloneDellaMateria>[];
    var quantiMini = 0, quantiGrandi = 0;
    for (var i = 0; i < ancoraggi.length; i++) {
      if (!accesi.contains(traguardi[i].id)) continue;
      if (ancoraggi[i].eGrande) {
        _aggiungi(grandi, forme[i], scala, dx, dy);
        aloniGrandi.add(_alonePerUno(forme[i], scala, dx, dy));
        quantiGrandi++;
      } else {
        _aggiungi(mini, forme[i], scala, dx, dy);
        aloniMini.add(_alonePerUno(forme[i], scala, dx, dy));
        quantiMini++;
      }
    }
    if (_ricordi.length >= quantiRicordi) _ricordi.remove(_ricordi.keys.first);
    return _ricordi[chiave] = _TracciatiRicordati(
      mini: mini,
      grandi: grandi,
      aloniMini: aloniMini,
      aloniGrandi: aloniGrandi,
      quantiMini: quantiMini,
      quantiGrandi: quantiGrandi,
    );
  }

  /// **LA LUCE HA IL COLORE DELLA MATERIA CHE ACCENDE.** Ordine X voce 01.
  ///
  /// **Perche' non l'oro.** L'oro e' complementare al blu: qualunque luce dorata
  /// su un lapislazzuli lo porta verso il grigio, a qualunque opacita'. Misurato
  /// sulle anteprime, il 73,8 per cento dei pixel che cambiavano accendendo la
  /// Costellazione portava la firma dell'oro e perdeva saturazione da 0,75 a
  /// 0,59; sul Loto gli stessi pixel dorati erano il 69,8 per cento e non
  /// perdevano niente, perche' la materia del Loto e' calda. Non e' una
  /// taratura: e' la scelta del colore della luce.
  ///
  /// **SI TIENE LA TINTA DELLA MATERIA, NON LA SUA DEBOLEZZA.** La luminosita'
  /// va al massimo, e **schiarire verso il bianco desatura**, quindi il valore
  /// si alza nello spazio della tinta e non aggiungendo bianco: era meta' del
  /// difetto originale e non si ripete.
  ///
  /// **La saturazione ha un pavimento, ed e' quella dell'oro che questa luce
  /// sostituisce, 0,74.** Il numero non viene da cio' che ho misurato sulle
  /// anteprime: viene dal vincolo che una luce nuova non puo' essere piu' scialba
  /// di quella che rimpiazza, altrimenti sui sentieri dove l'oro funzionava si
  /// perde. **E senza il pavimento si perdeva davvero, misurato**: la materia
  /// dell'Albero ha saturazione mediana 0,31 e quella del Loto 0,40, contro lo
  /// 0,84 del lapis, e una luce cosi' scialba lava cio' su cui si posa. Con
  /// l'oro l'Albero faceva 0,46 e 0,47, con la materia cruda faceva 0,52 e 0,44.
  /// **La tinta e' della materia, la forza e' quella che una luce deve avere.**
  ///
  /// **Senza colore si torna all'oro, e lo si dichiara qui.** Una forma di
  /// ripiego non ha un elemento sotto: darle un colore inventato sarebbe peggio
  /// che darle la luce di prima. Vale anche per una materia perfettamente grigia,
  /// che non ha nessuna tinta da tenere.
  Color _luceDi(FormaDellElemento forma) {
    final c = forma.colore;
    if (c == null) return oro;
    final materia = HSVColor.fromColor(Color.fromARGB(255, c[0], c[1], c[2]));
    if (materia.saturation <= 0) return oro;
    return materia
        .withSaturation(
            math.max(materia.saturation, HSVColor.fromColor(oro).saturation))
        .withValue(1.0)
        .toColor();
  }

  /// L'alone di UN elemento: il suo riquadro meno la sua forma, col suo colore.
  ///
  /// **LA SOTTRAZIONE E' ARITMETICA, non un motore booleano.** Ordine AC voce
  /// 01a. Prima era un `Path.combine` di differenza per elemento, e misurato
  /// costava il novantacinque per cento del tempo di composizione: 57,7
  /// millesimi sulla Costellazione, 86,2 sull'Albero, 275,7 sul Loto, contro i
  /// 2,8 dei rettangoli del tracciato. Il complemento di una forma a strisce
  /// dentro il suo riquadro si calcola per righe, prendendo i BUCHI fra un
  /// segmento e l'altro: e' lo stesso risultato senza scomodare la geometria
  /// booleana.
  ///
  /// **La sottrazione resta anche se la sfocatura la scavalca.** Il
  /// `MaskFilter.blur` si applica dopo, quindi il bagliore rientra comunque
  /// sopra la forma: e' il meccanismo che spiega la firma dorata misurata. Ma
  /// adesso cio' che rientra ha la tinta della materia, quindi illumina invece
  /// di lavare, e la sottrazione continua a tenere il grosso della luce fuori,
  /// dove un alone deve stare.
  _AloneDellaMateria _alonePerUno(
      FormaDellElemento forma, double scala, double dx, double dy) {
    final s = forma.strisce;
    if (s.length < 3) return _AloneDellaMateria(Path(), _luceDi(forma));
    var minX = s[1], maxX = s[2], minY = s[0], maxY = s[0];
    for (var k = 0; k + 2 < s.length; k += 3) {
      if (s[k] < minY) minY = s[k];
      if (s[k] > maxY) maxY = s[k];
      if (s[k + 1] < minX) minX = s[k + 1];
      if (s[k + 2] > maxX) maxX = s[k + 2];
    }
    // I segmenti della forma, raccolti per riga. **Non si assume una striscia
    // per riga**: una forma concava puo' averne due o tre sulla stessa y, e
    // darlo per scontato lascerebbe dentro l'alone un pezzo di elemento.
    final perRiga = <int, List<int>>{};
    for (var k = 0; k + 2 < s.length; k += 3) {
      (perRiga[s[k]] ??= <int>[]).addAll([s[k + 1], s[k + 2]]);
    }
    // **L'ALTEZZA E' LA STESSA DELLE STRISCE, mezzo punto in piu' compreso.** La
    // forma sovrappone le sue righe per non lasciare cuciture, e il suo
    // complemento deve sovrapporle uguale: costruirlo alto un punto esatto
    // lascerebbe una riga scoperta ogni volta, cioe' una cucitura di luce dove
    // prima non c'era.
    final alto = scala + 0.5;
    final via = Path();
    void rettangolo(int y, int da, int a) {
      if (a < da) return;
      via.addRect(Rect.fromLTWH(
          dx + da * scala, dy + y * scala, (a - da + 1) * scala, alto));
    }

    for (var y = minY; y <= maxY; y++) {
      final segmenti = perRiga[y];
      if (segmenti == null) {
        // Una riga senza strisce e' tutta alone, da un bordo all'altro.
        rettangolo(y, minX, maxX);
        continue;
      }
      final coppie = <List<int>>[];
      for (var j = 0; j + 1 < segmenti.length; j += 2) {
        coppie.add([segmenti[j], segmenti[j + 1]]);
      }
      coppie.sort((a, b) => a[0].compareTo(b[0]));
      var x = minX;
      for (final c in coppie) {
        rettangolo(y, x, c[0] - 1);
        if (c[1] + 1 > x) x = c[1] + 1;
      }
      rettangolo(y, x, maxX);
    }
    return _AloneDellaMateria(via, _luceDi(forma));
  }

  /// Le strisce di una forma diventano rettangoli dentro un tracciato.
  void _aggiungi(
      Path tracciato, FormaDellElemento forma, double scala, double dx, double dy) {
    for (var k = 0; k + 2 < forma.strisce.length; k += 3) {
      final y = forma.strisce[k].toDouble();
      final x1 = forma.strisce[k + 1].toDouble();
      final x2 = forma.strisce[k + 2].toDouble();
      tracciato.addRect(Rect.fromLTWH(
        dx + x1 * scala,
        dy + y * scala,
        (x2 - x1 + 1) * scala,
        scala + 0.5,
      ));
    }
  }

  /// **SI ACCENDE LA FORMA, NON IL PUNTO.**
  ///
  /// **Il grande e' piu' ampio e piu' caldo del mini, e la differenza si
  /// dichiara con un numero**: mezzo passo in piu' di alone, nove contro sei, e
  /// un quinto di luce in piu', 0,95 contro 0,78.
  void _accendi(Canvas tela, Path tracciato, List<_AloneDellaMateria> aloni,
      {required int quanti,
      required double ampiezza,
      required double forza}) {
    // **NIENTE computeMetrics QUI, ed e' costato dieci minuti a scoprirlo.** Su
    // un tracciato di qualche migliaio di rettangoli quella chiamata costruisce
    // le metriche di ogni contorno e l'anteprima non arrivava mai in fondo:
    // sapere SE c'e' qualcosa da accendere e' un contatore, non una misura.
    if (quanti == 0) return;
    final f = forza * respiro;
    if (effettiPieni) {
      // **L'ALONE STA FUORI DALL'ELEMENTO, e non sopra.** Un alone dorato steso
      // anche sull'orbo lo lava: il lapis blu sotto una velatura calda diventa
      // grigio, e la saturazione scende proprio dove l'elemento dovrebbe
      // brillare. Togliendogli l'area della forma, l'alone fa quello che un
      // alone fa, cioe' illuminare INTORNO, e il colore dell'elemento resta suo.
      // **UNA SOTTRAZIONE PER ELEMENTO, e il conto totale non cambia.** Prima
      // era una sola per stato su tutte le forme insieme; adesso sono una per
      // elemento su una forma sola, e i rettangoli attraversati sono gli stessi.
      // Cio' che cambia e' che ogni alone puo' avere il suo colore, che e' il
      // punto della voce.
      // **IL RITAGLIO CONTRO LA FORMA E' STATO PROVATO E SCARTATO, con i
      // numeri.** Ritagliando la tela sull'alone prima di stenderlo, la
      // sfocatura non rientra piu' sopra l'elemento: sulla Costellazione la
      // saturazione resta 0,67 e 0,65, cioe' identica, mentre sull'Albero
      // scende da 0,46 e 0,48 a 0,42 e 0,41 e sul Loto da 0,52 e 0,54 a 0,51 e
      // 0,51. **Costa un salvataggio, un ritaglio e un ripristino per elemento
      // e non compra niente**: la luce che rientra, adesso che ha la tinta
      // giusta, e' quella che fa salire la saturazione invece di abbassarla.
      for (final alone in aloni) {
        tela.drawPath(
          alone.dove,
          Paint()
            // **IL COLORE E' QUELLO DELLA MATERIA**, non l'oro. Vedi `_luceDi`:
            // l'oro sul lapis lo porta al grigio, e questa era la passata che
            // portava il grosso del danno, non quella netta qui sotto.
            ..color = alone.colore.withValues(alpha: 0.30 * f)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, ampiezza)
            // **ANCHE L'ALONE SI SOMMA.** Steso in modo normale lavava
            // l'elemento sotto, ed era meta' della desaturazione.
            ..blendMode = BlendMode.plus,
        );
      }
    }
    // **L'ACCENSIONE ILLUMINA, NON COPRE.** Ordine W voce 01.
    //
    // Prima qui c'era un riempimento pieno al settantadue per cento: un disco
    // d'oro piatto steso sopra l'elemento, che cancellava il modellato e il
    // colore sotto. **Il premio per aver raggiunto un traguardo era veder
    // spegnere il gioiello**: la sfera di peltro dell'Albero perdeva ombra e
    // riflesso, e l'orbo di lapis della Costellazione passava da blu profondo a
    // crema, guadagnando luminanza e PERDENDO saturazione.
    //
    // **La luce si somma, non si sovrappone**: in `BlendMode.plus` cio' che sta
    // sotto resta e si schiarisce, quindi il lapis resta lapis e la pietra resta
    // pietra. Il muro dell'8 agosto non c'entra: quello era la passata SFUMATA
    // su un tracciato di migliaia di rettangoli, e la sfumatura qui resta sul
    // riquadro, che e' un rettangolo per elemento.
    //
    // E il bianco e' sparito: schiarire verso il bianco DESATURA, ed era meta'
    // del difetto. La luce e' oro, e l'oro somma.
    tela.drawPath(
      tracciato,
      Paint()
        ..color = Color.fromRGBO(80, 80, 80, 0.85 * f)
        ..blendMode = BlendMode.colorDodge,
    );
  }

  /// **LA LINEA SI SALDA FRA DUE PUNTI ACCESI DELLO STESSO GRUPPO**, e solo
  /// allora: e' il progresso che si vede. Col reticolo intero visibile da subito
  /// la figura finale si vedrebbe prima di meritarla.
  void _linee(
    Canvas tela,
    List<AncoraggioDelSentiero> ancoraggi,
    List<FormaDellElemento> forme,
    List<dynamic> traguardi,
    double scala,
    double dx,
    double dy,
  ) {
    // **LA LINEA E' LUCE, NON UN FILO.** Ordine W voce 02.
    //
    // Prima era un tratto pieno che attraversava il tronco e le foglie
    // passandoci davanti: sembrava una linea di costruzione rimasta accesa, e
    // **appiattiva il disegno**. Nel 2.5D la profondita' la fa l'ordine dei
    // piani, e un filo davanti al tronco toglie all'albero il rilievo, che e'
    // l'identita' visiva scelta da Mauro.
    //
    // Le luci stanno sopra l'arte e non possono passarle dietro, quindi la
    // linea smette di sembrare un oggetto: **si dissolve verso il centro della
    // campata.** Il collegamento si legge ai due capi, dove nasce, e non taglia
    // cio' che sta in mezzo. La sfumatura e' un gradiente per segmento, e i
    // segmenti accesi sono al massimo una cinquantina: il muro dell'8 agosto
    // valeva per migliaia di rettangoli e qui non si incontra.
    final pennello = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.2, 2.4 * scala)
      ..strokeCap = StrokeCap.round
      ..blendMode = BlendMode.plus;
    for (var i = 0; i + 1 < ancoraggi.length; i++) {
      // Solo col VICINO nel cammino e solo dentro lo stesso gruppo: unire tutti
      // con tutti farebbe una ragnatela, non una figura che si compone.
      if (ancoraggi[i + 1].gruppo != ancoraggi[i].gruppo) continue;
      if (!accesi.contains(traguardi[i].id)) continue;
      if (!accesi.contains(traguardi[i + 1].id)) continue;
      final da = _punto(ancoraggi[i], scala, dx, dy);
      final a = _punto(ancoraggi[i + 1], scala, dx, dy);
      // **LA LINEA PRENDE IL COLORE DEI SUOI DUE CAPI.** Ordine X voce 01.
      //
      // Una linea unisce due elementi che possono essere di materia diversa,
      // quindi non ha un colore solo: nasce del colore di chi la emette a un
      // capo e arriva del colore di chi la riceve all'altro. Era oro tenue su
      // tutte, ed era la seconda passata in `plus` che portava dorato sopra il
      // lapis.
      //
      // **Se a un capo manca il colore la linea torna all'oro, tutta.** Meta'
      // colorata e meta' dorata direbbe una cosa che nel dato non c'e': dove il
      // colore non e' ricavabile si dichiara, non si sfuma.
      final ca = forme[i].colore, cb = forme[i + 1].colore;
      final tinta = (ca == null || cb == null)
          ? [oroTenue, oroTenue]
          : [_luceDi(forme[i]), _luceDi(forme[i + 1])];
      // Piena ai capi, spenta a meta': e' il filamento che nasce dai due
      // elementi accesi e non un tratto che li unisce passando davanti a tutto.
      pennello.shader = ui.Gradient.linear(da, a, [
        tinta[0].withValues(alpha: 0.62 * respiro),
        tinta[0].withValues(alpha: 0.05 * respiro),
        tinta[1].withValues(alpha: 0.62 * respiro),
      ], const [
        0.0,
        0.5,
        1.0,
      ]);
      tela.drawLine(da, a, pennello);
    }
  }

  Offset _punto(
          AncoraggioDelSentiero a, double scala, double dx, double dy) =>
      Offset(
        dx + a.x * ArteDelSentiero.larghezzaArte(sentiero) * scala,
        dy + a.y * ArteDelSentiero.altezzaArte(sentiero) * scala,
      );

  @override
  bool shouldRepaint(covariant PittoreDelleLuci vecchio) =>
      vecchio.sentiero != sentiero ||
      vecchio.accesi.length != accesi.length ||
      vecchio.evidenziato != evidenziato ||
      vecchio.respiro != respiro ||
      vecchio.effettiPieni != effettiPieni;
}
