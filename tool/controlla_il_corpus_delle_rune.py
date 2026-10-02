# -*- coding: utf-8 -*-
"""IL CONTROLLO DEL CORPUS DELLE RUNE. Ordine EX voce 03, 2 ottobre 2026.

Legge i cinque file dell'Architetto in docs/corpus/rune/ e controlla le regole
della specifica (SPECIFICA.md, sezioni 2, 3 e 7) prima che il generatore li
porti nel codice: i gruppi, i numeri delle voci, le voci che servono, gli
spazi permessi per campo, le lunghezze, le parole vietate, il trattino lungo,
la virgola prima della "e", i nomi di runa dove non vanno, gli apostrofi al
posto degli accenti. Non cambia nessun testo: stampa ogni voce che non passa
col file, il gruppo e il numero, perche' la corregga l'Architetto.

Le lunghezze si misurano a spazi riempiti con valori medi ({cosa} "il
lavoro", {glossa} "ciò che diviene", {gettata} "le tre norne").

  python tool/controlla_il_corpus_delle_rune.py
"""
import pathlib
import re
import sys

RADICE = pathlib.Path(__file__).resolve().parent.parent
CARTELLA = pathlib.Path(__import__('os').environ.get('CARTELLA_DEL_CORPUS', RADICE / 'docs/corpus/rune'))

RUNE = ['Fehu', 'Uruz', 'Thurisaz', 'Ansuz', 'Raidho', 'Kenaz', 'Gebo', 'Wunjo',
        'Hagalaz', 'Nauthiz', 'Isa', 'Jera', 'Eihwaz', 'Perthro', 'Algiz',
        'Sowilo', 'Tiwaz', 'Berkano', 'Ehwaz', 'Mannaz', 'Laguz', 'Ingwaz',
        'Dagaz', 'Othala']
CAMPI = {
    # campo: (spazi permessi, lunghezza minima, massima, nomina la runa)
    'risposta': ({'cosa'}, 60, 160, False),
    'verdetto': ({'cosa'}, 60, 160, False),
    'pietra': ({'cosa', 'glossa'}, 80, 240, True),
    'legame': ({'gettata'}, 60, 200, False),
    'gesto': ({'cosa'}, 40, 140, False),
}
RIEMPI = {'cosa': 'il lavoro', 'glossa': 'ciò che diviene',
          'gettata': 'le tre norne'}
VIETATE = ['guarigion', 'guarir', 'salute', 'malatt', 'fertilit', 'longevit',
           'vittori', 'ricchezz', 'tesor', 'armi']
ASTRI = ['pianet', 'zodiac', 'oroscop', 'astral', 'costellazion']


def leggi_le_voci_che_servono():
    out, campo = {}, None
    for r in (CARTELLA / 'le_voci_che_servono.txt').read_text(
            encoding='utf-8').splitlines():
        t = re.match(r'^([A-Z]+): \d+ gruppi', r)
        if t:
            campo = t.group(1).lower()
            out[campo] = {}
            continue
        v = re.match(r'^  (\S+) / (\S+): (\d+)$', r)
        if v and campo:
            out[campo][f'{v.group(1)}/{v.group(2)}'] = int(v.group(3))
    return out


def gruppo(campo, titolo):
    a, b = [x.strip() for x in titolo.split(',', 1)]
    if campo in ('risposta', 'pietra', 'gesto'):
        return f"{a}/{'ombra' if b == 'in ombra' else 'dritta'}"
    return f'{a}/{b}'


def main():
    servono = leggi_le_voci_che_servono()
    difetti = []
    totale = 0
    for campo, (spazi, lmin, lmax, nomina) in CAMPI.items():
        testo = (CARTELLA / f'{campo}.md').read_text(encoding='utf-8')
        gruppi, g = {}, None
        for n_riga, riga in enumerate(testo.splitlines(), 1):
            t = re.match(r'^## (.+)$', riga)
            if t:
                g = gruppo(campo, t.group(1))
                if g in gruppi:
                    difetti.append(f'{campo}.md riga {n_riga}: gruppo {g} ripetuto')
                gruppi[g] = []
                continue
            v = re.match(r'^(\d+)\.\s?(.*)$', riga)
            if not v or g is None:
                if riga.strip() and g is not None:
                    difetti.append(f'{campo}.md riga {n_riga}: riga fuori forma')
                continue
            n, voce = int(v.group(1)), v.group(2).rstrip()
            if n != len(gruppi[g]) + 1:
                difetti.append(f'{campo}.md, {g}, voce {n}: numero fuori fila')
            gruppi[g].append(voce)
            if not voce:
                continue
            totale += 1
            dove = f'{campo}.md, {g}, voce {n}'
            usati = set(re.findall(r'\{([a-z]+)\}', voce))
            if usati - spazi:
                difetti.append(f'{dove}: spazio non permesso {sorted(usati - spazi)}')
            pieno = re.sub(r'\{([a-z]+)\}', lambda m: RIEMPI.get(m.group(1), ''),
                           voce)
            if not lmin <= len(pieno) <= lmax:
                difetti.append(f'{dove}: lunghezza {len(pieno)} fuori da '
                               f'{lmin}-{lmax}')
            if '—' in voce or '–' in voce:
                difetti.append(f'{dove}: trattino lungo')
            if re.search(r',\s+e\s', voce):
                difetti.append(f'{dove}: virgola prima della "e"')
            basso = voce.lower()
            for p in VIETATE:
                if re.search(r'\b' + p, basso):
                    difetti.append(f'{dove}: parola vietata "{p}"')
            for p in ASTRI:
                if p in basso:
                    difetti.append(f'{dove}: astro "{p}"')
            nominate = [r for r in RUNE if re.search(r'\b' + r + r'\b', voce)]
            if nominate and not nomina:
                difetti.append(f'{dove}: nomina la runa {nominate}')
            if nomina:
                runa = g.split('/')[0]
                if runa not in nominate:
                    difetti.append(f'{dove}: non nomina la sua runa {runa}')
                altre = [r for r in nominate if r != runa]
                if altre:
                    difetti.append(f'{dove}: nomina un\'altra runa {altre}')
            if re.search(r"\b(e|perche|poiche|cosi|gia|piu|puo|cio|pero|sara|"
                         r"verra|potra)'", basso):
                difetti.append(f'{dove}: apostrofo al posto dell\'accento')
            if 'ascolta te stess' in basso:
                difetti.append(f'{dove}: "ascolta te stesso"')
        attesi = set(servono[campo])
        if set(gruppi) != attesi:
            difetti.append(f'{campo}.md: gruppi mancanti {sorted(attesi - set(gruppi))}, '
                           f'in piu\' {sorted(set(gruppi) - attesi)}')
        for g2, voci in gruppi.items():
            piene = sum(1 for v in voci if v)
            if g2 in servono[campo] and piene < servono[campo][g2]:
                difetti.append(f'{campo}.md, {g2}: {piene} voci, ne servono '
                               f'{servono[campo][g2]}')
        print(f'{campo}: {len(gruppi)} gruppi, '
              f'{sum(sum(1 for v in vv if v) for vv in gruppi.values())} voci')
    print(f'voci in tutto: {totale}')
    print(f'difetti: {len(difetti)}')
    for d in difetti:
        print('  ' + d)
    return 1 if difetti else 0


if __name__ == '__main__':
    sys.exit(main())
