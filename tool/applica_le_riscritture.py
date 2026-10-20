# -*- coding: utf-8 -*-
"""APPLICA LE RISCRITTURE DEI CORPORA DELL'OROSCOPO. Ordine GA voce GA.07,
20 ottobre 2026.

I dodici corpora `docs/corpus/eu/oroscopo_eu_*.md` si riscrivono nella forma
della voce GA.03 da piu' scrittori in parallelo: ognuno scrive le sue voci in
un file a parte, nella stessa forma del corpus (l'intestazione `####` e i
paragrafi a elenco), e questo strumento le rimette al loro posto.

Una voce si riconosce dalla parte dell'intestazione prima dei due punti
("Generale, favorevole, voce 1"): il titolo dopo i due punti puo' cambiare.
La voce riscritta sostituisce tutte le righe a elenco della voce vecchia,
quindi anche "Che cosa fare, Lunga", che nella forma nuova non c'e' piu'.

    python tool/applica_le_riscritture.py <corpus.md> <parte.md> [...]

Si ferma senza scrivere niente se una voce della parte non c'e' nel corpus,
o se una voce riscritta non ha esattamente i tre paragrafi della forma nuova.
"""
import io
import re
import sys

INTESTAZIONE = re.compile(r'^#### (.+?): (.+)$')
ATTESI = ['- Risposta: ', '- Che cosa fare: ', '- Risposta, Lunga: ']


def voci_della_parte(testo):
    voci = {}
    chiave = None
    for riga in testo.splitlines():
        m = INTESTAZIONE.match(riga)
        if m:
            chiave = m.group(1)
            if chiave in voci:
                raise SystemExit(f'voce doppia nella parte: {chiave}')
            voci[chiave] = [riga, []]
            continue
        if chiave and riga.startswith('- '):
            voci[chiave][1].append(riga)
    for chiave, (_, righe) in voci.items():
        if len(righe) != 3 or not all(r.startswith(a)
                                      for r, a in zip(righe, ATTESI)):
            raise SystemExit(f'la voce «{chiave}» non ha i tre paragrafi '
                             f'Risposta, Che cosa fare, Risposta Lunga')
    return voci


def applica(percorso, parti):
    testo = io.open(percorso, encoding='utf-8', newline='').read()
    a_capo = '\r\n' if '\r\n' in testo else '\n'
    righe = testo.split(a_capo)
    nuove = {}
    for p in parti:
        for k, v in voci_della_parte(
                io.open(p, encoding='utf-8').read()).items():
            if k in nuove:
                raise SystemExit(f'voce in due parti: {k}')
            nuove[k] = v
    fuori = []
    usate = set()
    i = 0
    while i < len(righe):
        m = INTESTAZIONE.match(righe[i])
        if not m or m.group(1) not in nuove:
            fuori.append(righe[i])
            i += 1
            continue
        intestazione, paragrafi = nuove[m.group(1)]
        usate.add(m.group(1))
        fuori.append(intestazione)
        i += 1
        # Le righe vuote dopo l'intestazione restano; le righe a elenco della
        # voce vecchia si sostituiscono tutte.
        while i < len(righe) and not righe[i].startswith('- ') \
                and not righe[i].startswith('#'):
            fuori.append(righe[i])
            i += 1
        while i < len(righe) and righe[i].startswith('- '):
            i += 1
        fuori.extend(paragrafi)
    mancanti = sorted(set(nuove) - usate)
    if mancanti:
        raise SystemExit('voci della parte che il corpus non ha: '
                         + ', '.join(mancanti[:10]))
    io.open(percorso, 'w', encoding='utf-8', newline='').write(
        a_capo.join(fuori))
    print(f'{percorso}: {len(usate)} voci riscritte')


if __name__ == '__main__':
    if len(sys.argv) < 3:
        raise SystemExit(__doc__)
    applica(sys.argv[1], sys.argv[2:])
