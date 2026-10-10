FH AGGIUNTA - LA MACCHINA DEL TEMPO

Questa e' un'aggiunta all'ordine FH, che stai lavorando adesso. Si lavora
dentro la FH, sullo stesso ramo
claude/esoteric-circle-master-order-e798aj, e non apre un ordine nuovo.

Eredita dalla FH, senza ripeterle: le regole di casa R0 a R12, le fermate,
la regola che nessun rosso si consegna, il giro delle guardie, la cartella
delle catture, il rapporto unico in fondo. Le catture di questa aggiunta
vanno nella cartella delle catture della FH. Il rapporto di questa
aggiunta e' una sezione del rapporto della FH.

Collocazione: va lavorata DOPO la parte 8 della FH, perche' la riusa.


A - LE MISURE DA FARE PRIMA DI SCRIVERE CODICE

Questa aggiunta non asserisce nessun fatto sul ramo. Le voci qui sotto
sono misure, non premesse. Fai tutte le misure, scrivi i risultati nel
rapporto e poi scrivi il codice.

Motivo: nella FG e nella FH tre premesse scritte a memoria dall'Architetto
sono risultate false e hanno causato due fermate, ai commit 2a7b6864 e
1f63c0a4. Qui il difetto e' rimosso togliendo le premesse.

A1. Trova ogni occorrenza della stringa "ritorno indietro nel tempo", in
    qualunque capitalizzazione e forma, in tutto lib e in tutti i file di
    testo degli asset. Elenca file e riga.

A2. Trova il file che disegna la scheda del menu' utente del Real Time
    Cosmo con le tre voci "Il cielo di adesso", "Il cielo della tua
    nascita", "Il ritorno indietro nel tempo". Dichiara nome del file e
    nome della classe.

A3. Dichiara il punto d'ingresso unico delle effemeridi, la sua firma
    esatta e se accetta un istante arbitrario passato dall'esterno.

A4. Dichiara la firma esatta di equatorialToHorizontal e da dove arriva
    oggi l'ora siderale locale che le viene passata.

A5. Dichiara se nel ramo le coordinate delle stelle vengono riportate
    all'equinozio della data, cioe' se la precessione e' applicata.
    Risposta si' o no, con file e riga.

A6. Dichiara come la scena del ritorno ottiene oggi la data di nascita e
    qual e' la durata della sua animazione.

A7. Dichiara se la fase della Luna disegnata dalla parte 8 della FH
    dipende da una data passata dall'esterno oppure da DateTime.now()
    letto dentro.

A8. Conta e elenca, con file e riga, tutti i punti di lib che leggono
    DateTime.now() per calcolare qualcosa di astronomico.

FERMATA: se A3 dice che il punto d'ingresso delle effemeridi non accetta
un istante arbitrario, fermati, scrivi il rapporto con le misure fatte e
aspetta. Non inventare la via.


B - LA RINOMINA

B1. Ogni occorrenza trovata in A1 diventa esattamente:
    La macchina del tempo
    Fonte: frase di Mauro del 10 ottobre 2026, "Attualmente nel menu' si
    chiama il ritorno indietro nel tempo, ma vorrei cambiarlo in la
    macchina del tempo".

B2. L'articolo resta nell'etichetta, per coerenza con le altre due voci
    della stessa scheda che hanno l'articolo.
    Fonte: misura A2 di questa aggiunta.

B3. I testi interni della scena non si toccano qui: li tratta la sezione E.


C - IL CONTROLLORE DEL TEMPO

C1. Una classe sola tiene l'istante mostrato, il luogo in uso e lo stato
    della corsa. Nome: IlTempoDelCosmo. Sta nella cartella del Real Time
    Cosmo.
    Fonte: frase di Mauro del 10 ottobre 2026, "voglio subito un ordine
    aggiuntivo", che approva la risposta dell'Architetto dello stesso
    giorno sulla sorgente unica della data.

C2. Guardia di casa nuova: un_solo_tempo. Dentro la cartella del Real Time
    Cosmo nessun file legge DateTime.now() per calcolare qualcosa di
    astronomico: l'unico punto autorizzato a leggere l'orologio di sistema
    e' IlTempoDelCosmo. Scrivila come una_luna_sola e portala nel giro
    delle guardie della FH.
    Fonte: regole di casa, guardie in uso dagli ordini precedenti.

C3. Cielo, pianeti, Luna, veli delle costellazioni, linee delle figure e
    oggetti del cielo profondo leggono l'istante da IlTempoDelCosmo.
    Nessuna data arriva da due strade diverse allo stesso disegno. La
    Luna della parte 8 della FH riceve l'istante da qui: la fase gira
    durante la corsa senza codice nuovo.

C4. I punti trovati in A8 che stanno fuori dal Real Time Cosmo non si
    toccano. Elencali nel rapporto e basta.

C5. Durante la corsa i fotogrammi al secondo sul telefono di collaudo non
    scendono sotto 50. Dichiara il numero misurato. Se scende sotto 50,
    dichiara il numero e fermati.


D - IL SELETTORE DI DATA

D1. Finestra: dal 1 gennaio 1900 al 31 dicembre 2100, estremi inclusi.
    Fuori da questa finestra non si va: il comando si blocca agli estremi,
    senza messaggi di errore.
    Fonte: frase di Mauro del 10 ottobre 2026, "va bene la finestra
    1900-2100".

D2. Default all'apertura: la data di nascita dell'utente come la tiene il
    Ritratto.
    Fonte: frase di Mauro del 10 ottobre 2026, "di default ci sara'
    selezionata la data di nascita".

D3. Se la data di nascita non c'e', il default e' la data di oggi.
    Fonte: frase di Mauro del 10 ottobre 2026, "ok le tue proposte",
    applicata al caso in cui il dato manca.

D4. L'ora: eredita l'ora di nascita. Se l'ora di nascita non c'e', le
    12:00 dell'ora locale del luogo in uso. L'ora non e' modificabile qui
    e non compare nel selettore.
    Fonte: frase di Mauro del 10 ottobre 2026, "ok le tue proposte".

D5. Il luogo: luogo di nascita quando la data mostrata e' la data di
    nascita, luogo attuale per ogni altra data. Sotto la data corre una
    riga sempre visibile che dice quale luogo si sta usando e permette di
    passare all'altro. Due sole voci, nessun campo di ricerca libero,
    nessuna schermata nuova.
    Fonte: frase di Mauro del 10 ottobre 2026, "ok le tue proposte".

D6. Il comando: tre ruote affiancate, giorno, mese, anno, nello stile
    della casa. La ruota dell'anno copre 1900 a 2100. Sopra le ruote una
    barra con due scorciatoie, "La tua nascita" e "Adesso". Il tocco su
    una scorciatoia porta la data e fa partire la corsa.

D7. Dove sta: un pannello che sale dal basso sopra la schermata della
    Macchina del tempo. Non una schermata nuova. Il cielo resta visibile
    dietro il pannello.

D8. Il 29 febbraio esiste solo negli anni bisestili: se la scelta di mese
    o anno rende la data impossibile, il giorno scala all'ultimo valido di
    quel mese, senza messaggi.

D9. Accessibilita': ogni ruota ha la sua etichetta parlata, il valore
    scelto si annuncia, il pannello si chiude col gesto di sistema e con
    un tocco fuori dal pannello. Area di tocco minima come da Linee Guida
    UX Trasversali, sezione sull'accessibilita'.
    Fonte: Linee Guida UX Trasversali, sezione sull'accessibilita'.

D10. Il ritorno al default e' la scorciatoia "La tua nascita". Nessun
     altro pulsante di ripristino.


E - LA CORSA E I TESTI

E1. Durata fissa: 6 secondi per qualunque distanza temporale. La velocita'
    del tempo simulato e' la distanza divisa per la durata. Un salto di un
    mese e un salto di ottant'anni durano lo stesso e cambia solo quanto
    vortica il cielo.
    Fonte: frase di Mauro del 10 ottobre 2026, "voglio subito un ordine
    aggiuntivo", che approva la risposta dell'Architetto dello stesso
    giorno sulla corsa a durata fissa.

E2. Direzione: indietro se la data scelta precede quella mostrata, avanti
    se la segue. Se coincidono non c'e' corsa.

E3. Durante la corsa scorre l'anno in grande al centro. Quando la data di
    arrivo e' la data di nascita, sotto l'anno compare anche l'eta' che
    scende fino a zero, esattamente come nella scena esistente, che non si
    tocca.
    Fonte: frase di Mauro, "la Scena del Ritorno e' sua: l'eta' al centro,
    STO TORNANDO INDIETRO NEL TEMPO col numero che scende a zero".

E4. La riga che corre sopra il numero:
    indietro: STO TORNANDO INDIETRO NEL TEMPO
    avanti:   STO ANDANDO AVANTI NEL TEMPO
    Maiuscole come nella scena esistente.

E5. Durante la corsa si ricalcolano solo Luna e pianeti, a ogni
    fotogramma. Le stelle non si ricalcolano: le loro coordinate sono
    fisse e il loro posto nel riquadro dipende solo dall'ora siderale, che
    e' gia' funzione dell'istante. Non ricalcolare il catalogo e non
    ricostruire i vertici delle linee delle figure a ogni fotogramma.

E6. Riduci Movimento attivo: nessuna corsa. La data cambia di colpo e
    compare direttamente il testo di arrivo.
    Fonte: Linee Guida UX Trasversali, sezione sull'accessibilita'.

E7. Un tocco durante la corsa la chiude subito e porta all'arrivo. Non
    ferma il tempo a meta'.

E8. I testi di arrivo, scritti dall'Architetto. Non vengono dal modello.
    Nessuno promette un esito. Il disclaimer non si ripete: vale quello
    unico dell'app.

    arrivo sulla data di nascita, invariato:
    QUESTO ERA IL CIELO SOPRA DI TE QUANDO SEI [NATO|NATA|VENUTO AL MONDO]

    arrivo su una data passata diversa dalla nascita:
    QUESTO ERA IL CIELO DEL <data lunga>

    arrivo sulla data di oggi:
    QUESTO E' IL CIELO DI OGGI

    arrivo su una data futura:
    QUESTO SARA' IL CIELO DEL <data lunga>

E9. Formato della data lunga: giorno in cifre, mese per nome minuscolo,
    anno in cifre. Esempio: 14 marzo 1987. Senza giorno della settimana e
    senza ora.

E10. La marca del genere si scrive a posizioni, [NATO|NATA|VENUTO AL
     MONDO], come gia' in uso nei file di lib. Nessun pulsante, nessuna
     domanda all'utente.
     Fonte: frase di Mauro, "Voglio la marca di genere e niente pulsante".

E11. Gli accenti nel codice si scrivono tipografici veri, non con
     l'apostrofo: in E8 l'apostrofo c'e' solo perche' questo blocco e'
     testo semplice. Nel codice vanno E e SARA con accento tipografico.


F - LA VERITA' DICHIARATA

F1. Nel pannello Fonti e metodo della Macchina del tempo entrano tre righe
    scritte dall'Architetto, verbatim:

    "La finestra va dal 1900 al 2100. Le posizioni dei pianeti e della
    Luna vengono dalle teorie VSOP87D ed ELP2000 nella forma pubblicata da
    Jean Meeus in Astronomical Algorithms."

    "Le posizioni delle stelle sono riferite all'equinozio del 2000 e non
    vengono riportate all'equinozio della data. Agli estremi della
    finestra lo scostamento arriva a circa 1,4 gradi, cioe' circa tre
    diametri della Luna piena."

    "Il moto proprio delle stelle non e' applicato. Dentro questa finestra
    il suo effetto non e' visibile a occhio nudo."

F2. Se la misura A5 dice che la precessione e' applicata, la seconda riga
    si riscrive con la verita' misurata e la riscrittura si dichiara nel
    rapporto.

F3. Nessuna di queste righe promette un esito, ne' salute, ne' fortuna,
    ne' protezione.


G - QUELLO CHE NON SI FA

G1. Non si mette niente nel Cosmic Passport. Nessuna voce, nessuna rotta,
    nessun aggancio.
    Fonte: frase di Mauro del 10 ottobre 2026, "Ma non fargli ancora
    mettere la voce nel Cosmic Passport".

G2. Non si applica la precessione degli equinozi.

G3. Non si applica il moto proprio delle stelle.

G4. Non si cambia nessuna voce della FH gia' lavorata. Questa aggiunta
    estende, non riscrive.

G5. Non si rende modificabile l'ora del giorno, non si aggiunge una
    ricerca di luoghi, non si salvano le date scelte dall'utente.

G6. Nessun limite per tier. La Macchina del tempo e' intera per tutti,
    Viandante compreso.
    Fonte: frase di Mauro dell'8 ottobre 2026, "nessun limite per tier,
    l'esperienza resta intera e wow per tutti".


H - PROVA DI VISTA

Catture nella cartella delle catture della FH, con prefisso "aggiunta".
Il giudizio visivo e' di Mauro: servono le immagini, non le descrizioni.

H1. il menu' utente con la voce rinominata
H2. il pannello del selettore aperto, con la data di nascita selezionata
H3. il cielo del 1 gennaio 1900
H4. il cielo del 31 dicembre 2100
H5. il cielo della data di nascita, con il testo di arrivo visibile
H6. registrazione della corsa dalla nascita al 2100, Riduci Movimento spento
H7. cattura con Riduci Movimento attivo, che mostra il salto senza corsa
H8. la riga del luogo nei suoi due stati
H9. il pannello Fonti e metodo con le tre righe della sezione F

Per H6 e H7 serve spegnere e riaccendere Riduci Movimento sul telefono di
collaudo: non lo fai tu, la richiesta la giri a Mauro.


I - RAPPORTO

Nella sezione del rapporto della FH dedicata a questa aggiunta:
- i risultati di tutte le misure da A1 a A8
- l'elenco dei file toccati
- i fotogrammi al secondo misurati durante la corsa, come numero
- l'esito della guardia un_solo_tempo
- l'elenco delle catture prodotte
- se la seconda riga di F1 e' stata riscritta per via di A5

FINE AGGIUNTA
