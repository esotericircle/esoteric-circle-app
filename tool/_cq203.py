# -*- coding: utf-8 -*-
"""CQ2.03: via il rito annunciato che non c'e', da tutti e quattro i posti."""
import re

NL = chr(10)
CR = chr(13)

POSTI = [
    'lib/features/rituals/dream_rite_screen.dart',
    'lib/features/rituals/ritual_gift_card.dart',
    'lib/features/rituals/ritual_view.dart',
    'lib/features/rituals/sunset_rune_screen.dart',
]

MOTIVO = """// **IL RITO ANNUNCIATO NON C'ERA, E LE TRE RIGHE SONO USCITE.**
// Ordine CQ voce 2.03, 3 settembre 2026.
//
// **Il fatto, parole del fondatore:** l'Arcano *"annuncia un rito che non
// esiste"*. La riga in cima diceva IL RITO DI OGGI e sotto stavano "Cosa
// fai", "Perche'" e "Cosa ti resta": tre righe di istruzioni davanti a un
// dono che deve rispondere. **La prima cosa che si leggeva era un compito**,
// e la misura della voce 2.00 lo ha trovato in tutti e cinque i Doni, non
// solo nell'Arcano.
//
// **Le tre righe restano nel dato**, su `DailyElement`, e continuano a
// descrivere il Dono dove una descrizione serve davvero, cioe' nel menu'
// degli avvisi dove si sceglie quali ricevere. Cio' che esce e' la loro
// comparsa in cima al responso.
"""


def leggi(p):
    return open(p, 'rb').read().decode('utf-8')


def scrivi(p, s):
    open(p, 'wb').write(s.encode('utf-8'))


for percorso in POSTI:
    grezzo = leggi(percorso)
    crlf = CR in grezzo
    s = grezzo.replace(CR + NL, NL) if crlf else grezzo
    apri = s.index('LeTreRigheDelRito(')
    # si risale all'inizio della riga
    inizio = s.rindex(NL, 0, apri) + 1
    rientro = len(s[inizio:apri]) - len(s[inizio:apri].lstrip())
    # si scende fino alla parentesi che chiude la chiamata
    livello = 0
    i = apri + len('LeTreRigheDelRito')
    while True:
        if s[i] == '(':
            livello += 1
        elif s[i] == ')':
            livello -= 1
            if livello == 0:
                break
        i += 1
    fine = i + 1
    if s[fine:fine + 1] == ',':
        fine += 1
    fine = s.index(NL, fine) + 1
    spazi = ' ' * (len(s[inizio:apri]) - len(s[inizio:apri].lstrip()))
    commento = NL.join(spazi + r for r in MOTIVO.rstrip(NL).split(NL)) + NL
    s = s[:inizio] + commento + s[fine:]
    scrivi(percorso, s.replace(NL, CR + NL) if crlf else s)
    controllo = leggi(percorso)
    assert 'LeTreRigheDelRito(' not in controllo, percorso
    print('FATTO', percorso)

# l'import resta orfano: si toglie
for percorso in POSTI:
    grezzo = leggi(percorso)
    crlf = CR in grezzo
    s = grezzo.replace(CR + NL, NL) if crlf else grezzo
    if 'LeTreRigheDelRito' in s:
        continue
    s = re.sub(r"import [^;]*le_tre_righe_del_rito\.dart';\n", '', s)
    scrivi(percorso, s.replace(NL, CR + NL) if crlf else s)
print('IMPORT ORFANI TOLTI')
