import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/maestro/tempi_dell_attesa.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/tarot/tarot_reading.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/core/tarot/tetti_della_stesa.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:esoteric_circle/features/tarot/attesa_di_medora.dart';
import 'package:esoteric_circle/features/tarot/stesa_choreography.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// LA STESA SI CAPISCE, ordine P voci da 05 a 10.
///
/// Sei voci, sei misure diverse, perche' sei difetti diversi non si prendono
/// con la stessa prova.
///
/// - **P.05**, il taglio: le quattro fasi hanno una durata dichiarata in un
///   punto solo, il totale sta sotto la soglia oltre la quale un'animazione
///   diventa attesa, le carte gia' estratte non si muovono di un punto, la
///   meta' di sotto va davvero SOPRA, e con Riduci Movimento le quattro fasi
///   diventano quattro stati e non zero.
/// - **P.06**, l'attesa: fra l'ultima carta e il primo responso c'e' una scena,
///   con almeno tre righe nella voce di Medora, e il minimo garantito viene da
///   [TempiDellAttesa] invece di essere riscritto.
/// - **P.07**, la bolla chiave: e' uno STATO di una delle tre bolle, e si
///   distingue A PIXEL oltre una soglia dichiarata nel codice.
/// - **P.08**, le due bolle: non esistono piu', ne' come widget ne' come testo
///   generato.
/// - **P.09**, il consiglio: e' la prima bolla, la piu' lunga, nomina almeno
///   due delle tre carte e finisce con la domanda dopo una riga di stacco.
/// - **P.10**, la larghezza: nessuna riga del blocco sotto la carta scende
///   sotto le quattro parole quando lo spazio ne consentirebbe di piu'.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
    final m = binding.defaultBinaryMessenger;
    m.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
        (call) async => null);
    for (final nome in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      m.setMockStreamHandler(
          EventChannel(nome), MockStreamHandler.inline(onListen: (a, e) {}));
    }
  }

  Future<void> caricaCaratteri() async {
    for (final f in const [
      ['Cinzel', 'assets/fonts/Cinzel-variable.ttf'],
      ['EBGaramond', 'assets/fonts/EBGaramond-variable.ttf'],
    ]) {
      final loader = FontLoader(f[0]);
      loader.addFont(
          Future.value(ByteData.view(File(f[1]).readAsBytesSync().buffer)));
      await loader.load();
    }
  }

  /// LA LARGHEZZA REALE, quella del telefono su cui l'app viene guardata:
  /// 1080 pixel fisici con rapporto 3, cioe' 360 punti logici. Non si deduce e
  /// non si arrotonda: e' la stessa del corredo delle anteprime.
  const double larghezzaReale = 360;

  Widget attorno(Widget scena, {bool riduciMovimento = false}) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: MediaQuery(
          data: MediaQueryData(disableAnimations: riduciMovimento),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: MaestroScope(child: scena),
          ),
        ),
      );

  /// Monta la stesa alla larghezza reale. L'altezza e' larga a piacere: quel
  /// che la lista non costruisce, la prova non lo troverebbe.
  Future<GlobalKey> monta(
    WidgetTester tester, {
    int seed = 2,
    bool revealAll = true,
    bool riduciMovimento = false,
    double altezza = 4400,
  }) async {
    silenzia();
    await caricaCaratteri();
    tester.view.physicalSize = Size(larghezzaReale, altezza);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final radice = GlobalKey();
    await tester.pumpWidget(attorno(
      RepaintBoundary(
        key: radice,
        child: StesaTreCarteScreen(
          seed: seed,
          revealAll: revealAll,
          skipIntro: true,
          topic: TarotTopic.bivio,
        ),
      ),
      riduciMovimento: riduciMovimento,
    ));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    return radice;
  }

  /// PESCA LA CARTA [indice] DAL VENTAGLIO, e pesca DAVVERO quella.
  ///
  /// Il centro di una carta dell'arco e' coperto dalla carta successiva, che sta
  /// sopra: toccare il centro fa pescare la vicina, e tre tocchi al centro
  /// potevano prendere due volte la stessa. La striscia scoperta e' quella a
  /// sinistra, larga quanto il passo fra due dorsi.
  Future<void> pesca(WidgetTester tester, int indice) async {
    final carta = find.byKey(Key('stesa_fan_$indice'));
    expect(carta, findsOneWidget, reason: 'la carta $indice non e\' nell\'arco');
    final r = tester.getRect(carta);
    await tester.tapAt(Offset(r.left + 6, r.center.dy));
    await tester.pump();
    // Il volo, poi il flip: due attese distinte, perche' il flip parte quando
    // la carta e' arrivata nel suo slot.
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 200));
  }

  /// La stesa VERA che la schermata ha in mano.
  ///
  /// Non `TarotSpread.draw(seed:)`: quella pesca col suo caso e da' versi
  /// diversi da `StesaInCorso`, che li fa nascere da `versoDi`. Chiedere alla
  /// schermata invece di rifare il conto e' la stessa regola per cui i tempi
  /// dell'attesa si leggono da `TempiDellAttesa`: due copie della stessa
  /// aritmetica divergono.
  TarotSpread stesaAVideo(WidgetTester tester) => tester
      .state<StesaTreCarteScreenState>(find.byType(StesaTreCarteScreen))
      .stesaCorrente;

  /// La cattura, gia' in byte: la conversione avviene DENTRO `runAsync`.
  ///
  /// Fuori di li' `toByteData` non si risolve mai, perche' l'orologio della
  /// prova e' finto e la conversione e' vera: la prima stesura di questa prova
  /// e' rimasta appesa dieci minuti prima di cadere per scadenza.
  Future<({ByteData dati, int larghezza, int altezza})> cattura(
      WidgetTester tester, GlobalKey radice) async {
    late ByteData dati;
    var larghezza = 0;
    var altezza = 0;
    await tester.runAsync(() async {
      final confine =
          radice.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final immagine = await confine.toImage();
      larghezza = immagine.width;
      altezza = immagine.height;
      dati = (await immagine.toByteData())!;
      immagine.dispose();
    });
    return (dati: dati, larghezza: larghezza, altezza: altezza);
  }

  /// Il colore medio di una fascia di pixel, dentro il rettangolo dato.
  ///
  /// Si campiona la FASCIA ALTA DEL RIENTRO, cioe' i pixel appena dentro il
  /// bordo superiore della bolla, dove non passa nessuna lettera: cosi' la
  /// misura confronta il trattamento della bolla e non quanta scrittura
  /// contiene.
  List<double> mediaDellaFascia(
    ({ByteData dati, int larghezza, int altezza}) scatto,
    Rect rettangolo, {
    int alta = 6,
  }) {
    var r = 0.0, g = 0.0, b = 0.0;
    var quanti = 0;
    for (var y = rettangolo.top.round() + 1;
        y < rettangolo.top.round() + 1 + alta;
        y++) {
      for (var x = rettangolo.left.round() + 1;
          x < rettangolo.right.round() - 1;
          x++) {
        if (x < 0 || y < 0 || x >= scatto.larghezza || y >= scatto.altezza) {
          continue;
        }
        final i = (y * scatto.larghezza + x) * 4;
        r += scatto.dati.getUint8(i);
        g += scatto.dati.getUint8(i + 1);
        b += scatto.dati.getUint8(i + 2);
        quanti++;
      }
    }
    if (quanti == 0) return const [0, 0, 0];
    return [r / quanti, g / quanti, b / quanti];
  }

  double scarto(List<double> a, List<double> b) {
    var somma = 0.0;
    for (var i = 0; i < 3; i++) {
      somma += (a[i] - b[i]).abs();
    }
    return somma / 3;
  }

  group('P.05 il taglio si capisce', () {
    test('le quattro fasi hanno una durata dichiarata in un punto solo', () {
      expect(TaglioFasi.fasi, hasLength(4),
          reason: 'il taglio racconta quattro momenti distinti, e ognuno deve '
              'esistere come durata dichiarata, non come numero sparso');
      for (final fase in TaglioFasi.fasi) {
        expect(fase.durata.inMilliseconds, greaterThan(0),
            reason: 'la fase ${fase.nome} non ha durata');
        expect(fase.racconto, isNotEmpty,
            reason: 'la fase ${fase.nome} non dice cosa racconta');
      }
      // Il totale non e' scritto: e' la somma delle quattro.
      expect(TaglioFasi.totale, StesaTiming.taglio,
          reason: 'il tempo del taglio nella regia non coincide con la somma '
              'delle quattro fasi: due numeri che devono restare d\'accordo '
              'prima o poi non lo restano');
    });

    test('il totale sta sotto la soglia oltre cui l\'animazione e\' attesa',
        () {
      expect(TaglioFasi.totale, lessThanOrEqualTo(TaglioFasi.soglia),
          reason: 'il taglio dura ${TaglioFasi.totale.inMilliseconds}ms contro '
              'una soglia di ${TaglioFasi.soglia.inMilliseconds}ms: si '
              'accorciano le fasi, non se ne salta una');
    });

    test('i confini della posa vengono dalle quattro durate', () {
      expect(TaglioPose.fineRaccolta, closeTo(TaglioFasi.confineDopo(0), 1e-9));
      expect(
          TaglioPose.fineDivisione, closeTo(TaglioFasi.confineDopo(1), 1e-9));
      expect(TaglioPose.fineRicomposizione,
          closeTo(TaglioFasi.confineDopo(2), 1e-9));
    });

    test('la meta\' di sotto va SOPRA quando le due meta\' si ricompongono',
        () {
      const count = 78;
      const taglioA = 40;
      // Dentro la fase tre, quella della ricomposizione.
      final t = (TaglioFasi.confineDopo(1) + TaglioFasi.confineDopo(2)) / 2;
      final sotto = TaglioPose.quotaDi(index: 3, taglioA: taglioA, t: t);
      final sopra =
          TaglioPose.quotaDi(index: count - 3, taglioA: taglioA, t: t);
      expect(sotto, greaterThan(sopra),
          reason: 'nella ricomposizione la meta\' di sotto deve passare sopra: '
              'senza questo il taglio si vede ma non si capisce che ha '
              'cambiato l\'ordine');
      // A riposo nessuna meta' e' privilegiata: la quota vale solo nel gesto.
      expect(TaglioPose.quotaDi(index: 3, taglioA: taglioA, t: 0),
          TaglioPose.quotaDi(index: count - 3, taglioA: taglioA, t: 0));
    });

    testWidgets('le carte gia\' estratte non si muovono di un punto',
        (tester) async {
      await monta(tester, revealAll: false, altezza: 1400);
      // Si pesca una carta sola, poi si taglia: la carta uscita deve restare
      // immobile per tutta l'animazione.
      await pesca(tester, 38);

      final carta = find.byKey(const Key('stesa_carta_passato'));
      expect(carta, findsOneWidget,
          reason: 'la carta del Passato non e\' a schermo');
      final partenza = tester.getRect(carta);

      await tester.tap(find.byKey(const Key('stesa_taglia')));
      final scostamenti = <String>[];
      for (var i = 0; i < 16; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (!tester.any(carta)) continue;
        final adesso = tester.getRect(carta);
        if (adesso != partenza) {
          scostamenti.add('al battito $i: $adesso invece di $partenza');
        }
      }
      expect(scostamenti, isEmpty,
          reason: 'la carta gia\' estratta si e\' mossa durante il taglio, ed '
              'e\' il modo visivo con cui la stesa dice che quella carta e\' '
              'ormai TUA:\n${scostamenti.join("\n")}');
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('le due meta\' si dividono DAVANTI A CHI GUARDA',
        (tester) async {
      // **QUESTA PROVA NASCE DA UN'ANTEPRIMA, non da un ragionamento.** Le
      // altre prove della voce 05 interrogavano `TaglioPose` con indici scelti
      // a mano, e da quel lato tornava tutto. Guardando le quattro immagini del
      // taglio, la seconda e la terza erano indistinguibili: un solo mazzetto
      // che si spostava e rientrava, nessuna divisione.
      //
      // La ragione era un'unita' di misura. Il punto di taglio viveva fra 2 e 7
      // perche' era contato sulle carte da pescare, mentre il ventaglio lo
      // confronta con gli indici delle settantotto: cadeva sempre fuori dalla
      // finestra montata, quindi tutte le carte a schermo stavano dalla stessa
      // parte del taglio.
      await monta(tester, revealAll: false, altezza: 1400);
      final stato = tester
          .state<StesaTreCarteScreenState>(find.byType(StesaTreCarteScreen));
      await tester.tap(find.byKey(const Key('stesa_taglia')));
      await tester.pump();
      // Al centro della divisione, dove la fase e' al suo pieno.
      await tester.pump(StesaTiming.taglio * TaglioFasi.centroDi(1));
      expect(stato.faseDelTaglioInScena, 1,
          reason: 'la scena non e\' nella divisione: si sta misurando '
              'un\'altra fase');

      final montate = tester
          .widgetList<Widget>(find.byWidgetPredicate((w) {
            final k = w.key;
            return k is ValueKey<String> &&
                k.value.startsWith('stesa_fan_') &&
                int.tryParse(k.value.substring('stesa_fan_'.length)) != null;
          }))
          .map((w) => int.parse((w.key as ValueKey<String>)
              .value
              .substring('stesa_fan_'.length)))
          .toList()
        ..sort();
      expect(montate, isNotEmpty,
          reason: 'nessuna carta del ventaglio e\' montata: non c\'e\' '
              'niente da dividere');
      final punto = stato.puntoDelTaglio;
      // **IL PUNTO E' UN INDICE DI CARTA, e si misura che lo sia.** Un numero
      // fra 2 e 7 non puo' essere il punto in cui si taglia un mazzo di
      // settantotto: e' un numero contato su un'altra cosa. Il taglio vero si fa
      // verso la meta', quindi il punto deve stare nel terzo centrale.
      final meta = TarotDeck.cards.length / 2;
      final distanza = (punto - meta).abs();
      expect(distanza, lessThan(TarotDeck.cards.length / 6),
          reason: 'il punto di taglio $punto sta a '
              '${distanza.toStringAsFixed(0)} carte dalla meta\' del mazzo '
              '(${meta.toStringAsFixed(0)}): un numero cosi\' lontano non e\' '
              'un indice di carta, e\' un numero contato su un\'altra unita\'');
      final sotto = montate.where((i) => i < punto).length;
      final sopra = montate.where((i) => i >= punto).length;
      expect(sotto, greaterThan(0),
          reason: 'nessuna delle ${montate.length} carte montate sta sotto il '
              'punto di taglio $punto (indici da ${montate.first} a '
              '${montate.last}): a schermo la divisione e\' un blocco unico '
              'che si sposta, e il gesto non si capisce');
      expect(sopra, greaterThan(0),
          reason: 'nessuna delle ${montate.length} carte montate sta sopra il '
              'punto di taglio $punto: vedi sopra');

      // E si vede anche NELLA GEOMETRIA: fra le due meta' si apre un vuoto piu'
      // largo del passo con cui i dorsi si sovrappongono a riposo.
      final centri = <double>[
        for (final i in montate)
          tester.getCenter(find.byKey(Key('stesa_fan_$i'))).dx,
      ]..sort();
      var vuotoMassimo = 0.0;
      var passoTipico = 0.0;
      for (var i = 1; i < centri.length; i++) {
        final passo = centri[i] - centri[i - 1];
        if (passo > vuotoMassimo) vuotoMassimo = passo;
        passoTipico += passo;
      }
      passoTipico /= (centri.length - 1);
      expect(vuotoMassimo, greaterThan(passoTipico * 2),
          reason: 'il vuoto piu\' largo fra due dorsi vale '
              '${vuotoMassimo.toStringAsFixed(1)} punti contro un passo medio '
              'di ${passoTipico.toStringAsFixed(1)}: le due meta\' non si '
              'staccano abbastanza per leggersi come due');
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('con Riduci Movimento le quattro fasi diventano quattro stati',
        (tester) async {
      await monta(tester,
          revealAll: false, riduciMovimento: true, altezza: 1400);
      final stato =
          tester.state<StesaTreCarteScreenState>(find.byType(StesaTreCarteScreen));
      await tester.tap(find.byKey(const Key('stesa_taglia')));
      await tester.pump();
      final viste = <int>{};
      for (var i = 0; i < 40; i++) {
        final fase = stato.faseDelTaglioInScena;
        if (fase != null) viste.add(fase);
        await tester.pump(const Duration(milliseconds: 60));
      }
      expect(viste, hasLength(4),
          reason: 'con Riduci Movimento il taglio ha mostrato ${viste.length} '
              'fasi su quattro: Riduci Movimento toglie il moto, non il '
              'contenuto');
      await tester.pump(const Duration(seconds: 6));
    });
  });

  group('P.06 Medora ci pensa', () {
    test('le righe dell\'attesa sono almeno tre e sono di Medora', () {
      expect(AttesaDiMedora.righe.length, greaterThanOrEqualTo(3),
          reason: 'con meno di tre righe l\'attesa si ripete subito');
      for (final riga in AttesaDiMedora.righe) {
        expect(riga, isNot(contains('—')),
            reason: 'trattino lungo nella riga: $riga');
        expect(riga.length, greaterThan(18),
            reason: 'riga troppo corta per essere una frase: $riga');
      }
      // Nessuna riga generica: ognuna nomina la stesa, le carte o lo sguardo
      // di Medora. Una riga che potrebbe stare su qualunque caricamento non e'
      // nella voce di nessuno.
      final generiche = AttesaDiMedora.righe
          .where((r) =>
              !r.toLowerCase().contains('cart') &&
              !r.toLowerCase().contains('stesa') &&
              !r.toLowerCase().contains('tre'))
          .toList();
      expect(generiche, isEmpty,
          reason: 'queste righe valgono per qualunque attesa: $generiche');
    });

    test('il minimo garantito viene da TempiDellAttesa, non riscritto', () {
      expect(AttesaDiMedora.durataMinima, TempiDellAttesa.durataMinima);
      expect(AttesaDiMedora.durataMinimaRidotta,
          TempiDellAttesa.durataMinimaRidotta);
      expect(AttesaDiMedora.durataRiga, TempiDellAttesa.durataBattuta);
    });

    testWidgets('fra l\'ultima carta e il responso c\'e\' la scena di Medora',
        (tester) async {
      await monta(tester, revealAll: false, altezza: 1400);
      for (final indice in const [38, 39, 40]) {
        await pesca(tester, indice);
      }
      // Terza carta scelta: la scena dell'attesa e' in sovrimpressione e il
      // responso non c'e' ancora.
      expect(find.byKey(const Key('stesa_attesa')), findsOneWidget,
          reason: 'il responso e\' apparso di colpo: un responso istantaneo e\' '
              'un responso letto da un archivio');
      expect(find.byKey(const Key('stesa_consiglio')), findsNothing,
          reason: 'il consiglio si vede mentre Medora sta ancora guardando');
      // Passato il minimo garantito la scena lascia il posto al responso.
      await tester.pump(TempiDellAttesa.durataMinima);
      await tester.pump(TempiDellAttesa.dissolvenza);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byKey(const Key('stesa_attesa')), findsNothing,
          reason: 'la scena dell\'attesa non se ne va piu\'');
      expect(find.byKey(const Key('stesa_consiglio')), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
    });
  });

  group('P.07 la bolla chiave e\' la bolla della carta', () {
    test('la soglia dello scarto e\' dichiarata nel codice, non nella prova',
        () {
      expect(BollaDellaPosizione.scartoMinimoAPixel, greaterThan(0));
    });

    testWidgets('la bolla chiave si distingue a pixel oltre la soglia',
        (tester) async {
      final radice = await monta(tester);
      final chiave = TarotReading.chiaveDi(stesaAVideo(tester)).drawn.position;

      final scatto = await cattura(tester, radice);
      final medie = <String, List<double>>{};
      for (final posizione in SpreadPosition.values) {
        final bolla = find.byKey(Key('stesa_letta_${posizione.name}'));
        expect(bolla, findsOneWidget);
        medie[posizione.name] =
            mediaDellaFascia(scatto, tester.getRect(bolla));
      }
      final dellaChiave = medie[chiave.name]!;
      final altre = SpreadPosition.values
          .where((p) => p != chiave)
          .map((p) => medie[p.name]!)
          .toList();
      // Le due bolle normali fra loro si somigliano: e' il fondo di
      // riferimento della misura.
      final fraLeNormali = scarto(altre[0], altre[1]);
      for (final altra in altre) {
        final differenza = scarto(dellaChiave, altra);
        expect(differenza,
            greaterThanOrEqualTo(BollaDellaPosizione.scartoMinimoAPixel),
            reason: 'la bolla chiave si scosta di soli '
                '${differenza.toStringAsFixed(1)} livelli dalla bolla normale, '
                'contro i ${BollaDellaPosizione.scartoMinimoAPixel} dichiarati. '
                'Fra le due bolle normali lo scarto vale '
                '${fraLeNormali.toStringAsFixed(1)}: una evidenziazione che si '
                'vede solo a chi sa che c\'e\' non e\' una evidenziazione');
      }
    });

    testWidgets('la marcatura dice perche\' e\' quella, e sta nella bolla',
        (tester) async {
      await monta(tester);
      final chiave = TarotReading.chiaveDi(stesaAVideo(tester));
      final marcatura =
          find.byKey(Key('stesa_marcatura_${chiave.drawn.position.name}'));
      expect(marcatura, findsOneWidget,
          reason: 'la bolla chiave non porta nessuna marcatura');
      // E le altre due non ce l'hanno.
      for (final posizione in SpreadPosition.values) {
        if (posizione == chiave.drawn.position) continue;
        expect(find.byKey(Key('stesa_marcatura_${posizione.name}')),
            findsNothing);
      }
    });
  });

  group('P.08 due bolle spariscono', () {
    testWidgets('la bolla della carta chiave e quella del dialogo non ci sono',
        (tester) async {
      await monta(tester);
      expect(find.byKey(const Key('stesa_chiave')), findsNothing,
          reason: 'la bolla LA CARTA CHIAVE e\' ancora montata');
      expect(find.byKey(const Key('stesa_dialogo')), findsNothing,
          reason: 'la bolla LE CARTE CHE DIALOGANO e\' ancora montata');
      expect(find.text('Le carte che dialogano'), findsNothing);
      expect(find.text('LE CARTE CHE DIALOGANO'), findsNothing);
      expect(find.text('LA CARTA CHIAVE'), findsNothing);
    });

    test('e non si generano piu\' nemmeno come testo', () {
      final sorgente =
          File('lib/core/tarot/tarot_reading.dart').readAsStringSync();
      for (final morto in const [
        'DialogoRule',
        'dialogoDi',
        'class Dialogo',
      ]) {
        expect(sorgente.contains(morto), isFalse,
            reason: 'eliminare vuol dire togliere anche la generazione e il '
                'suo costo: $morto vive ancora');
      }
    });
  });

  group('P.09 il consiglio e\' la prima cosa, ed e\' la piu\' lunga', () {
    test('il suo tetto e\' distinto e piu\' alto, e sta col blocco degli altri',
        () {
      for (final altro in TettiDellaStesa.tuttiTranneIlConsiglio) {
        expect(TettiDellaStesa.consiglio, greaterThan(altro),
            reason: 'il tetto del consiglio non e\' piu\' alto di $altro');
      }
    });

    test('il consiglio nomina almeno due delle tre carte uscite', () {
      // Su tutti i semi e tutti gli argomenti, non su uno scelto bene.
      for (var seed = 0; seed < 60; seed++) {
        final spread = TarotSpread.draw(seed: seed);
        for (final topic in TarotTopic.values) {
          final lettura = TarotReading.of(spread, topic);
          final nominate = spread.cards
              .where((c) => lettura.consiglio.contains(c.card.name))
              .length;
          expect(nominate, greaterThanOrEqualTo(2),
              reason: 'col seme $seed su ${topic.name} il consiglio nomina '
                  '$nominate carte: un testo che vale per qualunque stesa la '
                  'persona lo riconosce alla seconda lettura');
          expect(lettura.consiglio.length,
              lessThanOrEqualTo(TettiDellaStesa.consiglio),
              reason: 'il consiglio sfora il proprio tetto col seme $seed');
        }
      }
    });

    test('la domanda e\' l\'ultimo paragrafo del consiglio, dopo uno stacco',
        () {
      for (var seed = 0; seed < 40; seed++) {
        final spread = TarotSpread.draw(seed: seed);
        final lettura = TarotReading.of(spread, TarotTopic.bivio);
        expect(lettura.consiglio, contains('\n\n'),
            reason: 'senza riga di stacco la domanda e\' appiccicata al testo');
        final paragrafi = lettura.consiglio.split('\n\n');
        expect(paragrafi.last.trim(), lettura.domanda,
            reason: 'l\'ultimo paragrafo del consiglio non e\' la domanda');
      }
    });

    testWidgets('e a schermo sta sopra le tre bolle delle carte',
        (tester) async {
      await monta(tester);
      final consiglio = find.byKey(const Key('stesa_consiglio'));
      expect(consiglio, findsOneWidget);
      final suo = tester.getTopLeft(consiglio).dy;
      for (final posizione in SpreadPosition.values) {
        final bolla = find.byKey(Key('stesa_letta_${posizione.name}'));
        expect(suo, lessThan(tester.getTopLeft(bolla).dy),
            reason: 'il consiglio sta sotto la bolla di ${posizione.name}: e\' '
                'la bolla che la persona porta via, quindi si legge per prima');
      }
      // La bolla della domanda non esiste piu' come bolla propria.
      expect(find.byKey(const Key('stesa_domanda')), findsNothing);
      expect(find.text('LA DOMANDA CHE TI LASCIO'), findsNothing);
    });
  });

  group('P.10 il testo sotto la carta usa la larghezza che ha', () {
    testWidgets('nessuna riga scende sotto quattro parole se c\'e\' spazio',
        (tester) async {
      await monta(tester);
      final colpevoli = <String>[];
      for (final posizione in SpreadPosition.values) {
        for (final quale in const ['name', 'meaning']) {
          final chiave = Key('stesa_${quale}_${posizione.name}');
          final trovato = find.byKey(chiave);
          expect(trovato, findsOneWidget,
              reason: 'manca il testo $quale di ${posizione.name}');
          final widget = tester.widget<Text>(trovato);
          final testo = widget.data!;
          final larghezza = tester.getSize(trovato).width;
          final pittore = TextPainter(
            text: TextSpan(text: testo, style: widget.style),
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: larghezza);
          final righe = pittore.computeLineMetrics().length;
          // Quante righe servirebbero con tutta la larghezza disponibile.
          final pieno = TextPainter(
            text: TextSpan(text: testo, style: widget.style),
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: larghezzaReale - 32);
          final righeAlPieno = pieno.computeLineMetrics().length;
          final parole =
              testo.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).length;
          if (righe > righeAlPieno && parole / righe < 4) {
            colpevoli.add(
                '${posizione.name}/$quale: "$testo" va su $righe righe in '
                '${larghezza.toStringAsFixed(0)} punti, ne bastano '
                '$righeAlPieno con la larghezza disponibile, cioe'
                    ' ${(parole / righe).toStringAsFixed(1)} parole per riga');
          }
        }
      }
      expect(colpevoli, isEmpty,
          reason: 'questi testi vanno a capo per la larghezza della miniatura e '
              'non per la loro lunghezza:\n${colpevoli.join("\n")}');
    });

    testWidgets('ROVESCIATO e\' una marcatura leggibile, non maiuscoletto',
        (tester) async {
      // Il seme si cerca sulla LEGGE VERA del verso, `versoDi`, che e' quella
      // con cui la schermata assegna le carte. `TarotSpread.draw` ne usa
      // un'altra, e cercare li' darebbe un seme che a video non porta nessuna
      // carta rovesciata.
      var seed = 1;
      while (seed < 300 &&
          !List<int>.generate(3, (i) => TarotSpread.mazzoMescolato(seed: seed)[i])
              .any((carta) => TarotSpread.versoDi(carta, seed))) {
        seed++;
      }
      await monta(tester, seed: seed);
      final rovesciata =
          stesaAVideo(tester).cards.firstWhere((c) => c.reversed);
      final marca =
          find.byKey(Key('stesa_reversed_${rovesciata.position.name}'));
      expect(marca, findsOneWidget);
      final stile = tester.widget<Text>(marca).style!;
      // Didascalia, cioe' sedici, non l'etichetta al pavimento di dodici: e' la
      // riga che ribalta il significato della carta.
      expect(stile.fontSize, greaterThan(TypographyTokens.pavimento),
          reason: 'la marcatura del verso e\' ancora un maiuscoletto piccolo');
    });
  });
}
