# -*- coding: utf-8 -*-
"""Rigenera lib/core/horoscope/oroscopo_annuale_data.dart da docs/corpus/oroscopo_annuale.md.

Ordine ES voce 04. La fonte di verita' e' il corpus; il file dart non si
tocca a mano.

Uso, dalla radice del repository:
    python tool/_gen_oroscopo_annuale.py            # scrive il file
    python tool/_gen_oroscopo_annuale.py --prova    # non scrive: confronta col file in vigore
"""
from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

RADICE = Path(__file__).resolve().parent.parent
CORPUS = RADICE / 'docs' / 'corpus' / 'oroscopo_annuale.md'
USCITA = RADICE / 'lib' / 'core' / 'horoscope' / 'oroscopo_annuale_data.dart'

SEGNI = ['Ariete', 'Toro', 'Gemelli', 'Cancro', 'Leone', 'Vergine', 'Bilancia',
         'Scorpione', 'Sagittario', 'Capricorno', 'Acquario', 'Pesci']
# Il paragrafo del corpus, il nome nel codice, per segno o per casa.
SEZIONI = [('1', 'ascendente', 'segno'), ('2', 'sole', 'casa'),
           ('3', 'venere', 'casa'), ('4', 'giove', 'casa'),
           ('5', 'saturno', 'casa'), ('6', 'medioCielo', 'segno'),
           ('7', 'luna', 'casa')]


def dart(testo: str) -> str:
    return "'" + testo.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$') + "'"


def frasi(blocco: str) -> list[str]:
    uscita, corrente = [], None
    for riga in blocco.splitlines():
        m = re.match(r'^\d+\.\s+(.+)$', riga)
        if m:
            if corrente is not None:
                uscita.append(corrente)
            corrente = m.group(1).strip()
        elif corrente is not None and riga.startswith('   ') and riga.strip():
            corrente += ' ' + riga.strip()
        elif corrente is not None:
            uscita.append(corrente)
            corrente = None
    if corrente is not None:
        uscita.append(corrente)
    return uscita


def paragrafo(testo: str, numero: str) -> str:
    m = re.search(r'^## ' + re.escape(numero) + r'\. .*?(?=^## |\Z)', testo, re.M | re.S)
    assert m, numero
    return m.group(0)


def sottosezioni(testo: str) -> list[tuple[str, str]]:
    parti = re.split(r'^### (.*)$', testo, flags=re.M)
    return [(parti[i].strip(), parti[i + 1]) for i in range(1, len(parti), 2)]


def componi() -> str:
    t = CORPUS.read_text(encoding='utf-8').replace('\r\n', '\n')
    out = ['// GENERATO da tool/_gen_oroscopo_annuale.py a partire da '
           'docs/corpus/oroscopo_annuale.md.',
           "// Fonte di verita': il corpus. Non modificare a mano: rigenerare dal corpus.",
           '',
           "/// Le frasi dell'oroscopo annuale dalla Rivoluzione Solare (ordine ES voce",
           '/// 04), trascritte dal corpus: per ogni caso tre varianti.',
           'abstract final class OroscopoAnnualeData {']
    for numero, nome, tipo in SEZIONI:
        sotto = sottosezioni(paragrafo(t, numero))
        assert len(sotto) == 12, (nome, len(sotto))
        gruppi = []
        for i, (titolo, blocco) in enumerate(sotto):
            if tipo == 'segno':
                assert titolo.endswith(' ' + SEGNI[i]), (nome, titolo)
            else:
                assert re.search(r'casa ' + str(i + 1) + r'\b', titolo), (nome, titolo)
            f = frasi(blocco)
            assert len(f) >= 3, (nome, titolo)
            gruppi.append(f)
        out.append(f'  /// {nome}, per {tipo}, da {"Ariete" if tipo == "segno" else "casa 1"}.')
        out.append(f'  static const List<List<String>> {nome} = [')
        for g in gruppi:
            out.append('    [')
            out += [f'      {dart(x)},' for x in g]
            out.append('    ],')
        out.append('  ];')
        out.append('')
    note = dict(sottosezioni(paragrafo(t, '8')))
    chiavi = [k for k in note if k.startswith('Nota')]
    assert len(chiavi) == 3, chiavi
    for k, nome in zip(chiavi, ['notaGenerale', 'notaDomini', 'notaTutte']):
        f = frasi(note[k])
        assert len(f) == 1, k
        out.append(f'  static const String {nome} = {dart(f[0].strip().strip(chr(34)))};')
    out.append('}')
    return '\n'.join(out) + '\n'


def formattato(testo: str) -> str:
    f = RADICE / 'tool' / '_formato_oroscopo_annuale.dart'
    try:
        f.write_text(testo, encoding='utf-8', newline='\n')
        subprocess.run(['dart', 'format', str(f)], check=True,
                       capture_output=True, shell=sys.platform == 'win32')
        return f.read_text(encoding='utf-8')
    finally:
        f.unlink(missing_ok=True)


def main() -> None:
    nuovo = formattato(componi())
    if '--prova' in sys.argv:
        vecchio = USCITA.read_text(encoding='utf-8') if USCITA.exists() else ''
        print('uguale' if vecchio == nuovo else 'DIVERSO')
        sys.exit(0 if vecchio == nuovo else 1)
    USCITA.write_text(nuovo, encoding='utf-8', newline='\n')
    print('scritto', USCITA)


if __name__ == '__main__':
    main()
