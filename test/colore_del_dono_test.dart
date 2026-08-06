import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:esoteric_circle/core/rituals/dawn_gift.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/features/rituals/ritual_gift_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA PROVA DELLA VOCE 2: il colore della scheda nasce dal Maestro del giorno.
void main() {
  /// Il vetro della bolla, reso opaco: e' contro questo che si misura la
  /// leggibilita', perche' la scheda compare a gesto completato, cioe' a luce
  /// piena.
  const vetro = Color(0xFFFBF4E2);

  double _canale(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();

  double luminanza(Color c) =>
      0.2126 * _canale(c.r) + 0.7152 * _canale(c.g) + 0.0722 * _canale(c.b);

  double contrasto(Color a, Color b) {
    final la = luminanza(a);
    final lb = luminanza(b);
    final chiaro = la > lb ? la : lb;
    final scuro = la > lb ? lb : la;
    return (chiaro + 0.05) / (scuro + 0.05);
  }

  /// Monta la scheda per un Maestro e torna il colore della parola del giorno,
  /// che e' l'accento piu' grande e quindi il piu' facile da leggere a video.
  Future<Color> accentoMostrato(WidgetTester tester, Maestro maestro) async {
    final gift = DawnGift.forMaestro(DateTime(2026, 8, 6), maestro);
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: RitualGiftCard(
              gift: gift,
              dono: DailyElement.dawn,
              giorno: DateTime(2026, 8, 6),
              streak: 3,
              onShare: () {}),
      ),
    ));
    await tester.pump();
    // La parola del giorno: e' il Text con lo stile display piu' grande.
    final parola = tester
        .widgetList<Text>(find.byType(Text))
        .where((t) => (t.style?.fontSize ?? 0) >= 32)
        .toList();
    expect(parola, isNotEmpty,
        reason: 'la parola del giorno non e\' a schermo, quindi questa prova '
            'non sta misurando il colore che crede');
    return parola.first.style!.color!;
  }

  group('Il colore nasce dal Maestro del giorno', () {
    testWidgets('i tre Maestri danno tre accenti diversi', (tester) async {
      final visti = <Maestro, Color>{};
      for (final m in Maestro.values) {
        visti[m] = await accentoMostrato(tester, m);
      }
      expect(visti.values.toSet(), hasLength(3),
          reason: 'due Maestri danno lo stesso accento: la scheda non dice piu\' '
              'di chi e\' il giorno');
    });

    testWidgets('l\'accento tiene la tinta del suo Maestro', (tester) async {
      // Non basta che siano diversi: devono essere IL colore giusto. Si
      // confronta il canale dominante con quello della palette del Maestro.
      for (final m in Maestro.values) {
        final accento = await accentoMostrato(tester, m);
        final base = MaestroPalette.forKey(ThemeKey.of(m)).primary;
        int dominante(Color c) {
          if (c.r >= c.g && c.r >= c.b) return 0;
          if (c.g >= c.r && c.g >= c.b) return 1;
          return 2;
        }

        expect(dominante(accento), dominante(base),
            reason: '${m.name}: l\'accento non tiene la tinta della sua '
                'palette');
      }
    });

    testWidgets('ogni accento si legge sul vetro chiaro', (tester) async {
      // E' la ragione per cui esiste una regola sola invece di tre colori
      // scelti a mano: il verde di Aura, preso com'e', starebbe sotto soglia.
      for (final m in Maestro.values) {
        final accento = await accentoMostrato(tester, m);
        final c = contrasto(accento, vetro);
        expect(c, greaterThanOrEqualTo(4.5),
            reason: '${m.name}: contrasto ${c.toStringAsFixed(2)} sul vetro, '
                'sotto la soglia che rende leggibile un testo');
      }
    });

    testWidgets('il verde di Aura e\' stato scurito, gli altri due no',
        (tester) async {
      // La regola non deve toccare chi gia' passa: se scurisse tutti, il blu e
      // il rosso perderebbero forza senza motivo.
      for (final m in [Maestro.medora, Maestro.caligo]) {
        final accento = await accentoMostrato(tester, m);
        expect(accento, MaestroPalette.forKey(ThemeKey.of(m)).primary,
            reason: '${m.name} passava gia\' la soglia e non andava toccato');
      }
      final aura = await accentoMostrato(tester, Maestro.aura);
      final auraBase = MaestroPalette.forKey(ThemeKey.of(Maestro.aura)).primary;
      expect(aura, isNot(auraBase),
          reason: 'il verde di Aura non e\' stato scurito, quindi resta '
              'illeggibile');
      expect(contrasto(auraBase, vetro), lessThan(4.5),
          reason: 'se il verde di partenza passasse gia\', questa prova non '
              'starebbe verificando niente');
    });

    testWidgets('il testo NON si tinge, resta l\'inchiostro scuro',
        (tester) async {
      // Tingere l'inchiostro peggiorerebbe la lettura senza dire niente di
      // piu': il Maestro si vede negli accenti, non nel corpo del testo.
      const inchiostro = Color(0xFF2A2213);
      final corpi = <Color>{};
      for (final m in Maestro.values) {
        final gift = DawnGift.forMaestro(DateTime(2026, 8, 6), m);
        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: RitualGiftCard(
              gift: gift,
              dono: DailyElement.dawn,
              giorno: DateTime(2026, 8, 6),
              streak: 3,
              onShare: () {}),
          ),
        ));
        await tester.pump();
        final corpo = tester
            .widgetList<Text>(find.byType(Text))
            .where((t) => (t.style?.fontSize ?? 0) == 16)
            .toList();
        expect(corpo, isNotEmpty);
        corpi.add(corpo.first.style!.color!);
      }
      expect(corpi, hasLength(1),
          reason: 'il corpo del testo cambia col Maestro: si sta tingendo '
              'l\'inchiostro');
      expect(corpi.first, inchiostro);
    });
  });

  group('Un punto solo decide quel colore', () {
    test('nessun altro punto in lib deriva l\'accento della scheda', () {
      // Se un secondo punto decidesse questo colore, prima o poi i due
      // direbbero cose diverse e nessuno saprebbe quale comanda.
      const laPorta = 'lib/features/rituals/ritual_gift_card.dart';

      final definizioni = <String>[];
      final colpevoli = <String>[];
      for (final f in Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))) {
        final percorso = f.path.replaceAll(r'\', '/');
        final relativo = percorso.substring(percorso.indexOf('lib/'));
        final testo = f.readAsStringSync();
        for (final _ in RegExp(r'Color\s+_accentoDi\s*\(').allMatches(testo)) {
          definizioni.add(relativo);
        }
        if (relativo == laPorta) continue;
        // Nessun altro file deve costruire la scheda passandole un colore, ne
        // derivare una palette per lei.
        if (testo.contains('RitualGiftCard(') &&
            RegExp(r'RitualGiftCard\([^)]*(accento|palette)')
                .hasMatch(testo)) {
          colpevoli.add('$relativo: passa un colore alla scheda');
        }
      }
      expect(definizioni, [laPorta],
          reason: 'l\'accento si deriva in piu\' di un punto: $definizioni');
      expect(colpevoli, isEmpty,
          reason: 'qualcuno passa il colore da fuori: $colpevoli');
    });

    test('la scheda non accetta un colore dall\'esterno', () {
      // Se il costruttore lo accettasse, il secondo punto sarebbe possibile
      // anche senza che nessuno lo usi ancora.
      final sorgente =
          File('lib/features/rituals/ritual_gift_card.dart').readAsStringSync();
      final costruttore = sorgente.substring(
        sorgente.indexOf('const RitualGiftCard('),
        sorgente.indexOf('final DawnGift gift;'),
      );
      for (final vietato in ['accento', 'palette', 'Color']) {
        expect(costruttore.contains(vietato), isFalse,
            reason: 'il costruttore della scheda accetta "$vietato": e\' la '
                'porta da cui entrerebbe il secondo punto');
      }
    });
  });

  group("L'accento arriva a schermo, e non solo nello stile", () {
    // LA FAMIGLIA DI DIFETTO CHE QUESTO GRUPPO TIENE CHIUSA, e che le prove qui
    // sopra NON prendevano.
    //
    // Le etichette dei due pulsanti della scheda esistevano nel codice e a
    // schermo non comparivano. Non era contrasto: la misura l'ha fatta Mauro
    // ritagliando la zona dei pulsanti dallo screenshot e spingendo il
    // contrasto al massimo, e il bordo usciva nero netto mentre dentro non
    // emergeva nessun glifo. Se il testo ci fosse stato a contrasto basso, lo
    // stesso trattamento che ha rivelato il bordo avrebbe rivelato le lettere.
    //
    // La causa era un ALPHA A UNO SU 255. Il colore si scuriva con
    // `Color.fromARGB`, che vuole interi da zero a 255, e i tre canali di
    // colore glieli si passava moltiplicati per 255 mentre l'alpha no, perche'
    // `colore.a` vale gia' 1.0. Due sistemi di unita' nella stessa chiamata.
    // Il bordo si salvava perche' si costruisce con `withValues(alpha: 0.5)`,
    // che l'alpha lo riscrive.
    //
    // Mordeva SOLO Aura: blu e rosso passano la soglia al primo giro e tornano
    // prima di percorrere quella riga.
    //
    // E le prove qui sopra restavano verdi perche' misuravano i CANALI del
    // colore, non cio' che arriva allo schermo: la formula del contrasto legge
    // rosso, verde e blu, e un colore del tutto trasparente le passa uguale.

    testWidgets('nessun accento arriva trasparente, per nessuno dei tre',
        (tester) async {
      for (final m in Maestro.values) {
        final accento = await accentoMostrato(tester, m);
        expect(accento.a, 1.0,
            reason: 'l accento di ${m.id} arriva con alpha ${accento.a}: '
                'dipinto cosi non si vede, e la prova del contrasto non se ne '
                'accorge perche guarda i canali e non la trasparenza');
      }
    });

    testWidgets('dove c e un etichetta, qualcosa si dipinge davvero',
        (tester) async {
      // La prova sul FATTO, quella che avrebbe preso il difetto anche senza
      // sapere che c entrava l alpha: si guarda il riquadro del pulsante e si
      // conta quanti colori distinti contiene. Con le lettere ce ne sono
      // molti; senza, il riquadro e' una tinta piatta.
      tester.view.physicalSize = const Size(360, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final chiave = GlobalKey();
      final gift = DawnGift.forMaestro(DateTime(2026, 8, 6), Maestro.aura);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RepaintBoundary(
              key: chiave,
              child: RitualGiftCard(
              gift: gift,
              dono: DailyElement.dawn,
              giorno: DateTime(2026, 8, 6),
              streak: 4,
              onShare: () {}),
            ),
          ),
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      final img = await tester.runAsync(() async =>
          (chiave.currentContext!.findRenderObject() as RenderRepaintBoundary)
              .toImage(pixelRatio: 1.0));
      final dati = await tester
          .runAsync(() => img!.toByteData(format: ui.ImageByteFormat.rawRgba));
      final b = dati!.buffer.asUint8List();
      final larghezza = img!.width;
      final origine = tester.getRect(find.byKey(chiave));

      for (final k in const ['gift_base_toggle', 'gift_share_word']) {
        final f = find.byKey(Key(k));
        expect(f, findsOneWidget, reason: 'il pulsante $k non e a schermo');
        final r = tester.getRect(f).translate(-origine.left, -origine.top);
        final colori = <int>{};
        for (var y = r.top.round(); y < r.bottom.round(); y++) {
          for (var x = r.left.round(); x < r.right.round(); x++) {
            final i = (y * larghezza + x) * 4;
            if (i + 3 >= b.length) continue;
            colori.add((b[i] << 16) | (b[i + 1] << 8) | b[i + 2]);
          }
        }
        expect(colori.length, greaterThan(3),
            reason: 'il riquadro di $k contiene ${colori.length} colori '
                'distinti: e una tinta piatta, cioe un pulsante vuoto. '
                'L etichetta esiste nel codice e non arriva alla resa');
      }
    });
  });
}
