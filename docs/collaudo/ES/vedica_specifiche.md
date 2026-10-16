# Oroscopo vedico del giorno, specifiche verificate (ordine ES, voce 09)

Ricerca del 29 settembre 2026. Nessun file del repository è stato toccato: tutto
sta in questa cartella `vedica/`, accanto alla ricerca precedente
`../ricerca/cinese_e_vedica.md` (ayanamsa di Lahiri, rashi lunare), che qui si
dà per letta e non si ripete.

## File di questa cartella

| file | che cosa contiene |
|---|---|
| `specifiche.md` | questo documento: regole, fonti, verifica |
| `oroscopo_vedico.md` | la bozza del corpus nel tono di Medora |
| `verifica.csv` | venti nascite: rashi, nakshatra e pada dalla Swiss Ephemeris, rashi e nakshatra letti su Drik Panchang, scarto sulla fine del nakshatra |
| `rahu_kalam.csv` | Roma, Milano e Palermo dal 5 all'11 ottobre 2026: alba, tramonto e Rahu Kalam miei contro quelli di Drik Panchang |
| `nascite.py`, `verifica_nascite.py`, `fine_nakshatra.py` | calcolo e confronto delle venti nascite |
| `rahu_kalam.py` | alba, tramonto e Rahu Kalam con skyfield, confronto con Drik |
| `regole_bala.py` | le regole di Chandra Bala e Tara Bala confrontate con le tabelle di Drik |
| `cambi_ottobre.py` | istanti di cambio di nakshatra e rashi in ottobre 2026 contro Drik |
| `leggi_drik.py`, `scarica_rk.py`, `scarica_nascite.py`, `testo.py` | lettura delle pagine di Drik Panchang |
| `drik/` | le pagine di Drik Panchang scaricate il 29 settembre 2026 (prova conservata) |
| `raman_muhurtha.pdf`, `bphs.txt`, `bj.txt` | i testi delle fonti classiche usati per le citazioni |

Strumenti: Swiss Ephemeris 2.10.03 (pysweph) in modo siderale `SE_SIDM_LAHIRI`,
skyfield 1.55 con JPL DE421 per alba e tramonto, fusi storici da tzdata
`Europe/Rome`.

Drik Panchang **si legge in modo automatico**: le pagine sono HTML statico con
i valori già scritti (il panchang del giorno, il Rahu Kalam, l'alba indù, il
Chandrabalam e il Tarabalam per città e data, con `geoname-id` e
`date=gg/mm/aaaa` nell'indirizzo). Ho scaricato un centinaio di pagine con curl, una ogni
secondo circa, tutte conservate in `drik/`.

---

## 1. Le 27 costellazioni lunari (nakshatra)

### 1.1 Regola

Lo zodiaco siderale (ayanamsa di Lahiri, come in `cinese_e_vedica.md` 2.3) si
divide in 27 settori uguali di **13 gradi 20 primi** (360/27 = 13,3333 gradi)
a partire da **0 gradi di Mesha**. Ogni settore si divide in quattro **pada**
(quarti) di 3 gradi 20 primi.

```
lon = longitudine siderale geocentrica apparente della Luna (gradi, 0..360)
nakshatra = floor(lon / (40/3))            0 = Ashvini ... 26 = Revati
pada      = floor(lon / (10/3)) mod 4 + 1  1..4
```

- **Nakshatra di nascita (Janma Nakshatra)**: quello della Luna all'istante
  della nascita. Raman, *Muhurtha*, cap. III: "The constellation ruling at the
  time of birth is one's Janmanakshatra or birth star".
- **Nakshatra del giorno**: quello in cui sta la Luna nel momento considerato.
  Il panchang lo scrive come "Pushya fino alle 19:39, poi Ashlesha": nello
  stesso giorno civile la Luna cambia nakshatra circa una volta (lo attraversa
  in 24 ore circa, fra 20 e 27 a seconda della velocità).

**Proposta per l'app** (decisione da confermare): il nakshatra e il rashi "del
giorno" sono quelli della Luna **all'alba del luogo**, come fa il panchang (il
giorno del panchang comincia e finisce con l'alba: "In Panchang day starts and
ends with sunrise", Drik, pagina del Rahu Kalam). Così il testo resta lo stesso
per tutta la giornata. Quando la Luna cambia prima del tramonto, la scheda può
aggiungere l'ora del cambio. Senza città non c'è alba: si può usare l'istante
di apertura, dichiarandolo.

### 1.2 Tabella

Nomi in traslitterazione semplice senza segni diacritici, con la grafia che
usa Drik Panchang quando è diversa. Il signore Vimshottari è in tutti i testi
di jyotisha (BPHS cap. 46 della traduzione di Santhanam); qui serve solo come
dato di corredo.

| n | nome | grafia Drik | longitudine siderale | nel segno | signore (Vimshottari) |
|---|---|---|---|---|---|
| 1 | Ashvini | Ashwini | da 0° 00' a 13° 20' | da Mesha 0° 00' a Mesha 13° 20' | Ketu |
| 2 | Bharani | Bharani | da 13° 20' a 26° 40' | da Mesha 13° 20' a Mesha 26° 40' | Venere |
| 3 | Krittika | Krittika | da 26° 40' a 40° 00' | da Mesha 26° 40' a Vrishabha 10° 00' | Sole |
| 4 | Rohini | Rohini | da 40° 00' a 53° 20' | da Vrishabha 10° 00' a Vrishabha 23° 20' | Luna |
| 5 | Mrigashira | Mrigashira | da 53° 20' a 66° 40' | da Vrishabha 23° 20' a Mithuna 6° 40' | Marte |
| 6 | Ardra | Ardra | da 66° 40' a 80° 00' | da Mithuna 6° 40' a Mithuna 20° 00' | Rahu |
| 7 | Punarvasu | Punarvasu | da 80° 00' a 93° 20' | da Mithuna 20° 00' a Karka 3° 20' | Giove |
| 8 | Pushya | Pushya | da 93° 20' a 106° 40' | da Karka 3° 20' a Karka 16° 40' | Saturno |
| 9 | Ashlesha | Ashlesha | da 106° 40' a 120° 00' | da Karka 16° 40' a Karka 30° 00' | Mercurio |
| 10 | Magha | Magha | da 120° 00' a 133° 20' | da Simha 0° 00' a Simha 13° 20' | Ketu |
| 11 | Purva Phalguni | Purva Phalguni | da 133° 20' a 146° 40' | da Simha 13° 20' a Simha 26° 40' | Venere |
| 12 | Uttara Phalguni | Uttara Phalguni | da 146° 40' a 160° 00' | da Simha 26° 40' a Kanya 10° 00' | Sole |
| 13 | Hasta | Hasta | da 160° 00' a 173° 20' | da Kanya 10° 00' a Kanya 23° 20' | Luna |
| 14 | Chitra | Chitra | da 173° 20' a 186° 40' | da Kanya 23° 20' a Tula 6° 40' | Marte |
| 15 | Svati | Swati | da 186° 40' a 200° 00' | da Tula 6° 40' a Tula 20° 00' | Rahu |
| 16 | Vishakha | Vishakha | da 200° 00' a 213° 20' | da Tula 20° 00' a Vrishchika 3° 20' | Giove |
| 17 | Anuradha | Anuradha | da 213° 20' a 226° 40' | da Vrishchika 3° 20' a Vrishchika 16° 40' | Saturno |
| 18 | Jyeshtha | Jyeshtha | da 226° 40' a 240° 00' | da Vrishchika 16° 40' a Vrishchika 30° 00' | Mercurio |
| 19 | Mula | Mula | da 240° 00' a 253° 20' | da Dhanu 0° 00' a Dhanu 13° 20' | Ketu |
| 20 | Purva Ashadha | Purva Ashadha | da 253° 20' a 266° 40' | da Dhanu 13° 20' a Dhanu 26° 40' | Venere |
| 21 | Uttara Ashadha | Uttara Ashadha | da 266° 40' a 280° 00' | da Dhanu 26° 40' a Makara 10° 00' | Sole |
| 22 | Shravana | Shravana | da 280° 00' a 293° 20' | da Makara 10° 00' a Makara 23° 20' | Luna |
| 23 | Dhanishtha | Dhanishtha | da 293° 20' a 306° 40' | da Makara 23° 20' a Kumbha 6° 40' | Marte |
| 24 | Shatabhisha | Shatabhisha | da 306° 40' a 320° 00' | da Kumbha 6° 40' a Kumbha 20° 00' | Rahu |
| 25 | Purva Bhadrapada | Purva Bhadrapada | da 320° 00' a 333° 20' | da Kumbha 20° 00' a Mina 3° 20' | Giove |
| 26 | Uttara Bhadrapada | Uttara Bhadrapada | da 333° 20' a 346° 40' | da Mina 3° 20' a Mina 16° 40' | Saturno |
| 27 | Revati | Revati | da 346° 40' a 360° 00' | da Mina 16° 40' a Mina 30° 00' | Mercurio |

Nota: Drik Panchang nomina anche un 28° nakshatra, **Abhijit**, usato solo per
alcune scelte del momento (muhurta). Nel sistema a 27 settori uguali, quello del
panchang quotidiano e del Tarabalam, Abhijit non compare: Drik stesso calcola il
Tarabalam su 27 nakshatra (vedi 3.3).

### 1.3 Precisione richiesta

Un nakshatra è largo 13 gradi 20 primi, un pada 3 gradi 20 primi. La Luna
percorre un grado in circa due ore. La ricerca precedente ha misurato che la
Luna troncata dell'app sbaglia il rashi in una nascita su trecento; per il
nakshatra, con settori larghi meno della metà, lo sbaglio con la Luna troncata
sarebbe circa doppio. **Serve la Luna di Meeus intera**, che l'app ora ha (voce
ES.05, 0,0095 gradi dal JPL): con quella l'errore sul nakshatra si riduce a una
nascita su qualche migliaio (stima, non misurata).

---

## 2. Chandra Bala (forza della Luna)

### 2.1 Regola del calcolo

```
casa = ((rashi_luna_oggi - rashi_luna_nascita) mod 12) + 1     1..12
```

Si conta dal segno lunare di nascita (Janma Rashi) al segno in cui transita la
Luna oggi, includendo il segno di partenza: Luna di oggi nello stesso segno di
nascita = casa 1.

### 2.2 Esiti

| casa | Drik Panchang | Brihat Samhita 104.8-10 (Varahamihira) | Phaladeepika 26.12 (Mantreshvara) | esito per l'app |
|---|---|---|---|---|
| 1 | Good | pasti, letti e vesti eccellenti | nascita di fortuna | favorevole |
| 2 | Puja Needed | perdita di beni, ostacoli | perdita di ricchezza | di attenzione |
| 3 | Good | vesti, affetti e beni in abbondanza | successo | favorevole |
| 4 | Bad | crudele come un serpente (irrequietezza) | paura | sfavorevole |
| 5 | Puja Needed | umiliazione, malanni, ostacoli | dolore | di attenzione |
| 6 | Good | ricchezza, agio, rovina dei nemici | libertà dalla malattia | favorevole |
| 7 | Good | ricchezza e rispetto | felicità | favorevole |
| 8 | Bad | paura dei mali | eventi avversi | sfavorevole (la più pesante) |
| 9 | Puja Needed | prigionia e dolore | malattia | di attenzione |
| 10 | Good | ordini eseguiti, successo nel lavoro | desideri realizzati | favorevole |
| 11 | Good | prosperità, amicizie nuove | gioia | favorevole |
| 12 | Bad | ferite (causate da buoi) | spesa | sfavorevole |

**Case favorevoli: 1, 3, 6, 7, 10, 11.** Le tre fonti concordano:

- Varahamihira, *Brihat Samhita*, cap. 104 (Gocharadhyaya, "i transiti dei
  pianeti"), verso 4: la Luna dà effetti benefici nel 3°, 6°, 10°, 7° e 1°
  segno dalla Luna di nascita; versi 8-10: gli effetti casa per casa, con
  l'11ª che porta "prosperità e amicizie nuove". Traduzione inglese su
  wisdomlib.org (`/hinduism/book/brihat-samhita/d/doc229368.html`).
- Mantreshvara, *Phaladeepika*, cap. 26 (Gochara), verso 2: la Luna è buona in
  3, 10, 6, 7, 1 e 11, con le case di ostruzione (vedha) 2, 5, 12, 8, 4 e 9;
  verso 12: l'esito casa per casa. Traduzione su wisdomlib.org
  (`/hinduism/book/phaladeepika-by-mantreswara-text-and-translation/d/doc1621598.html`).
  Verso 1: i transiti si giudicano dal segno della Luna di nascita.
- **Drik Panchang**, pagina "Chandrabalam" (`/panchang/chandrabalam/chandrabalam-timings.html`):
  per ogni segno di nascita scrive Good, Bad o Puja Needed. **Ho verificato la
  regola sulle sue tabelle**: cinque giorni di ottobre 2026 (5, 13, 16, 20 e 24,
  sia in luna calante sia in luna crescente), dodici segni, anche i valori dopo
  il cambio di segno della Luna: **60 esiti su 60 uguali alla tabella sopra**
  (`regole_bala.py`). Drik quindi usa tre livelli: Good per 1, 3, 6, 7, 10, 11;
  Puja Needed ("serve un rito") per 2, 5, 9; Bad per 4, 8, 12. Non distingue
  la luna crescente dalla calante.

**Divergenze delle fonti, da sapere.**

1. **B. V. Raman**, *Muhurtha (Electional Astrology)*, cap. III, paragrafo
   "Chandrabala": "the Moon should not occupy in the election chart, a position
   that happens to represent the 6th, 8th or 12th from the person's Janma
   Rasi". Raman mette **la sesta fra le sfavorevoli**, contro Varahamihira,
   Mantreshvara e Drik. La sesta è una casa di crescita (upachaya) e i due testi
   classici la danno buona per la Luna; per l'app propongo di seguire i testi
   classici e Drik, che sono anche il riferimento che l'utente indiano ritrova.
2. **L'ottava dalla Luna** ha un nome suo, **Chandrashtama**, ed è la più
   evitata nella pratica: Raman la mette fra le tre da evitare, Brihat Samhita
   ne parla come "paura dei mali". Per questo nel corpus ha frasi a parte.
3. Esiste una tradizione, riferita da vari siti, per cui in luna crescente
   (Shukla Paksha) anche la 2ª, la 5ª e la 9ª sarebbero buone. **Non l'ho
   trovata nei testi letti** e Drik non la applica (verificato: stessa tabella
   in luna crescente e calante). Non la uso.

### 2.3 Proposta di esito per l'app

Tre livelli, come Drik: **favorevole** (1, 3, 6, 7, 10, 11), **di attenzione**
(2, 5, 9), **sfavorevole** (4, 12) più la **ottava** (8) come caso a sé. Il
livello della scheda Generale nasce da qui e dalla Tara Bala (sezione 3.4).

---

## 3. Tara Bala (forza della stella)

### 3.1 Regola del calcolo

```
conto = ((nakshatra_oggi - nakshatra_nascita) mod 27) + 1      1..27
tara  = ((conto - 1) mod 9) + 1                                  1..9
```

Raman, *Muhurtha*, cap. III: "Count from the birth constellation to the one
ruling on the particular day [...] and divide the number by 9 if divisible.
Otherwise keep it as it is." Esempio suo: nato in Ashvini, giorno in Shravana,
conto 22, resto 4, Kshema, favorevole.

### 3.2 I nove esiti

| tara | nome | Raman, *Muhurtha* cap. III | Drik Panchang | esito per l'app |
|---|---|---|---|---|
| 1 | Janma (la nascita) | "danger to body" | Not Good | di attenzione |
| 2 | Sampat (la ricchezza) | "wealth and prosperity" | Very Good | favorevole |
| 3 | Vipat (il pericolo) | "dangers, losses and accidents" | Bad | sfavorevole |
| 4 | Kshema (il benessere) | "prosperity" | Good | favorevole |
| 5 | Pratyak, o Pratyari (l'ostacolo) | "obstacles" | Not Good | di attenzione |
| 6 | Sadhana, o Sadhaka (la riuscita) | "realisation of ambitions" | Very Good | favorevole |
| 7 | Naidhana (la fine) | "dangers" | Totally Bad | sfavorevole (la più pesante) |
| 8 | Mitra (l'amico) | "good" | Good | favorevole |
| 9 | Parama Mitra (il grande amico) | "very favourable" | Good | favorevole |

**Verifica della regola sulle tabelle di Drik**: pagina "Tarabalam"
(`/panchang/tarabalam/tarabalam-timings.html`), Roma, 5, 13, 16 e 20 ottobre
2026, 27 nakshatra di nascita, prima e dopo il cambio del nakshatra del giorno:
**216 esiti su 216 uguali alla regola** (`regole_bala.py`).

### 3.3 Sfumature di Raman (non applicate da Drik)

- Nel primo giro di nove (conto da 1 a 9) gli esiti valgono per intero; nel
  secondo (10-18) il male è dimezzato; nel terzo (19-27) è "quasi trascurabile".
  Raman stesso però consiglia di evitare Vipat e Naidhana anche nel terzo giro
  per le cose importanti.
- Il giorno del proprio nakshatra (Janma) è sfavorevole in generale, ma
  favorevole per alcune imprese (agricoltura, acquisto di terre, studio).
- Alcuni autori danno sempre sfavorevoli il 22° (Vainashika) e il 27°; Raman
  scrive che la sua esperienza è contraria.

Per l'app propongo la regola semplice di Drik, verificata, senza i giri.

### 3.4 Livello della scheda Generale

Proposta (decisione di chi scrive l'ordine): il livello nasce dalla combinazione
delle due forze, come chiede Raman ("These three should be satisfactorily
disposed"): entrambe favorevoli, giornata piena; una favorevole e una di
attenzione, giornata buona con una cautela; una sfavorevole, giornata da
prendere piano; Chandrashtama (ottava) o Naidhana, giornata da non forzare.

---

## 4. Il pianeta del giorno (vara), colore e numero

### 4.1 Regola

Il giorno della settimana (vara) prende il nome dal pianeta che lo governa, e
il nome sanscrito lo dice: Ravivara (Ravi, il Sole), Somavara (Soma, la Luna),
Mangalavara (Marte), Budhavara (Mercurio), Guruvara (Giove), Shukravara
(Venere), Shanivara (Saturno). Drik Panchang scrive il vara nel panchang del
giorno (per il 15 marzo 1990, giovedì: "Guruwara"). Il giorno del vara, per il
panchang, va da alba ad alba; per l'app basta il giorno civile.

### 4.2 Tabella

| giorno | vara | pianeta | colore (Brihat Jataka 2.5) | colore d'uso per l'app | numero (numerologia indiana) |
|---|---|---|---|---|---|
| domenica | Ravivara | Sole | rosso | rosso | 1 |
| lunedì | Somavara | Luna | bianco | bianco | 2 |
| martedì | Mangalavara | Marte | rossastro | rosso | 9 |
| mercoledì | Budhavara | Mercurio | verde | verde | 5 |
| giovedì | Guruvara | Giove | giallastro | giallo | 3 |
| venerdì | Shukravara | Venere | variegato | bianco screziato (da decidere) | 6 |
| sabato | Shanivara | Saturno | nero | nero o blu scuro (da decidere) | 8 |

Rahu (4) e Ketu (7) non governano nessun giorno: nella numerologia indiana
completano la serie dei nove numeri ma non compaiono nella scheda del giorno.

**Fonti dei colori.** Varahamihira, *Brihat Jataka*, cap. 2, sloka 5,
traduzione di V. Subrahmanya Sastri (2ª ed., archive.org
`BrihatJataka2ndEd.ByVSubrahmanyaSastri`): "Red, white, reddish, green,
yellowish, variegated and black are the colours of the planets from the Sun
onwards". Lo sloka 4 aggiunge le carnagioni: il Sole rosso scuro, la Luna
bianca, Mercurio del verde scuro dell'erba durva, Giove giallastro, Venere "né
molto bianco né molto nero", Saturno scuro. Parashara, *Brihat Parashara Hora
Shastra*, cap. 3, versi 16-17 (traduzione di R. Santhanam) dà la stessa serie
con una differenza di traduzione sulla Luna ("tawny", fulva, dove Varahamihira
dice bianca). Per Venere il testo dice "variegato" (screziato, a più colori);
la pratica popolare indiana del venerdì usa il bianco o i colori chiari, ma
questa pratica non l'ho trovata in una fonte stampata autorevole. Per Saturno il
testo dice nero; il blu scuro è pratica popolare (gemma di Saturno lo zaffiro
blu), anche questa senza fonte classica letta.

**Fonte dei numeri.** La serie Sole 1, Luna 2, Giove 3, 4, Mercurio 5,
Venere 6, 7, Saturno 8, Marte 9 è di **Cheiro** (Louis Hamon), *Cheiro's Book
of Numbers*, Londra 1926, che però dà il 4 a Urano e il 7 a Nettuno. La
numerologia indiana corrente sostituisce Urano e Nettuno con Rahu (4) e Ketu
(7): lo documenta, come pratica osservata, "Investigating Correspondences
Between Numerology and Astrology, Part 2", livingincycles.blog, 21 gennaio 2020.
**Non è una regola dei testi sanscriti classici**: è numerologia moderna di
origine anglo-indiana. Va detto così nella nota del metodo, per onestà.

---

## 5. Rahu Kalam

### 5.1 Regola

Il tempo fra l'alba e il tramonto del luogo si divide in **otto parti uguali**;
il Rahu Kalam è una di queste, secondo il giorno della settimana. Drik Panchang,
pagina "Rahu Kaal" (`/panchang/rahu-kaal.html`), testo letto il 29 settembre
2026: "On Monday Rahu Kaal falls on the 2nd period, Saturday on the 3rd period,
Friday on the 4th period, Wednesday on the 5th period, Thursday on the 6th
period, Tuesday on the 7th period and Sunday on the 8th period."

| giorno | parte (1..8) |
|---|---|
| lunedì | 2 |
| martedì | 7 |
| mercoledì | 5 |
| giovedì | 6 |
| venerdì | 4 |
| sabato | 3 |
| domenica | 8 |

**La sequenza data nell'ordine è confermata**: la confermano anche 21 giorni su 21
dei confronti con Drik (sezione 7.2).

```
durata = (tramonto - alba) / 8
inizio = alba + durata * (parte - 1)
fine   = alba + durata * parte
```

Altre regole scritte da Drik nella stessa pagina, utili per il corpus:

- Il Rahu Kalam vale "only for undertaking any new work and already started
  work can be continued during Rahu Kaal": si evita di **cominciare**, non di
  continuare.
- La prima parte del giorno dopo l'alba è sempre libera dal Rahu Kalam.
- Varia da luogo a luogo e da giorno a giorno: senza città non si può dare.
- Esiste un Rahu Kalam notturno (dal tramonto all'alba diviso per otto) ma è
  poco usato: non lo propongo.

Fonte classica: il Rahu Kalam è una pratica soprattutto dell'India del Sud
("People, especially in South India, give utmost importance to Rahu Kaal",
Drik). Raman lo tratta in un'appendice di *Muhurtha* ("Rahu Kalam example",
secondo la nota del trascrittore dell'edizione digitale letta; l'appendice non
è nella copia scaricata). Non ho trovato un verso sanscrito antico che lo
fondi: è regola di calendario tradizionale, non di testo classico.

### 5.2 Alba e tramonto come li calcola Drik Panchang

Drik Panchang, pagina "Hindu Sunrise" (`/panchang/sunrise/panchang-sunrise.html`),
testo letto il 29 settembre 2026: "Drik Panchang uses upper edge of sun along
with refraction to mark the time of sunrise. Further, by default we don't
consider elevation for Sunrise calculations". La pagina mostra affiancate
quattro varianti; per Roma, 5 ottobre 2026:

| variante | alba | tramonto |
|---|---|---|
| **bordo superiore** (usata e suggerita da Drik) | 07:11 | 18:45 |
| centro del disco | 07:12 | 18:44 |
| bordo superiore con quota | 07:10 | 18:47 |
| centro del disco con quota | 07:11 | 18:45 |

**Convenzione per l'app**: bordo superiore del Sole con la rifrazione
atmosferica standard, senza quota. In pratica il centro del Sole a **-0,8333
gradi** di altezza (34 primi di rifrazione più 16 primi di semidiametro), la
stessa convenzione delle effemeridi nautiche e dei giornali. Coordinate della
città: Drik usa quelle di GeoNames (Roma 41°53'30" N, 12°30'40" E; Milano
45°27'51" N, 9°11'22" E; Palermo 38°07'55" N, 13°20'08" E). Con il centro del
disco (-0,5667 gradi) l'alba viene circa un minuto e mezzo dopo e il tramonto
un minuto e mezzo prima (colonne `alba_centro_mia` e `tramonto_centro_mio` di
`rahu_kalam.csv`).

Drik scrive le ore al minuto: nel confronto le mie ore arrotondate al minuto
più vicino coincidono con le sue (sezione 7.2).

---

## 6. Le case delle schede (bhava), contate dalla Luna di nascita

### 6.1 Contare dalla Luna

Le case si contano dal segno della Luna di nascita, preso come prima casa
(Chandra Lagna). Fonti: Mantreshvara, *Phaladeepika* 26.1 (i transiti si
giudicano dal segno della Luna); Parashara, *BPHS*, cap. 12 della traduzione di
Santhanam, nel sommario: "Moon equated to ascendant". È anche la regola di
tutti gli oroscopi quotidiani indiani sul rashi.

### 6.2 I significati delle case (BPHS cap. 11, "Judgement of Houses", Santhanam)

| scheda | casa | BPHS cap. 11 | conferma |
|---|---|---|---|
| Lavoro | **10ª** | "Royalty (authority), place, profession (livelihood), honour, father" (v. 11) | Brihat Samhita 104.10: con la Luna in 10ª "gli ordini saranno eseguiti, successo nel lavoro" |
| Fortuna | **2ª** | "Wealth, grains (food etc.), family" (v. 3) | nome tradizionale Dhana bhava, casa dei beni |
| Fortuna | **11ª** | "All articles, [...] income, prosperity" (v. 12) | nome tradizionale Labha bhava, casa dei guadagni; Brihat Samhita 104.10: "prosperità e amicizie nuove" |
| Amore | **7ª** | "Wife, travel, trade" (v. 8) | nome tradizionale Kalatra bhava, casa del coniuge |
| Amore | **5ª** | "amulets, sacred spells, learning, knowledge, sons, royalty" (v. 6) | vedi sotto |

**Conferma: le case assegnate dall'ordine sono quelle della tradizione, con una
precisazione sulla quinta.** Nel BPHS la 5ª è la casa dei figli, del sapere e
del merito, non dell'amore. L'amore come innamoramento e corteggiamento sulla
5ª è lettura moderna, diffusa anche nell'astrologia indiana di oggi (e in
quella occidentale), ma non è nel verso di Parashara. La 7ª è l'unione e il
coniuge. Nel corpus la 7ª parla del legame e dell'incontro con l'altro, la 5ª
del cuore che si apre, del gioco e della creatività: così non si attribuisce a
Parashara ciò che non ha scritto.

### 6.3 Regola proposta per le schede Amore, Lavoro e Fortuna

La Luna di oggi sta nella casa `h` (sezione 2.1). Per ogni scheda si sceglie un
caso solo, in quest'ordine di precedenza:

1. **Ottava (h = 8)**: Chandrashtama, vince su tutto.
2. **Luna nella casa del dominio**: la Luna "attraversa" la casa (per l'Amore
   h = 7 o h = 5; per il Lavoro h = 10; per la Fortuna h = 2 o h = 11).
3. **Luna opposta alla casa del dominio**: ogni pianeta guarda per intero la
   settima casa da sé (BPHS cap. 26, versi 2-5, Santhanam: "All planets aspect
   the 7th fully"). Per l'Amore h = 1 (guarda la 7ª) o h = 11 (guarda la 5ª);
   per il Lavoro h = 4 (guarda la 10ª); per la Fortuna h = 5 (guarda l'11ª),
   mentre h = 8 guarderebbe la 2ª ma è già preso dalla regola 1.
4. **Altrimenti, la Chandra Bala di h**: favorevole, di attenzione, sfavorevole.

Tabella risultante, tutte le dodici case per ogni scheda:

| h | Amore (7ª e 5ª) | Lavoro (10ª) | Fortuna (2ª e 11ª) |
|---|---|---|---|
| 1 | guarda la 7ª | favorevole | favorevole |
| 2 | di attenzione | di attenzione | nella 2ª |
| 3 | favorevole | favorevole | favorevole |
| 4 | sfavorevole | guarda la 10ª | sfavorevole |
| 5 | nella 5ª | di attenzione | guarda l'11ª |
| 6 | favorevole | favorevole | favorevole |
| 7 | nella 7ª | favorevole | favorevole |
| 8 | ottava | ottava | ottava |
| 9 | di attenzione | di attenzione | di attenzione |
| 10 | favorevole | nella 10ª | favorevole |
| 11 | guarda la 5ª | favorevole | nella 11ª |
| 12 | sfavorevole | sfavorevole | sfavorevole |

Il tono delle frasi "nella casa" e "guarda la casa" tiene conto della Chandra
Bala di quella casa: la Luna in 2ª o in 5ª attiva il dominio ma da una casa di
attenzione, la Luna in 4ª guarda il lavoro da una casa sfavorevole. Il corpus lo
riflette.

---

## 7. Verifica

### 7.1 Venti nascite: rashi e nakshatra

Le dieci nascite di `../ricerca/cinese_vedica_dieci_date.csv` più dieci nuove,
con ora e città italiane. Calcolo mio: Swiss Ephemeris, Luna geocentrica
apparente siderale Lahiri. Confronto: la pagina del panchang del giorno di Drik
Panchang per la città della nascita (giorno della nascita e giorno prima, per
le nascite prima dell'alba), letta nelle righe "Moonsign" e "Nakshatra" con le
ore di fine.

| nascita (ora italiana) | città | fuso | rashi | nakshatra, pada | minuti dal confine del nakshatra | Drik | scarto sulla fine del nakshatra (Drik meno mio) |
|---|---|---|---|---|---|---|---|
| 1990-03-15 08:30 | Roma | +1 | Tula | 15 Svati, 3 | 750 | Tula, Swati | +0,8 min |
| 1985-07-04 22:10 | Milano | +2 | Makara | 22 Shravana, 3 | 455 | Makara, Shravana | fuori pagina |
| 2000-01-01 00:05 | Napoli | +1 | Tula | 15 Svati, 2 | 750 | Tula, Swati | +1,6 min |
| 1972-11-23 14:00 | Torino | +1 | Mithuna | 6 Ardra, 3 | 565 | Mithuna, Ardra | +0,3 min |
| 1995-12-24 06:45 | Palermo | +1 | Makara | 21 Uttara Ashadha, 4 | 130 | Makara, Uttara Ashadha | +1,0 min |
| 1968-06-21 12:00 | Firenze | +2 | Mesha | 2 Bharani, 2 | 475 | Mesha, Bharani | fuori pagina |
| 2004-02-29 18:20 | Bologna | +1 | Mithuna | 5 Mrigashira, 4 | 362 | Mithuna, Mrigashira | +1,1 min |
| 1979-09-09 03:15 | Bari | +2 | Mina | 27 Revati, 4 | 139 | Meena, Revati | +1,3 min |
| 1999-08-11 11:00 | Venezia | +2 | Karka | 9 Ashlesha, 2 | 679 | Karka, Ashlesha | +0,9 min |
| 1958-04-30 20:30 | Genova | +1 | Kanya | 12 Uttara Phalguni, 4 | 114 | Kanya, Uttara Phalguni | 0,0 min |
| 1983-05-19 16:40 | Catania | +2 | Simha | 10 Magha, 2 | 474 | Simha, Magha | fuori pagina |
| 1976-10-02 09:15 | Cagliari | +1 | Makara | 21 Uttara Ashadha, 4 | 124 | Makara, Uttara Ashadha | +0,7 min |
| 1992-08-27 23:50 | Trieste | +2 | Simha | 10 Magha, 3 | 484 | Simha, Magha | fuori pagina |
| 2008-11-14 07:05 | Verona | +1 | Vrishabha | 4 Rohini, 1 | 215 | Vrishabha, Rohini | +0,5 min |
| 1964-01-08 13:20 | Perugia | +1 | Tula | 15 Svati, 3 | 699 | Tula, Swati | +1,8 min |
| 1988-02-11 05:30 | Ancona | +1 | Vrishchika | 16 Vishakha, 4 | 284 | Vrishchika, Vishakha | +0,6 min |
| 2011-06-30 19:45 | Reggio Calabria | +2 | Mithuna | 6 Ardra, 1 | 17 | Mithuna, Ardra | fuori pagina |
| 1997-04-03 02:10 | Trento | +2 | Makara | 22 Shravana, 3 | 508 | Makara, Shravana | +1,1 min |
| 1970-12-17 21:00 | Pescara | +1 | Karka | 9 Ashlesha, 4 | 111 | Karka, Ashlesha | +0,7 min |
| 2015-09-22 10:25 | Lecce | +2 | Dhanu | 20 Purva Ashadha, 2 | 379 | Dhanu, Purva Ashadha | +0,6 min |

**Risultato: rashi 20 su 20 uguali a Drik Panchang; nakshatra 20 su 20 uguali
a Drik Panchang.** Le dieci nascite vecchie danno anche lo stesso rashi della
ricerca precedente (10 su 10). Sulla fine del nakshatra di nascita, dove cade
nelle pagine scaricate (15 nascite su 20), lo scarto fra Drik e Swiss
Ephemeris va da 0,0 a +1,8 minuti, medio +0,9: Drik è sempre uguale o poco più
tardi. La nascita più vicina a un confine è Reggio Calabria 2011, entrata in
Ardra 17 minuti prima; la più vicina a un confine di rashi è Ancona 1988, 80
minuti. Il fuso storico coincide: nelle nascite con l'ora legale (1968, 1979,
1985, 1992, 1997, 1999, 2011, 2015) uno sbaglio di fuso darebbe un'ora di
scarto: non ce n'è nessuno.

Sulle date di ottobre 2026 (`cambi_ottobre.py`) il confronto è ancora più
stretto: quattro cambi di nakshatra e due di rashi per Roma, Drik scrive l'ora
troncata al minuto, scarto fra -0,2 e -0,6 minuti (cioè lo stesso minuto).

### 7.2 Rahu Kalam di Roma, Milano e Palermo, dal 5 all'11 ottobre 2026

Calcolo mio: skyfield con JPL DE421, alba e tramonto al bordo superiore con
rifrazione standard (-0,8333 gradi), senza quota, coordinate di GeoNames come
Drik, tabella delle parti della sezione 5.1. Confronto: la pagina del Rahu Kaal
di Drik per città e data (21 pagine) e il panchang del giorno per alba e
tramonto (21 pagine). Tutto in `rahu_kalam.csv`.

| città | giorno | parte | mio (al secondo) | Drik |
|---|---|---|---|---|
| Roma | lun 5 | 2 | 08:37:46 - 10:04:31 | 08:38 - 10:05 |
| Roma | mar 6 | 7 | 15:50:33 - 17:16:58 | 15:51 - 17:17 |
| Roma | mer 7 | 5 | 12:57:27 - 14:23:31 | 12:57 - 14:24 |
| Roma | gio 8 | 6 | 14:22:53 - 15:48:36 | 14:23 - 15:49 |
| Roma | ven 9 | 4 | 11:31:31 - 12:56:54 | 11:32 - 12:57 |
| Roma | sab 10 | 3 | 10:06:34 - 11:31:36 | 10:07 - 11:32 |
| Roma | dom 11 | 8 | 17:10:26 - 18:35:07 | 17:10 - 18:35 |
| Milano | lun 5 | 2 | 08:52:33 - 10:18:47 | 08:53 - 10:19 |
| Milano | mar 6 | 7 | 16:02:41 - 17:28:32 | 16:03 - 17:29 |
| Milano | mer 7 | 5 | 13:10:41 - 14:36:09 | 13:11 - 14:36 |
| Milano | gio 8 | 6 | 14:35:29 - 16:00:33 | 14:35 - 16:01 |
| Milano | ven 9 | 4 | 11:45:28 - 13:10:08 | 11:45 - 13:10 |
| Milano | sab 10 | 3 | 10:21:18 - 11:45:35 | 10:21 - 11:46 |
| Milano | dom 11 | 8 | 17:21:18 - 18:45:11 | 17:21 - 18:45 |
| Palermo | lun 5 | 2 | 08:33:03 - 10:00:18 | 08:33 - 10:00 |
| Palermo | mar 6 | 7 | 15:48:21 - 17:15:17 | 15:48 - 17:15 |
| Palermo | mer 7 | 5 | 12:54:12 - 14:20:50 | 12:54 - 14:21 |
| Palermo | gio 8 | 6 | 14:20:15 - 15:46:35 | 14:20 - 15:47 |
| Palermo | ven 9 | 4 | 11:27:36 - 12:53:38 | 11:28 - 12:54 |
| Palermo | sab 10 | 3 | 10:01:55 - 11:27:38 | 10:02 - 11:28 |
| Palermo | dom 11 | 8 | 17:09:24 - 18:34:50 | 17:09 - 18:35 |

**Risultato: con le mie ore arrotondate al minuto più vicino, 42 estremi su 42
coincidono con Drik (21 inizi e 21 fini), scarto 0 minuti.** Prima
dell'arrotondamento lo scarto è al massimo 0,48 minuti, medio +0,07. Alba e
tramonto: 42 su 42 entro 0,52 minuti da quelli di Drik, medio -0,04.

### 7.3 Regole di Chandra Bala e Tara Bala

Già dette sopra: 60 esiti di Chandrabalam su 60 e 216 di Tarabalam su 216
uguali alle tabelle di Drik Panchang (Roma, ottobre 2026).

---

## 8. Incertezze

1. **Chandra Bala, la sesta casa**: Raman la dà sfavorevole, Varahamihira,
   Mantreshvara e Drik favorevole. Ho seguito i secondi.
2. **La 5ª casa per l'amore** è lettura moderna: nel BPHS è la casa dei figli e
   del sapere. Il corpus la tratta come "cuore che si apre", senza attribuirla a
   Parashara.
3. **Numerologia indiana**: la serie è di Cheiro (1926) con Rahu e Ketu al posto
   di Urano e Nettuno; nessun testo sanscrito classico. La fonte che documenta
   la sostituzione è un blog, non un libro.
4. **Colori**: i testi danno "variegato" per Venere e "nero" per Saturno; il
   bianco del venerdì e il blu del sabato sono pratica popolare senza fonte
   classica letta. Da decidere con Mauro.
5. **Rahu Kalam**: nessun verso antico letto che lo fondi; la regola è quella
   del calendario tradizionale dell'India del Sud, come la riporta Drik.
6. **Scarto storico di Drik sulle fini del nakshatra** (fino a +1,8 minuti nelle
   nascite dal 1958 al 2015, contro meno di un minuto nel 2026): la causa non
   l'ho trovata (forse un altro modello del Delta T o un arrotondamento per
   eccesso). Non tocca nessun nakshatra delle venti nascite; tocca solo chi nasce
   entro due minuti da un confine.
7. **Nakshatra del giorno**: all'alba del luogo (convenzione del panchang, testo
   stabile per tutto il giorno) o all'istante di apertura. Ho proposto l'alba; è
   una scelta, non una verifica.
8. **Abhijit**: alcuni sistemi hanno 28 nakshatra; il Tarabalam di Drik e
   Raman ne usano 27; così fa anche questa specifica.
9. **Le pagine di Drik** si leggono oggi senza difficoltà; se cambiassero
   struttura, `leggi_drik.py` andrebbe riscritto. Le pagine usate sono salvate in
   `drik/` come prova.
