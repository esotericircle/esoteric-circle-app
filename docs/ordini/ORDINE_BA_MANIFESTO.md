# ORDINE BA, il manifesto

**DUE COSE.** Sul ramo `claude/esoteric-circle-master-order-e798aj`.

**Nasce dal collaudo del fondatore sulla 2195**, ed e' scritto col metodo
nuovo: il fondatore porta i fatti, cause e cure le decide chi sviluppa.

## Cosa ha funzionato, e va detto per primo

**La sequenza dell'ordine AZ e' verificata sul dispositivo.** Il fondatore ha
disinstallato, reinstallato, ed e' arrivato in home dopo che il Cerchio gli ha
mostrato cio' che custodiva. Il fatto F2, che aveva resistito a piu' giri, non
si e' ripresentato.

## Come si legge questo file

Ogni voce porta uno stato fra cinque: CHIUSA, APERTA, FERMATA SU PREMESSA
FALSA, FERMATA IN ATTESA DI DECISIONE, FERMATA SU DECISIONE DEL FONDATORE. In
fondo ci sono i marcatori, che la guardia `test/ordine_ba_guard_test.dart`
conta sulle righe.

## Le voci

- **BA.00** Manifesto e misure di partenza. Stato: CHIUSA
- **BA.01** Lo sfondo parte in ritardo. Stato: CHIUSA
- **BA.02** I Maestri coprono il messaggio sopra di loro. Stato: APERTA

## BA.01: la misura di partenza, e il fatto e' esatto

**La riga diagnostica del fondatore diceva gia' tutto**, e nessuno l'aveva
letta come una misura. Sulla 2195, col telefono in mano:

```
Mano: -2.0 e 4.8 gradi dal riposo, su 30 a fondo corsa.
Risposta dopo la curva 0.00 e 0.00 su 1,00.
Piano di fondo: 0.5 e 0.0 punti dalla mano, -14.6 dallo scorrimento.
Il cielo si ridipinge a 30 fotogrammi al secondo.
```

**Quattro virgola otto gradi, e il piano si muove di zero punti.**

### Non e' un ritardo di tempo: e' una soglia di angolo

La zona morta vale `0.085` **in seno**, cioe' **4,88 gradi**. Il fondatore
aveva la mano a **4,8 gradi**: sotto la soglia, per otto centesimi di grado.
La curva vera, calcolata sui parametri del ramo:

| inclinazione | punti sugli 80 |
|---|---|
| fino a 4,8 gradi | **0,0** |
| 5 gradi | 0,2 |
| 6 gradi | 2,8 |
| 8 gradi | 8,5 |
| 10 gradi | 14,6 |
| 15 gradi | 30,7 |
| 30 gradi | 80,0 |

**Il cielo non parte finche' non si inclina di quasi cinque gradi, e non si
vede niente fino a otto.** Chi muove il telefono di poco, come si fa
guardandolo, non vede muoversi nulla: **e' esattamente "sembra partire in
ritardo rispetto al movimento che applico"**.

### Perche' l'ordine AW non lo aveva trovato

**Le misure di AW sono vere e restano**, e non sono in contraddizione con
questo fatto: guardavano il TEMPO, cioe' quanti fotogrammi cambiano e quanto
salta il valore dipinto fra l'uno e l'altro. **Nessuna guardava quanti gradi
servono perche' il cielo cominci a muoversi.** Un cielo che si ridipinge
perfettamente a ogni fotogramma, ma solo dopo cinque gradi, passa tutte quelle
prove e sembra comunque in ritardo.

**E la soglia l'ho alzata io**, con l'ordine AV voce 02: la zona morta e'
passata a 0,085 per tenere la mano ferma a zero punti, e il fondo corsa a 30
gradi con l'ordine AW. Le due cose insieme fanno una partenza lenta.

## BA.02: la misura e' onesta, e i primi numeri erano gonfiati

**La misura sui pixel adesso c'e', ed e' quella che l'ordine AX voce 02
imponeva**: si dipinge la home due volte, con e senza la vernice dei Maestri,
e si contano i pixel del testo che cambiano. Le tre misure precedenti
dicevano ZERO confrontando rettangoli di layout, e le figure escono dal
proprio riquadro con `Clip.none`.

**E LA PRIMA VERSIONE DI QUESTA MISURA ERA FALSA. Si dichiara.** Diceva
37.621, 46.642 e 39.277 pixel coperti. **Erano gonfiati dal movimento delle
stelle**: fra la cattura con i Maestri e quella senza passavano sessanta
millesimi, e il cosmo scorre. Il segno che ha smascherato il numero e' che
"i Maestri arrivavano fino alla riga ZERO dello schermo", cioe' sopra il
titolo e sopra la barra, che e' impossibile.

**Adesso la misura porta la propria controprova**: due catture di seguito
senza cambiare niente devono dare **zero** differenze, e le due catture vere
sono separate da un `pump` che non fa scorrere il tempo.

**I numeri veri, dopo la prima cura**: **831** pixel su schermo alto, **4.712**
sul medio, **25.425** sul basso.

**La prima cura, e non basta.** Il calcolo dell'altezza del busto faceva
`math.max` fra un pavimento di 220 punti e lo spazio che il blocco del cielo
concede: **quando il pavimento vinceva, il busto era per definizione piu' alto
dello spazio disponibile**. Adesso comanda il vincolo, e solo un pavimento
assoluto di 150 punti puo' scavalcarlo, per gli schermi cosi' corti che sotto
quella soglia un Maestro non si riconosce piu'.

**La voce resta APERTA**, e la prova resta rossa a dichiararlo: **non e' una
guardia rossa apposta, e' un difetto ancora aperto con la sua misura**. Lo
schermo basso e' il caso peggiore, ed e' li' che il vincolo e il pavimento si
scontrano davvero.

## I marcatori

VOCI_TOTALI: 3
VOCI_APERTE: 1
VOCI_CHIUSE: 2
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
