"""Ordine FU voce FU.13, Regola A: ogni prova nuova vista rossa.

Per ogni innesto: la sostituzione con l'assert del conteggio, la verifica
col grep che il difetto sia entrato nel file, il giro della prova, il
ripristino e la rilettura del file, che deve tornare identico byte per byte.
Uso: python -I docs/collaudo/FU/fu13_innesti.py
L'uscita va anche in docs/collaudo/FU/fu13_innesti.txt.
"""
import builtins
import re
import subprocess
import time

_righe = []


def print(*a):  # noqa: A001 - l'uscita va a video e nel file
    testo = ' '.join(str(x) for x in a)
    _righe.append(testo)
    builtins.print(testo, flush=True)

SCENA = 'lib/features/horoscope/la_scena_dell_oroscopo.dart'
OROSCOPO = 'lib/features/horoscope/oroscopo_screen.dart'
COMUNE = 'lib/features/scene/la_scena_in_video.dart'
PROVA = 'test/la_scena_dell_oroscopo_e_un_filmato_test.dart'
GUARDIA = 'test/ogni_scena_si_salta_col_tocco_test.dart'

INNESTI = [
    ('gli emblemi non si accendono mai', SCENA,
     'if (emblemiAccesi)', 'if (false && emblemiAccesi)', PROVA),
    ('la ruota occidentale gira in senso orario', SCENA,
     'Zodiac.values[(occidentale.index - k + 12) % 12]',
     'Zodiac.values[(occidentale.index + k) % 12]', PROVA),
    ('la Maya riempie le sedi coi segni occidentali', SCENA,
     'case AstroTradition.araba:\n        return null;',
     'case AstroTradition.araba:\n        return List.filled(12, '
     'ZodiacArt.emblemPath(occidentale));', PROVA),
    ('il tocco non salta il video', OROSCOPO,
     'onSalta: _regia.salta,', 'onSalta: () {},', PROVA),
    ('a video finito la lettura sale subito, senza sosta', OROSCOPO,
     '_sostaSugliEmblemi = Timer(',
     '_letturaSalita = true; // innesto\n        _sostaSugliEmblemi = Timer(',
     PROVA),
    ('a scena ferma la lettura non sale', OROSCOPO,
     '        _letturaSalita = true;\n        _letturaAnimata = false;',
     '        _letturaSalita = false; // innesto\n'
     '        _letturaAnimata = false;', PROVA),
    ('la regia comune non spegne il volume', COMUNE,
     'await lettore.volume(muto ? 0 : 1);', 'await lettore.volume(1);', PROVA),
    ('l\'Oroscopo non passa dal tocco che salta', OROSCOPO,
     'return IlToccoCheSalta(', 'return _SenzaTocco(', GUARDIA),
]


def leggi(p):
    with open(p, encoding='utf-8', newline='') as f:
        return f.read()


def scrivi(p, testo):
    for _ in range(20):
        try:
            with open(p, 'w', encoding='utf-8', newline='') as f:
                f.write(testo)
            return
        except OSError:
            time.sleep(0.5)
    raise SystemExit(f'non riesco a scrivere {p}')


def un_innesto(nome, file, vecchio, nuovo, prova, originale):
    scrivi(file, originale.replace(vecchio, nuovo))
    if nuovo.startswith('return _SenzaTocco('):
        # Il nome nuovo deve esistere perche' il file compili.
        scrivi(file, leggi(file) + '\n\nclass _SenzaTocco extends '
               'StatelessWidget {\n  const _SenzaTocco({required this.inCorso, '
               'required this.onSalta, required this.child});\n  final bool '
               'inCorso;\n  final VoidCallback onSalta;\n  final Widget child;'
               '\n  @override\n  Widget build(BuildContext context) => child;'
               '\n}\n')
    # La spia del grep: la prima riga dell'innesto che il file originale non
    # aveva.
    spia = next(r.strip() for r in nuovo.splitlines()
                if r.strip() not in originale)
    entrato = spia in leggi(file)
    print(f'== INNESTO: {nome}\n   file {file}: grep "{spia}" '
          f'-> {"trovato" if entrato else "ASSENTE"}')
    assert entrato
    r = subprocess.run(['flutter', 'test', prova], capture_output=True,
                       text=True, encoding='utf-8', errors='replace',
                       shell=True)
    righe = [riga for riga in r.stdout.splitlines()
             if re.search(r'Some tests failed|All tests passed', riga)]
    cadute = sorted({re.sub(r'^.*?\.dart: ', '', riga).strip()
                     for riga in r.stdout.splitlines()
                     if riga.rstrip().endswith('[E]')})
    print(f'   esito {prova}: {righe[-1].strip() if righe else "?"} '
          f'(uscita {r.returncode})')
    for c in cadute:
        print(f'   rossa: {c}')


for nome, file, vecchio, nuovo, prova in INNESTI:
    originale = leggi(file)
    assert originale.count(vecchio) == 1, (nome, originale.count(vecchio))
    try:
        un_innesto(nome, file, vecchio, nuovo, prova, originale)
    finally:
        # Il ripristino avviene anche se l'innesto si e' fermato a meta'.
        scrivi(file, originale)
        assert leggi(file) == originale, f'{file} non ripristinato'
        print(f'   ripristino di {file}: identico')

scrivi('docs/collaudo/FU/fu13_innesti.txt', '\n'.join(_righe) + '\n')
