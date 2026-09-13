# ORDINE DK, LE ULTIME CORREZIONI, LA BUILD E LA PROVA A VIDEO

**Sigla:** DK. **Data:** 13 settembre 2026. **Ramo:**
`claude/esoteric-circle-master-order-e798aj`. Segue l'ordine DJ, commit
`e1076f17`, e ne chiude le pendenze.

**Vincolo permanente:** tutta l'intelligenza a runtime gira su Gemini e
Vertex AI, mai su API Anthropic. La build di quest'ordine l'ha ordinata il
fondatore, voce DK.06.

VOCI_TOTALI: 8
VOCI_CHIUSE: 5
VOCI_SBLOCCATE_E_APERTE: 3

---

## DK.01, NESSUN TITOLO CONTIENE I DUE PUNTI. CHIUSA

**Il titolo del tema *finito* e' *"E' finito e va bene cosi'"***, senza virgola
e senza due punti. **La rassegna dei centoquarantotto titoli**, i
centoquarantaquattro dei sei temi e i quattro senza domanda, ne ha trovato un
secondo coi due punti: *"Riposati: e' lavoro anche quello"*, nel tema
*blocco*, che e' diventato *"Riposati, e' lavoro anche quello"*. Sono le parole
del fondatore con la virgola al posto dei due punti; la virgola davanti a
*e'*, verbo, non e' quella che la regola della congiunzione vieta.

**La prova per costruzione** sta in `la_scena_parla_bene`: legge tutti i
titoli, col cardinale di centoquarantotto, e nessuno puo' contenere i due
punti. **Rossa** coi due titoli di prima, verde dopo.

---

## DK.02, LE FRASI DEI TRE OGGETTI NELL'ONBOARDING. CHIUSA

**Prima di scrivere, il gesto montato.** Nella rivelazione del Maestro il
tocco funziona sempre, per tutti e tre gli oggetti: trascinare o toccare
ovunque sulla schermata fa avanzare il rito. Il soffio conta soltanto dopo
che la persona ha scelto di accendere il microfono, dall'invito a usare la
voce. **Quindi alla prima apertura il gesto che l'app aspetta e' il dito,
anche per il soffione**, e col microfono acceso e' il soffio, col dito che
funziona ancora.

| oggetto | microfono spento | microfono acceso |
|---|---|---|
| candela, Caligo | *Passa il dito sulla fiamma.* | *Soffia sulla fiamma, oppure passaci il dito.* |
| sfera, Medora | *Passa il dito sul vetro.* | *Soffia sul vetro, oppure passaci il dito.* |
| soffione, Aura | *Sfiora il soffione con il dito.* | *Soffia piano, oppure sfiora il soffione con il dito.* |

Le frasi a microfono spento sono quelle dell'ordine. Quelle a microfono
acceso dicono il soffio, col *"Soffia piano"* che l'ordine detta per il
soffione, e il tocco come ripiego dichiarato nella stessa frase: qui c'era
*"Soffia dolcemente, oppure trascina il dito per svelare"*.

**Vista e lasciata al fondatore**: il titolo sopra la frase dice *"Soffia
sulla sfera di cristallo"*, *"Soffia per spegnere la candela"*, *"Soffia per
disperdere il soffione"*, anche a microfono spento, quando il soffio non lo
ascolta nessuno. E' la lingua del rito e non la cambio senza di lui: sta nel
rapporto.

**La prova**, `test/la_rivelazione_chiede_il_gesto_del_suo_oggetto_test.dart`:
le tre frasi dell'ordine, nessuna frase a microfono spento che chieda il
soffio, ogni frase a microfono acceso col soffio e col dito, e la schermata
vera che alla prima apertura mostra la frase del suo oggetto per tutti e tre
i Maestri. **Rossa** con la frase di prima rimessa, tre prove su tre.

---

## DK.04, I BRIEFING NON PROMETTONO PIU' LA DOMANDA AL MAESTRO REALE. CHIUSA

**Autorizzata espressamente dal fondatore.** Nei quattro briefing la voce
compare soltanto in `docs/02_Briefing_Progetto_Definitivo.md`, quattro volte;
i briefing 01, 03 e 04 non la citano. **Tolta la voce e nient'altro**: il diff
del file ha tre righe cambiate e una tolta, e nessuna riformattazione.

| riga | com'era | com'e' |
|---|---|---|
| 307 | *... esclusive spirituali, Maestro reale \|* | *... esclusive spirituali \|* |
| 315 | *In piu': una domanda al mese al Maestro reale con risposta entro quarantotto ore (ponte verso i consulti premium); accesso anticipato alle nuove funzioni; ...* | *In piu': accesso anticipato alle nuove funzioni; ...* |
| 343 | *\| Domanda al Maestro reale \| No \| No \| No \| 1/mese \|* | riga tolta |
| 497 | *\| Tier 3 \| Tutto illimitato, Maestro reale, compatibilita' a tre livelli, Albero dinamico \|* | *\| Tier 3 \| Tutto illimitato, compatibilita' a tre livelli, Albero dinamico \|* |

Nella riga 315 e' uscita anche la parentesi *"(ponte verso i consulti
premium)"*, che era la spiegazione di quella voce e di nient'altro. Nessuna
prova leggeva il briefing.

---

## DK.03, LA SCENA SI CHIEDE ALL'INIZIO DELLA DISCESA. CHIUSA

**Una cosa trovata prima di cambiare.** La chiamata della scena partiva a
discesa finita, e fra quel momento e la risalita c'erano gia' la nebbia,
l'incontro e il velo. **Il limite vero era dentro la chiamata**: due secondi
per tentativo, gli stessi nella prova e nell'app, e i tempi scaduti nascevano
li'.

**Adesso la chiamata parte al tocco di Scendi**, e il modello ha **sei secondi
in tutto, contati dalla partenza, per tutti e due i tentativi**: la scena
scartata si richiede solo col tempo che resta. Fra il tocco e la risalita ci
sono gli otto secondi del filmato, la nebbia e l'incontro, e nessuno aspetta
un istante di piu'.

**I due casi dell'ordine.** **La discesa saltata**, dalla seconda volta in
poi: la chiamata e' partita al tocco di Scendi, e alla risalita si aspetta al
massimo cio' che resta dei sei secondi, con la via deterministica pronta. **Il
dito alzato a meta' discesa**: la chiamata e' una sola, partita al tocco, e
niente la annulla o la rilancia.

**La misura, stessi undici casi della voce DJ.11, col modello vero**:

| caso | scena dal modello, prima | dopo | tempi scaduti, prima | dopo |
|---|---|---|---|---|
| Una scelta da fare | 89 | 95 | 3 | 0 |
| Una persona | 97 | 95 | 0 | 0 |
| Un blocco che non si supera | 99 | 97 | 1 | 0 |
| Un tempo che non arriva | 94 | 92 | 3 | 0 |
| Una direzione da prendere | 77 | 97 | 20 | 0 |
| Qualcosa che e' finito | 66 | 100 | 34 | 0 |
| *Mia sorella diventera' presto mamma?* | 78 | 95 | 19 | 0 |
| *Devo lasciare il mio lavoro per aprire qualcosa di mio?* | 90 | 93 | 9 | 3 |
| *Perche' con mio padre finisce sempre in lite?* | 93 | 94 | 2 | 1 |
| *Da mesi non riesco a finire niente di quello che comincio.* | 90 | 95 | 1 | 0 |
| *Ho chiuso con Luca dopo sei anni, e adesso?* | 97 | 96 | 1 | 0 |
| **in media** | **88,2** | **95,4** | **93 in tutto** | **4 in tutto** |

**Da 66-99 a 92-100 discese su cento.** Le discese che restano alla via
deterministica sono scene scartate due volte dalla lettura, non attese. Le
misure da A a F restano tutte dentro le soglie: C al massimo 35,7, D al
massimo 2, E 100 in tutti i casi, F senza finestre ripetute. La prova misura
la chiamata col suo tempo, senza il filmato davanti: nell'app i sei secondi
cadono dentro la discesa.

**Le prove**, in `la_scena_nasce_dalla_persona`: la chiamata parte al tocco di
Scendi e resta una sola col dito posato e alzato e dopo il salto della
discesa; la scadenza e' una per tutti e due i tentativi. **Due rossi**: la
chiamata rimessa a fine discesa, e il secondo tentativo con l'attesa intera.

---

## DK.05, LA PROVA niente_lavoro_non_spinto TORNA VERDE. CHIUSA

**Rifatta girare a spinta avvenuta**, con la testa remota del ramo canonico a
`d8cff5c1`, verificata con `git ls-remote`: **due prove su due, verdi**. Era
rossa soltanto perche' l'ordine DJ l'aveva lasciata col giro fatto prima della
spinta. La suite intera prima della spinta: 5.127 passate, due saltate, le
prove con la rete che senza token non girano, e tre rosse, i due rossi di legge
e questa.

---
