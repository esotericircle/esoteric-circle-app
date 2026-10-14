"""ORDINE DEL 14 OTTOBRE 2026, REGOLA A per la fermata anticipata del video
con rallentamento. Tre innesti, uno alla volta, verificati col conteggio
letterale prima di leggere l'esito; il file torna al byte prima del seguente.

python docs/collaudo/FS/aggiunta_video/regola_a_fermata.py
"""
import hashlib
import io
import subprocess
import sys
import time

F = 'lib/features/tarot/la_scena_della_stesa_in_video.dart'
PROVA = 'test/la_scena_si_ferma_col_rallentamento_test.dart'

INNESTI = [
    ('la scena si ferma alla fine vera del filmato, non prima',
     'static const Duration fermaA = Duration(milliseconds: 6917);',
     'static const Duration fermaA = Duration(milliseconds: 8000);'),
    ('la velocita non scende mai sotto 1,0',
     'return frazione.clamp(velocitaMinima, 1.0).toDouble();',
     'return 1.0; /* INNESTO B */'),
    ('la rampa puo arrivare a velocita zero',
     'static const double velocitaMinima = 0.1;',
     'static const double velocitaMinima = 0.0;'),
]


def scrivi(p, testo):
    for _ in range(20):
        try:
            io.open(p, 'w', encoding='utf-8', newline='').write(testo)
            return
        except OSError:
            time.sleep(0.5)
    raise OSError(p)


def sha(p):
    return hashlib.sha1(open(p, 'rb').read()).hexdigest()


for nome, a, b in INNESTI:
    prima = sha(F)
    t = io.open(F, encoding='utf-8', newline='').read()
    if t.count(a) != 1:
        print(f'== {nome}: il pezzo compare {t.count(a)} volte, SALTATO')
        continue
    scrivi(F, t.replace(a, b))
    e = io.open(F, encoding='utf-8', newline='').read()
    print(f'== {nome}')
    print(f'   innesto entrato (conteggio letterale): {e.count(b) == 1 and e.count(a) == 0}')
    try:
        r = subprocess.run(['flutter', 'test', '-r', 'expanded', PROVA],
                           capture_output=True, text=True, encoding='utf-8',
                           errors='replace', shell=True)
        righe = r.stdout.splitlines()
        print(f'   esito: uscita {r.returncode}')
        for c in righe:
            if c.rstrip().endswith('[E]'):
                print('   caduto:', c.split(': ', 1)[-1].replace(' [E]', ''))
    finally:
        scrivi(F, t)
        print(f'   ripristinato al byte: {sha(F) == prima}')
