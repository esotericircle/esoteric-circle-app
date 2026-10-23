"""ORDINE FS, REGOLA A per la guardia del manifesto, test/ordine_fs_guard_test.dart.

Tre innesti nel manifesto, uno alla volta, verificati col conteggio letterale
prima di leggere l'esito; il file torna al byte (sha1) prima del seguente.

python docs/collaudo/FS/aggiunta_video/ordine_fs_guard_regola_a.py > docs/collaudo/FS/aggiunta_video/ordine_fs_guard_regola_a.txt
"""
import hashlib
import io
import subprocess
import time

M = 'docs/ordini/ORDINE_FS_MANIFESTO.md'
PROVA = 'test/ordine_fs_guard_test.dart'
INNESTI = [
    ('il marcatore delle chiuse alzato', 'VOCI_CHIUSE: 1\n', 'VOCI_CHIUSE: 2\n'),
    ('una voce rinominata', '## VOCE FS.12\n', '## VOCE FS.21\n'),
    ('una voce aperta che non dice che cosa aspetta', 'ASPETTA: il fondatore, che pubblica', 'Aspetta il fondatore, che pubblica'),
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
    prima = sha(M)
    t = io.open(M, encoding='utf-8', newline='').read()
    if t.count(a) != 1:
        print(f'== {nome}: il pezzo compare {t.count(a)} volte, SALTATO')
        continue
    scrivi(M, t.replace(a, b))
    e = io.open(M, encoding='utf-8', newline='').read()
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
        scrivi(M, t)
        print(f'   ripristinato al byte: {sha(M) == prima}')
