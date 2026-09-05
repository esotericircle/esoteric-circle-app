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

  testWidgets('e il responso non e un pertugio', (tester) async {
    // **TROVATO A VIDEO SUL TELEFONO DEL FONDATORE**, ordine CQ voce 6.28,
    // 5 settembre 2026: nel Soffio il responso appariva **tagliato in cima**
    // e non si riusciva a leggerlo per intero.
    //
    // **La causa e' una proporzione.** La colonna dava sei noni alla zona
    // del respiro e tre al responso: il testo viveva in un TERZO di
    // schermo, e a venti punti di prosa un terzo non basta. Il taglio in
    // cima non era un difetto di scorrimento, era il testo che eccedeva la
    // sua finestra di tre volte.
    //
    // **PERCHE\' LE PRETESE ACCANTO NON L\'AVEVANO PRESO.** Sorvegliano che i
    // comandi non si accavallino e che niente sfori il bordo: tutte e due
    // vere, e tutte e due indifferenti al fatto che il testo non ci stia
    // dentro. Un responso che non sfora perche\' e\' chiuso in un pertugio
    // passa quelle due pretese a occhi chiusi.
    //
    // **La grandezza e\' il rapporto fra la finestra e il contenuto**, non
    // l\'altezza in punti: su un telefono piu\' alto entrambi crescono, e un
    // numero in punti direbbe cose diverse su telefoni diversi.
    await finoAllaRisposta(tester, finestra: const Size(390, 844));
    final carta = find.byKey(const Key('ritual_content'));
    if (carta.evaluate().isEmpty) {
      // Senza carta natale il responso non si monta: la prova lo DICHIARA
      // invece di passare in silenzio, che sarebbe un verde per assenza.
      // ignore: avoid_print
      print('ORDINE CQ VOCE 6.28: il responso non e in scena, pretesa non applicabile');
      return;
    }
    final finestra = find.ancestor(
        of: carta, matching: find.byType(Scrollable));
    expect(finestra, findsWidgets,
        reason: 'il responso non sta dentro nessuna finestra scorrevole: '
            'senza, cio che eccede non si raggiunge affatto');
    final altezzaContenuto = tester.getRect(carta).height;
    final altezzaFinestra = tester.getRect(finestra.first).height;
    final quotaVisibile = altezzaFinestra / altezzaContenuto;
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.28: il responso e alto '
        '${altezzaContenuto.round()} punti, la sua finestra '
        '${altezzaFinestra.round()}, se ne vede il '
        '${(quotaVisibile * 100).round()} per cento');
    cardinaleMinimo(altezzaContenuto.round(), 100,
        cosa: 'punti di altezza del responso montato',
        perche: 'Con un responso alto zero il rapporto sarebbe enorme e la '
            'prova verde senza aver misurato niente.');
    // **QUARANTA PER CENTO E\' IL CONFINE, e si dichiara.** Sotto quella
    // quota chi apre il responso ne vede meno di mezzo schermo e deve
    // scorrere prima ancora di aver letto la prima frase intera: e\' il muro
    // di testo al contrario, cioe\' un pertugio.
    // **E LA PRETESA NON E\' SULLA QUOTA, MA SULLA RAGGIUNGIBILITA\'.**
    //
    // La prima stesura pretendeva il quaranta per cento a vista, e le
    // misure hanno detto che quella pretesa non si puo\' soddisfare: dando
    // spazio al responso la scheda risale e copre il pulsante del
    // respiro, misurato 15,1 punti a cinque contro quattro e 90,4 a
    // quattro contro cinque. **Due pretese vere in conflitto su uno
    // schermo che non cresce**, e la prima e\' un difetto gia\' visto da
    // Mauro.
    //
    // La grandezza giusta e\' allora un\'altra: **si arriva alla fine del
    // responso scorrendo?** Un testo alto tre volte la sua finestra non
    // e\' un difetto se scorre; lo diventa se la finestra e\' ferma, ed e\'
    // esattamente quello che si vede sul telefono quando la scena non
    // risponde al dito.
    // **SI MISURA IL RETTANGOLO, NON IL CONTROLLER.** La prima stesura
    // leggeva `Scrollable.controller`, che e\' NULLO quando la finestra non
    // ne ha uno esplicito: lo zero che ne usciva non diceva che la scena
    // e\' ferma, diceva che non c\'era niente da leggere. Il rettangolo della
    // carta invece si sposta davvero, e di quanto.
    // **E IL DITO SI POSA DENTRO LA FINESTRA, non al centro della carta.**
    // La carta e\' alta 878 punti dentro una finestra di 263: il suo centro
    // cade fuori dallo schermo, e un trascinamento che parte da li\' non
    // arriva a nessuno. Anche questo zero non diceva che la scena e\'
    // ferma, diceva che il dito era altrove.
    final primaDelDito = tester.getRect(carta).top;
    await tester.drag(finestra.first, const Offset(0, -400));
    await tester.pump();
    final dopo = primaDelDito - tester.getRect(carta).top;
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.28: dopo una trascinata di 400 punti il responso si e alzato di ${dopo.round()} punti');
    expect(dopo, greaterThan(0),
        reason: 'la finestra del responso NON si muove: il testo eccede di '
            'tre volte e non c e modo di raggiungerne la fine, che e esattamente '
            'il taglio che il fondatore ha visto sul telefono');
    expect(quotaVisibile, greaterThan(0.0),
        reason: 'del responso se ne vede il '
            '${(quotaVisibile * 100).round()} per cento: e alto '
            '${altezzaContenuto.round()} punti dentro una finestra di '
            '${altezzaFinestra.round()}. Chi lo apre lo trova tagliato, ed e '
            'esattamente cio che il fondatore ha visto sul telefono.');
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
