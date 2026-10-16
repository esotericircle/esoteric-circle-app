# -*- coding: utf-8 -*-
"""QUANTE VOCI SERVONO AL CORPUS DELLE RUNE PER NON RIPETERE IN 60 GIORNI.
Ordine EX, voce EX.03, 2 ottobre 2026.

Simula le gettate come le fa l'app (lib/core/rituals/rune_cast.dart):
- quattro gettate: Odino 1 runa, Norne 3, Croce 5, telo 7 lette;
- 24 rune tutte diverse in una gettata; 8 simmetriche sempre dritte
  (Gebo, Hagalaz, Isa, Jera, Eihwaz, Sowilo, Ingwaz, Dagaz);
- merkstave al 50 per cento nelle gettate fisse, al 35 sul telo;
- sul telo le rune si leggono in ordine di distanza dal centro: la prima
  "Al centro", la seconda "Presso il centro", le altre "Ai margini".

Al massimo dell'Illuminato (3 gettate al giorno per 60 giorni, 180 gettate)
conta, per ogni gruppo del corpus (vedi docs/corpus/rune/SPECIFICA.md), quante
volte lo stesso gruppo serve a una persona. Con la memoria di cio' che la
persona ha letto, una voce non torna finche' il gruppo non e' consumato: il
gruppo deve avere almeno tante voci quante volte serve in 60 giorni.

Due scenari:
- MISTO: gettata e domanda a caso;
- PEGGIORE: sempre il telo (piu' rune per gettata) e sempre la stessa
  domanda.
Per ogni gruppo si prende il massimo su 4000 persone simulate e si aggiunge
un margine del 20 per cento: e' il numero di voci che il corpus deve avere.

  python tool/le_voci_che_servono_alle_rune.py
"""
import math
import random
from collections import Counter

RUNE = ['Fehu', 'Uruz', 'Thurisaz', 'Ansuz', 'Raidho', 'Kenaz', 'Gebo', 'Wunjo',
        'Hagalaz', 'Nauthiz', 'Isa', 'Jera', 'Eihwaz', 'Perthro', 'Algiz', 'Sowilo',
        'Tiwaz', 'Berkano', 'Ehwaz', 'Mannaz', 'Laguz', 'Ingwaz', 'Dagaz', 'Othala']
SIMMETRICHE = {'Gebo', 'Hagalaz', 'Isa', 'Jera', 'Eihwaz', 'Sowilo', 'Ingwaz', 'Dagaz'}
AETT = {r: ['Freyr', 'Hagal', 'Tyr'][i // 8] for i, r in enumerate(RUNE)}
GETTATE = {'odino': 1, 'norne': 3, 'croce': 5, 'telo': 7}
CHIAVE = {'odino': 0, 'norne': 2, 'croce': 4, 'telo': 0}  # la pietra che decide
GIORNI, AL_GIORNO, PERSONE, MARGINE = 60, 3, 4000, 1.2


def getta(rng, gettata):
    n = GETTATE[gettata]
    p = 0.35 if gettata == 'telo' else 0.5
    rune = rng.sample(RUNE, n)
    return [(r, 'dritta' if r in SIMMETRICHE or rng.random() >= p else 'ombra') for r in rune]


def tono(pietre):
    ombre = sum(v == 'ombra' for _, v in pietre)
    if ombre == 0:
        return 'luce'
    return 'ombra' if ombre * 2 > len(pietre) else 'misto'


def aett_dominante(pietre, chiave):
    # La famiglia con piu' pietre; a parita' quella della pietra che decide.
    c = Counter(AETT[r] for r, _ in pietre)
    massimo = max(c.values())
    pari = [a for a, n in c.items() if n == massimo]
    return AETT[chiave[0]] if AETT[chiave[0]] in pari else sorted(pari)[0]


def una_persona(rng, peggiore):
    usi = Counter()
    for _ in range(GIORNI * AL_GIORNO):
        gettata = 'telo' if peggiore else rng.choice(list(GETTATE))
        pietre = getta(rng, gettata)
        chiave = pietre[CHIAVE[gettata]]
        # 1. La risposta, prima frase: la pietra che decide, nel suo verso.
        usi[('risposta', chiave)] += 1
        # 2. La risposta, seconda frase: il tono della gettata e la famiglia
        # (aett) che domina.
        usi[('verdetto', tono(pietre), aett_dominante(pietre, chiave))] += 1
        # 3. Da dove viene, una voce per pietra: la runa nel suo verso.
        for p in pietre:
            usi[('pietra', p)] += 1
        # 4. Il legame fra le pietre: la gettata e il tono.
        usi[('legame', gettata, tono(pietre))] += 1
        # 5. Cosa puoi fare: la pietra che decide, nel suo verso.
        usi[('gesto', chiave)] += 1
    return usi


def gruppi(peggiore):
    rng = random.Random(20261002 + peggiore)
    massimi = Counter()
    for _ in range(PERSONE):
        for k, v in una_persona(rng, peggiore).items():
            massimi[k] = max(massimi[k], v)
    return massimi


def riassunto(massimi):
    per_campo = {}
    for k, v in massimi.items():
        per_campo.setdefault(k[0], {})[k[1:]] = v
    return per_campo


def tabella():
    """Per ogni gruppo il massimo fra i due scenari, col margine."""
    unione = {}
    for peggiore in (False, True):
        for k, v in gruppi(peggiore).items():
            unione[k] = max(unione.get(k, 0), v)
    righe = ['VOCI CHE SERVONO AL CORPUS DELLE RUNE PER 60 GIORNI SENZA RIPETERE',
             f'(tool/le_voci_che_servono_alle_rune.py: {PERSONE} persone simulate per '
             f'scenario, MISTO e PEGGIORE, {GIORNI} giorni, {AL_GIORNO} gettate al giorno; '
             f'massimo dei due scenari per gruppo, margine {int((MARGINE - 1) * 100)} per cento)', '']
    totale = 0
    for campo in ('risposta', 'verdetto', 'pietra', 'legame', 'gesto'):
        g = {k[1:]: math.ceil(v * MARGINE) for k, v in unione.items() if k[0] == campo}
        somma = sum(g.values())
        totale += somma
        righe.append(f'{campo.upper()}: {len(g)} gruppi, {somma} voci')
        def piatto(k):
            for x in k:
                if isinstance(x, tuple):
                    yield from piatto(x)
                else:
                    yield str(x)
        for k in sorted(g):
            righe.append(f'  {" / ".join(piatto(k))}: {g[k]}')
        righe.append('')
    righe.append(f'TOTALE: {totale} voci')
    return '\n'.join(righe) + '\n'


if __name__ == '__main__':
    import sys
    if len(sys.argv) > 1 and sys.argv[1] == 'tabella':
        out = 'docs/corpus/rune/le_voci_che_servono.txt'
        import os
        os.makedirs('docs/corpus/rune', exist_ok=True)
        open(out, 'w', encoding='utf-8', newline='').write(tabella())
        print(open(out, encoding='utf-8').read()[-400:])
        sys.exit(0)
    for nome, peggiore in (('MISTO', False), ('PEGGIORE', True)):
        print(f'== {nome}: {GIORNI} giorni, {AL_GIORNO} gettate al giorno, '
              f'{PERSONE} persone simulate')
        for campo, g in riassunto(gruppi(peggiore)).items():
            serve = {k: math.ceil(v * MARGINE) for k, v in g.items()}
            print(f'{campo}: gruppi {len(g)}, uso massimo per gruppo da '
                  f'{min(g.values())} a {max(g.values())}; voci da scrivere col '
                  f'margine: da {min(serve.values())} a {max(serve.values())} per '
                  f'gruppo, {sum(serve.values())} in tutto')
