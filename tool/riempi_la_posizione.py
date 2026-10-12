"""RIEMPIE UNA POSIZIONE DEL CORPUS DEI TAROCCHI, testo per testo.

Ordine FM, 12 ottobre 2026: il corpus posizionale passa a Code. Questo
strumento non reinventa i controlli: usa quelli di
`tool/genera_carte_nella_posizione.py` (controlla_testo, il tu dell'ordine FM
voce 04, la somiglianza di Jaccard, le prime parole) su ogni testo prima di
scriverlo nel file della fonte, e scrive SOLO i testi che passano. Gli altri
tornano indietro col loro difetto, cosi' chi scrive li rifa' subito invece di
scoprirli alla fine.

Uso:
    python tool/riempi_la_posizione.py <file> <testi.json> [--prova]

<file> e' il nome del file della fonte senza .md (passato, se_stesso,
registri...). <testi.json> e' un elenco di oggetti
{"carta": "Il Matto", "verso": "dritta", "chiave": "2", "testo": "..."}
dove la chiave e' 1, 2 o 3 per le posizioni e amore, lavoro o vita per i
registri. Con --prova controlla e non scrive.

I registri non si rivolgono alla persona: dicono di che cosa parla la carta
in un ambito. Per loro valgono gli stessi controlli tranne il tu e la
lunghezza delle posizioni, che per un registro e' fra 60 e 220 caratteri.
"""
import importlib.util
import json
import os
import re
import sys

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
_spec = importlib.util.spec_from_file_location(
    'genera', os.path.join(RADICE, 'tool', 'genera_carte_nella_posizione.py'))
g = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(g)

LUNGHEZZA_DEL_REGISTRO = (60, 220)


def percorso(file):
    return os.path.join(g.FONTE, file + '.md')


def chiavi_di(file):
    return g.GRUPPI if file == 'registri' else g.VARIANTI


def leggi_tutto(carte):
    """{file: {(carta, verso): {chiave: testo}}} di tutte le posizioni."""
    tutto = {}
    for _, file, _ in g.POSIZIONI:
        tutto[file] = g.leggi_file(percorso(file), g.VARIANTI, carte)
    tutto['registri'] = g.leggi_file(percorso('registri'), g.GRUPPI, carte)
    return tutto


def difetti(file, carta, verso, chiave, testo, tutto):
    dove = '%s, %s, %s, %s' % (file, carta, verso, chiave)
    colpe = []
    if file == 'registri':
        lo, hi = LUNGHEZZA_DEL_REGISTRO
        for c in g.controlla_testo(dove, testo, carta):
            if 'col tu' in c or 'lunghezza' in c:
                continue
            colpe.append(c)
        if not lo <= len(testo) <= hi:
            colpe.append('%s: lunghezza %d fuori da %d-%d' % (
                dove, len(testo), lo, hi))
    else:
        colpe += g.controlla_testo(dove, testo, carta)
    p = g.parole(testo)
    # Nella stessa carta-verso: le altre chiavi del file, e le altre
    # posizioni (lo strumento confronta le posizioni della stessa carta).
    for f, dati in tutto.items():
        for k, t in dati.get((carta, verso), {}).items():
            if not t or (f == file and k == chiave):
                continue
            if f == 'registri' and file != 'registri':
                continue
            if t == testo:
                colpe.append('%s: doppione di %s, %s' % (dove, f, k))
            s = g.jaccard(p, g.parole(t))
            if s > g.JACCARD:
                colpe.append('%s: somiglianza %.2f con %s, %s' % (
                    dove, s, f, k))
    # Nella stessa posizione, con le altre carte.
    for (c, v), d in tutto[file].items():
        if (c, v) == (carta, verso):
            continue
        for k, t in d.items():
            if t and g.jaccard(p, g.parole(t)) > g.JACCARD:
                colpe.append('%s: somiglianza %.2f con %s, %s, %s' % (
                    dove, g.jaccard(p, g.parole(t)), c, v, k))
    # Le prime parole delle tre varianti, diverse.
    if file != 'registri':
        prima = testo.split()[0].lower().strip(",.'")
        for k, t in tutto[file].get((carta, verso), {}).items():
            if t and k != chiave and t.split()[0].lower().strip(",.'") == prima:
                colpe.append('%s: comincia con "%s" come la variante %s' % (
                    dove, prima, k))
    return colpe


def scrivi_nel_file(file, nuovi):
    """Mette i testi nelle righe della fonte, al loro posto."""
    righe = open(percorso(file), encoding='utf-8', newline='').read().split('\n')
    carta = verso = None
    for i, r in enumerate(righe):
        nuda = r.rstrip('\r')
        m = re.match(r'^## (.+)$', nuda)
        if m:
            carta = m.group(1).strip()
            continue
        m = re.match(r'^### (dritta|capovolta)$', nuda)
        if m:
            verso = m.group(1)
            continue
        m = re.match(r'^- ([a-z0-9]+):', nuda)
        if m and (carta, verso, m.group(1)) in nuovi:
            fine = '\r' if r.endswith('\r') else ''
            righe[i] = '- %s: %s%s' % (m.group(1),
                                       nuovi[(carta, verso, m.group(1))], fine)
    with open(percorso(file), 'w', encoding='utf-8', newline='') as h:
        h.write('\n'.join(righe))


def main():
    file, sorgente = sys.argv[1], sys.argv[2]
    prova = '--prova' in sys.argv
    carte = g.carte_del_mazzo()
    tutto = leggi_tutto(carte)
    testi = json.load(open(sorgente, encoding='utf-8'))
    buoni, scartati = {}, []
    for x in testi:
        carta, verso, chiave = x['carta'], x['verso'], str(x['chiave'])
        testo = ' '.join(x['testo'].split())
        if carta not in carte or verso not in g.VERSI or \
                chiave not in chiavi_di(file):
            scartati.append('%s, %s, %s: carta, verso o chiave sconosciuti' %
                            (carta, verso, chiave))
            continue
        colpe = difetti(file, carta, verso, chiave, testo, tutto)
        if colpe:
            scartati += colpe
            continue
        buoni[(carta, verso, chiave)] = testo
        # Il testo accettato conta subito per i successivi dello stesso giro.
        tutto[file].setdefault((carta, verso), {})[chiave] = testo
    if buoni and not prova:
        scrivi_nel_file(file, buoni)
    print('accettati %d, scartati %d%s' % (
        len(buoni), len(testi) - len(buoni), ' (prova, niente scritto)'
        if prova else ''))
    for c in scartati:
        print('  ' + c)
    vuote = sum(1 for d in leggi_tutto(carte)[file].values()
                for t in d.values() if not t)
    print('righe ancora vuote in %s: %d' % (file, vuote))


if __name__ == '__main__':
    main()
