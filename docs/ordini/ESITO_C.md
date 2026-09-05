# ESITO dell'ORDINE C, gli angeli entrano in scena

## Dichiarazione, scritta prima di toccare il codice

**Chiudo C1, C2 e C3. Su C4 e C5 non prometto**, quindi le lascio per ultime
come
l'ordine stesso dispone.

La ragione in numeri. C1 e' un lavoro di modellazione su un file regolare:
settantadue schede con la stessa struttura, cinque campi in elenco e cinque
paragrafi titolati ciascuna, quindi si genera con uno script come e' stato fatto
per gli undicimila luoghi: il rischio sta tutto nel filtro dei termini
vietati, verificabile con un test. C2 e' una tessera sola in un file
solo. C3 e' un widget di nota su una schermata nuova.

C4 tocca invece la catena di build di Gradle, dove ogni giro di prova costa fra
i tre e i cinque minuti e l'esito si vede solo aprendo l'archivio: se la
dichiarazione degli ABI non filtra i plugin al primo colpo, si entra in una
serie di tentativi che non ho modo di chiudere con certezza. C5 dipende da C4:
un guardiano che nessuno ha visto fallire su un caso vero non serve.

## C1, il corpus arriva nelle carte: FATTO

`tool/genera_angeli.py` legge le settantadue schede del Corpus e produce
`lib/core/angels/angel_lore.dart`, che il catalogo espone su ogni angelo.

La politica di pubblicazione e' applicata **alla sorgente**, non a valle: cio'
che non si pubblica non entra nel file generato, quindi non puo' arrivare a
schermo per distrazione. Una frase che contiene un termine vietato viene tolta
INTERA invece che ripulita, perche' correggerla a macchina vorrebbe dire
riscrivere una fonte. Numeri della generazione: **72 angeli letti, 19 frasi
tolte, 0 angeli senza salmo, 0 senza arco, 0 senza segno**.

Ogni carta mostra ora l'arco di gradi col segno, il salmo con la sua
numerazione, il dominio secondo la tradizione, piu' la chiave di lettura sotto
l'etichetta "Medora la legge cosi'", staccata da cio' che viene dalle fonti come
la politica prescrive. Dove la confidenza dichiarata e' bassa il dominio non si
mostra. La riga che annunciava lo strato mancante e' sparita.

**Sedici nomi divergevano** fra il catalogo, che li prendeva dagli stem delle
immagini, contro il Corpus: Ieliel per Jeliel, Cahethel per Cahetel, Ieiaiel
contro Yeiayel. Sono varianti della stessa tradizione, ma la fonte verificata
e'
il Corpus: ora il nome mostrato viene da li', mentre lo stem del file resta
quello che e'. Il numero 17, che nel Corpus si chiama Lauviah come l'undici,
riceve il numerale per non mostrare due voci identiche.

## C2, tre miniature nella tessera: FATTO E VERIFICATO A VIDEO

La tessera ora dispone i tre angeli in tre colonne, ognuno col suo nome sotto il
proprio volto. Il test conta le miniature **dentro la tessera**, non nella
schermata dedicata: la misura si prende dove sta la promessa.

Il test da solo pero' non bastava, ed e' questa la parte da raccontare.
Con il layout gia' corretto e il test verde, l'anteprima mostrava ancora **un
volto su tre**: i widget c'erano tutti, ma nella cattura headless le altre due
immagini non erano decodificate al momento dello scatto. La causa era la
cattura, non la tessera, ma nessun test l'avrebbe detto: si e' vista
guardando. Aggiunto il precache
delle arti degli angeli prima dello scatto, l'anteprima mostra i tre volti:
Lauviah II, Ieiaiel e Cahethel, ciascuno con la sua arte.

## C3, fonti e metodo: FATTO

Punto interrogativo discreto nella barra della schermata, con la sua chiave, che
apre un foglio con le tre cose prescritte e nient'altro. La terza e' quella
scomoda: le fonti sono repertori che dichiarano di derivare da Lenain e da
Ambelain, mentre le tavole originali non sono state consultate in edizione
primaria.
Il test verifica che quella frase ci sia, non solo che il foglio si apra.

## C4 e C5: NON FATTI

Come dichiarato all'inizio. L'APK porta ancora le librerie native di ML Kit per
x86_64 e armeabi-v7a, mentre `verifica_apk.py` guarda ancora le sole otto
famiglie di asset. Non ho aperto la strada del Gradle: l'ordine dice di lasciarla se non e'
banale. Non avendola provata, resto senza modo di dirlo. E' l'unica voce di
questo ordine su cui non porto un numero.

## Consegna

Release **0.1.0 (2100)** a `cloud@esotericircle.app`:
`https://appdistribution.firebase.google.com/testerapps/1:425821975933:android:1b1ca4db8d4df69b940814/releases/6saif8nss71fg`

## Criteri, uno per uno

- Settantadue angeli modellati che leggono dal Corpus: **passa**, il test conta
  72 su 72.
- Sette campi su dodici angeli, uno per coro piu' tre: **passa**. Verificati
  nome, numero, coro, arcangelo, arco, segno e salmo, col controllo aggiuntivo
  che il salmo dichiari la propria numerazione.
- Zero termini vietati nei testi mostrati: **passa**, su 72 angeli per sei campi
  ciascuno, con l'elenco dei termini esposto in testa al test.
- Tre miniature distinte nella tessera: **passa**, contate nella tessera, piu'
  la conferma a video.
- Nota Fonti e metodo con la frase sulle edizioni primarie: **passa**.
- APK senza librerie native di altri ABI: **non fatto**, vedi C4.
- Peso non oltre 1 MiB in piu' della build precedente: **passa**. Da
  270.966.056 a 271.008.067 byte, cioe' **piu' 42.011 byte, 0,04 MiB**. Nessun
  asset nuovo da dichiarare: il Corpus modellato vive nel codice, non fra gli
  asset.
- Suite verde, analyze pulito, integrita' verde, versione non inferiore a 2100:
  **passano**. 820 test verdi, erano 813.
