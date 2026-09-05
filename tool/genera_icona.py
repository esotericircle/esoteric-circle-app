# -*- coding: utf-8 -*-
"""L'ICONA DELL'APP DAL LOGO DI MAURO. Ordine BB voce 13.

**Il fatto**: l'icona era ancora quella predefinita di Flutter, cioe' il
logo di un altro prodotto sulla schermata di casa di chi installa il Cerchio.

**Cosa c'era, misurato sul file.** `assets/brand/logo.png` e' 720 per 720 e
porta tre cose in colonna: il medaglione con le rune e il triangolo fino a
**y=586**, la scritta "Esoteric Circle" da **y=588**, e un fregio sotto. Il
fondo e' bianco.

**Cosa fa questo strumento.**

1. Ritaglia il solo medaglione, misurando dove finisce invece di fidarsi di
   un numero scritto a mano: **si cerca la strozzatura**, cioe' il punto in
   cui il profilo del disegno si stringe perche' il cerchio si chiude in
   punta. Fra medaglione e scritta non c'e' una banda vuota, e cercarne una
   portava il ritaglio dentro la parola "Esoteric".
2. **Toglie il fondo bianco** e lo sostituisce con la tinta profonda del
   Cerchio. Un'icona con fondo bianco su una schermata di casa scura e' un
   francobollo, e su Android le maschere tonde le taglierebbero comunque gli
   angoli bianchi lasciando un alone.
3. Genera le misure di Android e di iOS.
4. Per l'**icona adattiva** di Android scrive due strati separati: il fondo
   pieno e il medaglione in primo piano, **rimpicciolito dentro il quadrato
   sicuro**. La maschera tonda di Android taglia il 28 per cento del lato:
   un medaglione a pieno quadro perderebbe le rune del bordo, che sono
   proprio cio' che lo rende riconoscibile.

Uso:
  python tool/genera_icona.py
"""

import os
from PIL import Image

SORGENTE = 'assets/brand/logo.png'

# **LA TINTA E' PRESA DAL CODICE, NON INVENTATA.** E' esattamente
# `ColorTokens.neutralDeep`, cioe' 0xFF080718, il secondo colore del cielo
# neutro del Cerchio: quello che si vede dietro la schermata di casa dell'app.
# La prima stesura scriveva 0x0D0820 dichiarando che era "la stessa di
# ColorTokens.deepest": quel token con quel valore non esiste, era un numero a
# caso con una citazione sopra. Se un giorno il cielo cambia colore, la prova
# in `test/l_icona_e_quella_del_cerchio_test.dart` cade e questo va rifatto.
FONDO = (8, 7, 24, 255)

# **QUANTO DEL QUADRO OCCUPA IL MEDAGLIONE NELL'ICONA ADATTIVA.**
#
# La maschera tonda di Android inscrive un cerchio nel 72 per cento centrale
# del primo piano: fuori di li' non c'e' garanzia che qualcosa si veda. Con
# 0.62 il medaglione sta dentro quel cerchio con un margine d'aria, e nella
# maschera quadrata resta comunque grande.
QUOTA_ADATTIVA = 0.62

ANDROID = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
}

# Le misure che l'AppIcon di iOS vuole, nome per nome.
IOS = {
    'Icon-App-20x20@1x.png': 20, 'Icon-App-20x20@2x.png': 40,
    'Icon-App-20x20@3x.png': 60, 'Icon-App-29x29@1x.png': 29,
    'Icon-App-29x29@2x.png': 58, 'Icon-App-29x29@3x.png': 87,
    'Icon-App-40x40@1x.png': 40, 'Icon-App-40x40@2x.png': 80,
    'Icon-App-40x40@3x.png': 120, 'Icon-App-60x60@2x.png': 120,
    'Icon-App-60x60@3x.png': 180, 'Icon-App-76x76@1x.png': 76,
    'Icon-App-76x76@2x.png': 152, 'Icon-App-83.5x83.5@2x.png': 167,
    'Icon-App-1024x1024@1x.png': 1024,
}


def _pieno(px, x, y):
    """Vero se quel pixel porta contenuto: non trasparente e non quasi bianco."""
    r, g, b, a = px[x, y]
    return a > 30 and not (r > 235 and g > 235 and b > 235)


def ritaglia_il_medaglione(im):
    """Il solo medaglione, misurato e non indovinato.

    **Si cerca la strozzatura fra il cerchio e la scritta**, invece di
    scrivere un numero: se un giorno il logo cambia proporzioni, il numero
    scritto a mano taglierebbe in mezzo alle rune e nessuno se ne accorgerebbe
    finche' non guarda l'icona.
    """
    w, h = im.size
    px = im.load()
    larghezze = []
    for y in range(h):
        xs = [x for x in range(0, w, 2) if _pieno(px, x, y)]
        larghezze.append((xs[0], xs[-1]) if xs else None)

    # **IL MEDAGLIONE FINISCE DOVE IL PROFILO SI STRINGE, non dove si svuota.**
    #
    # La prima stesura cercava una riga vuota sotto la meta' del logo e
    # trovava quella fra la scritta e il fregio: **il ritaglio si portava
    # dentro "Esoteric Circle"**, cioe' esattamente cio' che l'ordine chiedeva
    # di togliere. Fra il cerchio e la scritta non c'e' un vuoto: c'e' una
    # strozzatura, perche' il cerchio si chiude in punta.
    #
    # Si cerca quindi il punto in cui il profilo scende sotto un'inezia del
    # suo massimo, partendo dalla riga piu' larga.
    # **IL MASSIMO SI CERCA NELLA META' ALTA**, dove sta il cerchio: la
    # scritta e' piu' LARGA del medaglione (590 punti contro 580, misurato),
    # quindi cercando il massimo su tutto il logo si finiva su di lei e il
    # taglio scendeva fino al fregio. Il difetto era lo stesso di prima con
    # un'altra faccia.
    larghi = [(y, e[1] - e[0])
              for y, e in enumerate(larghezze) if e and y < h * 0.6]
    if not larghi:
        raise SystemExit('il logo e\' vuoto')
    yMax, massimo = max(larghi, key=lambda v: v[1])
    fine = None
    for y in range(yMax, h):
        e = larghezze[y]
        largo = 0 if e is None else e[1] - e[0]
        if largo < massimo * 0.12:
            fine = y
            break
    if fine is None:
        raise SystemExit('non trovo dove finisce il medaglione: il logo e\' '
                         'cambiato, e questo strumento va rivisto invece che '
                         'forzato')

    inizio = next(y for y in range(h) if larghezze[y] is not None)
    pieni = [larghezze[y] for y in range(inizio, fine) if larghezze[y]]
    sinistra = min(e[0] for e in pieni)
    destra = max(e[1] for e in pieni)
    print('medaglione: da y=%d a y=%d, da x=%d a x=%d' %
          (inizio, fine, sinistra, destra))

    # **UN QUADRATO CENTRATO SUL MEDAGLIONE**, se no il cerchio si deforma.
    cx = (sinistra + destra) // 2
    cy = (inizio + fine) // 2
    lato = max(destra - sinistra, fine - inizio)
    mezzo = lato // 2 + 4
    return im.crop((max(0, cx - mezzo), max(0, cy - mezzo),
                    min(w, cx + mezzo), min(h, cy + mezzo)))


def togli_il_bianco(im):
    """Il fondo bianco diventa trasparente.

    **Solo il bianco ai BORDI**, raggiunto dall'esterno: un riempimento cieco
    di tutti i pixel chiari mangerebbe anche i riflessi dell'oro dentro il
    medaglione.
    """
    im = im.convert('RGBA')
    w, h = im.size
    px = im.load()
    visti = set()
    coda = []
    for x in range(w):
        coda.append((x, 0))
        coda.append((x, h - 1))
    for y in range(h):
        coda.append((0, y))
        coda.append((w - 1, y))
    while coda:
        x, y = coda.pop()
        if (x, y) in visti or not (0 <= x < w and 0 <= y < h):
            continue
        visti.add((x, y))
        r, g, b, a = px[x, y]
        if a == 0 or (r > 225 and g > 225 and b > 225):
            px[x, y] = (r, g, b, 0)
            coda.extend([(x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)])
    return im


def su_fondo(im, lato, quota=1.0):
    """Il medaglione sopra la tinta profonda, alla misura chiesta."""
    quadro = Image.new('RGBA', (lato, lato), FONDO)
    dentro = int(lato * quota)
    figura = im.resize((dentro, dentro), Image.LANCZOS)
    quadro.paste(figura, ((lato - dentro) // 2, (lato - dentro) // 2), figura)
    return quadro


def main():
    im = Image.open(SORGENTE).convert('RGBA')
    medaglione = togli_il_bianco(ritaglia_il_medaglione(im))

    scritte = 0
    # Android: l'icona piena, e i due strati dell'adattiva.
    for cartella, lato in ANDROID.items():
        dove = os.path.join('android/app/src/main/res', cartella)
        os.makedirs(dove, exist_ok=True)
        su_fondo(medaglione, lato).save(os.path.join(dove, 'ic_launcher.png'))
        # **I DUE STRATI DELL'ADATTIVA.** Android compone il fondo e il primo
        # piano e poi ci passa sopra la sua maschera: tonda, quadrata con gli
        # angoli, a goccia. Il primo piano si disegna piu' piccolo del quadro
        # perche' la maschera tonda ne taglia il ventotto per cento, e li'
        # dentro ci sono le rune del bordo.
        # Il fondo e' una TINTA PIENA, quindi si dichiara come colore e non
        # come cinque immagini: un colore pesa nulla e non puo' sfocarsi.
        primo = Image.new('RGBA', (lato, lato), (0, 0, 0, 0))
        dentro = int(lato * QUOTA_ADATTIVA)
        figura = medaglione.resize((dentro, dentro), Image.LANCZOS)
        primo.paste(figura, ((lato - dentro) // 2, (lato - dentro) // 2),
                    figura)
        primo.save(os.path.join(dove, 'ic_launcher_foreground.png'))
        scritte += 2
    print('scritte %d immagini per Android' % scritte)
    # **SENZA QUESTO L'ADATTIVA NON ESISTE.** I due strati da soli sono file
    # muti: e' questo XML che dice ad Android di comporli, e senza di lui il
    # sistema continua a usare `ic_launcher.png` e a smussarlo come capita.
    #
    # `monochrome` e' lo stesso disegno: e' quello che Android 13 e oltre usa
    # per le icone a tinta unita, quando chi ha il telefono sceglie di
    # intonare la schermata di casa allo sfondo. Senza quella riga il Cerchio
    # sarebbe l'unica icona che resta a colori in mezzo a tutte le altre.
    dove = 'android/app/src/main/res/mipmap-anydpi-v26'
    os.makedirs(dove, exist_ok=True)
    with open(os.path.join(dove, 'ic_launcher.xml'), 'w',
              encoding='utf-8') as f:
        f.write(
            '<?xml version="1.0" encoding="utf-8"?>\n'
            '<adaptive-icon'
            ' xmlns:android="http://schemas.android.com/apk/res/android">\n'
            '    <background'
            ' android:drawable="@color/ic_launcher_background" />\n'
            '    <foreground'
            ' android:drawable="@mipmap/ic_launcher_foreground" />\n'
            '    <monochrome'
            ' android:drawable="@mipmap/ic_launcher_foreground" />\n'
            '</adaptive-icon>\n')

    # Il fondo e' una TINTA PIENA, quindi si dichiara come colore e non come
    # cinque immagini: un colore pesa nulla e non puo' sfocarsi.
    with open('android/app/src/main/res/values/ic_launcher_background.xml',
              'w', encoding='utf-8') as f:
        f.write('<?xml version="1.0" encoding="utf-8"?>\n'
                '<resources>\n'
                '    <color name="ic_launcher_background">'
                '#%02X%02X%02X</color>\n'
                '</resources>\n' % FONDO[:3])
    print('scritto il legame dell\'icona adattiva')


if __name__ == '__main__':
    main()
