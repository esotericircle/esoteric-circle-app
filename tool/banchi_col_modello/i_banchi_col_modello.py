# -*- coding: utf-8 -*-
"""I BANCHI COL MODELLO, IN UN COMANDO SOLO. Ordine FD voce 03, e dall'ordine
FE voce 18 i sei percorsi del consulto: undici casi.

Lancia i casi che chiamano Gemini davvero, uno dopo l'altro, legge
l'esito di ciascuno e scrive `docs/collaudo/banchi_col_modello/<data>.txt`
con un risultato per caso, il commit su cui hanno girato e, con `--costo`, il
costo del giro letto da Cloud Monitoring e portato in euro.

Uso, dalla radice del progetto:

    python tool/banchi_col_modello/i_banchi_col_modello.py --costo

Pretende l'albero pulito in `lib`, `test` e `tool/banchi_col_modello`: il
risultato vale per il commit scritto nel file, e `tool/consegna.py` rifiuta
una consegna il cui codice e' diverso da quello su cui i banchi hanno girato.
Il gettone di Vertex si chiede a `gcloud` e passa ai banchi nell'ambiente,
senza essere stampato ne' scritto.

`--elenco` stampa i casi e i loro file senza lanciare niente: e' cio'
che usa la prova `i_banchi_col_modello_hanno_un_comando_test.dart`.

`--rifai-i-rossi <giro.txt>` rifa' SOLO i casi rossi di quel giro, sullo
stesso commit, ciascuno per nome, e scrive un giro completo: gli esiti
passati del giro vecchio e quelli nuovi dei casi rifatti, con la riga che
dice quali sono rifatti e da quale giro. Nasce il 10 ottobre 2026, ordine FH:
un caso del consulto e' caduto per l'oscillazione del modello (70 per cento
contro 80, dove l'8 ottobre aveva fatto 100 e 90) e rifare il giro intero
costava 3,65 euro e 80 minuti; il fondatore ha scelto di rifare solo il caso
caduto. Non sovrascrive mai un giro che esiste gia'.
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

# I casi: il file, il nome della prova, cosa misura. Il comando si chiamava
# `i_cinque_banchi.py` fino all'ordine FE, che ne ha aggiunti sei.
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
    # Ordine FE voci 16-18: i sei percorsi del consulto, col giudice della
    # coerenza.
    ('il_filo_del_consulto_col_modello_test.dart',
     'CON RETE: FE.16 A, tre domande di fila allo stesso Maestro sullo stesso tema',
     'percorso A del filo del consulto: zero contraddizioni e nove risposte '
     'su dieci che portano avanti il punto'),
    ('il_filo_del_consulto_col_modello_test.dart',
     'CON RETE: FE.16 B, la stessa domanda a Medora, poi a Caligo, poi ad Aura',
     'percorso B: il secondo e il terzo Maestro ricevono la scheda, la '
     'portano avanti e nominano chi ha parlato prima'),
    ('il_filo_del_consulto_col_modello_test.dart',
     'CON RETE: FE.16 C, la persona riprende la frase che il Maestro le ha suggerito',
     'percorso C: la frase suggerita ripresa vale come continuazione'),
    ('il_filo_del_consulto_col_modello_test.dart',
     'CON RETE: FE.16 D, una domanda, un tema diverso, poi il ritorno al primo tema',
     'percorso D: tornando al primo tema il Maestro riprende il suo parere'),
    ('il_filo_del_consulto_col_modello_test.dart',
     'CON RETE: FE.16 E, il consulto comincia scritto e continua a voce sullo stesso tema',
     'percorso E: dallo scritto alla voce il parere resta lo stesso'),
    ('il_filo_del_consulto_col_modello_test.dart',
     'CON RETE: FE.16 F, il consulto si interrompe e riprende dopo dieci minuti',
     'percorso F: dopo dieci minuti il Maestro ritrova il suo filo'),
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
    # Le prove stampano le loro misure in righe che cominciano con
    # "=== ORDINE ..." o "ORDINE ...", seguite da "accettati 11 su 12, ...":
    # il primo giro dell'ordine FD le perdeva tutte.
    chiave = re.compile(r'ORDINE |BANCO|DQ\.|RIEPILOGO|costo|accettati|'
                        r'sigilli \d|CHIAMATE')
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
    # I CASI ROSSI DI UN GIRO, da rifare da soli (vedi la testa del file).
    vecchio = None
    da_rifare = set()
    if '--rifai-i-rossi' in sys.argv:
        i = sys.argv.index('--rifai-i-rossi')
        if i + 1 >= len(sys.argv):
            raise SystemExit('--rifai-i-rossi vuole il file del giro')
        vecchio = sys.argv[i + 1]
        testo_vecchio = io.open(vecchio, encoding='utf-8').read()
        c = re.search(r'^commit: ([0-9a-f]{40})$', testo_vecchio, re.M)
        if not c:
            raise SystemExit('il giro ' + vecchio + ' non dice il suo commit')
        if c.group(1) != commit:
            # Lo stesso codice si misura come lo misura la consegna: i soli
            # file che i banchi raggiungono, senza i commenti.
            sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
            import consegna
            diversi = [p for p in consegna.i_file_dei_banchi() if p.endswith('.dart')
                       and consegna._senza_commenti(consegna._alla_revisione(c.group(1), p))
                       != consegna._senza_commenti(consegna._alla_revisione('HEAD', p))]
            if diversi:
                raise SystemExit('il giro ' + vecchio + ' e\' stato fatto su un '
                                 'codice diverso: i casi rossi si rifanno solo '
                                 'sullo stesso codice. Diversi: ' + ', '.join(diversi))
        esiti_vecchi = dict(re.findall(r'^RISULTATO (\d+): (\S+)', testo_vecchio,
                                       re.M))
        if len(esiti_vecchi) != len(BANCHI):
            raise SystemExit('il giro ' + vecchio + ' non porta tutti i casi')
        da_rifare = {int(k) for k, v in esiti_vecchi.items() if v != 'PASSATO'}
        if not da_rifare:
            raise SystemExit('il giro ' + vecchio + ' non ha casi rossi')
    tok = gettone()
    ambiente = dict(os.environ, VERTEX_TOKEN=tok)
    inizio = datetime.datetime.now(datetime.timezone.utc)
    uscite = {}
    if vecchio is None:
        for f in sorted({b[0] for b in BANCHI}, key=[b[0] for b in BANCHI].index):
            print(f'== {f}', flush=True)
            r = subprocess.run(['flutter', 'test', '-r', 'expanded', f'{CARTELLA}/{f}'],
                               capture_output=True, text=True, encoding='utf-8',
                               errors='replace', env=ambiente, shell=os.name == 'nt')
            uscite[f] = (r.stdout or '') + (r.stderr or '')
            print(uscite[f].strip().splitlines()[-1] if uscite[f].strip() else '(vuota)',
                  flush=True)
    else:
        for n in sorted(da_rifare):
            f, nome, _ = BANCHI[n - 1]
            print(f'== rifaccio il caso {n}: {f} | {nome}', flush=True)
            r = subprocess.run(['flutter', 'test', '-r', 'expanded',
                                '--plain-name', nome, f'{CARTELLA}/{f}'],
                               capture_output=True, text=True, encoding='utf-8',
                               errors='replace', env=ambiente, shell=os.name == 'nt')
            uscite[f] = uscite.get(f, '') + (r.stdout or '') + (r.stderr or '')
            print(uscite[f].strip().splitlines()[-1] if uscite[f].strip() else '(vuota)',
                  flush=True)
    fine = datetime.datetime.now(datetime.timezone.utc)

    righe = [f'I BANCHI COL MODELLO, ordine FD voce 03 e ordine FE voce 18',
             f'commit: {commit}',
             f'inizio: {inizio.isoformat(timespec="seconds")}',
             f'fine: {fine.isoformat(timespec="seconds")}',
             f'comando: python {CARTELLA}/i_banchi_col_modello.py'
             + (' --costo' if '--costo' in sys.argv else '')
             + (f' --rifai-i-rossi {vecchio}' if vecchio else ''), '']
    if vecchio:
        righe.insert(-1, 'rifatti: ' + ', '.join(f'RISULTATO {n}' for n in
                                                 sorted(da_rifare))
                     + f' dal giro {os.path.basename(vecchio)}; gli altri '
                     'esiti sono quelli di quel giro, sullo stesso commit')
    rossi = 0
    for i, (f, nome, cosa) in enumerate(BANCHI, 1):
        if vecchio and i not in da_rifare:
            e = esiti_vecchi[str(i)]
        else:
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
    if os.path.exists(nome_file):
        # **UN GIRO NON SI SOVRASCRIVE.** Il giro dell'8 ottobre sera ne aveva
        # cancellato uno della mattina.
        raise SystemExit(nome_file + ' esiste gia\': rinominalo prima di '
                         'un giro nuovo, con un nome che ordini prima')
    io.open(nome_file, 'w', encoding='utf-8', newline='\n').write('\n'.join(righe) + '\n')
    print('scritto ' + nome_file)
    # **L'USCITA INTERA SI TIENE.** Nel giro dell'ordine FD un banco e'
    # caduto e il motivo (un 429 di Vertex) non si poteva leggere: l'uscita
    # restava in memoria. Si tengono le righe che non sono il contatore.
    contatore = re.compile(r'^\d\d:\d\d \+\d+')
    # Non .txt: la consegna e la prova prendono l'ultimo .txt della cartella
    # come il giro; non .log, che git ignora.
    uscite_file = nome_file[:-len('.txt')] + '.uscite'
    with io.open(uscite_file, 'w', encoding='utf-8', newline='\n') as u:
        for f, testo in uscite.items():
            u.write(f'=== {f}\n')
            for r in testo.splitlines():
                if not contatore.match(r):
                    u.write(r.rstrip() + '\n')
    print('scritto ' + uscite_file)
    if rossi:
        raise SystemExit(f'{rossi} banchi su {len(BANCHI)} non sono passati')


if __name__ == '__main__':
    main()
