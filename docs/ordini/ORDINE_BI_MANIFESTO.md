# ORDINE BI, LA PORTA CHE SONDA, LA PASSWORD DI TUTTI, IL RICORDO DETTO GIUSTO

Ordine del fondatore del 24 agosto 2026, dal collaudo della 2203. Vale il
mandato esteso di BF. Ramo `claude/esoteric-circle-master-order-e798aj`, un
commit per voce, guardia `test/ordine_bi_guard_test.dart`.

## Le parole del fondatore, registrate

"La registrazione non deve essere chiesta all'avvio, alla prima schermata:
esiste gia' la richiesta alla fine dell'onboarding. All'inizio deve solo
controllare che effettivamente l'email dell'utente sia gia' presente nel
server e comunicato all'utente. Se non esiste, l'utente deve proseguire per
forza con l'onboarding. Questa volta ho provato a fare la registrazione con
email: perche' mi chiede la parola d'accesso e non la Password che usano
tutti? Cosi' confondi l'utente? e anche subito sotto, che significa 'Ho
perso la parola'? Scrivi come tutti 'Hai perso la Password?'. Inoltre nel
campo password dovrebbe esserci l'icona occhiolino per rivelare o meno la
password perche' l'utente deve essere certo di quello che scrive. Inoltre
la password deve essere di minimo 8 caratteri, almeno una maiuscola, almeno
un numero e almeno un carattere speciale e devi scrivere queste regole e
validarle. E deve esserci la possibilita' di essere memorizzate nel gestore
password del dispositivo. Inoltre annulla o custodisci non si leggono con
il colore blu. [...] IL MODULO DI REGISTRAZIONE TRAMITE EMAIL NON FUNZIONA!
ti avevo chiesto anche il 2 factor. [...] E visto che mi e' stata rifiutata
la registrazione con email, ho proceduto con la registrazione con google
(che e' la stessa email) e a questo punto, mi e' comparsa la schermata
BENTORNATO MAURO, con scritto che il Cerchio ti aveva tenuto tutto (da
sostituire con 'Il Cerchio si ricorda di te') e con la bolla con quello che
si ricorda di me: MA COME FA A RICORDARSI DI ME SE E' LA PRIMA VOLTA CHE
ACCEDO? [...] Sistema quello che ti ho segnalato e quello che eventualmente
hai lasciato in coda."

## I fatti misurati, prima delle voci

1. **Il "modulo di registrazione rifiutato" era una porta d'accesso.** Il
   fondatore ha usato la porta "Faccio gia' parte del Cerchio" con email e
   password nuove: quella porta fa un accesso (signIn), non una
   registrazione, e ha risposto "non troviamo un Cerchio con queste
   chiavi". Il provider email sul progetto e' ABILITATO (verificato via
   API admin): il difetto non e' tecnico, e' di disegno, ed e' esattamente
   quello che il fondatore descrive: la porta deve sondare e comunicare,
   non sembrare un modulo.
2. **Il Bentornato diceva il vero, ma nessuno poteva capirlo.** L'account
   Google del fondatore esiste sul server: creato alle 11:21 UTC del 24
   agosto, durante il collaudo di BG sulla 2202 (la porta piccola con
   Google crea in silenzio), ultimo accesso alle 15:42, il collaudo della
   2203. Non era la prima volta: era il Cerchio nato stamattina, con la
   sua dote. La frase "ti aveva tenuto tutto" resta comunque sbagliata di
   tono e va sostituita come chiede il fondatore.

## Le voci

- **BI.00** Il manifesto prima di tutto, con la guardia. CHIUSA: questo file e `test/ordine_bi_guard_test.dart`.
- **BI.01** La porta piccola sonda e comunica. CHIUSA: la porta di chi torna non mostra piu' un modulo, chiede PRIMA l'email e la controlla col server (callable esisteIlCerchio, con tetto di dieci sonde al giorno per account contro l'enumerazione, costo dichiarato e scelto dal fondatore); chi risulta entra con la SUA via (Google, Apple, oppure il campo Password con occhiolino e Hai perso la Password?), chi non risulta legge in chiaro che l'email non e' registrata e prosegue per forza il rito (bottone Prosegui il rito, nessuna via mostrata: niente account creati in silenzio); se il server non risponde la sonda lo dice e apre le tre vie classiche, mai un vicolo cieco. La guardia delle callable sale da sette a nove con la dichiarazione. Guardia: test/la_porta_sonda_e_la_password_test.dart.
- **BI.02** La password di tutti. CHIUSA: il campo si chiama Password, la via persa dice Hai perso la Password?, l'occhiolino rivela e copre, la regola del fondatore (8 caratteri, maiuscola, numero, carattere speciale) sta SCRITTA sotto il campo e VALIDATA a voce in guaioDellaPassword (casa unica, usata anche dal cambio Password del menu, il cui vecchio cancello sotto i sei caratteri era MUTO); il gestore password del dispositivo riceve AutofillGroup, i suggerimenti giusti e il segnale di chiusura; i bottoni del foglio (Annulla, Registrati) portano i colori di casa invece del blu del tema; la voce del menu diventa Cambia la Password e il foglio della registrazione si intitola Registrati con la tua email. Guardia nella stessa prova della voce 01.
- **BI.03** Il ricordo detto giusto. CHIUSA: la scena del ritrovamento dice "Il Cerchio si ricorda di te." e la frase del possesso e' vietata dalla guardia. Il caso del fondatore resta spiegato dal fatto misurato in testa a questo manifesto: il suo Cerchio esisteva davvero, nato nel collaudo del mattino.
- **BI.04** Il secondo fattore col codice numerico. CHIUSA, con l'unico gesto manuale dichiarato: nasce la callable secondoFattore (una sola, due operazioni): manda genera il codice di sei cifre, ne conserva l'IMPRONTA con scadenza di dieci minuti (mai il codice in chiaro, cinque invii al giorno) e lo spedisce dal mittente in Secret Manager (SMTP_URL, oggi un segnaposto: senza mittente il server DICHIARA mittente_non_configurato e il client ripiega sul collegamento di Firebase, mai un codice promesso che non arriva); verifica confronta l'impronta (cinque tentativi, il codice buono si consuma) e a verifica riuscita rende VERIFICATA l'email dell'account, cosi' il benvenuto arriva dalle regole di BH.01 senza una seconda strada per il premio. Il client: dopo la registrazione con email parte il codice e si apre il foglio delle sei cifre (autocompilazione oneTimeCode, Mandamelo di nuovo, guai declinati per motivo), a verifica compiuta il giro si rifa' e la festa si apre. IL GESTO DEL FONDATORE, guidato nel responso: creare la credenziale del mittente (password per le app di Gmail oppure una chiave SendGrid) e darla a Code, che imposta SMTP_URL e ridispiega: dieci minuti, nessuna conoscenza tecnica.
- **BI.05** Suite, build e consegna su App Tester. APERTA.

MARCATORI, per la guardia:
VOCI_TOTALI: 6
VOCI_APERTE: 1
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_CHIUSE: 5
