# -*- coding: utf-8 -*-
"""LE SCHERMATE E IL TASTO INDIETRO. Ordine FD voce 04.

Scrive `docs/collaudo/FD/le_schermate_e_il_tasto_indietro.md`: ogni rotta
che `lib` costruisce (`PassaggioDelCerchio.rotta` e i `PageRouteBuilder`), col
file e la riga, e dove porta il tasto indietro da li'. Enumera dal codice, non
da un elenco scritto a mano: rigenerarlo dopo un cambio di navigazione dice
subito cosa e' cambiato.

Uso: python tool/le_schermate_e_il_tasto_indietro.py
"""
import io
import os
import re

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(RADICE)
USCITA = 'docs/collaudo/FD/le_schermate_e_il_tasto_indietro.md'

ROTTA = re.compile(r'PassaggioDelCerchio\.rotta|PageRouteBuilder')
CLASSE = re.compile(r'^(?:abstract\s+)?(?:final\s+)?class\s+(\w+)')
COSTRUITO = re.compile(r'(?:=>|\(_\)\s*=>|\(\w+\)\s*=>)\s*(?:const\s+)?([A-Z]\w+)\(')

# I PopScope dichiarati, con cio' che fanno: lo stesso elenco della guardia.
TRATTENGONO = {
    'lib/features/onboarding/onboarding_screen.dart':
        'il rito: torna di un passo; dal primo passo non fa niente',
    'lib/features/onboarding/risveglio_journey.dart':
        'il Risveglio: torna di una fase',
}

VESTI = {'VestitoDelMenuUtente', 'MaestroScope', 'SogliaArte', 'Builder',
         'VeloDelCerchio', 'Consumer', 'ChangeNotifierProvider', 'Provider',
         'MultiProvider'}

righe = []
for base, _, files in os.walk('lib'):
    for nome in sorted(files):
        if not nome.endswith('.dart'):
            continue
        p = os.path.join(base, nome).replace(os.sep, '/')
        testo = io.open(p, encoding='utf-8').read().split('\n')
        classe = '?'
        for i, r in enumerate(testo):
            m = CLASSE.match(r)
            if m:
                classe = m.group(1)
            s = r.strip()
            if s.startswith('//') or s.startswith('*') or not ROTTA.search(r):
                continue
            pezzo = ' '.join(testo[i:i + 4])
            c = COSTRUITO.search(pezzo)
            schermata = c.group(1) if c else classe
            # Le vesti attorno alla schermata non sono la schermata: si
            # nomina la classe che dichiara la rotta.
            if schermata in VESTI:
                schermata = classe
            if p == 'lib/design_system/transizioni/passaggio_del_cerchio.dart':
                continue  # la definizione del passaggio, non una schermata
            if 'PageRouteBuilder' in r:
                dove = 'un velo trasparente sopra la rotta di sotto (festa o celebrazione): si chiude e torna li\''
            elif p in TRATTENGONO:
                dove = TRATTENGONO[p]
            else:
                dove = 'alla schermata precedente (pop della rotta)'
            righe.append((p, i + 1, schermata, dove))

out = ['# Le schermate e il tasto indietro, ordine FD voce 04', '',
       'Generato da `tool/le_schermate_e_il_tasto_indietro.py` sul codice: '
       'ogni rotta che `lib` costruisce, il file e la riga, e dove porta il '
       'tasto indietro.', '',
       '## La rotta 0, la home', '',
       '| Vista | File | Tasto indietro |', '|---|---|---|',
       '| Il Cerchio (Santuario) | `lib/features/shell/app_shell.dart` | primo tocco: "Premi di nuovo per uscire." per due secondi; '
       'secondo tocco entro due secondi: esce dall\'app (`lib/features/shell/il_tasto_indietro_della_home.dart`) |',
       '| Il Cosmic Passport | `lib/features/shell/app_shell.dart` | torna al Cerchio |', '',
       '## Le rotte spinte sopra la home', '',
       '| # | Schermata | File:riga | Tasto indietro |', '|---|---|---|---|']
for n, (p, riga, schermata, dove) in enumerate(righe, 1):
    out.append(f'| {n} | `{schermata}` | `{p}:{riga}` | {dove} |')
out += ['', f'Rotte enumerate: {len(righe)}. Nessuna esce dall\'app: in `lib` '
        'chiude l\'app solo `IlTastoIndietroDellaHome` (guardia '
        '`test/il_tasto_indietro_non_esce_dall_app_test.dart`).', '']
io.open(USCITA, 'w', encoding='utf-8', newline='\n').write('\n'.join(out))
print('scritto', USCITA, len(righe), 'rotte')
