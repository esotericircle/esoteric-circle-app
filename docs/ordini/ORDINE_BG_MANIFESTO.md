# ORDINE BG, il manifesto

**IL NEONATO NON RICEVE IL BENTORNATO.** Ordine creato da Code con
l'autorizzazione data dal fondatore dentro l'ordine BF ("se le voci diventano
eccessive per un singolo ordine, crea tu l'ordine BG di seguito e dichiaralo
nel manifesto"). Nasce dal collaudo del fondatore sulla 2201, parole sue:
"ho appena cancellato Account e dati, dopodiche' ho installato la nuova build
e fatto click sul pulsante 'faccio gia' parte del cerchio' inserendo la mia
solita e-mail di Google e il sistema mi da' il bentornato anche se non
dovrebbe ricordare nulla di me".

## Come si legge questo file

Ogni voce porta uno stato fra cinque: CHIUSA, APERTA, FERMATA SU PREMESSA
FALSA, FERMATA IN ATTESA DI DECISIONE, FERMATA SU DECISIONE DEL FONDATORE.
In fondo i marcatori, che la guardia `test/ordine_bg_guard_test.dart` conta
sulle righe.

## La causa, verificata prima di lavorare

Il sistema NON si ricorda di lui, e la scena mente. Due meta':

1. **Con Google non esiste "email gia' in uso".** "Faccio gia' parte del
   Cerchio" con un provider federato non puo' fallire: se l'account non
   esiste, Firebase ne CREA uno nuovo in silenzio. La cancellazione di BE.07
   aveva funzionato; il rientro ha fatto nascere un Cerchio vergine.
2. **La dote di nascita sembrava un ritorno.** `Ritrovamento` decideva
   "qualcosa da mostrare" con `Eos > 0`, ma ogni Cerchio appena nato ha gia'
   270 Eos (benvenuto piu' giorno, AN.07): il neonato era indistinguibile da
   un ritorno, e la scena diceva "Il Cerchio ti aveva tenuto tutto. 270 Eos"
   a chi non aveva niente da ritrovare. Il commento nel codice dichiarava
   perfino l'intenzione giusta ("chi entra con un account nuovo non deve
   vedere una scena che celebra il ritrovamento di zero cose"): era la dote
   ad averla resa cieca.

## Le voci

- **BG.01** Il neonato non riceve il Bentornato. CHIUSA: il segnale vero e' il BENVENUTO, che si accredita una volta sola nella vita di un Cerchio: se l'ultima sincronia lo ha accreditato (il campo `accreditati` nato con BF.01), il Cerchio e' nato adesso. La borsa lo espone (`cerchioAppenaNato`), il `Ritrovamento` non conta piu' la dote come cosa tenuta (gli Eos non fanno "qualcosa da mostrare" su un Cerchio appena nato; carta e traguardi restano sovrani), e a chi entra su un Cerchio appena nato lo si DICE con la riga onesta ("Questo account non aveva un Cerchio: ne nasce uno nuovo, da zero, con la sua dote di benvenuto") invece del Bentornato che mentiva. Guardia: `test/il_neonato_non_riceve_il_bentornato_test.dart`; le prove del rientro (porta per chi torna, onboarding che non si rifa', dote che racconta) restano verdi.

MARCATORI, per la guardia:
VOCI_TOTALI: 1
VOCI_APERTE: 0
VOCI_FERMATE_IN_ATTESA_DI_DECISIONE: 0
VOCI_FERMATE_SU_PREMESSA_FALSA: 0
VOCI_FERMATE_SU_DECISIONE_DEL_FONDATORE: 0
VOCI_CHIUSE: 1
