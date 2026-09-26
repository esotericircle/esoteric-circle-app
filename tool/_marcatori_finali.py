# -*- coding: utf-8 -*-
"""CQ5: i marcatori finali. CQ chiude a VOCI_APERTE 0, CP.08 si chiude."""
NL = chr(10)
CR = chr(13)


def cambia(percorso, vecchio, nuovo, quante=1):
    grezzo = open(percorso, 'rb').read().decode('utf-8')
    crlf = CR in grezzo
    s = grezzo.replace(CR + NL, NL) if crlf else grezzo
    assert s.count(vecchio) == quante, (percorso, s.count(vecchio),
                                        vecchio[:60])
    s = s.replace(vecchio, nuovo)
    open(percorso, 'wb').write(
        (s.replace(NL, CR + NL) if crlf else s).encode('utf-8'))
    print('FATTO', percorso, '|', vecchio[:44])


Q = 'docs/ordini/ORDINE_CQ_MANIFESTO.md'
P = 'docs/ordini/ORDINE_CP_MANIFESTO.md'

# --- le sei aperte si chiudono -----------------------------------------
cambia(Q, "- **CQ.16** Pezzo secondo 2.01, i cinque Doni rivisti frase per "
          "frase. **APERTA**: i cinque Doni sono stati misurati e liberati "
          "dal compito che li apriva, e la riscrittura di ogni responso non "
          "e' stata fatta.",
       "- **CQ.16** Pezzo secondo 2.01, i cinque Doni rivisti frase per "
       "frase. **CHIUSA**: i quattro strati della legge dei testi sono "
       "misurati su tutte e quattro le schermate dei cinque Doni, e due non "
       "li avevano. L'Arcano non portava nessuna fonte; il Tramonto la aveva "
       "solo dietro un pulsante in barra, cioe' chi legge il responso non "
       "incontrava mai da dove viene la runa. **Una risposta che non si puo' "
       "risalire chiede di essere creduta.**")

cambia(Q, "- **CQ.19** Pezzo secondo 2.04, la parola del giorno non dice a "
          "cosa serve. **APERTA.**",
       "- **CQ.19** Pezzo secondo 2.04, la parola del giorno non dice a cosa "
       "serve. **CHIUSA**: l'etichetta diceva \"Parola del giorno\", che e' "
       "il nome di una casella. Adesso dice di portarsela dietro, e sotto c'e' "
       "scritto dove va a finire.")

cambia(Q, "- **CQ.24** Pezzo secondo 2.09, la domanda della parola senza "
          "risposta. **APERTA.**",
       "- **CQ.24** Pezzo secondo 2.09, la domanda della parola senza "
       "risposta. **CHIUSA**: il richiamo della sera diceva che parola era e "
       "finiva li', cioe' un fatto e non una risposta. Adesso dice che ha "
       "attraversato il giorno e che adesso si chiude.")

cambia(Q, "- **CQ.25** Pezzo secondo 2.10, il responso della runa singola "
          "troppo lungo. **APERTA.**",
       "- **CQ.25** Pezzo secondo 2.10, il responso della runa singola troppo "
       "lungo. **CHIUSA**: misurato, la scheda intera porta 264 caratteri "
       "contro i 50 della sola risposta, **cinque volte e un quarto**. A una "
       "runa sola il simbolo, la Voce e la strofa stanno dietro una porta che "
       "si apre in posto; a tre e a cinque rune restano dove erano, perche' "
       "li' sono il corpo della lettura.")

cambia(Q, "- **CQ.29** Pezzo secondo 2.15, il ponte fra il motore delle date "
          "e la chat. **APERTA.**",
       "- **CQ.29** Pezzo secondo 2.15, il ponte fra il motore delle date e "
       "la chat. **CHIUSA**: il blocco entra nell'istruzione di sistema con "
       "al massimo tre eventi e il prossimo gradino del Cammino, senza "
       "promettere niente, e se non c'e' niente da dire non compare affatto. "
       "Passa dal contesto natale e non da un parametro nuovo, perche' "
       "`reply` e' implementato da undici doppioni nelle prove.")

cambia(Q, "- **CQ.30** Pezzo secondo 2.16, i promemoria, misurare e non "
          "costruire. **APERTA.**",
       "- **CQ.30** Pezzo secondo 2.16, i promemoria, misurare e non "
       "costruire. **CHIUSA**: la misura sta in `docs/promemoria/misura.md`. "
       "Ventuno eventi con una data calcolabile entro l'orizzonte, venti "
       "entro l'anno, cinque personali, e **sedici avvisi in un anno**, uno "
       "ogni ventitre giorni. Non e' un flusso.")

# --- le due fermate che non poggiavano su una decisione -----------------
cambia(Q, "- **CQ.21** Pezzo secondo 2.06, lo stesso difetto sul Tramonto. "
          "**FERMATA SU PREMESSA FALSA**",
       "- **CQ.21** Pezzo secondo 2.06, lo stesso difetto sul Tramonto. "
       "**CHIUSA**, e la premessa era falsa")

cambia(Q, "- **CQ.23** Pezzo secondo 2.08, la runa rovesciata senza lettura. "
          "**FERMATA SU PREMESSA FALSA**",
       "- **CQ.23** Pezzo secondo 2.08, la runa rovesciata senza lettura. "
       "**CHIUSA**, e la premessa era falsa")

cambia(Q, "- **CQ.22** Pezzo secondo 2.07, il Sigillo del Giorno non dice a "
          "cosa serve. **FERMATA IN ATTESA DI DECISIONE**: nell'app non "
          "esiste nessuno \"Sigillo del Giorno\". Ci sono il Sigillo del "
          "Sogno, il Sigillo del Cerchio e il Sigillo dell'Intenzione, e "
          "serve sapere quale dei tre.",
       "- **CQ.22** Pezzo secondo 2.07, il Sigillo del Giorno non dice a cosa "
       "serve. **CHIUSA**, e la fermata era una ricerca fatta male: **il "
       "Sigillo del Giorno esiste**, e' la bindrune che chiude ogni gettata "
       "di rune. Cercarlo fra i NOMI delle schermate invece che DENTRO le "
       "schermate ha prodotto una fermata dove c'era lavoro. Sotto il disegno "
       "c'era la nota della tradizione, che dice che cosa E' una bindrune e "
       "niente su cosa te ne fai: adesso c'e' prima la riga dell'uso, e la "
       "tradizione scende in fondo dove sta la fonte.")

# --- i marcatori seguono il dato ---------------------------------------
cambia(Q, "VOCI_TOTALI: 32" + NL + "VOCI_CHIUSE: 22" + NL + "VOCI_APERTE: 6" +
       NL + "VOCI_FERMATE_SU_PREMESSA_FALSA: 2" + NL +
       "VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 1" + NL +
       "VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 1",
       "VOCI_TOTALI: 32" + NL + "VOCI_CHIUSE: 31" + NL + "VOCI_APERTE: 0" +
       NL + "VOCI_FERMATE_SU_PREMESSA_FALSA: 0" + NL +
       "VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0" + NL +
       "VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 1")

# --- CP.08 si chiude col criterio adottato -----------------------------
cambia(P, "- **CP.08** La simulazione di un anno. **FERMATA IN ATTESA DI "
          "DECISIONE**: il criterio di accettazione e' proposto e **non "
          "approvato dal fondatore**. La simulazione c'e' ed e' verde, ma il "
          "numero che la dichiara buona non e' ancora stato deciso.",
       "- **CP.08** La simulazione di un anno. **CHIUSA**, col criterio "
       "adottato dall'ordine CQ voce 5.03: nessun giorno dell'anno porta piu' "
       "di TRE feste. **Non c'era nessuna decisione del fondatore a fermare "
       "questa voce**, c'era una proposta mia che aspettava, e per la REGOLA "
       "G una voce che aspetta una decisione mai chiesta non e' fermata, e' "
       "aperta con un altro nome. Il numero combacia col massimo misurato, "
       "cioe' non lascia margine: se un cielo piu' ricco ne producesse "
       "quattro, la prova cadrebbe il giorno stesso.")

cambia(P, "VOCI_CHIUSE: 8", "VOCI_CHIUSE: 9")
cambia(P, "VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 1",
       "VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0")

print('MARCATORI AGGIORNATI')
