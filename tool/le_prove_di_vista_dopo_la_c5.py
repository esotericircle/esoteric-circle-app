"""Le prove di vista delle guardie nate dopo la misura C5 dell'aggiunta della
Macchina del tempo all'ordine FH, 10 ottobre 2026 (Regola A).

Per ogni innesto: si copia il file, si mette il difetto, si verifica col grep
che il difetto sia entrato, si fa girare la prova, si legge l'esito, si
rimette il file com'era e si confronta l'impronta. L'esito va in
docs/collaudo/FH/prove_di_vista_dopo_la_c5.txt.

Uso: PYTHONIOENCODING=utf-8 python tool/le_prove_di_vista_dopo_la_c5.py
"""
import hashlib
import io
import os
import shutil
import subprocess
import sys
import time

RADICE = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
USCITA = os.path.join(RADICE, 'docs', 'collaudo', 'FH', 'prove_di_vista_dopo_la_c5.txt')
# Un giro parziale scrive accanto, col nome del giro: il file intero resta.
if len(sys.argv) > 1:
    USCITA = USCITA.replace('.txt', '_' + '_'.join(sys.argv[1:]) + '.txt')

SCHERMATA = 'lib/features/real_time_cosmo/cielo_reale_screen.dart'
PANNELLO = 'lib/features/real_time_cosmo/il_pannello_del_tempo.dart'
ECLITTICA = 'lib/features/real_time_cosmo/l_eclittica_in_scena.dart'
VIA = 'lib/features/real_time_cosmo/la_via_lattea_in_scena.dart'
ORIENTAMENTO = 'lib/core/motion/l_orientamento_del_telefono.dart'
MACCHINA = 'test/le_anteprime_della_macchina_del_tempo_test.dart'

# (nome, file, prima, dopo, prova, nome del caso o None)
INNESTI = [
    ('C1 le scritte parlano nella corsa', SCHERMATA,
     '    final tacciono = _ilRitornoParla || _senzaDistrazioni;',
     '    final tacciono = _senzaDistrazioni;',
     MACCHINA, 'I6 e I11'),
    ('C2 senza distrazioni non spegne i punti cardinali', SCHERMATA,
     '    final tacciono = _ilRitornoParla || _senzaDistrazioni;',
     '    final tacciono = _ilRitornoParla;',
     MACCHINA, 'esplora senza distrazioni'),
    ('C3 senza distrazioni senza il bottone che riaccende', SCHERMATA,
     '              if (senzaDistrazioni)\n                IconButton(',
     '              if (false)\n                IconButton(',
     MACCHINA, 'esplora senza distrazioni'),
    ('C4 la riga del luogo torna accanto al bottone', PANNELLO,
     "            Column(\n              key: const Key('macchina_riga_del_luogo'),\n              crossAxisAlignment: CrossAxisAlignment.stretch,",
     "            Row(\n              key: const Key('macchina_riga_del_luogo'),\n              crossAxisAlignment: CrossAxisAlignment.center,",
     MACCHINA, 'la riga del luogo del pannello'),
    ('C5 il nome dell\'eclittica ignora gli ostacoli', ECLITTICA,
     '      if (o.overlaps(scatola)) return false;',
     '      if (o.overlaps(scatola) && false) return false;',
     'test/real_time_cosmo_l_eclittica_test.dart', None),
    ('C6 la Via Lattea torna in screen', VIA,
     'const ui.BlendMode kComposizioneDellaViaLattea = ui.BlendMode.plus;',
     'const ui.BlendMode kComposizioneDellaViaLattea = ui.BlendMode.screen;',
     'test/real_time_cosmo_la_via_lattea_non_legge_lo_schermo_test.dart', None),
    ('C7 i colori della Via Lattea senza il fondo', VIA,
     '  int canale(int f) => (luce * (255 - f) / 255).round();',
     '  int canale(int f) => luce;',
     'test/real_time_cosmo_la_via_lattea_non_legge_lo_schermo_test.dart', None),
    ('C8 il filtro del sensore senza la quiete', ORIENTAMENTO,
     '      final quiete = (1 - _agitazione) * (1 - _agitazione);',
     '      final quiete = 0.0;',
     'test/real_time_cosmo_il_cielo_fermo_non_trema_test.dart', None),
    ('C9 il filtro del sensore senza la scatola', ORIENTAMENTO,
     '    if (r <= kSogliaDellaQuiete) return dato;',
     '    if (r <= 0) return dato;',
     'test/real_time_cosmo_il_cielo_fermo_non_trema_test.dart', None),
    ('C10 il pannello non dice il cambio alla schermata', SCHERMATA,
     '            if (mounted) setState(() => _sceltaDelTempo = s);',
     '            if (mounted) {}',
     MACCHINA, 'il pulsante riparte'),
    ('C11 il solo luogo cambiato non fa partire la corsa', SCHERMATA,
     '    if ((jdA - jdDa).abs() < 1 / 1440 && stessoLuogo) {',
     '    if ((jdA - jdDa).abs() < 1 / 1440) {',
     MACCHINA, 'il pulsante riparte'),
    ('C12 il tocco senza cambi non risponde', SCHERMATA,
     '      ScaffoldMessenger.maybeOf(context)\n        ?..hideCurrentSnackBar()',
     '      (null as ScaffoldMessengerState?)\n        ?..hideCurrentSnackBar()',
     MACCHINA, 'il pulsante riparte'),
    ('C13 la bussola ignora la schermata orizzontale', ORIENTAMENTO,
     '    if (!orizzontale) {',
     '    if (true) {',
     'test/real_time_cosmo_il_telefono_orizzontale_test.dart', None),
    ("C14 il nome dell'eclittica parla sempre", SCHERMATA,
     '      _fotogramma.nomeDellEclittica = ora < _nomeDellEclitticaFino;',
     '      _fotogramma.nomeDellEclittica = true;',
     'test/le_anteprime_dell_ordine_fh_test.dart', 'FH.13'),
    ("C15 l'indicatore senza il margine di sistema", SCHERMATA,
     '    final alto = kMargineAlto + bordi.top;',
     '    final alto = kMargineAlto;',
     MACCHINA, 'non copre la testata'),
    ("C16 l'indicatore non misura il pie' di pagina", SCHERMATA,
     '    final pie = _chiaveDelPieDiPagina.currentContext?.size?.height ?? 0;',
     '    const pie = 0.0;',
     MACCHINA, 'non copre la testata'),
]


def impronta(p):
    return hashlib.sha1(open(p, 'rb').read()).hexdigest()


def scrivi(p, dati):
    for _ in range(240):
        try:
            with open(p, 'wb') as f:
                f.write(dati)
            if open(p, 'rb').read() == dati:
                return
        except OSError:
            pass
        time.sleep(0.5)
    raise SystemExit('non riesco a scrivere ' + p)


def main():
    os.chdir(RADICE)
    righe = ['LE PROVE DI VISTA DOPO LA C5, ordine FH, 10 ottobre 2026', '']
    tutte = True
    scelti = sys.argv[1:]
    if scelti:
        righe[0] += ', giro parziale: ' + ' '.join(scelti)
    for nome, file, prima, dopo, prova, caso in INNESTI:
        if scelti and nome.split()[0] not in scelti:
            continue
        originale = open(file, 'rb').read()
        prima_h = impronta(file)
        testo = originale.decode('utf-8')
        crlf = '\r\n' in testo
        t = testo.replace('\r\n', '\n')
        if t.count(prima) != 1:
            raise SystemExit(nome + ': il pezzo da innestare non c\'e\' una volta sola')
        t = t.replace(prima, dopo)
        if crlf:
            t = t.replace('\n', '\r\n')
        try:
            scrivi(file, t.encode('utf-8'))
            entrato = dopo.split('\n')[0] in open(file, encoding='utf-8').read()
            comando = ['flutter', 'test', '-r', 'expanded', prova]
            if caso:
                comando[4:4] = ['--plain-name', caso]
            # Il comando come stringa quotata: con una lista e shell=True il
            # nome del caso con gli spazi si spezzava in piu' argomenti e la
            # prova non partiva (il primo giro diceva VERDE su quattro
            # innesti, 10 ottobre 2026).
            r = subprocess.run(subprocess.list2cmdline(comando),
                               capture_output=True, text=True,
                               encoding='utf-8', errors='replace', shell=True)
            uscita = (r.stdout or '') + (r.stderr or '')
            rossa = r.returncode != 0 and 'Some tests failed' in uscita
            verde = r.returncode == 0 and 'All tests passed' in uscita
            ultima = [l for l in uscita.splitlines() if l.strip()][-1:] or ['']
        finally:
            scrivi(file, originale)
        ripristinato = impronta(file) == prima_h
        tutte = tutte and entrato and rossa and ripristinato
        righe.append(f'{nome}')
        righe.append(f'  file: {file}')
        righe.append(f'  innesto entrato (grep): {"si" if entrato else "NO"}')
        righe.append(f'  prova: {prova}' + (f' | {caso}' if caso else ''))
        righe.append(f'  esito: {"ROSSA" if rossa else ("VERDE" if verde else "ERRORE, la prova non ha girato")}')
        righe.append(f'  ultima riga: {ultima[0].strip()[:160]}')
        motivo = [l.strip() for l in uscita.splitlines()
                  if 'Expected' in l or 'Actual' in l or 'reason' in l.lower()
                  or 'copre' in l or 'parla' in l or 'stretta' in l
                  or 'Error' in l][:3]
        for m in motivo:
            righe.append(f'    {m}')
        righe.append(f'  ripristinato al byte: {"si" if ripristinato else "NO"}')
        righe.append('')
        print(nome, 'ROSSA' if rossa else ('VERDE' if verde else 'ERRORE'), ultima[0][:120], flush=True)
    righe.append('TUTTE ROSSE COI DIFETTI ENTRATI E I FILE RIPRISTINATI: ' +
                 ('SI' if tutte else 'NO'))
    io.open(USCITA, 'w', encoding='utf-8', newline='\n').write('\n'.join(righe) + '\n')
    print('scritto', USCITA)
    sys.exit(0 if tutte else 1)


if __name__ == '__main__':
    main()
