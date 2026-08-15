# ORDINE U. UN TRAGUARDO, UNA FESTA

Tre voci. Nessuna consegna in fondo: la build si fa una volta sola alla fine
della serie di ordini, ed e' una deroga dichiarata.

Deroga dichiarata anche alla regola delle due voci per ordine: la U.00 non e'
un terzo oggetto ma una precondizione, perche' una suite che cambia colore col
giorno rende sporca qualunque misura presa dalle altre due.

## Come si legge questo file

Una riga per voce, con lo stato in fondo. I quattro stati terminali ammessi
sono CHIUSA, FERMATA SU PREMESSA FALSA, FERMATA IN ATTESA DI DECISIONE e
APERTA. Finche' una riga e' APERTA la guardia `test/ordine_u_guard_test.dart`
resta rossa. I marcatori si contano sulle righe, non si scrivono a memoria.

## Le premesse, abbattute prima di toccare il codice

Tutte e cinque reggono, e le due che chiedevano una misura la portano.

1. **VERA, tutte e due le meta'.** Le tre prove di
   `la_festa_arriva_sempre_test.dart` falliscono anche al commit `e0b7c39`,
   cioe' prima dell'ordine T, e questo l'avevo gia' misurato. **La dipendenza
   dal cielo l'avevo ipotizzata e adesso e' provata:** una `gettata` sola accende
   il traguardo `cal_6` e nient'altro, e lo accende **solo quando il cielo del
   giorno porta `luna_nuova`**. Misurato su quattro giorni: 13 agosto un
   traguardo, 14 agosto un traguardo, 15 agosto **zero**, 16 agosto zero. La
   finestra si chiude fra il 14 e il 15, ed e' esattamente il giorno in cui le
   tre prove hanno cambiato colore.
2. **VERA, e il censimento e' completo.** I traguardi che compaiono in piu' di un
   sentiero sono **tre**, e ognuno compare in tutti e tre: la carta natale
   (`med_1`, `cal_1`, `aur_1`, posizione 1), l'Angelo Custode (`med_2`, `cal_2`,
   `aur_2`, posizione 2), l'Animale Guida (`med_3`, `cal_3`, `aur_3`, posizione
   3). Sono i tre gia' dichiarati in `Sentieri.agganciTrasversali`.
3. **VERA.** Le celebrazioni sono due: `CelebrazioneAScermoPieno`, per i grandi e
   per il primissimo Sigillo, e `_FasciaDellaCelebrazione` per i mini. La forma e
   la direzione non cambiano da un Maestro all'altro, cambia solo la palette.
4. **VERA.** La voce P.34 e' viva: `Celebrazione.festeggia` torna vero solo se la
   festa e' comparsa davvero, e quando non c'e' dove ospitarla la festa entra in
   `CodaDelleFeste` invece di perdersi.
5. **VERA.** Il Quality Tier e' `QualityTierController`, con `richEffects` che
   dice se gli effetti pesanti sono attivi; Riduci Movimento si riversa su
   `MediaQuery.disableAnimations` in `lib/app.dart`.

## Le voci

- **U.00** Una prova che legge il cielo dichiara il suo istante — CHIUSA
  - **IL CENSIMENTO, per enumerazione e non a occhio: quattordici prove
    pescavano dall'orologio.** Dodici costruivano `DiarioDelCammino()` senza
    orologio, e da li' passava il cielo del giorno; due chiamavano `DateTime.now`
    direttamente.
  - **LA CORREZIONE: l'istante si dichiara in un punto solo**,
    `test/istante_dichiarato.dart`, ed e' il **14 agosto 2026 a mezzogiorno**.
    **Non e' il giorno che fa passare le prove: e' un giorno in cui c'e'
    qualcosa da vedere.** Una prova che sorveglia la festa ha bisogno che un
    traguardo si accenda, e sceglierne uno in cui non si accende niente vorrebbe
    dire sorvegliare il nulla. Dodici file corretti.
  - **LE TRE PROVE DELLA FESTA SONO VERDI con un istante dichiarato**, e non per
    aver cambiato cio' che sorvegliano.
  - **LA GUARDIA CHIUDE LA FAMIGLIA invece di ripulirla una volta sola**, ed e' la
    differenza fra un filtro e un vincolo: `test/una_prova_dichiara_il_suo_istante_test.dart`
    enumera i file di prova e cade se uno costruisce il Diario senza orologio o
    chiama `DateTime.now` senza essere dichiarato. Tre file sono dichiarati e
    accanto a ognuno sta scritto **cosa sorveglia**, non solo che e' esentato; una
    terza riga pretende che le dichiarazioni siano vive, cioe' che il file esista
    ancora e che la ragione sia una ragione. **La guardia non guarda se stessa**,
    perche' porta nei suoi messaggi le parole che cerca.
  - **ROSSO ESEGUITO, con l'iniezione VERIFICATA prima di leggere l'esito:**
    rimesso un `DiarioDelCammino()` nudo dentro `il_sentiero_si_legge_test.dart`,
    verificato che fosse davvero entrato, la guardia e' caduta col nome del file.
    Poi ripristinato.
  - **PRIMA quattordici, DOPO zero** prove che pescano dall'orologio senza
    dichiararlo.
- **U.01** Un gesto, una festa, un pagamento — FERMATA IN ATTESA DI DECISIONE
  - **IL CENSIMENTO E' COMPLETO: i traguardi che compaiono in piu' di un sentiero
    sono TRE**, e ognuno compare in tutti e tre. Carta natale (med_1, cal_1,
    aur_1, posizione 1), Angelo Custode (med_2, cal_2, aur_2, posizione 2),
    Animale Guida (med_3, cal_3, aur_3, posizione 3).
  - **LA GUARDIA E' SCRITTA E NASCE ROSSA, ed e' giusto cosi': dice il vero.**
    `test/un_gesto_una_festa_un_pagamento_test.dart` enumera i 165 traguardi e
    raggruppa per FIRMA della condizione, che e' il dato e non il testo: due
    traguardi con la stessa firma si accendono insieme, sempre. Trova tre
    condizioni ripetute. **La misura del difetto: la carta natale accende tre
    traguardi e paga 60 Eos per un gesto solo.** Torna verde quando i sei
    sostitutivi sono montati, e non si porta a verde allentando cio' che chiede.
  - **LA VERIFICA CHE L'ALLEGATO D CHIEDE PRIMA DEL MONTAGGIO E' FATTA, per
    enumerazione su tutte e 165 le voci: NESSUNO DEI SEI COLLIDE.** Il tipo
    `GestiCompiuti(gesto, 1)` non compare mai in nessuno dei tre sentieri: le
    progressioni cominciano tutte da tre, quindi lo spazio delle prime volte e'
    libero. Sull'oracolo la Costellazione ha gia' due, tre, cinque, sette e
    quattordici giorni di seguito; sulla gettata l'Albero ha tre, cinque, dieci,
    venti, trenta e cinquanta; sul tramonto due, tre, cinque, sette e quattordici
    sere; sul soffio il Loto ha tre, cinque, venti e cinquanta; sull'archetipo
    solo la combinazione di tre arti nello stesso giorno; sul chakra i sette
    centri diversi e lo stesso centro tre volte. Nessuna e' una prima volta.
  - **MANCANO SEI TESTI, ed e' la ragione per cui la voce non e' chiusa.** Un
    traguardo porta QUATTRO testi: `nome`, `frase`, `percheConta`, `cosaApre`.
    L'Allegato D ne da' quattro, ma uno dei quattro e' l'**Obiettivo**, che non e'
    la `frase`: la frase e' quella della FESTA, si legge una volta sola nel
    momento in cui il Sigillo si accende ed e' scritta al passato, mentre
    l'Obiettivo dice cosa fare ed e' all'imperativo. **Servono le sei frasi della
    festa.** Non le scrivo io: i testi sono materiale dell'Architetto, e usare
    l'Obiettivo al posto della frase sarebbe riformularlo cambiandogli posto.
- **U.02** Tre celebrazioni, una per Maestro — APERTA

## Marcatori

VOCI_TOTALI: 3
VOCI_CHIUSE: 1
VOCI_APERTE: 1
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 1
