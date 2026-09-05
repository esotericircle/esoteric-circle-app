# -*- coding: utf-8 -*-
"""Prova del rosso delle due pretese del rilancio punto 1. Regola A."""
import os
import re
import subprocess

RUNE = 'lib/features/maestri/caligo/rune/rune_draw_screen.dart'
CAT = 'lib/core/entitlement/plan_catalog.dart'
GUARDIA = 'test/il_piano_attivo_e_i_suoi_tetti_test.dart'
NL = chr(10)
CR = chr(13)

INNESTI = [
    ('il tetto delle gettate scritto a mano nella schermata', RUNE,
     '    final limite = borsa.limiteGettate(piano);',
     '    final limite = 30;',
     'il tetto delle gettate ha un lettore solo'),
    ('l Adepto non ha piu trenta gettate', CAT,
     "  static const String rigaGettate = 'Gettate di rune';",
     "  static const String rigaGettate = 'Stese complete tarocchi';",
     'LE 29 SU 30 DELLO SCREENSHOT'),
]


def leggi(p):
    return open(p, 'rb').read().decode('utf-8')


def scrivi(p, s):
    open(p, 'wb').write(s.encode('utf-8'))


def innesta(percorso, vecchio, nuovo):
    grezzo = leggi(percorso)
    crlf = CR in grezzo
    s = grezzo.replace(CR + NL, NL) if crlf else grezzo
    if s.count(vecchio) != 1:
        raise SystemExit('INNESTO MANCATO in %s: %d occorrenze'
                         % (percorso, s.count(vecchio)))
    s = s.replace(vecchio, nuovo)
    scrivi(percorso, s.replace(NL, CR + NL) if crlf else s)
    controllo = leggi(percorso)
    if crlf:
        controllo = controllo.replace(CR + NL, NL)
    if nuovo not in controllo:
        raise SystemExit('INNESTO NON VERIFICATO in %s' % percorso)
    print('INNESTO VERIFICATO col grep in %s' % percorso)


def main():
    originali = {p: leggi(p) for p in (RUNE, CAT)}
    esiti = []
    try:
        for nome, percorso, vecchio, nuovo, attesa in INNESTI:
            for p, s in originali.items():
                scrivi(p, s)
            innesta(percorso, vecchio, nuovo)
            prova = subprocess.run(
                ['flutter', 'test', GUARDIA], capture_output=True, text=True,
                env=dict(os.environ, TZ='Europe/Rome'), shell=True)
            cadute = sorted(set(re.findall(
                r'^\s+.*_test\.dart: (.+)$',
                prova.stdout.split('Failing tests:')[-1], re.M)))
            colpita = any(c.startswith(attesa) for c in cadute)
            esiti.append((nome, attesa, 'ROSSA' if colpita else 'VERDE',
                          cadute))
    finally:
        for p, s in originali.items():
            scrivi(p, s)

    fuori = ['LA PROVA DEL ROSSO DEL RILANCIO PUNTO 1',
             'Ordine CQ, rilancio, Regola A.', '=' * 72]
    for nome, attesa, esito, cadute in esiti:
        fuori.append('%-8s  %-52s  attesa: %s' % (esito, nome, attesa))
        for c in cadute:
            fuori.append('          caduta: %s' % c)
    quante = sum(1 for e in esiti if e[2] == 'ROSSA')
    fuori.append('=' * 72)
    fuori.append('INNESTI CHE HANNO FATTO ROSSA LA PRETESA ATTESA: %d su %d'
                 % (quante, len(esiti)))
    testo = NL.join(fuori)
    with open('docs/ordini/CQ_prova_del_rosso.txt', 'a',
              encoding='utf-8') as f:
        f.write(testo + NL + NL)
    print(testo.encode('ascii', 'replace').decode('ascii'))


if __name__ == '__main__':
    main()
