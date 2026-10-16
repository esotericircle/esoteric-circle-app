# -*- coding: utf-8 -*-
"""LE TRE FESTE, UNA ACCANTO ALL'ALTRA. Ordine AO voce 05.

**Perche' esiste questo strumento.** La voce 05 chiede tre anteprime
affiancate, perche' la domanda di Mauro non e' "la festa di Caligo e' bella"
ma "le tre feste sono DIVERSE". Tre immagini guardate una dopo l'altra non
rispondono: la memoria di un fondo scuro con particelle dorate e' corta. Una
sola immagine con le tre scene accostate risponde in un colpo d'occhio.

**Non ridisegna niente.** Prende i tre fotogrammi di meta' festa che
`tool/anteprime_delle_feste.dart` ha gia' prodotto dalla scena vera e li
accosta. Se ridisegnasse, sarebbe una quarta verita' sulla festa, e mostrerebbe
qualcosa che nell'app non esiste.

Uso, dalla radice del repository:
  python tool/le_tre_feste_affiancate.py
"""

from PIL import Image

# L'ordine e' quello dei tre Maestri come il Cerchio li nomina.
MAESTRI = ['medora', 'caligo', 'aura']

# Il fondo fra una scena e l'altra: lo stesso nero bluastro del cosmo, cosi'
# lo stacco si legge come una cornice e non come una striscia estranea.
FONDO = (8, 6, 12)
STACCO = 12

FUORI = 'docs/preview/le-tre-feste-affiancate.png'


def main():
    scene = [Image.open('docs/preview/festa_%s_meta.png' % m) for m in MAESTRI]
    altezza = min(s.height for s in scene)
    scalate = [
        s.resize((int(s.width * altezza / s.height), altezza)) for s in scene
    ]
    larghezza = sum(s.width for s in scalate) + STACCO * (len(scalate) - 1)
    quadro = Image.new('RGB', (larghezza, altezza), FONDO)
    x = 0
    for scena in scalate:
        quadro.paste(scena, (x, 0))
        x += scena.width + STACCO
    quadro.save(FUORI)
    print('anteprima: %s  %dx%d' % (FUORI, quadro.width, quadro.height))


if __name__ == '__main__':
    main()
