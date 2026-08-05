# -*- coding: utf-8 -*-
"""La consegna di un archivio a Firebase App Distribution, in un comando solo.

**Perche' questo file esiste.** La consegna era una sequenza di chiamate curl
scritte a mano a ogni giro, e in fondo alla sequenza c'era un passo che si
faceva a mano: aggiornare `docs/versione_distribuita.json` col numero appena
consegnato. Un passo a mano in fondo a una procedura lunga e' un passo che
prima o poi salta, e quando salta il guardiano `versione_build_test.dart`
smette di sorvegliare qualcosa di vero, perche' confronta il numero nuovo con
un ultimo distribuito che non e' piu' l'ultimo.

Qui la sequenza e' una sola, e **il file si aggiorna dentro la procedura**, solo
dopo che il server ha confermato la distribuzione.

**Nessuna chiave.** L'organizzazione vieta la creazione di chiavi JSON per gli
account di servizio, ed e' una scelta giusta. Il token si ottiene al volo
impersonando `distributore-app@`, dura un'ora e non si salva.

Uso:
  python tool/consegna.py build/app/outputs/flutter-apk/app-release.apk "Le note"
"""

import io
import json
import os
import subprocess
import sys
import time
import urllib.error
import urllib.request

APP = '1:425821975933:android:1b1ca4db8d4df69b940814'
SERVIZIO = 'distributore-app@esoteric-circle.iam.gserviceaccount.com'
TESTER = 'cloud@esotericircle.app'
REGISTRO = 'docs/versione_distribuita.json'


def token():
    """Il token impersonato, preso al volo e mai salvato."""
    out = subprocess.run(
        ['gcloud', 'auth', 'print-access-token',
         '--impersonate-service-account=' + SERVIZIO],
        capture_output=True, text=True, shell=True)
    if out.returncode != 0:
        raise SystemExit('token non ottenuto: ' + out.stderr.strip())
    return out.stdout.strip()


def chiama(url, tok, dati=None, metodo=None, binario=False):
    intestazioni = {'Authorization': 'Bearer ' + tok}
    corpo = None
    if binario:
        corpo = dati
        intestazioni['Content-Type'] = 'application/octet-stream'
        intestazioni['X-Goog-Upload-File-Name'] = 'app-release.apk'
        intestazioni['X-Goog-Upload-Protocol'] = 'raw'
    elif dati is not None:
        corpo = json.dumps(dati).encode('utf-8')
        intestazioni['Content-Type'] = 'application/json'
    req = urllib.request.Request(url, data=corpo, headers=intestazioni,
                                 method=metodo)
    try:
        with urllib.request.urlopen(req, timeout=1800) as r:
            testo = r.read().decode('utf-8')
            return r.status, (json.loads(testo) if testo.strip() else {})
    except urllib.error.HTTPError as e:
        return e.code, {'errore': e.read().decode('utf-8')}


def main():
    if len(sys.argv) < 3:
        raise SystemExit('uso: consegna.py <archivio> "<note>"')
    archivio, note = sys.argv[1], sys.argv[2]
    peso = os.path.getsize(archivio)
    print('archivio: ' + archivio + '  ' + '{:,}'.format(peso).replace(',', '.')
          + ' byte')

    tok = token()

    # 1. CARICAMENTO. Torna un'operazione, non la release: va attesa.
    print('carico...')
    stato, corpo = chiama(
        'https://firebaseappdistribution.googleapis.com/upload/v1/projects/'
        '425821975933/apps/' + APP + '/releases:upload',
        tok, dati=io.open(archivio, 'rb').read(), binario=True)
    if stato != 200:
        raise SystemExit('caricamento fallito ' + str(stato) + ': ' + str(corpo))
    operazione = corpo.get('name')
    print('operazione: ' + str(operazione))

    # 2. L'ATTESA. Un 200 sul caricamento NON e' una release pronta: e' una
    #    richiesta accettata. La release esiste quando l'operazione e' done.
    release, esito = None, None
    for _ in range(60):
        stato, corpo = chiama(
            'https://firebaseappdistribution.googleapis.com/v1/' + operazione,
            tok)
        if corpo.get('done'):
            risposta = corpo.get('response', {})
            esito = risposta.get('result')
            release = risposta.get('release', {}).get('name')
            break
        time.sleep(5)
    if not release:
        raise SystemExit('operazione non conclusa: ' + str(corpo))
    print('esito: ' + str(esito))
    print('release: ' + release)

    # 3. LE NOTE, e si rileggono dal server invece di darle per scritte.
    stato, corpo = chiama(
        'https://firebaseappdistribution.googleapis.com/v1/' + release
        + '?updateMask=releaseNotes.text',
        tok, dati={'releaseNotes': {'text': note}}, metodo='PATCH')
    if stato != 200:
        raise SystemExit('note non applicate ' + str(stato) + ': ' + str(corpo))
    print('note rilette dal server: ' + repr(
        corpo.get('releaseNotes', {}).get('text')))

    # 4. LA DISTRIBUZIONE al destinatario unico.
    stato, corpo = chiama(
        'https://firebaseappdistribution.googleapis.com/v1/' + release
        + ':distribute',
        tok, dati={'testerEmails': [TESTER]})
    if stato != 200:
        raise SystemExit('distribuzione fallita ' + str(stato) + ': '
                         + str(corpo))
    print('distribuita a ' + TESTER)

    # 5. IL REGISTRO, DENTRO LA PROCEDURA e non a mano, e solo adesso: prima di
    #    qui non c'era niente di consegnato da registrare.
    numero = int(release.rstrip('/').split('/')[-1]) if False else None
    # Il numero vero e' quello dell'archivio, letto da chi ci ha gia' guardato
    # dentro con aapt2 e passato qui: si prende dal pubspec solo come ultima
    # risorsa, e si dichiara.
    numero = int(os.environ.get('NUMERO_CONSEGNATO', '0'))
    if numero <= 0:
        raise SystemExit('NUMERO_CONSEGNATO non impostato: il registro non si '
                         'aggiorna con un numero non letto dall archivio')
    reg = json.loads(io.open(REGISTRO, encoding='utf-8').read())
    prima = reg.get('ultimo_distribuito')
    reg['ultimo_distribuito'] = numero
    reg['quando'] = time.strftime('%Y-%m-%d')
    reg['release'] = release.rstrip('/').split('/')[-1]
    io.open(REGISTRO, 'w', encoding='utf-8').write(
        json.dumps(reg, ensure_ascii=False, indent=2) + '\n')
    print('registro aggiornato: ' + str(prima) + ' -> ' + str(numero))


if __name__ == '__main__':
    main()
