import 'package:esoteric_circle/core/l10n/la_lingua_del_cerchio.dart';
import 'package:esoteric_circle/core/l10n/numero_del_cerchio.dart';
import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/design_system/components/borsellino.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sorgenti_di_lib.dart';

/// LA MONETA SEGUE LA LINGUA. Ordine DM, coda del fondatore.
///
/// **Da dove nasce, ed e' una domanda del fondatore.** Il Cammino conia 2.010
/// Eos per sentiero e 6.030 in tutto: **il saldo supera il mille**, quindi ha
/// un separatore delle migliaia, e si legge a schermo in piu' punti. La
/// domanda era se quel numero passasse dal formattatore nuovo, perche' in quel
/// caso sarebbe stato un punto cambiato senza dirlo.
///
/// **La risposta misurata e' no**: nessuna delle righe che scrivono una moneta
/// nomina `NumeroDelCerchio`. **Ma accanto c'era la stessa identica cosa**:
/// `cifraDegliEos` scriveva il separatore **a mano**, col punto, esattamente
/// come i quattro `replaceAll('.', ',')` che quest'ordine ha gia' ricondotto
/// alla porta. Giusto in italiano, sbagliato in inglese, dove 6.030 si scrive
/// 6,030.
///
/// **In italiano il testo non cambia di un carattere**, ed e' la condizione
/// perche' questa cura stia dentro l'ordine invece di violarlo: si misura qui
/// sotto, valore per valore, contro la vecchia forma scritta per esteso.
void main() {
  tearDown(LaLinguaDelCerchio.dimentica);

  /// La vecchia forma, copiata qui com'era prima dell'ordine DM: si cammina
  /// sulle cifre e si mette un punto ogni tre. E' il metro di paragone, e
  /// resta scritto qui anche quando il codice non l'avra' piu'.
  String comeEraPrima(int saldo) {
    final crudo = saldo.toString();
    final testo = StringBuffer();
    for (var i = 0; i < crudo.length; i++) {
      if (i > 0 && (crudo.length - i) % 3 == 0) testo.write('.');
      testo.write(crudo[i]);
    }
    return testo.toString();
  }

  test('IN ITALIANO IL SALDO NON CAMBIA DI UN CARATTERE', () {
    // I valori che il Cammino puo' davvero produrre, piu' i bordi: zero, una
    // cifra, il passaggio del mille, i due numeri che il fondatore ha
    // nominato, e un saldo grande come nessuno ne avra'.
    const valori = <int>[
      0,
      1,
      9,
      10,
      99,
      100,
      250,
      999,
      1000,
      1001,
      2010,
      6030,
      12345,
      999999,
    ];
    for (final v in valori) {
      expect(cifraDegliEos(v), comeEraPrima(v),
          reason: 'su $v il borsellino adesso scrive "${cifraDegliEos(v)}" e '
              'prima scriveva "${comeEraPrima(v)}"');
    }
    // E i due numeri del Cammino, per nome, come li legge una persona.
    expect(cifraDegliEos(Sentieri.eosAttesiPerSentiero), '2.010');
    expect(cifraDegliEos(Sentieri.eosAttesiInTutto), '6.030');
  });

  test('E IN INGLESE IL SEPARATORE E\' QUELLO GIUSTO', () {
    LaLinguaDelCerchio.faiValere(LinguaDelCerchio.inglese);
    expect(cifraDegliEos(Sentieri.eosAttesiInTutto), '6,030',
        reason: 'in inglese il saldo si legge ancora col punto, che li e il '
            'separatore dei decimali: 6.030 vuol dire sei virgola zero tre');
    expect(cifraDegliEos(2010), '2,010');
    expect(cifraDegliEos(999), '999');
  });

  test('NESSUNO SCRIVE PIU\' A MANO IL SEPARATORE DELLE MIGLIAIA', () {
    // **Erano TRE copie della stessa funzione**, parola per parola: nel
    // borsellino, nel listino dei piani e nel vocabolario del Viaggio. Tre
    // copie della stessa regola sono tre verita' che un giorno divergono, e
    // in inglese sbagliavano tutte e tre allo stesso modo.
    //
    // **La grandezza misurata e' la forma del giro**, cioe' scrivere un
    // carattere ogni tre cifre: e' cosi' che si riconosce un separatore
    // scritto a mano, in qualunque nome lo si chiami.
    final aMano = <String>[];
    var guardati = 0;
    final giro = RegExp(r'%\s*3\s*==\s*0');
    for (final f in sorgentiDiLib()) {
      final percorso = f.path.replaceAll(r'\', '/');
      guardati++;
      var n = 0;
      for (final riga in f.readAsLinesSync()) {
        n++;
        final pulita = riga.trim();
        if (pulita.startsWith('//')) continue;
        if (!giro.hasMatch(pulita)) continue;
        // Il giro ogni tre e' un separatore solo se scrive un carattere: in
        // un disegno puo' voler dire una tacca ogni tre, e quello non e'
        // un numero.
        if (RegExp(r"write\(\s*'[.,  ]'\s*\)").hasMatch(pulita)) {
          aMano.add('$percorso:$n  $pulita');
        }
      }
    }
    expect(guardati, greaterThanOrEqualTo(500),
        reason: 'guardati solo $guardati file: questa prova stava per dire '
            'il vero su niente');
    expect(aMano, isEmpty,
        reason: 'qui il separatore delle migliaia e scritto a mano, e in '
            'inglese scrivera il punto dove ci vuole la virgola: '
            '${aMano.join(" | ")}');
  });

  test('IL SALDO E\' UN INTERO, e non prende decimali per strada', () {
    // Un saldo con la virgola sarebbe un guasto in qualunque lingua: gli Eos
    // non si dividono.
    for (final v in [0, 7, 2010, 6030]) {
      expect(NumeroDelCerchio.interi(v), isNot(contains(',')));
      expect(cifraDegliEos(v), isNot(contains(',')));
    }
    LaLinguaDelCerchio.faiValere(LinguaDelCerchio.inglese);
    for (final v in [0, 7, 2010, 6030]) {
      expect(NumeroDelCerchio.interi(v), isNot(contains('.')));
    }
  });
}
