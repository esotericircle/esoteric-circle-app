# -*- coding: utf-8 -*-
"""GENERA IL CORPUS DEL PRESAGIO DELLE RUNE. Ordine EX voce 03.

Legge i cinque file dell'Architetto in docs/corpus/rune/ (risposta.md,
verdetto.md, pietra.md, legame.md, gesto.md: la forma e' in SPECIFICA.md) e
scrive lib/core/rituals/il_corpus_del_presagio.g.dart, carattere per
carattere. Un file che manca vale un campo vuoto: finche' i cinque non ci
sono tutti, il corpus non e' completo e le rune restano lette dal modello.

Un titolo di gruppo si scrive "## Fehu, dritta", "## Fehu, in ombra",
"## misto, Hagal" (verdetto), "## telo, misto" (legame); le voci sono righe
numerate "1. testo". Il numero e' l'identificativo: una voce tolta lascia il
suo numero vuoto ("17." senza testo), e il numero non si riusa.

  python tool/genera_corpus_del_presagio.py
"""
import pathlib
import re
import sys

RADICE = pathlib.Path(__file__).resolve().parent.parent
CARTELLA = RADICE / 'docs/corpus/rune'
USCITA = RADICE / 'lib/core/rituals/il_corpus_del_presagio.g.dart'
CAMPI = ['risposta', 'verdetto', 'pietra', 'legame', 'gesto']


def gruppo_da_titolo(campo, titolo):
    a, b = [x.strip() for x in titolo.split(',', 1)]
    if campo in ('risposta', 'pietra', 'gesto'):
        return f"{a}/{'ombra' if b == 'in ombra' else 'dritta'}"
    return f'{a}/{b}'


def leggi(campo):
    p = CARTELLA / f'{campo}.md'
    if not p.exists():
        return {}
    gruppi, gruppo = {}, None
    for riga in p.read_text(encoding='utf-8').splitlines():
        t = re.match(r'^## (.+)$', riga)
        if t:
            gruppo = gruppo_da_titolo(campo, t.group(1))
            gruppi[gruppo] = []
            continue
        v = re.match(r'^(\d+)\.\s?(.*)$', riga)
        if v and gruppo is not None:
            n = int(v.group(1))
            elenco = gruppi[gruppo]
            if n != len(elenco) + 1:
                sys.exit(f'{campo}.md, {gruppo}: la voce {n} non segue la {len(elenco)}')
            elenco.append(v.group(2).rstrip())
    return gruppi


def dart_stringa(s):
    return "'" + s.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$') + "'"


def main():
    righe = [
        '// GENERATO da tool/genera_corpus_del_presagio.py: non modificare a mano.',
        '// I testi sono dell\'Architetto, in docs/corpus/rune/ (ordine EX voce 03).',
        '',
        "import 'il_presagio_dal_corpus.dart';",
        '',
        '/// Il corpus del presagio delle rune, dai file dell\'Architetto.',
        'const CorpusDelPresagio corpusDelPresagio = CorpusDelPresagio({',
    ]
    for campo in CAMPI:
        gruppi = leggi(campo)
        if not gruppi:
            continue
        righe.append(f"  '{campo}': {{")
        for g, voci in gruppi.items():
            righe.append(f"    '{g}': [")
            for v in voci:
                righe.append(f'      {dart_stringa(v)},')
            righe.append('    ],')
        righe.append('  },')
    if righe[-1].endswith('CorpusDelPresagio({'):
        # Nessun file dell'Architetto ancora: il corpus vuoto, nella forma
        # che dart format lascia com'e'.
        righe[-1] = righe[-1] + '});'
    else:
        righe.append('});')
    USCITA.write_text('\n'.join(righe) + '\n', encoding='utf-8', newline='')
    print(f'{USCITA.relative_to(RADICE)}: scritto')


if __name__ == '__main__':
    main()
