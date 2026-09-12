# -*- coding: utf-8 -*-
"""Rigenera lib/core/horoscope/horoscope_data.dart da docs/corpus/oroscopo.md.

STORIA, e va detta: l'intestazione di horoscope_data.dart nomina questo
strumento da sempre, ma chi lo uso' la prima volta non lo consegno' mai al
repo. L'ordine BD voce 07 lo ha trovato mancante e lo ha riscritto, e la
prova della fedelta' e' stata il giro di andata e ritorno: rigenerato dal
corpus di quel giorno, ha riprodotto il file allora in vigore byte per byte
prima che le ancore nuove entrassero.

Uso, dalla radice del repository:
    python tool/_gen_oroscopo.py            # scrive il file
    python tool/_gen_oroscopo.py --prova    # non scrive: confronta col file in vigore

La fonte di verita' e' il corpus. Il file dart non si tocca a mano.
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

RADICE = Path(__file__).resolve().parent.parent
CORPUS = RADICE / 'docs' / 'corpus' / 'oroscopo.md'
USCITA = RADICE / 'lib' / 'core' / 'horoscope' / 'horoscope_data.dart'

# L'ordine dei segni e' quello del corpus e dello zodiaco, da Ariete a Pesci.
SEGNI = [
    ('Ariete', 'aries'), ('Toro', 'taurus'), ('Gemelli', 'gemini'),
    ('Cancro', 'cancer'), ('Leone', 'leo'), ('Vergine', 'virgo'),
    ('Bilancia', 'libra'), ('Scorpione', 'scorpio'),
    ('Sagittario', 'sagittarius'), ('Capricorno', 'capricorn'),
    ('Acquario', 'aquarius'), ('Pesci', 'pisces'),
]
DOMINI = ['Generale', 'Amore', 'Carriera', 'Fortuna']


def dart(testo: str) -> str:
    """Una stringa Dart a virgolette singole, con gli escape che servono."""
    return "'" + (testo.replace('\\', r'\\')
                  .replace("'", r"\'")
                  .replace('$', r'\$')) + "'"


def sezione(testo: str, titolo: str) -> str:
    """Il corpo di una sezione '## titolo', fino alla '##' successiva."""
    inizio = testo.index('\n## ' + titolo)
    fine = testo.find('\n## ', inizio + 1)
    return testo[inizio:fine if fine >= 0 else len(testo)]


def leggi_corpus() -> dict:
    testo = CORPUS.read_text(encoding='utf-8')

    aperture = re.findall(r'^\d+\. (.+)$',
                          sezione(testo, 'Aperture personalizzate'), re.M)
    if len(aperture) != 6:
        sys.exit(f'aperture trovate {len(aperture)} invece di 6')

    ancore: dict[str, list[tuple[str, str]]] = {}
    blocco = sezione(testo, 'Le ancore dei dodici segni')
    for nome, ident in SEGNI:
        m = re.search(rf'^### {nome},.*?$(.*?)(?=^### |\Z)', blocco,
                      re.M | re.S)
        if not m:
            sys.exit(f'il corpus non porta il segno {nome}')
        quattro = []
        for dominio in DOMINI:
            r = re.search(rf'^- {dominio}, "(.+?)": (.+)$', m.group(1), re.M)
            if not r:
                sys.exit(f'{nome} non porta il dominio {dominio}')
            quattro.append((r.group(1), r.group(2).strip()))
        ancore[ident] = quattro

    correnti: dict[int, list[str]] = {}
    blocco = sezione(testo, 'I pool della corrente del giorno, per dominio')
    for indice, dominio in enumerate(DOMINI):
        m = re.search(rf'^### {dominio}, dieci correnti$(.*?)(?=^### |\Z)',
                      blocco, re.M | re.S)
        if not m:
            sys.exit(f'manca il pool del dominio {dominio}')
        frasi = re.findall(r'^\d+\. (.+)$', m.group(1), re.M)
        if len(frasi) != 10:
            sys.exit(f'il pool {dominio} porta {len(frasi)} frasi invece di 10')
        correnti[indice] = frasi

    palette: dict[str, list[str]] = {}
    blocco = sezione(testo, 'Le palette del colore del giorno, per segno')
    for nome, ident in SEGNI:
        r = re.search(rf'^- {nome}: (.+)$', blocco, re.M)
        if not r:
            sys.exit(f'manca la palette di {nome}')
        palette[ident] = [c.strip() for c in r.group(1).split(',')]

    blocco = sezione(testo, 'Disclaimer, una sola volta nella schermata')
    righe = [r for r in blocco.split('\n')
             if r.strip() and not r.startswith('#')]
    if not righe:
        sys.exit('il disclaimer non c\'e\'')
    disclaimer = righe[0].strip()

    return dict(aperture=aperture, ancore=ancore, correnti=correnti,
                palette=palette, disclaimer=disclaimer)


def componi(d: dict) -> str:
    r = []
    r.append('// GENERATO da tool/_gen_oroscopo.py a partire da docs/corpus/oroscopo.md.')
    r.append('// Fonte di verita\': il corpus. Non modificare a mano: rigenerare dal corpus.')
    r.append('//')
    r.append('// I dati su dispositivo dell\'Oroscopo a quattro schede di Medora: le aperture')
    r.append('// personalizzate, le ancore dei dodici segni per i quattro domini, i pool della')
    r.append('// corrente del giorno, le palette del colore del giorno e la riga di disclaimer.')
    r.append('')
    r.append('/// Dati dell\'Oroscopo, trascritti dal corpus. Chiavi per id del segno')
    r.append('/// (`Zodiac.id`) e per indice del dominio (Generale 0, Amore 1, Carriera 2,')
    r.append('/// Fortuna 3).')
    r.append('class HoroscopeData {')
    r.append('  const HoroscopeData._();')
    r.append('')
    r.append('  /// Le aperture personalizzate. Il segnaposto `[Nome]` si sostituisce col')
    r.append('  /// vocativo completo (Caro o Cara piu\' il nome, altrimenti Ciao piu\' il nome).')
    r.append('  static const String namePlaceholder = \'[Nome]\';')
    r.append('')
    r.append('  static const List<String> openings = [')
    for apertura in d['aperture']:
        r.append(f'    {dart(apertura)},')
    r.append('  ];')
    r.append('')
    r.append('  /// Per ogni segno, quattro ancore in ordine di dominio: ognuna [titolo, testo].')
    r.append('  static const Map<String, List<List<String>>> anchors = {')
    for _, ident in SEGNI:
        r.append(f'    \'{ident}\': [')
        for titolo, corpo in d['ancore'][ident]:
            r.append(f'      [{dart(titolo)}, {dart(corpo)}],')
        r.append('    ],')
    r.append('  };')
    r.append('')
    r.append('  /// I pool della corrente del giorno, dieci frasi per dominio, per tutti i segni.')
    r.append('  static const Map<int, List<String>> dayPools = {')
    for indice in range(4):
        r.append(f'    {indice}: [')
        for frase in d['correnti'][indice]:
            r.append(f'      {dart(frase)},')
        r.append('    ],')
    r.append('  };')
    r.append('')
    r.append('  /// Le palette del colore del giorno, per id del segno.')
    r.append('  static const Map<String, List<String>> palettes = {')
    for _, ident in SEGNI:
        colori = ', '.join(dart(c) for c in d['palette'][ident])
        r.append(f'    \'{ident}\': [{colori}],')
    r.append('  };')
    r.append('')
    r.append('  /// La riga di disclaimer, mostrata una sola volta.')
    r.append(f'  static const String disclaimer = {dart(d["disclaimer"])};')
    r.append('}')
    r.append('')
    return '\n'.join(r)


def main() -> None:
    prova = '--prova' in sys.argv
    nuovo = componi(leggi_corpus())
    if prova:
        in_vigore = USCITA.read_text(encoding='utf-8')
        # Il confronto ignora la sola forma dei fine riga, che dipende dal
        # checkout: la sostanza deve coincidere carattere per carattere.
        if in_vigore.replace('\r\n', '\n') == nuovo:
            print('GIRO DI ANDATA E RITORNO: il corpus riproduce il file in '
                  'vigore, carattere per carattere.')
        else:
            import difflib
            vecchie = in_vigore.replace('\r\n', '\n').split('\n')
            scarti = list(difflib.unified_diff(vecchie, nuovo.split('\n'),
                                               'in_vigore', 'rigenerato',
                                               lineterm='', n=1))
            print('\n'.join(scarti[:40]))
            sys.exit('IL GIRO NON TORNA: vedi lo scarto qui sopra.')
    else:
        with open(USCITA, 'w', encoding='utf-8', newline='\r\n') as f:
            f.write(nuovo)
        print(f'scritto {USCITA.relative_to(RADICE)}')


if __name__ == '__main__':
    main()
