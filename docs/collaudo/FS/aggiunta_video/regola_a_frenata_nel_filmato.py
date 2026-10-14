"""14 ottobre 2026, dopo la 2310: REGOLA A per la guardia
la_frenata_sta_nel_filmato. Tre innesti, uno alla volta, ognuno verificato
prima di leggere l'esito; ogni file torna al byte prima del seguente.

python docs/collaudo/FS/aggiunta_video/regola_a_frenata_nel_filmato.py
"""
import hashlib
import io
import subprocess

CODICE = 'lib/features/tarot/la_scena_della_stesa_in_video.dart'
VIDEO = 'brand_assets/tavolo/medora_mazzo_in_vortice_v2.mp4'
PROVA = 'test/la_frenata_sta_nel_filmato_test.dart'


def sha(p):
    return hashlib.sha256(open(p, 'rb').read()).hexdigest()


def esito():
    r = subprocess.run(['flutter', 'test', '-r', 'expanded', PROVA],
                       capture_output=True, text=True, encoding='utf-8',
                       errors='replace', shell=True)
    cadute = [c.split(': ', 1)[-1].replace(' [E]', '')
              for c in r.stdout.splitlines() if c.rstrip().endswith('[E]')]
    return r.returncode, cadute


def testo(nome, p, a, b):
    prima = sha(p)
    t = io.open(p, encoding='utf-8', newline='').read()
    assert t.count(a) == 1, (nome, t.count(a))
    io.open(p, 'w', encoding='utf-8', newline='').write(t.replace(a, b))
    entrato = io.open(p, encoding='utf-8', newline='').read().count(b) == 1
    try:
        u, c = esito()
    finally:
        io.open(p, 'w', encoding='utf-8', newline='').write(t)
    print(f'== {nome}\n   innesto entrato: {entrato}\n   uscita {u}')
    for x in c:
        print('   caduto:', x)
    print(f'   ripristinato al byte: {sha(p) == prima}')


testo('la rampa di velocita torna nel lettore', CODICE,
      '    if (cambiato) _quandoCambia?.call();\n  }',
      '    if (cambiato) _quandoCambia?.call();\n'
      '    c.setPlaybackSpeed(0.5);\n  }')
testo('il codice dice 192 fotogrammi, il file 190', CODICE,
      'static const int fotogrammi = 190;',
      'static const int fotogrammi = 192;')

# Il terzo innesto: al posto del file misurato, l'originale senza frenata.
prima = sha(VIDEO)
nuovo = open(VIDEO, 'rb').read()
vecchio = subprocess.run(
    ['git', 'show', '48978334:brand_assets/tavolo/medora_mazzo_in_vortice_v1.mp4'],
    capture_output=True).stdout
open(VIDEO, 'wb').write(vecchio)
entrato = sha(VIDEO) == 'e8b6d318cf3604bf3d58960edd2d8ea8bc056b8c6719216ce2862875b546b30b'
try:
    u, c = esito()
finally:
    open(VIDEO, 'wb').write(nuovo)
print(f'== al posto del file con la frenata, l\'originale senza\n'
      f'   innesto entrato (impronta dell\'originale): {entrato}\n   uscita {u}')
for x in c:
    print('   caduto:', x)
print(f'   ripristinato al byte: {sha(VIDEO) == prima}')
