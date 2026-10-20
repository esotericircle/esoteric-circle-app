# Il salmo propiziatorio, Oracolo degli Angeli, Esoteric Circle

Ordine GA, voce GA.04, 20 ottobre 2026. Il riquadro "Il salmo propiziatorio"
dell'Oracolo degli Angeli: il versetto del Salmo che Lazare Lenain lega
all'angelo uscito, da leggere a voce, dentro un rito semplice da compiere
adesso, che accompagna e non promette niente.

**Nessuna formula inventata.** La formula è il versetto, alla lettera, nella
traduzione italiana di Antonio Martini. Il momento, il gesto, il numero delle
letture e il pensiero rivolto al dono dell'angelo (come lo descrivono i campi
`tradition` e `reading` di `lib/core/angels/angel_lore.dart`) accompagnano la
formula e non sono una formula.

## Le fonti

- **L'assegnazione dei salmi.** Lazare Lenain, *La science cabalistique*,
  Amiens 1823, letta nel repository, non di nuovo: `docs/corpus/angeli.md`
  (riga **Salmo** di ogni voce), `lib/core/angels/angel_lore.dart` (campo
  `psalm`, generato dal corpus) e `docs/angeli_verifica_lenain.md` (la verifica
  sulla stampa del 1823 fatta con l'ordine CS). Lenain cita i salmi con la
  numerazione della Vulgata.
- **Il latino.** Vulgata Clementina, nel testo pubblicato da drbo.org, una
  pagina per salmo: `https://www.drbo.org/lvb/chapter/21NNN.htm`, dove NNN è il
  numero del salmo nella Vulgata (per esempio `21003.htm` è il Salmo 3), e
  `https://www.drbo.org/lvb/chapter/01001.htm` per Genesi 1. Gli spazi che quel
  sito mette davanti a due punti e punto e virgola sono stati tolti; parole e
  punteggiatura sono le sue.
- **L'italiano, la fonte usata.** *La Sacra Bibbia secondo la Volgata
  tradotta in lingua italiana da monsignore Antonio Martini, con l'aggiunta
  delle migliori parafrasi dei poeti biblici e delle antichità e guerre
  giudaiche di Giuseppe Flavio*, Firenze, David Passigli, 1842. Pubblico
  dominio. Due copie digitalizzate da Google Books e conservate su Internet
  Archive:
  - Volume primo: https://archive.org/details/bub_gb_QDmEfk0Ml1YC (Google
    Books `QDmEfk0Ml1YC`), che contiene anche Genesi e i Salmi;
  - Vecchio Testamento, parte seconda: https://archive.org/details/bub_gb_VOmwZ1AwFsMC
    (Google Books `VOmwZ1AwFsMC`).
  **Ogni versetto è stato letto sull'immagine della pagina stampata, non sul
  testo riconosciuto a macchina**, che in queste scansioni sbaglia accenti e
  lettere. L'immagine di ogni versetto è indicata nella tavola qui sotto
  (`identificativo/page/nNUMERO`, l'indice dell'immagine nella scansione).
- **Una trascrizione di confronto, non usata come fonte.** Le pagine
  `https://preghiere.milazzo.life/salmo-NNN-martini/` riportano i Salmi di
  Martini in testo digitale, senza dichiarare l'edizione (citano "Parola Viva"
  e Wikisource). Sono servite solo come prima bozza: in quarantuno dei settantuno
  versetti dei Salmi differiscono dalla stampa del 1842, e ha sempre prevalso la stampa (elenco
  più sotto).
- **Una fonte cercata e non usabile.** Wikisource in italiano ha la pagina
  "Salmi (Martini)", https://it.wikisource.org/wiki/Salmi_(Martini), sul tomo
  14 dell'edizione 1785, ma ne sono trascritti solo la Prefazione, il Salmo I e
  il Salmo II: nessuno dei versetti che servono qui.

## La numerazione: tre numeri per lo stesso versetto

Lenain conta i versetti come la Vulgata Clementina, dove il titolo del salmo
("Salmo di David", "Per la fine") è il versetto 1. L'edizione Passigli di
Martini **non numera i titoli**: nei salmi che ne hanno uno, il versetto porta
un numero più basso di uno o di due; in qualche salmo (8, 39, 87, 99, 139) il
primo versetto numerato di Martini è il secondo della Clementina. Nel salmo 9
la Clementina continua la numerazione oltre il versetto 21 (il 9,22 di Lenain),
mentre drbo.org stampa quella seconda parte come "Salmo 10" numerato da 1 e
Martini la numera 9,21. La riga **Salmo** di ogni voce dà sempre il numero di
Lenain; la tavola dà anche quello di Martini e l'immagine della pagina.

| angelo | salmo Vulgata | versetto in Martini | immagine della scansione |
|---|---|---|---|
| 1 | 3,4 | 3,3 | bub_gb_QDmEfk0Ml1YC/page/n1455 |
| 2 | 21,20 | 21,19 | bub_gb_QDmEfk0Ml1YC/page/n1488 |
| 3 | 90,2 | 90,2 | bub_gb_QDmEfk0Ml1YC/page/n1609 |
| 4 | 6,5 | 6,4 | bub_gb_QDmEfk0Ml1YC/page/n1459 |
| 5 | 33,5 | 33,4 | bub_gb_QDmEfk0Ml1YC/page/n1508 |
| 6 | 9,12 | 9,11 | bub_gb_QDmEfk0Ml1YC/page/n1465 |
| 7 | 102,8 | 102,8 | bub_gb_QDmEfk0Ml1YC/page/n1625 |
| 8 | 94,6 | 94,6 | bub_gb_QDmEfk0Ml1YC/page/n1615 |
| 9 | 24,6 | 24,6 | bub_gb_QDmEfk0Ml1YC/page/n1492 |
| 10 | 32,22 | 32,22 | bub_gb_QDmEfk0Ml1YC/page/n1507 |
| 11 | 17,47 | 17,46 | bub_gb_QDmEfk0Ml1YC/page/n1481 |
| 12 | 9,22 | 9,21 | bub_gb_QDmEfk0Ml1YC/page/n1466 |
| 13 | 97,4 | 97,5 | bub_gb_QDmEfk0Ml1YC/page/n1619 |
| 14 | 9,10 | 9,9 | bub_gb_VOmwZ1AwFsMC/page/n598 |
| 15 | 93,22 | 93,22 | bub_gb_QDmEfk0Ml1YC/page/n1614 |
| 16 | 87,2 | 87,1 | bub_gb_QDmEfk0Ml1YC/page/n1601 |
| 17 | 8,2 | 8,1 | bub_gb_QDmEfk0Ml1YC/page/n1462 |
| 18 | 7,9 | 7,8 | bub_gb_QDmEfk0Ml1YC/page/n1461 |
| 19 | 39,2 | 39,1 | bub_gb_QDmEfk0Ml1YC/page/n1520 |
| 20 | 119,2 | 119,2 | bub_gb_QDmEfk0Ml1YC/page/n1668 |
| 21 | 30,15 | 30,14 | bub_gb_QDmEfk0Ml1YC/page/n1502 |
| 22 | 120,5 | 120,5 | bub_gb_QDmEfk0Ml1YC/page/n1669 |
| 23 | 120,8 | 120,8 | bub_gb_QDmEfk0Ml1YC/page/n1669 |
| 24 | 32,18 | 32,18 | bub_gb_VOmwZ1AwFsMC/page/n640 |
| 25 | 9,2 | 9,1 | bub_gb_QDmEfk0Ml1YC/page/n1464 |
| 26 | 118,145 | 118,145 | bub_gb_QDmEfk0Ml1YC/page/n1666 |
| 27 | 139,2 | 139,1 | bub_gb_VOmwZ1AwFsMC/page/n820 |
| 28 | 70,12 | 70,12 | bub_gb_QDmEfk0Ml1YC/page/n1571 |
| 29 | 53,6 | 53,4 | bub_gb_QDmEfk0Ml1YC/page/n1543 |
| 30 | 70,5 | 70,5 | bub_gb_QDmEfk0Ml1YC/page/n1571 |
| 31 | 70,16 | 70,16 | bub_gb_QDmEfk0Ml1YC/page/n1571 |
| 32 | 32,4 | 32,4 | bub_gb_QDmEfk0Ml1YC/page/n1505 |
| 33 | 93,11 | 93,11 | bub_gb_QDmEfk0Ml1YC/page/n1614 |
| 34 | 130,3 | 130,5 | bub_gb_QDmEfk0Ml1YC/page/n1677 |
| 35 | 114,1 | 114,1 | bub_gb_QDmEfk0Ml1YC/page/n1649 |
| 36 | 25,8 | 25,8 | bub_gb_QDmEfk0Ml1YC/page/n1494 |
| 37 | 79,8 | 79,8 | bub_gb_QDmEfk0Ml1YC/page/n1591 |
| 38 | 90,9 | 90,9 | bub_gb_QDmEfk0Ml1YC/page/n1610 |
| 39 | 29,11 | 29,10 | bub_gb_QDmEfk0Ml1YC/page/n1500 |
| 40 | 87,15 | 87,15 | bub_gb_QDmEfk0Ml1YC/page/n1602 |
| 41 | 119,2 | 119,2 | bub_gb_QDmEfk0Ml1YC/page/n1668 |
| 42 | 120,7 | 120,7 | bub_gb_QDmEfk0Ml1YC/page/n1669 |
| 43 | 87,14 | 87,14 | bub_gb_QDmEfk0Ml1YC/page/n1602 |
| 44 | 118,108 | 118,108 | bub_gb_QDmEfk0Ml1YC/page/n1663 |
| 45 | 93,18 | 93,18 | bub_gb_VOmwZ1AwFsMC/page/n747 |
| 46 | 144,9 | 144,9 | bub_gb_QDmEfk0Ml1YC/page/n1693 |
| 47 | 103,24 | 103,24 | bub_gb_QDmEfk0Ml1YC/page/n1629 |
| 48 | 97,2 | 97,3 | bub_gb_QDmEfk0Ml1YC/page/n1619 |
| 49 | 144,3 | 144,3 | bub_gb_VOmwZ1AwFsMC/page/n825 |
| 50 | 102,8 | 102,8 | bub_gb_QDmEfk0Ml1YC/page/n1625 |
| 51 | 103,31 | 103,31 | bub_gb_VOmwZ1AwFsMC/page/n762 |
| 52 | 7,18 | 7,17 | bub_gb_QDmEfk0Ml1YC/page/n1462 |
| 53 | 118,75 | 118,75 | bub_gb_QDmEfk0Ml1YC/page/n1661 |
| 54 | 102,19 | 102,19 | bub_gb_QDmEfk0Ml1YC/page/n1626 |
| 55 | 101,13 | 101,13 | bub_gb_QDmEfk0Ml1YC/page/n1623 |
| 56 | 144,14 | 144,14 | bub_gb_QDmEfk0Ml1YC/page/n1693 |
| 57 | 113,19 | 113,19 | bub_gb_QDmEfk0Ml1YC/page/n1648 |
| 58 | 6,4 | 6,3 | bub_gb_QDmEfk0Ml1YC/page/n1459 |
| 59 | 112,3 | 112,3 | bub_gb_QDmEfk0Ml1YC/page/n1646 |
| 60 | 144,17 | 144,17 | bub_gb_QDmEfk0Ml1YC/page/n1693 |
| 61 | 112,2 | 112,2 | bub_gb_QDmEfk0Ml1YC/page/n1646 |
| 62 | 118,159 | 118,159 | bub_gb_QDmEfk0Ml1YC/page/n1666 |
| 63 | 99,2 | 99,1 | bub_gb_QDmEfk0Ml1YC/page/n1620 |
| 64 | 32,18 | 32,18 | bub_gb_VOmwZ1AwFsMC/page/n640 |
| 65 | 89,13 | 89,13 | bub_gb_QDmEfk0Ml1YC/page/n1608 |
| 66 | 37,22 | 37,21 | bub_gb_VOmwZ1AwFsMC/page/n651 |
| 67 | 36,4 | 36,4 | bub_gb_QDmEfk0Ml1YC/page/n1514 |
| 68 | 105,1 | 105,1 | bub_gb_QDmEfk0Ml1YC/page/n1633 |
| 69 | 15,5 | 15,5 | bub_gb_QDmEfk0Ml1YC/page/n1474 |
| 70 | Genesi 1,1 | Genesi 1,1 | bub_gb_QDmEfk0Ml1YC/page/n39 |
| 71 | 108,30 | 108,29 | bub_gb_QDmEfk0Ml1YC/page/n1642 |
| 72 | 114,7 | 114,7 | bub_gb_QDmEfk0Ml1YC/page/n1649 |

## Le discordanze trovate, e come sono state risolte

**Fra i tre file del repository.**

1. La riga **Salmo** del corpus e il campo `psalm` di `angel_lore.dart`
   coincidono carattere per carattere in tutte e settantadue le voci: il file
   Dart è generato dal corpus.
2. **Versetti condivisi.** `docs/angeli_verifica_lenain.md` dice che un solo
   versetto è assegnato a due angeli, il Salmo 102,8 di Achaiah (7) e Daniel
   (50), e che sta così nella stampa del 1823. Il corpus ne ha altri due:
   **119,2** per Pahaliah (20) e Hahahel (41), **32,18** per Haheuiah (24) e
   Mehiel (64). La verifica dell'ordine CS legge a mano in Lenain solo quello
   di Haheuiah e non nomina gli altri. Non avendo la stampa del 1823 sotto gli
   occhi, sono stati lasciati come il corpus li dà, con riti diversi per ogni
   angelo; vanno riscontrati sulla scansione di Lenain. Provenienza: il corpus
   del 29 luglio 2026; la verifica dell'ordine CS (6 settembre 2026) non li
   segnala.
3. **La numerazione dichiarata.** La verifica dice che le voci 20, 22 e 24 non
   dichiarano la numerazione: oggi la dichiarano tutte e tre. Restano invece
   senza il numero della Vulgata le voci 17, 18, 19 e 21 (solo numerazione
   CEI), la 23 (CEI, con "nella Vulgata il salmo è il 120") e la 62 ("nella
   Vulgata il salmo porta il numero 118"). Il numero della Vulgata è stato
   ricavato e controllato sul latino: 8,2; 7,9; 39,2; 30,15; 120,8; 118,159.
4. **Anauel (63)** ha nel corpus due linee: Lenain, Salmo 99,2 ("Servite
   Domino in laetitia"), e Kabaleb, Salmo 2,11. Si è seguita la linea che il
   corpus stesso attribuisce a Lenain, 99,2.
5. **Iabamiah (70)** non ha un salmo: la tradizione gli dà Genesi 1,1, e così
   resta. Martini, nella stessa edizione Passigli, scrive "Al principio".
6. **Seheiah (28)** e **Reiiel (29)**: il corpus lascia aperte due cifre
   (70,12 oppure 70,13; 53,6 oppure 53,4). Per Seheiah la Clementina e
   Martini dicono tutte e due 70,12: il 70,13 non trova riscontro in nessuna
   delle due. Per Reiiel la Clementina dice 53,6 e Martini 53,4, perché
   Martini non conta i due versetti del titolo.
7. **Numerazione ebraica detta male**, senza effetto sulla Vulgata: per
   Mebahel (14) il corpus chiama masoretico il 9,9, che è il numero delle
   Bibbie inglesi (il masoretico è 9,10); lo stesso vale per Veualiah (43,
   "88,13", masoretico 88,14), Ieialel (58, "6,3", masoretico 6,4) e Manakel
   (66, "38,21", masoretico 38,22). Da correggere nel corpus quando lo si
   tocca, non in questo file.

**Il latino del repository confrontato con la Vulgata Clementina.** In
cinquantuno voci il campo porta il latino, e in tutte il versetto è quello
giusto. Le differenze di testo:

- **Hahahel (41)**: "a labiis mendacii, a lingua dolosa" è la Nova Vulgata;
  la Clementina, e Lenain con lei, legge "a labiis iniquis et a lingua dolosa",
  come nella voce di Pahaliah (20).
- **Mikael (42)**: "custodiet ... custodiet" è la Nova Vulgata; la Clementina
  legge "custodit ... custodiat".
- **Ielahiah (44)**: "beneplacita sint" è la Nova Vulgata; la Clementina legge
  "beneplacita fac".
- **Haheuiah (24)**: "in misericordia eius"; la Clementina legge "super
  misericordia ejus". **Mehiel (64)** omette "et" prima di "in eis".
- **Asaliah (47)**: il latino si ferma a "fecisti"; il versetto prosegue con
  "impleta est terra possessione tua".
- **Chavakhiah (35)** e **Habuhiah (68)**: manca "Alleluja", che nella
  Clementina apre il versetto. In Martini "Alleluia: lodate Dio" è un titolo
  fuori dal versetto, e qui non è riportato.
- **Anauel (63)**: il campo cita solo "Servite Domino in laetitia", una parte
  del versetto.
- **Vehuel (49)**, **Daniel (50)** e **Hahasiah (51)** riportano accanto alla
  Nova Vulgata anche la lezione Clementina, che coincide.
- In ventuno voci (9-19, 21, 23, 25-32) il campo porta solo una traduzione
  italiana moderna, senza latino: il numero è stato controllato e il latino
  preso dalla Clementina; il senso della frase italiana corrisponde.
- La grafia del repository (eius, iustitia, adiutor) è quella moderna; la
  Clementina scrive ejus, justitia, adjutor. Non è una differenza di testo.

**La stampa del 1842 contro la trascrizione digitale.** Dove le due
differiscono vale la stampa, letta sull'immagine. Le differenze che contano:
"lacrime" e non "lagrime" (8); "nei secoli" (9) e "pei secoli" (34, 51); "sei
tu" (3); "quanto ammirabile" e "dei cieli" (17); "coloro che lo temono, e sopra
coloro" al posto di "color, che io temono" (24, 64); "le tue meraviglie" (25);
"aspettazione" (30); "m'internerò" (31); "(E dirai)" fra parentesi (38); "Sien
graditi ... volontari sacrifizi ... giudizi" (44); "le opere tue" (47); "tutti
que', che stan per cadere" (56); "quelli, che temono", **senza "lo"** (57);
"fino a quando?..." (58); "(sarai sdegnato)" e "coi" (65); "giubbilo" (13,
63); l'accento grave di "perchè", "Perocchè", "Imperocchè" (12, 17, 30, 31,
32, 35, 40, 68, 72); il resto sono virgole, due punti e punti e virgola. I
titoli dei salmi che la trascrizione unisce al primo versetto (16, 17, 19, 27,
35, 63, 68) non fanno parte del versetto nella stampa e non sono riportati;
"COPH", la lettera ebraica che apre la strofa del 118, neppure.

## Versetti con la virgola prima di "e" o con il punto esclamativo

Il versetto resta alla lettera anche dove la regola di casa non lo
scriverebbe così. **Virgola prima di "e" o "ed"** nei versetti di:
Vehuiah (1), Sitael (3), Elemiah (4), Mahasiah (5), Cahethel (8), Lauviah (11), Hariel (15), Caliel (18), Leuviah (19), Melahel (23), Haheuiah (24), Reiiel (29), Vasariah (32), Iehuiah (33), Lehahiah (34), Menadel (36), Aniel (37), Rehael (39), Ieiazel (40), Veualiah (43), Ariel (46), Vehuel (49), Imamiah (52), Nithael (54), Mebahiah (55), Poyel (56), Mitzrael (60), Mehiel (64), Eiael (67), in tutto 29. **Punto esclamativo** nei versetti di: Lauviah II (17), Asaliah (47). Fuori dal
versetto, nei riti, non c'è nessuna delle due cose.

**"Salute".** Nei versetti di Elemiah (4),
Lauviah (11), Hakamiah (16) e Mihael (48) Martini scrive "salute" nel senso
antico di salvezza. Il versetto resta alla lettera; il rito intorno non parla
mai di salute.

## Come si legge una voce

- **Salmo**: numero e versetto nella Vulgata, quelli di Lenain.
- **Latino**: il versetto della Vulgata Clementina.
- **Martini**: il versetto alla lettera dalla stampa Passigli 1842, con
  accenti, apostrofi e punteggiatura della stampa. Fra parentesi quadre, in
  coda, le forme antiche segnalate: non fanno parte del versetto e a video si
  tolgono.
- **Rito**: fra quaranta e cinquanta parole contate per spazi, versetto
  compreso. Il versetto sta fra virgolette basse alla lettera; se finisce con
  punto, due punti o punto e virgola, quel segno finale è tolto, e nient'altro.
  Nessuna cifra.
- **Da dove viene**: il salmo, Lenain 1823, la traduzione di Martini e, dove
  cambia, il numero del versetto in Martini.

Il controllo delle parole e della lingua dei riti è uno script di prova fuori
dal repository, sulla traccia di `tool/le_parole_dei_responsi.py`: settantadue
riti fra quaranta e cinquanta parole, nessun difetto di lingua, nessuna frase
uguale in due riti fuori dal versetto.

## I settantadue

### 1, Vehuiah
- Salmo: 3, 4
- Latino: Tu autem Domine, susceptor meus es, gloria mea, et exaltans caput meum.
- Martini: Tu però, o Signore, tu se' mio scudo, mia gloria, e tu rinnalzi il mio capo. [forme antiche: «se'» per «sei», «rinnalzi» per «rialzi»]
- Rito: Al mattino, prima di cominciare, leggi a voce «Tu però, o Signore, tu se' mio scudo, mia gloria, e tu rinnalzi il mio capo». Ripetilo tre volte pensando a una cosa che rimandi da tempo. Il versetto non sceglie al posto tuo: accompagna il primo passo.
- Da dove viene: Salmo 3,4 della Vulgata, che Lenain (1823) assegna a Vehuiah; traduzione di Antonio Martini, Passigli 1842, dove è il versetto 3.

### 2, Ieliel
- Salmo: 21, 20
- Latino: Tu autem, Domine, ne elongaveris auxilium tuum a me; ad defensionem meam conspice.
- Martini: Signore, non allontanar da me il tuo soccorso; accorri in mia difesa. [forme antiche: «allontanar» troncato]
- Rito: Trova un momento di quiete e pronuncia «Signore, non allontanar da me il tuo soccorso; accorri in mia difesa». Dillo due volte pensando a un legame che ti sta a cuore. Chiediti che cosa lo tiene insieme dopo un disaccordo. Lascia un silenzio prima di tornare alle tue cose.
- Da dove viene: Salmo 21,20 della Vulgata, che Lenain (1823) assegna a Ieliel; traduzione di Antonio Martini, Passigli 1842, dove è il versetto 19.

### 3, Sitael
- Salmo: 90, 2
- Latino: Dicet Domino: Susceptor meus es tu et refugium meum; Deus meus, sperabo in eum.
- Martini: Egli dirà al Signore: Mio difensore sei tu, e mio asilo: egli è il mio Dio, in lui spererò;
- Rito: Richiama alla mente una promessa che hai fatto. Leggi a voce «Egli dirà al Signore: Mio difensore sei tu, e mio asilo: egli è il mio Dio, in lui spererò». Fallo tre volte. Guarda quanto tempo vuoi ancora dare a quella parola, anche ora che costa di più.
- Da dove viene: Salmo 90,2 della Vulgata, che Lenain (1823) assegna a Sitael; traduzione di Antonio Martini, Passigli 1842.

### 4, Elemiah
- Salmo: 6, 5
- Latino: Convertere, Domine, et eripe animam meam; salvum me fac propter misericordiam tuam.
- Martini: Volgiti, o Signore, e libera l'anima mia: per tua misericordia dammi salute. [«salute» vale «salvezza»]
- Rito: Quando una strada sembra inceppata, fermati un istante e leggi «Volgiti, o Signore, e libera l'anima mia: per tua misericordia dammi salute». Ripeti il versetto due volte prima di muoverti. Prova a distinguere l'ostacolo vero dal tumulto che senti dentro. Non cercare subito una soluzione: per ora basta vedere meglio.
- Da dove viene: Salmo 6,5 della Vulgata, che Lenain (1823) assegna a Elemiah; traduzione di Antonio Martini, Passigli 1842, dove è il versetto 4.

### 5, Mahasiah
- Salmo: 33, 5
- Latino: Exquisivi Dominum, et exaudivit me; et ex omnibus tribulationibus meis eripuit me.
- Martini: Cercai il Signore, e mi esaudì: e mi trasse fuori di tutte le mie tribolazioni.
- Rito: Prima di studiare o di parlare con una persona che si è allontanata, leggi piano «Cercai il Signore, e mi esaudì: e mi trasse fuori di tutte le mie tribolazioni». Ripetilo tre volte respirando con calma. Osserva il clima che porti nella stanza ancora prima di dire una parola.
- Da dove viene: Salmo 33,5 della Vulgata, che Lenain (1823) assegna a Mahasiah; traduzione di Antonio Martini, Passigli 1842, dove è il versetto 4.

### 6, Lelahel
- Salmo: 9, 12
- Latino: Psallite Domino qui habitat in Sion; annuntiate inter gentes studia ejus
- Martini: Cantate inni al Signore, che abita in Sion, annunziate i consigli di lui tralle nazioni; [forme antiche: «tralle» per «tra le»]
- Rito: Tieni in mente una tua capacità. Recita a voce chiara «Cantate inni al Signore, che abita in Sion, annunziate i consigli di lui tralle nazioni». Ripetilo due volte guardando le tue mani. Domandati per chi altro puoi usare quel talento questa settimana. La risposta può arrivare piano: lasciale spazio.
- Da dove viene: Salmo 9,12 della Vulgata, che Lenain (1823) assegna a Lelahel; traduzione di Antonio Martini, Passigli 1842, dove è il versetto 11.

### 7, Achaiah
- Salmo: 102, 8
- Latino: Miserator et misericors Dominus, longanimis, et multum misericors.
- Martini: Il Signore misericordioso e benigno: paziente e misericordioso grandemente.
- Rito: Scegli una domanda che ti accompagna da tempo e che hai smesso di guardare. Leggi a voce bassa «Il Signore misericordioso e benigno: paziente e misericordioso grandemente». Ripetilo sette volte senza fretta. Ogni ripetizione è un ritorno alla stessa cosa: così la pazienza continua a osservare anche quando l'interesse cala.
- Da dove viene: Salmo 102,8 della Vulgata, che Lenain (1823) assegna a Achaiah; traduzione di Antonio Martini, Passigli 1842.

### 8, Cahethel
- Salmo: 94, 6
- Latino: Venite, adoremus, et procidamus, et ploremus ante Dominum qui fecit nos
- Martini: Venite, adoriamolo e prostriamoci, e spargiamo lacrime dinanzi al Signore, di cui siamo fattura:
- Rito: Prima di un pasto o a fine lavoro, leggi «Venite, adoriamolo e prostriamoci, e spargiamo lacrime dinanzi al Signore, di cui siamo fattura». Dillo due volte con le mani aperte. Nomina in silenzio una cosa che hai ricevuto e da dove viene. Lascia che quel ricordo guidi il gesto successivo.
- Da dove viene: Salmo 94,6 della Vulgata, che Lenain (1823) assegna a Cahethel; traduzione di Antonio Martini, Passigli 1842.

### 9, Haziel
- Salmo: 24, 6
- Latino: Reminiscere miserationum tuarum, Domine, et misericordiarum tuarum quae a saeculo sunt.
- Martini: Ricordati di tue misericordie, o Signore, delle tue misericordie, che furono nei secoli addietro.
- Rito: Pensa a un torto che porti ancora con te. Leggi lentamente «Ricordati di tue misericordie, o Signore, delle tue misericordie, che furono nei secoli addietro». A ognuna delle tre letture chiediti se quel peso ti serve ancora. Perdonare resta una scelta tua, da fare senza fretta.
- Da dove viene: Salmo 24,6 della Vulgata, che Lenain (1823) assegna a Haziel; traduzione di Antonio Martini, Passigli 1842.

### 10, Aladiah
- Salmo: 32, 22
- Latino: Fiat misericordia tua, Domine, super nos, quemadmodum speravimus in te.
- Martini: Sia sopra di noi, o Signore, la tua misericordia, conforme noi in te abbiamo sperato. [forme antiche: «conforme» per «come»]
- Rito: Quando un vecchio errore torna a pesare, leggi a voce «Sia sopra di noi, o Signore, la tua misericordia, conforme noi in te abbiamo sperato». Fallo tre volte ricordando quello che è successo senza cancellarlo. Lascia che smetta di dire chi sei. Ricominciare è un gesto piccolo.
- Da dove viene: Salmo 32,22 della Vulgata, che Lenain (1823) assegna a Aladiah; traduzione di Antonio Martini, Passigli 1842.

### 11, Lauviah
- Salmo: 17, 47
- Latino: Vivit Dominus! et benedictus Deus meus! et exaltetur Deus salutis meae!
- Martini: Viva il Signore, e diasi benedizione al mio Dio, e sia glorificato il Dio di mia salute. [forme antiche: «diasi» per «si dia»; «salute» vale «salvezza»]
- Rito: Pensa a un progetto lungo che stai portando avanti. Leggi in piedi «Viva il Signore, e diasi benedizione al mio Dio, e sia glorificato il Dio di mia salute». Due letture bastano, con voce piena. Chiediti che cosa ti fa continuare quando l'entusiasmo dei primi giorni è passato.
- Da dove viene: Salmo 17,47 della Vulgata, che Lenain (1823) assegna a Lauviah; traduzione di Antonio Martini, Passigli 1842, dove è il versetto 46.

### 12, Hahaiah
- Salmo: 9, 22
- Latino: Ut quid, Domine, recessisti longe, despicis in opportunitatibus, in tribulatione?
- Martini: E perchè, o Signore, ti se' ritirato in lontananza, ci hai negletti nel maggior uopo, nella tribolazione? [forme antiche: «perchè» con l'accento grave, «se'» per «sei», «uopo» per «bisogno»]
- Rito: La sera, prima di dormire, leggi sottovoce «E perchè, o Signore, ti se' ritirato in lontananza, ci hai negletti nel maggior uopo, nella tribolazione?». Ripetilo due volte e poi resta in silenzio al buio. Se nella notte arriva un sogno o un'intuizione, accoglilo senza pretendere spiegazioni.
- Da dove viene: Salmo 9,22 della Vulgata, che Lenain (1823) assegna a Hahaiah; traduzione di Antonio Martini, Passigli 1842, dove è il versetto 21.

### 13, Iezalel
- Salmo: 97, 4
- Latino: Jubilate Deo, omnis terra; cantate et exsultate, et psallite.
- Martini: Canti con giubbilo laude a Dio tutta quanta la terra: cantate ed esultate al suono de' musicali strumenti. [forme antiche: «giubbilo» per «giubilo», «laude» per «lode», «de'» per «dei»]
- Rito: Pensa alle persone che tieni insieme. Leggi con voce piena «Canti con giubbilo laude a Dio tutta quanta la terra: cantate ed esultate al suono de' musicali strumenti». Tre volte, anche cantando se ti viene. Ricorda un nome che altri dimenticano. Fedeltà qui vuol dire memoria viva.
- Da dove viene: Salmo 97,4 della Vulgata, che Lenain (1823) assegna a Iezalel; traduzione di Antonio Martini, Passigli 1842, dove è il versetto 5.

### 14, Mebahel
- Salmo: 9, 10
- Latino: Et factus est Dominus refugium pauperi; adjutor in opportunitatibus, in tribulatione.
- Martini: E il Signore è stato rifugio al povero, aiutatore al tempo opportuno, nella tribolazione. [forme antiche: «aiutatore» per «aiuto»]
- Rito: Quando devi dire una cosa scomoda, leggi prima «E il Signore è stato rifugio al povero, aiutatore al tempo opportuno, nella tribolazione». Pronuncialo due volte senza alzare il tono. Chiediti se la verità che porti protegge qualcuno senza diventare un'arma. Applica la stessa misura prima di tutto a te.
- Da dove viene: Salmo 9,10 della Vulgata, che Lenain (1823) assegna a Mebahel; traduzione di Antonio Martini, Passigli 1842, dove è il versetto 9.

### 15, Hariel
- Salmo: 93, 22
- Latino: Et factus est mihi Dominus in refugium, et Deus meus in adjutorium spei meae.
- Martini: Ma il Signore è stato mio rifugio, e il mio Dio il sostegno di mia speranza.
- Rito: Riordina il tavolo o la stanza dove lavori. Poi leggi a voce «Ma il Signore è stato mio rifugio, e il mio Dio il sostegno di mia speranza». Ripetilo tre volte mentre guardi lo spazio che hai sistemato. Lascia che le idee prendano ordine come le cose intorno a te.
- Da dove viene: Salmo 93,22 della Vulgata, che Lenain (1823) assegna a Hariel; traduzione di Antonio Martini, Passigli 1842.

### 16, Hakamiah
- Salmo: 87, 2
- Latino: Domine, Deus salutis meae, in die clamavi et nocte coram te.
- Martini: Signore Dio di mia salute, di giorno e di notte alzai le mie grida dinanzi a te. [«salute» vale «salvezza»]
- Rito: Nel momento in cui vorresti sparire da una situazione difficile, leggi «Signore Dio di mia salute, di giorno e di notte alzai le mie grida dinanzi a te». Dillo due volte restando al tuo posto per tutto il tempo della lettura. Poi parla chiaro, anche se la franchezza costa qualcosa.
- Da dove viene: Salmo 87,2 della Vulgata, che Lenain (1823) assegna a Hakamiah; traduzione di Antonio Martini, Passigli 1842, dove è il versetto 1.

### 17, Lauviah II
- Salmo: 8, 2
- Latino: Domine, Dominus noster, quam admirabile est nomen tuum in universa terra! quoniam elevata est magnificentia tua super caelos.
- Martini: Signore, Signor nostro, quanto ammirabile è il nome tuo per tutta quanta la terra! Perocchè la tua maestà è elevata fin sopra dei cieli. [forme antiche: «Perocchè» per «perché», «ammirabile» per «mirabile»]
- Rito: Quando un'intuizione arriva di notte, leggi «Signore, Signor nostro, quanto ammirabile è il nome tuo per tutta quanta la terra! Perocchè la tua maestà è elevata fin sopra dei cieli». Una volta sola basta. Poi annota l'intuizione su un foglio e trattala come un dato da verificare.
- Da dove viene: Salmo 8,2 della Vulgata, che Lenain (1823) assegna a Lauviah II; traduzione di Antonio Martini, Passigli 1842, dove è il versetto 1.

### 18, Caliel
- Salmo: 7, 9
- Latino: Dominus judicat populos. Judica me, Domine, secundum justitiam meam, et secundum innocentiam meam super me.
- Martini: Il Signore fa giudizio dei popoli. Fammi ragione, o Signore, secondo la mia giustizia, e secondo l'innocenza che è in me. [forme antiche: «Fammi ragione» per «rendimi giustizia»]
- Rito: Prima di prendere posizione su una questione, leggi «Il Signore fa giudizio dei popoli. Fammi ragione, o Signore, secondo la mia giustizia, e secondo l'innocenza che è in me». Ripetilo due volte con la voce bassa. Separa il fatto dall'opinione. Poi decidi senza bisogno di alzare il tono.
- Da dove viene: Salmo 7,9 della Vulgata, che Lenain (1823) assegna a Caliel; traduzione di Antonio Martini, Passigli 1842, dove è il versetto 8.

### 19, Leuviah
- Salmo: 39, 2
- Latino: Exspectans exspectavi Dominum, et intendit mihi.
- Martini: Aspettai ansiosamente il Signore, ed egli a me si rivolse.
- Rito: Ripensa a una questione rimasta aperta nel tuo passato. Leggi con calma «Aspettai ansiosamente il Signore, ed egli a me si rivolse». Ripetilo tre volte lasciando fra una lettura e l'altra il tempo di un respiro. Ricorda per capire. Non serve rinfacciare niente a nessuno.
- Da dove viene: Salmo 39,2 della Vulgata, che Lenain (1823) assegna a Leuviah; traduzione di Antonio Martini, Passigli 1842, dove è il versetto 1.

### 20, Pahaliah
- Salmo: 119, 2
- Latino: Domine, libera animam meam a labiis iniquis et a lingua dolosa.
- Martini: Signore, libera l'anima mia dalle labbra inique e dalla lingua ingannatrice.
- Rito: Pensa a un'abitudine che ti blocca da tempo. Leggi con voce chiara «Signore, libera l'anima mia dalle labbra inique e dalla lingua ingannatrice». Ripeti il versetto tre volte. Decidi una sola cosa che consideri non negoziabile. Cambiare direzione è una scelta da rinnovare ogni giorno.
- Da dove viene: Salmo 119,2 della Vulgata, che Lenain (1823) assegna a Pahaliah; traduzione di Antonio Martini, Passigli 1842.

### 21, Nelchael
- Salmo: 30, 15
- Latino: Ego autem in te speravi, Domine; dixi: Deus meus es tu
- Martini: Io però in te sperai, o Signore; io dissi: Tu se' il mio Dio: [forme antiche: «se'» per «sei»]
- Rito: Apri il libro o il quaderno che stai studiando. Prima di leggere, pronuncia «Io però in te sperai, o Signore; io dissi: Tu se' il mio Dio». Dillo due volte e accetta di non capire subito. Il sapere serve a costruire qualcosa, non ad avere ragione.
- Da dove viene: Salmo 30,15 della Vulgata, che Lenain (1823) assegna a Nelchael; traduzione di Antonio Martini, Passigli 1842, dove è il versetto 14.

### 22, Ieiaiel
- Salmo: 120, 5
- Latino: Dominus custodit te, Dominus protectio tua super manum dexteram tuam.
- Martini: Il Signore ti custodisce: il Signore è tua difesa al tuo destro fianco.
- Rito: Prima di presentare un lavoro agli altri, fermati e leggi «Il Signore ti custodisce: il Signore è tua difesa al tuo destro fianco». Tre letture, lente. Chiediti se ciò che consegni regge nel tempo. L'applauso conta meno della solidità di quello che fai.
- Da dove viene: Salmo 120,5 della Vulgata, che Lenain (1823) assegna a Ieiaiel; traduzione di Antonio Martini, Passigli 1842.

### 23, Melahel
- Salmo: 120, 8
- Latino: Dominus custodiat introitum tuum et exitum tuum, ex hoc nunc et usque in saeculum.
- Martini: Il Signore ti custodisca all'entrare e all'uscire, da questo punto, e per sempre.
- Rito: Mentre annaffi una pianta o versi un bicchiere d'acqua, leggi «Il Signore ti custodisca all'entrare e all'uscire, da questo punto, e per sempre». Ripetilo ogni sera per una settimana. La costanza di questo gesto piccolo vale più di un gesto grande fatto una volta.
- Da dove viene: Salmo 120,8 della Vulgata, che Lenain (1823) assegna a Melahel; traduzione di Antonio Martini, Passigli 1842.

### 24, Haheuiah
- Salmo: 32, 18
- Latino: Ecce oculi Domini super metuentes eum: et in eis qui sperant super misericordia ejus.
- Martini: Ecco gli occhi del Signore sopra coloro che lo temono, e sopra coloro, che confidano nella sua misericordia.
- Rito: Pensa a chi oggi si sente fuori posto, anche a te. Leggi «Ecco gli occhi del Signore sopra coloro che lo temono, e sopra coloro, che confidano nella sua misericordia». Ripetilo due volte tenendo in mente quella persona. Stai accanto a quella condizione con fermezza più che con pietà.
- Da dove viene: Salmo 32,18 della Vulgata, che Lenain (1823) assegna a Haheuiah; traduzione di Antonio Martini, Passigli 1842.

### 25, Nithhaiah
- Salmo: 9, 2
- Latino: Confitebor tibi, Domine, in toto corde meo; narrabo omnia mirabilia tua.
- Martini: Te io loderò o Signore, con tutto il mio cuore: racconterò tutte le tue meraviglie.
- Rito: Concediti qualche minuto di silenzio prima di parlare. Poi leggi «Te io loderò o Signore, con tutto il mio cuore: racconterò tutte le tue meraviglie». Ripetilo tre volte e torna al silenzio. Le intuizioni arrivano spesso quando smetti di cercarle. Lascia che la parola venga dopo.
- Da dove viene: Salmo 9,2 della Vulgata, che Lenain (1823) assegna a Nithhaiah; traduzione di Antonio Martini, Passigli 1842, dove è il versetto 1.

### 26, Haaiah
- Salmo: 118, 145
- Latino: Clamavi in toto corde meo: exaudi me, Domine; justificationes tuas requiram.
- Martini: Gridai con tutto il mio cuore: esaudiscimi, o Signore: fa' ch'io cerchi le tue giustificazioni.
- Rito: Prima di un confronto in cui le posizioni si irrigidiscono, leggi «Gridai con tutto il mio cuore: esaudiscimi, o Signore: fa' ch'io cerchi le tue giustificazioni». Ripetilo due volte cercando dentro di te il punto di incontro. Pensa alla cosa giusta da dire senza alzare la voce.
- Da dove viene: Salmo 118,145 della Vulgata, che Lenain (1823) assegna a Haaiah; traduzione di Antonio Martini, Passigli 1842.

### 27, Ierathel
- Salmo: 139, 2
- Latino: Eripe me, Domine, ab homine malo; a viro iniquo eripe me.
- Martini: Liberami, o Signore, dall'uomo cattivo: liberami dall'uomo iniquo.
- Rito: Quando senti una pressione ingiusta su di te o su qualcuno che stimi, leggi a voce ferma «Liberami, o Signore, dall'uomo cattivo: liberami dall'uomo iniquo». Ripetilo tre volte. Chiediti dove puoi portare chiarezza. Usa la fermezza per difendere chi ne ha bisogno. Mai per colpire.
- Da dove viene: Salmo 139,2 della Vulgata, che Lenain (1823) assegna a Ierathel; traduzione di Antonio Martini, Passigli 1842, dove è il versetto 1.

### 28, Seheiah
- Salmo: 70, 12
- Latino: Deus, ne elongeris a me; Deus meus, in auxilium meum respice.
- Martini: Non ti dilungare, o Dio, da me; Dio mio, volgiti ad aiutarmi. [forme antiche: «dilungare» per «allontanare»]
- Rito: Prima di una decisione presa di corsa, rallenta e leggi «Non ti dilungare, o Dio, da me; Dio mio, volgiti ad aiutarmi». Dillo tre volte con un respiro lungo fra le letture. Guarda la strada davanti a te. Scegli un passo che puoi sostenere.
- Da dove viene: Salmo 70,12 della Vulgata, che Lenain (1823) assegna a Seheiah; traduzione di Antonio Martini, Passigli 1842.

### 29, Reiiel
- Salmo: 53, 6
- Latino: Ecce enim Deus adjuvat me, et Dominus susceptor est animae meae.
- Martini: Ecco però, che Dio mi aiuta, e il Signore ha presa a difendere la mia vita. [forme antiche: «ha presa» con il participio accordato]
- Rito: Pensa a una credenza ricevuta che ormai ti sta stretta. Leggi piano «Ecco però, che Dio mi aiuta, e il Signore ha presa a difendere la mia vita». Ripetilo due volte, poi lascia andare un legame che trattiene, senza rancore verso chi te l'ha dato.
- Da dove viene: Salmo 53,6 della Vulgata, che Lenain (1823) assegna a Reiiel; traduzione di Antonio Martini, Passigli 1842, dove è il versetto 4.

### 30, Omael
- Salmo: 70, 5
- Latino: quoniam tu es patientia mea, Domine; Domine, spes mea a juventute mea.
- Martini: Imperocchè tu se', o Signore, la mia aspettazione: Signore, tu mia speranza fin dalla mia gioventù. [forme antiche: «Imperocchè» per «perché», «se'» per «sei», «aspettazione» per «attesa»]
- Rito: Nei giorni in cui nulla sembra muoversi, leggi piano «Imperocchè tu se', o Signore, la mia aspettazione: Signore, tu mia speranza fin dalla mia gioventù». Ripetilo tre volte senza forzare il raccolto. Pensa a come preparare il terreno per ciò che matura lentamente.
- Da dove viene: Salmo 70,5 della Vulgata, che Lenain (1823) assegna a Omael; traduzione di Antonio Martini, Passigli 1842.

### 31, Lecabel
- Salmo: 70, 16
- Latino: introibo in potentias Domini; Domine, memorabor justitiae tuae solius.
- Martini: Perchè io non ho cognizione di lettere m'internerò nella possanza del Signore; della sola giustizia tua, o Signore, io mi ricorderò. [forme antiche: «Perchè» con l'accento grave, «m'internerò», «possanza» per «potenza»]
- Rito: Prima di un lavoro di precisione, leggi «Perchè io non ho cognizione di lettere m'internerò nella possanza del Signore; della sola giustizia tua, o Signore, io mi ricorderò». Basta una lettura lenta. Poi guarda il dettaglio senza perdere l'insieme del progetto.
- Da dove viene: Salmo 70,16 della Vulgata, che Lenain (1823) assegna a Lecabel; traduzione di Antonio Martini, Passigli 1842.

### 32, Vasariah
- Salmo: 32, 4
- Latino: Quia rectum est verbum Domini, et omnia opera ejus in fide.
- Martini: Perocchè diritta ell'è la parola del Signore, e tutte le opere di lui sono nella fedeltà. [forme antiche: «Perocchè» per «perché», «ell'è» per «essa è»]
- Rito: Quando stai per giudicare qualcuno, leggi «Perocchè diritta ell'è la parola del Signore, e tutte le opere di lui sono nella fedeltà». Dillo due volte prima di aprire bocca. Separa l'errore dalla persona che l'ha commesso. Misura con calma prima di pronunciarti.
- Da dove viene: Salmo 32,4 della Vulgata, che Lenain (1823) assegna a Vasariah; traduzione di Antonio Martini, Passigli 1842.

### 33, Iehuiah
- Salmo: 93, 11
- Latino: Dominus scit cogitationes hominum, quoniam vanae sunt.
- Martini: Il Signore conosce i pensieri degli uomini, e come son vani. [forme antiche: «son» per «sono»]
- Rito: Prima di entrare al lavoro o in una riunione, leggi in silenzio e poi a voce «Il Signore conosce i pensieri degli uomini, e come son vani». Due letture bastano. Distingui il ruolo dalla persona che lo occupa. Tieni la promessa che hai fatto anche quando costa.
- Da dove viene: Salmo 93,11 della Vulgata, che Lenain (1823) assegna a Iehuiah; traduzione di Antonio Martini, Passigli 1842.

### 34, Lehahiah
- Salmo: 130, 3
- Latino: Speret Israel in Domino, ex hoc nunc et usque in saeculum.
- Martini: Nel Signore speri Israele da questo punto, e pei secoli. [forme antiche: «pei» per «per i»]
- Rito: Quando senti salire la collera, fermati. Respira tre volte e leggi «Nel Signore speri Israele da questo punto, e pei secoli». Ripetilo finché la voce torna piana. La calma che cerchi non è debolezza: è una forza che sceglie di non esplodere. Riprendi poi la conversazione.
- Da dove viene: Salmo 130,3 della Vulgata, che Lenain (1823) assegna a Lehahiah; traduzione di Antonio Martini, Passigli 1842, dove è il versetto 5.

### 35, Chavakhiah
- Salmo: 114, 1
- Latino: Alleluja. Dilexi, quoniam exaudiet Dominus vocem orationis meae.
- Martini: Ho amato, perchè esaudirà il Signore la voce della mia orazione; [forme antiche: «perchè» con l'accento grave]
- Rito: Pensa a una persona di famiglia con cui il filo si è spezzato. Leggi a mezza voce «Ho amato, perchè esaudirà il Signore la voce della mia orazione». Ripetilo tre volte e chiediti quale primo passo è possibile. Scegliere il legame non significa dare ragione all'altro.
- Da dove viene: Salmo 114,1 della Vulgata, che Lenain (1823) assegna a Chavakhiah; traduzione di Antonio Martini, Passigli 1842.

### 36, Menadel
- Salmo: 25, 8
- Latino: Domine, dilexi decorem domus tuae, et locum habitationis gloriae tuae.
- Martini: Signore, io ho amato lo splendore della tua casa, e il luogo dove abita la tua gloria.
- Rito: All'inizio della giornata di lavoro, leggi «Signore, io ho amato lo splendore della tua casa, e il luogo dove abita la tua gloria». Ripetilo due volte guardando il luogo dove ti trovi. Chiediti che cosa ha ancora da insegnarti il posto che occupi oggi.
- Da dove viene: Salmo 25,8 della Vulgata, che Lenain (1823) assegna a Menadel; traduzione di Antonio Martini, Passigli 1842.

### 37, Aniel
- Salmo: 79, 8
- Latino: Deus virtutum, converte nos, et ostende faciem tuam, et salvi erimus.
- Martini: Dio degli eserciti, convertici, e mostraci la tua faccia, e sarem salvi. [forme antiche: «sarem» per «saremo»]
- Rito: Quando ti accorgi di girare intorno alla stessa cosa, leggi «Dio degli eserciti, convertici, e mostraci la tua faccia, e sarem salvi». Ripetilo tre volte e dai un nome al cerchio che si ripete. Poi decidi con lucidità il primo gesto per uscirne.
- Da dove viene: Salmo 79,8 della Vulgata, che Lenain (1823) assegna a Aniel; traduzione di Antonio Martini, Passigli 1842.

### 38, Haamiah
- Salmo: 90, 9
- Latino: Quoniam tu es, Domine, spes mea; Altissimum posuisti refugium tuum.
- Martini: (E dirai): Tu se', o Signore, la mia speranza: e che per tuo rifugio hai scelto l'Altissimo. [forme antiche: «se'» per «sei»]
- Rito: Scegli un'ora fissa del giorno per questo gesto. Leggi «(E dirai): Tu se', o Signore, la mia speranza: e che per tuo rifugio hai scelto l'Altissimo». Ripetilo tre volte alla stessa ora per alcuni giorni. Il rito non serve a ottenere: ricorda chi sei mentre lo compi.
- Da dove viene: Salmo 90,9 della Vulgata, che Lenain (1823) assegna a Haamiah; traduzione di Antonio Martini, Passigli 1842.

### 39, Rehael
- Salmo: 29, 11
- Latino: Audivit Dominus, et misertus est mei; Dominus factus est adjutor meus.
- Martini: Il Signore mi udì, ed ebbe pietà di me: il Signore si fe' mio aiuto. [forme antiche: «fe'» per «fece»]
- Rito: Pensa a un genitore o a un figlio. Leggi a voce «Il Signore mi udì, ed ebbe pietà di me: il Signore si fe' mio aiuto». Ripetilo due volte con quel volto davanti agli occhi. Prova a guardare quella persona senza il conto aperto degli anni passati.
- Da dove viene: Salmo 29,11 della Vulgata, che Lenain (1823) assegna a Rehael; traduzione di Antonio Martini, Passigli 1842, dove è il versetto 10.

### 40, Ieiazel
- Salmo: 87, 15
- Latino: Ut quid, Domine, repellis orationem meam, avertis faciem tuam a me?
- Martini: E perchè, o Signore, rigetti tu la mia orazione, e rivolgi da me la tua faccia? [forme antiche: «perchè» con l'accento grave]
- Rito: Quando qualcuno accanto a te attraversa la tristezza, leggi per te «E perchè, o Signore, rigetti tu la mia orazione, e rivolgi da me la tua faccia?». Una lettura sola, a bassa voce. Poi resta accanto senza spiegare. Il dolore chiede presenza, non fretta.
- Da dove viene: Salmo 87,15 della Vulgata, che Lenain (1823) assegna a Ieiazel; traduzione di Antonio Martini, Passigli 1842.

### 41, Hahahel
- Salmo: 119, 2
- Latino: Domine, libera animam meam a labiis iniquis et a lingua dolosa.
- Martini: Signore, libera l'anima mia dalle labbra inique e dalla lingua ingannatrice.
- Rito: Prima di parlare in pubblico o di insegnare, leggi «Signore, libera l'anima mia dalle labbra inique e dalla lingua ingannatrice». Ripetilo due volte con lentezza. Chiediti se quello che dici corrisponde a quello che fai quando nessuno guarda. La fiducia degli altri resta nelle tue mani.
- Da dove viene: Salmo 119,2 della Vulgata, che Lenain (1823) assegna a Hahahel; traduzione di Antonio Martini, Passigli 1842.

### 42, Mikael
- Salmo: 120, 7
- Latino: Dominus custodit te ab omni malo; custodiat animam tuam Dominus.
- Martini: Il Signore ti custodisce da ogni male: custodisca il Signore l'anima tua.
- Rito: Prima di una trattativa o di un viaggio, leggi con voce tranquilla «Il Signore ti custodisce da ogni male: custodisca il Signore l'anima tua». Ripetilo tre volte mettendo ordine nei pensieri. Guarda le cose come stanno prima di prendere posizione. La responsabilità resta tua.
- Da dove viene: Salmo 120,7 della Vulgata, che Lenain (1823) assegna a Mikael; traduzione di Antonio Martini, Passigli 1842.

### 43, Veualiah
- Salmo: 87, 14
- Latino: Et ego ad te, Domine, clamavi, et mane oratio mea praeveniet te.
- Martini: Ma io alzai a te le grida, o Signore, e la mia orazione al mattino ti preverrà. [forme antiche: «preverrà» per «precederà»]
- Rito: Al mattino, davanti a un compito da portare a termine, leggi «Ma io alzai a te le grida, o Signore, e la mia orazione al mattino ti preverrà». Due volte, poi scrivi il prossimo passo verificabile. La disciplina conta più dell'entusiasmo.
- Da dove viene: Salmo 87,14 della Vulgata, che Lenain (1823) assegna a Veualiah; traduzione di Antonio Martini, Passigli 1842.

### 44, Ielahiah
- Salmo: 118, 108
- Latino: Voluntaria oris mei beneplacita fac, Domine, et judicia tua doce me.
- Martini: Sien graditi a te, o Signore, i volontari sacrifizi della mia bocca: e insegnami i tuoi giudizi. [forme antiche: «Sien» per «siano», «sacrifizi» per «sacrifici»]
- Rito: Quando mantenere la parola data costa, leggi «Sien graditi a te, o Signore, i volontari sacrifizi della mia bocca: e insegnami i tuoi giudizi». Ripetilo due volte ricordando che cosa hai promesso e a chi. Chiediti come restare coerente anche sotto pressione.
- Da dove viene: Salmo 118,108 della Vulgata, che Lenain (1823) assegna a Ielahiah; traduzione di Antonio Martini, Passigli 1842.

### 45, Sealiah
- Salmo: 93, 18
- Latino: Si dicebam: Motus est pes meus, misericordia tua, Domine, adjuvabat me.
- Martini: Se io diceva a te: il mio piede vacilla; la tua misericordia, o Signore, veniva in mio soccorso. [forme antiche: «diceva» per «dicevo»]
- Rito: Dopo una caduta, anche piccola, leggi «Se io diceva a te: il mio piede vacilla; la tua misericordia, o Signore, veniva in mio soccorso». Ripetilo tre volte con calma. Rimetti in moto una sola cosa che si era fermata. Non pretendere che accada tutto subito.
- Da dove viene: Salmo 93,18 della Vulgata, che Lenain (1823) assegna a Sealiah; traduzione di Antonio Martini, Passigli 1842.

### 46, Ariel
- Salmo: 144, 9
- Latino: Suavis Dominus universis; et miserationes ejus super omnia opera ejus.
- Martini: Il Signore con tutti è benefico, e in tutte le opere di lui han luogo le sue misericordie. [forme antiche: «han» per «hanno»]
- Rito: Prima di indagare su un dettaglio che ti incuriosisce, leggi «Il Signore con tutti è benefico, e in tutte le opere di lui han luogo le sue misericordie». Due letture, poi verifica con pazienza quello che hai notato invece di innamorartene.
- Da dove viene: Salmo 144,9 della Vulgata, che Lenain (1823) assegna a Ariel; traduzione di Antonio Martini, Passigli 1842.

### 47, Asaliah
- Salmo: 103, 24
- Latino: Quam magnificata sunt opera tua, Domine! omnia in sapientia fecisti; impleta est terra possessione tua.
- Martini: Quanto grandiose son le opere tue, o Signore! ogni cosa hai tu fatto con sapienza: la terra è piena di tue ricchezze. [forme antiche: «son» per «sono»]
- Rito: Prima di dire una parola che pesa sulla vita di altri, leggi «Quanto grandiose son le opere tue, o Signore! ogni cosa hai tu fatto con sapienza: la terra è piena di tue ricchezze». Una lettura lenta basta. Cerca il vero prima del comodo.
- Da dove viene: Salmo 103,24 della Vulgata, che Lenain (1823) assegna a Asaliah; traduzione di Antonio Martini, Passigli 1842.

### 48, Mihael
- Salmo: 97, 2
- Latino: Notum fecit Dominus salutare suum; in conspectu gentium revelavit justitiam suam.
- Martini: Il Signore ha manifestata la sua salute: ha rivelata la sua giustizia agli occhi delle nazioni. [forme antiche: «ha manifestata» e «ha rivelata» con il participio accordato; «salute» vale «salvezza»]
- Rito: Pensa al legame che ti è più vicino. Leggi, anche insieme all'altra persona, «Il Signore ha manifestata la sua salute: ha rivelata la sua giustizia agli occhi delle nazioni». Ripetilo due volte. Resta presente anche nei giorni in cui il legame restituisce poco.
- Da dove viene: Salmo 97,2 della Vulgata, che Lenain (1823) assegna a Mihael; traduzione di Antonio Martini, Passigli 1842, dove è il versetto 3.

### 49, Vehuel
- Salmo: 144, 3
- Latino: Magnus Dominus, et laudabilis nimis; et magnitudinis ejus non est finis.
- Martini: Grande il Signore, e laudabile oltre modo: e la grandezza di lui non ha termine. [forme antiche: «laudabile» per «lodevole»]
- Rito: Prima di valutare il lavoro di qualcuno, leggi «Grande il Signore, e laudabile oltre modo: e la grandezza di lui non ha termine». Ripetilo tre volte con voce piana. Usa il tuo metro alto per riconoscere il valore di chi hai davanti. Non per pesarti addosso.
- Da dove viene: Salmo 144,3 della Vulgata, che Lenain (1823) assegna a Vehuel; traduzione di Antonio Martini, Passigli 1842.

### 50, Daniel
- Salmo: 102, 8
- Latino: Miserator et misericors Dominus, longanimis, et multum misericors.
- Martini: Il Signore misericordioso e benigno: paziente e misericordioso grandemente.
- Rito: Davanti a una scelta rimandata troppo a lungo, siediti e leggi «Il Signore misericordioso e benigno: paziente e misericordioso grandemente». Ripetilo tre volte senza correre. Ascolta le ragioni di chi la pensa diversamente. Poi passa dal dubbio alla scelta, sapendo che una decisione può costare qualcosa.
- Da dove viene: Salmo 102,8 della Vulgata, che Lenain (1823) assegna a Daniel; traduzione di Antonio Martini, Passigli 1842.

### 51, Hahasiah
- Salmo: 103, 31
- Latino: Sit gloria Domini in saeculum; laetabitur Dominus in operibus suis.
- Martini: Sia celebrata pei secoli la gloria del Signore: si allegrerà il Signore nelle opere sue: [forme antiche: «pei» per «per i», «allegrerà» per «rallegrerà»]
- Rito: Prima di metterti al lavoro su una cosa nuova, leggi «Sia celebrata pei secoli la gloria del Signore: si allegrerà il Signore nelle opere sue». Ripetilo due volte e chiediti come funziona davvero quello che hai davanti. Tieni il metodo, lascia la pretesa di sapere tutto.
- Da dove viene: Salmo 103,31 della Vulgata, che Lenain (1823) assegna a Hahasiah; traduzione di Antonio Martini, Passigli 1842.

### 52, Imamiah
- Salmo: 7, 18
- Latino: Confitebor Domino secundum justitiam ejus, et psallam nomini Domini altissimi.
- Martini: Glorificherò il Signore per la sua giustizia, e al nome del Signore altissimo canterò inni di laude. [forme antiche: «laude» per «lode»]
- Rito: Quando riconosci un tuo errore, leggi a voce «Glorificherò il Signore per la sua giustizia, e al nome del Signore altissimo canterò inni di laude». Due volte, senza trasformarlo in condanna. Scegli un fatto concreto con cui cominciare a riparare.
- Da dove viene: Salmo 7,18 della Vulgata, che Lenain (1823) assegna a Imamiah; traduzione di Antonio Martini, Passigli 1842, dove è il versetto 17.

### 53, Nanael
- Salmo: 118, 75
- Latino: Cognovi, Domine, quia aequitas judicia tua, et in veritate tua humiliasti me.
- Martini: Ho conosciuto, o Signore, che i giudizi tuoi sono equità; e che secondo la tua verità tu mi hai umiliato.
- Rito: Nel silenzio di un momento di studio, leggi «Ho conosciuto, o Signore, che i giudizi tuoi sono equità; e che secondo la tua verità tu mi hai umiliato». Ripetilo una volta. Pensa a come trasmettere ciò che sai senza umiliare chi ascolta.
- Da dove viene: Salmo 118,75 della Vulgata, che Lenain (1823) assegna a Nanael; traduzione di Antonio Martini, Passigli 1842.

### 54, Nithael
- Salmo: 102, 19
- Latino: Dominus in caelo paravit sedem suam, et regnum ipsius omnibus dominabitur.
- Martini: Il Signore ha preparato in cielo il suo trono, e al regno di lui tutti saranno soggetti.
- Rito: Davanti a una cosa bella che altri non notano, leggi «Il Signore ha preparato in cielo il suo trono, e al regno di lui tutti saranno soggetti». Ripetilo due volte mentre la guardi. Chiediti che cosa di quello che fai può durare oltre te.
- Da dove viene: Salmo 102,19 della Vulgata, che Lenain (1823) assegna a Nithael; traduzione di Antonio Martini, Passigli 1842.

### 55, Mebahiah
- Salmo: 101, 13
- Latino: Tu autem, Domine, in aeternum permanes, et memoriale tuum in generationem et generationem.
- Martini: Ma tu, o Signore, duri in eterno, e di generazione in generazione va la ricordanza di te. [forme antiche: «ricordanza» per «ricordo»]
- Rito: Pensa a un principio in cui credi. Leggi «Ma tu, o Signore, duri in eterno, e di generazione in generazione va la ricordanza di te». Dillo due volte e poi scegli un gesto di oggi che lo renda visibile. Le parole dichiarate contano meno dei fatti.
- Da dove viene: Salmo 101,13 della Vulgata, che Lenain (1823) assegna a Mebahiah; traduzione di Antonio Martini, Passigli 1842.

### 56, Poyel
- Salmo: 144, 14
- Latino: Allevat Dominus omnes qui corruunt, et erigit omnes elisos.
- Martini: Il Signore sostenta tutti que', che stan per cadere, e rialza tutti que' che si sono infranti. [forme antiche: «que'» per «quei», «stan» per «stanno»]
- Rito: Quando qualcosa cede, la fiducia o un progetto, leggi «Il Signore sostenta tutti que', che stan per cadere, e rialza tutti que' che si sono infranti». Ripetilo tre volte e chiedi soltanto quello che serve davvero. Rialzarsi viene prima di salire.
- Da dove viene: Salmo 144,14 della Vulgata, che Lenain (1823) assegna a Poyel; traduzione di Antonio Martini, Passigli 1842.

### 57, Nemamiah
- Salmo: 113, 19
- Latino: Qui timent Dominum speraverunt in Domino; adjutor eorum et protector eorum est.
- Martini: Nel Signore hanno sperato quelli, che temono: egli è loro aiuto e lor protettore. [forme antiche: «lor» per «loro»]
- Rito: Prima di una decisione rapida, leggi «Nel Signore hanno sperato quelli, che temono: egli è loro aiuto e lor protettore». Ripetilo due volte separando la sostanza dall'apparenza. Decidi in fretta solo dopo aver nominato a voce alta ciò che hai capito davvero.
- Da dove viene: Salmo 113,19 della Vulgata, che Lenain (1823) assegna a Nemamiah; traduzione di Antonio Martini, Passigli 1842.

### 58, Ieialel
- Salmo: 6, 4
- Latino: Et anima mea turbata est valde; sed tu, Domine, usquequo?
- Martini: E l'anima mia è grandemente turbata: ma tu, o Signore, fino a quando?...
- Rito: Quando la fatica di un lavoro lungo si fa sentire, leggi «E l'anima mia è grandemente turbata: ma tu, o Signore, fino a quando?». Ripetilo due volte e poi torna sulla cosa che stai facendo. Guardala finché non ne vedi la causa.
- Da dove viene: Salmo 6,4 della Vulgata, che Lenain (1823) assegna a Ieialel; traduzione di Antonio Martini, Passigli 1842, dove è il versetto 3.

### 59, Harahel
- Salmo: 112, 3
- Latino: A solis ortu usque ad occasum laudabile nomen Domini.
- Martini: Dall'oriente fino all'occaso ha da lodarsi il nome del Signore. [forme antiche: «occaso» per «tramonto»]
- Rito: Prima di riordinare carte, appunti o archivi, leggi a voce «Dall'oriente fino all'occaso ha da lodarsi il nome del Signore». Ripetilo tre volte, all'inizio e alla fine del lavoro. Chiediti che cosa di quello che conservi merita di passare a qualcun altro. Giudica con misura.
- Da dove viene: Salmo 112,3 della Vulgata, che Lenain (1823) assegna a Harahel; traduzione di Antonio Martini, Passigli 1842.

### 60, Mitzrael
- Salmo: 144, 17
- Latino: Justus Dominus in omnibus viis suis, et sanctus in omnibus operibus suis.
- Martini: Giusto il Signore in tutte le sue vie, e santo in tutte le opere sue.
- Rito: Pensa a qualcosa che si è rotto dentro di te o fra te e un'altra persona. Leggi «Giusto il Signore in tutte le sue vie, e santo in tutte le opere sue». Tre letture, una dopo l'altra. Scegli la pazienza al posto della rivincita.
- Da dove viene: Salmo 144,17 della Vulgata, che Lenain (1823) assegna a Mitzrael; traduzione di Antonio Martini, Passigli 1842.

### 61, Umabel
- Salmo: 112, 2
- Latino: Sit nomen Domini benedictum ex hoc nunc et usque in saeculum.
- Martini: Sia benedetto il nome del Signore, da questo punto fino ne' secoli. [forme antiche: «ne'» per «nei»]
- Rito: Pensa a un'amicizia che ti è cara. Leggi a voce, con calma, «Sia benedetto il nome del Signore, da questo punto fino ne' secoli». Ripetilo due volte sentendo la vicinanza dell'altra persona. Ricorda però dove finisci tu e dove comincia lei.
- Da dove viene: Salmo 112,2 della Vulgata, che Lenain (1823) assegna a Umabel; traduzione di Antonio Martini, Passigli 1842.

### 62, Iahhel
- Salmo: 118, 159
- Latino: Vide quoniam mandata tua dilexi, Domine; in misericordia tua vivifica me.
- Martini: Mira, o Signore, com'io ho amati i tuoi precetti: per tua misericordia dammi la vita. [forme antiche: «com'io» per «come io»]
- Rito: Prima di rispondere a una domanda difficile, ritirati per un momento e leggi «Mira, o Signore, com'io ho amati i tuoi precetti: per tua misericordia dammi la vita». Basta una volta. Il silenzio scelto prepara una parola misurata, che arriva al momento giusto.
- Da dove viene: Salmo 118,159 della Vulgata, che Lenain (1823) assegna a Iahhel; traduzione di Antonio Martini, Passigli 1842.

### 63, Anauel
- Salmo: 99, 2
- Latino: Jubilate Deo, omnis terra; servite Domino in laetitia. Introite in conspectu ejus in exsultatione.
- Martini: Canti con giubbilo le lodi di Dio tutta quanta la terra: servite il Signore con allegrezza. [forme antiche: «giubbilo» per «giubilo»]
- Rito: Quando due interessi sembrano opposti, leggi «Canti con giubbilo le lodi di Dio tutta quanta la terra: servite il Signore con allegrezza». Ripetilo tre volte cercando il punto in cui le due parti possono incontrarsi. Comincia da lì, con un passo piccolo.
- Da dove viene: Salmo 99,2 della Vulgata, che Lenain (1823) assegna a Anauel; traduzione di Antonio Martini, Passigli 1842, dove è il versetto 1.

### 64, Mehiel
- Salmo: 32, 18
- Latino: Ecce oculi Domini super metuentes eum: et in eis qui sperant super misericordia ejus.
- Martini: Ecco gli occhi del Signore sopra coloro che lo temono, e sopra coloro, che confidano nella sua misericordia.
- Rito: Prima di scrivere o di parlare in pubblico, leggi «Ecco gli occhi del Signore sopra coloro che lo temono, e sopra coloro, che confidano nella sua misericordia». Una sola lettura, con tutta l'attenzione. Unisci quello che senti a quello che ragioni, senza sacrificare nessuno dei due.
- Da dove viene: Salmo 32,18 della Vulgata, che Lenain (1823) assegna a Mehiel; traduzione di Antonio Martini, Passigli 1842.

### 65, Damabiah
- Salmo: 89, 13
- Latino: Convertere, Domine; usquequo? et deprecabilis esto super servos tuos.
- Martini: Volgiti a noi, o Signore: e fino a quando (sarai sdegnato)? placati coi servi tuoi. [forme antiche: «coi» per «con i»]
- Rito: Vicino a un'acqua che scorre, anche quella di un rubinetto, leggi «Volgiti a noi, o Signore: e fino a quando (sarai sdegnato)? placati coi servi tuoi». Ripetilo due volte ascoltando il suono dell'acqua. Ascolta prima di parlare. Attingi alla sorgente che hai dentro.
- Da dove viene: Salmo 89,13 della Vulgata, che Lenain (1823) assegna a Damabiah; traduzione di Antonio Martini, Passigli 1842.

### 66, Manakel
- Salmo: 37, 22
- Latino: Ne derelinquas me, Domine Deus meus; ne discesseris a me.
- Martini: Non abbandonarmi, Signore Dio mio, non ti allontanare da me.
- Rito: La sera, quando la giornata si chiude, leggi sottovoce «Non abbandonarmi, Signore Dio mio, non ti allontanare da me». Ripetilo tre volte prima di dormire. Pensa a ciò che hai lasciato indietro. Lascia che le cose vive crescano col loro ritmo, senza forzarle.
- Da dove viene: Salmo 37,22 della Vulgata, che Lenain (1823) assegna a Manakel; traduzione di Antonio Martini, Passigli 1842, dove è il versetto 21.

### 67, Eiael
- Salmo: 36, 4
- Latino: Delectare in Domino, et dabit tibi petitiones cordis tui.
- Martini: Metti la tua consolazione nel Signore, ed ei ti darà quello, che il tuo cuore domanda. [forme antiche: «ei» per «egli»]
- Rito: In un momento di solitudine scelta, in un angolo quieto, leggi «Metti la tua consolazione nel Signore, ed ei ti darà quello, che il tuo cuore domanda». Ripetilo due volte lentamente. Allena lo sguardo: cerca una cosa bella dove di solito passi oltre.
- Da dove viene: Salmo 36,4 della Vulgata, che Lenain (1823) assegna a Eiael; traduzione di Antonio Martini, Passigli 1842.

### 68, Habuhiah
- Salmo: 105, 1
- Latino: Alleluja. Confitemini Domino, quoniam bonus, quoniam in saeculum misericordia ejus.
- Martini: Date lode al Signore, perchè egli è buono, perchè eterna ell'è la sua misericordia. [forme antiche: «perchè» con l'accento grave, «ell'è» per «essa è»]
- Rito: Prima di un gesto generoso, piccolo e concreto, leggi «Date lode al Signore, perchè egli è buono, perchè eterna ell'è la sua misericordia». Ripetilo tre volte, poi dai senza contare e senza aspettarti un ritorno. Lascia che il gesto parli prima delle parole.
- Da dove viene: Salmo 105,1 della Vulgata, che Lenain (1823) assegna a Habuhiah; traduzione di Antonio Martini, Passigli 1842.

### 69, Rochel
- Salmo: 15, 5
- Latino: Dominus pars haereditatis meae, et calicis mei: tu es qui restitues haereditatem meam mihi.
- Martini: Il Signore è la porzione di mio retaggio e del mio calice: tu se' quegli, che a me restituirai la mia eredità. [forme antiche: «se'» per «sei», «retaggio» per «eredità»]
- Rito: Quando cerchi chiarezza su qualcosa che è andato perso, leggi «Il Signore è la porzione di mio retaggio e del mio calice: tu se' quegli, che a me restituirai la mia eredità». Una lettura, poi un respiro lungo. Non avere fretta di giudicare.
- Da dove viene: Salmo 15,5 della Vulgata, che Lenain (1823) assegna a Rochel; traduzione di Antonio Martini, Passigli 1842.

### 70, Iabamiah
- Salmo: nessuno; Genesi 1, 1
- Latino: In principio creavit Deus caelum et terram.
- Martini: Al principio creò Dio il cielo e la terra. [forme antiche: «Al principio» per «In principio»]
- Rito: In un passaggio della vita, quando qualcosa finisce e altro comincia, leggi a voce «Al principio creò Dio il cielo e la terra». Tre volte, con pause lunghe. Guarda la forma che cambia. Resta al tuo lavoro mentre accade: la trasformazione si costruisce giorno per giorno.
- Da dove viene: Genesi 1,1 nella Vulgata, il versetto che la tradizione di Lenain (1823) dà a Iabamiah al posto di un salmo; traduzione di Antonio Martini, Passigli 1842.

### 71, Haiaiel
- Salmo: 108, 30
- Latino: Confitebor Domino nimis in ore meo, et in medio multorum laudabo eum
- Martini: Celebrerò altamente colla mia bocca il Signore: e nella numerosa adunanza a lui darò lode. [forme antiche: «colla» per «con la», «adunanza» per «assemblea»]
- Rito: Quando devi dire no per difendere qualcuno, leggi «Celebrerò altamente colla mia bocca il Signore: e nella numerosa adunanza a lui darò lode». Ripetilo due volte con la mente fredda. Prendi la decisione senza impulso. Non cercare applausi in cambio.
- Da dove viene: Salmo 108,30 della Vulgata, che Lenain (1823) assegna a Haiaiel; traduzione di Antonio Martini, Passigli 1842, dove è il versetto 29.

### 72, Mumiah
- Salmo: 114, 7
- Latino: Convertere, anima mea, in requiem tuam, quia Dominus benefecit tibi
- Martini: Torna, o anima mia, nella tua requie: perocchè il Signore ti ha fatto del bene. [forme antiche: «perocchè» per «perché», «requie» per «riposo»]
- Rito: Alla fine di un lavoro, prima di passare al successivo, leggi «Torna, o anima mia, nella tua requie: perocchè il Signore ti ha fatto del bene». Ripetilo tre volte e chiudi davvero ciò che è finito. Così ricominci senza trascinarti dietro il vecchio.
- Da dove viene: Salmo 114,7 della Vulgata, che Lenain (1823) assegna a Mumiah; traduzione di Antonio Martini, Passigli 1842.
