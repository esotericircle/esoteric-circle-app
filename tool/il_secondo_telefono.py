# -*- coding: utf-8 -*-
"""IL SECONDO TELEFONO DI COLLAUDO, SENZA TELEFONO. Ordine FD voce 05.

L'ordine voleva il secondo account sull'emulatore del PC, ma l'emulatore non
parte: la virtualizzazione e' spenta nel firmware (il driver aehd si ferma
col codice -95, 5 ottobre 2026). Il fondatore ha scelto, lo stesso giorno, un
secondo telefono finto: questo client, che entra come account anonimo di
collaudo e fa le STESSE chiamate dell'app al server, coi suoi nomi e i suoi
campi. Le catture restano quelle del Realme.

**Le regole che rispetta.**
- E' un account di collaudo, registrato in `functions/src/i_collaudi.ts` e in
  `docs/collaudo/registro_dei_collaudi.md`: le porte del Cerchio lo chiama
  SOLO quando il server lo sa collaudo (sottocomando `cerchio`, che lo
  verifica prima di tutto), cosi' non scrive mai nello spazio degli utenti.
- L'accesso dell'account (il gettone di rinnovo) sta in
  `.secrets/il_secondo_telefono.json`, che git esclude; non si stampa.
- La chiave del client Firebase si legge da `android/app/google-services.json`
  e non si stampa.
- Ogni chiamata si scrive nel registro delle chiamate,
  `docs/collaudo/FD/il_secondo_telefono.txt`: nome della porta, campi, esito.

Uso:
  python tool/il_secondo_telefono.py nasci          # crea l'account e dice l'uid
  python tool/il_secondo_telefono.py uid            # dice l'uid
  python tool/il_secondo_telefono.py profilo        # quattordici anni, nome, icona
  python tool/il_secondo_telefono.py legame CODICE  # entra nel Cerchio del Realme
  python tool/il_secondo_telefono.py presente MINUTI  # il passo della presenza
  python tool/il_secondo_telefono.py esce           # esce dal conto dei presenti
"""
import datetime
import io
import json
import os
import sys
import time
import urllib.error
import urllib.request

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(RADICE)
SEGRETO = '.secrets/il_secondo_telefono.json'
REGISTRO = 'docs/collaudo/FD/il_secondo_telefono.txt'
REGIONE = 'europe-west1'
PROGETTO = 'esoteric-circle'
NOME = 'Collaudo Due'


def chiave():
    for p in ('android/app/google-services.json',
              os.path.join(os.path.dirname(RADICE), '..', '..', 'android', 'app',
                           'google-services.json')):
        if os.path.exists(p):
            j = json.load(io.open(p, encoding='utf-8'))
            return j['client'][0]['api_key'][0]['current_key']
    raise SystemExit('google-services.json non trovato')


def annota(riga):
    os.makedirs(os.path.dirname(REGISTRO), exist_ok=True)
    adesso = datetime.datetime.now(datetime.timezone.utc).isoformat(timespec='seconds')
    with io.open(REGISTRO, 'a', encoding='utf-8', newline='\n') as f:
        f.write(f'{adesso} {riga}\n')
    print(riga)


def posta(url, corpo, gettone=None):
    dati = json.dumps(corpo).encode('utf-8')
    req = urllib.request.Request(url, data=dati, method='POST',
                                 headers={'Content-Type': 'application/json'})
    if gettone:
        req.add_header('Authorization', 'Bearer ' + gettone)
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            return r.status, json.loads(r.read().decode('utf-8') or '{}')
    except urllib.error.HTTPError as e:
        return e.code, {'errore': e.read().decode('utf-8')[:300]}


def nasci():
    if os.path.exists(SEGRETO):
        raise SystemExit('l\'account esiste gia\': ' + uid())
    stato, r = posta('https://identitytoolkit.googleapis.com/v1/accounts:signUp?key='
                     + chiave(), {'returnSecureToken': True})
    if stato != 200:
        raise SystemExit('nascita rifiutata: %s %s' % (stato, r))
    os.makedirs('.secrets', exist_ok=True)
    json.dump({'uid': r['localId'], 'rinnovo': r['refreshToken']},
              io.open(SEGRETO, 'w', encoding='utf-8'))
    annota('nasci: account anonimo creato, uid ' + r['localId']
           + ' (nessuna porta del Cerchio chiamata)')


def uid():
    return json.load(io.open(SEGRETO, encoding='utf-8'))['uid']


def gettone():
    s = json.load(io.open(SEGRETO, encoding='utf-8'))
    dati = ('grant_type=refresh_token&refresh_token=' + s['rinnovo']).encode()
    req = urllib.request.Request('https://securetoken.googleapis.com/v1/token?key='
                                 + chiave(), data=dati, method='POST',
                                 headers={'Content-Type': 'application/x-www-form-urlencoded'})
    with urllib.request.urlopen(req, timeout=60) as r:
        return json.loads(r.read().decode('utf-8'))['id_token']


def chiama(porta, dati):
    url = f'https://{REGIONE}-{PROGETTO}.cloudfunctions.net/{porta}'
    stato, r = posta(url, {'data': dati}, gettone())
    esito = r.get('result', r)
    annota(f'{porta} {json.dumps(dati, ensure_ascii=False)} -> {stato} '
           f'{json.dumps(esito, ensure_ascii=False)[:240]}')
    return stato, esito


def pretendi_collaudo():
    """Il server deve gia' saperlo collaudo, o non si chiama il Cerchio."""
    s = io.open('functions/src/i_collaudi.ts', encoding='utf-8').read()
    if uid() not in s:
        raise SystemExit('l\'uid non e\' nel registro dei collaudi del server')
    # La prova che il deploy c'e': la funzione dei minuti, nata nello stesso
    # deploy del registro, risponde.
    stato, _ = posta(f'https://{REGIONE}-{PROGETTO}.cloudfunctions.net/iMinutiDelLive',
                     {'data': {}}, gettone())
    if stato == 404:
        raise SystemExit('il deploy dell\'ordine FD non c\'e\' ancora: niente Cerchio')


def main():
    cosa = sys.argv[1] if len(sys.argv) > 1 else ''
    if cosa == 'nasci':
        nasci()
    elif cosa == 'uid':
        print(uid())
    elif cosa == 'profilo':
        pretendi_collaudo()
        chiama('ilMioProfiloNelCerchio',
               {'quattordici': True, 'maggiorenne': True, 'segno': 'libra',
                'maestro': 'medora'})
        chiama('scegliIlNome', {'nome': NOME})
    elif cosa == 'legame':
        pretendi_collaudo()
        chiama('chiediIlLegame', {'codice': sys.argv[2]})
    elif cosa == 'presente':
        pretendi_collaudo()
        minuti = int(sys.argv[2]) if len(sys.argv) > 2 else 5
        for i in range(minuti):
            chiama('chiEOnline', {'arte': 'oroscopo', 'scheda': i == 0})
            time.sleep(60)
    elif cosa == 'esce':
        pretendi_collaudo()
        chiama('chiEOnline', {'esce': True})
    else:
        raise SystemExit(__doc__)


if __name__ == '__main__':
    main()
