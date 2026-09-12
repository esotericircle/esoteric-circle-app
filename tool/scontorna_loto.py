# LO SCONTORNO DEL LOTO DELLE PERLE. Ordine AE voce 01.
#
# Dal sorgente di Mauro (docs/preview/journal_loto_nuovo-1.png, che NON si
# modifica mai sul posto) si produce l'arte pronta: si toglie il bianco
# COLLEGATO AL BORDO per inondazione, mai il bianco ovunque, perche' i riflessi
# delle perle sono bianchi anche loro e uno scontorno ingenuo li bucherebbe.
# Poi si ridimensiona a 941 per 1672 e si scrive su
# brand_assets/sentieri/loto.png.
#
# LA SOGLIA DEL BIANCO: un pixel partecipa all'inondazione quando il suo canale
# MINIMO sta sopra 235. Il fondo misurato e' bianco pieno (255,255,255) e il
# bordo dell'arte scende sotto in pochi pixel di antialias: 235 prende il fondo
# e la sfumatura di transizione senza mordere l'arte, che ai bordi e' oro o
# verde, cioe' con almeno un canale ben sotto.
#
# Si lancia a mano:  python tool/scontorna_loto.py
from collections import deque

from PIL import Image

SORGENTE = 'docs/preview/journal_loto_nuovo-1.png'
DESTINAZIONE = 'brand_assets/sentieri/loto.png'
SOGLIA = 235
MISURA_FINALE = (941, 1672)

im = Image.open(SORGENTE).convert('RGBA')
w, h = im.size
px = bytearray(im.tobytes())

def bianco(p):
    i = p * 4
    return min(px[i], px[i + 1], px[i + 2]) >= SOGLIA

# L'INONDAZIONE, da tutto il perimetro.
visto = bytearray(w * h)
coda = deque()
for x in range(w):
    for y in (0, h - 1):
        p = y * w + x
        if bianco(p) and not visto[p]:
            visto[p] = 1
            coda.append(p)
for y in range(h):
    for x in (0, w - 1):
        p = y * w + x
        if bianco(p) and not visto[p]:
            visto[p] = 1
            coda.append(p)
resi = 0
while coda:
    p = coda.popleft()
    px[p * 4 + 3] = 0
    resi += 1
    x, y = p % w, p // w
    for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
        nx, ny = x + dx, y + dy
        if 0 <= nx < w and 0 <= ny < h:
            n = ny * w + nx
            if not visto[n] and bianco(n):
                visto[n] = 1
                coda.append(n)

print(f'soglia {SOGLIA}: pixel resi trasparenti {resi} su {w*h} '
      f'({100*resi/(w*h):.1f} per cento)')

# **ANCHE LE SACCHE CHIUSE SPARISCONO.** Ordine AF voce 01, decisione di Mauro:
# trasparenza vera anche fra gli steli. L'inondazione dal bordo non raggiunge il
# bianco chiuso dentro l'arte, quindi le regioni bianche interne si rendono
# trasparenti anch'esse, CON UNA PROTEZIONE: dentro i cinquantacinque dischi
# delle perle e dei centri non si tocca niente, perche' i riflessi sono bianchi
# anche loro e sono arte. I dischi si leggono da loto_pallini.png, che le
# coordinate le porta gia': una seconda lettura dello stesso dato, non una
# seconda porta.
#
# Il criterio con cui una regione interna e' detta SFONDO: stessa soglia
# dell'inondazione, canale minimo sopra 235, e nessun pixel della regione dentro
# un disco. Una regione bianca che tocca un disco e' un riflesso che sborda, e
# si lascia stare.
import os
if os.path.exists('brand_assets/sentieri/loto_pallini.png'):
    pal = Image.open('brand_assets/sentieri/loto_pallini.png').convert('RGBA')
    # il pallini e' alla misura FINALE: si riporta alla misura del sorgente
    pal = pal.resize((w, h), Image.NEAREST)
    palp = pal.tobytes()
    def nel_disco(q):
        return palp[q * 4 + 3] > 128
    sacche = celle_tolte = toccate = 0
    for q in range(w * h):
        if not bianco(q) or visto[q]:
            continue
        visto[q] = 1
        pila = [q]
        celle = []
        tocca = False
        while pila:
            t = pila.pop()
            celle.append(t)
            if nel_disco(t):
                tocca = True
            x, y = t % w, t // w
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = x + dx, y + dy
                if 0 <= nx < w and 0 <= ny < h:
                    n = ny * w + nx
                    if not visto[n] and bianco(n):
                        visto[n] = 1
                        pila.append(n)
        if tocca:
            toccate += 1
            continue
        sacche += 1
        for t in celle:
            px[t * 4 + 3] = 0
        celle_tolte += len(celle)
    print(f'sacche interne rese trasparenti: {sacche} regioni, '
          f'{celle_tolte} pixel; regioni risparmiate perche\' toccano un '
          f'disco: {toccate}')
else:
    print('loto_pallini.png assente: il passo delle sacche interne e\' saltato')

pronta = Image.frombytes('RGBA', (w, h), bytes(px))
pronta = pronta.resize(MISURA_FINALE, Image.LANCZOS)

# **L'ALFA SEGUE L'INONDAZIONE ANCHE ATTRAVERSO IL RICAMPIONAMENTO.** Il
# ricampionamento di qualita' (LANCZOS) ha un supporto di tre pixel e lascia
# code di alfa da 1 a 8 fino a tre pixel dentro il fondo: invisibili a occhio,
# ma sono fondo con alfa non nullo, e la guardia le troverebbe. La maschera
# dell'inondazione si ricampiona con supporto CORTO (bilineare, un pixel) e
# l'alfa finale non puo' superarla: cosi' oltre un pixel dal bordo dell'arte il
# fondo e' trasparente esatto, e la sfumatura del bordo resta.
maschera = Image.frombytes(
    'L', (w, h),
    bytes(0 if px[q * 4 + 3] == 0 else 255 for q in range(w * h)))
maschera = maschera.resize(MISURA_FINALE, Image.BILINEAR)
fp = bytearray(pronta.tobytes())
mp = maschera.tobytes()
for q in range(MISURA_FINALE[0] * MISURA_FINALE[1]):
    if fp[q * 4 + 3] > mp[q]:
        fp[q * 4 + 3] = mp[q]
pronta = Image.frombytes('RGBA', MISURA_FINALE, bytes(fp))
pronta.save(DESTINAZIONE)
print(f'scritto {DESTINAZIONE} a {MISURA_FINALE[0]}x{MISURA_FINALE[1]}')

# LE MISURE DELLA VOCE, sul file scritto.
finale = Image.open(DESTINAZIONE).convert('RGBA')
fw, fh = finale.size
fp = finale.tobytes()
alfa_min = min(fp[i] for i in range(3, len(fp), 4))
perimetro_opaco = 0
for x in range(fw):
    for y in (0, fh - 1):
        if fp[(y * fw + x) * 4 + 3] > 0:
            perimetro_opaco += 1
for y in range(fh):
    for x in (0, fw - 1):
        if fp[(y * fw + x) * 4 + 3] > 0:
            perimetro_opaco += 1

# I BUCHI: pixel del tutto trasparenti NON collegati al bordo. Il fondo tolto
# per inondazione e' collegato al bordo per costruzione, quindi tutto cio' che
# resta trasparente e staccato e' un buco dentro l'arte.
visto2 = bytearray(fw * fh)
coda2 = deque()
def trasparente(p):
    return fp[p * 4 + 3] == 0
for x in range(fw):
    for y in (0, fh - 1):
        p = y * fw + x
        if trasparente(p) and not visto2[p]:
            visto2[p] = 1
            coda2.append(p)
for y in range(fh):
    for x in (0, fw - 1):
        p = y * fw + x
        if trasparente(p) and not visto2[p]:
            visto2[p] = 1
            coda2.append(p)
while coda2:
    p = coda2.popleft()
    x, y = p % fw, p // fw
    for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
        nx, ny = x + dx, y + dy
        if 0 <= nx < fw and 0 <= ny < fh:
            n = ny * fw + nx
            if not visto2[n] and trasparente(n):
                visto2[n] = 1
                coda2.append(n)
buchi = sum(1 for p in range(fw * fh) if trasparente(p) and not visto2[p])

print(f'alfa minimo {alfa_min}, perimetro opaco {perimetro_opaco} pixel, '
      f'buchi interni {buchi} pixel')
