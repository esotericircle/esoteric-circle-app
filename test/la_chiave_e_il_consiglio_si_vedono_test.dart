import 'dart:io';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/tarot/tarot_reading.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:esoteric_circle/design_system/typography/paragrafi_di_lettura.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// LA CHIAVE SI VEDE, E IL CONSIGLIO SI LEGGE. Ordine BN voci 05 e 06.
///
/// - **BN.05**: la carta che regge la lettura si distingue dalle altre due
///   ANCHE nella stesa, e non solo nella sua bolla. La distinzione si misura
///   sui PIXEL e mai sui rettangoli di layout, col metodo di AX.02: le carte
///   escono dal proprio riquadro, quindi un confronto di geometrie direbbe il
///   falso.
/// - **BN.06**: il titolo del consiglio sale di una misura piena della scala e
///   resta su una riga sola; il testo si presenta in due o tre paragrafi, e
///   nessun paragrafo comincia a meta' di una frase.
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

  Widget attorno(Widget scena) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
        ],
        child: MediaQuery(
          data: const MediaQueryData(),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: MaestroScope(child: scena),
          ),
        ),
      );

  /// Il riquadro dipinto DAVVERO, scala compresa: `getRect` legge il
  /// riquadro di layout, e un `Transform` non ci entra. Ordine BV voce 04.
  RenderObject radiceDipinta(WidgetTester tester) =>
      tester.renderObject(find.byType(MaterialApp).first);

  Future<GlobalKey> monta(WidgetTester tester,
      {int seed = 2,
      double altezzaFinestra = 4400,
      double larghezzaFinestra = 360}) async {
    silenzia();
    await caricaCaratteri();
    tester.view.physicalSize = Size(larghezzaFinestra, altezzaFinestra);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final radice = GlobalKey();
    await tester.pumpWidget(attorno(RepaintBoundary(
      key: radice,
      child: StesaTreCarteScreen(
        seed: seed,
        revealAll: true,
        skipIntro: true,
        topic: TarotTopic.bivio,
      ),
    )));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    return radice;
  }

  /// Quanto azzurro c'e' SOPRA la carta [posizione], misurato sui pixel.
  ///
  /// **Ordine BZ voce 08: e' li' che il segno vive adesso.** Fino alla voce
  /// BV.04 il segno era una cornice attorno alla carta, e si misurava la
  /// banda attorno al riquadro; il fondatore l'ha bocciata ("FA ANCORA
  /// SCHIFO") e al suo posto ci sono le parole "Carta Chiave" in cima alla
  /// colonna. La grandezza misurata cambia con lui: la striscia guardata e'
  /// quella fra il bordo alto della carta e i trentadue punti sopra di lei.
  Future<double> azzurroSopra(
      WidgetTester tester, GlobalKey radice, SpreadPosition posizione) async {
    final r = tester.getRect(find.byKey(Key('stesa_carta_${posizione.name}')));
    var quanti = 0;
    await tester.runAsync(() async {
      final b =
          radice.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final img = await b.toImage();
      final data = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
      final px = data!.buffer.asUint8List();
      final origine = tester.getRect(find.byKey(radice)).topLeft;
      for (var y = (r.top - 32).round(); y < r.top.round(); y++) {
        for (var x = r.left.round(); x < r.right.round(); x++) {
          final px0 = (x - origine.dx).round();
          final py0 = (y - origine.dy).round();
          if (px0 < 0 || py0 < 0 || px0 >= img.width || py0 >= img.height) {
            continue;
          }
          final i = (py0 * img.width + px0) * 4;
          if (i + 2 >= px.length) continue;
          // Lo stesso predicato della cornice: un azzurro CHIARO, che il
          // fondo blu scuro dell'app non passa.
          if (px[i + 2] > 150 && px[i + 2] - px[i] > 60) quanti++;
        }
      }
    });
    return quanti.toDouble();
  }

  testWidgets('la carta chiave si distingue dalle altre due, sui pixel',
      (tester) async {
    // Tre semi diversi, cosi' la chiave cade su posizioni diverse e la prova
    // non misura una sola configurazione fortunata.
    for (final seed in const [2, 5, 9]) {
      final radice = await monta(tester, seed: seed);
      final lettura = TarotReading.of(
        TarotSpread.dalMazzo(TarotSpread.mazzoMescolato(seed: seed)),
        TarotTopic.bivio,
      );
      final chiave = lettura.chiave.drawn.position;

      final misure = <SpreadPosition, double>{};
      for (final p in SpreadPosition.values) {
        misure[p] = await azzurroSopra(tester, radice, p);
      }
      final altre = [
        for (final p in SpreadPosition.values)
          if (p != chiave) misure[p]!,
      ];
      // ignore: avoid_print
      print('ORDINE BZ VOCE 8 (misura BN.05) seme $seed, chiave '
          '${chiave.name}: azzurro SOPRA la chiave '
          '${misure[chiave]!.toStringAsFixed(0)}, sopra le altre '
          '${altre.map((v) => v.toStringAsFixed(0)).join(" e ")}');
      expect(misure[chiave]!, greaterThan(80),
          reason: 'seme $seed: sopra la carta chiave non c\'e\' abbastanza '
              'azzurro perche\' ci sia scritto qualcosa');
      for (final v in altre) {
        expect(misure[chiave]!, greaterThan(v * 1.5),
            reason: 'seme $seed: la carta chiave (${chiave.name}) non si '
                'distingue dalle altre due nella stesa: chi guarda le tre '
                'carte non sa quale regge la lettura');
      }
    }
  });

  testWidgets('il titolo del consiglio e\' cresciuto e sta su una riga',
      (tester) async {
    await monta(tester);
    final titolo = find.byKey(const Key('stesa_consiglio_titolo'));
    expect(titolo, findsOneWidget);
    final w = tester.widget<Text>(titolo);
    // La misura non e' battuta qui: viene dalla scala del design system.
    expect(w.style!.fontSize, TypographyTokens.titoloScheda().fontSize,
        reason: 'il titolo non e\' salito al gradino pieno della scala');
    expect(w.style!.fontSize, greaterThan(TypographyTokens.pavimento),
        reason: 'il titolo e\' ancora al pavimento della scala');
    final tp = TextPainter(
      text: TextSpan(text: w.data, style: w.style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout(maxWidth: 360 - 32);
    expect(tp.didExceedMaxLines, isFalse,
        reason: 'il titolo cresciuto non sta piu\' su una riga a 360 punti');
  });

  test('il consiglio ha due o tre paragrafi, e nessuno comincia a meta\'', () {
    for (final seed in const [2, 5, 9, 13, 21]) {
      for (final topic in TarotTopic.values) {
        final lettura = TarotReading.of(
          TarotSpread.dalMazzo(TarotSpread.mazzoMescolato(seed: seed)),
          topic,
        );
        // La domanda finale sta gia' staccata da sempre: si guarda il corpo.
        final corpo = lettura.consiglio.split('\n\n');
        expect(corpo.length, greaterThanOrEqualTo(3),
            reason: 'seme $seed, ${topic.name}: il consiglio non e\' diviso '
                'in paragrafi');
        // L'ultimo pezzo e' la domanda: i paragrafi del consiglio sono gli
        // altri, e devono essere due o tre.
        final paragrafi = corpo.sublist(0, corpo.length - 1);
        expect(paragrafi.length, inInclusiveRange(2, 3),
            reason: 'seme $seed, ${topic.name}: i paragrafi sono '
                '${paragrafi.length}, e l\'ordine ne chiede due o tre');
        for (final p in paragrafi) {
          final primo = p.trimLeft();
          expect(primo.isNotEmpty, isTrue);
          // NESSUN PARAGRAFO COMINCIA A META' DI UNA FRASE: la prima lettera
          // e' maiuscola, o e' un nome proprio, e mai una minuscola figlia di
          // un taglio.
          expect(primo[0], primo[0].toUpperCase(),
              reason: 'seme $seed, ${topic.name}: un paragrafo comincia con '
                  '"${primo.substring(0, primo.length.clamp(0, 40))}", cioe\' '
                  'a meta\' di una frase');
        }
      }
    }
  });

  // --- ORDINE BU, LA STESA SI LEGGE -----------------------------------------

  testWidgets(
      'BU.01: il velo della carta ingrandita e\' opaco, e sotto non '
      'passa niente', (tester) async {
    // **LA MISURA E' SUI PIXEL, non sul numero scritto nel codice.** Il numero
    // si legge lo stesso, perche' una prova che guarda solo i pixel non dice
    // dove intervenire; ma cio' che conta e' che dentro il riquadro del testo
    // non passi un solo pixel di cio' che sta sotto.
    await monta(tester);

    await tester.tap(find.byKey(const Key('stesa_apri_presente')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    final testo = find.byKey(const Key('carta_ingrandita_testo'));
    expect(testo, findsOneWidget,
        reason: 'la carta ingrandita non si e\' aperta');
    // **LA GRANDEZZA MISURATA E' CAMBIATA DUE VOLTE, e le ragioni stanno
    // qui.** La prima stesura contava l'oro del contenuto dentro il riquadro
    // del testo: col velo rimesso a 0,72 quel numero restava zero, perche'
    // dietro quel riquadro, in questa scena, non capita nessun titolo oro. La
    // seconda contava i pixel non neri in una fascia fuori dalla carta: ma la
    // carta ingrandita dipinge una sua fioritura su tutto lo schermo, quindi
    // quella fascia non e' mai velo puro e il numero non cambiava col velo.
    // **Un rosso che non scatta non si aggiusta abbassando la soglia: si
    // cambia cio' che si misura.** Cio' che decide davvero se sotto passa
    // qualcosa e' l'opacita' della barriera, e qui si legge DALLA ROTTA VIVA,
    // non dal testo del sorgente: e' il numero che Flutter sta usando.
    final barriere = find.byType(ModalBarrier).evaluate();
    final opacita = [
      for (final e in barriere)
        if ((e.widget as ModalBarrier).color != null)
          (e.widget as ModalBarrier).color!.a,
    ];
    // ignore: avoid_print
    print('ORDINE BU VOCE 1: opacita del velo della carta ingrandita '
        '$opacita');
    expect(opacita, isNotEmpty,
        reason: 'la carta ingrandita non ha nessun velo: sotto si legge '
            'tutto');
    expect(opacita.every((o) => o == 1.0), isTrue,
        reason: 'il velo ha opacita\' $opacita invece di 1: a 0,72 passa il '
            'ventotto per cento di cio\' che sta sotto, ed e\' il contenuto '
            'che il fondatore ha visto dietro le righe del testo');
    // E la riga che dice DOVE intervenire, dopo il numero che dice quanto.
    final sorgente =
        File('lib/features/tarot/carta_ingrandita.dart').readAsStringSync();
    expect(sorgente.contains('barrierColor: Colors.black,'), isTrue,
        reason: 'il velo della carta ingrandita non e\' piu\' opaco pieno: '
            'sotto tornano a leggersi i titoli della lista');
  });

  testWidgets('BU.01: nessun testo di contenuto sta sotto la misura di lettura',
      (tester) async {
    await monta(tester);
    // I testi di CONTENUTO della schermata, enumerati uno per uno con la loro
    // chiave: le etichette di servizio e i conti non stanno qui, perche' non
    // sono cose da leggere ma cose da vedere.
    const diContenuto = [
      'stesa_closing',
      'stesa_meaning_passato',
      'stesa_meaning_presente',
      'stesa_meaning_futuro',
    ];
    final misure = <String, double>{};
    for (final chiave in diContenuto) {
      final f = find.byKey(Key(chiave));
      if (f.evaluate().isEmpty) continue;
      // I testi di contenuto passano da ParagrafiDiLettura, che e' la porta
      // unica del testo narrato: la misura si legge dal suo stile.
      final w = tester.widget<ParagrafiDiLettura>(f);
      misure[chiave] = w.stile.fontSize!;
    }
    // E i testi delle tre bolle, che non hanno una chiave loro.
    final bolle = find.descendant(
        of: find.byType(BollaDellaPosizione), matching: find.byType(Text));
    for (final e in bolle.evaluate()) {
      final w = e.widget as Text;
      final testo = w.data ?? '';
      // Le etichette di posizione sono maiuscole e brevi: sono servizio.
      if (testo.length < 25) continue;
      misure['bolla: ${testo.substring(0, 18)}...'] = w.style!.fontSize!;
    }
    final lettura = TypographyTokens.lettura().fontSize!;
    // ignore: avoid_print
    print('ORDINE BU VOCE 1: misura di lettura $lettura, testi di contenuto '
        '${misure.length}, il piu\' piccolo '
        '${misure.values.reduce((a, b) => a < b ? a : b)}');
    expect(misure, isNotEmpty,
        reason: 'nessun testo di contenuto trovato: la prova gira a vuoto');
    misure.forEach((dove, misura) {
      expect(misura, greaterThanOrEqualTo(lettura),
          reason: '$dove e\' scritto a $misura, sotto la misura di lettura '
              'di $lettura: e\' il font piccolo che il fondatore ha visto');
    });
  });

  testWidgets('BU.01: il consiglio ha paragrafi separati e non e\' oro',
      (tester) async {
    await monta(tester);
    final bolla = find.byKey(const Key('stesa_consiglio'));
    expect(bolla, findsOneWidget);
    final paragrafi =
        find.descendant(of: bolla, matching: find.byType(ParagrafiDiLettura));
    expect(paragrafi, findsOneWidget,
        reason: 'il consiglio e\' tornato un blocco solo: i paragrafi si '
            'fondono e il testo diventa un muro');
    final w = tester.widget<ParagrafiDiLettura>(paragrafi);
    expect(w.stile.fontSize, TypographyTokens.lettura().fontSize,
        reason: 'il consiglio non e\' alla misura di lettura');
    expect(w.stile.color, isNot(MaestroPalette.medora.goldSoft),
        reason: 'il consiglio e\' ancora tutto oro: un accento su ogni riga '
            'non accenta niente');
    final quanti = w.testo.split(RegExp(r'\n\s*\n')).length;
    // ignore: avoid_print
    print('ORDINE BU VOCE 1: il consiglio ha $quanti paragrafi, misura '
        '${w.stile.fontSize}, colore ${w.stile.color}');
    expect(quanti, greaterThanOrEqualTo(2),
        reason: 'il testo del consiglio non porta piu\' paragrafi: qui non '
            'si misura la resa ma il dato che le sta sotto');
  });

  testWidgets('BU.01: le due etichette sono quelle nuove', (tester) async {
    await monta(tester);
    expect(find.text('LE CARTE, UNA ALLA VOLTA'), findsOneWidget,
        reason: 'l\'intestazione della lista non e\' quella chiesta');
    final lente = tester.widget<Text>(find.byKey(const Key('stesa_lente')));
    expect(lente.style!.fontSize,
        greaterThan(TypographyTokens.etichetta().fontSize!),
        reason: 'l\'intestazione doveva essere scritta IN GRANDE');
    final selettori =
        File('lib/features/tarot/tarot_selectors.dart').readAsStringSync();
    expect(selettori.contains("titolo: 'Scegli la tua domanda'"), isTrue,
        reason: 'il selettore chiede ancora l\'argomento invece della domanda');
  });

  testWidgets('BZ.08: sopra la carta chiave non si disegna piu\' niente',
      (tester) async {
    // **LA TERZA STESURA DELLO STESSO SEGNO, e la prima senza colore.**
    // BN.05 ci aveva messo un alone d'oro, BU.02 la sola linea azzurra, BV.04
    // la linea piu' spessa con la carta cresciuta. Parole del fondatore
    // dell'ordine BZ: "la Carta chiave evidenziata da cornice azzurra FA
    // ANCORA SCHIFO". Adesso sopra la carta non c'e' niente: il segno sono le
    // parole in cima alla colonna e la misura.
    await monta(tester);
    final lettura = TarotReading.of(
      TarotSpread.dalMazzo(TarotSpread.mazzoMescolato(seed: 2)),
      TarotTopic.bivio,
    );
    final chiave = lettura.chiave.drawn.position;
    for (final p in SpreadPosition.values) {
      expect(find.byKey(Key('stesa_chiave_${p.name}')), findsNothing,
          reason: 'la cornice azzurra e\' tornata sopra la carta ${p.name}');
    }
    // E le parole ci sono, su UNA carta sola.
    expect(
        find.byKey(Key('stesa_parole_chiave_${chiave.name}')), findsOneWidget,
        reason: 'sopra la carta chiave non c\'e\' scritto niente');
    expect(find.text('Carta Chiave'), findsOneWidget,
        reason:
            'le parole "Carta Chiave" compaiono ${find.text('Carta Chiave').evaluate().length} volte invece di una');
  });

  testWidgets('BU.02: la bolla chiave ha lo stesso fondo delle altre',
      (tester) async {
    await monta(tester);
    final bolle = find.byType(BollaDellaPosizione);
    expect(bolle, findsNWidgets(3));
    final fondi = <Color?>[];
    final ombre = <int>[];
    for (final e in bolle.evaluate()) {
      final container = find
          .descendant(
              of: find.byWidget(e.widget), matching: find.byType(Container))
          .evaluate()
          .first
          .widget as Container;
      final d = container.decoration as BoxDecoration;
      fondi.add(d.color);
      ombre.add(d.boxShadow?.length ?? 0);
    }
    // ignore: avoid_print
    print('ORDINE BU VOCE 2: i fondi delle tre bolle $fondi, le ombre $ombre');
    expect(fondi.toSet(), hasLength(1),
        reason: 'la bolla chiave ha ancora un fondo suo: il fondatore ha '
            'chiesto la cornice e niente altro');
    expect(ombre.every((n) => n == 0), isTrue,
        reason: 'una bolla porta ancora un alone');
  });

  /// Quanti pixel SCURI ci sono dentro un rettangolo.
  ///
  /// **E' la grandezza che distingue una cornice da una copertura, e ci sono
  /// volute tre stesure.** Contare l'azzurro dentro la carta non funziona: le
  /// carte dei tarocchi il blu ce l'hanno dentro, e un fondo blu traslucido
  /// steso sopra si confonde col loro. Cio' che una copertura fa sempre,
  /// qualunque colore abbia, e' SCHIARIRE le ombre della figura: un velo al
  /// 62 per cento somma il suo colore anche al nero. Quindi si contano i
  /// pixel scuri: se la carta chiave ne ha molti meno delle altre due,
  /// qualcosa le e' stato steso sopra.
  Future<int> scuriDentro(
      WidgetTester tester, GlobalKey radice, Rect dentro) async {
    var coperti = 0;
    await tester.runAsync(() async {
      final b =
          radice.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final img = await b.toImage();
      final data = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
      final px = data!.buffer.asUint8List();
      final origine = tester.getRect(find.byKey(radice)).topLeft;
      for (var y = dentro.top.round(); y < dentro.bottom.round(); y++) {
        for (var x = dentro.left.round(); x < dentro.right.round(); x++) {
          final px0 = (x - origine.dx).round();
          final py0 = (y - origine.dy).round();
          if (px0 < 0 || py0 < 0 || px0 >= img.width || py0 >= img.height) {
            continue;
          }
          final i = (py0 * img.width + px0) * 4;
          if (i + 2 >= px.length) continue;
          if (px[i] + px[i + 1] + px[i + 2] < 120) coperti++;
        }
      }
    });
    return coperti;
  }

  testWidgets('BU.02: dentro la carta chiave non passa un pixel di copertura',
      (tester) async {
    // **LA MISURA SUI PIXEL, dentro il rettangolo della carta.** La prova
    // strutturale qui sopra dice che il segno non ha fondo ne' ombra; questa
    // guarda cio' che si vede: dentro la carta, tolta la cornice di tre punti,
    // non deve esserci un solo pixel dell'azzurro che la cornice porta. Con un
    // fondo azzurro steso sopra, anche traslucido, la figura ne prende dovunque.
    final radice = await monta(tester);
    final lettura = TarotReading.of(
      TarotSpread.dalMazzo(TarotSpread.mazzoMescolato(seed: 2)),
      TarotTopic.bivio,
    );
    final chiave = lettura.chiave.drawn.position;
    // **LA MISURA E' DIFFERENZIALE, e la prima stesura non lo era.** Contare
    // l'azzurro dentro la carta chiave da' ottanta pixel anche quando sopra
    // non c'e' niente: le carte dei tarocchi il blu ce l'hanno dentro. Il
    // numero da solo non dice niente; cio' che dice qualcosa e' il confronto
    // con le altre due carte, che nessuno copre. Una copertura stesa sopra la
    // figura fa saltare quel rapporto di colpo, una cornice no.
    final conti = <SpreadPosition, int>{};
    for (final posizione in SpreadPosition.values) {
      final r =
          tester.getRect(find.byKey(Key('stesa_carta_${posizione.name}')));
      // Otto punti di rientro, non tre: la cornice e' larga due, ma ha gli
      // angoli arrotondati e il bordo sfuma, e tre punti ne lasciavano dentro
      // ancora un pezzo. Otto e' lontano dal bordo e vicinissimo alla figura.
      final dentro =
          Rect.fromLTRB(r.left + 8, r.top + 8, r.right - 8, r.bottom - 8);
      conti[posizione] = await scuriDentro(tester, radice, dentro);
    }
    final coperti = conti[chiave]!;
    final altre = [
      for (final p in SpreadPosition.values)
        if (p != chiave) conti[p]!,
    ];
    final piuBassa = altre.reduce((x, y) => x < y ? x : y);
    // ignore: avoid_print
    print('ORDINE BU VOCE 2: pixel scuri DENTRO la carta chiave $coperti, '
        'dentro le altre due ${altre.join(" e ")}');
    expect(coperti, greaterThanOrEqualTo((piuBassa * 0.5).round()),
        reason: 'dentro la carta chiave ci sono $coperti pixel scuri contro '
            'i $piuBassa della meno scura fra le altre due: le ombre della '
            'figura sono state schiarite, cioe\' qualcosa le e\' stato steso '
            'sopra, ed e\' cio\' che il fondatore non vuole');
  });

  testWidgets('BV.04: la carta chiave e\' piu\' grande, e la cornice si stacca',
      (tester) async {
    // **LA FORMA E' UNA SCELTA, e questa prova la misura invece di crederci.**
    // Il fondatore ha detto che la linea azzurra a filo si vede poco e non
    // mette in evidenza la chiave, e ha lasciato la forma a me: la chiave e'
    // piu' GRANDE delle altre due, che si legge da un metro e non aggiunge
    // niente sopra la figura, e la cornice si stacca dal bordo invece di
    // seguirlo.
    await monta(tester);
    final lettura = TarotReading.of(
      TarotSpread.dalMazzo(TarotSpread.mazzoMescolato(seed: 2)),
      TarotTopic.bivio,
    );
    final chiave = lettura.chiave.drawn.position;
    // La misura vera e' quella DIPINTA, non quella del riquadro di layout: la
    // scala e' un Transform, e il riquadro non la vede.
    final dipinta = <SpreadPosition, Rect>{};
    for (final p in SpreadPosition.values) {
      final ro = tester
          .element(find.byKey(Key('stesa_carta_${p.name}')))
          .renderObject! as RenderBox;
      final m = ro.getTransformTo(radiceDipinta(tester));
      dipinta[p] = MatrixUtils.transformRect(m, Offset.zero & ro.size);
    }
    final altaChiave = dipinta[chiave]!.height;
    final altre = [
      for (final p in SpreadPosition.values)
        if (p != chiave) dipinta[p]!.height,
    ];
    final piuAlta = altre.reduce((x, y) => x > y ? x : y);
    final scarto = (altaChiave - piuAlta) / piuAlta;
    // ignore: avoid_print
    print('ORDINE BV VOCE 4: la carta chiave e\' alta '
        '${altaChiave.toStringAsFixed(1)} punti contro '
        '${altre.map((v) => v.toStringAsFixed(1)).join(" e ")}, cioe\' il '
        '${(scarto * 100).toStringAsFixed(1)} per cento in piu\'');
    // **LA SOGLIA SALE CON L'ORDINE BZ VOCE 8.** Con la sola chiave cresciuta
    // lo scarto era il dieci per cento; adesso le vicine scendono a
    // ottantasei centesimi e lo scarto dipinto passa il venti. Non si abbassa
    // mai una soglia: questa si ALZA, perche' la grandezza misurata e'
    // cambiata sotto.
    expect(scarto, greaterThanOrEqualTo(0.20),
        reason: 'la carta chiave supera le altre di appena il '
            '${(scarto * 100).toStringAsFixed(1)} per cento: a colpo d\'occhio '
            'non si distingue, ed e\' cio\' che il fondatore ha detto della '
            'linea a filo');

    // **LE PAROLE STANNO SOPRA LA CARTA CHIAVE, ordine BZ voce 08**, e sopra
    // vuol dire piu' in alto del suo bordo: se finissero accanto, o sotto,
    // sarebbero un'altra etichetta e non il nome di quella carta. Si misura
    // dipinto, non di layout, perche' la carta e' scalata da un Transform.
    final paroleRo = tester
        .element(find.byKey(Key('stesa_parole_chiave_${chiave.name}')))
        .renderObject! as RenderBox;
    final parole = MatrixUtils.transformRect(
        paroleRo.getTransformTo(radiceDipinta(tester)),
        Offset.zero & paroleRo.size);
    // ignore: avoid_print
    print('ORDINE BZ VOCE 8: le parole stanno da '
        '${parole.top.toStringAsFixed(1)} a '
        '${parole.bottom.toStringAsFixed(1)}, la carta chiave comincia a '
        '${dipinta[chiave]!.top.toStringAsFixed(1)}');
    expect(parole.bottom, lessThanOrEqualTo(dipinta[chiave]!.top + 1),
        reason: 'le parole "Carta Chiave" non stanno sopra la carta: '
            'finiscono a ${parole.bottom.toStringAsFixed(1)} mentre la carta '
            'comincia a ${dipinta[chiave]!.top.toStringAsFixed(1)}');
    expect(parole.center.dx,
        closeTo(dipinta[chiave]!.center.dx, dipinta[chiave]!.width / 2),
        reason: 'le parole non stanno sopra la colonna della carta chiave');

    // **E LA CARTA CRESCIUTA NON DEVE TOCCARE LE VICINE.** Un difetto nuovo
    // al posto di quello vecchio non sarebbe una cura.
    final segnoDipinto = dipinta[chiave]!;
    for (final p in SpreadPosition.values) {
      if (p == chiave) continue;
      final aria = segnoDipinto.left > dipinta[p]!.left
          ? segnoDipinto.left - dipinta[p]!.right
          : dipinta[p]!.left - segnoDipinto.right;
      final sovrapposto = segnoDipinto.overlaps(dipinta[p]!);
      // ignore: avoid_print
      print('ORDINE BV VOCE 4: fra la chiave e la carta ${p.name} restano '
          '${aria.toStringAsFixed(1)} punti, si toccano? $sovrapposto');
      expect(sovrapposto, isFalse,
          reason: 'la carta chiave, cresciuta, entra dentro la carta '
              '${p.name}');
    }
  });

  testWidgets('BV.04: le tre carte restano dentro lo schermo, anche piccolo',
      (tester) async {
    // **LA LEZIONE DEL VENTAGLIO, ordine BU**: cio' che cresce puo' uscire di
    // scena, e lo si scopre solo misurandolo su uno schermo vero.
    // **E ANCHE STRETTO, ordine BZ voce 08**: la chiave cresce del dieci per
    // cento e le vicine calano, quindi la fila cambia forma, e il fondatore ha
    // chiesto di controllare che le tre carte ci stiano ancora. Trecentoventi
    // e' il piu' stretto degli schermi in commercio.
    for (final misura in const [
      [360.0, 797.0],
      [360.0, 640.0],
      [320.0, 640.0],
    ]) {
      final larghezza = misura[0];
      final altezza = misura[1];
      await monta(tester,
          altezzaFinestra: altezza, larghezzaFinestra: larghezza);
      final fuori = <String>[];
      for (final p in SpreadPosition.values) {
        final ro = tester
            .element(find.byKey(Key('stesa_carta_${p.name}')))
            .renderObject! as RenderBox;
        final m = ro.getTransformTo(radiceDipinta(tester));
        final r = MatrixUtils.transformRect(m, Offset.zero & ro.size);
        // La cornice sta sei punti piu' in la', e conta anche lei.
        if (r.left - 7 < 0 || r.right + 7 > larghezza) {
          fuori.add('${p.name} da ${r.left.toStringAsFixed(1)} a '
              '${r.right.toStringAsFixed(1)}');
        }
      }
      // ignore: avoid_print
      print('ORDINE BV VOCE 4: su ${larghezza.toStringAsFixed(0)} per '
          '${altezza.toStringAsFixed(0)}, carte fuori dai bordi: '
          '${fuori.isEmpty ? "nessuna" : fuori}');
      expect(fuori, isEmpty,
          reason: 'su uno schermo ${larghezza}x$altezza queste carte escono '
              'dai bordi: $fuori');
    }
  });
}
