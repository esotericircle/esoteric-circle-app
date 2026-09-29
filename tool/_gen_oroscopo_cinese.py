# -*- coding: utf-8 -*-
"""Rigenera lib/core/horoscope/oroscopo_cinese_data.dart da docs/corpus/oroscopo_cinese.md.

Ordine ES voce 08: "le frasi vengono da un corpus scritto una volta, in
docs/corpus/oroscopo_cinese.md, con piu' varianti per caso". La fonte di
verita' e' il corpus; il file dart non si tocca a mano.

Uso, dalla radice del repository:
    python tool/_gen_oroscopo_cinese.py            # scrive il file
    python tool/_gen_oroscopo_cinese.py --prova    # non scrive: confronta col file in vigore
"""
from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

RADICE = Path(__file__).resolve().parent.parent
CORPUS = RADICE / 'docs' / 'corpus' / 'oroscopo_cinese.md'
USCITA = RADICE / 'lib' / 'core' / 'horoscope' / 'oroscopo_cinese_data.dart'

# Le sottosezioni del paragrafo 1, nell'ordine del corpus.
RAPPORTI = ['armonia', 'triplaArmonia', 'scontro', 'punizione', 'punizioneDiSe',
            'danno', 'armoniaChePunisce', 'stessoAnimale', 'nessuno']
# Le sottosezioni del paragrafo 3.
SCHEDE_DEI = ['fortuna', 'lavoro', 'amoreDonna', 'amoreUomo', 'amoreNeutro']
# I Dieci Dei per carattere, come DioDelGiorno.
DEI = {'比肩': 'compagno', '劫财': 'rivale', '食神': 'nutrimento',
       '伤官': 'ufficialeFerito', '偏财': 'ricchezzaIndiretta',
       '正财': 'ricchezzaDiretta', '七杀': 'setteUccisioni',
       '正官': 'ufficialeDiretto', '偏印': 'sigilloIndiretto',
       '正印': 'sigilloDiretto'}


def dart(testo: str) -> str:
    return "'" + testo.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$') + "'"


def frasi(blocco: str) -> list[str]:
    return [m.group(1).strip() for m in re.finditer(r'^\d+\.\s+(.+)$', blocco, re.M)]


def sottosezioni(testo: str, numero: str) -> list[str]:
    """I blocchi delle sottosezioni '### numero.x' del paragrafo."""
    parti = re.split(r'^### ' + re.escape(numero) + r'\.\d+ .*$', testo, flags=re.M)
    return parti[1:]


def paragrafo(testo: str, numero: str) -> str:
    m = re.search(r'^## ' + re.escape(numero) + r'\. .*?(?=^## |\Z)', testo, re.M | re.S)
    assert m, numero
    return m.group(0)


def componi() -> str:
    t = CORPUS.read_text(encoding='utf-8')
    uno = sottosezioni(paragrafo(t, '1'), '1')
    assert len(uno) == len(RAPPORTI), len(uno)
    due = sottosezioni(paragrafo(t, '2'), '2')
    assert len(due) == 12, len(due)
    tre = sottosezioni(paragrafo(t, '3'), '3')
    assert len(tre) == len(SCHEDE_DEI), len(tre)
    # La tabella delle spiegazioni dei Dieci Dei, in testa al paragrafo 3.
    spiegazioni = {DEI[c]: s.strip() for c, s in re.findall(
        r'^\| (\S+) \| [^|]+ \| ([^|]+) \|\s*$', paragrafo(t, '3'), re.M)
        if c in DEI}
    assert len(spiegazioni) == 10, spiegazioni
    quattro = paragrafo(t, '4')

    out = ['// GENERATO da tool/_gen_oroscopo_cinese.py a partire da '
           'docs/corpus/oroscopo_cinese.md.',
           "// Fonte di verita': il corpus. Non modificare a mano: rigenerare dal corpus.",
           '',
           '/// Le frasi dell\'oroscopo cinese del giorno (ordine ES voce 08), trascritte',
           '/// dal corpus. Le marche del genere `[m|f|n]` si risolvono alla lettura.',
           'abstract final class OroscopoCineseData {',
           '  /// Scheda Generale: il rapporto fra l\'animale del giorno e il tuo.',
           '  static const Map<String, List<String>> rapporti = {']
    for chiave, blocco in zip(RAPPORTI, uno):
        f = frasi(blocco)
        assert len(f) >= 3, chiave
        out.append(f'    {dart(chiave)}: [')
        out += [f'      {dart(x)},' for x in f]
        out.append('    ],')
    out.append('  };')
    out.append('')
    out.append('  /// Scheda Generale: il guardiano del giorno, da Stabilire a Chiudere.')
    out.append('  static const List<List<String>> guardiani = [')
    consigli = []
    for blocco in due:
        f = frasi(blocco)
        assert len(f) >= 3
        m = re.search(r'^Adatto a: (.+?)\. Meglio evitare: (.+?)\.\s*$', blocco, re.M)
        assert m, blocco[:80]
        consigli.append((m.group(1), m.group(2)))
        out.append('    [')
        out += [f'      {dart(x)},' for x in f]
        out.append('    ],')
    out.append('  ];')
    out.append('')
    out.append('  /// Che cosa conviene e che cosa no col guardiano, da Stabilire a Chiudere.')
    out.append('  static const List<(String, String)> consigliDelGuardiano = [')
    out += [f'    ({dart(a)}, {dart(e)}),' for a, e in consigli]
    out.append('  ];')
    out.append('')
    out.append('  /// Fortuna, Lavoro e Amore: i Dieci Dei, per scheda e per dio.')
    out.append('  static const Map<String, Map<String, List<String>>> dei = {')
    for chiave, blocco in zip(SCHEDE_DEI, tre):
        out.append(f'    {dart(chiave)}: {{')
        pezzi = re.split(r'^\*\*(\S+?),.*?\*\*\s*$', blocco, flags=re.M)
        visti = set()
        for i in range(1, len(pezzi), 2):
            nome = DEI[pezzi[i]]
            f = frasi(pezzi[i + 1])
            assert len(f) >= 3, (chiave, nome)
            visti.add(nome)
            out.append(f'      {dart(nome)}: [')
            out += [f'        {dart(x)},' for x in f]
            out.append('      ],')
        assert len(visti) == 10, (chiave, visti)
        out.append('    },')
    out.append('  };')
    out.append('')
    out.append('  /// La spiegazione di una riga di ognuno dei Dieci Dei.')
    out.append('  static const Map<String, String> spiegazioni = {')
    out += [f'    {dart(k)}: {dart(v)},' for k, v in spiegazioni.items()]
    out.append('  };')
    out.append('')
    colore = re.search(r'### 4\.1.*?(?=### 4\.2)', quattro, re.S).group(0)
    out.append('  /// La riga del colore e dei numeri.')
    out.append('  static const List<String> coloreENumeri = [')
    out += [f'    {dart(x)},' for x in frasi(colore)]
    out.append('  ];')
    direzione = re.search(r'### 4\.2.*?(?=### 4\.3)', quattro, re.S).group(0)
    gen = re.search(r'Generale:\s*\n(.*?)(?=\nFortuna:)', direzione, re.S).group(1)
    fort = re.search(r'Fortuna:\s*\n(.*?)(?=\n\n|\Z)', direzione, re.S).group(1)
    out.append('  static const List<String> direzioneGioia = [')
    out += [f'    {dart(x)},' for x in frasi(gen)]
    out.append('  ];')
    out.append('  static const List<String> direzioneRicchezza = [')
    out += [f'    {dart(x)},' for x in frasi(fort)]
    out.append('  ];')
    nota = re.search(r'### 4\.3.*', quattro, re.S).group(0)
    note = re.findall(r'^- (\w+(?:, \w+)*): "(.+)"\s*$', nota, re.M)
    assert len(note) == 3, note
    for (chi, frase), nome in zip(note, ['notaGenerale', 'notaDei', 'notaColore']):
        out.append(f'  static const String {nome} = {dart(frase)};')
    out.append('}')
    return '\n'.join(out) + '\n'


def formattato(testo: str) -> str:
    """Il file come lo lascia `dart format`: e' cosi' che sta nel repo."""
    # Dentro il pacchetto, non in una cartella temporanea: fuori dal
    # pacchetto `dart format` usa l'ultima versione del linguaggio e
    # formatta in un altro stile.
    f = RADICE / 'tool' / '_formato_oroscopo_cinese.dart'
    try:
        f.write_text(testo, encoding='utf-8', newline='\n')
        subprocess.run(['dart', 'format', str(f)], check=True,
                       capture_output=True, shell=sys.platform == 'win32')
        return f.read_text(encoding='utf-8')
    finally:
        f.unlink(missing_ok=True)


def main() -> None:
    nuovo = formattato(componi())
    if '--prova' in sys.argv:
        vecchio = USCITA.read_text(encoding='utf-8') if USCITA.exists() else ''
        print('uguale' if vecchio == nuovo else 'DIVERSO')
        sys.exit(0 if vecchio == nuovo else 1)
    USCITA.write_text(nuovo, encoding='utf-8', newline='\n')
    print('scritto', USCITA)


if __name__ == '__main__':
    main()
