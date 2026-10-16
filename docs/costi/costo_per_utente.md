# Quanto costa un utente che usa tutto

Ordine EW, voce EW.05, 2 ottobre 2026.

> *"Il tier 1 spende 9,99 euro al mese, hai già calcolato il suo consumo medio
> o massimo? ... a quante persone tier 1 corrispondono 95 dollari o quanto mi
> costa un utente che sfrutta tutto al massimo? Tieni presente che la voce live
> Protoface è solo dal tier 2 in su ed è cmq limitato."*

## In breve

| Piano | Prezzo al mese | Modello, tutto al massimo, 30 giorni | Se ogni uso cade al suo massimo | LIVE coi minuti del piano | **Totale al massimo** | Sul prezzo |
|---|---|---|---|---|---|---|
| Viandante | 0 | 0,84 $ | 2,02 $ | 0 | **0,84 $** (fino a 2,02) | gratuito |
| Iniziato | 9,99 € (11,29 $) | 5,66 $ | 11,56 $ | 0 | **5,66 $** (fino a 11,56) | 50 per cento (fino a 102) |
| Adepto | 19,99 € (22,58 $) | 9,77 $ | 20,58 $ | 2,13 $ | **11,90 $** (fino a 22,71) | 53 per cento (fino a 101) |
| Illuminato | 29,99 € (33,88 $) | 26,40 $ | 56,74 $ | 5,32 $ | **31,72 $** (fino a 62,06) | 94 per cento (fino a 183) |

- **95 dollari al mese sono circa 17 Iniziati che usano tutto, tutti i giorni**
  (8 se ogni uso costasse il suo massimo misurato). Un Iniziato che usa tutto
  costa 5,66 dollari al mese di Gemini, il 50 per cento dei suoi 9,99 euro
  lordi; se ogni uso cadesse al suo massimo misurato, 11,56, poco piu' del
  prezzo.
- **La voce che pesa di piu' e' la gettata di rune**: venti al giorno per
  l'Iniziato, 0,0060 dollari l'una, sono **quasi due terzi** del suo costo
  massimo (3,61 dollari su 5,66).
- **L'Illuminato al massimo puo' costare piu' di quanto paga** se ogni uso
  cade al suo massimo (62 dollari contro 34), e quasi quanto paga nel caso
  medio (32 contro 34): 50 domande e 50 gettate al giorno.
- **Per il caso peggiore del LIVE, oggi senza un tetto al mese**, vedi
  `docs/costi/il_minuto_del_live.md`: i minuti del piano non scendono mai.

Questo e' il **massimo**, una persona che usa ogni limite ogni giorno per
trenta giorni. L'utente medio usa una parte di questi limiti: la stima dei
30 giorni (`docs/costi/stima_costi_30_giorni.md`) ha misurato circa 5 dollari
di costo dell'app in un mese per tutti gli utenti di collaudo insieme.

## Come si e' fatto il conto

**Il costo per uso** e' quello misurato col codice vero (voce EW.04,
`docs/costi/costo_per_funzione.md`), **senza la cache**, cioe' come se ogni
domanda arrivasse sola e pagasse l'ingresso intero: e' il conto del caso
peggiore. Con la cache misurata al banco il massimo dell'Iniziato scende a
3,88 dollari al mese. **La colonna "se ogni uso cade al suo massimo"** usa per
ogni gesto il costo piu' alto dei venti usi misurati: e' un tetto, non un caso
realistico. **Il cambio**: 1,1298 dollari per euro, riferimento BCE del 1
ottobre 2026. **I prezzi dei piani** sono lordi: IVA e commissione dello
store non sono tolte.

Il calcolo sta in `tool/i_conti_del_costo_ew.py`, l'uscita in
`docs/costi/i_conti_del_costo.txt`.

## La giornata al massimo, voce per voce

Limiti dal codice (`lib/core/entitlement/plan_catalog.dart`, le righe della
matrice; i budget del server in `functions/src/budget.ts`), costo al giorno in
dollari, medio per uso senza cache.

| Gesto | Viandante | Iniziato | Adepto | Illuminato | Costo per uso |
|---|---|---|---|---|---|
| Domande a un Maestro (chat e LIVE insieme) | 3 | 5 | 10 | 50 | 0,0052 senza memoria, 0,0069 con la memoria |
| Titolo della conversazione (al massimo uno per domanda) | 3 | 5 | 10 | 50 | 0,00002 |
| Vai piu' a fondo | 0 | 3 | 10 | 30 | 0,0043 |
| Confronti (il Consiglio dei tre Maestri) | 0 | 3 | 5 | 20 | 0,0025 |
| Stese dei tarocchi | 1 | 4 | 7 | 20 | 0,0021 |
| Gettate di rune | 1 | 20 | 30 | 50 | 0,0060 |
| Discese del Viaggio | 1 | 1 | 1 | 2 | 0,0035 |
| Segni dell'animale | 1 a settimana | 3 a settimana | 1 | 5 | 0,0001 |
| Sigilli fatti, riformulati e compiuti (il limite e' lo spazio: 1, 2, 3, 5 vivi; si conta che si rifacciano tutti ogni giorno) | 1 | 2 | 3 | 5 | 0,0007 |
| Lettura del mese dei Ricordi | 0 | 1 al mese | 1 al mese | 1 al mese | 0,0001 |
| **Al giorno** | **0,028 $** | **0,189 $** | **0,326 $** | **0,880 $** | |
| **In 30 giorni** | **0,84 $** | **5,66 $** | **9,77 $** | **26,40 $** | |

Dettaglio dell'Iniziato, al giorno: gettate 0,1203; domande 0,0347; Vai piu' a
fondo 0,0129; stese 0,0083; confronti 0,0075; discese 0,0035; sigilli 0,0014;
titoli 0,0001; segni 0,00005.

**Non chiamano nessun modello**, e per questo non sono nel conto: la carta
singola dei tarocchi, la sinastria VIP, l'oroscopo (Breve e Lunga escono dal
corpus), il nutrimento dell'animale, la carica dei sigilli, l'oroscopo per gli
amici, i Rituali del giorno.

## La voce e il LIVE, solo per Adepto e Illuminato

La voce dei Maestri esiste solo nel LIVE. **Ogni turno del LIVE costa una
domanda del giorno** (decisione del fondatore, ordine EQ voce 07), quindi le
risposte dette nel LIVE sono comprese nelle 10 e 50 domande della tabella, non
si aggiungono. Il LIVE aggiunge il volto, la voce e l'ascolto: 0,0213 dollari
al minuto in conversazione (voce EW.07, misurato sul Realme).

| | Adepto | Illuminato |
|---|---|---|
| Minuti al mese nel codice | 100 | 250 |
| Se usati tutti | 2,13 $ | 5,32 $ |
| Minuti per sessione | 20 | 20 |

Nel totale sopra il LIVE e' sommato coi minuti del codice. **Oggi quei minuti
non scendono** (difetto di EG.06, `docs/costi/il_minuto_del_live.md`): un
Adepto puo' tenere il LIVE aperto senza un tetto al mese, a 0,0125 dollari al
minuto senza conversazione.

## Le funzioni pagate con gli Eos, a parte

Gli Eos si guadagnano ogni giorno (20, 40, 60 e 100 al primo avvio, per piano,
`functions/src/borsellino.ts`) e si spendono per un uso oltre il piano: una
domanda 80 Eos, un Vai piu' a fondo 60, un confronto 150, una gettata 60, una
stesa 150, una sinastria 150. Gli acquisti veri di Eos non sono attivi
(`lib/core/entitlement/pacchetti_di_eos.dart`: il pacchetto da 300 Eos e'
dichiarato a 2,99 euro).

**Il massimo che gli Eos del giorno aggiungono al costo**: spesi tutti in
gettate, 100 Eos dell'Illuminato fanno 1,67 gettate al giorno, 0,010 dollari,
**0,30 al mese**; 40 Eos dell'Iniziato, 0,67 gettate, **0,12 al mese**.
Quando gli acquisti saranno attivi, 300 Eos comprati a 2,99 euro valgono al
massimo 5 gettate, 0,03 dollari di modello.

## I limiti del codice contro il Briefing §22

Il Briefing (`docs/02_Briefing_Progetto_Definitivo.md`, sezione 22) e la
matrice del codice non dicono le stesse cose. **Le differenze si elencano, non
si correggono** (l'ordine EW non cambia nessun limite):

| Riga | Briefing §22 (Free, Tier 1, Tier 2, Tier 3) | Codice (Viandante, Iniziato, Adepto, Illuminato) |
|---|---|---|
| Domande a un Maestro | 1, 5, 10, illimitate al giorno | 3, 5, 10, **50** al giorno |
| Tarocchi carta singola | 1, 3, illimitati, illimitati | 1, 3, 30, 50 al giorno (e il limite non e' applicato: `RitualAllowance` non ha chiamanti) |
| Stese complete | Eos pieno, Eos scontati, 5 al giorno, illimitate | 1, 4, 7, 20 al giorno |
| Rune, I-Ching, Pendolo | Eos, Eos scontati, inclusi, inclusi | gettate 1, 20, 30, 50 al giorno |
| Sinastria | 3, 5+, 5, illimitata al giorno | 3, 5, 5, 25 al giorno |
| Oroscopo settimanale | Base, Dettagliato, Dettagliato, Dettagliato | il Viandante non ce l'ha |
| Cosmic Journal | Base, Completo, Completo + AI, Completo + AI + report | Cammino e Ricordi; con la lettura del mese dall'Iniziato; il report all'Illuminato |
| Voce AI dei Maestri | No, No, Esclusiva, Si' | uguale, e solo nel LIVE |
| Righe del codice che il Briefing non ha | | Vai piu' a fondo, confronti, discese e segni del Viaggio, sigilli, oroscopo per gli amici, minuti del LIVE (100 e 250 al mese) |

**Le card dei piani** dicono a loro volta cose diverse dalla matrice:
l'Iniziato "Eos scontati" per le stese contro 4 al giorno, l'Adepto "5 stese"
contro 7, l'Illuminato "50 stese" contro 20, e l'Adepto "Oracoli secondari 30
al giorno" senza un contatore nel codice.

## I tetti dell'Illuminato

**Ogni uso che chiama il modello ha un numero anche per l'Illuminato**: 50
domande, 30 Vai piu' a fondo, 20 confronti, 20 stese, 50 gettate, 2 discese, 5
segni, 5 sigilli vivi. **Senza un numero** restano solo gesti che non chiamano
nessun modello (il nutrimento, la carica dei sigilli, l'oroscopo per gli
amici) e **i minuti del LIVE**, che hanno un numero (250) che il server non fa
scendere. Sopra il piano il Viaggio ha il suo tetto tecnico (10 discese e 10
segni, voce EW.02); le altre funzioni non ne hanno uno.
