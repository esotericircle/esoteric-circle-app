# Ordine GD, parte EF: il Respiro della Luna (GD.23, GD.24) e il cielo in tempo reale (GD.25)

Ramo locale `gd-ef`, partito da `02522987`. 23 ottobre 2026. Nessuna chiamata al
modello, nessuna build, nessun telefono. Gli innesti della Regola A e della Regola B
stanno in `docs/collaudo/GD/regola_a_ef.txt`.

## Le voci in trenta secondi

| Voce | Stato proposto | Prova |
|---|---|---|
| GD.23 | CHIUSA | `test/gd23_il_respiro_col_solo_dito_test.dart` |
| GD.24 | APERTA IN ATTESA DI VERIFICA | `test/gd24_medora_segue_il_respiro_test.dart` |
| GD.25 | CHIUSA | `test/gd25_alza_il_telefono_al_cielo_test.dart` |

---

## GD.23 VIA IL MICROFONO, RESTA IL TIENI PREMUTO

**Stato proposto: CHIUSA** (provata a video nelle prove; resta la cattura sul telefono,
sotto).

DOMANDA: "per il respiro della luna e solo nella funzione «Respira», espira e inspira con il microfono non funziona perché è difficile determinare se l'utente sta inspirando o espirando, elimina il microfono e lascia solo «tieni premuto per inspirare e per espirare». Se l'utente solleva il dito, l'animazione e conteggio si fermano, ma può riprenderlo tenendo premuto. Ma deve essere chiaro per l'utente cosa deve fare ovvero tenere premuto"
PROVA: test/gd23_il_respiro_col_solo_dito_test.dart
MISURA: chiamate al canale del microfono (`com.llfbandit.record/messages`) aprendo il rito e respirando un giro, prima 3 (`create`, `hasPermission`, `startStream`, misurate rimettendo il vecchio avvio) dopo 0; nomi del microfono nel sorgente del Respiro (`BreathDetector`, `breath_detector.dart`, `AppPermission.microphone`, `package:record/`) prima 3 dopo 0; luce della Luna col dito sollevato per 5 secondi, prima 0,79 che saliva a 1,0 dopo resta 0,79 (ferma); giro col dito sollevato per 5 secondi fermo a "Giro 2 di 8, fermo"; col dito premuto un giro intero porta il conteggio da "Giro 1 di 8" a "Giro 2 di 8" senza mai sollevare il dito.

Che cosa e' cambiato in `lib/features/respiro_della_luna/il_respiro_della_luna_screen.dart`:
- tolti il rilevatore del soffio (`BreathDetector`, soglia 0,12, grazia di 700 ms), il suo
  avvio all'apertura, l'avviso del permesso del microfono nel rito e il parametro
  `rilevatore` delle prove;
- il dito guida tutto il rito: finche' resta sulla Luna il respiro va da solo, inspiro e poi
  espiro coi tempi della fase (`TempiDelRespiroDellaLuna`), e il giro si conta in fondo
  all'espiro; sollevato il dito la Luna, Medora e il giro si fermano dove sono (`_luce.stop()`),
  e alla pressione seguente il tratto riprende per il solo tempo che mancava;
- sulla scena, sotto la Luna, dove l'occhio gia' guarda: prima del primo tocco "Tieni premuto
  sulla Luna / per inspirare e per espirare"; col dito "Inspira" o "Espira"; col dito
  sollevato "Tieni premuto per riprendere / Hai sollevato il dito: il respiro è fermo" e
  "Giro N di M, fermo". Il pannello sotto la scena porta il titolo con le parole del
  fondatore, "Tieni premuto per inspirare e per espirare".
- il foglio delle fonti del Respiro (`lib/features/maestri/widgets/foglio_delle_fonti.dart`,
  `TestiDelleFonti.respiroDellaLuna`) diceva che il soffio si riconosceva dal microfono:
  adesso dice che il respiro si guida col dito, senza microfono.

Il resto del Respiro non e' toccato (GB.10, "per ora lasciamo così"): la consultazione della
Luna, il righello, la Collana, gli avvisi, la scena d'apertura restano com'erano.

**Il permesso del microfono nei manifesti resta.** `RECORD_AUDIO` in
`android/app/src/main/AndroidManifest.xml` riga 9 e `NSMicrophoneUsageDescription` in
`ios/Runner/Info.plist` riga 35 servono ancora ad altri: in `lib` il microfono lo usano
`lib/features/rituals/breath_destiny_screen.dart` (Soffio del Destino),
`lib/features/rituals/dream_rite_screen.dart` (Sigillo del Sogno),
`lib/features/maestri/chat/widgets/chat_composer.dart` (dettatura ai Maestri),
`lib/services/voce/l_orecchio_del_live.dart` (LIVE) e
`lib/features/onboarding/maestro_reveal_screen.dart`. La frase di iOS non ha mai nominato il
Respiro della Luna: non c'e' niente da togliere.

PADRE del difetto: ordine FX voce FX.04 (commit `08f4b578`, "il gesto e' doppio": dito e
microfono insieme) e ordine FY voce FY.06 (commit `6c26c958`, il soffio misurato come aria,
`BreathDetector(soloAria: true)`). Il conteggio che si fermava solo al rilascio del dito
(FY, "IL GIRO SI CONTA QUANDO SI LASCIA") e' l'altra meta' del gesto di FX.04.

Guardie nuove: la prova del sorgente legge un file solo (non scopre insiemi); la prova a
video non scopre insiemi.

Prove vecchie adeguate (la regola di prima era "tieni premuto per inspirare, lascia per
espirare"): `test/il_respiro_si_compie_test.dart` (la prova del soffio col microfono finto
misurava un gesto che non esiste piu': al suo posto il dito che si solleva a ogni giro e
riprende fino alla perla), `test/il_respiro_della_luna_test.dart`,
`test/il_giro_della_luna_fy_test.dart`, `test/le_anteprime_dell_ordine_fx_test.dart` (il dito
resta sulla Luna per tutto il rito). Nessuna soglia allentata.

Catture delle prove (dalla prova, `--dart-define=CATTURE=true`, 1080 per 2400 a 3x):
`docs/collaudo/GD/ef/gd23_1_prima_del_gesto.png`,
`docs/collaudo/GD/ef/gd23_2_dito_premuto.png`,
`docs/collaudo/GD/ef/gd23_3_dito_sollevato.png`. Nelle prove il video di Medora non si apre
(nessun lettore vero), quindi la scena e' il cielo fermo.

---

## GD.24 IL VIDEO DI MEDORA SEGUE IL RESPIRO

**Stato proposto: APERTA IN ATTESA DI VERIFICA.** La logica e' provata (posizioni chieste al
lettore); il movimento vero del video sul Realme, la fluidita' dei salti indietro e la
copertura della Luna dipinta si vedono solo sul telefono.

DOMANDA: "eravamo d'accordo se non sbaglio, che il video di Medora doveva andare avanti e indietro seguendo «espira e inspira» e per questo avevamo creato il video apposta con Medora che inspira ed espira"
PROVA: test/gd24_medora_segue_il_respiro_test.dart
MISURA: posizione chiesta al lettore col dito sempre premuto, prima nessuna (il video del rito non esisteva: a scena ferma la scena era il cielo dipinto senza video) dopo 2166 ms a meta' inspiro, 4458 ms in cima all'inspiro (l'ultimo fotogramma del tratto, 107 su 107), 2500 ms a meta' espiro: sale e poi scende. Col dito sollevato, posizioni nuove in tre secondi: 0.

**Il video c'e' gia'.** Cercato sul ramo e nella cartella del fondatore
(`D:\Clienti Roogly\Rituali Cartomanzia\App\Respiro della Luna Scena\`): l'unico video di
Medora che respira e' `medora_il_respiro_della_luna_v1.mp4` (ordine FX, P1: "Medora respira
sulla terrazza e la Luna velata si svela fino a piena"), 8 secondi, 192 fotogrammi a 24 al
secondo, 1080 per 1920. Guardato fotogramma per fotogramma
(montaggio ogni mezzo secondo fra 2 e 5,5 secondi): da 0 a circa 4,5 secondi Medora alza il
viso e prende l'aria (bocca aperta, viso al cielo), da circa 5 secondi abbassa il capo. Nei
testi degli ordini FX e FY nessuna voce chiedeva di farlo andare avanti e indietro col
respiro: FX.02 lo usa come scena d'apertura, una volta per apertura.

**Le scelte, con la ragione.**
- *Il tratto dell'inspiro*, da 0 a 4,5 secondi: avanti sull'inspiro porta Medora al viso
  piu' alto, indietro sull'espiro la riporta giu'. Suonare gli 8 secondi interi in avanti
  sull'inspiro le farebbe abbassare il capo mentre la persona ancora inspira.
- *La posizione, non la velocita'*: su Android `setPlaybackSpeed` arriva circa mezzo secondo
  tardi e un video non si suona all'indietro; la posizione si chiede al fotogramma
  (`seekTo`), e un salto alla volta: se un salto e' in corso si ricorda solo l'ultimo
  fotogramma voluto, e un fotogramma uguale non si richiede
  (`lib/features/respiro_della_luna/medora_che_respira.dart`, `MedoraCheRespira`).
- *Un file suo, tutto a fotogrammi chiave.* Misurato con ffprobe: il video della scena ha un
  solo fotogramma chiave, il primo (1 su 192). Ogni salto indietro costringerebbe a
  ridecodificare dal primo fotogramma, e su Android il salto si aggancia al fotogramma
  chiave (lo dice anche `lib/features/maestri/caligo/viaggio/la_discesa_in_video.dart`):
  tornerebbe sempre all'inizio. Il file del rito,
  `brand_assets/respiro_della_luna/medora_il_respiro_della_luna_inspiro_v1.mp4`, e' lo
  stesso filmato dipinto tagliato ai primi 4,5 secondi dall'originale del fondatore e
  codificato H.264 high, qualita' costante 28, un fotogramma chiave per fotogramma (108 su
  108), senza audio: 6.540.468 byte, SHA-256
  `4a43e8957637fa094ed21b9bf601797a820267b1a240c31f5d3cfadbd13f1499`. Misurate tre
  alternative: qualita' 24 a 1080 (9,6 MB), qualita' 28 a 810 per 1440 (4,2 MB), scelta la
  28 a 1080 perche' la scena d'apertura e' a 1080 e il passaggio dalla scena al rito non
  deve ammorbidirsi. Non serve toccare `pubspec.yaml`: la cartella
  `brand_assets/respiro_della_luna/` e' gia' dichiarata. `docs/stato_asset.json` porta il
  conteggio a 3 con la nota del file.
- *Una sola Luna.* Nel video la Luna dipinta si svela; sopra di lei resta la Luna vera di
  quest'ora (FY.03). Per non vederne due, sul disco dipinto e sul suo alone (1,35 raggi) si
  stende il cielo dipinto senza Luna della stessa scena (`respiro_cielo_senza_luna_v1`),
  allineato al pixel e sfumato verso fuori (`_LaLunaDipintaCoperta`). E' un ritaglio di una
  pittura esistente, nessuna figura disegnata.
- *Quando si apre il lettore*: entrando nella voce Respiro, non all'apertura della
  schermata; con Riduci Movimento o con la grafica alleggerita non si apre e la scena resta
  ferma come prima.
- *Il costo dei salti indietro sul Realme non e' misurato* (niente telefono in questa
  parte): con un fotogramma chiave per fotogramma ogni salto decodifica un solo fotogramma
  1080 per 1920; il ritmo dei salti e' limitato dalla risposta del lettore stesso. Da
  misurare sul telefono con `dumpsys gfxinfo` durante un giro.

Il lettore vero osserva il ciclo di vita (`AppLifecycleListener`, pausa quando l'app va in
fondo): lo pretende la guardia di casa
`test/nessuna_sorgente_resta_accesa_in_sottofondo_test.dart`, che e' caduta sul file nuovo
ed e' tornata verde con la cura.

Cattura dei tre fotogrammi chiesti dalla prova, estratti dal file vero con ffmpeg agli
istanti misurati (2,166 s, 4,458 s, 2,5 s): `docs/collaudo/GD/ef/gd24_i_tre_fotogrammi_chiesti.png`.

PADRE: ordine FX voce FX.02 (commit `08f4b578`): il video fatto per il respiro e' stato
montato come scena d'apertura, una volta per apertura, e a scena ferma il rito mostrava il
cielo senza video. Nessun testo d'ordine aveva chiesto il movimento avanti e indietro.

Guardie nuove: la prova a video non scopre insiemi; la prova del file legge un file solo.

---

## GD.25 "ALZA IL TELEFONO AL CIELO", TRE SECONDI E POI IN DISSOLVENZA

**Stato proposto: CHIUSA** (provata a video nelle due schermate; restano le catture sul
telefono).

DOMANDA: "quando si accede al cielo in tempo reale deve comparire una scritta che scompare dopo 3 secondi in disoolvenza «Alza il telefono al Cielo», questo anche nell'onboarding"
PROVA: test/gd25_alza_il_telefono_al_cielo_test.dart
MISURA: opacita' della scritta dall'ingresso, prima nessuna scritta (0 a ogni istante) dopo 1,0 a 0,5 s, 1,0 a 2 s, 0,5 a 3,5 s (la dissolvenza c'e'), 0,0 a 4 s e fuori dall'albero al fotogramma seguente; uguale nel cielo in tempo reale e nel cielo dell'onboarding. Sorgenti di lib che scrivono la frase: 1 (`lib/features/real_time_cosmo/alza_il_telefono_al_cielo.dart`).

**Un punto solo.** `AlzaIlTelefonoAlCielo` in
`lib/features/real_time_cosmo/alza_il_telefono_al_cielo.dart`: compare in un quarto di
secondo, resta piena fino a tre secondi, sfuma in un secondo e si toglie dall'albero; non
prende tocchi. La monta `CieloRealeScreen`, che e' anche il passaggio dell'onboarding che
mostra il cielo (`RisveglioJourney`, fase `heaven`, `CieloRealeScreen(modo: ritorno,
nascita: widget.details)`): la prova del punto unico controlla anche che l'onboarding passi
ancora da li'.

**Le scelte, con la ragione.**
- Il tempo parte all'ingresso nella schermata, non quando il cielo ha finito di caricarsi:
  "quando si accede".
- Compare nel cielo di adesso e nel cielo dell'onboarding, le due entrate che seguono il
  telefono col sensore. Non compare nel cielo di nascita ne' nella macchina del tempo aperta
  dal cielo di adesso, che partono col dito, e non con Riduci Movimento, che spegne il
  sensore: li' alzare il telefono non muoverebbe niente. La prova del cielo di nascita lo
  misura (nessuna scritta a mezzo secondo).
- L'animazione e' `AnimationBehavior.preserve`: con la scala delle animazioni a zero la
  scritta non sparisce prima di essere letta.

PADRE: nessun difetto, funzione nuova.

Guardie nuove: la prova del punto unico scorre i sorgenti di lib dalla porta comune
(`sorgentiDiLib`) con cardinale minimo 100 (`cardinaleMinimo`); le prove a video non scoprono
insiemi.

---

## Che cosa resta da vedere sul telefono

1. GD.23: aprire il Respiro della Luna, toccare la voce "Respiro" della barra in basso.
   Cattura prima del gesto (sotto la Luna "Tieni premuto sulla Luna / per inspirare e per
   espirare", "Giro 1 di N"); dito premuto sulla Luna per qualche secondo (la Luna si accende,
   "Inspira", poi "Espira", il giro avanza); dito sollevato a meta' (la Luna resta com'e',
   "Tieni premuto per riprendere", "Giro N di M, fermo"); di nuovo premuto (riprende).
   Verificare che il sistema non chieda mai il microfono (con l'app appena installata o col
   permesso tolto dalle impostazioni).
2. GD.24: nello stesso rito, col dito premuto Medora alza il viso sull'inspiro e lo abbassa
   sull'espiro; col dito sollevato resta ferma. Guardare che sulla Luna dipinta del video la
   copertura col cielo dipinto non lasci un bordo e non tagli male le nuvole che passano
   davanti alla Luna fra 1 e 3 secondi del filmato; misurare i fotogrammi persi con
   `dumpsys gfxinfo` durante un giro, soprattutto sull'espiro (salti indietro).
3. GD.25: aprire il cielo in tempo reale; catture a 0,5 s, 2 s e 4 s dall'ingresso (la
   scritta piena, piena, sparita). Lo stesso nell'onboarding alla fase "Guarda il cielo in
   cui sei nato" (macchina del tempo).

## Comandi per il fondatore

Nessuno: nessuna funzione del server, nessuna pubblicazione.

## File toccati

- `lib/features/respiro_della_luna/il_respiro_della_luna_screen.dart`
- `lib/features/respiro_della_luna/medora_che_respira.dart` (nuovo)
- `lib/features/maestri/widgets/foglio_delle_fonti.dart` (il solo testo delle fonti del Respiro)
- `lib/features/real_time_cosmo/alza_il_telefono_al_cielo.dart` (nuovo)
- `lib/features/real_time_cosmo/cielo_reale_screen.dart`
- `brand_assets/respiro_della_luna/medora_il_respiro_della_luna_inspiro_v1.mp4` (nuovo)
- `docs/stato_asset.json` (conteggio e nota del video nuovo)
- `test/gd23_il_respiro_col_solo_dito_test.dart`, `test/gd24_medora_segue_il_respiro_test.dart`,
  `test/gd25_alza_il_telefono_al_cielo_test.dart` (nuovi)
- `test/il_respiro_si_compie_test.dart`, `test/il_respiro_della_luna_test.dart`,
  `test/il_giro_della_luna_fy_test.dart`, `test/le_anteprime_dell_ordine_fx_test.dart` (adeguati)
- `docs/collaudo/GD/regola_a_ef.txt`, `docs/collaudo/GD/ef/*.png`, questo file

Prove della zona fatte girare in locale, tutte verdi: Respiro (19 file, 112 prove), cielo e
onboarding (24 file, 106 prove), GD.25 (4 prove). `flutter analyze` sui file toccati: nessun
problema.
