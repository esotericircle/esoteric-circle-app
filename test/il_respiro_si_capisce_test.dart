import 'package:esoteric_circle/core/rituals/tempi_del_respiro.dart';
import 'package:esoteric_circle/design_system/components/guida_del_respiro.dart';
import 'package:esoteric_circle/design_system/theme/accento_del_maestro.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL RESPIRO SI CAPISCE, cioe' dice il GESTO e non dove va l'aria.
///
/// Diceva "Dentro" e "Fuori": chi tiene gli occhi socchiusi le legge e non sa
/// cosa fare, perche' descrivono l'aria invece del gesto. Adesso dice
/// "Inspira" ed "Espira", e prima di cominciare dice che sta per cominciare.
void main() {
  Widget attorno(TempiDelRespiro tempi, {bool riduciMovimento = false}) =>
      MaterialApp(
        home: MediaQuery(
          data: MediaQueryData(disableAnimations: riduciMovimento),
          child: Scaffold(
            backgroundColor: const Color(0xFFBFD5B2), // il prato del Soffio
            body: Center(
              child: GuidaDelRespiro(
                  tempi: tempi, colore: const Color(0xFFD8C89B)),
            ),
          ),
        ),
      );

  // IL RITO PARTE COL TOCCO, ordine 2163 voce 11: il vecchio timer di due
  // secondi e' stato revocato da Mauro. Per arrivare al respiro si tocca il
  // pulsante e si attraversa il conto alla rovescia, quattro secondi pieni.
  // Il no-tocco e il conto sono provati in
  // il_respiro_parte_quando_decidi_tu_test.dart: qui si attraversano e basta.
  Future<void> comincia(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('respiro_tocca')));
    await tester.pump();
    await tester.pump(ParoleDelRespiro.durataDelConto);
    await tester.pump(const Duration(milliseconds: 50));
  }

  group('le tre parole, nei tre momenti', () {
    testWidgets(
        'prima del conto dice di prepararsi, e resta finche\' non '
        'decidi tu', (tester) async {
      await tester
          .pumpWidget(attorno(const TempiDelRespiro(tempi: 4, giri: 3)));
      await tester.pump();
      expect(find.text(ParoleDelRespiro.preparati), findsOneWidget,
          reason: 'Il rito parte senza dire che sta per partire.');

      // **LA GRANDEZZA E' CAMBIATA UNA SECONDA VOLTA, e va detto.** La prima
      // stesura chiedeva che a un secondo e mezzo la frase ci fosse ancora,
      // perche' il conteggio partiva da solo dopo due secondi. Con l'ordine
      // 2163 voce 11 quel timer non esiste piu': la frase resta finche' la
      // persona non tocca, quindi qui si aspetta piu' a lungo del vecchio
      // limite e si verifica che NIENTE sia partito.
      await tester.pump(const Duration(milliseconds: 3500));
      expect(find.text(ParoleDelRespiro.inspira), findsNothing,
          reason: 'Il respiro e\' partito senza il tocco: il timer revocato '
              'e\' tornato.');
      expect(find.text(ParoleDelRespiro.preparati), findsOneWidget);

      await comincia(tester);
      // Un fotogramma in piu' per la transizione della parola: dura 180
      // millisecondi. Non e' una tolleranza sulla regola, e' il tempo del
      // cambio.
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text(ParoleDelRespiro.inspira), findsOneWidget,
          reason: 'Finito il conto il respiro deve essere partito.');
      expect(find.text(ParoleDelRespiro.preparati), findsNothing,
          reason: 'E la frase di apertura deve avere finito di uscire.');
    });

    testWidgets('durante dice Inspira, e cambia insieme alla fase',
        (tester) async {
      const tempi = TempiDelRespiro(tempi: 2, giri: 2);
      await tester.pumpWidget(attorno(tempi));
      await tester.pump();
      await comincia(tester);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(ParoleDelRespiro.inspira), findsOneWidget,
          reason: 'Il primo gesto e\' inspirare.');
      expect(find.text('Dentro'), findsNothing,
          reason: 'La parola vecchia descriveva l\'aria, non il gesto.');

      // A meta' del primo giro la fase si rovescia: la parola deve cambiare
      // CON lei, non prima.
      await tester.pump(tempi.fase - const Duration(milliseconds: 200));
      expect(find.text(ParoleDelRespiro.inspira), findsOneWidget,
          reason: 'La parola e\' cambiata prima della fase.');
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text(ParoleDelRespiro.espira), findsOneWidget,
          reason: 'Passata meta' ' del giro il gesto e\' espirare.');
    });

    testWidgets('alla fine dice che il respiro e\' compiuto', (tester) async {
      const tempi = TempiDelRespiro(tempi: 1, giri: 1);
      await tester.pumpWidget(attorno(tempi));
      await tester.pump();
      await comincia(tester);
      await tester.pump(tempi.intero + const Duration(milliseconds: 200));
      expect(find.text(ParoleDelRespiro.compiuto), findsOneWidget);
    });
  });

  group('i numeri sono quelli veri', () {
    test('la forma del rito riporta i tempi che l\'animazione esegue', () {
      // **Il presidio contro la frase che mente.** I numeri non si scrivono:
      // si leggono dai tempi, cioe' dallo stesso dato che muove la figura. Una
      // riga che dichiara quattro tempi mentre la figura ne conta sei e' peggio
      // di nessuna riga, e questo progetto l'ha gia' pagato una volta.
      expect(ParoleDelRespiro.formaDi(const TempiDelRespiro(tempi: 4, giri: 3)),
          'Quattro tempi dentro, quattro fuori. Tre volte.');
      expect(ParoleDelRespiro.formaDi(const TempiDelRespiro(tempi: 6, giri: 3)),
          'Sei tempi dentro, sei fuori. Tre volte.');
      expect(ParoleDelRespiro.formaDi(const TempiDelRespiro(tempi: 5, giri: 1)),
          'Cinque tempi dentro, cinque fuori. Una volta.');
    });

    testWidgets('cambiando i tempi cambia la frase, senza toccarla',
        (tester) async {
      // Se la frase fosse scritta a mano, questa cadrebbe: e' il rosso della
      // regola, eseguito ogni volta che la prova gira.
      for (final t in [
        const TempiDelRespiro(tempi: 4, giri: 3),
        const TempiDelRespiro(tempi: 6, giri: 4),
      ]) {
        await tester.pumpWidget(attorno(t));
        await tester.pump();
        expect(find.text(ParoleDelRespiro.formaDi(t)), findsOneWidget,
            reason: 'Con ${t.tempi} tempi e ${t.giri} giri la frase mostrata '
                'non e\' quella che i numeri veri producono.');
      }
    });

    testWidgets('il giro mostrato e\' quello in corso', (tester) async {
      const tempi = TempiDelRespiro(tempi: 1, giri: 3);
      await tester.pumpWidget(attorno(tempi));
      await tester.pump();
      await comincia(tester);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text(ParoleDelRespiro.giro(1, 3)), findsOneWidget);
      await tester.pump(tempi.giro);
      expect(find.text(ParoleDelRespiro.giro(2, 3)), findsOneWidget);
    });

    test('non si nomina un tempo che il rito non esegue', () {
      // Il rito non trattiene il fiato: scriverlo a video sarebbe promettere
      // una pausa che l'animazione non fa.
      final tutte = [
        ParoleDelRespiro.preparati,
        ParoleDelRespiro.tocca,
        ParoleDelRespiro.inspira,
        ParoleDelRespiro.espira,
        ParoleDelRespiro.compiuto,
        ParoleDelRespiro.formaDi(const TempiDelRespiro(tempi: 4, giri: 3)),
      ].join(' ').toLowerCase();
      for (final vietata in ['trattieni', 'trattenere', 'pausa']) {
        expect(tutte.contains(vietata), isFalse,
            reason: 'Le parole del respiro nominano "$vietata", ma il rito non '
                'lo esegue.');
      }
    });
  });

  group('la parola grande si legge', () {
    test('contrasto oltre 4,5 contro la sua superficie', () {
      // Nel Soffio il fondale e' un prato chiaro: la parola ha un velo suo, e
      // il contrasto si misura contro quello.
      final contrasto = AccentoDelMaestro.contrastoFra(
          inchiostroDelConteggio, veloDelConteggio);
      expect(contrasto, greaterThanOrEqualTo(4.5),
          reason: 'La parola grande si legge a '
              '${contrasto.toStringAsFixed(2)} di contrasto.');
    });

    test('anche la riga di servizio resta leggibile', () {
      // Smorzata non vuol dire illeggibile: sta al 72 per cento di opacita',
      // e il contrasto si misura su cio' che ne risulta.
      final smorzato =
          Color.lerp(veloDelConteggio, inchiostroDelConteggio, 0.72)!;
      final contrasto =
          AccentoDelMaestro.contrastoFra(smorzato, veloDelConteggio);
      expect(contrasto, greaterThanOrEqualTo(4.5),
          reason: 'La riga del giro si legge a '
              '${contrasto.toStringAsFixed(2)} di contrasto.');
    });
  });

  testWidgets('con Riduci Movimento il cambio di parola e\' secco',
      (tester) async {
    const tempi = TempiDelRespiro(tempi: 1, giri: 2);
    await tester.pumpWidget(attorno(tempi, riduciMovimento: true));
    await tester.pump();
    await comincia(tester);
    expect(find.text(ParoleDelRespiro.inspira), findsOneWidget);
    // Passata la fase, la parola nuova c'e' e la vecchia non c'e' piu' nello
    // stesso fotogramma: con la dissolvenza convivrebbero per un istante.
    await tester.pump(tempi.fase);
    expect(find.text(ParoleDelRespiro.inspira), findsNothing,
        reason: 'Con Riduci Movimento le due parole non devono convivere '
            'nemmeno per un fotogramma.');
    expect(find.text(ParoleDelRespiro.espira), findsOneWidget);
  });
}
