# ORDINE EJ, IL MICROFONO CHE NON TRONCA, LE VOCI DA SCEGLIERE E LE RISPOSTE CHE DICONO QUALCOSA

**Sigla:** EJ, riverificata sul ramo il 24 settembre 2026: in `docs/ordini`
non c'e' nessun `ORDINE_EJ_*` e in `test/` nessuna `ordine_ej_guard`; il ramo
remoto era a `d1d66a4c`. **Data dell'ordine:** 25 settembre 2026, con
un'aggiunta dello stesso giorno per le voci 09 e 10. **Il lavoro comincia il
24 settembre 2026 sull'orologio della macchina**: la data dell'ordine e' un
giorno avanti, ed e' dichiarata qui invece di corretta.
**Ramo:** `claude/esoteric-circle-master-order-e798aj`.

VOCI_TOTALI: 10
VOCI_CHIUSE: 3
VOCI_APERTE: 7

Le prove stanno in `docs/collaudo/EJ/`.

---

## I FATTI VERIFICATI PRIMA DI SCRIVERE UNA RIGA

### 1. Le sedici catture non sono arrivate

L'ordine dice che il fondatore allega sedici catture della 2278. **Nel
messaggio non c'erano.** Le voci da 05 a 08 partono dalle frasi che l'ordine
cita alla lettera, e il collaudo misura conversazioni nuove, non quelle.

### 2. La pronuncia di Caligo: nell'app non c'e' nessuna regola da correggere

L'ordine chiede di correggere *"ogni punto dell'app che porta la regola di
pronuncia"*. **Non ce n'e' nessuno**: in `lib/`, `functions/src/`, `assets/`,
`tool/` e `docs/` non compare nessuna indicazione di accento sul nome. Alla
voce arrivano solo il nome della voce e il modo di parlare,
`functions/src/live.ts` righe 426-448 (`LE_VOCI`). La regola sbagliata vive
solo nel file del fondatore, riga 31: *"Pronuncia il tuo nome con l'accento
sulla prima sillaba: CA-li-go."*

### 3. La riga ripetuta e le anticipazioni non le scrive Gemini: le scrive l'app

*"Ripassa fra 2 giorni, per la Luna piena."*, *"Torna domani sera: la runa
che scende e' Fehu"* e *"Torna domani: si apre la gola"* nascono in
`lib/core/maestro/consiglio_finale.dart`, `invitoDelRitorno`, righe 178-249:
l'app compone l'invito a tornare e lo mette in fondo alla riga d'oro. **La
riga d'oro sta sotto ogni risposta**, `chat_bubble.dart` riga 421, quindi lo
stesso invito si legge cinque volte di fila. Caligo nomina la runa che il
Tramonto dara' domani (`SunsetRune.estrai` sul giorno dopo), Aura il chakra
del giorno dopo (`ChakraDelGiorno.di(domani)`).

### 4. I tre dati in ogni risposta li impone una regola nostra

`lib/services/ai/maestro_persona.dart` righe 481-483 chiede che **ogni**
risposta nomini almeno un dato della persona, e se manca la chat
**rigenera** (`maestro_chat_controller.dart` righe 1136-1157, con
`VerificaAncoraggio`). Nessuna regola vieta di ripeterli.

### 5. Il LIVE non dice a Protoface a che qualita' girare

Il corpo della sessione in `functions/src/live.ts` righe 285-313 non porta il
campo `quality`: la sessione gira al predefinito, `standard` secondo la
documentazione. Protoface non pubblica i moltiplicatori dei livelli
(*"Quality tier; drives the billing multiplier"*, e basta): il costo si
misura, non si legge.

### 6. Le immagini da cui sono nati gli avatar

Nella cartella del fondatore `Avatar/Ok` le immagini `Proto-*` sono PNG da
1.700 per 1.200 pixel, `Proto-Aura-3` da 1.200 per 1.200; la figura occupa
da 983 a 1.505 pixel di larghezza.

### 7. Esplora e la regola ferrea

`docs/STATO_VIVO.md`, **Regole ferree**: *"ESPLORA E IL SUO MENU' A SCOMPARSA
NON SI TOCCANO"*, decisione del fondatore del 17 agosto 2026. La voce 09
chiede esplicitamente di cambiarla nelle chat dei Maestri: si applica **solo
li'**, e la regola ferrea prende l'eccezione per iscritto.

---

## PARTE PRIMA, IL LIVE

## VOCE EJ.01, IL MICROFONO NON TRONCA

**Cosa e' cambiato.** Il LIVE non usa piu' il riconoscitore di Android.
`lib/services/voce/l_orecchio_del_live.dart` registra la persona a 16 kHz e
decide lui quando una frase e' finita, con la regola di
`lib/features/maestri/live/il_silenzio_vero.dart`: il silenzio iniziale non
chiude niente, una frase si chiude solo dopo due secondi di silenzio vero dopo
aver parlato, un colpo breve non e' parlare. La frase va a Gemini flash-lite in
europe-west1 per la trascrizione (`LaTrascrizione`), e se Gemini non sente
parole non parte niente. Il pulsante del microfono si **tiene premuto** per
parlare senza limiti di tempo, e la frase parte quando lo si lascia.

**Tre giri sul Realme, e ognuno ha cambiato la cura.** Il portatile diceva
ad alta voce una frase di quattro frasi con pause di 1,5, 1,3 e 1,6 secondi.

- Giro 1 (`docs/collaudo/EJ/live/giro_1_realme.txt`): arrivava *"Mei d'ora
  vorrei chiederti una cosa"*, una frase su quattro. Il pulsante tenuto
  premuto invece ha portato intera una frase di 25,9 secondi con pause di 3
  secondi.
- Giro 2 (`docs/collaudo/EJ/live/giro_2_realme_pro.txt`, col registro dei
  livelli): silenzio vero fra -85 e -91 dB, voce che attacca a -42, code fra
  -58 e -75. **Con una soglia sola le code diventavano silenzio.** Cura:
  l'isteresi, 12 decibel sopra il fondo per cominciare e 4 per continuare.
  Arrivavano tre frasi su quattro.
- Giro 3 (`docs/collaudo/EJ/live/giro_3_realme.txt`): il microfono si chiudeva
  per trascrivere ogni frase, e chi riprendeva a parlare in quel secondo e
  mezzo non era ascoltato. Cura: il microfono resta aperto, e
  `lib/features/maestri/live/le_frasi_della_persona.dart` unisce i pezzi se la
  persona riprende a parlare prima che la trascrizione torni. **Arrivano
  quattro frasi su quattro**, 20,2 secondi in due pezzi riuniti; la seconda
  domanda, con una pausa di 1,8 secondi, arriva intera.

Tre difetti visti a video e curati nello stesso giro: il rumore che teneva
viva la sessione (l'orologio dei trenta secondi ripartiva a ogni frase vuota),
la trascrizione che arrivava con gli a capo, e la coda della voce del volto
che apriva una frase vuota dopo ogni risposta (0,7 secondi di attesa).
**Resta uno scarto**: il portatile dice "Medora" e la trascrizione scrive
"Mezz'ora"; il nome del Maestro non e' dato alla trascrizione, e non e' stato
provato a darglielo.

Guardie: `il_microfono_del_live_non_tronca_test.dart`, sei prove, due nate
rosse sul difetto vero misurato sul telefono;
`le_frasi_della_persona_si_uniscono_test.dart`, quattro prove, cinque innesti
su cinque rossi.

**CHIUSA.**
DOMANDA: "Quando il maestro sta per finire di parlare, il microfono si riattiva, ma mi lascia circa un secondo per parlare. Anche quando inizio a parlare nuovamente, subito dopo il microfono si disattiva e mi tronca la mia domanda che cmq viene inviata anche se ovviamente sbagliata essendo troncata."
PROVA: docs/collaudo/EJ/live/giro_3_realme.txt
MISURA: frasi della domanda di prova arrivate al Maestro: 1 su 4 nel giro 1, 4 su 4 nel giro 3 (20.240 ms in 2 pezzi); seconda domanda con pausa di 1,8 s: 1 su 1; col pulsante tenuto premuto: 4 su 4 in 25.920 ms con pause di 3 s

## VOCE EJ.02, IL SELETTORE DELLE VOCI

**Cosa e' cambiato.** Sul server, `functions/src/live.ts`: le candidate
(`LE_CANDIDATE`) scelte sulle preferenze del fondatore, anziane e profonde per
Medora e Calìgo, giovane e calma per Aura; il modo di parlare di ciascuno
(`I_MODI`); la frase di prova, uguale per tutte le candidate di un Maestro; la
voce scelta letta da Firestore, `configurazione/live.voci`, e valida solo se
e' fra le candidate. Tre funzioni nuove riservate ai fondatori,
`leVociDelMaestro`, `ascoltaUnaVoce` e `scegliLaVoce`, distribuite il 24
settembre 2026 in europe-west1. Sul telefono,
`lib/features/maestri/live/il_selettore_delle_voci.dart`: l'elenco, il tasto
per ascoltare e quello per scegliere; lo apre l'icona del timbro nella
testata del LIVE, che compare solo quando il server dice che chi entra e' un
fondatore.

Medora: Gacrux, Sulafat, Kore, Vindemiatrix, Erinome. Calìgo: Algenib,
Charon, Alnilam, Rasalgethi, Orus, Enceladus. Aura: Leda, Achernar, Despina,
Aoede, Autonoe. Ogni candidata e' registrata sulla sua frase in
`docs/collaudo/EJ/voci/`, e tutte sono state chiamate davvero in europe-west1.
**L'aggettivo "anziana" nel modo di parlare rallentava la voce**: aggiunto
"senza mai rallentare", misurato in caratteri al secondo sulla stessa frase.

**Il telefono di collaudo non e' un fondatore**, quindi nel LIVE l'icona non
compare, ed e' giusto cosi'. Il selettore e' fotografato dall'app col server
finto e le stesse candidate, `docs/collaudo/EJ/voci/selettore_medora.png`.

**APERTA IN ATTESA DI VERIFICA.** Quale voce scegliere lo decide il
fondatore ascoltandole, e il selettore non e' stato visto su un telefono di
un fondatore.

## VOCE EJ.03, I MEZZIBUSTI SFOCATI

**Cosa si e' misurato.** Le immagini da cui sono nati gli avatar sono PNG da
1.700 per 1.200 pixel (Aura 1.200 per 1.200), con la figura larga da 983 a
1.505 pixel. **Il video che Protoface manda al telefono e' di 384 per 384
pixel nei primi secondi e di 512 per 512 dopo**, a 21-25 fotogrammi al
secondo, in H264 o VP8: misurato in quattro sessioni dal registro del
telefono. Sullo schermo del Realme la finestra del volto e' di 936 per 1.170
pixel veri, e ci si vede il 61,9 per cento del video in larghezza e il 77,4
in altezza: **238 per 297 pixel di video ingranditi circa 3,9 volte**, e 317
per 396 ingranditi circa 2,95 volte quando arriva il 512.

**Le immagini sorgente non sono il limite**: la figura e' due o tre volte
piu' grande dell'intero fotogramma che arriva. Il limite e' il flusso.

**Il livello di qualita'.** Oggi la sessione gira al predefinito, standard.
Il server adesso legge il livello da `configurazione/live.qualita`, senza
build, e scrive nel registro l'uso del mese a ogni apertura
(`functions/src/live.ts`, `lUsoDelMese`). Misurato: una sessione **pro** di
155 secondi fatturati e' costata **3 crediti**, una **standard** di 165
secondi **3 crediti**: un credito al minuto, arrotondato, per tutti e due.
**E in pro il video e' arrivato uguale**, 384 e poi 512 pixel. Il livello e'
tornato al predefinito dopo la prova.

**APERTA.** La causa e' misurata, la cura no: con questo flusso un volto
grande quanto la finestra resta ingrandito tre o quattro volte. Le strade
sono due, e la scelta e' del fondatore: una finestra piu' piccola, che
ingrandisce meno, oppure chiedere a Protoface se esiste un'uscita piu' grande
di 512 pixel.

## VOCE EJ.04, SI DICE CALÌGO

Nel file del fondatore, `D:\Clienti Roogly\Rituali Cartomanzia\App\Avatar\Ok\
Protoface-Addestreamento- Avatar.txt`, e' cambiata la sola riga 31: prima
*"Pronuncia il tuo nome con l'accento sulla prima sillaba: CA-li-go."*, dopo
*"Pronuncia il tuo nome con l'accento sulla seconda sillaba: ca-LI-go,
Calìgo."*. Il file e' rimasto UTF-8 con i suoi 152 a capo CRLF.

**Nell'app** alla voce arriva il nome scritto con l'accento:
`lib/features/maestri/live/il_parlato_del_maestro.dart`, `pronunciato`, e la
frase di prova di Calìgo nel server. A video il nome resta "Caligo". **Un
indicazione nel modo di parlare non funziona**: provata, la voce la leggeva
ad alta voce (`docs/collaudo/EJ/nome/3_caligo_accento_e_indicazione.wav`).
Le registrazioni prima e dopo stanno in `docs/collaudo/EJ/nome/`, e la guardia
`il_parlato_del_maestro_test.dart` e' rossa se l'accento sparisce.

**APERTA IN ATTESA DI VERIFICA.** Come suona il nome lo giudica l'orecchio
del fondatore.

## PARTE SECONDA, LE RISPOSTE DEI MAESTRI

**Il collaudo.** `tool/collaudo_ej.dart`: sei domande vere per Maestro, a
Gemini vero in europe-west1, con la chat vera e le regole vere; ogni risposta
passa dai controlli di `tool/controlli_ej.dart` e dai giudici di
`tool/giudici_ej.dart`, che votano a maggioranza su tre e sono tarati su testi
noti. Le trascrizioni stanno in `docs/collaudo/EJ/risposte/<fase>/`, e
`tool/rigiudica_ej.dart` e `tool/grammatica_ej.dart` rigiudicano tutte le fasi
con lo stesso metro. Una fase prima e quattro dopo: 18 risposte prima, 72
dopo.

## VOCE EJ.05, NIENTE FRASI FATTE E NIENTE RIPETIZIONI

**Da dove nascevano.** La riga ripetuta la scriveva l'app, non Gemini:
`lib/core/maestro/consiglio_finale.dart` metteva l'invito a tornare sotto ogni
risposta. Adesso l'invito sta solo sotto l'ultima risposta del Maestro
(`invitoSotto`), e la riga d'oro e' il passo concreto. I tre dati li imponeva
una regola nostra, `maestro_persona.dart`, con la rigenerazione del
controller: adesso li chiede solo alla prima risposta, poi *"nominane uno
SOLO se serve"*. Le frasi vietate si tolgono anche quando il modello le
scrive, `lib/core/chat/la_risposta_ripulita.dart`.

Conti, stesso metro (`docs/collaudo/EJ/risposte/_rigiudizio.txt`, e i conti
di `dopo3` e `dopo4`): chiusure ripetute **15 prima, 0 in tutti e quattro i
giri dopo**; frasi vietate 0 prima e 0 dopo in queste conversazioni; dati
ripetuti **17 prima, poi 3, 3, 5 e 7**.

**APERTA.** Le chiusure ripetute sono sparite; i dati della persona tornano
ancora in tre-sette risposte su diciotto, e se ogni volta servissero lo puo'
dire solo chi le legge.

## VOCE EJ.06, RISPOSTE DIRETTE

**Cosa e' cambiato.** `lib/core/chat/la_risposta_nel_merito.dart`: rispondi
diretto, una massima non e' una risposta, il simbolo spiega e non sostituisce,
se non puoi rispondere dillo in una riga. `lib/core/maestro/voce_del_maestro.dart`:
tutti e tre aprono rispondendo; Medora col consiglio prima del cielo e
l'esempio sbagliato accanto a quello giusto; Calìgo con la prima sentenza come
verdetto, perche' "parli per sentenze" lo portava ad aprire con una massima
che ripeteva la domanda. La riga d'oro e' il passo concreto
(`consiglio_finale.dart`, `istruzione`). La rigenerazione per l'ancoraggio
chiedeva il dato "nella prima frase": adesso subito dopo la risposta.

Conti, stesso metro: risposte non dirette **15 su 18 prima, poi 7, 9, 10 e 7**;
senza passo concreto **13 su 18 prima, poi 1, 2, 0 e 1**. Medora oscilla fra
2 e 5 non dirette su 6 da un giro all'altro.

**APERTA.** Il passo concreto c'e' quasi sempre; la risposta diretta manca
ancora in sette-dieci risposte su diciotto.

## VOCE EJ.07, NESSUNA ANTICIPAZIONE DEI DONI

**Da dove nascevano**: `lib/core/maestro/consiglio_finale.dart`,
`invitoDelRitorno`, che nominava la runa del Tramonto di domani
(`SunsetRune.estrai` sul giorno dopo) e il centro del giorno dopo
(`ChakraDelGiorno.di(domani)`). Tolti tutti e due, e gli inviti di Calìgo e
Aura non nominano piu' nessun segno. L'istruzione dei Maestri vieta di legare
un nome di runa, carta o centro a domani. La guardia
`l_invito_non_svela_e_non_si_ripete_test.dart` scorre un anno di inviti.

**CHIUSA.**
DOMANDA: "Torna domani sera: la runa che scende è Fehu"
PROVA: docs/collaudo/EJ/risposte/_rigiudizio.txt
MISURA: anticipazioni dei doni nelle conversazioni del collaudo: 12 su 18 risposte prima, 0 su 18 in ciascuno dei quattro giri dopo (72 risposte, dati e domande diverse)

## VOCE EJ.08, L'ITALIANO CORRETTO

**Cosa e' cambiato.** Le regole di lingua che il modello rispetta quasi
sempre si fanno rispettare sempre: `la_risposta_ripulita.dart` trasforma il
trattino lungo e toglie la virgola davanti a "e". L'istruzione chiede
l'accordo fra articolo, nome e aggettivo, con l'esempio "una soglia".

Conti: errori di regola **6 su 18 risposte nel primo giro prima** (Calìgo;
le trascrizioni di quel giro sono state sovrascritte dal secondo, e il
numero sta nel conto di quella sera), 0 nel secondo giro prima, **0 su 72
dopo**. Errori di grammatica col giudice
severo, tarato su "un soglia" (`docs/collaudo/EJ/risposte/_grammatica.txt`):
**0 su 18 prima, 1 su 72 dopo**, Aura in `dopo3`: *"senti il calmo del tuo
respiro"*.

**APERTA.** Un errore vero in settantadue risposte, e l'errore del
fondatore, "un soglia", non si e' ripresentato ne' prima ne' dopo: la misura
non basta a dire che e' sparito.

## AGGIUNTA DEL 25 SETTEMBRE 2026

## VOCE EJ.09, LA BARRA "ESPLORA" NON OCCUPA SPAZIO

**Cosa e' cambiato.** La chat di un Maestro e' dichiarata in
`lib/features/shell/dove_si_vede_la_barra.dart`,
`barraNascostaAllApertura`, e la barra del Cerchio la apre ritirata
(`barra_del_cerchio.dart`, `_pilaCambiata`). La barra resta **presente**:
la regola del 6 agosto 2026 non cambia, e il movimento continuo che segue il
dito e' quello di sempre. Compare quando il dito scende sulla conversazione,
cioe' verso i messaggi di prima, e si ritira quando il dito sale, cioe'
quando si torna a leggere in avanti, e quando si tocca il campo di scrittura:
il campo manda su per l'albero la notizia `LaPersonaScrive`
(`corsa_della_barra.dart`). **Nessun temporizzatore**: la regola del 6
agosto vieta una barra che si abbassa da sola mentre il dito ci sta andando,
e "riprende a leggere" si legge sul dito, che e' la sola cosa che la persona
conosce.

Due cose servivano perche' la barra potesse comparire davvero. La lista dei
messaggi e la pagina del benvenuto adesso **scorrono anche quando ci sta
tutto** (`AlwaysScrollableScrollPhysics`): una conversazione corta non
mandava nessun gesto, e la barra ritirata non sarebbe tornata mai. E la
lista **non tiene piu' il posto alla barra**: il fondo interno e' il campo
piu' il bordo di sistema (`maestro_chat_screen.dart`, `_spazioSottoIlCampo`),
cosi' l'ultimo messaggio sta subito sopra il campo. Quando la barra compare,
il campo sale con lei e i messaggi le scorrono dietro, come prima.

La regola ferrea di `docs/STATO_VIVO.md` su Esplora prende l'eccezione per
iscritto: vale solo nelle chat dei Maestri.

**Guardato sul Realme** (`docs/collaudo/EJ/barra_e_pastiglia/`): nelle chat
di Medora, Calìgo e Aura la barra non c'e' all'apertura; scorrendo compare e
il campo sale sopra di lei; toccando il campo si ritira. La guardia
`la_barra_e_la_pastiglia_della_chat_test.dart` lo prova sui tre Maestri,
quattro innesti su quattro rossi. Tre guardie di casa che davano per scontata
la barra in vista nella chat sono state riscritte con la lapide:
`screenshot_capture_test.dart` (CI.04), `il_titolo_non_stampa_sul_contenuto_test.dart`
e `l_emblema_sta_nel_suo_riquadro_test.dart`, che era cieca.

**CHIUSA.**
DOMANDA: "le chat dei maestri partono all'apertura della schermata con il menù sotto ESPLORA visibile e non mi piace, occupa spazio inutile, il menù dovrebbe restare nascosto e compare con lo scrolling"
PROVA: docs/collaudo/EJ/barra_e_pastiglia/medora_apertura.png
MISURA: barra all'apertura: in vista prima, sotto il bordo dopo, in 3 chat su 3; il campo di scrittura sul Realme sta a 2.084 px dall'alto con la barra ritirata e a 1.748 px con la barra in vista, 336 px cioe' 112 punti restituiti alla conversazione; nella prova sui tre Maestri 112,0 punti ciascuno

## VOCE EJ.10, LA PASTIGLIA "DAL VIVO" NELLA TESTATA

**Cosa e' cambiato.** `lib/features/maestri/chat/widgets/la_porta_del_vivo.dart`:
la pastiglia col microfono e la scritta "Dal vivo" sta nella testata della
chat, **sopra** l'icona della conversazione nuova. Accanto e non in fila, ed
e' una scelta misurata: in fila avrebbe tolto al titolo novanta punti e il
nome del Maestro non ci stava piu'; impilate, il titolo cede solo la
differenza fra la pastiglia e l'icona, quaranta punti. Dal tier 2 in su e'
d'oro e apre il LIVE con la stessa chat, come la voce del menu; sotto e'
grigia col lucchetto e apre `IlFoglioDelVivo`: il busto del Maestro, le sue
parole, il pulsante *Scopri il piano dell'Adepto* che porta ai piani, e *Non
ora*. La voce *Parlami a voce* nel menu resta dov'e'.

**Il telefono non e' il cancello.** La pastiglia d'oro porta alla schermata
LIVE, e li' il server guarda di nuovo il diritto: il piano e i minuti del
mese. Letto su Firestore il 24 settembre 2026, `configurazione/live` porta
`apertoAlTier2: true`, quindi un Adepto e un Illuminato entrano davvero; se
il fondatore lo richiudesse, chi entra troverebbe la frase del Maestro che
dice che la stanza non e' ancora aperta, come dal menu dall'ordine EG.

**"Con la sua voce e il suo lessico"** e' letto come nel resto del progetto,
dove *la voce del Maestro* e' il suo modo di parlare
(`lib/core/maestro/voce_del_maestro.dart`): il foglio porta parole scritte,
diverse per ciascuno dei tre. Non suona audio: la voce viva la compone una
funzione del server riservata a chi ha il LIVE.

**Guardato sul Realme**, che ha il piano del Viandante: la pastiglia grigia
col lucchetto nelle tre chat, e i tre fogli, ciascuno col busto e le parole
del suo Maestro (`docs/collaudo/EJ/barra_e_pastiglia/`). **Lo stato d'oro non
e' stato visto sul telefono**: e' fotografato dall'app col piano portato al
tier 2, `docs/preview/ej-dal-vivo-oro-medora.png` e le altre due. La guardia
`la_barra_e_la_pastiglia_della_chat_test.dart` prova i due stati per ogni
piano, il foglio e la strada ai piani.

**APERTA IN ATTESA DI VERIFICA.** Lo stato d'oro va visto su un telefono
con un piano dal tier 2 in su, e il tocco che entra nel LIVE da li'.

---

## PROTOCOLLO DELLE GUARDIE

**Regola A.** Sei guardie nuove, tutte viste rosse con l'innesto verificato:
`i_controlli_ej_prendono_i_difetti_test.dart`,
`l_invito_non_svela_e_non_si_ripete_test.dart`,
`il_microfono_del_live_non_tronca_test.dart`,
`le_frasi_della_persona_si_uniscono_test.dart`,
`la_barra_e_la_pastiglia_della_chat_test.dart` e
`ordine_ej_guard_test.dart`. **Due sono nate rosse sul difetto vero**, misurato
sul Realme prima della cura: il fondo del microfono inchiodato a -100 dai primi
pezzi muti, e le code della voce prese per silenzio. **Un innesto non e'
scattato al primo colpo**, il fondo che risale sulla voce: si e' cambiata la
grandezza, le pause fra le parole portate a -30 come nella voce vera, mai la
soglia.

**Regola B.** Undici guardie delle zone toccate viste rosse prima di chiudere
il lavoro, con l'innesto verificato e il file ripristinato byte per byte:
`il_maestro_risponde_nel_merito_test.dart`,
`il_gesto_finale_non_nasconde_il_chiarimento_test.dart`,
`un_rifiuto_vale_per_tutta_la_conversazione_test.dart`,
`il_live_consuma_solo_i_suoi_minuti_test.dart`,
`il_live_non_e_mai_un_vicolo_cieco_test.dart`,
`la_porta_del_live_non_porta_chiavi_test.dart`,
`ogni_maestro_saluta_con_la_sua_voce_test.dart`,
`la_finestra_sul_volto_test.dart`,
`i_controlli_del_collaudo_prendono_i_difetti_test.dart`,
`una_barra_sola_test.dart` e `il_parlato_del_maestro_test.dart`. Date
aggiornate in `docs/guardie.md`. **Due cose trovate**: in
`ogni_maestro_saluta_con_la_sua_voce_test.dart` un saluto copiato da un
Maestro all'altro fa cadere solo la prova delle parole di firma, non quella
delle parole uguali; e `l_emblema_sta_nel_suo_riquadro_test.dart` **era
cieca**, il trascinamento non muoveva la lista (da 0,0 a 0,0 punti): riparata
misurando la geometria, e vista rossa. **La Regola B e' stata applicata a
lavoro gia' cominciato**, non prima di mettere mano alla zona come chiede:
lo scarto e' dichiarato qui.

**Regola C.** I padri dei difetti:

- l'invito ripetuto sotto ogni risposta e le anticipazioni della runa e del
  centro di domani: commit `927f8db0` del 4 agosto 2026, la riga del
  consiglio **entrata fuori da ogni ordine** (*"Deciso il 3 agosto, mai
  entrato in un ordine"*);
- i tre dati della persona in ogni risposta: ordine Chat 3 voce 1, commit
  `eedd9f9c` del 2 agosto 2026, con la rigenerazione del controller;
- il microfono che chiudeva la frase un secondo e mezzo dopo l'ultima
  parola: ordine EG voce 05, commit `3687c223`;
- la cecita' di `l_emblema_sta_nel_suo_riquadro`: ordine 2164 voce 6, che ha
  tolto il riquadro opaco senza cambiare la misura;
- la sessione LIVE tenuta viva dal rumore e il microfono chiuso fra una
  frase e l'altra: **ordine EJ voce 01**, la prima stesura di questo stesso
  ordine, curati prima di chiudere la voce;
- le tre guardie di casa cadute sulla barra ritirata: ordine EJ voce 09;
- quindici cadute di regole di casa sul codice nuovo (catch muti, grigio,
  misure tipografiche, accenti, trattino lungo nel sorgente, parola "voce",
  velo del Cerchio): ordine EJ voci 01, 02, 06, 08 e 10, curate nello
  stesso ordine;
- "Medora" trascritto "Mezz'ora": ordine EJ voce 01, **non curato**.
