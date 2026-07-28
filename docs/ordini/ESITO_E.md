# ESITO dell'ORDINE E, la Risonanza equilibrata

## Il push, con un errore mio da mettere a verbale

Avevi ragione: il push non era bloccato. Il remoto porta la credenziale
nell'indirizzo, non serve altro, quindi ha funzionato al primo tentativo appena
l'ho lanciato nudo. `6c134de..3087b56` e' sul remoto.

Come ci sono arrivato a dire il contrario, per intero. Il primo tentativo, tre
ordini fa, l'ho lanciato senza opzioni e si e' fermato al timeout di tre minuti:
non era fallito, stava caricando, ma l'ho ucciso io. Da li' ho dedotto che
chiedesse una finestra interattiva. Nei tentativi successivi ho aggiunto
`-c credential.helper=` e `-c core.askPass=true` per aggirare quella finestra
che non esisteva, ma quelle due opzioni disabilitano proprio l'autenticazione:
il `No anonymous write access` che ho letto e riportato come prova del blocco me
lo ero procurato da solo. Ho ripetuto quella conclusione in cinque esiti senza
mai riprovare in modo pulito.

La lezione, per quel che vale: un comando che va in timeout non e' un comando
che fallisce; un errore ottenuto cambiando le opzioni non dice niente sul
comando originale.

## Le distribuzioni, prima e dopo

Ventimila carte natali pseudocasuali, seme fisso 4242, generate con pianeti in
segni e case casuali.

| | Medora | Aura | Caligo |
| --- | --- | --- | --- |
| **Carta completa, prima** | **72,1%** | **1,4%** | 26,5% |
| **Carta completa, dopo** | 29,3% | 34,8% | 35,9% |
| **Carta essenziale, prima** | **100,0%** | **0,0%** | **0,0%** |
| **Carta essenziale, dopo** | 33,7% | 32,9% | 33,4% |

I numeri del prima li ha misurati il test stesso sul codice non ancora
corretto, e combaciano con l'audit dell'Architetto, che dava 72,2 contro 1,5 e
26,3: la differenza sta nel seme.

## Come e' stata corretta

La strada e' quella suggerita, la normalizzazione, con una correzione
importante rispetto alla lettera del suggerimento.

**Non si normalizza sul massimo teorico, si normalizza sull'atteso.** Provata
prima la strada del massimo, il risultato e' stato Medora 65,0 per cento, Aura
35,0, **Caligo 0,0**. La ragione e' che il massimo assoluto di Caligo pretende
ogni pianeta in Scorpione E insieme in casa dell'ombra E insieme in un segno di
fuoco: una condizione che non si presenta mai, quindi dividere per quel numero
lo azzera. Il valore atteso, cioe' quanto ogni Maestro prende in media da un
pianeta con segni e case equiprobabili, mette i tre sulla stessa scala.

I tre valori attesi per pianeta, coi conti scritti nel codice: Medora 0,2333,
Aura 0,2833, Caligo 0,4334.

Poi restava uno scarto: Medora al 24,2 per cento contro un minimo di 25.
Il divisore era gonfiato di un terzo di punto, perche' per l'Ascendente contavo
l'elemento al massimo dell'aria, 0,5, invece che al valore atteso, 0,15, come
faccio per tutti i pianeti. Corretto quello, Medora e' salita a 29,3.

**Il ripiego.** Scelta la prima delle due strade offerte, cioe' equilibrare
invece di dichiarare provvisorio. Con la sola carta essenziale c'e' il Sole, che
e' di Medora, quindi la formula piena le dava il cento per cento. Ora i dodici
segni si dividono in tre gruppi da quattro per dominio: aria piu' Leone a
Medora, acqua piu' terra della cura ad Aura, le due firme di Caligo piu' il
fuoco che agisce a Caligo. La lettura resta vera, perche' il segno solare dice
davvero qualcosa, mentre la frase dichiara comunque che con l'ora di nascita si
fara' piu' precisa.

## Criteri, uno per uno

- Carta completa, nessuno sotto il 25 ne' sopra il 40: **passa**, 29,3 / 34,8 /
  35,9 su ventimila carte.
- Ripiego, nessuno sotto il 20: **passa**, 33,7 / 32,9 / 33,4.
- Test statistico permanente nella suite, seme fisso: **c'e'**, in
  `test/risonanza_equilibrio_test.dart`, sette casi.
- Determinismo, cento ripetizioni: **passa**, e i punteggi non si muovono
  nemmeno di un millesimo.
- Significativita': **passa** su due fronti. Sei cieli molto diversi non danno
  tutti lo stesso Maestro; tre coppie costruite a mano, che differiscono di un
  grado dentro lo stesso segno, danno lo stesso Maestro.
- Suite verde, analyze pulito: **passano**, 831 test contro gli 824 di prima.
