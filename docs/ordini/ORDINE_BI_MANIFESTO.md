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
- **BI.01** La porta piccola sonda e comunica: prima l'email, il server dice se esiste e con quale via, chi esiste viene instradato alla sua via, chi non esiste lo sa subito e prosegue per forza l'onboarding. Nasce la callable dell'esistenza, ottava, dichiarata alla guardia delle callable. APERTA.
- **BI.02** La password di tutti: la parola Password ovunque, Hai perso la Password?, l'occhiolino per rivelare, le regole scritte e validate (almeno 8 caratteri, una maiuscola, un numero, un carattere speciale), il gestore password del dispositivo, e i bottoni del foglio leggibili coi colori di casa. APERTA.
- **BI.03** Il ricordo detto giusto: il Bentornato dice "Il Cerchio si ricorda di te", mai piu' "ti aveva tenuto tutto". APERTA.
- **BI.04** Il secondo fattore col codice numerico: l'infrastruttura server e client del codice via email, col mittente da configurare e la guida passo passo al fondatore per l'unico gesto manuale suo. APERTA.
- **BI.05** Suite, build e consegna su App Tester. APERTA.

MARCATORI, per la guardia:
VOCI_TOTALI: 6
VOCI_APERTE: 5
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_CHIUSE: 1
