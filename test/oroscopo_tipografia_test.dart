import 'dart:async';

import 'package:esoteric_circle/app.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/horoscope/horoscope.dart';
import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:esoteric_circle/features/horoscope/oroscopo_screen.dart';
import 'package:esoteric_circle/services/app_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA TIPOGRAFIA DELL'OROSCOPO, MISURATA SULL'ALBERO VERO.
///
/// **Perche' dall'app e non dal widget in isolamento.** Una schermata montata da
/// sola non ha il tema dell'app, non ha il limite al corpo del testo di sistema
/// e non ha sopra di se' nulla di cio' che la avvolge davvero: una prova cosi'
/// misura un'ipotesi, non quel che la persona legge. Qui si monta
/// `EsotericCircleApp` e si spinge la rotta dell'Oroscopo come fa l'app.
///
/// **Cosa si guarda.** Ogni `RichText` del sottoalbero della schermata, che e'
/// cio' in cui ogni `Text` si risolve a stile gia' ereditato: leggere i `Text`
/// darebbe stili nulli tutte le volte che il colore o la misura vengono dal
/// tema, e la prova sarebbe cieca proprio dove serve.
///
/// Tre pretese, ognuna col suo rosso eseguito davvero, riportato accanto.
void main() {
  /// Le tre pretese si misurano sulla stessa scena, quindi si apre una volta
  /// sola per prova e si riusa.
  Future<void> apri(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
        EsotericCircleApp(conIntro: false, services: AppServices.offline()));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    unawaited(nav.push(OroscopoScreen.route(
        userSign: Zodiac.aries, now: DateTime(2026, 7, 10))));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    await tester.tap(find.byKey(const Key('oroscopo_interroga')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 3));
  }

  /// Tutti gli stili di testo del sottoalbero della schermata, col testo che
  /// portano, cosi' un fallimento dice quale frase e' fuori regola e non solo
  /// che una lo e'.
  List<({String testo, TextStyle stile})> stiliDi(
      WidgetTester tester, Finder radice) {
    final trovati = <({String testo, TextStyle stile})>[];
    // LE ICONE NON SONO TESTO, anche se in Flutter passano dallo stesso
    // meccanismo: un'icona e' un glifo di un font simbolico e la sua "misura"
    // e' la sua dimensione in punti, non un corpo tipografico. Contarle
    // avrebbe fatto cadere questa prova su due frecce da dieci punti, cioe'
    // su un difetto che non esiste. Si riconoscono dalla famiglia.
    bool eUnIcona(TextStyle? s) =>
        s?.fontFamily != null && s!.fontFamily!.contains('MaterialIcons');

    void raccogli(InlineSpan span, TextStyle? ereditato) {
      final stile = span.style ?? ereditato;
      if (span is TextSpan) {
        if ((span.text ?? '').trim().isNotEmpty &&
            stile != null &&
            !eUnIcona(stile)) {
          trovati.add((testo: span.text!.trim(), stile: stile));
        }
        for (final figlio in span.children ?? const <InlineSpan>[]) {
          raccogli(figlio, stile);
        }
      }
    }

    for (final w in tester.widgetList<RichText>(
        find.descendant(of: radice, matching: find.byType(RichText)))) {
      raccogli(w.text, w.text.style);
    }
    return trovati;
  }

  /// Un colore e' oro quando la tinta sta nella fascia dell'oro ed e' SATURO.
  ///
  /// Si guarda la tinta e non l'uguaglianza con una costante, perche' l'oro
  /// dell'app non e' un colore solo (`gold`, `goldLight`, `goldBright`) e un
  /// confronto secco lascerebbe passare le sue sfumature, che a video sono oro
  /// come lui.
  ///
  /// **LA GRANDEZZA MISURATA E' CAMBIATA UNA VOLTA, e sta qui scritto perche'
  /// e' la cosa che chi riprende non ritroverebbe da solo.** Il primo criterio
  /// guardava tinta e luminosita' e contava quattro blocchi dorati in una
  /// scheda che ne ha uno: l'avorio del testo di questa app NON e' un grigio,
  /// e' un bianco caldo con la STESSA tinta dell'oro (`textPrimary` sta a 45,0
  /// gradi, l'oro a 45,9). A separarli e' la saturazione, e non di poco:
  /// avorio 0,35 e testo smorzato 0,15 da una parte, oro fra 0,65 e 0,81
  /// dall'altra. La soglia sta a 0,50, cioe' in mezzo al vuoto fra i due
  /// gruppi, quindi non e' un numero scelto per far passare la prova.
  bool oro(Color? c) {
    if (c == null) return false;
    final hsl = HSLColor.fromColor(c);
    return hsl.hue >= 35 && hsl.hue <= 58 && hsl.saturation >= 0.5;
  }

  /// Un BLOCCO e' un pezzo di prosa, non un'etichetta di comando.
  ///
  /// Serve perche' dentro la scheda ci sono anche controlli scritti nella serif
  /// del corpo, per esempio la voce "Breve" del selettore di profondita', che e'
  /// dorata perche' e' la scelta attiva e non perche' porti il senso del
  /// responso. Una frase ha spazi e va a capo; un comando sta in una parola.
  bool prosa(String testo) => testo.length >= 40 && testo.contains(' ');

  testWidgets('Nessun testo dell\'Oroscopo sotto il pavimento di dodici',
      (tester) async {
    await apri(tester);
    final stili = stiliDi(tester, find.byType(OroscopoScreen));
    expect(stili, isNotEmpty,
        reason: 'nessun testo trovato: la prova non sta misurando niente, e '
            'una prova cieca e\' peggio di nessuna prova');

    final sotto = stili
        .where((s) => (s.stile.fontSize ?? 99) < TypographyTokens.pavimento)
        .map((s) => '"${s.testo}" a ${s.stile.fontSize}')
        .toList();
    expect(sotto, isEmpty,
        reason: 'Testi sotto il pavimento di ${TypographyTokens.pavimento} '
            'punti nella schermata dell\'Oroscopo:\n${sotto.join('\n')}');
    // ROSSO ESEGUITO: rimettendo `TypographyTokens.label(size: 11)` al posto
    // del ruolo `etichetta()` sull'etichetta del dominio della scheda, la prova
    // e' caduta nominando "GENERALE" a 11.0 punti.
  });

  testWidgets('Il responso si legge a diciotto punti', (tester) async {
    await apri(tester);
    for (final dominio in HoroscopeDomain.values) {
      final responso = find.byKey(Key('oroscopo_testo_${dominio.name}'));
      // Le schede sotto la piega non sono nemmeno costruite: la lista le fa
      // nascere quando servono. Senza questo scorrimento la prova misurerebbe
      // la sola Generale e direbbe che va tutto bene per le altre tre.
      await tester.scrollUntilVisible(responso, 300,
          scrollable: find.byType(Scrollable).first);
      await tester.pump();
      expect(responso, findsOneWidget,
          reason: 'manca il responso della scheda ${dominio.name}');
      final stili = stiliDi(tester, responso);
      expect(stili, isNotEmpty,
          reason: 'il responso di ${dominio.name} non porta nessun testo');
      for (final s in stili) {
        expect(s.stile.fontSize, TypographyTokens.lettura().fontSize,
            reason: 'il responso di ${dominio.name} non e\' nel ruolo lettura: '
                '"${s.testo}" sta a ${s.stile.fontSize} punti invece di '
                '${TypographyTokens.lettura().fontSize}');
        expect(s.stile.height, TypographyTokens.lettura().height,
            reason: 'il responso di ${dominio.name} non ha l\'interlinea del '
                'ruolo lettura: senza quella le righe si stringono e il muro '
                'di testo torna anche a diciotto punti');
      }
    }
    // ROSSO ESEGUITO: riportando il responso a `body(size: 17)`, la prova e'
    // caduta su tutte e quattro le schede, 17.0 contro 18.0.
  });

  testWidgets('Un solo blocco in oro per scheda', (tester) async {
    await apri(tester);
    // Blocco vuol dire PROSA, non titolo: si distingue dalla famiglia, perche'
    // i titoli e le etichette dell'app sono nella serif cerimoniale e il testo
    // che si legge e' nella serif del corpo. Un titolo dorato e' l'identita'
    // della scheda; due paragrafi dorati sono due enfasi che si annullano.
    for (final dominio in HoroscopeDomain.values) {
      final scheda = find.byKey(Key('oroscopo_card_${dominio.name}'));
      // Come sopra: le schede sotto la piega nascono solo quando si arriva.
      await tester.scrollUntilVisible(scheda, 300,
          scrollable: find.byType(Scrollable).first);
      await tester.pump();
      expect(scheda, findsOneWidget);
      final dorati = stiliDi(tester, scheda)
          .where((s) =>
              oro(s.stile.color) &&
              s.stile.fontFamily != TypographyTokens.displayFamily &&
              prosa(s.testo))
          .map((s) => '"${s.testo}"')
          .toList();
      expect(dorati.length, lessThanOrEqualTo(1),
          reason: 'la scheda ${dominio.name} ha ${dorati.length} blocchi di '
              'prosa in oro invece di uno solo: ${dorati.join(', ')}. Due '
              'paragrafi in oro nella stessa scheda sono un difetto, non '
              'un\'enfasi, perche\' l\'occhio non sa piu\' quale dei due porta '
              'il senso.');
    }
    // ROSSO ESEGUITO: dando all'apertura della scheda anche il colore oro sul
    // responso, la Generale e' passata a 2 blocchi dorati e la prova e' caduta
    // nominando le due frasi.
  });

  testWidgets('Il corpo del testo di sistema si rispetta, entro un limite',
      (tester) async {
    // Chi ha alzato il carattere nelle impostazioni del telefono lo ha fatto
    // per un motivo: la scala arriva fino a 1,3 e l'app si allarga con lei.
    // Oltre, le cornici cerimoniali a misura fissa non contengono piu' il
    // testo. Il limite vive in UN punto solo, sopra il Navigator, quindi vale
    // anche per le rotte spinte sopra il guscio come questa.
    tester.view.physicalSize = const Size(1080, 2391);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    for (final (chiesta, atteso) in [(3.0, 1.3), (0.5, 0.9), (1.1, 1.1)]) {
      await tester.pumpWidget(MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(chiesta)),
        child:
            EsotericCircleApp(conIntro: false, services: AppServices.offline()),
      ));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
      unawaited(nav.push(OroscopoScreen.route(
          userSign: Zodiac.aries, now: DateTime(2026, 7, 10))));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      final dentro = tester.element(find.byType(OroscopoScreen));
      final scala = MediaQuery.of(dentro).textScaler;
      expect(scala.scale(100), closeTo(atteso * 100, 0.01),
          reason: 'con la scala di sistema a $chiesta la schermata riceve '
              '${scala.scale(100) / 100} invece di $atteso: il limite non c\'e\' '
              'oppure non sta sopra il Navigator, quindi le rotte spinte sopra '
              'il guscio ne restano fuori');
    }
    // ROSSO ESEGUITO: togliendo il clamp dal MediaQuery di `app.dart`, la
    // schermata ha ricevuto 3,0 invece di 1,3 e la prova e' caduta.
  });

  test('Il responso si spezza in paragrafi da tre o quattro righe', () {
    // La spezzatura e' una funzione pura, quindi si misura senza montare
    // niente: qui si guarda la regola, nell'albero si guarda la resa.
    const testo =
        'Il cielo di oggi ti chiede attenzione. Marte scivola nel tuo settore '
        'delle prove e porta una fretta che non e\' tua. Prendi il tempo che '
        'serve, perche\' la giornata non premia chi corre. La Luna, dal canto '
        'suo, apre uno spiraglio nella sera. Ascolta chi ti parla piano.';
    final paragrafi = spezzaInParagrafi(testo);

    expect(paragrafi.length, greaterThan(1),
        reason: 'il responso resta un blocco unico: e\' il muro di testo');
    for (final p in paragrafi) {
      final righe = (p.length / caratteriPerRigaDelResponso).ceil();
      expect(righe, lessThanOrEqualTo(5),
          reason: 'un paragrafo di $righe righe non e\' un paragrafo: "$p"');
    }
    // Nessuna parola si perde per strada, e nessuna si duplica.
    expect(paragrafi.join(' ').replaceAll(RegExp(r'\s+'), ' '),
        testo.replaceAll(RegExp(r'\s+'), ' '),
        reason: 'la spezzatura ha cambiato il testo: un paragrafo si taglia, '
            'non si riscrive');
  });
}
