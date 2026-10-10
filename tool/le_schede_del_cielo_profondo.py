"""LE SCHEDE DEL CIELO PROFONDO, dal corpus al codice. Ordine FH parte 10.

Legge docs/corpus/cielo_profondo.md, il corpus dell'Architetto del 9 ottobre
2026, e scrive lib/core/astro/real_time_cosmo/le_schede_del_cielo_profondo.dart.
Il testo NON si riscrive: le righe di ogni paragrafo si uniscono con uno
spazio e basta. Per cambiare una scheda si cambia il corpus e si rilancia:

    python tool/le_schede_del_cielo_profondo.py

La riga pratica del corpus ha due parti: la prima frase e' la FORMA, che il
motore compone dai dati del momento (voce 10.4), e il resto e' un fatto della
stagione, che si legge cosi' com'e'. "sorgono" nella forma dice che il nome
e' plurale.
"""

import io
import re
import sys

CORPUS = 'docs/corpus/cielo_profondo.md'
USCITA = 'lib/core/astro/real_time_cosmo/le_schede_del_cielo_profondo.dart'

# Il titolo del corpus e l'id dell'oggetto in kCieloProfondo.
ID = {
    'Le Pleiadi': 'm45',
    'La Nebulosa di Orione': 'm42',
    'La Galassia di Andromeda': 'm31',
    'La Nebulosa Laguna': 'm8',
    'Il Doppio Ammasso del Perseo': 'h_chi',
}

PARTI = ['Apertura.', 'Il fatto.', 'Il fatto umano.', 'La riga pratica.']


def leggi():
    testo = io.open(CORPUS, encoding='utf-8').read().replace('\r\n', '\n')
    schede = []
    for blocco in re.split(r'\n## ', testo)[1:]:
        righe = blocco.split('\n')
        titolo = righe[0].strip()
        if titolo not in ID:
            continue
        paragrafi = []
        corrente = []
        for r in righe[1:]:
            r = r.strip()
            if r == '---':
                break
            if not r:
                if corrente:
                    paragrafi.append(' '.join(corrente))
                    corrente = []
                continue
            corrente.append(r)
        if corrente:
            paragrafi.append(' '.join(corrente))
        parti = {}
        for p in paragrafi:
            for nome in PARTI:
                capo = '**' + nome + '**'
                if p.startswith(capo):
                    parti[nome] = p[len(capo):].strip()
        mancano = [n for n in PARTI if n not in parti]
        if mancano:
            sys.exit('%s: mancano %s' % (titolo, mancano))
        pratica = parti['La riga pratica.']
        punto = pratica.index('. ') + 1
        forma, stagione = pratica[:punto], pratica[punto:].strip()
        schede.append({
            'id': ID[titolo],
            'titolo': titolo,
            'apertura': parti['Apertura.'],
            'fatto': parti['Il fatto.'],
            'fattoUmano': parti['Il fatto umano.'],
            'forma': forma,
            'stagione': stagione,
            'plurale': 'sorgono' in forma,
        })
    if len(schede) != len(ID):
        sys.exit('schede lette %d invece di %d' % (len(schede), len(ID)))
    return schede


def dart(s):
    return "'" + s.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$') + "'"


def scrivi(schede):
    o = []
    o.append('// GENERATO da tool/le_schede_del_cielo_profondo.py dal corpus')
    o.append('// docs/corpus/cielo_profondo.md. Non si modifica a mano: si cambia il')
    o.append('// corpus e si rilancia il generatore (ordine FH parte 10).')
    o.append('')
    o.append('/// Una scheda del cielo profondo, nelle quattro parti del corpus.')
    o.append('class SchedaDelCieloProfondo {')
    o.append('  const SchedaDelCieloProfondo({')
    for c in ['id', 'titolo', 'apertura', 'fatto', 'fattoUmano', 'forma', 'stagione', 'plurale']:
        o.append('    required this.%s,' % c)
    o.append('  });')
    o.append('')
    o.append("  /// L'id dell'oggetto in kCieloProfondo.")
    o.append('  final String id;')
    o.append('  final String titolo, apertura, fatto, fattoUmano;')
    o.append('')
    o.append('  /// La forma della riga pratica, che compone il motore (voce 10.4).')
    o.append('  final String forma;')
    o.append('')
    o.append('  /// Il fatto della stagione, che segue la riga pratica.')
    o.append('  final String stagione;')
    o.append('')
    o.append('  /// Il nome e\' plurale: "sorgono", "alte".')
    o.append('  final bool plurale;')
    o.append('}')
    o.append('')
    o.append('const List<SchedaDelCieloProfondo> kSchedeDelCieloProfondo = [')
    for s in schede:
        o.append('  SchedaDelCieloProfondo(')
        for c in ['id', 'titolo', 'apertura', 'fatto', 'fattoUmano', 'forma', 'stagione']:
            o.append('    %s: %s,' % (c, dart(s[c])))
        o.append('    plurale: %s,' % ('true' if s['plurale'] else 'false'))
        o.append('  ),')
    o.append('];')
    o.append('')
    io.open(USCITA, 'w', encoding='utf-8', newline='\n').write('\n'.join(o))


if __name__ == '__main__':
    s = leggi()
    scrivi(s)
    print('schede scritte: %d' % len(s))
