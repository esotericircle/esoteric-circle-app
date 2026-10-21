"""Prepara la seconda prova dei lettori ciechi (GA.06): lo scambio dei simboli.

Uso: python tool/ga06_prepara_gli_scambi.py <arte> <campione.json> <uscita_dir> [seme]
Scrive scambio3_<arte>.json (per il lettore, solo testo libero) e chiave3_<arte>.json.
Meta' delle schede, scelte col seme, ricevono i simboli di un'altra scheda del gruppo
scambiato (un giro chiuso, nessuna resta con i suoi). Oroscopo: si scambiano periodo,
dominio e fascia fra schede con dati diversi. Oracolo: si scambiano gli angeli, la
domanda resta col suo testo. Rune: si scambiano le pietre fra gettate della
stessa forma, la domanda resta col suo testo. Al lettore arrivano solo risposta, cosa fare e
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
    if arte == 'rune':
        return [{k: v for k, v in x.items() if k in ('posizione', 'runa', 'verso', 'parolaChiave', 'significato')} for x in r['simboli']]
    return [{k: v for k, v in x.items() if k in ('ruolo', 'posizione', 'angelo', 'coro', 'dominioDelCoro', 'coperta')} for x in r['simboli']]

def gruppo(r):
    # Le Rune si scambiano solo fra gettate della stessa forma, perche' il
    # numero delle pietre non tradisca lo scambio.
    return r.get('gettata', '') if arte == 'rune' else ''

n = len(d)
indici = list(range(n))
rnd.shuffle(indici)
scelti = sorted(indici[: n // 2])
# un giro chiuso per gruppo fra gli scelti, rimescolato finche' ogni scheda riceve simboli diversi dai suoi
dest = {}
for g in sorted({gruppo(d[i]) for i in scelti}):
    membri = [i for i in scelti if gruppo(d[i]) == g]
    if len(membri) < 2:
        continue
    for _ in range(1000):
        giro = membri[:]
        rnd.shuffle(giro)
        prova = {giro[i]: giro[(i + 1) % len(giro)] for i in range(len(giro))}
        if all(json.dumps(simboli(d[a]), sort_keys=True) != json.dumps(simboli(d[b]), sort_keys=True) for a, b in prova.items()):
            dest.update(prova)
            break
    else:
        sys.exit('nessun giro valido per ' + g)

schede, chiave = [], []
for i, r in enumerate(d):
    sorgente = dest.get(i, i)
    s = {'scheda': i + 1}
    if arte in ('oracolo', 'rune'):
        s['domanda'] = r['domanda']
    if arte == 'rune':
        s['gettata'] = r['gettata']
    s['dati' if arte == 'oroscopo' else 'simboli'] = simboli(d[sorgente])
    s['testo'] = testo(r)
    schede.append(s)
    chiave.append({'scheda': i + 1, 'id': r['id'], 'scambiato': sorgente != i, 'simboliDi': d[sorgente]['id']})
json.dump({'schede': schede}, open(f'{uscita}/scambio3_{arte}.json', 'w', encoding='utf-8', newline='\n'), ensure_ascii=False, indent=1)
json.dump(chiave, open(f'{uscita}/chiave3_{arte}.json', 'w', encoding='utf-8', newline='\n'), ensure_ascii=False, indent=1)
print(arte, 'schede', n, 'scambiate', len(dest))
