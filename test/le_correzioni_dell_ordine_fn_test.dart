import 'dart:io';

import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/responsi/la_forma_del_responso.dart';
import 'package:esoteric_circle/core/tarot/la_lettura_dal_modello.dart';
import 'package:esoteric_circle/core/tarot/le_carte_nella_posizione.dart';
import 'package:esoteric_circle/core/tarot/tarot_reading.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/design_system/components/il_responso_interpretato.dart';
import 'package:esoteric_circle/design_system/components/riquadro_arancione.dart';
import 'package:esoteric_circle/features/horoscope/answer_depth.dart';
import 'package:esoteric_circle/features/maestri/chat/chat_openers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'la_lettura_finta_della_stesa.dart';

/// **LE DIECI CORREZIONI DELL'ORDINE FN.** 13 ottobre 2026, richieste del
/// fondatore sulla Stesa di Tarocchi dopo la consegna della build 2306.
///
/// **ORDINE GA, 20 ottobre 2026, voci GA.03, GA.04 e GA.05.** LAPIDE: la
/// Lunga dell'ordine FN erano due paragrafi di approfondimento in un riquadro
/// arancione, `approfondimento1` e `approfondimento2`. Adesso la Lunga ha la
/// forma di GA.03: il paragrafo che approfondisce, scritto dal modello, e il
/// riquadro arancione "La contemplazione propiziatoria" della carta chiave,
/// dal corpus dei riti; solo nel responso principale, mai nelle carte
/// (*"solo per il responso principale e non per le singole carte"*).
void main() {
  // --- FN.1 e GA.03: la profondità Lunga porta l'approfondimento e la
  // contemplazione, solo nel responso principale ---

  group('FN.1 e GA.03, la profondità Lunga', () {
    test('campiPer chiede l\'approfondimento solo se profonda', () {
      final croce = TarotSpread.draw(seed: 2);
      expect(LaLetturaDellaStesa.campiPer(croce).containsKey('approfondimento'),
          isFalse);
      expect(
          LaLetturaDellaStesa.campiPer(croce, profonda: true)
              .containsKey('approfondimento'),
          isTrue);
    });

    test('l\'istruzione nomina APPROFONDIMENTO solo quando è profonda', () {
      final breve = LaLetturaDellaStesa.istruzione(CourtesyForm.neutral);
      final lunga =
          LaLetturaDellaStesa.istruzione(CourtesyForm.neutral, profonda: true);
      expect(breve, isNot(contains('APPROFONDIMENTO')));
      expect(lunga, contains('APPROFONDIMENTO (campo "approfondimento")'));
      expect(lunga.trimRight().split('\n').last, contains('"approfondimento"'),
          reason: 'il JSON finale deve nominare il campo');
    });

    test('nella Lunga l\'approfondimento e\' obbligatorio, nella Breve no', () {
      final s = TarotSpread.draw(seed: 5);
      final l = letturaFinta(s, lunga: true);
      final conApprofondimento =
          LetturaDelModello.daJson(l.toJson(), lunga: true);
      expect(conApprofondimento!.approfondimento, approfondimentoFinto);
      final senza = letturaFinta(s);
      expect(LetturaDelModello.daJson(senza.toJson(), lunga: true), isNull,
          reason: 'un responso Lungo senza il suo terzo paragrafo non ha la '
              'forma di GA.03: si chiede di nuovo');
      expect(LetturaDelModello.daJson(l.toJson())!.approfondimento, isEmpty,
          reason: 'nella Breve l\'approfondimento non si legge');
    });

    test('un approfondimento fuori misura fa cadere la lettura', () {
      final s = TarotSpread.draw(seed: 7);
      final l = letturaFinta(s, lunga: true);
      final lungo = LetturaDelModello(
        risposta: l.risposta,
        cosaFare: l.cosaFare,
        approfondimento: '${l.approfondimento} Poi riposa.',
      );
      expect(LaLetturaDellaStesa.scarto(lungo, s),
          contains('l\'approfondimento ha 51 parole'));
    });

    test(
        'il responso principale e\' Lungo SOLO con depth profonda e '
        'l\'approfondimento del modello', () {
      final s = TarotSpread.draw(seed: 11);
      final l = letturaFinta(s, lunga: true);
      final conTutto = TarotReading.of(s, TarotTopic.lavoroTrovare,
          depth: AnswerDepth.profonda, dalModello: l);
      expect(conTutto.principale.approfondimento, approfondimentoFinto);
      expect(conTutto.principale.rito,
          LeCarteNellaPosizione.contemplazioneDi(conTutto.chiave.drawn),
          reason: 'il rito e\' la contemplazione della carta chiave, dal '
              'corpus');
      expect(conTutto.principale.difetti(), isEmpty);
      expect(conTutto.fonte, contains('Golden Dawn'),
          reason: 'il "Da dove viene" della Lunga dice la fonte del rito');
      for (final p in conTutto.posizioni) {
        expect(p.responso!.lungo, isFalse,
            reason: 'le singole carte restano Brevi');
      }

      final breveConModelloLungo = TarotReading.of(s, TarotTopic.lavoroTrovare,
          depth: AnswerDepth.breve, dalModello: l);
      expect(breveConModelloLungo.principale.lungo, isFalse,
          reason: 'la Breve non mostra l\'approfondimento anche se per '
              'caso ci fosse');
      expect(breveConModelloLungo.fonte, isNot(contains('Golden Dawn')));

      final profondaSenzaModello = TarotReading.of(s, TarotTopic.lavoroTrovare,
          depth: AnswerDepth.profonda);
      expect(profondaSenzaModello.principale.lungo, isFalse,
          reason: 'la lettura di casa, senza modello, non ha un '
              'approfondimento da mostrare');

      final profondaMaModelloBreve = TarotReading.of(
          s, TarotTopic.lavoroTrovare,
          depth: AnswerDepth.profonda, dalModello: letturaFinta(s));
      expect(profondaMaModelloBreve.principale.lungo, isFalse,
          reason: 'se il modello non ha scritto l\'approfondimento, niente '
              'riquadro vuoto');
    });

    testWidgets('il riquadro arancione del rito compare solo nella Lunga',
        (tester) async {
      final s = TarotSpread.draw(seed: 11);
      Future<void> monta(ResponsoInterpretato r) => tester.pumpWidget(
            MaterialApp(
              home: Material(
                child: SingleChildScrollView(
                  child: IlResponsoInterpretato(
                    responso: r,
                    chiave: 'stesa_principale',
                    stileDelTitolo: const TextStyle(fontSize: 20),
                    stile: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          );
      final lunga = TarotReading.of(s, TarotTopic.lavoroTrovare,
          depth: AnswerDepth.profonda,
          dalModello: letturaFinta(s, lunga: true));
      await monta(lunga.principale);
      expect(
          find.descendant(
              of: find.byType(RiquadroArancione),
              matching: find.text(
                  LaFormaDelResponso.titoloDelRito(ArteInterpretata.tarocchi))),
          findsOneWidget,
          reason: 'nella Lunga il riquadro arancione porta il titolo del '
              'rito');
      expect(find.text('La contemplazione propiziatoria'), findsOneWidget);
      expect(find.byKey(const Key('stesa_principale_approfondimento')),
          findsOneWidget);

      final breve = TarotReading.of(s, TarotTopic.lavoroTrovare,
          dalModello: letturaFinta(s));
      await monta(breve.principale);
      expect(find.byType(RiquadroArancione), findsNothing,
          reason: 'nella Breve niente riquadro arancione');
    });
  });

  // --- FN.2: il pannello si chiude alla prima carta ---

  group('FN.2, il pannello si chiude da solo', () {
    final schermata = File('lib/features/tarot/stesa_tre_carte_screen.dart')
        .readAsStringSync();

    test('la prima carta chiude il pannello', () {
      expect(schermata, contains('if (slot == 0) _setupAperto = false;'),
          reason: 'la prima carta scelta non chiude piu\' il pannello '
              '"Scegli la tua stesa"');
    });
  });

  // --- FN.4: la tastiera non torna da sola ---

  group('FN.4, la tastiera non torna da sola', () {
    final selettori =
        File('lib/features/tarot/tarot_selectors.dart').readAsStringSync();

    // **DA `onTapDown` A `onOpened`, ordine FR voce 01, 13 ottobre 2026.**
    // Il fondatore ha visto la tastiera tornare su ANCORA, dopo che questa
    // stessa voce diceva il difetto chiuso: `onTapDown` su un
    // `GestureDetector` esterno non vince sempre l'arena dei gesti contro
    // l'`InkWell` interno di `PopupMenuButton`, quindi il tocco poteva
    // aprire il menu senza passare da li'. `PopupMenuButton.onOpened` lo
    // chiama il bottone stesso, dentro `showButtonMenu()`, PRIMA di aprire
    // la rotta del menu (verificato sul sorgente del framework,
    // `popup_menu.dart`): nessuna arena, nessuna corsa da vincere.
    // **LAPIDE, ordine FS 13 ottobre 2026**: qui c'erano due prove sul
    // sorgente che pretendevano `FocusScope.of(context).unfocus()` in
    // `onOpened` e in `onSelected` (ordini FR voci 01 e 06). Il fondatore ha
    // visto la tastiera tornare anche cosi', perche' quella chiamata spegne la
    // schermata e non il campo. Il fatto si misura adesso col gesto vero in
    // `test/la_tastiera_non_torna_dopo_la_scelta_test.dart`; qui resta solo
    // che il sorgente non torni alle due forme che non funzionavano.
    test('la tendina spegne il campo a fuoco, non la schermata', () {
      // Senza i commenti: la spiegazione della correzione nomina la forma
      // vecchia, e la prova non deve accusare chi spiega.
      final codice = selettori
          .split('\n')
          .where((r) => !r.trimLeft().startsWith('//'))
          .join('\n');
      expect(codice, contains('FocusManager.instance.primaryFocus?.unfocus()'),
          reason: 'la tendina non spegne piu\' il campo che ha il focus');
      expect(codice, isNot(contains('FocusScope.of(context).unfocus()')),
          reason: 'FocusScope.of(context).unfocus() spegne la schermata, '
              'che alla chiusura del menu ridà il focus al campo');
      expect(selettori,
          isNot(contains('onTapDown: (_) => FocusScope.of(context).unfocus()')),
          reason: 'e non deve tornare al vecchio onTapDown');
    });
  });

  // --- FN.5: lo scorrimento torna in cima dopo la riflessione ---

  group('FN.5, lo scorrimento torna in cima', () {
    final schermata = File('lib/features/tarot/stesa_tre_carte_screen.dart')
        .readAsStringSync();

    test('la risalita è chiamata prima della sequenza del tavolo', () {
      expect(schermata, contains('void _risaliInCima()'),
          reason: 'il metodo che fa risalire lo scorrimento non esiste '
              'più');
      final risale = schermata.indexOf('_risaliInCima();');
      final sequenza = schermata.indexOf('unawaited(_laSequenzaDelTavolo());');
      expect(risale, greaterThanOrEqualTo(0),
          reason: 'la risalita non viene mai chiamata');
      expect(sequenza, greaterThan(risale),
          reason: 'la risalita deve avvenire PRIMA che le carte comincino '
              'a girarsi e alzarsi, non dopo');
    });
  });

  // --- FN.9: lo scorrimento non va più a scatti con Alleggerisci grafica ---

  group('FN.9, lo scorrimento rispetta Alleggerisci grafica', () {
    final schermata = File('lib/features/tarot/stesa_tre_carte_screen.dart')
        .readAsStringSync();

    test('il tier basso ferma il galleggio, non solo Riduci Movimento', () {
      expect(schermata,
          contains('MediaQuery.of(context).disableAnimations || tierBasso'),
          reason: '"Alleggerisci grafica" (QualityTier.low) non ferma più '
              'il galleggio e il tilt del tavolo: lo scorrimento resta a '
              'scatti anche con quell\'impostazione attiva');
    });
  });

  // --- FN.7 e FN.8: il Consiglio ha il suo Parlane, e i pulsanti sono
  // centrati ---

  group('FN.7 e FN.8, il Parlane del Consiglio e la centratura', () {
    final schermata = File('lib/features/tarot/stesa_tre_carte_screen.dart')
        .readAsStringSync();
    final azioni = File('lib/features/ricordi/azioni_del_responso.dart')
        .readAsStringSync();

    test('il Consiglio di Medora ha il suo pulsante Parlane', () {
      expect(schermata, contains("Key('stesa_consiglio_parlane')"),
          reason: 'la prima bolla di risposta, il Consiglio di Medora, non '
              'ha più il suo Parlane con Medora');
    });

    test('ParlaneConMaestroCompatto è centrato, non a destra', () {
      expect(azioni, contains('alignment: Alignment.center,'),
          reason: 'il pulsante Parlane sottile non è più centrato');
      expect(azioni, isNot(contains('alignment: Alignment.centerRight,')),
          reason: 'il pulsante Parlane sottile è tornato allineato a '
              'destra');
    });
  });

  // --- FN.6/FN.8: la domanda torna sempre nell'apertura della chat ---

  group('FN.6, la domanda torna nell\'apertura della chat della bolla', () {
    test('ChatOpeners.cartaDellaStesa cita la domanda e la carta', () {
      final apertura =
          ChatOpeners.cartaDellaStesa('Devo accettare?', 'Passato', 'Il Papa');
      expect(apertura, contains('Devo accettare'));
      expect(apertura, contains('Passato'));
      expect(apertura, contains('Il Papa'));
    });

    test('la bolla passa la domanda a ChatOpeners.cartaDellaStesa', () {
      final schermata = File('lib/features/tarot/stesa_tre_carte_screen.dart')
          .readAsStringSync();
      expect(
          RegExp(r'ChatOpeners\.cartaDellaStesa\(\s*domanda,\s*'
                  r'letta\.drawn\.position\.label')
              .hasMatch(schermata),
          isTrue,
          reason: 'la bolla non passa più la domanda all\'apertura della '
              'chat');
    });
  });
}
