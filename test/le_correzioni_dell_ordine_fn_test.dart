import 'dart:io';

import 'package:esoteric_circle/core/tarot/la_lettura_dal_modello.dart';
import 'package:esoteric_circle/core/tarot/tarot_reading.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/design_system/components/il_responso_in_tre_paragrafi.dart';
import 'package:esoteric_circle/features/horoscope/answer_depth.dart';
import 'package:esoteric_circle/features/maestri/chat/chat_openers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LE DIECI CORREZIONI DELL'ORDINE FN.** 13 ottobre 2026, richieste del
/// fondatore sulla Stesa di Tarocchi dopo la consegna della build 2306.
void main() {
  LetturaDelModello buona(TarotSpread s, {bool profonda = false}) =>
      LetturaDelModello(
        risposta: 'Le carte indicano che puoi accettare, a patto di '
            'chiarire prima le condizioni. ${s.presente.card.name} nel '
            'presente dice che la decisione è matura.',
        passato: '${s.passato.card.name} nel passato racconta da dove '
            'parti: un lavoro che ti stava stretto.',
        presente: '${s.presente.card.name} nel presente dice che adesso '
            'hai gli strumenti per scegliere.',
        futuro: '${s.futuro.card.name} nel futuro indica un ambiente '
            'dove il tuo mestiere può crescere.',
        legame: 'Dal passato al futuro le carte vanno da una chiusura a '
            'un inizio.',
        consiglio: 'Questa settimana chiedi per iscritto orari e '
            'compenso.',
        approfondimento1: profonda
            ? 'Scrivi una lista di tre condizioni non negoziabili e '
                'mandala prima del colloquio di martedì.'
            : '',
        approfondimento2: profonda
            ? 'Se la risposta tarda oltre venerdì, richiama tu: non '
                'aspettare un secondo silenzio.'
            : '',
      );

  // --- FN.1: la profondità Lunga porta due paragrafi in riquadro arancione,
  // solo nel Consiglio di Medora ---

  group('FN.1, la profondità Lunga', () {
    test('campiPer chiede i due campi solo se profonda', () {
      final croce = TarotSpread.draw(seed: 2);
      expect(
          LaLetturaDellaStesa.campiPer(croce).containsKey('approfondimento1'),
          isFalse);
      expect(
          LaLetturaDellaStesa.campiPer(croce, profonda: true)
              .containsKey('approfondimento1'),
          isTrue);
      expect(
          LaLetturaDellaStesa.campiPer(croce, profonda: true)
              .containsKey('approfondimento2'),
          isTrue);
    });

    test('l\'istruzione nomina APPROFONDIMENTO solo quando è profonda', () {
      final breve = LaLetturaDellaStesa.istruzione(CourtesyForm.neutral);
      final lunga = LaLetturaDellaStesa.istruzione(CourtesyForm.neutral,
          profonda: true);
      expect(breve, isNot(contains('APPROFONDIMENTO')));
      expect(lunga, contains('APPROFONDIMENTO1'));
      expect(lunga, contains('approfondimento1'),
          reason: 'il JSON finale deve nominare il campo in minuscolo');
    });

    test('daJson legge i due campi quando ci sono, vuoti quando mancano', () {
      final s = TarotSpread.draw(seed: 5);
      final l = buona(s, profonda: true);
      final conApprofondimento =
          LetturaDelModello.daJson(l.toJson(), chiavi: l.chiavi);
      expect(conApprofondimento!.approfondimento1, isNotEmpty);
      expect(conApprofondimento.approfondimento2, isNotEmpty);
      final senza = buona(s);
      final senzaApprofondimento =
          LetturaDelModello.daJson(senza.toJson(), chiavi: senza.chiavi);
      expect(senzaApprofondimento!.approfondimento1, isEmpty);
      // Una lettura senza i due campi resta comunque una lettura: non sono
      // obbligatori come risposta, legame o consiglio.
    });

    test('un approfondimento troppo lungo fa cadere la lettura', () {
      final s = TarotSpread.draw(seed: 7);
      final l = buona(s, profonda: true);
      final lungo = LetturaDelModello(
        risposta: l.risposta,
        carte: l.carte,
        chiavi: l.chiavi,
        legame: l.legame,
        consiglio: l.consiglio,
        approfondimento1:
            'x' * (LaLetturaDellaStesa.tettoDellApprofondimento + 1),
        approfondimento2: l.approfondimento2,
      );
      expect(LaLetturaDellaStesa.scarto(lungo, s), isNotNull);
    });

    test(
        'TarotReading.of porta approfondimento SOLO con depth profonda e '
        'dalModello completo', () {
      final s = TarotSpread.draw(seed: 11);
      final l = buona(s, profonda: true);
      final conTutto = TarotReading.of(s, TarotTopic.lavoroTrovare,
          depth: AnswerDepth.profonda, dalModello: l);
      expect(conTutto.approfondimento, hasLength(2));

      final breveConModelloLungo = TarotReading.of(s, TarotTopic.lavoroTrovare,
          depth: AnswerDepth.breve, dalModello: l);
      expect(breveConModelloLungo.approfondimento, isEmpty,
          reason: 'la Breve non mostra l\'approfondimento anche se per '
              'caso ci fosse');

      final profondaSenzaModello = TarotReading.of(s, TarotTopic.lavoroTrovare,
          depth: AnswerDepth.profonda);
      expect(profondaSenzaModello.approfondimento, isEmpty,
          reason: 'la lettura di casa, senza modello, non ha un '
              'approfondimento da mostrare');

      final mezzo = buona(s);
      final profondaMaModelloMuto = TarotReading.of(s, TarotTopic.lavoroTrovare,
          depth: AnswerDepth.profonda, dalModello: mezzo);
      expect(profondaMaModelloMuto.approfondimento, isEmpty,
          reason: 'se il modello non ha scritto i due campi, niente '
              'riquadro vuoto');
    });

    testWidgets('il riquadro arancione compare coi due paragrafi, mai con uno',
        (tester) async {
      Future<void> monta(List<String> approfondimento) => tester.pumpWidget(
            MaterialApp(
              home: Material(
                child: ResponsoInTreParagrafi(
                  paragrafi: const ['Uno.', 'Due.', 'Tre.'],
                  stile: const TextStyle(fontSize: 16),
                  approfondimento: approfondimento,
                ),
              ),
            ),
          );
      await monta(const ['Primo approfondimento.', 'Secondo approfondimento.']);
      expect(find.byKey(const Key('riquadro_approfondimento')), findsOneWidget,
          reason: 'con due paragrafi il riquadro arancione deve comparire');
      expect(find.text('Primo approfondimento.'), findsOneWidget);
      expect(find.text('Secondo approfondimento.'), findsOneWidget);

      await monta(const []);
      expect(find.byKey(const Key('riquadro_approfondimento')), findsNothing,
          reason: 'senza approfondimento niente riquadro arancione');

      await monta(const ['Solo uno.']);
      expect(find.byKey(const Key('riquadro_approfondimento')), findsNothing,
          reason: 'un paragrafo solo non basta: ne servono due');
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

    test('ogni tendina toglie il focus prima di aprirsi', () {
      expect(selettori, contains('onTapDown: (_) => FocusScope.of(context).unfocus()'),
          reason: 'la tendina non toglie piu\' il focus dal campo della '
              'domanda prima di aprirsi: la tastiera torna su da sola '
              'quando la route del menu si chiude');
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
      expect(
          schermata,
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
    final azioni =
        File('lib/features/ricordi/azioni_del_responso.dart').readAsStringSync();

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
