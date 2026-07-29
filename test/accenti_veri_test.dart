import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

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
    "perche'": 'perché',
    "piu'": 'più',
    "gia'": 'già',
    "puo'": 'può',
    "cioe'": 'cioè',
    "sara'": 'sarà',
    "verita'": 'verità',
  };

  test('Nessuna stringa mostrata usa l\'apostrofo al posto dell\'accento', () {
    final colpevoli = <String>[];
    for (final f in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
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
          final testo = pezzi[k];
          for (final e in sbagliate.entries) {
            final chiaveSenzaApice = e.key.substring(0, e.key.length - 1);
            // La stringa e' spezzata sull'apice, quindi la forma sbagliata
            // compare come parola che FINISCE il pezzo: "TI DIRA" seguito
            // dall'apice che ha spezzato.
            if (testo.endsWith(chiaveSenzaApice) &&
                (testo.length == chiaveSenzaApice.length ||
                    ' .,;:!?('.contains(
                        testo[testo.length - chiaveSenzaApice.length - 1]))) {
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
