import 'dart:io';

import 'package:esoteric_circle/core/arts/art_catalog.dart';
import 'package:esoteric_circle/core/arts/arti_preferite.dart';
import 'package:esoteric_circle/core/arts/gli_sfondi_delle_schede.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/santuario/le_righe_della_casa.dart';
import 'package:esoteric_circle/features/schede/la_luce_delle_schede.dart';
import 'package:esoteric_circle/features/schede/la_riga_delle_schede.dart';
import 'package:esoteric_circle/features/schede/la_scheda_dell_arte.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';

/// **LA SCHEDA DELL'ARTE E LE RIGHE DELLA HOME.** Ordine EO, voci da 02 a
/// 07 e voce 09, 26 settembre 2026.
///
/// Una sola scheda per tutta l'app (`lib/features/schede/`), e le dieci righe
/// della home (`lib/features/santuario/le_righe_della_casa.dart`). Qui si
/// misura quello che il fondatore ha chiesto, voce per voce, sulla
/// composizione vera che la home monta: `LeRigheDellaCasaView`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ArtEntry arte(String id) => ArtCatalog.all.firstWhere((a) => a.id == id);

  /// La finestra del telefono di prova, 390 per 844 punti.
  void finestra(WidgetTester tester) {
    tester.view.devicePixelRatio = 3.0;
    tester.view.physicalSize = const Size(1170, 2532);
    addTearDown(tester.view.reset);
  }

  Widget conIlCerchio(Widget figlio,
          {bool riduci = false,
          double scala = 1,
          ArtiPreferiteController? pref}) =>
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          if (pref != null)
            ChangeNotifierProvider<ArtiPreferiteController>.value(value: pref),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(
                disableAnimations: riduci,
                textScaler: TextScaler.linear(scala)),
            child: MaestroScope(child: child!),
          ),
          home: Scaffold(backgroundColor: Colors.black, body: figlio),
        ),
      );

  /// Monta UNA scheda da sola, con un'apertura finta che si annota.
  Future<List<String>> montaUna(WidgetTester tester, String id,
      {bool riduci = false}) async {
    finestra(tester);
    final aperte = <String>[];
    await tester.pumpWidget(conIlCerchio(
      Center(
        child: LaSchedaDellArte(
          art: arte(id),
          maestro: Maestro.caligo,
          formato: FormatoDellaScheda.verticale,
          larghezza:
              LaSchedaDellArte.larghezzaPer(FormatoDellaScheda.verticale),
          onApri: (_) async => aperte.add(id),
        ),
      ),
      riduci: riduci,
    ));
    await tester.pump();
    return aperte;
  }

  LaSchedaDellArteState stato(WidgetTester tester) =>
      tester.state<LaSchedaDellArteState>(find.byType(LaSchedaDellArte));

  /// L'angolo in alto a destra COME SI VEDE a video, dentro l'area della
  /// "i": venti punti dentro dai due bordi. Si prende a scheda dritta, perche'
  /// mezzo giro specchia la pila ma non sposta il riquadro.
  Offset angoloInAltoADestra(WidgetTester tester, String id) {
    final r = tester.getRect(find.byKey(Key('scheda_tocco_$id')));
    return Offset(r.right - 20, r.top + 20);
  }

  // --- EO.02, COM'E' FATTA UNA SCHEDA -------------------------------------

  /// Quanto un widget e' ingrandito o rimpicciolito rispetto a un suo
  /// antenato: si confrontano le due trasformazioni verso lo schermo. Il
  /// sollevamento della scheda al centro vale per tutti e due, e si elide.
  ///
  /// **SI TRASFORMANO DUE PUNTI, non si legge `getMaxScaleOnAxis`.** La prima
  /// stesura lo leggeva, e l'innesto di un titolo rimpicciolito a 0,9 ne
  /// coglieva 14 su 56: con la prospettiva del giro nella catena le
  /// traslazioni finiscono nella colonna z della matrice, e quel numero
  /// cambiava con la posizione della scheda nella riga. La distanza fra due
  /// punti trasformati e' la scala che l'occhio vede.
  double scalaRelativa(RenderBox figlio, RenderBox antenato) {
    double scalaX(RenderBox b) {
      final m = b.getTransformTo(null);
      final a = MatrixUtils.transformPoint(m, Offset.zero);
      final c = MatrixUtils.transformPoint(m, const Offset(100, 0));
      return (c - a).distance / 100;
    }

    return scalaX(figlio) / scalaX(antenato);
  }

  /// L'area minima della "i", dall'ordine EO voce 04: *"almeno 48 dp"*. E'
  /// il numero dell'ordine e non la costante del codice: con la costante,
  /// l'innesto che la abbassava a 30 abbassava anche la soglia, e la guardia
  /// restava verde.
  const areaMinimaDellaI = 48.0;

  for (final scala in const [1.0, 1.3]) {
    testWidgets(
        'EO.02: su tutte le schede della home il titolo e\' sotto, a sinistra, '
        'al massimo su due righe e mai rimpicciolito (testo a $scala)',
        (tester) async {
      SharedPreferences.setMockInitialValues(const {});
      finestra(tester);
      final pref = ArtiPreferiteController();
      addTearDown(pref.dispose);
      await tester.pumpWidget(conIlCerchio(
        const SingleChildScrollView(
            child: LeRigheDellaCasaView(sensore: false)),
        scala: scala,
        pref: pref,
      ));
      await tester.pump();

      final pieno = LaSchedaDellArte.stileDelTitolo();
      final riga1 = TextPainter(
        text: TextSpan(text: 'A', style: pieno),
        textDirection: TextDirection.ltr,
        textScaler: TextScaler.linear(scala),
      )..layout();
      final altezzaDiRiga = riga1.height;
      riga1.dispose();

      var unaRiga = 0, dueRighe = 0, righeDecise = 0, rimpiccioliti = 0;
      var oltreDue = 0, schede = 0;
      final chiavi = [
        LeRigheDellaCasa.preferite,
        for (final r in LeRigheDellaCasa.righe) r.chiave,
      ];
      for (final chiave in chiavi) {
        final posizione = tester
            .state<ScrollableState>(find.descendant(
                of: find.byKey(Key('riga_scorre_$chiave')),
                matching: find.byType(Scrollable)))
            .position;
        final viste = <String>{};
        for (var px = 0.0;; px += 120) {
          posizione.jumpTo(px.clamp(0, posizione.maxScrollExtent));
          await tester.pump();
          final prefisso = 'riga_${chiave}_';
          for (final e in find
              .byWidgetPredicate((w) =>
                  w.key is ValueKey<String> &&
                  (w.key! as ValueKey<String>).value.startsWith(prefisso))
              .evaluate()) {
            final id = (e.widget.key! as ValueKey<String>)
                .value
                .substring(prefisso.length);
            if (!viste.add(id)) continue;
            schede++;
            final scheda = find.byKey(Key('$prefisso$id'));
            final colonna = tester.renderObject<RenderBox>(find.descendant(
                of: scheda, matching: find.byKey(Key('scheda_$id'))));
            final titolo = find.descendant(
                of: scheda, matching: find.byKey(Key('scheda_titolo_$id')));
            final immagine = find.descendant(
                of: scheda, matching: find.byKey(Key('scheda_tocco_$id')));

            // Sotto e a sinistra: il bordo sinistro del titolo e' quello
            // dell'immagine, e il titolo comincia dove l'immagine finisce.
            final rImm = tester.getRect(immagine);
            final rTit = tester.getRect(titolo);
            expect((rTit.left - rImm.left).abs(), lessThan(0.5),
                reason: '$chiave/$id: il titolo non e\' allineato al bordo '
                    'sinistro dell\'immagine');
            expect(rTit.top, greaterThanOrEqualTo(rImm.bottom - 0.5),
                reason: '$chiave/$id: il titolo non sta sotto l\'immagine');

            // Nessun testo sopra l'immagine: la "i", la clessidra e il
            // lucchetto sono icone.
            expect(find.descendant(of: immagine, matching: find.byType(Text)),
                findsNothing,
                reason: '$chiave/$id: c\'e\' testo sopra l\'immagine');

            final paragrafi = tester
                .renderObjectList<RenderParagraph>(find.descendant(
                    of: titolo,
                    matching: find.byType(RichText),
                    matchRoot: true))
                .toList();
            final deciso = arte(id).righeDelTitolo != null;
            for (final p in paragrafi) {
              final s = scalaRelativa(p, colonna);
              final corpo = p.text.style?.fontSize ?? 0;
              if (s < 0.999 || (!deciso && corpo < pieno.fontSize! - 0.01)) {
                rimpiccioliti++;
                debugPrint('RIMPICCIOLITO $chiave/$id: scala $s corpo $corpo');
              }
              if (p.didExceedMaxLines) {
                oltreDue++;
                debugPrint('OLTRE LE RIGHE $chiave/$id');
              }
            }
            if (deciso) {
              righeDecise++;
            } else {
              final righe =
                  (paragrafi.single.size.height / altezzaDiRiga).round();
              if (righe <= 1) {
                unaRiga++;
              } else if (righe == 2) {
                dueRighe++;
              } else {
                oltreDue++;
              }
            }

            // Gli angoli: la "i" su tutte, con la sua area di un centimetro;
            // la clessidra sulle arti in arrivo, il lucchetto sulle Premium.
            final i = find.descendant(
                of: scheda, matching: find.byKey(Key('scheda_i_$id')));
            expect(i, findsOneWidget, reason: '$chiave/$id: manca la "i"');
            final area = tester.getSize(i);
            expect(area.shortestSide, greaterThanOrEqualTo(areaMinimaDellaI),
                reason: '$chiave/$id: l\'area della "i" e\' $area');
            final st = arte(id).state;
            expect(
                find.descendant(
                    of: scheda,
                    matching: find.byKey(Key('scheda_clessidra_$id'))),
                st == ArtState.inArrivo ? findsOneWidget : findsNothing,
                reason: '$chiave/$id ($st): la clessidra');
            expect(
                find.descendant(
                    of: scheda,
                    matching: find.byKey(Key('scheda_lucchetto_$id'))),
                st == ArtState.premium ? findsOneWidget : findsNothing,
                reason: '$chiave/$id ($st): il lucchetto');
          }
          if (px >= posizione.maxScrollExtent) break;
        }
      }
      // ignore: avoid_print
      print('EO.02 MISURA (testo a $scala): schede $schede, titoli su una riga '
          '$unaRiga, su due righe $dueRighe, righe decise $righeDecise, oltre '
          'due righe $oltreDue, rimpiccioliti $rimpiccioliti');
      // Le schede della home oggi sono 56: sei preferite e cinquanta nelle
      // nove righe. Margine dichiarato di sei, una riga intera.
      cardinaleMinimo(schede, 50,
          cosa: 'schede della home',
          perche: 'la guardia dei titoli gira sulle schede che trova a video.');
      expect(rimpiccioliti, 0, reason: 'titoli rimpiccioliti');
      expect(oltreDue, 0, reason: 'titoli oltre le due righe');
    });
  }

  // --- EO.03, IL TOCCO ------------------------------------------------------

  testWidgets(
      'EO.03: la scheda si abbassa, si ingrandisce e svanisce, e l\'arte si '
      'apre sotto, in circa tre decimi di secondo', (tester) async {
    final aperte = await montaUna(tester, 'rune_draw');
    await tester.tap(find.byKey(const Key('scheda_tocco_rune_draw')));
    await tester.pump();
    final premuta = tester.widget<AnimatedScale>(find.byType(AnimatedScale));
    expect(premuta.scale, LaSchedaDellArte.pressione,
        reason: 'al tocco la scheda non si abbassa come un pulsante');

    var ms = 0;
    var vistaUscire = false;
    var apertaA = -1;
    var massimo = 0.0;
    while (ms < 1000) {
      await tester.pump(const Duration(milliseconds: 10));
      ms += 10;
      if (apertaA < 0 && aperte.isNotEmpty) apertaA = ms;
      final uscita = find.byKey(const Key('scheda_in_uscita'));
      if (uscita.evaluate().isNotEmpty) {
        vistaUscire = true;
        final scala = tester
            .widget<Transform>(find
                .descendant(of: uscita, matching: find.byType(Transform))
                .first)
            .transform
            .getMaxScaleOnAxis();
        if (scala > massimo) massimo = scala;
      } else if (vistaUscire) {
        break;
      }
    }
    // ignore: avoid_print
    print('EO.03 MISURA: transizione $ms ms, arte aperta a $apertaA ms, '
        'ingrandimento massimo ${massimo.toStringAsFixed(3)}');
    expect(vistaUscire, isTrue, reason: 'la scheda non svanisce');
    expect(aperte, ['rune_draw']);
    expect(apertaA, lessThan(ms),
        reason: 'l\'arte deve aprirsi SOTTO, mentre la scheda svanisce');
    expect(massimo, greaterThan(1.1), reason: 'la scheda non si ingrandisce');
    expect(ms, inInclusiveRange(250, 350),
        reason: 'la transizione deve durare circa tre decimi di secondo');
  });

  // **LAPIDE: fino alla prima stesura dell'ordine EO, con la riduzione del
  // movimento il tocco apriva l'arte senza effetti.** L'ordine spegne con la
  // riduzione del movimento solo il riflesso (EO.06) e il sollevamento
  // (EO.07); e sul Realme del collaudo le tre scale delle animazioni sono a
  // zero, che Flutter legge come riduzione del movimento: il fondatore non
  // avrebbe mai visto il tocco che ha chiesto.
  testWidgets(
      'EO.03: con le animazioni del telefono a zero il tocco dura ancora tre '
      'decimi, e non si accorcia', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    final aperte = await montaUna(tester, 'rune_draw', riduci: true);
    await tester.tap(find.byKey(const Key('scheda_tocco_rune_draw')));
    await tester.pump();
    var ms = 0;
    var vista = false;
    while (ms < 1000) {
      await tester.pump(const Duration(milliseconds: 10));
      ms += 10;
      if (find.byKey(const Key('scheda_in_uscita')).evaluate().isNotEmpty) {
        vista = true;
      } else if (vista) {
        break;
      }
    }
    // ignore: avoid_print
    print('EO.03 MISURA con le animazioni a zero: transizione $ms ms');
    expect(vista, isTrue,
        reason: 'con le animazioni a zero la scheda non svanisce');
    expect(aperte, ['rune_draw']);
    expect(ms, inInclusiveRange(250, 350),
        reason: 'con le animazioni a zero la transizione si e\' accorciata');
  });

  testWidgets(
      'EO.04: con le animazioni del telefono a zero la scheda gira in tre '
      'dimensioni, non di colpo', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await montaUna(tester, 'rune_draw', riduci: true);
    await tester.tap(find.byKey(const Key('scheda_i_rune_draw')));
    await tester.pump();
    await tester.pump(LaSchedaDellArte.tempoDelGiro ~/ 4);
    expect(stato(tester).girata, isFalse,
        reason: 'a un quarto del tempo la scheda e\' gia\' girata: il giro si '
            'e\' accorciato');
    await tester.pumpAndSettle();
    expect(stato(tester).girata, isTrue);
  });

  testWidgets('EO.03: il tocco su un\'arte Premium la apre come oggi',
      (tester) async {
    final aperte = await montaUna(tester, 'synastry_depth');
    await tester.tap(find.byKey(const Key('scheda_tocco_synastry_depth')));
    await tester.pump();
    expect(aperte, ['synastry_depth']);
    expect(find.byKey(const Key('scheda_in_uscita')), findsNothing);
    expect(stato(tester).girata, isFalse);
  });

  // --- EO.04, LA "i" GIRA LA SCHEDA ----------------------------------------

  testWidgets(
      'EO.04: la "i" gira la scheda, lo stesso angolo la rigira, il resto del '
      'retro entra', (tester) async {
    final aperte = await montaUna(tester, 'rune_draw');
    final angolo = angoloInAltoADestra(tester, 'rune_draw');

    await tester.tapAt(angolo);
    await tester.pumpAndSettle();
    expect(stato(tester).girata, isTrue, reason: 'la "i" non gira la scheda');
    expect(find.byKey(const Key('scheda_retro_rune_draw')), findsOneWidget);
    expect(
        find.byKey(const Key('scheda_informazioni_rune_draw')), findsOneWidget,
        reason: 'sul retro non ci sono le informazioni dell\'arte');
    expect(aperte, isEmpty, reason: 'la "i" non deve entrare nell\'arte');

    // Il giro e' in tre dimensioni: a meta' la scheda e' di taglio.
    await tester.tapAt(angolo);
    await tester.pump();
    await tester.pump(LaSchedaDellArte.tempoDelGiro ~/ 2);
    expect(aperte, isEmpty,
        reason: 'sul retro il tocco nell\'angolo in alto a destra e\' entrato '
            'nell\'arte invece di rigirarla');
    // Il Transform del giro e' quello con la prospettiva: a meta' giro il
    // coseno dell'angolo, sulla diagonale, e' vicino a zero.
    final giri = tester
        .widgetList<Transform>(find.descendant(
            of: find.byType(AnimatedScale), matching: find.byType(Transform)))
        .map((t) => t.transform)
        .where((m) => m.entry(3, 2) != 0)
        .toList();
    expect(giri, hasLength(1), reason: 'il giro non ha prospettiva');
    // ignore: avoid_print
    print('EO.04 MISURA: a meta\' giro coseno ${giri.single.entry(0, 0)}');
    expect(giri.single.entry(0, 0).abs(), lessThan(0.5),
        reason: 'a meta\' del tempo la scheda deve essere quasi di taglio');
    await tester.pumpAndSettle();
    expect(stato(tester).girata, isFalse,
        reason: 'sul retro, lo stesso angolo in alto a destra non la rigira');
    expect(aperte, isEmpty,
        reason: 'sul retro il tocco nell\'angolo in alto a destra e\' entrato '
            'nell\'arte invece di rigirarla');

    await tester.tapAt(angolo);
    await tester.pumpAndSettle();
    expect(stato(tester).girata, isTrue);
    await tester.tapAt(
        tester.getCenter(find.byKey(const Key('scheda_tocco_rune_draw'))));
    await tester.pumpAndSettle();
    expect(aperte, ['rune_draw'],
        reason: 'sul retro, un tocco fuori dall\'angolo deve entrare');
  });

  // --- EO.05, LE ARTI IN ARRIVO ---------------------------------------------

  testWidgets(
      'EO.05: al tocco un\'arte in arrivo si gira da sola e dice la sua fase, '
      'e nessuna pagina si apre', (tester) async {
    final aperte = await montaUna(tester, 'pendulum');
    expect(find.byKey(const Key('scheda_clessidra_pendulum')), findsOneWidget);
    await tester.tap(find.byKey(const Key('scheda_tocco_pendulum')));
    await tester.pumpAndSettle();
    expect(stato(tester).girata, isTrue, reason: 'la scheda non si gira');
    expect(
        tester.widget<Text>(find.byKey(const Key('scheda_fase_pendulum'))).data,
        'In arrivo, Fase 2');
    expect(aperte, isEmpty, reason: 'si e\' aperta una pagina');
    await tester.tap(find.byKey(const Key('scheda_tocco_pendulum')));
    await tester.pumpAndSettle();
    expect(stato(tester).girata, isFalse);
    expect(aperte, isEmpty);
  });

  // --- EO.06, IL RIFLESSO DELL'ORO ------------------------------------------

  Future<void> montaRiga(WidgetTester tester, {required bool riduci}) async {
    finestra(tester);
    await tester.pumpWidget(conIlCerchio(
      LaRigaDelleSchede(
        chiave: 'prova',
        titolo: 'Prova',
        formato: FormatoDellaScheda.orizzontale,
        arti: LeRigheDellaCasa.artiDi(LeRigheDellaCasa.righe
            .firstWhere((r) => r.chiave == 'cerca_una_risposta')
            .arti),
      ),
      riduci: riduci,
    ));
    await tester.pump();
  }

  testWidgets(
      'EO.06: il riflesso c\'e\', senza sensore segue la riga, e si spegne con '
      'la riduzione del movimento', (tester) async {
    await montaRiga(tester, riduci: false);
    final riflessi = find.byWidgetPredicate((w) =>
        w.key is ValueKey<String> &&
        (w.key! as ValueKey<String>).value.startsWith('scheda_riflesso_'));
    expect(riflessi, findsWidgets, reason: 'nessun riflesso sulle schede');
    // Il ripiego: senza inclinazione la luce si muove con la riga.
    double luce(double s) => IlRiflessoDellOro.posizione(
        inclinazione: null, scorrimento: s, chiave: 'pendulum');
    final prima = luce(0);
    final dopo = luce(1);
    expect(dopo, isNot(prima),
        reason: 'scorrendo la riga la luce non si muove');

    await montaRiga(tester, riduci: true);
    expect(riflessi, findsNothing,
        reason: 'con la riduzione del movimento il riflesso resta');
  });

  // --- EO.07, LA SCHEDA AL CENTRO SI SOLLEVA --------------------------------

  testWidgets(
      'EO.07: la scheda al centro e\' piu\' grande e piu\' luminosa delle altre, '
      'e con la riduzione del movimento no', (tester) async {
    await montaRiga(tester, riduci: false);
    final posizione = tester
        .state<ScrollableState>(find.descendant(
            of: find.byKey(const Key('riga_scorre_prova')),
            matching: find.byType(Scrollable)))
        .position;
    posizione.jumpTo(200);
    await tester.pump();
    final ombre = <int, double>{};
    final scale = <int, double>{};
    for (final e in find
        .byWidgetPredicate((w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('scheda_ombra_'))
        .evaluate()) {
      final i =
          int.parse((e.widget.key! as ValueKey<String>).value.split('_').last);
      ombre[i] = (e.widget as ColoredBox).color.a;
      final t = e.findAncestorWidgetOfExactType<Transform>()!;
      scale[i] = t.transform.getMaxScaleOnAxis();
    }
    expect(ombre.length, greaterThanOrEqualTo(2),
        reason: 'servono almeno due schede a video per confrontarle');
    final alCentro =
        ombre.keys.reduce((a, b) => ombre[a]! <= ombre[b]! ? a : b);
    // ignore: avoid_print
    print('EO.07 MISURA: ombre $ombre, scale $scale, al centro $alCentro');
    for (final i in ombre.keys.where((i) => i != alCentro)) {
      expect(scale[alCentro]!, greaterThan(scale[i]!),
          reason: 'la scheda al centro non e\' piu\' grande della $i');
      expect(ombre[alCentro]!, lessThan(ombre[i]!),
          reason: 'la scheda al centro non e\' piu\' luminosa della $i');
    }
    expect(scale[alCentro]!, lessThanOrEqualTo(LaRigaDelleSchede.sollevamento),
        reason: 'si ingrandisce appena, non di piu\'');

    await montaRiga(tester, riduci: true);
    expect(
        find.byWidgetPredicate((w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('scheda_ombra_')),
        findsNothing,
        reason: 'con la riduzione del movimento le schede si sollevano ancora');
  });

  // --- EO.09, LE RIGHE DELLA HOME -------------------------------------------

  /// L'elenco del fondatore, **copiato alla lettera dall'ordine EO voce 09**,
  /// coi nomi come li ha scritti lui: si confronta con i titoli a video, non
  /// con gli identificativi, cosi' anche un titolo cambiato nel catalogo
  /// cade qui.
  const elencoDelFondatore = <String, List<String>>{
    'Le arti preferite': [
      'Oroscopo Personalizzato',
      'Stesa di Tarocchi',
      'Estrazione Rune',
      'Sinastria VIP',
      'Meditazione',
      'Mappa del Viso',
    ],
    'Da condividere': [
      'Mappa del Viso',
      'Sinastria VIP',
      'Numeri Ricorrenti',
      "Analisi dell'Aura",
      'Compatibilità tra Amici',
      "Sigillo dell'Intenzione",
      'Affinità Lunare',
      'Numerologia del Destino',
      'Pet Astrology',
    ],
    'Amore e affinità': [
      'Sinastria VIP',
      'Affinità Lunare',
      'Sinastria Approfondita',
      'Compatibilità tra Amici',
      'Pet Astrology',
    ],
    'Cerca una risposta': [
      'Stesa di Tarocchi',
      'Estrazione Rune',
      'Oracolo dei Cristalli',
      'Oracolo degli Angeli',
      'Pendolo',
      'Interpretazione dei Sogni',
      'I-Ching',
      'Lettura dei Fondi di Caffè',
    ],
    'Le stelle parlano': [
      'Oroscopo Personalizzato',
      'Il Respiro della Luna',
      'Destino Narrativo',
      'Pet Astrology',
    ],
    'Conosci te stesso': [
      'Numerologia del Destino',
      'Destino Narrativo',
      'Il Viaggio dello Sciamano',
      'Mood Tracker',
      'Interpretazione dei Sogni',
    ],
    'Il tuo corpo': [
      'Mappa del Viso',
      'Scan dei Chakra',
      "Analisi dell'Aura",
      'Bioritmo',
    ],
    'La tua serenità': [
      'Meditazione',
      'Sleep Stories',
      'Affermazioni del Giorno',
      'Micro-rituali',
      'Mood Tracker',
    ],
    'La tua intenzione': [
      "Sigillo dell'Intenzione",
      'Affermazioni del Giorno',
      'Micro-rituali',
      'Numeri Ricorrenti',
      'Il Viaggio dello Sciamano',
    ],
    'La tua energia': [
      'Scan dei Chakra',
      'Oracolo dei Cristalli',
      "Analisi dell'Aura",
      'Purificazione Energetica',
      'Bioritmo',
    ],
  };

  /// I formati dell'ordine, riga per riga.
  const formatiDelFondatore = <String, FormatoDellaScheda>{
    'Le arti preferite': FormatoDellaScheda.quadrata,
    'Da condividere': FormatoDellaScheda.verticale,
    'Amore e affinità': FormatoDellaScheda.orizzontale,
    'Cerca una risposta': FormatoDellaScheda.verticale,
    'Le stelle parlano': FormatoDellaScheda.orizzontale,
    'Conosci te stesso': FormatoDellaScheda.orizzontale,
    'Il tuo corpo': FormatoDellaScheda.verticale,
    'La tua serenità': FormatoDellaScheda.orizzontale,
    'La tua intenzione': FormatoDellaScheda.orizzontale,
    'La tua energia': FormatoDellaScheda.orizzontale,
  };

  testWidgets('EO.09: righe e schede a video, contro l\'elenco del fondatore',
      (tester) async {
    SharedPreferences.setMockInitialValues(const {});
    finestra(tester);
    final pref = ArtiPreferiteController();
    addTearDown(pref.dispose);
    await tester.pumpWidget(conIlCerchio(
      const SingleChildScrollView(child: LeRigheDellaCasaView(sensore: false)),
      pref: pref,
    ));
    await tester.pump();

    // Le righe, nell'ordine in cui stanno sulla pagina, dall'alto.
    final righe = tester
        .widgetList<LaRigaDelleSchede>(find.byType(LaRigaDelleSchede))
        .toList();
    final titoli = [for (final r in righe) r.titolo];
    final cime = [
      for (final r in righe)
        tester.getTopLeft(find.byKey(Key('riga_${r.chiave}'))).dy
    ];
    for (var i = 1; i < cime.length; i++) {
      expect(cime[i], greaterThan(cime[i - 1]),
          reason: 'la riga "${titoli[i]}" non sta sotto "${titoli[i - 1]}"');
    }
    expect(titoli, elencoDelFondatore.keys.toList(),
        reason: 'le righe della home non sono quelle del fondatore, in '
            'quell\'ordine');
    expect(find.text('Le arti preferite'), findsOneWidget);

    var confrontate = 0;
    for (final r in righe) {
      expect(r.formato, formatiDelFondatore[r.titolo],
          reason: 'la riga "${r.titolo}" ha il formato sbagliato');
      final posizione = tester
          .state<ScrollableState>(find.descendant(
              of: find.byKey(Key('riga_scorre_${r.chiave}')),
              matching: find.byType(Scrollable)))
          .position;
      final aVideo = <String>[];
      final prefisso = 'riga_${r.chiave}_';
      for (var px = 0.0;; px += 120) {
        posizione.jumpTo(px.clamp(0, posizione.maxScrollExtent));
        await tester.pump();
        final qui = <(double, String)>[];
        for (final e in find
            .byWidgetPredicate((w) =>
                w.key is ValueKey<String> &&
                (w.key! as ValueKey<String>).value.startsWith(prefisso))
            .evaluate()) {
          final id = (e.widget.key! as ValueKey<String>)
              .value
              .substring(prefisso.length);
          qui.add((
            tester.getTopLeft(find.byKey(Key('$prefisso$id'))).dx,
            arte(id).title
          ));
        }
        qui.sort((a, b) => a.$1.compareTo(b.$1));
        for (final (_, t) in qui) {
          if (!aVideo.contains(t)) aVideo.add(t);
        }
        if (px >= posizione.maxScrollExtent) break;
      }
      confrontate += aVideo.length;
      expect(aVideo, elencoDelFondatore[r.titolo],
          reason: 'le schede della riga "${r.titolo}" non sono quelle del '
              'fondatore, in quell\'ordine');
    }
    // ignore: avoid_print
    print(
        'EO.09 MISURA: righe ${righe.length} su ${elencoDelFondatore.length}, '
        'schede confrontate $confrontate');
    cardinaleMinimo(confrontate, 50,
        cosa: 'schede delle righe della home',
        perche: 'oggi sono 56, margine dichiarato di sei.');
  });

  test(
      'EO.09: una stessa arte in righe diverse apre sempre la stessa '
      'schermata, perche\' la scheda chiede la rotta al catalogo', () {
    // La scheda apre con `apriLArte`, che chiede `artRouteFor(art.id, ...)`:
    // la rotta dipende solo dall'identificativo, non dalla riga. E le righe
    // della home non passano un'apertura loro.
    final scheda =
        File('lib/features/schede/la_scheda_dell_arte.dart').readAsStringSync();
    expect('artRouteFor('.allMatches(scheda).length, 1);
    expect(scheda, matches(RegExp(r'artRouteFor\(\s*art\.id,')));
    for (final f in [
      'lib/features/santuario/le_righe_della_casa.dart',
      'lib/features/schede/la_riga_delle_schede.dart',
    ]) {
      expect(File(f).readAsStringSync(), isNot(contains('onApri:')),
          reason: '$f passa alla scheda un\'apertura sua');
    }
  });
}
