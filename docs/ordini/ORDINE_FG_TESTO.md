# ORDINE FG, REAL TIME COSMO, PRIMA PIETRA

Testo dell'ordine come e' arrivato a Code l'8 ottobre 2026: la seconda stesura (la prima e' annullata dall'Architetto dopo la fermata di Code sulle premesse P2, P4 e P11), consegnata in tre pezzi, e l'aggiunta FG delle 20:00 circa, che corregge P12, la voce 0.2 e la voce 7.8. Le correzioni dell'aggiunta sono riportate nel testo al loro posto e, per intero, in fondo.

```
ORDINE FG, REAL TIME COSMO, PRIMA PIETRA
Seconda stesura, 8 ottobre 2026. La prima e' annullata: non eseguirla.
Ramo canonico: claude/esoteric-circle-master-order-e798aj

=====================================================================
QUELLO CHE L'ARCHITETTO HA SBAGLIATO NELLA PRIMA STESURA
=====================================================================
Tre premesse su undici erano false, e Code le ha abbattute sulla testa 2a7b6864
prima di scrivere una riga di codice. Erano: le effemeridi collocate in un file
cancellato da un mese, drawAtlas dichiarato assente mentre una chiamata esiste
gia', e un cielo da catalogo vero dichiarato inesistente mentre e' proprio il
Cielo che l'app mostra ogni giorno.

Il meccanismo, scritto perche' e' la sola difesa che resta: le premesse erano
state copiate da una scheda del 18 agosto invece di essere misurate sul ramo del
giorno. Quella scheda avverte in testa, testualmente, che le sue misure vanno
rifatte prima di scrivere codice, e il Protocollo dice la stessa cosa. Non e'
stato fatto. La stessa riga falsa era finita anche dentro il briefing tecnico
consegnato un'ora prima, che e' stato corretto col V12.

La fermata di Code e' corretta ed e' esattamente il mestiere delle premesse. Le
tre riscritture che Code ha proposto sono accettate tutte e tre, con una riga in
piu' sulla terza.

=====================================================================
PREMESSE DA ABBATTERE
=====================================================================
Si verificano PRIMA di toccare una riga di codice, sulla TESTA del ramo del
giorno e mai su uno sha letto in un rapporto. Se anche una sola e' falsa, ci si
ferma e la si riporta senza eseguire nulla.

P1. In lib/core/astro/celestial.dart esiste equatorialToHorizontal con i
    parametri raDeg, decDeg, latDeg, lstDeg, che restituisce altezza e azimut in
    gradi con l'azimut da nord verso est. Esistono anche gmstDegrees e
    localSiderealDegrees.
P2. I pianeti si calcolano col VSOP87D di Meeus, da un unico punto d'ingresso,
    IlCieloDiMeeus in lib/core/astro/meeus/. Il file lib/core/astro/effemeridi.dart
    NON esiste piu', cancellato nel commit ff52d671, ordine FD.02.
P3. lib/core/astro/sky_catalog.dart contiene costellazioni disegnate a mano in un
    riquadro locale normalizzato da 0 a 1, senza coordinate equatoriali vere.
    Vale per quel file e non per tutta l'app: vedi P11.
P4. In lib/ esiste UNA sola chiamata a drawAtlas, in
    lib/features/sigilli/spirale_di_stelle.dart, una per fotogramma, con circa
    2.600 stelle. drawRawPoints e drawVertices non compaiono da nessuna parte.
P5. sensors_plus e' nel pubspec.yaml alla versione ^6.1.1.
P6. In assets/img/zodiac esistono i dodici file zod_<segno>.webp dei segni
    zodiacali, insieme ad altri file che non riguardano questo ordine.
P7. I dodici velo_<segno>.webp NON sono nel ramo: stanno in
    C:\Users\user\Desktop\esoteric-circle-app\assets\img\zodiac_velo e vanno
    copiati nel worktree come prima voce della parte 4. I nomi sono velo_ariete,
    velo_toro, velo_gemelli, velo_cancro, velo_leone, velo_vergine,
    velo_bilancia, velo_scorpione, velo_sagittario, velo_capricorno,
    velo_acquario, velo_pesci.
P8. Il Cielo di nascita e il Cielo sopra di te adesso NON sono due schermate:
    sono una classe sola, SkyOverviewScreen in
    lib/features/santuario/sky_overview_screen.dart, con due rotte, route() per
    il cielo di adesso e birthRoute() per quello di nascita.
P9. Nel menu utente, lib/features/account/account_screen.dart, si possono
    aggiungere voci senza toccare quelle esistenti.
P10. language_rule_test.dart e testo_a_video_test.dart sono vive e verdi sulla
     testa del ramo.
P11. Un cielo disegnato da un catalogo vero ESISTE GIA' ed e' il Cielo esistente:
     SkyOverviewScreen legge assets/data/bright_stars.json attraverso SkyCatalog
     in lib/core/astro/sky.dart, con venti costellazioni e centosei stelle J2000
     da Hipparcos, ESA 1997, piu' le linee degli asterismi.
P12. [testo dell'aggiunta A1] Il file Specifica_Real_Time_Cosmo_estratto_v2.md
     esiste in C:\Users\user\Desktop\esoteric-circle-app\, pesa 26.001 byte e
     contiene le sezioni 1-bis, 1-ter, 4, 4-bis, 5, 6 e 14 della scheda del
     Project. Il file vecchio, Specifica_Real_Time_Cosmo_estratto.md senza il
     suffisso v2, e' superato: non si legge e non si copia. La prima scrittura
     non era arrivata sul disco, verificato rileggendo il file.

=====================================================================
IL DEBITO DEI DUE CATALOGHI, DICHIARATO CON LA SUA DATA DI CHIUSURA
=====================================================================
Dalla P11 piu' il divieto della parte 9 discende che nell'app vivranno DUE
cataloghi per le stesse stelle: HYG per il Real Time Cosmo e Hipparcos per il
Cielo esistente. E' la famiglia delle due porte, la piu' numerosa di questo
progetto. Qui e' ammessa per una ragione sola, cioe' che e' temporanea e
dichiarata, e la sua data di chiusura e' la decisione del fondatore sulla
sostituzione: se decide di sostituire esce Hipparcos con le due rotte vecchie,
se decide di non sostituire esce HYG. Non esiste il terzo caso in cui restano
tutti e due.

La regola 1.8 sulle linee degli asterismi riguarda il lavoro NUOVO. Le linee che
il Cielo esistente ha gia' restano dove sono e non sono un difetto di questo
ordine.

=====================================================================
REGOLE DI CASA CHE VALGONO PER TUTTO QUESTO ORDINE
=====================================================================
R0. Il testo di questo ordine non e' affidabile: l'Architetto ha gia' sbagliato
    tre premesse su undici nella prima stesura. Code verifica tutto sul ramo,
    anche cio' che l'ordine da' per certo.
R1. La regola vive nel dato, non su una delle strade che lo leggono. Prima di
    dichiarare chiusa una voce: questa regola dove vive, e quante porte ci
    arrivano? La risposta si scrive nel messaggio di commit.
R2. Per ogni guardia nuova si fa la prova di vista: si rimette il difetto, si
    verifica che l'iniezione sia ENTRATA, poi si legge l'esito, e nel rapporto si
    dichiara che l'iniezione e' entrata.
R3. Durante le voci si eseguono solo le prove dell'area toccata piu' le guardie
    di questo ordine. La suite intera UNA volta sola, in fondo, prima del push.
R4. Nessun rosso si consegna. Un test rosso si corregge, non ferma il lavoro.
R5. Si commette a ogni parte chiusa, per percorsi espliciti. git add -A non si usa.
R6. Ogni parte chiusa porta tre cose insieme: la misura in numeri col metodo, le
    immagini prima e dopo a 360 per 797 punti logici con rapporto di pixel 3, la
    frase di accettazione che dice al fondatore dove guardare.
R7. Niente trattino lungo, niente virgola prima della congiunzione e oppure ed,
    accenti tipografici veri nelle stringhe a video.
R8. Ogni ipotesi si verifica prima di correggere, e l'esito si dichiara anche
    quando l'ipotesi cade.
R9. Un ripiego dichiara sempre di essere un ripiego, nel codice e a schermo.
R10. Le catture stanno dentro tester.runAsync e usano pump, mai step.
R11. Una misura scritta in un documento precedente non e' una misura di adesso.
     Vale per questo ordine, per la specifica e per i briefing.

=====================================================================
PARTE 0, I FILE CHE ARRIVANO DA FUORI DEL RAMO
=====================================================================
Fonte: rapporto di fermata di Code, 8 ottobre 2026.

0.1 Si copiano nel worktree i dodici velo_<segno>.webp da
    C:\Users\user\Desktop\esoteric-circle-app\assets\img\zodiac_velo verso
    assets/img/zodiac_velo, e si dichiarano nel pubspec.yaml.

0.2 [testo dell'aggiunta A2] Si copia Specifica_Real_Time_Cosmo_estratto_v2.md da
    C:\Users\user\Desktop\esoteric-circle-app\ verso
    docs/Specifica_Real_Time_Cosmo.md. Da li' in avanti e' quella la copia che
    Code legge. La sezione 4-bis di quel file e' la fonte del debito dei due
    cataloghi dichiarato in testa all'ordine.
    L'avvertenza sul "bel disegno" della sezione 4 e' approvata e va aggiunta in
    testa al file copiato: la riga che dice che il cielo di oggi e' un bel
    disegno e non il cielo vale per sky_catalog.dart, non per il Cielo esistente,
    che un catalogo vero ce l'ha. La 4-bis lo spiega per intero.

0.3 Si copiano le catture di OSR Star Finder dalla cartella principale verso
    docs/collaudo/FG/catture_del_fondatore/.

=====================================================================
PARTE 1, IL CATALOGO DELLE STELLE
=====================================================================
Fonte: docs/Specifica_Real_Time_Cosmo.md, sezioni 4, 5 e 6.

1.1 Si usa il catalogo HYG v4.1 di astronexus, licenza CC BY-SA 4.0. Si scarica
    da https://github.com/astronexus/HYG-Database, file hyg/CURRENT/hygdata_v41.csv,
    119.626 righe. I campi che servono sono ra, dec, mag, ci, bayer, flam, con,
    proper.

1.2 La licenza impone attribuzione e ShareAlike sul file derivato, non sul codice
    dell'app. Il file di dati derivato si pubblica sotto CC BY-SA 4.0 col suo file
    di licenza e l'attribuzione ad astronexus. Il sorgente di Esoteric Circle non
    e' toccato.

1.3 Si costruisce un file binario ridotto, non si imbarca il CSV. Il taglio e'
    magnitudine 6,0, che sul catalogo da' 5.071 stelle, misurate dall'Architetto
    l'8 ottobre 2026. Se la conta che esce dal file scaricato e' diversa si
    riporta quella e si dichiara lo scarto.

1.4 Formato del file binario, quattro campi per stella:
    ra in millesimi di grado, intero a 32 bit senza segno;
    dec in millesimi di grado, intero a 32 bit con segno;
    mag in centesimi, intero a 16 bit con segno;
    ci in centesimi, intero a 16 bit con segno, col valore sentinella -32768 per
    le stelle che nel catalogo non hanno indice di colore.
    Dodici byte per stella, 60.852 byte piu' l'intestazione.

1.5 L'intestazione dichiara una firma di quattro byte, la versione del formato,
    il numero di stelle, la magnitudine di taglio in centesimi, l'epoca J2000. Un
    lettore che trova una firma o una versione diversa solleva invece di
    indovinare.

1.6 Accanto al binario vive un secondo file coi nomi: per le sole stelle che nel
    catalogo hanno proper non vuoto, l'indice nel binario piu' il nome. Sul
    catalogo intero sono 465, meno dopo il taglio: si misura e si riporta.

1.7 I due file vivono in assets/astro/ e sono dichiarati nel pubspec.yaml. Il
    generatore che li produce dal CSV vive in tool/ ed e' versionato, cosi' il
    file si rifa' identico. Il CSV di partenza NON entra nel repository.

1.8 Le linee degli asterismi NON si prendono da Stellarium. In questo ordine le
    linee non si disegnano affatto: il velo della parte 4 sostituisce la linea.
    La regola riguarda il lavoro nuovo e non tocca il Cielo esistente.

1.9 L'attribuzione ad astronexus compare dentro il pannello Fonti e metodo della
    funzione, insieme al disclaimer gia' in uso nell'app.

1.10 Il catalogo nuovo NON sostituisce assets/data/bright_stars.json e non lo
     tocca. I due convivono fino alla decisione sulla sostituzione, come dichiara
     la sezione del debito qui sopra.

=====================================================================
PARTE 2, IL CIELO NAVIGABILE
=====================================================================
Fonte: frase del fondatore dell'8 ottobre 2026, meno zoom, partire da una specie
di panoramica, piu' docs/Specifica_Real_Time_Cosmo.md sezione 1-ter.

2.1 Il cielo si disegna a lotto unico con drawAtlas: un solo sprite di stella
    preparato una volta, disegnato per tutte le stelle in una chiamata per
    fotogramma. Colore e dimensione per stella da magnitudine e indice di colore.
    L'alone viene dalla texture dello sprite, mai da un MaskFilter. Nel cammino
    per fotogramma non si creano MaskFilter, non si chiama createShader, non si
    rigenerano liste.

2.2 Il precedente da copiare esiste gia' ed e'
    lib/features/sigilli/spirale_di_stelle.dart, che usa drawAtlas con circa
    2.600 stelle in una sola chiamata per fotogramma. Si legge prima di
    scrivere, si riusa cio' che si puo' riusare, e se nasce un secondo modo di
    fare la stessa cosa si dichiara perche'.

2.3 Il colore della stella dall'indice di colore, cinque fasce:
    ci minore di 0,0      -> 185, 212, 255
    ci da 0,0 a 0,3       -> 224, 234, 255
    ci da 0,3 a 0,6       -> 255, 251, 243
    ci da 0,6 a 1,0       -> 255, 236, 200
    ci da 1,0 in su       -> 255, 200, 158
    Le stelle col valore sentinella sono bianche.

2.4 Il raggio dello sprite per stella e' il massimo fra 1,1 punti logici e
    (5,7 meno la magnitudine) elevato a 1,9, moltiplicato per 0,85.

2.5 Il fondo e' 9, 13, 32. La densita' bersaglio a schermo e' fra 158 e 218 punti
    luminosi, misurata sull'app di riferimento. Si misura la densita' vera in tre
    inquadrature e si riporta.

2.6 Il campo visivo di partenza e' 70 gradi. Il pizzico stringe fino a 18 gradi e
    allarga fino a 100. Il filtro del movimento si fa piu' severo man mano che si
    stringe: la costante di tempo cresce in modo lineare dal campo largo al campo
    stretto, coi due estremi dichiarati nel codice.

2.7 La proiezione passa da equatorialToHorizontal, che esiste gia' e non si
    duplica. Chi scrive una seconda conversione da coordinate equatoriali a
    orizzontali ha aperto una seconda porta.

2.8 I pianeti e la Luna si prendono da IlCieloDiMeeus, che e' il punto d'ingresso
    unico del VSOP87D. Non si scrive un secondo motore e non si cerca
    effemeridi.dart, che non esiste piu'.

2.9 L'orientamento viene dal vettore di rotazione del telefono, con la
    declinazione magnetica applicata per passare dal nord magnetico al nord vero.
    Si verifica se sensors_plus 6.1.1 espone gia' il vettore di rotazione fuso:
    se non lo espone si dichiara e si usa il ripiego tattile, senza aggiungere
    dipendenze in questo ordine.

2.10 Il ripiego tattile e' obbligatorio e non e' una via di scarto: senza
     sensore, o col permesso negato, si esplora trascinando il dito e la funzione
     resta intera. Con Riduci Movimento attivo l'inseguimento e' fermo e si
     naviga a tocco.

2.11 Le frecce di guida: un indicatore laterale che nomina il bersaglio e
     dichiara la distanza in gradi, con la distanza che scende mentre ci si
     avvicina e la freccia che sparisce quando il bersaglio entra in quadro. In
     questo ordine il bersaglio e' uno solo, la costellazione del segno della
     persona.

2.12 Il tocco seleziona l'oggetto piu' vicino in coordinate di schermo, cercando
     dentro una griglia grossolana per regione di cielo, non ricalcolando il
     cielo intero.

=====================================================================
PARTE 3, IL CIELO DI NASCITA E IL RIAVVOLGIMENTO
=====================================================================
Fonte: docs/Specifica_Real_Time_Cosmo.md sezione 1-bis, piu' la decisione del
fondatore dell'8 ottobre 2026 sul posto del riavvolgimento.

3.1 Il cielo di nascita e' lo stesso motore con un altro istante e un altro
    luogo, presi dalla carta natale gia' persistita. Non si scrive un secondo
    motore.

3.2 Il riavvolgimento: mentre il numero degli anni scende accelerando fino a
    zero, il cielo gira davvero all'indietro. Il senso del movimento lo danno la
    rotazione diurna accelerata, le fasi della Luna e il moto dei pianeti, non le
    stelle fisse, che su decenni quasi non si spostano.

3.3 Il tetto e' dichiarato prima di scrivere la scena: non piu' di 24 istanti
    calcolati al secondo, con interpolazione fra un istante e il successivo per i
    fotogrammi intermedi. Se sul telefono lento non regge si riduce il numero di
    istanti calcolati e non la fluidita'.

3.4 Con Riduci Movimento attivo il riavvolgimento diventa un passaggio secco.

3.5 Senza ora di nascita non si finge l'istante: si dichiara che si arriva al
    giorno e non all'istante, e si offre la via per completare il dato.

3.6 La Luna di stanotte non si spaccia mai per la Luna della nascita.

=====================================================================
PARTE 4, IL VELO DELLE COSTELLAZIONI
=====================================================================
Fonte: frase del fondatore dell'8 ottobre 2026, creiamo una forma flat piena
dorata cesellata e la si sovrappone con dissolvenza, piu' l'approvazione della
taratura dello stesso giorno. Il metodo per intero sta in
docs/Specifica_Real_Time_Cosmo.md sezione 14.

4.1 I dodici asset sono gia' cotti e arrivano dalla parte 0. Code non li genera e
    non li ritocca.

4.2 A runtime il velo si disegna cosi' e basta: l'immagine come sta, con
    BlendMode.screen sopra il cielo, piu' un alone che e' la stessa immagine
    sfocata a 26 punti logici e miscelata al 40 per cento. L'alone si dipinge UNA
    volta in cache e si riusa, mai per fotogramma.

4.3 Nessuna taratura si rifa' sul telefono: luminanza, contrasto, gamma, tinta e
    alfa sono gia' dentro l'asset. La ricetta e' scritta qui solo per
    tracciabilita', cioe' per cuocere un domani le altre figure con gli stessi
    numeri: luminanza stirata fra il percentile 2 e il percentile 98 dei soli
    pixel con alfa maggiore di 24; contrasto 1,70 centrato sulla mediana della
    stessa popolazione; gamma 0,76; oro con rosso da 170 a 255, verde da 108 a
    200, blu da 28 a 98; alfa del pixel moltiplicata per 0,62 e per (0,38 piu'
    0,62 per la luminanza).

4.4 La scala: si prendono le stelle principali della costellazione, cioe' le piu'
    luminose, da un minimo di cinque a un massimo di dodici, ordinate per
    magnitudine crescente. Il lato del velo e' la media geometrica di larghezza e
    altezza del loro riquadro a schermo, moltiplicata per 1,25 e divisa per la
    media geometrica delle misure dell'asset.

4.5 Il centro del velo e' il baricentro delle stelle principali pesato per
    luminosita', con peso pari a 10 elevato a (meno 0,4 per la magnitudine). NON
    e' il centro del riquadro: quello sbilancia la figura quando una stella sta
    lontana dalle altre, misurato su Vergine, Capricorno ed Ariete.

4.6 Il velo compare quando la costellazione entra in quadro e si dissolve quando
    esce, con una dissolvenza di 400 millesimi di secondo. Non compare mai di
    colpo.

4.7 Il velo del segno della persona e' dorato come tutti gli altri, ma la sua
    opacita' complessiva sale del venti per cento rispetto agli altri segni. Le
    altre costellazioni restano senza velo in questo ordine, perche' i loro asset
    non esistono.

=====================================================================
PARTE 5, LA PARALLASSE DEL VELO
=====================================================================
Fonte: frase del fondatore dell'8 ottobre 2026, vale la pena che l'immagine
sovrapposta sia staccata dal cielo e dalle stelle per un effetto parallasse e di
distanziamento.

5.1 Il velo sta su un piano davanti al cielo. Quando l'orientamento cambia il
    cielo si sposta poco mentre il velo si sposta molto: il rapporto e' 1 a 8,7,
    cioe' 3 punti logici di cielo contro 26 di velo sulla stessa escursione.

5.2 Lo scostamento verticale del velo e' il 35 per cento di quello orizzontale.

5.3 La profondita' di campo: il cielo dietro il velo e' sfocato a 3,2 punti
    logici, con la maschera presa dall'alfa del velo, sfocata a 40 punti e
    portata al 70 per cento. Si dipinge in cache e si rifa' solo quando il velo
    entra o esce, mai per fotogramma.

5.4 Il velo sborda dal riquadro delle stelle ed e' giusto cosi': e' il segno che
    sta su un altro piano. Chi lo ritaglia sul riquadro ha tolto l'effetto.

=====================================================================
PARTE 6, LA VOCE TEMPORANEA NEL MENU UTENTE
=====================================================================
Fonte: frase del fondatore dell'8 ottobre 2026, propongo una voce temporanea nel
menu utente Real Time Cosmo per testare le 3 opzioni.

6.1 In lib/features/account/account_screen.dart si aggiunge una voce, Real Time
    Cosmo, che apre una schermata con tre scelte separate: il cielo di adesso, il
    cielo della nascita, l'animazione del ritorno indietro nel tempo.

6.2 Le tre sono separate di proposito, cosi' si giudicano una per una. La voce e'
    temporanea e porta nel codice il commento che dice che si toglie quando la
    decisione sulla sostituzione sara' presa.

6.3 La voce non ha limiti di piano. Nessuna delle tre opzioni chiede un
    abbonamento, per decisione del fondatore dell'8 ottobre 2026.

6.4 Nessuna domanda all'ingresso. Se in questo istante, da dove si trova la
    persona, la Luna o un pianeta brillante stanno sopra l'orizzonte, compare una
    riga discreta e ignorabile che invita a puntarlo per guadagnare precisione.
    Se non ci sono, non compare niente.

=====================================================================
PARTE 7, GUARDIE E PRESTAZIONI
=====================================================================

7.1 Guardia: il cielo si dipinge una volta. La prova legge il sorgente del
    cammino per fotogramma e cade nominando metodo e riga se trova un MaskFilter,
    una chiamata a createShader o una lista rigenerata. Pretende anche che gli
    strati pesanti esistano dentro la cache, perche' un cielo vuoto passerebbe.

7.2 Guardia: nessuna seconda porta sull'astronomia. La prova enumera lib/ e cade
    se trova una seconda conversione da coordinate equatoriali a orizzontali,
    oppure un secondo punto d'ingresso per i pianeti accanto a IlCieloDiMeeus.

7.3 Guardia: il catalogo e' letto e non inventato. La prova confronta la
    posizione di tre stelle note calcolata dall'app con tre valori di riferimento
    scritti nella prova, presi da una fonte terza, con lo scarto massimo
    dichiarato.

7.4 Guardia: il velo non si disegna senza il suo asset. La prova enumera i dodici
    segni e cade se per uno manca il file in assets/img/zodiac_velo oppure se non
    e' dichiarato nel pubspec.

7.5 Guardia: nessuna linea di asterismo nel lavoro nuovo. La prova enumera il
    sorgente della funzione nuova e cade se trova un disegno di linee fra stelle.
    NON guarda il Cielo esistente, che le sue linee le ha gia' e non si tocca.

7.6 Guardia: i due cataloghi restano separati. La prova cade se il codice del
    Real Time Cosmo legge bright_stars.json, oppure se il Cielo esistente legge
    il catalogo nuovo. Finche' convivono devono essere due strade che non si
    incrociano, altrimenti il debito dichiarato diventa un difetto vero.

7.7 Prestazioni, da misurare sul telefono e non sulle prove:
    millesimi per fotogramma nel cielo fermo;
    millesimi per fotogramma durante il riavvolgimento;
    numero di stelle a schermo in tre inquadrature;
    memoria grafica in transizione.
    I quattro numeri si riportano nel rapporto. Senza quelli la parte 2 resta
    aperta, ed e' il solo pezzo di questo ordine che dipende da una build.

7.8 [testo dell'aggiunta A3] La schermata si ferma quando esce di scena: sensori
    spenti, disegno fermo. Il modello da copiare e' cosmos_background.dart, che
    segue lo stato dell'app, paused, hidden e detached, e annulla la sentinella:
    e' l'ordine AM voce 01. Il riferimento all'ordine AJ voce 01 scritto nella
    prima stesura era sbagliato: AJ voce 01 e' il giro che parte solo senza
    Riduci Movimento, e serve invece alle voci 2.10 e 3.4 di questo ordine.

=====================================================================
PARTE 8, PROVA DI VISTA
=====================================================================

8.1 Per ognuna delle sei guardie della parte 7 si fa la prova di vista: si
    rimette il difetto, si verifica che l'iniezione sia ENTRATA, si legge
    l'esito, e nel rapporto si dichiara che l'iniezione e' entrata e che la
    guardia e' caduta nominando la riga.

8.2 Se una prova di vista resta verde, prima di concludere che la misura e' cieca
    si guarda se il caso scelto percorre davvero il ramo. Se non lo percorre si
    enumera invece di campionare.

=====================================================================
PARTE 9, QUELLO CHE NON SI TOCCA
=====================================================================

9.1 SkyOverviewScreen non si tocca, ne' la classe ne' le sue due rotte, route()
    e birthRoute(). Non si deprecano, non si annunciano in uscita, non si
    collegano alla funzione nuova. La sostituzione NON e' decisa: si decide dopo
    che il fondatore avra' provato le tre opzioni sul telefono.

9.2 assets/data/bright_stars.json non si tocca e non si cancella.

9.3 Non si tocca lo scope della Demo, che resta congelato.

9.4 Non si prende niente da Stellarium, ne' linee ne' arte.

9.5 Non si chiedono permessi nuovi nel manifest oltre a quelli che la funzione
    usa davvero, e il permesso di posizione si chiede nel punto in cui serve, con
    la sua ragione a schermo.

9.6 Nessuna credenziale compare in questo ordine e nessuna va chiesta in chat.

=====================================================================
CONSEGNA
=====================================================================

C1. Si lavora per parti nell'ordine scritto, dalla 0 alla 8. Si commette a ogni
    parte chiusa.

C2. La stima si dichiara all'inizio, non alla fine. La stima di Code nel rapporto
    di fermata e' 12-16 ore in tutto: catalogo e generatore 1,5; motore con
    drawAtlas, proiezione e sensori 4; riavvolgimento 3; velo con parallasse 2;
    menu, guardie e prove di vista 3. Se la stima cambia dopo la parte 1 si
    ridichiara.

C3. In fondo: analyze pulito, suite intera verde una volta sola, anteprime
    rigenerate, push col credential helper effimero, verifica che locale e remoto
    coincidano.

C4. Le catture di questo ordine vivono in docs/collaudo/FG/. La clip di OSR Star
    Finder e il mosaico dei suoi fotogrammi arrivano dalla parte 0 e sono il
    riferimento di stile per la densita' delle stelle e per il tono del fondo.

C5. Il rapporto finale dichiara, per ogni parte: la misura in numeri col metodo,
    le immagini prima e dopo a 360 per 797 punti logici, la frase di accettazione
    che dice al fondatore dove guardare sul telefono.

C6. La build non si fa: la ordina il fondatore. Se serve una build per misurare
    le prestazioni della 7.7, la si chiede a lui invece di lanciarla.
```

## L'aggiunta FG dell'8 ottobre 2026, per intero

```
FG AGGIUNTA, 8 ottobre 2026
Tre correzioni all'ordine FG seconda stesura. Tutto il resto dell'ordine resta
come scritto.

A1. La premessa P12 si legge cosi':
    P12. Il file Specifica_Real_Time_Cosmo_estratto_v2.md esiste in
    C:\Users\user\Desktop\esoteric-circle-app\, pesa 26.001 byte e contiene le
    sezioni 1-bis, 1-ter, 4, 4-bis, 5, 6 e 14 della scheda del Project.
    Il file vecchio, Specifica_Real_Time_Cosmo_estratto.md senza il suffisso v2,
    e' superato: non si legge e non si copia. La prima scrittura non era arrivata
    sul disco, verificato rileggendo il file.

A2. La voce 0.2 della parte 0 si legge cosi':
    0.2 Si copia Specifica_Real_Time_Cosmo_estratto_v2.md da
    C:\Users\user\Desktop\esoteric-circle-app\ verso
    docs/Specifica_Real_Time_Cosmo.md. Da li' in avanti e' quella la copia che
    Code legge. La sezione 4-bis di quel file e' la fonte del debito dei due
    cataloghi dichiarato in testa all'ordine.
    L'avvertenza sul "bel disegno" della sezione 4 e' approvata e va aggiunta in
    testa al file copiato: la riga che dice che il cielo di oggi e' un bel
    disegno e non il cielo vale per sky_catalog.dart, non per il Cielo esistente,
    che un catalogo vero ce l'ha. La 4-bis lo spiega per intero.

A3. La voce 7.8 si legge cosi':
    7.8 La schermata si ferma quando esce di scena: sensori spenti, disegno
    fermo. Il modello da copiare e' cosmos_background.dart, che segue lo stato
    dell'app, paused, hidden e detached, e annulla la sentinella: e' l'ordine AM
    voce 01. Il riferimento all'ordine AJ voce 01 scritto nella prima stesura era
    sbagliato: AJ voce 01 e' il giro che parte solo senza Riduci Movimento, e
    serve invece alle voci 2.10 e 3.4 di questo ordine.

A4. Confermate senza modifiche le tre verifiche di Code: il pannello Fonti e
    metodo della voce 1.9 si riusa da quelli esistenti e non se ne scrive uno
    nuovo; il manifest non cambia, perche' ACCESS_FINE_LOCATION e
    ACCESS_COARSE_LOCATION ci sono gia' e bussola e giroscopio su Android non
    chiedono permessi; la stima resta 12-16 ore e si ridichiara dopo la parte 1
    se cambia.
```
