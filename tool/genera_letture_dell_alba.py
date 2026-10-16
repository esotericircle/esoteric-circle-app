"""Genera le letture dell'Arcano dell'Alba dal corpus dei tarocchi.

Ordine DT voci 07 e 09, 17 settembre 2026. La fonte e' la sezione
"## Arcano dell'Alba, le letture del dono" di docs/corpus/tarocchi.md; l'uscita
e' lib/core/rituals/arcano_dell_alba/letture_dell_alba_dati.dart. Il corpus si
tocca alla fonte: si modifica il markdown e si rilancia questo script.

    python tool/genera_letture_dell_alba.py
"""
import io
import os
import re
import sys

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CORPUS = os.path.join(RADICE, 'docs', 'corpus', 'tarocchi.md')
USCITA = os.path.join(RADICE, 'lib', 'core', 'rituals', 'arcano_dell_alba',
                      'letture_dell_alba_dati.dart')

# L'ordine delle carte e' quello del corpus e delle attribuzioni.
CARTE = [
    'Il Matto', 'Il Mago', 'La Papessa', "L'Imperatrice", "L'Imperatore",
    'Il Papa', 'Gli Amanti', 'Il Carro', 'La Giustizia', "L'Eremita",
    'La Ruota della Fortuna', 'La Forza', "L'Appeso", 'La Morte',
    'La Temperanza', 'Il Diavolo', 'La Torre', 'La Stella', 'La Luna',
    'Il Sole', 'Il Giudizio', 'Il Mondo',
]


def leggi():
    testo = io.open(CORPUS, encoding='utf-8').read()
    inizio = testo.index("## Arcano dell'Alba, le letture del dono")
    fine = testo.find('\n## ', inizio + 1)
    sezione = testo[inizio:] if fine < 0 else testo[inizio:fine]
    letture = []
    carta = None
    for riga in sezione.split('\n'):
        # Ordine DU voce 09: l'intestazione porta il nome e l'attribuzione,
        # e non piu' la forma, perche' la forma e' una sola per tutti.
        m = re.match(r'^### (?:0|[IVXL]+) (.+?), [^,]+$', riga)
        if m:
            carta = CARTE.index(m.group(1))
            continue
        m = re.match(r'^- \*\*(dritto|rovesciato), lettura (\d+)\*\*$', riga)
        if m:
            letture.append({'carta': carta, 'rovescio':
                            m.group(1) == 'rovesciato',
                            'numero': int(m.group(2))})
            continue
        m = re.match(r'^  - (parola|dono|perche|medora): (.+)$', riga)
        if m:
            letture[-1][m.group(1)] = m.group(2).strip()
    return letture


def dart(s):
    return "'" + s.replace('\\', '\\\\').replace("'", "\\'") + "'"


def scrivi(letture):
    righe = [
        '// GENERATO da tool/genera_letture_dell_alba.py, non toccare a mano:',
        '// la fonte e\' docs/corpus/tarocchi.md.',
        "import 'lettura_dell_alba.dart';",
        '',
        '/// Le letture dell\'Arcano dell\'Alba, nell\'ordine del corpus.',
        'const List<LetturaDellAlba> lettureDellAlba = [',
    ]
    for l in letture:
        righe.append('  LetturaDellAlba(')
        righe.append('    carta: %d,' % l['carta'])
        righe.append('    rovescio: %s,' % ('true' if l['rovescio'] else 'false'))
        righe.append('    numero: %d,' % l['numero'])
        if 'parola' in l:
            righe.append('    parola: %s,' % dart(l['parola']))
        righe.append('    dono: %s,' % dart(l['dono']))
        righe.append('    perche: %s,' % dart(l['perche']))
        righe.append('    medora: %s,' % dart(l['medora']))
        righe.append('  ),')
    righe.append('];')
    io.open(USCITA, 'w', encoding='utf-8', newline='\n').write(
        '\n'.join(righe) + '\n')


if __name__ == '__main__':
    letture = leggi()
    scrivi(letture)
    print('letture scritte: %d' % len(letture))
    sys.exit(0)
