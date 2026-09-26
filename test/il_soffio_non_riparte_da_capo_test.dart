// ignore_for_file: avoid_print
import 'package:esoteric_circle/features/rituals/breath_destiny_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'attorno_al_soffio.dart';

/// **IL SOFFIO RICONOSCIUTO NON FA RIPARTIRE IL GESTO DA CAPO.** Ordine EF,
/// 23 settembre 2026.
///
/// **Il difetto, visto solo sul telefono.** Il riconoscimento del soffio e'
/// un fermo: `FormaDelSoffio.eSoffio` una volta acceso resta acceso, e il
/// flusso del microfono continua ad arrivare a pacchetti. Ogni pacchetto
/// rientrava in `_complete()` e faceva ripartire l'animazione della
/// dispersione **da zero**. Riavviare un `AnimationController` **annulla** il
/// `TickerFuture` precedente, e un futuro annullato non chiama il suo `then`:
/// **`_reveal()` non scattava mai**. A video il soffione spariva, il dono
/// restava a meta' e l'invito *"Soffia, oppure spazza col dito"* rimaneva li'
/// per sempre.
///
/// **Perche' nessuna prova poteva vederlo prima.** Il ramo di Riduci
/// Movimento rivelava il dono nello stesso fotogramma, senza nessuna
/// animazione da annullare, e sul Realme del fondatore, che ha la scala degli
/// animatori a zero, la strada rotta non si percorreva mai. Tolto quel ramo
/// nello stesso ordine, il blocco e' venuto a galla alla prima prova a video.
///
/// **Qui il gesto si ripete a mano**, che e' il modo di rifare al banco cio'
/// che il microfono fa da solo trenta volte al secondo.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('due gesti di fila non bloccano la rivelazione', (tester) async {
    SharedPreferences.setMockInitialValues({});
    const finestra = Size(411, 914);
    tester.view.physicalSize = finestra;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(attornoAlSoffio(
      BreathDestinyScreen(now: DateTime(2026, 8, 7, 10, 30)),
      finestra: finestra,
      rientri: const EdgeInsets.only(top: 40, bottom: 24),
      scala: 1.0,
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // **IL SECONDO GESTO ARRIVA MENTRE IL PRIMO STA ANCORA VOLANDO**, che e'
    // cio' che fa il microfono: il suo riconoscimento e' un fermo, resta
    // acceso, e ogni pacchetto audio rientra in `_complete()`.
    //
    // **E la grandezza misurata e' il TEMPO, non "prima o poi si rivela".**
    // Col difetto la rivelazione arriva lo stesso, ma **solo dopo l'ultimo
    // rientro**: sul telefono i rientri non finiscono mai, e li' la
    // schermata resta bloccata per sempre. La prima stesura di questa prova
    // faceva tre gesti distanziati e restava verde, perche' fra l'uno e
    // l'altro il volo faceva in tempo a finire.
    //
    // I conti, con `tester.longPress` che tiene premuto mezzo secondo:
    // il primo gesto scatta a 500 ms e il volo, lungo 900, finisce a 1400.
    // Il secondo scatta a 1000, mentre il primo vola ancora. A 1600 ms il
    // dono **deve** essere rivelato; col difetto il volo e' ripartito da
    // capo e finisce a 1900.
    await tester.longPress(find.byKey(const Key('ritual_gesture')));
    await tester.longPress(find.byKey(const Key('ritual_gesture')));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byKey(const Key('soffio_invito_al_gesto')), findsNothing,
        reason: 'l\'invito al gesto e\' ancora a video: il dono non si e\' '
            'rivelato, e la schermata resta bloccata come sul telefono del '
            'fondatore');
    expect(find.byKey(const Key('guida_respiro')), findsOneWidget,
        reason: 'la guida del respiro non e\' comparsa: la rivelazione non '
            'e\' scattata');
  });
}
