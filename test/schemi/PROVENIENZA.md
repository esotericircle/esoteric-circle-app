# Da dove viene `codemagic-schema.json`

Scaricato il **6 agosto 2026** da:

    https://codemagic.io/codemagic-schema.json

E' lo schema ufficiale che Codemagic pubblica e che gli editor integrati con
schemastore.org usano per validare `codemagic.yaml`. Titolo dichiarato dentro il
file: *Codemagic CI/CD configuration file - docs.codemagic.io*.

## Perche' sta nel repository invece di essere scaricato dalla prova

Una prova che scarica da Internet fallisce quando la rete non c'e', e quando
fallisce non si sa se sia colpa del file o della linea. Qui lo schema e' un dato
versionato: la prova gira sempre, e quando lo schema cambia si aggiorna con un
commit che si vede.

## Quando riscaricarlo

Quando Codemagic aggiunge una chiave che ci serve e la prova la rifiuta come non
ammessa. In quel caso si riscarica, si guarda il `git diff` dello schema, e si
capisce cosa e' cambiato prima di fidarsi.

    curl -sS -L -o test/schemi/codemagic-schema.json https://codemagic.io/codemagic-schema.json

## Cosa lo schema NON controlla

Lo dice la documentazione di Codemagic, e va saputo per non prendere il verde
per piu' di quello che vale: **non** valida il valore di `max_build_duration`,
**non** valida le versioni dei software, **non** valida le credenziali ne' i
valori delle variabili d'ambiente, e **non** sa quali funzioni a pagamento sia
attive sul piano. Il verde di questa prova dice che la struttura e' quella
giusta, non che la build riuscira'.
