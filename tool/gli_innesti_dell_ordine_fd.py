"""LA REGOLA A DELL'ORDINE FD: ogni prova nuova vista rossa sul suo difetto.

Stessa forma del banco dell'ordine FC (`gli_innesti_dell_ordine_fc.py`): per
ogni innesto la copia del file, il difetto messo a mano, il controllo che
l'innesto sia ENTRATO, la prova fatta girare, l'esito letto, il nome della
prova che DEVE cadere cercato fra le cadute, il file rimesso dalla copia e
confrontato al byte.

Uso: PYTHONIOENCODING=utf-8 python tool/gli_innesti_dell_ordine_fd.py [sigla ...]
L'esito si scrive in docs/collaudo/FD/regola_a_fd.txt (in coda).
"""
import io
import os
import shutil
import subprocess
import sys

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(RADICE)

INDIETRO = 'flutter test test/il_tasto_indietro_non_esce_dall_app_test.dart -r expanded'
GUSCIO = 'lib/features/shell/app_shell.dart'
LA_PORTA = 'lib/features/shell/il_tasto_indietro_della_home.dart'
IMPOSTAZIONI = 'lib/features/settings/settings_screen.dart'
INVITA = 'lib/features/cerchio/invita_nel_cerchio_screen.dart'
SPESA = 'flutter test test/la_spesa_passa_dalla_conferma_test.dart -r expanded'
CONFERMA = 'lib/design_system/components/la_conferma_della_spesa.dart'
PORTA_SPESA = 'lib/design_system/components/porta_della_spesa.dart'
ENTRATA = 'lib/features/maestri/live/l_entrata_nel_vivo.dart'

# sigla, voce, file, vecchio, nuovo, comando, la prova che deve cadere
INNESTI = [
    ('A1', 'FD.04', GUSCIO,
     '    return IlTastoIndietroDellaHome(\n      adesso: clock,\n      child: Scaffold(',
     '    return KeyedSubtree(\n      child: Scaffold(',
     INDIETRO, 'un tocco avvisa'),
    ('A2', 'FD.04', LA_PORTA,
     '    if (nav.view == ShellView.passport) {\n      nav.goToSantuario();\n      return;\n    }\n',
     '',
     INDIETRO, 'dal Passport'),
    ('A3', 'FD.04', LA_PORTA,
     '        ora.difference(primo) <= IlTastoIndietroDellaHome.finestra) {',
     '        ora.difference(primo) <= const Duration(days: 1)) {',
     INDIETRO, 'dopo si ricomincia'),
    ('A4', 'FD.04', INVITA,
     'class InvitaNelCerchioScreen extends StatefulWidget {',
     'void esciDallInvito() => SystemNavigator.pop();\n\n'
     'class InvitaNelCerchioScreen extends StatefulWidget {',
     INDIETRO, 'un punto solo'),
    ('A5', 'FD.04', IMPOSTAZIONI,
     'class SettingsScreen extends StatelessWidget {',
     'Widget trattieni(Widget w) => PopScope(canPop: false, child: w);\n\n'
     'class SettingsScreen extends StatelessWidget {',
     INDIETRO, 'un punto solo'),
    ('A6', 'FD.01', CONFERMA,
     '            onPressed: () => Navigator.of(c).pop(false),',
     '            onPressed: () => Navigator.of(c).pop(true),',
     SPESA, 'Non ora non spende niente'),
    ('A7', 'FD.01', CONFERMA,
     '            onPressed: attiva ? () => Navigator.of(c).pop(true) : null,',
     '            onPressed: () => Navigator.of(c).pop(true),',
     SPESA, 'saldo corto'),
    # A8 tolto: il controllo che innestava era un doppione del pulsante spento,
    # ed e' stato tolto dal codice (verde all'innesto, ordine FD voce 01).
    # Un punto di spesa che salta la conferma: il consenso fatto a mano.
    ('A9', 'FD.01', PORTA_SPESA,
     [("import 'la_conferma_della_spesa.dart';",
       "import 'la_conferma_della_spesa.dart';\n"
       "import '../../core/entitlement/il_consenso_della_spesa.dart';"),
      ('    final consenso =\n'
       '        await LaConfermaDellaSpesa.degliEos(context, costo: widget.voce.costo);',
       '    final consenso = ConsensoDellaSpesa.dato(widget.voce.costo);')],
     None, SPESA, 'lo crea la conferma'),
    # Il LIVE che riapre la sessione al primo tocco.
    ('A10', 'FD.01', ENTRATA,
     [("import '../../../core/maestro/maestro.dart';",
       "import '../../../core/entitlement/il_consenso_della_spesa.dart';\n"
       "import '../../../core/maestro/maestro.dart';"),
      ('  final consenso = await LaConfermaDellaSpesa.deiMinuti(',
       '  final consenso = ConsensoDellaSpesa.dato(0);\n'
       '  await LaConfermaDellaSpesa.deiMinuti(')],
     None, SPESA, 'lo crea la conferma'),
    ('A11', 'FD.01', 'lib/core/cerchio/il_cerchio_sociale.dart',
     '  Future<EsitoDelGesto> regalaGliEos(String a, int quanti,\n'
     '      {required ConsensoDellaSpesa consenso}) async {',
     '  Future<EsitoDelGesto> regalaGliEos(String a, int quanti,\n'
     '      {ConsensoDellaSpesa? consenso}) async {',
     SPESA, 'lo crea la conferma'),
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
        # Un innesto puo' essere fatto di piu' pezzi nello stesso file: allora
        # `vecchio` e' un elenco di coppie (vecchio, nuovo) e `nuovo` e' None.
        coppie = vecchio if isinstance(vecchio, list) else [(vecchio, nuovo)]
        for v, _ in coppie:
            n = testo.count(v)
            if n != 1:
                return '%s (%s) INNESTO NON ENTRATO: il pezzo vecchio compare %d volte' % (sigla, voce, n)
        for v, nv in coppie:
            testo = testo.replace(v, nv)
        scrivi(percorso, testo.replace('\n', '\r\n') if crlf else testo)
        dopo = leggi(percorso).replace('\r\n', '\n')
        entrato = True
        for v, nv in coppie:
            if nv and v in nv:
                entrato = entrato and dopo.count(nv) == 1
            else:
                entrato = entrato and (nv in dopo if nv else True) and dopo.count(v) == 0
        if not entrato:
            return '%s (%s) INNESTO NON ENTRATO al controllo' % (sigla, voce)
        esito = subprocess.run(comando, shell=True, capture_output=True,
                               text=True, encoding='utf-8', errors='replace')
        uscita = esito.stdout + esito.stderr
        rossa = esito.returncode != 0
        cadute = [r.strip()[:170] for r in uscita.splitlines() if '[E]' in r]
        nel_bersaglio = any(bersaglio in c for c in cadute)
        misure = [r.strip()[:220] for r in uscita.splitlines()
                  if r.startswith('ORDINE FD')][:2]
        return ('%s (%s) %s: innesto entrato (grep del pezzo nuovo 1, del vecchio 0); '
                '%s; bersaglio "%s" %s; cadute: %s; misure lette: %s') % (
                    sigla, voce, percorso,
                    'ROSSA' if rossa else 'VERDE (la prova NON vede il difetto)',
                    bersaglio, 'colpito' if nel_bersaglio else 'NON COLPITO',
                    ' | '.join(cadute[:2]) if cadute else '(nessuna riga di caduta letta)',
                    ' | '.join(misure) if misure else '(nessuna)')
    finally:
        shutil.copyfile(copia, percorso)
        os.remove(copia)


def main():
    scelte = set(sys.argv[1:])
    os.makedirs('docs/collaudo/FD', exist_ok=True)
    registro = 'docs/collaudo/FD/regola_a_fd.txt'
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
