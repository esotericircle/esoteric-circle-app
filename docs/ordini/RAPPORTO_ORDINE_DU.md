# RAPPORTO DELL'ORDINE DU, L'ARCANO DELL'ALBA DIVENTA UNA SCENA

**Data:** 17 settembre 2026. **Ramo:** `claude/esoteric-circle-master-order-e798aj`.
**Manifesto:** `docs/ordini/ORDINE_DU_MANIFESTO.md`.

**Quattordici voci, quattordici chiuse.** Nessuna e' rimasta aperta e nessuna
e' ferma in attesa di una decisione.

L'ordine e' nato da una frase del fondatore sulla consegna 2266 e 2267:
*"l'Arcano dell'Alba e' un compitino"*. Aveva ragione, ed era mio: l'ordine DT
non chiedeva una scena e io non l'avevo proposta.

---

## 1. LA CORREZIONE DI ROTTA, E COSA HA CAMBIATO

La prima stesura della scena riusava il ventaglio della Stesa dei Tarocchi con
ventidue dorsi, davanti all'avatar di Medora. **L'ho mostrata, e il fondatore
l'ha respinta**: *"e' identico alla funzionalita' stesa dei tarocchi e vorrei
qualcosa di originale"*, e poi *"togli anche la figura avatar di Medora"*.

Il riscontro sul codice che mi aveva portato li' era giusto, la conclusione no.
La scena esisteva davvero ed era gia' parametrica nel numero di carte, ma
riusarla dava all'Alba la faccia della Stesa. **Ventidue carte sono poche
abbastanza da starci tutte insieme**: non c'e' niente da sfogliare, c'e' un
tavolo da guardare.

Il costo di quell'errore: una stesura della scena buttata, il ventaglio e
l'avatar da togliere, due voci del manifesto da riscrivere e la guardia
dell'ordine da rovesciare, perche' pretendeva `MedoraStage` e `StesaFan` dentro
l'Alba. **La lezione sta nel manifesto, non solo qui**: un riscontro sul codice
dice cosa esiste, non cosa e' giusto per la persona che guarda.

---

## 2. LA SCENA NUOVA, IN NUMERI

`lib/features/rituals/tavolo_dei_ventidue.dart`, 640 righe.

| cosa | il numero |
|---|---|
| dorsi in scena | 22, tutti toccabili |
| righe sopra i 420 punti | 2 da 11 |
| righe sotto i 420 punti | 3 da 8, 7 e 7 |
| larghezza di una carta a 360 punti | 53,7 punti |
| arco di una riga | la carta centrale 11,1 punti sopra i bordi |
| inclinazione delle carte di bordo | 0,13 radianti, in versi opposti |
| ingresso a spirale | 1500 ms, una carta dopo l'altra |
| respiro del tavolo | 7 s a giro, ogni carta con la sua fase |
| mischia e taglia | 1100 e 900 ms, sull'aspetto e non sull'esito |
| rivelazione | 1400 ms, la faccia dopo il mezzo giro |

**Perche' tre righe sul telefono**: a 360 punti undici carte per riga
lascerebbero a ogni dorso meno di trentadue punti, e un dorso di trentadue
punti non si distingue e non si tocca. Il conto sta in `righeDi`, che e'
pubblica perche' la prova la legge.

**Mischia e taglia non cambiano la sorte, ed e' scritto nel codice**: i dorsi
sono lo stesso disegno e la carta si estrae dal caso nel momento del tocco.
Restano perche' sono il gesto che una persona fa con un mazzo vero.

**La seconda correzione, sulla scena gia' rifatta.** Il tavolo e' stato
approvato con quattro richieste: le tre file a ventaglio, il suono della carta
della Stesa, mischia e taglia dentro due bolle, e un titolo d'oro sopra
l'invito. Sono entrate tutte, e la prima ha cambiato la geometria: ogni riga e'
un arco, la carta centrale sta 11,1 punti sopra i bordi e le carte dei bordi si
inclinano in versi opposti, col respiro che si somma alla posa invece di
sostituirla.

**E guardando l'anteprima e' saltato fuori un difetto che nessuna prova
cercava**: il titolo e l'invito non si spegnevano mentre la carta volava,
perche' l'opacita' si calcolava fuori da chi ascolta l'animazione. Adesso c'e'
un `AnimatedBuilder`, e una guardia misura l'opacita' a meta' volo.

---

## 3. IL CORPUS, 528 LETTURE

Decisione del fondatore: **dodici letture per stato**, quarantaquattro stati,
528 testi. Ogni lettura porta la parola della carta, il dono che la contiene e
la chiusura di Medora.

**Settantacinque letture sono state riscritte**, e ognuna per una misura, non
per gusto:

| perche' | quante |
|---|---|
| la parola viveva gia' in un'apertura del primo movimento | 10 |
| la parola la diceva il filo di ieri | 6 |
| la parola era il nome dell'attribuzione della carta | 4 |
| Medora spiegava la parola riusandola | 13 |
| due parole gemelle nello stesso stato | 2 |
| due movimenti condividevano il nucleo | 38 |
| il dono faceva respirare, che e' il lavoro di Aura | 2 |

La prova gira su **4.193.280 combinazioni** di lettura, apertura, clausola e
filo di ieri. Su 3.300 consegne simulate a venticinque persone i ripieghi sono
**4** e le marche tornate dentro la finestra **6**, tutte coperte da un ripiego
contato.

---

## 4. L'ESTRAZIONE PERDE IL SACCHETTO

Il fondatore: *"alla roulette puo' uscire lo stesso numero due volte"*. Il
sacchetto senza reimbussolamento e' stato tolto, e con lui la prova che lo
misurava. Al suo posto `test/l_estrazione_dell_alba_e_libera_test.dart`:

- su centomila giri ogni stato esce fra 2.174 e 2.426 volte, atteso 2.273;
- la stessa carta torna il giro dopo nel **4,5 per cento** dei casi, lo stesso
  stato nel **2,2**: sono un ventiduesimo e un quarantaquattresimo;
- su ogni singola carta il verso rovescio sta fra il 44 e il 56 per cento;
- **nessuna riga di codice** dei ventidue file dell'Alba nomina piu' un
  sacchetto, una distanza minima o le ultime carte uscite.

Il diario, che col sacchetto misurava cicli, adesso misura la **finestra
scorrevole** del registro, e il legame vero: una marca torna soltanto dove il
motore ha contato un ripiego.

---

## 5. IL SOFFIO DEL DESTINO, VOCE 14

Il cerchio disallineato erano due anelli fini a raggio `r` e `r/2`, mentre i
petali finiscono a `0,92 r` coi nodi appena oltre: l'anello tagliava i nodi
invece di contenerli. Adesso gli anelli non si disegnano piu' e **il fiato sta
nei petali**, ognuno con la sua fase.

Il disegno e' uscito dal pittore privato della schermata ed e' diventato
`FormaDelDono`, perche' **una scena si misura solo se una prova la puo'
dipingere da sola**.

La guardia guarda i pixel: per ogni raggio conta quanta parte della
circonferenza e' accesa. Senza anelli il massimo e' il **6 per cento**,
coll'anello innestato il **69**. La prima stesura della misura campionava una
riga di pixel interi e coll'anello leggeva solo il 37 per cento: **non ho
abbassato la soglia, ho allargato la misura a una banda di un pixel**, perche'
un anello fine con l'antialiasing si spalma su due.

---

## 6. LE GUARDIE, E QUELLE VISTE ROSSE

| guardia | vista rossa con |
|---|---|
| `il_tavolo_dei_ventidue_test.dart`, le righe | la soglia innestata a 300 punti |
| `il_tavolo_dei_ventidue_test.dart`, mischia e taglia | la consegna del posto invece della carta |
| `ordine_du_guard_test.dart`, nessun avatar | `MedoraStage` innestato nella schermata |
| `l_estrazione_dell_alba_e_libera_test.dart` | `SacchettoDellAlba` innestato nel diario |
| `il_dono_del_soffio_non_ha_cerchi_test.dart` | i due anelli rimessi nel disegno |
| `il_corpus_dell_alba_regge_test.dart`, l'articolo | il rilevatore vecchio, che prendeva *gli* per un nome |
| `l_arcano_dell_alba_si_gira_test.dart`, il titolo che si spegne | il titolo agganciato a un'animazione ferma |

---

## 7. UN DIFETTO TROVATO PER STRADA, E IL SUO PADRE

**Il rilevatore del nucleo prendeva per nome della carta anche il suo
articolo.** Bocciava *"Gli affetti campano di presenza"* perche' comincia con
*gli*, che e' l'articolo degli Amanti. **Proveniente dall'ordine DT voce 09**,
dove il rilevatore e' nato con l'elenco delle parole di servizio incompleto:
c'erano *del* e *dei*, scritti a mano quando servivano, e nessun articolo.

Adesso gli articoli e le preposizioni escono dal nome misurato, la pretesa e'
stata scritta prima e vista rossa sul rilevatore vecchio, e il nome vero resta
preso: *"non capitano piu' da sole"* nomina ancora il Sole.

---

## 8. COSA NON E' STATO FATTO

- **Nessuna build.** Si costruisce quando Mauro lo ordina.
- **La funzione `statoDelCerchio` resta da distribuire dal PC di Mauro**, passo
  8 di `docs/ordini/DISTRIBUZIONI_DAL_TUO_PC.md`: questa sessione non ha i
  permessi per distribuire in produzione. Viene dall'ordine DT e non da qui.
