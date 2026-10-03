# -*- coding: utf-8 -*-
"""LE SECONDE DELLE COPPIE, COL GIUDIZIO ALLA CIECA. Ordine ES voce 21.

Il banco delle trenta domande (ordine ET voci 01 e 03) ha cinque coppie di
domande simili di fila; alla lettura alla cieca ogni seconda di coppia ha il
suo giudizio: ripete la prima o no. Questo script raccoglie, da tutte le
fasi giudicate, la prima risposta, la seconda e il giudizio, e scrive
`docs/collaudo/ES/coppie_ripetute.json`: la prova della rete che non ripete
la legge per pretendere che la rete prenda le ripetizioni che i giudici hanno
visto e lasci stare le seconde che non ripetono.

Uso:
  python tool/le_coppie_ripetute.py
"""
import json
import pathlib

RADICE = pathlib.Path(__file__).resolve().parent.parent
CIECHI = RADICE / 'docs' / 'collaudo' / 'ET' / 'ciechi'
USCITA = RADICE / 'docs' / 'collaudo' / 'ES' / 'coppie_ripetute.json'


def main():
    fuori = []
    for fase in ('prima', 'giro2', 'giro4', 'giro5'):
        chiave = json.loads(
            (CIECHI / f'chiave_et01_{fase}.json').read_text(encoding='utf-8'))
        giudizi = {}
        for parte in range(1, 5):
            f = CIECHI / f'giudizio_et01_{fase}_parte{parte}.json'
            giudizi.update(json.loads(f.read_text(encoding='utf-8')))
        for voce, dato in sorted(chiave.items()):
            g = giudizi.get(voce)
            if g is None or g.get('ripete') is None:
                continue
            fuori.append({
                'voce': voce,
                'fase': fase,
                'maestro': dato['maestro'],
                'canale': dato['canale'],
                'primaDomanda': dato.get('prima_domanda', ''),
                'primaTesto': dato.get('prima_testo', ''),
                'domanda': dato['domanda'],
                'testo': dato['testo'],
                'ripete': g['ripete'] == 'sì',
            })
    USCITA.write_text(json.dumps(fuori, ensure_ascii=False, indent=1) + '\n',
                      encoding='utf-8', newline='')
    quante = sum(1 for x in fuori if x['ripete'])
    print(f'{len(fuori)} seconde di coppia, {quante} ripetono: '
          f'{USCITA.relative_to(RADICE)}')


if __name__ == '__main__':
    main()
