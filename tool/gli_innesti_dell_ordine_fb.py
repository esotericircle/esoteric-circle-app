"""LA REGOLA A DELL'ORDINE FB: ogni prova nuova vista rossa sul suo difetto.

Per ogni innesto: copia del file, il difetto messo a mano, il controllo che
l'innesto sia ENTRATO (il pezzo nuovo c'e', il vecchio no), la prova fatta
girare, l'esito letto, il file rimesso dalla copia e confrontato al byte.
Stessa forma del banco dell'ordine FA (`gli_innesti_dell_ordine_fa.py`), con
una riga in piu': il nome della prova che DEVE cadere si cerca fra le cadute,
e se cade un'altra prova l'innesto e' dichiarato fuori bersaglio.

Uso: python tool/gli_innesti_dell_ordine_fb.py [sigla ...]
L'esito si scrive in docs/collaudo/FB/regola_a_fb.txt (in coda).
"""
import io
import os
import shutil
import subprocess
import sys

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(RADICE)

SERVER = 'cd functions && npm test'
TENDINA = 'flutter test test/la_tendina_non_supera_dieci_letture_test.dart -r expanded'
TUTTI = 'flutter test test/la_tendina_mostra_tutti_gli_amici_test.dart -r expanded'
SIGILLO = 'flutter test test/il_sigillo_sempre_fra_i_bloccati_test.dart -r expanded'

# sigla, voce, file, vecchio, nuovo, comando, la prova che deve cadere
INNESTI = [
    ('A1', 'FB.01', 'functions/src/sociale.ts',
     'export const FRAMMENTI_DELLA_PRESENZA = 96;',
     'export const FRAMMENTI_DELLA_PRESENZA = 32;',
     SERVER, "I FRAMMENTI REGGONO IL TETTO"),
    ('A2', 'FB.01', 'functions/src/sociale.ts',
     'export const PRESENZE_NELL_ISTANTANEA = 5000;',
     'export const PRESENZE_NELL_ISTANTANEA = 6100;',
     SERVER, "L'ISTANTANEA STA NEL SUO DOCUMENTO"),
    ('A3', 'FB.01', 'functions/src/sociale.ts',
     'export function lettureDegliAmici(_amici: number, _amiciPresenti: number): number {\n  return 0;',
     'export function lettureDegliAmici(_amici: number, _amiciPresenti: number): number {\n  return Math.min(_amiciPresenti, 6);',
     SERVER, "LE LETTURE DI UN'APERTURA"),
    ('A4', 'FB.01', 'functions/src/il_cerchio_sociale.ts',
     '    .filter((a) => !blocchi.has(a))\n    .flatMap(',
     '    .filter((a) => !blocchi.has(a))\n    .slice(0, 6)\n    .flatMap(',
     TENDINA, 'nessun tetto sugli amici'),
    ('A5', 'FB.01', 'functions/src/il_cerchio_sociale.ts',
     '    istantanea({ricostruisci: false}),\n    statoDi(',
     '    istantanea({ricostruisci: true}),\n    statoDi(',
     TENDINA, 'nessun tetto sugli amici'),
    ('A6', 'FB.01', 'functions/src/sociale.ts',
     'export const SOGLIA_DELLE_LETTURE_PER_APERTURA = 10;',
     'export const AMICI_NELLA_TENDINA = 6;\nexport const SOGLIA_DELLE_LETTURE_PER_APERTURA = 10;',
     TENDINA, 'nessun tetto sugli amici'),
    ('A7', 'FB.01', 'lib/features/cerchio/la_tendina_del_cerchio.dart',
     '                            for (final p in t.amiciPresenti)\n',
     '                            for (final p in t.amiciPresenti.take(6))\n',
     TUTTI, 'li mostra'),
    ('A8', 'FB.02', 'lib/features/cerchio/profilo_nel_cerchio_screen.dart',
     '                        sempre: true,\n', '',
     SIGILLO, 'anche senza nomi uguali'),
    ('A9', 'FB.02', 'lib/features/cerchio/widgets/disegni_del_cerchio.dart',
     '    if (sempre) {\n', '    if (sempre && nome.isEmpty) {\n',
     SIGILLO, 'anche senza nomi uguali'),
    ('A10', 'FB.02', 'lib/features/cerchio/widgets/disegni_del_cerchio.dart',
     '        (sempre || ElencoDelCerchio.eDoppio(context, nome));',
     '        (true || ElencoDelCerchio.eDoppio(context, nome));',
     SIGILLO, 'negli altri elenchi'),
    ('A11', 'FB.02', 'lib/features/cerchio/widgets/disegni_del_cerchio.dart',
     "    return Row(\n      key: Key('sigillo_accanto_a_$nome'),\n",
     "    return Text.rich(\n        TextSpan(children: [\n          TextSpan(text: nome, style: stile),\n"
     "          TextSpan(text: '  $sigillo', style: stileDelSigillo),\n        ]),\n"
     "        key: Key('sigillo_accanto_a_$nome'),\n        overflow: TextOverflow.ellipsis,\n"
     "        maxLines: 1);\n    // ignore: dead_code\n    return Row(\n      key: Key('sigillo_accanto_a_$nome'),\n",
     SIGILLO, 'riga stretta'),
    ('A12', 'FB.03', 'docs/ordini/RAPPORTO_ORDINE_EZ.md',
     '## LE VOCI CHIUSE, con la prova di ciascuna\n\n- EZ.02',
     "## LE VOCI CHIUSE, con la prova di ciascuna\n\n- EZ.03, le letture della tendina scendono (chiusa dall'ordine FA voce 05): functions/src/sociale.test.ts\n- EZ.02",
     'flutter test test/i_rapporti_consegnati_non_si_correggono_test.dart -r expanded',
     'FB.03'),
    ('A13', 'FB.03', 'docs/ordini/RAPPORTO_ORDINE_EZ.md',
     "la prova e' functions/src/sociale.test.ts, e la chiusura",
     'e la chiusura',
     'flutter test test/ogni_voce_chiusa_porta_la_sua_prova_test.dart -r expanded',
     'il rapporto porta in cima'),
    ('A15', 'FB.01', 'functions/src/sociale.ts',
     '    if (viaDaQui === tutte) vuoti.push(frammento);',
     '    if (viaDaQui === tutte && tutte < 0) vuoti.push(frammento);',
     SERVER, "l'istantanea dai frammenti"),
    ('A16', 'FB.01', 'functions/src/sociale.ts',
     '    dopo: 1 + Math.max(1, Math.min(FRAMMENTI_DELLA_PRESENZA, presenti)),',
     '    dopo: 1 + FRAMMENTI_DELLA_PRESENZA,',
     SERVER, "LE LETTURE DI UN'APERTURA"),
    ('A17', 'FB.01', 'functions/src/il_cerchio_sociale.ts',
     '      db().collection("profili").doc(uid).delete(),\n      scriviLaPresenza(uid, null),\n',
     '      db().collection("profili").doc(uid).delete(),\n',
     'flutter test test/il_cerchio_si_apre_a_quattordici_anni_test.dart -r expanded',
     'quattordici anni'),
    ('A14', 'FB', 'docs/ordini/ORDINE_FB_MANIFESTO.md',
     'VOCI_CHIUSE: 2\n', 'VOCI_CHIUSE: 3\n',
     'flutter test test/ordine_fb_guard_test.dart -r expanded', 'ogni voce'),
]


def leggi(p):
    return io.open(p, encoding='utf-8', newline='').read()


def scrivi(p, s):
    io.open(p, 'w', encoding='utf-8', newline='').write(s)


def un_innesto(sigla, voce, percorso, vecchio, nuovo, comando, bersaglio):
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
        cadute = [r.strip()[:170] for r in uscita.splitlines()
                  if ('[E]' in r or r.strip().startswith('not ok') or '✖' in r)]
        nel_bersaglio = any(bersaglio in c for c in cadute)
        misure = [r.strip()[:220] for r in uscita.splitlines()
                  if r.startswith('FB.0') or r.startswith('ORDINE')][:3]
        return ('%s (%s) %s: innesto entrato (grep del pezzo nuovo 1, del vecchio 0); '
                '%s; bersaglio "%s" %s; cadute: %s; misure lette: %s') % (
                    sigla, voce, percorso,
                    'ROSSA' if rossa else 'VERDE (la prova NON vede il difetto)',
                    bersaglio, 'colpito' if nel_bersaglio else 'NON COLPITO',
                    ' | '.join(cadute[:3]) if cadute else '(nessuna riga di caduta letta)',
                    ' | '.join(misure) if misure else '(nessuna)')
    finally:
        shutil.copyfile(copia, percorso)
        os.remove(copia)


def main():
    scelte = set(sys.argv[1:])
    os.makedirs('docs/collaudo/FB', exist_ok=True)
    registro = 'docs/collaudo/FB/regola_a_fb.txt'
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
