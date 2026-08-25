import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/synastry/vip_catalog.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/synastry/cielo_dei_volti.dart';
import 'package:esoteric_circle/features/synastry/sinastria_gallery_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// IL CIELO DEI VOLTI. Ordine BO voce 05.
///
/// **Il difetto: la galleria era una lista.** Una `SliverGrid` di mattonelle
/// tutte uguali e ferme, cinquanta ritratti in fila come un catalogo di
/// prodotti, e il fondatore l'ha detto per primo: "prima di tutto per le
/// animazioni che non ci sono".
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
            home: MaestroScope(child: Material(child: scena)),
          ),
        ),
      );

  Future<void> monta(WidgetTester tester,
      {bool riduciMovimento = false, List<Vip>? vips}) async {
    tester.view.physicalSize = const Size(360, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    // **NIENTE SCORRIMENTO INTORNO, e non e' un dettaglio.** La prima stesura
    // montava il cielo dentro un `SingleChildScrollView`, e la prova che
    // conta i rilayout ne trovava due: erano del VIEWPORT, che si marca da
    // solo a ogni fotogramma, non del cielo. Una misura che conta anche il
    // suo contenitore misura la cosa sbagliata. Qui lo schermo della prova e'
    // alto abbastanza da tenere tutto il cielo, quindi non serve scorrere.
    await tester.pumpWidget(attorno(
      Padding(
        padding: const EdgeInsets.all(16),
        child: CieloDeiVolti(
          vips: vips ?? VipCatalog.vips,
          larghezza: 328,
          palette: MaestroPalette.medora,
          onApri: (_) {},
        ),
      ),
      riduciMovimento: riduciMovimento,
    ));
    await tester.pump();
  }

  test('tre profondità, e nessuna sotto il bersaglio del dito', () {
    expect(ProfonditaDelVolto.values, hasLength(3));
    for (final p in ProfonditaDelVolto.values) {
      expect(p.larghezza, greaterThanOrEqualTo(48.0),
          reason: '${p.name} è sotto i 48 punti del bersaglio minimo');
      expect(p.larghezza / kRapportoDelRitratto, greaterThanOrEqualTo(48.0),
          reason: '${p.name}: il bersaglio è alto meno di 48 punti');
    }
    // I tre piani sono davvero diversi: se due coincidessero, la profondità
    // non esisterebbe e la parallasse sarebbe una faglia fra due gruppi.
    final profondita = {for (final p in ProfonditaDelVolto.values) p.depth};
    expect(profondita, hasLength(3));
  });

  test('la disposizione è deterministica: due aperture, lo stesso cielo', () {
    final a = DisposizioneDelCielo.per(VipCatalog.vips, 328);
    final b = DisposizioneDelCielo.per(VipCatalog.vips, 328);
    for (var i = 0; i < a.length; i++) {
      expect(a[i].centro, b[i].centro, reason: a[i].vip.name);
      expect(a[i].profondita, b[i].profondita, reason: a[i].vip.name);
    }
  });

  test('ogni fila porta tutti e tre i piani', () {
    // Se i piani si raggruppassero, mezza scena si muoverebbe a una velocità
    // e mezza a un'altra: sarebbe una faglia, non una profondità.
    final posti = DisposizioneDelCielo.per(VipCatalog.vips, 328);
    for (var riga = 0; riga * 3 + 2 < posti.length; riga++) {
      final piani = {
        for (var c = 0; c < 3; c++) posti[riga * 3 + c].profondita
      };
      expect(piani, hasLength(3), reason: 'la fila $riga non ha tre piani');
    }
  });

  test('nessun volto esce dal cielo', () {
    const larghezza = 328.0;
    final posti = DisposizioneDelCielo.per(VipCatalog.vips, larghezza);
    final altezza = DisposizioneDelCielo.altezzaPer(VipCatalog.vips.length);
    for (final p in posti) {
      expect(p.riquadro.left, greaterThanOrEqualTo(0), reason: p.vip.name);
      expect(p.riquadro.right, lessThanOrEqualTo(larghezza), reason: p.vip.name);
      expect(p.riquadro.top, greaterThanOrEqualTo(0), reason: p.vip.name);
      expect(p.riquadro.bottom, lessThanOrEqualTo(altezza), reason: p.vip.name);
    }
  });

  testWidgets('tutti e cinquanta i volti sono in scena e toccabili',
      (tester) async {
    await monta(tester);
    for (final v in VipCatalog.vips) {
      final f = find.byKey(Key('vip_${v.name}'));
      expect(f, findsOneWidget, reason: '${v.name} non è nel cielo');
      final r = tester.getRect(f);
      expect(r.width, greaterThanOrEqualTo(48.0), reason: v.name);
      expect(r.height, greaterThanOrEqualTo(48.0), reason: v.name);
    }
  });

  testWidgets('la memoria delle immagini è quella della lista di prima',
      (tester) async {
    await monta(tester);
    // **LA MISURA E' LA MINIATURA, non il byte.** La memoria delle immagini
    // in Flutter la decide quale asset si carica: cinquanta ritratti PIENI
    // sarebbero un ordine di grandezza in piu' della griglia di prima, che
    // caricava le miniature. Si conta quindi che ogni figura in scena chieda
    // la miniatura e nessuna il ritratto pieno, che e' la condizione da cui
    // il vincolo del venti per cento discende.
    final immagini = tester.widgetList<Image>(find.byType(Image)).toList();
    expect(immagini, isNotEmpty);
    final pieni = <String>[];
    for (final img in immagini) {
      final p = img.image;
      if (p is AssetImage && p.assetName.contains('/img/')) {
        pieni.add(p.assetName);
      }
    }
    expect(pieni, isEmpty,
        reason: 'queste figure caricano il ritratto pieno invece della '
            'miniatura, e la memoria del cielo sfonderebbe quella della '
            'lista: $pieni');
    expect(immagini.length, lessThanOrEqualTo(VipCatalog.vips.length),
        reason: 'in scena ci sono più immagini che VIP: qualcuno è '
            'disegnato due volte');
  });

  testWidgets('con Riduci Movimento la parallasse è ferma e il cielo resta',
      (tester) async {
    await monta(tester, riduciMovimento: true);
    // La disposizione non cambia: non si torna alla griglia.
    for (final v in VipCatalog.vips.take(10)) {
      expect(find.byKey(Key('vip_${v.name}')), findsOneWidget, reason: v.name);
    }
    // E nessun ritratto e' agganciato alla parallasse: se lo fosse, il cielo
    // si muoverebbe lo stesso alla prima inclinazione.
    expect(find.byType(Selector<ParallaxController, Offset>), findsNothing,
        reason: 'con Riduci Movimento i volti ascoltano ancora la '
            'parallasse: al primo movimento del telefono si muoverebbero');
  });

  testWidgets('senza Riduci Movimento i volti seguono il loro piano',
      (tester) async {
    await monta(tester);
    expect(find.byType(Selector<ParallaxController, Offset>),
        findsNWidgets(VipCatalog.vips.length),
        reason: 'i volti non ascoltano la parallasse: la scena è ferma');
  });

  testWidgets('inclinare il telefono non ricalcola nessun layout',
      (tester) async {
    // **LA GRANDEZZA CHE PRENDE DAVVERO IL DIFETTO, e la storia di come ci si
    // e' arrivati.**
    //
    // La prima misura era il tempo per fotogramma: passava da sola a 5,4
    // millesimi e cadeva sopra gli otto quando la suite girava con quattro
    // processi in parallelo, cioe' misurava il carico della macchina. Presa
    // la lettura piu' veloce dei trenta, la misura e' diventata stabile, ma
    // **il rosso non scattava piu'**: anche la versione difettosa restava
    // sotto la soglia, perche' una macchina scarica fa in fretta anche il
    // lavoro inutile. Un tempo non e' la grandezza giusta per un difetto che
    // e' STRUTTURALE.
    //
    // Il difetto vero e' questo: spostare i volti cambiando `left` e `top`
    // fa rifare il LAYOUT dello Stack con cinquanta figli a ogni
    // inclinazione. Quindi si misura quello, contando quante volte Flutter
    // marca un render object come "da rilayoutare" durante un fotogramma di
    // parallasse. Zero e' l'unica risposta giusta, e non dipende da nessuna
    // macchina.
    await monta(tester);
    final parallasse = Provider.of<ParallaxController>(
        tester.element(find.byType(CieloDeiVolti)),
        listen: false);
    parallasse.inclinaPerLaProva(0.1, 0.1);
    await tester.pump();

    final righe = <String>[];
    final vecchio = debugPrint;
    debugPrint = (String? messaggio, {int? wrapWidth}) {
      if (messaggio != null) righe.add(messaggio);
    };
    debugPrintMarkNeedsLayoutStacks = true;
    parallasse.inclinaPerLaProva(-0.4, 0.3);
    await tester.pump();
    debugPrintMarkNeedsLayoutStacks = false;
    debugPrint = vecchio;

    // **SI CONTANO GLI OGGETTI, NON LE RIGHE.** La prima stesura contava
    // ogni riga che nominasse `markNeedsLayout`, e ne trovava due per un
    // oggetto solo: la seconda era la traccia dello stack, che quel nome lo
    // contiene per forza. Contava il proprio strumento di misura.
    final marcature = righe
        .where((r) => r.startsWith('markNeedsLayout() called for'))
        .length;
    // ignore: avoid_print
    print('ORDINE BO VOCE 05: un fotogramma di parallasse marca $marcature '
        'render object da rilayoutare');
    expect(marcature, 0,
        reason: 'inclinando il telefono si rifà il layout $marcature volte: '
            'con cinquanta volti in scena è il layout a costare, non il '
            'disegno');
  });

  // **LA MISURA A OROLOGIO NON C'E' PIU', ED E' UNA SOSTITUZIONE DICHIARATA.**
  //
  // C'era una prova che pretendeva meno di otto millesimi per fotogramma. Ha
  // fatto il suo mestiere una volta, trovando lo scarto messo sul layout, poi
  // e' diventata un problema suo: sotto la suite intera con quattro processi
  // in parallelo cadeva anche col codice giusto, e presa la lettura piu'
  // veloce dei trenta smetteva di cadere anche col codice sbagliato. Un
  // orologio dentro una prova misura la macchina, non la scena.
  //
  // **La grandezza che difende lo stesso difetto e non dipende da nessuna
  // macchina sta qui sopra**: quanti render object vengono marcati da
  // rilayoutare durante un fotogramma di parallasse. La soglia non e' stata
  // toccata, e' stata sostituita la cosa misurata, come le regole di casa
  // chiedono quando il rosso non scatta.

  test('ogni categoria ha la sua costellazione, e nessuna due uguali', () {
    final figure = <String, List<Offset>>{};
    for (final c in ['Tutti', ...VipCatalog.categorie]) {
      final punti = CostellazioneDellaCategoria.puntiDi(c);
      expect(punti, hasLength(CostellazioneDellaCategoria.stelle), reason: c);
      for (final p in punti) {
        expect(p.dx, inInclusiveRange(0.0, 1.0), reason: c);
        expect(p.dy, inInclusiveRange(0.0, 1.0), reason: c);
      }
      figure[c] = punti;
    }
    // Due categorie non possono avere la stessa figura, o il filtro
    // smetterebbe di distinguersi a colpo d'occhio.
    final impronte = {
      for (final e in figure.entries)
        e.value.map((p) => '${p.dx.toStringAsFixed(3)},'
            '${p.dy.toStringAsFixed(3)}').join('|')
    };
    expect(impronte, hasLength(figure.length),
        reason: 'due categorie hanno la stessa costellazione');
    // E la stessa categoria da' sempre la stessa figura.
    expect(CostellazioneDellaCategoria.puntiDi('Musica'),
        CostellazioneDellaCategoria.puntiDi('Musica'));
  });
}
