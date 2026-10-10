# -*- coding: utf-8 -*-
"""LA TAVOLA DELLE RUNE INCISE. Ordine EA voce 22, 20 settembre 2026.

**Perche' esiste.** Il segno inciso in una pietra non si misura a macchina in
modo affidabile: sono fotografie di sassi storti, e il confronto col disegno
a tratti dava dal 7 al 92 per cento su pietre tutte giuste. Il giudizio lo da'
l'occhio, e l'occhio ha bisogno di vedere le ventiquattro pietre insieme, nel
loro ordine, col nome accanto.

**Come si usa.** Si rigenera dopo ogni cambio d'arte, si guarda, e se i segni
sono quelli giusti si riscrivono le impronte in
`test/ogni_pietra_porta_la_sua_runa_test.dart`. La guardia confronta le
impronte e la firma della tavola: una pietra cambiata senza che nessuno abbia
riguardato la tavola fa cadere la prova.

```
python tool/tavola_delle_rune.py
```
"""
import hashlib
import os

from PIL import Image, ImageDraw

DENTRO = 'assets/img/rune_bone'
TAVOLA = 'docs/anteprime/rune_incise.png'
FIRMA = 'docs/anteprime/rune_incise.sha1'
LATO = 300
COLONNE = 6
FONDO = (12, 10, 26)
ORO = (233, 196, 106)


def main():
    nomi = sorted(n for n in os.listdir(DENTRO) if n.endswith('.webp'))
    if len(nomi) != 24:
        raise SystemExit('le pietre incise sono %d invece di ventiquattro'
                         % len(nomi))
    righe = (len(nomi) + COLONNE - 1) // COLONNE
    foglio = Image.new('RGB', (COLONNE * LATO, righe * (LATO + 30)), FONDO)
    d = ImageDraw.Draw(foglio)
    impronte = []
    for i, nome in enumerate(nomi):
        percorso = os.path.join(DENTRO, nome)
        impronte.append(hashlib.sha1(open(percorso, 'rb').read())
                        .hexdigest()[:16])
        im = Image.open(percorso).convert('RGBA')
        im.thumbnail((LATO - 16, LATO - 16))
        sotto = Image.new('RGBA', im.size, FONDO + (255,))
        x = (i % COLONNE) * LATO + (LATO - im.width) // 2
        y = (i // COLONNE) * (LATO + 30) + 26
        foglio.paste(Image.alpha_composite(sotto, im).convert('RGB'), (x, y))
        d.text(((i % COLONNE) * LATO + 8, (i // COLONNE) * (LATO + 30) + 8),
               nome.replace('rune_bone_', '').replace('_v1.webp', ''),
               fill=ORO)
    os.makedirs(os.path.dirname(TAVOLA), exist_ok=True)
    foglio.save(TAVOLA)
    somma = hashlib.sha1(','.join(impronte).encode()).hexdigest()[:16]
    with open(FIRMA, 'w', encoding='utf-8', newline='\n') as f:
        f.write(somma + '\n')
    print('TAVOLA DELLE RUNE: %d pietre in %s, firma %s'
          % (len(nomi), TAVOLA, somma))


if __name__ == '__main__':
    main()
