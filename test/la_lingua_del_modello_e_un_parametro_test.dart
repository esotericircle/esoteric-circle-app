import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/l10n/la_lingua_del_cerchio.dart';
import 'package:esoteric_circle/core/l10n/la_lingua_del_modello.dart';
import 'package:esoteric_circle/core/magic/il_sigillo_dal_modello.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sorgenti_di_lib.dart';

/// LA LINGUA DELLA RISPOSTA DEL MODELLO E' UN PARAMETRO. Ordine DM voce 04.
///
/// **Il fatto misurato prima di quest'ordine**: la lingua della risposta era
/// scritta dentro i prompt, **nove volte in quattro file**, e l'ordine ne
/// nominava otto in tre. Il quarto file, `la_scena_dal_modello.dart`, non lo
/// nominava nessuno.
///
/// **E la cosa che questa prova sorveglia davvero** non e' che la porta
/// funzioni: e' che **nessun prompt torni a scriversi la lingua dentro**. La
/// prima riga cablata che rientra rimette il progetto dov'era, e nessuno se ne
/// accorge finche' non serve la seconda lingua.
void main() {
  tearDown(LaLinguaDelCerchio.dimentica);

  test('IN ITALIANO LA RIGA E\' IDENTICA A QUELLA DI PRIMA, al byte', () {
    // **E' la regola dell'ordine**: il comportamento visibile in italiano non
    // cambia di un carattere. Un prompt che cambiasse di una virgola
    // cambierebbe le risposte del modello.
    expect(LaLinguaDelModello.nome, 'italiano');
    expect(LaLinguaDelModello.laRiga, '- Scrivi sempre e solo in italiano.');
    expect(LaLinguaDelModello.laRigaConGliAccenti,
        '- Scrivi sempre e solo in italiano, con accenti veri.');
    expect(LaLinguaDelModello.nomeMaiuscolo, 'Italiano');
  });

  test('e in inglese cambia la lingua, non la frase', () {
    LaLinguaDelCerchio.faiValere(LinguaDelCerchio.inglese);
    expect(LaLinguaDelModello.nome, 'inglese');
    expect(LaLinguaDelModello.laRiga, '- Scrivi sempre e solo in inglese.');
    expect(LaLinguaDelModello.nomeMaiuscolo, 'Inglese');
  });

  test('IL PROMPT VERO PORTA LA LINGUA, e cambia con lei', () {
    // Non la porta per conto suo: un prompt vero, preso da chi lo compone.
    final italiano =
        IlSigilloDalModello.istruzioneDeiTesti(CourtesyForm.feminine);
    expect(italiano, contains('in italiano, rivolti a lei col tu'),
        reason: 'il prompt del Sigillo non dice piu la lingua come prima');
    LaLinguaDelCerchio.faiValere(LinguaDelCerchio.inglese);
    final inglese =
        IlSigilloDalModello.istruzioneDeiTesti(CourtesyForm.feminine);
    expect(inglese, contains('in inglese, rivolti a lei col tu'),
        reason: 'cambiata la lingua del Cerchio, il prompt continua a '
            'chiedere l italiano: la lingua non e un parametro');
    // **E NELLA RIGA CHE PORTA LA LINGUA non e' cambiato nient'altro.**
    //
    // Si confronta la prima riga e non il prompt intero, ed e' una lezione:
    // confrontandoli interi la prova cadeva, perche' **in inglese cambia
    // anche il blocco di cortesia**. Non e' un guasto, e' la voce 05 che
    // funziona: in una lingua senza genere la marca `[a|b|c]` rende il campo
    // neutro invece di scegliere fra maschile e femminile. Una prova che
    // pretendesse i due prompt identici pretenderebbe che la voce 05 non
    // esista.
    expect(inglese.split('\n').first.replaceAll('inglese', 'italiano'),
        italiano.split('\n').first,
        reason: 'nella riga che porta la lingua e cambiato qualcosa oltre '
            'alla lingua');
  });

  test('NESSUN PROMPT SI SCRIVE LA LINGUA DENTRO', () {
    // **La grandezza misurata**: una stringa di codice che chiede a qualcuno
    // di scrivere *in italiano*. Non i commenti, che di italiano parlano di
    // continuo, e non le citazioni: la forma cercata e' quella
    // dell'istruzione, cioe' la preposizione attaccata al nome della lingua
    // dentro una frase che comanda.
    final colpevoli = <String>[];
    var guardati = 0;
    final laPorta = RegExp(r'la_lingua_del_modello\.dart$');
    final istruzione = RegExp(
        r"(scrivi|scrivo|rispondi|testi|campi|riga|frasi|regole)[^'\n]{0,40}"
        r'\bin italian[oa]\b',
        caseSensitive: false);
    for (final f in sorgentiDiLib()) {
      final percorso = f.path.replaceAll('\\', '/');
      if (laPorta.hasMatch(percorso)) continue;
      guardati++;
      for (final riga in f.readAsLinesSync()) {
        final pulita = riga.trim();
        // I commenti dicono la loro: qui si guardano solo le stringhe, e una
        // riga che comincia con due barre non ne e' una.
        if (pulita.startsWith('//')) continue;
        if (!pulita.contains("'") && !pulita.contains('"')) continue;
        if (istruzione.hasMatch(pulita)) {
          colpevoli.add('$percorso: $pulita');
        }
      }
    }
    expect(guardati, greaterThanOrEqualTo(500),
        reason: 'guardati solo $guardati file: questa prova stava per dire '
            'il vero su niente');
    expect(colpevoli, isEmpty,
        reason: 'questi prompt si scrivono la lingua dentro, e il giorno '
            'della seconda lingua vanno ritrovati uno per uno:\n  '
            '${colpevoli.join("\n  ")}');
  });
}
