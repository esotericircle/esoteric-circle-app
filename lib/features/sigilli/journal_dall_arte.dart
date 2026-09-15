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

  /// **L'INTERRUTTORE, ED E' ACCESO dal 16 agosto 2026, ordine AC voce 01.**
  ///
  /// **LA CAUSA VERA ERANO LE CINQUANTACINQUE SOTTRAZIONI BOOLEANE, non i
  /// migliaia di rettangoli.** Per mesi qui c'era scritto che il disegno a
  /// cinquantacinque accesi non arrivava in fondo per via del tracciato a
  /// strisce. Misurato strumentando la composizione in due parti, il tracciato
  /// costava **2,8 millesimi di secondo sul Loto**, cioe' era innocente: i
  /// cinquantacinque `Path.combine` di differenza, uno per elemento, ne costavano
  /// **275,7**. Il novantacinque per cento del tempo stava dove nessuno guardava.
  ///
  /// **E' STATA TOLTA CALCOLANDO IL COMPLEMENTO PER RIGHE.** Il buco fra un
  /// segmento e l'altro dentro il riquadro di una forma e' aritmetica sulle
  /// strisce, non geometria booleana: stesso risultato, nessun motore. Verificato
  /// a pixel contro il disegno di prima, la differenza massima per canale e' 6
  /// sulla Costellazione, 9 sull'Albero, 20 sul Loto, tutte sotto la soglia di 30
  /// con cui le guardie stesse decidono se un pixel e' cambiato.
  ///
  /// **IL TETTO CHE SORVEGLIA QUESTO RAMO E' CENTO MILLESIMI, ed e' l'apertura e
  /// non il fotogramma**: questo pittore si disegna UNA volta quando il sentiero
  /// si apre, e zero volte scorrendo l'elenco o toccando un traguardo, contate.
  /// I tre numeri misurati sono **Costellazione 18,80, Albero 19,68, Loto 25,82**,
  /// contro i 71,89, 100,39 e 287,60 di prima. La guardia sta in
  /// `test/il_journal_arriva_in_fondo_test.dart` e da adesso cade se qualcuno
  /// appesantisce il disegno.
  static const bool acceso = true;

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

/// UNA LAMPADINA: la forma, il suo cerchio e il suo colore. Ordine AF voce 02.
///
/// **Tiene insieme cio' che serve a disegnare un elemento ACCESO come una
/// lampadina**: la forma esatta da ridipingere, il centro e il raggio del suo
/// cerchio per l'alone a gradiente e il riflesso, e il colore della materia per
/// la tinta dell'alone, che resta la legge dell'ordine X.
class _Lampadina {
  const _Lampadina(this.forma, this.centro, this.raggio, this.colore);

  /// La forma esatta dell'elemento, da ridipingere luminosa.
  final Path forma;

  /// Il centro del cerchio che avvolge la forma.
  final Offset centro;

  /// Il raggio equivalente della forma sulla tela.
  final double raggio;

  /// La materia dell'elemento, portata alla luminosita' piena.
  final Color colore;
}

/// LE LAMPADINE COMPOSTE UNA VOLTA E TENUTE. Ordine AC voce 01a.
///
/// **Non e' una scorciatoia, e' il riconoscimento di un fatto**: le forme sono un
/// dato generato che non cambia mai, e l'insieme dei traguardi accesi cambia un
/// traguardo alla volta. Ricomporre i tracciati a ogni passata era rifare ogni
/// volta un lavoro il cui risultato era identico.
class _LampadineRicordate {
  const _LampadineRicordate({required this.mini, required this.grandi});

  final List<_Lampadina> mini;
  final List<_Lampadina> grandi;
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
    final ricordo =
        _lampadineDi(ancoraggi, forme, traguardi, misura, scala, dx, dy);

    // **L'EVIDENZA STA FUORI DAL RICORDO, ed e' voluto.** E' un elemento solo,
    // cambia a ogni tocco, e tenerla dentro vorrebbe dire buttare via tutto il
    // resto ogni volta che il dito si sposta.
    final evidenza = <_Lampadina>[];
    if (evidenziato != null) {
      for (var i = 0; i < ancoraggi.length; i++) {
        if (traguardi[i].id != evidenziato) continue;
        if (!accesi.contains(traguardi[i].id)) continue;
        evidenza.add(_lampadinaPerUno(forme[i], scala, dx, dy));
      }
    }
    _accendi(tela, ricordo.mini, forza: 0.85);
    _accendi(tela, ricordo.grandi, forza: 1.0);
    _accendi(tela, evidenza, forza: 1.0, enfasi: 1.3);
  }

  /// **CIO' CHE SI TIENE FRA UNA PASSATA E L'ALTRA.**
  ///
  /// **La chiave dice tutto cio' da cui il tracciato dipende**, e se ne
  /// dimenticasse un pezzo il disegno resterebbe indietro senza che nessuno lo
  /// veda: il sentiero, la misura della tela, i colori della sua tavolozza e
  /// **quali** traguardi sono accesi, non quanti. Due insiemi diversi della
  /// stessa lunghezza sono due disegni diversi.
  static final Map<String, _LampadineRicordate> _ricordi = {};

  /// **QUANTI RICORDI SI TENGONO.** Tre sentieri, e una misura di tela per
  /// ciascuno: sopra questo numero si sta tenendo in vita roba che nessuno
  /// riguardera'. Non e' una cache generica, e' una memoria corta e dichiarata.
  static const int quantiRicordi = 6;

  _LampadineRicordate _lampadineDi(
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

    final mini = <_Lampadina>[];
    final grandi = <_Lampadina>[];
    for (var i = 0; i < ancoraggi.length; i++) {
      if (!accesi.contains(traguardi[i].id)) continue;
      (ancoraggi[i].eGrande ? grandi : mini)
          .add(_lampadinaPerUno(forme[i], scala, dx, dy));
    }
    if (_ricordi.length >= quantiRicordi) _ricordi.remove(_ricordi.keys.first);
    return _ricordi[chiave] = _LampadineRicordate(mini: mini, grandi: grandi);
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
  ///
  /// **SUL LOTO LA PALETTE E' FISSA: SEMPRE L'ORO, MAI LA MATERIA.** Ordine AG
  /// voce 02. Le perle sono grigie e la loro tinta mediana e' un accidente
  /// della pittura: due dischi su cinquantacinque (gli indici 13 e 46)
  /// portavano una tinta fredda quasi invisibile, 190 e 220 gradi con
  /// saturazione 0,050 e 0,032, e il pavimento di saturazione 0,74 la
  /// trasformava in azzurro pieno: erano le due lampade azzurre viste
  /// dall'Architetto. Una tinta che nell'arte non si vede non puo' comandare
  /// la luce.
  Color _luceDi(FormaDellElemento forma) {
    if (sentiero == Sentiero.loto) return oro;
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

  /// LA LAMPADINA di UN elemento: forma, cerchio e colore.
  _Lampadina _lampadinaPerUno(
      FormaDellElemento forma, double scala, double dx, double dy) {
    final via = Path();
    _aggiungi(via, forma, scala, dx, dy);
    final s = forma.strisce;
    if (s.length < 3) {
      return _Lampadina(via, Offset.zero, 0, _luceDi(forma));
    }
    var minX = s[1], maxX = s[2], minY = s[0], maxY = s[0];
    for (var k = 0; k + 2 < s.length; k += 3) {
      if (s[k] < minY) minY = s[k];
      if (s[k] > maxY) maxY = s[k];
      if (s[k + 1] < minX) minX = s[k + 1];
      if (s[k + 2] > maxX) maxX = s[k + 2];
    }
    final centro = Offset(
      dx + (minX + maxX + 1) / 2 * scala,
      dy + (minY + maxY + 1) / 2 * scala,
    );
    // Il raggio equivalente discende dall'area, cosi' vale uguale su un disco
    // del Loto e su una sfera dell'Albero.
    final raggio = math.sqrt(forma.area / math.pi) * scala;
    return _Lampadina(via, centro, raggio, _luceDi(forma));
  }

  /// Le strisce di una forma diventano rettangoli dentro un tracciato.
  void _aggiungi(Path tracciato, FormaDellElemento forma, double scala,
      double dx, double dy) {
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

  /// **LA LAMPADINA.** Ordine AF voce 02, difetto di Mauro: una perla accesa
  /// deve leggersi come una lampadina accesa al primo sguardo, non come una
  /// scintilla tenue.
  ///
  /// **SENZA MaskFilter, SENZA sfocature, SENZA BlendMode.plus, ed e' un
  /// vincolo di costruzione**: la tecnica vecchia e' la stessa sospettata di non
  /// comparire affatto sul telefono (difetto Impeller aperto), e un gradiente
  /// disegnato non dipende da quel percorso di rendering. Tre passate per
  /// elemento, tutte in disegno normale: l'ALONE, un gradiente radiale che
  /// sfuma dal colore della materia al niente; il DISCO, la forma ridipinta
  /// piena con un gradiente da bianco caldo a oro caldo, spostato in alto a
  /// sinistra perche' una sfera illuminata ha il colmo dove guarda la luce; il
  /// RIFLESSO, un cerchietto bianco pieno.
  ///
  /// **Il colore dell'alone resta quello della materia**, che e' la legge
  /// dell'ordine X; il disco invece e' bianco caldo e oro caldo per decisione di
  /// Mauro in quest'ordine: la lampadina e' la lampadina, su tutti e tre i
  /// sentieri. **Sul Loto l'alone non si disegna e la luce e' sempre oro**,
  /// ordine AG voce 02: vedi `_luceDi` e il commento dentro `_accendi`.
  ///
  /// **IL PAVIMENTO DEL RAGGIO, ed e' la strada della AC.11**: sotto gli otto
  /// punti logici una lampadina non si legge su uno schermo a 360 di larghezza,
  /// quindi un elemento piu' piccolo si accende comunque come un cerchio da
  /// otto. Il numero e' un pavimento di leggibilita', non una misura dell'arte.
  static const double pavimentoDelRaggio = 8.0;

  /// Il bianco caldo del colmo e l'oro caldo del bordo della lampadina.
  static const Color _biancoCaldo = Color(0xFFFFF3D6);
  static const Color _oroCaldo = Color(0xFFE9B84D);

  void _accendi(Canvas tela, List<_Lampadina> lampadine,
      {required double forza, double enfasi = 1.0}) {
    if (lampadine.isEmpty) return;
    final f = (forza * respiro).clamp(0.0, 1.0);
    for (final lampadina in lampadine) {
      if (lampadina.raggio <= 0) continue;
      final raggio = math.max(lampadina.raggio, pavimentoDelRaggio) * enfasi;
      final centro = lampadina.centro;

      // L'ALONE: un gradiente radiale col colore della materia, disegnato e non
      // sfocato. Cade quando gli effetti pieni sono spenti, come prima.
      //
      // **SUL LOTO L'ALONE E' BIANCO-ORO NEUTRO, MAI LA MATERIA.** Strada 1
      // dell'ordine BF voce 02, scelta dal fondatore. L'ordine AG voce 02
      // aveva tolto l'alone dal Loto perche' il velo COLORATO della materia
      // tingeva i petali dipinti di blu; ma senza nessun alone un traguardo
      // acceso pesava 911 pixel sul Loto contro 4.632 sulla Costellazione
      // (ordine AB voce 02, rapporto 5,1 col tetto a 2). Era la tinta a
      // sporcare, non l'alone in se': col bianco caldo della lampadina,
      // stessa famiglia d'oro dei petali, il peso si pareggia e la tinta
      // non vira. Il divieto della materia sul Loto resta intero.
      if (effettiPieni) {
        // Il neutro del Loto e' il BIANCO PURO, non il bianco caldo: un velo
        // bianco alza i tre canali nella stessa proporzione e la tinta del
        // petalo non si muove di un grado (misurato: col bianco caldo 0xFFF3D6
        // l'anello attorno alla perla virava di 16,4 gradi, col bianco puro di
        // zero). E' luce, non colore: la lettera della guardia AG.02.
        final tintaDellAlone =
            sentiero == Sentiero.loto ? Colors.white : lampadina.colore;
        // Sul Loto le perle stanno fitte sul fiore: l'ampiezza piena da 2,4
        // raggi fondeva gli aloni vicini in una nuvola sola da 45.049 pixel,
        // misurata. Un alone piu' stretto pareggia il peso senza fondere.
        final raggioAlone = raggio * (sentiero == Sentiero.loto ? 2.0 : 2.4);
        tela.drawCircle(
          centro,
          raggioAlone,
          Paint()
            ..shader = ui.Gradient.radial(centro, raggioAlone, [
              tintaDellAlone.withValues(alpha: 0.50 * f),
              tintaDellAlone.withValues(alpha: 0.22 * f),
              tintaDellAlone.withValues(alpha: 0.0),
            ], [
              raggio / raggioAlone,
              0.62,
              1.0,
            ]),
        );
      }

      // IL DISCO: la forma ridipinta luminosa. Il colmo del gradiente sta in
      // alto a sinistra, dove una sfera prende la luce. Se la forma e' piu'
      // piccola del pavimento si disegna il cerchio del pavimento: la
      // leggibilita' vince sulla fedelta' di una forma minuscola.
      final colmo = centro.translate(-raggio * 0.25, -raggio * 0.30);
      final pennello = Paint()
        ..shader = ui.Gradient.radial(colmo, raggio * 1.7, [
          _biancoCaldo.withValues(alpha: 0.95 * f),
          _oroCaldo.withValues(alpha: 0.90 * f),
        ], [
          0.0,
          1.0,
        ]);
      if (lampadina.raggio < pavimentoDelRaggio) {
        tela.drawCircle(centro, raggio, pennello);
      } else {
        tela.drawPath(lampadina.forma, pennello);
      }

      // IL RIFLESSO FORTE: il lampo che dice "accesa" anche in miniatura.
      tela.drawCircle(
        centro.translate(-raggio * 0.32, -raggio * 0.36),
        raggio * 0.24,
        Paint()..color = Colors.white.withValues(alpha: 0.95 * f),
      );
    }
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
      // **SENZA BlendMode.plus, dall'ordine AF**: il plus e' nella famiglia
      // sospettata di non comparire sul telefono, e un gradiente d'alfa in
      // disegno normale dice la stessa cosa.
      ..strokeCap = StrokeCap.round;
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

  Offset _punto(AncoraggioDelSentiero a, double scala, double dx, double dy) =>
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
