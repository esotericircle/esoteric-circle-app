# ORDINE AX, il manifesto

**L'INGRESSO, IL MONDO, I DONI.** Sedici voci, dalla AX.00 alla AX.15, sul ramo
`claude/esoteric-circle-master-order-e798aj`.

**Nasce dai collaudi del fondatore sulla 2191.** Due regole dell'ordine valgono
quanto le voci: **AX.01 e' la prima e si consegna anche se le altre non sono
pronte**, e **il controller della parallasse non si tocca**, perche' il cielo e'
chiuso con l'ordine AW.

## Come si legge questo file

Ogni voce porta uno stato fra cinque: CHIUSA, APERTA, FERMATA SU PREMESSA
FALSA, FERMATA IN ATTESA DI DECISIONE, FERMATA SU DECISIONE DEL FONDATORE. In
fondo ci sono i marcatori, che la guardia `test/ordine_ax_guard_test.dart`
conta sulle righe.

## Le voci

- **AX.00** Il manifesto prima di tutto. Stato: CHIUSA
- **AX.01** Chi torna non riesce piu' a entrare. Stato: CHIUSA
- **AX.02** I Maestri, misurati sui pixel e non sul layout. Stato: APERTA
- **AX.03** Il titolo su una riga, e la Luna si tocca. Stato: APERTA
- **AX.04** Il foglio del borsellino dice tutto, e invita. Stato: APERTA
- **AX.05** I movimenti del borsellino. Stato: APERTA
- **AX.06** Gli Eos dichiarati sui pulsanti. Stato: APERTA
- **AX.07** Il Passaporto porta a sbloccare. Stato: APERTA
- **AX.08** La parola del giorno sparisce. Stato: APERTA
- **AX.09** L'Alba non manda al Soffio. Stato: APERTA
- **AX.10** "Attiva la posizione" non attiva niente. Stato: APERTA
- **AX.11** Il Soffio non somiglia all'Alba. Stato: APERTA
- **AX.12** Le notifiche dei doni. Stato: APERTA
- **AX.13** Il menu' Account nelle Impostazioni. Stato: CHIUSA con l'ordine AZ voce 11
- **AX.14** Il luogo di nascita e' un paese, non un planisfero. Stato: APERTA
- **AX.15** L'icona dell'app. Stato: APERTA

## Cosa e' stato fatto, voce per voce

### AX.01, chi torna riesce a entrare

**Due cause, non una, e nessuna era quella che sembrava.** Il fondatore
disinstallava, reinstallava, toccava "Faccio gia' parte del Cerchio" e sceglieva
lo stesso account Google: l'accesso non riusciva, e da quel momento non
funzionava piu' **nemmeno la registrazione**.

**Causa uno: chi torna passava dalla porta di chi custodisce.** La schermata di
rientro chiamava `eleva`, cioe' `linkWithCredential`, che ATTACCA l'identita'
all'anonimo di questo telefono. Quell'identita' pero' era gia' di un altro
Cerchio, quindi il collegamento **falliva per forza**, non per un difetto di
rete. La via d'uscita offerta era un secondo tocco che riusava
`_riconosciuta.credenziale`, **cioe' la credenziale gia' spesa dal tentativo
appena fallito**: su Google un token speso non entra piu'.

**Causa due, ed e' quella che chiudeva la porta alle spalle:**
`GoogleSignIn().signIn()` lascia il client "gia' entrato". Alla chiamata dopo
restituisce lo stesso account **senza riaprire il selettore**, con un token che
puo' essere gia' stato speso. Non era la registrazione a rompersi: era Google
che rispondeva con cio' che aveva in mano.

**La cura.** Una via nuova, `entraDirettamente`, che chiede una credenziale
FRESCA e fa `signInWithCredential` invece di collegare; e un `dimentica()` sulla
porta del flusso, chiamato **prima** di ogni richiesta e **dopo** ogni
fallimento, anche nell'elevazione.

**Le misure**, in `test/chi_torna_riesce_a_entrare_test.dart`, sulla porta VERA
`PortaDellIdentitaFirebase` e non su una controfigura: **i cinque rami di uscita
enumerati** (entra, chiude la finestra, il fornitore dice annullato, il Cerchio
non c'e' con quelle chiavi, la rete non risponde), **zero collegamenti tentati**
da chi torna anche quando l'account e' gia' di un altro Cerchio, il diario del
flusso che dice `[dimentica, credenziale]` e non il contrario, e **dopo un
fallimento il secondo tentativo entra**.

**Sul dispositivo non e' misurata e si dichiara**: il fondatore deve
disinstallare, reinstallare e rientrare col suo account Google.

## I marcatori

VOCI_TOTALI: 16
VOCI_APERTE: 13
VOCI_CHIUSE: 3
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
