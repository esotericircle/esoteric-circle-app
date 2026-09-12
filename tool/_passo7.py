# -*- coding: utf-8 -*-
"""Scrive il passo 7 del foglio delle distribuzioni: la porta della Demo."""
P = 'docs/ordini/DISTRIBUZIONI_DAL_TUO_PC.md'
NL = chr(10)
B = chr(92)

CARTELLA = 'C:' + B + 'Users' + B + 'user' + B + 'Desktop' + B + \
    'esoteric-circle-app'

PASSO = r'''
---

## PASSO 7. LA PORTA DELLA DEMO, `attivaIlPianoInDemo`

Ordine CQ, rilancio del 3 settembre 2026.

**A cosa serve.** Il pulsante "Attiva in Demo" nella schermata dei Piani
cambiava il piano SOLO dentro il telefono. Il server continuava a leggere
`free` per tutti, e tu vedevi "limite giornaliero raggiunto" con l'Illuminato
attivo. Adesso quel pulsante chiama una funzione che scrive il piano sul
server, e la funzione **nasce chiusa**: senza la variabile qui sotto risponde
`failed-precondition` e non scrive niente.

**Perche' la chiave sta in un file e non in un comando.** In questo progetto le
funzioni leggono l'ambiente da un file `.env` dentro `functions/`, che il
comando di distribuzione carica da solo. Quel file **non finisce su Git**, e'
gia' escluso: resta sul tuo PC, e il giorno che vuoi chiudere la porta basta
togliere la riga e ridistribuire.

**1. Porta la tua cartella alla testa nuova.**

```powershell
cd @CARTELLA@
```

```powershell
git fetch origin
```

```powershell
git checkout claude/esoteric-circle-master-order-e798aj
```

```powershell
git pull
```

**Cosa devi leggere**: l'ultima riga deve nominare un commit dell'ordine CQ.

**2. Scrivi la chiave nel file dell'ambiente.**

```powershell
cd @CARTELLA@\functions
```

```powershell
Add-Content -Path .env -Value 'DEMO_APERTA=1' -Encoding utf8
```

**Cosa devi leggere**: niente. Se non compare nessun errore, e' andata.

**3. Controlla che la riga ci sia davvero, e una volta sola.**

```powershell
Get-Content .env
```

**Cosa devi leggere**: una riga che dice esattamente `DEMO_APERTA=1`. Se ne
vedi due, cancella il file e rifai il passo 2:

```powershell
Remove-Item .env
```

**4. Distribuisci la funzione.**

```powershell
npx firebase deploy --only functions:attivaIlPianoInDemo --project esoteric-circle
```

**Cosa devi leggere**: `Successful create operation` oppure `Successful update
operation`, e poi `Deploy complete!`. Se leggi `Function failed on loading user
code`, fermati e dimmelo.

**5. Controlla che il server la conosca.**

```powershell
npx firebase functions:list --project esoteric-circle
```

**Cosa devi leggere**: nell'elenco deve comparire `attivaIlPianoInDemo`.

**6. La prova vera, sul telefono.** Apri i Piani e premi "Attiva in Demo" su un
livello. Se leggi il nome del piano e basta, il server lo ha registrato. Se
leggi *"attivo solo su questo telefono: il server non lo ha registrato"*, la
porta e' ancora chiusa: rifai il passo 2.

**QUANDO VORRAI CHIUDERLA.** Il giorno che il pagamento vero arriva dal web:

```powershell
cd @CARTELLA@\functions
```

```powershell
Remove-Item .env
```

```powershell
npx firebase deploy --only functions:attivaIlPianoInDemo --project esoteric-circle
```

Da quel momento il pulsante della Demo torna a non poter scrivere niente sul
server, e non serve pubblicare nessuna versione nuova dell'app.
'''

testo = open(P, encoding='utf-8').read().rstrip()
passo = PASSO.replace('@CARTELLA@', CARTELLA)
open(P, 'w', encoding='utf-8').write(testo + NL + passo)
controllo = open(P, encoding='utf-8').read()
assert 'PASSO 7' in controllo
assert 'DEMO_APERTA=1' in controllo
print('passo 7 scritto, righe totali', controllo.count(NL))
