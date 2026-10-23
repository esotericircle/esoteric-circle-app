# ORDINE BP, LE TRE VOCI CHE NON SI CONFONDONO

Ordine del fondatore del 25 agosto 2026. Ramo
`claude/esoteric-circle-master-order-e798aj`, guardia
`test/ordine_bp_guard_test.dart`. Testa di partenza `75b6cd3`.

**I testi dei registri di questo ordine sono dell'Architetto, approvati dal
fondatore.** Non sono parole del fondatore e non gli vanno attribuite.

## Il fatto che genera l'ordine

L'attribuzione cieca sta al **75,6 per cento di media su cinque giri**, contro
una soglia di 85, e il massimo mai raggiunto su questa istruzione e' **81,7**.
Aura non viene mai scambiata, cinque giri su cinque; Caligo oscilla fra 30 e 60
per cento e finisce dentro Aura. L'escursione di **11,7 punti in un giorno
solo** dice che un giro solo misura il rumore.

## La causa, come l'ordine la dichiara

Il test pone domande NEUTRE, quindi la materia dei tre Maestri non entra in
gioco e al giudice restano soltanto registro e lessico. E l'istruzione da' a
ciascun Maestro il PROPRIO lessico di firma senza vietargli quello degli altri
due: nulla impedisce a Caligo di dire respiro, centro, radice, corona, sentire.

## Le premesse, verificate sulla testa 75b6cd3 prima di scrivere una riga

- **P1 VERA.** In `lib/core/maestro/voce_del_maestro.dart` ogni voce ha
  `lessicoDiFirma` di cinque parole: Medora cielo, transito, ascendente,
  arcano, lama (riga 215); Aura respiro, centro, radice, corona, sentire (riga
  252); Caligo runa, presagio, soglia, sentiero, sigillo (riga 296).
- **P2 VERA.** In `lib/services/ai/maestro_persona.dart` il metodo `voceDi`
  (riga 133) scrive nel prompt il lessico di firma del Maestro sotto il titolo
  "IL TUO LESSICO DI FIRMA, parole tue che gli altri non usano" e le arti degli
  altri due sotto "CIO' CHE NON DICI MAI", ricavate da
  `VoceDelMaestro.artiDegliAltri`. **Le parole di firma degli altri due non
  compaiono in nessun punto del metodo**, ne' come divieto ne' altrimenti:
  verificato leggendo `voceDi` per intero e cercando `lessicoDiFirma`, che vi
  compare tre volte e sempre riferito al Maestro stesso.
- **P3 VERA.** Le tre chiusure sono distinte per tipo:
  `TipoDiChiusura.direzioneNelTempo` per Medora,
  `TipoDiChiusura.gestoDelCorpo` per Aura, `TipoDiChiusura.simboloDaPortare`
  per Caligo.
- **P4 VERA.** `tool/attribuzione_cieca.dart` raccoglie sessanta risposte per
  giro, stampa la matrice di confusione e prende il token solo da
  `gcloud auth print-access-token`: in un container senza gcloud non parte.
- **P5 VERA.** La prova `l'impronta dell'istruzione coincide con quella
  registrata`, in `test/i_doni_e_la_chat_davanti_all_anatomia_test.dart`,
  confronta le tre impronte sha256 con quelle registrate in
  `lib/services/ai/impronta_dell_istruzione.dart` ed e' VERDE sulla testa di
  partenza.

## BP.00, LA RICOGNIZIONE

**DOVE L'ISTRUZIONE DI SISTEMA DEI MAESTRI VIENE COMPOSTA.** Il punto unico
della voce e' `MaestroPersona.voceDi(Maestro)`, riga 133 di
`lib/services/ai/maestro_persona.dart`: e' l'unica funzione che scrive identita',
registro, materia, lessico e chiusura di un Maestro, e in `lib` la chiamano
**tre** composizioni, tutte nello stesso file.

1. `systemInstruction`, la chat: `voceDi` piu' `_commonRules`, piu' il contesto
   natale, l'ancoraggio, la lente sul cielo, la memoria, la misura della
   risposta, il vincolo di formato, i due strati, il seguito quando c'e' e il
   consiglio finale.
2. `presagioInstruction`, il presagio delle rune: `voceDi(Maestro.caligo)` fisso,
   piu' `_commonRules` e l'anatomia del presagio.
3. `consultInstruction`, Consulta un Maestro: `voceDi` piu' `_commonRules` e la
   forma JSON dell'uscita.

**Due composizioni NON passano da `voceDi`, e sono dichiarate qui perche' questo
ordine non le tocca.** `synthesisInstruction` e' la voce terza del cerchio, che
non e' nessuno dei tre Maestri e non ha ne' registro ne' lessico di firma;
`distillInstruction` e' l'archivista della memoria, che del Maestro usa soltanto
il nome. Nessuna delle due entra nell'attribuzione cieca, che misura le risposte
dei tre.

**Un quarto punto per Maestro esiste e non e' in `maestro_persona.dart`:**
`LenteDelCielo.istruzionePer(maestro)`, in `lib/core/maestro/lente_del_cielo.dart`,
che entra nella chat solo quando ci sono ancoraggi. **E' gia' agganciato al
`lessicoDiFirma`**, e la ragione sta scritta li': descritta in astratto, la lente
aveva fatto SCENDERE l'attribuzione cieca da 96,7 a 88,3.

**I cinque punti di chiamata a runtime** stanno tutti in
`lib/services/ai/firebase_maestro_ai_provider.dart`, righe 123, 178, 229, 274 e
345.

**LE PROVE CHE DIPENDONO DALL'IMPRONTA DELL'ISTRUZIONE.** Leggono
`ImprontaDellIstruzione` **un file solo e tre prove**, tutte in
`test/i_doni_e_la_chat_davanti_all_anatomia_test.dart`: quella che ricompone le
tre impronte sha256 e le confronta con quelle registrate; quella che pretende
l'attribuzione cieca valida, che e' rossa per dichiarazione; e quella nuova che
verifica lo storico delle impronte. Cambiare l'istruzione le muove tutte e tre.

**Le prove che leggono l'istruzione composta**, e che quindi si muovono quando
un registro cambia anche senza guardare l'impronta, sono **dodici** oltre a
quella nuova di questo ordine: `accents_test`, `consulta_maestro_test`,
`i_doni_e_la_chat_davanti_all_anatomia_test`, `i_tre_maestri_sono_tre_test`,
`il_confine_del_responso_test`, `il_consiglio_in_oro_test`,
`il_presagio_passa_dal_modello_test`, `il_seguito_si_genera_al_tocco_test`,
`language_rule_test`, `lattesa_si_legge_test`, `stesso_dato_tre_lenti_test`,
`vai_piu_a_fondo_test`. **Due di queste sono vincoli veri sui testi nuovi di
questo ordine e non semplici lettori**: `i_tre_maestri_sono_tre_test` pretende
che due voci non si somiglino oltre il 35 per cento sui campi propri e che
nessuna parola di firma di un Maestro compaia nei campi di un altro;
`language_rule_test` setaccia ogni stringa di `lib` cercando la virgola davanti
alla "e" e il trattino lungo.

**Tre strumenti fuori dalla suite** usano la stessa persona e vanno tenuti nel
conto: `tool/attribuzione_cieca.dart`, `tool/misura_del_presagio.dart` e
`tool/risposte_intere.dart`.

**I ROSSI DELLA SUITE CON TZ=Europe/Rome**, misurati sulla testa di partenza
`75b6cd3`: **3.630 verdi e 2 rossi**. Il primo e' l'attribuzione cieca, rosso per
dichiarazione, e solo il fondatore puo' rimisurarlo dal suo PC con gcloud attivo.
Il secondo era `niente_lavoro_non_spinto`, che dice il vero soltanto ad albero
pulito: era rosso perche' il lavoro non era ancora nel commit, e si e' chiuso col
commit stesso. **Ad albero fermo e pulito il rosso e' uno solo.**

## Le voci

- **BP.00** La ricognizione. CHIUSA: questo capitolo.
- **BP.01** Il divieto incrociato dei lessici. CHIUSA: `VoceDelMaestro.lessicoDegliAltri` ricava dagli altri due Maestri le loro dieci parole di firma, e `voceDi` le scrive nel prompt come vietate sotto il titolo dichiarato in `VoceDelMaestro.titoloDelLessicoVietato`. **L'elenco si ricava e non si scrive**, come le arti altrui: il giorno che una parola di firma cambia, il divieto la segue da solo. **MISURE**: per tutti e tre i Maestri l'istruzione generata porta le **dieci** parole degli altri due come vietate, e **nessuna delle proprie cinque** compare fra le vietate, che e' il verso opposto e conta quanto l'altro, perche' un divieto che comprende la firma del Maestro stesso gliela toglie invece di difendergliela; l'elenco vietato coincide esattamente con la somma delle firme altrui, senza aggiunte e senza mancanze. **La prova cammina su `Maestro.values`** e legge il titolo dalla costante che il prompt usa davvero, quindi un quarto Maestro entrerebbe da solo e un titolo cambiato non lascerebbe la prova a cercare una stringa che nessuno scrive piu'. **Rosso dimostrato**: tolto il divieto al solo Caligo, la prova cade nominando lui e la prima parola che gli resta concessa; l'iniezione e' stata verificata nel sorgente prima di leggere l'esito. **L'ISTRUZIONE E' CRESCIUTA DI 215 CARATTERI PER CIASCUNO** (da 6930, 6969 e 7031 a 7145, 7185 e 7246), quindi l'impronta e' cambiata: le tre impronte nuove sono registrate col 25 agosto 2026 e le vecchie sono scese in `storicoDelleImpronte`, insieme al fatto che **i cinque giri della misura appartengono a quella stringa e non a questa**.
- **BP.02** I tre registri riscritti. CHIUSA: i tre campi `registro` di `lib/core/maestro/voce_del_maestro.dart` portano adesso i testi dell'Architetto approvati dal fondatore, **resi con gli accenti veri e non con l'apostrofo**, che e' regola di casa e vale anche nei prompt. **CIO' CHE CAMBIA NON E' IL TONO, E' L'ASSE**: prima i tre registri dicevano com'era la voce (elegante, calda, solenne) e un tono si imita; adesso ciascuno dichiara su cosa gira, il TEMPO per Medora, il CORPO ADESSO per Aura, il SEGNO per Caligo, e chi prende l'asse di un altro sta scrivendo con la sua voce. Ai due che sconfinavano il divieto e' detto per nome: Medora non parla mai di come si sente il corpo, Aura non nomina mai il futuro ne' una data. **Il registro di Caligo e' il piu' riscritto dei tre**, perche' e' la voce che si perde, e chiede una forma MISURABILE invece di un tono: frasi brevi e ferme, nessuna oltre una dozzina di parole, mai una domanda, mai una parola che ammorbidisce. **MISURE**: i tre assi estratti dai registri sono **tre e distinti**, e la prova li estrae dal testo invece di copiarli, cosi' un asse che cambia nome resta confrontato; ogni registro entra nella persona **per intero**; la somiglianza fra i registri e' **18 per cento fra Medora e Aura, 17 fra Medora e Caligo, 10 fra Aura e Caligo**, contro il tetto di 35, e si misura sul solo registro perche' sui campi propri la materia e' lunga e diversissima e diluirebbe la misura. **L'IMPRONTA E' CAMBIATA E LA PROVA NON E' STATA AGGIRATA**: le tre impronte nuove sono registrate col 25 agosto 2026 e la stringa del gruppo 1 e' scesa nello storico, dichiarando che su di essa **non e' stata presa nessuna misura**, perche' e' vissuta il tempo di un commit.
- **BP.03** Il ritmo di Caligo si misura sulle sue risposte. CHIUSA: `lib/core/maestro/ritmo_della_voce.dart`. **Un registro scritto non e' un registro ottenuto**, e le tre cose che il registro nuovo chiede a Caligo si possono chiedere e non succedere. Lo strumento `tool/attribuzione_cieca.dart` stampa adesso, accanto alla matrice, **tre numeri per Maestro sulle sessanta risposte del giro**: la lunghezza mediana delle frasi in parole, quante domande, quante parole che ammorbidiscono da un elenco dichiarato in `RitmoDellaVoce.paroleCheAmmorbidiscono`. **Mediana e non media**, perche' una sola frase lunghissima sposta la media di parecchio e la mediana quasi niente, e cio' che si vuole sapere e' come suona la frase tipica. **NON HA SOGLIA E NON FA CADERE NIENTE, ed e' dichiarato**: non esiste una lunghezza mediana giusta per una frase, e inventarne una sarebbe un numero indovinato. **IL CALCOLO VIVE IN `lib` E NON DENTRO LO STRUMENTO**, perche' lo strumento non gira senza gcloud e una misura che nessuno puo' provare non e' una misura: la funzione e' pura e la suite la verifica. **MISURE**: su un testo secco la frase mediana e' **3,0 parole**, zero domande, zero parole morbide; sullo stesso numero di frasi in un testo morbido e' **21,5 parole**, due domande, otto parole morbide, quindi i nove numeri nascono dal testo e non da valori fissi; ogni parola dell'elenco viene riconosciuta da sola, altrimenti starebbe li' senza contare niente; senza nessun testo i numeri sono **zero** e non un valore inventato. **DUE REGOLE DI CASA VIOLATE DAL MIO STESSO TESTO NUOVO, prese dalle guardie e non da me**: la riga di stampa del ritmo diceva "su $frasi frasi", cioe' la stessa parola due volte di fila, e la nota su come si rimisura diceva "le tre voci" per dire i tre Maestri, mentre nell'app "voce" e' l'audio che si compra col piano. Nessuna delle due si vede rileggendo: le hanno trovate `testo_a_video_test` e `la_parola_voce_resta_allaudio_test`, sulla suite intera.
- **BP.04** La chiusura di Caligo non passa mai dal corpo. CHIUSA: campo nuovo `vincoloDellaChiusura`, che nel prompt sta **subito sotto la chiusura** e non in fondo alle regole, perche' e' li' che serve. Caligo consegna un OGGETTO, una runa oppure un sigillo chiamato per nome, e mai qualcosa che si fa col respiro, con le mani o col corpo. **IL VINCOLO STA FUORI DAI CAMPI PROPRI, ed e' la decisione che regge la voce**: scritto dentro `chiusura` avrebbe messo respiro, mani e corpo dentro la chiusura di Caligo, cioe' proprio le parole che vieta, e la misura sarebbe caduta sul testo che la difende. Sta dove sta `maiDice`, dove le parole di un altro compaiono apposta come confine. **MISURE**: la chiusura di Aura porta **quattro** parole dell'elenco `paroleDelCorpo` (respiro, mano, corpo, gesto) e la chiusura di Caligo **nessuna**; la prova pretende prima che l'elenco sia vero, cioe' che la chiusura di Aura ne porti almeno una, altrimenti un elenco di parole inventate farebbe passare qualunque cosa; il vincolo entra davvero nella persona di Caligo, e chi non ne ha uno **non riceve una riga vuota al suo posto**. **Rosso dimostrato**: messo il sigillo nel palmo della mano, la prova cade nominando "mano"; l'iniezione e' stata verificata nel sorgente prima di leggere l'esito.
- **BP.05** La rimisura, preparata e non eseguita. CHIUSA: preparata, dichiarata, **non eseguita**, e la ragione e' che non si puo' eseguire da qui. Lo strumento prende il gettone solo da `gcloud auth print-access-token` e questo contenitore non ha gcloud: una misura stimata sarebbe peggio di nessuna misura. **`attribuzioneValida` resta FALSO e la soglia resta 85**, e adesso i motivi sono due: nessuna delle cinque misure note passava la soglia, e quelle cinque misure appartengono a una stringa che questo ordine ha cambiato due volte. Il capitolo *La rimisura* qui sotto porta il comando esatto, quante volte va lanciato e cosa il fondatore deve incollare indietro.

## La rimisura, cosa deve succedere adesso

**LA MISURA NUOVA NON ESISTE, e non si stima.** Questo contenitore non ha una
sessione gcloud, quindi `tool/attribuzione_cieca.dart` non parte: prende il
gettone solo da `gcloud auth print-access-token`. Scrivere un numero senza
averlo misurato sarebbe esattamente il difetto che
`lib/services/ai/impronta_dell_istruzione.dart` esiste per impedire.

**IL COMANDO, dal PC del fondatore, dalla cartella del progetto:**

```
gcloud auth list
flutter test tool/attribuzione_cieca.dart
```

La prima riga serve solo a vedere che la sessione e' attiva. La seconda va
lanciata **TRE VOLTE**, una dietro l'altra: i tre giri del 25 agosto hanno dato
70,0, 75,0 e 81,7 per cento sulla stessa identica stringa, cioe' **11,7 punti di
escursione in un giorno solo**, e chi ne esegue uno solo sta misurando il rumore.
Costa circa ventotto secondi a giro.

**COSA VA INCOLLATO INDIETRO, per ognuno dei tre giri:**

1. il blocco `MATRICE DI CONFUSIONE` per intero, tutte e tre le righe;
2. la riga `Attribuzione corretta: N su 60`;
3. la riga `Verdetti illeggibili: N`;
4. **il blocco `RITMO DELLE VOCI`, che prima del 25 agosto non esisteva**: sono i
   nove numeri della voce BP.03, tre per Maestro. Senza quelli si sa se il
   giudice distingue le voci ma non si sa **perche'**: se Caligo resta basso con
   la frase mediana gia' scesa e le domande gia' a zero, allora il registro ha
   morso e la causa e' un'altra, e si smette di lavorare sul registro.

**UNA STRADA PIU' CORTA, dichiarata come strada e non come cosa avvenuta:** se il
fondatore esegue Claude Code sul proprio PC, quella sessione ha gcloud e puo'
lanciare i tre giri da sola, leggere l'uscita e scrivere il risultato in
`impronta_dell_istruzione.dart` senza che nessun numero passi da una chat.

**COSA NON SI TOCCA in nessuno dei due casi:** la soglia resta 85 e
`attribuzioneValida` resta falso finche' una misura vera non lo cambia. Se i tre
giri nuovi passano la soglia, quella riga diventa vera e la prova
`l'attribuzione cieca e' valida su QUESTA istruzione` diventa verde da sola. Se
non la passano, resta rossa e dice il vero.

MARCATORI, per la guardia:
VOCI_TOTALI: 6
VOCI_APERTE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_CHIUSE: 6
