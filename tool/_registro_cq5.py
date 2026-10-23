# -*- coding: utf-8 -*-
"""CQ5: il registro delle guardie si riallinea contando, non a mano."""
NL = chr(10)
A = chr(39)
P = 'docs/guardie.md'
s = open(P, 'rb').read().decode('utf-8')
assert chr(13) not in s

# 1. Un vocabolario solo per la stessa cosa. Cinque righe dicevano "cardinale
#    proprio" e quarantacinque "proprio, dichiarato": due nomi per la stessa
#    classe fanno due conti della stessa cosa, che e' il difetto che questo
#    registro esiste per non avere.
quante = s.count('| cardinale proprio |')
assert quante == 5, quante
s = s.replace('| cardinale proprio |', '| proprio, dichiarato |')

# 2. Le tre categorie si riscrivono da cio' che la tavola dice davvero.
vecchio = ('| Guardie che passano dalla porta comune | 3 |' + NL +
           '| Guardie con un cardinale proprio dichiarato | 39 |' + NL +
           '| Guardie che non scoprono nessun insieme di file | 235 |')
nuovo = ('| Guardie che passano dalla porta comune | 111 |' + NL +
         '| Guardie con un cardinale proprio dichiarato | 50 |' + NL +
         '| Guardie che non scoprono nessun insieme di file | 122 |')
assert s.count(vecchio) == 1
s = s.replace(vecchio, nuovo)

nota = ("""Le due righe in grassetto **coincidono**, contate il 4 settembre 2026.

**E le tre categorie erano false, scoperto con l'ordine CQ voce 5.05.** Dicevano
3, 39 e 235: sommavano al totale giusto e nessuna delle tre era il numero che la
tavola qui sotto porta scritto nella sua colonna. **La guardia non se ne era
accorta perche' controllava soltanto che le tre cifre sommassero fra loro**, cioe'
la coerenza di tre numeri inventati insieme. Era la seconda specie di cecita', la
guardia cieca al bersaglio, dentro il documento che quella tavola la definisce.
Adesso i tre numeri sono contati sulla colonna, e sono 111, 50 e 122.

La terza""")
vecchia_nota = """Le due righe in grassetto **coincidono**, contate il 3 settembre 2026. La terza"""
assert s.count(vecchia_nota) == 1
s = s.replace(vecchia_nota, nota)

# 3. Il disallineamento delle otto righe non esisteva: era un grep incompleto.
i = s.index('**E QUI DUE CONTI DELLA STESSA COSA NON TORNANO')
j = s.index('Il **17** dell' + A + 'ordine CL')
s = s[:i] + ("""**E QUI DUE CONTI DELLA STESSA COSA TORNAVANO A NON TORNARE, E IL COLPEVOLE
ERA IL COMANDO.** Fino all'ordine CQ questo paragrafo diceva che la tavola
classificava **108** guardie "dalla porta comune" mentre il grep ne trovava
**100**, e attribuiva le otto righe di differenza a una classificazione sbagliata
da riparare a mano una per una.

**Non c'era niente da riparare.** Il grep cercava due nomi, `sorgentiDiLib(` e
`sorgentiDiCartelle(`, e le porte comuni sono **quattro**: mancavano
`fileScoperti(` e `righeDiLib(`. Contate tutte e quattro, i file che passano da
una porta sono **116**, e i **111** censiti nella tavola sono esattamente quelli
che hanno anche una riga: i cinque di scarto sono prove che usano una porta senza
essere guardie secondo la definizione. **Il numero della tavola era giusto da
sempre, e per tre ordini si e' dato per sbagliato un dato vero sulla parola di un
comando scritto male.** Provenienza: ordine CM voce 03, che ha scritto il grep.

""") + s[j:]

open(P, 'wb').write(s.encode('utf-8'))
print('REGISTRO RIALLINEATO')
