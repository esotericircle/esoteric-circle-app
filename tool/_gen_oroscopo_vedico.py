# -*- coding: utf-8 -*-
"""Rigenera lib/core/horoscope/oroscopo_vedico_data.dart da docs/corpus/oroscopo_vedico.md.

Ordine ES voce 09. La fonte di verita' e' il corpus; il file dart non si
tocca a mano.

Uso, dalla radice del repository:
    python tool/_gen_oroscopo_vedico.py            # scrive il file
    python tool/_gen_oroscopo_vedico.py --prova    # non scrive: confronta col file in vigore
"""
from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

RADICE = Path(__file__).resolve().parent.parent
CORPUS = RADICE / 'docs' / 'corpus' / 'oroscopo_vedico.md'
USCITA = RADICE / 'lib' / 'core' / 'horoscope' / 'oroscopo_vedico_data.dart'

GIORNI = ['Domenica', 'Lunedì', 'Martedì', 'Mercoledì', 'Giovedì',
          'Venerdì', 'Sabato']


def dart(testo: str) -> str:
    return "'" + testo.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$') + "'"


def frasi(blocco: str) -> list[str]:
    """Le frasi numerate, anche su piu' righe (le righe dopo sono rientrate)."""
    uscita = []
    corrente = None
    for riga in blocco.splitlines():
        m = re.match(r'^\d+\.\s+(.+)$', riga)
        if m:
            if corrente is not None:
                uscita.append(corrente)
            corrente = m.group(1).strip()
        elif corrente is not None and riga.startswith('   ') and riga.strip():
            corrente += ' ' + riga.strip()
        elif corrente is not None:
            uscita.append(corrente)
            corrente = None
    if corrente is not None:
        uscita.append(corrente)
    return uscita


def paragrafo(testo: str, numero: str) -> str:
    m = re.search(r'^## ' + re.escape(numero) + r'\. .*?(?=^## |\Z)', testo, re.M | re.S)
    assert m, numero
    return m.group(0)


def sottosezioni(testo: str) -> list[tuple[str, str]]:
    """(titolo, blocco) di ogni '### ' del paragrafo."""
    parti = re.split(r'^### (.*)$', testo, flags=re.M)
    return [(parti[i].strip(), parti[i + 1]) for i in range(1, len(parti), 2)]


def per_casa(testo: str) -> list[list[str]]:
    """Il gruppo di frasi per ogni casa da 1 a 12, dai titoli '(h = ...)'."""
    case: list[list[str] | None] = [None] * 12
    for titolo, blocco in sottosezioni(testo):
        m = re.search(r'\(h = ([\d, ]+)\)', titolo)
        assert m, titolo
        f = frasi(blocco)
        assert len(f) >= 3, titolo
        for h in m.group(1).split(','):
            i = int(h) - 1
            assert case[i] is None, (titolo, h)
            case[i] = f
    assert all(c is not None for c in case), case
    return case  # type: ignore[return-value]


def lista(nome: str, valori: list[str], doc: str) -> list[str]:
    out = [f'  /// {doc}', f'  static const List<String> {nome} = [']
    out += [f'    {dart(v)},' for v in valori]
    out.append('  ];')
    return out


def gruppi(nome: str, valori: list[list[str]], doc: str) -> list[str]:
    out = [f'  /// {doc}', f'  static const List<List<String>> {nome} = [']
    for g in valori:
        out.append('    [')
        out += [f'      {dart(v)},' for v in g]
        out.append('    ],')
    out.append('  ];')
    return out


def componi() -> str:
    t = CORPUS.read_text(encoding='utf-8').replace('\r\n', '\n')
    uno = sottosezioni(paragrafo(t, '1'))
    assert len(uno) == 12, len(uno)
    due = sottosezioni(paragrafo(t, '2'))
    assert len(due) == 9, len(due)
    tre = paragrafo(t, '3')
    giorni = {}
    for g in GIORNI:
        m = re.search(r'^- \*\*' + g + r'\*\*: (.+?)(?=^- \*\*|^\(|^###|\Z)', tre, re.M | re.S)
        assert m, g
        giorni[g] = ' '.join(m.group(1).split())
    generiche = frasi(dict(sottosezioni(tre))['Varianti generiche della stessa riga'])
    assert len(generiche) >= 3
    amore = per_casa(paragrafo(t, '4'))
    lavoro = per_casa(paragrafo(t, '5'))
    fortuna = per_casa(paragrafo(t, '6'))
    rahu = dict(sottosezioni(paragrafo(t, '7')))
    chiavi_rahu = [('Il Rahu Kalam deve ancora venire', 'rahuPrima'),
                   ('Il Rahu Kalam è in corso', 'rahuInCorso'),
                   ('Il Rahu Kalam è già passato', 'rahuPassato'),
                   ('Manca la città', 'rahuSenzaCitta')]
    glossario = [(' '.join(a.split()), b) for a, b in re.findall(
        r'^- \*\*(.+?)\*\*: (.+?)(?=^- \*\*|\Z)', paragrafo(t, '8'), re.M | re.S)]
    assert len(glossario) >= 9, glossario

    out = ['// GENERATO da tool/_gen_oroscopo_vedico.py a partire da '
           'docs/corpus/oroscopo_vedico.md.',
           "// Fonte di verita': il corpus. Non modificare a mano: rigenerare dal corpus.",
           '',
           "/// Le frasi dell'oroscopo vedico del giorno (ordine ES voce 09), trascritte",
           '/// dal corpus. Le marche del genere `[m|f|n]` si risolvono alla lettura.',
           'abstract final class OroscopoVedicoData {']
    out += gruppi('chandraBala', [frasi(b) for _, b in uno],
                  'Chandra Bala: la Luna di oggi nella casa da 1 a 12 contata dalla Luna di nascita.')
    out.append('')
    out += gruppi('taraBala', [frasi(b) for _, b in due],
                  'Tara Bala: le nove tare, da Janma a Parama Mitra.')
    out.append('')
    out += lista('righeDelGiorno', [giorni[g] for g in GIORNI],
                 'La riga del pianeta del giorno, da domenica a sabato.')
    out.append('')
    out += lista('righeDelPianeta', generiche,
                 'Le varianti generiche della riga del pianeta del giorno.')
    out.append('')
    out += gruppi('amore', amore, 'Amore: il gruppo di frasi per la casa da 1 a 12.')
    out.append('')
    out += gruppi('lavoro', lavoro, 'Lavoro: il gruppo di frasi per la casa da 1 a 12.')
    out.append('')
    out += gruppi('fortuna', fortuna, 'Fortuna: il gruppo di frasi per la casa da 1 a 12.')
    out.append('')
    for titolo, nome in chiavi_rahu:
        f = frasi(rahu[titolo])
        assert len(f) >= 3, titolo
        out += lista(nome, f, f'Rahu Kalam: {titolo[0].lower()}{titolo[1:]}.')
        out.append('')
    out.append('  /// Il glossario della nota del metodo: termine e spiegazione.')
    out.append('  static const List<(String, String)> glossario = [')
    out += [f"    ({dart(a)}, {dart(' '.join(b.split()))})," for a, b in glossario]
    out.append('  ];')
    out.append('}')
    return '\n'.join(out) + '\n'


def formattato(testo: str) -> str:
    """Il file come lo lascia `dart format`, dentro il pacchetto."""
    f = RADICE / 'tool' / '_formato_oroscopo_vedico.dart'
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
