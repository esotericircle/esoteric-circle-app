import 'dart:io';

import 'package:esoteric_circle/core/archetypes/archetype_history.dart';
import 'package:esoteric_circle/core/astro/night_sky.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/rituals/animal_constellations.dart';
import 'package:esoteric_circle/design_system/components/zodiac_figures.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:esoteric_circle/features/maestri/caligo/animal/guide_animal_screen.dart';
import 'package:esoteric_circle/features/rituals/dawn_rite_screen.dart';
import 'package:esoteric_circle/features/rituals/dream_rite_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL RESPONSO SI LEGGE OVUNQUE, NON SOLO DA MEDORA. Ordine BV voce 06.
///
/// **Parole del fondatore sulla build 2209**: "il testo del consiglio di Medora
/// adesso va bene, applica lo stesso standard a tutti gli altri responsi".
///
/// Lo standard nato con l'ordine BU sul consiglio di Medora e' fatto di quattro
/// cose: **misura di lettura** invece della misura del corpo, **colore
/// primario** invece dell'oro o del secondario, **paragrafi separati** dalla
/// porta unica invece di un blocco solo, **titolo oro** sopra. Qui si enumerano
/// gli otto responsi dell'app e si misura che ognuno lo rispetti, e per le
/// schermate che questa voce ha toccato si misura anche che niente esca dallo
/// schermo, sul telefono di riferimento e su uno piu' piccolo.
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  void silenzia() {
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

  Widget attorno(Widget scena, {Maestro maestro = Maestro.medora}) =>
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (_) => MaestroController(initial: ThemeKey.of(maestro))),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
          // LO STORICO DELL'ARCHETIPO, che l'Animale Guida pretende dal
          // contesto: senza, la schermata non costruisce niente.
          ChangeNotifierProvider(create: (_) => ArchetypeHistory()..carica()),
        ],
        child: MaterialApp(
          builder: (ctx, child) => MediaQuery(
            data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
            child: MaestroScope(child: child!),
          ),
          home: scena,
        ),
      );

  void schermo(WidgetTester tester, double altezza) {
    tester.view.physicalSize = Size(360, altezza);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> passo(WidgetTester tester) async {
    await tester.pump();
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  /// Tocca un bersaglio SOLO se c'e'. Montando due volte la stessa schermata
  /// il rito puo' risultare gia' compiuto, e allora il passo non esiste piu':
  /// pretenderlo farebbe cadere la prova su un difetto che non c'e'.
  Future<bool> seCeTocca(WidgetTester tester, Key chiave) async {
    if (find.byKey(chiave).evaluate().isEmpty) return false;
    await tester.tap(find.byKey(chiave));
    return true;
  }

  /// I due schermi su cui si giudica: il telefono di riferimento e uno piu'
  /// piccolo, quello su cui un testo cresciuto si vede uscire per primo.
  const schermi = [797.0, 640.0];

  group('BV.06, lo standard del responso su tutte le schermate', () {
    test('Gli otto responsi portano la misura e il colore della lettura', () {
      // **L'ENUMERAZIONE, non la visita.** Gli otto responsi si dichiarano qui
      // con il punto esatto in cui vivono: se domani ne nasce un nono e nessuno
      // lo aggiunge, questa riga non se ne accorge, ed e' una sorveglianza in
      // meno DICHIARATA. Cio' che invece non puo' succedere e' che uno degli
      // otto scenda di misura senza che la prova cada.
      const responsi = {
        'l\'Oroscopo': (
          'lib/features/horoscope/oroscopo_screen.dart',
          'final TextStyle stileDelResponso =',
        ),
        'la Sinastria': (
          'lib/features/synastry/sinastria_vip_screen.dart',
          'key: const Key(\'sinastria_eredita\'),',
        ),
        // **IL PUNTO DELLE RUNE ERA SBAGLIATO, ordine CQ voce 6.27 del 5
        // settembre 2026.** Puntava a `gettata.testoDinamico`, che non e\'
        // il responso: e\' la MATERIA STORICA della gettata, Tacito e
        // l\'Edda, cioe\' il testo che il fondatore ha fatto togliere da
        // davanti al gesto. Il responso delle Rune e\' il PRESAGIO, e
        // arriva dopo il getto.
        //
        // Spostando la materia dietro la porta questa riga e\' caduta
        // dicendo "non si trova piu\' il punto dichiarato", ed e\' stata
        // lei a far vedere che sorvegliava la cosa sbagliata: **una
        // guardia che punta al pezzo accanto**, la stessa famiglia che
        // il conto delle ore ha contato sette volte su sette.
        'le Rune': (
          'lib/features/maestri/caligo/rune/rune_draw_screen.dart',
          'key: const Key(\'rune_presage_text\'),',
        ),
        'gli Angeli': (
          'lib/features/angels/angels_screen.dart',
          'testo: lore.reading,',
        ),
        'l\'Archetipo': (
          'lib/features/maestri/aura/archetype/archetype_test_screen.dart',
          'testo: ritratto.essenza,',
        ),
        'l\'Animale Guida': (
          'lib/features/maestri/caligo/animal/guide_animal_screen.dart',
          'key: const Key(\'animal_message_text\'),',
        ),
        'il Sogno': (
          'lib/features/rituals/dream_rite_screen.dart',
          'key: const Key(\'dream_message\'),',
        ),
        'l\'Alba': (
          'lib/features/rituals/ritual_gift_card.dart',
          'key: const Key(\'alba_orientamento\'),',
        ),
      };
      // I colori ammessi per un responso: il primario dell'app e l'inchiostro
      // della carta stampata, che del suo foglio e' il primario.
      const coloriDelResponso = ['ColorTokens.textPrimary', 'abito.inchiostro'];
      final fuoriStandard = <String>[];
      final detti = <String>[];
      responsi.forEach((nome, dove) {
        final righe = File(dove.$1).readAsStringSync().split('\n');
        final i = righe.indexWhere((r) => r.contains(dove.$2));
        if (i < 0) {
          fuoriStandard.add('$nome: non si trova piu\' il punto dichiarato');
          return;
        }
        final finestra =
            righe.sublist(i, (i + 9).clamp(0, righe.length)).join('\n');
        final misura = finestra.contains('TypographyTokens.lettura()');
        final colore = coloriDelResponso.any(finestra.contains);
        detti.add('$nome ${misura ? "lettura" : "SOTTO MISURA"} e '
            '${colore ? "primario" : "COLORE SBAGLIATO"}');
        if (!misura || !colore) {
          fuoriStandard.add('$nome (${dove.$1}, riga ${i + 1})');
        }
      });
      // ignore: avoid_print
      print('ORDINE BV VOCE 6: gli otto responsi -> ${detti.join("; ")}');
      expect(fuoriStandard, isEmpty,
          reason: 'questi responsi non portano lo standard del consiglio di '
              'Medora: $fuoriStandard');
    });

    test('Sette responsi su otto passano dalla porta unica', () {
      // **L'ECCEZIONE E' UNA SOLA E SI DICHIARA.** L'Oroscopo scrive a
      // macchina e chiama `spezzaInParagrafi` da se', ed e' l'eccezione che la
      // guardia di casa gia' conosce; la carta dell'Alba e' un oggetto
      // stampato, dove spezzare cambierebbe l'ingombro. Gli altri sei passano
      // tutti da `ParagrafiDiLettura`.
      const conLaPorta = {
        'la Sinastria': 'lib/features/synastry/sinastria_vip_screen.dart',
        'le Rune': 'lib/features/maestri/caligo/rune/rune_draw_screen.dart',
        'gli Angeli': 'lib/features/angels/angels_screen.dart',
        'l\'Archetipo':
            'lib/features/maestri/aura/archetype/archetype_test_screen.dart',
        'l\'Animale Guida':
            'lib/features/maestri/caligo/animal/guide_animal_screen.dart',
        'il Sogno': 'lib/features/rituals/dream_rite_screen.dart',
      };
      final senzaPorta = <String>[];
      conLaPorta.forEach((nome, file) {
        if (!File(file).readAsStringSync().contains('ParagrafiDiLettura(')) {
          senzaPorta.add(nome);
        }
      });
      // E l'Oroscopo, che la porta la usa dal di dentro.
      final oroscopo = File('lib/features/horoscope/oroscopo_screen.dart')
          .readAsStringSync();
      // ignore: avoid_print
      print('ORDINE BV VOCE 6: responsi dalla porta unica '
          '${conLaPorta.length - senzaPorta.length} su ${conLaPorta.length}, '
          'piu\' l\'Oroscopo che spezza col metodo comune: '
          '${oroscopo.contains('spezzaInParagrafi(')}');
      expect(senzaPorta, isEmpty,
          reason: 'questi responsi si spezzano per conto loro: $senzaPorta');
      expect(oroscopo.contains('spezzaInParagrafi('), isTrue,
          reason: 'l\'Oroscopo ha smesso di usare la regola comune dei '
              'paragrafi e se ne e\' scritta una propria');
    });
  });

  group('BV.06, niente esce dallo schermo dove il testo e\' cresciuto', () {
    testWidgets('Il Messaggio dell\'Animale Guida sta dentro', (tester) async {
      for (final altezza in schermi) {
        SharedPreferences.setMockInitialValues(const {});
        silenzia();
        schermo(tester, altezza);
        await tester.pumpWidget(attorno(
            const GuideAnimalScreen(
                userSign: Zodiac.cancer, modo: GuideAnimalMode.viaggio),
            maestro: Maestro.caligo));
        await passo(tester);
        await seCeTocca(tester, const Key('animal_popup_reveal'));
        await passo(tester);
        final figura = costellazioneDi('Lupo').figura;
        for (var i = 0; i < figura.punti.length; i++) {
          if (!await seCeTocca(tester, Key('animal_star_$i'))) break;
          await tester.pump(const Duration(milliseconds: 60));
        }
        await passo(tester);
        await passo(tester);
        final guaio = tester.takeException();
        expect(find.byKey(const Key('animal_message_text')), findsOneWidget,
            reason: 'a ${altezza.toStringAsFixed(0)} punti di altezza il '
                'messaggio del giorno non arriva in scena');
        // ignore: avoid_print
        print('ORDINE BV VOCE 6: Animale Guida su 360 per '
            '${altezza.toStringAsFixed(0)}, traboccamenti '
            '${guaio ?? "nessuno"}');
        expect(guaio, isNull,
            reason: 'col messaggio alla misura di lettura la schermata '
                'dell\'Animale Guida trabocca su 360 per $altezza: $guaio');
      }
    });

    testWidgets('Il saluto del Sogno sta dentro', (tester) async {
      final quando = DateTime(2026, 7, 13, 22, 40);
      for (final altezza in schermi) {
        silenzia();
        schermo(tester, altezza);
        await tester.pumpWidget(attorno(DreamRiteScreen(now: quando)));
        await passo(tester);
        await seCeTocca(tester, const Key('dream_fog_skip'));
        await passo(tester);
        final segno = NightSky.moonSign(quando);
        final figura = kZodiacConstellations.firstWhere((c) => c.sign == segno);
        for (var i = 0; i < figura.points.length; i++) {
          if (!await seCeTocca(tester, Key('dream_star_$i'))) break;
          await tester.pump(const Duration(milliseconds: 60));
        }
        await tester.pump(const Duration(milliseconds: 1000));
        await passo(tester);
        final guaio = tester.takeException();
        expect(find.byKey(const Key('dream_message')), findsOneWidget,
            reason: 'a ${altezza.toStringAsFixed(0)} punti di altezza il '
                'saluto della notte non arriva in scena');
        // ignore: avoid_print
        print('ORDINE BV VOCE 6: Sogno su 360 per '
            '${altezza.toStringAsFixed(0)}, traboccamenti '
            '${guaio ?? "nessuno"}');
        expect(guaio, isNull,
            reason: 'col saluto alla misura di lettura il rito del Sogno '
                'trabocca su 360 per $altezza: $guaio');
      }
    });

    testWidgets('Il dono dell\'Alba sta dentro la sua carta', (tester) async {
      for (final altezza in schermi) {
        silenzia();
        schermo(tester, altezza);
        await tester
            .pumpWidget(attorno(DawnRiteScreen(now: DateTime(2026, 7, 13, 7))));
        await tester.pump();
        await seCeTocca(tester, const Key('ritual_gesture'));
        for (var i = 0; i < 12; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
        final guaio = tester.takeException();
        expect(find.byKey(const Key('alba_orientamento')), findsOneWidget,
            reason: 'a ${altezza.toStringAsFixed(0)} punti di altezza '
                'l\'orientamento del giorno non arriva in scena');
        final testo =
            tester.widget<Text>(find.byKey(const Key('alba_orientamento')));
        // ignore: avoid_print
        print('ORDINE BV VOCE 6: Alba su 360 per '
            '${altezza.toStringAsFixed(0)}, orientamento a '
            '${testo.style!.fontSize} punti, traboccamenti '
            '${guaio ?? "nessuno"}');
        expect(testo.style!.fontSize, TypographyTokens.lettura().fontSize,
            reason: 'l\'orientamento del giorno non e\' alla misura di '
                'lettura');
        expect(guaio, isNull,
            reason: 'con l\'orientamento alla misura di lettura la carta '
                'dell\'Alba trabocca su 360 per $altezza: $guaio');
      }
    });
  });

  test('BV.06: le due schermate col solo colore cambiato non si spostano', () {
    // **UN COLORE NON MUOVE UN PIXEL**, e vale la pena dirlo invece di
    // montare due schermate per scoprirlo: agli Angeli e all'Archetipo e'
    // cambiato soltanto il colore del testo, la misura era gia' quella di
    // lettura. Qui si verifica proprio questo, che la misura non sia stata
    // toccata insieme al colore.
    const misurate = {
      'gli Angeli': 'lib/features/angels/angels_screen.dart',
      'l\'Archetipo':
          'lib/features/maestri/aura/archetype/archetype_test_screen.dart',
    };
    final sbagliate = <String>[];
    misurate.forEach((nome, file) {
      final s = File(file).readAsStringSync();
      if (!s.contains('TypographyTokens.lettura()')) sbagliate.add(nome);
    });
    // ignore: avoid_print
    print('ORDINE BV VOCE 6: schermate col solo colore cambiato '
        '${misurate.keys.join(" e ")}, misura ancora di lettura: '
        '${sbagliate.isEmpty}');
    expect(sbagliate, isEmpty,
        reason: 'qui doveva cambiare solo il colore, e invece e\' cambiata '
            'anche la misura: $sbagliate');
  });
}
