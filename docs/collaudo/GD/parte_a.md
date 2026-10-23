# Ordine GD, parte A: i video di ingresso ai domini (GD.01, GD.02, GD.03)

Resoconto della parte "a", 23 ottobre 2026. Ramo locale `gd-a`, partito da
`02522987` (testa verificata con `git log --oneline -1`). Nessuna chiamata a
pagamento, nessuna build, nessun telefono.

| Voce | Stato proposto | Prova |
|---|---|---|
| GD.01 | CHIUSA (a video nelle prove), da guardare sul telefono | `test/gd_il_dono_nel_palmo_test.dart`, `docs/collaudo/GD/catture/gd01_medora_dominio_cancro.png` |
| GD.02 | CHIUSA (a video nelle prove), da guardare sul telefono | `test/gd_il_dono_nel_palmo_test.dart`, `docs/collaudo/GD/catture/gd02_caligo_dominio_sera_1.png` |
| GD.03 | APERTA, ripiego dichiarato dall'ordine | `lib/core/maestro/chakra_del_giorno.dart` (il dato c'e'), nessun simbolo dipinto dei chakra nel ramo |

## GD.01, il segno zodiacale nel palmo di Medora

**Stato proposto: CHIUSA** (provata a video nelle prove headless sul
fotogramma dipinto vero; resta la cattura sul telefono, vedi sotto).

DOMANDA: "nei video di ingresso ai domini mancano le personalizzazioni promesse: Medora alla fine mostra la mano aperta e dovrebbe comparire il segno zodiacale dell'utente, ma non compare"
PROVA: test/gd_il_dono_nel_palmo_test.dart
MISURA: simboli nel palmo di Medora a scena ferma, prima 0 e dopo 1; due persone di segno diverso (nate il 5 luglio e il 5 aprile 1990) vedono prima 0 simboli e dopo 2 simboli diversi (`zod_cancro.webp`, `zod_ariete.webp`); centro del segno riportato nei pixel del fotogramma 1080 per 1920 dentro la mano tesa (x 180-310, y 850-1000); opacita' del segno a video in corso 0, a video finito, saltato, fallito o con Riduci Movimento 1.

Cosa e' stato fatto:
- `lib/features/maestri/il_dono_nel_palmo.dart` (nuovo): `IlDonoNelPalmo`
  tiene il punto del palmo misurato sul fotogramma e il conto `BoxFit.cover`
  per riportarlo sullo schermo; `IlDonoSulPalmo` sceglie l'arte e la posa.
- Il segno e' l'**emblema dipinto** gia' nel ramo, `ZodiacArt.emblemPath`
  (`assets/img/zodiac/zod_<segno>.webp`, dodici file, 721 per 820 con
  canale alfa): nessun pezzo nuovo, nessun disegno (R8).
- Il segno della persona viene da `ProfileController.identity.sunSign`
  (`BirthIdentity.sunSign`, che discende dalla data e vale nullo coi dati
  d'esempio), e in sua vece da `BirthIdentityController.sunSign`, la stessa
  fonte dell'avatar dell'utente. Senza data di nascita il palmo resta vuoto:
  non si inventa un segno.
- Montato in `lib/features/maestri/domain_screen.dart` sopra il video e
  dentro lo stesso `Transform.translate` del fotogramma (lo spostamento
  verso l'alto dell'ordine FW), avvolto in `IlRestoDopoLaScena`: non c'e'
  mentre il video gira, entra in dissolvenza (450 ms, la durata comune)
  quando il video finisce o lo si salta, e' pieno subito quando la scena e'
  ferma dalla prima immagine (Riduci Movimento, grafica alleggerita, video
  che non si carica).

**Come e' stato misurato il palmo.** Sul fermo
`assets/img/maestri_scena/medora_dominio_ultimo_fotogramma_v1.webp`
(1080 per 1920, la stessa misura del video, letta con ffprobe) ritagliato e
ingrandito tre volte con un righello a passo venti pixel sovrapposto: la mano
tesa va da x 160 (punta delle dita) a x 320 (polso), il palmo aperto fra y
970 e y 1060. Il segno si posa appena sopra il palmo, nella scia di polvere
d'oro: centro x 245, y 915, largo 140 pixel. Le costanti stanno in
`IlDonoNelPalmo.palmoDiMedora` col commento del come.

PADRE del difetto: la personalizzazione "promessa" non compare in nessun
documento del ramo ne' della cartella del fondatore (cercato `palmo`, `mano
aperta`, `mano tesa` in `docs/ordini`, `docs/*.md`, `tool/` e in tutti i `.md`
di `D:\Clienti Roogly\Rituali Cartomanzia\App`: nessuna riga prima
dell'ordine GD). La scena senza dono e' nata con l'ordine FW voce FW.03
(commit `09948086`), che ha messo il video del dominio senza nessuna
sovrapposizione: la promessa, se c'e' stata, non ha lasciato traccia scritta.
**PROVENIENZA IGNOTA** per la promessa; la scena vuota e' di FW.03.

## GD.02, i due video di Caligo si scambiano, e nella mano la runa del tramonto

**Stato proposto: CHIUSA** (provata a video nelle prove; catture sul
telefono da prendere).

DOMANDA: "Per Caligo bisogna scambiare il video introduttivo della chat con quello del dominio e nella sua mano aperta dovrebbe comparire la runa del tramonto del giorno, se non sbaglio"
PROVA: test/gd_il_dono_nel_palmo_test.dart
MISURA: impronta del video del dominio prima `05b6636e...` (il vortice) e dopo `5965a25b...` (il cerchio di fuoco), del video della chat prima `5965a25b...` e dopo `05b6636e...`; ultimo fotogramma del dominio prima `83e10a5f...` e dopo `8c87b79a...`; scarto fra l'ultimo fotogramma del video e il suo fermo, dominio 12,18 (contro 18,96 col fermo sbagliato), chat 9,62 (contro 18,69); rune nel palmo di Caligo prima 0 e dopo 1, quella di `SunsetRune.estrai` per quel giorno; due sere diverse per la stessa persona danno prima 0 e dopo 2 pietre diverse; centro della pietra nei pixel del fotogramma dentro il vuoto dell'anello (x 760-865, y 820-1040).

Cosa e' stato fatto:
- **Lo scambio dei file**, con `git mv`: `brand_assets/maestri_scena/
  caligo_dominio_v1.mp4` e `caligo_chat_v1.mp4` si sono scambiati il nome,
  e cosi' i due `caligo_*_ultimo_fotogramma_v1.webp`. I due primi
  fotogrammi di Caligo sono lo stesso file byte per byte (impronta
  `378fd93e...` per entrambi), quindi non c'era niente da scambiare. Il nome
  nel ramo continua a dire il posto nell'app, la regola di FW.01:
  `LaScenaDelMaestro` non cambia nel codice, solo nel commento.
- Le impronte in `test/ogni_video_dei_maestri_e_nel_suo_posto_test.dart`
  si sono scambiate di posto insieme ai file, col perche' nel commento.
- `tool/gli_asset_dell_ordine_fw.py`: le due righe di Caligo tornano al
  posto della loro cartella, cosi' rieseguire lo script non disfa la GD.02.
- **La runa del tramonto** nel palmo e' la pietra dipinta della famiglia
  `rune_bone` (`Rune.fullPath`, 24 file), scelta da `SunsetRune.estrai`,
  la stessa estrazione della schermata del rituale, con la stessa identita'
  (`SunsetRuneScreen._prepara`): la nascita dal `ProfileController` quando
  non e' d'esempio, con l'ora se nota, altrimenti l'id del dispositivo
  (`DeviceId.corrente`). Il giorno e' il giorno rituale, col confine a
  mezzogiorno: alle nove del mattino la pietra e' ancora quella della sera
  prima, come nel rituale. Il verso d'ombra si mostra capovolto, come nel
  rituale (`Transform.rotate` di mezzo giro sulla pietra dipinta).
- Stesso montaggio della GD.01, stesse regole di comparsa.

**Come e' stato misurato il palmo.** Sul fermo della scena col cerchio di
fuoco verde (oggi `caligo_dominio_ultimo_fotogramma_v1.webp`), ritaglio
ingrandito due volte col righello: la mano aperta e' in basso a y 1100,
l'anello di fuoco le sta sopra e il suo vuoto va da x 745 a x 880 e da y 800
a y 1060. La pietra sta al centro del vuoto, x 812 e y 935, larga 112
pixel: e' la scena che il sorgente stesso chiama "la runa della sera"
(`caligo_la_runa_della_sera_v1.mp4` nella cartella "Caligo Dominio Scena").

PADRE del difetto: lo scambio dei video l'aveva fatto l'ordine FW voce FW.05
(commit `09948086`, 15 ottobre 2026), per parola del fondatore di allora;
la GD.02 lo riporta indietro, cioe' ogni video torna al posto della sua
cartella d'origine. La runa mai comparsa nel palmo: stessa origine della
GD.01, FW.03 senza sovrapposizioni, promessa **PROVENIENZA IGNOTA**.

**Attenzione per la build: lo scambio e' una rinomina.** `git mv` lascia ai
quattro file la data di prima, e un pacchetto degli asset gia' costruito
(`build/`) puo' non accorgersi che sotto lo stesso nome c'e' un altro
contenuto: e' successo qui, la prima cattura mostrava ancora il vortice. Sul
mio albero ho fatto `touch` dei quattro file; su un altro albero (la build
della sessione principale) la cosa sicura e' una build pulita, oppure
`touch` di `brand_assets/maestri_scena/caligo_*_v1.mp4` e
`assets/img/maestri_scena/caligo_*_ultimo_fotogramma_v1.webp` prima di
costruire. La prova adesso legge i byte dal pacchetto (`rootBundle`) e cade
se il pacchetto e' vecchio.

Catture (prove headless, `--dart-define=CATTURE=si`, fotogrammi e arti
veri): `docs/collaudo/GD/catture/gd01_medora_dominio_cancro.png` e
`gd01_medora_dominio_ariete.png` (granchio e ariete sopra la mano tesa),
`gd02_caligo_dominio_sera_1.png` e `gd02_caligo_dominio_sera_2.png` (due
pietre diverse dentro l'anello di fuoco), `gd03_aura_dominio_ferma.png`
(palmo vuoto). La cattura della chat di Caligo va presa sul telefono; il
legame del video alla chat e' provato dalle impronte.

**Da sapere, e va guardato dal fondatore.** Il video che dopo lo scambio apre
la chat (il vortice) finisce con una runa gia' dipinta nel fuoco della mano
di Caligo: e' Dagaz, fissa, la stessa per tutti e tutti i giorni (si vede in
`assets/img/maestri_scena/caligo_chat_ultimo_fotogramma_v1.webp`). Non e' la
runa del tramonto e non l'ho toccata: e' dentro il video. Se il fondatore
legge "la sua mano aperta" come quella scena, la cura e' un video nuovo senza
la runa dipinta (che genera lui), non un ritocco in codice.

**Una scelta da dichiarare.** Mostrare la runa nel dominio la anticipa prima
che la persona la getti nel rituale della sera: la richiesta del fondatore e'
esplicita, quindi l'ho eseguita; se si preferisse non anticipare, basta
mostrarla solo dopo che il rituale del giorno e' stato fatto
(`SunsetRuneMemory.settimanaCorrente` sa se la sera c'e').

## GD.03, il simbolo nel palmo di Aura

**Stato proposto: APERTA**, ripiego dichiarato dall'ordine ("se il chakra del
giorno non esiste come dato vero nel codice, Code lo scrive nel rapporto e
non lo inventa"), qui per la meta' grafica.

DOMANDA: "Aura non ricordo, proponi tu"
PROVA: lib/core/maestro/chakra_del_giorno.dart
MISURA: chakra del giorno come dato: presente (`ChakraDelGiorno.di`, sette chakra uno per giorno della settimana, usato da `ColoreDelCentro`, `FrequenzaDelGiorno`, `CioCheAuraRicorda`); simboli dipinti dei sette chakra nel ramo: 0 (prima 0, dopo 0); simboli nel palmo di Aura: prima 0, dopo 0.

Cosa ho cercato:
- il dato: `grep -rn -i "chakraDelGiorno\|chakra del giorno\|centro di oggi"
  lib` trova `lib/core/maestro/chakra_del_giorno.dart`. **Il dato esiste ed
  e' vero**: `ChakraDelGiorno.di(giorno)` da' il chakra del giorno della
  settimana (lunedi' Muladhara, domenica Sahasrara), dichiarato in testa al
  file come curatela contemporanea. Non dipende dalla persona: e' lo stesso
  per tutti nello stesso giorno, quindi "il chakra del giorno dell'utente" e'
  il chakra del suo giorno, non un dato suo.
- il simbolo: `find assets brand_assets -iname "*chakra*" -o -iname
  "*muladhara*" -o -iname "*anahata*" -o -iname "*sahasrara*"` trova solo
  i tre sfondi della scheda `assets/schede/Scan-Chakra-*.webp` (lo sfondo
  della carta dell'arte, non sette simboli); `git log --all` non ha mai
  aggiunto altri file con quei nomi; nella cartella del fondatore
  `D:\Clienti Roogly\Rituali Cartomanzia\App` nessun file coi nomi dei
  chakra.
- Disegnare i sette simboli in codice violerebbe R8. **Il palmo di Aura resta
  vuoto** e la prova `aura: nessun simbolo nel palmo` lo dice; cadra' il
  giorno in cui le arti arriveranno, ed e' voluto.

Cosa serve per chiuderla (la riga del fondatore):
- sette simboli dipinti dei chakra, uno per centro, PNG o WebP con canale
  alfa, nello stile delle altre famiglie (metallo inciso, cornice oro), con
  il centro luminoso pensato per stare dentro il loto (il loto e' chiaro:
  il simbolo deve leggersi su un fondo giallo verde molto luminoso);
- nome dei file, per esempio `assets/img/chakra/chakra_1_muladhara_v1.webp`
  fino a `chakra_7_sahasrara_v1.webp`, e la riga nel pubspec
  `- assets/img/chakra/`.
- Il punto del loto e' gia' misurato sul fermo
  `aura_dominio_ultimo_fotogramma_v1.webp` (stesso righello, ingrandito tre
  volte): il loto va da x 460 a x 600 e da y 975 a y 1075, il cuore
  luminoso e' a x 530, y 1015; un simbolo largo 90 pixel ci sta dentro. Con
  le arti il lavoro e' una riga in `IlDonoNelPalmo.palmoDi` e un caso in
  `IlDonoSulPalmo`.

PADRE: PROVENIENZA IGNOTA (nessun ordine ha mai chiesto le arti dei chakra).

## Cosa resta da vedere sul telefono

Il collaudo lo fa la sessione principale sul Realme, con dati di collaudo:
1. **Dominio di Medora**: Santuario, tocco su Medora. Cattura a video finito
   (otto secondi) e una seconda dopo averlo saltato con un tocco: il segno
   della persona di collaudo compare sopra il palmo aperto in dissolvenza,
   mai durante il video. Ripetere con una seconda identita' di segno diverso
   (Passport, dati di nascita di collaudo).
2. **Dominio di Caligo**: il video adesso e' quello del cerchio di fuoco col
   palmo aperto; a video finito la pietra della runa del tramonto e' dentro
   l'anello. Confronto: aprire la Runa del Tramonto e verificare che la
   pietra gettata sia la stessa (dopo mezzogiorno; prima di mezzogiorno e'
   quella della sera prima).
3. **Chat di Caligo vuota** (nuova conversazione): il video adesso e' il
   vortice, che finisce con Dagaz dipinta (vedi la nota sopra).
4. **Riduci Movimento acceso** (Impostazioni del telefono): i due domini
   mostrano subito il fermo col dono gia' nel palmo.
5. **Dominio di Aura**: nessun cambiamento.
Da guardare con l'occhio: la misura del dono sul telefono (140 e 112 pixel
del fotogramma, circa 58 e 46 punti su uno schermo da 797), e che il segno di
Medora non stia troppo alto sopra la mano.

## Le guardie nuove

- `test/gd_il_dono_nel_palmo_test.dart`: diciassette prove, nessuna scorre un
  insieme di file scoperto a esecuzione (lavora su due identita', due sere e
  tre Maestri dichiarati per nome), quindi niente porta comune ne' cardinale.
  Viste rosse con dodici innesti, uno per fatto misurato
  (`docs/collaudo/GD/regola_a_a.txt`).
- `test/ogni_video_dei_maestri_e_nel_suo_posto_test.dart`: non e' nuova, ha
  le due impronte di Caligo scambiate; vista rossa prima di toccarla (Regola
  B, stesso file).

## Asset e pubspec

Nessun asset nuovo, nessuna riga nuova nel pubspec: gli emblemi dello
zodiaco (`assets/img/zodiac/`), le pietre delle rune (`assets/img/rune_bone/`)
e le cartelle delle scene (`assets/img/maestri_scena/`,
`brand_assets/maestri_scena/`) sono gia' registrati. Per la GD.03 servira'
`- assets/img/chakra/` quando arriveranno le arti.

## Comandi per il fondatore

Nessuno: niente funzioni del server in questa parte.
