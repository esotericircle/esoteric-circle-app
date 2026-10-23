"""Pubblica i video del cammino sul bucket, col manifesto che l'app legge.

Ordine FZ voce FZ.06. `tool/gli_asset_dell_ordine_fz.py` ricomprime i dodici
video, li taglia nei tre pezzi e scrive il manifesto nella cartella di posa
`_pronti`, ma la pubblicazione era "un passo suo" e non era mai stata fatta:
il manifesto sul bucket rispondeva 404 e nessuna persona riceveva un video
(trovato dalla simulazione da persona del 20 ottobre 2026). Decisione del
fondatore del 20 ottobre 2026: *"Si', pubblicali"*.

Prima di caricare, ogni file del manifesto si rilegge dal disco e si confronta
con la sua misura in byte e la sua impronta SHA-256: un file che non torna
ferma tutto, perche' l'app lo rifiuterebbe comunque
(`lib/core/viaggio/i_video_del_cammino_scaricati.dart`).

I file portano la versione nel nome (`_v1`): un file pubblicato non cambia mai
e si tiene in cache per un anno. Il manifesto si rilegge dopo cinque minuti.

    python tool/pubblica_i_video_del_cammino.py --prova     (controlla soltanto)
    python tool/pubblica_i_video_del_cammino.py --pubblica  (carica file e manifesto)
"""
import hashlib
import json
import os
import sys

PRONTI = os.environ.get(
    'VIDEO_DEL_CAMMINO',
    r'D:\Clienti Roogly\Rituali Cartomanzia\App\Viaggio Sciamano Animali'
    r'\_pronti')
BUCKET = 'esoteric-circle-assets-cdn'
PREFISSO = 'viaggio_sciamano/'
MANIFESTO = 'manifesto_viaggio_v1.json'
TIPI = {'.mp4': 'video/mp4', '.webp': 'image/webp', '.jpg': 'image/jpeg'}


def file_del_manifesto(manifesto):
    """Ogni file nominato dal manifesto, con misura e impronta attese."""
    for animale, voce in sorted(manifesto['animali'].items()):
        for pezzo in voce['pezzi'].values():
            yield animale, pezzo['file'], pezzo['byte'], pezzo['sha256']
        posa = voce['posa']
        yield animale, posa['file'], posa['byte'], posa['sha256']


def controlla(manifesto):
    """Rilegge dal disco ogni file e torna l'elenco da caricare."""
    da_caricare = []
    for animale, nome, byte, impronta in file_del_manifesto(manifesto):
        percorso = os.path.join(PRONTI, nome)
        dati = open(percorso, 'rb').read()
        if len(dati) != byte:
            raise SystemExit('%s: %d byte invece di %d' % (nome, len(dati), byte))
        if hashlib.sha256(dati).hexdigest() != impronta:
            raise SystemExit('%s: l\'impronta non torna' % nome)
        da_caricare.append((nome, dati))
    return da_caricare


def main():
    if '--prova' not in sys.argv and '--pubblica' not in sys.argv:
        raise SystemExit(__doc__)
    testo = open(os.path.join(PRONTI, MANIFESTO), 'rb').read()
    manifesto = json.loads(testo.decode('utf-8'))
    da_caricare = controlla(manifesto)
    totale = sum(len(d) for _, d in da_caricare)
    print('%d animali, %d file, %d byte: impronte tutte giuste' %
          (len(manifesto['animali']), len(da_caricare), totale))
    if '--pubblica' not in sys.argv:
        print('prova: niente caricato')
        return
    from google.cloud import storage
    secchio = storage.Client(project='esoteric-circle').bucket(BUCKET)
    for i, (nome, dati) in enumerate(da_caricare, 1):
        b = secchio.blob(PREFISSO + nome)
        b.cache_control = 'public, max-age=31536000, immutable'
        b.upload_from_string(
            dati, content_type=TIPI[os.path.splitext(nome)[1]])
        if i % 12 == 0:
            print('caricati %d su %d' % (i, len(da_caricare)))
    # Il manifesto per ultimo: finche' non c'e', nessuno chiede un file che
    # non sia ancora arrivato.
    b = secchio.blob(PREFISSO + MANIFESTO)
    b.cache_control = 'public, max-age=300'
    b.upload_from_string(testo, content_type='application/json; charset=utf-8')
    print('pubblicati %d file e il manifesto' % len(da_caricare))


if __name__ == '__main__':
    main()
