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
# **I DESTINATARI SONO DUE, ordine AR voce 09.** Fino alla 2185 la consegna
# andava al solo account di servizio del progetto; l'ordine chiede che arrivi
# anche all'indirizzo con cui Mauro usa il telefono. Restano due voci in una
# lista, cosi' aggiungerne un terzo domani non tocca il resto della procedura.
TESTER = ['cloud@esotericircle.app', 'info@esotericircle.com']
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


PACCHETTO = 'com.esotericircle.esoteric_circle'


def _adb():
    """Il percorso di adb, dal SDK locale o dal PATH."""
    locale = os.path.join(os.environ.get('LOCALAPPDATA', ''), 'Android', 'Sdk',
                          'platform-tools', 'adb.exe')
    return locale if os.path.isfile(locale) else 'adb'


def _corri(args, timeout=180):
    r = subprocess.run(args, capture_output=True, text=True,
                       encoding='utf-8', errors='replace', timeout=timeout)
    return r.returncode, (r.stdout or '') + (r.stderr or '')


def prova_di_accensione(archivio, attesa_secondi=12):
    """L'APK si accende davvero, oppure la consegna non parte.

    Quattro pretese, ciascuna col suo perche':
    1. c'e' UN dispositivo in stato `device`: senza, ci si ferma e lo si
       dice, perche' consegnare al buio e' come e' arrivata la 2161 rotta;
    2. l'APK appena costruito si installa (`adb install -r`);
    3. avviata l'app, dopo l'attesa dichiarata il processo e' VIVO e il
       sistema ha registrato `Displayed`, cioe' il primo fotogramma e' stato
       disegnato: un processo vivo che non disegna e' un'app appesa;
    4. nel log dell'avvio non c'e' nessun FATAL EXCEPTION del pacchetto.

    Quando una pretesa cade si stampano LE RIGHE VERE del log, non un
    riassunto, e la consegna muore prima di caricare qualunque cosa.
    """
    adb = _adb()
    print('prova di accensione...')
    _, fuori = _corri([adb, 'devices'])
    righe = [r for r in fuori.strip().splitlines()[1:] if r.strip()]
    vivi = [r.split()[0] for r in righe if r.strip().endswith('device')]
    if len(vivi) != 1:
        raise SystemExit(
            'prova di accensione: serve UN dispositivo in stato "device", '
            'trovato:\n' + fuori.strip() + '\nNon si consegna al buio: '
            'collega il telefono o avvia un emulatore e riprova.')
    codice, fuori = _corri([adb, 'install', '-r', archivio], timeout=600)
    if codice != 0 or 'Success' not in fuori:
        raise SystemExit('prova di accensione: install fallita:\n' + fuori)
    _corri([adb, 'logcat', '-c'])
    _corri([adb, 'shell', 'am', 'force-stop', PACCHETTO])
    _corri([adb, 'shell', 'monkey', '-p', PACCHETTO, '-c',
            'android.intent.category.LAUNCHER', '1'])
    time.sleep(attesa_secondi)
    # Il processo e' vivo?
    _, pid = _corri([adb, 'shell', 'pidof', PACCHETTO])
    # Il log dell'avvio, una volta sola: ci si leggono fotogramma e crash.
    _, log = _corri([adb, 'logcat', '-d', '-v', 'threadtime'])
    fatali = [r for r in log.splitlines() if 'FATAL EXCEPTION' in r
              or (PACCHETTO in r and 'AndroidRuntime' in r)]
    disegnato = any('Displayed' in r and PACCHETTO in r
                    for r in log.splitlines())
    if not pid.strip():
        raise SystemExit(
            'prova di accensione: il processo NON e\' vivo dopo '
            + str(attesa_secondi) + ' secondi. Le righe del log:\n'
            + '\n'.join(fatali[:25] or log.splitlines()[-25:]))
    if fatali:
        raise SystemExit(
            'prova di accensione: FATAL EXCEPTION nel log di avvio:\n'
            + '\n'.join(fatali[:25]))
    if not disegnato:
        raise SystemExit(
            'prova di accensione: il sistema non ha registrato "Displayed" '
            'per ' + PACCHETTO + ': il primo fotogramma non e\' stato '
            'disegnato. Ultime righe del log:\n'
            + '\n'.join(log.splitlines()[-25:]))
    print('prova di accensione: processo vivo, primo fotogramma disegnato, '
          'nessun FATAL EXCEPTION.')
    # IL NUMERO SI LEGGE QUI, dal pacchetto appena installato: e' il numero
    # dell'ARCHIVIO, letto dal dispositivo, non dal pubspec. Cosi' il passo
    # del registro in fondo non muore piu' chiedendo una variabile: nelle
    # consegne 2161 e 2162 la procedura e' morta due volte sullo stesso
    # gradino, a caricamento gia' avvenuto.
    _, dump = _corri([adb, 'shell', 'dumpsys', 'package', PACCHETTO])
    for r in dump.splitlines():
        if 'versionCode=' in r:
            numero = r.split('versionCode=')[1].split()[0]
            os.environ.setdefault('NUMERO_CONSEGNATO', numero)
            print('numero letto dal dispositivo: ' + numero)
            break


def numero_da_aapt2(archivio):
    """Il versionCode letto dall'archivio con aapt2, quando nessun dispositivo
    lo ha potuto leggere. Serve al registro: il numero e' dell'ARCHIVIO, mai
    del pubspec."""
    radice = os.path.join(os.environ.get('LOCALAPPDATA', ''), 'Android',
                          'sdk', 'build-tools')
    aapt2 = None
    if os.path.isdir(radice):
        for versione in sorted(os.listdir(radice), reverse=True):
            candidato = os.path.join(radice, versione, 'aapt2.exe')
            if os.path.isfile(candidato):
                aapt2 = candidato
                break
    if not aapt2:
        raise SystemExit('aapt2 non trovato sotto ' + radice + ': senza '
                         'dispositivo e senza aapt2 il numero non si legge, '
                         'e un registro col numero del pubspec direbbe una '
                         'cosa non misurata.')
    codice, fuori = _corri([aapt2, 'dump', 'badging', archivio])
    if codice != 0:
        raise SystemExit('aapt2 dump badging fallito:\n' + fuori)
    for pezzo in fuori.split():
        if pezzo.startswith("versionCode='"):
            numero = pezzo.split("'")[1]
            os.environ.setdefault('NUMERO_CONSEGNATO', numero)
            print('numero letto dall\'archivio con aapt2: ' + numero)
            return
    raise SystemExit('aapt2 non ha stampato un versionCode:\n' + fuori[:400])


def main():
    if len(sys.argv) < 3:
        raise SystemExit('uso: consegna.py <archivio> "<note>" oppure '
                         'consegna.py <archivio> @<file di note in UTF-8>')
    archivio, note = sys.argv[1], sys.argv[2]

    # LE NOTE CON GLI ACCENTI VANNO LETTE DA UN FILE, non passate a riga di
    # comando.
    #
    # Su Windows gli argomenti arrivano decodificati con la codepage di
    # sistema, e una "e" accentata nella riga di comando si presenta al server
    # come un carattere rotto: la 2152 e' stata consegnata con "La Luna ?"
    # nelle note, e se n'e' accorto solo chi ha riletto la risposta del server.
    # L'API non c'entrava, il corpo JSON e' sempre stato in UTF-8: si rompeva
    # prima, nel passaggio dalla shell a Python.
    #
    # Con la forma @file il testo non attraversa mai la riga di comando.
    if note.startswith('@'):
        note = io.open(note[1:], encoding='utf-8').read().strip()

    # E SI DICHIARA SUBITO se il testo si e' gia' rotto per strada, invece di
    # scoprirlo a consegna avvenuta: il carattere di sostituzione non compare
    # mai in un testo scritto bene.
    if '�' in note:
        raise SystemExit(
            'le note contengono un carattere rotto: sono passate da una shell '
            'che non parla UTF-8. Scrivile in un file e passalo come @file.')
    # LA PROVA DI ACCENSIONE, PRIMA DEL CARICAMENTO. Ordine 2162: la 2161 e'
    # arrivata a Mauro con duemilaquarantasei prove verdi e moriva all'avvio,
    # perche' nessuna prova avvia l'archivio: in `flutter test` Firebase e i
    # plugin nativi non partono affatto. Da qui in poi NESSUNA consegna parte
    # senza che l'APK si sia acceso davvero su un dispositivo: si installa, si
    # avvia, si pretende il processo vivo e il primo fotogramma disegnato, e
    # nessun FATAL EXCEPTION nel log. Se non c'e' un dispositivo, ci si ferma:
    # non si consegna al buio.
    # L'UNICO SALTO AMMESSO e' un ORDINE ESPLICITO di Mauro, scritto nella
    # variabile con la ragione: la consegna lo dichiara a voce alta e il
    # numero si legge dall'archivio con aapt2 invece che dal dispositivo.
    # E' un ripiego e si dichiara come tale: l'APK parte senza che nessun
    # dispositivo lo abbia acceso.
    salto = os.environ.get('ACCENSIONE_SALTATA_PER_ORDINE', '').strip()
    if salto:
        print('ATTENZIONE: prova di accensione SALTATA per ordine esplicito: '
              + salto)
        print('Questa consegna parte al buio: nessun dispositivo ha acceso '
              'questo archivio prima del caricamento.')
        numero_da_aapt2(archivio)
    else:
        prova_di_accensione(archivio)

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
        tok, dati={'testerEmails': TESTER})
    if stato != 200:
        raise SystemExit('distribuzione fallita ' + str(stato) + ': '
                         + str(corpo))
    print('distribuita a ' + ', '.join(TESTER))
    # **IL 200 NON E' LA PROVA, e si e' gia' pagato per crederlo.** La
    # risposta della distribuzione torna 200 anche quando l'invito non
    # raggiunge nessuno: si rilegge la release e si stampa quanti inviti
    # risultano accettati, cosi' chi legge il rapporto sa cosa e' successo
    # davvero invece di fidarsi di un codice di stato.
    stato_v, corpo_v = chiama(
        'https://firebaseappdistribution.googleapis.com/v1/' + release, tok)
    print('rilettura della release: stato ' + str(stato_v) + ', inviti '
          + str(corpo_v.get('testerCount', 'non dichiarato')) + ', accettati '
          + str(corpo_v.get('acceptedInvitationCount', 'non dichiarato')))

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
