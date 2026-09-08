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
}
