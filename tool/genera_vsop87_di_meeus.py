"""GENERA LE TABELLE DEI PIANETI DI MEEUS. Ordine FD voce 02.

Scrive `lib/core/astro/meeus/le_tabelle_dei_pianeti.dart` con:

- la teoria VSOP87 (Bretagnon e Francou 1988, la versione D: eclittica e
  equinozio della data) per la Terra e i sette pianeti da Mercurio a
  Nettuno, la stessa che Meeus, *Astronomical Algorithms*, seconda edizione,
  usa nel capitolo 32 e riporta troncata nell'Appendice III;
- la teoria di Plutone del capitolo 37 di Meeus (43 termini, valida dal
  1885 al 2099).

La fonte dei coefficienti e' il pacchetto pymeeus (Dagoberto Salazar), che
porta il VSOP87 intero. **Il troncamento e' una soglia dichiarata**: si
tengono i termini con l'ampiezza A di almeno SOGLIA, nell'unita' delle
tabelle (1e-8 radianti per L e B, 1e-8 unita' astronomiche per R). Con 50,
misurato il 5 ottobre 2026 dal 1900 al 2100 ogni 22 giorni, la longitudine
geocentrica si scosta da quella del VSOP87 intero al massimo di 4,3 secondi
d'arco (Marte); vedi `docs/collaudo/FD/il_troncamento_del_vsop87.txt`.

Uso: python tool/genera_vsop87_di_meeus.py
"""
import importlib
import io
import os

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
USCITA = os.path.join(RADICE, 'lib', 'core', 'astro', 'meeus', 'le_tabelle_dei_pianeti.dart')
SOGLIA = 50.0
# La Terra si tiene intera: da lei vengono il Sole, che la Rivoluzione Solare
# vuole al secondo d'arco, e il punto di vista di ogni pianeta.
SOGLIA_DELLA_TERRA = 0.0
PRIMO_ANNO_DT = 1899
ULTIMO_ANNO_DT = 2101

PIANETI = [('terra', 'Earth'), ('mercurio', 'Mercury'), ('venere', 'Venus'),
           ('marte', 'Mars'), ('giove', 'Jupiter'), ('saturno', 'Saturn'),
           ('urano', 'Uranus'), ('nettuno', 'Neptune')]


def numero(x):
    s = repr(float(x))
    return s


def serie_dart(tab, soglia):
    righe = []
    for s in tab:
        termini = [t for t in s if t[0] >= soglia]
        corpo = ', '.join('[%s, %s, %s]' % (numero(a), numero(b), numero(c)) for a, b, c in termini)
        righe.append('    [%s],' % corpo)
    return '\n'.join(righe), sum(1 for s in tab for t in s if t[0] >= soglia)


def main():
    out = io.StringIO()
    out.write('// GENERATO DA tool/genera_vsop87_di_meeus.py, NON SI MODIFICA A MANO.\n')
    out.write('// Ordine FD voce 02. Fonte dei coefficienti: pymeeus (VSOP87D intero e\n')
    out.write('// Meeus capitolo 37), troncati alla soglia A >= %s; la Terra intera.\n' % numero(SOGLIA))
    out.write('// ignore_for_file: lines_longer_than_80_chars\n\n')
    out.write('/// Le serie VSOP87D di un corpo: L, B, R, ciascuna in potenze di tau, ogni\n')
    out.write('/// termine [A, B, C] vale A cos(B + C tau).\n')
    out.write('typedef SerieVsop = List<List<List<double>>>;\n\n')
    totale = 0
    for nome, modulo in PIANETI:
        m = importlib.import_module('pymeeus.' + modulo)
        for lettera, tab in (('L', m.VSOP87_L), ('B', m.VSOP87_B), ('R', m.VSOP87_R)):
            testo, n = serie_dart(tab, SOGLIA_DELLA_TERRA if nome == 'terra' else SOGLIA)
            totale += n
            out.write('/// %s, serie %s del VSOP87D, %d termini.\n' % (modulo, lettera, n))
            out.write('const SerieVsop vsop%s%s = [\n%s\n];\n\n' % (nome[0].upper() + nome[1:], lettera, testo))
    p = importlib.import_module('pymeeus.Pluto')
    out.write('/// Plutone, Meeus capitolo 37: gli argomenti [i, j, k] di J, S, P.\n')
    out.write('const List<List<int>> plutoneArgomenti = [\n')
    out.write('\n'.join('  [%d, %d, %d],' % tuple(a) for a in p.PLUTO_ARGUMENT))
    out.write('\n];\n\n')
    for nome, tab in (('Longitudine', p.PLUTO_LONGITUDE), ('Latitudine', p.PLUTO_LATITUDE),
                      ('Raggio', p.PLUTO_RADIUS_VECTOR)):
        out.write('/// Plutone, Meeus capitolo 37: %s, coppie [A seno, B coseno].\n' % nome.lower())
        out.write('const List<List<double>> plutone%s = [\n' % nome)
        out.write('\n'.join('  [%s, %s],' % (numero(a), numero(b)) for a, b in tab))
        out.write('\n];\n\n')
    luna = importlib.import_module('pymeeus.Moon')
    out.write('/// La Luna, Meeus tabella 47.B: D, M, M1, F e il coefficiente del seno\n')
    out.write('/// della latitudine, in milionesimi di grado.\n')
    out.write('const List<List<int>> lunaLatitudine = [\n')
    out.write('\n'.join('  [%d, %d, %d, %d, %d],' % tuple(int(v) for v in t)
                        for t in luna.PERIODIC_TERMS_B_TABLE))
    out.write('\n];\n\n')
    # IL DELTA T ANNO PER ANNO, Meeus cap. 10: una tabella di valori misurati,
    # non un polinomio. Dal timescale di skyfield: i valori dell'IERS fino a
    # oggi e, dopo, il modello a lungo termine di Morrison, Stephenson,
    # Hohenkerk e Zawilski (2021), lo stesso che usano i riferimenti del JPL.
    from skyfield.api import load
    ts = load.timescale()
    anni = range(PRIMO_ANNO_DT, ULTIMO_ANNO_DT + 1)
    valori = [float(ts.utc(a, 1, 1).delta_t) for a in anni]
    out.write('/// Il Delta T al 1 gennaio di ogni anno dal %d al %d, in secondi\n'
              % (PRIMO_ANNO_DT, ULTIMO_ANNO_DT))
    out.write('/// (Meeus cap. 10): IERS fino a oggi, poi il modello a lungo termine\n')
    out.write('/// di Morrison, Stephenson, Hohenkerk e Zawilski (2021), da skyfield.\n')
    out.write('const int primoAnnoDelDeltaT = %d;\n' % PRIMO_ANNO_DT)
    out.write('const List<double> deltaTAnnuale = [\n')
    out.write('\n'.join('  %.3f, // %d' % (v, a) for a, v in zip(anni, valori)))
    out.write('\n];\n\n')
    os.makedirs(os.path.dirname(USCITA), exist_ok=True)
    io.open(USCITA, 'w', encoding='utf-8', newline='\n').write(out.getvalue())
    print('scritto %s: %d termini VSOP87, %d di Plutone' % (USCITA, totale, len(p.PLUTO_ARGUMENT)))


if __name__ == '__main__':
    main()
