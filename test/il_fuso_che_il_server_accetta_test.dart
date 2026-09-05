import 'dart:io';

import 'package:esoteric_circle/services/push/fuso_del_telefono.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **IL FUSO CHE IL SERVER ACCETTA.** Ordine CQ voce 1.09, 3 settembre 2026.
///
/// **Il fatto, misurato sui log di Google Cloud dall'Architetto.** Ventitre
/// chiamate a `scriviLeScelteDellePush` e ventitre risposte 400. La raccolta
/// `push_dei_doni` su Firestore **non esiste**: nessuna scelta e' mai arrivata,
/// quindi nessuna push e' mai partita, e nessuno se ne era accorto perche' il
/// telefono si limita a stampare una riga di debug e riprovare al giro dopo.
///
/// **Quale dei tre controlli scattava, e non e' una deduzione.** La callable
/// rifiuta per tre motivi: token fuori misura, fuso che non somiglia a un nome
/// IANA, doni che non sono un oggetto. Il telefono mandava
/// `DateTime.now().timeZoneName`, che su Android e' l'abbreviazione della zona
/// (`CEST`, `CET`) o il nome tradotto: **nessuna barra in mezzo, e il
/// controllo del fuso pretende `Area/Citta`.** E' il secondo dei tre, sempre,
/// per tutti.
///
/// **PROVENIENZA: ordine CI voce 07**, che ha costruito la porta delle scelte
/// e la sua callable. Il controllo del server e il valore del client sono
/// nati nella stessa voce e non si sono mai parlati: **le prove del server
/// mandavano un nome IANA scritto a mano, quelle del client non guardavano il
/// fuso**, e in mezzo non c'era niente che confrontasse i due.
///
/// **Ed e' questa la cecita' da chiudere.** La guardia qui sotto legge il
/// controllo VERO dal sorgente del server, non una sua copia, e ci passa
/// dentro cio' che il client produce DAVVERO. Una copia della regola scritta
/// qui sarebbe verde per sempre anche il giorno che il server cambia idea.
void main() {
  test('il fuso che il telefono manda passa il controllo del server', () {
    // La regola vera, letta dal sorgente della funzione: non una sua copia.
    final server = File('functions/src/push.ts').readAsStringSync();
    final scritta = RegExp(r'if \(!/(.+)/\.test\(fuso\)\)').firstMatch(server);
    expect(scritta, isNotNull,
        reason: 'il controllo del fuso non esiste piu nel server, oppure ha '
            'cambiato forma: questa guardia stava misurando un ricordo');
    final regola = RegExp(scritta!.group(1)!);

    // Cio' che il client produce, in fusi diversi. Non si sposta l'orologio
    // della macchina: si chiede il nome per l'istante che si vuole.
    final prodotti = <String, String>{};
    for (final quando in <DateTime>[
      DateTime.now(),
      DateTime.utc(2026, 1, 15, 12),
      DateTime.utc(2026, 7, 15, 12),
    ]) {
      prodotti['$quando'] = fusoDelTelefono(adesso: quando);
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 1.09: il controllo del server e "${scritta.group(1)}"'
        ', i fusi prodotti dal client $prodotti, zone nel database '
        '$quanteZoneConosciute');
    cardinaleMinimo(quanteZoneConosciute, 300,
        cosa: 'zone nel database dei fusi caricato',
        perche: 'Con un database vuoto ogni ricerca cadrebbe sul ripiego, che '
            'passa il controllo, e la prova sarebbe verde per il motivo '
            'sbagliato.');
    for (final voce in prodotti.entries) {
      expect(regola.hasMatch(voce.value), isTrue,
          reason: 'il fuso "${voce.value}" prodotto per ${voce.key} non passa '
              'il controllo del server: e il 400 che il fondatore ha nei log');
    }
  });

  test('il ripiego passa anche lui il controllo', () {
    final server = File('functions/src/push.ts').readAsStringSync();
    final scritta = RegExp(r'if \(!/(.+)/\.test\(fuso\)\)').firstMatch(server);
    // ignore: avoid_print
    print('ORDINE CQ VOCE 1.09: il ripiego e "$fusoDiRipiego"');
    expect(RegExp(scritta!.group(1)!).hasMatch(fusoDiRipiego), isTrue,
        reason: 'il ripiego non passa il controllo: nel caso in cui nessuna '
            'zona corrisponde il telefono manderebbe di nuovo un dato che il '
            'server rifiuta, cioe il difetto tornerebbe identico nel caso '
            'raro invece che in quello comune');
  });

  test('nessuno manda piu il nome corto del fuso', () {
    // **LA GRANDEZZA E' LA SORGENTE DEL VALORE**, non il suo posto: domani
    // qualcun altro potrebbe mandare il fuso da un'altra schermata, e
    // `timeZoneName` sarebbe sbagliato li' come qui.
    final colpevoli = <String>[];
    var guardate = 0;
    for (final file in sorgentiDiLib()) {
      guardate++;
      final testo = file.readAsStringSync();
      if (testo.contains('timeZoneName')) colpevoli.add(file.path);
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 1.09: sorgenti guardate $guardate, che usano il '
        'nome corto del fuso ${colpevoli.length}');
    cardinaleMinimo(guardate, 100,
        cosa: 'sorgenti di lib',
        perche: 'Con un insieme vuoto la prova non guarderebbe niente.');
    expect(colpevoli, isEmpty,
        reason: 'queste sorgenti usano ancora il nome corto del fuso, che il '
            'server rifiuta: ${colpevoli.join(", ")}');
  });
}
