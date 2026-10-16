# -*- coding: utf-8 -*-
"""Rigenera i corpora dell'ordine EU nel codice da docs/corpus/eu/.

EU Aggiunta, 1 ottobre 2026: i dodici corpora dell'Architetto
(oroscopo_eu_<tradizione>_<periodo>.md) sono la fonte unica; il codice li
porta carattere per carattere in tre file, uno per tradizione:
lib/core/horoscope/i_testi_eu_<tradizione>_data.dart. I file dart non si
toccano a mano, e il corpus non lo tocca Code (regola fissa 11): un difetto
in un testo si scrive nel rapporto.

Uso, dalla radice del repository:
    python tool/_gen_oroscopo_eu.py            # scrive i tre file
    python tool/_gen_oroscopo_eu.py --prova    # non scrive: confronta coi file in vigore
"""
from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

RADICE = Path(__file__).resolve().parent.parent
CARTELLA = RADICE / 'docs' / 'corpus' / 'eu'
USCITA = RADICE / 'lib' / 'core' / 'horoscope'

TRADIZIONI = ['occidentale', 'vedica', 'cinese']
PERIODI = ['giorno', 'settimana', 'mese', 'anno']
DOMINI = ['Generale', 'Amore', 'Carriera', 'Fortuna']
FASCE = [('Favorevole', 'favorevole'), ('In equilibrio', 'equilibrio'),
         ('In salita', 'salita')]
# Quante voci per fascia, dalla EU Aggiunta.
ATTESE = {'giorno': [30, 24, 15], 'settimana': [14, 14, 14],
          'mese': [4, 4, 4], 'anno': [2, 2, 2]}
CAMPI = ['Risposta', 'Che cosa fare', 'Risposta, Lunga', 'Che cosa fare, Lunga']


def dart(testo: str) -> str:
    return "'" + testo.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$') + "'"


def sezione(testo: str, intestazione: str, livello: str) -> str:
    """Il blocco sotto l'intestazione [intestazione] fino alla prossima del
    suo livello o di uno superiore."""
    m = re.search(r'^' + livello + ' ' + re.escape(intestazione) + r'\n(.*?)(?=^#{1,'
                  + str(len(livello)) + r'} |\Z)', testo, re.M | re.S)
    assert m, intestazione
    return m.group(1)


def aperture(testo: str) -> list[list[str]]:
    blocco = sezione(testo, 'Aperture', '##')
    uscita = []
    for nome, _ in FASCE:
        m = re.search(r'^### Aperture, ' + re.escape(nome) + r' \(.*?\)\n(.*?)(?=^### |\Z)',
                      blocco, re.M | re.S)
        assert m, nome
        righe = []
        for riga in m.group(1).splitlines():
            r = re.match(r'^(\d+)\. (.+)$', riga)
            if r:
                assert int(r.group(1)) == len(righe) + 1, riga
                righe.append(r.group(2))
        uscita.append(righe)
    return uscita


def voci(testo: str, periodo: str) -> list[list[list[tuple[str, ...]]]]:
    uscita = []
    for dominio in DOMINI:
        blocco = sezione(testo, dominio, '##')
        per_fascia = []
        for k, (nome, corto) in enumerate(FASCE):
            m = re.search(r'^### ' + re.escape(dominio) + ', ' + re.escape(nome)
                          + r' \(.*?\)\n(.*?)(?=^### |\Z)', blocco, re.M | re.S)
            assert m, (dominio, nome)
            elenco = []
            pezzi = re.split(r'^#### (.*)$', m.group(1), flags=re.M)
            for i in range(1, len(pezzi), 2):
                testa = re.match(r'^' + re.escape(dominio) + ', ' + corto
                                 + r', voce (\d+): (.+)$', pezzi[i])
                assert testa, pezzi[i]
                assert int(testa.group(1)) == len(elenco) + 1, pezzi[i]
                campi = {}
                for riga in pezzi[i + 1].splitlines():
                    r = re.match(r'^- (Risposta|Che cosa fare|Risposta, Lunga|'
                                 r'Che cosa fare, Lunga): (.+)$', riga)
                    if r:
                        assert r.group(1) not in campi, pezzi[i]
                        campi[r.group(1)] = r.group(2)
                    else:
                        assert not riga.strip(), riga
                assert list(campi) == CAMPI, pezzi[i]
                elenco.append((testa.group(2),) + tuple(campi[c] for c in CAMPI))
            assert len(elenco) == ATTESE[periodo][k], (dominio, nome, len(elenco))
            per_fascia.append(elenco)
        uscita.append(per_fascia)
    return uscita


def genera(tradizione: str) -> str:
    righe = [
        '// GENERATO da tool/_gen_oroscopo_eu.py dai corpora di docs/corpus/eu/.',
        '// Non si tocca a mano: si cambia il corpus (lo fa l\'Architetto) e si',
        '// rigenera. EU Aggiunta, 1 ottobre 2026.',
        '// ignore_for_file: lines_longer_than_80_chars',
        '',
        "import 'i_testi_eu.dart';",
        '',
        '/// I testi dell\'Architetto per la tradizione ' + tradizione + ': per periodo,',
        '/// dominio e fascia, le voci in fila; nel Giorno anche le aperture.',
        'abstract final class ITestiEu' + tradizione.capitalize() + 'Data {',
    ]
    righe.append('  static const List<List<String>> aperture = [')
    testo_giorno = (CARTELLA / f'oroscopo_eu_{tradizione}_giorno.md').read_text(encoding='utf-8')
    for fascia in aperture(testo_giorno):
        righe.append('    [')
        for a in fascia:
            righe.append('      ' + dart(a) + ',')
        righe.append('    ],')
    righe.append('  ];')
    righe.append('')
    righe.append('  /// [periodo][dominio][fascia][voce]')
    righe.append('  static const List<List<List<List<VoceEu>>>> voci = [')
    for periodo in PERIODI:
        testo = (CARTELLA / f'oroscopo_eu_{tradizione}_{periodo}.md').read_text(encoding='utf-8')
        righe.append('    // ' + periodo)
        righe.append('    [')
        for dominio in voci(testo, periodo):
            righe.append('      [')
            for fascia in dominio:
                righe.append('        [')
                for v in fascia:
                    righe.append('          VoceEu(')
                    for campo in v:
                        righe.append('            ' + dart(campo) + ',')
                    righe.append('          ),')
                righe.append('        ],')
            righe.append('      ],')
        righe.append('    ],')
    righe.append('  ];')
    righe.append('}')
    return '\n'.join(righe) + '\n'


def formatta(percorsi: list[Path]) -> None:
    subprocess.run(['dart', 'format', *[str(p) for p in percorsi]], check=True,
                   shell=sys.platform == 'win32', capture_output=True)


def main() -> int:
    prova = '--prova' in sys.argv
    diversi = 0
    for t in TRADIZIONI:
        destinazione = USCITA / f'i_testi_eu_{t}_data.dart'
        nuovo = genera(t)
        if prova:
            temp = USCITA / f'.i_testi_eu_{t}_data.prova.dart'
            temp.write_text(nuovo, encoding='utf-8', newline='\n')
            formatta([temp])
            uguale = temp.read_text(encoding='utf-8') == destinazione.read_text(encoding='utf-8')
            temp.unlink()
            print(t, 'uguale' if uguale else 'DIVERSO')
            diversi += 0 if uguale else 1
        else:
            destinazione.write_text(nuovo, encoding='utf-8', newline='\n')
            formatta([destinazione])
            print('scritto', destinazione.name)
    return 1 if diversi else 0


if __name__ == '__main__':
    sys.exit(main())
