# Autoverifica delle Rune di Caligo dopo la cura (ordine GA, voce GA.06)

Letta da chi ha fatto la cura, non da un lettore cieco: un lettore cieco
indipendente rifarà la prova. Fonte: `docs/collaudo/GA/lettori_ciechi/rune.json`
rigenerato con `GA06_SCRIVI=1 flutter test test/ga06_campioni_per_i_lettori_ciechi_test.dart`
(seme 606, stesse 40 gettate e stesse domande del campione di prima; solo la
riga del verso d'ombra dice adesso "in ombra (merkstave, rovesciata)", i tre
nomi che usano la schermata e i testi). Tarocchi, Oroscopo e Oracolo
rigenerati sono usciti identici.

Le tre domande, lette come le ha lette il lettore cieco:
- **D1** la prima frase risponde alla domanda (anche con un "non ancora" o
  con il limite delle rune detto chiaro);
- **D2** il "Cosa fare adesso" dà un'azione concreta che riguarda la domanda;
- **D3** il responso è coerente con le pietre (pietra che decide, verso,
  tono contato) e con la domanda.

## I conti, prima e dopo

| domanda | prima (1804c7d7) | dopo |
|---|---|---|
| D1, la prima frase risponde | 6 su 40 | 38 su 40 |
| D2, il cosa fare è concreto e pertinente | 7 su 40 | 38 su 40 |
| D3, coerente con le rune e con la domanda | 13 su 40 | 37 su 40 |
| domande a trabocchetto col limite detto (9) | 0 su 9 | 9 su 9 |
| domande doppie separate (2) | 0 su 2 | 2 su 2 |
| "ciò che hai chiesto" al posto del tema, nelle risposte | 20 su 40 | 0 su 40 |
| frase sul tono che nomina una runa assente o conta male | 10 casi | 0 (guardia: 0 su 61.560 testi) |

## Una riga per responso

| id | domanda | D1 | D2 | D3 | nota |
|---|---|---|---|---|---|
| rune-1 | Come gestisco il conflitto con il mio capo? | sì | sì | sì | "Tenendo duro senza irrigidirti: è questa la via per il lavoro"; riquadro: un gesto preciso entro due giorni, preparando la frase |
| rune-2 | Andrà tutto bene? | sì | sì | sì | "Le rune non promettono che vada tutto bene", poi la svolta chiara di Dagaz |
| rune-3 | Devo accettare l'offerta della nuova azienda? | sì | sì | sì | "Non ancora: prima di accettare l'offerta ... serve altro tempo" (Ingwaz nell'Esito) |
| rune-4 | Come affronto il pranzo di Natale con la famiglia di lui? | sì | sì | sì | tema "la tua famiglia" (prima "l'amore"); Wunjo in ombra al centro, "curando il legame" |
| rune-5 | Passerò l'esame di stato a dicembre? | sì | sì | sì | limite sull'esito, Isa: sosta, preparazione costante |
| rune-6 | Conviene investire i miei risparmi in borsa adesso? | sì | sì | sì | limite e consulente nella prima frase; nessuna spinta ad agire |
| rune-7 | Cosa prova davvero Marco per me? | sì | sì | sì | "Le rune non leggono il cuore di un'altra persona"; riquadro: osserva i fatti, poi chiedi |
| rune-8 | Devo lasciare Roma, e se lo faccio la mia famiglia capirà? | sì | sì | sì | "Non senza un confronto" (Mannaz, domanda di chiusura); la seconda domanda separata |
| rune-9 | Ha senso riprovarci con la mia ex? | sì | sì | sì | "Sì: la gettata dice di riprovarci con la tua ex" |
| rune-10 | Mio figlio sta attraversando un periodo difficile, come lo aiuto? | no | sì | no | la prima frase ("Tenendo la rotta che hai scelto") è un modo troppo largo per aiutare un figlio; la RISPOSTA del corpus di Sowilo ("avanzare senza chiedere il permesso a nessuno") ha un tono fuori luogo su una preoccupazione |
| rune-11 | Devo dirle che sono innamorato di lei? | sì | sì | sì | "Non ancora: prima di dirle che sei innamorato di lei serve altro tempo" |
| rune-12 | Devo chiudere l'amicizia con Giulia? | sì | sì | sì | Gebo non dice più sì a una chiusura: "Non prima di aver riequilibrato lo scambio" |
| rune-13 | Vincerò la causa contro il mio ex socio? | sì | sì | sì | limite e avvocato; nessun "nessun ostacolo sbarra la strada" |
| rune-14 | La mia relazione può durare nonostante la distanza? | sì | sì | sì | limite sull'esito, Hagalaz a Skuld; testo severo ma coerente |
| rune-15 | Che cosa mi aspetta? | sì | sì | sì | "Le rune non mostrano un futuro già scritto" |
| rune-16 | Devo trasferirmi a Milano o restare a Bari? | sì | sì | sì | criterio di scelta con le due strade nominate |
| rune-17 | Devo lasciare il lavoro per tornare a studiare? | sì | sì | sì | "Non ancora" (Ingwaz); il seme in un vaso non c'è più |
| rune-18 | Posso fidarmi del mio compagno? | sì | sì | sì | limite sul cuore dell'altro; riquadro: chiedere direttamente |
| rune-19 | Lui tornerà da me dopo quello che è successo? | sì | sì | sì | letta come domanda su un altro; "è in cammino un messaggio" riscritto |
| rune-20 | Compro casa adesso o aspetto un anno? | sì | sì | sì | letta come denaro: consulente, nessun consiglio d'acquisto |
| rune-21 | Il colloquio di giovedì andrà bene? | sì | sì | sì | limite sull'esito; nessun "rimanda ogni annuncio" con il colloquio fissato |
| rune-22 | Il cambiamento che sento arrivare sarà positivo? | sì | sì | sì | |
| rune-23 | Incontrerò qualcuno di importante quest'anno? | sì | sì | sì | tema "l'incontro che cerchi" |
| rune-24 | Riuscirò a ottenere la promozione che aspetto? | sì | sì | sì | |
| rune-25 | È il momento giusto per aprire la mia attività? | sì | sì | sì | "Non ancora: prima di aprire la tua attività" |
| rune-26 | Come posso ritrovare l'intesa con mio marito? | no | no | sì | "Preparando in silenzio" (Ingwaz) è coerente con la pietra ma risponde poco a "come ritrovare l'intesa", e il riquadro resta vago |
| rune-27 | Quando finirà questo periodo di stallo? | sì | sì | sì | "Le rune non danno date" |
| rune-28 | Il progetto che ho presentato verrà approvato? | sì | sì | sì | |
| rune-29 | Lui mi ama ancora e troverò lavoro entro Natale? | sì | sì | no | domanda separata; la RISPOSTA del corpus ("Ciò che custodisci in segreto per l'amore") presume un segreto che nessuno ha nominato |
| rune-30 | Arriverà presto la risposta che aspetto? | sì | sì | sì | tema "la risposta che aspetti" |
| rune-31 | L'operazione al ginocchio del mese prossimo andrà bene? | sì | sì | sì | medici nella prima frase; niente "porta via ciò che era incrinato", niente "Wunjo risponde di sì", nessuno sforzo fisico nelle schede |
| rune-32 | Quale strada scelgo tra i due corsi di laurea? | sì | sì | sì | criterio; il "dado in aria, goditi l'attesa" riscritto |
| rune-33 | Come posso fare pace con mia sorella? | sì | sì | sì | "Sì, scambia" e la bicicletta in cantina non ci sono più |
| rune-34 | Dimmi qualcosa. | sì | no | sì | il riquadro è concreto ma, sulla domanda più larga di tutte, resta generale; l'approfondimento non manda più chi legge a cercarsi il tempo da solo |
| rune-35 | È giusto andare a vivere lontano dai miei genitori? | sì | sì | sì | |
| rune-36 | Come gestisco il conflitto con il mio capo? | sì | sì | sì | "il mistero è un invito, non un muro" riscritto |
| rune-37 | Andrà tutto bene? | sì | sì | sì | nessun "sì pieno" |
| rune-38 | Devo accettare l'offerta della nuova azienda? | sì | sì | sì | "Sì, con le giuste tutele"; "Sì, hai riparo" riscritto |
| rune-39 | Come affronto il pranzo di Natale con la famiglia di lui? | sì | sì | sì | |
| rune-40 | Passerò l'esame di stato a dicembre? | sì | sì | no | la RISPOSTA del corpus di Ehwaz ("chi cammina al tuo fianco") presume un compagno di studio |

## Le schede

- Il titolo di ogni scheda legge la posizione ("Ciò che ti frena: un cammino
  che ha perso la cadenza" per Raidho dritta nell'Ostacolo; "Il consiglio:
  difendendo il tuo confine con misura"). Sulle domande delicate il titolo
  dice l'atteggiamento dal posto della pietra ("Nell'Esito, per te: lascia
  passare l'agitazione senza trattenerla"), mai l'esito.
- Nessuna scheda dice più "risponde di sì" o comincia con "Sì,"/"No," (41
  voci di PIETRA riscritte), nessuna dice "capovolta" (101 voci: "rovesciata",
  come la schermata), nessuna passa al voi (Ehwaz 35 e 62).
- Resta: il riquadro della scheda (CONSIGLIO) e il suo paragrafo (PIETRA) si
  scelgono ancora in due gruppi separati e a volte parlano di due cose
  (rune-3, scheda di Wunjo: il paragrafo sui traguardi, il riquadro su un
  malinteso). Non curato: vedi il rapporto.
