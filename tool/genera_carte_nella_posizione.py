"""Genera le carte nella loro posizione della Stesa di Medora.

Ordine EQ voce 04, 27 settembre 2026. La fonte e'
docs/corpus/tarocchi_nella_posizione.md: per ogni carta, nell'ordine del
mazzo, i due versi (dritta e capovolta) coi tre testi del passato, del
presente e del futuro. L'uscita e'
lib/core/tarot/le_carte_nella_posizione_dati.dart. Il corpus si tocca alla
fonte: si modifica il markdown e si rilancia questo script.

    python tool/genera_carte_nella_posizione.py
"""
import io
import os
import re
import sys

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CORPUS = os.path.join(RADICE, 'docs', 'corpus',
                      'tarocchi_nella_posizione.md')
USCITA = os.path.join(RADICE, 'lib', 'core', 'tarot',
                      'le_carte_nella_posizione_dati.dart')

VERSI = ('dritta', 'capovolta')
POSIZIONI = ('passato', 'presente', 'futuro')


def leggi():
    """Le carte nell'ordine del corpus: [(nome, {verso: {posizione: testo}})].

    Il corpus si legge per intero o non si legge: una carta senza un verso,
    un verso senza una posizione o una riga doppia fermano lo script, invece
    di scrivere un file dati a meta'.
    """
    testo = io.open(CORPUS, encoding='utf-8', newline='').read()
    carte = []
    carta = None
    verso = None
    for numero, riga in enumerate(testo.split('\n'), 1):
        riga = riga.rstrip('\r')
        m = re.match(r'^## (.+)$', riga)
        if m:
            carta = (m.group(1).strip(), {})
            carte.append(carta)
            verso = None
            continue
        m = re.match(r'^### (dritta|capovolta)$', riga)
        if m:
            if carta is None or m.group(1) in carta[1]:
                raise ValueError('riga %d: verso fuori posto' % numero)
            verso = m.group(1)
            carta[1][verso] = {}
            continue
        m = re.match(r'^- (passato|presente|futuro): (.+)$', riga)
        if m:
            if verso is None or m.group(1) in carta[1][verso]:
                raise ValueError('riga %d: posizione fuori posto' % numero)
            carta[1][verso][m.group(1)] = m.group(2).strip()
    nomi = [nome for nome, _ in carte]
    if len(set(nomi)) != len(nomi):
        raise ValueError('una carta compare due volte')
    for nome, versi in carte:
        for v in VERSI:
            for p in POSIZIONI:
                if p not in versi.get(v, {}):
                    raise ValueError('%s, %s: manca il %s' % (nome, v, p))
                # La guardia tarot_accordo_rovescio vieta la parola del
                # rovescio nelle stringhe dei tarocchi: si prende da
                # TarotCard.reversedWord, mai scritta a mano.
                if 'rovesciat' in versi[v][p].lower():
                    raise ValueError('%s, %s, %s: parola del rovescio nel '
                                     'testo' % (nome, v, p))
    return carte


def dart(s):
    return "'" + s.replace('\\', '\\\\').replace("'", "\\'").replace(
        '$', '\\$') + "'"


def scrivi(carte):
    righe = [
        '// GENERATO da tool/genera_carte_nella_posizione.py da '
        'docs/corpus/tarocchi_nella_posizione.md: non toccare a mano.',
        '',
        '/// Le carte nella loro posizione, la Stesa di Medora, ordine EQ '
        'voce 04.',
        '///',
        '/// Per ogni carta e verso, nell\'ordine del mazzo, i tre testi della '
        'stesa',
        '/// a tre carte: passato, presente, futuro. La chiave e\' il nome '
        'della',
        '/// carta come in `TarotCard.name`, una barra verticale e il verso, '
        '`dritta`',
        '/// oppure `capovolta`.',
        'const Map<String, List<String>> carteNellaPosizione = {',
    ]
    for nome, versi in carte:
        for v in VERSI:
            righe.append('  %s: [' % dart('%s|%s' % (nome, v)))
            for p in POSIZIONI:
                righe.append('    %s,' % dart(versi[v][p]))
            righe.append('  ],')
    righe.append('};')
    io.open(USCITA, 'w', encoding='utf-8', newline='\n').write(
        '\n'.join(righe) + '\n')


if __name__ == '__main__':
    carte = leggi()
    scrivi(carte)
    print('carte %d, chiavi %d, testi %d' % (
        len(carte), len(carte) * len(VERSI),
        len(carte) * len(VERSI) * len(POSIZIONI)))
    sys.exit(0)
