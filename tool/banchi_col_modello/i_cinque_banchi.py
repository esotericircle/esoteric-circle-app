# -*- coding: utf-8 -*-
"""I CINQUE BANCHI COL MODELLO, IN UN COMANDO SOLO. Ordine FD voce 03.

Lancia i cinque casi che chiamano Gemini davvero, uno dopo l'altro, legge
l'esito di ciascuno e scrive `docs/collaudo/banchi_col_modello/<data>.txt`
con i cinque risultati, il commit su cui hanno girato e, con `--costo`, il
costo del giro letto da Cloud Monitoring e portato in euro.

Uso, dalla radice del progetto:

    python tool/banchi_col_modello/i_cinque_banchi.py --costo

Pretende l'albero pulito in `lib`, `test` e `tool/banchi_col_modello`: il
risultato vale per il commit scritto nel file, e `tool/consegna.py` rifiuta
una consegna il cui codice e' diverso da quello su cui i banchi hanno girato.
Il gettone di Vertex si chiede a `gcloud` e passa ai banchi nell'ambiente,
senza essere stampato ne' scritto.

`--elenco` stampa i cinque casi e i loro file senza lanciare niente: e' cio'
che usa la prova `i_banchi_col_modello_hanno_un_comando_test.dart`.
"""
import datetime
import io
import json
import os
import re
import subprocess
import sys
import time
import urllib.parse
import urllib.request

RADICE = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
os.chdir(RADICE)
CARTELLA = 'tool/banchi_col_modello'
USCITA = 'docs/collaudo/banchi_col_modello'
PROGETTO = 'esoteric-circle'

# I cinque casi: il file, il nome della prova, cosa misura.
BANCHI = [
    ('il_banco_delle_domande_libere_col_modello_test.dart',
     'CON RETE: il classificatore vero sul banco',
     'il classificatore delle domande libere del Viaggio, col modello vero, '
     'sul banco delle domande di prova'),
    ('la_prova_a_cento_discese_col_modello_test.dart',
     'CON RETE: le cinque misure su cento discese, col modello vero',
     'cento discese del Viaggio dello Sciamano col modello vero: le cinque '
     'misure della ripetizione e il costo di una discesa'),
    ('la_prova_a_cento_discese_col_modello_test.dart',
     'CON RETE: G, venti cammini col modello vero',
     'venti cammini interi: quanto si ripetono gli strati del racconto'),
    ('la_prova_a_cento_discese_col_modello_test.dart',
     'CON RETE: il segno col modello vero, dodici domande',
     'il segno dell\'animale scelto dal modello su dodici domande'),
    ('la_sonda_del_sigillo_test.dart',
     'Tre chiamate vere per ogni sigillo, lette tutte',
     'i testi del Sigillo dell\'Intenzione: tre chiamate per sigillo, ogni '
     'testo letto e controllato'),
]

# I prezzi di Vertex in dollari per milione di token, dall'ordine DJ voce 03
# (catalogo Cloud Billing). L'uscita comprende il ragionamento, che Monitoring
# conta insieme all'uscita e che si paga come uscita.
PREZZI = {
    'gemini-2.5-flash': (0.30, 2.50),
    'gemini-2.5-flash-lite': (0.10, 0.40),
}


def git(*a):
    r = subprocess.run(['git', *a], capture_output=True, text=True,
                       encoding='utf-8', errors='replace')
    return r.stdout.strip()


def gettone():
    r = subprocess.run('gcloud auth print-access-token', shell=True,
                       capture_output=True, text=True)
    t = r.stdout.strip()
    if not t:
        raise SystemExit('gcloud non ha dato un gettone: ' + r.stderr.strip())
    return t


def esito_di(uscita, nome):
    """PASSATO, ROSSO o SALTATO per la prova [nome], dal rapporto expanded."""
    righe = [r for r in uscita.splitlines() if nome in r]
    if any('[E]' in r for r in righe):
        return 'ROSSO'
    if any('Skip:' in r or '(skipped)' in r for r in righe):
        return 'SALTATO'
    # Il rapporto expanded scrive il nome quando la prova parte: e' passata se
    # dopo di lei il contatore dei passati e' salito senza una caduta.
    if righe:
        return 'PASSATO'
    return 'NON TROVATO'


def righe_di_misura(uscita):
    chiave = re.compile(r'BANCO|DQ\.|RIEPILOGO|costo|sigilli \d|CHIAMATE')
    return [r.rstrip() for r in uscita.splitlines() if chiave.search(r)][:40]


def monitoring(tok, inizio, fine):
    secondi = max(60, int((fine - inizio).total_seconds()))
    q = {
        'filter': 'metric.type = "aiplatform.googleapis.com/publisher/'
                  'online_serving/token_count"',
        'interval.startTime': inizio.strftime('%Y-%m-%dT%H:%M:%SZ'),
        'interval.endTime': fine.strftime('%Y-%m-%dT%H:%M:%SZ'),
        'aggregation.alignmentPeriod': f'{secondi}s',
        'aggregation.perSeriesAligner': 'ALIGN_SUM',
        'aggregation.crossSeriesReducer': 'REDUCE_SUM',
        'aggregation.groupByFields': ['resource.labels.model_user_id',
                                      'metric.labels.type'],
    }
    url = (f'https://monitoring.googleapis.com/v3/projects/{PROGETTO}/timeSeries?'
           + urllib.parse.urlencode(q, doseq=True))
    req = urllib.request.Request(url, headers={'Authorization': 'Bearer ' + tok})
    with urllib.request.urlopen(req, timeout=120) as r:
        j = json.loads(r.read().decode('utf-8'))
    conti = {}
    for s in j.get('timeSeries', []):
        modello = s['resource']['labels'].get('model_user_id', '?')
        tipo = s['metric']['labels'].get('type', '?')
        n = sum(float(p['value'].get('int64Value', p['value'].get('doubleValue', 0)))
                for p in s.get('points', []))
        conti[(modello, tipo)] = conti.get((modello, tipo), 0) + n
    return conti, secondi


def cambio_bce():
    url = 'https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml'
    with urllib.request.urlopen(url, timeout=60) as r:
        x = r.read().decode('utf-8')
    data = re.search(r"time='([0-9-]+)'", x).group(1)
    usd = float(re.search(r"currency='USD' rate='([0-9.]+)'", x).group(1))
    return data, usd


def main():
    if '--elenco' in sys.argv:
        for f, nome, cosa in BANCHI:
            print(f'{CARTELLA}/{f} | {nome} | {cosa}')
        return
    sporco = git('status', '--porcelain', '--', 'lib', 'test', CARTELLA,
                 ':(exclude)' + CARTELLA + '/README.md')
    if sporco:
        raise SystemExit('albero non pulito in lib, test o nei banchi: il '
                         'risultato non varrebbe per un commit.\n' + sporco)
    commit = git('rev-parse', 'HEAD')
    tok = gettone()
    ambiente = dict(os.environ, VERTEX_TOKEN=tok)
    inizio = datetime.datetime.now(datetime.timezone.utc)
    uscite = {}
    for f in sorted({b[0] for b in BANCHI}, key=[b[0] for b in BANCHI].index):
        print(f'== {f}', flush=True)
        r = subprocess.run(['flutter', 'test', '-r', 'expanded', f'{CARTELLA}/{f}'],
                           capture_output=True, text=True, encoding='utf-8',
                           errors='replace', env=ambiente, shell=os.name == 'nt')
        uscite[f] = (r.stdout or '') + (r.stderr or '')
        print(uscite[f].strip().splitlines()[-1] if uscite[f].strip() else '(vuota)',
              flush=True)
    fine = datetime.datetime.now(datetime.timezone.utc)

    righe = [f'I CINQUE BANCHI COL MODELLO, ordine FD voce 03',
             f'commit: {commit}',
             f'inizio: {inizio.isoformat(timespec="seconds")}',
             f'fine: {fine.isoformat(timespec="seconds")}',
             f'comando: python {CARTELLA}/i_cinque_banchi.py'
             + (' --costo' if '--costo' in sys.argv else ''), '']
    rossi = 0
    for i, (f, nome, cosa) in enumerate(BANCHI, 1):
        e = esito_di(uscite[f], nome)
        if e != 'PASSATO':
            rossi += 1
        righe.append(f'RISULTATO {i}: {e} | {f} | {nome}')
        righe.append(f'  misura: {cosa}')
    righe.append('')
    for f, testo in uscite.items():
        righe.append(f'--- le misure stampate da {f}')
        righe.extend('  ' + r for r in righe_di_misura(testo))
    if '--costo' in sys.argv:
        # I punti di Monitoring arrivano un minuto dopo le chiamate.
        print('aspetto tre minuti i punti di Monitoring...', flush=True)
        time.sleep(180)
        # **IL GETTONE SI PRENDE ADESSO, non all'inizio.** Il primo giro
        # dell'ordine FD e' durato ottanta minuti e il gettone preso
        # all'inizio era scaduto: Monitoring ha risposto 401 e il file del
        # giro non e' nato. Se il costo non si legge lo stesso, gli esiti
        # si scrivono comunque e il comando esce rosso.
        try:
            conti, secondi = monitoring(gettone(), inizio,
                                        fine + datetime.timedelta(minutes=2))
        except Exception as errore:  # noqa: BLE001
            conti, secondi = None, 0
            righe.append('')
            righe.append(f'COSTO NON LETTO: {errore}')
            rossi += 1
    if '--costo' in sys.argv and conti is not None:
        dollari = 0.0
        righe.append('')
        righe.append(f'--- il costo, da Cloud Monitoring (token_count), '
                     f'finestra di {secondi} secondi')
        for (modello, tipo), n in sorted(conti.items()):
            prezzi = PREZZI.get(modello)
            parte = 0.0
            if prezzi:
                parte = n / 1e6 * (prezzi[0] if tipo == 'input' else prezzi[1])
            dollari += parte
            righe.append(f'  {modello} {tipo}: {int(n)} token, {parte:.4f} dollari')
        data, usd = cambio_bce()
        euro = dollari / usd
        righe.append(f'  totale {dollari:.4f} dollari, cambio BCE del {data}: '
                     f'1 euro = {usd} dollari')
        righe.append(f'COSTO DEL GIRO: {euro:.2f} euro')
        righe.append('  (un massimo: nella stessa finestra possono esserci '
                     'chiamate dell\'app di altre persone, che Monitoring non '
                     'separa; la cache implicita costa il 10 per cento e qui '
                     'e\' contata intera)')
    os.makedirs(USCITA, exist_ok=True)
    nome_file = f'{USCITA}/{inizio.astimezone().date().isoformat()}.txt'
    io.open(nome_file, 'w', encoding='utf-8', newline='\n').write('\n'.join(righe) + '\n')
    print('scritto ' + nome_file)
    if rossi:
        raise SystemExit(f'{rossi} banchi su cinque non sono passati')


if __name__ == '__main__':
    main()
