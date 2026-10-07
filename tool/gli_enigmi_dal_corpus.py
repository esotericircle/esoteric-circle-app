"""GLI ENIGMI DEL CERCHIO DAL CORPUS. Ordine FF, parti seconda e quinta.

Legge i due corpora dell'Architetto, che non si toccano:
- docs/corpus/Corpus_Il_Ritratto.md, le 120 caratteristiche;
- docs/corpus/Corpus_Le_Prove.md, i sei temi delle Prove;
e scrive i dati per il telefono e per il server:
- lib/core/cerchio/il_ritratto_del_corpus.g.dart
- functions/src/il_ritratto_del_corpus.ts
- lib/core/cerchio/le_prove_del_corpus.g.dart
- functions/src/le_prove_del_corpus.ts

Il codice non si scrive a mano: un corpus cambiato si rigenera da qui.
Si ferma (e non scrive niente) se il corpus non rispetta la forma che il
codice pretende: 120 voci numerate, un elemento ciascuna, dodici domande da
quattro risposte coi pesi 0-3, quattro fasce da 0 a 100 per tema.

Uso: python tool/gli_enigmi_dal_corpus.py
"""
import io
import os
import re
import sys

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(RADICE)

ELEMENTI = ['fuoco', 'terra', 'aria', 'acqua', 'libera']


def leggi(p):
    return ricomponi_le_marche(io.open(p, encoding='utf-8').read())


MARCA = re.compile(r'\[[^\[\]]*\|[^\[\]]*\]')


def ricomponi_le_marche(t):
    """Una marca che il markdown manda a capo si rimette su una riga:
    l'a capo e il rientro dentro le quadre diventano uno spazio. Non cambia
    una parola del corpus: e' l'impaginazione del file."""
    return MARCA.sub(lambda m: re.sub(r'\s*\n\s*', ' ', m.group(0)), t)


def marche_di(testo):
    """Le marche di un testo; si ferma se una e' malformata: tre campi, mai
    vuoti, nell'ordine [maschile|femminile|neutro]."""
    trovate = MARCA.findall(testo)
    for m in trovate:
        campi = m[1:-1].split('|')
        if len(campi) != 3 or any(not c.strip() for c in campi):
            raise SystemExit('MARCA MALFORMATA: %s' % m)
    return trovate


def scrivi(p, s):
    io.open(p, 'w', encoding='utf-8', newline='\n').write(s)


def dart(s):
    """Una stringa Dart fra apici singoli."""
    return "'" + s.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$') + "'"


def ts(s):
    return '"' + s.replace('\\', '\\\\').replace('"', '\\"') + '"'


def il_ritratto():
    t = leggi('docs/corpus/Corpus_Il_Ritratto.md')
    sezione = None
    voci = []
    for riga in t.splitlines():
        m = re.match(r'^## (.+)$', riga)
        if m:
            sezione = m.group(1).strip()
            continue
        m = re.match(r'^(\d+)\. (.+?) \[([a-z]+)\]\s*$', riga)
        if m:
            voci.append((int(m.group(1)), m.group(2).strip(), m.group(3), sezione))
    errori = []
    if [v[0] for v in voci] != list(range(1, 121)):
        errori.append('le voci non sono numerate da 1 a 120')
    for v in voci:
        if v[2] not in ELEMENTI:
            errori.append('voce %d: elemento %s' % (v[0], v[2]))
    if errori:
        raise SystemExit('RITRATTO: ' + '; '.join(errori))
    conto = {e: sum(1 for v in voci if v[2] == e) for e in ELEMENTI}
    conto['tratti marcati'] = sum(1 for v in voci if marche_di(v[1]))
    conto['marche'] = sum(len(marche_di(v[1])) for v in voci)
    sezioni = []
    for v in voci:
        if v[3] not in sezioni:
            sezioni.append(v[3])

    d = ['// GENERATO da tool/gli_enigmi_dal_corpus.py su',
         '// docs/corpus/Corpus_Il_Ritratto.md. Non si modifica a mano.',
         '// ignore_for_file: lines_longer_than_80_chars',
         '',
         "import 'il_ritratto.dart';",
         '',
         '/// Le sezioni del corpus, nell\'ordine del corpus.',
         'const List<String> sezioniDelRitratto = [']
    for s in sezioni:
        d.append('  %s,' % dart(s))
    d.append('];')
    d.append('')
    d.append('/// Le 120 caratteristiche: fuoco %(fuoco)d, terra %(terra)d, '
             'aria %(aria)d, acqua %(acqua)d, libere %(libera)d; '
             '%(tratti marcati)d marcate, %(marche)d marche del genere.' % conto)
    d.append('const List<TrattoDelRitratto> trattiDelCorpus = [')
    for n, testo, el, sez in voci:
        d.append('  TrattoDelRitratto(%d, %s, ElementoDelTratto.%s, %d),'
                 % (n, dart(testo), el, sezioni.index(sez)))
    d.append('];')
    scrivi('lib/core/cerchio/il_ritratto_del_corpus.g.dart', '\n'.join(d) + '\n')

    s = ['// GENERATO da tool/gli_enigmi_dal_corpus.py su',
         '// docs/corpus/Corpus_Il_Ritratto.md. Non si modifica a mano.',
         '',
         '/** L\'elemento di ogni caratteristica, per numero (1-120). */',
         'export const ELEMENTI_DEL_RITRATTO: Record<number, string> = {']
    for n, _, el, _ in voci:
        s.append('  %d: %s,' % (n, ts(el)))
    s.append('};')
    scrivi('functions/src/il_ritratto_del_corpus.ts', '\n'.join(s) + '\n')
    return conto


def le_prove():
    t = leggi('docs/corpus/Corpus_Le_Prove.md')
    temi = []
    for blocco in re.split(r'^# TEMA ', t, flags=re.M)[1:]:
        righe = blocco.splitlines()
        m = re.match(r'^(\d+)\. (.+)$', righe[0])
        numero, nome = int(m.group(1)), m.group(2).strip()
        corpo = '\n'.join(righe[1:])
        intro = corpo.split('\n\nD1.')[0].strip()
        domande = []
        for dm in re.finditer(r'^D(\d+)\. (.+?)\n((?:\s+[a-d]\) .+\n?)+)', corpo, re.M):
            risposte = re.findall(r'^\s+([a-d])\) (.+?) \[(\d)\]\s*$', dm.group(3), re.M)
            domande.append((int(dm.group(1)), dm.group(2).strip(),
                            [(r[1].strip(), int(r[2])) for r in risposte]))
        fasce_testo = corpo.split('FASCE', 1)[1].split('\n---')[0]
        fasce = []
        for fm in re.finditer(r'^(\d+)-(\d+) \*\*(.+?)\*\* (.+?)(?=^\d+-\d+ \*\*|\Z)',
                              fasce_testo, re.M | re.S):
            fasce.append((int(fm.group(1)), int(fm.group(2)), fm.group(3).strip().rstrip('.'),
                          re.sub(r'\s*\n\s*', ' ', fm.group(4)).strip()))
        temi.append((numero, nome, intro, domande, fasce))
    errori = []
    if [x[0] for x in temi] != list(range(1, 7)):
        errori.append('i temi non sono sei, numerati da 1')
    for numero, nome, _, domande, fasce in temi:
        if [d[0] for d in domande] != list(range(1, 13)):
            errori.append('tema %d: le domande non sono dodici' % numero)
        for d in domande:
            if sorted(p for _, p in d[2]) != [0, 1, 2, 3]:
                errori.append('tema %d D%d: pesi %s' % (numero, d[0], [p for _, p in d[2]]))
        if [(f[0], f[1]) for f in fasce] != [(0, 25), (26, 50), (51, 75), (76, 100)]:
            errori.append('tema %d: fasce %s' % (numero, [(f[0], f[1]) for f in fasce]))
    if errori:
        raise SystemExit('PROVE: ' + '; '.join(errori))

    d = ['// GENERATO da tool/gli_enigmi_dal_corpus.py su',
         '// docs/corpus/Corpus_Le_Prove.md. Non si modifica a mano.',
         '// ignore_for_file: lines_longer_than_80_chars',
         '',
         "import 'la_prova.dart';",
         '',
         '/// I sei temi, nell\'ordine dei criteri del cielo.',
         'const List<TemaDellaProva> temiDelCorpus = [']
    for numero, nome, intro, domande, fasce in temi:
        d.append('  TemaDellaProva(')
        d.append('    numero: %d,' % numero)
        d.append('    nome: %s,' % dart(nome.capitalize() if nome.isupper() else nome))
        d.append('    domande: [')
        for n, testo, risposte in domande:
            d.append('      DomandaDellaProva(%d, %s, [' % (n, dart(testo)))
            for rt, p in risposte:
                d.append('        RispostaDellaProva(%s, %d),' % (dart(rt), p))
            d.append('      ]),')
        d.append('    ],')
        d.append('    fasce: [')
        for da, a, figura, testo in fasce:
            d.append('      FasciaDellaProva(%d, %d, %s, %s),' % (da, a, dart(figura), dart(testo)))
        d.append('    ],')
        d.append('  ),')
    d.append('];')
    scrivi('lib/core/cerchio/le_prove_del_corpus.g.dart', '\n'.join(d) + '\n')

    s = ['// GENERATO da tool/gli_enigmi_dal_corpus.py su',
         '// docs/corpus/Corpus_Le_Prove.md. Non si modifica a mano.',
         '',
         '/** Per ogni tema (1-6), i pesi delle quattro risposte di ogni domanda (D1-D12). */',
         'export const PESI_DELLE_PROVE: Record<number, number[][]> = {']
    for numero, _, _, domande, _ in temi:
        s.append('  %d: [%s],' % (numero, ', '.join(
            '[%s]' % ', '.join(str(p) for _, p in d[2]) for d in domande)))
    s.append('};')
    s.append('')
    s.append('/** Le figure delle quattro fasce di ogni tema: da, a, nome. */')
    s.append('export const FASCE_DELLE_PROVE: Record<number, [number, number, string][]> = {')
    for numero, _, _, _, fasce in temi:
        s.append('  %d: [%s],' % (numero, ', '.join(
            '[%d, %d, %s]' % (f[0], f[1], ts(f[2])) for f in fasce)))
    s.append('};')
    scrivi('functions/src/le_prove_del_corpus.ts', '\n'.join(s) + '\n')
    conti = []
    for numero, nome, intro, domande, fasce in temi:
        testi = [d[1] for d in domande] + \
            [r[0] for d in domande for r in d[2]] + \
            [f[2] + ' ' + f[3] for f in fasce]
        risposte = sum(len(d[2]) for d in domande)
        conti.append((numero, len(domande), risposte, len(fasce), risposte,
                      sum(len(marche_di(x)) for x in testi)))
    for c in conti:
        print('  tema %d: domande %d, risposte %d, fasce %d, pesi %d, marche %d' % c)
    print('  totale: pesi %d, marche %d' % (sum(c[4] for c in conti),
                                           sum(c[5] for c in conti)))
    return len(temi)


if __name__ == '__main__':
    quale = sys.argv[1:] or ['ritratto', 'prove']
    if 'ritratto' in quale:
        print('RITRATTO:', il_ritratto())
    if 'prove' in quale:
        print('PROVE: temi', le_prove())
