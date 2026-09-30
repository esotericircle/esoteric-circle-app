// ignore_for_file: avoid_print
import 'package:esoteric_circle/services/voce/l_orecchio_del_live.dart';
import 'package:flutter_test/flutter_test.dart';

/// **L'ISTRUZIONE DI CHI TRASCRIVE NON PORTA FRASI DA RICOPIARE.** Ordine ES
/// voce 22, 30 settembre 2026.
///
/// Sul Realme, venti domande dette al LIVE di Medora: la prima stesura
/// dell'istruzione di questa voce portava fra parentesi due esempi (il "mi
/// ama ancora" letto male, il futuro di "trovare") e diceva di che cosa parla
/// di solito la persona. Su due domande arrivate a pezzi chi trascrive ha
/// scritto *"Vorrei sapere se lui mi ama ancora"* e *"Vorrei sapere che si
/// faccia vivo lui"*: l'esempio e l'argomento sono diventati la domanda. Al
/// banco, sulle domande con un secondo di voce tolto, la stessa stesura ha
/// scritto *"Trovo lavoro"* e *"Quando troverò la persona giusta"*.
///
/// E' la stessa cosa vista con l'elenco dei nomi (ordine EK voce 03): cio'
/// che l'istruzione cita, il modello lo ricopia. L'elenco dei nomi resta,
/// perche' serve e ha la sua rete (`eUnPezzoDellElenco`); frasi da dire e
/// argomenti no.
void main() {
  /// Le frasi fra virgolette dell'istruzione, tolto l'elenco dei nomi.
  List<String> citate(String istruzione) => RegExp(r'"([^"]+)"|«([^»]+)»')
      .allMatches(istruzione)
      .map((m) => m.group(1) ?? m.group(2)!)
      .toList();

  /// Gli argomenti di cui la persona parlerebbe "di solito".
  final argomenti = RegExp(
      r"(?<!\p{L})(amore|lavoro|soldi|famiglia|salute|ex|matrimonio)(?!\p{L})",
      unicode: true,
      caseSensitive: false);

  test('nessuna frase fra virgolette e nessun argomento suggerito', () {
    final istruzione = LaTrascrizione.istruzione;
    final frasi = citate(istruzione);
    final suggeriti =
        argomenti.allMatches(istruzione).map((m) => m.group(0)!).toList();
    print('ORDINE ES VOCE 22, L\'ISTRUZIONE DI CHI TRASCRIVE: frasi fra '
        'virgolette prima 4 (la prima stesura), dopo ${frasi.length}; '
        'argomenti suggeriti prima 5, dopo ${suggeriti.length}');
    expect(frasi, isEmpty, reason: 'frasi da ricopiare: $frasi');
    expect(suggeriti, isEmpty, reason: 'argomenti suggeriti: $suggeriti');
  });

  test(
      'dice di lasciare fuori cio\' che non si capisce, e resta la regola '
      'del senso compiuto', () {
    const frase = LaTrascrizione.frasiDiSensoCompiuto;
    expect(LaTrascrizione.istruzione, contains(frase));
    expect(frase, contains('senso compiuto'));
    expect(frase, contains('lascialo fuori'));
    expect(frase, contains('senza completarlo'));
    // Anche la seconda trascrizione, quella senza il sottofondo, porta la
    // stessa frase: e' da li' che e' uscita una delle due domande inventate.
    expect(LaTrascrizione.istruzioneSenzaSottofondo, contains(frase));
  });

  test('la prima stesura, rimessa, farebbe cadere la guardia', () {
    // La misura si prova sulla stringa di prima, senza toccare il codice: le
    // quattro frasi e i cinque argomenti che la guardia conta.
    const primaStesura =
        'Di solito la persona fa una domanda sulla sua vita: l\'amore, il '
        'lavoro, i soldi, la famiglia, la salute. Scrivi la frase che ha '
        'detto davvero, in italiano corretto: quando un suono si può leggere '
        'in due modi, scegli la lettura che fa una frase di senso compiuto '
        '(per esempio "mi ama ancora" e non "mia, ma ancora"; "troverò" e '
        'non "trovo", se la frase parla del futuro).';
    expect(citate(primaStesura), hasLength(4));
    expect(argomenti.allMatches(primaStesura), hasLength(5));
  });
}
