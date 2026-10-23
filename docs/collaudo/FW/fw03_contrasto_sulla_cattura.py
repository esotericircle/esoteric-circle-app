"""Il contrasto del testo sulla scena del dominio, ordine FW voce FW.03/FW.04.

Campiona il fondo RESO sulle anteprime vere (docs/preview/FW/*_dopo.png,
360x797 punti, densita' 3) nella fascia dove cade ogni riga di testo e
calcola il contrasto WCAG verso i due colori di inchiostro che la schermata
usa davvero (goldSoft #F0D77B per il titolo, textSecondary #D7D2C2 per la
riga sotto). Stesso metodo di docs/tipografia/alba_contrasto.md e di FU.13:
il colore PIU' FREQUENTE della fascia (la moda, quantizzata a passi di 8
livelli per canale), mai la media, perche' una lettera che sbordasse nella
fascia sposterebbe la media verso l'inchiostro; mai il pixel piu' chiaro in
assoluto, perche' una singola stella o un riflesso isolato non e' il fondo
dietro la scritta, e misurarlo sarebbe un cricchetto troppo severo che
nessuna soglia di velo potrebbe mai passare per davvero.
"""
import sys
from collections import Counter
from pathlib import Path
from PIL import Image

SOGLIA = 4.5

INCHIOSTRI = {
    'goldSoft (titolo)': (0xF0, 0xD7, 0x7B),
    'textSecondary (riga)': (0xD7, 0xD2, 0xC2),
}


def canale(v):
    f = v / 255
    return f / 12.92 if f <= 0.03928 else ((f + 0.055) / 1.055) ** 2.4


def luminanza(rgb):
    r, g, b = rgb
    return 0.2126 * canale(r) + 0.7152 * canale(g) + 0.0722 * canale(b)


def contrasto(a, b):
    la, lb = luminanza(a), luminanza(b)
    chiaro, scuro = max(la, lb), min(la, lb)
    return (chiaro + 0.05) / (scuro + 0.05)


def moda_della_fascia(im, y0, y1, x0, x1, passo=8):
    """Il colore piu' frequente della fascia, quantizzato a passi di [passo]
    livelli per canale (gruppi di colori quasi uguali contano insieme)."""
    conta = Counter()
    rappresentante = {}
    for y in range(y0, y1):
        for x in range(x0, x1):
            px = im.getpixel((x, y))[:3]
            chiave = tuple(c // passo for c in px)
            conta[chiave] += 1
            rappresentante.setdefault(chiave, px)
    chiave_moda = conta.most_common(1)[0][0]
    return rappresentante[chiave_moda]


def main():
    preview_dir = Path('docs/preview/FW')
    righe = []
    for f in sorted(preview_dir.glob('fw06_*_dominio_ferma_dopo.png')):
        im = Image.open(f).convert('RGB')
        w, h = im.size
        # Fascia del titolo "LE ARTI DI X" e della riga sotto, misurata a
        # occhio sull'anteprima e allargata di margine: fra il 52% e il 61%
        # dell'altezza, su tutta la larghezza del testo (sinistra, dove sta
        # il blocco SectionTitle).
        y0, y1 = int(h * 0.515), int(h * 0.615)
        x0, x1 = 0, int(w * 0.85)
        moda = moda_della_fascia(im, y0, y1, x0, x1)
        riga = [f.name]
        for nome, inchiostro in INCHIOSTRI.items():
            c = contrasto(inchiostro, moda)
            passa = 'si\'' if c >= SOGLIA else 'NO'
            riga.append(f'{nome}: fondo #{moda[0]:02X}{moda[1]:02X}{moda[2]:02X} '
                         f'contrasto {c:.2f} ({passa})')
        righe.append(riga)

    for r in righe:
        print(r[0])
        for voce in r[1:]:
            print(f'  {voce}')


if __name__ == '__main__':
    sys.exit(main())
