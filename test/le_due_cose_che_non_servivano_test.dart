import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'sorgenti_di_lib.dart';

/// LA PAROLA CHE SERVE, E IL PONTE CHE NON SERVIVA. Ordine BB, voci 06 e 07.
///
/// **BB.06, e questa prova e' stata RIBALTATA una volta, per un errore che va
/// dichiarato.** La voce diceva "Decisione del fondatore: si toglie", e non
/// era vero: **il fondatore non aveva mai chiesto di togliere la parola del
/// giorno, aveva fatto una domanda.** La decisione l'aveva scritta l'Architetto
/// e attribuita a lui, e il lavoro fatto su quella premessa e' stato rovesciato.
///
/// **La domanda vera, parole sue**: "la parola doveva avere uno scopo: se
/// dichiari che la parola del giorno, SOLO ALL'ALBA PERO', e' 'sete' (ad
/// esempio) la risposta o responso all'utente deve essere inerente quella
/// parola perche' l'utente si chiedera': ok, ma cosa ne faccio adesso di
/// questa parola?"
///
/// **E la risposta non c'era davvero.** La parola compariva grande e sola: un
/// titolo senza testo. **Il legame esisteva gia' nel corpus e non arrivava a
/// schermo**: ogni parola porta il suo `perche`, cioe' cosa indica in questo
/// giorno, e l'ordine AS voce 06 aveva gia' fatto in modo che nascesse dal
/// GESTO e non da un terzo seme. Mancava l'ultimo passo, mostrarlo.
///
/// **BB.07, il ponte dall'Alba al Soffio**: "nel rito dell'Alba c'e' un testo
/// collegato che porta al soffio del destino, perche'? Eliminalo." Quello era
/// una richiesta vera, e resta tolto.
///
/// **Si legge il CODICE senza i commenti**: e' gia' successo due volte che una
/// guardia diventasse rossa per la propria spiegazione, e qui i commenti
/// nominano per forza tutto cio' di cui si parla.
void main() {
  String soloCodice(String percorso) {
    return File(percorso).readAsLinesSync().where((r) {
      final p = r.trimLeft();
      return !p.startsWith('//') && !p.startsWith('///');
    }).join('\n');
  }

  final scheda = soloCodice('lib/features/rituals/ritual_gift_card.dart');

  test('BB.06: nel Soffio non si condivide nessuna parola', () {
    final soffio =
        soloCodice('lib/features/rituals/breath_destiny_screen.dart');
    // ignore: avoid_print
    print('ORDINE BB VOCE 06: nel Soffio "parola del giorno" compare '
        '${'parola del giorno'.allMatches(soffio).length} volte nel codice');
    expect(soffio.contains('parola del giorno'), isFalse,
        reason: 'il Soffio condivide ancora una parola del giorno che non '
            'mostra');
  });

  test('BB.07: dall Alba non si va piu al Soffio', () {
    // ignore: avoid_print
    print('ORDINE BB VOCE 07: "ponte_verso_il_soffio" compare '
        '${"ponte_verso_il_soffio".allMatches(scheda).length} volte, '
        '"BreathDestinyScreen" ${"BreathDestinyScreen".allMatches(scheda).length}');
    expect(scheda.contains('ponte_verso_il_soffio'), isFalse,
        reason: 'la scheda del dono porta ancora al Soffio del Destino');
    expect(scheda.contains('BreathDestinyScreen'), isFalse,
        reason: 'la scheda del dono conosce ancora la strada per il Soffio: '
            'un dono non fa da corridoio a un altro dono');
  });

  test('e il Soffio del Destino resta raggiungibile dalla sua fascia', () {
    // **LA CONTROPROVA, e senza di lei si sarebbe tolto un rito.**
    var vie = 0;
    for (final f in sorgentiDiLib()) {
      if (f.path.endsWith('ritual_gift_card.dart')) continue;
      if (f.path.endsWith('breath_destiny_screen.dart')) continue;
      if (soloCodice(f.path).contains('BreathDestinyScreen.route')) vie++;
    }
    // ignore: avoid_print
    print('ORDINE BB VOCE 07: le vie che portano al Soffio, fuori dalla '
        'scheda del dono, sono $vie');
    expect(vie, greaterThan(0),
        reason: 'togliendo il ponte si e tolta l unica strada per il Soffio '
            'del Destino: il rito esiste e nessuno puo piu arrivarci');
  });
}
