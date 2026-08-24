# ORDINE BG, il manifesto

**IL FANTASMA DEL CERCHIO, LE PROMESSE, L'ECONOMIA VIVA.** Otto voci, dalla
BG.00 alla BG.07, sul ramo `claude/esoteric-circle-master-order-e798aj`, col
mandato esteso dell'ordine BF (le decisioni del fondatore le prende Code e le
dichiara, marcate DECISIONE COL MANDATO).

**Nota di cronaca, per onesta'.** La voce BG.01 e' arrivata dal fondatore in
due tempi: prima la segnalazione a caldo con lo screenshot, poi l'ordine
scritto. Fra i due, Code aveva gia' aperto un ordine BG a voce singola con
l'autorizzazione dichiarata in BF: quel lavoro E' la BG.01 di questo
manifesto, che ora segue la numerazione del fondatore.

## Come si legge questo file

Ogni voce porta uno stato fra cinque: CHIUSA, APERTA, FERMATA SU PREMESSA
FALSA, FERMATA IN ATTESA DI DECISIONE, FERMATA SU DECISIONE DEL FONDATORE.
In fondo i marcatori, che la guardia `test/ordine_bg_guard_test.dart` conta
sulle righe.

## BG.01, la misura chiesta dall'ordine: quale delle due?

**La prima: e' un Cerchio NUOVO con la dote, e la schermata mentiva.**
Misurato sul codice, in due meta':

1. **Con Google non esiste "email gia' in uso".** "Faccio gia' parte del
   Cerchio" con un provider federato non puo' fallire: se l'account non
   esiste, Firebase ne CREA uno nuovo in silenzio. La cancellazione di BE.07
   aveva funzionato davvero; il rientro ha fatto nascere un Cerchio vergine
   con un uid nuovo.
2. **La dote di nascita sembrava un ritorno.** `Ritrovamento` decideva
   "qualcosa da mostrare" con `Eos > 0`, ma ogni Cerchio appena nato riceve
   subito la dote (benvenuto piu' accredito del giorno, AN.07): il neonato
   era indistinguibile da un ritorno, e la scena diceva "Bentornato. Il
   Cerchio ti aveva tenuto tutto" a chi non aveva niente da ritrovare.

Niente sopravvive alla cancellazione: nessun dato, nessun saldo, nessun
traguardo. Sopravviveva solo una FRASE sbagliata.

## Le voci

- **BG.00** Il manifesto prima di tutto, con la guardia di consegna. CHIUSA: questo file e `test/ordine_bg_guard_test.dart`.
- **BG.01** Il Cerchio ricorda chi ha cancellato tutto. CHIUSA: la misura sta qui sopra (Cerchio nuovo, schermata bugiarda). La cura usa il segnale nato con BF.01: il benvenuto si accredita UNA volta nella vita di un Cerchio, quindi se l'ultima sincronia lo ha accreditato il Cerchio e' nato adesso. `QuestionAllowance.cerchioAppenaNato` (si rifa' a ogni sincronia), `Ritrovamento` non conta piu' gli Eos del neonato come cosa tenuta (carta e traguardi restano sovrani), entrambe le strade del Custode passano il segnale, e chi rientra dopo una cancellazione vede la VERITA': niente Bentornato, la riga onesta "Questo account non aveva un Cerchio: ne nasce uno nuovo, da zero, con la sua dote di benvenuto", e l'onboarding di un Cerchio nuovo. Guardia: `test/il_neonato_non_riceve_il_bentornato_test.dart`; suite intera verde con la cura (3.397 piu' il listino rimesso a posto).
- **BG.02** Il foglio del borsellino. CHIUSA, e il fondatore aveva ragione a non fidarsi: due bugie, non un conteggio rotto. (1) Il foglio a scorrimento libero saliva fino in cima e il saldo finiva SOTTO la barra sottile: ora ha un tetto che lascia liberi la fascia di stato, i trenta punti della barra e un respiro. (2) Il piano Viandante non porta approfondimenti ne' confronti (matrice: No), e il foglio li raccontava come ESAURITI ("Non ti resta nessun approfondimento. Domani torna intero": falso due volte, non li hai finiti e domani torna zero). Un limite a zero non e' un esaurimento: ora quelle righe dicono "non nel tuo piano. Si aprono salendo nel Cerchio". Le righe vere (domande 3 su 3, gettata 1 su 1) erano GIUSTE: il fondatore aveva fatto una gettata sola e il piano ne concede una, non tre (la bugia delle "tre gettate" era nel vecchio invito, gia' curata in BF.05.a). Guardia: `test/il_foglio_del_borsellino_dice_il_vero_test.dart`.
- **BG.03** Le promesse dell'app, censimento e verifica. APERTA.
- **BG.04** Gli Eos dichiarati su ogni condivisione. CHIUSA: la regola di BB.04 e' estesa a TUTTA l'app. Censiti sedici punti che condividono: tre gia' a posto o esenti (la celebrazione e la card del traguardo coi loro tre modi; lo scarico dei propri dati, che non e' un gesto da premiare), TREDICI erano senza numero e senza premio: oroscopo, archetipo, Costellazione del Viso, animale guida, gettata di rune, stesa, carta della notte, runa del tramonto, sinastria, Sigillo del Cerchio, cielo del Santuario, Soffio e parola dell'Alba. Ora c'e' `PremioDellaCondivisione`, casa unica: l'etichetta scrive sul pulsante il numero del SERVER ("Condividi · +15 Eos", motivo nuovo `condivisione_arte` nel listino, deploy fatto) e TACE quando il tetto anti farming del giorno e' raggiunto o il server non ha parlato (mai promettere un bonus che non arriverebbe); il premio si paga solo a condivisione AVVENUTA (gli aiutanti delle card ora restituiscono l'esito vero della porta), dentro lo stesso tetto di 3 al giorno, col registro scritto ("Hai condiviso..."). Guardia che ENUMERA: `test/ogni_condivisione_dichiara_gli_eos_test.dart`.
- **BG.05** Comprare con gli Eos quando il giorno e' finito. CHIUSA, DECISIONE COL MANDATO sui prezzi: il RISCATTO e' vivo per i quattro budget del giorno. Il listino e' del server (`PREZZI_DEL_RISCATTO`: domanda 80 dal listino approvato con AN, confronto 150 come "Una sinastria in piu'", approfondimento e gettata 60 decisi col mandato, sotto la domanda perche' gesti piu' brevi) e viaggia con lo stato (`listinoDelRiscatto`); il prezzo del client si ignora, vale quello del server; nella STESSA transazione del saldo il server scala il contatore del giorno, cosi' il gesto si rifa' subito (lo speso puo' andare sotto zero: e' il credito comprato, e vale anche FUORI piano, i cancelli ora guardano i rimasti e non il piano, col credito che si consuma contandolo). Le quattro porte esauste offrono la strada: gettate (col getto che riparte da solo a riscatto avvenuto), domande, confronti, approfondimenti, tutte con `showUpgradeInvite` esteso alla riga del riscatto col prezzo in chiaro, e quando il saldo non basta la riga dice quanto manca invece di sparire. Registro dei movimenti scritto ("Hai riscattato..."). FUORI dal riscatto e dichiarate: le profondita' e i periodi dell'Oroscopo e il cammino oltre il ventesimo gradino (porte di PIANO, non budget del giorno: la loro strada e' l'abbonamento) e la stesa di tarocchi (oggi non ha limite giornaliero: niente da riscattare). Server 39/39, deploy fatto (statoDelCerchio e muoviGliEos su Node 22); guardia `test/il_riscatto_compra_il_giorno_test.dart`.
- **BG.06** Retention ed engagement, le iniziative. APERTA.
- **BG.07** La coda residua. APERTA.

MARCATORI, per la guardia:
VOCI_TOTALI: 8
VOCI_APERTE: 3
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_CHIUSE: 5
