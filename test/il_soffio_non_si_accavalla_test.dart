import 'dart:io';

import 'package:esoteric_circle/features/rituals/breath_destiny_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'attorno_al_soffio.dart';
import 'cardinale_minimo.dart';

/// **IL SOFFIO NON SI ACCAVALLA, E NON ANNUNCIA LA SUA RISPOSTA.**
/// Ordine CQ voce 6.03, 4 settembre 2026.
///
/// **Parole del fondatore, e sono due difetti in una schermata sola.**
///
/// Il primo: *"Alla fine del responso, compare anche la Bolla 'La risposta'
/// come prima, mentre ho chiesto la rielaborazione dei testi."* Un'etichetta
/// che annuncia una risposta **non e' uno dei quattro strati della legge dei
/// testi**: il primo strato e' un titolo che sia gia' una risposta, non un
/// cartello che dice che sotto ce n'e' una. Chi arriva li' dopo aver soffiato
/// trova scritto che sta per leggere una risposta, cioe' una riga di attesa in
/// piu' prima della risposta vera.
///
/// Il secondo: *"Il soffio del destino NON FUNZIONA"*, e nello screenshot
/// l'etichetta dei giorni di fila e i pulsanti si accavallano semitrasparenti
/// sopra un riquadro.
///
/// **La grandezza misurata**: i rettangoli veri di cio' che sta a video, presi
/// a schermata montata, e la loro sovrapposizione. Nessuna guardia del Soffio
/// li guardava: misuravano il contrasto, la lunghezza dei testi, il respiro e
/// la scelta, cioe' **ognuna una proprieta' del suo pezzo**, e la
/// sovrapposizione e' una proprieta' di due pezzi insieme.
void main() {
  /// Porta la schermata fino alla risposta, che e' dove il fondatore guarda.
  Future<void> finoAllaRisposta(WidgetTester tester, {Size? finestra}) async {
    // **LA FINESTRA SI PINNA SUL TESTER, non solo nel MediaQuery.**
    //
    // `attornoAlSoffio` passa la misura dentro un `MediaQueryData`, e la
    // schermata la legge: ma **la superficie su cui il layout si stende resta
    // quella del tester**, ottocento per seicento. La prima stesura di questa
    // guardia ha misurato i due comandi a 480 e 522 punti su una finestra
    // dichiarata di 360, e ha gridato al traboccamento: era il layout steso
    // su ottocento, cioe' un difetto della prova, non della schermata.
    if (finestra != null) {
      tester.view.physicalSize = finestra;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    }
    await tester.pumpWidget(attornoAlSoffio(
      BreathDestinyScreen(now: DateTime(2026, 8, 6, 10, 30)),
      finestra: finestra,
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    final gesto = find.byKey(const Key('ritual_gesture'));
    if (gesto.evaluate().isNotEmpty) {
      await tester.longPress(gesto);
      for (var i = 0; i < 14; i++) {
        await tester.pump(const Duration(milliseconds: 200));
      }
    }
  }

  test('la risposta non porta piu un cartello che la annuncia', () {
    // **SI LEGGE IL SORGENTE, E SI DICHIARA PERCHE'.** Il riquadro della
    // risposta si monta solo con una carta natale caricata, che in prova non
    // c'e' e non si puo' fingere senza inventare un cielo: montare la
    // schermata qui misurerebbe l'assenza della carta, non l'assenza del
    // cartello.
    final schermata = File('lib/features/rituals/breath_destiny_screen.dart')
        .readAsStringSync();
    final cartello = schermata.contains("Text('LA RISPOSTA'");
    final riquadro = schermata.contains("Key('soffio_risposta')");
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.03: il riquadro della risposta esiste $riquadro, '
        'il cartello LA RISPOSTA esiste $cartello');
    expect(riquadro, isTrue,
        reason: 'il riquadro della risposta e sparito: senza superficie le '
            'due righe stanno sul prato chiaro sotto la soglia del contrasto');
    expect(cartello, isFalse,
        reason: 'il cartello che annuncia la risposta e tornato: non e uno '
            'dei quattro strati della legge dei testi, e chi legge riceve una '
            'riga di attesa prima della risposta vera');
  });

  testWidgets('e nessuno dei comandi si accavalla con un altro',
      (tester) async {
    // **LA FINESTRA E' STRETTA APPOSTA.** Il fondatore guarda un telefono, e
    // il difetto che descrive e' di quelli che compaiono quando lo spazio
    // manca: su una finestra larga tutto sta comodo e la prova non vede
    // niente.
    await finoAllaRisposta(tester, finestra: const Size(360, 797));

    // Le cose che a video devono stare una accanto all'altra, mai una
    // sull'altra. Le chiavi sono quelle vere della schermata: un elenco
    // scoperto leggendo l'albero prenderebbe anche i contenitori che per
    // costruzione si contengono a vicenda.
    const chiavi = <String>[
      'gift_streak',
      'gift_share_word',
      'soffio_risposta',
    ];
    final rettangoli = <String, Rect>{};
    for (final chiave in chiavi) {
      final trovato = find.byKey(Key(chiave));
      if (trovato.evaluate().isEmpty) continue;
      rettangoli[chiave] = tester.getRect(trovato.first);
    }
    // E i comandi, che si trovano dal loro testo perche' sono pulsanti.
    for (final testo in const ['Custodisci', 'Parlane con Aura']) {
      final trovato = find.text(testo);
      if (trovato.evaluate().isEmpty) continue;
      rettangoli[testo] = tester.getRect(trovato.first);
    }

    final accavallati = <String>[];
    final nomi = rettangoli.keys.toList();
    for (var i = 0; i < nomi.length; i++) {
      for (var j = i + 1; j < nomi.length; j++) {
        final a = rettangoli[nomi[i]]!;
        final b = rettangoli[nomi[j]]!;
        // Il riquadro della risposta CONTIENE i suoi testi, e contenere non
        // e' accavallarsi: si guardano solo le coppie che non si contengono.
        if (a.contains(b.topLeft) && a.contains(b.bottomRight)) continue;
        if (b.contains(a.topLeft) && b.contains(a.bottomRight)) continue;
        if (!a.overlaps(b)) continue;
        accavallati.add('${nomi[i]} e ${nomi[j]}');
      }
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.03: elementi misurati ${rettangoli.length} '
        '(${rettangoli.keys.join(", ")}), coppie accavallate '
        '${accavallati.length}');
    cardinaleMinimo(rettangoli.length, 2,
        cosa: 'elementi del Soffio trovati a video e misurati',
        perche: 'Con meno di due elementi non esiste nessuna coppia da '
            'confrontare, e la prova direbbe che niente si accavalla per non '
            'aver guardato niente.');
    expect(accavallati, isEmpty,
        reason: 'questi elementi si accavallano a video: '
            '${accavallati.join(", ")}');
  });

  testWidgets('e niente sfora il bordo della finestra', (tester) async {
    // **IL TRABOCCAMENTO E' L'ALTRA FACCIA DELL'ACCAVALLAMENTO**, e su una
    // riga stretta compaiono insieme: cio' che non ci sta o si sovrappone o
    // esce.
    await finoAllaRisposta(tester, finestra: const Size(360, 797));
    final fuori = <String>[];
    var guardati = 0;
    for (final testo in const ['Custodisci', 'Parlane con Aura']) {
      final trovato = find.text(testo);
      if (trovato.evaluate().isEmpty) continue;
      guardati++;
      final r = tester.getRect(trovato.first);
      if (r.left < 0 || r.right > 360) {
        fuori.add('$testo: da ${r.left.toStringAsFixed(0)} a '
            '${r.right.toStringAsFixed(0)} su 360');
      }
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.03: comandi guardati $guardati, fuori dal bordo '
        '${fuori.length}');
    expect(fuori, isEmpty,
        reason: 'questi comandi escono dalla finestra: ${fuori.join(", ")}');
  });
}
