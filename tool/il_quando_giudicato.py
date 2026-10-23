# -*- coding: utf-8 -*-
"""LE RISPOSTE AL "QUANDO" GIUDICATE ALLA CIECA. Ordine ES voce 19.

Dal fascicolo alla cieca del quinto e del sesto giro del banco delle trenta
domande (stessi giudici, voci mescolate): la prima frase di ogni risposta a
una domanda sul quando, col giudizio del lettore (risponde o non risponde).
Scrive `docs/collaudo/ES/quando_giudicati.json`: la prova della rete della
prima frase pretende che al quando passino le prime frasi che i giudici hanno
dato buone e non quelle che hanno bocciato.

Uso:
  python tool/il_quando_giudicato.py <cartella dei giudizi> <etichetta>
"""
import glob
import json
import pathlib
import re
import sys

RADICE = pathlib.Path(__file__).resolve().parent.parent
USCITA = RADICE / 'docs' / 'collaudo' / 'ES' / 'quando_giudicati.json'


def prima_frase(testo):
    riga = testo.strip().split('\n')[0]
    m = re.match(r'^.*?[.!?](?=\s|$)', riga)
    return (m.group(0) if m else riga).strip()


def main():
    cartella, etichetta = sys.argv[1], sys.argv[2]
    chiave = json.loads(pathlib.Path(cartella, f'chiave_et01_{etichetta}.json')
                        .read_text(encoding='utf-8'))
    giudizi = {}
    for f in sorted(glob.glob(str(pathlib.Path(cartella, f'giudizio_et01_{etichetta}_parte*.json')))):
        giudizi.update(json.loads(pathlib.Path(f).read_text(encoding='utf-8')))
    voci = []
    for codice, v in sorted(chiave.items()):
        if not re.search(r'\bquando\b', v['domanda'], re.I):
            continue
        voci.append({
            'fase': v['fase'],
            'maestro': v['maestro'],
            'domanda': v['domanda'],
            'prima_frase': prima_frase(v['testo']),
            'risponde': giudizi[codice]['prima_frase'] == 'sì',
        })
    USCITA.write_text(json.dumps({
        'da': f'docs/collaudo/ET/ciechi, fascicolo {etichetta}',
        'voci': voci,
    }, ensure_ascii=False, indent=1) + '\n', encoding='utf-8', newline='\n')
    buone = sum(1 for v in voci if v['risponde'])
    print(f'{len(voci)} risposte al quando, {buone} date buone, {len(voci) - buone} bocciate')


if __name__ == '__main__':
    main()
