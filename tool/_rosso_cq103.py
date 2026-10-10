# -*- coding: utf-8 -*-
"""Prova del rosso della guardia del ventaglio. Ordine CQ voce 1.03, Regola A."""
import os
import re
import subprocess

S = 'lib/features/tarot/stesa_tre_carte_screen.dart'
GUARDIA = 'test/il_ventaglio_vive_subito_test.dart'
NL = chr(10)
CR = chr(13)

INNESTI = [
    ('il ventaglio torna a non rispondere al primo tocco',
     '    if (_complete || _taken.contains(fanIndex)) return;',
     '    if (_complete || _taken.contains(fanIndex)) return;' + chr(10) + '    if (_drawn == 0) return;',
     'senza premere niente, il ventaglio posa la carta'),
    ('il pulsante torna dentro il blocco delle carte da pescare',
     '        if (!_responsoPronto) ...[\n          const SizedBox(height: SpacingTokens.sm),\n          Center(\n            child: FilledButton.icon(\n              key: const Key(\'stesa_inizia\'),',
     '        if (!_responsoPronto && !_complete) ...[\n          const SizedBox(height: SpacingTokens.sm),\n          Center(\n            child: FilledButton.icon(\n              key: const Key(\'stesa_inizia\'),',
     'il pulsante c e da subito, spento, e si accende alla terza'),
    ('il pulsante e premibile anche a zero carte',
     '              onPressed: _complete && !_stoPerRiflettere\n                  ? () => unawaited(_apriIlResponso())\n                  : null,',
     '              onPressed: () => unawaited(_apriIlResponso()),',
     'il pulsante c e da subito, spento, e si accende alla terza'),
    ('la terza carta torna a consumare la stesa',
     '      if (_complete) _scene = StesaScene.completa;',
     '      if (_complete) _scene = StesaScene.completa;\n      if (_complete) {\n        _forse<QuestionAllowance>(context)?.registraStesa(\n            _forse<EntitlementService>(context)?.tier ?? Tier.free);\n      }',
     'scegliere non consuma, premere si'),
]


def leggi(p):
    return open(p, 'rb').read().decode('utf-8')


def scrivi(p, s):
    open(p, 'wb').write(s.encode('utf-8'))


def main():
    originale = leggi(S)
    crlf = CR in originale
    esiti = []
    try:
        for nome, vecchio, nuovo, attesa in INNESTI:
            s = originale.replace(CR + NL, NL) if crlf else originale
            if s.count(vecchio) != 1:
                raise SystemExit('INNESTO MANCATO "%s": %d occorrenze'
                                 % (nome, s.count(vecchio)))
            s = s.replace(vecchio, nuovo)
            scrivi(S, s.replace(NL, CR + NL) if crlf else s)
            controllo = leggi(S).replace(CR + NL, NL)
            if nuovo not in controllo:
                raise SystemExit('INNESTO NON VERIFICATO: %s' % nome)
            print('INNESTO VERIFICATO col grep: %s' % nome)
            prova = subprocess.run(
                ['flutter', 'test', GUARDIA], capture_output=True, text=True, encoding='utf-8', errors='replace',
                env=dict(os.environ, TZ='Europe/Rome'), shell=True)
            cadute = sorted(set(re.findall(
                r'^\s+.*_test\.dart: (.+)$',
                prova.stdout.split('Failing tests:')[-1], re.M)))
            esiti.append((nome, attesa,
                          'ROSSA' if attesa in cadute else 'VERDE', cadute))
    finally:
        scrivi(S, originale)

    fuori = ['LA PROVA DEL ROSSO DELLA GUARDIA DEL VENTAGLIO',
             'Ordine CQ voce 1.03, Regola A.', '=' * 72]
    for nome, attesa, esito, cadute in esiti:
        fuori.append('%-8s  %-50s' % (esito, nome))
        fuori.append('          attesa: %s' % attesa)
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
