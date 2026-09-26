# ESITO: I DATI DI NASCITA SBLOCCANO TUTTO

## Voce 1, i dati di nascita: CHIUSA per la parte del LUOGO

### La misura, anello per anello

Ho misurato i cinque anelli uno per uno, con una prova ciascuno, perche' una
prova sola che dice "l'ora manca" non direbbe DOVE si perde.

| Anello | Esito |
|---|---|
| 1. Ora e luogo entrano nel modello | REGGE |
| 2. Finiscono nell'archivio | REGGE |
| 3. Sopravvivono alla chiusura completa | REGGE |
| 4. Il ponte ha tutti gli otto campi | REGGE |
| 5. Le porte sono due, ed enumerate | REGGE |

**La persistenza dell'ora funziona in ogni suo anello.** Non e' li' che si
perde.

### Il difetto vero: IL LUOGO NON SI POTEVA DARE

La schermata "I tuoi dati di nascita" che ho aggiunto nel giro scorso
CONSERVAVA il luogo esistente ma non permetteva di darlo ne di modificarlo. E
la funzione pretende otto campi, fra cui latitudine e longitudine: **chi aveva
concluso il Risveglio senza luogo non poteva piu' darlo, quindi non avrebbe mai
visto un pianeta, e correggere la sola ora non lo avrebbe sbloccato.**

Adesso la schermata ha il campo del luogo con la ricerca delle citta', lo stesso
catalogo del Risveglio.

**Prova di vista passata**: tolto il campo, la prova cade.

### Le immagini

- `docs/preview/prima_dopo/dati_nascita_prima.png`
- `docs/preview/prima_dopo/dati_nascita_dopo.png`

Nella prima la schermata ha giorno e ora e basta; nella seconda c'e' "Luogo di
nascita" con la ricerca della citta' e la riga che spiega a cosa serve.

### La frase di accettazione

**Apri Area utente, "I tuoi dati di nascita", cerca la tua citta' e scegli, poi
Salva: da quel momento il Passport deve smettere di dire che l'Ascendente resta
velato.**

### Quello che NON ho verificato, e lo dichiaro

**1c non l'ho chiusa.** Con ora e luogo completi la chiamata deve partire, ma il
messaggio vero che torna nasce sul dispositivo: da qui posso solo provare che
l'app manda tutti e otto i campi, e quello lo provo. Se sulla build nuova il
ripiego resta, il campo `causa` del controller porta la frase testuale, ed e' la
prima cosa da guardare.

## Voce 2, il catalogo delle costellazioni: CHIUSA

Fatta prima che l'ordine cambiasse la coda, ed e' la voce 2 di questo ordine.

**La misura**: una prova enumera le dodici figure disegnabili e cade se una sola
non ha voce nel catalogo che risponde. Aggiunte Ariete, Cancro, Bilancia,
Capricorno, Acquario e Pesci con stelle vere dal catalogo Hipparcos, edizione
pubblica ESA 1997.

**Due cose trovate che l'ordine non nominava.** La ricerca della costellazione
confrontava il nome ITALIANO del catalogo con l'id INGLESE del segno, quindi non
trovava mai niente: il posizionamento dei corpi che avevo collegato nel giro
prima non arrivava alle costellazioni, solo alla Luna. E le soglie dell'orizzonte
erano QUATTRO numeri sparsi, meno due, zero, meno tre e meno cinque: adesso e'
un dato solo.

**Le immagini**: `cielo_ariete_prima.png` e `cielo_ariete_dopo.png`.

**La frase di accettazione**: **Apri "Il cielo sopra di te" e tocca Ariete: deve
dirti quanti gradi e' alto sul suolo, non che non lo conosce.**

## Voci 3, 4, 5: NON FATTE

La bolla che copre la Luna, le frasi che mentono, le miniature tagliate. Stanno
in `RIPRESA.md` nell'ordine in cui le vuoi.
