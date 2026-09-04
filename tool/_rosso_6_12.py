# -*- coding: utf-8 -*-
"""La prova del rosso della guardia della voce 6.12, regola A.

Tre innesti, uno per pretesa. Ogni innesto si verifica COL GREP prima di
leggere l'esito: chi legge l'esito senza aver verificato l'innesto misura un
errore suo.
"""
import io
import subprocess
import sys

NL = chr(10)
A = chr(39)
P = 'docs/ordini/DISTRIBUZIONI_DAL_TUO_PC.md'
PROVA = 'test/un_comando_di_distribuzione_ha_il_suo_controllo_test.dart'
ORIGINALE = io.open(P, encoding='utf-8', newline='').read()

INNESTI = [
    ('il controllo torna a nominare uno sha',
     'git rev-list --count HEAD..origin/claude/esoteric-circle-master-order-e798aj',
     'git log --oneline -1',
     'git log --oneline -1'),
    ('il ripiego FERMATI QUI sparisce',
     'FERMATI QUI e porta la cartella avanti',
     'e porta la cartella avanti',
     'e porta la cartella avanti'),
    ('il controllo della porta della Demo sparisce',
     'Select-String -Path functions' + chr(92) + 'src' + chr(92) +
     'index.ts -Pattern attivaIlPianoInDemo',
     'Write-Host andiamo',
     'Write-Host andiamo'),
]

righe = []
rossi = 0
for nome, vecchio, nuovo, spia in INNESTI:
    testo = ORIGINALE
    assert testo.count(vecchio) >= 1, ('innesto non applicabile', nome)
    testo = testo.replace(vecchio, nuovo, 1)
    io.open(P, 'w', encoding='utf-8', newline='').write(testo)
    # **IL GREP, PRIMA DI LEGGERE L'ESITO.** Regola A: chi legge l'esito senza
    # aver verificato che il difetto sia entrato misura un errore suo.
    dentro = io.open(P, encoding='utf-8').read()
    entrato = spia in dentro and vecchio not in dentro
    assert entrato, ('innesto NON entrato nel file', nome)
    out = subprocess.run([sys.argv[1] if len(sys.argv) > 1 else 'flutter',
                          'test', PROVA],
                         capture_output=True, text=True, shell=True)
    caduta = 'All tests passed' not in out.stdout
    rossi += 1 if caduta else 0
    righe.append(('ROSSA' if caduta else 'VERDE') + '     ' + nome)
    io.open(P, 'w', encoding='utf-8', newline='').write(ORIGINALE)

# **IL RIPRISTINO SI VERIFICA COL BYTE**, non sulla parola del replace.
assert io.open(P, encoding='utf-8', newline='').read() == ORIGINALE, \
    'IL FOGLIO NON E RITORNATO COME PRIMA'

print(NL.join(righe))
print('INNESTI CHE HANNO FATTO ROSSA LA GUARDIA: ' + str(rossi) + ' su ' +
      str(len(INNESTI)))
