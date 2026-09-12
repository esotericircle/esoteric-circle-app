# ESITO: LA PORTA ROTTA, E IL CIELO DI NASCITA

## Voce 1, la schermata bianca: CHIUSA

### La causa, misurata

**Le rotte si montano alla RADICE del Navigator, quindi non ereditano gli scope
montati sotto.** `DatiDiNascitaScreen.route()` era un `MaterialPageRoute` nudo, e
la schermata legge la palette del Maestro da un `MaestroScope`: aperta da un
punto gia' dentro uno scope funzionava, aperta da altrove la costruzione si
interrompeva e restava un riquadro bianco.

Non erano due rotte duplicate ne un Provider mancante: era **una rotta che non si
portava dietro cio' di cui la schermata ha bisogno**.

### La regola, nel dato

La rotta e' una sola e include il proprio scope. Una prova conta le costruzioni
della schermata in tutto `lib` e cade se ne compare una seconda: chi la montasse
a mano ricreerebbe una copia senza scope, cioe' bianca.

E una prova la monta NUDA, col minimo indispensabile e senza scope attorno, che
e' la condizione peggiore in cui qualcuno possa aprirla: se regge cosi', regge da
ogni porta. **Prova di vista passata**: tolto lo scope dalla rotta, cade.

### Le immagini

- `docs/preview/prima_dopo/dati_nascita_prima.png`
- `docs/preview/prima_dopo/dati_nascita_dopo.png`

### La frase di accettazione

**Apri "I tuoi dati di nascita" da qualunque punto la offra: devi vedere giorno,
ora e il campo del luogo, mai una schermata bianca.**

## Voce 2, il cielo di nascita: PARZIALE

### 2a. Avevo verificato una porta sola, ed e' vero

Il cielo di nascita e' la stessa classe con `birth` vero, e non l'avevo mai
guardato. Da adesso le coppie prima e dopo si generano per **entrambi** i cieli,
e in questo giro sono quattro file.

### 2b. Il piede non era sottratto: CORRETTO

Nel cielo di nascita sotto la scheda c'e' anche "Leggi la tua carta". Lo spazio
libero sottraeva la sola scheda, quindi i corpi finivano sotto il pulsante.
Adesso si sottrae TUTTO cio' che copre il cielo, e il piede si somma nel conto:
se domani se ne aggiunge un altro, il calcolo lo prende per costruzione.

### 2c. L'ipotesi dell'asse rovesciato era SBAGLIATA, e la causa vera e' un'altra

Ho verificato la mappatura prima di toccarla: a zero gradi la posizione vale
0,86 dell'altezza, cioe' in fondo, e allo zenit 0,12, cioe' in cima. **L'asse non
era rovesciato.**

**La causa della contraddizione era il RIPIEGO.** Quando l'azimut cadeva fuori
dal campo orizzontale il calcolo restituiva NULLA, e il corpo ripiegava sullo
slot grafico fisso, che per la Luna sta in cima. Il numero veniva dal dato, il
disegno da una costante, e i due si contraddicevano: la scheda diceva quattro
gradi e la Luna stava sotto il titolo.

Adesso chi esce di lato viene riportato al bordo e la sua ALTEZZA RESTA QUELLA
VERA. Si perde un po' di precisione sull'azimut, che non e' dichiarato da
nessuna parte, e non si perde il dato che la scheda annuncia.

**La prova sulla mappatura c'e' e gira su entrambi i cieli, e NON l'ho vista
cadere sul codice vecchio**: alle 22:30 la Luna resta dentro il campo
orizzontale, quindi il ripiego non scatta e la prova non discrimina. La
correzione e' giusta e motivata, la prova la protegge d'ora in avanti, e non
posso dire che l'abbia dimostrata.

### UN DIFETTO NUOVO CHE L'IMMAGINE RIVELA, e lo dichiaro

Guardando `cielo_nascita_dopo.png`: i corpi non finiscono piu' sotto niente, ma
**le etichette si accavallano fra loro**. Si leggono "CANCRO", "GEMELLI" e
"TORO" stampate una sopra l'altra, illeggibili, e la Luna si sovrappone al Toro.

Comprimendo il campo i corpi si sono avvicinati, e nessuno impedisce a due
corpi di occupare lo stesso punto. **Non l'ho corretto**: non era in questo
ordine e non ho margine per farlo bene. Sta in `RIPRESA.md` come prima voce del
cielo.

### Le immagini, quattro

- `cielo_adesso_prima.png` e `cielo_adesso_dopo.png`
- `cielo_nascita_prima.png` e `cielo_nascita_dopo.png`

### La frase di accettazione

**Apri il cielo di nascita dal Passport e tocca un corpo: nessun nome deve
leggersi sotto il vetro della scheda ne sotto il pulsante in fondo.**
