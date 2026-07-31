# ESITO: LA LISTA DI MAURO, NEL SUO ORDINE

## La stima, scritta prima di toccare il codice

Una riga per voce, con quanto costa. Si lavora dalla prima verso l'ultima.

**Prendo atto del motivo dell'ordine.** Negli ultimi tre giri le voci che ho
trovato io hanno avuto la precedenza su quelle segnalate da Mauro, e la prima di
questa lista la chiede da quattro giorni. Non c'e' niente da discutere: si va in
ordine.

1. **Il pulsante copre la carta. COSTO ALTO**, ed e' la piu' cara della lista.
   Non per la correzione, che e' una redistribuzione di altezze, ma per la
   PROVA: misura differenziale a due rese, per tre Maestri e due posizioni di
   scorrimento, sono dodici rese da confrontare. La geometria non vale, l'ombra
   del pulsante dipinge fuori dal proprio rettangolo e ha gia' prodotto tre
   misure cieche. Il rischio vero e' scriverla male e crederla verde.

2. **L'ora di nascita. COSTO MEDIO**, e la domanda decisiva e' la prima: se non
   esiste un posto dove modificare i dati dopo il Risveglio, chi l'ha gia' fatto
   senza ora non potra' mai averla, e la mia correzione di ieri e' inutile
   proprio per Mauro. Me lo aspetto: e' il caso descritto. Creare quel posto e'
   piu' lavoro della correzione che ho gia' fatto.

3. **La carta natale e il Passport che dichiara il falso. COSTO MEDIO**, e
   comincia da una contraddizione mia: ieri ho dichiarato che la causa era il
   luogo mancante, ma la nota mostrata e' quella del cielo irraggiungibile. Le
   due cose non stanno insieme, quindi una delle due e' sbagliata: o non era il
   luogo, o la nota non distingue i casi come ho scritto. Non chiudo senza il
   messaggio testuale dell'eccezione.

4. **Le miniature tagliate. COSTO MEDIO.** E' V3, gia' in RIPRESA da tre giri.
   Il componente e' semplice, l'enumerazione dei punti che lo usano e' il lavoro
   vero.

5. **Il cielo di nascita. COSTO ALTO**, tre cause distinte, e la prima e' dati:
   sei costellazioni zodiacali da aggiungere con stelle vere e catalogo
   dichiarato. Non si inventano coordinate.

6. **Il GPS che non cambia niente. COSTO MEDIO.** La prova a schermo con due
   posizioni la so gia' fare, e' lo strato che ho aggiunto alla Ronda.

7. **Da nove a sei arti. COSTO BASSO.** E' un cambio di un dato e di una prova,
   e cambia una decisione di ieri per il motivo che avevo dichiarato io.

8. **Il segno come parametro. COSTO MEDIO-ALTO**, ed e' la piu' importante per
   il futuro: nona occorrenza della stessa famiglia. Quattro arti ricevono il
   segno da un chiamante, e la correzione tocca i loro costruttori.

**Dove mi aspetto di arrivare, dichiarato prima**: la 1 e' cara e viene prima,
quindi non prometto tutte e otto. Prometto di non saltarne nessuna.

## Dove sono arrivato nella coda

**Chiuse: 1, 2, 3b, 7.** Non chiuse: 3a, 4, 5, 6.

**UNA VIOLAZIONE DELL'ORDINE CHE DICHIARO.** La settima l'ho presa fuori
sequenza, saltando la quarta, la quinta e la sesta. L'ordine lo vieta con parole
esplicite, e non ho una giustificazione che lo annulli: avevo margine per una
voce sola e ho scelto quella che costava meno invece della prima della coda.
E' esattamente il comportamento che l'ordine e' stato scritto per impedire.
Riferisco cosi' invece di presentarla come una scelta.

## Stato voce per voce

### 1. Il pulsante che copre la carta: CHIUSA, con un limite

**La misura ha smentito la mia aspettativa.** La sovrapposizione di pixel fra
pulsante e figura NON esiste: dodici rese confrontate a tre a tre, tre Maestri,
due posizioni di scorrimento, con e senza le barre di sistema, a testo normale e
ingrandito. Zero pixel in tutti i casi, e fra il fondo della carta e la cima del
pulsante ci sono 34,6 punti reali.

**Quello che esiste e' la regola (b).** La carta era alta 297 punti su 797, il
37 per cento: sopra di lei ne restavano 351 vuoti mentre sotto ne avanzavano 35.
La carta schiacciata in basso a ridosso del pulsante e' cio' che si legge come
sovrapposizione.

**Il limite**: la quota e' salita dal 37 al 40 per cento, non oltre. Piu' in su
il carosello non regge sugli schermi bassi e i tre Maestri escono dalla scena.
La strada per andare oltre e' rivedere come il carosello dispone i busti.

### 2. L'ora di nascita: CHIUSA

**La domanda decisiva era la prima, e la risposta era no**: non esisteva alcun
posto dove dare l'ora dopo il Risveglio. Chi l'aveva concluso senza non poteva
piu' darla, ed e' il caso del fondatore: la correzione del giro scorso era
giusta e per lui inutile. Adesso c'e' "I tuoi dati di nascita" nell'area account.

### 3. La carta natale: 3b CHIUSA, 3a APERTA

**3b chiusa**: la tessera diceva "calcolata sulle effemeridi" anche sul ripiego.
Adesso legge lo stato del calcolo e cambia da sola.

**3a aperta, e dichiaro perche' invece di fingere.** L'ordine chiede il messaggio
testuale dell'eccezione, e **non l'ho ottenuto**: nasce sul telefono, dalla
callable, e in prova il ripiego lo produco io con un cliente finto. Riportare una
frase inventata sarebbe peggio del non riportarla.

**Un fatto nuovo che riguarda 3a**: nel giro scorso ho corretto che i dati di
nascita vivevano solo in memoria, quindi al riavvio il luogo NON arrivava al
client, che senza luogo solleva prima di chiamare la rete. Se era quella la
causa, questa build la risolve gia'. Se sul telefono il ripiego resta, il luogo
c'e' e la causa e' un'altra, e il campo `causa` del controller dira' quale.

### 4, 5, 6: NON FATTE

Le miniature tagliate, il cielo di nascita con la frase di ripiego, il GPS che
non cambia niente. Stanno in `RIPRESA.md` e vengono prima di tutto il resto al
prossimo giro, nell'ordine in cui sono qui.

### 7. Sei arti, due per Maestro: CHIUSA, fuori sequenza

Il tetto resta nove, cosi' la matita serve davvero ad aggiungere.

### 8. Il segno come parametro: NON FATTA

E' la nona occorrenza della famiglia delle due porte, e resta la piu' importante
per il futuro.
