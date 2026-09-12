AGGIUNTA ALL'ORDINE P. SEZIONE ZERO, SI ESEGUE PER PRIMA.

Queste otto voci hanno PRIORITA' SU TUTTO, comprese P.01, P.02 e P.03. Si
eseguono prima della Sezione A e prima di ogni altra cosa dell'ordine.

VOCI_TOTALI nel manifesto passa da 32 a 40. Il manifesto va aggiornato come
prima azione, prima di toccare il codice, e test/ordine_p_guard_test.dart
legge 40.

Tutto cio' che segue e' stato verificato leggendo il ramo canonico sul remoto,
sha 3b3a8ff9, e i quattro commit dell'ordine O. Non e' dedotto dagli screenshot
e non e' una questione di gusto: sono cose che il codice fa o non fa.


-------------------------------------------------------------------------------
P.33  I TRE SENTIERI SI DISEGNANO DAVVERO
-------------------------------------------------------------------------------

IL FATTO, misurato. lib/features/sigilli/sentiero_screen.dart, 274 righe, monta
un ListView.builder di ListTile. Le icone sono quelle di serie del framework:
Icons.auto_awesome per l'acceso, Icons.circle_outlined e
Icons.radio_button_unchecked per lo spento, Icons.lock_outline_rounded per il
bloccato. Nel file NON esiste nessun CustomPainter. I tre sentieri si
distinguono per due cose sole: la palette del Maestro e lo stesso
CosmosBackground(seed: 19), identico per tutti e tre, cioe' lo stesso campo di
stelle soltanto tinto.

Quindi la sezione 13 del Briefing di Progetto NON e' stata costruita. I file
core/sigilli/sentiero_costellazione.dart, sentiero_albero.dart e
sentiero_loto.dart sono i dati dei 55 traguardi, non un disegno.

COSA VA COSTRUITO. Un disegno proprio per ciascun sentiero, come da briefing,
con i traguardi come punti del disegno e non come righe di un elenco.

  COSTELLAZIONE DI MEDORA. Ogni mini-traguardo e' una stella. Le stelle accese
  si uniscono fra loro con una linea luminosa. Ogni dieci stelle la figura si
  chiude in una Costellazione, che e' il grande traguardo. Le stelle non ancora
  accese esistono nel disegno, spente e in trasparenza, cosi' si vede la forma
  che manca.

  ALBERO DELLA VITA DI CALIGO. Ogni mini-traguardo e' un frutto o un fiore
  luminoso su un ramo. I cinque grandi sono le Sefirot Maggiori che si accendono
  salendo, fino a Keter come cinquantesimo. I rami e i sentieri fra le Sefirot
  si vedono anche quando i frutti sono spenti.

  FIORE DI LOTO DI AURA. Ogni mini-traguardo e' un petalo che si apre lungo lo
  stelo. I cinque grandi sono le Fioriture, cinque livelli di apertura fino al
  loto pienamente sbocciato. I petali chiusi si vedono.

L'ELENCO NON SPARISCE, diventa la seconda lettura. Il disegno sta in alto ed e'
la prima cosa che si vede; scorrendo si arriva all'elenco leggibile dei
traguardi. Toccando un punto del disegno si va al suo traguardo, e viceversa il
traguardo evidenzia il suo punto.

PROVA A GUARDIA, differenziale a pixel, una per sentiero. Si monta il sentiero,
si cattura, poi si monta lo stesso sentiero con il solo fondo cosmico e si
cattura di nuovo. La differenza in pixel dipinti deve superare una soglia
dichiarata. Prova del rosso: si spegne il painter, la differenza crolla, la
prova cade, si allega l'output.

SECONDA PROVA. Le tre catture dei tre sentieri, confrontate a due a due, devono
differire oltre una soglia dichiarata anche DOPO aver neutralizzato la palette.
E' la prova che i tre disegni sono tre disegni e non lo stesso ricolorato.

CRITERIO NUOVO SULLE ANTEPRIME, e vale da qui in avanti per tutte. L'ordine O ha
prodotto sentiero_costellazione_o_dopo.png, sentiero_albero_o_dopo.png e
sentiero_loto_o_dopo.png, sono state catturate e guardate, e la mancanza del
disegno non e' stata vista. Da adesso, guardando un'anteprima, si risponde per
iscritto a una domanda in piu': CHE COSA, IN QUESTA SCHERMATA, E' DISEGNATO DA
NOI E NON DAL FRAMEWORK. Se la risposta e' niente, l'anteprima non e' approvata.


-------------------------------------------------------------------------------
P.34  LA CELEBRAZIONE PARTE SEMPRE, E NON DIPENDE DAL SERVER
-------------------------------------------------------------------------------

IL FATTO. Sul telefono risultano accesi almeno due traguardi, "Sotto la Luna
nuova" e "Tre gettate", e nessuna celebrazione e' mai comparsa. Un Sigillo che
si accende in silenzio e' un premio che non esiste.

IPOTESI, DA VERIFICARE PRIMA DI CORREGGERE, E DA DICHIARARE ANCHE SE CADONO.
Sono due e si correggono in modo diverso.

  PRIMA, ed e' la piu' probabile. In
  lib/features/sigilli/regia_del_cammino.dart, dentro guardaCosaSiAccende, la
  riga

      final saldo = await PremioDelTraguardo.accredita(porta, traguardo);

  sta PRIMA della chiamata a Celebrazione.festeggia, senza try/catch attorno.
  Le funzioni non sono distribuite sul server: se quella chiamata solleva o
  resta appesa, il ciclo non arriva mai alla festa. Il commento accanto dice che
  il Sigillo resta acceso lo stesso, ed e' vero, ma la festa e' a valle di
  quell'attesa. Questo spiega esattamente cio' che si vede: Sigilli accesi, zero
  celebrazioni.

  SECONDA. guardaCosaSiAccende viene chiamata anche all'avvio. Se un traguardo
  matura in quel momento, non c'e' nessuna schermata montata capace di ospitare
  la sovrimpressione, e il controllo su context.mounted fa uscire in silenzio.

LA REGOLA, comunque vada la verifica. L'ORDINE E': si accende, SI CELEBRA, e
solo dopo si accredita. L'accredito va in fondo, protetto, e se fallisce riparte
alla prossima sincronia perche' porta gia' il suo identificativo. La
celebrazione non deve mai attendere la rete, e non deve mai poter essere saltata
da un errore di rete. Un premio in Eos che arriva in ritardo e' un fastidio; una
festa che non arriva e' il traguardo che non e' successo.

LA CODA. Se un traguardo si accende quando nessuna schermata puo' ospitare la
sovrimpressione, non si perde: entra in una coda e si celebra al primo momento
utile, cioe' appena l'app ha una schermata montata. La coda sopravvive alla
chiusura dell'app.

LE ANIMAZIONI. La celebrazione e' animata, non una scheda che compare. Il
simbolo del sentiero si accende con un movimento, il nome entra, gli Eos salgono
contando, e nei cinque grandi la figura del sentiero si compone. Due intensita':
piena e lunga per i grandi, breve ma sempre a tutto schermo per i mini. Con
Riduci Movimento diventa statica e NON sparisce.

PROVE. Una prova accende un traguardo con la porta del server che SOLLEVA, e
cade se la celebrazione non compare. Una seconda accende un traguardo con la
porta che non risponde mai entro il tempo, e cade se la celebrazione non
compare. Una terza accende un traguardo senza schermata montata e cade se la
festa non arriva al primo momento utile. Rosso eseguito per tutte e tre.


-------------------------------------------------------------------------------
P.35  LA STESA DEI TAROCCHI ENTRA NEL CAMMINO, E CON LEI TUTTE LE ARTI
-------------------------------------------------------------------------------

IL FATTO, verificato sui quattro commit dell'ordine O. Le sole schermate
collegate a RegiaDelCammino sono quattro: rune_draw_screen.dart,
breath_destiny_screen.dart, dawn_rite_screen.dart e cosmic_passport_screen.dart.
lib/features/tarot/stesa_tre_carte_screen.dart NON compare in nessuno dei
quattro commit. Quindi una stesa completata non registra niente e nessun
traguardo dei tarocchi puo' accendersi, ne' con tre stese ne' con trecento.

Si collega la stesa alla regia, nel punto in cui la stesa e' COMPIUTA e non
quando la scena si apre.

E POI SI CHIUDE LA FAMIGLIA, perche' se e' successo ai tarocchi e' successo
altrove. Una prova enumera le arti dichiarate nel registro unico, quello che
alimenta SogliaArte, legge il sorgente di ciascuna e CADE COL NOME DEL FILE se
un'arte compie un gesto e non chiama RegiaDelCammino.dopoUnGesto. Il rapporto
elenca tutte le arti trovate scollegate, non solo i tarocchi.

Prova del rosso: si stacca il collegamento delle rune, la prova deve accusare
rune_draw_screen.dart per nome.


-------------------------------------------------------------------------------
P.36  LA DISCESA AL PUNTO RAGGIUNTO: IL CONTO E' ROVESCIATO
-------------------------------------------------------------------------------

IL FATTO, con la riga. In sentiero_screen.dart, dentro _scendiAlPunto:

    final gradini = (50 - accesi).clamp(0, 50);
    final dove = (50 - gradini) * altezzaDelGradino;   // altezzaDelGradino = 92

Sostituendo, dove vale accesi * 92. La lista e' rovesciata, quindi in cima c'e'
il 50 e in fondo l'1. Con due traguardi accesi lo scorrimento si ferma a 184
punti, cioe' due righe: e' il motivo per cui non si muove niente. Con zero
accesi non si muove affatto. Il valore giusto e' (49 - accesi) * 92, che con due
accesi fa 4.324.

SECONDO DIFETTO SOTTO IL PRIMO. altezzaDelGradino e' fissata a 92 mentre le
righe hanno titoli su una o due righe: anche col conto corretto il punto di
arrivo scivola. L'altezza va MISURATA sulla resa, non assunta.

LA PROVA ESISTENTE E' CIECA e va sostituita, non allentata: verifica che
l'animazione parta, non dove arriva. La prova nuova misura l'offset finale dello
ScrollController e cade se non coincide col traguardo raggiunto entro mezza
riga. Rosso eseguito rimettendo la formula vecchia.

Con Riduci Movimento la discesa e' immediata ma il punto di arrivo e' lo stesso.


-------------------------------------------------------------------------------
P.37  I TRAGUARDI NON RAGGIUNTI SONO ILLEGGIBILI, E LE OPACITA' SI MOLTIPLICANO
-------------------------------------------------------------------------------

IL FATTO, coi numeri. Nel gradino, il colore del non raggiunto e'
ColorTokens.textSecondary.withValues(alpha: 0.35), e l'intero ListTile e'
avvolto in Opacity(opacity: 0.78). Le due si moltiplicano: l'alfa effettivo del
titolo di un traguardo non raggiunto e' 0,273. Sul fondo cosmico non si legge, e
lo si vede in tre screenshot su quattro.

Il commento accanto al codice dice che a 0,55 i nomi sparivano e che il grigio e'
stato reso leggibile. La misura dice il contrario, e vince la misura.

CORREZIONE. Una sola opacita' governa lo stato, mai due che si moltiplicano. Il
valore si sceglie in modo che il contrasto del titolo sul fondo reale soddisfi
la soglia della voce P.12, cioe' 4.5 a 1, non a occhio.

IL SENTIERO ENTRA NEL CENSIMENTO DEL CONTRASTO della voce P.14: le coppie
testo-fondo dei tre sentieri sono censite e contate in SOTTO_IL_CONTRASTO. Prova
del rosso: sul codice attuale la prova deve fallire prima della correzione.


-------------------------------------------------------------------------------
P.38  "I TUOI STELLA. I TUOI FRUTTO. I TUOI PETALO."
-------------------------------------------------------------------------------

IL FATTO. Nel Cosmic Passport, cioe' la porta d'ingresso della funzione, le tre
righe si leggono "I tuoi Stella: cinquanta piccoli con cinque grandi", "I tuoi
Frutto: ..." e "I tuoi Petalo: ...". Singolare dove serve il plurale, e una
frase che si legge come un segnaposto e non come italiano.

E' la stessa famiglia gia' chiusa a inizio agosto con "Ne hai uno oggi" contro
"Ne hai una oggi", risolta allora con una formula unica che non deve concordare.
Qui qualcuno ha ricomposto un'etichetta a mano incollando il nome singolare del
mini-traguardo dentro una frase al plurale.

CORREZIONE. Il nome del mini-traguardo porta con se' la sua forma plurale come
DATO, accanto al singolare, e la frase non si compone piu' incollando pezzi. Le
tre righe diventano frasi vere, scritte per intero, che dicono a cosa serve il
sentiero e non quanti pezzi ha.

PROVA. Una prova enumera le stringhe composte dell'app che incollano un nome
dentro una frase e cade se una di esse non dichiara la forma che sta usando.
Rosso eseguito rimettendo la composizione a mano.


-------------------------------------------------------------------------------
P.39  IL SOTTOTITOLO TAGLIATO A META' FRASE
-------------------------------------------------------------------------------

IL FATTO. Sul gradino acceso si legge "Tre gettate di rune: le pietre hanno
imparato il peso della" e finisce li'. Il sottotitolo e' a maxLines: 2 e la
frase del traguardo e' piu' lunga, quindi viene troncata senza puntini e a meta'
di un gruppo di parole.

CORREZIONE. O la frase sta intera nello spazio previsto, e allora le frasi dei
traguardi vengono scritte a quella misura; oppure lo spazio si adatta alla
frase. Non si tronca e basta, e non si aggiungono i puntini per nascondere il
problema: una frase tagliata a meta' e' una frase non scritta.

PROVA. Una prova monta ogni gradino di tutti e 165 i traguardi alla larghezza
reale e cade col nome del traguardo se il testo reso e' piu' corto del testo del
dato.


-------------------------------------------------------------------------------
P.40  LA CARD DEL CIELO DI NASCITA COPERTA DALLA BARRA
-------------------------------------------------------------------------------

IL FATTO. Nel Cosmic Passport la card "Il tuo cielo di nascita" passa sotto la
barra ESPLORA e sotto la navigazione in fondo, col testo che si legge
attraverso, e piu' sotto "Il tuo Sigillo" e' tagliato.

E' la famiglia delle sovrapposizioni gia' nota. Si applica la prova
dell'occlusione differenziale gia' esistente, estesa al Cosmic Passport, con
l'ipotesi del riflusso da verificare per prima: togliere l'elemento sospetto
cambia il layout, quindi il confronto legge tutto come coperto, e la correzione
probabile e' smettere di dipingerlo tenendogli il posto.


===============================================================================
CHIUSURA DELLA SEZIONE ZERO
===============================================================================

Il rapporto di queste otto voci porta, oltre alla misura di ciascuna:

  - le tre catture dei tre sentieri alla larghezza reale, dopo la correzione, e
    per ognuna la risposta scritta alla domanda "cosa e' disegnato da noi e non
    dal framework"
  - la registrazione a schermo di una celebrazione, mini e grande
  - l'elenco completo delle arti trovate scollegate dal cammino
  - l'offset finale misurato della discesa, per un sentiero vuoto e per uno a
    meta'
  - i valori di contrasto prima e dopo sui traguardi non raggiunti

Nessuna soglia si abbassa. Dove una guardia non scatta si cambia la grandezza
misurata, mai il numero.
