# -*- coding: utf-8 -*-
"""INGRANDISCE I DODICI ANIMALI GUIDA, ordine DE voce 04, 11 settembre 2026.

**Le parole dell'ordine, e sono un divieto prima che un compito.** *"NON si
rigenerano, e la ragione non e' il costo: l'animale che si scopre con la lente
deve essere identico a quello che si trova nel Passaporto e fra i dodici totem.
Due lupi diversi nella stessa app rompono la promessa."*

Quindi qui non si genera niente: si **ingrandisce**, con l'upscaling di Imagen
su Vertex AI, che il progetto ha gia' configurato.

**IL PROBLEMA DELL'ALPHA, e la sua cura.** L'upscaler di Imagen prende e
restituisce un'immagine **senza canale alpha**: mandargli un WebP trasparente
vuol dire riavere un rettangolo con lo sfondo inventato da lui. La cura e'
separare prima di mandare:

  1. il colore va all'upscaler, con le zone trasparenti riempite col colore del
     bordo piu' vicino, cosi' l'upscaler non inventa un fondo che poi sborda
     sui contorni;
  2. **la maschera dell'alpha si ingrandisce a parte, con Lanczos**, che su una
     maschera gia' antialiasata e' esatto quanto serve e non inventa niente;
  3. le due meta' si rimettono insieme.

**Cosi' la sagoma resta quella, al pixel**, ed e' la cosa che conta: e' la
stessa sagoma che la lente scopre, che le impronte disegnano e che attraversa
il cielo della home.

Uso:
  python tool/ingrandisci_animali.py            prova su UN animale, il lupo
  python tool/ingrandisci_animali.py tutti      tutti e dodici
  python tool/ingrandisci_animali.py lupo orso  solo quelli nominati
"""

import io
import os
import subprocess
import sys
import base64
import json

try:
    from PIL import Image
except ImportError:  # pragma: no cover
    print('Serve Pillow: pip install pillow')
    sys.exit(1)

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(BASE, 'assets', 'img', 'animali')
FUORI = os.path.join(BASE, 'assets', 'img', 'animali_grandi')

PROGETTO = 'esoteric-circle'
REGIONE = 'us-central1'
MODELLO = 'imagegeneration@002'

NOMI = ['aquila', 'cavallo', 'cervo', 'corvo', 'falco', 'gufo',
        'lince', 'lupo', 'orso', 'serpente', 'tartaruga', 'volpe']

# **LA MISURA CHIESTA DALL'ORDINE**: circa il doppio, 1800 per 1520. Le dodici
# non hanno la stessa forma, quindi il doppio esatto di ognuna e' la cosa
# giusta: il fattore e' due, non una misura fissa che le deformerebbe.
FATTORE = 2


def gcloud():
    """Il percorso del gcloud SDK, che su questa macchina non sta nel PATH."""
    candidati = [
        os.path.expandvars(
            r'%LOCALAPPDATA%\Google\Cloud SDK\google-cloud-sdk\bin\gcloud.cmd'),
        'gcloud',
    ]
    for c in candidati:
        if c == 'gcloud' or os.path.exists(c):
            return c
    return 'gcloud'


def gettone():
    """Il gettone di accesso, dalle credenziali predefinite."""
    fuori = subprocess.run(
        [gcloud(), 'auth', 'print-access-token'],
        capture_output=True, text=True, shell=True)
    if fuori.returncode != 0:
        raise RuntimeError('gcloud non ha dato il gettone: ' + fuori.stderr)
    return fuori.stdout.strip()


def riempi_i_trasparenti(im):
    """Riempie le zone trasparenti col colore che hanno intorno.

    **Perche' non basta mandare il PNG trasparente.** L'upscaler lo appiattisce
    su un fondo suo, di solito nero, e quel nero **sborda** sui contorni
    antialiasati: l'animale torna con un alone scuro tutto intorno. Riempiendo
    prima col colore del bordo, l'alone che sborda e' del colore dell'animale e
    la maschera lo ritaglia via senza lasciare traccia.
    """
    rgb = im.convert('RGB')
    alfa = im.getchannel('A')
    # Il trucco: si ingrandisce l'immagine dilatandone i colori dove e'
    # trasparente, con una sfocatura pesante mascherata dall'alpha.
    from PIL import ImageFilter
    sfondo = rgb.filter(ImageFilter.GaussianBlur(24))
    fuso = Image.composite(rgb, sfondo, alfa.point(lambda v: 255 if v > 8 else 0))
    for _ in range(3):
        sfondo = fuso.filter(ImageFilter.GaussianBlur(24))
        fuso = Image.composite(fuso, sfondo,
                               alfa.point(lambda v: 255 if v > 8 else 0))
    return fuso


def chiedi_a_imagen(png_bytes, token):
    """Manda il colore all'upscaler e torna i byte dell'immagine grande."""
    import urllib.request
    url = ('https://{r}-aiplatform.googleapis.com/v1/projects/{p}/locations/'
           '{r}/publishers/google/models/{m}:predict').format(
               r=REGIONE, p=PROGETTO, m=MODELLO)
    corpo = {
        'instances': [{
            'prompt': '',
            'image': {'bytesBase64Encoded':
                      base64.b64encode(png_bytes).decode('ascii')},
        }],
        'parameters': {
            'sampleCount': 1,
            'mode': 'upscale',
            'upscaleConfig': {'upscaleFactor': 'x2'},
        },
    }
    richiesta = urllib.request.Request(
        url,
        data=json.dumps(corpo).encode('utf-8'),
        headers={'Authorization': 'Bearer ' + token,
                 'Content-Type': 'application/json; charset=utf-8'},
    )
    with urllib.request.urlopen(richiesta, timeout=300) as risposta:
        dati = json.loads(risposta.read().decode('utf-8'))
    previsioni = dati.get('predictions') or []
    if not previsioni:
        raise RuntimeError('Imagen non ha risposto con nessuna immagine: '
                           + json.dumps(dati)[:400])
    return base64.b64decode(previsioni[0]['bytesBase64Encoded'])


def ingrandisci(nome, token):
    sorgente = os.path.join(SRC, 'ani_%s_v1.webp' % nome)
    im = Image.open(sorgente).convert('RGBA')
    larga, alta = im.size

    colore = riempi_i_trasparenti(im)
    buf = io.BytesIO()
    colore.save(buf, format='PNG')
    grande_bytes = chiedi_a_imagen(buf.getvalue(), token)
    grande = Image.open(io.BytesIO(grande_bytes)).convert('RGB')

    atteso = (larga * FATTORE, alta * FATTORE)
    if grande.size != atteso:
        # **L'upscaler puo' tornare una misura sua**: si riporta a quella
        # attesa, cosi' la maschera combacia al pixel.
        grande = grande.resize(atteso, Image.LANCZOS)

    # **LA MASCHERA A PARTE, con Lanczos.** Su un canale alpha gia' antialiasato
    # Lanczos e' la scelta giusta: non inventa contorni, li interpola.
    maschera = im.getchannel('A').resize(atteso, Image.LANCZOS)
    finita = grande.convert('RGBA')
    finita.putalpha(maschera)

    os.makedirs(FUORI, exist_ok=True)
    destinazione = os.path.join(FUORI, 'ani_%s_v2.webp' % nome)
    finita.save(destinazione, format='WEBP', lossless=True, quality=100)
    return sorgente, destinazione, (larga, alta), atteso


def main():
    quali = sys.argv[1:]
    if not quali:
        quali = ['lupo']
    elif quali == ['tutti']:
        quali = NOMI
    token = gettone()
    print('Gettone preso, %d caratteri.' % len(token))
    fatti = []
    for n in quali:
        try:
            s, d, prima, dopo = ingrandisci(n, token)
            print('%-10s %sx%s -> %sx%s  %s' %
                  (n, prima[0], prima[1], dopo[0], dopo[1], d))
            fatti.append(n)
        except Exception as errore:  # noqa: BLE001
            print('%-10s FALLITO: %s' % (n, errore))
    print('Ingranditi %d su %d.' % (len(fatti), len(quali)))


if __name__ == '__main__':
    main()
