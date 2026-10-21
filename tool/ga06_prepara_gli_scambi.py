"""Prepara la seconda prova dei lettori ciechi (GA.06): lo scambio dei simboli.

Uso: python tool/ga06_prepara_gli_scambi.py <arte> <campione.json> <uscita_dir> [seme]
Scrive scambio3_<arte>.json (per il lettore, solo testo libero) e chiave3_<arte>.json.
Meta' delle schede, scelte col seme, ricevono i simboli di un'altra scheda del gruppo
scambiato (un giro chiuso, nessuna resta con i suoi). Oroscopo: si scambiano periodo,
dominio e fascia fra schede con dati diversi. Oracolo: si scambiano gli angeli, la
domanda resta col suo testo. Al lettore arrivano solo risposta, cosa fare e
approfondimento: titolo, rito e da dove viene nominano i simboli e li direbbero.
"""
import json, random, sys

arte, campione, uscita = sys.argv[1], sys.argv[2], sys.argv[3]
seme = int(sys.argv[4]) if len(sys.argv) > 4 else 2110
d = json.load(open(campione, encoding='utf-8'))['responsi']
rnd = random.Random(seme)

def testo(r):
    p = r['responso']
    t = {'risposta': p.get('risposta', ''), 'cosaFare': p.get('cosaFare', '')}
    if p.get('approfondimento'):
        t['approfondimento'] = p['approfondimento']
    return t

def simboli(r):
    if arte == 'oroscopo':
        s = r['senzaDomanda']
        return {'periodo': s['periodo'], 'dominio': s['dominio'], 'fascia': s['fascia']}
    return [{k: v for k, v in x.items() if k in ('ruolo', 'posizione', 'angelo', 'coro', 'dominioDelCoro', 'coperta')} for x in r['simboli']]

n = len(d)
indici = list(range(n))
rnd.shuffle(indici)
scelti = sorted(indici[: n // 2])
# un giro chiuso fra gli scelti, rimescolato finche' ogni scheda riceve simboli diversi dai suoi
for _ in range(1000):
    giro = scelti[:]
    rnd.shuffle(giro)
    dest = {giro[i]: giro[(i + 1) % len(giro)] for i in range(len(giro))}
    if all(json.dumps(simboli(d[a]), sort_keys=True) != json.dumps(simboli(d[b]), sort_keys=True) for a, b in dest.items()):
        break
else:
    sys.exit('nessun giro valido')

schede, chiave = [], []
for i, r in enumerate(d):
    sorgente = dest.get(i, i)
    s = {'scheda': i + 1}
    if arte == 'oracolo':
        s['domanda'] = r['domanda']
    s['simboli' if arte == 'oracolo' else 'dati'] = simboli(d[sorgente])
    s['testo'] = testo(r)
    schede.append(s)
    chiave.append({'scheda': i + 1, 'id': r['id'], 'scambiato': sorgente != i, 'simboliDi': d[sorgente]['id']})
json.dump({'schede': schede}, open(f'{uscita}/scambio3_{arte}.json', 'w', encoding='utf-8', newline='\n'), ensure_ascii=False, indent=1)
json.dump(chiave, open(f'{uscita}/chiave3_{arte}.json', 'w', encoding='utf-8', newline='\n'), ensure_ascii=False, indent=1)
print(arte, 'schede', n, 'scambiate', len(dest))
