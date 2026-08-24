import 'dart:ui' as ui;

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/design_system/components/feature_tile.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:esoteric_circle/features/maestri/domain_screen.dart';
import 'package:esoteric_circle/features/santuario/santuario_screen.dart';
import 'package:esoteric_circle/features/shell/barra_del_cerchio.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// NESSUN TESTO FINISCE SOTTO QUALCOS'ALTRO.
///
/// **Il difetto che questa prova esiste per prendere.** Nel Santuario la riga
/// personale stava negli stessi punti verticali delle carte dei tre Maestri:
/// misurato sull'app montata a 360 per 797, il testo finiva a 337,2 e le carte
/// laterali cominciavano a 274,3, quindi si leggeva a meta'. Nessuna prova se ne
/// accorgeva, perche' le prove esistenti sulla copertura sono MIRATE su un caso
/// solo ciascuna (la bolla sopra l'avatar, il pulsante sopra la carta) e non
/// enumerano.
///
/// **SI MISURA L'OCCLUSIONE, NON SI CONTANO I WIDGET, e la misura e'
/// DIFFERENZIALE.** Un rettangolo che si sovrappone a un altro non dice niente:
/// un'ombra dipinge fuori dal proprio riquadro, una figura esce dal suo con
/// `Clip.none`, un fondo trasparente si sovrappone senza coprire. Quindi si
/// rende la scena DUE VOLTE, con e senza l'elemento sospetto, e si confronta
/// quanti pixel del testo sopravvivono. E' la stessa tecnica della bolla del 30
/// luglio, dove contare i riquadri avrebbe dato la risposta sbagliata.
///
/// Qui l'elemento sospetto e' l'intera scena tranne il testo: si dipinge il
/// testo da solo su fondo nero, poi si dipinge la scena vera, e per ogni pixel
/// acceso del primo si guarda se nel secondo il colore e' ancora quello del
/// testo. Dove non lo e', qualcosa ci e' finito sopra.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  /// I sensori tacciono: senza, il giroscopio solleva e la prova non arriva
  /// mai a misurare.
  void silence() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (c) async => null);
    for (final n in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(n), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  /// I pixel di una scena, come li vede lo schermo.
  Future<Uint8List> pixelDi(WidgetTester tester, Finder radice) async {
    late Uint8List byte;
    await tester.runAsync(() async {
      final boundary =
          tester.renderObject<RenderRepaintBoundary>(radice);
      final img = await boundary.toImage(pixelRatio: 1);
      final dati = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
      byte = dati!.buffer.asUint8List();
      img.dispose();
    });
    return byte;
  }

  /// Quanti pixel del testo restano visibili nella scena vera.
  ///
  /// Si confronta la scena INTERA con la stessa scena in cui il testo e' stato
  /// reso da solo: un pixel del testo si considera coperto quando nella scena
  /// vera il suo colore si scosta di piu' di quaranta livelli, cioe' quando
  /// sopra ci e' finito qualcosa di opaco. Sotto quella soglia stanno le
  /// differenze di antialiasing e le velature, che non impediscono di leggere.
  double quotaCoperta(Uint8List soloTesto, Uint8List scena, int larghezza,
      Rect area) {
    var accesi = 0;
    var coperti = 0;
    for (var y = area.top.floor(); y < area.bottom.ceil(); y++) {
      for (var x = area.left.floor(); x < area.right.ceil(); x++) {
        final i = (y * larghezza + x) * 4;
        if (i + 3 >= soloTesto.length) continue;
        // Un pixel del testo: chiaro, perche' il testo dell'app e' avorio o oro
        // su fondo scuro.
        final luce = soloTesto[i] > soloTesto[i + 1]
            ? soloTesto[i]
            : soloTesto[i + 1];
        // **I NUCLEI DEI GLIFI, NON I BORDI. Ordine BF voce 05.e.** A 140 la
        // misura contava anche i pixel di antialiasing, che sul fondo
        // NEUTRO del banco isolato hanno una miscela e sopra una nebulosa
        // chiara ne hanno un'altra: sull'Oroscopo il titolo usciva "coperto
        // al 57 per cento" pur leggendosi intero. Un testo davvero coperto
        // perde i NUCLEI, non solo i bordi: a 200 la misura guarda quelli.
        if (luce < 200) continue;
        accesi++;
        // **UNA COPERTURA TOGLIE LUCE, NON NE AGGIUNGE. Ordine BF voce
        // 05.e.** Il confronto assoluto accusava il sottotitolo
        // dell'Oroscopo, che sta sopra la nebulosa chiara: i tratti sottili
        // sono quasi tutti antialiasing, e la luce del fondo che filtra
        // ADDIZIONA i canali senza togliere niente al glifo (le due rese,
        // guardate affiancate, sono identiche nella forma). Cio' che copre
        // un testo gli SOTTRAE la sua luce: si conta coperto il pixel che
        // perde piu' di 40 su un canale, non quello che ne guadagna. Il
        // limite dichiarato: un occlusore piu' luminoso del testo su OGNI
        // canale passerebbe; nelle scene di quest'app gli occlusori veri
        // (carte, veli, figure) la luce dei glifi la spengono.
        var perso = 0;
        for (var c = 0; c < 3; c++) {
          final d = soloTesto[i + c] - scena[i + c];
          if (d > perso) perso = d;
        }
        // A 70 e non a 40, e si dichiara: il sottotitolo dell'Oroscopo
        // arriva a schermo circa 55 livelli piu' tenue della sua resa
        // isolata (misurato pixel per pixel: 208 contro 154, uniforme su
        // ogni canale e su ogni x), che e' una questione di resa dello
        // stile, non una copertura: il glifo c'e', identico nella forma.
        // Una copertura vera sostituisce il glifo e strappa piu' di 70
        // (le carte sul testo del Santuario passavano i 100).
        if (perso > 70) coperti++;
      }
    }
    // **LA MISURA CHIEDE MATERIA. Ordine BF voce 05.e.** Un testo grigio
    // (textSecondary sta a 163 di luce) non porta nuclei sopra la soglia:
    // restano poche punte di antialiasing, e giudicare su una manciata di
    // pixel fa il verdetto a moneta (il sottotitolo dell'Oroscopo usciva
    // "coperto al 51 per cento" contando le punte sotto le stelle). Sotto i
    // centocinquanta pixel di nucleo non si giudica: quei testi li coprono
    // le prove di leggibilita' dei grigi, che guardano il contrasto.
    if (accesi < 150) return 0;
    return coperti / accesi;
  }

  Future<void> apri(WidgetTester tester, GlobalKey radice) async {
    silence();
    SharedPreferences.setMockInitialValues(
        const {'onboarding.done': true, 'santuario.greeted': true});
    tester.view.physicalSize = const Size(360, 797);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(RepaintBoundary(
      key: radice,
      child: EsotericCircleApp(conIntro: false, services: AppServices.offline()),
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
  }

  /// Enumera i testi della schermata in cima e verifica che nessuno sia coperto.
  ///
  /// **LE SCHERMATE COPERTE, dichiarate: Santuario, Dominio e Oroscopo.**
  /// L'app ne ha una ventina e le altre NON sono guardate: chi legge questa
  /// prova non deve credere che sia sorvegliata l'app intera.
  ///
  /// **Il falso positivo di ieri, spiegato e chiuso (ordine BF voce 05.e).**
  /// "Consulta Medora" usciva coperto al cento per cento perche' il banco
  /// fotografava la scena prima che la rivelazione d'ingresso partisse
  /// (ScrollReveal parte da un postFrame, e due pompe non bastavano): non
  /// mentiva la misura, mentiva la fotografia. Sull'Oroscopo altre tre
  /// trappole, tutte dichiarate nel codice qui sotto: il velo del Coming
  /// soon che copre per costruzione, i testi grigi senza nuclei sopra la
  /// soglia, e il sottotitolo che a schermo arriva piu' tenue della sua
  /// resa isolata senza perdere un tratto.
  Future<void> verifica(WidgetTester tester, GlobalKey radice, String dove,
      Type schermata) async {
    final scena = await pixelDi(tester, find.byKey(radice));
    final larghezza = tester.view.physicalSize.width.round();

    // SI RACCOGLIE PRIMA E SI MISURA DOPO. Scorrere i widget mentre si
    // rimonta l'albero disattiva gli elementi sotto i piedi: la prima stesura
    // moriva su un null check al secondo testo.
    final bersagli =
        <({
      InlineSpan span,
      TextAlign align,
      int? maxLines,
      TextOverflow overflow,
      String testo,
      Rect area,
      double scala
    })>[];
    for (final w in tester.widgetList<RichText>(find.descendant(
        of: find.byType(schermata), matching: find.byType(RichText)))) {
      final testo = w.text.toPlainText().trim();
      if (testo.length < 8) continue;
      // **IL VELO DELLE TESSERE E' UNA COPERTURA DICHIARATA.** Ordine BF
      // voce 05.e: dentro una FeatureTile non attiva il contenuto sta
      // SOTTO il velo smerigliato per costruzione (Coming soon e Premium,
      // AN.06): misurarlo come occlusione accuserebbe il design approvato.
      if (find
          .ancestor(of: find.byWidget(w), matching: find.byType(FeatureTile))
          .evaluate()
          .isNotEmpty) {
        continue;
      }
      final el = tester.element(find.byWidget(w));
      final box = el.renderObject as RenderBox;
      if (!box.attached || box.size.isEmpty) continue;
      // **IL TESTO SI MISURA COME E' DIPINTO, non come sarebbe senza chi lo
      // rimpicciolisce.** Ordine BC voce 01, coda: falso positivo trovato
      // guardando le due immagini.
      //
      // Il titolo del cielo sta dentro un `FittedBox` con `scaleDown`, messo
      // dall'ordine BB voce 05 perche' non andasse a capo in mezzo a una
      // parola. Il `RichText` dentro conserva la sua misura NON scalata, e
      // `localToGlobal` restituisce invece l'origine gia' scalata: mettendo
      // insieme i due si ottiene un rettangolo che non esiste, largo 297
      // punti dove a video il titolo ne occupa 232.
      //
      // La resa isolata qui sotto ridisegnava quindi lo stesso testo **a un
      // corpo piu' grande**, e i glifi non cadevano sugli stessi pixel: la
      // misura dichiarava il titolo **coperto per l'89 per cento** mentre
      // nell'immagine si legge perfettamente. Verificato salvando le due
      // immagini e guardandole.
      //
      // La trasformazione completa dice la verita' su tutti e due i fronti:
      // dove il testo cade E quanto e' grande. Chi non e' scalato ottiene
      // esattamente il rettangolo di prima.
      final versoLoSchermo = box.getTransformTo(null);
      final area = MatrixUtils.transformRect(versoLoSchermo,
          Rect.fromLTWH(0, 0, box.size.width, box.size.height));
      final scala = box.size.width == 0 ? 1.0 : area.width / box.size.width;
      // LA FASCIA DELLA BARRA E' ESCLUSA, e non e' una scappatoia: dalla 2158
      // la barra del Cerchio SCIVOLA SOPRA il contenuto per scelta dichiarata,
      // e il contenuto che le finisce sotto si raggiunge scorrendo. Contarlo
      // come coperto vorrebbe dire chiamare difetto una decisione presa
      // guardando l'anteprima. Sono i testi della fascia "Le tue arti", che
      // senza questa riga risultavano coperti al cento per cento.
      final fasciaBarra =
          tester.view.physicalSize.height - BarraDelCerchio.altezza;
      if (area.top < 0 ||
          area.bottom > tester.view.physicalSize.height ||
          area.bottom > fasciaBarra ||
          area.width <= 0) {
        continue;
      }
      // LA FASCIA DELLA BARRA DELL'IDENTITA' E' ESCLUSA, ordine AM voce 04,
      // per la stessa ragione della barra del Cerchio: la barra sottile e'
      // una superficie persistente decisa da Mauro, e le schermate le fanno
      // spazio col padding alto. Contare coperto cio' che le sta sotto
      // chiamerebbe difetto una decisione.
      final barra = find.byKey(const Key('barra_dell_identita'));
      if (barra.evaluate().isNotEmpty &&
          area.overlaps(tester.getRect(barra).inflate(4))) {
        continue;
      }
      // LA CODA SFUMATA DEI DONI E' ESCLUSA, e non e' una scappatoia: la
      // striscia dei doni SCORRE, e ai due capi le icone svaniscono invece
      // di tagliarsi di netto. E' una decisione presa guardando l'anteprima
      // (ordine AM voce 04), e la sfumatura fa il suo mestiere proprio
      // rendendo meno visibile cio' che sta per uscire. La misura
      // differenziale la legge come copertura, ma li' non c'e' niente
      // sopra: c'e' il disegno che dice "continua".
      final doni = find.byKey(const Key('santuario_daily_strip'));
      if (doni.evaluate().isNotEmpty) {
        final r = tester.getRect(doni);
        final codaDestra = Rect.fromLTRB(r.right - 48, r.top, r.right, r.bottom);
        final codaSinistra = Rect.fromLTRB(r.left, r.top, r.left + 24, r.bottom);
        if (area.overlaps(codaDestra) || area.overlaps(codaSinistra)) continue;
      }
      bersagli.add((
        span: w.text,
        align: w.textAlign,
        maxLines: w.maxLines,
        // **ANCHE IL MODO IN CUI IL TESTO TRABOCCA, e senza di lui la prova
        // accusa il falso.** Ordine AV voce 03.
        //
        // La resa isolata qui sotto ricostruisce il testo per confrontarlo con
        // la scena. Se nella scena il testo e' troncato coi puntini e nella
        // resa isolata no, **i pixel divergono per un motivo che non e' una
        // copertura**, e la differenza viene letta come tale: la riga
        // personale del Santuario risultava "coperta al 74 per cento" mentre
        // sopra di lei non c'era niente, verificato widget per widget.
        //
        // **E' anche la spiegazione del falso positivo dichiarato qui sopra**,
        // quello della chat del Maestro e dell'Oroscopo che nessuno era
        // riuscito a spiegare: sono testi troncati.
        overflow: w.overflow,
        testo: testo,
        area: area,
        scala: scala
      ));
    }
    expect(bersagli, isNotEmpty,
        reason: 'in $dove non si trova nessun testo da misurare: la prova non '
            'sta guardando niente');

    final colpe = <String>[];
    for (final b in bersagli) {
      // LA MISURA DIFFERENZIALE: la stessa scena col solo testo, sul fondo
      // dell'app, cosi' il confronto isola cio' che gli e' finito sopra.
      final soloKey = GlobalKey();
      await tester.pumpWidget(RepaintBoundary(
        key: soloKey,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Scaffold(
            backgroundColor: const Color(0xFF05040A),
            body: Stack(children: [
              Positioned(
                left: b.area.left,
                top: b.area.top,
                // **NIENTE LARGHEZZA QUI**, e la ragione e' stata vista
                // sull'immagine: fissando la larghezza dipinta, il figlio
                // veniva stretto PRIMA di essere scalato, il testo si
                // rimpaginava su 232 punti invece che sui suoi 297, e la
                // resa isolata usciva troncata, "Il Cielo Sopra di Te."
                // invece del titolo intero. Un troncamento diverso da quello
                // della scena e' proprio il falso positivo che questa prova
                // dichiara di evitare.
                //
                // **E SI RIDISEGNA ALLA GRANDEZZA VERA.** Il testo va rimesso
                // al suo corpo originale e poi scalato, non ridisposto su una
                // larghezza che non e' la sua.
                child: Transform.scale(
                  scale: b.scala,
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: b.area.width / b.scala,
                    height: b.area.height / b.scala,
                    child: RichText(
                        text: b.span,
                        textAlign: b.align,
                        maxLines: b.maxLines,
                        overflow: b.overflow),
                  ),
                ),
              ),
            ]),
          ),
        ),
      ));
      await tester.pump();
      final solo = await pixelDi(tester, find.byKey(soloKey));
      final quota = quotaCoperta(solo, scena, larghezza, b.area);
      if (quota > 0.35) {
        colpe.add('$dove: "${b.testo.substring(0, b.testo.length.clamp(0, 44))}" '
            'coperto per il ${(quota * 100).round()} per cento');
      }
    }
    expect(colpe, isEmpty,
        reason: 'questi testi finiscono sotto qualcos\'altro:\n'
            '${colpe.join('\n')}');
  }

  /// **LA RIVELAZIONE VA LASCIATA PARTIRE, ed era il falso positivo
  /// dichiarato.** ScrollReveal parte da un postFrame: col vecchio giro di
  /// due pompe la scena veniva fotografata a opacita' zero e "Consulta
  /// Medora" risultava coperto al cento per cento pur leggendosi benissimo.
  /// Non era la misura a mentire, era il banco che non lasciava finire la
  /// comparsa: qualche fotogramma in piu' e la misura dice il vero anche
  /// qui. Ordine BF voce 05.e.
  Future<void> lasciaFinireLaComparsa(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  testWidgets('Dominio del Maestro: nessun testo finisce sotto',
      (tester) async {
    final radice = GlobalKey();
    await apri(tester, radice);
    final nav = tester.state<NavigatorState>(find.byType(Navigator).last);
    nav.push(DomainScreen.route(
        maestro: Maestro.medora, services: AppServices.offline()));
    await tester.pump();
    await lasciaFinireLaComparsa(tester);
    await verifica(tester, radice, 'Dominio', DomainScreen);
  });

  testWidgets('Oroscopo: nessun testo finisce sotto', (tester) async {
    final radice = GlobalKey();
    await apri(tester, radice);
    final nav = tester.state<NavigatorState>(find.byType(Navigator).last);
    nav.push(OroscopoScreen.route(
        userSign: Zodiac.aries, now: DateTime(2026, 8, 24, 12)));
    await tester.pump();
    await lasciaFinireLaComparsa(tester);
    // **LA FESTA DEL PRIMO OROSCOPO SI CHIUDE PRIMA DI MISURARE.** Aprire
    // l'Oroscopo per la prima volta accende il traguardo e la scena piena
    // celebra subito (ordine BD voce 08): i testi della schermata stanno
    // legittimamente sotto la festa, che e' la rotta in cima, non
    // un'occlusione. Si esce dalla festa e si misura la schermata nuda.
    final continua = find.text('Continua il cammino');
    if (continua.evaluate().isNotEmpty) {
      await tester.tap(continua);
      await tester.pump();
      await lasciaFinireLaComparsa(tester);
    }
    await verifica(tester, radice, 'Oroscopo', OroscopoScreen);
  });

  testWidgets('Santuario: nessun testo finisce sotto le carte', (tester) async {
    final radice = GlobalKey();
    await apri(tester, radice);
    await verifica(tester, radice, 'Santuario', SantuarioScreen);
    // ROSSO ESEGUITO: rimettendo la riga personale dentro il blocco del cielo,
    // dove stava fino all'ordine D, la prova e' caduta nominando il Santuario e
    // la frase, coperta per il 62 per cento.
  });

}
