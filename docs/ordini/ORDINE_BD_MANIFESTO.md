# ORDINE BD, il manifesto

**I MAESTRI GRANDI E I SOSPESI.** Otto voci, dalla BD.00 alla BD.07, sul ramo
`claude/esoteric-circle-master-order-e798aj`. Nasce dal collaudo della build
2198 e raccoglie i lavori che i responsi degli ordini AU, BB e BC avevano
dichiarati aperti.

## Come si legge questo file

Ogni voce porta uno stato fra cinque: CHIUSA, APERTA, FERMATA SU PREMESSA
FALSA, FERMATA IN ATTESA DI DECISIONE, FERMATA SU DECISIONE DEL FONDATORE. In
fondo ci sono i marcatori, che la guardia `test/ordine_bd_guard_test.dart`
conta sulle righe.

## Le premesse, verificate prima di lavorare

**Sei premesse su sette sono esatte. Una e' falsa e si dichiara qui con la via
scelta, invece di adattare in silenzio.**

### BD.01: esatta

Sulla build 2198 il busto centrale misura 247 punti su schermo alto e le tre
carte non si toccano: fra la centrale e ciascuna laterale c'e' aria. Le parole
del fondatore chiedono l'opposto: cosi' grandi che la centrale copra in parte
le laterali, e la sovrapposizione E' la profondita'. Restano ferme le
decisioni gia' prese: davanti ai testi, interi a ogni inclinazione, tocco vivo
su tutti e tre.

### BD.02: esatta

3.288 passate e 38 cadute, contate dal giro intero della suite dopo l'ultima
riga della coda di BC.01. La preesistenza e' gia' stata verificata due volte:
ricostruendo l'albero di prima dell'ordine BC in un worktree su `e5507912`, e
scambiando il solo file del Santuario. La bonifica era un'offerta del responso
BC: il fondatore accetta, quindi ogni caduta diventa verde o viene dichiarata
una per una col motivo per cui resta.

### BD.03: esatta al numero

Contato sul catalogo vero, `assets/data/luoghi.csv`: **8.438 luoghi italiani**
(il terzo campo porta la provincia) e **3.108 luoghi esteri in 241 paesi** (il
terzo campo porta il paese). L'Italia si disegna dai suoi luoghi con
`mappa_della_nazione.dart`; ogni altro paese vede il planisfero. **E il buco
del catalogo e' confermato: 116 paesi hanno una sola citta'**, quindi
qualunque strada disegni gli altri paesi dai loro luoghi trovera' 116 nazioni
con un punto solo. Il buco resta dichiarato e NON si sana in questa voce.

### BD.04: esatta

Dichiarata dal responso BB e ancora vera: sullo schermo 320 per 568 il blocco
del cielo pesa piu' della meta' dell'altezza e i Maestri si vedono appena. Si
chiude INSIEME a BD.01, perche' ingrandire i Maestri e liberare lo schermo
piccolo sono la stessa geometria guardata da due schermi diversi.

### BD.05: esatta

Dichiarata dal responso AU: i gradini dell'identita' maturano tutti nello
stesso istante alla fine dell'onboarding, la coda delle feste li mostra uno
per volta ma la causa sta nelle condizioni dei traguardi, che l'onboarding
soddisfa in blocco. L'effetto voluto dal fondatore resta quello di allora: una
sola festa alla fine dell'onboarding, le altre legate a gesti veri successivi.

### BD.06: esatta sulla card, e il dato sta meglio di come l'ordine temeva

La scritta "obiettivo raggiunto il [data e ora]" non esiste in nessun
riquadro, verificato su `lib/`. **Ma l'istante e' gia' salvato dall'ordine
AP**: `DiarioDelCammino` custodisce `cammino.accesi.quando` e la legge
`quandoSiEAcceso(id)` dichiara gia' la regola giusta, i Sigilli accesi prima
dell'ordine AP non hanno data e non se ne inventa una. Qui si aggiunge la
scritta alla card, non il dato.

### BD.07: UNA PREMESSA E' FALSA, e la via scelta si dichiara qui

Il file dell'Architetto ordina di rigenerare `horoscope_data.dart` con
`tool/_gen_oroscopo.py` **e quello strumento non esiste**: mai committato,
verificato con `git log --all` sull'intera storia del repo. L'intestazione di
`horoscope_data.dart` lo nomina, ma chi lo uso' non lo consegno' mai.

**La via scelta**: lo strumento si scrive adesso, con quel nome, e la prova
della sua fedelta' e' il giro di andata e ritorno: rigenerato dal corpus
ATTUALE deve riprodurre il `horoscope_data.dart` attuale. Solo dopo quella
prova si sostituiscono le ancore. Se il giro non torna, la voce si ferma e lo
si dice.

Il resto del file dell'Architetto combacia col codice e col corpus: la sezione
"Le ancore dei dodici segni" sta a riga 43 di `docs/corpus/oroscopo.md`, i
dodici titoli di segno coincidono, e `oroscopo_share_card.dart` mostra davvero
la sintesi nuda.

## Le voci

- **BD.00** Manifesto e verifica delle premesse. Stato: CHIUSA
- **BD.01** I Maestri ancora piu' grandi, con la sovrapposizione. Stato: APERTA
- **BD.02** Le 38 prove rosse, la bonifica. Stato: APERTA
- **BD.03** Il mondo oltre l'Italia. Stato: APERTA
- **BD.04** Lo schermo piccolo. Stato: APERTA
- **BD.05** I gradini dell'identita' che maturano insieme. Stato: APERTA
- **BD.06** La data e l'ora sulla card del traguardo. Stato: CHIUSA
- **BD.07** Le quarantotto ancore dell'Oroscopo. Stato: CHIUSA, con le 48 virgole tolte per il precedente del fondatore

## L'ordine di lavoro, deciso qui

1. **BD.07**, per prima perche' e' autonoma dal resto: corpus, generatore da
   scrivere con la prova di andata e ritorno, due guardie, anteprime della
   card guardate.
2. **BD.06**, che e' una scritta e un dato gia' esistente da mostrare.
3. **BD.05**, che e' la regia delle feste e va misurata con un onboarding
   simulato.
4. **BD.01 e BD.04 insieme**, perche' sono la stessa geometria: i Maestri
   crescono fino a sovrapporsi e lo schermo piccolo li deve vedere.
5. **BD.03**, il mondo, che tocca la mappa e il catalogo.
6. **BD.02 per ultima**, perche' la bonifica misura la geometria che BD.01 ha
   appena cambiato: bonificare prima vorrebbe dire bonificare due volte.

## Cosa BD.07 ha trovato e deciso, e va detto

**Lo strumento mancante e' stato scritto**, `tool/_gen_oroscopo.py`, e la sua
fedelta' e' provata dal giro di andata e ritorno: PRIMA di toccare le ancore
ha rigenerato dal corpus di quel momento il `horoscope_data.dart` allora in
vigore, carattere per carattere. Solo dopo quella prova le ancore nuove sono
entrate. Il giro resta verde anche dopo l'innesto.

**Le 48 virgole prima della "e", una per ancora.** Ogni ancora dell'Architetto
portava una virgola prima della "e", e la regola della casa la vieta in ogni
stringa di `lib`. Non e' stata chiesta una deroga, perche' il fondatore l'ha
gia' negata una volta con la ragione scritta nella prova stessa: quella
virgola e' sempre stilistica e mai portante, si toglie senza cambiare il
senso, e una regola con un elenco di eccezioni diventa un elenco che nessuno
mantiene. Le 48 virgole sono state tolte applicando quel precedente, il testo
non e' stato toccato in nessun altro punto, e il fondatore puo' rovesciare la
scelta con una parola.

**Gli accenti sono stati resi nella forma tipografica del corpus** con una
mappa esplicita di venticinque parole, e ogni parola non mappata avrebbe
fermato l'innesto invece di indovinare.

**E l'anteprima ha trovato un difetto suo**: sulla card del Toro il titolo
"L'abbondanza concreta" usciva spezzato in mezzo alla parola, "L'ABBONDANZ A".
La bolla prometteva nel commento "va a capo e si rimpicciolisce" ma il
rimpicciolimento non esisteva. Adesso esiste, con quattro punti di respiro dal
bordo, perche' scalare al pareggio lasciava la parola a un decimo di punto dal
limite. La cattura della card copre ora TRE segni invece di uno, Ariete, Toro
e Pesci, e le tre anteprime sono state guardate.

## I marcatori

VOCI_TOTALI: 8
VOCI_APERTE: 5
VOCI_CHIUSE: 3
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
