import 'package:flutter_test/flutter_test.dart';

import 'sorgenti_di_lib.dart';

/// Gli accenti a schermo sono accenti, non apostrofi.
///
/// La regola vale da sempre e in una stringa nuova era stata violata: la
/// schermata del genere diceva "LA TUA GUIDA TI DIRA'" con l'apostrofo al
/// posto della A accentata. Ingrandita a piena risoluzione si vede benissimo,
/// perche' un apostrofo sta in alto a destra della lettera e un accento le
/// sta sopra.
///
/// Il test guarda le stringhe, non i commenti: nei commenti l'apostrofo al
/// posto dell'accento e' una convenzione voluta di questo repository, perche'
/// il sorgente resti leggibile ovunque.
void main() {
  /// Le parole italiane che a schermo vogliono l'accento, con la forma
  /// sbagliata e quella giusta.
  const sbagliate = <String, String>{
    "DIRA'": 'DIRÀ',
    "PERCHE'": 'PERCHÉ',
    "PIU'": 'PIÙ',
    "GIA'": 'GIÀ',
    "PUO'": 'PUÒ',
    "CIOE'": 'CIOÈ',
    "SARA'": 'SARÀ',
    "VERITA'": 'VERITÀ',
    "QUALITA'": 'QUALITÀ',
    "ATTIVITA'": 'ATTIVITÀ',
    "citta'": 'città',
  };

  test('Nessuna stringa mostrata usa l\'apostrofo al posto dell\'accento', () {
    final colpevoli = <String>[];
    for (final f in sorgentiDiLib()) {
      var n = 0;
      for (final riga in f.readAsLinesSync()) {
        n++;
        final pulita = riga.trimLeft();
        // Via i commenti: li' l'apostrofo e' una convenzione di questo
        // repository, non un errore.
        if (pulita.startsWith('//')) continue;
        // Le stringhe della riga, prese col piu' semplice dei modi: fra due
        // apici, senza inseguire le sequenze di fuga. Basta allo scopo.
        final pezzi = riga.split("'");
        for (var k = 1; k < pezzi.length; k += 2) {
          // **VIA LA BARRA DI PROTEZIONE, e questa riga nasce da un buco
          // vero.** Ordine CF voce 14, coda del 31 agosto 2026. Nel codice
          // l\'apice dentro una stringa si scrive protetto, e allora lo
          // spezzone che arriva qui finisce con la barra: "Perche" seguito
          // dalla barra non e\' uguale a "Perche", e la parola sbagliata
          // passava. **E\' successo davvero**: `Text('Perche\\' proprio lui')`
          // e\' arrivato fino all\'anteprima con questa prova verde, e a
          // trovarlo e\' stato l\'occhio sull\'immagine.
          final testo = pezzi[k].endsWith(r'\')
              ? pezzi[k].substring(0, pezzi[k].length - 1)
              : pezzi[k];
          // **E SENZA BADARE ALLE MAIUSCOLE, seconda meta' dello stesso
          // buco.** L'elenco porta "PERCHE'" e "perche'", e "Perche'" con la
          // sola iniziale grande non era nessuno dei due: e' proprio la forma
          // con cui la parola sbagliata e' passata. Un elenco che deve
          // prevedere ogni maiuscola e' un elenco che dimentica sempre una
          // forma.
          final testoBasso = testo.toLowerCase();
          for (final e in sbagliate.entries) {
            final chiaveSenzaApice =
                e.key.substring(0, e.key.length - 1).toLowerCase();
            // La stringa e' spezzata sull'apice, quindi la forma sbagliata
            // compare come parola che FINISCE il pezzo: "TI DIRA" seguito
            // dall'apice che ha spezzato.
            if (testoBasso.endsWith(chiaveSenzaApice) &&
                (testoBasso.length == chiaveSenzaApice.length ||
                    ' .,;:!?('.contains(testoBasso[
                        testoBasso.length - chiaveSenzaApice.length - 1]))) {
              colpevoli.add('${f.path}:$n  "$testo" va scritto ${e.value}');
            }
          }
        }
      }
    }
    expect(colpevoli, isEmpty,
        reason: 'accenti resi con l\'apostrofo a schermo:\n'
            '${colpevoli.take(12).join('\n')}');
  });
}
