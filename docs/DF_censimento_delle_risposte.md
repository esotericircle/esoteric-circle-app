# IL CENSIMENTO DI OGNI RISPOSTA DELL'APP

Ordine DF voce 01, 11 settembre 2026. Nessuna riparazione in questo documento:
soltanto la misura.

**Che cosa c'e' dentro ogni riga**, come chiede la voce:

  a) il nome che la persona legge a schermo
  b) il file e la funzione che compongono il testo finale
  c) quali pezzi del testo sono FISSI, cioe' identici a ogni esecuzione
  d) quali pezzi VARIANO, e da quale ingresso dipende ciascuno
  e) quante combinazioni distinte quell'ingresso puo' produrre, **contate sul
     corpus reale e non stimate**

**LA REGOLA DEL PUNTO (e), e va letta prima della tabella.** *"Un pezzo che
dipende da un ingresso con due soli valori possibili va dichiarato come
praticamente fisso, e non come variabile."* Nella colonna delle combinazioni,
**ogni numero sotto dieci e' scritto in grassetto**: quelli sono i pezzi che la
persona vede tornare uguali.

**IL CONFINE CHE DECIDE QUALI FUNZIONI VANNO MISURATE.** Il chiarimento in testa
all'ordine DF: la regola della giornata stabile *"riguarda e riguardava solo
l'oroscopo perche' non c'e' domanda da parte dell'utente"*. Dove la persona
pone una domanda, ogni consultazione e' un evento nuovo e le quattro misure
della voce DF.02 si applicano. Dove non la pone, la ripetizione nella stessa
giornata **e' voluta**, e la colonna lo dice.

---

## LE ARTI ATTIVE, contate dal catalogo

`lib/core/arts/art_catalog.dart` porta **57 voci**, di cui **10 in stato
attiva**. Il conto viene dal file, non da un elenco a mano:

```
grep -c "ArtEntry(" lib/core/arts/art_catalog.dart          -> 57
grep -n "state: ArtState.attiva" lib/core/arts/art_catalog.dart | wc -l  -> 10
```

Le dieci: Oroscopo Personalizzato, Sinastria VIP, Stesa di Tarocchi, Angelo
Custode personale, Il Viaggio dello Sciamano, Meditazione, Test Archetipo,
Costellazione del Viso, Estrazione Rune, Sigillo dell'Intenzione.

---

## TABELLA UNO, LE ARTI ORACOLARI CON DOMANDA

Sono le tre a cui la voce DF.02 si applica per intero, e sono le tre che la
guardia `test/la_guardia_della_diversita_test.dart` misura a ogni giro.

### 1. Stesa di Tarocchi

| | |
|---|---|
| **(a) a schermo** | Stesa di Tarocchi, il Consiglio di Medora piu' Passato Presente Futuro |
| **(b) file** | `lib/core/tarot/tarot_reading.dart`, `consiglioDi` e `PosizioneLetta.of`; le forme in `lib/core/tarot/voce_della_stesa.dart` |

**(c) FISSO, prima dell'ordine DF:**

- il primo paragrafo, `topic.lente` piu' `topic.group.risposta`: **16 aperture
  da 3 risposte**, e nessuna delle due guardava le carte;
- il secondo paragrafo, `topic.group.consiglio`: **3 testi in tutta l'app**;
- la cucitura *"Le tre carte lo dicono insieme."*, in ogni lettura;
- la formula del futuro *"non e' una sentenza: e' dove questo va se non cambi
  passo"*, in ogni lettura e su qualunque carta;
- l'apertura della domanda *"Hai chiesto: X. Le tre carte rispondono a questa e
  non a una domanda in generale."*, **identica in cento letture su cento**;
- l'apertura di ognuna delle tre posizioni, cioe' la lente dell'argomento,
  **tre volte per lettura e uguale in tutte**.

**(c) FISSO, dopo l'ordine DF:** nessun paragrafo. Misurato: il paragrafo piu'
ripetuto su cento letture compare **1 volta**.

**(d) VARIA, e da cosa:**

| pezzo | ingresso | (e) combinazioni |
|---|---|---|
| il titolo | sintesi della carta del Presente | 78 carte per 2 versi = **156** |
| il riconoscimento della domanda | forma scelta dal filo | 8 |
| l'apertura della risposta | forma scelta dal filo | 8 |
| cosa dice il Presente | natura della carta per forma | 4 nature per 8 = 32 |
| l'aggancio dell'azione | forma scelta dal filo | 12 |
| il gesto | natura per forma | 4 per 8 = 32 |
| la ragione del gesto | forma scelta dal filo | 8 |
| il legame passato-presente | forma scelta dal filo | 12 |
| la chiusura sul futuro | natura della carta del Futuro per forma | 4 per 8 = 32 |
| i versi e i Maggiori | conto delle rovesciate per forma | 3 per 4, piu' 4 per i Maggiori |
| la chiusura della lettura | forma scelta dal filo | 8 |
| l'apertura di ogni posizione | forma scelta dal filo, una per posizione | 8 |
| i tre testi ricchi | le tre carte coi loro versi | 156 ognuno |

**Il filo che sceglie le forme nasce dalle tre carte e dai loro versi**, mai
dall'orologio: `FiloDellaVoce` in `lib/core/responsi/filo_della_voce.dart`.

**(e) MISURATO, non stimato**, su cento letture con lo stesso ingresso:

- testi distinti **100 su 100**
- scheletri distinti **100 su 100**, il piu' ripetuto **1 volta**
- somiglianza massima fra letture senza nessuna carta in comune **33,0 per
  cento** su 4777 coppie
- paragrafo piu' ripetuto **1 volta**

### 2. Estrazione Rune

| | |
|---|---|
| **(a) a schermo** | il presagio, in tre parti: la risposta, cosa puoi fare, da dove viene |
| **(b) file** | `lib/core/rituals/rune_presage.dart`, `componiIlResponso` |

**(c) FISSO:**

- l'apertura e la chiusura della **cornice della domanda**, da
  `lib/core/domande/cornici_del_presagio.dart`: **17 cornici**, una per
  domanda scelta piu' quella della giornata. **A parita' di domanda sono due
  frasi costanti**, e restano tali anche dopo l'ordine DF: sono corpus
  dell'Architetto e sono la cornice della domanda posta, non una risposta
  generata.
- prima dell'ordine DF: *"Per {glossa},"* davanti a ogni posizione, tre volte
  per gettata; l'equilibrio in **3 frasi**; l'esito in **2**; la famiglia in
  **3**; il nome della gettata in **4**.

**(d) VARIA, e da cosa:**

| pezzo | ingresso | (e) combinazioni |
|---|---|---|
| la riga di ogni posizione | runa uscita per verso | 24 per 2 = 48 per posizione |
| la forma della posizione | filo dalle rune | 16 |
| l'equilibrio | conto delle ombre per forma | 3 casi per 12 |
| l'esito | verso dell'ultima per forma | 2 per 8 |
| la famiglia dominante | aett per forma | 3 per 8 |
| il nome della gettata | gettata per forma | 4 per 8 |
| la terza parte | filo dalle rune | 16 forme |
| il significato di ogni runa | runa uscita | 24 |

**(e) MISURATO**, su cento gettate delle tre Norne con la stessa domanda:

- testi distinti **100 su 100**
- scheletri distinti **100 su 100**, il piu' ripetuto **1 volta**
- somiglianza massima fra gettate senza nessuna runa in comune **39,6 per
  cento** su 4374 coppie
- paragrafo piu' ripetuto **1 volta**

### 3. Il Viaggio dello Sciamano

| | |
|---|---|
| **(a) a schermo** | la scena che si riporta su, alla risalita |
| **(b) file** | `lib/core/viaggio/scena_del_viaggio.dart`, `ScenaDelViaggio.testo` e `ScenaSenzaModello.componi` |

**(c) FISSO, prima dell'ordine DF:** **una frase sola per ognuno dei tre gradi
di nitidezza**, cioe' **3 stampi in tutta l'arte**. E il seme della scena
nasceva da **la domanda e il giorno**: chi scendeva due volte lo stesso giorno
con la stessa domanda si riportava su **la stessa identica scena**.

**(d) VARIA, e da cosa:**

| pezzo | ingresso | (e) combinazioni |
|---|---|---|
| il luogo | vocabolario | 12 |
| la cosa | vocabolario | 18 |
| il gesto | vocabolario | 10 |
| il momento | vocabolario | **4** |
| l'apertura | filo dai quattro pezzi | 12 |
| il corpo | grado di nitidezza per forma | 3 casi per 8 |
| la chiusura | filo dai quattro pezzi | 12 |

Il vocabolario chiuso resta quello dell'ordine DC voce 06: **8640 scene**,
44 figure da disegnare. **Non e' stato toccato.**

**(e) MISURATO**, su cento discese con la stessa domanda nello stesso giorno:

- testi distinti **100 su 100**
- scheletri distinti **99 su 100**, il piu' ripetuto **2 volte**
- somiglianza massima fra scene senza nessuna figura in comune **25,0 per
  cento** su 2936 coppie
- paragrafo piu' ripetuto **1 volta**

---

## TABELLA DUE, LE FUNZIONI SENZA DOMANDA

Qui la persona **non chiede niente**, quindi la regola della giornata stabile
vale e la ripetizione dentro la giornata e' voluta. **La voce DF.02 non si
applica**, e il motivo sta scritto in testa all'ordine con le parole del
fondatore.

| funzione | file e funzione | fisso | varia da | combinazioni |
|---|---|---|---|---|
| Oroscopo Personalizzato | `lib/features/horoscope/oroscopo_screen.dart` con il corpus delle tradizioni | la cornice della tradizione | segno per giorno per tradizione | 12 segni per 365 giorni per tradizione |
| Arcano del Giorno | `lib/core/rituals/arcano_del_giorno.dart` | la cornice | carta del giorno | 78 per 2 versi |
| Dono dell'Alba | `lib/core/rituals/dawn_gift.dart` e `rito_alba.dart` | la struttura del dono | rito del giorno per memoria | il corpus di `rito_alba_corpus.dart` |
| Runa della Sera | `lib/core/rituals/sunset_rune.dart` e `sunset_rune_corpus.dart` | la cornice della sera | seme del giorno | `ritiDellaSera.length` |
| Angelo Custode | `lib/core/angels/angel_lore.dart` | la scheda | angelo dalla data di nascita | 72 |
| Test Archetipo | `lib/core/archetypes/` | la scheda dell'archetipo | risposte al test | 12 archetipi |
| Costellazione del Viso | `lib/core/face/` | le sette categorie | misure del volto | 3 varianti per 7 categorie |
| Sigillo dell'Intenzione | `lib/features/sigilli/` | la cornice | intenzione scritta | il testo della persona |
| Meditazione | `lib/features/maestri/aura/meditation/` | la cornice | sintomo per frequenza per durata | 12 per 9 per la durata |
| Sinastria VIP | `lib/core/synastry/` | la struttura del confronto | VIP per carta natale | 50 VIP per la carta della persona |

**PERCHE' QUESTA TABELLA NON PORTA I QUATTRO NUMERI.** Perche' la misura della
voce DF.02 pretende **cento consultazioni con lo stesso ingresso**, e in queste
funzioni l'ingresso **non si puo' ripetere**: l'Oroscopo di oggi e' l'Oroscopo
di oggi, l'Angelo di una data di nascita e' quell'angelo, l'Archetipo di un
test e' quell'archetipo. Cento consultazioni con lo stesso ingresso qui sono
**cento volte la stessa cosa per costruzione**, ed e' cio' che la persona si
aspetta: un oroscopo che cambiasse a ogni apertura sarebbe una slot machine, e
il fondatore lo ha vietato esplicitamente.

**LA CHAT DEI MAESTRI e la Sinastria passano dal modello**, cioe' da Vertex AI
e Gemini: la' la varieta' non e' un problema di composizione ma di
temperatura, e non e' materia di questo censimento.

---

## QUANTE SONO, IN TUTTO

**Tredici funzioni** producono un testo destinato alla persona: **tre** con
domanda, misurate per intero; **dieci** senza domanda, censite e dichiarate
fuori dalla misura con la ragione scritta.

**Piu' i riti e gli avvisi**, che non compongono un responso ma una riga:
`lib/core/rituals/avvisi_del_rito.dart`, `scelta_degli_avvisi.dart`,
`chiamata_del_primo_giorno.dart`, le feste dei traguardi in
`lib/features/sigilli/`. Sono righe di sistema, non risposte a una domanda, e
la loro ripetizione e' cio' che le rende riconoscibili.

---

MARCATORE DI CHIUSURA DEL CENSIMENTO, ordine DF voce 01.
