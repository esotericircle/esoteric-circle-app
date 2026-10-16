# -*- coding: utf-8 -*-
"""LE RETI DEL GIRO 6, IN UN FILE SOLO. Ordine ES voce 19.

Unisce le 101 risposte scartate dal banco delle trenta domande al giro 6
(i testi interi, `scartate_giro6.json`, scritti dal banco) coi giudizi dati a
mano uno per uno (`docs/collaudo/ET/trenta_domande/giro6_scartate.txt`), e
scrive `docs/collaudo/ES/giro6_reti.json`: la prova delle reti la legge per
pretendere che una rete scarti cio' che il giudizio chiama un difetto vero e
lasci passare cio' che chiama uno scarto inutile.

Uso:
  python tool/le_reti_del_giro6.py <percorso di scartate_giro6.json>
"""
import json
import pathlib
import re
import sys

RADICE = pathlib.Path(__file__).resolve().parent.parent
GIUDIZI = RADICE / 'docs' / 'collaudo' / 'ET' / 'trenta_domande' / 'giro6_scartate.txt'
USCITA = RADICE / 'docs' / 'collaudo' / 'ES' / 'giro6_reti.json'


def main():
    sorgente = pathlib.Path(sys.argv[1])
    casi = json.loads(sorgente.read_text(encoding='utf-8'))
    testo = GIUDIZI.read_text(encoding='utf-8')
    blocchi = re.split(r'\n(?=\d+\. \S+\.md, )', testo)
    giudizi = {}
    for b in blocchi:
        m = re.match(r'(\d+)\. (\S+)\.md, (.*)\n', b)
        if not m:
            continue
        n = int(m.group(1))
        g = re.search(r'BOZZA_DIRETTA: (\w+) \| FINALE_DIRETTA: (\w+) \| '
                      r'CERTEZZA_VERA: (\S+) \| GIUDIZIO: (\w+)', b)
        certa = re.search(r'frase certa \(se c\'e\'\): «(.*?)»', b)
        if g is None:
            continue
        giudizi[n] = {
            'file': m.group(2),
            'bozzaDiretta': g.group(1) == 'si',
            'finaleDiretta': g.group(2) == 'si',
            'certezzaVera': {'si': True, 'no': False}.get(g.group(3)),
            'giudizio': g.group(4),
            'fraseCerta': certa.group(1) if certa else '',
        }
    fuori = []
    for i, c in enumerate(casi, start=1):
        g = giudizi.get(i)
        if g is None:
            raise SystemExit(f'manca il giudizio del caso {i}')
        nome = pathlib.Path(c['file']).stem
        if nome != g['file']:
            raise SystemExit(f'caso {i}: {nome} contro {g["file"]}')
        maestro, canale = nome.split('_')[:2]
        fuori.append({
            'n': i,
            'maestro': maestro,
            'canale': canale,
            'domanda': c['domanda'],
            'reti': c['reti'],
            'scartata': c['scartata'],
            'finale': c['finale'],
            **{k: v for k, v in g.items() if k != 'file'},
        })
    USCITA.write_text(json.dumps(fuori, ensure_ascii=False, indent=1) + '\n',
                      encoding='utf-8', newline='')
    print(f'{len(fuori)} casi scritti in {USCITA.relative_to(RADICE)}')


if __name__ == '__main__':
    main()
