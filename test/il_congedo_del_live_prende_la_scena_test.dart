import 'dart:io';

import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/theme/app_theme.dart';
import 'package:esoteric_circle/features/maestri/live/la_scena_del_live.dart';
import 'package:esoteric_circle/features/maestri/live/stato_della_schermata_live.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// **A LIVE FINITO IL RITORNO ALLA CONVERSAZIONE NON COPRE NIENTE.** Ordine EN
/// voce 02, 25 settembre 2026.
///
/// **Il fatto, sul Realme, con l'archivio da consegnare**: il LIVE di Medora
/// si e' chiuso dopo trenta secondi di silenzio e "Torna alla conversazione"
/// si e' disegnato sopra la domanda in oro. Il congedo stava nel posto del
/// volto, e con la zona del testo misurata in righe dalla voce EN.02 quel
/// posto si era accorciato: la colonna traboccava. **Nessuna prova montava
/// lo stato di chiusura**, ed e' per questo che nessuna l'ha visto.
///
/// Si monta nella geometria del Realme, come la guardia della voce EN.02: 360
/// per 800 punti, le due testate sopra la scena, la barra di Android sotto.
void main() {
  const domanda = 'Medora, mio fratello si sposa a giugno e devo fare il '
      'discorso. Come lo preparo, e da dove comincio?';
  final risposta = List.filled(
          10, 'Scrivi le idee principali che vuoi esprimere sul discorso.')
      .join(' ');
  // La frase vera della fine per silenzio, dalla stessa porta che usa la
  // schermata.
  final frase = const QuadroDelLive(
          momento: MomentoDelLive.finito, maestro: Maestro.medora)
      .con(fine: ComeFinisce.silenzio)
      .laFraseDellaFine();

  Future<void> monta(WidgetTester tester, {double scala = 1}) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      home: MediaQuery(
        data: MediaQueryData(
            size: const Size(360, 800), textScaler: TextScaler.linear(scala)),
        child: Scaffold(
          body: Column(children: [
            const SizedBox(height: 122),
            Expanded(
              child: LaScenaDelLive(
                volto: const SizedBox.expand(
                    child: ColoredBox(color: Colors.black)),
                congedo: IlCongedoDelLive(
                    maestro: Maestro.medora, frase: frase, torna: () {}),
                domanda: domanda,
                risposta: risposta,
                stato: '',
              ),
            ),
            const SizedBox(height: 44),
          ]),
        ),
      ),
    ));
    await tester.pump();
  }

  for (final scala in [1.0, 1.3]) {
    testWidgets(
        'il congedo sta nella scena e il ritorno non copre niente, alla '
        'scala $scala', (tester) async {
      await monta(tester, scala: scala);
      expect(tester.takeException(), isNull,
          reason: 'il congedo trabocca dal suo posto');
      final torna = find.byKey(const Key('live_torna_alla_chat'));
      expect(torna, findsOneWidget);
      final pulsante = tester.getRect(torna);
      // **Il pulsante si vede senza scorrere**: sta dentro lo spazio che il
      // congedo occupa davvero. Il congedo scorre quando il testo e' grande,
      // quindi un pulsante fuori dal suo spazio non trabocca: resta nascosto,
      // o si disegna sopra cio' che sta sotto. E' il difetto del Realme, e
      // la prima stesura di questa prova non lo guardava.
      final spazio = tester.getRect(find.byType(IlCongedoDelLive));
      expect(spazio.top <= pulsante.top && pulsante.bottom <= spazio.bottom,
          isTrue,
          reason: 'il ritorno alla conversazione sta fuori dallo spazio del '
              'congedo: pulsante $pulsante, congedo $spazio');
      final zona = find.byKey(const Key('live_zona_del_testo'));
      if (zona.evaluate().isNotEmpty) {
        expect(tester.getRect(zona).overlaps(pulsante), isFalse,
            reason: 'il ritorno alla conversazione copre la zona della '
                'domanda');
      }
      // Tutto dentro la scena: sotto le testate e sopra la barra di Android.
      expect(pulsante.top, greaterThanOrEqualTo(122));
      expect(pulsante.bottom, lessThanOrEqualTo(800 - 44),
          reason: 'il ritorno alla conversazione sta sotto il bordo della '
              'scena: ${pulsante.bottom}');
      // Niente testo sotto il pulsante: la domanda e la risposta restano
      // scritte nella conversazione.
      expect(find.byKey(const Key('live_domanda')), findsNothing,
          reason: 'a LIVE finito la domanda sta ancora nella scena, sotto il '
              'congedo');
      expect(find.byKey(const Key('live_sottotitolo')), findsNothing);
      final congedo = tester.getRect(find.byKey(const Key('live_congedo')));
      expect(congedo.overlaps(pulsante), isFalse,
          reason: 'la frase della fine e il pulsante si coprono');
    });
  }

  test('la schermata del LIVE passa il congedo alla scena, non al volto', () {
    // **Si guarda la composizione che parte davvero.** La scena qui sopra e'
    // la stessa che la schermata monta; resta da sapere che la schermata le
    // dia il congedo e non lo rimetta nel posto del volto, dov'era.
    final schermata = File('lib/features/maestri/live/schermata_live.dart')
        .readAsStringSync();
    expect(schermata, contains('IlCongedoDelLive('),
        reason: 'la schermata non monta il congedo della scena');
    expect(schermata, contains('congedo:'),
        reason: 'la schermata non passa il congedo alla scena');
    expect(schermata.contains("Key('live_torna_alla_chat')"), isFalse,
        reason: 'il ritorno alla conversazione e\' tornato nella schermata, '
            'fuori dalla scena');
  });
}
