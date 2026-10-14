"""ORDINE FS AGGIUNTA, REGOLA A: la guardia nuova
test/la_scena_della_stesa_e_un_filmato_test.dart vista rossa su sette difetti
innestati, uno alla volta. Ogni innesto si verifica col conteggio letterale
del pezzo nuovo prima di leggere l'esito, e il file torna al byte (sha1)
prima del seguente.

python docs/collaudo/FS/aggiunta_video/regola_a.py > docs/collaudo/FS/aggiunta_video/regola_a.txt
"""
import hashlib
import io
import subprocess

S = 'lib/features/tarot/stesa_tre_carte_screen.dart'
V = 'lib/features/tarot/la_scena_della_stesa_in_video.dart'
PROVA = 'test/la_scena_della_stesa_e_un_filmato_test.dart'

INNESTI = [
    ('il filmato non arriva al tavolo', S,
     '                filmato: _filmatoInScena,\n', ''),
    ('il silenzioso del telefono non conta', S,
     'final muto = !suono || await LaSuoneria.spenta();',
     'final muto = !suono;'),
    ('il filmato si apre anche con Riduci Movimento', S,
     '    if (_reduceMotion) return;\n    final lettore =',
     '    final lettore ='),
    ('uscendo dall\'app il filmato non si ferma', S,
     '      unawaited(lettore.sospendi());\n', ''),
    ('il filmato si riapre a ogni lettura delle dipendenze', S,
     '    if (_avviata) return;\n    _avviata = true;\n',
     '    unawaited(_apriIlFilmato());\n    if (_avviata) return;\n'
     '    _avviata = true;\n'),
    ('a filmato fallito resta la posa del mazzo', S,
     '    return l == null || l.fallito\n',
     '    return l == null\n'),
    ('il riquadro del filmato parte dal taglio della scena', V,
     'Rect.fromLTWH(0, (sopra - GeometriaDelTavolo.taglioInAlto) * s, w,',
     'Rect.fromLTWH(0, 0 * (sopra - GeometriaDelTavolo.taglioInAlto) * s, w,'),
]


def scrivi(p, testo):
    # Windows tiene a volte il file aperto per un attimo (errno 22 o 13):
    # si riprova, e la verifica col conteggio dice se e' entrato.
    import time
    for _ in range(20):
        try:
            io.open(p, 'w', encoding='utf-8', newline='').write(testo)
            return
        except OSError:
            time.sleep(0.5)
    raise OSError(f'non si scrive {p}')


def sha(p):
    return hashlib.sha1(open(p, 'rb').read()).hexdigest()


import sys
SOLO = sys.argv[1:]

for nome, f, a, b in INNESTI:
    if SOLO and nome not in SOLO:
        continue
    prima = sha(f)
    t = io.open(f, encoding='utf-8', newline='').read()
    n = t.count(a)
    if n != 1:
        print(f'== {nome}: il pezzo da innestare compare {n} volte, SALTATO')
        continue
    scrivi(f, t.replace(a, b))
    entrato = io.open(f, encoding='utf-8', newline='').read()
    if b and a in b:
        # Un innesto che AGGIUNGE davanti al pezzo vecchio: il vecchio resta
        # dentro il nuovo, e si conta il nuovo.
        verifica = entrato.count(b) == 1
    elif b:
        verifica = entrato.count(b) >= 1 and entrato.count(a) == 0
    else:
        verifica = entrato.count(a) == 0
    print(f'== {nome} ({f})')
    print(f'   innesto entrato (conteggio letterale): {verifica}')
    try:
        if not verifica:
            continue
        r = subprocess.run(['flutter', 'test', '-r', 'expanded', PROVA],
                           capture_output=True, text=True, encoding='utf-8',
                           errors='replace', shell=True)
        righe = r.stdout.splitlines()
        cadute = [x for x in righe if x.rstrip().endswith('[E]')]
        print(f'   esito: uscita {r.returncode}, {righe[-1].strip() if righe else ""}')
        for c in cadute:
            print('   caduto:', c.split(': ', 1)[-1].replace(' [E]', ''))
    finally:
        scrivi(f, t)
        print(f'   ripristinato al byte: {sha(f) == prima}')
