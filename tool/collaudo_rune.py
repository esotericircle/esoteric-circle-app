# -*- coding: utf-8 -*-
"""IL COLLAUDO DELLE RUNE, sul telefono vero.

**Ordine CQ voce 6.18, 4 settembre 2026.** Verifica a video le quattro cose che
il fondatore ha contestato guardando gli screenshot della gettata a tre rune,
e le verifica **dove lui le ha viste**: sullo schermo, non nel sorgente.

| cosa | come si riconosce a video |
| --- | --- |
| 6.14, la frase della Luna | non deve comparire "la ultimo" ne' "la primo" |
| 6.16, la domanda | deve comparire UNA volta sola, e per intero |
| 6.17, il Sigillo | deve nominare la domanda e le parole delle rune |
| 6.15, i caratteri | i blocchi di prosa devono avere la stessa altezza di riga |

**Cosa questo strumento non puo' fare**, e si dichiara: non misura i punti
tipografici, che l'albero delle viste non espone. Misura l'altezza dei
rettangoli del testo, che e' cio' che l'occhio confronta.
"""
import os
import re
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from collaudo_a_video import adb, apri, cattura, schermo, telefono  # noqa: E402

NL = chr(10)


def albero():
    """L'albero delle viste, grezzo: serve anche per i rettangoli."""
    adb('shell', 'uiautomator', 'dump', '/sdcard/vista.xml')
    return adb('shell', 'cat', '/sdcard/vista.xml')


def nodi(grezzo):
    """Ogni nodo col suo testo e il suo rettangolo."""
    fuori = []
    for m in re.finditer(
            r'text="([^"]*)"[^>]*?bounds="\[(\d+),(\d+)\]\[(\d+),(\d+)\]"',
            grezzo):
        testo = m.group(1).strip()
        if not testo:
            continue
        x1, y1, x2, y2 = (int(m.group(i)) for i in range(2, 6))
        fuori.append({'testo': testo, 'x': x1, 'y': y1,
                      'larghezza': x2 - x1, 'altezza': y2 - y1})
    return fuori


def tutto_il_testo(passi=8):
    """Scorre la schermata fino in fondo e raccoglie tutto quello che vede."""
    w, h = schermo()
    visti = []
    chiavi = set()
    for _ in range(passi):
        for n in nodi(albero()):
            chiave = n['testo']
            if chiave in chiavi:
                continue
            chiavi.add(chiave)
            visti.append(n)
        adb('shell', 'input', 'swipe', str(w // 2), str(int(h * 0.78)),
            str(w // 2), str(int(h * 0.28)), '350')
        time.sleep(0.9)
    return visti


def referto(visti, domanda):
    """Le quattro misure, dette col numero."""
    righe = []
    testo = ' | '.join(n['testo'] for n in visti)

    # 6.14, la Luna.
    storte = re.findall(r'la (ultimo|primo) quarto', testo)
    righe.append('VOCE 6.14  frasi della Luna sgrammaticate a video: '
                 + str(len(storte))
                 + ('' if not storte else '  -> ' + str(storte)))

    # 6.16, la domanda nominata una volta sola.
    quante = sum(1 for n in visti if domanda.lower() in n['testo'].lower())
    righe.append('VOCE 6.16  volte in cui la domanda compare per intero: '
                 + str(quante))

    # E la vecchia formula vuota non deve esserci piu'.
    vuote = sum(1 for n in visti if 'Dentro la tua domanda' in n['testo'])
    righe.append('VOCE 6.16  volte in cui compare la vecchia formula vuota: '
                 + str(vuote))

    # 6.17, il Sigillo.
    sigillo = [n['testo'] for n in visti
               if 'ti resta quando i testi' in n['testo']]
    righe.append('VOCE 6.17  la riga del Sigillo a video: '
                 + (sigillo[0][:150] if sigillo else 'NON TROVATA'))
    if sigillo:
        righe.append('VOCE 6.17  il Sigillo nomina la domanda: '
                     + str(domanda.lower() in sigillo[0].lower()))
        righe.append('VOCE 6.17  "e cio" senza accento a video: '
                     + str('e cio ' in sigillo[0]))

    # 6.15, le altezze di riga dei blocchi di prosa.
    prosa = [n for n in visti if len(n['testo']) > 60]
    altezze = {}
    for n in prosa:
        righe_stimate = max(1, round(n['altezza'] / 60))
        altezze.setdefault(round(n['altezza'] / righe_stimate / 5) * 5, 0)
        altezze[round(n['altezza'] / righe_stimate / 5) * 5] += 1
    righe.append('VOCE 6.15  blocchi di prosa guardati: ' + str(len(prosa))
                 + ', altezze di riga distinte: ' + str(sorted(altezze)))
    return NL.join(righe)


if __name__ == '__main__':
    if telefono() is None:
        raise SystemExit('nessun telefono collegato')
    domanda = sys.argv[1] if len(sys.argv) > 1 else ''
    apri()
    visti = tutto_il_testo()
    print('TESTO RACCOLTO A VIDEO, ' + str(len(visti)) + ' blocchi')
    for n in visti:
        print('  [' + str(n['altezza']).rjust(4) + '] ' + n['testo'][:110])
    if domanda:
        print(NL + referto(visti, domanda))
