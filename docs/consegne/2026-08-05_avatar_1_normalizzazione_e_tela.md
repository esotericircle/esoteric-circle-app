# Avatar 1, normalizzazione delle figure e riduzione della tela

Consegna della sessione parallela sul ramo `claude/avatar-1`, partito da
`origin/claude/esoteric-circle-master-order-e798aj` a `5cb1885`.

Deroga scritta applicata: `docs/STATO_VIVO.md` e `docs/ordini/RIPRESA.md` non
sono stati toccati e l'agente `custode-memoria` non e' stato invocato, perche'
su quei due file lavora in parallelo un'altra sessione e l'ultimo che scrive
cancella il lavoro del primo. Nemmeno `pubspec.yaml` e' stato toccato, per la
stessa ragione.

## Il difetto, cos'era davvero

Nello stesso riquadro Medora sembrava piu' piccola degli altri due. Non era
disegnata piu' bassa: attorno alla sua figura c'era piu' aria. Nei sorgenti
nuovi la figura di Medora occupava l'83,8 per cento dell'altezza del file,
quella di Caligo il 96,9.

Sotto ce n'era un secondo, piu' costoso. I tre avatar stavano su una tela di
2056x3060, una grandezza a cui l'app non li disegna mai. Una immagine
decodificata occupa larghezza per altezza per 4 byte in RAM qualunque sia la
compressione del file: i tre tenevano **75,5 MB di memoria su un telefono**.

## Cosa e' stato fatto

Le tre figure sono state ritagliate al contenuto, portate alla stessa altezza e
posate sulla stessa linea, su una tela sola di **1142x1700**. Aura non e' stata
ridisegnata ne' spostata: la sua immagine e' stata solo ridotta, quindi il suo
aspetto non cambia e resta il termine di paragone.

Il comando che lo fa e che si rilancia:

```bash
python tool/normalizza_avatar.py "D:/Clienti Roogly/Rituali Cartomanzia/App/Avatar/Ok Nuovi"
```

## La tela e da dove esce il numero

L'altezza a cui l'app disegna davvero un avatar e' stata **misurata montando le
schermate vere**, non stimata dal codice. Comando:

```bash
flutter test test/nessuno_disegna_oltre_la_tela_test.dart
```

Su 360x797 punti logici a rapporto 3, il telefono di riferimento:

| punto | punti logici | px fisici |
|---|---|---|
| Rivelazione, carta di scelta | 398,0 | 1194 |
| Santuario, busto centrale | 352,6 | 1058 |
| Chat, presenza a vuoto | 280,0 | 840 |
| Dominio, presenza | 250,0 | 750 |
| Santuario, busti laterali | 241,5 | 725 |
| Consulta, busto nella lente | 213,3 | 640 |

Su schermi diversi, perche' il margine fosse misurato e non stimato:

| schermo | Rivelazione | Santuario centrale |
|---|---|---|
| 360x797 r3, riferimento | 1194 | 1058 |
| 360x900 r3, piu' alto | 1194 | 1225 |
| 360x800 r4, piu' fitto | 1592 | 1417 |
| 360x900 r4, il peggiore | 1592 | **1633** |

**Il massimo non e' un tetto, e' una retta.** La carta della Rivelazione ha una
misura fissa, 340 piu' 58 punti, quindi non cresce. Il busto del Santuario invece
cresce con l'altezza dello schermo. Per questo sopra i 1633 misurati resta un
margine del 4 per cento: 1700 copre uno schermo alto fino a 931 punti logici a
rapporto 4, oltre qualunque telefono in circolazione.

La larghezza non e' stata scelta: 1700 per 2056 diviso 3060 fa 1142, cioe' la
stessa proporzione della tela di prima, cosi' nessun riquadro dell'app cambia
larghezza.

## Pesi e memoria, prima e dopo

| avatar | file prima | file dopo | in meno |
|---|---|---|---|
| `assets/avatars_webp/Medora-1.webp` | 618.992 B | 258.182 B | 58,3% |
| `assets/avatars_webp/Aura-1.webp` | 516.876 B | 171.166 B | 66,9% |
| `assets/avatars_webp/Caligo-1.webp` | 584.448 B | 209.934 B | 64,1% |
| `brand_assets/avatars/Medora-1.png` | 6.456.065 B | 2.118.262 B | 67,2% |
| `brand_assets/avatars/Aura-1.png` | 5.156.039 B | 1.467.007 B | 71,5% |
| `brand_assets/avatars/Caligo-1.png` | 5.798.128 B | 1.966.101 B | 66,1% |

Memoria da decodificato, che e' il risultato che conta:

| | per avatar | i tre insieme |
|---|---|---|
| prima, 2056x3060 | 25.165.440 B, 25,17 MB base 1000, 24,00 MiB base 1024 | 75.496.320 B, 75,50 MB, 72,00 MiB |
| dopo, 1142x1700 | 7.765.600 B, 7,77 MB, 7,41 MiB | 23.296.800 B, 23,30 MB, 22,22 MiB |
| risparmio | | 52.199.520 B, **52,20 MB**, 49,78 MiB, il 69,1 per cento |

Geometria finale, identica per tutti e tre: figura alta **1658 px**, cima a
y=21, piedi a y=1679.

## Il ritratto tondo, con un errore mio corretto in corsa

Avevo riferito che il tondo della chat era `MaestroAvatar` con la costante
`Alignment(0, -0.7)`, dicendo che normalizzando le figure quella costante sarebbe
tornata a cadere sul volto da sola. Era sbagliato: **quel widget non era
istanziato da nessuna parte**, ne' in `lib/` ne' in `test/`. E' stato tolto in
questo stesso commit.

Il tondo vero e' `MaestroBust` e inquadra il volto con tre numeri per Maestro,
espressi come frazioni della tela dell'asset. Sono stati rimisurati sulle
immagini nuove, leggendole con una griglia di frazioni sovrapposta:

| Maestro | centerX | headTopY | collarY |
|---|---|---|---|
| Medora | 0,50 | 0,02 | 0,20 |
| Aura | 0,49 | 0,03 | 0,22 |
| Caligo | 0,49 | 0,02 | 0,21 |

Aura non e' cambiata: la sua immagine e' stata scalata in modo uniforme, quindi
ogni sua frazione resta identica. E' la conferma che ridurre era l'operazione
giusta.

Le tre terne sono vicine fra loro, come previsto: scarto 0,01 sulla cima della
testa e sul centro, 0,02 sul colletto. La differenza che resta e' di disegno,
non di inquadratura: Aura porta una corona il cui puntale sale sopra la chioma
degli altri due, quindi la sua cima utile parte piu' in basso.

## Le prove e cosa prende ciascuna

Sei prove nuove, ognuna col rosso eseguito davvero.

| prova | il rosso eseguito | cosa ha detto |
|---|---|---|
| stessa altezza di figura | Medora riscalata al 92% | atteso <= 6, trovato 133 |
| piedi sulla stessa linea | Caligo alzato di 80 px | atteso <= 6, trovato 80 |
| canale alpha conservato | Aura appiattita su un fondo | atteso > 0,1, trovato 0,0 |
| peso dichiarato | Medora risalvata senza perdita | atteso <= 320.000, trovato 987.108 |
| tela dichiarata | Aura riportata a 2056x3060 | atteso <= 1142, trovato 2056 |
| nessuno disegna oltre la tela | tela abbassata a 1500 | atteso <= 1500, trovato 1633 |
| fascia del volto dentro la figura | collarY di Medora a 0,60 | atteso < 850, trovato 1020 |
| fascia del volto dentro la figura | headTopY di Caligo a 0,001 | atteso >= 21, trovato 1,7 |
| terne vicine fra loro | headTopY di Medora a 0,15 | atteso <= 0,05, trovato 0,13 |
| inquadratura dichiarata | tela di Aura cambiata | atteso 1142, trovato 2056 |

## Due cose da sapere sulle prove, dette per intero

**La prova sul contenimento del volto, da sola, NON avrebbe preso il difetto
storico.** Rimettendo le frazioni di prima sugli asset nuovi, tutte le prove
sul volto passano verdi: quelle frazioni cadono ancora dentro la figura. E'
stato verificato eseguendolo, non ragionandoci sopra. Quello che prende il
difetto vero e' la prova sull'**inquadratura dichiarata**: accanto ai
`facePoints` ora sta scritta la tela e la banda della figura su cui sono stati
misurati, con una prova che la confronta con l'asset vero. Chi rigenera un avatar con
un'inquadratura diversa trova rosso.

Il limite che resta, dichiarato: chi cambia l'asset **e** aggiorna quei quattro
numeri di riferimento senza rimisurare i `facePoints` passa comunque. Contro
quello c'e' solo il testo accanto alla costante, che glielo dice.

**Un rosso arrivato per caso non e' una misura.** La prova sulla vicinanza
delle terne aveva soglia 0,04 e cadeva su 0,040000000000000036, cioe' sul
rumore della virgola mobile. La soglia e' stata portata a 0,05, lontano dai
valori veri e il suo rosso e' stato eseguito con uno scostamento vero.

**Una prova che legge quello che hanno lasciato le altre cade per il motivo
sbagliato.** L'asserzione sulla tela stava in una prova finale a parte e
leggeva le misure raccolte dalle altre: filtrandola per nome trovava la mappa
vuota e falliva su quello invece che sulla soglia. E' stata spostata dentro la
misura, cosi' ogni schermata sorveglia se stessa.

## Anteprime, con una regola di casa che avevo mancato

Le anteprime erano nate in un file mio, `test/anteprime_avatar_test.dart`, che
scriveva dritto in `docs/preview`. **Era una seconda porta** e la suite l'ha
presa: `test/corredo_anteprime_test.dart` pretende che verso `docs/preview` ci
sia una porta sola, il corredo in `test/screenshot_capture_test.dart`, perche'
"una regola messa in una porta quando le porte sono due non e' una regola". Il
file mio e' stato tolto e le catture sono state spostate dentro il corredo.

Il corredo produceva gia' il Santuario per ciascun Maestro, le chat, il
dominio: quelle anteprime si rigenerano da sole con gli avatar nuovi. Quello che
mancava, poi aggiunto, sono due catture:

- `avatar-tondo-medora.png`, `avatar-tondo-aura.png`, `avatar-tondo-caligo.png`:
  il tondo di ciascuno, ingrandito per giudicare il volto, con accanto le
  misure vere dell'app, 26, 34, 40 e 48 punti.
- `avatar-confronto-tre.png`: i tre affiancati alla stessa scala sulla riga di
  terra, piu' uno per uno.

Il comando che le rigenera e' quello di sempre, `tool/aggiorna_anteprime.ps1`
su Windows, cioe' il corredo con `AGGIORNA_ANTEPRIME=1`.

**Il tondo si giudica ingrandito, col perche' scritto accanto.** Nell'app
l'anello va da 26 a 48 punti, una misura in cui un volto inquadrato male si
vede appena. L'inquadratura scala linearmente col diametro, quindi l'anello
grande mostra lo stesso taglio, solo leggibile, con accanto le misure
vere per non giudicare una cosa diversa da quella che l'app disegna.

**Un limite dichiarato.** Nelle anteprime di chat il tondo non compare, perche'
l'header lo mostra solo quando c'e' un turno e la cattura parte a chat vuota:
quelle immagini fanno vedere la presenza a figura intera. Il tondo si giudica
sulle tre anteprime dedicate.

L'anteprima della bottom bar e' caduta d'accordo: la striscia disegna
`Icon(maestro.icon)`, non l'avatar, quindi avrebbe mostrato icone e non il
lavoro.

## Secondo giro, 6 agosto 2026: il volto dentro il tondo

Mauro ha guardato i tre tondi affiancati e ha visto due difetti che nessuna
prova prendeva: Aura decentrata a destra, con una fascia di fondo verde vuota a
sinistra, e Caligo con la testa piu' piccola degli altri due. Medora giusta.

**Il metodo del primo giro era sbagliato.** Avevo misurato i `facePoints`
leggendo l'asset con una griglia di frazioni sovrapposta. Su Medora ha
funzionato, sugli altri due no. Il secondo giro misura il RISULTATO: il tondo
viene disegnato davvero, l'immagine catturata, e sui suoi pixel si misura
quanto la testa riempie la corda del cerchio e di quanto e' scentrata. Il fondo
del tondo e' un colore piatto, quindi la figura si separa senza bisogno di
rilevare volti.

| | riempimento prima | dopo | scarto prima | dopo |
|---|---|---|---|---|
| Medora, riferimento | 49,7% | 49,7% | -0,9 | -0,9 |
| Caligo | 43,3% | **48,6%** | +3,5 | **-1,0** |
| Aura | 37,2% | **47,4%** | +5,4 | **-0,1** |

### La domanda su Aura, e la risposta misurata

Delle due ipotesi, o le frazioni erano gia' sbagliate oppure la riduzione aveva
spostato il centro, vale **la prima**. Il centro della figura di Aura nella
fascia del volto misura 0,5003 sull'asset vecchio e 0,4999 su quello nuovo:
quattro decimillesimi, cioe' rumore di ricampionamento. E non poteva essere
altrimenti, perche' una frazione della larghezza resta la stessa frazione sotto
qualunque scalatura orizzontale. Il valore dichiarato era 0,49 in entrambi i
casi: falso da prima, e rimasto tale perche' nessuno aveva mai messo i tre
tondi uno accanto all'altro.

### La misura che mancava, ora c'e'

`test/il_volto_nel_tondo_test.dart` sorveglia le due cose che si vedono a
occhio: il riempimento entro 3 punti da Medora, lo scarto di centratura entro
2,5. Le ragioni delle due soglie stanno accanto ai numeri. Rossi eseguiti:
rimettendo la fascia larga a Caligo il riempimento scende a 43,3 contro 49,7 e
la prova cade; rimettendo 0,49 a centerX di Aura lo scarto sale a 10,1 contro
-0,9 e cade.

### Una prova che chiedeva la cosa sbagliata

`le tre terne sono vicine fra loro` pretendeva che anche i tre `collarY`
stessero vicini. **Quella pretesa era falsa, e ha quasi bloccato la
correzione.** La fascia fra cima della testa e colletto non dice dove sta la
testa, dice quanto e' grande, e le tre teste sono disegnate di taglie diverse:
circa 258 px per Caligo, 238 per Medora, 221 per Aura sulla tela da 1700.
Chiedere fasce vicine significava chiedere teste della stessa taglia. La prova
ora controlla `headTopY` e `centerX`, dove il controllo ha senso, e lascia il
resto alla misura sul risultato.

## Fuori perimetro, visto e non toccato

- `lib/features/tarot/medora_stage.dart:92` dice che i tre ritratti
  d'espressione stanno "nella cartella gia' dichiarata nel pubspec", ma
  `brand_assets/avatars/` non e' dichiarato: quel commento dichiara il falso e
  quei file non entrerebbero nel pacchetto.
- `test/screenshot_capture_test.dart:308` dice 2392 pixel fisici dove 797 punti
  per 3 fanno 2391.
- `brand_assets/santuario/moon.png` non esiste, la cartella contiene solo
  `tempio.png`. Il precache lo dichiara a voce invece di tacere, quindi non e'
  un ripiego muto, ma il riferimento resta rotto.

## Cosa NON e' cambiato

`pubspec.yaml` dichiara la cartella `assets/avatars_webp/`, non i singoli file:
gli stessi nomi significano manifesto intatto. `docs/stato_asset.json` conta 3
file in `brand_assets/avatars` e ne conta ancora 3. Aura non e' stata
ridisegnata. Nessuna riga di codice e' cambiata oltre ai `facePoints`, ai
quattro numeri di riferimento accanto a loro e alla rimozione del widget
orfano.
