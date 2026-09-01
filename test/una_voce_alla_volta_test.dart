import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LE ALTRE VOCI ARRIVANO UNA ALLA VOLTA.
///
/// **L'ipotesi dell'ordine, verificata prima di correggere, ed E' CADUTA.**
/// L'ordine dava per fatto che "Chiedi anche agli altri" mandasse le chiamate
/// degli altri due Maestri ravvicinate, con lo stesso schema che ha fatto
/// scattare il 429. Cercando in tutto `lib` i punti che chiedono una risposta
/// a un Maestro se ne trovano TRE, e nessuno dei tre le chiede in parallelo:
/// `chiediAgliAltri` aspetta ogni voce dentro il suo ciclo, e la Sintesi
/// comparativa parte dopo, quando le lenti sono gia' arrivate. Il 429 veniva
/// dallo strumento di misura, `tool/risposte_intere.dart`, che ne mandava
/// cinque insieme, ed e' stato corretto il 3 agosto 2026.
///
/// **Allora perche' questo file esiste.** Perche' quella proprieta' non era
/// scritta da nessuna parte: reggeva perche' chi ha scritto quel ciclo ha messo
/// un `await`, e il giorno che qualcuno lo toglie per fare prima, nessuno se ne
/// accorge finche' Vertex non risponde 429 a un utente vero. La prova qui sotto
/// ENUMERA i punti che chiedono risposte e cade se uno le manda insieme.
void main() {
  test('Nessun punto chiede piu\' risposte insieme', () {
    // I MODI DI PARTIRE INSIEME, e cosa non deve esserci dentro.
    //
    // **Qui cercavo la cosa sbagliata, e una prova del rosso me lo ha detto.**
    // Cercavo la chiamata diretta all'AI, `.reply(` e le sue sorelle. Ma il
    // pericolo sta un livello SOPRA: mettendo in parallelo `_generate`, che e'
    // il metodo del controllore, dentro la parentesi non compare nessuna
    // chiamata all'AI, e la prova restava verde mentre le tre voci partivano
    // insieme. Si cerca quindi qualunque parallelo che riguardi un MAESTRO,
    // che e' la forma vera del difetto.
    const insieme = ['Future.wait', 'Future.any', 'unawaited('];
    const chiedono = [
      '.reply(',
      '.consult(',
      '.synthesize(',
      'Maestro',
      'maestro',
    ];

    // LE ECCEZIONI, dichiarate con la ragione accanto e non nascoste.
    //
    // Un parallelo che riguarda un Maestro non e' per forza un parallelo di
    // RISPOSTE: qui si leggono tre cose diverse dello stesso Maestro, e
    // leggerle una alla volta allungherebbe l'apertura della chat senza
    // toccare nessuna quota, perche' non e' Vertex che risponde, e' la
    // memoria locale.
    // La chiave e' il file piu' un pezzo del CORPO, non il numero di riga.
    //
    // **Il numero di riga si e' rotto il giorno dopo.** Era 192, e togliendo
    // l'Eco quella `Future.wait` e' scivolata a 168: la prova ha bocciato un
    // punto che era gia' dichiarato, e per una ragione che non c'entrava
    // niente con cio' che sorveglia. Un'eccezione ancorata a un numero di riga
    // si rompe ogni volta che qualcosa sopra si muove.
    const eccezioni = <String, String>{
      // **LA VOCE DEL RESPONSO NON E\' UNA RISPOSTA CHIESTA A UN MAESTRO.**
      // Ordine BX voce 05: e\' un suono, cioe\' un tono sintetizzato sul
      // telefono, e non tocca Vertex ne\' nessuna quota. Nomina un Maestro
      // perche\' ogni responso ha la voce del suo, ed e\' proprio quello che
      // l'ordine chiedeva.
      'lib/features/sigilli/regia_del_cammino.dart|'
              'PaletteSensoriale.responso(':
          'e\' il suono del responso, non una risposta: nessuna chiamata a '
              'Vertex, nessuna quota, e non si aspetta perche\' il responso e\' '
              'gia\' a schermo',
      'lib/core/sensi/palette_sensoriale.dart|'
              '_motore.tono(':
          'e\' il lettore audio che suona un tono generato qui: la parola '
              'Maestro compare perche\' ogni Maestro ha la sua nota',
      // Il gesto che entra nel cammino dopo una condivisione non chiede
      // niente a nessun Maestro: registra un fatto nel diario.
      'lib/core/condivisione/premio_della_condivisione.dart|'
              'RegiaDelCammino.dopoUnGesto(':
          'e\' un gesto che entra nel cammino, non una risposta chiesta a un '
              'Maestro',
      'lib/features/maestri/chat/maestro_chat_controller.dart|'
              '_memory.loadProfile()':
          'sono tre LETTURE della memoria per UN Maestro, non tre risposte '
              'chieste a tre Maestri: non passano da Vertex',
    };

    final colpe = <String>[];
    final da = <FileSystemEntity>[Directory('lib')];
    while (da.isNotEmpty) {
      final voce = da.removeLast();
      if (voce is Directory) {
        da.addAll(voce.listSync());
        continue;
      }
      if (voce is! File || !voce.path.endsWith('.dart')) continue;
      final percorso = voce.path.replaceAll(Platform.pathSeparator, '/');
      final righe = voce.readAsLinesSync();

      for (var i = 0; i < righe.length; i++) {
        final riga = righe[i];
        if (riga.trimLeft().startsWith('//')) continue;
        if (!insieme.any(riga.contains)) continue;
        // Il corpo della chiamata: da qui fino alla fine dell'istruzione. Se
        // dentro ci si chiede una risposta a un Maestro, quelle risposte
        // partono insieme.
        final dentro = <String>[];
        for (var j = i; j < righe.length && j < i + 12; j++) {
          dentro.add(righe[j]);
          if (righe[j].contains(');')) break;
        }
        final corpo =
            dentro.where((r) => !r.trimLeft().startsWith('//')).join('\n');
        if (chiedono.any(corpo.contains)) {
          final dichiarata = eccezioni.keys.any((chiave) {
            final pezzi = chiave.split('|');
            return percorso == pezzi[0] && corpo.contains(pezzi[1]);
          });
          if (dichiarata) continue;
          colpe.add('$percorso riga ${i + 1}: ${riga.trim()}');
        }
      }
    }

    expect(
      colpe,
      isEmpty,
      reason: 'qui si chiedono piu\' risposte insieme. Non e\' solo una '
          'questione di quota: tre Maestri che rispondono nello stesso istante '
          'sanno di chiamata multipla, tre voci che arrivano una dopo l\'altra '
          'sanno di cerchio che si consulta.\n${colpe.join("\n")}',
    );
  });

  // **LE DUE PROVE DI COMPORTAMENTO SONO STATE TOLTE IL 5 agosto 2026.**
  //
  // Guardavano `chiediAgliAltri`, cioe' il metodo che chiedeva la stessa
  // domanda agli altri due Maestri e ne incollava le risposte in QUESTA
  // conversazione. Quel metodo non esiste piu': nella chat di un Maestro parla
  // soltanto quel Maestro, e le altre voci si ascoltano nel Consiglio del
  // Cerchio.
  //
  // La regola che proteggevano NON resta scoperta, ed e' anzi piu' larga di
  // prima: la prova qui sopra scandisce TUTTO lib e cade se un punto qualunque
  // chiede piu' risposte insieme, compreso il Consiglio, che e' il posto dove
  // adesso le voci si raccolgono.
}
