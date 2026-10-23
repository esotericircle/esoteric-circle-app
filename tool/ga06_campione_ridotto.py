"""Riduce un campione dei lettori ciechi (GA.06) a N responsi, per l'ultimo giro.

Uso: python tool/ga06_campione_ridotto.py <campione.json> <N> <uscita.json>

Sceglie fino a un terzo di domande a trabocchetto (se il campione ne ha) e il
resto a passo regolare fra gli altri, in modo che ogni tipo di domanda e ogni
forma di gettata o di stesa che il campione porta abbia la sua parte. Nessun
seme: lo stesso campione dà sempre la stessa scelta.
"""
import json
import sys

campione, n, uscita = sys.argv[1], int(sys.argv[2]), sys.argv[3]
dati = json.load(open(campione, encoding='utf-8'))
responsi = dati['responsi']


def trabocchetto(r):
    return 'trabocchetto' in str(r.get('ambitoDellaDomanda', ''))


trabocchetti = [r for r in responsi if trabocchetto(r)]
altri = [r for r in responsi if not trabocchetto(r)]
quanti_trab = min(len(trabocchetti), max(0, n // 3))
quanti_altri = n - quanti_trab


def a_passo(lista, k):
    if k <= 0 or not lista:
        return []
    if k >= len(lista):
        return list(lista)
    passo = len(lista) / k
    return [lista[int(i * passo)] for i in range(k)]


# L'Oroscopo non ha domande: si sceglie per tradizione e per periodo (tre
# tradizioni per quattro periodi) e, dentro ogni coppia, si fa girare il
# dominio, cosi' il campione porta tutte e tre le tradizioni, tutti i periodi
# (il "Da dove viene" cambia per periodo) e tutti e quattro i domini.
if responsi and 'senzaDomanda' in responsi[0]:
    tradizioni = sorted({r['senzaDomanda']['tradizione'] for r in responsi})
    periodi = ['giorno', 'settimana', 'mese', 'anno']
    domini = sorted({r['senzaDomanda']['dominio'] for r in responsi})
    scelti = []
    k = 0
    for t in tradizioni:
        for per in periodi:
            dom = domini[k % len(domini)]
            k += 1
            candidati = [r for r in responsi
                         if r['senzaDomanda']['tradizione'] == t
                         and r['senzaDomanda']['periodo'] == per
                         and r['senzaDomanda']['dominio'] == dom]
            if not candidati:
                candidati = [r for r in responsi
                             if r['senzaDomanda']['tradizione'] == t
                             and r['senzaDomanda']['periodo'] == per]
            if candidati:
                scelti.append(candidati[0])
    scelti = scelti[:n]
else:
    scelti = a_passo(trabocchetti, quanti_trab) + a_passo(altri, quanti_altri)
scelti.sort(key=lambda r: responsi.index(r))
dati['responsi'] = scelti
dati['quanti'] = len(scelti)
json.dump(dati, open(uscita, 'w', encoding='utf-8', newline='\n'), ensure_ascii=False, indent=1)
print(campione, '->', uscita, len(scelti), 'responsi, di cui trabocchetti', sum(1 for r in scelti if trabocchetto(r)))
