import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// **NESSUN ROSSO ATTRAVERSA UNA CONSEGNA.** Ordine CZ, voce 14.
///
/// **La domanda dell'ordine**: CI.04 era rossa dall'ordine CT e nessuno se
/// n'era accorto. Accertarne la provenienza era la parte facile; la parte
/// grave e' **come abbia fatto un rosso ad attraversare una consegna intera
/// senza fermarla**. Finche' quella falla e' aperta, ogni dichiarazione di
/// guardie tutte verdi vale meno di quello che sembra.
///
/// **LE TRE RISPOSTE, lette negli strumenti e non supposte.**
///
/// **UNO: lo sbarramento gira su tutte le guardie.** `tool/sbarramento.sh`
/// esegue `flutter test "$@"`, e senza argomenti quello e' la suite intera.
/// `codemagic.yaml` lo invoca senza argomenti. Non esiste nessun sottoinsieme
/// scelto da qualcuno: gli argomenti servono solo a provare lo sbarramento
/// stesso su un file, ed e' scritto nel suo commento.
///
/// **DUE: esiste una via, ed e' che LA CONSEGNA NON LO CHIAMA.**
/// `tool/consegna.py` non nomina lo sbarramento in nessun punto: sono due
/// strumenti separati, e nulla obbliga il primo a essere passato prima del
/// secondo. Chi costruisce l'archivio e lo carica senza aver lanciato lo
/// sbarramento consegna su qualunque rosso, **senza scavalco e senza lasciare
/// traccia**. Lo scavalco dichiarato, `SPEDISCO_SU_ROSSO`, almeno si stampa e
/// va riportato nel rapporto: saltare lo sbarramento invece non si vede.
///
/// **TRE: questo file.** La consegna deve pretendere l'esito dello
/// sbarramento, e l'esito deve essere di questo albero e non di ieri.
///
/// **REGOLA H**: non basta che la consegna nomini lo sbarramento. Si prova
/// anche che **non esista una via per consegnare senza di lui**, cioe' che il
/// controllo non sia un avviso stampato e poi ignorato.
void main() {
  final consegna = File('tool/consegna.py');

  test('Lo strumento della consegna esiste ed e\' stato letto', () {
    expect(consegna.existsSync(), isTrue,
        reason: 'tool/consegna.py non esiste: questa prova guarderebbe il '
            'nulla');
    expect(consegna.readAsStringSync().length, greaterThan(2000),
        reason: 'tool/consegna.py e\' vuoto o non e\' stato letto');
  });

  test('LA CONSEGNA PRETENDE L\'ESITO DELLO SBARRAMENTO', () {
    final codice = consegna
        .readAsStringSync()
        .split('\n')
        .where((r) => !r.trimLeft().startsWith('#'))
        .join('\n');
    expect(codice.contains('sbarramento'), isTrue,
        reason: 'tool/consegna.py non nomina lo sbarramento in nessuna riga di '
            'codice: si puo\' costruire un archivio e caricarlo senza che '
            'nessuna prova sia mai girata, ed e\' cosi\' che CI.04 ha '
            'attraversato una consegna intera');
  });

  test('REGOLA H: e non e\' un avviso che si puo\' ignorare', () {
    final codice = consegna
        .readAsStringSync()
        .split('\n')
        .where((r) => !r.trimLeft().startsWith('#'))
        .join('\n');
    // Il controllo deve **fermare** la consegna, non stamparle accanto una
    // riga. Si cerca l'uscita con errore nella stessa funzione che guarda lo
    // sbarramento: senza, la falla resta aperta e questa prova sarebbe verde
    // su una consegna che avvisa e carica lo stesso.
    // **SI CERCA IL FATTO, NON IL TOKEN.** Il primo giro cercava `sys.exit`
    // e cadeva su una consegna che si ferma benissimo: usa `raise SystemExit`.
    // E' la famiglia della guardia legata al nome invece che al
    // comportamento, che questo progetto ha gia' pagato piu' volte.
    final siFerma = codice.contains('SystemExit');
    expect(siFerma, isTrue,
        reason: 'la consegna non esce mai con errore: qualunque controllo '
            'aggiunto sarebbe un avviso, e un avviso non ferma niente');

    // E il controllo dello sbarramento deve stare **fra quelli che fermano**,
    // non fra le righe che stampano.
    expect(codice.contains('SBARRAMENTO NON PASSATO'), isTrue,
        reason: 'la consegna nomina lo sbarramento ma non si ferma quando non '
            'e passato: il controllo sarebbe decorativo');
    expect(codice.contains('SBARRAMENTO_PASSATO'), isTrue,
        reason: 'manca la prova che lo sbarramento sia passato su QUESTO '
            'albero: senza un dato che lo dichiari, la consegna non ha modo '
            'di distinguere una suite verde di adesso da una di ieri');
  });

  test('E IL GETTONE PORTA DAVVERO IL NUMERO, non una riga vuota', () {
    // **IL DIFETTO CHE QUESTA PROVA NASCE PER PRENDERE.** Ordine CZ, dopo lo
    // sbarramento finale. Il gettone si scriveva cosi':
    //
    //     SBARRAMENTO_PASSATO
    //     numero=
    //     prove=
    //
    // La consegna confronta il numero del gettone col numero dell'archivio:
    // con un numero vuoto **nessuna consegna sarebbe mai passata**, e la
    // porta che avevo appena chiuso si sarebbe richiusa su di me.
    //
    // **La causa e' la famiglia gia' nota**: la funzione era stata scritta
    // con un heredoc, e il `\1` che riferisce il gruppo catturato era
    // arrivato nel file come il byte di controllo 0x01. Le espressioni
    // sembravano giuste a occhio e sostituivano con niente.
    //
    // **La grandezza misurata non e' la forma della riga, e' il numero che
    // ne esce.** Si prende l'espressione dallo script vero, la si applica a
    // una riga nota, e si guarda cosa produce.
    final script = File('tool/sbarramento.sh');
    expect(script.existsSync(), isTrue,
        reason: 'tool/sbarramento.sh non esiste: questa prova guarderebbe il '
            'nulla');
    final righe = script.readAsLinesSync();

    /// Da `sed -nE 's/PATTERN/SOSTITUZIONE/p'` tira fuori le due meta'.
    (String, String)? espressioneDi(String contrassegno) {
      for (final r in righe) {
        if (!r.contains(contrassegno)) continue;
        final apri = r.indexOf("'s/");
        if (apri < 0) continue;
        final chiudi = r.indexOf("/p'", apri);
        if (chiudi < 0) continue;
        final corpo = r.substring(apri + 3, chiudi);
        final taglio = corpo.lastIndexOf('/');
        if (taglio < 0) continue;
        return (corpo.substring(0, taglio), corpo.substring(taglio + 1));
      }
      return null;
    }

    void provala(String contrassegno, String riga, String atteso, String cosa) {
      final pezzi = espressioneDi(contrassegno);
      expect(pezzi, isNotNull,
          reason: 'nello script non si trova piu\' l\'espressione che ricava '
              '$cosa: o l\'hanno tolta, o questa prova non sa piu\' dove '
              'guardare, e in tutti e due i casi non sta misurando niente');
      final (pattern, sostituzione) = pezzi!;
      // La sostituzione deve **riferire un gruppo**. Un byte di controllo,
      // uno spazio o il vuoto passerebbero qualunque controllo sulla forma
      // della riga, e sono esattamente cio' che e' successo.
      expect(sostituzione, matches(RegExp(r'^\\[1-9]$')),
          reason: 'l\'espressione che ricava $cosa sostituisce con '
              '"${sostituzione.codeUnits}" invece che col gruppo catturato: '
              'il gettone nascerebbe con la riga vuota');
      final numero = int.parse(sostituzione.substring(1));
      final presa = RegExp(pattern).firstMatch(riga);
      expect(presa, isNotNull,
          reason: 'l\'espressione che ricava $cosa non aggancia la riga '
              '"$riga": sul rapporto vero non prenderebbe niente');
      expect(presa!.group(numero), atteso,
          reason: 'da "$riga" l\'espressione ricava '
              '"${presa.group(numero)}" invece di "$atteso"');
    }

    provala('NUMERO=', 'version: 0.1.0+2237', '2237',
        'il numero della build dal pubspec');
    provala('PASSATE=', '22:35 +4024 -0: All tests passed!', '4024',
        'il conto delle prove passate dal registro');

    // **E IL CONTO SI PRENDE DAL POSTO GIUSTO DEL REGISTRO.** Secondo difetto
    // dello stesso gettone: dopo il rapporto di `flutter test` lo sbarramento
    // aggiunge righe sintetiche `00:00 +0 -1` per le cadute delle altre
    // suite, e la pipeline chiudeva con `tail -1`. Il gettone ha dichiarato
    // **prove=0 dopo quattromilasettecento prove passate**, che e' un numero
    // falso stampato con la faccia di un numero vero.
    //
    // **Qui si misura la scelta, non la forma della riga.** Si prende la
    // pipeline dallo script, si costruisce un registro finto fatto come
    // quello vero (il rapporto, e dopo di lui la riga sintetica), e si guarda
    // che numero ne esce.
    final indice = righe.indexWhere((r) => r.contains('PASSATE='));
    expect(indice, greaterThanOrEqualTo(0),
        reason: 'nello script non si trova piu\' la riga che conta le prove');
    final pipeline = StringBuffer();
    for (var i = indice; i < righe.length; i++) {
      pipeline.write(righe[i]);
      if (righe[i].contains(')"')) break;
    }
    const registroFinto = [
      '22:35 +4725 -3: Some tests failed.',
      '00:00 +0 -1: SCALA 1,3: Cattura l\'Oroscopo [E]',
    ];
    final pattern = espressioneDi('PASSATE=')!.$1;
    final raccolti = <int>[
      for (final r in registroFinto)
        if (RegExp(pattern).firstMatch(r) != null)
          int.parse(RegExp(pattern).firstMatch(r)!.group(1)!),
    ];
    expect(raccolti.length, 2,
        reason: 'l\'espressione non aggancia tutte e due le righe del '
            'registro finto: questa prova non sta misurando la scelta');
    // Se la pipeline ordina, vale il massimo; se chiude con `tail` e basta,
    // vale l'ultima riga incontrata. E' esattamente quello che fa la conchiglia.
    final ordina = pipeline.toString().contains('sort -n');
    final uscita = ordina
        ? raccolti.reduce((a, b) => a > b ? a : b)
        : raccolti.last;
    // ignore: avoid_print
    print('ORDINE CZ VOCE 14: dal registro finto il gettone ricava $uscita '
        'prove, e la pipeline ${ordina ? "ordina" : "prende l ultima riga"}');
    expect(uscita, 4725,
        reason: 'dal registro il gettone ricava $uscita prove invece di 4725: '
            'pesca la riga sintetica che viene dopo il rapporto, e dichiara '
            'un numero falso');

    // **E IL GETTONE VERO, se e' li'.** Viene scritto dopo la suite, quindi
    // dentro la suite puo' non esistere: quando esiste pero' e' il fatto in
    // persona, e non si guarda un'altra volta la forma dell'espressione.
    final gettone = File('build/sbarramento_passato.txt');
    if (!gettone.existsSync()) {
      // ignore: avoid_print
      print('ORDINE CZ VOCE 14: il gettone non c\'e\' ancora, e va bene: si '
          'scrive alla fine della suite. Provate le due espressioni che lo '
          'riempiono');
      return;
    }
    final dentro = gettone.readAsLinesSync();
    for (final campo in const ['numero', 'prove']) {
      final riga = dentro.firstWhere((r) => r.startsWith('$campo='),
          orElse: () => '');
      final valore = riga.contains('=') ? riga.split('=')[1].trim() : '';
      // ignore: avoid_print
      print('ORDINE CZ VOCE 14: il gettone dice $campo="$valore"');
      expect(int.tryParse(valore), isNotNull,
          reason: 'il gettone porta $campo="$valore", che non e\' un numero: '
              'la consegna lo confronta col numero dell\'archivio e non '
              'passerebbe mai');
    }
  });
}
