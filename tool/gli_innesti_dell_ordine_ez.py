"""LA REGOLA A DELL'ORDINE EZ: ogni prova nuova vista rossa sul suo difetto.

Per ogni innesto: copia del file, il difetto messo a mano, il controllo che
l'innesto sia ENTRATO (il pezzo nuovo c'e', il vecchio no), la prova fatta
girare, l'esito letto, il file rimesso dalla copia e confrontato al byte.
Stessa forma del banco dell'ordine EY (`gli_innesti_dell_ordine_ey.py`).

Uso: python tool/gli_innesti_dell_ordine_ez.py [sigla ...]
L'esito si scrive in docs/collaudo/EZ/regola_a_ez.txt (in coda).
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
    ('A1', 'EZ.01', 'lib/features/cerchio/widgets/disegni_del_cerchio.dart',
     '      width: quadrato,\n      height: quadrato,\n      fit: BoxFit.contain,',
     '      width: lato,\n      height: lato,\n      fit: BoxFit.cover,',
     'flutter test test/le_icone_stanno_intere_nel_tondo_test.dart',
     'EZ.01'),
    ('A2', 'EZ.01', 'lib/features/cerchio/profilo_nel_cerchio_screen.dart',
     'child: IconaTonda(icona: p.icona, lato: 112),',
     'child: Column(children: [IconaTonda(icona: p.icona, lato: 112), Image.asset(IconaDelProfilo.da(p.icona).asset, width: 20)]),',
     'flutter test test/le_icone_stanno_intere_nel_tondo_test.dart',
     'EZ.01'),
    ('A3', 'EZ.02', 'lib/core/cerchio/il_confronto_del_cielo.dart',
     'final accordo = math.cos(distanza * math.pi / 180);',
     'final accordo = math.cos((luna.index * 30 + 15 - puntoDIncontro(a, b) + 0 * distanza) * math.pi / 180);',
     'flutter test test/il_confronto_del_cielo_e_simmetrico_test.dart',
     'GUARDIA EZ.02'),
    ('A4', 'EZ.02', 'lib/core/cerchio/il_confronto_del_cielo.dart',
     'static const double ampiezzaDelGiorno = 20;',
     'static const double ampiezzaDelGiorno = 60;',
     'flutter test test/il_confronto_del_cielo_e_simmetrico_test.dart',
     'GUARDIA EZ.02'),
    ('A5', 'EZ.03', 'functions/src/sociale.ts',
     '.slice(0, VETRINA_DELL_ISTANTANEA);',
     '.slice(0, 3000);',
     SERVER, 'EZ.03'),
    ('A6', 'EZ.03', 'functions/src/sociale.ts',
     'dopo: conteggi + Math.max(1, Math.min(VETRINA_DELL_ISTANTANEA, presenti)),',
     'dopo: presenti + 1 + 0 * conteggi,',
     SERVER, 'EZ.03'),
    ('A7', 'EZ.04', 'functions/src/il_cerchio_sociale.ts',
     '    if (!sogliaDellEtaPassata(porta, snap.data()?.quattordici)) {\n'
     '      return {concesso: false as const, sottoLaSoglia: true, mancaMs: 0};\n'
     '    }\n',
     '',
     'flutter test test/il_cerchio_si_apre_a_quattordici_anni_test.dart',
     'EZ.04'),
    ('A8', 'EZ.04', 'lib/core/cerchio/il_cerchio_sociale.dart',
     'if (_chiusoPerEta && porta != portaCheRiceveLEta) {',
     'if (_chiusoPerEta && porta == \'nessuna porta\') {',
     'flutter test test/il_cerchio_si_apre_a_quattordici_anni_test.dart',
     'EZ.04'),
    ('A9', 'EZ.04', 'functions/src/sociale.ts',
     'return porta === PORTA_CHE_RICEVE_L_ETA || quattordici === true;',
     'return porta === PORTA_CHE_RICEVE_L_ETA || quattordici !== false;',
     SERVER, 'EZ.04'),
    ('A10', 'EZ.05', 'lib/features/cerchio/scheda_dell_amico_screen.dart',
     'if (IlCerchioSociale.ilGiftEosEAperto)',
     'if (IlCerchioSociale.ilGiftEosEAperto || amico.uid.isNotEmpty)',
     'flutter test test/il_gift_eos_si_dichiara_test.dart',
     'EZ.05'),
    ('A11', 'EZ.05', 'functions/src/il_cerchio_sociale.ts',
     'regalabili: regalabili - quanti,',
     'regalabili: regalabili + quanti,',
     'flutter test test/il_gift_eos_si_dichiara_test.dart',
     'EZ.05'),
    ('A12', 'EZ.06', 'lib/core/entitlement/plan_catalog.dart',
     "FeatureRow('Oroscopo per gli amici', ['No', '3', '10', '50'],",
     "FeatureRow('Oroscopo per gli amici', ['No', '3', '10', 'Senza limite'],",
     'flutter test test/gli_amici_offline_hanno_un_numero_test.dart',
     'EZ.06'),
    ('A13', 'EZ.06', 'lib/features/amici/amici_screen.dart',
     ': _amici.tutti.length > posti\n',
     ': _amici.tutti.length > posti * 10\n',
     'flutter test test/gli_amici_offline_hanno_un_numero_test.dart',
     'EZ.06'),
    ('A14', 'EZ.07', 'functions/src/la_pagina_dell_invito.ts',
     '  android: "",',
     '  android: "https://play.google.com/store/apps/details?id=com.esotericircle.esoteric_circle",',
     SERVER, 'EZ.07'),
    ('A15', 'EZ.08', 'lib/core/cerchio/i_segni_del_cerchio.dart',
     "rigaDiChiRiceve: 'Qualcuno ti manda dalla Luna di stanotte.',",
     "rigaDiChiRiceve: 'Stanotte la Luna è nel tuo segno.',",
     'flutter test test/i_segni_del_cerchio_hanno_i_testi_veri_test.dart',
     'EZ.08'),
    ('A16', 'EZ.08', 'functions/src/sociale.ts',
     '  miManchi: 2,',
     '  miManchi: 3,',
     'flutter test test/i_segni_del_cerchio_hanno_i_testi_veri_test.dart',
     'EZ.08'),
    ('A17', 'EZ', 'docs/ordini/ORDINE_EZ_MANIFESTO.md',
     'VOCI_CHIUSE: 4\n',
     'VOCI_CHIUSE: 5\n',
     'flutter test test/ordine_ez_guard_test.dart',
     'ogni voce'),
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
                  if r.startswith('EZ.0')][:3]
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
    os.makedirs('docs/collaudo/EZ', exist_ok=True)
    registro = 'docs/collaudo/EZ/regola_a_ez.txt'
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
