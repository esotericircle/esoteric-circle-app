# ORDINE BF, il manifesto

**LA CHIUSURA DI TUTTO, PRIMA DELLA REVISIONE.** Sette voci, dalla BF.00 alla
BF.06, sul ramo `claude/esoteric-circle-master-order-e798aj`. E' l'ultimo
ordine di bonifica prima della revisione delle singole funzionalita', e porta
il mandato esteso del fondatore: "se ci sono delle decisioni che dovrei
prendere io, le prende Code sulla base di logica e delle scelte migliori e
adatte". Le decisioni prese con questo mandato sono marcate DECISIONE COL
MANDATO, con la motivazione accanto.

In coda all'ordine il fondatore ha aggiunto una correzione veloce, eseguita
subito: il cuore dei preferiti non sta piu' sulle tre schermate dei sentieri,
che non sono arti da scaffale (`test/i_sentieri_non_hanno_il_cuore_test.dart`).

## Come si legge questo file

Ogni voce porta uno stato fra cinque: CHIUSA, APERTA, FERMATA SU PREMESSA
FALSA, FERMATA IN ATTESA DI DECISIONE, FERMATA SU DECISIONE DEL FONDATORE.
La voce BF.05 ha tredici lavori interni, da BF.05.a a BF.05.m, ciascuno col
suo stato: per loro e' terminale anche RIMANDATA ALLA REVISIONE, che
l'ordine ammette per nome ("eseguilo, oppure dichiaralo rimandato alla
revisione delle funzionalita' con una riga di motivo"). In fondo ci sono i
marcatori, che la guardia `test/ordine_bf_guard_test.dart` conta sulle righe.

## Le premesse, verificate prima di lavorare

### BF.01: la premessa non regge, e si dichiara

Il fondatore dice: "mi ha riportato ancora 270 Eos, che non dovevano piu'
esserci perche' avevo cancellato l'account". Verificato sul codice: **niente
sopravvive alla cancellazione**. La prova piu' forte e' la sua stessa
sequenza: la registrazione con la stessa email e' riuscita, e Firebase la
avrebbe rifiutata con "email gia' in uso" se l'account vecchio esistesse
ancora. `cancellaIlCerchio` cancella il ramo con `recursiveDelete` e
l'account con `deleteUser`; la registrazione nuova produce un uid nuovo e un
ramo vuoto. **I 270 Eos sono la dote di nascita di ogni Cerchio nuovo**:
250 di benvenuto piu' 20 di accredito del giorno del piano Viandante,
l'economia approvata con l'ordine AN voce 07 (`functions/src/borsellino.ts`,
`BENVENUTO = 250`, `ACCREDITO_DEL_GIORNO.free = 20`). Ogni Cerchio nuovo,
di chiunque, parte cosi': non e' il borsellino vecchio che torna, e' quello
nuovo che nasce con la sua dote. Il difetto vero e' che il numero non
racconta da dove viene, e la cura sta nella voce.

## Le voci

- **BF.00** Il manifesto prima di tutto, con la guardia di consegna. CHIUSA: questo file e `test/ordine_bf_guard_test.dart`.
- **BF.01** I 270 Eos dopo la cancellazione. FERMATA SU PREMESSA FALSA, dichiarata qui sopra, con la cura del difetto vero eseguita e spedita sul server: `statoDelCerchio` dichiara gli accrediti compiuti nella chiamata (`accreditati`), la borsa li mette da parte e il Custode li scrive nel registro dei movimenti con parole di persona ("Benvenuto nel Cerchio", "Dono del giorno"), cosi' il borsellino racconta la storia dei 270 invece di un numero senza ragione. Guardie: `functions/src/cerchio.test.ts` e `test/la_dote_racconta_la_sua_storia_test.dart`. Deploy di `statoDelCerchio` eseguito il 24 agosto 2026.
- **BF.02** Il peso del traguardo, strada 1 scelta dal fondatore. CHIUSA: l'alone torna sul Loto in `journal_dall_arte.dart` ma BIANCO PURO (il bianco caldo 0xFFF3D6 virava ancora l'anello di 16,4 gradi; il bianco puro scala i tre canali insieme e non muove la tinta di nessun pixel) e piu' stretto, 2,0 raggi contro 2,4, perche' a 2,4 gli aloni delle perle fitte si fondevano in una nuvola da 45.049 pixel. Mediana del Loto da 911 a 3.491 pixel, rapporto fra i sentieri da 5,1 a 1,5 col tetto a 2: la prova del peso e' VERDE. Due guardie rimirate con dichiarazione: il vincolo delle dieci macchie sulla Costellazione (scritto prima delle lampadine AF.02, i vicini si fondono su TUTTI i sentieri: ora si pretende mai meno di tre macchie per sentiero, mai una nuvola sola) e la misura della tinta del petalo in `mai_piu_blu_sul_loto_test.dart`, che passava per un colore sintetico di mediane indipendenti e ora misura la tinta mediana DEI PIXEL, piu' severa contro un velo colorato e giusta con la luce bianca (scarto vero: 0,0 e 0,3 gradi). Anteprime rigenerate e guardate.
- **BF.03** La riconciliazione di tutti i manifesti. CHIUSA: censite 63 voci non terminali su 16 manifesti (AC, AX, T, U, e le fermate sparse da AD ad AV) con quattro ricognizioni sul repo, e ognuna voltata con la dichiarazione datata: 54 chiuse perche' assolte da ordini successivi o perche' il collaudo atteso e' avvenuto (i collaudi del fondatore dalle build 2180 alla 2200 sono la catena documentata nei manifesti), 8 voltate su decisione del fondatore che le ha superate (AT.04/08/09 e U.02 con la festa unica, AX.08 con la parola che resta, AO.02 gia' contata fra le chiuse, AC.09 il rosso ammesso di Vertex, AN.05 il listino che si aggancia alla revisione), 1 gia' su premessa falsa. Le guardie AC, U e AN sono state estese al quinto stato (FERMATA SU DECISIONE DEL FONDATORE) per dire la verita' senza travestirla da chiusura. Tutte le 28 guardie d'ordine sono VERDI, comprese le quattro rosse per legge.
- **BF.04** I rossi residui della suite. APERTA.
- **BF.05** I lavori lasciati indietro, enumerati. APERTA: lo stato dei tredici sta qui sotto.
- **BF.06** Il giro finale di completezza. APERTA.

## I tredici lavori di BF.05

- **BF.05.a** Le rune concordate e mai eseguite (spazio sotto le pietre, pulsanti che restano, responsi tagliati, presagio prima delle bolle, sigillo a una sola asta). APERTA.
- **BF.05.b** La meditazione non ha una fine (ordine P voce 35), coi tre dati mai registrati e i cinque gradini dormienti. APERTA.
- **BF.05.c** Il campo della chat trasparente. CHIUSA: la riga del compositore sfumava piena solo al 35 per cento dell'altezza, e coi Maestri grandi di BD la figura e la coda del saluto si leggevano fra i controlli. Il velo ora e' pieno (98 per cento) gia' al 12 per cento: resta la dissolvenza in cima che evita lo scalino, e la fascia dei controlli e' muta. La prova differenziale dell'opacita' e' estesa alla fascia intera del compositore con tolleranza percettiva di 8 livelli: zero pixel fantasma misurati. Anteprime della chat rigenerate.
- **BF.05.d** La ridondanza nelle schede delle rune. CHIUSA: le glosse del getto sul telo non ripetono piu' il titolo, dicono il PESO della posizione nella lettura ("la voce che pesa di piu'", "la voce di mezzo", "la voce piu' lieve"), che e' la regola del telo e l'informazione che il titolo non porta. Vale anche nel presagio ("Per la voce che pesa di piu', ..."). Prove del telo e della lingua verdi.
- **BF.05.e** La prova dell'occlusione estesa al dominio e all'Oroscopo. APERTA.
- **BF.05.f** La verifica BackdropFilter su Impeller. APERTA.
- **BF.05.g** Analyze da 70 a 128 avvisi, mai esaminato voce per voce. APERTA.
- **BF.05.h** I vuoti verticali, 138 in 54 file all'ultima misura. APERTA.
- **BF.05.i** La CI: Flutter fissato per numero e chat-screenshot.yml esaminata. APERTA.
- **BF.05.j** La condivisione vera. FERMATA SU PREMESSA FALSA: il difetto era gia' curato dall'ordine AN voce 08. `PortaDellaCondivisione.avvenuta` legge l'esito di share_plus e paga SOLO su `ShareResultStatus.success` (dismissed e unavailable non pagano, con la prudenza dichiarata nel file); `condividiIlTraguardo` segna e incassa solo dopo il vero, e l'invito non si paga alla condivisione perche' l'attribuzione non esiste. Guardia verde: `test/i_tre_pulsanti_condividono_davvero_test.dart`.
- **BF.05.k** Il rialzo di Node e di firebase-functions (Node 20 dismesso il 30 ottobre 2026). APERTA.
- **BF.05.l** Il grigio del Coming soon e il grigio del Premium. CHIUSA: verificati a schermo col metodo dei pixel, non per fiducia. Il velo di fondo e' lo stesso per costruzione e va bene cosi': a distinguere le strade sono i segni sopra, e la prova nuova `test/i_due_grigi_si_distinguono_test.dart` rende la coppia e misura 385 pixel di lucchetto dorato al centro del premium contro zero sul Coming soon, coi badge "Premium" e "Dietro il velo" al loro posto.
- **BF.05.m** I tre pezzi dell'identita' mai registrati come gesti. FERMATA SU PREMESSA FALSA: l'ordine BD voce 05 li ha gia' registrati alle loro porte. Il Sigillo del Cerchio e la Luna di nascita si accendono nel Passaporto (`cosmic_passport_screen.dart` accende `sigillo_del_cerchio` e `luna_natale` alle porte vere), il nome proprio al primo saluto (`greeting_banner.dart` accende `nome_proprio`). Guardia gia' in vigore: `test/i_gradini_maturano_alle_loro_porte_test.dart`.

## I rossi dichiarati (BF.04)

Si compila quando la voce BF.04 si chiude, dopo BF.02 e BF.03. Ogni rosso che
resta portera' qui il suo motivo e il suo orizzonte.

## Il giro finale (BF.06 e gli esiti rimandati qui)

Si compila quando le voci si chiudono, un ritrovamento per riga, con l'esito.

MARCATORI, per la guardia:
VOCI_TOTALI: 7
VOCI_APERTE: 3
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 1
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_CHIUSE: 3
LAVORI_BF05_TOTALI: 13
LAVORI_BF05_APERTI: 8
