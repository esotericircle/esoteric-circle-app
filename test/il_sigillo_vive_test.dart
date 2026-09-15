import 'dart:convert';
import 'dart:ui' as ui;

import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:esoteric_circle/core/magic/il_sigillo_dal_modello.dart';
import 'package:esoteric_circle/core/magic/il_sigillo_vivo.dart';
import 'package:esoteric_circle/core/magic/intention_sigil.dart';
import 'package:esoteric_circle/core/magic/la_chiamata_del_sigillo.dart';
import 'package:esoteric_circle/core/magic/la_voce_del_sigillo.dart';
import 'package:esoteric_circle/core/magic/libro_dei_sigilli.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/rituals/avvisi_del_rito.dart';
import 'package:esoteric_circle/core/viaggio/le_guardie_del_responso.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/sigillo/il_segno_del_sigillo.dart';
import 'package:esoteric_circle/features/maestri/caligo/sigillo/libro_dei_sigilli_screen.dart';
import 'package:esoteric_circle/services/apertura_delle_chiamate.dart';
import 'package:esoteric_circle/services/avvisi_locali.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **IL SIGILLO DELL'INTENZIONE DIVENTA UN OGGETTO CHE VIVE.** Ordine DO,
/// 15 settembre 2026: lo stato, la carica, il Libro, i limiti del piano, la
/// chiamata alla scadenza, i testi del modello con le loro guardie, il genere
/// e lo sfondo del telefono.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  final oggi = DateTime(2026, 9, 15, 11);

  SigilloVivo nuovo(String id,
          {DateTime? nascita,
          int giorni = 30,
          ViaMagica via = ViaMagica.bianca,
          String intenzione = 'Chiedo chiarezza sulla mia strada'}) =>
      SigilloVivo(
        id: id,
        intenzione: intenzione,
        riformulata: intenzione,
        via: via,
        nascita: nascita ?? oggi,
        scadenza: DateTime((nascita ?? oggi).year, (nascita ?? oggi).month,
            (nascita ?? oggi).day + giorni),
      );

  group('DO.02: lo stato', () {
    test('Nasce vivo e spento', () {
      final s = nuovo('a');
      expect(s.statoA(oggi), StatoDelSigillo.vivo);
      expect(s.cariche, isEmpty);
      expect(s.luceA(oggi), 0);
    });

    test('Arriva alla sua data all\'inizio del giorno scelto', () {
      final s = nuovo('a', giorni: 3);
      final vigilia = DateTime(2026, 9, 17, 23, 59);
      final giorno = DateTime(2026, 9, 18, 0, 1);
      expect(s.statoA(vigilia), StatoDelSigillo.vivo);
      expect(s.statoA(giorno), StatoDelSigillo.scaduto,
          reason: 'la chiamata suona quel giorno, e chi la tocca deve trovare '
              'la domanda');
    });

    test('Compiuto e lasciato li dichiara la persona, e restano', () {
      final s = nuovo('a', giorni: 3)
          .dichiara(StatoDelSigillo.compiuto, oggi, testoDelCompimento: 'x');
      expect(s.statoA(oggi.add(const Duration(days: 400))),
          StatoDelSigillo.compiuto);
      final l = nuovo('b').dichiara(StatoDelSigillo.lasciato, oggi);
      expect(l.statoA(oggi), StatoDelSigillo.lasciato);
    });

    test('Si salva e si rilegge per intero', () {
      final s = nuovo('a')
          .conCarica(oggi)
          .conITesti('Titolo', 'Responso')
          .dichiara(StatoDelSigillo.compiuto, oggi, testoDelCompimento: 'T');
      final r = SigilloVivo.fromJson(
          (jsonDecode(jsonEncode(s.toJson())) as Map).cast<String, Object?>())!;
      expect(r.toJson(), s.toJson());
    });
  });

  group('DO.03: la carica', () {
    test('Una al giorno per sigillo vivo, e la luce cresce', () async {
      var adesso = oggi;
      final libro = LibroDeiSigilli(orologio: () => adesso);
      await libro.apri();
      await libro.aggiungi(nuovo('a'));
      expect(await libro.caricaIlSigillo('a'), isTrue);
      expect(await libro.caricaIlSigillo('a'), isFalse,
          reason: 'due cariche nello stesso giorno');
      final prima = libro.diId('a')!.luceA(adesso);
      adesso = adesso.add(const Duration(days: 1));
      expect(await libro.caricaIlSigillo('a'), isTrue);
      expect(libro.diId('a')!.luceA(adesso), greaterThan(prima));
    });

    test('Sotto la settimana non si affievolisce, dopo un mese si', () {
      var s = nuovo('a', giorni: 90);
      for (var i = 0; i < 7; i++) {
        s = s.conCarica(oggi.add(Duration(days: i)));
      }
      final ultima = oggi.add(const Duration(days: 6));
      expect(s.luceA(ultima), 1.0);
      expect(s.luceA(ultima.add(const Duration(days: 6))), 1.0,
          reason: 'sotto la settimana e\' la vita normale di una persona');
      expect(s.luceA(ultima.add(const Duration(days: 30))), lessThan(1.0));
    });

    test('Uno scaduto o chiuso non si carica', () async {
      var adesso = oggi;
      final libro = LibroDeiSigilli(orologio: () => adesso);
      await libro.apri();
      await libro.aggiungi(nuovo('a', giorni: 1));
      adesso = oggi.add(const Duration(days: 2));
      expect(await libro.caricaIlSigillo('a'), isFalse);
    });

    test('La prima carica cambia il segno a vista: un terzo della luce', () {
      final prima = SegnoDelSigilloPainter.visibile(0);
      final dopo = SegnoDelSigilloPainter.visibile(1 / 7);
      expect(dopo - prima, greaterThan(0.3));
    });
  });

  group('DO.05 e DO.06: il Libro', () {
    test('Vivi per data, poi i chiusi dal piu\' recente', () async {
      var adesso = oggi;
      final libro = LibroDeiSigilli(orologio: () => adesso);
      await libro.apri();
      await libro.aggiungi(nuovo('lontano', giorni: 60));
      await libro.aggiungi(nuovo('vicino', giorni: 10));
      await libro.aggiungi(nuovo('chiuso', giorni: 20));
      await libro.dichiara('chiuso', StatoDelSigillo.compiuto,
          testoDelCompimento: 'x');
      expect(libro.vivi.map((s) => s.id), ['vicino', 'lontano']);
      expect(libro.chiusi.map((s) => s.id), ['chiuso']);
      final riaperto = LibroDeiSigilli(orologio: () => adesso);
      await riaperto.apri();
      expect(riaperto.tutti, hasLength(3), reason: 'il Libro non si salva');
    });

    test('Il rinnovo da\' una data nuova e la carica riparte', () async {
      final libro = LibroDeiSigilli(orologio: () => oggi);
      await libro.apri();
      await libro.aggiungi(nuovo('a'));
      await libro.caricaIlSigillo('a');
      final nuova = DateTime(2026, 12, 1);
      await libro.rinnova('a', nuova);
      expect(libro.diId('a')!.scadenza, nuova);
      expect(libro.diId('a')!.cariche, isEmpty);
    });
  });

  group('DO.11: i limiti sono di spazio', () {
    test('La matrice dice 1, 2, 3 e 5, e la carica e\' sempre aperta', () {
      expect([for (final t in Tier.values) ILimitiDelSigillo.viviInsiemePer(t)],
          [1, 2, 3, 5]);
      final carica = PlanCatalog.matrix
          .firstWhere((r) => r.chiave == RigaDelPiano.caricaDelSigillo);
      expect(carica.values.toSet(), {'Sempre'});
    });

    test('Pieno col piano, libero quando uno si chiude', () async {
      final libro = LibroDeiSigilli(orologio: () => oggi);
      await libro.apri();
      await libro.aggiungi(nuovo('a'));
      expect(ILimitiDelSigillo.puoTracciare(Tier.free, libro),
          EsitoDelTracciamento.pieno);
      expect(ILimitiDelSigillo.puoTracciare(Tier.tier1, libro),
          EsitoDelTracciamento.si);
      await libro.dichiara('a', StatoDelSigillo.lasciato);
      expect(ILimitiDelSigillo.puoTracciare(Tier.free, libro),
          EsitoDelTracciamento.si);
    });

    test('Uno arrivato alla data senza risposta occupa ancora lo spazio',
        () async {
      var adesso = oggi;
      final libro = LibroDeiSigilli(orologio: () => adesso);
      await libro.apri();
      await libro.aggiungi(nuovo('a', giorni: 1));
      adesso = oggi.add(const Duration(days: 3));
      expect(libro.scaduti, hasLength(1));
      expect(ILimitiDelSigillo.puoTracciare(Tier.free, libro),
          EsitoDelTracciamento.pieno);
    });

    test('Il tetto tecnico: dieci tracciamenti al giorno contando tutto',
        () async {
      final libro = LibroDeiSigilli(orologio: () => oggi);
      await libro.apri();
      for (var i = 0; i < 10; i++) {
        await libro.aggiungi(nuovo('s$i'));
        await libro.dichiara('s$i', StatoDelSigillo.lasciato);
      }
      expect(ILimitiDelSigillo.puoTracciare(Tier.tier3, libro),
          EsitoDelTracciamento.tettoTecnico);
    });
  });

  group('DO.08: la chiamata alla scadenza', () {
    test('Il Libro la programma, la sposta e la toglie', () async {
      final avvisi = _AvvisiFinti();
      final libro = LibroDeiSigilli(orologio: () => oggi, avvisi: avvisi);
      await libro.apri();
      final s = nuovo('a', giorni: 30);
      await libro.aggiungi(s);
      final id = LaChiamataDelSigillo.idDi('a');
      final c = avvisi.programmate[id]!;
      expect(c.quando, DateTime(2026, 10, 15, LaChiamataDelSigillo.ora));
      expect(c.canale, LaChiamataDelSigillo.canale);
      expect(c.carico, LaChiamataDelSigillo.carico);
      expect('${c.titolo} ${c.testo}'.contains(s.intenzione), isFalse);
      expect(
          '${c.titolo} ${c.testo}'.toLowerCase().contains('chiarezza'), isFalse,
          reason: 'la notifica si legge davanti a chiunque passi');
      await libro.rinnova('a', DateTime(2026, 11, 20));
      expect(avvisi.programmate[id]!.quando,
          DateTime(2026, 11, 20, LaChiamataDelSigillo.ora));
      await libro.dichiara('a', StatoDelSigillo.compiuto);
      expect(avvisi.programmate.containsKey(id), isFalse);
    });

    test('Il canale e\' dichiarato, e gli id stanno lontano dai Doni', () {
      expect(
          AvvisiLocali.canali.containsKey(LaChiamataDelSigillo.canale), isTrue);
      for (var i = 0; i < 500; i++) {
        final id = LaChiamataDelSigillo.idDi('s$i');
        expect(id, inInclusiveRange(2000, 6999));
      }
    });

    testWidgets('Il carico della chiamata apre il Libro', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(MaterialApp(home: Builder(builder: (c) {
        ctx = c;
        return const SizedBox();
      })));
      expect(AperturaDelleChiamate.rottaPer(LaChiamataDelSigillo.carico, ctx),
          isNotNull);
    });
  });

  group('DO.10: i testi del modello e la riserva', () {
    Future<String?> Function(String, String, Map<String, dynamic>) risponde(
            Map<String, String> j) =>
        (i, r, c) async => jsonEncode(j);

    test('Titolo e responso passano quando reggono', () async {
      final t = await IlSigilloDalModello.scrivi(
        intenzione: 'Chiedo chiarezza sulla mia strada',
        via: ViaMagica.bianca,
        forma: CourtesyForm.unknown,
        chiamata: (i, r, c) => risponde({
          'titolo': 'La chiarezza sulla tua strada',
          'responso': 'Il segno custodisce la chiarezza che cerchi sulla tua '
              'strada.',
        })(i, r, c),
      );
      expect(t.titoloDalModello, isTrue);
      expect(t.responsoDalModello, isTrue);
    });

    test('Il fuoco, la promessa e il silenzio del modello: parla la casa',
        () async {
      final fuoco = await IlSigilloDalModello.scrivi(
        intenzione: 'Chiedo chiarezza sulla mia strada',
        via: ViaMagica.bianca,
        forma: CourtesyForm.unknown,
        chiamata: (i, r, c) => risponde({
          'titolo': 'La chiarezza sulla tua strada',
          'responso': 'Accendi una candela per la chiarezza sulla tua strada.',
        })(i, r, c),
      );
      expect(fuoco.responsoDalModello, isFalse);
      expect(fuoco.scarti, isNotEmpty);
      expect(fuoco.responso, contains('Chiedo chiarezza sulla mia strada'),
          reason: 'la riserva di casa deve nominare l\'intenzione');
      final muto = await IlSigilloDalModello.scrivi(
        intenzione: 'Metto radici',
        via: ViaMagica.verde,
        forma: CourtesyForm.unknown,
        chiamata: (i, r, c) async => throw Exception('rete'),
      );
      expect(muto.titolo, isNotEmpty);
      expect(muto.responso, contains('Metto radici'));
    });

    test('Il compimento nomina l\'intenzione anche senza modello', () async {
      final r = await IlSigilloDalModello.compimento(
        intenzione: 'Trovo un lavoro che mi somiglia',
        forma: CourtesyForm.unknown,
        chiamata: (i, r, c) async => null,
      );
      expect(r.dalModello, isFalse);
      expect(r.testo, contains('Trovo un lavoro che mi somiglia'));
    });

    test(
        'Ogni istruzione porta il blocco di cortesia e il modello e\' in '
        'regione', () {
      for (final f in CourtesyForm.values) {
        for (final i in [
          IlSigilloDalModello.istruzioneDeiTesti(f),
          IlSigilloDalModello.istruzioneDelCompimento(f),
          IlSigilloDalModello.istruzioneDellaRiformulazione(f),
        ]) {
          expect(i, contains('COME TI RIVOLGI ALLA PERSONA:'));
        }
      }
      expect(IlSigilloDalModello.modello, 'gemini-2.5-flash');
      expect(IlSigilloDalModello.riformulazioniPerSigillo, 3);
    });

    test('I titoli di casa reggono alle guardie per ogni forma', () {
      for (final via in ViaMagica.values) {
        for (final t in LaVoceDelSigillo.titoli[via]!) {
          for (final f in CourtesyForm.values) {
            expect(
                LeGuardieDelResponso.delTitolo(t,
                    domanda: 'chiarezza', forma: f),
                isNull,
                reason: '"$t" a ${f.name}');
          }
        }
      }
    });
  });

  group('DO.12: la riformulazione non dice il genere sbagliato', () {
    test('Il genere della prima persona si legge', () {
      expect(
          IlSigilloDalModello.genereDellaPrimaPersona(
              'Sono pronta ad accogliere un legame'),
          'f');
      expect(
          IlSigilloDalModello.genereDellaPrimaPersona(
              'Mi sento amato e scelto'),
          'm');
      expect(
          IlSigilloDalModello.genereDellaPrimaPersona(
              'Apro il mio cuore a un legame vero'),
          isNull);
    });

    test('A una donna niente maschile, a chi non ha scelto niente dei due',
        () async {
      Future<String?> dice(String t) async => jsonEncode({'riformulata': t});
      Future<String?> riformula(String t, CourtesyForm f) =>
          IlSigilloDalModello.riformula(
              intenzione: 'Voglio un amore',
              via: ViaMagica.rossa,
              forma: f,
              chiamata: (i, r, c) => dice(t));
      expect(
          await riformula(
              'Sono pronto ad accogliere l\'amore', CourtesyForm.feminine),
          isNull);
      expect(
          await riformula(
              'Sono pronta ad accogliere l\'amore', CourtesyForm.feminine),
          isNotNull);
      expect(
          await riformula(
              'Sono pronta ad accogliere l\'amore', CourtesyForm.unknown),
          isNull);
      expect(
          await riformula(
              'Accolgo l\'amore nella mia vita', CourtesyForm.unknown),
          isNotNull);
    });

    test('La riformulazione di casa non dice il genere', () {
      final r = LettoreIntenzione.leggi('Fai che lui si innamori di me');
      expect(r.eStataRiformulata, isTrue);
      expect(
          IlSigilloDalModello.genereDellaPrimaPersona(r.riformulata), isNull);
      expect(r.riformulata.contains('degno'), isFalse);
    });
  });

  group('DO.07: lo sfondo del telefono', () {
    test(
        'Il segno sta nella fascia fra il 35 e il 60 per cento, largo al '
        'massimo il 55', () {
      const fondo = Size(1440, 3200);
      final r = LoSfondoDelSigillo.riquadroDelSegno(fondo);
      expect(r.top, greaterThanOrEqualTo(fondo.height * 0.35));
      expect(r.bottom, lessThanOrEqualTo(fondo.height * 0.60));
      expect(r.width, lessThanOrEqualTo(fondo.width * 0.55));
      expect(r.center.dx, fondo.width / 2);
    });

    testWidgets(
        'Sul fondo vero la fascia e\' scura, e fuori dal segno l\'immagine '
        'e\' il fondo com\'era: nessuna scritta', (tester) async {
      await tester.runAsync(() async {
        for (final via in ViaMagica.values) {
          final dati = await rootBundle.load(LoSfondoDelSigillo.fondoPer(via));
          final codec =
              await ui.instantiateImageCodec(dati.buffer.asUint8List());
          final fondo = (await codec.getNextFrame()).image;
          expect([fondo.width, fondo.height], [1440, 3200]);
          final pFondo = (await fondo.toByteData())!;
          final cammino =
              IntentionSigil.cammino('Chiedo chiarezza sulla mia strada');
          final composto =
              await LoSfondoDelSigillo.componi(via: via, cammino: cammino);
          final pComp = (await composto.toByteData())!;
          final r = LoSfondoDelSigillo.riquadroDelSegno(const Size(1440, 3200))
              .inflate(40);
          var diversiFuori = 0;
          var diversiDentro = 0;
          // LA MEDIA DEI TRE CANALI, che e' la misura con cui i fondi sono
          // stati dichiarati dal fondatore: con la luma Rec.709 la rossa,
          // che ha il verde quasi a zero, scende a 6,2 e sembrerebbe fuori.
          var somma = 0.0;
          var n = 0;
          for (var y = 0; y < 3200; y += 4) {
            for (var x = 0; x < 1440; x += 4) {
              final i = (y * 1440 + x) * 4;
              final diverso = pFondo.getUint8(i) != pComp.getUint8(i) ||
                  pFondo.getUint8(i + 1) != pComp.getUint8(i + 1) ||
                  pFondo.getUint8(i + 2) != pComp.getUint8(i + 2);
              if (r.contains(Offset(x.toDouble(), y.toDouble()))) {
                if (diverso) diversiDentro++;
              } else if (diverso) {
                diversiFuori++;
              }
              if (y >= 3200 * 0.35 && y < 3200 * 0.60) {
                somma += (pFondo.getUint8(i) +
                        pFondo.getUint8(i + 1) +
                        pFondo.getUint8(i + 2)) /
                    3;
                n++;
              }
            }
          }
          final media = somma / n;
          // ignore: avoid_print
          print('DO.07 ${via.name}: fascia ${media.toStringAsFixed(1)}/255, '
              'pixel cambiati dentro $diversiDentro, fuori $diversiFuori');
          expect(media, inInclusiveRange(7, 24), reason: via.name);
          expect(diversiFuori, 0,
              reason: 'fuori dal segno l\'immagine e\' cambiata: ci si e\' '
                  'scritto qualcosa');
          expect(diversiDentro, greaterThan(500),
              reason: 'il segno non si e\' composto sul fondo');
          fondo.dispose();
          composto.dispose();
        }
      });
    });
  });

  group('DO.03 a video: la carica col dito', () {
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

    Future<void> monta(WidgetTester tester, Widget w) async {
      silence();
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
        ],
        child: MaterialApp(home: MaestroScope(child: w)),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }

    Future<void> ripassa(WidgetTester tester, List<Offset> cammino,
        {int salta = -1}) async {
      final r = tester.getRect(find.byKey(const Key('sigillo_carica_gesto')));
      Offset p(Offset n) => r.topLeft + Offset(n.dx * r.width, n.dy * r.width);
      final g = await tester.startGesture(p(cammino.first));
      var da = p(cammino.first);
      for (var i = 1; i < cammino.length; i++) {
        // Saltare un punto vuol dire andare dritti dal precedente al
        // successivo, senza passarci.
        if (i == salta) continue;
        final a = p(cammino[i]);
        for (var k = 1; k <= 6; k++) {
          await g.moveTo(Offset.lerp(da, a, k / 6)!);
          await tester.pump(const Duration(milliseconds: 16));
        }
        da = a;
      }
      await g.up();
      await tester.pump();
    }

    double luce(WidgetTester tester) => (tester
            .widget<CustomPaint>(find.byKey(const Key('sigillo_segno')))
            .painter! as SegnoDelSigilloPainter)
        .luce;

    testWidgets('Ripassato il segno, la carica entra e il segno si accende',
        (tester) async {
      final libro = LibroDeiSigilli(orologio: () => oggi);
      await libro.apri();
      final s = nuovo('a', intenzione: 'Chiedo pace');
      await libro.aggiungi(s);
      await monta(tester, SigilloDelLibroScreen(id: 'a', libro: libro));
      expect(luce(tester), 0);
      final cammino = IntentionSigil.cammino(s.riformulata);
      // Saltando un punto la carica non entra.
      await ripassa(tester, cammino, salta: 2);
      expect(libro.diId('a')!.cariche, isEmpty,
          reason: 'la carica e\' entrata senza ripercorrere il segno');
      await ripassa(tester, cammino);
      await tester.pump();
      expect(libro.diId('a')!.cariche, hasLength(1));
      expect(luce(tester), greaterThan(0));
      expect(find.text('Il segno si è acceso. Si carica di nuovo domani.'),
          findsOneWidget);
    });

    testWidgets(
        'COSA MI RIMANE: il Libro con due vivi e un compiuto, e nessun '
        'contatore', (tester) async {
      final libro = LibroDeiSigilli(orologio: () => oggi);
      await libro.apri();
      await libro.aggiungi(nuovo('a', giorni: 10));
      await libro.aggiungi(nuovo('b', giorni: 40, via: ViaMagica.rossa));
      await libro.aggiungi(nuovo('c', giorni: 20, via: ViaMagica.verde));
      await libro.dichiara('c', StatoDelSigillo.compiuto,
          testoDelCompimento: 'x');
      await monta(tester, LibroDeiSigilliScreen(libro: libro));
      expect(find.text('VIVI'), findsOneWidget);
      expect(find.text('COMPIUTI E LASCIATI'), findsOneWidget);
      for (final id in ['a', 'b', 'c']) {
        expect(find.byKey(Key('libro_voce_$id')), findsOneWidget);
      }
      final testi = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '')
          .join(' ');
      expect(RegExp(r'\d+ ?(%|/7|cariche)').hasMatch(testi), isFalse,
          reason: 'un contatore di carica e\' a vista');
    });

    testWidgets(
        'COSA HO OTTENUTO: alla data la domanda con tre risposte, e il '
        'compiuto resta col suo testo', (tester) async {
      final libro = LibroDeiSigilli(orologio: () => oggi);
      await libro.apri();
      await libro.aggiungi(nuovo('a', giorni: 10, intenzione: 'Metto radici'));
      await libro.anticipaLaScadenzaPerIlCollaudo('a');
      await monta(
          tester,
          LibroDeiSigilliScreen(
              libro: libro, chiamata: (i, r, c) async => null));
      expect(find.text(LaVoceDelSigillo.laDomanda), findsOneWidget);
      expect(find.text(LaVoceDelSigillo.siECompiuto), findsOneWidget);
      expect(find.text(LaVoceDelSigillo.loLascioAndare), findsOneWidget);
      expect(find.text(LaVoceDelSigillo.loRinnovo), findsOneWidget);
      await tester.tap(find.byKey(const Key('libro_compiuto_a')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 600));
      expect(libro.diId('a')!.statoA(oggi), StatoDelSigillo.compiuto);
      expect(find.byKey(const Key('libro_testo_compimento')), findsOneWidget);
      expect(find.textContaining('Metto radici'), findsWidgets);
    });
  });
}

class _Programmata {
  _Programmata(this.quando, this.titolo, this.testo, this.canale, this.carico);
  final DateTime quando;
  final String titolo;
  final String testo;
  final String canale;
  final String carico;
}

class _AvvisiFinti extends ServizioAvvisi {
  final Map<int, _Programmata> programmate = {};

  @override
  bool get disponibile => true;
  @override
  Future<bool> chiediPermesso() async => true;
  @override
  Future<bool> permessoConcesso() async => true;
  @override
  Future<void> programma({
    required int id,
    required DateTime quando,
    required String titolo,
    required String testo,
    String canale = 'rito_alba',
    String carico = '',
  }) async =>
      programmate[id] = _Programmata(quando, titolo, testo, canale, carico);
  @override
  Future<void> annulla(int id) async => programmate.remove(id);
  @override
  Future<List<int>> inAttesa() async => programmate.keys.toList();
  @override
  Future<void> mostraAdesso(
      {required String titolo, required String testo}) async {}
}
