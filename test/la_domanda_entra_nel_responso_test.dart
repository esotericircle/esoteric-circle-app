import 'dart:io';

import 'package:esoteric_circle/core/tarot/domanda_della_persona.dart';
import 'package:esoteric_circle/core/tarot/la_carta_nella_risposta.dart';
import 'package:esoteric_circle/core/tarot/la_carta_nella_risposta_scritta.dart';
import 'package:esoteric_circle/core/tarot/la_domanda_letta.dart';
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
///
/// **DALL'ORDINE GA, voci GA.03 e GA.06, 20 ottobre 2026**, le parole della
/// domanda non stanno piu' nel paragrafo: ogni paragrafo ha da 40 a 50
/// parole, e con la domanda dentro la misura dipenderebbe da quanto scrive
/// la persona. La domanda si legge a video sotto il titolo, e nel responso
/// entra attraverso la lente che sceglie: la guardia misura che la lente
/// della domanda stia nella prima frase, quella che risponde. LAPIDE: la
/// funzione `portanti`, le parole portanti cercate nel primo paragrafo.
void main() {
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

  // **LAPIDE: "le parole della domanda scritta arrivano nel testo del
  // responso"**, cioe' nel primo paragrafo, attraverso il riconoscimento
  // della domanda (*"Hai chiesto: «...»"*). Ordine GA, voci GA.03 e GA.06, 20
  // ottobre 2026, scelta della ricognizione della stesa: il riconoscimento
  // esce dal paragrafo, perche' ogni paragrafo ha da 40 a 50 parole e con la
  // domanda dentro la misura dipenderebbe da quanto scrive la persona. La
  // domanda scritta sta a video sotto il titolo, e quella pretesa la tiene
  // l'ultima prova di questo file (la schermata passa la domanda al motore).
  //
  // **LA LEGGE DEL FONDATORE RESTA**, *"il responso ha alcun riferimento alla
  // mia domanda, le risposte sono generiche"*.
  //
  // **LA GRANDEZZA MISURATA CAMBIA DI NUOVO, ordine GA voce GA.06, 21 ottobre
  // 2026.** LAPIDE: "la lente della domanda sta nella prima frase". Il
  // lettore cieco ha trovato proprio quella lente in testa alla risposta
  // anche quando era sbagliata (*"sul ritorno che aspetti"* su una causa
  // contro l'ex socio, *"sul lavoro che cerchi"* su un investimento), e una
  // lente in testa non e' una risposta. Adesso la domanda entra in due modi,
  // e si misurano tutti e due: **la prima frase risponde nella forma della
  // domanda** (a un si' o no risponde si', no o non ancora), e **il "Cosa
  // fare adesso" porta il gesto della sua situazione** (`LaDomandaLetta`).
  test('la domanda scritta decide la forma della risposta e il suo gesto', () {
    final casi = <(String, Situazione)>[
      (
        'Devo lasciare il mio lavoro per aprire una libreria?',
        Situazione.lasciareIlLavoro
      ),
      ('Tornera da me il mio ex fidanzato?', Situazione.ritorno),
      ('Il mio compagno mi sta nascondendo qualcosa?', Situazione.fiducia),
    ];
    // Le aperture del verdetto, ordine GA voce GA.06 (i testi scritti): un
    // si', un no, un non ancora, o sul timore e sul distacco la risposta che
    // gli spetta. Non `\b`: in Dart non vede le lettere accentate.
    final risponde = RegExp(
        r'^(Le carte inclinano (al sì|al no|a farlo|a non chiudere|a non farlo)|Sì|No,|'
        r'Per ora no|Non ancora|Non subito|Può andare|Così com.è adesso, no|'
        r'Meglio non decidere|Le carte consigliano di non decidere|'
        r'Non è detto|Le carte non lo confermano|Le carte non danno certezze|'
        r'Non come certezza|Il timore non trova conferma|'
        // Il terzo giro (GA.06): senza una carta che dica l'esito la
        // risposta dice che un si' o un no non c'e', e cosa le carte
        // mostrano. Il verdetto vero lo danno solo le carte che lo dicono.
        r'Le carte (propendono per|vanno verso) il (sì|no)|'
        r'Il (sì|no) è la direzione|Tutto fa pensare al sì|'
        r'Un sì o un no netto|Su questo le carte non danno un sì o un no|'
        r'La risposta non è un sì o un no|'
        r'Le carte non decidono al posto tuo|'
        r'Una risposta secca le carte non la danno|'
        r'Un verdetto le carte non lo pronunciano|'
        r'Le carte non confermano e non smentiscono questo timore|'
        r'Su questo timore le carte non danno|'
        r'Il timore resta aperto|Le carte non dicono se il timore|'
        // Con una situazione riconosciuta l'apertura la nomina.
        r'Un ritorno le carte non lo promettono|Se ci sia un ritorno|'
        r'Se puoi fidarti le carte non lo dicono|Sulla fiducia le carte non)'
        r'(?![A-Za-zÀ-ÿ])');
    final guasti = <String>[];
    var guardate = 0;
    for (final (domanda, situazione) in casi) {
      final lettura = TarotReading.of(stesa(), TarotTopic.momentoCheVivo,
          domandaScritta: domanda);
      final risposta = lettura.principale.risposta;
      final i = risposta.indexOf(RegExp(r'[.!?](\s|$)'));
      final prima = i < 0 ? risposta : risposta.substring(0, i + 1);
      guardate++;
      // ignore: avoid_print
      print('ORDINE GA VOCE 06: "$domanda": "$prima"');
      if (!risponde.hasMatch(prima)) {
        guasti.add('"$domanda": la prima frase non risponde si\' o no: '
            '"$prima"');
      }
      final gesti = [
        for (final tono in TonoDellaCarta.values)
          ...gestiDellaDomanda['${situazione.name}|${tono.name}']!.values,
      ];
      if (!gesti.any(lettura.principale.cosaFare.contains)) {
        guasti.add('"$domanda": il cosa fare non porta il gesto della '
            'situazione ${situazione.name}: "${lettura.principale.cosaFare}"');
      }
      if (risposta.contains(domanda)) {
        guasti.add('"$domanda" e\' tornata dentro il paragrafo');
      }
    }
    cardinaleMinimo(guardate, 3, cosa: 'domande scritte guardate');
    expect(guasti, isEmpty, reason: guasti.join('\n'));
  });

  test('e la domanda di chiusura e la sua, non una pescata dal corpus', () {
    const domanda = 'Il mio compagno mi sta nascondendo qualcosa?';
    final sua =
        TarotReading.of(stesa(), TarotTopic.fiducia, domandaScritta: domanda);
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
    print(
        'ORDINE CQ VOCE 6.10: senza domanda la chiusura e "${senza.domanda}"');
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
    final schermata = File('lib/features/tarot/stesa_tre_carte_screen.dart')
        .readAsStringSync();
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
