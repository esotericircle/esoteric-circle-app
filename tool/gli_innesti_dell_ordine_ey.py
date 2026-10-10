"""LA REGOLA A DELL'ORDINE EY: ogni prova nuova vista rossa sul suo difetto.

Per ogni innesto: copia del file, il difetto messo a mano, il controllo che
l'innesto sia ENTRATO (il pezzo nuovo c'e', il vecchio no), la prova fatta
girare, l'esito letto, il file rimesso dalla copia e confrontato al byte.

Uso: python tool/gli_innesti_dell_ordine_ey.py [sigla ...]
L'esito si scrive in docs/collaudo/EY/regola_a_ey.txt (in coda).
"""
import io
import os
import shutil
import subprocess
import sys

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(RADICE)

# sigla, voce, file, vecchio, nuovo, comando, cosa deve cadere
INNESTI = [
    ('A1', 'EY.01', 'functions/src/il_nome_del_cerchio.json',
     '    "Medora",\n', '',
     'flutter test test/il_nome_del_cerchio_test.dart',
     'GUARDIA EY.01: nessun nome riservato passa'),
    ('A2', 'EY.01', 'lib/core/cerchio/il_nome_iniziatico.dart',
     '        if (proprio.length >= 3 && _piana(nome).contains(proprio)) continue;\n',
     '',
     'flutter test test/il_nome_del_cerchio_test.dart',
     'non contiene mai il nome proprio'),
    ('A3', 'EY.13', 'lib/core/cerchio/il_confronto_del_cielo.dart',
     'final cieloDiOggi = ((giornoA + giornoB) / 2).round();',
     'final cieloDiOggi = giornoA + 0 * giornoB;',
     'flutter test test/il_confronto_del_cielo_e_simmetrico_test.dart',
     'GUARDIA EY.13'),
    ('A4', 'EY.14', 'lib/core/cerchio/il_glifo_del_legame.dart',
     "final testo = a.compareTo(b) <= 0 ? '$a|$b' : '$b|$a';",
     "final testo = '$a|$b';",
     'flutter test test/il_glifo_del_legame_test.dart',
     'GUARDIA EY.14'),
    ('A5', 'EY.10', 'lib/features/cerchio/invita_nel_cerchio_screen.dart',
     'maxLength: 4,', 'maxLength: 40,',
     'flutter test test/il_cerchio_non_ha_testo_libero_test.dart',
     'GUARDIA EY.10'),
    ('A6', 'EY.17', 'lib/features/account/invita_un_amico.dart',
     'TestoDellaCondivisione.invitoLibero(premioInvito: premio));',
     "'${TestoDellaCondivisione.invitoLibero(premioInvito: premio)}?invito=$premio');",
     'flutter test test/il_link_d_invito_non_porta_l_uid_test.dart',
     'GUARDIA EY.17'),
    ('A7', 'EY.15', 'lib/core/condivisione/porta_della_condivisione.dart',
     '    if (byte.isEmpty) return false;\n    final conLink = await conIlLink(testo);',
     '    if (byte.isEmpty) return false;\n    final conLink = testo;',
     'flutter test test/i_nove_ereditati_test.dart',
     'ogni via che condivide passa dal punto che aggiunge il link'),
    ('A8', 'EY.16', 'functions/src/il_cerchio_sociale.ts',
     '  await tettoDellaPorta(uid, "mandaUnDono");\n', '',
     'flutter test test/il_cerchio_custodisce_il_cammino_test.dart',
     'IL CAMMINO VIAGGIA DENTRO LA CHIAMATA'),
    ('A9', 'EY.07', 'lib/core/entitlement/plan_catalog.dart',
     "FeatureRow('Amici nel Cerchio', ['3', '15', '50', '150'],",
     "FeatureRow('Amici nel Cerchio', ['3', '15', '50', 'Senza limite'],",
     'flutter test test/i_numeri_del_cerchio_sociale_test.dart',
     'EY.07 ed EY.10'),
    ('A10', 'EY.11', 'lib/features/cerchio/widgets/i_segni_ricevuti.dart',
     'if (segno.ricevuto && !segno.risposto) ...[',
     'if (!segno.risposto) ...[',
     'flutter test test/le_schermate_del_cerchio_test.dart',
     'EY.11'),
    ('A11', 'EY.04', 'lib/features/cerchio/la_richiesta_di_legame.dart',
     '  final accetta = await showModalBottomSheet<bool>(',
     '  await sociale.chiediIlLegame(codice: codice);\n  final accetta = await showModalBottomSheet<bool>(',
     'flutter test test/le_schermate_del_cerchio_test.dart',
     'EY.04'),
    ('A12', 'EY.08', 'lib/features/cerchio/la_tendina_del_cerchio.dart',
     'if (persona.invitabile && persona.semaforo == Semaforo.spento)',
     'if (persona.semaforo == Semaforo.spento)',
     'flutter test test/le_schermate_del_cerchio_test.dart',
     'EY.08'),
    ('A13', 'EY.03', 'lib/core/cerchio/le_icone_del_cerchio.dart',
     "  animale('Gli animali guida', 12),",
     "  animale('Gli animali guida', 11),",
     'flutter test test/i_numeri_del_cerchio_sociale_test.dart',
     'EY.03'),
    ('A14', 'EY.12', 'lib/core/entitlement/listino_degli_eos.dart',
     "    id: 'dono_scintilla',\n    nome: 'Una scintilla da donare',\n    costo: 30,",
     "    id: 'dono_scintilla',\n    nome: 'Una scintilla da donare',\n    costo: 35,",
     'flutter test test/i_numeri_del_cerchio_sociale_test.dart',
     'EY.12'),
    ('A15', 'EY.06', 'functions/src/borsellino.ts',
     'export const EOS_DELL_INVITO_ACCOLTO = 150;',
     'export const EOS_DELL_INVITO_ACCOLTO = 60;',
     'flutter test test/l_invito_porta_qualcuno_test.dart',
     'listino'),
    ('A16', 'EY.09', 'lib/core/cerchio/il_cerchio_sociale.dart',
     '    return anni >= 18;', '    return anni >= 17;',
     'flutter test test/i_numeri_del_cerchio_sociale_test.dart',
     'EY.09'),
    ('A17', 'EY', 'docs/ordini/ORDINE_EY_MANIFESTO.md',
     'VOCI_CHIUSE: 2', 'VOCI_CHIUSE: 3',
     'flutter test test/ordine_ey_guard_test.dart',
     'ogni voce ha uno stato solo'),
    ('A18', 'EY.02', 'functions/src/sociale.ts',
     '    gradino: gradinoValido(dati.gradino) ?? 0,\n    maestro:',
     '    gradino: gradinoValido(dati.gradino) ?? 0,\n    ...({email: dati.email} as object),\n    maestro:',
     'npm --prefix functions test',
     'EY.02 il profilo pubblico porta sette campi'),
    ('A19', 'EY.05', 'functions/src/sociale.ts',
     'export type Semaforo = "spento" | "arancioneChiaro" | "arancionePieno" | "verde";',
     'export type Semaforo = "spento" | "arancioneChiaro" | "arancionePieno" | "verde" | "rosso";',
     'npm --prefix functions test',
     'EY.05 il semaforo'),
    ('A20', 'EY.08', 'functions/src/sociale.ts',
     'export const OGNI_QUANTO_SI_RIFA_L_ISTANTANEA_MS = 30 * 1000;',
     'export const OGNI_QUANTO_SI_RIFA_L_ISTANTANEA_MS = 1;',
     'npm --prefix functions test',
     'LA MISURA DELLE LETTURE'),
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
        # Se il pezzo nuovo contiene il vecchio (un innesto che AGGIUNGE prima
        # di una riga), si conta il nuovo; altrimenti il vecchio deve sparire.
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
        righe = [r for r in uscita.splitlines()
                 if ('[E]' in r or 'not ok' in r) and cade.split()[0] in r]
        nomi = [r.strip()[:140] for r in uscita.splitlines()
                if ('[E]' in r or r.strip().startswith('not ok') or '✖' in r)][:4]
        return ('%s (%s) %s: innesto entrato (grep del pezzo nuovo 1, del vecchio 0); '
                '%s; cadute: %s') % (
                    sigla, voce, percorso,
                    'ROSSA' if rossa else 'VERDE (la prova NON vede il difetto)',
                    ' | '.join(nomi) if nomi else '(nessuna riga di caduta letta)')
    finally:
        shutil.copyfile(copia, percorso)
        os.remove(copia)


def main():
    scelte = set(sys.argv[1:])
    os.makedirs('docs/collaudo/EY', exist_ok=True)
    registro = 'docs/collaudo/EY/regola_a_ey.txt'
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
