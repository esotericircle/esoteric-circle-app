import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/features/santuario/widgets/maestro_bust.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// L'ALONE DIETRO LE FIGURE, misurato in DIFFERENZIALE.
///
/// **Perche' differenziale.** Guardare la sola resa accesa direbbe soltanto che
/// qualcosa e' stato dipinto, non che quel qualcosa stacca la figura dal suo
/// fondo. Si rende la stessa carta due volte, con e senza alone, e si
/// confrontano i pixel: cosi' la misura parla dell'effetto e non del disegno.
///
/// **Le tre grandezze, dichiarate.**
/// - LA FASCIA ATTORNO ALLA SILHOUETTE sono le due colonne di carta subito a
///   lato della figura, all'altezza del centro dell'alone: li' c'e' solo fondo,
///   perche' la figura sta al centro ed e' piu' stretta della cornice. E' la
///   zona in cui lo stacco si vede o non si vede.
/// - IL FONDO LONTANO sono i due angoli bassi della carta, dove la figura non
///   arriva e dove l'alone non deve schiarire niente: se schiarisse anche li'
///   non sarebbe un alone, sarebbe una carta piu' chiara.
/// - I PIXEL DELLA FIGURA non entrano in nessuna delle due, e non potrebbero:
///   l'alone le sta dietro, quindi la figura e' identica nelle due rese, ed e'
///   la garanzia che non le stiamo mettendo un velo sopra.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const misura = Size(220, 380);

  /// Rende la carta di un Maestro e ne restituisce i pixel.
  Future<_Tela> rendi(WidgetTester tester, Maestro maestro,
      {required bool conAlone}) async {
    final chiave = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: RepaintBoundary(
            key: chiave,
            child: MaestroBust(
              maestro: maestro,
              height: misura.height,
              central: true,
              conAlone: conAlone,
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
    // **L'AVATAR SI PRECARICA, e senza non e' una misura differenziale.**
    // `Image.asset` risolve in modo asincrono: eseguita da sola, questa prova
    // rendeva la prima carta senza figura e la seconda con la figura gia' in
    // cache, quindi confrontava due immagini che differivano anche per il
    // busto. In suite intera capitava con l'altra, e il fondo lontano
    // risultava schiarito del 70,9 per cento da un alone che li' non arriva.
    // Precaricando, fra le due rese cambia SOLO l'alone, che e' il punto.
    await tester.runAsync(() => precacheImage(
        AssetImage(maestro.avatarAsset), tester.element(find.byType(Center))));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // **`runAsync` non e' un dettaglio.** `toImage` aspetta la GPU finta del
    // banco di prova, e il tempo di una prova widget e' finto: senza, la
    // chiamata resta appesa per sempre invece di fallire, e l'ho pagato.
    final boundary =
        chiave.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    late _Tela tela;
    await tester.runAsync(() async {
      final immagine = await boundary.toImage(pixelRatio: 1);
      final dati =
          await immagine.toByteData(format: ui.ImageByteFormat.rawRgba);
      tela = _Tela(dati!.buffer.asUint8List(), immagine.width, immagine.height);
    });
    return tela;
  }

  /// La luminanza media di un rettangolo di pixel.
  double luminanzaDi(_Tela tela, Rect zona) {
    var somma = 0.0;
    var quanti = 0;
    for (var y = zona.top.round(); y < zona.bottom.round(); y++) {
      for (var x = zona.left.round(); x < zona.right.round(); x++) {
        if (x < 0 || y < 0 || x >= tela.larghezza || y >= tela.altezza)
          continue;
        final i = (y * tela.larghezza + x) * 4;
        somma += 0.2126 * tela.pixel[i] +
            0.7152 * tela.pixel[i + 1] +
            0.0722 * tela.pixel[i + 2];
        quanti++;
      }
    }
    return quanti == 0 ? 0 : somma / quanti;
  }

  for (final maestro in Maestro.fixedOrder) {
    testWidgets('${maestro.displayName}: l\'alone stacca la figura dal fondo',
        (tester) async {
      final senza = await rendi(tester, maestro, conAlone: false);
      final con = await rendi(tester, maestro, conAlone: true);
      expect(con.larghezza, senza.larghezza);

      // La carta e' larga il 58 per cento dell'altezza della scena e sta in
      // basso; il riquadro reso e' piu' largo di lei perche' comprende l'aura.
      final w = con.larghezza.toDouble();
      final h = con.altezza.toDouble();
      final cartaW = misura.height * 0.58;
      final cartaH = misura.height * 0.84;
      final cartaSinistra = (w - cartaW) / 2;
      final cartaAlto = h - cartaH;

      // L'altezza del centro dell'alone, dal dato dichiarato dal widget.
      final yCentro =
          cartaAlto + cartaH * (1 + AloneDietroLaFigura.centro.y) / 2;

      // Le due colonne a lato della figura: dal bordo interno della cornice
      // verso il centro, per un sesto della larghezza della carta.
      final larghezzaFascia = cartaW / 6;
      final fasce = [
        Rect.fromLTWH(cartaSinistra + 6, yCentro - 30, larghezzaFascia, 60),
        Rect.fromLTWH(cartaSinistra + cartaW - 6 - larghezzaFascia,
            yCentro - 30, larghezzaFascia, 60),
      ];
      var primaDopo = <double>[0, 0];
      for (final f in fasce) {
        primaDopo[0] += luminanzaDi(senza, f) / fasce.length;
        primaDopo[1] += luminanzaDi(con, f) / fasce.length;
      }
      final crescita = (primaDopo[1] - primaDopo[0]) / primaDopo[0] * 100;
      expect(crescita, greaterThanOrEqualTo(25.0),
          reason: 'Attorno alla silhouette la luminanza passa da '
              '${primaDopo[0].toStringAsFixed(1)} a '
              '${primaDopo[1].toStringAsFixed(1)}, cioe'
              ' '
              '${crescita.toStringAsFixed(1)} per cento: sotto il venticinque '
              'chiesto, l\'alone non stacca la figura dal fondo.');

      // Il fondo lontano: gli angoli bassi, dove la figura non arriva.
      final angoli = [
        Rect.fromLTWH(cartaSinistra + 8, cartaAlto + cartaH - 40, 26, 26),
        Rect.fromLTWH(
            cartaSinistra + cartaW - 34, cartaAlto + cartaH - 40, 26, 26),
      ];
      for (final a in angoli) {
        final prima = luminanzaDi(senza, a);
        final dopo = luminanzaDi(con, a);
        final delta = prima == 0 ? 0.0 : (dopo - prima) / prima * 100;
        expect(delta, lessThanOrEqualTo(5.0),
            reason: 'Lontano dalla figura il fondo si schiarisce del '
                '${delta.toStringAsFixed(1)} per cento: oltre il cinque '
                'ammesso, non e\' piu\' un alone ma una carta piu\' chiara.');
      }
    });
  }

  testWidgets('l\'alone non sborda dalla cornice', (tester) async {
    // Fuori dalla carta i pixel devono restare identici: se cambiassero,
    // l'alone starebbe illuminando attorno al riquadro invece che dentro.
    final senza = await rendi(tester, Maestro.medora, conAlone: false);
    final con = await rendi(tester, Maestro.medora, conAlone: true);

    final w = con.larghezza.toDouble();
    final h = con.altezza.toDouble();
    final cartaW = misura.height * 0.58;
    final cartaH = misura.height * 0.84;
    final cartaSinistra = (w - cartaW) / 2;
    final cartaAlto = h - cartaH;

    final fuori = [
      // A sinistra della carta, alla stessa altezza del centro dell'alone.
      Rect.fromLTWH(2, cartaAlto + cartaH * 0.3, cartaSinistra - 6, 60),
      // A destra della carta.
      Rect.fromLTWH(cartaSinistra + cartaW + 4, cartaAlto + cartaH * 0.3,
          cartaSinistra - 6, 60),
    ];
    for (final zona in fuori) {
      if (zona.width < 4) continue;
      final prima = luminanzaDi(senza, zona);
      final dopo = luminanzaDi(con, zona);
      expect((dopo - prima).abs(), lessThan(1.0),
          reason: 'Fuori dalla cornice la luminanza passa da '
              '${prima.toStringAsFixed(2)} a ${dopo.toStringAsFixed(2)}: '
              'l\'alone sta uscendo dalla carta.');
    }
  });

  testWidgets('un testo chiaro sopra la carta illuminata si legge ancora',
      (tester) async {
    // **IL CRITERIO HA OGGETTO, e l'ho verificato guardando l'anteprima.** Nel
    // Santuario la frase del cielo passa SOPRA le carte laterali, proprio alla
    // quota che l'alone illumina: misurata sull'anteprima vera, quella riga sta
    // a 9,63 di contrasto sulla carta di sinistra e a 6,89 su quella di destra.
    //
    // Qui pero' non si rimonta il Santuario, perche' quella misura dipende
    // dalla frase del giorno, che cambia: si misura il caso PEGGIORE, cioe' il
    // punto piu' chiaro a cui l'alone porta il FONDO della carta. Se un testo
    // chiaro si legge li', si legge ovunque sulla carta.
    //
    // **LA GRANDEZZA E' CAMBIATA, e va detto.** La prima stesura prendeva il
    // pixel piu' chiaro di una colonna a lato della figura e dava 1,37 di
    // contrasto, cioe' bocciava. Guardando cosa aveva misurato, era un
    // dettaglio della FIGURA, l'oro di una veste, non il fondo: in quella
    // colonna la figura entra. Una misura che boccia per il motivo sbagliato
    // e' cieca quanto una che promuove.
    //
    // Il fondo si riconosce senza indovinare: sono i pixel che CAMBIANO fra le
    // due rese. La figura sta davanti all'alone, quindi e' identica nelle due,
    // e tutto cio' che cambia e' per costruzione fondo illuminato.
    final senza = await rendi(tester, Maestro.medora, conAlone: false);
    final con = await rendi(tester, Maestro.medora, conAlone: true);
    // **E ANCORA NON BASTAVA: il massimo prendeva la CORNICE.** L'alone sta
    // sopra la carta, quindi illumina anche il filo dorato e i fioroni, che
    // erano gia' chiari per conto loro: il pixel piu' luminoso era un tratto
    // d'oro largo due punti, e dava 1,43. Un tratto d'oro non e' il fondo su
    // cui si posa una frase.
    //
    // Il fondo vero e' quel che cambia ED ERA SCURO PRIMA: la cornice era gia'
    // chiara senza alone, quindi esce da se' senza doverla cercare.
    var massima = 0.0;
    for (var i = 0; i < con.pixel.length; i += 4) {
      final cambia = (con.pixel[i] - senza.pixel[i]).abs() > 2 ||
          (con.pixel[i + 1] - senza.pixel[i + 1]).abs() > 2 ||
          (con.pixel[i + 2] - senza.pixel[i + 2]).abs() > 2;
      if (!cambia) continue;
      final prima = _luminanzaWcag(
          senza.pixel[i], senza.pixel[i + 1], senza.pixel[i + 2]);
      if (prima > 0.10) continue;
      final l =
          _luminanzaWcag(con.pixel[i], con.pixel[i + 1], con.pixel[i + 2]);
      if (l > massima) massima = l;
    }
    // Il testo chiaro dell'app, `ColorTokens.textPrimary`.
    const testo = 0xF4 / 255.0;
    final lTesto = _luminanzaWcag(0xF4, 0xF1, 0xE8);
    final contrasto = (lTesto + 0.05) / (massima + 0.05);
    expect(contrasto, greaterThanOrEqualTo(4.5),
        reason: 'Nel punto piu'
            ' chiaro che l\'alone raggiunge, un testo '
            'chiaro si legge a ${contrasto.toStringAsFixed(2)} di contrasto: '
            'sotto il 4,5, quindi la frase del cielo che passa sopra le carte '
            'laterali sparirebbe. (Il bianco del testo vale $testo.)');
  });

  testWidgets(
      'sopra la carta non c\'e\' testo, quindi non ce n\'e\' da salvare',
      (tester) async {
    // **IL TERZO CRITERIO DELL'ORDINE NON HA OGGETTO, e va detto invece di
    // dichiararlo passato.** Chiedeva che il contrasto di ogni testo sopra la
    // carta restasse oltre 4,5 con l'alone acceso: verificato, sulla carta non
    // c'e' nessun testo, ne' il nome del Maestro ne' altro. Il nome vive
    // altrove nel Santuario, fuori dal riquadro che l'alone illumina.
    //
    // La prova resta perche' il giorno in cui qualcuno scrivesse una parola
    // dentro la carta, questa cade e chiede di rimisurare il contrasto contro
    // un fondo che nel frattempo si e' schiarito del quarantuno per cento.
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: MaestroBust(
              maestro: Maestro.medora, height: misura.height, central: true),
        ),
      ),
    ));
    await tester.pump();
    final testi = find.descendant(
        of: find.byType(MaestroBust), matching: find.byType(Text));
    expect(testi, findsNothing,
        reason: 'Sulla carta e\' comparso del testo: il contrasto va misurato '
            'contro il fondo con l\'alone acceso, che e\' piu\' chiaro del '
            'quarantuno per cento.');
  });

  testWidgets('l\'alone e\' lo stesso per tutti e tre', (tester) async {
    // Un punto solo vuol dire che nessuno dei tre puo' avere il suo valore: se
    // il widget dell'alone comparisse piu' volte con misure diverse, questa
    // prova non se ne accorgerebbe, ma il dato che governa il disegno e' uno e
    // si legge da qui.
    for (final maestro in Maestro.fixedOrder) {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Center(
            child: MaestroBust(
                maestro: maestro, height: misura.height, central: true),
          ),
        ),
      ));
      await tester.pump();
      expect(find.byType(AloneDietroLaFigura), findsOneWidget,
          reason: '${maestro.displayName} non porta l\'alone, oppure ne porta '
              'piu\' di uno.');
    }
  });
}

/// I pixel di una resa, con le sue misure.
class _Tela {
  const _Tela(this.pixel, this.larghezza, this.altezza);
  final Uint8List pixel;
  final int larghezza;
  final int altezza;
}

/// La luminanza relativa secondo le WCAG, sui tre canali a 0..255.
double _luminanzaWcag(int r, int g, int b) {
  double canale(int v) {
    final x = v / 255.0;
    return x <= 0.03928
        ? x / 12.92
        : math.pow((x + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * canale(r) + 0.7152 * canale(g) + 0.0722 * canale(b);
}
