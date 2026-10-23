"""Pubblica Marsiglia e Thoth sul bucket, col manifest che l'app legge.

Ordine FJ voci 9-13, 11 ottobre 2026. Il Rider-Waite sta nel binario; gli
altri mazzi stanno sul bucket pubblico `esoteric-circle-assets-cdn` e l'app li
scarica quando la persona li sceglie (`lib/core/tarot/i_mazzi_scaricati.dart`).

Per ogni mazzo:
- le piene sono i WebP definitivi a 853x1280, come sono (Marsiglia dalle voci
  di `ELENCO_DEFINITIVO.md`, Thoth l'ultima versione di ogni file, come nella
  misura dell'ordine FI voce 13);
- le miniature si fanno qui a lato lungo 500, qualita' 82, metodo 6, i
  parametri del Rider-Waite in `tool/converti_webp.py`;
- ogni file prende il nome del suo posto nel mazzo (da 00 a 77) e nel manifest
  e' legato alla carta del Rider-Waite che gli corrisponde (lo `stem` di
  `TarotCard`), con la misura in byte e l'impronta SHA-256.

I percorsi portano la versione (`marsiglia/v1/...`): un file pubblicato non
cambia mai, e si puo' tenere in cache per un anno. Il manifest invece si
rilegge dopo cinque minuti.

    python tool/pubblica_i_mazzi.py --prova     (scrive solo il manifest locale)
    python tool/pubblica_i_mazzi.py --pubblica  (carica file e manifest)

Il campo `piano` di ogni mazzo ripete la matrice dell'ordine FI voce 32
(Marsiglia dall'Iniziato, Thoth dall'Adepto): l'app oggi decide dal proprio
catalogo, il campo c'e' perche' un mazzo nuovo porti il suo piano senza una
release.
"""
import hashlib
import io
import json
import os
import re
import sys

from PIL import Image

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
# I definitivi stanno nella copia principale del progetto, fuori dal repo.
SORGENTE = os.environ.get(
    'MAZZI_SORGENTE',
    os.path.join(os.path.expanduser('~'), 'Desktop', 'esoteric-circle-app',
                 'assets'))
RIDER = os.path.join(RADICE, 'assets', 'img', 'mazzo-tarocchi')
BUCKET = 'esoteric-circle-assets-cdn'
PREFISSO = 'tarocchi/mazzi/'
BASE = 'https://storage.googleapis.com/%s/%s' % (BUCKET, PREFISSO)
LOCALE = os.path.join(RADICE, 'docs', 'collaudo', 'FJ',
                      'manifest_dei_mazzi.json')
SEMI = ('coppe', 'denari', 'spade', 'bastoni')

MAZZI = (
    ('marsiglia', 'Marsiglia', 'Mazzo Marsiglia', 'tar_mar', 'iniziato'),
    ('thoth', 'Thoth', 'Mazzo Thoth', 'tar_tho', 'adepto'),
)


def posto_del_rider(stem):
    """Il posto da 0 a 77 della carta del Rider-Waite, come TarotDeckStyle.postoDi."""
    m = re.match(r'^tar_rw_(\d{2})_', stem)
    if m:
        n = int(m.group(1))
        return {8: 11, 11: 8}.get(n, n)
    m = re.match(r'^tar_rw_([a-z]+)_(\d{2})_', stem)
    return 22 + SEMI.index(m.group(1)) * 14 + int(m.group(2)) - 1


def definitivi(cartella, prefisso):
    elenco = os.path.join(cartella, 'ELENCO_DEFINITIVO.md')
    if os.path.exists(elenco):
        nomi = re.findall(r'`(%s_[a-z0-9_\-]+)`' % prefisso,
                          io.open(elenco, encoding='utf-8').read())
        nomi = [n for n in dict.fromkeys(nomi)
                if os.path.exists(os.path.join(cartella, n + '.webp'))]
    else:
        ultimi = {}
        for f in sorted(os.listdir(cartella)):
            m = re.match(r'(%s_.+)_v(\d+)\.webp$' % prefisso, f)
            if m and int(m.group(2)) >= ultimi.get(m.group(1), (0,))[0]:
                ultimi[m.group(1)] = (int(m.group(2)), f[:-5])
        nomi = [v[1] for v in ultimi.values()]
    carte = {}
    dorso = None
    for n in nomi:
        m = re.match(r'^%s_(\d{2})_' % prefisso, n)
        if m:
            carte[int(m.group(1))] = n
        elif '_dorso_' in n:
            dorso = n
    if sorted(carte) != list(range(78)):
        raise SystemExit('%s: le carte non sono 78 (%d)' % (cartella, len(carte)))
    return carte, dorso


def miniatura(percorso):
    im = Image.open(percorso)
    im = im.convert('RGBA') if im.mode not in ('RGB', 'RGBA') else im
    w, h = im.size
    s = 500 / max(w, h)
    im = im.resize((round(w * s), round(h * s)), Image.LANCZOS)
    b = io.BytesIO()
    im.save(b, 'WEBP', quality=82, method=6)
    return b.getvalue()


def voce(percorso, dati):
    return {'percorso': percorso, 'byte': len(dati),
            'sha256': hashlib.sha256(dati).hexdigest()}


def prepara():
    """(manifest, {percorso sul bucket: byte})."""
    rider = sorted(f[:-5] for f in os.listdir(RIDER)
                   if f.endswith('.webp') and '_dorso_' not in f)
    if len(rider) != 78:
        raise SystemExit('il Rider-Waite nel binario non ha 78 carte')
    del_posto = {posto_del_rider(s): s for s in rider}
    caricare = {}
    mazzi = []
    for ident, nome, cartella, prefisso, piano in MAZZI:
        carte, dorso = definitivi(os.path.join(SORGENTE, cartella), prefisso)
        file = []
        totale = 0
        for posto in range(78):
            sorgente = os.path.join(SORGENTE, cartella, carte[posto] + '.webp')
            piena = open(sorgente, 'rb').read()
            mini = miniatura(sorgente)
            pp = '%s/v1/piene/%02d.webp' % (ident, posto)
            pm = '%s/v1/miniature/%02d.webp' % (ident, posto)
            caricare[pp], caricare[pm] = piena, mini
            totale += len(piena) + len(mini)
            file.append({'carta': del_posto[posto], 'origine': carte[posto],
                         'piena': voce(pp, piena), 'miniatura': voce(pm, mini)})
        if dorso:
            sorgente = os.path.join(SORGENTE, cartella, dorso + '.webp')
            piena = open(sorgente, 'rb').read()
            mini = miniatura(sorgente)
            pp, pm = '%s/v1/dorso.webp' % ident, '%s/v1/dorso_miniatura.webp' % ident
            caricare[pp], caricare[pm] = piena, mini
            totale += len(piena) + len(mini)
            file.append({'carta': 'dorso', 'origine': dorso,
                         'piena': voce(pp, piena), 'miniatura': voce(pm, mini)})
        mazzi.append({'id': ident, 'nome': nome, 'versione': 1,
                      'piano': piano, 'byte': totale, 'file': file})
    manifesto = {'formato': 1, 'base': BASE, 'mazzi': mazzi}
    return manifesto, caricare


def main():
    if '--prova' not in sys.argv and '--pubblica' not in sys.argv:
        raise SystemExit(__doc__)
    manifesto, caricare = prepara()
    testo = json.dumps(manifesto, ensure_ascii=False, indent=1)
    os.makedirs(os.path.dirname(LOCALE), exist_ok=True)
    with open(LOCALE, 'w', encoding='utf-8', newline='\n') as f:
        f.write(testo + '\n')
    for m in manifesto['mazzi']:
        print('%s: %d file, %d byte' % (m['nome'], 2 * len(m['file']), m['byte']))
    if '--pubblica' not in sys.argv:
        print('prova: niente caricato, manifest in %s' % LOCALE)
        return
    from google.cloud import storage
    secchio = storage.Client(project='esoteric-circle').bucket(BUCKET)
    for i, (percorso, dati) in enumerate(sorted(caricare.items()), 1):
        b = secchio.blob(PREFISSO + percorso)
        b.cache_control = 'public, max-age=31536000, immutable'
        b.upload_from_string(dati, content_type='image/webp')
        if i % 40 == 0:
            print('caricati %d su %d' % (i, len(caricare)))
    b = secchio.blob(PREFISSO + 'manifest.json')
    b.cache_control = 'public, max-age=300'
    b.upload_from_string(testo.encode('utf-8'),
                         content_type='application/json; charset=utf-8')
    print('pubblicati %d file e il manifest' % len(caricare))


if __name__ == '__main__':
    main()
