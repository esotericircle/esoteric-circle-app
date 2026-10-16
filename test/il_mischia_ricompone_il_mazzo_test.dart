// ignore_for_file: avoid_print
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'sorgenti_di_lib.dart';

/// **IL MISCHIA RICOMPONE IL MAZZO.** Ordine EE voce 01, 23 settembre 2026.
///
/// **Il fondatore, verbatim**: *"Arcano dell'Alba ok la disposizione delle
/// carte, ma quando premo su 'Mischia' le carte devono ricomporsi in un
/// mazzo, mischiarsi e poi stendersi nuovamente a ventaglio su 3 righe"*.
///
/// **Cosa faceva prima.** Ogni carta girava attorno al **proprio** posto e ci
/// tornava: `centro.dx + cos(giro) * raggio`, con `giro` ricavato dal posto
/// della carta. Nessun mazzo si componeva, e da fuori passava un'ondata sul
/// ventaglio senza toglierlo di mezzo. **Padre: PROVENIENZA IGNOTA**, il
/// gesto nasce cosi' col file e nessun ordine risulta averlo descritto.
///
/// **E i posti si mescolavano a corsa FINITA**, quindi per tutta
/// l'animazione le carte puntavano al posto vecchio: anche con una raccolta
/// al centro, la stesa finale le avrebbe riportate dov'erano.
///
/// **QUESTA PROVA GUARDA IL SORGENTE, e lo dichiara.** Il movimento vive
/// dentro un `CustomPainter` che dipinge ventidue dorsi uguali: rasterizzare
/// direbbe dove sono le macchie scure, non quale delle ventidue sia quale, e
/// il mazzo si riconosce dal fatto che **tutte** convergono in un punto. La
/// prova vera di questa voce la fa il fondatore a video, e il rapporto lo
/// dichiara invece di darlo per fatto.
void main() {
  late String sorgente;

  setUpAll(() {
    sorgente = senzaCommenti(
        File('lib/features/rituals/tavolo_dei_ventidue.dart')
            .readAsStringSync());
  });

  test('le carte si raccolgono in un punto solo, non ognuna sul suo posto', () {
    // Il mazzo e' un punto del tavolo verso cui TUTTE convergono: se la
    // destinazione dipendesse dal posto della carta, sarebbero ventidue
    // destinazioni e nessun mazzo.
    final haIlMazzo = sorgente.contains('final mazzo = Offset(');
    final interpola = sorgente.contains('Offset.lerp(centro, mazzo');
    print('ORDINE EE VOCE 01: il mazzo e\' un punto $haIlMazzo, '
        'le carte ci vanno $interpola');
    expect(haIlMazzo, isTrue,
        reason: 'non esiste un punto verso cui le carte si raccolgono: senza '
            'quello non si compone nessun mazzo');
    expect(interpola, isTrue, reason: 'le carte non si muovono verso il mazzo');
  });

  test('e i posti cambiano MENTRE il mazzo e\' chiuso, non alla fine', () {
    // **La meta' che il difetto vecchio non aveva.** Con la mescolata a
    // corsa finita, le carte tornavano al posto di prima e il gesto non
    // cambiava niente di cio' che si vede.
    //
    // **Si cerca la mescolata che viene DOPO l'attesa**, non la prima del
    // file: la prima sta nel ramo a movimento ridotto, dove non c'e' nessuna
    // animazione da aspettare ed e' giusto che cambi subito.
    final aspetta = sorgente.indexOf('_durataMischia * 0.5');
    final dopo =
        aspetta < 0 ? -1 : sorgente.indexOf('_posti = _mescolati()', aspetta);
    print('ORDINE EE VOCE 01: attesa di meta\' corsa a $aspetta, '
        'mescolata che la segue a $dopo');
    expect(aspetta, greaterThan(-1),
        reason: 'nessuno aspetta che il mazzo sia chiuso prima di mescolare: '
            'le carte si rimescolano sotto gli occhi oppure a corsa finita, e '
            'in tutti e due i casi il gesto non e\' quello chiesto');
    expect(dopo, greaterThan(-1),
        reason: 'dopo l\'attesa non si mescola piu\': il mazzo si chiude e si '
            'riapre con le carte nello stesso ordine');
  });

  test('i tre tempi ci sono tutti, e il terzo stende', () {
    // Raccolta, mescolata, stesa: se un tempo sparisse, il gesto tornerebbe
    // a essere quello di prima senza che niente cadesse.
    final tempi = <String, bool>{
      'raccolta': sorgente.contains('t < 0.35'),
      'mescolata': sorgente.contains('t >= 0.35 && t < 0.65'),
      'stesa': sorgente.contains('(t - 0.65) / 0.35'),
    };
    final senza = tempi.entries.where((e) => !e.value).map((e) => e.key);
    print('ORDINE EE VOCE 01: tempi trovati '
        '${tempi.values.where((v) => v).length} su ${tempi.length}');
    expect(senza, isEmpty,
        reason: 'mancano questi tempi del gesto: ${senza.join(", ")}');
  });
}
