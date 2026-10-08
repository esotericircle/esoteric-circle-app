# RAPPORTO DELL'ORDINE FF, GLI ENIGMI DEL CERCHIO

**I giochi del Cerchio sono scritti, provati e spinti; per vederli sul telefono serve il deploy delle funzioni.** Il Ritratto, Chi del Cerchio, la Prova della settimana, le scommesse, la sfida a due, il Pellegrinaggio e la classifica girano sul server con sei porte nuove: finche' non sono pubblicate, la pagina degli Enigmi dice "Il Cerchio non risponde". La Soglia del Sonno e' in home e nel dominio di Aura. Nessuna voce chiama un modello.

Ramo `claude/esoteric-circle-master-order-e798aj`, partenza `d483eae6`, 7 e 8 ottobre 2026. Testo dell'ordine: `docs/ordini/ORDINE_FF_TESTO.md`. Manifesto: `docs/ordini/ORDINE_FF_MANIFESTO.md` (20 voci: 11 chiuse, 9 aperte in attesa di verifica). Regola A: `docs/collaudo/FF/regola_a_ff.txt`, 43 innesti, tutti rossi sul loro bersaglio (F15, F31 e F37 al secondo innesto: il primo non metteva il difetto intero, e l'ho rifatto cambiando l'innesto, mai la soglia).

## LE VOCI CHIUSE, con la prova di ciascuna

- FF.08, le contraddizioni dichiarate: docs/collaudo/FF/le_contraddizioni_dichiarate.txt
- FF.10, i due corpora marcati nel worktree: docs/collaudo/FF/i_corpora_e_gli_asset.txt
- FF.11, la marca del genere, la regola: test/il_genere_non_si_indovina_test.dart
- FF.12, la guardia del genere: test/il_genere_non_si_indovina_test.dart
- FF.13, la rigenerazione: docs/collaudo/FF/il_conto_dei_corpora.txt
- FF.14, i tre asset nel worktree: docs/collaudo/FF/i_corpora_e_gli_asset.txt
- FF.15, la Soglia nel dominio di Aura: docs/collaudo/FF/soglia_del_sonno/03_il_dominio_di_aura.png
- FF.16, la Soglia nella riga La tua serenità: docs/collaudo/FF/soglia_del_sonno/01_la_riga_della_home.png
- FF.17, In arrivo, Fase 3: docs/collaudo/FF/soglia_del_sonno/02b_al_tocco_in_arrivo_fase_3.png
- FF.18, i censimenti: test/gli_sfondi_delle_schede_test.dart
- FF.19, le guardie della scheda: test/la_soglia_del_sonno_test.dart

## LE VOCI APERTE IN ATTESA DI VERIFICA, e cosa le chiude

- FF.01-FF.07, la presenza e i giochi: il deploy delle funzioni (lo fai tu) e il collaudo sul Realme.
- FF.09, le push su iPhone: la build iOS di Codemagic, che parte solo a mano dal pannello.
- FF.20, le sei catture: 01, 02 e 03 dal Realme; 04 (donna), 05 (uomo) e 06 (indizio) sono anteprime a 360x797, perche' sul Realme il genere si dichiara solo nell'onboarding e rifarlo cancellerebbe i dati del telefono di collaudo; dal Realme c'e' il neutro del profilo di collaudo (07). La 06 su una partita vera vuole il deploy.

## I NUMERI CHE L'ORDINE CHIEDE

**Le scritture della presenza, prima e dopo** (FF.01, misurate sul telefono finto, `test/chi_esce_dal_cerchio_esce_dal_conto_test.dart`): in una sessione di dieci minuti 11 passi e 1 uscita, cioe' 12 scritture, prima e dopo. Prima l'uscita cancellava la presenza, adesso scrive l'ora: stessa scrittura, nessuna in piu'. Con due sessioni, il numero letto da B mentre A passa a un'altra app e torna era 2, 1, 1, 2; adesso 2, 2, 2, 2.

**Le letture per apertura di ogni gioco**, contate porta per porta nel codice di `functions/src/il_cerchio_sociale.ts` (N = gli amici del Cerchio):
- la pagina degli Enigmi (`gliEnigmi`): 4N + 15 letture con le domande vuote (il tetto 1, il proprio stato 8, poi per te e per ogni amico i contatori, il Pellegrinaggio e il profilo, la Prova di ogni amico, le tue scommesse e le sfide nei due versi); con cinque amici 35;
- un indovinello aperto (`unIndovinello`, apri): almeno 23 (il tetto, la partita, il piano, i contatori, il tuo Ritratto, legami e blocchi, tre letture per ognuno dei quattro volti, i quattro profili), piu' tre per ogni amico saltato perche' senza Ritratto o fuori dai giochi;
- un indizio: 3; una risposta: 6;
- la Prova consegnata: almeno 5 (il tetto, la settimana, la tua Prova, le scommesse e le sfide su di te);
- il tuo Ritratto: 3.

**Il costo in Eos di ogni gesto a pagamento**: il primo indizio di ogni partita 0, il secondo e il terzo 5 Eos l'uno; il segno di chi ti ha indovinato 20 Eos, uno alla volta. Tutto il resto e' gratuito: il Ritratto, gli indovinelli entro il limite, la Prova, le scommesse, la sfida, il Pellegrinaggio.

**Le due contraddizioni separate** (FF.08, senza modello sui 61 giri gia' giudicati): 137 contraddizioni su 3560 risposte giudicate; dichiarate col perche' 0; col solo annuncio "Io leggo diversamente da Medora" 7, tutte frasi della rete della coerenza; a tradimento 137. Percorsi oltre due contraddizioni: 4 su 356, con qualunque dei due conti.

## LE PREMESSE ABBATTUTE

- **"Senza limite dall'Adepto in su"**: l'ordine CE voce 08 ha tolto ogni illimitato (`functions/src/budget.ts:41`). Indovinelli 3, 10, 50, 150 al giorno; scommesse 1, 3, 15, 45.
- **"In grigio o semitrasparenza, come le altre arti non ancora vive"**: le altre hanno l'immagine piena con la clessidra dorata (`lib/core/arts/art_catalog.dart:56`, "mai un velo che le renda illeggibili"). La Soglia e' come le altre.
- **"Il testo che iOS mostra dentro la finestra di sistema"**: iOS non lo permette. La frase sta nel foglio che la precede, senza la virgola prima della "e".
- **"I corpora sono a zero virgole" e "il dizionario conosceva una parola sola"**: restavano due virgole per file a capo riga; il dizionario conosceva 43 parole e vedeva 7 dei 34 testi marcati.
- **I corpora corretti dell'Architetto**: due forme neutre sbagliate (37 e 100), un tempo del verbo (119), due "che" mancanti nelle fasce dei temi 3 e 4, tre marche a capo riga. Corretti da me per la tua scelta dell'8 ottobre.

## FIN DOVE SONO ARRIVATO

Scritto, agganciato, provato e spinto: il server dei giochi (sei porte, con tetto e soglia dei quattordici anni), il telefono (la pagina degli Enigmi dal Cerchio, il Ritratto anche dal profilo, Chi del Cerchio, la Prova, scommesse e sfide, il Pellegrinaggio con la barra, la classifica), il motore degli indizi, i tempi, la presenza, le push su iPhone, la Soglia del Sonno, i corpora marcati con la porta del genere, la privacy aggiornata all'8 ottobre. Nove anteprime a 360x797 in `docs/preview/FF/`. Guardato sul Realme col pacchetto locale 2302 (non distribuito): la Soglia del Sonno in home, in verticale, al tocco e nel dominio di Aura; il Ritratto in neutro; e un difetto trovato li', il codice NOT_FOUND a video con la porta non pubblicata, curato. Non guardato sul telefono: tutto cio' che passa dal server nuovo.

## LE DECISIONI CHE RESTANO AL FONDATORE

1. **Il deploy delle funzioni**, che apre la presenza nuova e i giochi.
2. **La build**: hai scelto "Niente build per ora". Il cancello della consegna vuole un giro dei banchi col modello sul codice nuovo (l'ultimo 5,51 dollari).
3. **La build iOS su Codemagic**, per chiudere FF.09.
