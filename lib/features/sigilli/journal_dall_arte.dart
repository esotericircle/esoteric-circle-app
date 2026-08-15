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
    _linee(tela, ancoraggi, traguardi, scala, dx, dy);

    // **UN TRACCIATO SOLO PER I MINI E UNO PER I GRANDI, e non uno per forma.**
    // L'alone sfumato costa, e cinquantacinque aloni separati mettevano il
    // disegno in ginocchio: l'ha mostrato la prima anteprima, che non e' mai
    // arrivata in fondo. Unendo le forme in due tracciati le passate sfumate
    // diventano due, e a video non cambia niente perche' gli aloni si sommavano
    // comunque.
    final mini = Path();
    final grandi = Path();
    final evidenza = Path();
    final aloneMini = Path();
    final aloneGrandi = Path();
    final aloneEvidenza = Path();
    var quantiMini = 0, quantiGrandi = 0, quantaEvidenza = 0;
    for (var i = 0; i < ancoraggi.length; i++) {
      if (!accesi.contains(traguardi[i].id)) continue;
      if (ancoraggi[i].eGrande) {
        _aggiungi(grandi, forme[i], scala, dx, dy);
        _riquadro(aloneGrandi, forme[i], scala, dx, dy);
        quantiGrandi++;
      } else {
        _aggiungi(mini, forme[i], scala, dx, dy);
        _riquadro(aloneMini, forme[i], scala, dx, dy);
        quantiMini++;
      }
      if (evidenziato == traguardi[i].id) {
        _aggiungi(evidenza, forme[i], scala, dx, dy);
        _riquadro(aloneEvidenza, forme[i], scala, dx, dy);
        quantaEvidenza++;
      }
    }
    _accendi(tela, mini, aloneMini,
        quanti: quantiMini, ampiezza: 6.0, forza: 0.78);
    _accendi(tela, grandi, aloneGrandi,
        quanti: quantiGrandi, ampiezza: 9.0, forza: 0.95);
    _accendi(tela, evidenza, aloneEvidenza,
        quanti: quantaEvidenza, ampiezza: 14.0, forza: 1.0);
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
  /// **IL RIQUADRO DELLA FORMA, e serve all'alone.** Sfumare un tracciato fatto
  /// di migliaia di rettangoli, uno per riga, non arriva mai in fondo: la prima
  /// anteprima a cinquantacinque accesi ci ha girato dieci minuti e poi e'
  /// scaduta, due volte. **L'alone e' morbido per definizione**, quindi puo'
  /// posarsi sul riquadro dell'elemento, che e' un rettangolo solo; la luce
  /// netta resta sulla forma esatta, ed e' quella che si vede.
  void _riquadro(
      Path alone, FormaDellElemento forma, double scala, double dx, double dy) {
    if (forma.strisce.length < 3) return;
    var minX = forma.strisce[1], maxX = forma.strisce[2];
    var minY = forma.strisce[0], maxY = forma.strisce[0];
    for (var k = 0; k + 2 < forma.strisce.length; k += 3) {
      if (forma.strisce[k] < minY) minY = forma.strisce[k];
      if (forma.strisce[k] > maxY) maxY = forma.strisce[k];
      if (forma.strisce[k + 1] < minX) minX = forma.strisce[k + 1];
      if (forma.strisce[k + 2] > maxX) maxX = forma.strisce[k + 2];
    }
    alone.addRect(Rect.fromLTWH(
      dx + minX * scala,
      dy + minY * scala,
      (maxX - minX + 1) * scala,
      (maxY - minY + 1) * scala,
    ));
  }

  void _accendi(Canvas tela, Path tracciato, Path alone,
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
      // **Una sottrazione per stato, non una per elemento**: il costo non
      // cambia.
      final soloIntorno =
          Path.combine(PathOperation.difference, alone, tracciato);
      tela.drawPath(
        soloIntorno,
        Paint()
          ..color = oro.withValues(alpha: 0.30 * f)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, ampiezza)
          // **ANCHE L'ALONE SI SOMMA.** Steso in modo normale lavava di oro
          // l'elemento sotto, ed era meta' della desaturazione: il lapis blu
          // sotto una velatura calda diventa grigio.
          ..blendMode = BlendMode.plus,
      );
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
      // Piena ai capi, spenta a meta': e' il filamento che nasce dai due
      // elementi accesi e non un tratto che li unisce passando davanti a tutto.
      pennello.shader = ui.Gradient.linear(da, a, [
        oroTenue.withValues(alpha: 0.62 * respiro),
        oroTenue.withValues(alpha: 0.05 * respiro),
        oroTenue.withValues(alpha: 0.62 * respiro),
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
