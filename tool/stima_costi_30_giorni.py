# -*- coding: utf-8 -*-
"""Le quantita' dei 30 giorni dalle metriche di Google Cloud, in sola lettura.

Ordine extra del 2 ottobre 2026, la stima dei costi. Legge solo Cloud
Monitoring (timeSeries.list, metricDescriptors.list) con il token di gcloud:
non crea, non cambia e non cancella niente, e non legge documenti di
Firestore.

Il periodo: dal 2 settembre 2026 alle 00:00 al 2 ottobre 2026 alle 00:00 ora di
Roma (CEST, UTC+2), cioe' i 30 giorni interi fino al 1 ottobre compreso.

Uso, dalla radice del repository:
    python tool/stima_costi_30_giorni.py serie METRICA [PROGETTO] [ALLINEAMENTO] [RAGGRUPPA...]
    python tool/stima_costi_30_giorni.py metriche PREFISSO [PROGETTO]

ALLINEAMENTO: ALIGN_SUM (contatori e delta) oppure ALIGN_MEAN o ALIGN_MAX
(misure come lo spazio occupato). Il secchio e' l'intera finestra (vedi la
memoria sulle metriche: un secchio piu' corto legge solo la sua coda).
"""
from __future__ import annotations

import json
import subprocess
import sys
import urllib.parse
import urllib.request

INIZIO = '2026-09-01T22:00:00Z'
FINE = '2026-10-01T22:00:00Z'
SECONDI = 30 * 86400


def token() -> str:
    r = subprocess.run('gcloud auth print-access-token', shell=True,
                       capture_output=True, text=True)
    return r.stdout.strip()


TOK = token()


def get(url: str) -> dict:
    req = urllib.request.Request(url, headers={'Authorization': 'Bearer ' + TOK})
    try:
        with urllib.request.urlopen(req, timeout=120) as r:
            return json.loads(r.read().decode('utf-8'))
    except urllib.error.HTTPError as e:
        return {'errore': e.code, 'testo': e.read().decode('utf-8')[:300]}


def serie(metrica: str, progetto: str = 'esoteric-circle',
          allinea: str = 'ALIGN_SUM', raggruppa: list[str] | None = None,
          riduci: str = 'REDUCE_SUM', periodo: int = SECONDI,
          filtro_in_piu: str = '') -> list[tuple[dict, float]]:
    q = {
        'filter': f'metric.type = "{metrica}"' + filtro_in_piu,
        'interval.startTime': INIZIO,
        'interval.endTime': FINE,
        'aggregation.alignmentPeriod': f'{periodo}s',
        'aggregation.perSeriesAligner': allinea,
        'aggregation.crossSeriesReducer': riduci,
    }
    if raggruppa:
        q['aggregation.groupByFields'] = raggruppa
    url = (f'https://monitoring.googleapis.com/v3/projects/{progetto}/timeSeries?'
           + urllib.parse.urlencode(q, doseq=True))
    fuori = []
    while True:
        j = get(url)
        if 'errore' in j:
            return [({'errore': j['errore'], 'testo': j['testo']}, 0.0)]
        for s in j.get('timeSeries', []):
            etichette = {**s.get('metric', {}).get('labels', {}),
                         **s.get('resource', {}).get('labels', {})}
            totale = 0.0
            for p in s.get('points', []):
                v = p['value']
                x = v.get('doubleValue', v.get('int64Value'))
                if x is None and 'distributionValue' in v:
                    x = v['distributionValue'].get('count', 0)
                totale += float(x or 0)
            fuori.append(({k: etichette[k] for k in etichette
                           if not raggruppa or any(k in g for g in raggruppa)},
                          totale))
        t = j.get('nextPageToken')
        if not t:
            return fuori
        url = url.split('&pageToken=')[0] + '&pageToken=' + urllib.parse.quote(t)


def metriche(prefisso: str, progetto: str = 'esoteric-circle') -> list[str]:
    q = {'filter': f'metric.type = starts_with("{prefisso}")'}
    j = get(f'https://monitoring.googleapis.com/v3/projects/{progetto}/'
            'metricDescriptors?' + urllib.parse.urlencode(q))
    return [d['type'] + '  ' + d.get('metricKind', '') + ' ' + d.get('valueType', '')
            + ' ' + d.get('unit', '') for d in j.get('metricDescriptors', [])]


if __name__ == '__main__':
    if sys.argv[1] == 'metriche':
        for m in metriche(sys.argv[2], *(sys.argv[3:4] or [])):
            print(m)
    else:
        metrica = sys.argv[2]
        progetto = sys.argv[3] if len(sys.argv) > 3 else 'esoteric-circle'
        allinea = sys.argv[4] if len(sys.argv) > 4 else 'ALIGN_SUM'
        gruppi = sys.argv[5:]
        riduci = 'REDUCE_MEAN' if allinea in ('ALIGN_MEAN', 'ALIGN_MAX') else 'REDUCE_SUM'
        righe = serie(metrica, progetto, allinea, gruppi or None, riduci)
        for etichette, totale in sorted(righe, key=lambda x: -x[1]):
            print(f'{totale:>18,.2f}  {json.dumps(etichette, ensure_ascii=False)}')
