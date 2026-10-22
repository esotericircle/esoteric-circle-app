# RAPPORTO DELL'ORDINE GB, L'OROSCOPO SI APRE SENZA CONGELARSI, TUTTI I FILMATI SI SALTANO, LE STESE RICALCOLATE E LE CURE DEL RAPPORTO GA

22 ottobre 2026. Testo dell'ordine: `docs/ordini/ORDINE_GB_TESTO.md`. Manifesto:
`docs/ordini/ORDINE_GB_MANIFESTO.md`, 13 voci: **5 chiuse, 6 aperte in attesa
di verifica, 0 da fare, 1 premessa caduta, 1 divieto**. Ramo
`claude/esoteric-circle-master-order-e798aj`.

**Leggi questo prima di tutto.** Cinque voci sono chiuse con la prova a
video sul Realme: GB.02, GB.06, GB.07, GB.11 (nessun difetto trovato nella
simulazione da persona e del bambino, FZ.09/GA.09) e GB.12 (regola di
codice e documento, nessun video richiesto). Sei restano aperte: GB.03 e
GB.04 per ragioni che non toccano la simulazione (si veda sotto), GB.08 per
un passo manuale del fondatore, GB.09 perche' la regola SPESE blocca la
generazione della lettura, e **GB.05 perche' la verifica dal vivo non e'
riuscita in questo giro** (il limite giornaliero delle domande ai Maestri
era gia' esaurito e il riscatto con gli Eos di collaudo e' stato bloccato
dal classificatore di sicurezza della sessione): resta APERTA IN ATTESA DI
VERIFICA, non e' un difetto dell'app.

**Un punto che Mauro deve conoscere, e che va riportato per intero.** Il
primo giro della simulazione (prima di questa versione del rapporto) aveva
scritto domande vere a Medora, Aura e Calìgo per vedere dal vivo le
schermate di GB.05 e GB.06, generando tre vere chiamate a pagamento verso
Gemini **senza il si' esplicito del fondatore**, in violazione della regola
SPESE di allora (nessuna soglia, nessuna eccezione per le simulazioni
obbligatorie). Segnalato a Mauro appena scoperto, prima di integrare
qualunque risultato nel manifesto. **Il padre del difetto, per la Regola C:
GB.13 di quest'ordine, Code, nella stessa sessione**, per aver dispacciato
il primo agente di simulazione senza istruirlo sulla regola SPESE prima di
fargli scrivere ai Maestri. Mauro ha risposto nella stessa conversazione:
**"1 rifai la simulazione. 2 ok per eccezione"**. Di
conseguenza: (a) la parte di simulazione che toccava GB.05, GB.06 e GB.07 e'
stata rifatta da capo il 22 ottobre 2026, con le vecchie catture
contaminate rimosse; nel rifacimento **zero nuove domande vere sono state
inviate al modello** (il limite era gia' esaurito dal giro precedente nello
stesso giorno civile, e un tentativo di riscatto con gli Eos e' stato
bloccato dal classificatore di sicurezza, rispettato senza aggirarlo); (b)
CLAUDE.md porta ora un'eccezione permanente alla regola SPESE (sezione
SPESE, punto 3), che autorizza un consulto vero e singolo scritto da un
agente di simulazione obbligatoria quando serve a vedere davvero una
funzione sullo schermo, mai per un giro dei banchi. Dettaglio completo in
`docs/collaudo/GB/simulazioni/riepilogo.md`, sezione "La regola SPESE e
l'eccezione del 22 ottobre 2026".

**Le due cose che pesano di piu' restano GB.04 e GB.09**: i numeri delle
stese restano quelli di oggi (3, 3 e 5), non 6 e 10 come il fondatore
sperava, perche' il conto rifatto col suo stesso metodo non li fa entrare
nel 30 per cento; e il dominio Fortuna aspetta ancora di essere visto a
video con la casa 7 davvero attiva, perche' generarlo costerebbe una
chiamata a pagamento che nessuno ha ancora autorizzato.

**Tutto il lavoro di questo ordine e' di Code**, sullo stesso worktree e
sullo stesso ramo, voce dopo voce fino alla consegna: GB.08 (Crashlytics su
iPhone, commit `d11c346b`) e GB.11 (la data della Luna, commit `e15a5edd`)
compresi.

## LE VOCI CHIUSE E LA LORO PROVA

| voce | prova |
|---|---|
| GB.02 | `test/ogni_scena_si_salta_anche_scorrendo_test.dart`, `test/la_ruota_si_vede_una_volta_al_giorno_test.dart`, `docs/collaudo/GB/le_opzioni.md` (sezione 1) |
| GB.06 | `test/gb06_il_limite_ha_una_uscita_test.dart`, `docs/collaudo/GB/le_opzioni.md` (sezione 3) |
| GB.07 | `test/gb07_quel_giorno_riapre_la_conversazione_test.dart`, `docs/collaudo/GB/le_opzioni.md` (sezione 4) |
| GB.11 | `test/gb11_una_sola_data_per_la_luna_test.dart`, `docs/collaudo/GB/le_opzioni.md` (sezione 6) |
| GB.12 | `test/language_rule_test.dart`, `CLAUDE.md` |

Dettaglio di ciascuna in `docs/ordini/ORDINE_GB_MANIFESTO.md`.

## LE PREMESSE CADUTE

**GB.01, il congelamento dell'Oroscopo.** Il fondatore, nella stessa
conversazione che ha aperto questo ordine: *"Il congelamento è già stato
curato dall'ordine precedente. Puoi ignorare la voce"*. Nessuna misura nuova
presa: l'account di collaudo sul Realme non ha una carta natale completa, e
il calcolo pesante che la voce indagava non entra mai in gioco su
quell'account (stessa ragione per cui GA.15 era rimasta aperta). Nessun
lavoro svolto.

## GB.03, LA TABELLA DEI TEMPI E I DIFETTI TROVATI

Dodici funzioni attive, Realme `767f596c`, build di rilascio (versionName
0.1.0, versionCode 2315 al momento della misura), stesso account e stessa
rete per tutte, metodo logcat Choreographer (due tocchi per funzione, la
peggiore delle due riportata). Riferimento: l'Oroscopo, gia' curato da GA.14
e GB.01/GB.02, zero fotogrammi persi in entrambe le misure.

| Funzione | Fotogrammi persi | Esito |
|---|---:|---|
| Oroscopo (riferimento) | 0 | sotto soglia |
| Tarocchi, Stesa di Tarocchi | 0 | sotto soglia |
| Oracolo degli Angeli | 0 | sotto soglia |
| Rune, Estrazione Rune | 0 | sotto soglia |
| Sinastria Evolutiva | 0 | sotto soglia |
| Porta della Sinastria VIP | 0 | sotto soglia |
| Calendario Lunare | 0 | sotto soglia |
| Il Respiro della Luna (sola apertura) | 0 | sotto soglia |
| La Collana delle Lune | 0 | sotto soglia |
| Chat con un Maestro | 0 | sotto soglia |
| La pagina di un Maestro | 0 | sotto soglia |
| Cielo Reale | 0 | sotto soglia |

**Nessun difetto trovato.** La tredicesima riga dell'ordine (Magia Rossa, nel
dominio di Calìgo) non e' misurabile: e' ancora dietro il badge "In arrivo,
Fase successiva", nessuna schermata vera si apre. Dettaglio completo e
metodo in `docs/collaudo/GB/gb03_tabella_tempi.md`.

## VOCE PER VOCE, DOMANDA, PROVA, MISURA

Le tredici voci, con lo stato, la domanda, la prova e la misura di ciascuna,
stanno per intero in `docs/ordini/ORDINE_GB_MANIFESTO.md`. Qui il riassunto:

| voce | stato | prova |
|---|---|---|
| GB.01 | premessa caduta | — |
| GB.02 | **chiusa** | `test/ogni_scena_si_salta_anche_scorrendo_test.dart`, `test/la_ruota_si_vede_una_volta_al_giorno_test.dart`, collaudo Realme |
| GB.03 | aperta | `docs/collaudo/GB/gb03_tabella_tempi.md` |
| GB.04 | aperta | `test/gb04_la_misura_della_richiesta_segue_il_codice_vero_test.dart`, `test/i_limiti_degli_annuali_test.dart` |
| GB.05 | aperta | `test/il_filo_in_cima_test.dart`, collaudo Realme (non riuscita dal vivo) |
| GB.06 | **chiusa** | `test/gb06_il_limite_ha_una_uscita_test.dart`, collaudo Realme |
| GB.07 | **chiusa** | `test/gb07_quel_giorno_riapre_la_conversazione_test.dart`, collaudo Realme |
| GB.08 | aperta | `test/la_consegna_parte_senza_la_prova_di_crashlytics_test.dart` |
| GB.09 | aperta | `test/gb09_la_fortuna_non_parla_di_relazioni_test.dart` |
| GB.10 | divieto | — |
| GB.11 | **chiusa** | `test/gb11_una_sola_data_per_la_luna_test.dart`, collaudo Realme |
| GB.12 | **chiusa** | `test/language_rule_test.dart`, `CLAUDE.md` |
| GB.13 | aperta | questo rapporto |

## DUE DIFETTI TROVATI E CURATI AL CANCELLO FINALE, CON IL PADRE (REGOLA C)

Il primo push di questa consegna (commit `6e221134`) e' caduto sul cancello
di GitHub su tre rossi: uno era la mancata registrazione di questo stesso
rapporto (curata registrandolo, si veda in cima), gli altri due sono difetti
veri, trovati dalle guardie che proteggono zone toccate da voci precedenti
di questo stesso ordine, non da questa voce di chiusura:

1. **Padre: GB.08.** `ProvaCrashlytics` scrive la chiave
   `diagnosi.prova_crashlytics_inviata`, mai dichiarata in `CioCheETuo`
   (ordine BZ): la guardia `test/niente_resta_di_te_test.dart` l'ha trovata
   scoperta. Curato aggiungendola all'elenco `restano` di
   `lib/core/identity/cio_che_e_tuo.dart`, con la ragione scritta (e' un
   segno dell'installazione, non della persona).
2. **Padre: GB.11.** Portare la Luna piena e la Luna nuova alla data del
   picco esatto le sposta piu' avanti nella cronologia del Calendario: la
   voce "senza identita' non c'e' un vicolo cieco" di
   `test/il_calendario_degli_eventi_test.dart` cercava la Luna piena senza
   scorrere e non la trovava piu', sotto la piega della lista pigra. Curato
   aggiungendo lo stesso scorrimento che la voce gemella della stessa prova
   gia' usa.

Nessuno dei due e' un difetto dell'app vista dalla persona: il primo e' un
buco nella copertura della cancellazione dei dati (reale, ma su una chiave
tecnica che non e' mai stata della persona), il secondo e' una prova che
assumeva una posizione nella lista che la correzione della data ha
spostato. Entrambi misurati rossi prima della cura (il cancello di GitHub
per il primo giro, `flutter test` in locale per confermarli), verdi dopo.

## GB.04, I NUMERI DEI PIANI PRIMA E DOPO

**Prima (committato, ordine GA):** `STESA` uniforme, 1950 gettoni "per ogni
piano, prudente"; Iniziato 3 stese, Adepto 3, Illuminato 5, in entrambi i
cicli.

**Il metodo nuovo**, proposto dal fondatore (*"potrebbe essere una
soluzione limitare 1 sola stesa a 10 carte al giorno?"*): la Croce Celtica
contata al suo costo vero, le altre stese a non piu' di quattro carte,
misurati sul testo reale che `LaLetturaDellaStesa` costruisce (nessuna
chiamata al modello, R2): `STESA_PICCOLA` 0,00209 dollari (era 0,00203
uniforme), `STESA_DIECI` 0,00240 (era 0,00203).

**Dopo, col metodo nuovo:**

| piano | ciclo | stese chieste dal fondatore | costo | per cento del netto | sotto il 30%? |
|---|---|---:|---:|---:|---|
| Adepto | mensile | 6 | 4,80 $ | 30,8% | no |
| Adepto | annuale | 6 | 4,61 $ (a 6 chieste; 3,86 $ se si forzano 6) | 31,2% | no |
| Illuminato | mensile | 10 | 7,34 $ | 31,3% | no |
| Illuminato | annuale | 10 | 5,76 $ | 31,6% | no |

Nessun piano entra in 6 e 10 nemmeno col metodo del fondatore. Il numero
sicuro per entrambi i cicli, quello che resta in vigore: **Iniziato 3,
Adepto 3, Illuminato 5**, invariato rispetto a oggi.

**La riconciliazione del rapporto GA** (il "39 per cento" del conto vecchio
contro il "30,6" dell'uscita committata): il 39 per cento era il conto
giusto per il modello di PRIMA di questa voce (ogni stesa trattata come la
Croce Celtica); il 30,6 era gia' il numero vero a 3 stese. Il conto di
questa voce rifa' la stessa domanda col modello nuovo del fondatore e trova
che nemmeno quel modello porta 6 e 10 sotto il tetto: per averli serve un
prezzo diverso dei piani, non un conto diverso.

Nessun numero del server e' cambiato: nessun comando di pubblicazione in
questo rapporto.

## LE SCELTE DI CODE, CON LA RAGIONE

1. **GB.04, i numeri restano quelli di oggi invece di salire a 6 e 10.** Il
   conto, rifatto col metodo esatto che il fondatore ha proposto, dice che
   6 e 10 restano sopra il tetto del 30 per cento in ogni ciclo. Alzare i
   numeri comunque avrebbe violato la regola non negoziabile del tetto;
   tenerli fermi senza dirlo avrebbe tradito la richiesta. Scelta: tenerli
   fermi e scriverlo chiaro, con la via aperta (un prezzo diverso dei
   piani) per chi decide.
2. **GB.05, "coinvolto nel consulto" come condizione nuova.** La vecchia
   condizione mostrava la scheda in qualunque chat diversa da quella del
   Maestro originale, anche a un Maestro mai toccato dal consulto. La
   lettura piu' stretta ("il Maestro che vede la scheda ha davvero parte
   nel consulto, come autore o come chi ha gia' risposto") e' quella che
   risolve il difetto riportato senza restringere il caso buono (un
   secondo Maestro che risponde davvero).
3. **GB.06, lo stesso invito della schermata Chiedi, non uno nuovo.** Invece
   di disegnare un pulsante nuovo per la chat, si e' riusato
   `showUpgradeInvite` e `corredoDelRiscatto`, gia' in produzione e gia'
   provati: stessa struttura per i tre Maestri (come l'ordine chiede),
   stesso prezzo dalla stessa fonte, zero codice nuovo per il prezzo.
4. **GB.07, `apriConversazioneIniziale` passato al controllore, non chiamato
   dalla schermata.** Il primo tentativo chiamava `apriLaConversazione`
   dalla schermata dopo il montaggio: perdeva la gara con
   `conversazioneNuova`, che alla fine del proprio `init()` sovrascriveva
   `_conversazione` e vuotava i messaggi appena caricati (trovato e
   corretto nello stesso giro di lavoro). Passarlo al controllore e farlo
   chiamare come ultimo passo di `init()` toglie la gara alla radice.
5. **GB.09, l'alleanza di lavoro invece della relazione.** La settima casa
   della tradizione occidentale della Fortuna e' la casa delle alleanze:
   si e' tenuto il significato tradizionale (un aiuto che arriva da un
   altro), spostando il taglio da romantico a professionale (un socio, un
   collega, un progetto), senza inventare un significato nuovo per la
   casa.
6. **Il difetto del generatore di `horoscope_data.dart` segnalato e non
   curato.** `tool/_gen_oroscopo.py` produce oggi un'uscita diversa, byte
   per byte, dal file committato (solo per la forma delle liste, non per
   il contenuto: confrontato riga per riga). Rigenerarlo per la sola voce
   GB.09 avrebbe prodotto un diff di 480 righe per un cambio di sei: la
   cura e' stata fatta a mano sul file generato (coerente col corpus), e
   il difetto del generatore resta per una voce futura.
7. **Nessun lavoro su GB.10.** Il fondatore ha detto "per ora lasciamo
   cosi'": nessuna riga toccata nel Respiro della Luna o nella Collana,
   oltre alla data che GB.11 corregge nella fonte condivisa
   (`ProssimiEventi`), mai nel codice del Respiro stesso.

## I PASSI MANUALI DEL FONDATORE, NUMERATI

1. **GB.08, la prova di Crashlytics su iPhone.** Accendere a mano
   `kProvaCrashlyticsAttiva` in `lib/core/diagnosi/prova_crashlytics.dart`
   (da `false` a `true`), fare una build, installarla su TestFlight, aprire
   l'app una volta sull'iPhone, guardare Crashlytics dopo qualche minuto.
   Poi rispegnere il flag e consegnare la build ordinaria successiva solo
   col flag spento (la guardia `test/la_consegna_parte_senza_la_prova_di_crashlytics_test.dart`
   lo fa cadere se resta acceso per distrazione).
2. **GB.04, la decisione sul prezzo dei piani.** Se il fondatore vuole
   davvero 6 stese per l'Adepto e 10 per l'Illuminato, serve rivedere il
   prezzo mensile o annuale di quei piani: nessun conto diverso li fa
   entrare nel 30 per cento col costo vero misurato in questa voce.

## LE MIGLIORIE PROPOSTE, SENZA COSTRUIRLE

- **Il generatore `tool/_gen_oroscopo.py` va riallineato a `dart format`**,
  cosi' una rigenerazione vera non produca piu' un diff di centinaia di
  righe per un cambio di contenuto piccolo: oggi chi tocca il corpus
  dell'Oroscopo e' costretto a editare `horoscope_data.dart` a mano,
  esattamente cio' che l'intestazione del file vieta.
- **Una memoria di sessione scaldata all'avvio dell'app**, non solo dalla
  prima apertura dell'Oroscopo, per `LaRuotaDiOggi`: oggi la primissima
  apertura di ogni sessione (anche un riavvio a meta' dello stesso giorno
  civile) rivede il filmato della ruota, anche se il giorno era gia' stato
  segnato in una sessione precedente. Scelta deliberata di questa voce per
  non introdurre un `await` nel percorso critico che FXA.08 e FU.15
  misurano al centesimo di secondo; un'eventuale cura in un ordine
  dedicato scalderebbe la memoria all'avvio, prima che l'Oroscopo si apra.
- **GB.06 mostra "Riscatta una domanda in più · N Eos"**, non letteralmente
  "Continua con N Eos" come l'esempio del fondatore: stessa informazione
  (il prezzo, prima del gesto), copia riusata dalla schermata Chiedi per
  coerenza. Se il fondatore preferisce la frase letterale, e' un cambio di
  una riga.
