"""LA REGOLA A DELL'ORDINE FE: ogni prova nuova vista rossa sul suo difetto.

Stessa forma del banco dell'ordine FC (`gli_innesti_dell_ordine_fd.py`): per
ogni innesto la copia del file, il difetto messo a mano, il controllo che
l'innesto sia ENTRATO, la prova fatta girare, l'esito letto, il nome della
prova che DEVE cadere cercato fra le cadute, il file rimesso dalla copia e
confrontato al byte.

Uso: PYTHONIOENCODING=utf-8 python tool/gli_innesti_dell_ordine_fe.py [sigla ...]
L'esito si scrive in docs/collaudo/FE/regola_a_fe.txt (in coda).
"""
import io
import os
import shutil
import subprocess
import sys

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(RADICE)


CIELO = 'flutter test test/il_cielo_non_ferma_l_interfaccia_test.dart -r expanded'
FUNZIONI = 'lib/services/ai/le_funzioni_del_cielo.dart'

# sigla, voce, file, vecchio, nuovo, comando, la prova che deve cadere
INNESTI = [
    # FE.01, il cielo calcolato sul filo dell'interfaccia.
    ('A1', 'FE.01', FUNZIONI,
     '        callable: periodoFuoriDalFilo,',
     '        callable: periodo,',
     CIELO, 'lascia libero il filo'),
    ('A2', 'FE.01', FUNZIONI,
     '    return fuoriDalFilo(() => _cieloDeiGiorni(giorni, carta));',
     '    return _cieloDeiGiorni(giorni, carta);',
     CIELO, 'passa dalla porta fuori dal filo'),
    # Regola B, fatta dopo il tocco della FE.01 e dichiarata: le due guardie
    # della zona delle funzioni del cielo.
    ('B1', 'FE.01', FUNZIONI,
     '      if (g != null) giorniChiesti.add(DateTime(g.year, g.month, g.day, 12));\n',
     '',
     'flutter test test/medora_sa_il_cielo_e_il_responso_test.dart -r expanded',
     '[E]'),
    ('B2', 'FE.01', FUNZIONI,
     '      giorniChiesti.add(DateTime(d.year, d.month, d.day, 12));\n    }\n    return giorni;',
     '    }\n    return giorni;',
     'flutter test test/i_giorni_nominati_test.dart -r expanded',
     '[E]'),
]


def leggi(p):
    return io.open(p, encoding='utf-8', newline='').read()


def scrivi(p, s):
    io.open(p, 'w', encoding='utf-8', newline='').write(s)


def un_innesto(sigla, voce, percorso, vecchio, nuovo, comando, bersaglio):
    copia = percorso + '.copia_regola_a'
    shutil.copyfile(percorso, copia)
    try:
        dati = leggi(percorso)
        crlf = '\r\n' in dati
        testo = dati.replace('\r\n', '\n')
        # Un innesto puo' essere fatto di piu' pezzi nello stesso file: allora
        # `vecchio` e' un elenco di coppie (vecchio, nuovo) e `nuovo` e' None.
        coppie = vecchio if isinstance(vecchio, list) else [(vecchio, nuovo)]
        for v, _ in coppie:
            n = testo.count(v)
            if n != 1:
                return '%s (%s) INNESTO NON ENTRATO: il pezzo vecchio compare %d volte' % (sigla, voce, n)
        for v, nv in coppie:
            testo = testo.replace(v, nv)
        scrivi(percorso, testo.replace('\n', '\r\n') if crlf else testo)
        dopo = leggi(percorso).replace('\r\n', '\n')
        entrato = True
        for v, nv in coppie:
            if nv and v in nv:
                entrato = entrato and dopo.count(nv) == 1
            else:
                entrato = entrato and (nv in dopo if nv else True) and dopo.count(v) == 0
        if not entrato:
            return '%s (%s) INNESTO NON ENTRATO al controllo' % (sigla, voce)
        esito = subprocess.run(comando, shell=True, capture_output=True,
                               text=True, encoding='utf-8', errors='replace')
        uscita = esito.stdout + esito.stderr
        rossa = esito.returncode != 0
        # Le cadute di flutter test portano [E]; quelle del server, col
        # rapporto spec di node, cominciano con la crocetta pesante.
        cadute = [r.strip()[:170] for r in uscita.splitlines()
                  if '[E]' in r or r.lstrip().startswith('✖')]
        nel_bersaglio = any(bersaglio in c for c in cadute)
        misure = [r.strip()[:220] for r in uscita.splitlines()
                  if r.startswith('ORDINE FE')][:2]
        return ('%s (%s) %s: innesto entrato (grep del pezzo nuovo 1, del vecchio 0); '
                '%s; bersaglio "%s" %s; cadute: %s; misure lette: %s') % (
                    sigla, voce, percorso,
                    'ROSSA' if rossa else 'VERDE (la prova NON vede il difetto)',
                    bersaglio, 'colpito' if nel_bersaglio else 'NON COLPITO',
                    ' | '.join(cadute[:2]) if cadute else '(nessuna riga di caduta letta)',
                    ' | '.join(misure) if misure else '(nessuna)')
    finally:
        shutil.copyfile(copia, percorso)
        os.remove(copia)


def main():
    scelte = set(sys.argv[1:])
    os.makedirs('docs/collaudo/FE', exist_ok=True)
    registro = 'docs/collaudo/FE/regola_a_fe.txt'
    for innesto in INNESTI:
        if scelte and innesto[0] not in scelte:
            continue
        prima = open(innesto[2], 'rb').read()
        riga = un_innesto(*innesto)
        dopo = open(innesto[2], 'rb').read()
        riga += '; file rimesso dalla copia: %s.' % (
            'uguale al byte (cmp)' if prima == dopo else 'DIVERSO, CONTROLLARE')
        print(riga, flush=True)
        with io.open(registro, 'a', encoding='utf-8', newline='\n') as f:
            f.write(riga + '\n')


if __name__ == '__main__':
    main()
