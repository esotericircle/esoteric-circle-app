Seconda stesura dell'aggiunta, arrivata il 10 ottobre 2026 mentre si
facevano le misure della prima: sostituisce
docs/ordini/ORDINE_FH_AGGIUNTA_MACCHINA_DEL_TEMPO.md, che resta come
memoria. Il testo del fondatore e' qui sotto per intero, e in fondo le sue
due frasi arrivate dopo.

---

FH AGGIUNTA - LA MACCHINA DEL TEMPO E LA LUNA PROTAGONISTA

Questa e' un'aggiunta all'ordine FH, che stai lavorando adesso. Si lavora
dentro la FH, sullo stesso ramo
claude/esoteric-circle-master-order-e798aj, e non apre un ordine nuovo.

Eredita dalla FH, senza ripeterle: le regole di casa R0 a R12, le fermate,
la regola che nessun rosso si consegna, il giro delle guardie, la cartella
delle catture, il rapporto unico in fondo. Le catture di questa aggiunta
vanno nella cartella delle catture della FH. Il rapporto di questa
aggiunta e' una sezione del rapporto della FH.

Collocazione: si lavora DOPO la parte 8 della FH, perche' la riusa.

Catture del fondatore gia' nella cartella delle catture della FH, da
guardare prima di cominciare:
  anteprima_mauro_2026-10-10_luna_01.png   (0 ANNI, 22 novembre 1988)
  anteprima_mauro_2026-10-10_luna_02.png   (34 ANNI, 26 giugno 2022)


A - LE MISURE DA FARE PRIMA DI SCRIVERE CODICE

Questa aggiunta non asserisce nessun fatto sul ramo. Le voci qui sotto
sono misure, non premesse. Fai tutte le misure, scrivi i risultati nel
rapporto e poi scrivi il codice.

Motivo: nella FG e nella FH tre premesse scritte a memoria dall'Architetto
sono risultate false e hanno causato due fermate, ai commit 2a7b6864 e
1f63c0a4. Qui il difetto e' rimosso togliendo le premesse.

A1. Cerca in tutto lib e in tutti i file di testo degli asset queste tre
    forme, in qualunque capitalizzazione:
      "ritorno indietro nel tempo"
      "ritorno nel tempo"
      "Ritorno nel Tempo"
    Elenca ogni occorrenza con file e riga. Il titolo che compare nelle
    due anteprime del fondatore e' "Il ritorno nel tempo", cioe' la forma
    corta: deve risultare dalla ricerca.
    Fonte: catture anteprima_mauro_2026-10-10_luna_01.png e _02.png.

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

A6. Dichiara come la scena del ritorno ottiene oggi la data di nascita,
    qual e' la durata della sua animazione e dove sta il blocco di testo
    (numero, parola ANNI, data, riga che corre) in percentuale
    dell'altezza dello schermo.

A7. Dichiara come viene calcolato oggi il diametro sullo schermo della
    Luna e dei pianeti, e il raggio dell'alone di ciascuno. Dichiara se
    la Luna ha una scala propria oppure la stessa dei pianeti.

A8. Conta e elenca, con file e riga, tutti i punti di lib che leggono
    DateTime.now() per calcolare qualcosa di astronomico.

FERMATA: se A3 dice che il punto d'ingresso delle effemeridi non accetta
un istante arbitrario, fermati, scrivi il rapporto con le misure fatte e
aspetta. Non inventare la via.


B - LA RINOMINA

B1. Ogni occorrenza trovata in A1 diventa esattamente:
    La macchina del tempo
    Vale per la voce del menu' utente e per il titolo della schermata.
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
    Nessuna data arriva da due strade diverse allo stesso disegno. La Luna
    della parte 8 della FH riceve l'istante da qui: la fase gira durante
    la corsa senza codice nuovo.

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


E - LA CORSA, I NUMERI E I TESTI

E1. Durata fissa: 6 secondi per qualunque distanza temporale. La velocita'
    del tempo simulato e' la distanza divisa per la durata. Un salto di un
    mese e un salto di ottant'anni durano lo stesso e cambia solo quanto
    vortica il cielo.
    Fonte: frase di Mauro del 10 ottobre 2026, "voglio subito un ordine
    aggiuntivo", che approva la risposta dell'Architetto dello stesso
    giorno sulla corsa a durata fissa.

E2. Direzione: indietro se la data scelta precede quella mostrata, avanti
    se la segue. Se coincidono non c'e' corsa.

E3. Quando l'arrivo e' la data di nascita, il blocco dei numeri resta
    esattamente quello che c'e' oggi nelle due anteprime del fondatore:
    eta' in grande, parola ANNI, data per esteso che scorre, riga che
    corre. Non si tocca.
    Fonte: catture anteprima_mauro_2026-10-10_luna_01.png e _02.png, piu'
    la frase di Mauro, "la Scena del Ritorno e' sua: l'eta' al centro, STO
    TORNANDO INDIETRO NEL TEMPO col numero che scende a zero".

E4. Quando l'arrivo NON e' la data di nascita, al posto dell'eta' in
    grande scorre l'ANNO in grande, senza la parola ANNI. Sotto resta la
    data per esteso che scorre e sotto ancora la riga che corre. Stesso
    carattere, stessa dimensione, stesso oro.
    Fonte: frase di Mauro del 10 ottobre 2026, "vorrei che l'utente possa
    selezionare la data a cui vuole riavvolgere il tempo oppure avanzare
    nel futuro".

E5. La riga che corre:
    indietro: STO TORNANDO INDIETRO NEL TEMPO
    avanti:   STO ANDANDO AVANTI NEL TEMPO
    Maiuscole come nella scena esistente.

E6. Il blocco di testo si sposta in basso. Oggi sta nella fascia alta e
    occupa il centro del riquadro, che e' il posto della Luna. Il blocco
    si ancora al 72 per cento dell'altezza dello schermo, centrato in
    orizzontale, e non copre mai la Luna.
    Fonte: frase di Mauro del 10 ottobre 2026, "la luna e' molto piccola.
    Non dovrebbe essere piu' grande e davanti a tutti?", piu' le due
    catture, dove il testo occupa il centro.

E7. Il testo di arrivo si ancora al 78 per cento dell'altezza, su due
    righe al massimo.

E8. Durante la corsa si ricalcolano solo Luna e pianeti, a ogni
    fotogramma. Le stelle non si ricalcolano: le loro coordinate sono
    fisse e il loro posto nel riquadro dipende solo dall'ora siderale, che
    e' gia' funzione dell'istante. Non ricalcolare il catalogo e non
    ricostruire i vertici delle linee delle figure a ogni fotogramma.

E9. Riduci Movimento attivo: nessuna corsa. La data cambia di colpo e
    compare direttamente il testo di arrivo.
    Fonte: Linee Guida UX Trasversali, sezione sull'accessibilita'.

E10. Un tocco durante la corsa la chiude subito e porta all'arrivo. Non
     ferma il tempo a meta'.

E11. I testi di arrivo, scritti dall'Architetto. Non vengono dal modello.
     Nessuno promette un esito. Il disclaimer non si ripete: vale quello
     unico dell'app.

     arrivo sulla data di nascita:
     QUESTO ERA IL CIELO SOPRA DI TE QUANDO SEI [NATO|NATA|VENUTO AL MONDO]

     arrivo su una data passata diversa dalla nascita:
     QUESTO ERA IL CIELO DEL <data lunga>

     arrivo sulla data di oggi:
     QUESTO E' IL CIELO DI OGGI

     arrivo su una data futura:
     QUESTO SARA' IL CIELO DEL <data lunga>

E12. Formato della data lunga: giorno in cifre, mese per nome minuscolo,
     anno in cifre. Esempio: 14 marzo 1987. Senza giorno della settimana e
     senza ora. Lo stesso formato gia' in uso nelle due anteprime.

E13. La marca del genere si scrive a posizioni, [NATO|NATA|VENUTO AL
     MONDO], come gia' in uso nei file di lib. Nessun pulsante, nessuna
     domanda all'utente.
     Fonte: frase di Mauro, "Voglio la marca di genere e niente pulsante".

E14. Gli accenti nel codice si scrivono tipografici veri, non con
     l'apostrofo: in E11 l'apostrofo c'e' solo perche' questo blocco e'
     testo semplice. Nel codice vanno E e SARA con accento tipografico.


F - LA LUNA PROTAGONISTA

Misura fatta dall'Architetto sulla cattura
anteprima_mauro_2026-10-10_luna_01.png, da cui nasce questa sezione: il
disco lunare e' 53 pixel; la distanza fra le Pleiadi e Aldebaran, che nel
cielo vero e' 14,2 gradi, nella cattura e' 210 pixel, quindi un grado vale
14,8 pixel; la Luna vera, 0,52 gradi, dovrebbe essere 7,7 pixel. La Luna
e' gia' disegnata circa sette volte piu' grande del vero. Il difetto non
e' la scala: e' che non e' protagonista.

F1. Durante la corsa la camera si aggancia alla Luna. Il centro del
    riquadro segue la posizione della Luna per tutta la durata della
    corsa e il cielo le gira attorno. La camera puo' scendere sotto
    l'orizzonte, perche' la visione e' a 360 gradi.
    Fonte: frase di Mauro dell'8 ottobre 2026, "Anche la macchina del
    tempo, secondo me sarebbe piu' d'impatto se si vedesse la luna che
    cambia le fasi e tutte il cosmo gira intorno".

F2. Durante la corsa la Luna cresce con un fattore di scena: parte da 1,
    arriva a 5 al venti per cento della corsa, resta a 5 fino all'ottanta
    per cento, torna a 1 negli ultimi venti per cento. All'arrivo la Luna
    e' alla stessa scala di prima della corsa.
    Fonte: frase di Mauro del 10 ottobre 2026, "la luna e' molto piccola.
    Non dovrebbe essere piu' grande e davanti a tutti?".

F3. La licenza di scena vive solo dentro la corsa. All'arrivo la camera si
    stacca dalla Luna, la scala torna quella vera e il cielo resta
    riconoscibile quando l'utente alza il telefono. Nessuna scala falsa
    sopravvive alla fine dell'animazione.
    Fonte: frase di Mauro dell'8 ottobre 2026, "ma non so se si puo' fare
    perche' perderebbe di credibilita' forse".

F4. Durante la corsa l'orizzonte e la terra si disegnano al venti per
    cento di opacita', cosi' si capisce dove sono senza che coprano la
    scena. All'arrivo tornano pieni.

F5. La Luna si disegna per ultima fra gli oggetti del cielo: sopra le
    stelle, sopra le linee delle figure, sopra i veli delle costellazioni,
    sopra gli oggetti del cielo profondo, sopra i pianeti.

F6. La Luna ha un alone proprio, piu' ampio di quello di qualunque
    pianeta. Nessun pianeta ha un alone di raggio superiore al raggio del
    disco lunare a riposo. Nella cattura
    anteprima_mauro_2026-10-10_luna_01.png il pianeta sotto la Luna ha un
    alone piu' grande della Luna stessa e le ruba la scena: va corretto.
    Fonte: cattura anteprima_mauro_2026-10-10_luna_01.png.

F7. Il terminatore della fase si vede sempre, anche quando la Luna e'
    piena o quasi piena: in fase piena il bordo del disco resta distinto
    dall'alone, cosi' si legge come Luna e non come una luce. Nella
    cattura 01 la Luna e' quasi piena e si legge come un disco bianco
    uniforme.
    Fonte: cattura anteprima_mauro_2026-10-10_luna_01.png.

F8. Fuori dalla corsa, cioe' nel cielo fermo, la camera non segue la Luna
    e la scala resta quella attuale. Questa sezione non cambia niente del
    cielo fermo, a parte F5, F6 e F7, che valgono sempre.


G - LA VERITA' DICHIARATA

G1. Nel pannello Fonti e metodo della Macchina del tempo entrano quattro
    righe scritte dall'Architetto, verbatim:

    "La finestra va dal 1900 al 2100. Le posizioni dei pianeti e della
    Luna vengono dalle teorie VSOP87D ed ELP2000 nella forma pubblicata da
    Jean Meeus in Astronomical Algorithms."

    "Le posizioni delle stelle sono riferite all'equinozio del 2000 e non
    vengono riportate all'equinozio della data. Agli estremi della
    finestra lo scostamento arriva a circa 1,4 gradi, cioe' circa tre
    diametri della Luna piena."

    "Il moto proprio delle stelle non e' applicato. Dentro questa finestra
    il suo effetto non e' visibile a occhio nudo."

    "Durante l'animazione la Luna viene ingrandita per renderla leggibile.
    Quando l'animazione finisce torna alla sua misura, che e' quella del
    cielo che vedi alzando il telefono."

G2. Se la misura A5 dice che la precessione e' applicata, la seconda riga
    si riscrive con la verita' misurata e la riscrittura si dichiara nel
    rapporto.

G3. Nessuna di queste righe promette un esito, ne' salute, ne' fortuna,
    ne' protezione.


H - QUELLO CHE NON SI FA

H1. Non si mette niente nel Cosmic Passport. Nessuna voce, nessuna rotta,
    nessun aggancio.
    Fonte: frase di Mauro del 10 ottobre 2026, "Ma non fargli ancora
    mettere la voce nel Cosmic Passport".

H2. Non si applica la precessione degli equinozi.

H3. Non si applica il moto proprio delle stelle.

H4. Non si cambia la scala della Luna nel cielo fermo.

H5. Non si cambia nessuna voce della FH gia' lavorata. Questa aggiunta
    estende, non riscrive.

H6. Non si rende modificabile l'ora del giorno, non si aggiunge una
    ricerca di luoghi, non si salvano le date scelte dall'utente.

H7. Nessun limite per tier. La Macchina del tempo e' intera per tutti,
    Viandante compreso.
    Fonte: frase di Mauro dell'8 ottobre 2026, "nessun limite per tier,
    l'esperienza resta intera e wow per tutti".


I - PROVA DI VISTA

Catture nella cartella delle catture della FH, con prefisso "aggiunta".
Il giudizio visivo e' di Mauro: servono le immagini, non le descrizioni.

I1.  il menu' utente con la voce rinominata
I2.  il titolo della schermata rinominato
I3.  il pannello del selettore aperto, con la data di nascita selezionata
I4.  il cielo del 1 gennaio 1900
I5.  il cielo del 31 dicembre 2100
I6.  il cielo della data di nascita, con il testo di arrivo visibile
I7.  registrazione della corsa dalla nascita al 2100, Riduci Movimento
     spento, dove si vede la camera agganciata alla Luna, la Luna che
     cresce e torna, e la fase che gira
I8.  registrazione della corsa dal 2100 alla nascita
I9.  cattura con Riduci Movimento attivo, che mostra il salto senza corsa
I10. la riga del luogo nei suoi due stati
I11. una cattura della Luna quasi piena, per la prova di F7
I12. il pannello Fonti e metodo con le quattro righe della sezione G

Per I7, I8 e I9 serve spegnere e riaccendere Riduci Movimento sul telefono
di collaudo: non lo fai tu, la richiesta la giri a Mauro.


L - RAPPORTO

Nella sezione del rapporto della FH dedicata a questa aggiunta:
- i risultati di tutte le misure da A1 a A8
- l'elenco dei file toccati
- i fotogrammi al secondo misurati durante la corsa, come numero
- il diametro in pixel della Luna a riposo e al colmo della corsa
- il raggio dell'alone della Luna e del pianeta piu' luminoso in campo
- l'esito della guardia un_solo_tempo
- l'elenco delle catture prodotte
- se la seconda riga di G1 e' stata riscritta per via di A5

FINE AGGIUNTA

---

Le due frasi del fondatore arrivate dopo, il 10 ottobre 2026:

1. Sulle catture anteprima_mauro_2026-10-10_luna_01.png e _02.png: "Le
   catture sono queste, le hai generate tu". Sono le anteprime
   docs/preview/FH/fh_14_il_rallentamento.png e
   fh_16_la_corsa_con_la_data.png del commit 037e43f2 (nel rallentamento
   il contatore sta gia' in alto, nella corsa al centro); copiate in
   docs/collaudo/FH/ coi nomi dell'ordine.

2. "Inoltre voglio un pulsante per l'utente che premera' quando vuole fare
   partire l'animazione del riavvolgimento o avanzamento del tempo".
   Cambia la D6: le scorciatoie e le ruote scelgono la data, la corsa
   parte dal pulsante.

Le scelte del fondatore alle tre domande della fermata, stesso giorno:
la finestra verificata delle effemeridi si estende al 31 dicembre 2100 con
un confronto contro il JPL; l'aggiunta si fa intera, poi le parti 11-15
della FH; la build locale per il Realme si fa quando l'aggiunta e' pronta,
per C5 e per le registrazioni.
