# RAPPORTO DELL'ORDINE EF, IL SOFFIO DEL DESTINO RIFATTO E GUARDATO PRIMA DI CONSEGNARLO

23 settembre 2026. Ramo `claude/esoteric-circle-master-order-e798aj`,
partenza dal commit `b7f84d7b`. Manifesto in
`docs/ordini/ORDINE_EF_MANIFESTO.md`, catture in `docs/collaudo/EF/`.

---

## IN CIMA: LA RISPOSTA ALLA TUA DOMANDA

*"MA A CHE CAZZO SERVONO LE PROVE A VIDEO CHE FA CODE? MA LE FA?"*

**No, non le faceva, e nell'ordine EE ho scritto di averlo fatto.** Li' c'e'
scritto *"le due animazioni si giudicano solo a video"*, e poi a video non le
ha guardate nessuno.

**E c'era una ragione strutturale, che e' peggio della pigrizia.** Il pittore
della scena cominciava con `if (dandelion == null) return;`, e sotto
`flutter test` un asset PNG non si carica mai: **in ogni prova di layout mai
scritta su questa schermata il soffione semplicemente non esisteva**. Non
c'era niente da coprire, quindi nessuna prova poteva accorgersi che un
riquadro lo copriva. La voce 03, che toglie la fotografia, e' per questo la
cura vera dell'ordine e non un intervento estetico.

**Quest'ordine ha guardato, e guardare ha trovato tre difetti che nessuno
aveva chiesto di cercare**, elencati piu' sotto.

---

## 1. LE CINQUE VOCI

| voce | prodotto | agganciato | verificato a video |
|---|---|---|---|
| EF.01, il soffione si vede e la bolla cresce | si' | si' | **si'**, `3_prima_di_respirare.png` |
| EF.02, otto respiri | **scarto**: la premessa era falsa | nessuna riga | niente da vedere |
| EF.03, il soffione d'oro inciso | si' | si' | **si'**, `1_prima_del_soffio.png` |
| EF.04, il soffio al microfono | si' | si' | **misurato**, il soffio vero resta a te |
| EF.05, ogni stato si guarda | si' | si' | **si'**, sei catture |

---

## 2. GLI SCARTI FRA L'ORDINE E IL RAMO

**1. Il respiro non e' una costante e nessuno l'aveva cambiato in tre.**
Arriva dal rito del giorno: `breath_destiny_screen.dart` legge
`_gift!.rito!.tempi` e `.giri`, e `rito_alba_corpus.dart` ha **trentasei
riti** con cadenze diverse, fra cui uno da quattro tempi e otto giri. Messo
davanti alla scelta hai risposto **"Lascio come sta, decide il rito"**:
nessuna riga cambiata.

**2. Nella fase del respiro il soffione non c'e'.** Nel rito prima si soffia e
poi si respira, e a quel punto l'opacita' della testa e' zero. Me l'hai
confermato tu che il rito e' giusto cosi', quindi la figura che deve vedersi
e respirare durante il respiro e' **il dono**.

**3. La fotografia non e' uscita dal pacchetto**, solo dalla schermata: la usa
anche `soffio_share_card.dart`, la card da condividere, che sta **fuori dal
perimetro**. Toglierla romperebbe una superficie che l'ordine dice di non
toccare. **Serve una tua parola.**

---

## 3. OGNI DIFETTO COL SUO PADRE

| difetto | dove | padre |
|---|---|---|
| il riquadro del respiro copriva la figura | `breath_destiny_screen.dart` | **ordine EE voce 02** |
| la misura "71,0 per cento al culmine" era falsa | `il_soffione_respira_test.dart` | **ordine EE voce 02** |
| la fotografia rendeva la schermata cieca a ogni prova di layout | il pittore della scena | **PROVENIENZA IGNOTA**, commit `21f46cf0` senza sigla |
| l'invito al gesto copriva la testa del soffione | `breath_destiny_screen.dart` | **PROVENIENZA IGNOTA** |
| le animazioni del rito duravano un ventesimo | i tre motori | **PROVENIENZA IGNOTA** |
| il volo dei semi e il respiro spenti da `_reduceMotion` | `breath_destiny_screen.dart` | **PROVENIENZA IGNOTA** |
| la schermata restava bloccata dopo il soffio | `_complete()` | **PROVENIENZA IGNOTA** |
| il pavimento fisso teneva ferma la bolla | il layout della colonna | **ordine 2164 voce 8** |
| il titolo troncato coi puntini | la barra del Soffio | **PROVENIENZA IGNOTA** |

---

## 4. IL DIFETTO PIU' GRANDE NON ERA IN NESSUNA VOCE

**Le animazioni giravano, e duravano venti volte meno.** Quando la
piattaforma dichiara `disableAnimations`, Flutter **non spegne** un
`AnimationController`: **ne moltiplica la durata per 0,05**. Su Android quel
flag viene dalla scala di durata degli animatori, **un numero che moltissimi
mettono a zero per far sembrare il telefono piu' rapido**, e sul tuo Realme le
tre scale sono a zero.

| animazione | dichiarata | vera sul tuo telefono |
|---|---|---|
| volo dei semi | 900 ms | **45 ms** |
| respiro guidato | 28 s | **1,4 s** |

Da qui il tuo *"e' cambiata di botto"*. E c'erano **due interruttori nostri**
oltre a quello di Flutter: `_complete()` saltava del tutto il volo, e il
respiro restava alla misura ferma.

**TI HO DETTO DUE COSE SBAGLIATE PRIMA DI ARRIVARCI, e le scrivo qui.**
Prima che era il telefono: falso. Poi che era il nostro codice a spegnerle:
vero a meta'. **La causa l'ha trovata una cattura che diceva "compiuto"
troppo presto**, non una lettura del codice. Tu me l'avevi detto subito che
l'animazione aveva sempre funzionato, e avevi ragione.

---

## 5. E POI LA SCHERMATA RESTAVA BLOCCATA PER SEMPRE

Dopo il soffio il soffione spariva, il dono restava a meta' e l'invito non se
ne andava piu'. Il registro del telefono lo conferma: **il microfono macinava
campioni all'infinito**, segno che la rivelazione non era mai scattata.

`_complete()` non aveva nessuna guardia di rientro, e
`FormaDelSoffio.eSoffio` e' **un fermo**: acceso una volta, resta acceso.
Ogni pacchetto audio faceva ripartire l'animazione da zero, e riavviare un
`AnimationController` **annulla** il suo `TickerFuture`: un futuro annullato
non chiama il `then`, quindi `_reveal()` non si eseguiva mai.

**Era li' da prima, e nascosto dal ramo che ho tolto in quest'ordine**: sotto
Riduci Movimento il dono si rivelava nello stesso fotogramma, senza
animazione da annullare, quindi sul tuo telefono la strada rotta non si
percorreva.

**LA PRIMA VERSIONE DELLA GUARDIA RESTAVA VERDE SUL DIFETTO.** Tre gesti
distanziati lasciano finire il volo fra l'uno e l'altro. L'ho rifatta
misurando **il tempo**: il secondo gesto arriva mentre il primo vola ancora, e
a 1600 millisecondi il dono deve essere rivelato. Col difetto innestato e'
rossa.

---

## 6. IL TITOLO TRONCATO, E QUANTO E' LARGO IL PROBLEMA

**La cura esisteva gia'.** `TitoloCheNonSiRompe` nasce dall'ordine S voce 05
proprio per questo: va a capo fra le parole, e se la parola piu' lunga non
entra rimpicciolisce fino al pavimento invece di tagliare. **Lo usano
ventidue schermate.** Il Soffio aveva un `Text` nudo, che in una barra con
tre azioni a destra non ha altra scelta che i puntini.

**Agganciato qui, che e' dentro il perimetro. Ma agganciarlo non bastava.**
Quel componente evita che una parola si spezzi a meta', **pero' quando il
titolo intero vuole piu' righe di quelle concesse rende lo stesso una
misura**: il testo non si rompe, l'ultima riga sparisce. E' successo sul
Viaggio dello Sciamano nell'ordine DQ voce 14, dove la barra diceva *"Il
Viaggio dello"*. Avevo dichiarato la cura senza misurarne l'esito: adesso c'e'
la misura, sulla geometria vera del tuo telefono, **360 punti e non i 390 del
banco**. Con due azioni nella barra restano **208 punti** e il titolo ci sta
intero a corpo venti su due righe, come si vede nelle catture.

**E il conto di quanto e' largo**: in `lib/features/` ci sono **quarantadue**
punti con un `title: Text(` nudo (alcuni sono finestre di dialogo, non barre).
**Non li ho toccati**: quaranta schermate fuori perimetro sono esattamente il
genere di cosa che ci ha gia' fatto male. **Serve un ordine tuo**, e sarebbe
un ordine piccolo: la cura c'e' gia', si tratta di agganciarla.

---

## 7. I NUMERI DELLA BOLLA, TUTTI MISURATI

Ci sono volute **tre passate**, e le prime due hanno guadagnato niente:

1. tolto il riquadro da sopra la figura: **mezzo punto percentuale**;
2. separate le due fasi, perche' tenevo il riquadro sotto lo stelo di un
   soffione che durante il respiro non c'e': **ancora poco**;
3. **il colpevole era il pavimento fisso dei sei noni**, dall'ordine 2164 voce
   8, che teneva la zona a 529 punti quando ne chiedeva 479.

E per alzare ancora ho dovuto rimpicciolire la figura, perche' era gia'
attaccata al bordo di sopra.

**Sul tuo telefono, schermata vera:**

| | build 2276 | adesso |
|---|---|---|
| dove comincia la bolla | y 1697 su 2400 | **y 1200** |
| righe di testo visibili | tre | **sei** |
| punti che restano alla bolla, al banco | 276 | **415** |
| la figura al culmine | 73,7 per cento | **59,1 per cento** |

**Lo scambio e' dichiarato**: la quota dell'ordine DD voce 03 scende da
settanta a cinquantasei, e la guardia porta la lapide che lo dice. Quella
pretesa nasceva da un cerchio che ne prendeva **trentasei**. **Se la figura ti
sembra troppo piccola, si rialza**: e' una decisione che si prende guardando.

---

## 8. UNA COSA CHE HO IMPARATO, E VALE OLTRE QUEST'ORDINE

**Una differenza fra il banco e il telefono puo' stare nel TEMPO, e una
cattura ferma non la mostra.**

Tutte le guardie di questa schermata misurano geometrie: quanto e' largo,
dove comincia, cosa copre cosa. Nessuna misurava **quanto dura**. Eppure il
difetto che ti ha fatto arrabbiare era esattamente li': un'animazione che
girava venti volte piu' in fretta occupava gli stessi pixel negli stessi
posti, e **ogni singola guardia restava verde**.

L'ho trovato perche' una cattura diceva *"Il respiro e' compiuto"* otto
secondi dopo l'inizio di un respiro che dura ventotto. **Non era un pixel
sbagliato: era un orologio.**
