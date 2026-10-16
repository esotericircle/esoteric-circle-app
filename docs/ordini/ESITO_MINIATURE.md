# ESITO: LE MINIATURE INTERE

## Voce 1, le miniature tagliate: CHIUSA

### La causa, che non era quella che sembrava

**Il componente giusto esisteva gia'.** Dentro `birth_companions.dart` c'era una
classe PRIVATA con `BoxFit.contain` e la proporzione da carta, scritta bene e
commentata bene. Gli altri punti che mostrano le stesse immagini non la
vedevano, perche' era privata di quel file, e usavano `cover`.

**Un componente che risolve il difetto in un file solo non e' un componente, e'
una correzione locale.** E' la tredicesima volta che questo progetto incontra
questa forma.

### Cosa ho fatto

`MiniaturaIntera` nel design system, con due costruttori: quello quadrato e
`MiniaturaIntera.carta`, rettangolare verticale con la proporzione da carta,
perche' le illustrazioni degli Angeli SONO carte e in un quadrato si mutilano
per costruzione.

Portato nel Passport per l'angelo e per l'animale, dove il lupo era in un cerchio
con `cover`: adesso la figura ci sta dentro intera, rimpicciolita, con il margine
che serve perche' un quadrato inscritto in un cerchio e' piu' piccolo del
cerchio.

### La prova ha trovato due punti che nessuno aveva segnalato

- `sinastria_gallery_screen.dart`: i ritratti VIP erano adattati al riempimento,
  quindi i volti tagliati dal riquadro. **Corretto.**
- `sunset_rune_screen.dart`: e' lo SFONDO del tramonto, non la miniatura di un
  soggetto. Dichiarato come eccezione: contenerlo lascerebbe due bande vuote.

**Prova di vista passata**: rimesso `cover` nel Passport, la prova cade.

### UN LIMITE DELLE IMMAGINI, che dichiaro

`miniature_prima.png` e `miniature_dopo.png` esistono e sono committate, ma **non
mostrano la differenza**: in prova headless gli asset delle miniature non si
caricano, quindi in entrambe si vede il ripiego, un cerchio vuoto e un riquadro
vuoto. E' un limite del mezzo e non del lavoro, e le immagini non provano
niente in questo caso.

Quello che prova la correzione e' la misura: la prova enumera i punti, li conta,
e cade se uno adatta al riempimento. E la prova di vista.

### La frase di accettazione

**Apri il Passport e guarda le tessere Animale guida e I tuoi angeli: il lupo
deve stare tutto dentro il suo cerchio, zampe e coda comprese, e l'angelo deve
essere una carta verticale intera, non mozzata sui lati.**

## Voci 2 e 3: NON FATTE

Il segno che viaggia come parametro e le costellazioni piu' grandi. Restano in
`RIPRESA.md` nell'ordine in cui le vuoi, e la 2 viene prima.
