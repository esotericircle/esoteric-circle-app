# RETENTION, il documento del ritorno

Questo documento va tenuto presente in ogni ordine che tocca la superficie
dell'app. Nasce l'11 agosto 2026 da due critiche esterne e dalla discussione
che ne e' seguita. Non e' un elenco di desideri: e' la disciplina con cui si
decide cosa mostrare, cosa chiamare e cosa misurare. Come ogni documento di
`docs/`, non si condensa: si integra nelle sezioni giuste.

## Le due critiche, come sono arrivate

1. Un fondatore: "perche' dovrei tornare ad aprire l'app ogni giorno?"
2. Un investitore (visione tecnica, mai usata un'app esoterica), trascrizione
   fedele: "ci sono troppe informazioni nell'app. Bellissima, fantastica. Pero'
   non invoglia [...] sarebbe bene dividere l'app in quattro tematiche
   principali [...] come per dire fossero quattro app in una [...] troppe
   informazioni e' uguale a zero informazioni."

Vanno prese per quello che sono: diagnosi preziose con rimedi sbagliati. Chi
critica ha visto il sintomo vero (densita', mancanza di richiamo) e ha
proposto la cura piu' ovvia dalla sua esperienza (spacchettare). La regola di
casa: si accoglie la diagnosi, si discute il rimedio, non ci si innamora del
prodotto e nemmeno della critica.

## Cosa dicono davvero le due critiche

**La prima e' la domanda giusta al momento giusto.** L'app e' costruita a
giorni (oroscopo del giorno, tre gettate del giorno, Runa del Tramonto, Rito
dell'Alba, Rito del Sogno, domande del giorno) ma nessuno lo dice a chi tiene
il telefono in tasca. Un'app che si rinnova ogni giorno senza chiamare
nessuno e' un teatro che replica a sipario chiuso.

**La seconda sbaglia il rimedio e centra il sintomo.** L'app E' gia' divisa in
quattro: la home Il Cerchio piu' i tre domini dei Maestri (Medora per
astrologia e carte, Caligo per rune e rituali, Aura per energia e archetipi),
piu' il Passport. Se un investitore davanti all'app non percepisce le quattro
aree che esistono, il difetto non e' l'assenza della divisione: e' che la
superficie non la racconta. E il "troppo scritto" e' un fatto: il primo
sguardo riceve troppe cose insieme, molte delle quali in cammino (Coming
soon). La frase "troppe informazioni e' uguale a zero informazioni" e' una
legge di interfaccia corretta. La risposta NON e' amputare funzioni ne'
spacchettare in quattro app: e' gerarchia, una cosa davanti e le altre dietro,
col Coming soon che non fa folla davanti a chi entra.

## Le leggi della permanenza

1. **La promessa del giorno.** Ogni giorno l'app ha qualcosa che ieri non
   c'era e domani non ci sara' piu' uguale: e' la ragione del ritorno. Va
   detta, non sottintesa.
2. **La chiamata.** Una promessa senza richiamo non esiste. La notifica e' la
   voce del Maestro che chiama al momento giusto, non un volantino: una
   chiamata dice COSA c'e' ora (la runa della sera ti aspetta), mai "apri
   l'app".
3. **Il rito si chiude.** Cio' che si apre lascia un segno: la gettata di oggi
   ha il suo conto, la runa della sera passa nel Sogno, il consulto resta
   scritto. Un gesto che non lascia traccia non da' motivo di tornare.
4. **Il primo sguardo e' una cosa sola.** In ogni schermata c'e' UNA azione
   protagonista. Il resto esiste, ma dietro: la gerarchia e' la cura del
   "troppo scritto", non la forbice.
5. **Troppe informazioni uguale zero informazioni.** Vale per le schermate e
   per le notifiche: meglio una chiamata al giorno che tre, meglio un rito in
   vista che sei in fila.
6. **Non si amputa, si mette in ordine.** Nessuna funzione si elimina per
   placare la densita': si decide cosa sta davanti, cosa dietro un tocco e
   cosa tace finche' non e' il suo momento. Le quattro porte esistono gia':
   il lavoro e' farle percepire.
7. **Si misura, non si crede.** Ritorno del giorno dopo, ritorno della
   settimana, apertura da notifica: quando l'analytics entrera', queste tre
   misure decidono se le mosse funzionano. Fino ad allora, ogni mossa dichiara
   cosa si aspetta di muovere.

## L'inventario vero delle leve, verificato sul codice l'11 agosto 2026

Gia' vive nell'app:

- **Oroscopo del giorno** con gesto del consulto, quattro schede, profondita'.
- **Tre gettate di rune al giorno** per il Viandante, col conto a vista e il
  messaggio "si riparte domani" (ordini I e L): il limite giornaliero e' gia'
  esso stesso una ragione di ritorno.
- **Runa del Tramonto**, un getto per sera col giorno rituale suo, che passa
  la runa al Rito del Sogno (la cerniera della sera).
- **Rito dell'Alba** col ciclo del mattino.
- **Domande ai Maestri** a budget giornaliero, con l'Eco.
- **Confine del giorno unico** (`ConfineDelGiorno`): tutti i contatori
  ribaltano insieme, quindi "il nuovo giorno" e' un fatto solo in tutta l'app.
- **Avvisi locali GIA' IMPLEMENTATI** in `lib/services/avvisi_locali.dart`
  sopra `flutter_local_notifications`, con un canale (`rito_alba`), ora
  approssimata per obbligo di Android 14, permesso chiesto DAL RITO con la
  spiegazione davanti e mai all'avvio, porta astratta `ServizioAvvisi` con
  regole in `lib/core/rituals/avvisi_del_rito.dart`. Oggi chiamano UN solo
  momento: l'alba.

Non esiste ancora (dichiarato per non parlarne come se ci fosse):

- Una serie dei giorni (streak) o un filo visibile dei ritorni.
- Notifiche per la sera, per l'oroscopo o per il ritorno delle gettate.
- Una misura del ritorno (analytics).

## Le mosse, in ordine

**Mossa 1, LE NOTIFICHE DEL GIORNO (la prossima).** Si estende la porta che
gia' esiste, non se ne scrive una seconda: agli avvisi del rito si aggiungono
i momenti che l'app gia' possiede.

- La sera: "La tua Runa del Tramonto ti aspetta", all'ora del tramonto (gia'
  calcolata dalla scena), sul canale suo.
- Il mattino: "Il tuo cielo di oggi e' pronto", per l'oroscopo del giorno.
- Il ritorno delle gettate: chi ha chiuso la giornata a zero gettate riceve,
  al nuovo giorno, "Le tue tre gettate sono tornate".

Regole non negoziabili della mossa: mai piu' di due chiamate al giorno in
totale, una del mattino e una della sera; ogni canale si spegne da solo nelle
impostazioni di sistema perche' ha nome e descrizione chiari; il permesso si
chiede dentro un'esperienza con lo scambio di valore davanti, mai a freddo;
ogni avviso apre la scena che promette, non la home; l'ora resta approssimata
(vincolo di Android 14 gia' documentato); i tre esiti del permesso restano
distinti fino a schermo come per la posizione.

**Mossa 2, L'ARCO DEL GIORNO IN HOME.** La home racconta il momento: al
mattino porta davanti l'Alba e l'oroscopo, alla sera il Tramonto e il Sogno.
Una cosa protagonista per momento, il resto un passo dietro. E' la risposta
vera al "troppo scritto": stessa ricchezza, gerarchia nuova.

**Mossa 3, IL FILO DEI GIORNI.** Un segno discreto di continuita' (i giorni
di seguito in cui il rito si e' chiuso), nel Passport e non in faccia: la
serie invita, non ricatta. Insieme, il diario dei consulti letti.

**Mossa 4, LA MISURA.** Quando l'analytics entra: ritorno D1 e D7, aperture da
notifica per canale, chiusura del rito. Ogni mossa precedente si rilegge coi
numeri e si tiene o si corregge.

## La risposta alle quattro app, per iscritto

Non si spacchetta. Quattro app separate moltiplicano onboarding, store,
aggiornamenti e pubblicita' per quattro. Uccidono la cosa che nessun
concorrente ha: i tre Maestri che si conoscono, si passano i riti (la runa
della sera entra nel sogno della notte) e ricordano la stessa persona. La
divisione percepita si ottiene con le porte che gia' esistono, rese
inconfondibili: colore, Maestro, una frase d'ingresso, una azione protagonista
per dominio. Se dopo l'arco del giorno e la gerarchia nuova un esterno ancora
non percepisce le quattro aree, si riapre la discussione coi numeri in mano.
