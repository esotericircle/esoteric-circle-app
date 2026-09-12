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
- **BA.02** I Maestri coprono il messaggio sopra di loro. Stato: CHIUSA

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

## BA.02 chiusa: la terza misura era ancora sbagliata, e la cura era altrove

**Anche la seconda misura era falsa, e l'ha smascherata una mappa dipinta.**
Contava i pixel che cambiano dentro il RETTANGOLO del testo, ma un rettangolo
di testo e' quasi tutto vuoto. Dipinta la mappa della differenza, su schermo
alto la cima dei Maestri entrava nelle ultime quattordici righe di quel
rettangolo, **dove lettere non ce ne sono**: la prova dichiarava 830 pixel
coperti mentre a video non era coperto niente. Era il difetto denunciato tre
volte, il rettangolo al posto della vernice, spostato di un livello.

**La terza misura conta le LETTERE.** Si dipinge una terza volta anche senza
il testo, e la differenza fra quella e la scena senza Maestri e' l'insieme
esatto dell'inchiostro. **La prima stesura di questa misura non funzionava**,
e l'ha detto la guardia dentro la prova stessa: una bandiera globale che
cambia non fa ridipingere niente, e il conto dava zero pixel di inchiostro,
cioe' avrebbe dichiarato risolto un difetto **non guardandolo**. Con un
notificatore al posto del booleano il ridisegno e' certo.

**I numeri veri, finalmente**: su 7.344 pixel di inchiostro ne erano coperti
**210** su schermo alto, **966** sul medio, e **5.979 su 7.107 sul basso, cioe'
l'ottantaquattro per cento del testo**.

**La cura non era l'altezza del busto, ed e' per questo che tre tentativi di
restringerlo non erano bastati.** Il riquadro del carosello poteva salire
dentro il blocco del cielo, e le figure ne uscivano pure con `Clip.none`:
qualunque conto sull'altezza lasciava scoperto il caso in cui il pavimento
minimo vince sullo spazio concesso. Adesso due cose insieme, e nessuna delle
due da sola bastava: **il carosello e' ritagliato** con una dissolvenza in
cima, cosi' sopra la sua zona non arriva un pixel per costruzione; e **il suo
riquadro non puo' piu' essere piu' alto dello spazio che c'e'**.

**Misurato dopo: ZERO pixel di inchiostro coperti su tutti e tre gli
schermi.**

## Cosa resta, sullo schermo piu' piccolo, e non si tace

Su **320 per 568** il blocco del cielo occupa 258 punti su 568, e sotto ne
restano **ventiquattro**: il busto si dissolve nel ritaglio e in pratica non
si vede. Il testo si legge, ma quella home ha perso i suoi protagonisti.

**Non e' un difetto della cura, e' la stanza troppo piccola per due mobili**, e
la scelta fra i due l'aveva gia' scritta il codice: quando non stanno insieme
vince il testo, perche' un Maestro piu' piccolo si riconosce ancora e una frase
coperta a meta' non si legge affatto.

**La cura completa e' che il cielo ceda su quegli schermi**, ed e' lavoro
dichiarato e non fatto. La prova stampa a ogni giro quanti punti restano al
busto sui tre schermi, **234, 150 e 24**, cosi' il giorno in cui si fara' si sa
da che numero si parte.

## I marcatori

VOCI_TOTALI: 3
VOCI_APERTE: 0
VOCI_CHIUSE: 3
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
