# RAPPORTO DELL'ORDINE FG, REAL TIME COSMO, PRIMA PIETRA

**Il cielo vero e' nel menu utente, alla voce Real Time Cosmo, con le tre prove separate: il cielo di adesso, il cielo della tua nascita, il ritorno indietro nel tempo.** Le stelle sono le 5.070 del catalogo HYG fino alla sesta magnitudine, il Sole, la Luna e i pianeti vengono da Meeus, i dodici veli dorati si posano sulle costellazioni dello zodiaco con la loro parallasse, e il ritorno fa girare il cielo all'indietro fino al tuo istante usando solo istanti veri. Per vederlo sul telefono serve una build, che ordini tu: la stessa build mi serve per le quattro misure di prestazione della 7.7, l'unica parte che resta aperta.

Ramo `claude/esoteric-circle-master-order-e798aj`, partenza `2a7b6864`, 8 ottobre 2026. Testo dell'ordine: `docs/ordini/ORDINE_FG_TESTO.md` (seconda stesura e aggiunta). Specifica: `docs/Specifica_Real_Time_Cosmo.md`. Anteprime: `docs/preview/FG/`. Prima e dopo: `docs/collaudo/FG/prima_dopo/`. Prove di vista: `docs/collaudo/FG/prove_di_vista.txt`.

## LE PREMESSE

Prima stesura: tre premesse false su undici (P2 effemeridi.dart cancellato, P4 drawAtlas gia' chiamato, P11 il Cielo esistente ha gia' un catalogo vero), fermata senza toccare il codice. Seconda stesura: P1-P11 vere sulla testa `2a7b6864`; P12 falsa sul primo estratto (mancava la 4-bis), vera sull'estratto v2 dopo l'aggiunta A1 (26.001 byte, sezioni 1-bis, 1-ter, 4, 4-bis, 5, 6, 14). Una precisazione: sensors_plus nel pubspec e' `^6.1.1`, nel lock e' 6.1.2.

## PARTE 0, I FILE DA FUORI DEL RAMO (commit `2aa1a9c4`)

MISURA: dodici veli (2.596.266 byte), la specifica v2, la clip e il mosaico di OSR Star Finder, tutti confrontati al byte con gli originali: 15 file su 15 identici. L'avvertenza sul "bel disegno" e' in testa alla specifica.
IMMAGINI: nessuna, la parte non ha schermo.
ACCETTAZIONE: nessuna verifica sul telefono; la specifica la leggi in `docs/Specifica_Real_Time_Cosmo.md`.

## PARTE 1, IL CATALOGO DELLE STELLE (commit `6325af8e`, `055a83c7`)

MISURA, sul CSV scaricato oggi (impronta sha256 nel generatore): 119.626 righe come dichiarato; al taglio 6,0 le righe sono 5.071 come ha misurato l'Architetto, ma una e' il Sole, che non entra perche' lo calcola Meeus: **5.070 stelle, scarto 1**. Binario 60.864 byte (24 di intestazione e 5.070 per 12; l'ordine stimava 60.852 sulle 5.071). Nomi propri: 465 sul catalogo intero, **347 dopo il taglio**. 23 stelle senza indice di colore, col valore -32768. In HYG l'ascensione retta e' in ore: convertita in gradi. Il generatore `tool/il_catalogo_delle_stelle_hyg.py` con `--verifica` rifa' i quattro file identici al byte; il CSV non e' nel repository. Licenza CC BY-SA 4.0 verificata sul file LICENSE di astronexus; il file derivato porta `LICENZA_HYG_v41.txt` accanto.
**Una deviazione dichiarata**: il record da dodici byte e' quello della 1.4, ma la costellazione e le sigle di Bayer e Flamsteed (che la 1.1 chiede e che servono al velo e alla scheda del tocco) vivono in un terzo file, `stelle_hyg_v41_costellazioni.json` (88 costellazioni, 2.715 sigle).
IMMAGINI: nessuna, la parte non ha schermo.
ACCETTAZIONE: tocca una stella brillante nel cielo: la scheda ne dice il nome, la sigla, la costellazione in italiano e la magnitudine. L'attribuzione ad astronexus e' nell'icona (i) in alto a destra, Fonti e metodo.

## PARTI 2, 4 E 5, IL CIELO NAVIGABILE, IL VELO E LA PARALLASSE (commit `25f193c8`)

MISURA:
- **Densita' a 70 gradi** su 360x797, tre inquadrature (Roma, 8 ottobre 2026 alle 22): sud a 40 gradi **191**, est a 30 gradi **194**, nord a 60 gradi **211** punti luminosi (bersaglio 158-218). Il primo limite provato (4,15 al campo largo) dava 145, 149, 151 ed e' stato bocciato; con 4,55 il limite a 70 gradi e' 5,08.
- **Una sola chiamata** di disegno per le stelle a fotogramma (misurata a schermo: 1). E' `drawRawAtlas`, la forma grezza della stessa chiamata della spirale dei sigilli: la spirale crea a ogni fotogramma le liste di RSTransform e ha i colori dentro l'immagine; qui le stelle sono cinquemila, ognuna col suo colore, e il fotogramma non deve creare liste. Il modo e' lo stesso, la forma cambia per questa ragione.
- **Campo** 70 gradi, pizzico da 18 a 100; filtro del movimento con costante di tempo lineare da 0,08 s a 100 gradi a 0,45 s a 18.
- **L'orientamento**: sensors_plus non espone il vettore di rotazione (il plugin Android registra solo accelerometro, giroscopio, campo magnetico e pressione; su iOS il magnetometro e' grezzo). Senza aggiungere dipendenze, l'orientamento si ricava da gravita' e bussola come fa Android con getRotationMatrix; la gravita' passa dalla porta unica dell'accelerometro (ParallaxController). Declinazione magnetica dal **World Magnetic Model 2025** della NOAA: scarto peggiore **0,005 gradi** sui cento punti di prova ufficiali. Il ripiego col dito resta sempre, anche col sensore acceso.
- **La latitudine dei pianeti**: IlCieloDiMeeus la calcolava ma non la dava fuori (solo la Luna); ora la porta la espone, provata sull'esempio 33.a di Meeus (Venere, -2,08474 gradi). Senza, Plutone avrebbe sbagliato fino a 17 gradi.
- **Il velo**: principali da 5 a 12 fino alla magnitudine 4,5; scala 1,25 volte la media geometrica del riquadro; centro nel baricentro pesato 10^(-0,4 m); dissolvenza 400 ms; il tuo segno al 100 per cento e gli altri a 1/1,2, cioe' il tuo piu' presente del venti per cento; alone a 26 punti al 40 per cento cotto una volta.
- **La parallasse**: 3 punti di cielo contro 26 di velo sull'inclinazione del telefono, verticale al 35 per cento; profondita' di campo a 3,2 punti con maschera dall'alfa del velo sfocata a 40 e al 70 per cento, cotta quando un velo entra o esce (misurato: al piu' 2 cotture in 15 fotogrammi).
IMMAGINI: prima `parte2_cielo_di_adesso_prima_il_cielo_esistente.png` (il Cielo di oggi), dopo `parte2_cielo_di_adesso_dopo.png` e `parti4_5_i_veli_dopo.png`, in `docs/collaudo/FG/prima_dopo/`.
ACCETTAZIONE: menu utente, Real Time Cosmo, Il cielo di adesso. Alza il telefono verso la Luna o verso sud: le stelle stanno dove le vedi in cielo, i veli dorati compaiono sulle costellazioni e scivolano piu' delle stelle quando inclini il telefono; la freccia d'oro sul bordo dice "Il tuo Toro" (il tuo segno) e i gradi che scendono mentre ti giri, e sparisce quando il segno entra in quadro. Allarga e stringi con due dita. Se il nord ti sembra sbagliato, punta la Luna al centro e tocca la riga in basso.

## PARTE 3, IL CIELO DI NASCITA E IL RITORNO (commit `6073c6c7`, schermata in `dd37e5c4`)

MISURA: tetto dichiarato prima di scrivere la scena, **24 istanti calcolati al secondo per 7 secondi, 168 istanti**, con interpolazione a ogni fotogramma. **Ogni istante calcolato e' un istante vero del cielo**: riavvolgere trent'anni alla lettera in pochi secondi darebbe undicimila giri e trecentosettanta lunazioni, che a 24 campioni al secondo diventano rumore; per questo ogni istante si sceglie fra i giorni vicini alla data che scorre, nel momento in cui il cielo ha la rotazione voluta e la Luna la fase piu' vicina a quella voluta. Sulla nascita di prova: tempo siderale entro 0,0005 gradi, fase della Luna entro 6,84 gradi, data entro 14,9 giorni, mai prima della nascita; piano preparato in 429 ms nella prova. **Ipotesi cadute, dichiarate**: lo scarto di 93 gradi della prima stesura non veniva dal confine della nascita, come avevo creduto (misurato con e senza: uguale), ma da una mia funzione che ripiegava in due l'angolo di fase; e il quadrato attorno alla Luna non veniva dall'alone tagliato a quattro raggi, ma a dieci (l'alone di LunaReale arriva a 4,6 raggi).
Il cielo di nascita e' lo stesso motore con l'istante e il luogo dal profilo. Senza ora: "Senza l'ora di nascita posso portarti al giorno, non all'istante" e il pulsante Aggiungi l'ora. Riduci Movimento: passaggio secco. La Luna mostrata e' sempre quella dell'istante: nella scheda si chiama "La Luna della tua nascita" o "La Luna di stanotte".
IMMAGINI: prima `parte3_cielo_della_nascita_prima_il_cielo_esistente.png`, dopo `parte3_cielo_della_nascita_dopo.png` e `parte3_il_ritorno_dopo.png`; la corsa intera in `docs/preview/FG/fg_05`, `fg_06`, `fg_07`.
ACCETTAZIONE: menu utente, Real Time Cosmo, Il ritorno indietro nel tempo. Al centro compare la tua eta', poi "STO TORNANDO INDIETRO NEL TEMPO" mentre il numero scende accelerando e il cielo gira all'indietro, la Luna cambia fase, i pianeti si spostano; poi "QUESTO ERA IL CIELO SOPRA DI TE ALLA TUA NASCITA" e la frase della Luna di quel giorno. "Rivedi il ritorno" lo rifa'. Nell'anteprima, per una nascita a Napoli il 14 maggio 1988 alle 8:40, il Sole sta fra Ariete e Toro, Giove nell'Ariete e la Luna e' una falce sottilissima: la Luna nuova era il giorno dopo.
**I testi della scena sono di Mauro** (specifica, 1-bis). Ho reso neutra la frase d'arrivo, "alla tua nascita" invece di "quando sei nato", perche' il genere della persona non entra in questo ordine: se vuoi la frase col genere, la porto alla porta del genere gia' esistente.

## PARTE 6, LA VOCE NEL MENU UTENTE (commit `dd37e5c4`)

MISURA: una voce aggiunta in fondo all'elenco, dopo Privacy e dati, nessuna voce esistente spostata (l'ordine relativo che la guardia del menu pretende e' intatto); il commento che dice che si toglie con la decisione; nessun limite di piano; nessuna domanda all'ingresso. La riga che invita a puntare compare solo nel cielo di adesso, col sensore acceso e con la Luna o un pianeta brillante sopra l'orizzonte; senza, non compare niente. Il permesso di posizione si chiede col pulsante "Usa la mia posizione", con la ragione a schermo; il manifest non cambia.
IMMAGINI: prima `parte6_menu_utente_prima.png`, dopo `parte6_menu_utente_dopo.png` (il prima e' scattato togliendo la voce per un momento e rimettendo il file identico al byte).
ACCETTAZIONE: apri il menu utente dal tuo volto nella barra, scorri in fondo: Real Time Cosmo, "Prova: il cielo vero, adesso e alla tua nascita". Toccala: tre schede, una per prova.

## PARTE 7, LE GUARDIE (commit `a60ab21d`)

Sei guardie nuove, ciascuna con la sua prova di vista: 7.1 il cielo si dipinge una volta, 7.2 nessuna seconda porta sull'astronomia, 7.3 il catalogo e' letto (Sirio, Vega e Betelgeuse contro SIMBAD, scarto massimo 0,003 gradi; la Polare da Roma all'altezza della latitudine in ventiquattro ore), 7.4 il velo ha il suo asset, 7.5 nessuna linea di asterismo, 7.6 i due cataloghi non si incrociano. La 7.8 ha la sua prova sulla schermata vera: in scena disegna, sotto un'altra rotta e in pausa si ferma e spegne la bussola, al ritorno riparte.
**7.7, le misure sul telefono**, prese sul Realme 767f596c con la 2303 costruita per la consegna, l'8 ottobre 2026 alle 23 (metodo: `dumpsys SurfaceFlinger --timestats` sul livello di Flutter, `SurfaceView[com.esotericircle.esoteric_circle/...]`, perche' `gfxinfo` non vede i fotogrammi di Flutter; `dumpsys meminfo`, riga Graphics):
- **cielo fermo**: 656 fotogrammi in 10,9 s, cioe' 60 al secondo sullo schermo a 60 Hz, **16,6 ms per fotogramma, 0 persi**; trascinando il cielo col dito per 11,3 s: 611 fotogrammi, **54 al secondo, circa 18,5 ms**, 0 persi;
- **memoria grafica in transizione**: 119 MB nel menu delle tre prove, **146-147 MB** a 1, 3 e 7 secondi dall'apertura del ritorno (passaggio compreso), **118,6 MB** tornando al menu: nessuna perdita;
- **stelle a schermo**: contate dalla cattura nell'inquadratura verso ovest, senza veli, circa **230** punti luminosi (257 macchie meno le lettere delle scritte); con i veli in quadro il conto dai pixel non regge (le incisioni chiare dei veli diventano migliaia di "punti"), e vale la misura della scena, 191, 194 e 211;
- **il ritorno**: NON misurabile su questo telefono. Il Realme ha le tre scale di animazione a 0 (impostazioni del fondatore, non si toccano), quindi Riduci Movimento e' attivo e il ritorno e' un passaggio secco, come vuole la 3.4. Questa misura resta aperta, e con lei la chiusura piena della parte 2: si prende su un telefono con le animazioni accese.

## PARTE 8, LE PROVE DI VISTA (commit `fb8a8685`)

Otto prove (due per la 7.1, una per ciascuna delle altre e una per la 7.8), fatte da `tool/le_prove_di_vista_dell_ordine_fg.py`: per ognuna l'iniezione e' ENTRATA (verificato rileggendo il file, o che il file tolto non ci fosse), la guardia e' caduta nominando la riga o il valore, il file e' tornato identico al byte. Nessuna e' rimasta verde. Registro: `docs/collaudo/FG/prove_di_vista.txt`.

## LA SUITE INTERA, E UNA REGOLA DI CASA CHE HA VINTO SULL'ORDINE

La suite intera, una volta sola in fondo (R3), sul commit `fb8a8685` in un worktree a parte: **6.971 passate, 12 rosse**, tutte di questo lavoro e nessuna accettata. Corrette tutte, e rifatte verdi nel worktree di lavoro (50 prove su 50): le scritte del cielo seguono la scala del testo scelta dalla persona; quattro catch muti tolti (tre erano inutili, Provider da' null da solo per un tipo nullabile che manca, il quarto dichiara perche' ignora l'errore); la scheda del menu senza il click di sistema; la magnitudine dalla porta della lingua; la tipografia dai ruoli, col ruolo nuovo `numeroDellaScena` per l'eta' al centro del ritorno; la guardia della porta comune nel registro delle guardie (cinque righe nuove, totale da 720 a 725); il censimento dei vuoti verticali rigenerato; l'orologio fisso nella prova della 7.8.
**La regola che ha vinto**: la voce 1.9 chiedeva il disclaimer dentro Fonti e metodo; la regola non negoziabile di CLAUDE.md lo vuole UNA volta sola, all'ingresso e alla registrazione, e la guardia `i_tre_testi_in_una_pagina` lo conta. Il pannello porta l'attribuzione ad astronexus, Meeus, il WMM e i limiti, senza il disclaimer.

## IL DEBITO DEI DUE CATALOGHI

Dichiarato nel codice (`lib/core/astro/real_time_cosmo/catalogo_delle_stelle.dart`) e qui: HYG per il Real Time Cosmo, Hipparcos (`assets/data/bright_stars.json`) per il Cielo esistente, due strade che la guardia 7.6 tiene separate. Si chiude con la tua decisione: se sostituisci esce Hipparcos con le due rotte vecchie, se non sostituisci esce HYG, e con lei la voce del menu.

## COSA NON HO TOCCATO

SkyOverviewScreen e le sue due rotte, bright_stars.json, lo scope della Demo, il manifest. Niente da Stellarium. Nessuna credenziale.

## LA BUILD

Chiesta dal fondatore l'8 ottobre 2026 sera, "La build serve con solita consegna perche' devo provare": la **2303** su App Distribution, con la consegna solita (banchi col modello sullo stesso codice, verde di GitHub, accensione sul Realme). Le righe della consegna stanno in coda a questo rapporto.

## COSA TI CHIEDO

1. Se la frase d'arrivo del ritorno la vuoi col genere ("quando sei nato", "quando sei nata"), dimmelo.
