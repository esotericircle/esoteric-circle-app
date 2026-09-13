# RAPPORTO DELL'ORDINE DI, IL VIAGGIO DELLO SCIAMANO DIVENTA UN PERCORSO

**Voce DI.17.** 13 settembre 2026. Ramo `claude/esoteric-circle-master-order-e798aj`.
**Nessuna build**: non e' stata ordinata, e non e' partita. L'ultima consegnata
resta la 2249.

Lo stato voce per voce, con le misure e le prove, sta nel manifesto
`docs/ordini/ORDINE_DI_MANIFESTO.md`. Qui ci sono le cinque cose che la voce
DI.17 chiede, e prima di loro cio' che il fondatore deve sapere per decidere.

---

## 1. Che cosa aspetta una decisione del fondatore

1. **Il modello, A o B.** L'ordine nomina Gemini 3.5 Flash Lite e Gemini 3.6
   Flash, che rispondono **solo dall'endpoint `global`**. Montata e' la scelta
   B: Gemini 2.5 Flash Lite e 2.5 Flash su `europe-west1`, dove l'app tiene i
   dati. Misurate tutte e due (DI.02 e DI.03): la B e' piu' veloce e non ha mai
   sforato la pazienza; la A ha avuto una chiamata da venti secondi. Cambiare
   e' una costante per modello.
2. **Il tamburo della discesa.** Lo slot c'e', `assets/audio/tamburo_della_discesa.mp3`,
   con le misure in `assets/audio/LEGGIMI.md`; il file e' da scegliere.
3. **I disegni dei sei gesti del segno per i dodici animali**, settantadue, da
   commissionare: oggi il gesto e' l'illustrazione che si muove.
4. **La "Domanda al Maestro reale"** che il listino promette all'Illuminato, una
   al mese con risposta entro 48 ore: nel codice non la implementa niente.
5. **I titoli del responso sono otto per tema.** Dopo l'ordine DI sono l'unico
   pezzo del responso che torna spesso: per chi scende ogni giorno con la
   stessa domanda, lo stesso titolo ogni otto giorni. Tutto il resto non torna
   prima di centinaia di discese. La misura D dell'ordine DF non conta i titoli,
   ed e' giusto che il fondatore lo sappia: portarli a cinquanta per tema e'
   lavoro di scrittura, nella sua voce, e lo propongo.
6. **Una frase dell'onboarding e' cambiata**: la rivelazione del Maestro diceva
   *"Trascina il dito per svelare, come un gratta e vinci"*, e l'ordine vieta
   quel nome in ogni punto dell'interfaccia. Adesso dice *"Trascina il dito per
   svelare"*.
7. **La misura C con rete, in un caso su undici, e' al 40,7 per cento**, sette
   decimi sopra la soglia: due responsi alla stessa domanda libera con la
   stessa frase di risposta e la stessa cosa raccontata con la stessa forma,
   perche' il modello torna su quell'oggetto una ventina di volte su cento e
   le forme della frase della scena sono otto. **Due leve, e sono una
   scelta**: scrivere piu' forme per la frase che cuce la scena, oppure
   allungare la memoria dei ritorni della cosa, che vuol dire meno oggetti
   ricorrenti per la stessa domanda. Consiglio la prima, perche' non toglie al
   modello niente di cio' che sceglie per la persona.
8. **`siPuoComprareAncora`** e' rimasta come funzione che torna sempre falso:
   la sua premessa, una discesa in piu' comprata con gli Eos, non esiste in
   nessuna strada del codice. La si puo' togliere quando il fondatore decide
   che non tornera'.

**Niente di tutto questo e' stato verificato a video**: la discesa col filmato
e il dito, il velo di cenere, il tamburo a schermo pieno, il segno. Servono una
build e il telefono.

---

## 2. Le cinque misure, per ogni tema e per ogni domanda libera

**La prova** e' `test/la_prova_a_cento_discese_test.dart`: cento discese
consecutive, un giorno ciascuna, con la stessa domanda e lo stesso profilo (il
Lupo, Sole Cancro, Luna Scorpione, Ascendente Pesci, 7), per i sei temi e per
cinque domande libere. **La strada e' quella dell'app**: un Diario vero, la
scena scelta dal modello o dalla via deterministica con gli argomenti della
risalita, e il responso composto da `IlResponsoDelViaggio`, che e' la stessa
funzione che la schermata chiama. Senza rete gira sempre ed e' una guardia; con
rete chiama Vertex davvero, una discesa alla volta, col token nell'ambiente.

**Come si leggono le colonne.** A, testi distinti su cento. B, scheletri
distinti, e fra parentesi quante volte torna il piu' ripetuto. C, la
somiglianza della coppia peggiore **su tutte le 4.950 coppie**, e dopo la
barra quella fra le coppie senza simboli in comune, la soglia dell'ordine DF.
D, quante volte torna il paragrafo composto piu' ripetuto. E, in quanti
responsi c'e' un riferimento riconoscibile al tema. Soglie: A 100, B almeno
90 e nessuno oltre 3, C sotto 40, D non oltre 2, E almeno 95. **Il richiamo**
e' in quante discese compare: raro per scelta, e sempre vero.

### Senza rete: lavorano le vie di riserva

| caso | tema | A | B | C tutte / senza simboli | D | E | titolo piu' ripetuto | richiamo | la stessa azione torna dopo | la stessa risposta torna dopo |
|---|---|---|---|---|---|---|---|---|---|---|
| Una scelta da fare | scelta | 100 | 100 (1) | 36,4 / 31,0 | 1 | 100 | 13 | 10 | 20 | 11 |
| Una persona | persona | 100 | 100 (1) | 34,3 / 34,3 | 1 | 100 | 14 | 14 | 20 | 11 |
| Un blocco che non si supera | blocco | 100 | 100 (1) | 36,8 / 31,3 | 1 | 100 | 13 | 9 | 20 | 11 |
| Un tempo che non arriva | attesa | 100 | 100 (1) | 32,8 / 28,8 | 1 | 100 | 14 | 11 | 20 | 11 |
| Una direzione da prendere | direzione | 100 | 100 (1) | 32,4 / 32,4 | 2 | 100 | 14 | 11 | 20 | 11 |
| Qualcosa che e' finito | finito | 100 | 100 (1) | 28,0 / 28,0 | 1 | 100 | 14 | 14 | 20 | 11 |
| *Mia sorella diventera' presto mamma?* | attesa, dalla tabella | 100 | 100 (1) | 37,1 / 30,7 | 1 | 100 | 14 | 11 | 20 | 11 |
| *Devo lasciare il mio lavoro per aprire qualcosa di mio?* | nessuno | 100 | 100 (1) | 34,5 / 34,5 | 2 | **0** | 26 | 11 | 20 | 7 |
| *Perche' con mio padre finisce sempre in lite?* | nessuno | 100 | 100 (1) | 34,1 / 31,4 | 2 | **0** | 26 | 11 | 20 | 7 |
| *Da mesi non riesco a finire niente di quello che comincio.* | blocco, dalla tabella | 100 | 100 (1) | 38,5 / 38,5 | 1 | 100 | 13 | 9 | 20 | 11 |
| *Ho chiuso con Luca dopo sei anni, e adesso?* | finito, dalla tabella | 100 | 100 (1) | 35,3 / 31,1 | 1 | 100 | 14 | 12 | 20 | 11 |

**Le due distanze non sono misure dell'ordine**, e le ha aggiunte la voce
DI.16: le cinque misure non vedono la stessa azione suggerita a tre giorni di
distanza, e chi legge si'. La risposta senza tema ha otto forme, e torna dopo
sette discese. Nelle domande libere la distanza della risposta si legge sulle
risposte del tema capito.

**La E a zero di due domande libere e' la riserva dichiarata della voce
DI.02**: senza rete decide la tabella delle parole, che capisce una domanda su
tre e non ne sbaglia nessuna. Quelle due non le capisce, il responso esce sul
ramo senza domanda, che l'ordine dice legittimo, e non nomina un tema che non
c'e'. Con rete le capisce il modello.

### Con rete: il modello vero

| caso | tema | A | B | C tutte / senza simboli | D | E | scena dal modello | titolo piu' ripetuto | richiamo | azione dopo | risposta dopo | guasti della scena, nei due tentativi |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Una scelta da fare | scelta | 100 | 100 (1) | 33,3 / 29,0 | 1 | 100 | 98 | 13 | 1 | 20 | 11 | scartate: 22 |
| Una persona | persona | 100 | 100 (1) | 35,3 / 35,3 | 1 | 100 | 97 | 14 | 9 | 20 | 11 | scartate: 19 |
| Un blocco che non si supera | blocco | 100 | 100 (1) | 38,7 / 38,7 | 1 | 100 | 96 | 13 | 7 | 20 | 11 | scartate: 28, scadute: 1 |
| Un tempo che non arriva | attesa | 100 | 100 (1) | 36,5 / 29,6 | 1 | 100 | 94 | 14 | 4 | 20 | 11 | scadute: 1, scartate: 25 |
| Una direzione da prendere | direzione | 100 | 100 (1) | 36,1 / 30,2 | 2 | 100 | 93 | 14 | 4 | 20 | 11 | scartate: 34, scadute: 1 |
| Qualcosa che e' finito | finito | 100 | 100 (1) | 31,0 / 27,1 | 1 | 100 | 99 | 14 | 5 | 20 | 11 | scartate: 21 |
| *Mia sorella diventera' presto mamma?* | attesa, dal modello | 100 | 100 (1) | 29,9 / 29,9 | 1 | 100 | 88 | 14 | 8 | 20 | mai | scartate: 49, scadute: 1 |
| *Devo lasciare il mio lavoro per aprire qualcosa di mio?* | scelta, dal modello | 100 | 100 (1) | 31,6 / 31,6 | 1 | 100 | 96 | 13 | 3 | 20 | mai | scartate: 21 |
| *Perche' con mio padre finisce sempre in lite?* | blocco, dal modello | 100 | 100 (1) | 40,7 / 38,5 | 1 | 100 | 100 | 13 | 5 | 20 | mai | scartate: 23 |
| *Da mesi non riesco a finire niente di quello che comincio.* | blocco dal modello: 99, blocco dalla tabella: 1 | 100 | 100 (1) | 39,5 / 39,5 | 1 | 100 | 93 | 13 | 4 | 20 | mai | scartate: 33, scadute: 2 |
| *Ho chiuso con Luca dopo sei anni, e adesso?* | finito, dal modello | 100 | 100 (1) | 36,2 / 28,0 | 1 | 100 | 93 | 14 | 6 | 20 | mai | scartate: 29 |

**La scena del modello e' usata in 88-100 discese su cento**; nelle altre decide la via deterministica, perche' la lettura ha scartato due volte di seguito una scena che rifaceva una scena della storia. **La C peggiore su tutte le coppie e' 40,7 per cento.** Le chiamate della prova sono 1.856, per 1.391.562 token in ingresso e 54.820 in uscita.


---

## 3. La classificazione della voce DI.02

**La via principale e' il modello**, a temperatura zero, con la risposta
vincolata ai sei id; **la riserva e' la tabella delle parole**,
`IlTemaDellaDomandaLibera`, che decide quando il modello non risponde in due
secondi. La tabella dell'ordine, a rete staccata, e le misure col modello
vero stanno per intero nel manifesto, sezione DI.02; qui i numeri.

**A rete staccata, la tabella delle parole**:

| gruppo di domande | capite | sbagliate | come si legge |
|---|---|---|---|
| le venti del gruppo dell'ordine | 20 su 20 | 0 | prova di regressione: la tabella le conosceva mentre la scrivevo |
| il terzo gruppo, scritto dopo averla congelata | 3 su 12 | **2** | e' la misura che ha fatto cambiare due principi |
| il quarto gruppo, scritto dopo i due principi | 4 su 12 | **0** | la misura onesta: capisce una domanda su tre, non ne sbaglia nessuna |

**Col modello vero, sulle 56 domande di prova**, con la stessa istruzione e lo
stesso elenco chiuso:

| modello | giuste | mediano | peggiore | oltre 2 s |
|---|---|---|---|---|
| `gemini-2.5-flash-lite`, `europe-west1`, montato | 53 su 56 | 0,44 s | 1,30 s | 0 |
| `gemini-3.5-flash-lite`, `global`, dell'ordine | 54 su 56 | 0,69 s | 20,04 s | 1 |

**Nella prova a cento discese**, le cinque domande libere, cento volte
ciascuna: senza rete la tabella ne capisce tre (attesa, blocco, finito) e due
restano senza tema; con rete il modello le capisce tutte e cinque, cento
volte su cento, ciascuna sempre nello stesso tema: *attesa* per la sorella che
aspetta un figlio, *scelta* per il lavoro da lasciare, *blocco* per il padre
con cui si litiga e per le cose che non si finiscono, *finito* per Luca. La
domanda sul padre e' la sola che si poteva leggere anche come *persona*: il
modello la legge come un blocco, e l'istruzione gli chiede proprio *cosa la
persona sta chiedendo, non di chi parla*.

---

## 4. I punti dell'app con lo stesso difetto della voce DI.01

**Il difetto della voce DI.01**: un'etichetta per le persone confrontata con
un identificatore stabile. Lo schermo teneva il tema come l'etichetta *"Una
scelta da fare"*, la voce del Mondo di Sotto lo cercava come `scelta`, e il
tema arrivava nullo per tutte e tre le vie: le risposte scritte per tema non
le aveva mai lette nessuno. **Curato col tipo**, `TemaDellaDomanda`: scrivere
l'etichetta dove va il tema non compila.

**Il censimento, in tre passate**: i confronti diretti fra un campo id e un
campo etichetta; le undici funzioni che cercano per id una stringa venuta da
fuori, coi loro chiamanti; le etichette usate come chiave di una mappa o di un
confronto.

| punto | che cosa succedeva | cura |
|---|---|---|
| lo schermo del Viaggio e la voce del Mondo di Sotto | il tema arrivava nullo, sempre | il tipo `TemaDellaDomanda`; guardia `il_tema_della_domanda_arriva_alla_risposta`, che fa la strada intera |
| **la matrice dei piani** | le righe si cercavano per etichetta, e un'etichetta non trovata ripiegava in silenzio: la memoria dei Maestri gratis per tutti, il limite giornaliero illimitato, la Profonda tolta a chi l'ha pagata | il tipo `RigaDelPiano`, dieci chiavi |
| **il registro lunare delle rune del tramonto** | indicizzato col nome italiano della fase | una guardia: le chiavi del registro sono esattamente i nomi che la fase sa produrre |
| il segno del ricordo dell'oroscopo | accettato in tre forme, di proposito | nessuna: verificato |
| i pianeti degli eventi del cielo | `sun` da tutte e due le parti | nessuna: verificato |

Le altre funzioni che cercano per id ricevono tutte id scritti dal codice.
**La guardia di famiglia** e' `le_etichette_non_fanno_da_chiave`.

---

## 5. Le chiamate al modello e il costo per utente attivo al giorno

**Le chiamate del Viaggio sono tre**, e tutte su `europe-west1`: la scena,
Gemini 2.5 Flash, a ogni discesa; il tema della domanda libera, Gemini 2.5 Flash
Lite, a ogni discesa con una domanda scritta a mano; il segno dell'animale,
Gemini 2.5 Flash Lite, dopo il riconoscimento. Il nutrimento non chiama nessun
modello.

| chiamata | token in ingresso | in uscita | tempo mediano | da dove viene il numero |
|---|---|---|---|---|
| scena | 929 | 40 | circa 0,7 s | la prova a cento discese, 1.356 chiamate di scena |
| tema | 264 | 2 | 0,41 s | dieci chiamate vere |
| segno | 351 | 43 | 0,61 s | dieci chiamate vere |

**Con i prezzi di listino di Vertex AI che conosco**, da riverificare sul
listino del giorno: Gemini 2.5 Flash 0,30 dollari per milione di token in
ingresso e 2,50 in uscita, Gemini 2.5 Flash Lite 0,10 e 0,40. Una scena costa
0,000378 dollari, un tema 0,000027, un segno 0,000052. **Una discesa costa 0,000493 dollari**, contando
i secondi tentativi della scena: 1,23 chiamate di scena per discesa nella prova.
La stima dell'ordine era di due decimi di centesimo a discesa.

**Per utente attivo al giorno**, dopo il riconoscimento, chi usa tutto cio' che
il suo piano concede e scrive sempre la domanda a mano:

| piano | discese al giorno | segni al giorno | chiamate al giorno | dollari al giorno | al mese |
|---|---|---|---|---|---|
| Viandante | 1 | 0,14 | 2,4 | 0,00050 | 0,015 |
| Iniziato | 1 | 0,43 | 2,7 | 0,00052 | 0,015 |
| Adepto | 1 | 1 | 3,2 | 0,00055 | 0,016 |
| Illuminato | 2 | 5 | 9,5 | 0,00125 | 0,037 |

**Prima del riconoscimento** e' una discesa al giorno per tutti: 2,2 chiamate,
0,00049 dollari. **Il tetto tecnico e' di dieci chiamate al giorno**, voce DI.15:
l'Illuminato che usa tutto ci arriva a filo coi secondi tentativi, e quando lo
passa la chiamata di troppo la fa la riserva, senza che la persona se ne
accorga.


---

## 6. Le righe di codice rimosse perche' mai raggiunte

**Contate sui diff dei commit dell'ordine**, righe tolte in `lib`, al netto
delle righe soltanto riformattate o spostate.

### Mai raggiunte a runtime: circa 203 righe

| voce | file | che cosa | righe | perche' non si raggiungevano |
|---|---|---|---|---|
| DI.09 | `il_tunnel_che_scende.dart` | i diciotto anelli, la spirale, il filo di luce, `quantiAnelli`, `latiDellAnello`, `giriDellaSpirale`, `raggioDellAnello`, `formeAlCulmine`, `_anello()`, `_coloreLontano()` | circa 190 | si disegnavano solo senza la roccia sotto, e la roccia c'era sempre |
| DI.09 | stesso file | il parametro `sopraLaRoccia`, con l'argomento `true` | 9 | il ramo falso non si percorreva mai |
| DI.15 | `tetti_del_viaggio.dart` | il ramo che rispondeva di si' in `siPuoComprareAncora` | 3 | nessuna strada del codice vende una discesa; la funzione resta, vedi il punto 8 della sezione 1 |

### Raggiungibili, e sostituite dall'ordine: circa 905 righe

| voce | che cosa | righe |
|---|---|---|
| DI.10 | la lente, `la_lente_che_scopre.dart`: `LenteCheScopre`, `_ConLaMisuraVera`, il ritaglio circolare, il ritaglio della fascia | circa 545 |
| DI.10 | gli aiuti della lente in `dove_sta_la_testa.dart`: le tre fasce, il raggio, il punto dove tenerne il centro | 126 |
| DI.10, DI.16 | nella schermata: il blocco della lente, il giorno della scena, la composizione del responso spostata in `IlResponsoDelViaggio` | circa 57 |
| DI.09 | la discesa col timer: `primaDiscesa`, `discesaConosciuta`, `_quantoDura`, `_premi()`, `_lascia()`, il tunnel col dito | circa 89 |
| DI.07 e DI.08 | le tre cose da sapere e *"Dodici ti aspettano"* | circa 60 |
| DI.11, DI.14 | il tamburo in un tocco, `_battiIlTamburo()`, e *"Lo hai richiamato oggi"* | 15 |
| DI.15 | la mappa `domandeAlGiorno` e la frase sugli Eos | 12 |

**L'ombra dell'animale non e' fra le righe tolte**: stava nel file della lente,
serve a cinque schermate, e ha un file suo, `l_ombra_dell_animale.dart`.

---

## 7. I difetti trovati, e i loro padri

Regola C: ogni difetto col suo padre. Qui ci sono quelli trovati **dopo** le
voci che li hanno causati: dalla suite intera fatta girare per chiudere la
voce DI.10, dalle catture del velo, e dalla prova a cento discese. Quelli
trovati e chiusi dentro la loro stessa voce stanno nel manifesto.

| difetto | padre | come si e' visto | cura |
|---|---|---|---|
| **il richiamo in cento discese su cento, anche alla prima**: *"Ti era gia' capitato di vedere la chiave"* a chi scendeva per la prima volta | **DE voce 11**, commit `09f8915d`: il richiamo si calcolava dopo aver segnato la discesa di oggi | prova a cento discese | `IlResponsoDelViaggio` prende le discese di prima; prova sulla schermata vera |
| il titolo ripetuto fino a trenta volte su cento, risposta e gesto fino a tre | **DG voce 07**, commit `6691242e`, con le forme pescate dal filo | prova a cento discese | la voce del Viaggio gira: gesto e risposta su due cicli, cornici iniettive e mescolate, titolo fuori fase, frase della scena scelta dalla storia |
| *"Non sei bloccato"* e *"saresti pronto?"*, al maschile verso chi legge | **DG voce 07**, commit `6691242e`; la guardia della DI.05 aveva un elenco chiuso di sei participi | prova a cento discese, leggendo i responsi | riscritte neutre; guardia allargata alla forma del difetto |
| meta' delle scene del modello scartate su cento discese | **DI voce 03**, mia: la regola del pezzo ripreso chiesta al modello e punita dopo | prova a cento discese col modello vero | lo schema non ammette luoghi e gesti gia' visti; la scena scartata si richiede una volta |
| tre `Text` di lettura fuori da `ParagrafiDiLettura` | **DI voci 13 e 14**, mie | suite intera, `etichette_e_lettura` | `ParagrafiDiLettura` |
| i giorni contati sottraendo due date locali | **DI voce 15**, mia | suite intera, `il_giorno_si_conta_dalla_porta` | `ConfineDelGiorno.giorniDa` |
| tre `catch` muti | **DI voci 03 e 14**, mie | suite intera, `nessun_catch_muto` | `catch (errore)` col perche' scritto |
| il Viaggio consumatore nuovo dei dati di nascita, conto fermo a 15 | **DI voce 03**, mia: non un difetto, un conto da aggiornare | suite intera, `la_catena_dei_dati_di_nascita` | 16, verificato che passa dalla porta unica |
| le righe della griglia delle sagome finite in doppio punto | **DI voce 10**, mia | suite intera, `testi_falsi` | il vuoto e' un trattino |
| il censimento dei vuoti verticali a 149 invece di 148 | **DI voce 10**, mia: togliere la lente ha tolto uno spazio | suite intera, `tipografia_nel_dato` | rigenerato col suo strumento |
| la cenere a bolle, le parti sottili scoperte, i palchi di cenere, il cumulo a rettangolo | **DI voce 10**, mie, nelle prime stesure | le catture, prima del commit | vedi il manifesto, sezione DI.10 |

**Le voci DI.03, DI.13, DI.14 e DI.15 erano state spinte senza la suite
intera.** E' la ragione per cui cinque difetti sono arrivati fino a qui, e
non si ripete: la suite intera gira prima di ogni commit di questa consegna.

**Una cosa vista e non curata, perche' fuori dall'ordine**: il Diario conserva
novanta discese, `quantiNeTiene`, e `quanteDiscese` e' la loro lunghezza.
Dalla novantunesima discesa in poi il conto resta fermo a novanta: il
riassunto per i Maestri direbbe *"ha fatto 90 discese"* per sempre, e il
numero della discesa smette di entrare nel seme della scena. Padre: **DC voci
04, 05, 06, 08 e 09**, commit `1e2d116a`. Si cura contando le discese a parte;
aspetta un ordine.
