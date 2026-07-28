# CODA DEGLI ORDINI, Esoteric Circle

Preparata dall'Architetto in Cowork la notte del 28 luglio 2026, mentre Mauro dorme.

## Come funziona

Mauro dà una riga sola. Tu esegui gli ordini di questa coda **in sequenza, senza fermarti a chiedere fra uno e l'altro**. Alla fine di ciascuno scrivi il suo esito, poi apri il successivo.

Se un ordine non riesci a chiuderlo per intero, NON passare al successivo: finisci quello che puoi, scrivi l'esito dicendo con precisione cosa resta, e solo allora vai avanti. Meglio consegnare cose intere e verificate che sei cose abbozzate, esattamente come hai fatto stanotte.

## La sequenza

1. **`ORDINE_CORRENTE.md`** — Il rifacimento immersivo. Le parti non fatte dell'ordine precedente: il sistema di scena unificato, il permesso di posizione, il carosello dei Maestri, le due animazioni di trionfo mancanti, i tre punti di disposizione, il ripristino del Risveglio in debug, più la correzione del numero di versione.
2. **`ORDINE_B_REGOLE_DELLA_CASA.md`** — Le otto regole trasversali violate, applicate una volta sola su tutta l'app.
3. **`ORDINE_ENTITLEMENT.md`** — Le sette verifiche su entitlement e percorso a pagamento, con la prova del rosso eseguita.

## Regole che valgono su tutta la coda

Una build e una distribuzione **alla fine di ciascun ordine**, non alla fine della coda: Mauro deve poter guardare i risultati man mano, e se qualcosa va storto non voglio scoprirlo tre ordini dopo.

Destinatario unico della distribuzione: `cloud@esotericircle.app`.

Non toccare mai `docs/STATO_VIVO.md` durante la coda. Lo aggiorniamo insieme alla fine, con l'Architetto.

Prima di aprire ogni ordine, rileggi `claude/Indice_delle_Prescrizioni_Esoteric_Circle` nel Project: se il blocco che stai per aprire può chiudere anche altre righe marcate ASSENTE o VIOLATA senza costo aggiuntivo, fallo e dillo nell'esito.

Italiano. Niente trattino lungo. Niente proposizione dopo la virgola che inizia con la lettera e. Accenti veri.

## Il push, da fare per primo

Sono cinque commit fermi in locale. Prima di qualunque altra cosa, prova:

```
git -C "C:\Users\user\Desktop\esoteric-circle-app" push origin claude/esoteric-circle-master-order-e798aj
```

Se il gestore delle credenziali chiede una finestra interattiva e fallisce, non insistere: scrivilo in testa all'esito e prosegui col resto. Mauro lo sbloccherà al risveglio.
