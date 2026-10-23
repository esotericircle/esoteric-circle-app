# -*- coding: utf-8 -*-
"""I CONTI DEI GIRI DEL VIAGGIO. Ordine EX Aggiunta 4, voce EX.10.

Legge docs/collaudo/EX/qualita/viaggio_<giro>.jsonl
(tool/la_scena_senza_modello_a_confronto.dart) e stampa, per ogni giro:
le chiamate della scena per discesa, le scene dal modello, i silenzi, e le
righe scartate per guardia e per pezzo (titolo, risposta, azione).

  python tool/i_conti_del_viaggio.py modello2 scena1
"""
import collections
import json
import pathlib
import sys

CARTELLA = (pathlib.Path(__file__).resolve().parent.parent /
            'docs/collaudo/EX/qualita')


def conti(giro):
    righe = [json.loads(r) for r in
             (CARTELLA / f'viaggio_{giro}.jsonl').read_text(
                 encoding='utf-8').splitlines() if r.strip()]
    chiamate = sum(r['chiamateScena'] for r in righe)
    silenzi = sum(1 for r in righe if r['risposta'].startswith('(Silenzio'))
    dal = sum(1 for r in righe if r['dalModello'])
    motivi = collections.Counter()
    pezzi = collections.Counter()
    for r in righe:
        for s in r.get('scarti') or []:
            motivi[s['motivo']] += 1
            pezzi[s['pezzo']] += 1
    print(f'{giro} ({len(righe)} discese)')
    print(f'  chiamate della scena {chiamate}, per discesa '
          f'{chiamate / len(righe):.2f}; dal modello {dal}; silenzi {silenzi}')
    print(f'  righe scartate {sum(motivi.values())}: per pezzo {dict(pezzi)}')
    for m, n in motivi.most_common():
        print(f'    {m}: {n}')


if __name__ == '__main__':
    sys.stdout.reconfigure(encoding='utf-8')
    for g in sys.argv[1:]:
        conti(g)
