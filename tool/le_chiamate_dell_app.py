"""Le chiamate dell'app al modello, minuto per minuto, da Cloud Monitoring.

Conta le richieste a firebasevertexai.googleapis.com (le chiamate che
l'app fa a Gemini tramite Firebase AI Logic; i banchi chiamano Vertex
direttamente e non entrano qui) fra due istanti UTC.

    python chiamate_app.py 2026-10-07T14:00:00Z 2026-10-07T15:00:00Z
"""
import json
import subprocess
import sys
import urllib.parse
import urllib.request

PROGETTO = 'esoteric-circle'


def gettone():
    return subprocess.run('gcloud auth print-access-token', shell=True,
                          capture_output=True, text=True).stdout.strip()


def serie(inizio, fine):
    filtro = ('metric.type="serviceruntime.googleapis.com/api/request_count" '
              'AND resource.type="consumed_api" '
              'AND resource.labels.service="firebasevertexai.googleapis.com"')
    q = {
        'filter': filtro,
        'interval.startTime': inizio,
        'interval.endTime': fine,
        'aggregation.alignmentPeriod': '60s',
        'aggregation.perSeriesAligner': 'ALIGN_SUM',
        'aggregation.crossSeriesReducer': 'REDUCE_SUM',
        'aggregation.groupByFields': ['resource.labels.method',
                                      'metric.labels.response_code'],
    }
    url = (f'https://monitoring.googleapis.com/v3/projects/{PROGETTO}/'
           f'timeSeries?' + urllib.parse.urlencode(q, doseq=True))
    req = urllib.request.Request(url, headers={
        'Authorization': 'Bearer ' + gettone()})
    with urllib.request.urlopen(req, timeout=60) as r:
        return json.load(r).get('timeSeries', [])


def main():
    inizio, fine = sys.argv[1], sys.argv[2]
    righe = {}
    for s in serie(inizio, fine):
        metodo = s['resource']['labels'].get('method', '?').split('.')[-1]
        codice = s['metric']['labels'].get('response_code', '?')
        for p in s.get('points', []):
            t = p['interval']['endTime'][:16]
            n = int(p['value'].get('int64Value', 0))
            if n:
                righe.setdefault(t, []).append(f'{metodo} {codice}: {n}')
    totale = 0
    for t in sorted(righe):
        print(t, '|', ', '.join(righe[t]))
        totale += sum(int(x.rsplit(': ', 1)[1]) for x in righe[t])
    print('TOTALE', totale)


main()
