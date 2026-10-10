# -*- coding: utf-8 -*-
"""LE CERTEZZE GIUDICATE ALLA CIECA. Ordine ES voce 19.

Dal fascicolo alla cieca del giro 5 e del giro nuovo del banco delle trenta
domande (stessi giudici, voci mescolate): le frasi che i giudici hanno citato
come certezze (cio' che nessuno puo' sapere detto come un fatto) e le frasi
delle risposte che gli stessi giudici hanno dato senza nessuna certezza.
Scrive `docs/collaudo/ES/certezze_giudicate.json`: la prova della rete delle
certezze pretende che la rete prenda le prime e lasci stare le seconde.

Piu' fascicoli si uniscono: la stessa frase citata due volte conta una.

Uso:
  python tool/le_certezze_giudicate.py <cartella dei giudizi> <etichetta>[,<etichetta>...]
"""
import glob
import json
import os
import pathlib
import re
import sys

RADICE = pathlib.Path(__file__).resolve().parent.parent
USCITA = RADICE / 'docs' / 'collaudo' / 'ES' / 'certezze_giudicate.json'


def frasi(testo):
    righe = [r for r in testo.split('\n')
             if r.strip() and not r.strip().startswith('✦')]
    return [f.strip() for f in re.split(r'(?<=[.!?])\s+', ' '.join(righe))
            if len(f.strip()) > 12]


def main():
    cartella, etichette = sys.argv[1], sys.argv[2].split(',')
    certe, buone = [], []
    viste = set()
    for etichetta in etichette:
        chiave = json.loads(pathlib.Path(cartella, f'chiave_et01_{etichetta}.json')
                            .read_text(encoding='utf-8'))
        giudizi = {}
        for f in glob.glob(os.path.join(cartella, f'giudizio_et01_{etichetta}_parte*.json')):
            giudizi.update(json.loads(pathlib.Path(f).read_text(encoding='utf-8')))
        for codice, voce in sorted(chiave.items()):
            g = giudizi.get(codice)
            if g is None:
                continue
            if g['certezze']:
                for c in g['certezze']:
                    if ('c', c) in viste:
                        continue
                    viste.add(('c', c))
                    certe.append({'voce': f'{etichetta}:{codice}', 'fase': voce['fase'],
                                  'maestro': voce['maestro'], 'frase': c})
            else:
                for f in frasi(voce['testo']):
                    if ('b', f) in viste:
                        continue
                    viste.add(('b', f))
                    buone.append({'voce': f'{etichetta}:{codice}', 'fase': voce['fase'],
                                  'maestro': voce['maestro'], 'frase': f})
    USCITA.write_text(json.dumps({'certe': certe, 'buone': buone},
                                 ensure_ascii=False, indent=1) + '\n',
                      encoding='utf-8', newline='')
    print(f'certezze citate {len(certe)}, frasi di risposte senza certezze '
          f'{len(buone)}: {USCITA.relative_to(RADICE)}')


if __name__ == '__main__':
    main()
