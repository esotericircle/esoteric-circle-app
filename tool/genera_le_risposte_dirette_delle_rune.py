# -*- coding: utf-8 -*-
"""GENERA LE RISPOSTE DIRETTE DELLE RUNE. Ordine GA voce GA.06, la cura delle
Rune di Caligo, 21 ottobre 2026.

Legge docs/corpus/rune/diretta.md e azione.md (la forma e le regole in
tool/controlla_le_risposte_dirette_delle_rune.py) e scrive
lib/core/rituals/le_risposte_dirette.g.dart, carattere per carattere. Prima
di generare, controlla: se lo strumento trova un difetto, non scrive niente.

  python tool/genera_le_risposte_dirette_delle_rune.py
"""
import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import controlla_le_risposte_dirette_delle_rune as dirette  # noqa: E402

RADICE = dirette.RADICE
USCITA = RADICE / 'lib/core/rituals/le_risposte_dirette.g.dart'


def dart_stringa(s):
    return "'" + s.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$') + "'"


def main():
    corpus = {c: dirette.leggi(c)[0] for c in dirette.CAMPI}
    # --parziale: durante la scrittura, i soli gruppi gia' scritti (il
    # compositore torna alla forma di prima dove un gruppo manca). La
    # consegna si genera sempre senza.
    parziale = '--parziale' in sys.argv
    difetti = dirette.controlla(corpus, attesi_completi=not parziale)
    if difetti:
        print(f'difetti: {len(difetti)}: non scrivo niente')
        for d in difetti[:40]:
            print('  ' + d)
        return 1
    righe = [
        '// GENERATO da tool/genera_le_risposte_dirette_delle_rune.py: non '
        'modificare a mano.',
        '// I testi stanno in docs/corpus/rune/diretta.md e azione.md (ordine '
        'GA voce GA.06).',
        '',
        '/// Le risposte dirette delle rune: per campo (`diretta`, il paragrafo',
        '/// della risposta; `azione`, il riquadro "Cosa fare adesso"), per',
        '/// gruppo `runa/verso/tipo`, le voci.',
        'const Map<String, Map<String, List<String>>> leRisposteDirette = {',
    ]
    for campo in dirette.CAMPI:
        righe.append(f"  '{campo}': {{")
        for g in dirette.gruppi_attesi():
            if g not in corpus[campo]:
                continue
            righe.append(f"    '{g}': [")
            for v in corpus[campo][g]:
                righe.append(f'      {dart_stringa(v)},')
            righe.append('    ],')
        righe.append('  },')
    righe.append('};')
    USCITA.write_text('\n'.join(righe) + '\n', encoding='utf-8', newline='')
    print(f'{USCITA.relative_to(RADICE)}: scritto')
    return 0


if __name__ == '__main__':
    sys.stdout.reconfigure(encoding='utf-8')
    sys.exit(main())
