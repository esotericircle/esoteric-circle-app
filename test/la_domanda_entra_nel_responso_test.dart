import 'dart:io';

import 'package:esoteric_circle/core/tarot/domanda_della_persona.dart';
import 'package:esoteric_circle/core/tarot/tarot_card.dart';
import 'package:esoteric_circle/core/tarot/tarot_reading.dart';
import 'package:esoteric_circle/core/tarot/tarot_spread.dart';
import 'package:esoteric_circle/core/tarot/tarot_topic.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LA DOMANDA ENTRA NEL RESPONSO.** Ordine CQ voce 6.10, 4 settembre 2026.
///
/// **Parole del fondatore, ed e' lui a chiamarla la piu' grave**: *"COSA MOLTO
/// GRAVE: ho fatto una domanda libera e il responso ha alcun riferimento alla
/// mia domanda, le risposte sono generiche."*
///
/// **Il difetto, misurato prima di curarlo.** `TarotReading.of` prendeva la
/// stesa, l'argomento, la profondita' e il fatto del cielo. **Non prendeva la
/// domanda.** La domanda di chiusura del responso era `domandaDi(spread,
/// topic)`, pescata dal corpus in modo deterministico, e la domanda scritta
/// dalla persona finiva in due soli posti: il ricordo salvato e il riquadro
/// che la ripete a video. Nel testo del responso non entrava nessuna sua
/// parola.
///
/// **Un campo che raccoglie una domanda e non la usa e' peggio che non
/// averlo**, perche' promette e non mantiene: sono parole del fondatore, e
/// sono la ragione per cui questa guardia misura le PAROLE e non la presenza
/// del parametro. Un parametro passato e ignorato sarebbe verde qui se
/// misurassi la firma.
void main() {
  /// Le parole portanti di una frase: quelle che restano tolte le vuote.
  /// Serve alla misura, e la stessa regola vive nel motore.
  Set<String> portanti(String frase) => frase
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-zàèéìòùA-Z ]'), ' ')
      .split(RegExp(r'\s+'))
      .where((p) => p.length > 3)
      .toSet();

  DrawnCard di(String nome, SpreadPosition pos) => DrawnCard(
        card: TarotDeck.cards.firstWhere((c) => c.name == nome),
        position: pos,
        reversed: false,
      );

  TarotSpread stesa() => TarotSpread([
        di('Il Matto', SpreadPosition.passato),
        di('Il Mago', SpreadPosition.presente),
        di('La Papessa', SpreadPosition.futuro),
      ]);

  test('le parole della domanda scritta arrivano nel testo del responso', () {
    const domanda = 'Devo lasciare il mio lavoro per aprire una libreria?';
    final lettura = TarotReading.of(stesa(), TarotTopic.momentoCheVivo,
        domandaScritta: domanda);
    // **SI CERCA NEL PRIMO PARAGRAFO, e ci sono voluti due giri.** La prima
    // stesura cercava le parole in consiglio PIU' chiusura; la seconda nel
    // solo consiglio. Tutte e due restavano verdi togliendo l'apertura,
    // **perche' il consiglio finisce con la domanda in coda**: le parole
    // c'erano lo stesso, portate da un altro pezzo della cura. Il primo
    // paragrafo e' l'unico posto dove solo l'apertura puo' metterle, ed e'
    // anche cio' che conta: chi legge deve vedere subito che la sua
    // domanda e' stata letta, non scoprirlo in fondo.
    final testo = lettura.consiglio.split(String.fromCharCode(10) * 2).first;
    final cercate = portanti(domanda);
    final arrivate = cercate.where((p) => testo.toLowerCase().contains(p));
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.10: parole portanti della domanda '
        '${cercate.length}, arrivate nel responso ${arrivate.length}: '
        '${arrivate.join(", ")}');
    cardinaleMinimo(cercate.length, 4,
        cosa: 'parole portanti estratte dalla domanda della prova',
        perche: 'Con una domanda senza parole portanti la prova direbbe che '
            'sono tutte arrivate per non averne cercata nessuna.');
    expect(arrivate.length, cercate.length,
        reason: 'il responso ignora ${cercate.length - arrivate.length} '
            'parole su ${cercate.length} della domanda scritta: chi ha '
            'scritto una domanda riceve un testo che non la nomina, e un '
            'campo che raccoglie e non usa promette e non mantiene');
  });

  test('e la domanda di chiusura e la sua, non una pescata dal corpus', () {
    const domanda = 'Il mio compagno mi sta nascondendo qualcosa?';
    final sua = TarotReading.of(stesa(), TarotTopic.fiducia,
        domandaScritta: domanda);
    final senza = TarotReading.of(stesa(), TarotTopic.fiducia);
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.10: con la domanda scritta la chiusura e '
        '"${sua.domanda}", senza e "${senza.domanda}"');
    expect(sua.domanda, isNot(equals(senza.domanda)),
        reason: 'la stesa chiude con la stessa domanda del corpus sia che tu '
            'ne abbia scritta una sia che tu non l abbia fatto: la tua non '
            'cambia niente');
    expect(sua.domanda.toLowerCase().contains('nascondendo'), isTrue,
        reason: 'la chiusura non riprende la domanda della persona');
  });

  test('senza domanda scritta il responso resta quello di prima', () {
    // **NON SI ROMPE CHI NON SCRIVE NIENTE.** La maggior parte delle stese
    // non ha una domanda libera, e per loro il corpus resta il corpus.
    final senza = TarotReading.of(stesa(), TarotTopic.denaro);
    final vuota =
        TarotReading.of(stesa(), TarotTopic.denaro, domandaScritta: '   ');
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.10: senza domanda la chiusura e "${senza.domanda}"');
    expect(vuota.domanda, senza.domanda,
        reason: 'una domanda fatta di soli spazi cambia il responso: il '
            'campo vuoto non e una domanda');
    expect(vuota.consiglio, senza.consiglio,
        reason: 'una domanda vuota cambia il consiglio');
  });

  test('la domanda scritta sceglie la lente quando la nomina', () {
    // **IL DIFETTO ERA DOPPIO, e il fondatore lo ha detto con "generiche".**
    // Non basta nominare la domanda: se chi chiede di un ritorno d'amore
    // legge il responso del "momento che vivo", il testo resta generico
    // anche con la sua frase incollata sopra.
    final generico = TarotReading.of(stesa(), TarotTopic.momentoCheVivo);
    final mirato = TarotReading.of(stesa(), TarotTopic.momentoCheVivo,
        domandaScritta: 'Tornera da me il mio ex fidanzato?');
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.10: senza domanda la lente e '
        '"${generico.consiglio.split(",").first}", con la domanda del ritorno '
        'diventa "${mirato.consiglio.split(",").first}"');
    // **SI MISURA LA LENTE, non che il testo sia diverso.** La prima
    // stesura confrontava i due consigli, e la prova del rosso lo ha preso:
    // bastava l'apertura con la domanda a renderli diversi, quindi la
    // deduzione della lente poteva sparire senza che questa pretesa
    // cadesse.
    expect(mirato.topic, TarotTopic.ritornoAmore,
        reason: 'la domanda di un ritorno non ha scelto la lente del '
            'ritorno: la lettura resta quella generale, e le tre carte '
            'vengono lette col taglio sbagliato');
    expect(generico.topic, TarotTopic.momentoCheVivo,
        reason: 'senza domanda la lente non e piu quella scelta a mano');
  });

  test('la schermata della stesa passa davvero la domanda al motore', () {
    // **IL MOTORE GIUSTO E LA SCHERMATA CHE NON GLIELA DA' SONO LO STESSO
    // SILENZIO.** Questa riga esiste perche' il difetto originale era
    // esattamente di questa forma: il campo raccoglieva, il ricordo salvava,
    // e in mezzo nessuno passava niente.
    final schermata =
        File('lib/features/tarot/stesa_tre_carte_screen.dart').readAsStringSync();
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.10: la schermata passa la domanda al motore '
        '${schermata.contains("domandaScritta: _setup.domandaScritta")}');
    expect(schermata.contains('domandaScritta: _setup.domandaScritta'), isTrue,
        reason: 'la schermata costruisce la lettura senza passare la domanda '
            'scritta: il motore la sa usare e nessuno gliela consegna');
  });

  test('ogni lente ha le parole che la nominano', () {
    // **UNA LENTE SENZA PAROLE NON VERREBBE MAI SCELTA**, e nessuno se ne
    // accorgerebbe: la deduzione ripiegherebbe in silenzio sull'argomento
    // scelto a mano, che e' esattamente il comportamento di prima della cura.
    final senzaParole = TarotTopic.values
        .where((t) => (DomandaDellaPersona.parolePerLente[t] ?? []).isEmpty)
        .map((t) => t.name)
        .toList();
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.10: lenti ${TarotTopic.values.length}, senza '
        'parole che le nominano ${senzaParole.length}');
    cardinaleMinimo(TarotTopic.values.length, 16,
        cosa: 'lenti della stesa guardate',
        perche: 'Con zero lenti la prova direbbe che nessuna e scoperta per '
            'non averne guardata nessuna.');
    expect(senzaParole, isEmpty,
        reason: 'queste lenti non hanno nessuna parola che le nomini, quindi '
            'nessuna domanda potra mai sceglierle: ${senzaParole.join(", ")}');
  });

  test('la card da condividere NON porta la domanda scritta', () {
    // **QUESTA IMMAGINE ESCE DAL TELEFONO.** La card mostra il primo
    // paragrafo del consiglio, che con la cura di questa voce e' la domanda
    // stessa: chi condivide una lettura non sta condividendo cosa ha chiesto.
    // Segue pero' la LENTE, cosi' parla dello stesso tema del responso letto.
    final card =
        File('lib/features/tarot/stesa_share_card.dart').readAsStringSync();
    final schermata = File('lib/features/tarot/stesa_tre_carte_screen.dart')
        .readAsStringSync();
    // ignore: avoid_print
    print('ORDINE CQ VOCE 6.10: la card riceve la domanda '
        '${card.contains("domandaScritta")}, e riceve la lente dedotta '
        '${schermata.contains("topic: _reading.topic")}');
    expect(card.contains('domandaScritta'), isFalse,
        reason: 'la card da condividere costruisce la lettura con la domanda '
            'scritta: la domanda privata finisce in un immagine che la '
            'persona manda ad altri');
    expect(schermata.contains('topic: _reading.topic'), isTrue,
        reason: 'la card riceve l argomento scelto a mano invece della lente '
            'che la domanda ha dedotto: la card parlerebbe di un tema e il '
            'responso a schermo di un altro');
  });
}
