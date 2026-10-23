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
MEEUS = 'lib/core/astro/meeus/il_cielo_di_meeus.dart'
PORTA_SOLA = 'flutter test test/il_cielo_ha_una_porta_sola_test.dart -r expanded'
JPL = 'flutter test test/il_cielo_di_meeus_contro_il_jpl_test.dart -r expanded'
BANCHI = 'flutter test test/i_banchi_col_modello_hanno_un_comando_test.dart -r expanded'
COLLAUDI = 'flutter test test/i_collaudi_sono_registrati_test.dart -r expanded'
SERVER = 'cd functions && npm test'
RUBRICA = 'flutter test test/la_rubrica_resta_sul_telefono_test.dart -r expanded'
SCEGLI = 'lib/features/cerchio/scegli_dalla_rubrica_screen.dart'

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
    ('A23', 'FD.04', LA_PORTA,
     '              child: Material(\n'
     '                type: MaterialType.transparency,\n',
     '              child: KeyedSubtree(\n',
     INDIETRO, 'un tocco avvisa'),
    # FD.05, il Cerchio che si rilegge al ritorno (difetto visto sul Realme).
    ('A33', 'FD.05', 'lib/features/cerchio/il_tuo_cerchio_screen.dart',
     '  void didPopNext() => _rileggi();\n',
     '  void didPopNext() {}\n',
     'flutter test test/il_cerchio_si_rilegge_al_ritorno_test.dart -r expanded',
     'chiusa la rotta sopra'),
    ('A34', 'FD.05', 'lib/features/cerchio/il_tuo_cerchio_screen.dart',
     '    if (stato == AppLifecycleState.resumed) _rileggi();\n',
     '',
     'flutter test test/il_cerchio_si_rilegge_al_ritorno_test.dart -r expanded',
     'tornata in primo piano'),
    # FD.06, la rubrica come prima strada del Cerchio.
    ('A24', 'FD.06', 'docs/ordini/ORDINE_FD_MANIFESTO.md',
     'VOCI_TOTALI: 6\n',
     'VOCI_TOTALI: 5\n',
     'flutter test test/ordine_fd_guard_test.dart -r expanded',
     'i conti tornano'),
    # Regola B delle tre guardie che FD.06 ha toccato: il difetto e' la riga
    # della guardia tolta (o il testo di prima del server), e la guardia
    # deve cadere sul codice nuovo.
    ('B1', 'FD.06', 'test/il_cerchio_non_ha_testo_libero_test.dart',
     "    'rubrica_ricerca': 40,\n", '',
     'flutter test test/il_cerchio_non_ha_testo_libero_test.dart -r expanded',
     '[E]'),
    ('B2', 'FD.06', 'test/le_chiavi_di_ios_ci_sono_tutte_test.dart',
     "    'flutter_contacts': 'NSContactsUsageDescription',\n", '',
     'flutter test test/le_chiavi_di_ios_ci_sono_tutte_test.dart -r expanded',
     '[E]'),
    ('B3', 'FD.06', 'functions/src/la_pagina_dell_invito.ts',
     '    `<p class="nota">Questo invito è scaduto. Chiedi alla persona che te lo ha\n'
     '    mandato di rifarlo.</p>` :',
     '    `<p class="nota">Questo invito non vale più. Chiedine uno nuovo a chi te\n'
     '    l’ha mandato, oppure entra nel Cerchio da solo.</p>` :',
     SERVER, 'EY.04 la pagina del link'),
    ('A25', 'FD.06', INVITA,
     '    _rileggiLaRubricaChiusa();\n',
     '    _rileggiLaRubricaChiusa();\n    LaRubricaDelTelefono.richiesta();\n',
     RUBRICA, 'nessuna richiesta all'),
    ('A26', 'FD.06', SCEGLI,
     '    final numeri = [for (final i in _scelti) contatti[i].numero];',
     '    final numeri = [for (final i in _scelti) contatti[i].numero];\n'
     '    await sociale.chiediIlLegame(sigillo: numeri.join(\',\'));',
     RUBRICA, 'non escono dal telefono'),
    ('A27', 'FD.06', SCEGLI,
     '    final pieno = _scelti.length >= IlMessaggioDellInvito.tetto;',
     '    final pieno = _scelti.length >= 99;',
     RUBRICA, 'le spunte si fermano'),
    ('A28', 'FD.06', SCEGLI,
     "      '${ListinoDegliEos.premioDiChiArrivaConUnInvito} Eos:\\n$link';",
     "      '100 Eos:\\n$link';",
     RUBRICA, 'il link e gli Eos'),
    ('A29', 'FD.06', INVITA,
     '      if (mounted) setState(() => _rubricaChiusa = true);',
     '',
     RUBRICA, 'col permesso negato'),
    ('A30', 'FD.06', INVITA,
     "                titolo: 'Manda il tuo invito',",
     "                titolo: 'Manda il tuo invito',\n"
     "                riga: 'Il link vale trenta giorni e porta solo un codice del '\n"
     "                    'Cerchio: niente del tuo nome vero, niente della tua nascita.',",
     RUBRICA, 'le righe tolte'),
    ('A31', 'FD.06', 'lib/features/cerchio/la_richiesta_di_legame.dart',
     'codice.length == 6 ? rigaDelCodiceScaduto : rigaDelLinkScaduto',
     'rigaDelLinkScaduto',
     RUBRICA, 'dicono la loro riga'),
    ('A32', 'FD.06', 'lib/core/cerchio/la_rubrica_del_telefono.dart',
     '  static Future<List<ContattoDellaRubrica>> Function() leggi = _dalTelefono;',
     '  static List<ContattoDellaRubrica> ultimi = [];\n'
     '  static Future<List<ContattoDellaRubrica>> Function() leggi = _dalTelefono;',
     RUBRICA, 'nessun contatto resta'),
    # FD.02, la porta sola del cielo.
    ('A12', 'FD.02', 'lib/core/astro/night_sky.dart',
     '  static double moonEclipticLongitude(DateTime date) =>',
     '  static double soleMedio(double n) => (280.46 + 0.9856474 * n) % 360;\n\n'
     '  static double moonEclipticLongitude(DateTime date) =>',
     PORTA_SOLA, 'nessuna seconda via'),
    ('A13', 'FD.02', MEEUS,
     "    _pretendi('la longitudine di ${corpo.nome}', jdUt);\n", '',
     JPL, 'non gira'),
    ('A14', 'FD.02', MEEUS,
     '    CorpoCeleste.sole: 0.0001,', '    CorpoCeleste.sole: 0.00005,',
     JPL, 'scarto dichiarato'),
    ('A15', 'FD.02', 'lib/core/cerchio/il_confronto_del_cielo.dart',
     [("import '../astro/meeus/il_cielo_di_meeus.dart';",
       "import '../astro/meeus/il_cielo_di_meeus.dart';\n"
       "import '../astro/night_sky.dart';"),
      ('    final lunaInGradi =\n'
       '        IlCieloDiMeeus.longitudineAllIstante(CorpoCeleste.luna, mezzogiorno);',
       '    final lunaInGradi = NightSky.moonEclipticLongitude(mezzogiorno);')],
     None, PORTA_SOLA, 'viene dalla porta di Meeus'),
    ('A16', 'FD.02', 'lib/core/astro/celestial.dart',
     '    if (scarto.abs() > 0.125) return f;', '    return f;',
     'flutter test test/medora_sa_il_cielo_e_il_responso_test.dart -r expanded',
     'nel giorno chiesto'),
    ('A17', 'FD.02', 'lib/core/astro/meeus/la_luna_intera.dart',
     '    if (i >= 0 && i + 1 < deltaTAnnuale.length) {',
     '    if (i < 0 && i + 1 < deltaTAnnuale.length) {',
     'flutter test test/la_rivoluzione_solare_test.dart -r expanded',
     'contro il JPL'),
    ('A18', 'FD.02', 'lib/core/astro/meeus/eclissi.dart',
     '    _pretendi(anno);\n', '',
     PORTA_SOLA, 'le eclissi non girano'),
    # FD.03, i banchi col modello.
    ('A19', 'FD.03', 'tool/consegna.py',
     '    passati, perche = i_banchi_sono_passati()',
     '    passati, perche = True, \'saltati\'',
     BANCHI, 'la consegna non parte'),
    # FD.05, i collaudi separati.
    ('A20', 'FD.05', 'functions/src/il_cerchio_sociale.ts',
     '  const doc = FRAMMENTO(frammentoDi(uid), spazioDi(uid));',
     '  const doc = FRAMMENTO(frammentoDi(uid), "");',
     SERVER, 'ogni via alla presenza'),
    ('A21', 'FD.05', 'docs/collaudo/registro_dei_collaudi.md',
     '| `iToukegmg2P3LBmlyYGJjkxvFbs1` |',
     '| `iToukegmg2P3LBmlyYGJjkxvFbs2` |',
     COLLAUDI, 'gli stessi account'),
    # FD.01, la lettura dei minuti sul server.
    ('A22', 'FD.01', 'functions/src/live.ts',
     '    apribile: r >= SECONDI_MINIMI_PER_APRIRE,',
     '    apribile: r > 0,',
     SERVER, 'i minuti per la conferma'),
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
        # Le cadute di flutter test portano [E]; quelle del server, col
        # rapporto spec di node, cominciano con la crocetta pesante.
        cadute = [r.strip()[:170] for r in uscita.splitlines()
                  if '[E]' in r or r.lstrip().startswith('✖')]
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
