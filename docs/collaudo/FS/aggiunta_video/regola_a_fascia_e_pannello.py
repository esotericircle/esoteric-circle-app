"""14 ottobre 2026, dopo la 2310: REGOLA A per la guardia
nessuna_fascia_sotto_la_barra_della_stesa. Tre innesti, uno alla volta,
verificati prima di leggere l'esito; ogni file torna al byte.

python docs/collaudo/FS/aggiunta_video/regola_a_fascia_e_pannello.py
"""
import hashlib
import io
import subprocess

SCHERMATA = 'lib/features/tarot/stesa_tre_carte_screen.dart'
TAVOLO = 'lib/features/tarot/il_tavolo_di_medora.dart'
PROVA = 'test/nessuna_fascia_sotto_la_barra_della_stesa_test.dart'

INNESTI = [
    ('gli otto punti di prima fra la barra e la scena', SCHERMATA,
     '          sottoLaBarra -\n'
     '              GeometriaDelTavolo.sfumaturaInAlto *\n'
     '                  GeometriaDelTavolo.scala(MediaQuery.sizeOf(context).width),',
     '          sottoLaBarra + SpacingTokens.xs,'),
    ('il margine di prima fra il tavolo e il pannello', SCHERMATA,
     '        if (_responsoPronto) const SizedBox(height: SpacingTokens.sm),',
     '        const SizedBox(height: SpacingTokens.sm),'),
    ('la sfumatura di prima sotto il tavolo, fino al 1255', TAVOLO,
     '  static const double fineDellaSfumatura = bordoBassoDelPiano;',
     '  static const double fineDellaSfumatura = bordoDavanti + 50;'),
]


def sha(p):
    return hashlib.sha256(open(p, 'rb').read()).hexdigest()


for nome, p, a, b in INNESTI:
    prima = sha(p)
    t = io.open(p, encoding='utf-8', newline='').read()
    assert t.count(a) == 1, (nome, t.count(a))
    io.open(p, 'w', encoding='utf-8', newline='').write(t.replace(a, b))
    nuovo = io.open(p, encoding='utf-8', newline='').read()
    # Una occorrenza in piu' di b e nessuna di a: b puo' esistere gia'.
    entrato = nuovo.count(b) == t.count(b) + 1 and nuovo.count(a) == 0
    try:
        r = subprocess.run(['flutter', 'test', '-r', 'expanded', PROVA],
                           capture_output=True, text=True, encoding='utf-8',
                           errors='replace', shell=True)
    finally:
        io.open(p, 'w', encoding='utf-8', newline='').write(t)
    print(f'== {nome}\n   innesto entrato: {entrato}\n   uscita {r.returncode}')
    for c in r.stdout.splitlines():
        if c.rstrip().endswith('[E]'):
            print('   caduto:', c.split(': ', 1)[-1].replace(' [E]', ''))
        if 'punti' in c and ('fra' in c or 'cosmo' in c):
            print('   ', c.strip())
    print(f'   ripristinato al byte: {sha(p) == prima}')
