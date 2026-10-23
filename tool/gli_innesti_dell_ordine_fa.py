"""LA REGOLA A DELL'ORDINE FA: ogni prova nuova vista rossa sul suo difetto.

Per ogni innesto: copia del file, il difetto messo a mano, il controllo che
l'innesto sia ENTRATO (il pezzo nuovo c'e', il vecchio no), la prova fatta
girare, l'esito letto, il file rimesso dalla copia e confrontato al byte.
Stessa forma del banco dell'ordine EY (`gli_innesti_dell_ordine_ey.py`).

Uso: python tool/gli_innesti_dell_ordine_fa.py [sigla ...]
L'esito si scrive in docs/collaudo/FA/regola_a_fa.txt (in coda).
"""
import io
import os
import shutil
import subprocess
import sys

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(RADICE)

SERVER = 'cd functions && npm test'

# sigla, voce, file, vecchio, nuovo, comando, cosa deve cadere
INNESTI = [
    ('A1', 'FA.01', 'lib/core/cerchio/le_icone_del_cerchio.dart',
     "      : '${FamigliaDelleIcone.segno.name}:${segno?.index ?? 0}';",
     "      : '${FamigliaDelleIcone.segno.name}:${segno == null ? 0 : 0}';",
     'flutter test test/gli_arcani_escono_dalle_icone_test.dart', 'FA.01'),
    ('A2', 'FA.01', 'functions/src/sociale.ts',
     '  animale: 12,\n', '  animale: 12,\n  arcano: 22,\n',
     'flutter test test/i_numeri_del_cerchio_sociale_test.dart', 'EY.03'),
    ('A3', 'FA.02', 'lib/features/cerchio/widgets/i_segni_ricevuti.dart',
     "artRouteFor('synastry_vip', userBirth: nascita)",
     "artRouteFor('sinastria_fra_amici', userBirth: nascita)",
     'flutter test test/i_segni_dicono_il_vero_test.dart', 'FA.02'),
    ('A4', 'FA.03', 'lib/features/cerchio/profilo_nel_cerchio_screen.dart',
     'onSelected: (_) => setState(() => _famiglia = f),',
     'onSelected: (_) => setState(() {}),',
     'flutter test test/le_catture_della_vetrina_sono_diverse_test.dart', 'FA.03'),
    ('A5', 'FA.04', 'lib/features/cerchio/widgets/disegni_del_cerchio.dart',
     'ElencoDelCerchio.eDoppio(context, nome);',
     "ElencoDelCerchio.eDoppio(context, '${nome}x');",
     'flutter test test/il_sigillo_quando_due_nomi_coincidono_test.dart', 'FA.04'),
    ('A6', 'FA.04', 'lib/features/cerchio/widgets/disegni_del_cerchio.dart',
     'final forma = LeRegoleDelNome.formaDelNome(p.nome);',
     'final forma = p.nome;',
     'flutter test test/il_sigillo_quando_due_nomi_coincidono_test.dart', 'FA.04'),
    ('A7', 'FA.05', 'functions/src/il_cerchio_sociale.ts',
     '    .limit(AMICI_NELLA_TENDINA)\n', '',
     'flutter test test/la_tendina_non_supera_dieci_letture_test.dart', 'FA.05'),
    ('A8', 'FA.05', 'functions/src/il_cerchio_sociale.ts',
     '  const esclusi = new Set<string>([...amici, ...blocchi]);',
     '  await Promise.all([...amici].map((a) => profiloDi(a).get()));\n'
     '  const esclusi = new Set<string>([...amici, ...blocchi]);',
     'flutter test test/la_tendina_non_supera_dieci_letture_test.dart', 'FA.05'),
    ('A9', 'FA.05', 'functions/src/sociale.ts',
     'export const AMICI_NELLA_TENDINA = 6;',
     'export const AMICI_NELLA_TENDINA = 8;',
     'flutter test test/la_tendina_non_supera_dieci_letture_test.dart', 'FA.05'),
    ('A10', 'FA.06', 'lib/core/cerchio/i_segni_del_cerchio.dart',
     "rigaDiChiRiceve: 'Qualcuno ha visto quanta strada hai fatto.',",
     "rigaDiChiRiceve: 'Qualcuno ha visto quanto sei arrivato lontano.',",
     'flutter test test/i_segni_dicono_il_vero_test.dart', 'FA.06'),
    ('A11', 'FA.02', 'lib/core/cerchio/i_segni_del_cerchio.dart',
     "testo: 'Sfidami con un VIP',",
     "testo: 'Facciamo la sinastria',",
     'flutter test test/i_segni_dicono_il_vero_test.dart', 'FA.02'),
    ('A12', 'FA', 'docs/ordini/ORDINE_FA_MANIFESTO.md',
     'VOCI_CHIUSE: 4\n', 'VOCI_CHIUSE: 5\n',
     'flutter test test/ordine_fa_guard_test.dart', 'ogni voce'),
]


def leggi(p):
    return io.open(p, encoding='utf-8', newline='').read()


def scrivi(p, s):
    io.open(p, 'w', encoding='utf-8', newline='').write(s)


def un_innesto(sigla, voce, percorso, vecchio, nuovo, comando, cade):
    copia = percorso + '.copia_regola_a'
    shutil.copyfile(percorso, copia)
    try:
        dati = leggi(percorso)
        crlf = '\r\n' in dati
        testo = dati.replace('\r\n', '\n')
        n = testo.count(vecchio)
        if n != 1:
            return '%s (%s) INNESTO NON ENTRATO: il pezzo vecchio compare %d volte' % (sigla, voce, n)
        testo = testo.replace(vecchio, nuovo)
        scrivi(percorso, testo.replace('\n', '\r\n') if crlf else testo)
        dopo = leggi(percorso).replace('\r\n', '\n')
        if nuovo and vecchio in nuovo:
            entrato = dopo.count(nuovo) == 1
        else:
            entrato = (nuovo in dopo if nuovo else True) and dopo.count(vecchio) == 0
        if not entrato:
            return '%s (%s) INNESTO NON ENTRATO al controllo' % (sigla, voce)
        esito = subprocess.run(comando, shell=True, capture_output=True,
                               text=True, encoding='utf-8', errors='replace')
        uscita = esito.stdout + esito.stderr
        rossa = esito.returncode != 0
        nomi = [r.strip()[:150] for r in uscita.splitlines()
                if ('[E]' in r or r.strip().startswith('not ok') or '✖' in r)][:3]
        misure = [r.strip()[:200] for r in uscita.splitlines()
                  if r.startswith('FA.0') or r.startswith('EY.03')][:3]
        return ('%s (%s) %s: innesto entrato (grep del pezzo nuovo 1, del vecchio 0); '
                '%s; cadute: %s; misure lette: %s') % (
                    sigla, voce, percorso,
                    'ROSSA' if rossa else 'VERDE (la prova NON vede il difetto)',
                    ' | '.join(nomi) if nomi else '(nessuna riga di caduta letta)',
                    ' | '.join(misure) if misure else '(nessuna)')
    finally:
        shutil.copyfile(copia, percorso)
        os.remove(copia)


def main():
    scelte = set(sys.argv[1:])
    os.makedirs('docs/collaudo/FA', exist_ok=True)
    registro = 'docs/collaudo/FA/regola_a_fa.txt'
    for innesto in INNESTI:
        if scelte and innesto[0] not in scelte:
            continue
        prima = open(innesto[2], 'rb').read()
        riga = un_innesto(*innesto)
        dopo = open(innesto[2], 'rb').read()
        riga += '; file rimesso dalla copia: %s.' % (
            'uguale al byte (cmp)' if prima == dopo else 'DIVERSO, CONTROLLARE')
        print(riga, flush=True)
        with io.open(registro, 'a', encoding='utf-8', newline='\n') as f:
            f.write(riga + '\n')


if __name__ == '__main__':
    main()
