"""LA REGOLA A DELL'ORDINE FF: ogni prova nuova vista rossa sul suo difetto.

Stessa forma del banco dell'ordine FE (`gli_innesti_dell_ordine_fe.py`): per
ogni innesto la copia del file, il difetto messo a mano, il controllo che
l'innesto sia ENTRATO, la prova fatta girare, l'esito letto, il nome della
prova che DEVE cadere cercato fra le cadute, il file rimesso dalla copia e
confrontato al byte.

Uso: PYTHONIOENCODING=utf-8 python tool/gli_innesti_dell_ordine_ff.py [sigla ...]
L'esito si scrive in docs/collaudo/FF/regola_a_ff.txt (in coda).
"""
import io
import os
import shutil
import subprocess
import sys
import time

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(RADICE)

VERDETTI = 'tool/banchi_col_modello/i_verdetti_del_filo.dart'
BANCO_FILO = 'tool/banchi_col_modello/il_filo_del_consulto_col_modello_test.dart'
PROVA_VERDETTI = 'flutter test test/i_verdetti_del_filo_test.dart -r expanded'
IPHONE = 'flutter test test/le_push_arrivano_su_iphone_test.dart -r expanded'
PRESENZA = 'flutter test test/chi_esce_dal_cerchio_esce_dal_conto_test.dart -r expanded'
GENERE = 'flutter test test/il_genere_non_si_indovina_test.dart -r expanded'
SOGLIA = 'flutter test test/la_soglia_del_sonno_test.dart -r expanded'
REGOLE = 'flutter test test/gli_enigmi_rispettano_le_regole_test.dart -r expanded'
RITRATTO = 'flutter test test/il_ritratto_e_la_prova_test.dart -r expanded'
VIDEO = 'flutter test test/gli_enigmi_a_video_test.dart -r expanded'

# sigla, voce, file, vecchio, nuovo, comando, la prova che deve cadere
INNESTI = [
    # FF.08, il giudice separa le contraddizioni dichiarate.
    ('F1', 'FF.08', VERDETTI,
     '      case cambiaDichiarando:\n        dichiarate++;',
     '      case cambiaDichiarando:\n        aTradimento++;',
     PROVA_VERDETTI, 'le dichiarate non sono un difetto'),
    ('F2', 'FF.08', VERDETTI,
     '  bool get passa => aTradimento <= 2 &&',
     '  bool get passa => aTradimento <= 3 &&',
     PROVA_VERDETTI, 'tre contraddizioni a tradimento'),
    ('F3', 'FF.08', VERDETTI,
     'CAMBIA_DICHIARANDO: afferma il contrario',
     'CAMBIA DICHIARANDO: afferma il contrario',
     PROVA_VERDETTI, 'la regola nomina i quattro verdetti'),
    ('F4', 'FF.08', BANCO_FILO,
     '      expect(conteggio.aTradimento, lessThanOrEqualTo(2),',
     '      expect(conteggio.aTradimento + conteggio.dichiarate,\n          lessThanOrEqualTo(2),',
     PROVA_VERDETTI, 'il banco del filo usa questa regola'),
    # FF.09, le push su iPhone.
    ('F5', 'FF.09', 'ios/Runner/Runner.entitlements',
     '\t<key>aps-environment</key>\n\t<string>production</string>\n',
     '',
     IPHONE, 'Runner.entitlements dichiara le push'),
    ('F6', 'FF.09', 'ios/Runner/Runner.entitlements',
     '\t<string>production</string>',
     '\t<string>development</string>',
     IPHONE, 'Runner.entitlements dichiara le push'),
    ('F7', 'FF.09', 'ios/Runner/Info.plist',
     '\t\t<string>remote-notification</string>\n',
     '',
     IPHONE, 'Info.plist accetta la spinta silenziosa'),
    ('F8', 'FF.09', 'lib/services/avvisi_locali.dart',
     '    if (concesso) IlPermessoConcesso.annuncia();\n',
     '',
     IPHONE, 'il recapito si rilegge appena'),
    ('F9', 'FF.09', 'lib/features/push/custode_montato.dart',
     '    _permesso = IlPermessoConcesso.flusso.listen((_) => _rileggi());',
     '    _permesso = null;',
     'flutter test test/le_push_sono_montate_test.dart -r expanded',
     'il permesso concesso a sessione aperta'),
    ('F10', 'FF.09', 'functions/src/push.ts',
     '          payload: {aps: {contentAvailable: true}},\n',
     '',
     IPHONE, 'il server spinge al recapito'),
    ('F11', 'FF.09', 'test/i_diritti_di_ios_hanno_il_loro_passo_sul_portale_test.dart',
     "    'aps-environment': 'Push Notifications',\n",
     '',
     'flutter test test/i_diritti_di_ios_hanno_il_loro_passo_sul_portale_test.dart -r expanded',
     'ogni diritto di Runner.entitlements'),
    # FF.01, la presenza non si spegne in secondo piano.
    ('F12', 'FF.01', 'functions/src/presenza.ts',
     'export const FINESTRA_DELLA_PRESENZA_MS = 5 * 60 * 1000;',
     'export const FINESTRA_DELLA_PRESENZA_MS = OGNI_QUANTO_CHIEDE_MS + 30 * 1000;',
     'cd functions && npm test', 'FF.01 a)'),
    ('F13', 'FF.01', 'functions/src/cerchio.ts',
     '    await scriviLUscita(uid, adesso);\n    return {quanti: 0};',
     '    await scriviLaPresenza(uid, null);\n    return {quanti: 0};',
     PRESENZA, 'chi va sullo sfondo lascia il suo ultimo segno'),
    ('F14', 'FF.01', 'functions/src/il_cerchio_sociale.ts',
     '    await doc.update({[`p.${uid}.u`]: adesso});',
     '    await doc.update({[`p.${uid}`]: FieldValue.delete()});',
     PRESENZA, 'chi va sullo sfondo lascia il suo ultimo segno'),
    ('F15', 'FF.01', 'lib/services/server/chi_e_online.dart',
     '      if (_passo != null) unawaited(_porta.esciDalCerchio());',
     '      // uscita tolta',
     PRESENZA, 'le scritture di una sessione di dieci minuti'),
    # FF aggiunta 1, voce A3: la marca del genere nei corpora degli Enigmi.
    ('F16', 'FF.A3', 'lib/core/cerchio/il_testo_degli_enigmi.dart',
     '      _risolvi(testoMarcato, CourtesyForm.neutral);',
     '      _risolvi(testoMarcato, CourtesyForm.feminine);',
     GENERE, 'FF.A3 c)'),
    ('F17', 'FF.A3', 'lib/core/cerchio/il_testo_degli_enigmi.dart',
     '  static String perChiCompila(String testoMarcato, CourtesyForm forma) =>\n      _risolvi(testoMarcato, forma);',
     '  static String perChiCompila(String testoMarcato, CourtesyForm forma) =>\n      _risolvi(testoMarcato, CourtesyForm.masculine);',
     GENERE, 'FF.A3 a)'),
    ('F18', 'FF.A3', 'lib/core/cerchio/il_testo_degli_enigmi.dart',
     '      throw MarcaNonRisolta(testo);',
     '      return fuori;',
     GENERE, 'FF.A3 d)'),
    ('F19', 'FF.A3', 'docs/corpus/Corpus_Il_Ritratto.md',
     '29. Sono [quello|quella|la persona] che',
     '29. Sono [quello|quella] che',
     GENERE, 'FF.A3 e)'),
    # FF aggiunta 1, voce A10: la scheda della Soglia del Sonno.
    ('F20', 'FF.A10', 'lib/features/santuario/le_righe_della_casa.dart',
     "        'soglia_del_sonno',\n",
     '',
     SOGLIA, 'FF.A10 a)'),
    ('F21', 'FF.A10', 'lib/core/arts/l_ordine_dei_domini.dart',
     "          'soglia_del_sonno',\n",
     '',
     SOGLIA, 'FF.A10 b)'),
    ('F22', 'FF.A10', 'lib/core/arts/art_catalog.dart',
     '        icon: Icons.dark_mode_rounded,\n        state: ArtState.inArrivo,',
     '        icon: Icons.dark_mode_rounded,\n        state: ArtState.attiva,',
     SOGLIA, 'FF.A10 c) e d)'),
    ('F23', 'FF.A10', 'lib/core/arts/gli_sfondi_delle_schede.dart',
     "    'soglia_del_sonno': 'Soglia-Sonno',\n",
     '',
     SOGLIA, 'FF.A10 e)'),
    ('F24', 'FF.A10', 'lib/core/arts/art_catalog.dart',
     "        title: 'La Soglia del Sonno',",
     "        title: 'La soglia del sonno',",
     SOGLIA, 'FF.A10 f)'),
    # FF.02-FF.07, i giochi del Cerchio.
    ('F25', 'FF.06', 'functions/src/gli_enigmi.ts',
     '    b.indovinati - a.indovinati || a.uid.localeCompare(b.uid));',
     '    a.uid.localeCompare(b.uid));',
     REGOLE, 'FF.06.1'),
    ('F26', 'FF.02', 'functions/src/il_cerchio_sociale.ts',
     '        ok: true, partita: id, facce, domanda: p.domanda, indizi,',
     '        ok: true, partita: id, facce, domanda: p.domanda, indizi, dati: p.dati,',
     REGOLE, 'FF.02.6 d)'),
    ('F27', 'FF.06', 'functions/src/il_cerchio_sociale.ts',
     '    await tettoDellaPorta(uid, "unPassoDelPellegrinaggio");',
     '    await tettoDellaPorta(uid, "unPassoDelPellegrinaggio");\n    await pianoDi(uid);',
     REGOLE, 'FF.06.5 b)'),
    ('F28', 'FF.07', 'functions/src/il_cerchio_sociale.ts',
     '      chiudiLeSfideScadute(uid, adesso)]);',
     '      Promise.resolve([])]);',
     REGOLE, 'FF.07.3 b)'),
    ('F29', 'FF.04', 'functions/src/gli_enigmi.ts',
     '  return ritrattoValido(p.ritratto) !== null && p.fuoriDaiGiochi !== true &&',
     '  return ritrattoValido(p.ritratto) !== null &&',
     'cd functions && npm test', 'FF.04 c)'),
    ('F30', 'FF.05', 'functions/src/gli_enigmi.ts',
     '  if (a.provaDellAmico) return "tardi";\n',
     '',
     'cd functions && npm test', 'FF.05 d)'),
    ('F31', 'FF.02', 'lib/core/cerchio/il_ritratto.dart',
     '    return scelte.length == quante &&\n        insieme.length == quante &&',
     '    return scelte.length >= quante - 1 &&\n        insieme.length >= quante - 1 &&',
     RITRATTO, 'c) il Ritratto non si chiude'),
    ('F32', 'FF.02', 'lib/features/cerchio/enigmi/gli_enigmi_screen.dart',
     '        onPressed: v.ritrattoCompilato && v.indovinelliRimasti > 0',
     '        onPressed: v.indovinelliRimasti > 0',
     VIDEO, 'FF.02 a)'),
    ('F33', 'FF.07', 'lib/features/cerchio/enigmi/gli_enigmi_screen.dart',
     "      RigaDegliEnigmi(\n          'Finisce fra ${ilTempoCheResta(ITempiDeiGiochi.resta(scadeLaProva, _adesso))}.'),",
     "      const RigaDegliEnigmi('Finisce con la settimana.'),",
     VIDEO, 'FF.07 a)'),
    ('F34', 'FF.03', 'functions/src/gli_indizi.ts',
     '  return n === 1 ? 0 : PREZZO_DELL_INDIZIO;',
     '  return PREZZO_DELL_INDIZIO;',
     'cd functions && npm test', 'FF.03 c)'),
    ('F35', 'FF.03', 'functions/src/gli_indizi.ts',
     'export const PUNTI_PER_INDIZI = [3, 2, 1, 0.5] as const;',
     'export const PUNTI_PER_INDIZI = [3, 3, 2, 1] as const;',
     'cd functions && npm test', 'FF.03 d)'),
    ('F36', 'FF.03', 'functions/src/gli_indizi.ts',
     '  "archetipoSecondario",\n] as const;',
     '  "archetipoSecondario",\n  "orariDiApertura",\n] as const;',
     'cd functions && npm test', 'FF.03 b)'),
    ('F37', 'FF.04', 'functions/src/il_cerchio_sociale.ts',
     '          segni: [...(voce.segni ?? []), io.segno ?? "sconosciuto"],',
     '          segni: [...(voce.segni ?? []), `${uid}:${io.segno ?? ""}`],',
     'cd functions && npm test', 'FF.04 d)'),
    ('F38', 'FF.06', 'lib/features/cerchio/enigmi/gli_enigmi_screen.dart',
     '                  flex: passo.quanti,',
     '                  flex: 1,',
     VIDEO, 'FF.06 c)'),
    ('F39', 'FF.02', 'lib/core/cerchio/il_ritratto.dart',
     '      final inizio = giornoDiNascita % n;',
     '      const inizio = 0;',
     RITRATTO, 'b) due carte diverse'),
    ('F40', 'FF.05', 'lib/core/cerchio/la_prova.dart',
     '      return CriterioDelCielo.mercurioRetrogrado;',
     '      return CriterioDelCielo.nessuno;',
     RITRATTO, 'b) il tema segue il cielo'),
    ('F41', 'FF.05', 'functions/src/gli_enigmi.ts',
     '  const salta = new Set([r, (r + 1) % 12]);',
     '  const salta = new Set([r, (r + 2) % 12]);',
     'cd functions && npm test', 'FF.05 la settimana'),
    ('F42', 'FF.09', 'lib/core/permissions/app_permission.dart',
     "        body: defaultTargetPlatform == TargetPlatform.iOS",
     "        body: defaultTargetPlatform == TargetPlatform.fuchsia",
     IPHONE, 'FF.09.4'),
]


def leggi(p):
    return io.open(p, encoding='utf-8', newline='').read()


def con_pazienza(fai):
    """Windows tiene a volte un file chiuso per qualche istante (Errno 22 o
    13, mentre l'analizzatore o la suite lo leggono): si riprova per due
    minuti prima di arrendersi. Il 6 ottobre 2026 lo strumento e' caduto due
    volte cosi', a meta' innesto."""
    for _ in range(240):
        try:
            return fai()
        except OSError:
            time.sleep(0.5)
    return fai()


def scrivi(p, s):
    con_pazienza(lambda: io.open(p, 'w', encoding='utf-8', newline='').write(s))


def un_innesto(sigla, voce, percorso, vecchio, nuovo, comando, bersaglio):
    copia = percorso + '.copia_regola_a'
    con_pazienza(lambda: shutil.copyfile(percorso, copia))
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
                  if r.startswith('ORDINE F')][:2]
        return ('%s (%s) %s: innesto entrato (grep del pezzo nuovo 1, del vecchio 0); '
                '%s; bersaglio "%s" %s; cadute: %s; misure lette: %s') % (
                    sigla, voce, percorso,
                    'ROSSA' if rossa else 'VERDE (la prova NON vede il difetto)',
                    bersaglio, 'colpito' if nel_bersaglio else 'NON COLPITO',
                    ' | '.join(cadute[:2]) if cadute else '(nessuna riga di caduta letta)',
                    ' | '.join(misure) if misure else '(nessuna)')
    finally:
        con_pazienza(lambda: shutil.copyfile(copia, percorso))
        os.remove(copia)


def main():
    scelte = set(sys.argv[1:])
    os.makedirs('docs/collaudo/FF', exist_ok=True)
    registro = 'docs/collaudo/FF/regola_a_ff.txt'
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
