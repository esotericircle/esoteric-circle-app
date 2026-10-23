# Ordine GB voce 03, la caccia agli altri blocchi

Metodo: device Android di collaudo `767f596c` (Realme), app Esoteric Circle gia' installata in release, package `com.esotericircle.esoteric_circle`, versionName 0.1.0, versionCode 2315. Misura fatta il 22 ottobre 2026. Per ogni funzione: `adb logcat -c` per svuotare il registro, tocco sulla card dalla griglia principale (Home/Cerchio) o dal dominio del Maestro competente, attesa di circa 3 secondi, poi `adb logcat -d -s Choreographer:W` per leggere le righe "Skipped N frames" (il filo dell'interfaccia che si ferma). Ogni funzione e' stata misurata due volte e viene riportata la peggiore delle due. Nessun dato di produzione e' stato inserito: dove la schermata chiedeva una foto personale, si e' scelta l'opzione che non la richiede (avatar a costellazione, senza caricare immagini).

Riferimento di confronto: l'Oroscopo (gia' curato negli ordini GA.14 e GB.01/GB.02) ha aperto senza perdere fotogrammi in entrambe le misure, ed e' la soglia "verde" con cui si confrontano le altre funzioni. Soglia pratica di allarme: piu' di 6 fotogrammi persi (circa 100 ms di blocco a 60 Hz) = sopra soglia.

## Tabella

| Funzione | Fotogrammi persi (peggiore delle 2 misure) | Testo della riga Choreographer | Esito |
|---|---|---|---|
| Oroscopo (riferimento) | 0 | nessuna | sotto soglia (riferimento) |
| Tarocchi, Stesa di Tarocchi | 0 | nessuna | sotto soglia |
| Oracolo degli Angeli | 0 | nessuna | sotto soglia |
| Rune, Estrazione Rune | 0 | nessuna | sotto soglia |
| Sinastria Evolutiva | 0 | nessuna | sotto soglia |
| Porta della Sinastria VIP (apertura della galleria Sinastria VIP e del responso di compatibilita' con un VIP a caso, Angelina Jolie) | 0 | nessuna | sotto soglia |
| Calendario Lunare | 0 | nessuna | sotto soglia |
| Il Respiro della Luna (sola apertura, tab Luna; nessun altro tocco dentro, nessuna sessione di respiro avviata) | 0 | nessuna | sotto soglia |
| La Collana delle Lune (raggiunta dal link interno a Il Respiro della Luna, tab Respiro) | 0 | nessuna | sotto soglia |
| Chat con un Maestro (chat con Medora) | 0 | nessuna | sotto soglia |
| La pagina di un Maestro (dominio di Medora, "Entra nel Dominio di Medora") | 0 | nessuna | sotto soglia |
| Cielo Reale ("Il Cielo di Adesso", raggiunto dal widget "Tocca il Cielo" in Home) | 0 | nessuna | sotto soglia |
| Magia Rossa (bonus, trovata navigando nel dominio di Calìgo) | non misurabile | non misurabile | non apribile, dietro badge "In arrivo, Fase successiva" (coming soon): il tocco mostra solo l'anticipo, nessuna schermata vera si apre |

## Nota sulla Sinastria VIP

La card "Sinastria VIP" apre prima una galleria di selezione (nessun blocco, 0 fotogrammi persi anche li'), poi chiede di scegliere un profilo VIP: e' stato scelto a caso Angelina Jolie dalla lista "Tutti i VIP" e si e' misurata l'apertura del responso di compatibilita' (la "Porta della Sinastria" vera e propria), che e' la schermata richiesta dall'ordine. Durante la selezione e' comparsa anche l'opzione "Aggiungi la tua foto": non e' stata usata (ne' fotocamera ne' galleria), si e' scelto di lasciare l'avatar di default, per non introdurre dati personali.

## Conclusione

Nessuna delle dodici funzioni elencate nell'ordine ha perso fotogrammi all'apertura: tutte sono risultate sotto soglia, alla pari con l'Oroscopo di riferimento. Non e' stato trovato nessun altro "blocco" paragonabile al vecchio Oroscopo prima della cura. L'unica voce non misurabile e' Magia Rossa, perche' non ancora attiva (coming soon).
