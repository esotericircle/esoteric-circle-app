# -*- coding: utf-8 -*-
"""LE CONSEGNE COL CANCELLO DI GITHUB, ordine FC voce 07 (ACCELERA.03).

Ricostruisce dalla storia di `docs/versione_distribuita.json`, commit per
commit, quale cancello ha fatto passare ogni consegna: il campo
`sbarramento` lo scrive `tool/consegna.py` (ordine ACCELERA voce 03), con
`github <sha>` quando il cancello di GitHub era verde e `locale` quando e'
passato il gettone del PC. Prima dell'ordine ACCELERA il campo non c'era.

Scrive `docs/collaudo/ACCELERA/le_consegne_col_cancello_di_github.txt`.
"""
import io
import json
import os
import subprocess

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(RADICE)
FILE = 'docs/versione_distribuita.json'


def git(*args):
    return subprocess.run(['git', *args], capture_output=True, text=True,
                          encoding='utf-8').stdout


def main():
    commit = git('log', '--format=%h %ad', '--date=short', '--', FILE).split('\n')
    righe = []
    visti = set()
    for riga in commit:
        if not riga.strip():
            continue
        sha, data = riga.split()
        try:
            d = json.loads(git('show', '%s:%s' % (sha, FILE)))
        except ValueError:
            continue
        numero = d.get('ultimo_distribuito')
        if numero in visti:
            continue
        visti.add(numero)
        righe.append((numero, data, sha, d.get('sbarramento')))
    righe.sort()
    uscita = [
        "LE CONSEGNE COL CANCELLO DI GITHUB, ordine FC voce 07 (chiude ACCELERA.03).",
        "Comando: python tool/le_consegne_col_cancello_di_github.py",
        "Fonte: la storia di %s, un commit per consegna; il campo sbarramento lo"
        % FILE,
        "scrive tool/consegna.py dall'ordine ACCELERA voce 03.",
        "",
    ]
    for numero, data, sha, sbarramento in righe:
        uscita.append('build %s, %s, commit del registro %s: %s' % (
            numero, data, sha, sbarramento or '(campo assente: prima del cancello di GitHub)'))
    col_github = [r for r in righe if (r[3] or '').startswith('github')]
    dal_campo = [r for r in righe if r[3]]
    uscita.append('')
    uscita.append('Consegne col campo: %d; passate dal cancello di GitHub: %d; '
                  'col gettone locale: %d.' % (
                      len(dal_campo), len(col_github),
                      len([r for r in dal_campo if r[3] == 'locale'])))
    if col_github:
        prima = col_github[0]
        uscita.append('La prima passata dal cancello di GitHub: build %s, %s, %s.'
                      % (prima[0], prima[1], prima[3]))
    os.makedirs('docs/collaudo/ACCELERA', exist_ok=True)
    with io.open('docs/collaudo/ACCELERA/le_consegne_col_cancello_di_github.txt',
                 'w', encoding='utf-8', newline='\n') as f:
        f.write('\n'.join(uscita) + '\n')
    print('\n'.join(uscita))


if __name__ == '__main__':
    main()
