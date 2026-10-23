# -*- coding: utf-8 -*-
"""IL FASCICOLO DELLA QUALITA'. Ordine EX, regola NESSUNA RISPOSTA PEGGIORA.

Due comandi.

  python tool/il_fascicolo_della_qualita.py fascicolo <nome> <giro_a> <giro_b>
      Mescola i due giri del banco (docs/collaudo/EX/qualita/<giro>.jsonl)
      in un fascicolo alla cieca: docs/collaudo/EX/qualita/<nome>/schede.md
      (cio' che leggono i giudici, senza il giro) e chiave.json (da quale
      giro viene ogni scheda, da non dare ai giudici).

  python tool/il_fascicolo_della_qualita.py conta <nome> <giudizio.txt> [...]
      Legge i giudizi (righe "id|A|B|C|D|E|perche'") e scrive, per ogni
      giro, quante schede passano ogni misura: le regole dei responsi (A),
      i fatti della memoria usati (B), i fatti del cielo giusti (C), il
      merito (D), il seguito (E). Piu' giudizi: un conto per giudizio.
"""
import json
import pathlib
import random
import sys

RADICE = pathlib.Path(__file__).resolve().parent.parent
CARTELLA = RADICE / 'docs/collaudo/EX/qualita'


def leggi_giro(giro):
    p = CARTELLA / f'{giro}.jsonl'
    return [json.loads(r) for r in p.read_text(encoding='utf-8').splitlines() if r.strip()]


def scheda(sid, d):
    righe = [f'## Scheda {sid}', '', f'Maestro: {d["maestro"]}'
             + (' (nel LIVE, detto a voce)' if d['nelLive'] else ''), '',
             f'Domanda della persona: {d["domanda"]}', '',
             'Risposta che la persona legge:', '', d['risposta'] or '(vuota)', '']
    if d.get('seguito'):
        righe += ['"Vai più a fondo":', '', d['seguito'], '']
    if d['fattiDellaMemoria']:
        righe += ['Fatti della memoria (veri, il Maestro li conosce): '
                  + '; '.join(d['fattiDellaMemoria']), '']
    for c in d['cieloDelleDate']:
        righe += ['Cielo delle effemeridi dell\'app:', '', c, '']
    return '\n'.join(righe)


def fascicolo(nome, giro_a, giro_b):
    a, b = leggi_giro(giro_a), leggi_giro(giro_b)
    tutte = [(giro_a, d) for d in a] + [(giro_b, d) for d in b]
    caso = random.Random(f'{nome}-{giro_a}-{giro_b}')
    caso.shuffle(tutte)
    out = CARTELLA / nome
    out.mkdir(parents=True, exist_ok=True)
    chiave, testi = {}, []
    for i, (giro, d) in enumerate(tutte, start=1):
        sid = f'S{i:02d}'
        chiave[sid] = {'giro': giro, 'caso': d['id']}
        testi.append(scheda(sid, d))
    (out / 'schede.md').write_text(
        f'# Fascicolo {nome}: {len(testi)} schede\n\n' + '\n\n'.join(testi) + '\n',
        encoding='utf-8', newline='')
    (out / 'chiave.json').write_text(json.dumps(chiave, indent=1), encoding='utf-8', newline='')
    print(f'{out}/schede.md: {len(testi)} schede')


def conta(nome, giudizi):
    chiave = json.loads((CARTELLA / nome / 'chiave.json').read_text(encoding='utf-8'))
    for g in giudizi:
        voti = {}
        for r in pathlib.Path(g).read_text(encoding='utf-8').splitlines():
            parti = r.split('|')
            if len(parti) < 7 or parti[0] not in chiave:
                continue
            voti[parti[0]] = parti[1:6]
        print(f'== {g}: schede giudicate {len(voti)} su {len(chiave)}')
        giri = sorted({v['giro'] for v in chiave.values()})
        for giro in giri:
            ids = [s for s, v in chiave.items() if v['giro'] == giro and s in voti]
            riga = []
            for k, lettera in enumerate('ABCDE'):
                si = sum(voti[s][k].strip() == 'SI' for s in ids)
                tot = sum(voti[s][k].strip() in ('SI', 'NO') for s in ids)
                riga.append(f'{lettera} {si}/{tot}')
            print(f'{giro}: ' + ', '.join(riga))
        # Le schede dove i due giri divergono, caso per caso.
        per_caso = {}
        for s, v in chiave.items():
            if s in voti:
                per_caso.setdefault(v['caso'], {})[v['giro']] = voti[s]
        diverse = [c for c, x in per_caso.items() if len(x) == 2 and len({tuple(y) for y in x.values()}) > 1]
        print(f'casi con giudizi diversi fra i giri: {len(diverse)} {sorted(diverse)}')


if __name__ == '__main__':
    if sys.argv[1] == 'fascicolo':
        fascicolo(sys.argv[2], sys.argv[3], sys.argv[4])
    else:
        conta(sys.argv[2], sys.argv[3:])
