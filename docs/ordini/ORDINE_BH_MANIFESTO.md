# ORDINE BH, LA REGISTRAZIONE CHE PREMIA, PROTEGGE E FA ORDINE

Ordine del fondatore del 24 agosto 2026, arrivato in due tempi (la seconda
parte con un blocco esplicito a lavoro non ancora iniziato: menu utente e
privacy policy). Vale il mandato esteso dichiarato con l'ordine BF: le
decisioni che spetterebbero al fondatore le prende Code sulla base di logica
e delle scelte migliori, e le dichiara. Si lavora sul ramo
`claude/esoteric-circle-master-order-e798aj`, un commit per voce, guardia
`test/ordine_bh_guard_test.dart`.

## Le parole del fondatore, registrate

Prima parte: "all'atto della prima registrazione inserire il premio di 250
Eos proprio scritto nell'invito a registrarsi, cosi' l'utente e' piu'
motivato. [...] io lascerei senza premio chi non si registra e legherei i
250 Eos solo alla prima registrazione. cosi' se ti registri li ottieni,
altrimenti non verrai premiato. subito dopo, ovviamente, vorrei una festa
dedicata alla registrazione e al premio. inoltre se all'inizio l'utente fa
come ho fatto io ovvero click su 'faccio gia' parte del cerchio' e il
sistema non rileva l'email, l'utente deve essere avvertito che l'email non
risulta registrata e che potra' fare la registrazione poco dopo oppure nel
menu' utente. io non ho ancora provato la registrazione classica con email
e vorrei che ti assicurassi che questa sia possibile farla sia come adesso,
alla fine dell'onboarding e sia successivamente dal menu' utente o da dove
ritieni piu' utile. vorrei che la registrazione con email, inoltre, sia
vincolata a un'autenticazione a 2 fattori, con invio all'email del codice
numerico. sorge il problema se un utente per guadagnare ogni volta 250 Eos,
cancellasse l'account per poi rifare la registrazione. questo dovrebbe fare
parte delle misure antifrode e anti abuso. mi raccomando queste regole devi
vederle per bene e devi tutelarmi."

Seconda parte: "vorrei che rivedessi il menu' utente in modo che sia
ordinato e completo. anche l'ordine e' importante e vorrei che la
cancellazione dell'account e dati e anche privacy policy siano in fondo o
magari in sotto menu', non direttamente accessibili, anche perche' sono poco
utilizzate e per evitare click accidentali magari chiedere piu' volte se
l'utente e' sicuro e chiedergli perche' sta eliminando i dati o l'account in
modo da avere un feedback. inoltre, gia' che ci sei, completa nel modo piu'
professionale e aggiornato legalmente tutta la parte di privacy policy. se
hai eventuali domande, trova tu la risposta migliore e professionale
possibile."

## Il fatto registrato, prima delle voci

Oggi la dote di benvenuto (250) arriva alla NASCITA del Cerchio, anche senza
registrazione (AN.07, confermato da BG.01): la promessa "registrati e ricevi
250 Eos" scritta cosi' com'e' sarebbe falsa per chi i 250 li ha gia'. Il
fondatore ha deciso la strada: il premio si LEGA alla prima registrazione e
chi non si registra non lo riceve. L'accredito del giorno (20) resta alla
nascita: il Cerchio anonimo vive, ma la dote grande si guadagna.

## Le voci

- **BH.00** Il manifesto prima di tutto, con la guardia. CHIUSA: questo file e `test/ordine_bh_guard_test.dart`.
- **BH.01** I 250 Eos alla prima registrazione, non alla nascita. CHIUSA: il server accredita il benvenuto solo a token registrato (provider non anonimo con email; il provider password pretende l'email verificata, o il premio si comprerebbe con un indirizzo inventato), il premio viaggia nel listino della registrazione con lo stato, e la risposta porta il segnale di nascita robusto (borsellino mai esistito prima della chiamata) perche' la lapide di BH.05 puo' fermare il benvenuto su un Cerchio nuovo e il ritrovamento non deve mostrare i 20 del giorno come cosa tenuta. Il client: nasce PromessaDellaRegistrazione (casa unica, numero del server, senza numero quando il server tace), scritta nei TRE inviti (foglio della custodia, passo dell'onboarding con la riga in oro posteriore alla riga sola di AQ.05, voce del menu account); il foglio per chi torna NON la porta (il suo benvenuto e' gia' stato pagato); la snackbar del Cerchio appena nato si declina sui fatti (con la dote se e' arrivata, con la verita' della lapide se e' stata fermata). Guardie: prove server 42, test/il_premio_della_registrazione_test.dart. Il deploy del server parte con la voce 08.
- **BH.02** La festa della registrazione. CHIUSA: nasce FestaDellaRegistrazione, scena piena dedicata (non una celebrazione di Sentiero: nessun Traguardo dietro), con lo scudo, il titolo Sei nel Cerchio, il premio col numero VERO del server e il volo degli Eos alla chiusura; l'ingresso unico dopoLaCustodia sincronizza la borsa e decide fra le tre verita': festa se il benvenuto e' arrivato, riga della verifica se l'email la aspetta, riga onesta della lapide se il premio non si ripete. Agganciata ai due atterraggi della custodia (foglio e passo del Risveglio). Guardia: test/la_festa_della_registrazione_test.dart.
- **BH.03** La porta piccola avverte. CHIUSA, sui due casi veri: (1) con Google e Apple non esiste il rifiuto (l'account nasce in silenzio), quindi l'avviso del Cerchio appena nato sale da snackbar a DIALOGO che si congeda con un tocco (titolo Questa email non aveva un Cerchio, corpo declinato sui fatti: dote arrivata oppure lapide); (2) con email e parola sconosciute la frase del non riconosciuto porta adesso la strada in avanti, solo sulla porta di chi torna: registrarsi tra poco alla fine del rito oppure dal menu utente. Guardia: test/la_porta_piccola_avverte_test.dart.
- **BH.04** La registrazione con email. CHIUSA: le due porte esistono e la guardia le enumera (il passo dell'onboarding e il foglio aperto dal menu utente montano le stesse vie, Google, Apple, email); la registrazione con email adesso MANDA LA VERIFICA DA SOLA dentro l'elevazione, la ricarica dell'account RINFRESCA IL GETTONE (senza, il server leggerebbe la verifica vecchia fino a un'ora e il benvenuto sbloccato non arriverebbe), e la voce del menu diventa il compimento: un foglio con due strade, rimandare l'email oppure Ho verificato, che ricarica, rinfresca e passa dalla festa della registrazione; a chi non risulta ancora verificato lo si dice. IL VINCOLO E LA SUA FORMA, dichiarati col mandato: il vincolo del fondatore (nessun premio senza prova della casella) e' VIVO, realizzato con l'email di verifica di Firebase che parte oggi senza infrastruttura nuova; il CODICE NUMERICO chiesto dal fondatore richiede un mittente email proprio (dominio con SPF e DKIM piu' un servizio di invio, per esempio l'estensione Trigger Email o SendGrid): non esiste nel progetto, e costruirlo senza mittente avrebbe prodotto codici che non arrivano. Dichiarato per la revisione: con un mittente configurato il codice numerico si innesta nello stesso foglio, stima mezza giornata piu' la configurazione del servizio. Guardia: test/la_registrazione_con_email_test.dart.
- **BH.05** Antifrode: il benvenuto una volta per email, per sempre, anche dopo la cancellazione; le regole si vedono per bene e tutelano il fondatore. APERTA.
- **BH.06** Il menu utente riordinato e completo: cancellazione e privacy in fondo o in sottomenu, conferme ripetute, il perche' della cancellazione raccolto come feedback. APERTA.
- **BH.07** La privacy policy completa, professionale e aggiornata legalmente. APERTA.
- **BH.08** Suite, build e consegna su App Tester. APERTA.

MARCATORI, per la guardia:
VOCI_TOTALI: 9
VOCI_APERTE: 4
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_CHIUSE: 5
