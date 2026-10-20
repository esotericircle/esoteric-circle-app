// ignore_for_file: avoid_print
import 'dart:io';

import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/responsi/i_riti_propiziatori.dart';
import 'package:esoteric_circle/core/responsi/la_forma_del_responso.dart';
import 'package:esoteric_circle/core/tarot/la_chiave_di_lettura.dart';
import 'package:esoteric_circle/core/tarot/la_lettura_dal_modello.dart';
import 'package:esoteric_circle/core/tarot/le_carte_nella_posizione.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/core/tarot/tarot_reading.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread_type.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/design_system/components/riquadro_in_evidenza.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/horoscope/answer_depth.dart';
import 'package:esoteric_circle/features/tarot/stesa_tre_carte_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'cardinale_minimo.dart';
import 'la_lettura_finta_della_stesa.dart';

/// **LA STESA HA LA FORMA NUOVA.** Ordine GA voci GA.03, GA.04, GA.05 e
/// GA.07, 20 ottobre 2026.
///
/// Il fondatore, 19 ottobre 2026 alle 23:08: *"tutte le risposte composte da
/// paragrafi ognuno con tra 40 a 50 parole ognuno. Per le risposte brevi 2
/// paragrafi di cui il secondo messo in evidenza in un riquadro e questo
/// riquadro deve intitolarsi 'cosa fare adesso' [...] Per le risposte lunghe
/// aggiungi 2 paragrafi sempre con il primo in riquadro. Sotto sempre il
/// paragrafo in corsivo 'da dove viene'. Restano all'inizio i titoli, anche
/// per le singola carte"*; 20 ottobre 2026 alle 00:10, *"Profondità lunga
/// [...] solo per il responso principale e non per le singole carte"*; e la
/// decisione del 20 ottobre, "Carte dal corpus": in ogni stesa le singole
/// carte vengono dal corpus e il modello scrive il solo responso principale.
///
/// Si misura, per le stese da 1, 3, 4 e 10 carte, Breve e Lunga, col modello
/// finto e senza: ogni carta e il responso principale senza difetti di forma
/// (`ResponsoInterpretato.difetti`), la contemplazione propiziatoria della
/// carta principale dal corpus dei riti, il "Da dove viene" uno solo; sul
/// corpus intero, ogni responso di carta possibile (carta, verso, posizione,
/// variante e ambito); nell'istruzione al modello, la forma comune una volta
/// sola. Nessuna chiamata vera (regola SPESE).
void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  group('le stese da 1, 3, 4 e 10 carte, Breve e Lunga', () {
    test('ogni carta e il responso principale hanno la forma di GA.03', () {
      final guasti = <String>[];
      var principali = 0, carte = 0, lunghe = 0;
      for (final tipo in TarotSpreadType.values) {
        for (final topic in TarotTopic.values) {
          for (var seme = 0; seme < 3; seme++) {
            final s = TarotSpread.draw(
                seed: seme * 41 + topic.index, posizioni: tipo.posizioni);
            for (final depth in [AnswerDepth.breve, AnswerDepth.profonda]) {
              final lunga = depth == AnswerDepth.profonda;
              for (final dalModello in [
                null,
                letturaFinta(s, lunga: lunga),
              ]) {
                final r = TarotReading.of(s, topic,
                    depth: depth,
                    dalModello: dalModello,
                    mazzo: 'Rider-Waite',
                    nomeDellaStesa: tipo.nome);
                final dove = '${tipo.name} ${topic.name} seme $seme '
                    '${depth.name} ${dalModello == null ? 'di casa' : 'dal '
                        'modello'}';
                principali++;
                for (final d in r.principale.difetti()) {
                  guasti.add('$dove: $d');
                }
                // La Lunga solo col modello e solo nel responso principale.
                final attesaLunga = lunga && dalModello != null;
                if (r.principale.lungo != attesaLunga) {
                  guasti.add('$dove: lunga ${r.principale.lungo}, attesa '
                      '$attesaLunga');
                }
                if (attesaLunga) {
                  lunghe++;
                  final chiave = TarotReading.chiaveDi(s).drawn;
                  if (r.principale.rito !=
                      LeCarteNellaPosizione.contemplazioneDi(chiave)) {
                    guasti.add('$dove: il rito non e\' la contemplazione '
                        'della carta chiave ${chiave.displayName}');
                  }
                  if (!r.fonte.contains(
                      LeCarteNellaPosizione.fonteDellaContemplazione(
                          chiave)!)) {
                    guasti.add('$dove: il "Da dove viene" non dice la fonte '
                        'della contemplazione');
                  }
                }
                // Il "Da dove viene" e' uno: nomina ogni carta, una volta.
                if ('Le carte uscite:'.allMatches(r.fonte).length != 1) {
                  guasti.add('$dove: il "Da dove viene" non e\' uno solo');
                }
                for (final c in s.cards) {
                  if (!r.fonte.contains(c.displayName)) {
                    guasti.add('$dove: il "Da dove viene" non nomina '
                        '${c.displayName}');
                  }
                }
                for (final p in r.posizioni) {
                  carte++;
                  for (final d in p.responso!.difetti(conLaFonte: false)) {
                    guasti.add('$dove, ${p.drawn.displayName}: $d');
                  }
                  if (p.responso!.lungo || p.responso!.daDoveViene != null) {
                    guasti.add('$dove, ${p.drawn.displayName}: la carta e\' '
                        'lunga o ha il suo "Da dove viene"');
                  }
                }
                // La stesa a una carta: il responso principale di casa e'
                // quello della carta, senza un secondo blocco.
                if (tipo == TarotSpreadType.unaCarta && dalModello == null) {
                  final c = r.posizioni.single.responso!;
                  if (r.principale.titolo != c.titolo ||
                      r.principale.risposta != c.risposta ||
                      r.principale.cosaFare != c.cosaFare) {
                    guasti.add('$dove: il responso di casa della carta sola '
                        'non e\' quello della carta');
                  }
                }
              }
            }
          }
        }
      }
      cardinaleMinimo(principali, 4 * 16 * 3 * 2 * 2,
          cosa: 'responsi principali',
          perche: 'quattro stese, sedici argomenti, tre semi, due '
              'profondita\', col modello e senza');
      cardinaleMinimo(carte, 1700, cosa: 'responsi di carta');
      cardinaleMinimo(lunghe, 4 * 16 * 3, cosa: 'responsi Lunghi');
      print('ORDINE GA: responsi principali $principali, Lunghi $lunghe, '
          'carte $carte, difetti ${guasti.length}');
      expect(guasti, isEmpty, reason: guasti.take(8).join('\n'));
    });
  });

  group('il corpus intero', () {
    test('ogni responso di carta possibile ha la forma di GA.03', () {
      final guasti = <String>[];
      var responsi = 0;
      for (final p in SpreadPosition.values) {
        for (final c in TarotDeck.cards) {
          for (final rovesciata in const [false, true]) {
            final d = DrawnCard(card: c, position: p, reversed: rovesciata);
            final titolo = LeCarteNellaPosizione.titoloDi(d);
            final n = LaFormaDelResponso.parole(titolo);
            if (n < 3 || n > 8 || titolo.endsWith('.')) {
              guasti.add('${LeCarteNellaPosizione.chiaveDi(d)}: il titolo '
                  '"$titolo"');
            }
            for (final g in TarotTopicGroup.values) {
              for (var uscita = 0; uscita < 3; uscita++) {
                responsi++;
                final r =
                    LeCarteNellaPosizione.responsoDi(d, g, uscita: uscita);
                for (final difetto in r.difetti(conLaFonte: false)) {
                  guasti.add('${LeCarteNellaPosizione.chiaveDi(d)} '
                      '${g.name} uscita $uscita: $difetto');
                }
              }
            }
          }
        }
      }
      cardinaleMinimo(responsi, 21060,
          cosa: 'responsi di carta',
          perche: 'quindici posizioni, settantotto carte, due versi, tre '
              'ambiti, tre varianti');
      print('ORDINE GA: responsi di carta dal corpus $responsi, difetti '
          '${guasti.length}');
      expect(guasti, isEmpty, reason: guasti.take(8).join('\n'));
    });

    test('la stessa carta che torna non ripete il suo riquadro', () {
      var guardate = 0;
      final uguali = <String>[];
      for (final c in TarotDeck.cards) {
        for (final rovesciata in const [false, true]) {
          final d = DrawnCard(
              card: c, position: SpreadPosition.presente, reversed: rovesciata);
          for (final g in TarotTopicGroup.values) {
            guardate++;
            final tre = [
              for (var u = 0; u < 3; u++)
                LeCarteNellaPosizione.cosaFareDi(d, g, uscita: u)
            ];
            if (tre.toSet().length != 3) {
              uguali.add('${c.name} ${g.name}');
            }
          }
        }
      }
      cardinaleMinimo(guardate, 468, cosa: 'carte, versi e ambiti');
      expect(uguali, isEmpty, reason: uguali.take(6).join('\n'));
    });

    test('la contemplazione di ogni carta e verso ha la misura e la fonte', () {
      final guasti = <String>[];
      var riti = 0;
      for (final c in TarotDeck.cards) {
        for (final rovesciata in const [false, true]) {
          final d = DrawnCard(
              card: c, position: SpreadPosition.presente, reversed: rovesciata);
          final rito = LeCarteNellaPosizione.contemplazioneDi(d);
          if (rito == null) {
            guasti.add('${d.displayName}: manca il rito');
            continue;
          }
          riti++;
          if (!LaFormaDelResponso.aMisura(rito)) {
            guasti.add('${d.displayName}: il rito ha '
                '${LaFormaDelResponso.parole(rito)} parole');
          }
          if (LeCarteNellaPosizione.fonteDellaContemplazione(d) == null) {
            guasti.add('${d.displayName}: il rito non ha la sua fonte');
          }
        }
      }
      cardinaleMinimo(riti, 156,
          cosa: 'contemplazioni', perche: 'settantotto carte per due versi');
      expect(
          IRitiPropiziatori.fonte(IRitiPropiziatori.contemplazione, const []),
          contains('Golden Dawn'));
      expect(guasti, isEmpty, reason: guasti.take(6).join('\n'));
    });
  });

  group('l\'istruzione al modello', () {
    test('la forma comune sta nell\'istruzione una volta sola', () {
      var istruzioni = 0;
      for (final forma in CourtesyForm.values) {
        for (final chiave in ReadingKey.values) {
          for (final profonda in const [false, true]) {
            istruzioni++;
            final i = LaLetturaDellaStesa.istruzione(forma,
                chiave: chiave, profonda: profonda);
            final forme =
                LaFormaDelResponso.intestazioneDelModello.allMatches(i).length;
            expect(forme, 1,
                reason: '${forma.name} ${chiave.name} profonda $profonda: '
                    'la forma comune compare $forme volte');
            expect(
                i,
                contains(LaFormaDelResponso.perIlModello(
                    arte: ArteInterpretata.tarocchi, lunga: profonda)));
            // La misura si dice in un punto solo: nessun'altra riga
            // dell'istruzione della stesa la riscrive.
            const misura = 'da ${LaFormaDelResponso.minimo} a '
                '${LaFormaDelResponso.massimo} parole';
            expect(misura.allMatches(i).length, 1,
                reason: 'la misura e\' scritta due volte');
          }
        }
      }
      cardinaleMinimo(istruzioni, 24, cosa: 'istruzioni');
    });

    test('il modello scrive solo il responso principale, in ogni stesa', () {
      for (final tipo in TarotSpreadType.values) {
        final s = TarotSpread.draw(seed: 3, posizioni: tipo.posizioni);
        expect(LaLetturaDellaStesa.campiPer(s).keys,
            ['risposta', 'cosaFare', 'titolo'],
            reason: tipo.name);
        expect(LaLetturaDellaStesa.campiPer(s, profonda: true).keys,
            ['risposta', 'cosaFare', 'approfondimento', 'titolo'],
            reason: tipo.name);
        // Il tetto dei gettoni non sale piu' con le carte.
        expect(
            LaLetturaDellaStesa.tettoDeiGettoni(
                LaLetturaDellaStesa.campiPer(s, profonda: true),
                profonda: true),
            LaLetturaDellaStesa.tettoDeiGettoni(
                LaLetturaDellaStesa.campiPer(TarotSpread.draw(seed: 3),
                    profonda: true),
                profonda: true));
      }
    });
  });

  group('a video', () {
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

    for (final tipo in TarotSpreadType.values) {
      testWidgets(
          '${tipo.name}: il responso principale, le carte col loro riquadro e '
          'un "Da dove viene" solo', (tester) async {
        silenzia();
        for (final f in const [
          ['Cinzel', 'assets/fonts/Cinzel-variable.ttf'],
          ['EBGaramond', 'assets/fonts/EBGaramond-variable.ttf'],
        ]) {
          final loader = FontLoader(f[0]);
          loader.addFont(
              Future.value(ByteData.view(File(f[1]).readAsBytesSync().buffer)));
          await loader.load();
        }
        // Alta abbastanza per dieci bolle (la lista e' pigra), e sotto il
        // lato massimo di una bitmap del cielo dipinto.
        tester.view.physicalSize = const Size(360, 15000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => MaestroController()),
            ChangeNotifierProvider(create: (_) => ParallaxController()),
            ChangeNotifierProvider(create: (_) => QualityTierController()),
            ChangeNotifierProvider(create: (_) => ZodiacController()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: MaestroScope(
              child: StesaTreCarteScreen(
                seed: 5,
                revealAll: true,
                skipIntro: true,
                topic: TarotTopic.bivio,
                tipo: tipo,
              ),
            ),
          ),
        ));
        await tester.pump();
        await tester.pump(const Duration(seconds: 3));
        final stesa = tester
            .state<StesaTreCarteScreenState>(find.byType(StesaTreCarteScreen))
            .stesaCorrente;
        expect(stesa.cards, hasLength(tipo.carte));
        // Il responso principale: la risposta e il riquadro.
        expect(
            find.byKey(const Key('stesa_principale_risposta')), findsOneWidget);
        expect(
            find.descendant(
                of: find.byType(RiquadroInEvidenza),
                matching: find.byKey(const Key('stesa_principale_cosa_fare'))),
            findsOneWidget);
        // Il "Da dove viene" e' uno solo, in tutta la schermata.
        expect(find.byKey(const Key('stesa_principale_da_dove_viene')),
            findsOneWidget);
        final dove = find.byWidgetPredicate((w) =>
            w is Text &&
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.endsWith('_da_dove_viene'));
        expect(dove, findsOneWidget,
            reason: 'una carta porta il suo "Da dove viene"');
        if (tipo.carte == 1) {
          // Voce GA.05: niente secondo blocco per la stessa carta.
          expect(find.byType(BollaDellaPosizione), findsNothing);
          expect(find.text('LE CARTE, UNA ALLA VOLTA'), findsNothing);
        } else {
          expect(find.byType(BollaDellaPosizione), findsNWidgets(tipo.carte));
          for (var i = 0; i < stesa.cards.length; i++) {
            final d = stesa.cards[i];
            expect(find.byKey(Key('carta_${d.position.name}_cosa_fare')),
                findsWidgets,
                reason: '${d.position.name}: manca il riquadro');
            expect(find.byKey(Key('carta_${d.position.name}_titolo')),
                findsWidgets,
                reason: '${d.position.name}: manca il titolo');
          }
          // Il riquadro "Cosa fare adesso": uno per carta e quello del
          // responso principale.
          expect(find.text(LaFormaDelResponso.titoloDelConsiglio),
              findsNWidgets(tipo.carte + 1));
        }
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('la Lunga mostra la contemplazione della carta chiave',
        (tester) async {
      // La schermata con la Lunga chiede la profondita' al pannello e il
      // modello vero: qui si guarda il responso principale della Lunga
      // disegnato dallo stesso pezzo che la schermata usa.
      final s = TarotSpread.draw(seed: 8);
      final r = TarotReading.of(s, TarotTopic.bivio,
          depth: AnswerDepth.profonda,
          dalModello: letturaFinta(s, lunga: true));
      expect(r.principale.rito, isNotNull);
      expect(r.principale.rito,
          LeCarteNellaPosizione.contemplazioneDi(r.chiave.drawn));
      expect(r.principale.difetti(), isEmpty);
    });
  });

  test('la lettura finta e\' a misura, o le prove misurano se stesse', () {
    var guardate = 0;
    for (final tipo in TarotSpreadType.values) {
      for (var seme = 0; seme < 40; seme++) {
        final s = TarotSpread.draw(seed: seme, posizioni: tipo.posizioni);
        final LetturaDelModello l = letturaFinta(s, lunga: true);
        guardate++;
        expect(LaLetturaDellaStesa.scarto(l, s, forma: CourtesyForm.neutral),
            isNull,
            reason: '${tipo.name} seme $seme');
      }
    }
    cardinaleMinimo(guardate, 160, cosa: 'letture finte');
  });
}
