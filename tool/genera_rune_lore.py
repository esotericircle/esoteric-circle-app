# -*- coding: utf-8 -*-
"""IL GENERATORE DEL CORPUS DELLE RUNE, e il filtro vive QUI.

Legge docs/corpus/rune.md e produce lib/core/rituals/rune_lore.g.dart: le
forme attestate, la materia, le strofe dei tre poemi runici con fonte e
traduzione, le note di assenza per le rune che il Futhark recente ha perso.

IL FILTRO DELLE PAROLE VIETATE STA NEL GENERATORE, NON A VALLE. Se una di
queste parole compare nel corpus, la generazione SI RIFIUTA e nomina runa e
parola: guarigione, salute, malattia, fertilita', longevita', vittoria,
protezione dalle armi, ricchezza, ritrovamento di tesori. Neppure quando una
fonte lo afferma: la traduzione si riformula, la promessa non entra.

Uso:  python tool/genera_rune_lore.py
"""
import io
import re
import sys

CORPUS = 'docs/corpus/rune.md'
USCITA = 'lib/core/rituals/rune_lore.g.dart'

# Le radici vietate: prendono singolare, plurale e derivati.
VIETATE = [
    'guarigion', 'salute', 'malatti', 'fertilit', 'longevit',
    'vittori', 'ricchezz', 'tesor', 'protezione dalle armi',
]


def vieta(testo, dove):
    basso = testo.lower()
    for parola in VIETATE:
        if parola in basso:
            sys.exit(f'PAROLA VIETATA "{parola}" in {dove}: il corpus non '
                     f'promette mai. Riformulare, non filtrare a valle.')


def dart(testo):
    return testo.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$')


def main():
    testo = io.open(CORPUS, encoding='utf-8').read()
    sezioni = re.split(r'\n### \d+\. ', testo)
    if len(sezioni) != 25:
        sys.exit(f'Attese 24 rune nel corpus, trovate {len(sezioni) - 1}.')

    rune = []
    for sez in sezioni[1:]:
        righe = sez.splitlines()
        nome = righe[0].strip()
        vieta(sez, nome)

        def campo(etichetta):
            for r in righe:
                if r.startswith(f'- **{etichetta}**'):
                    return r.split(':', 1)[1].strip()
            return None

        profilo = campo('Nome ricostruito')
        materia = campo('Materia attestata')
        if not profilo or not materia:
            sys.exit(f'{nome}: manca il profilo o la materia.')

        strofe = []
        for fonte in ('Old English Rune Poem', 'Old Icelandic Rune Poem',
                      'Old Norwegian Rune Rhyme'):
            for r in righe:
                if r.startswith(f'- **{fonte}**'):
                    m = re.search(
                        r'«(.+?)» Traduzione: (.+)$', r)
                    if not m:
                        sys.exit(f'{nome}: strofa {fonte} senza originale '
                                 'fra virgolette o senza traduzione.')
                    strofe.append((fonte, m.group(1).strip(),
                                   m.group(2).strip()))
        if not strofe:
            sys.exit(f'{nome}: nessuna strofa attestata, e il poema '
                     'anglosassone copre tutte e ventiquattro: manca.')

        nota = campo('Strofa norrena')
        rune.append((nome, profilo, materia, strofe, nota))

    ne_hanno_norrena = sum(1 for r in rune if len(r[3]) == 3)
    print(f'Rune col trittico completo: {ne_hanno_norrena}; '
          f'solo anglosassone: {24 - ne_hanno_norrena}.')

    out = io.StringIO()
    out.write("// GENERATO da tool/genera_rune_lore.py, NON scrivere a mano.\n")
    out.write('// Fonte: docs/corpus/rune.md. Il filtro delle parole vietate\n')
    out.write('// vive nel generatore: questo file esiste solo se il corpus\n')
    out.write('// e\' pulito.\n\n')
    out.write("/// Una strofa di un poema runico, con fonte e traduzione "
              "nostra.\n")
    out.write('class StrofaRunica {\n')
    out.write('  const StrofaRunica(this.fonte, this.originale, '
              'this.traduzione);\n')
    out.write('  final String fonte;\n  final String originale;\n'
              '  final String traduzione;\n}\n\n')
    out.write('/// La materia attestata di una runa, con le sue strofe.\n')
    out.write('class RuneLore {\n')
    out.write('  const RuneLore({\n    required this.profilo,\n'
              '    required this.materia,\n    required this.strofe,\n'
              '    this.notaNorrena,\n  });\n')
    out.write('  final String profilo;\n  final String materia;\n'
              '  final List<StrofaRunica> strofe;\n\n'
              '  /// Perche\' la strofa norrena non c\'e\', quando non c\'e\':'
              '\n  /// runa perduta dal Futhark recente, oppure continuita\''
              '\n  /// contesa. Nullo quando il trittico e\' completo.\n'
              '  final String? notaNorrena;\n}\n\n')
    out.write('const Map<String, RuneLore> kRuneLore = {\n')
    for nome, profilo, materia, strofe, nota in rune:
        out.write(f"  '{dart(nome)}': RuneLore(\n")
        out.write(f"    profilo: '{dart(profilo)}',\n")
        out.write(f"    materia: '{dart(materia)}',\n")
        out.write('    strofe: [\n')
        for fonte, orig, trad in strofe:
            out.write(f"      StrofaRunica('{dart(fonte)}', "
                      f"'{dart(orig)}', '{dart(trad)}'),\n")
        out.write('    ],\n')
        if nota:
            out.write(f"    notaNorrena: '{dart(nota)}',\n")
        out.write('  ),\n')
    out.write('};\n')

    io.open(USCITA, 'w', encoding='utf-8', newline='\n').write(out.getvalue())
    print(f'Scritto {USCITA} con {len(rune)} rune.')


if __name__ == '__main__':
    main()
