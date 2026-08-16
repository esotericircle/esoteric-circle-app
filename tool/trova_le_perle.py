# LE CINQUANTA PERLE DEL LOTO, E IL FILE DEI PALLINI. Ordine AE voce 02.
#
# COME SI TROVANO, e perche' cosi'. Le perle sono sfere neutre, ma il loro
# grigio e' scuro quanto le incisioni: croma e luminanza da sole fondono i
# dischi coi tratti, misurato. Il segno che non si confonde e' il RIFLESSO: ogni
# perla porta un lampo bianco chiuso nel disco. Si parte dai riflessi e attorno
# a ogni seme si adatta un cerchio; poi ogni cerchio si RICENTRA sul baricentro
# del corpo neutro e il raggio si rimisura col profilo radiale mediano sulla
# SATURAZIONE NORMALIZZATA, che e' la grandezza giusta: il verde scuro ha croma
# assoluta bassa quanto il grigio, ma saturazione 0,61 contro lo 0,19 della
# perla, misurato. Un'ombra scambiata per perla muore alla ricentratura, perche'
# il suo raggio radiale crolla sotto quattordici: e' successo, (130,1349).
#
# I NUMERI, misurati su QUESTA arte:
#   - seme: luminanza >= 225 e croma <= 30, componenti da 20 a 3000 pixel;
#   - corpo: croma assoluta <= 35 per l'adattamento, saturazione <= 0,35 per la
#     ricentratura; il confine radiale e' saturazione > 0,45, fra lo 0,38 del
#     novantesimo percentile della perla e lo 0,56 dell'ombra;
#   - cerchio buono: dentro almeno 85 per cento neutro e 30 per cento scuro,
#     anello fuori con al massimo 10 per cento di chiaro;
#   - raggio buono dopo la ricentratura: fra 14 e 40.
#
# LA GUARDIA DURA: o cinquanta perle in cinque gruppi da dieci coi grandi
# sull'oro, o questo strumento si ferma senza scrivere niente.
#
# Si lancia a mano:  python tool/trova_le_perle.py
import math
from PIL import Image, ImageDraw

ARTE = 'brand_assets/sentieri/loto.png'
PALLINI = 'brand_assets/sentieri/loto_pallini.png'
MAPPA = 'docs/preview/loto_perle_trovate.png'

# I cinque colori del file dei pallini vecchio, uno per gruppo: la convenzione
# non cambia. L'ordine dei gruppi e' dal basso verso l'alto, come il lettore
# degli ancoraggi conta i gruppi.
COLORI = [(255, 0, 0), (0, 255, 0), (0, 255, 255), (255, 255, 0), (255, 0, 255)]

im = Image.open(ARTE).convert('RGBA')
w, h = im.size
p = im.tobytes()

def opaco(q): return p[q * 4 + 3] > 128
def croma(q):
    i = q * 4
    return max(p[i], p[i + 1], p[i + 2]) - min(p[i], p[i + 1], p[i + 2])
def lum(q):
    i = q * 4
    return (p[i] * 299 + p[i + 1] * 587 + p[i + 2] * 114) // 1000
def saturazione(q):
    i = q * 4
    mx = max(p[i], p[i + 1], p[i + 2])
    return (mx - min(p[i], p[i + 1], p[i + 2])) / mx if mx else 0.0
def neutro(q): return opaco(q) and croma(q) <= 35
def chiaro(q): return opaco(q) and lum(q) >= 225 and croma(q) <= 30
def oro(q):
    i = q * 4
    r, g, b = p[i], p[i + 1], p[i + 2]
    return opaco(q) and r > g and g >= b and (r - b) > 60 and r > 140

# I SEMI: i riflessi, componenti chiare da 20 a 3000 pixel.
visto = bytearray(w * h)
semi = []
for q in range(w * h):
    if not chiaro(q) or visto[q]:
        continue
    visto[q] = 1
    pila = [q]
    celle = []
    while pila:
        t = pila.pop()
        celle.append(t)
        x, y = t % w, t // w
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            nx, ny = x + dx, y + dy
            if 0 <= nx < w and 0 <= ny < h:
                n = ny * w + nx
                if chiaro(n) and not visto[n]:
                    visto[n] = 1
                    pila.append(n)
    if 20 <= len(celle) <= 3000:
        semi.append((sum(k % w for k in celle) // len(celle),
                     sum(k // w for k in celle) // len(celle)))

ANG = [a * math.pi / 18 for a in range(36)]

def misura(cx, cy, r):
    nd = sc = td = 0
    for fr in (0.35, 0.6, 0.85):
        for a in ANG:
            x = round(cx + r * fr * math.cos(a))
            y = round(cy + r * fr * math.sin(a))
            if 0 <= x < w and 0 <= y < h:
                td += 1
                q = y * w + x
                if neutro(q):
                    nd += 1
                    if lum(q) <= 120:
                        sc += 1
    cb = tf = 0
    for a in ANG:
        x = round(cx + (r + 5) * math.cos(a))
        y = round(cy + (r + 5) * math.sin(a))
        if 0 <= x < w and 0 <= y < h:
            tf += 1
            if chiaro(y * w + x):
                cb += 1
    if td == 0 or tf == 0:
        return None
    return nd / td, sc / td, cb / tf

def raggio_radiale(cx, cy):
    raggi = []
    for a in ANG:
        d = 8
        while d <= 40:
            x = round(cx + d * math.cos(a))
            y = round(cy + d * math.sin(a))
            if not (0 <= x < w and 0 <= y < h):
                break
            if not opaco(y * w + x) or saturazione(y * w + x) > 0.45:
                break
            d += 1
        raggi.append(d)
    raggi.sort()
    return raggi[len(raggi) // 2] - 1

grezzi = []
for sx, sy in semi:
    meglio = None
    for r in range(16, 33, 2):
        for dy in range(-12, 13, 3):
            for dx in range(-12, 13, 3):
                m = misura(sx + dx, sy + dy, r)
                if m is None:
                    continue
                qn, qs, qc = m
                s = qn + qs - 2 * qc
                if meglio is None or s > meglio[0]:
                    meglio = (s, qn, qs, qc, sx + dx, sy + dy, r)
    s, qn, qs, qc, cx, cy, r = meglio
    if qn >= 0.85 and qs >= 0.30 and qc <= 0.10:
        grezzi.append((cx, cy, r))

rifinite = []
scartate = []
for cx, cy, r in grezzi:
    rr = round(r * 1.2)
    sx = sy = n = 0
    for y in range(max(0, cy - rr), min(h, cy + rr + 1)):
        for x in range(max(0, cx - rr), min(w, cx + rr + 1)):
            if (x - cx) ** 2 + (y - cy) ** 2 <= rr * rr and \
                    opaco(y * w + x) and saturazione(y * w + x) <= 0.35:
                sx += x
                sy += y
                n += 1
    if n == 0:
        continue
    ncx, ncy = sx // n, sy // n
    nr = raggio_radiale(ncx, ncy)
    if 14 <= nr <= 40:
        rifinite.append((ncx, ncy, nr))
    else:
        scartate.append((cx, cy, r, nr))

perle = []
for c in sorted(rifinite, key=lambda c: -c[2]):
    if all((c[0] - u[0]) ** 2 + (c[1] - u[1]) ** 2 > max(c[2], u[2]) ** 2
           for u in perle):
        perle.append(c)

print(f'semi {len(semi)}, cerchi buoni {len(grezzi)}, '
      f'scartate alla ricentratura {len(scartate)} {scartate}, '
      f'perle uniche {len(perle)}')

# I CINQUE FIORI, per vicinanza spaziale: si parte dai cinque blob d'oro grandi,
# che sono i bottoni dei fiori, e ogni perla va al bottone piu' vicino.
visto = bytearray(w * h)
bottoni = []
for q in range(w * h):
    if not oro(q) or visto[q]:
        continue
    visto[q] = 1
    pila = [q]
    n = 0
    sx = sy = 0
    while pila:
        t = pila.pop()
        n += 1
        sx += t % w
        sy += t // w
        x, y = t % w, t // w
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            nx, ny = x + dx, y + dy
            if 0 <= nx < w and 0 <= ny < h:
                m = ny * w + nx
                if oro(m) and not visto[m]:
                    visto[m] = 1
                    pila.append(m)
    if n > 3000:
        bottoni.append((n, sx // n, sy // n))
bottoni.sort(key=lambda b: -b[1] * 0)  # tengo l'ordine di scoperta
assert len(bottoni) == 5, f'bottoni d\'oro trovati {len(bottoni)} invece di 5'
# dal basso verso l'alto, come il lettore conta i gruppi
bottoni.sort(key=lambda b: -b[2])

gruppi = {i: [] for i in range(5)}
for c in perle:
    d = [(c[0] - bx) ** 2 + (c[1] - by) ** 2 for _, bx, by in bottoni]
    gruppi[d.index(min(d))].append(c)

# LA GUARDIA DURA.
guasti = []
if len(perle) != 50:
    guasti.append(f'le perle sono {len(perle)} invece di 50')
for i in range(5):
    if len(gruppi[i]) != 10:
        guasti.append(f'il fiore {i} ha {len(gruppi[i])} perle invece di 10: '
                      f'{sorted(gruppi[i])}')

# I GRANDI: baricentro delle dieci perle, verificato sull'oro nell'intorno 9x9.
grandi = []
for i in range(5):
    if len(gruppi[i]) != 10:
        continue
    gx = sum(x for x, y, r in gruppi[i]) // 10
    gy = sum(y for x, y, r in gruppi[i]) // 10
    quanto_oro = sum(1 for dy in range(-4, 5) for dx in range(-4, 5)
                     if 0 <= gx + dx < w and 0 <= gy + dy < h
                     and oro((gy + dy) * w + gx + dx))
    if quanto_oro < 41:
        guasti.append(f'il grande del fiore {i} a ({gx},{gy}) non cade '
                      f'sull\'oro: {quanto_oro} pixel su 81 nell\'intorno')
    grandi.append((gx, gy, quanto_oro))

# LA CONTROPROVA STRUTTURALE, detta da Mauro guardando l'arte: le dieci perle
# di un fiore stanno su un ANELLO, quasi equidistanti dal centro e fra loro.
# Un'impostora non sbaglia di poco: un'ombra o un frammento cade dentro o fuori
# dall'anello, o apre un buco angolare. I confini vengono dalla struttura, non
# dalla misura: su un anello di dieci il passo ideale e' 36 gradi, e un disegno
# fatto a mano oscilla, misurato fra 25 e 44; lo scarto radiale misurato sta
# fra il 6 e il 12 per cento del raggio mediano. **L'anello si misura dal
# baricentro delle dieci**, che e' il suo centro per costruzione: il blob
# dell'oro ha il baricentro spostato dal riflesso, misurato 22 pixel sul
# fiore in cima, e da li' l'anello sembrerebbe storto.
for i in range(5):
    if len(gruppi[i]) != 10:
        continue
    bx, by = grandi[i][0], grandi[i][1]
    dist = sorted(math.hypot(x - bx, y - by) for x, y, r in gruppi[i])
    if (dist[-1] - dist[0]) > 0.25 * dist[5]:
        guasti.append(f'il fiore {i} non e\' un anello: raggi da {dist[0]:.0f} '
                      f'a {dist[-1]:.0f} contro un mediano di {dist[5]:.0f}')
    angoli = sorted(math.degrees(math.atan2(y - by, x - bx))
                    for x, y, r in gruppi[i])
    passi = [(angoli[(k + 1) % 10] - angoli[k]) % 360 for k in range(10)]
    if min(passi) < 20 or max(passi) > 55:
        guasti.append(f'il fiore {i} ha passi angolari da {min(passi):.0f} a '
                      f'{max(passi):.0f} gradi: dieci perle su un anello '
                      f'camminano attorno ai 36')


if guasti:
    print('LA GUARDIA DURA FERMA LO STRUMENTO:')
    for g in guasti:
        print(' ', g)
    raise SystemExit(1)

raggi = sorted(r for _, _, r in perle)
raggio_mediano = raggi[len(raggi) // 2]
# **IL RAGGIO DEL GRANDE E' IL DOPPIO DEL MEDIANO DEI MINI**, per la convenzione
# del file dei pallini e per il confine del lettore, che pretende il grande
# largo almeno 1,5 volte il diametro mediano. Il disco d'oro vero misura fra 37
# e 46 di raggio: coi raggi veri tre fiori su cinque non passerebbero il
# confine, e la differenza si dichiara nel rapporto.
raggio_grande = raggio_mediano * 2

print(f'perle 50, raggio mediano {raggio_mediano}, minimo {raggi[0]}, '
      f'massimo {raggi[-1]}, raggio del grande {raggio_grande}')
for i in range(5):
    print(f'fiore {i}: bottone {bottoni[i][1:]}, grande {grandi[i]}')

# IL FILE DEI PALLINI: pieni e opachi su fondo trasparente, un colore per
# gruppo. Nessun pallino deve toccarne un altro, altrimenti il lettore vede una
# macchia sola: si verifica e ci si ferma se succede.
for i in range(5):
    for j in range(5):
        for a in gruppi[i]:
            for b in gruppi[j]:
                if a is b:
                    continue
                d = math.hypot(a[0] - b[0], a[1] - b[1])
                if d < a[2] + b[2] + 2:
                    raise SystemExit(
                        f'due pallini si toccherebbero: {a} e {b}, distanza '
                        f'{d:.0f}')

pallini = Image.new('RGBA', (w, h), (0, 0, 0, 0))
dis = ImageDraw.Draw(pallini)
for i in range(5):
    col = COLORI[i] + (255,)
    gx, gy, _ = grandi[i]
    dis.ellipse([gx - raggio_grande, gy - raggio_grande,
                 gx + raggio_grande, gy + raggio_grande], fill=col)
    for x, y, r in gruppi[i]:
        dis.ellipse([x - r, y - r, x + r, y + r], fill=col)
pallini.save(PALLINI)
print(f'scritto {PALLINI}')

# LA MAPPA PER GLI OCCHI DI MAURO: l'arte coi cerchi trovati, colorati per
# gruppo, cosi' un pallino sul petalo sbagliato si vede in un secondo.
mappa = Image.new('RGBA', (w, h), (20, 20, 30, 255))
mappa.alpha_composite(im)
dm = ImageDraw.Draw(mappa)
for i in range(5):
    col = COLORI[i] + (255,)
    gx, gy, _ = grandi[i]
    dm.ellipse([gx - raggio_grande, gy - raggio_grande,
                gx + raggio_grande, gy + raggio_grande], outline=col, width=4)
    for x, y, r in gruppi[i]:
        dm.ellipse([x - r, y - r, x + r, y + r], outline=col, width=4)
mappa.save(MAPPA)
print(f'scritta {MAPPA}')
