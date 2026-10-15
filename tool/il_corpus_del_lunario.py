# IL CORPUS DEL CALENDARIO LUNARE. Ordine FV voci FV.06 e FV.07, 15 ottobre
# 2026. Stesso metodo degli altri corpus del ramo (tool/il_corpus_dell_oracolo.py,
# tool/il_corpus_della_sinastria.py): la fonte sta in docs/corpus/lunario/
# (fonti.md, regole.md, testi.md), questo strumento la controlla e scrive il
# Dart in lib/core/lunario/il_corpus_del_lunario.g.dart.
#
# QUESTO STRUMENTO NON CHIAMA NESSUN MODELLO (regola R2 dell'ordine FV e
# regola SPESE di CLAUDE.md): legge la fonte, controlla, scrive il Dart.
#
# La grammatica delle tre fonti e' descritta per esteso in
# docs/corpus/lunario/LEGGIMI.md.
#
# Uso:
#   python tool/il_corpus_del_lunario.py controlla
#   python tool/il_corpus_del_lunario.py genera
#   python tool/il_corpus_del_lunario.py conta
import io
import json
import os
import re
import subprocess
import sys
import tempfile
import time

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FONTE = os.path.join(RADICE, 'docs', 'corpus', 'lunario')
DART = os.path.join(RADICE, 'lib', 'core', 'lunario', 'il_corpus_del_lunario.g.dart')
ATTIVITA_DART = os.path.join(RADICE, 'lib', 'core', 'lunario', 'le_attivita_del_lunario.dart')

F_FONTI = os.path.join(FONTE, 'fonti.md')
F_REGOLE = os.path.join(FONTE, 'regole.md')
F_TESTI = os.path.join(FONTE, 'testi.md')


def _riprova(fn):
    """Windows tiene a volte un file aperto: si riprova."""
    for _ in range(60):
        try:
            return fn()
        except OSError:
            time.sleep(0.5)
    return fn()


def _leggi(p):
    return _riprova(lambda: io.open(p, encoding='utf-8', newline='').read())


def _scrivi(p, testo):
    provvisorio = p + '.nuovo'
    io.open(provvisorio, 'w', encoding='utf-8', newline='').write(testo)
    _riprova(lambda: os.replace(provvisorio, p))


# --- LE CHIAVI VALIDE DI "quando" --------------------------------------------
# Zodiac (lib/core/astro/zodiac.dart): i dodici nomi inglesi minuscoli, esatti
# come i nomi dell'enum Dart.
SEGNI_VALIDI = ['aries', 'taurus', 'gemini', 'cancer', 'leo', 'virgo', 'libra',
                'scorpio', 'sagittarius', 'capricorn', 'aquarius', 'pisces']
# FaseLunare (lib/core/lunario/il_giorno_lunare.dart): gli otto nomi dell'enum.
FASI_VALIDE = ['nuova', 'crescente', 'primoQuarto', 'gibbosaCrescente', 'piena',
               'gibbosaCalante', 'ultimoQuarto', 'calante']
# TipoBiodinamico (lib/core/lunario/il_giorno_lunare.dart): i quattro nomi.
TIPI_VALIDI = ['radice', 'foglia', 'fiore', 'frutto']
LUCE_VALIDA = ['crescente', 'calante']
FUORICORSO_VALIDO = ['si', 'no']

CHIAVI_VALIDE = {'luce', 'fase', 'segno', 'bio', 'fuoricorso'}


def attivita_del_contratto():
    """I nomi dell'enum AttivitaDelLunario, dal contratto Dart."""
    testo = _leggi(ATTIVITA_DART)
    m = re.search(r'enum AttivitaDelLunario\s*\{(.*?)\n\}', testo, re.S)
    if not m:
        raise SystemExit('non trovo enum AttivitaDelLunario in %s' % ATTIVITA_DART)
    corpo = m.group(1)
    nomi = re.findall(r'^\s*(\w+)\(CategoriaDelLunario\.', corpo, re.M)
    if len(nomi) < 20:
        raise SystemExit('troppe poche attivita'' lette dal contratto: %d' % len(nomi))
    return nomi


# --- LETTURA DI fonti.md -----------------------------------------------------

def leggi_fonti():
    """{id: {citazione, indirizzo, letta, dice}}"""
    testo = _leggi(F_FONTI)
    fonti = {}
    for blocco in re.split(r'^### ', testo, flags=re.M)[1:]:
        righe = blocco.split('\n')
        fid = righe[0].strip()
        campi = {}
        for riga in righe[1:]:
            m = re.match(r'^- (citazione|indirizzo|letta|dice):\s*(.*)$', riga)
            if m:
                campi[m.group(1)] = m.group(2).strip()
        fonti[fid] = campi
    return fonti


# --- LETTURA DI regole.md ----------------------------------------------------

def leggi_regole():
    """[{id, attivita, quando_raw, peso, effetto, fonti, detto, _riga_errore}]"""
    testo = _leggi(F_REGOLE)
    regole = []
    for blocco in re.split(r'^### ', testo, flags=re.M)[1:]:
        righe = blocco.split('\n')
        rid = righe[0].strip()
        campi = {'id': rid}
        for riga in righe[1:]:
            m = re.match(
                r'^- (attivita|quando|peso|effetto|fonti|detto):\s*(.*)$', riga)
            if m:
                campi[m.group(1)] = m.group(2).strip()
        regole.append(campi)
    return regole


# --- LETTURA DI testi.md -----------------------------------------------------

def leggi_testi():
    """{"sezione.chiave": testo}"""
    testo = _leggi(F_TESTI)
    out = {}
    sezione = None
    for riga in testo.split('\n'):
        m = re.match(r'^## (\w+)\s*$', riga)
        if m:
            sezione = m.group(1)
            continue
        m = re.match(r'^- ([\w.]+):\s*(.*)$', riga)
        if m and sezione:
            out['%s.%s' % (sezione, m.group(1))] = m.group(2).strip()
    return out


# --- I CONTROLLI DI LINGUA (R7, R8 dell'ordine FV) --------------------------

L = r'A-Za-zÀ-ÿ'
ELISIONI = set('''l un c d dell all nell sull dall quest sant m t s v gl gli
anch nessun ciascun buon grand bell tutt qual po di fa va sta da mo be to n
senz sopr contr dentr sott quell part com or ver tal altr nostr vostr vent
trent quarant cinquant sessant settant ottant novant qualcos'''.split())
APOSTROFO = re.compile(r"([%s]+)'" % L)
SENZA_ACCENTO = set('''piu perche poiche benche finche nonche affinche gia
cosi puo cioe percio sara fara dara potra verra andra avra citta liberta
verita qualita quantita possibilita responsabilita identita realta novita
universita virtu gioventu tribu lunedi martedi mercoledi giovedi
venerdi'''.split())
VIRGOLA_E = re.compile(r',\s+(e|ed)(?![%s])' % L, re.I)
TRATTINO = re.compile(r'[—–]|\s-\s')
DOPPIA = re.compile(r'(?<![%s])([%s]{3,})\s+\1(?![%s])' % (L, L, L), re.I)
CIFRA = re.compile(r'\d')
FUTURO = re.compile(
    r"(?<![%s])(?!però(?![%s]))[%s]{2,}(rà|rai|ranno|rò)(?![%s])" % (L, L, L, L),
    re.I)
CERTEZZA = re.compile(
    r"(?<![%s])(di sicuro|sicuramente|certamente|senza dubbio|per sempre|"
    r"è scritto|destino segnato|garantit\w*|ti prometto|promesso|"
    r"inevitabilmente|immancabilmente|vedrai che)(?![%s])" % (L, L), re.I)

# LA POLITICA R8 DELL'ORDINE FV: niente salute, niente soldi, nessuna
# promessa di esito, niente fertilita'/fecondita', mai la NASA nei testi di
# Medora.
POLITICA = re.compile(
    r"(?<![%s])("
    r"salute|sanità|malat\w*|guari\w*|curativ\w*|terapi\w*|rimedi\w*|"
    r"farmac\w*|medic\w*|dentist\w*|diet\w*|digiun\w*|sintom\w*|dottor\w*|"
    r"ospedal\w*|"
    r"fertil\w*|steril\w*|fecond\w*|gravid\w*|incint\w*|concepi\w*|"
    r"soldi|denar\w*|guadagn\w*|investiment\w*|invest\w*|ricchezz\w*|"
    r"patrimon\w*|"
    r"garantit\w*|successo assicurat\w*|vittoria certa|esito certo|"
    r"nasa|"
    r"gioco|giochi|sfida|sfide|punteggio|classifica"
    r")(?![%s])" % (L, L), re.I)

# IL TU: solo per testi.md (giorni tuoi), che si rivolgono alla persona.
SEGNI_DEL_TU = re.compile(
    r"(?<![%s])(tu|ti|te|tuo|tua|tuoi|tue|hai|sei|puoi|vuoi|sai|fai|dai|"
    r"stai|vai|senti|cerchi|guardi|chiedi|scegli|lascia|prova|parla|nota|"
    r"ricorda|ascolta|accendi|siedi|respira|pronuncia|scrivi|tieni|prendi|"
    r"metti|chiudi|apri|resta|torna|accogli|osserva|guarda|chiediti|"
    r"fermati|dì|hanno|affidi|cominciato)(?![%s])" % (L, L), re.I)
SEGNI_DEL_VOI = re.compile(
    r"(?<![%s])(voi|vostro|vostra|vostri|vostre|siete|avete|potete|sapete)"
    r"(?![%s])" % (L, L), re.I)
MARCA = re.compile(r'\[[^\[\]]*\]')
MARCA_BUONA = re.compile(r'\[[^\[\]|]+\|[^\[\]|]+\|[^\[\]|]+\]')


def _controlli_di_lingua(testo):
    """Gli accenti, la virgola, il trattino, le ripetizioni, il futuro: gli
    stessi per qualunque testo del corpus, comprese le citazioni di
    fonti.md (dove una cifra o una virgoletta sono normali e non si
    controllano qui: vedi [_controlli_comuni])."""
    colpe = []
    for m in APOSTROFO.finditer(testo):
        if m.group(1).lower() not in ELISIONI:
            colpe.append('apostrofo che non e\' un\'elisione ammessa (accento '
                         'finto?): "%s"' % m.group(0))
    for p in re.findall(r'[%s]+' % L, testo):
        if p.lower() in SENZA_ACCENTO:
            colpe.append('parola senza accento: "%s"' % p)
    if VIRGOLA_E.search(testo):
        colpe.append('virgola prima di "e" o "ed"')
    if TRATTINO.search(testo):
        colpe.append('trattino lungo o trattino usato come lineetta')
    if DOPPIA.search(testo):
        colpe.append('parola ripetuta due volte di fila: "%s"' % DOPPIA.search(testo).group(0))
    m = FUTURO.search(testo)
    if m:
        colpe.append('futuro detto come certezza: "%s"' % m.group(0))
    m = CERTEZZA.search(testo)
    if m:
        colpe.append('certezza sul futuro: "%s"' % m.group(0))
    m = POLITICA.search(testo)
    if m:
        colpe.append('parola vietata dalla politica R8: "%s"' % m.group(0))
    return colpe


def _controlli_comuni(testo):
    """I controlli di lingua, piu' quelli che valgono solo per i testi nella
    voce di Medora (detto, testi.md): nessuna cifra (gli orari li scrive il
    motore) e nessuna citazione fra virgolette."""
    colpe = _controlli_di_lingua(testo)
    if CIFRA.search(testo):
        colpe.append('cifra nel testo (gli orari li scrive il motore, non il corpus)')
    if '«' in testo or '»' in testo:
        colpe.append('citazione fra virgolette')
    return colpe


def difetti_di_fonte(testo):
    """fonti.md: citazioni bibliografiche. Le cifre (anni, edizioni) e le
    virgolette (titoli) sono normali e non si controllano; il resto della
    lingua di casa si'."""
    return _controlli_di_lingua(testo)


def difetti_di_detto(testo):
    """Le regole di regole.md: brevi etichette, non si rivolgono al tu."""
    colpe = _controlli_comuni(testo)
    if not (2 <= len(testo) <= 90):
        colpe.append('lunghezza %d fuori da 2-90' % len(testo))
    if SEGNI_DEL_VOI.search(testo):
        colpe.append('si rivolge al voi')
    return colpe


def difetti_di_testo(testo):
    """testi.md: la voce di Medora, seconda persona, con la marca del genere."""
    colpe = _controlli_comuni(testo)
    if not (40 <= len(testo) <= 500):
        colpe.append('lunghezza %d fuori da 40-500' % len(testo))
    senza_marche = MARCA.sub(' ', testo)
    if not SEGNI_DEL_TU.search(senza_marche) and '[' not in testo:
        colpe.append('non si rivolge a te (seconda persona singolare)')
    if SEGNI_DEL_VOI.search(testo):
        colpe.append('si rivolge al voi')
    for m in MARCA.finditer(testo):
        if not MARCA_BUONA.fullmatch(m.group(0)):
            colpe.append('marca del genere malformata: %s' % m.group(0))
    return colpe


FORME_EXE = os.environ.get('FORME_DEL_GENERE_EXE') or os.path.join(
    RADICE, '.dart_tool', 'forme_del_genere_dei_testi.exe')


def forme_del_genere(testi):
    """Il criterio di casa (lib/core/chat/le_forme_del_genere.dart), chiamato
    in Dart via tool/forme_del_genere_dei_testi.dart: una lista di liste di
    difetti, una per testo, nello stesso ordine."""
    if not testi:
        return []
    fd, nome = tempfile.mkstemp(suffix='.json')
    with os.fdopen(fd, 'w', encoding='utf-8') as f:
        json.dump(testi, f, ensure_ascii=False)
    usa_exe = FORME_EXE and os.path.exists(FORME_EXE)
    comando = ([FORME_EXE, nome] if usa_exe
               else ['dart', 'run', 'tool/forme_del_genere_dei_testi.dart', nome])
    try:
        uscita = subprocess.run(
            comando, cwd=RADICE, capture_output=True, text=True,
            encoding='utf-8', shell=(os.name == 'nt' and not usa_exe))
        testo = uscita.stdout[uscita.stdout.find('['):]
        esito = json.loads(testo)
        if len(esito) != len(testi):
            raise SystemExit('il criterio del genere non ha risposto per tutti')
        return esito
    finally:
        _riprova(lambda: os.remove(nome))


# --- IL PARSING DI "quando" --------------------------------------------------

def analizza_quando(raw):
    """La stringa di "quando" -> (CondizioneDelLunarioRaw, [colpe]).

    Restituisce un dict con le chiavi trovate (liste di stringhe) e la lista
    dei difetti di grammatica (chiave o valore non validi).
    """
    colpe = []
    chiavi = {}
    for pezzo in raw.split(';'):
        pezzo = pezzo.strip()
        if not pezzo:
            continue
        m = re.match(r'^(\w+)\s*=\s*(.+)$', pezzo)
        if not m:
            colpe.append('condizione illeggibile: "%s"' % pezzo)
            continue
        chiave, valori_raw = m.group(1), m.group(2)
        if chiave not in CHIAVI_VALIDE:
            colpe.append('chiave non valida: "%s"' % chiave)
            continue
        valori = [v.strip() for v in valori_raw.split(',') if v.strip()]
        validi = {
            'luce': LUCE_VALIDA, 'fase': FASI_VALIDE, 'segno': SEGNI_VALIDI,
            'bio': TIPI_VALIDI, 'fuoricorso': FUORICORSO_VALIDO,
        }[chiave]
        for v in valori:
            if v not in validi:
                colpe.append('valore non valido per %s: "%s"' % (chiave, v))
        if chiave in chiavi:
            colpe.append('chiave ripetuta: "%s"' % chiave)
        chiavi[chiave] = valori
    return chiavi, colpe


# --- CONTROLLA ----------------------------------------------------------------

def controlla():
    colpe = []
    fonti = leggi_fonti()
    for fid, campi in fonti.items():
        for campo in ('citazione', 'indirizzo', 'letta', 'dice'):
            if not campi.get(campo):
                colpe.append('fonte %s: manca "%s"' % (fid, campo))
            else:
                for c in difetti_di_fonte(campi[campo]):
                    colpe.append('fonte %s %s: %s' % (fid, campo, c))

    regole = leggi_regole()
    visti = set()
    attivita_con_fonte_vera = set()
    tutte_le_attivita = set(attivita_del_contratto())
    detti = []
    for r in regole:
        rid = r['id']
        if rid in visti:
            colpe.append('regola ripetuta: %s' % rid)
        visti.add(rid)
        nomi_attivita = [a.strip() for a in r.get('attivita', '').split(',') if a.strip()]
        if not nomi_attivita:
            colpe.append('%s: manca "attivita"' % rid)
        for a in nomi_attivita:
            if a not in tutte_le_attivita:
                colpe.append('%s: attivita\' inesistente nel contratto: "%s"' % (rid, a))
        quando_raw = r.get('quando', '')
        if not quando_raw:
            colpe.append('%s: manca "quando"' % rid)
        chiavi, colpe_quando = analizza_quando(quando_raw)
        for c in colpe_quando:
            colpe.append('%s: %s' % (rid, c))
        ha_peso = 'peso' in r and r['peso'] != ''
        ha_effetto = 'effetto' in r and r['effetto'] != ''
        if ha_peso and ha_effetto:
            colpe.append('%s: porta "peso" ed "effetto" insieme' % rid)
        if not ha_peso and not ha_effetto:
            colpe.append('%s: non porta ne\' "peso" ne\' "effetto"' % rid)
        if ha_peso and not re.match(r'^[+-]?\d+$', r['peso']):
            colpe.append('%s: peso non e\' un intero con segno: "%s"' % (rid, r['peso']))
        if ha_effetto and r['effetto'] != 'toglie_oro':
            colpe.append('%s: effetto non riconosciuto: "%s"' % (rid, r['effetto']))
        fonti_regola = [f.strip() for f in r.get('fonti', '').split(',') if f.strip()]
        if not fonti_regola:
            colpe.append('%s: manca "fonti"' % rid)
        for f in fonti_regola:
            if f not in fonti:
                colpe.append('%s: fonte inesistente: "%s"' % (rid, f))
        if any(f != 'chiave_di_medora' for f in fonti_regola):
            for a in nomi_attivita:
                attivita_con_fonte_vera.add(a)
        detto = r.get('detto', '')
        if not detto:
            colpe.append('%s: manca "detto"' % rid)
        else:
            for c in difetti_di_detto(detto):
                colpe.append('%s detto: %s' % (rid, c))
            detti.append(detto)

    senza_regola = tutte_le_attivita - attivita_con_fonte_vera
    for a in sorted(senza_regola):
        colpe.append('attivita\' senza una regola con una fonte vera: %s' % a)

    testi = leggi_testi()
    chiavi_attese_giorni_tuoi = {
        'giorni_tuoi.ritorno_lunare', 'giorni_tuoi.luna_sul_sole',
        'giorni_tuoi.luna_nel_segno', 'giorni_tuoi.fase_di_nascita',
    }
    mancanti = chiavi_attese_giorni_tuoi - set(testi)
    for m in sorted(mancanti):
        colpe.append('testi.md: manca la chiave dei giorni tuoi "%s"' % m)
    testi_validi_per_genere = []
    for chiave, testo in testi.items():
        for c in difetti_di_testo(testo):
            colpe.append('testi.md %s: %s' % (chiave, c))
        testi_validi_per_genere.append((chiave, testo))

    # Il criterio di casa sul genere: i "detto" sono etichette (mai "tu"), i
    # testi.md si rivolgono alla persona e vanno passati al criterio vero.
    for (chiave, testo), forme in zip(
            testi_validi_per_genere,
            forme_del_genere([t for _, t in testi_validi_per_genere])):
        if forme:
            colpe.append('testi.md %s: genere di chi legge %s' % (chiave, forme))

    for c in colpe:
        print(c)
    print('DIFETTI: %d' % len(colpe))
    return colpe


# --- CONTA --------------------------------------------------------------------

def conta():
    fonti = leggi_fonti()
    regole = leggi_regole()
    testi = leggi_testi()
    print('fonti: %d' % len(fonti))
    print('regole: %d' % len(regole))
    print('testi: %d' % len(testi))
    tutte = set(attivita_del_contratto())
    con_fonte = set()
    for r in regole:
        fonti_regola = [f.strip() for f in r.get('fonti', '').split(',') if f.strip()]
        if any(f != 'chiave_di_medora' for f in fonti_regola):
            for a in [x.strip() for x in r.get('attivita', '').split(',') if x.strip()]:
                con_fonte.add(a)
    print('attivita\' del contratto: %d, con almeno una regola con fonte vera: %d'
          % (len(tutte), len(con_fonte & tutte)))
    senza = sorted(tutte - con_fonte)
    if senza:
        print('senza regola con fonte vera: %s' % ', '.join(senza))


# --- GENERA -------------------------------------------------------------------

def _d(t):
    return "'" + t.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$') + "'"


LUCE_DART = {'crescente': 'LuceDellaLuna.crescente', 'calante': 'LuceDellaLuna.calante'}
FUORICORSO_DART = {'si': 'true', 'no': 'false'}


def _condizione_dart(chiavi):
    pezzi = []
    if 'luce' in chiavi:
        pezzi.append('luce: %s' % LUCE_DART[chiavi['luce'][0]])
    if 'fase' in chiavi:
        pezzi.append('fasi: [%s]' % ', '.join('FaseLunare.%s' % v for v in chiavi['fase']))
    if 'segno' in chiavi:
        pezzi.append('segni: [%s]' % ', '.join('Zodiac.%s' % v for v in chiavi['segno']))
    if 'bio' in chiavi:
        pezzi.append('tipi: [%s]' % ', '.join('TipoBiodinamico.%s' % v for v in chiavi['bio']))
    if 'fuoricorso' in chiavi:
        pezzi.append('fuoriCorso: %s' % FUORICORSO_DART[chiavi['fuoricorso'][0]])
    return 'CondizioneDelLunario(%s)' % ', '.join(pezzi)


def genera():
    colpe = controlla()
    if colpe:
        raise SystemExit('LA FONTE NON E\' PRONTA: nessun Dart scritto a meta\'.')
    fonti = leggi_fonti()
    regole = leggi_regole()
    testi = leggi_testi()

    out = io.StringIO()
    out.write(
        "// GENERATO da tool/il_corpus_del_lunario.py dalla fonte in\n"
        "// docs/corpus/lunario/. Non si modifica a mano: si corregge la\n"
        "// fonte e si rigenera. Ordine FV voci FV.06 e FV.07.\n\n"
        "import '../astro/zodiac.dart';\n"
        "import 'il_giorno_lunare.dart';\n"
        "import 'la_regola_del_lunario.dart';\n"
        "import 'le_attivita_del_lunario.dart';\n\n"
        "/// Le fonti del corpus lunare, per id (docs/corpus/lunario/fonti.md).\n"
        "const Map<String, FonteDelLunario> fontiDelLunario = {\n"
    )
    for fid in sorted(fonti):
        c = fonti[fid]
        out.write(
            "  '%s': FonteDelLunario(\n"
            "    id: '%s',\n"
            "    citazione: %s,\n"
            "    indirizzo: %s,\n"
            "    letta: %s,\n"
            "    dice: %s,\n"
            "  ),\n" % (fid, fid, _d(c['citazione']), _d(c['indirizzo']),
                        _d(c['letta']), _d(c['dice']))
        )
    out.write(
        "};\n\n"
        "/// Le regole del corpus lunare (docs/corpus/lunario/regole.md).\n"
        "const List<RegolaDelLunario> regoleDelLunario = [\n"
    )
    for r in regole:
        nomi_attivita = [a.strip() for a in r['attivita'].split(',') if a.strip()]
        chiavi, _ = analizza_quando(r['quando'])
        fonti_regola = [f.strip() for f in r['fonti'].split(',') if f.strip()]
        peso = r.get('peso', '')
        toglie = r.get('effetto', '') == 'toglie_oro'
        out.write(
            "  RegolaDelLunario(\n"
            "    id: '%s',\n"
            "    attivita: [%s],\n"
            "    quando: %s,\n"
            "    peso: %s,\n"
            "    toglieLOro: %s,\n"
            "    fonti: [%s],\n"
            "    detto: %s,\n"
            "  ),\n" % (
                r['id'],
                ', '.join('AttivitaDelLunario.%s' % a for a in nomi_attivita),
                _condizione_dart(chiavi),
                int(peso) if peso else 0,
                'true' if toglie else 'false',
                ', '.join(_d(f) for f in fonti_regola),
                _d(r['detto']),
            )
        )
    out.write(
        "];\n\n"
        "/// I testi del corpus lunare non legati a una regola, chiave\n"
        "/// \"sezione.chiave\" (docs/corpus/lunario/testi.md).\n"
        "const Map<String, String> testiDelLunario = {\n"
    )
    for chiave in sorted(testi):
        out.write("  '%s': %s,\n" % (chiave, _d(testi[chiave])))
    out.write("};\n")

    os.makedirs(os.path.dirname(DART), exist_ok=True)
    _scrivi(DART, out.getvalue())
    print('scritto', DART)


if __name__ == '__main__':
    comando = sys.argv[1] if len(sys.argv) > 1 else ''
    if comando == 'controlla':
        sys.exit(1 if controlla() else 0)
    elif comando == 'conta':
        conta()
    elif comando == 'genera':
        genera()
    else:
        print('comandi: controlla, conta, genera')
        sys.exit(2)
