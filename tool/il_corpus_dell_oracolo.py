# IL CORPUS DELL'ORACOLO DEGLI ANGELI. Ordine FU voci FU.05 e FU.07, 15
# ottobre 2026. Metodo dell'ordine FM e del corpus della Sinastria evolutiva
# (tool/il_corpus_della_sinastria.py): prima gli schedari, poi i testi,
# scritti da agenti che li mandano a questo strumento; lo strumento scrive
# nella fonte SOLO i testi che passano i controlli e rimanda gli altri col
# difetto.
#
# QUESTO STRUMENTO NON CHIAMA NESSUN MODELLO (regola R2 dell'ordine FU e
# regola SPESE di CLAUDE.md): legge la fonte, controlla, scrive il Dart.
#
# LA FONTE sta in docs/corpus/oracolo_angeli/: custode.md, cuore.md,
# intelletto.md (la voce di Medora: tre messaggi per angelo) e rito.md (la
# voce di Caligo: due riti per angelo). Ogni cella e' una riga
# "## NN Nome" (NN a due cifre, Nome = seedName di
# lib/core/angels/angel_catalog.dart) seguita dalle righe
# "- <campo> <n>: <testo>" (testo vuoto = da scrivere).
#
# **IL CONSIGLIO, ordine GA voci GA.03, GA.05 e GA.07, 20 ottobre 2026.**
# Ogni carta singola si legge nella forma nuova dei responsi: il suo
# messaggio e sotto il riquadro "Cosa fare adesso". Il testo del riquadro e'
# il campo `consiglio`, nella stessa cella e nello stesso file del messaggio:
# il consiglio n accompagna il messaggio n. Messaggio e consiglio si misurano
# in PAROLE, da 40 a 50 (il fondatore, 19 ottobre 2026: "tutte le risposte
# composte da paragrafi ognuno con tra 40 a 50 parole ognuno"), contate come
# `LaFormaDelResponso.parole`, separate da uno spazio; la misura in caratteri
# dell'ordine FU resta solo per il rito. Le parti scritte dagli agenti si
# portano nella fonte col comando `applica`, che passa da `riempi` e quindi
# da tutti i controlli qui sotto.
#
# I CONTROLLI (regole R7 e R8 dell'ordine FU, la POLITICA DI PUBBLICAZIONE
# di docs/corpus/angeli.md, le guardie di casa sui testi a video):
#  - lunghezza per campo (in parole per messaggio e consiglio, in caratteri
#    per il rito);
#  - il consiglio non ripete il suo messaggio (Jaccard 0,5, ordine GA);
#  - si rivolge a te (seconda persona singolare), mai al voi;
#  - il genere di chi legge: il criterio della guardia di casa,
#    lib/core/chat/le_forme_del_genere.dart, chiamato con
#    tool/forme_del_genere_dei_testi.dart (stesso criterio, non una copia);
#  - la marca del genere ben formata [maschile|femminile|neutra];
#  - mai una virgola prima di "e" o "ed";
#  - accenti veri: nessun apostrofo che non sia un'elisione dell'elenco
#    della guardia testo_a_video, nessuna parola che ha perso l'accento;
#  - mai il trattino lungo, mai una parola ripetuta due volte di fila;
#  - mai il futuro detto come certezza;
#  - le parole vietate dalla politica: salute e corpo, promesse di esito,
#    entita' avverse e goetia, sigilli; mai gioco, sfida, punteggio;
#  - nessuna cifra (l'ora e il salmo li scrive l'app);
#  - nessun nome di un ALTRO angelo dentro la cella;
#  - le varianti di una cella non cominciano con la stessa parola e non si
#    somigliano oltre 0,5 (Jaccard sulle parole); nessun attacco di due
#    parole apre piu' di dodici testi di un file;
#  - lo stesso angelo non dice la stessa cosa in due ruoli (Jaccard 0,5).
#
# Uso:
#   python tool/il_corpus_dell_oracolo.py scheletro
#   python tool/il_corpus_dell_oracolo.py riempi <file> <testi.json>
#   python tool/il_corpus_dell_oracolo.py controlla
#   python tool/il_corpus_dell_oracolo.py genera
#   python tool/il_corpus_dell_oracolo.py conta
#   python tool/il_corpus_dell_oracolo.py applica <parte.md> [<parte.md>...]
#
# <file> e' custode, cuore, intelletto o rito. <testi.json> e' una lista di
# {"cella": "01 Vehuiah", "campo": "messaggio", "n": 1, "testo": "..."}.
# <parte.md> e' scritta nella forma della fonte ("## NN Nome" e righe
# "- <campo> <n>: <testo>") e il suo nome dice il file: consiglio_cuore_01_36.md
# o messaggi_custode.md vanno in cuore e in custode. `scheletro` aggiunge ai
# file che esistono le righe vuote dei campi nuovi.
import io
import json
import os
import re
import subprocess
import sys
import tempfile
import time
from collections import Counter

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FONTE = os.path.join(RADICE, 'docs', 'corpus', 'oracolo_angeli')
DART = os.path.join(RADICE, 'lib', 'core', 'oracolo_angeli',
                    'il_corpus_dell_oracolo.g.dart')
CATALOGO = os.path.join(RADICE, 'lib', 'core', 'angels', 'angel_catalog.dart')
LORE = os.path.join(RADICE, 'lib', 'core', 'angels', 'angel_lore.dart')

# I file e i loro campi: [(campo, varianti per cella)]. Il consiglio
# dall'ordine GA: tre per cella, uno per messaggio.
FILE = {
    'custode': [('messaggio', 3), ('consiglio', 3)],
    'cuore': [('messaggio', 3), ('consiglio', 3)],
    'intelletto': [('messaggio', 3), ('consiglio', 3)],
    'rito': [('rito', 2)],
}

# La misura di ogni campo: (unita', minimo, massimo). Messaggio e consiglio
# in parole dall'ordine GA (prima: messaggio da 160 a 320 caratteri, ordine
# FU); il rito resta in caratteri, perche' non e' un paragrafo del responso.
LUNGHEZZE = {
    'messaggio': ('parole', 40, 50),
    'consiglio': ('parole', 40, 50),
    'rito': ('caratteri', 100, 240),
}


def parole_di(testo):
    """Le parole come le conta chi legge: separate da uno spazio, come
    `LaFormaDelResponso.parole`."""
    return len(testo.split())


def misura(campo, testo):
    unita, _, _ = LUNGHEZZE[campo]
    return parole_di(testo) if unita == 'parole' else len(testo)


def _riprova(fn):
    """Windows tiene a volte un file aperto: si riprova."""
    for _ in range(60):
        try:
            return fn()
        except OSError:
            time.sleep(0.5)
    return fn()


def angeli():
    """[(numero, seedName, nome a video)] dal catalogo e dal Corpus."""
    cat = _riprova(lambda: io.open(CATALOGO, encoding='utf-8').read())
    semi = [(int(m.group(1)), m.group(2)) for m in re.finditer(
        r"number:\s*(\d+),\s*seedName:\s*'([^']+)'", cat)]
    lore = _riprova(lambda: io.open(LORE, encoding='utf-8').read())
    nomi = {int(m.group(1)): m.group(2) for m in re.finditer(
        r"number: (\d+),\s*name: '([^']+)'", lore)}
    if len(semi) != 72:
        raise SystemExit('il catalogo non porta 72 angeli: %d' % len(semi))
    return [(n, s, nomi.get(n, s)) for n, s in semi]


def celle():
    return ['%02d %s' % (n, s) for n, s, _ in angeli()]


def struttura():
    return {nome: [(c, campo, k) for c in celle() for campo, k in campi]
            for nome, campi in FILE.items()}


INTESTAZIONE = (
    '<!-- Fonte del corpus dell\'Oracolo degli Angeli, ordine FU voci FU.05 '
    'e FU.07. Regole e schedari in LEGGIMI.md, nella stessa cartella. Si '
    'riempie solo con tool/il_corpus_dell_oracolo.py riempi: le righe '
    'scritte a mano non passano dai controlli. -->\n')

TITOLI = {
    'custode': 'L\'Angelo Custode: che cosa fare (voce di Medora)',
    'cuore': 'L\'Angelo del Cuore: che cosa sentire (voce di Medora)',
    'intelletto': 'L\'Angelo dell\'Intelletto: che cosa capire (voce di Medora)',
    'rito': 'Il rito con Caligo: come vivere i venti minuti dell\'angelo',
}


def percorso(nome):
    return os.path.join(FONTE, nome + '.md')


def _scrivi(p, testo):
    provvisorio = p + '.nuovo'
    io.open(provvisorio, 'w', encoding='utf-8', newline='\n').write(testo)
    _riprova(lambda: os.replace(provvisorio, p))


def _aggiungi_i_campi_nuovi(nome, cs):
    """Ordine GA: nei file che esistono, le righe vuote dei campi che la
    struttura chiede e il file non ha ancora, in fondo alla loro cella."""
    p = percorso(nome)
    righe = _riprova(lambda: io.open(p, encoding='utf-8').read()).split('\n')
    presenti = set(leggi(nome))
    attese = {}
    for cella, campo, k in cs:
        for n in range(1, k + 1):
            if (cella, campo, n) not in presenti:
                attese.setdefault(cella, []).append('- %s %d:' % (campo, n))
    if not attese:
        print('esiste gia', p)
        return
    fuori = []
    cella = None
    for riga in righe + ['## FINE']:
        if riga.startswith('## '):
            if cella in attese:
                # Le righe nuove dopo l'ultima riga della cella, prima della
                # riga vuota che la separa dalla seguente.
                while fuori and not fuori[-1].strip():
                    fuori.pop()
                fuori.extend(attese.pop(cella))
                fuori.append('')
            cella = riga[3:].strip()
        if riga != '## FINE':
            fuori.append(riga)
    while fuori and not fuori[-1].strip():
        fuori.pop()
    _scrivi(p, '\n'.join(fuori) + '\n')
    print('righe nuove in', p)


def scheletro():
    os.makedirs(FONTE, exist_ok=True)
    for nome, cs in struttura().items():
        p = percorso(nome)
        if os.path.exists(p):
            _aggiungi_i_campi_nuovi(nome, cs)
            continue
        out = io.StringIO()
        out.write('# %s\n\n' % TITOLI[nome] + INTESTAZIONE)
        for cella, campo, k in cs:
            out.write('\n## %s\n' % cella)
            for i in range(1, k + 1):
                out.write('- %s %d:\n' % (campo, i))
        _scrivi(p, out.getvalue())
        print('scritto', p)


RIGA = re.compile(r'^- (\w+) (\d+):(.*)$')


def leggi(nome):
    """{(cella, campo, n): testo} dal file."""
    dati = {}
    cella = None
    righe = _riprova(lambda: io.open(percorso(nome), encoding='utf-8').read())
    for riga in righe.split('\n'):
        if riga.startswith('## '):
            cella = riga[3:].strip()
            continue
        m = RIGA.match(riga)
        if m and cella:
            dati[(cella, m.group(1), int(m.group(2)))] = m.group(3).strip()
    return dati


# --- I CONTROLLI ------------------------------------------------------------

L = r'A-Za-zÀ-ÿ'
SEGNI_DEL_TU = re.compile(
    r"(?<![%s])(tu|ti|te|tuo|tua|tuoi|tue|hai|sei|puoi|vuoi|sai|fai|dai|"
    r"stai|vai|senti|cerchi|guardi|chiedi|scegli|lascia|prova|parla|nota|"
    r"ricorda|ascolta|accendi|siedi|respira|pronuncia|scrivi|tieni|prendi|"
    r"metti|chiudi|apri|resta|torna|accogli|osserva|guarda|chiediti|"
    r"fermati|dì|t)(?![%s])" % (L, L), re.I)
SEGNI_DEL_VOI = re.compile(
    r"(?<![%s])(voi|vostro|vostra|vostri|vostre|siete|avete|potete|sapete)"
    r"(?![%s])" % (L, L), re.I)

# Le elisioni ammesse: lo stesso elenco della guardia testo_a_video
# (test/testo_a_video_test.dart). Ogni altro apostrofo dopo una parola e' un
# accento finto.
ELISIONI = set('''l un c d dell all nell sull dall quest sant m t s v gl gli
anch nessun ciascun buon grand bell tutt qual po di fa va sta da mo be to n
senz sopr contr dentr sott quell part com or ver tal altr nostr vostr vent
trent quarant cinquant sessant settant ottant novant qualcos'''.split())
APOSTROFO = re.compile(r"([%s]+)'" % L)
# Le parole che in italiano non esistono senza accento: lo stesso elenco
# della guardia testo_a_video.
SENZA_ACCENTO = set('''piu perche poiche benche finche nonche affinche gia
cosi puo cioe percio sara fara dara potra verra andra avra citta liberta
verita qualita quantita possibilita responsabilita identita realta novita
universita virtu gioventu tribu lunedi martedi mercoledi giovedi
venerdi'''.split())
VIRGOLA_E = re.compile(r',\s+(e|ed)(?![%s])' % L, re.I)
TRATTINO = re.compile(r'[—–]|\s-\s')
DOPPIA = re.compile(r'(?<![%s])([%s]{3,})\s+\1(?![%s])' % (L, L, L), re.I)
CIFRA = re.compile(r'\d')
MARCA = re.compile(r'\[[^\[\]]*\]')
MARCA_BUONA = re.compile(r'\[[^\[\]|]+\|[^\[\]|]+\|[^\[\]|]+\]')

# IL FUTURO DETTO COME CERTEZZA. I verbi al futuro della seconda e della
# terza persona (sarai, avrai, otterrai, accadra', succedera', arriveranno)
# e le formule della certezza. "Pero'" non e' un futuro.
FUTURO = re.compile(
    r"(?<![%s])(?!però(?![%s]))[%s]{2,}(rà|rai|ranno|rò)(?![%s])" % (L, L, L, L),
    re.I)
CERTEZZA = re.compile(
    r"(?<![%s])(di sicuro|sicuramente|certamente|senza dubbio|per sempre|"
    r"è scritto|destino segnato|garantit\w*|ti prometto|promesso|"
    r"inevitabilmente|immancabilmente|vedrai che)(?![%s])" % (L, L), re.I)

# LA POLITICA DI PUBBLICAZIONE (docs/corpus/angeli.md) e la regola R8:
# radici che aprono la parola. Larga di proposito: un falso allarme si
# riscrive in un minuto, una promessa di guarigione a video no.
POLITICA = re.compile(
    r"(?<![%s])("
    # salute, corpo, sensi, medicina
    r"salute|sanità|malat\w*|malann\w*|guari\w*|curativ\w*|terapi\w*|"
    r"rimedi\w*|farmac\w*|medic\w*|sintom\w*|diagnos\w*|ospedal\w*|"
    r"dottor\w*|fertil\w*|steril\w*|gravid\w*|incint\w*|concepi\w*|"
    r"longev\w*|vecchiaia|corpo|corpi|corporal\w*|vista|olfatt\w*|udito|"
    r"tatto|sonno|insonni\w*|dolor\w* fisic\w*|morte|morire|muor\w*|"
    r"rigenera\w*|"
    # promesse di esito
    r"vittori\w*|vincer\w*|vincit\w*|vinci|vince|vincono|trionf\w*|"
    r"sconfigg\w*|nemic\w*|avversari\w*|armi|arma|guerr\w*|battagl\w*|"
    r"ricchezz\w*|ricco|ricca|denar\w*|soldi|guadagn\w*|patrimon\w*|"
    r"eredit\w*|fortun\w*|lotteri\w*|promozion\w*|tesor\w*|ritrov\w*|"
    r"prigion\w*|carcer\w*|galera|liberazion\w*|proteg\w*|protezion\w*|"
    r"scudo|immun\w*|success\w*|miracol\w*|panacea|filosofale|abbondanz\w*|"
    # entita' avverse, goetia, sigilli
    r"demon\w*|diavol\w*|satan\w*|infern\w*|goet\w*|contrari\w*|"
    r"malefic\w*|maledi\w*|sortileg\w*|incantesim\w*|stregon\w*|"
    r"malocch\w*|sigill\w*|talisman\w*|amulet\w*|pentacol\w*|evoca\w*|"
    r"scongiur\w*|"
    # nessun invito a chiamare qualcuno e nessun numero da chiamare, ordine
    # FV aggiunta voce FVA.01: il fondatore, "Il consiglio di chiamare
    # qualcuno sarebbe già una presa di posizione". L'invocazione dell'angelo
    # nei riti ("Chiama Ieliel per nome") non e' presa: dopo "chiama" viene il
    # nome, non una persona.
    r"telefonat\w*|telefona|chiama (?:la|quella|una|un|oggi|qualcuno)|"
    r"chiamal[aoie]|112|emergenz\w*|soccors\w*|"
    # la vita privata di terzi
    r"tradiment\w*|tradir\w*|tradisc\w*|amante|"
    # la tradizione citata dove non e' documentata
    r"secondo la tradizione|la tradizione dice|la tradizione insegna|"
    r"la tradizione vuole|gli antichi|"
    # le regole di casa sui test esoterici
    r"gioco|giochi|sfida|sfide|punteggio|scommessa|classifica|"
    r"vocativ\w*"
    r")(?![%s])" % (L, L), re.I)


def nomi_degli_angeli():
    """{numero: [nomi]} con le due grafie, dal piu' lungo al piu' corto."""
    fuori = {}
    for n, s, v in angeli():
        fuori[n] = sorted({s, v}, key=len, reverse=True)
    return fuori


def parole(t):
    return set(re.findall(r'[a-zà-ÿ]+', t.lower()))


def jaccard(a, b):
    x, y = parole(a), parole(b)
    return len(x & y) / max(1, len(x | y))


def altri_angeli(cella, testo):
    """I nomi di altri angeli scritti nel testo di una cella."""
    numero = int(cella.split()[0])
    nomi = nomi_degli_angeli()
    t = testo
    for nome in nomi[numero]:
        t = re.sub(r'(?<![%s])%s(?![%s])' % (L, re.escape(nome), L), ' ', t)
    trovati = []
    for n, ns in nomi.items():
        if n == numero:
            continue
        for nome in ns:
            if re.search(r'(?<![%s])%s(?![%s])' % (L, re.escape(nome), L), t):
                trovati.append(nome)
    return trovati


def difetti_di(cella, campo, testo):
    colpe = []
    unita, lo, hi = LUNGHEZZE[campo]
    if not lo <= misura(campo, testo) <= hi:
        colpe.append('lunghezza %d %s, fuori da %d-%d' % (
            misura(campo, testo), unita, lo, hi))
    senza_marche = MARCA.sub(' ', testo)
    if not SEGNI_DEL_TU.search(senza_marche) and '[' not in testo:
        colpe.append('non si rivolge a te (seconda persona singolare)')
    if SEGNI_DEL_VOI.search(testo):
        colpe.append('si rivolge al voi: "%s"' % SEGNI_DEL_VOI.search(testo).group(0))
    for m in MARCA.finditer(testo):
        if not MARCA_BUONA.fullmatch(m.group(0)):
            colpe.append('marca del genere malformata: %s (vale '
                         '[maschile|femminile|neutra])' % m.group(0))
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
        colpe.append('parola vietata dalla politica: "%s"' % m.group(0))
    if CIFRA.search(testo):
        colpe.append('cifra nel testo')
    if '«' in testo or '»' in testo or '"' in testo:
        colpe.append('citazione fra virgolette (il salmo lo scrive l\'app)')
    altri = altri_angeli(cella, testo)
    if altri:
        colpe.append('nome di un altro angelo: %s' % ', '.join(altri))
    return colpe


# Con molti scrittori in parallelo, un eseguibile gia' compilato evita che
# tanti `dart run` si contendano la cache di Dart:
#   dart compile exe tool/forme_del_genere_dei_testi.dart \
#     -o .dart_tool/forme_del_genere_dei_testi.exe
# (.dart_tool e' fuori da Git). La variabile FORME_DEL_GENERE_EXE ne dice un
# altro percorso. Senza nessuno dei due, si usa `dart run`.
FORME_EXE = os.environ.get('FORME_DEL_GENERE_EXE') or os.path.join(
    RADICE, '.dart_tool', 'forme_del_genere_dei_testi.exe')

# LE GEMELLE dello schedario (LEGGIMI.md): ogni angelo e l'angelo che gli
# somiglia di piu' fra i 72, a coppie. Le usano i lettori ciechi
# (tool/i_lettori_ciechi_dell_oracolo.py).
GEMELLE = [(1, 45), (2, 48), (3, 44), (4, 42), (5, 26), (6, 54), (7, 58),
           (8, 30), (9, 10), (11, 22), (12, 62), (13, 61), (14, 18), (15, 31),
           (16, 33), (17, 46), (19, 66), (20, 55), (21, 53), (23, 28),
           (24, 71), (25, 51), (27, 64), (29, 52), (32, 47), (34, 60),
           (35, 39), (36, 56), (37, 43), (38, 41), (40, 65), (49, 50),
           (57, 69), (70, 72), (59, 67), (63, 68)]


def forme_del_genere(testi):
    """Il criterio di casa, chiamato in Dart: una lista di liste."""
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


# --- RIEMPI -----------------------------------------------------------------

class Lucchetto:
    """Piu' scrittori sullo stesso file: uno alla volta."""

    def __init__(self, nome):
        self.p = percorso(nome) + '.lucchetto'

    def __enter__(self):
        for _ in range(1200):
            try:
                fd = os.open(self.p, os.O_CREAT | os.O_EXCL | os.O_WRONLY)
                os.close(fd)
                return self
            except FileExistsError:
                # Un lucchetto rimasto da uno scrittore morto: oltre dieci
                # minuti si toglie.
                try:
                    if time.time() - os.path.getmtime(self.p) > 600:
                        os.remove(self.p)
                except OSError:
                    pass
                time.sleep(0.5)
            except OSError:
                time.sleep(0.5)
        raise SystemExit('il file resta chiuso da un altro scrittore')

    def __exit__(self, *a):
        _riprova(lambda: os.remove(self.p))


def scrivi_nel_file(nome, nuovi):
    p = percorso(nome)
    righe = _riprova(lambda: io.open(p, encoding='utf-8').read()).split('\n')
    cella = None
    for i, riga in enumerate(righe):
        if riga.startswith('## '):
            cella = riga[3:].strip()
            continue
        m = RIGA.match(riga)
        if m and cella and (cella, m.group(1), int(m.group(2))) in nuovi:
            righe[i] = ('- %s %s: ' % (m.group(1), m.group(2)) +
                        nuovi[(cella, m.group(1), int(m.group(2)))])
    _scrivi(p, '\n'.join(righe))


def _attacco(t):
    return ' '.join(t.lower().split()[:2])


TETTO_ATTACCO = 12


def colpe_fra_testi(nome, chiave, testo, tutto, altri_ruoli):
    colpe = []
    # Ordine GA: il consiglio n non ripete il messaggio n che accompagna, e
    # un messaggio riscritto non ripete il suo consiglio.
    compagno = {'consiglio': 'messaggio', 'messaggio': 'consiglio'}.get(chiave[1])
    if compagno:
        t = tutto.get((chiave[0], compagno, chiave[2]))
        if t and jaccard(t, testo) > 0.5:
            colpe.append('troppo simile al %s %d della stessa cella'
                         % (compagno, chiave[2]))
    sorelle = [t for (c, f, n), t in tutto.items()
               if c == chiave[0] and f == chiave[1] and n != chiave[2] and t]
    for s in sorelle:
        if jaccard(s, testo) > 0.5:
            colpe.append('troppo simile a una variante gia\' scritta della '
                         'stessa cella')
            break
        if s.split()[0].lower() == testo.split()[0].lower():
            colpe.append('comincia con la stessa parola di un\'altra variante')
            break
    uguali = sum(1 for (c, f, n), t in tutto.items()
                 if t and (c, f, n) != chiave and _attacco(t) == _attacco(testo))
    if uguali >= TETTO_ATTACCO:
        colpe.append('attacco ripetuto: "%s" apre gia\' %d testi di questo '
                     'file' % (_attacco(testo), uguali))
    for altro, t in altri_ruoli:
        if jaccard(t, testo) > 0.5:
            colpe.append('troppo simile al testo dello stesso angelo in %s'
                         % altro)
            break
        if t == testo:
            colpe.append('identico a un testo di %s' % altro)
            break
    return colpe


def stessi_angelo_altri_ruoli(nome, cella):
    fuori = []
    if nome == 'rito':
        return fuori
    for altro in ('custode', 'cuore', 'intelletto'):
        if altro == nome or not os.path.exists(percorso(altro)):
            continue
        for (c, f, n), t in leggi(altro).items():
            if c == cella and t:
                fuori.append((altro, t))
    return fuori


def riempi(nome, testi_json):
    if nome not in FILE:
        raise SystemExit('file sconosciuto: %s (custode, cuore, intelletto, rito)' % nome)
    proposte = json.load(io.open(testi_json, encoding='utf-8-sig'))
    scartati = []
    candidati = []
    struttura_file = {(c, f, n) for c, f, k in struttura()[nome]
                      for n in range(1, k + 1)}
    for v in proposte:
        chiave = (v.get('cella', ''), v.get('campo', ''), int(v.get('n', 0)))
        testo = ' '.join(str(v.get('testo', '')).split())
        if chiave not in struttura_file:
            scartati.append((chiave, testo, ['cella, campo o numero inesistenti']))
            continue
        colpe = difetti_di(chiave[0], chiave[1], testo)
        if colpe:
            scartati.append((chiave, testo, colpe))
        else:
            candidati.append((chiave, testo))
    genere = forme_del_genere([t for _, t in candidati])
    validi = {}
    with Lucchetto(nome):
        tutto = leggi(nome)
        for (chiave, testo), forme in zip(candidati, genere):
            if forme:
                scartati.append((chiave, testo,
                                 ['genere di chi legge: ' + ', '.join(forme)]))
                continue
            tutto_senza = dict(tutto)
            tutto_senza[chiave] = ''
            colpe = colpe_fra_testi(nome, chiave, testo, tutto_senza,
                                    stessi_angelo_altri_ruoli(nome, chiave[0]))
            if colpe:
                scartati.append((chiave, testo, colpe))
                continue
            validi[chiave] = testo
            tutto[chiave] = testo
        if validi:
            scrivi_nel_file(nome, validi)
        vuoti = sum(1 for t in leggi(nome).values() if not t)
    print('%s: scritti %d, scartati %d' % (nome, len(validi), len(scartati)))
    for chiave, testo, colpe in scartati:
        print('  SCARTATO %s | %s %d: %s' % (chiave[0], chiave[1], chiave[2],
                                             '; '.join(colpe)))
        print('     ' + testo)
    print('  ancora da scrivere in %s: %d' % (nome, vuoti))


# --- APPLICA ----------------------------------------------------------------

def file_della_parte(percorso_parte):
    """Il file della fonte che una parte riempie, dal suo nome:
    consiglio_cuore_01_36.md -> cuore, messaggi_custode.md -> custode."""
    base = os.path.basename(percorso_parte).lower()
    trovati = [n for n in FILE if re.search(r'(^|_)%s(_|\.)' % n, base)]
    if len(trovati) != 1:
        raise SystemExit('dal nome %s non si capisce il file (%s)'
                         % (base, ', '.join(FILE)))
    return trovati[0]


def leggi_la_parte(percorso_parte):
    """[{cella, campo, n, testo}] dalle righe "- <campo> <n>: <testo>" sotto
    le intestazioni "## NN Nome"."""
    fuori = []
    cella = None
    testo = _riprova(lambda: io.open(percorso_parte, encoding='utf-8-sig').read())
    for riga in testo.split('\n'):
        riga = riga.rstrip('\r')
        if riga.startswith('## '):
            cella = riga[3:].strip()
            continue
        m = RIGA.match(riga)
        if m and cella:
            fuori.append({'cella': cella, 'campo': m.group(1),
                          'n': int(m.group(2)), 'testo': m.group(3).strip()})
    return fuori


def applica(parti):
    """Ordine GA: porta nella fonte le parti scritte dagli agenti, ognuna
    attraverso `riempi`, cioe' attraverso tutti i controlli. Cio' che non li
    passa resta fuori e lo strumento lo dice col difetto."""
    for parte in parti:
        nome = file_della_parte(parte)
        voci = leggi_la_parte(parte)
        if not voci:
            raise SystemExit('nella parte %s non c\'e\' nessuna voce' % parte)
        fd, provvisorio = tempfile.mkstemp(suffix='.json')
        with os.fdopen(fd, 'w', encoding='utf-8') as f:
            json.dump(voci, f, ensure_ascii=False)
        try:
            print('APPLICA %s -> %s.md: %d voci' % (
                os.path.basename(parte), nome, len(voci)))
            riempi(nome, provvisorio)
        finally:
            _riprova(lambda: os.remove(provvisorio))


# --- CONTROLLA, CONTA, GENERA ----------------------------------------------

def conta():
    totale = scritti = 0
    for nome in FILE:
        d = leggi(nome)
        pieni = sum(1 for t in d.values() if t)
        totale += len(d)
        scritti += pieni
        print('%s: %d su %d' % (nome, pieni, len(d)))
    print('TOTALE: %d su %d' % (scritti, totale))
    return scritti, totale


def controlla():
    colpe = []
    tutti = []
    for nome, cs in struttura().items():
        d = leggi(nome)
        attese = {(c, f, n) for c, f, k in cs for n in range(1, k + 1)}
        if set(d) != attese:
            colpe.append('%s: le celle del file non sono quelle della '
                         'struttura (%d attese, %d trovate)' % (
                             nome, len(attese), len(d)))
        for chiave, testo in sorted(d.items()):
            if not testo:
                colpe.append('%s %s: vuoto' % (nome, chiave))
                continue
            for c in difetti_di(chiave[0], chiave[1], testo):
                colpe.append('%s %s: %s' % (nome, chiave, c))
            tutti.append((nome, chiave, testo))
    for (nome, chiave, testo), forme in zip(
            tutti, forme_del_genere([t for _, _, t in tutti])):
        if forme:
            colpe.append('%s %s: genere di chi legge %s' % (nome, chiave, forme))
    # Le varianti della stessa cella, gli attacchi, i ruoli dello stesso
    # angelo, i doppioni su tutto il corpus.
    letti = {nome: leggi(nome) for nome in FILE}
    for nome, d in letti.items():
        attacchi = Counter(_attacco(t) for t in d.values() if t)
        for a, q in attacchi.items():
            if q > TETTO_ATTACCO:
                colpe.append('%s: l\'attacco "%s" apre %d testi (tetto %d)'
                             % (nome, a, q, TETTO_ATTACCO))
        # Le varianti sono quelle dello stesso campo della cella: dall'ordine
        # GA una cella porta due campi, messaggio e consiglio.
        per_cella = {}
        for (c, f, n), t in d.items():
            if t:
                per_cella.setdefault('%s, %s' % (c, f), []).append(t)
        for c, vs in per_cella.items():
            for i in range(len(vs)):
                for j in range(i + 1, len(vs)):
                    if jaccard(vs[i], vs[j]) > 0.5:
                        colpe.append('%s %s: due varianti troppo simili' % (nome, c))
                    if vs[i].split()[0].lower() == vs[j].split()[0].lower():
                        colpe.append('%s %s: due varianti con la stessa prima '
                                     'parola' % (nome, c))
        # Ordine GA: il consiglio n non ripete il messaggio n.
        for (c, f, n), t in d.items():
            if f == 'consiglio' and t:
                m = d.get((c, 'messaggio', n))
                if m and jaccard(m, t) > 0.5:
                    colpe.append('%s %s: il consiglio %d ripete il suo messaggio'
                                 % (nome, c, n))
    ruoli = ('custode', 'cuore', 'intelletto')
    for i, a in enumerate(ruoli):
        for b in ruoli[i + 1:]:
            for (c, f, n), t in letti[a].items():
                for (c2, f2, n2), t2 in letti[b].items():
                    if c == c2 and t and t2 and jaccard(t, t2) > 0.5:
                        colpe.append('%s e %s, %s: lo stesso angelo dice la '
                                     'stessa cosa in due ruoli' % (a, b, c))
    visti = Counter(t for d in letti.values() for t in d.values() if t)
    for t, q in visti.items():
        if q > 1:
            colpe.append('testo ripetuto %d volte: %s' % (q, t[:60]))
    for c in colpe:
        print(c)
    print('DIFETTI: %d su %d testi' % (len(colpe), len(tutti)))
    return colpe


def dart_stringa(t):
    return "'" + t.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$') + "'"


def genera():
    colpe = controlla()
    if colpe:
        raise SystemExit('LA FONTE NON E\' PRONTA: nessun Dart scritto a meta\'.')
    out = io.StringIO()
    out.write('// GENERATO da tool/il_corpus_dell_oracolo.py dalla fonte in\n'
              '// docs/corpus/oracolo_angeli/. Non si modifica a mano:\n'
              '// si corregge la fonte e si rigenera. Ordine FU voci FU.05 e '
              'FU.07,\n'
              '// col consiglio dell\'ordine GA voci GA.03, GA.05 e GA.07.\n\n'
              '/// Il corpus dell\'Oracolo degli Angeli: chiave\n'
              '/// "<file>|<NN>|<campo>" (file: custode, cuore, intelletto, '
              'rito;\n'
              '/// NN: il numero dell\'angelo a due cifre; campo: messaggio, '
              'consiglio\n'
              '/// o rito), valore le varianti in ordine. Il consiglio n '
              'accompagna il\n'
              '/// messaggio n, nel riquadro "Cosa fare adesso".\n'
              'const Map<String, List<String>> corpusDellOracolo = {\n')
    for nome, cs in struttura().items():
        d = leggi(nome)
        for cella, campo, k in cs:
            nn = cella.split()[0]
            out.write("  '%s|%s|%s': [\n" % (nome, nn, campo))
            for n in range(1, k + 1):
                out.write('    %s,\n' % dart_stringa(d[(cella, campo, n)]))
            out.write('  ],\n')
    out.write('};\n')
    os.makedirs(os.path.dirname(DART), exist_ok=True)
    _scrivi(DART, out.getvalue())
    print('scritto', DART)


if __name__ == '__main__':
    comando = sys.argv[1] if len(sys.argv) > 1 else ''
    if comando == 'scheletro':
        scheletro()
    elif comando == 'riempi':
        riempi(sys.argv[2], sys.argv[3])
    elif comando == 'controlla':
        sys.exit(1 if controlla() else 0)
    elif comando == 'conta':
        conta()
    elif comando == 'genera':
        genera()
    elif comando == 'applica':
        applica(sys.argv[2:])
    else:
        print('comandi: scheletro, riempi <file> <testi.json>, controlla, '
              'conta, genera, applica <parte.md>...')
        sys.exit(2)
