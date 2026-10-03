import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/rituals/tempi_del_respiro.dart';
import 'package:esoteric_circle/design_system/components/guida_del_respiro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// OGNI LETTERA DEL TITOLO STA SUL VELO, NON SUL PRATO.
///
/// Ordine 2171, voce 7. Nel Soffio il fondale e' un prato chiaro, e il velo
/// scuro dietro il titolo esiste per una ragione sola: una parola chiara su un
/// prato chiaro non si legge.
///
/// **La causa era geometrica.** Il velo aveva raggio 999, cioe' la forma a
/// pillola: gli angoli curvano di meta' dell'altezza, e quel contenitore
/// diventa alto piu' di cento punti quando porta il conto alla rovescia. Il
/// titolo finiva nella fascia piu' stretta, e le ultime lettere uscivano sul
/// prato. Misurato da Mauro sull'anteprima a 360 punti: alla quota della prima
/// riga di lettere il velo cominciava a 250 e il testo a 220, e a destra il
/// velo finiva a 832 mentre il testo arrivava a 860.
///
/// **E IL PRESIDIO DEL GIRO SCORSO MISURAVA LA GRANDEZZA SBAGLIATA.** Diceva
/// "la parola resta intera su una riga sola", ed era vero mentre le lettere
/// stavano fuori: una parola puo' restare intera e su una riga sola e uscire
/// lo stesso dal riquadro che dovrebbe proteggerla. Qui si misura l'unica cosa
/// che conta per la leggibilita': sotto ogni pixel del titolo c'e' il velo, e
/// non il prato.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Il prato del Soffio, chiaro: e' il fondale su cui il titolo sparirebbe.
  const prato = Color(0xFFBFD5B2);

  Widget attorno() => const MaterialApp(
        home: Scaffold(
          backgroundColor: prato,
          body: Center(
            child: RepaintBoundary(
              key: Key('scena_respiro'),
              child: GuidaDelRespiro(
                tempi: TempiDelRespiro(tempi: 4, giri: 3),
                colore: Color(0xFFD8C89B),
              ),
            ),
          ),
        ),
      );

  /// Se quel pixel E' IL PRATO.
  ///
  /// **La prima stesura guardava solo la luminosita' e non separava niente.**
  /// Sotto il titolo trovava 695 pixel chiari e li chiamava prato, ma erano le
  /// LETTERE, che sono dorate e chiare per definizione: il piu' chiaro valeva
  /// il 116 per cento del prato, cioe' piu' del prato stesso. Era oro, non
  /// erba, e la prova avrebbe accusato un difetto che non c'era.
  ///
  /// A separare le tre superfici e' la TINTA, non la luce. Il prato e' verde
  /// (0xBFD5B2: il verde supera il rosso), le lettere sono oro (il rosso
  /// supera il verde), il velo e' scuro. Non e' la soglia a essere cambiata:
  /// e' cio' che si guarda.
  bool eIlPrato(ByteData dati, int larghezza, int x, int y) {
    final i = (y * larghezza + x) * 4;
    final r = dati.getUint8(i);
    final g = dati.getUint8(i + 1);
    final b = dati.getUint8(i + 2);
    final luce = 0.2126 * r + 0.7152 * g + 0.0722 * b;
    const luceDelPrato = 0.2126 * 0xBF + 0.7152 * 0xD5 + 0.0722 * 0xB2;
    return luce / luceDelPrato > 0.85 && g > r + 4 && g > b + 8;
  }

  /// Quanti pixel di prato ci sono sotto il rettangolo del titolo, nella
  /// scena montata in questo momento.
  Future<int> pratoSottoIlTitolo(WidgetTester tester, String quando) async {
    final titolo = find.text(ParoleDelRespiro.preparati);
    expect(titolo, findsOneWidget,
        reason: '$quando il titolo non c\'e\' piu\': la prova non misura piu\' '
            'niente');
    final testo = tester.getRect(titolo);
    final scena = tester.getRect(find.byKey(const Key('scena_respiro')));
    final velo = tester.getRect(find.byKey(const Key('respiro_velo')));

    late int larghezza;
    late int altezza;
    late ByteData dati;
    await tester.runAsync(() async {
      // **runAsync non e' un dettaglio**: `toImage` aspetta la GPU finta del
      // banco di prova, e il tempo di una prova widget e' finto. Senza, la
      // chiamata resta appesa invece di fallire.
      final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const Key('scena_respiro')));
      final img = await boundary.toImage(pixelRatio: 1.0);
      larghezza = img.width;
      altezza = img.height;
      dati = (await img.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    });

    // Si scandisce il rettangolo del TESTO, non quello del velo: le lettere
    // stanno qui, e qui sotto deve esserci la superficie scura.
    final x0 = math.max(0, (testo.left - scena.left).round());
    final x1 = math.min(larghezza, (testo.right - scena.left).round());
    final y0 = math.max(0, (testo.top - scena.top).round());
    final y1 = math.min(altezza, (testo.bottom - scena.top).round());

    var fuori = 0;
    var xPrimo = -1;
    var yPrimo = -1;
    for (var y = y0; y < y1; y++) {
      for (var x = x0; x < x1; x++) {
        if (eIlPrato(dati, larghezza, x, y)) {
          fuori++;
          if (xPrimo < 0) {
            xPrimo = x;
            yPrimo = y;
          }
        }
      }
    }
    // ignore: avoid_print
    print('SOFFIO $quando: velo alto ${velo.height.toStringAsFixed(1)} punti, '
        'titolo ${testo.width.toStringAsFixed(1)}x'
        '${testo.height.toStringAsFixed(1)}; pixel di prato sotto il titolo: '
        '$fuori${fuori > 0 ? ", il primo a ($xPrimo, $yPrimo)" : ""}');
    return fuori;
  }

  testWidgets('sotto OGNI pixel del titolo c\'e\' il velo, non il prato',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(attorno());
    await tester.pump();

    // 1. ALL'APERTURA, col velo basso.
    expect(await pratoSottoIlTitolo(tester, 'all\'apertura'), 0,
        reason: 'gia\' all\'apertura le lettere del titolo finiscono su fondo '
            'chiaro, che e\' il difetto di contrasto per cui il velo esiste');

    // **IL CONTO ALLA ROVESCIA NON SI MISURA QUI, e la ragione conta.**
    // Appena parte il conto il titolo cambia: "Preparati a respirare" lascia
    // il posto alla parola del momento, piu' corta, che nel velo ci sta
    // comodamente. La scena del difetto e' questa, all'apertura, dove il velo
    // e' gia' alto 131 punti perche' contiene anche la forma del respiro.
  });

  testWidgets('il titolo sta dentro la FORMA del velo, angoli compresi',
      (tester) async {
    // **LA MISURA DELLA CAUSA, e non del solo effetto.**
    //
    // La scansione a pixel qui sopra guarda il risultato; questa guarda la
    // geometria che lo produce, ed e' quella che cade appena il raggio torna
    // eccessivo. Un riquadro ad angoli tondi non e' un rettangolo: alla quota
    // del titolo, che sta a otto punti dal bordo superiore, la larghezza utile
    // e' minore di quella del velo, e di quanto lo dice il raggio.
    //
    // Col raggio 999 su un velo alto 131 punti, Flutter scala la curvatura a
    // meta' dell'altezza, cioe' 65,5: a otto punti dal bordo la forma perde 34
    // punti per lato e ne restano 184 contro i 215 del titolo. Trentuno punti
    // di lettere fuori, quindici per lato. Con raggio 28 la perdita a quella
    // quota e' di 8 punti per lato e ne restano 236: il titolo ci sta.
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(attorno());
    await tester.pump();

    final velo = tester.getRect(find.byKey(const Key('respiro_velo')));
    final testo = tester.getRect(find.text(ParoleDelRespiro.preparati));

    // Il raggio vero, letto dal widget e non supposto.
    final contenitore =
        tester.widget<Container>(find.byKey(const Key('respiro_velo')));
    final decorazione = contenitore.decoration! as BoxDecoration;
    final raggioDichiarato =
        (decorazione.borderRadius! as BorderRadius).topLeft.x;
    // Flutter non disegna mai una curva piu' grande di meta' del lato piu'
    // corto: e' quella la curvatura che conta, non il numero scritto.
    final raggio =
        math.min(raggioDichiarato, math.min(velo.width, velo.height) / 2);

    /// Quanta larghezza resta alla quota [y], misurata dal bordo superiore.
    double larghezzaUtile(double y) {
      final dalBordo = math.min(y - velo.top, velo.bottom - y);
      if (dalBordo >= raggio) return velo.width;
      final dx = raggio -
          math.sqrt(
              raggio * raggio - (raggio - dalBordo) * (raggio - dalBordo));
      return velo.width - 2 * dx;
    }

    // La quota peggiore per il titolo e' la sua riga piu' vicina al bordo.
    final utile =
        math.min(larghezzaUtile(testo.top), larghezzaUtile(testo.bottom));
    // ignore: avoid_print
    print('SOFFIO forma: raggio dichiarato $raggioDichiarato, curvatura vera '
        '${raggio.toStringAsFixed(1)}; alla quota del titolo restano '
        '${utile.toStringAsFixed(1)} punti su ${velo.width.toStringAsFixed(1)}, '
        'e il titolo ne chiede ${testo.width.toStringAsFixed(1)}');

    expect(utile, greaterThanOrEqualTo(testo.width),
        reason: 'alla quota del titolo la forma del velo lascia solo '
            '${utile.toStringAsFixed(1)} punti, ma il titolo ne occupa '
            '${testo.width.toStringAsFixed(1)}: '
            '${(testo.width - utile).toStringAsFixed(1)} punti di lettere '
            'finiscono fuori dalla superficie scura, sul prato');
  });

  testWidgets('il velo copre il titolo con un margine, non a filo',
      (tester) async {
    // Zero pixel di prato non basta come unica misura: un velo largo esatto
    // quanto il testo passerebbe, e basterebbe un carattere leggermente piu'
    // largo su un altro telefono per riaprire il difetto.
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(attorno());
    await tester.pump();

    final testo = tester.getRect(find.text(ParoleDelRespiro.preparati));
    final velo = tester.getRect(find.byKey(const Key('respiro_velo')));
    final margineSinistro = testo.left - velo.left;
    final margineDestro = velo.right - testo.right;

    // ignore: avoid_print
    print('SOFFIO: il velo va da ${velo.left.toStringAsFixed(1)} a '
        '${velo.right.toStringAsFixed(1)}, il titolo da '
        '${testo.left.toStringAsFixed(1)} a '
        '${testo.right.toStringAsFixed(1)}: margini '
        '${margineSinistro.toStringAsFixed(1)} e '
        '${margineDestro.toStringAsFixed(1)} punti');

    expect(margineSinistro, greaterThanOrEqualTo(8),
        reason: 'a sinistra il velo lascia solo '
            '${margineSinistro.toStringAsFixed(1)} punti: e\' a filo, e basta '
            'un carattere piu\' largo per far uscire la prima lettera');
    expect(margineDestro, greaterThanOrEqualTo(8),
        reason: 'a destra il velo lascia solo '
            '${margineDestro.toStringAsFixed(1)} punti: e\' a filo');
  });
}
