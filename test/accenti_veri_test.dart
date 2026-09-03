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
    // **E QUESTE SETTE SONO ARRIVATE DOPO, ordine CO voce 16.** Il
    // fondatore ha letto "Se da' fastidio" dentro il Rito dell'Alba e ha
    // chiesto l'accento vero. **Questa guardia non era cieca: il suo
    // elenco non conteneva la parola.** E' la stessa specie del difetto
    // degli accenti usati come inchiostro, trovato nello stesso ordine:
    // non una guardia che guarda male, un insieme che non contiene il
    // caso. Un elenco scritto a mano dimentica sempre una parola, e
    // l'unico rimedio onesto e' allungarlo appena una manca.
    "DA'": 'DÀ',
    "PERO'": 'PERÒ',
    "COSI'": 'COSÌ',
    "NE'": 'NÉ',
    "SE'": 'SÉ',
    "LI'": 'LÌ',
  };

  /// **DUE PUNTI DOVE LA PAROLA FINISCE DAVVERO COSI', dichiarati per nome.**
  /// Ordine CO voce 16, 3 settembre 2026.
  ///
  /// Questa prova spezza la riga sugli apici e guarda come FINISCE ogni
  /// pezzo. E' il modo giusto e ha un limite di forma: una stringa che
  /// termina legittimamente con la preposizione "da" e' indistinguibile da
  /// una che finisce col verbo scritto male. Non e' una debolezza da
  /// nascondere, e' il prezzo di una misura semplice che ha appena trovato
  /// quattro difetti veri; le due che sbaglia si scrivono qui col perche'.
  const conRagioneScritta = <String, String>{
    'lib/core/lang/euphonic.dart:81':
        'e la tavola delle preposizioni articolate, dove "da" e una CHIAVE '
            'di mappa e non una parola mostrata: da, dal, dallo, dalla',
    'lib/features/santuario/sky_overview_screen.dart:473':
        'e l etichetta "Coordinate da", che finisce con la preposizione '
            'perche il valore le viene scritto accanto',
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
              final percorso = f.path.replaceAll(r'\', '/');
              final dove =
                  '${percorso.substring(percorso.indexOf('lib/'))}:$n';
              if (conRagioneScritta.containsKey(dove)) continue;
              colpevoli.add('$dove  "$testo" va scritto ${e.value}');
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
