# ORDINE FD, LA CONFERMA DELLA SPESA, LA PORTA SOLA DEL CIELO, I BANCHI, IL TASTO INDIETRO E IL CERCHIO DEI COLLAUDI

**Sigla:** FD. **Data dell'ordine:** 5 ottobre 2026. **Ramo:**
`claude/esoteric-circle-master-order-e798aj`, nessun altro. **Partenza:**
commit `07d74c3d`, la chiusura dell'ordine FC.

**Regole in primo piano.** R1 ogni voce dichiara la sua fonte; R2 le premesse
si abbattono con la misura; R3 si enumera, non si campiona; R4 e R5 le
Regole A e B; R6 ogni affermazione visiva e' una cattura o una misura; R7
nessun rosso si consegna e i tre numeri delle prove coincidono; R8 niente
dati di produzione; R9 il manifesto coi quattro marcatori; R10 nessuna
credenziale chiesta in chat. La build 2298 l'ha ordinata il fondatore.

**Le due scelte del fondatore del 5 ottobre 2026**, chieste perche'
necessarie: per la R8 i collaudi del Cerchio si isolano in uno spazio
proprio della presenza (*"Isolare i collaudi"*), e il secondo account di
collaudo lo crea Code sull'emulatore (*"Sì, fallo tu"*).

VOCI_TOTALI: 5
VOCI_CHIUSE: 0
VOCI_APERTE: 5
VOCI_DA_FARE: 0

## VOCE FD.01, NESSUNA SPESA SENZA CONFERMA

**APERTA IN ATTESA DI VERIFICA.** Nessun punto dell'app consuma minuti o
Eos al primo tocco: prima compare la conferma unica,
`LaConfermaDellaSpesa`, col costo, il saldo e due pulsanti, coi testi
dell'ordine alla lettera (l'unico scarto: "1 minuto" al singolare). Ogni
porta che consuma pretende il consenso che solo quella conferma crea, quindi
un punto di spesa nuovo che la salti non compila. I quindici punti, enumerati
con file e riga, in `docs/collaudo/FD/i_punti_di_spesa.md`; il dialogo
proprio del dono e' stato tolto. Il LIVE legge i minuti dal server prima del
tocco con la funzione nuova `iMinutiDelLive`, che il fondatore pubblica.

DOMANDA: "Nessuna funzione consuma minuti, Eos o denaro al primo tocco. Prima compare sempre una conferma che mostra il costo e il saldo residuo, con due pulsanti."
PROVA: test/la_spesa_passa_dalla_conferma_test.dart
MISURA: punti di spesa con la conferma di costo e saldo prima 0 su 15, dopo 15 su 15; conferme diverse prima 4 (riga col prezzo della porta della spesa, riscatto a un tocco, confronto in piu', dialogo del dono), dopo 1; consumi con Non ora prima e dopo (saldo 300 e 300, movimenti 0; LIVE chiamate solo iMinutiDelLive); col saldo corto pulsante spento e 0 movimenti
ACCETTAZIONE: toccando la pastiglia LIVE vedo "Stai per aprire una sessione dal vivo." coi miei minuti, e niente parte finche' non tocco "Apri la sessione"

## VOCE FD.02, UNA PORTA SOLA PER IL CIELO, CON LA SUA VALIDITA'

**APERTA IN ATTESA DI VERIFICA.** Il cielo si calcola con Meeus in una
libreria sola, `lib/core/astro/meeus/`, e da una porta sola,
`IlCieloDiMeeus`. Il motore limitato al 2020-2030, `Effemeridi`, e' cancellato,
come il Sole del capitolo 25, i polinomi sul JPL e il Sole NOAA dell'alba e
del tramonto. La porta dichiara l'intervallo verificato, dal 31 dicembre 1899
al 31 dicembre 2099, e fuori non risponde; le eclissi dichiarano il loro,
2021-2030. La Luna del confronto del cielo viene dalla porta.

DOMANDA: "il motore limitato al 2020 e 2030 si cancella e non resta inutilizzato"
PROVA: test/il_cielo_ha_una_porta_sola_test.dart
MISURA: fonti della posizione di un corpo in lib prima 6, dopo 1; scarto massimo dal JPL DE440s sul secolo prima (Effemeridi, epoca verificata 2020-2030) fino a 0,570 gradi su Saturno al 1950, dopo 11 secondi d'arco sulla Luna e 3,3 sui pianeti; venti coppie del confronto in docs/collaudo/FD/il_confronto_prima_e_dopo.txt
ACCETTAZIONE: il confronto del cielo fra due amici da' gli stessi numeri sulle stesse coppie, e la Luna viene dal motore di Meeus

## VOCE FD.03, I BANCHI COL MODELLO NON SONO CODICE MORTO

**APERTA IN ATTESA DI VERIFICA.** Un comando solo,
`python tool/banchi_col_modello/i_cinque_banchi.py --costo`, lancia i cinque
banchi e scrive `docs/collaudo/banchi_col_modello/<data>.txt`; il README dice
cosa misura ognuno e il costo di un giro in euro; `tool/consegna.py` non
consegna senza un giro passato sullo stesso codice.

DOMANDA: "un comando solo, scritto in un README in tool/banchi_col_modello/ insieme a cosa testa ciascuno dei cinque banchi"
PROVA: test/i_banchi_col_modello_hanno_un_comando_test.dart
MISURA: comandi per lanciare i banchi prima 0 (tre righe a mano, una per file), dopo 1; giri registrati prima 0, dopo 1
ACCETTAZIONE: lancio un comando e trovo il file del giro coi cinque esiti e il costo

## VOCE FD.04, IL TASTO INDIETRO NON ESCE MAI DALL'APP

**APERTA IN ATTESA DI VERIFICA.** Da ogni schermata interna il tasto
indietro torna alla precedente; dal Passport torna al Cerchio; sulla home il
primo tocco mostra "Premi di nuovo per uscire." per due secondi e solo un
secondo tocco entro due secondi esce. Le 66 rotte con file e riga e dove
porta il tasto in `docs/collaudo/FD/le_schermate_e_il_tasto_indietro.md`.

DOMANDA: "Da qualunque schermata interna, il tasto indietro riporta alla schermata precedente e non esce mai dall'app."
PROVA: test/il_tasto_indietro_non_esce_dall_app_test.dart
MISURA: tocchi che escono dall'app dalla home prima 1 (il primo), dopo 2 entro due secondi; dal Passport prima 1, dopo mai (torna al Cerchio); punti di lib che chiudono l'app 1; rotte enumerate 66
ACCETTAZIONE: sul telefono il tasto indietro mi riporta indietro, e sulla home mi chiede di premerlo di nuovo

## VOCE FD.05, IL CERCHIO POPOLATO VISTO SU UN TELEFONO VERO

**APERTA IN ATTESA DI VERIFICA.** I collaudi hanno uno spazio proprio della
presenza (`functions/src/i_collaudi.ts`, registro leggibile in
`docs/collaudo/registro_dei_collaudi.md`), cosi' il giro fra il Realme e
l'emulatore non legge ne' scrive documenti di utenti reali.

DOMANDA: "il Cerchio popolato con il semaforo verde, la riga dell'ultimo dato noto con l'ora, e il Cerchio che torna vuoto quando il primo account esce"
PROVA: test/i_collaudi_sono_registrati_test.dart
MISURA: account di collaudo registrati prima 0, dopo 1 su 2
ACCETTAZIONE: sul Realme vedo l'altro account nel mio Cerchio col semaforo verde, e quando esce il Cerchio torna vuoto
