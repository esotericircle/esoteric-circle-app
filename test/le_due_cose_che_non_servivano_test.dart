import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LE DUE COSE CHE NON SERVIVANO. Ordine BB, voci 06 e 07.
///
/// **BB.06, la parola del giorno**, chiesta due volte dal fondatore: "sia
/// nell'alba che nel soffio c'e' la parola del giorno: ma a che serve? Cosa
/// deve farne l'utente?" Una parola in risalto che non chiede niente e non
/// porta da nessuna parte occupava il posto piu' importante della scheda: chi
/// la legge cerca cosa farne, non trova risposta, **e quel vuoto se lo porta
/// dietro per tutto il rito**.
///
/// **BB.07, il ponte dall'Alba al Soffio**: "nel rito dell'Alba c'e' un testo
/// collegato che porta al soffio del destino, perche'? Eliminalo." Un dono del
/// giorno non fa da corridoio a un altro dono.
///
/// **Prima di togliere si e' guardato il corpus vivo**, come l'ordine AX
/// chiedeva: `Traguardi_165_Revisione_D2.json` non nomina la parola del giorno
/// **zero volte**, quindi nessun traguardo si spezza. Il Soffio invece e'
/// nominato quindici volte e resta dov'e': qui si toglie la porta che ci
/// portava dall'Alba, non il rito.
///
/// **Si legge il CODICE senza i commenti.** E' gia' successo due volte in
/// questo repository che una guardia diventasse rossa per la propria
/// spiegazione: qui i commenti raccontano cosa e' stato tolto e perche', e
/// nominano per forza le cose tolte.
void main() {
  String soloCodice(String percorso) {
    return File(percorso)
        .readAsLinesSync()
        .where((r) {
          final p = r.trimLeft();
          return !p.startsWith('//') && !p.startsWith('///');
        })
        .join('\n');
  }

  test('BB.06: la parola del giorno non si dipinge piu', () {
    final card = soloCodice('lib/features/rituals/ritual_gift_card.dart');
    for (final segno in const [
      "Key('gift_word')",
      "Key('alba_etichetta_parola')",
      "'Parola del giorno'",
    ]) {
      // ignore: avoid_print
      print('ORDINE BB VOCE 06: "$segno" compare '
          '${segno.allMatches(card).length} volte nel codice della scheda');
      expect(card.contains(segno), isFalse,
          reason: 'la scheda del dono dipinge ancora $segno');
    }
  });

  test('BB.06: e non si condivide piu una cosa che non si vede', () {
    // **SI CONDIVIDE CIO' CHE SI VEDE.** Se la parola sparisce dallo schermo
    // ma resta nel testo condiviso, chi riceve il messaggio apre l'app e non
    // trova cio' che gli e' stato promesso.
    for (final schermo in const [
      'lib/features/rituals/breath_destiny_screen.dart',
      'lib/features/rituals/dawn_rite_screen.dart',
    ]) {
      final codice = soloCodice(schermo);
      // ignore: avoid_print
      print('ORDINE BB VOCE 06: in $schermo "parola del giorno" compare '
          '${'parola del giorno'.allMatches(codice).length} volte nel codice');
      expect(codice.contains('parola del giorno'), isFalse,
          reason: '$schermo condivide ancora la parola del giorno');
    }
  });

  test('BB.07: dall Alba non si va piu al Soffio', () {
    final card = soloCodice('lib/features/rituals/ritual_gift_card.dart');
    // ignore: avoid_print
    print('ORDINE BB VOCE 07: "ponte_verso_il_soffio" compare '
        '${"ponte_verso_il_soffio".allMatches(card).length} volte, '
        '"BreathDestinyScreen" ${"BreathDestinyScreen".allMatches(card).length}');
    expect(card.contains('ponte_verso_il_soffio'), isFalse,
        reason: 'la scheda del dono porta ancora al Soffio del Destino');
    expect(card.contains('BreathDestinyScreen'), isFalse,
        reason: 'la scheda del dono conosce ancora la strada per il Soffio: '
            'un dono non fa da corridoio a un altro dono');
  });

  test('e il Soffio del Destino resta raggiungibile dalla sua fascia', () {
    // **LA CONTROPROVA, e senza di lei si sarebbe tolto un rito.** Il ponte
    // spariva insieme all'unica via, e il Soffio diventava irraggiungibile:
    // sarebbe stato molto peggio del difetto.
    var vie = 0;
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
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
