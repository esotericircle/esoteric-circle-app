# -*- coding: utf-8 -*-
"""GENERA I RITI PROPIZIATORI. Ordine GA voce GA.04, 20 ottobre 2026.

I riti del quarto paragrafo della Lunga stanno in `docs/corpus/riti/*.md`,
uno per raccolta: gli inni orfici e i mantra dei Navagraha per l'Oroscopo
occidentale e vedico, i gesti del Tong Shu per il cinese, i salmi di Lenain
nella traduzione di Martini per l'Oracolo degli Angeli, i galdr per le Rune,
la contemplazione per i Tarocchi. Questo strumento li porta carattere per
carattere in `lib/core/responsi/i_riti_propiziatori_dati.dart`.

La forma di ogni file:
- una sezione `## Da dove viene` con righe `- <Chiave>: <testo>` (una per
  pianeta, graha o ufficiale) oppure un paragrafo unico per tutta la
  raccolta;
- le sezioni `### <chiave>, <chiave>, ...` con sotto le righe
  `- <Campo>: <testo>`; il campo `Rito` e' il testo del riquadro, e un campo
  `Da dove viene` dentro la sezione vale solo per lei (i salmi).

Ogni rito si controlla con le regole di `tool/le_parole_dei_responsi.py`
(da 40 a 50 parole, la lingua di casa): se uno sbaglia lo strumento si ferma
e non scrive niente.

    python tool/genera_i_riti.py
"""
import io
import os
import re
import sys

sys.path.insert(0, os.path.dirname(__file__))
from le_parole_dei_responsi import MASSIMO, MINIMO, difetti_di_lingua, parole  # noqa: E402

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CARTELLA = os.path.join(RADICE, 'docs', 'corpus', 'riti')
USCITA = os.path.join(RADICE, 'lib', 'core', 'responsi',
                      'i_riti_propiziatori_dati.dart')
RACCOLTE = ['inni_orfici', 'mantra_navagraha', 'gesti_tong_shu',
            'salmi_martini', 'galdr_delle_rune', 'contemplazione_dei_tarocchi']
# Le parti del rito che stanno fra virgolette basse e vengono dalla fonte
# (il versetto di Martini, il verso orfico): la lingua di casa non le tocca.
CITAZIONE = re.compile(r'«[^»]*»')


def dart(testo):
    return "'" + testo.replace('\\', '\\\\').replace("'", "\\'") \
        .replace('$', '\\$') + "'"


def chiave(intestazione):
    return '|'.join(p.strip() for p in intestazione.split(','))


def leggi(raccolta):
    testo = io.open(os.path.join(CARTELLA, raccolta + '.md'),
                    encoding='utf-8').read()
    riti, fonti, difetti = {}, {}, []
    sezione = None
    intestazione = None
    for riga in testo.splitlines():
        if riga.startswith('## '):
            sezione = riga[3:].strip()
            intestazione = None
            continue
        if riga.startswith('### '):
            intestazione = chiave(riga[4:])
            continue
        if sezione == 'Da dove viene' and intestazione is None:
            m = re.match(r'^- ([^:]+): (.+)$', riga)
            if m:
                fonti[f'{raccolta}|{chiave(m.group(1))}'] = m.group(2).strip()
            elif riga.strip() and not riga.startswith('#'):
                fonti.setdefault(raccolta, riga.strip())
            continue
        if intestazione is None:
            continue
        m = re.match(r'^- ([^:]+): (.*)$', riga)
        if not m:
            continue
        campo, valore = m.group(1).strip(), m.group(2).strip()
        k = f'{raccolta}|{intestazione}'
        if campo == 'Rito':
            if k in riti:
                difetti.append(f'{k}: rito doppio')
            riti[k] = valore
            n = parole(valore)
            if not MINIMO <= n <= MASSIMO:
                difetti.append(f'{k}: {n} parole')
            for d in difetti_di_lingua(CITAZIONE.sub('«»', valore)):
                difetti.append(f'{k}: {d}')
        elif campo == 'Da dove viene' and valore:
            fonti[k] = valore
    return riti, fonti, difetti


def main():
    riti, fonti, difetti = {}, {}, []
    for r in RACCOLTE:
        if not os.path.exists(os.path.join(CARTELLA, r + '.md')):
            difetti.append(f'manca la raccolta {r}.md')
            continue
        a, b, c = leggi(r)
        riti.update(a)
        fonti.update(b)
        difetti.extend(c)
        print(f'{r}: {len(a)} riti, {len(b)} righe di "Da dove viene"')
    if difetti:
        print('\n'.join(difetti[:60]))
        raise SystemExit(f'DIFETTI: {len(difetti)}, non scrivo niente')
    righe = [
        '// GENERATO da tool/genera_i_riti.py dai file di docs/corpus/riti/.',
        '// Non si tocca a mano: si cambia la raccolta e si rigenera. Ordine GA',
        '// voce GA.04, 20 ottobre 2026.',
        '// ignore_for_file: lines_longer_than_80_chars',
        '',
        '/// I riti propiziatori e le loro fonti, per raccolta e chiave',
        '/// (`<raccolta>|<chiave>|<chiave>...`). Si leggono da',
        '/// `IRitiPropiziatori`.',
        'abstract final class IRitiPropiziatoriDati {',
        '  static const Map<String, String> riti = {',
    ]
    for k in sorted(riti):
        righe.append(f'    {dart(k)}: {dart(riti[k])},')
    righe.append('  };')
    righe.append('')
    righe.append('  static const Map<String, String> fonti = {')
    for k in sorted(fonti):
        righe.append(f'    {dart(k)}: {dart(fonti[k])},')
    righe.append('  };')
    righe.append('}')
    io.open(USCITA, 'w', encoding='utf-8', newline='\n').write(
        '\n'.join(righe) + '\n')
    print(f'{USCITA}: {len(riti)} riti, {len(fonti)} fonti')


if __name__ == '__main__':
    main()
