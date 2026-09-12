# -*- coding: utf-8 -*-
"""Aggiorna docs/guardie.md con le guardie nate nell'ordine CQ."""
NL = chr(10)
P = 'docs/guardie.md'

# nome file, descrizione, specie sorvegliate, porta, vista rossa, categoria
NUOVE = [
    ('cosa_dicono_i_doni_test.dart', 'cosa dicono i Doni', '1',
     'non scopre insiemi di file', '04/09/2026, CQ', '3'),
    ('i_manifesti_sono_sigillati_test.dart',
     'i manifesti sono sigillati', '1, 2', 'proprio, dichiarato',
     '04/09/2026, CQ', '2'),
    ('il_freno_del_gesto_ripetuto_test.dart',
     'il freno del gesto ripetuto', '1, 2', 'proprio, dichiarato',
     '03/09/2026, CQ', '2'),
    ('il_fuso_che_il_server_accetta_test.dart',
     'il fuso che il server accetta', '1, 2', 'dalla porta comune',
     '03/09/2026, CQ', '1'),
    ('il_ventaglio_vive_subito_test.dart',
     'il ventaglio vive subito', '1, 2', 'proprio, dichiarato',
     '03/09/2026, CQ', '2'),
    ('l_alba_e_il_soffio_non_dicono_lo_stesso_test.dart',
     'l Alba e il Soffio non dicono lo stesso', '1, 2',
     'proprio, dichiarato', '03/09/2026, CQ', '2'),
    ('l_arcano_e_del_singolo_test.dart', 'l Arcano e del singolo', '1, 2',
     'proprio, dichiarato', '03/09/2026, CQ', '2'),
    ('l_effetto_non_aspetta_la_piattaforma_test.dart',
     'l effetto non aspetta la piattaforma', '1, 2, 4',
     'dalla porta comune', '03/09/2026, CQ', '1'),
    ('la_domanda_libera_si_trova_test.dart',
     'la domanda libera si trova', '1', 'non scopre insiemi di file',
     '03/09/2026, CQ', '3'),
    ('la_runa_rovesciata_ha_la_sua_lettura_test.dart',
     'la runa rovesciata ha la sua lettura', '1, 2',
     'proprio, dichiarato', 'mai', '2'),
    ('la_stella_non_finisce_sotto_il_testo_test.dart',
     'la stella non finisce sotto il testo', '1, 2, 4',
     'proprio, dichiarato', '03/09/2026, CQ', '2'),
    ('nessun_suono_che_non_hai_scelto_test.dart',
     'nessun suono che non hai scelto', '1, 2, 4', 'dalla porta comune',
     '03/09/2026, CQ', '1'),
    ('nessun_traguardo_resta_indietro_test.dart',
     'nessun traguardo resta indietro', '1, 2', 'proprio, dichiarato',
     '04/09/2026, CQ', '2'),
    ('ordine_cp_guard_test.dart', 'ordine CP guard', '1, 2',
     'proprio, dichiarato', 'mai', '2'),
    ('ordine_cq_guard_test.dart', 'ordine CQ guard', '1, 2',
     'proprio, dichiarato', 'mai', '2'),
    ('scegliere_la_gettata_non_getta_test.dart',
     'scegliere la gettata non getta', '1, 2', 'proprio, dichiarato',
     '03/09/2026, CQ', '2'),
]

testo = open(P, encoding='utf-8').read()
righe = testo.split(NL)

# --- 1. le righe nuove entrano nella tavola, in ordine alfabetico -------
tavola = [i for i, r in enumerate(righe) if r.startswith('| `')]
assert tavola, 'la tavola non si trova'
gia = {r.split('`')[1] for r in righe if r.startswith('| `')}
aggiunte = 0
for nome, desc, specie, porta, rossa, cat in NUOVE:
    if nome in gia:
        continue
    nuova = '| `%s` | %s | %s | %s | %s | %s |' % (
        nome, desc, specie, porta, rossa, cat)
    posto = None
    for i in [i for i, r in enumerate(righe) if r.startswith('| `')]:
        if righe[i].split('`')[1] > nome:
            posto = i
            break
    if posto is None:
        posto = max(i for i, r in enumerate(righe) if r.startswith('| `')) + 1
    righe.insert(posto, nuova)
    aggiunte += 1

testo = NL.join(righe)
quante = testo.count(NL + '| `')

# --- 2. i conti seguono il dato ----------------------------------------
percategoria = {'1': 0, '2': 0, '3': 0}
for r in testo.split(NL):
    if not r.startswith('| `'):
        continue
    percategoria[r.rstrip().rstrip('|').strip()[-1]] += 1
viste = sum(1 for r in testo.split(NL)
            if r.startswith('| `') and ' mai |' not in r)
mai = quante - viste

CAMBI = [
    ('| Guardie che passano dalla porta comune | 108 |',
     '| Guardie che passano dalla porta comune | %d |' % percategoria['1']),
    ('| Guardie con un cardinale proprio dichiarato | 35 |',
     '| Guardie con un cardinale proprio dichiarato | %d |'
     % percategoria['2']),
    ('| Guardie che non scoprono nessun insieme di file | 118 |',
     '| Guardie che non scoprono nessun insieme di file | %d |'
     % percategoria['3']),
    ('| **Somma delle categorie** | **261** |',
     '| **Somma delle categorie** | **%d** |' % quante),
    ('| **Guardie mai viste rosse** | **215** |',
     '| **Guardie mai viste rosse** | **%d** |' % mai),
    ('| **Guardie viste rosse almeno una volta** | **46** |',
     '| **Guardie viste rosse almeno una volta** | **%d** |' % viste),
]
for vecchio, nuovo in CAMBI:
    assert testo.count(vecchio) == 1, vecchio
    testo = testo.replace(vecchio, nuovo)
testo = testo.replace('| **Guardie secondo la definizione** | **261** |',
                      '| **Guardie secondo la definizione** | **%d** |'
                      % quante)
testo = testo.replace('| Di questi, censiti come guardie | 261 |',
                      '| Di questi, censiti come guardie | %d |' % quante)
testo = testo.replace(
    'Quarantasei su duecentosessantuno e\' il **17,6 per cento**.',
    'Le guardie viste rosse sono **%d su %d**, il **%.1f per cento**, contate '
    'il 4 settembre 2026 con l\'ordine CQ.' % (
        viste, quante, viste * 100.0 / quante))

open(P, 'w', encoding='utf-8', newline=NL).write(testo)
print('AGGIUNTE %d guardie, totale %d, viste rosse %d (%.1f per cento)'
      % (aggiunte, quante, viste, viste * 100.0 / quante))
