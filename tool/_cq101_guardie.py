# -*- coding: utf-8 -*-
"""Le due guardie che la callable nuova dell'ordine CQ voce 1.01 ha reso rosse."""
NL = chr(10)
CR = chr(13)


def cambia(percorso, vecchio, nuovo, quante=1):
    grezzo = open(percorso, 'rb').read().decode('utf-8')
    crlf = CR in grezzo
    s = grezzo.replace(CR + NL, NL) if crlf else grezzo
    assert s.count(vecchio) == quante, (percorso, s.count(vecchio),
                                        vecchio[:70])
    s = s.replace(vecchio, nuovo)
    open(percorso, 'wb').write(
        (s.replace(NL, CR + NL) if crlf else s).encode('utf-8'))
    assert nuovo.split(NL)[0] in open(percorso, 'rb').read().decode('utf-8')
    print('FATTO', percorso)


# --- 1. il conto delle callable segue il dato --------------------------
cambia('test/il_cerchio_custodisce_il_cammino_test.dart',
       """    expect(callable.length, 10,""",
       """    // **UNDICI E NON PIU' DIECI, e il numero segue il dato.** Ordine CQ voce
    // 1.01, 3 settembre 2026: e' entrata `attivaIlPianoInDemo`, la callable
    // che scrive sul server il piano scelto col pulsante "Attiva in Demo".
    // Prima quel pulsante cambiava il piano SOLO dentro il telefono, il
    // server continuava a leggere `free` per tutti, e il fondatore vedeva il
    // limite giornaliero raggiunto con l'Illuminato attivo. La callable e'
    // sbarrata a chiave: senza la variabile DEMO_APERTA a uno risponde
    // failed-precondition e non scrive niente.
    expect(callable.length, 11,""")

# --- 2. la finestra del congedo finisce dove finisce la funzione -------
cambia('test/il_menu_ordinato_e_la_cancellazione_protetta_test.dart',
       """    final congedo = server.substring(
        server.indexOf('async function scriviIlCongedo'),
        server.indexOf('export const azzeraIDatiDelCerchio'));""",
       """    // **LA FINESTRA FINISCE DOVE FINISCE LA FUNZIONE, non alla prossima
    // export.** Ordine CQ voce 1.01, 3 settembre 2026, e la guardia si e'
    // fatta trovare cosi': fra `scriviIlCongedo` e `azzeraIDatiDelCerchio` e'
    // entrata una callable nuova, che di `uid` ne nomina due, e la prova e'
    // diventata rossa senza che il congedo fosse stato toccato. **Misurava
    // una finestra che chiunque poteva allargare scrivendoci dentro**, cioe'
    // era una guardia legata alla forma del file invece che al fatto. Adesso
    // la finestra e' il corpo della funzione, che finisce alla sua parentesi
    // in colonna zero.
    final chiusura = String.fromCharCodes([10, 125, 10]);
    final inizio = server.indexOf('async function scriviIlCongedo');
    expect(inizio, greaterThanOrEqualTo(0),
        reason: 'la funzione del congedo non esiste piu');
    final fine = server.indexOf(chiusura, inizio);
    expect(fine, greaterThan(inizio),
        reason: 'non si trova la fine del corpo del congedo');
    final congedo = server.substring(inizio, fine);""")
