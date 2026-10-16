# -*- coding: utf-8 -*-
"""La prova del rosso della guardia del piano. Ordine CQ voce 1.01, Regola A."""
import os
import re
import subprocess
import sys

ENT = 'lib/core/entitlement/entitlement_service.dart'
BOR = 'lib/core/entitlement/question_allowance.dart'
GUARDIA = 'test/il_piano_attivo_e_i_suoi_tetti_test.dart'
NL = chr(10)
CR = chr(13)

INNESTI = [
    ('il tetto delle gettate legge la riga sbagliata', BOR,
     "  int? limiteGettate(Tier tier) =>\n"
     "      PlanCatalog.limiteGiornaliero(PlanCatalog.rigaGettate, tier);",
     "  int? limiteGettate(Tier tier) =>\n"
     "      PlanCatalog.limiteGiornaliero(PlanCatalog.rigaStese, tier);",
     'per ogni piano e per ogni arte'),
    ('il piano del server non si traduce piu', ENT,
     "    setTier(switch (piano) {\n"
     "      'tier1' => Tier.tier1,\n"
     "      'tier2' => Tier.tier2,\n"
     "      'tier3' => Tier.tier3,\n"
     "      _ => Tier.free,\n"
     "    });",
     "    setTier(Tier.free);",
     'il piano che il server dichiara'),
    ('il ponte del piano si stacca', BOR,
     "    quandoIlServerDiceIlPiano?.call(stato.piano);",
     "    // ponte staccato",
     'la sincronia col server porta il piano'),
    ('il no del server torna a scrivere un milione', BOR,
     "    final tetto = _tettoDelBudget(budget);\n    if (tetto == null) return;",
     "    final tetto = 1 << 20;",
     'al no del server il conto si chiude'),
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


def main():
    originali = {p: leggi(p) for p in (ENT, BOR)}
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

    fuori = ['LA PROVA DEL ROSSO DELLA GUARDIA DEL PIANO ATTIVO',
             'Ordine CQ voce 1.01, Regola A.', '=' * 72]
    for nome, attesa, esito, cadute in esiti:
        fuori.append('%-8s  %-46s  attesa: %s' % (esito, nome, attesa))
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
