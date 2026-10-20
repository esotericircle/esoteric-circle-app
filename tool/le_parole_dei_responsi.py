# -*- coding: utf-8 -*-
"""LE PAROLE DEI RESPONSI. Ordine GA voci GA.03 e GA.07, 20 ottobre 2026.

Il fondatore, 19 ottobre 2026: *"tutte le risposte composte da paragrafi ognuno
con tra 40 a 50 parole ognuno"*. Le parole si contano come le conta chi legge:
separate da uno spazio. Il titolo, il titolo del riquadro e il "Da dove viene"
sono fuori dal conto.

Questo strumento legge i corpora dell'Oroscopo (`docs/corpus/eu/*.md`) e per
ogni voce controlla i paragrafi che vanno a video nella forma nuova:

- "Risposta" (il paragrafo 1, la risposta);
- "Che cosa fare" (il paragrafo 2, nel riquadro "Cosa fare adesso");
- "Risposta, Lunga" (il paragrafo 3 della Lunga, che approfondisce).

"Che cosa fare, Lunga" non va piu' a video (il quarto paragrafo della Lunga e'
il rito propiziatorio della tradizione, voce GA.04) e non si controlla.

Controlla anche le regole di lingua di casa: niente trattino lungo, niente
virgola prima di "e" o di "ed", niente punto esclamativo, niente apostrofo al
posto dell'accento nelle parole che lo vogliono (piu', perche', gia', cosi',
puo', e' verbo).

    python tool/le_parole_dei_responsi.py [file.md ...]

Senza argomenti guarda tutti i dodici corpora. Esce con 1 se trova un difetto.
"""
import glob
import re
import sys

CAMPI = {
    'Risposta': 'risposta',
    'Che cosa fare': 'cosa fare',
    'Risposta, Lunga': 'approfondimento',
}
MINIMO, MASSIMO = 40, 50
VOCE = re.compile(r'^#### (.+)$')
CAMPO = re.compile(r'^- (Risposta|Che cosa fare|Risposta, Lunga|'
                   r'Che cosa fare, Lunga): (.*)$')
ACCENTI = re.compile(r"\b(piu|perche|gia|cosi|puo|pero|perche|finche|"
                     r"poiche|affinche|cioe|nonche)'", re.IGNORECASE)
# Il futuro rivolto a chi legge (test/i_corpora_non_dicono_il_futuro_test.dart
# e ConfineDelResponso.formeDellaPrevisione): le parole in "-rai" che non sono
# un futuro sono queste.
NON_FUTURI = {'distrai', 'attrai', 'estrai', 'sottrai', 'trai', 'ritrai',
              'contrai'}
FUTURO = re.compile(r'(?<![a-zàèéìòù])([a-zàèéìòù]+rai)(?![a-zàèéìòù])',
                    re.IGNORECASE)
CERTEZZA = re.compile(r"\b(e['’]\s+certo|è\s+certo|sicuramente|senza\s+dubbio)\b",
                      re.IGNORECASE)
# Il confine del responso: niente che dichiari da dove viene il testo.
DICHIARA = re.compile(r'\b(corpus|il sistema|l\'algoritmo)\b', re.IGNORECASE)


def parole(testo):
    return len(testo.split())


def difetti_di_lingua(testo):
    fuori = []
    if '—' in testo or '–' in testo:
        fuori.append('trattino lungo')
    if re.search(r',\s+(e|ed)\s', testo):
        fuori.append('virgola prima di "e"')
    if '!' in testo:
        fuori.append('punto esclamativo')
    if ACCENTI.search(testo) or re.search(r"\be' ", testo):
        fuori.append('apostrofo al posto dell\'accento')
    for m in FUTURO.finditer(testo):
        if m.group(1).lower() not in NON_FUTURI:
            fuori.append(f'futuro rivolto a chi legge: «{m.group(1)}»')
    if CERTEZZA.search(testo):
        fuori.append('certezza sul futuro')
    if DICHIARA.search(testo):
        fuori.append('il testo dichiara da dove viene')
    if re.search(r'\d', testo):
        fuori.append('cifra nel testo')
    return fuori


def frasi(testo):
    return [f.strip().lower() for f in re.split(r'(?<=[.?:;])\s+', testo)
            if len(f.split()) >= 5]


def guarda(percorso):
    difetti = []
    voci = 0
    paragrafi = 0
    voce = None
    viste = {}
    with open(percorso, encoding='utf-8') as f:
        for riga in f:
            riga = riga.rstrip('\n')
            m = VOCE.match(riga)
            if m:
                voce = m.group(1)
                voci += 1
                continue
            m = CAMPO.match(riga)
            if not m or voce is None:
                continue
            nome, testo = m.group(1), m.group(2)
            if nome not in CAMPI:
                continue
            paragrafi += 1
            n = parole(testo)
            if not MINIMO <= n <= MASSIMO:
                difetti.append(f'{voce} | {nome}: {n} parole')
            for d in difetti_di_lingua(testo):
                difetti.append(f'{voce} | {nome}: {d}')
            # Nessuna frase torna uguale in due voci dello stesso file.
            for f in frasi(testo):
                if f in viste and viste[f] != voce:
                    difetti.append(f'{voce} | {nome}: frase gia\' in '
                                   f'«{viste[f]}»: «{f[:60]}»')
                viste.setdefault(f, voce)
    return voci, paragrafi, difetti


def main(argomenti):
    file = argomenti or sorted(glob.glob('docs/corpus/eu/oroscopo_eu_*.md'))
    tutti = 0
    for percorso in file:
        voci, paragrafi, difetti = guarda(percorso)
        tutti += len(difetti)
        print(f'{percorso}: {voci} voci, {paragrafi} paragrafi, '
              f'{len(difetti)} difetti')
        for d in difetti[:40]:
            print(f'  {d}')
        if len(difetti) > 40:
            print(f'  ... e altri {len(difetti) - 40}')
    print('NESSUN DIFETTO' if tutti == 0 else f'DIFETTI: {tutti}')
    return 0 if tutti == 0 else 1


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
