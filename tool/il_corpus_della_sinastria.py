# IL CORPUS DELLA SINASTRIA APPROFONDITA. Ordine FT voce FT.12, 14 ottobre
# 2026. Metodo dell'ordine FM: prima gli schedari, poi i testi, scritti da
# agenti in parallelo (uno per file della fonte), che li mandano a questo
# strumento; lo strumento scrive nella fonte SOLO i testi che passano i
# controlli e rimanda gli altri col difetto.
#
# QUESTO STRUMENTO NON CHIAMA NESSUN MODELLO (regola R2 dell'ordine FT e
# regola SPESE di CLAUDE.md): legge la fonte, controlla, scrive il Dart.
#
# LA FONTE sta in docs/corpus/sinastria_approfondita/, un file .md per
# gruppo. Ogni cella e' una riga "## <cella>" seguita dalle righe
# "- <campo> <n>: <testo>" (testo vuoto = da scrivere).
#
# I CONTROLLI, uno per uno (sono le regole R7 dell'ordine e le guardie di
# casa che sui corpora nuovi sono gia' cadute: memoria del progetto):
#  - lunghezza per campo;
#  - si rivolge alla persona (tu) o alla coppia (voi);
#  - il genere di chi legge: lo decide il criterio della guardia di casa,
#    lib/core/chat/le_forme_del_genere.dart, chiamato con
#    tool/forme_del_genere_dei_testi.dart (stesso criterio, non una copia);
#  - il genere della coppia e dell'altra persona: plurali e aggettivi che
#    concordano ("siete pronti", "{nome} e' pronto"), e "lui"/"lei";
#  - mai una virgola prima di "e" o "ed" (language_rule);
#  - accenti veri, mai l'apostrofo al posto dell'accento (testo_a_video);
#  - mai il trattino lungo;
#  - mai la parola "voce" (nell'app vuol dire l'audio);
#  - mai gioco, sfida, punteggio, scommessa, classifica;
#  - mai il futuro detto come certezza, mai salute, morte, denaro,
#    gravidanza, eredita', tradimento: niente vita privata (FT.12);
#  - nessuna cifra (i numeri li dice il codice);
#  - le varianti di una cella non cominciano con la stessa parola e non si
#    somigliano oltre 0,6 (Jaccard sulle parole).
#
# Uso:
#   python tool/il_corpus_della_sinastria.py scheletro
#   python tool/il_corpus_della_sinastria.py riempi <file> <testi.json>
#   python tool/il_corpus_della_sinastria.py controlla
#   python tool/il_corpus_della_sinastria.py genera
#   python tool/il_corpus_della_sinastria.py conta
#
# <testi.json> e' una lista di {"cella": ..., "campo": ..., "n": 1, "testo": ...}.
import io
import json
import os
import re
import subprocess
import sys
import tempfile
import time

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FONTE = os.path.join(RADICE, 'docs', 'corpus', 'sinastria_approfondita')
DART = os.path.join(RADICE, 'lib', 'core', 'synastry_approfondita',
                    'il_corpus_della_sinastria_approfondita.g.dart')

LEGAMI = ['amore', 'amicizia', 'famiglia', 'lavoro']
TONI = ['fuso', 'armonico', 'teso', 'silenzio']
CAPITOLI = ['attrazione', 'emozioni', 'mente', 'durata', 'destino']
ASPETTI = ['congiunzione', 'sestile', 'quadratura', 'trigono', 'opposizione']
FAMIGLIE = ['fuso', 'armonico', 'teso']

# Le coppie di punti di ogni capitolo: la tradizione della sinastria
# (Davison 1977, Arroyo 1979, Schulman 1984 per i nodi). Coppie non
# ordinate: vale in tutte e due le direzioni.
COPPIE = {
    'attrazione': [('venere', 'marte'), ('sole', 'venere'), ('marte', 'marte')],
    'emozioni': [('luna', 'luna'), ('sole', 'luna'), ('luna', 'venere')],
    'mente': [('mercurio', 'mercurio'), ('sole', 'mercurio'), ('mercurio', 'luna')],
    'durata': [('saturno', 'sole'), ('saturno', 'luna'), ('saturno', 'venere')],
    'destino': [('nodo', 'sole'), ('nodo', 'luna'), ('nodo', 'venere')],
}
# Il Composito di Hand: aspetti fra i punti medi di questi cinque.
COMPOSITO = ['sole', 'luna', 'mercurio', 'venere', 'marte']
# Keplero, Harmonices Mundi (1619), libro IV: l'arco fra i due punti sul
# cerchio intero da' il rapporto della corda.
CONSONANZE = ['unisono', 'ottava', 'quinta', 'quarta', 'terza_minore',
              'terza_maggiore', 'sesta_maggiore', 'sesta_minore', 'nessuna']
TRANSITI_OGGI = ['sole', 'luna', 'mercurio', 'venere', 'marte', 'giove',
                 'saturno']
TRANSITI_MOMENTO = ['sole', 'luna', 'mercurio', 'venere', 'giove']


def struttura():
    """Le celle di ogni file, coi campi e il numero di varianti."""
    s = {}
    for c in CAPITOLI:
        s['capitolo_' + c] = [
            (f'{l} {t}', [('titolo', 3), ('apertura', 3), ('fare', 3)])
            for l in LEGAMI for t in TONI]
    a = []
    b = []
    for c in CAPITOLI:
        for (p, q) in COPPIE[c]:
            for asp in ASPETTI:
                cella = (f'{p}-{q} {asp}', [('testo', 3)])
                (a if c in ('attrazione', 'emozioni', 'mente') else b).append(cella)
    s['contatti_cuore_e_mente'] = a
    s['contatti_durata_e_destino'] = b
    comp = []
    for i, p in enumerate(COMPOSITO):
        for q in COMPOSITO[i + 1:]:
            for f in FAMIGLIE:
                comp.append((f'{p}-{q} {f}', [('titolo', 2), ('testo', 2)]))
    # Nessuno dei dieci aspetti nell'orbo: la relazione parla per intero.
    comp.append(('nessuno', [('titolo', 2), ('testo', 2)]))
    s['composito'] = comp
    k = [(f'keplero {c}', [('testo', 2)]) for c in CONSONANZE]
    k += [(f'oggi {t} {c}', [('testo', 2)]) for t in TRANSITI_OGGI
          for c in CAPITOLI]
    k += [('oggi nessuno', [('testo', 2)])]
    k += [(f'momento {t} {l}', [('testo', 3)]) for t in TRANSITI_MOMENTO
          for l in LEGAMI]
    k += [(f'momento nessuno {l}', [('testo', 3)]) for l in LEGAMI]
    s['keplero_oggi_momento'] = k
    return s


LUNGHEZZE = {
    'titolo': (15, 70),
    'apertura': (160, 340),
    'fare': (160, 340),
    'testo': (110, 320),
}

INTESTAZIONE = (
    '<!-- Fonte del corpus della Sinastria approfondita, ordine FT voce '
    'FT.12. Regole e schedari in LEGGIMI.md, nella stessa cartella. Si '
    'riempie solo con tool/il_corpus_della_sinastria.py riempi: le righe '
    'scritte a mano non passano dai controlli. -->\n')


def percorso(nome):
    return os.path.join(FONTE, nome + '.md')


def scheletro():
    os.makedirs(FONTE, exist_ok=True)
    for nome, celle in struttura().items():
        p = percorso(nome)
        if os.path.exists(p):
            print('esiste gia', p)
            continue
        out = io.StringIO()
        out.write(f'# {nome}\n\n' + INTESTAZIONE)
        for cella, campi in celle:
            out.write(f'\n## {cella}\n')
            for campo, n in campi:
                for i in range(1, n + 1):
                    out.write(f'- {campo} {i}:\n')
        io.open(p, 'w', encoding='utf-8', newline='\n').write(out.getvalue())
        print('scritto', p)


RIGA = re.compile(r'^- (\w+) (\d+):(.*)$')


def leggi(nome):
    """{(cella, campo, n): testo} dal file."""
    dati = {}
    cella = None
    for riga in io.open(percorso(nome), encoding='utf-8'):
        riga = riga.rstrip('\n')
        if riga.startswith('## '):
            cella = riga[3:].strip()
            continue
        m = RIGA.match(riga)
        if m and cella:
            dati[(cella, m.group(1), int(m.group(2)))] = m.group(3).strip()
    return dati


# --- I CONTROLLI ------------------------------------------------------------

SEGNI_DEL_TU = re.compile(
    r"(?<![A-Za-zÀ-ÿ])(tu|ti|te|tuo|tua|tuoi|tue|hai|sei|puoi|vuoi|"
    r"sai|fai|dai|stai|vai|senti|cerchi|guardi|chiedi|scegli|lascia|prova|"
    r"chiedi|parla|nota|ricorda|ascolta|dì|dì)(?![A-Za-zÀ-ÿ])", re.I)
SEGNI_DEL_VOI = re.compile(
    r"(?<![A-Za-zÀ-ÿ])(voi|vi|vostro|vostra|vostri|vostre|siete|avete|"
    r"potete|sapete|fate|state|cercate|parlate|provate|scegliete|lasciate|"
    r"ascoltate|ricordate|tenete|date|guardate|chiedete|sentite|"
    r"insieme)(?![A-Za-zÀ-ÿ])", re.I)
CON_IL_NOME = re.compile(r'\{nome\}')

# Aggettivi e participi che concordano col genere: al plurale per il "voi",
# al singolare dopo {nome}. L'elenco e' quello delle parole che una lettura
# di coppia usa davvero; il criterio di casa copre il "tu".
RADICI = ['pront', 'sol', 'sicur', 'unit', 'legat', 'vicin', 'lontan',
          'stanc', 'innamorat', 'attratt', 'coinvolt', 'divers', 'sincer',
          'liber', 'attent', 'abituat', 'stat', 'tranquill', 'seren',
          'apert', 'chius', 'divis', 'brav', 'nat', 'cresciut', 'arrivat',
          'partit', 'tornat', 'caric', 'pien', 'ferit', 'delus', 'contrariat',
          'preoccupat', 'convint', 'decis', 'consapevol', 'pres', 'distratt',
          'concentrat', 'appassionat', 'affiatat', 'complic', 'ispirat',
          'motivat', 'coraggios', 'generos', 'gelos', 'possessiv', 'testard',
          'orgoglios', 'timid', 'riservat', 'fortunat', 'destinat',
          'chiamat', 'spint', 'portat']
PLURALE = re.compile(
    r'(?<![A-Za-zÀ-ÿ])(siete|siate|restate|rimanete|diventate|sembrate|'
    r'vi sentite|sentirvi|vi scoprite|vi trovate|vi ritrovate|state)'
    r'\s+(?:[A-Za-zÀ-ÿ]+\s+){0,2}?(' + '|'.join(RADICI) + r')(i|e)'
    r'(?![A-Za-zÀ-ÿ])', re.I)
SINGOLARE_DEL_NOME = re.compile(
    r'\{nome\}\s+(?:[A-Za-zÀ-ÿ]+\s+){0,2}?(è|resta|rimane|sembra|diventa|'
    r'si sente|si scopre|si trova)\s+(?:[A-Za-zÀ-ÿ]+\s+){0,1}?(' +
    '|'.join(RADICI) + r')(o|a)(?![A-Za-zÀ-ÿ])', re.I)
PRONOMI_DI_GENERE = re.compile(
    r'(?<![A-Za-zÀ-ÿ])(lui|lei|egli|ella|marito|moglie|fidanzato|fidanzata|'
    r'ragazzo|ragazza|compagno|compagna|uomo|donna|padre|madre|'
    r'figlio|figlia|fratello|sorella)(?![A-Za-zÀ-ÿ])', re.I)

# "piu'", "perche'", e anche "E'" da sola; "po'" e' un troncamento vero.
# **IL MASCHILE O IL FEMMINILE GENERICO SULLA COPPIA.** Il primo giro dei
# nove scrittori (14 ottobre 2026) ne ha lasciati circa centotrenta che i
# controlli di sopra non vedevano: "entrambi" e' sbagliato per due donne,
# "entrambe" per una coppia mista. Le forme neutre ci sono: "voi due",
# "ognuna delle due persone", "una persona e l'altra", "in amicizia".
GENERICO_SULLA_COPPIA = re.compile(
    r"(?<![A-Za-zÀ-ÿ])(entramb[ie]|ciascuno|ognuno|l'uno|l'una|"
    r"nessuno dei due|nessuna delle due|tutti e due|tutte e due|"
    r"fra amici|tra amici|da amici|voi amici|fra amiche|tra amiche|"
    r"per primo|gli fa|gli serve|gli piace)(?![A-Za-zÀ-ÿ])", re.I)

ACCENTO_FINTO = re.compile(
    r"(?:(?<![A-Za-zÀ-ÿ])(?!po')[A-Za-z]*[aeiouAEIOU])'(?=[\s.,;:!?)]|$)")
VIRGOLA_E = re.compile(r',\s+(e|ed)\s', re.I)
TRATTINO = re.compile('[—–]')
PAROLE_VIETATE = re.compile(
    r'(?<![A-Za-zÀ-ÿ])(voce|voci|gioco|giochi|sfida|sfide|punteggio|'
    r'scommessa|classifica|sicuramente|certamente|di sicuro|per sempre|'
    r'succederà|accadrà|avverrà|sposerete|lascerete|tradimento|tradirà|'
    r'tradire|salute|malattia|morte|morire|denaro|soldi|gravidanza|'
    r'incinta|eredità|destino segnato|è scritto)(?![A-Za-zÀ-ÿ])', re.I)
CIFRA = re.compile(r'\d')
SEGNAPOSTO = re.compile(r'\{(\w+)\}')


def parole(t):
    return set(re.findall(r'[a-zà-ÿ]+', t.lower()))


def jaccard(a, b):
    x, y = parole(a), parole(b)
    return len(x & y) / max(1, len(x | y))


def difetti_di(cella, campo, testo):
    colpe = []
    lo, hi = LUNGHEZZE[campo]
    if not lo <= len(testo) <= hi:
        colpe.append(f'lunghezza {len(testo)}, fuori da {lo}-{hi}')
    if campo != 'titolo' and not cella.startswith('keplero') and not (
            SEGNI_DEL_TU.search(testo) or SEGNI_DEL_VOI.search(testo) or
            CON_IL_NOME.search(testo)):
        colpe.append('non si rivolge a te, alla coppia o a {nome}')
    for nome in SEGNAPOSTO.findall(testo):
        if nome != 'nome':
            colpe.append('segnaposto sconosciuto {' + nome + '}: vale solo {nome}')
    if PLURALE.search(testo):
        colpe.append('genere della coppia: "' + PLURALE.search(testo).group(0) +
                     '" (due donne o due uomini o una coppia mista: riscrivi '
                     'senza aggettivo che concorda)')
    if SINGOLARE_DEL_NOME.search(testo):
        colpe.append('genere di {nome}: "' + SINGOLARE_DEL_NOME.search(testo)
                     .group(0) + '"')
    if PRONOMI_DI_GENERE.search(testo):
        colpe.append('parola col genere dell\'altra persona o del ruolo: "' +
                     PRONOMI_DI_GENERE.search(testo).group(0) + '" (usa {nome} '
                     'o "l\'altra persona")')
    if GENERICO_SULLA_COPPIA.search(testo):
        colpe.append('genere generico sulla coppia o su {nome}: "' +
                     GENERICO_SULLA_COPPIA.search(testo).group(0) + '" (usa '
                     '"voi due", "ognuna delle due persone", "una persona e '
                     'l\'altra", "in amicizia")')
    if ACCENTO_FINTO.search(testo):
        colpe.append('accento scritto con l\'apostrofo: "' +
                     ACCENTO_FINTO.search(testo).group(0) + '"')
    if VIRGOLA_E.search(testo):
        colpe.append('virgola prima di "e" o "ed"')
    if TRATTINO.search(testo):
        colpe.append('trattino lungo')
    if PAROLE_VIETATE.search(testo):
        colpe.append('parola vietata: "' + PAROLE_VIETATE.search(testo).group(0) + '"')
    if CIFRA.search(testo):
        colpe.append('cifra nel testo')
    if '[' in testo and not re.search(r'\[[^\[\]|]+\|[^\[\]|]+\|[^\[\]|]+\]', testo):
        colpe.append('marca del genere malformata: [maschile|femminile|neutra]')
    return colpe


def forme_del_genere(testi):
    """Il criterio di casa, chiamato in Dart: una lista di liste."""
    if not testi:
        return []
    fd, nome = tempfile.mkstemp(suffix='.json')
    with os.fdopen(fd, 'w', encoding='utf-8') as f:
        json.dump(testi, f, ensure_ascii=False)
    # Con molti scrittori in parallelo, un eseguibile gia' compilato
    # (dart compile exe tool/forme_del_genere_dei_testi.dart) evita che
    # tanti `dart run` si contendano la cache di Dart: la variabile
    # FORME_DEL_GENERE_EXE ne dice il percorso. Senza, si usa `dart run`.
    eseguibile = os.environ.get('FORME_DEL_GENERE_EXE')
    comando = ([eseguibile, nome] if eseguibile and os.path.exists(eseguibile)
               else ['dart', 'run', 'tool/forme_del_genere_dei_testi.dart', nome])
    try:
        uscita = subprocess.run(
            comando, cwd=RADICE, capture_output=True, text=True,
            encoding='utf-8', shell=(os.name == 'nt' and not eseguibile))
        testo = uscita.stdout[uscita.stdout.find('['):]
        return json.loads(testo)
    finally:
        os.remove(nome)


# --- RIEMPI -----------------------------------------------------------------

def scrivi_nel_file(nome, nuovi):
    p = percorso(nome)
    righe = io.open(p, encoding='utf-8').read().split('\n')
    cella = None
    for i, riga in enumerate(righe):
        if riga.startswith('## '):
            cella = riga[3:].strip()
            continue
        m = RIGA.match(riga)
        if m and cella and (cella, m.group(1), int(m.group(2))) in nuovi:
            righe[i] = (f'- {m.group(1)} {m.group(2)}: ' +
                        nuovi[(cella, m.group(1), int(m.group(2)))])
    provvisorio = p + '.nuovo'
    io.open(provvisorio, 'w', encoding='utf-8', newline='\n').write('\n'.join(righe))
    for _ in range(40):
        try:
            os.replace(provvisorio, p)
            return
        except PermissionError:
            time.sleep(0.5)
    raise SystemExit('il file resta bloccato da Windows: ' + p)


def riempi(nome, testi_json):
    tutto = leggi(nome)
    proposte = json.load(io.open(testi_json, encoding='utf-8'))
    validi = {}
    scartati = []
    candidati = []
    for v in proposte:
        chiave = (v.get('cella', ''), v.get('campo', ''), int(v.get('n', 0)))
        testo = ' '.join(str(v.get('testo', '')).split())
        if chiave not in tutto:
            scartati.append((chiave, testo, ['cella, campo o numero inesistenti']))
            continue
        colpe = difetti_di(chiave[0], chiave[1], testo)
        if colpe:
            scartati.append((chiave, testo, colpe))
        else:
            candidati.append((chiave, testo))
    genere = forme_del_genere([t for _, t in candidati])
    for (chiave, testo), forme in zip(candidati, genere):
        if forme:
            scartati.append((chiave, testo, ['genere di chi legge: ' + ', '.join(forme)]))
            continue
        # Insieme alle varianti gia' scritte della stessa cella e campo.
        sorelle = [t for (c, f, n), t in tutto.items()
                   if c == chiave[0] and f == chiave[1] and n != chiave[2] and t]
        colpe = []
        for s in sorelle:
            if jaccard(s, testo) > 0.6:
                colpe.append('troppo simile a una variante gia\' scritta')
                break
            if s.split()[0].lower() == testo.split()[0].lower():
                colpe.append('comincia con la stessa parola di un\'altra variante')
                break
        # **LE FORMULE CHE SI RIPETONO FRA CELLE**: il primo giro del
        # Composito aveva trenta titoli che cominciavano tutti con "La vostra
        # relazione". Nello stesso file e nello stesso campo, le prime due
        # parole non tornano in piu' di un quinto delle celle.
        if not colpe and chiave[1] in ('titolo', 'apertura', 'fare'):
            attacco = ' '.join(testo.lower().split()[:2])
            uguali = sum(1 for (c, f, n), t in tutto.items()
                         if f == chiave[1] and t and c != chiave[0]
                         and ' '.join(t.lower().split()[:2]) == attacco)
            celle = len({c for (c, f, n) in tutto if f == chiave[1]})
            if uguali >= max(3, celle // 5):
                colpe.append(f'attacco ripetuto: "{attacco}" comincia gia\' '
                             f'{uguali} testi di questo campo in altre celle')
        if colpe:
            scartati.append((chiave, testo, colpe))
            continue
        validi[chiave] = testo
        tutto[chiave] = testo
    if validi:
        scrivi_nel_file(nome, validi)
    print(f'{nome}: scritti {len(validi)}, scartati {len(scartati)}')
    for chiave, testo, colpe in scartati:
        print(f'  SCARTATO {chiave[0]} | {chiave[1]} {chiave[2]}: {"; ".join(colpe)}')
        print(f'     {testo}')
    vuoti = sum(1 for t in leggi(nome).values() if not t)
    print(f'  ancora da scrivere in {nome}: {vuoti}')


# --- CONTROLLA, CONTA, GENERA ----------------------------------------------

def conta():
    totale = scritti = 0
    for nome in struttura():
        d = leggi(nome)
        pieni = sum(1 for t in d.values() if t)
        totale += len(d)
        scritti += pieni
        print(f'{nome}: {pieni} su {len(d)}')
    print(f'TOTALE: {scritti} su {totale}')
    return scritti, totale


def controlla():
    colpe = []
    tutti = []
    for nome, celle in struttura().items():
        d = leggi(nome)
        attese = {(c, f, n) for c, campi in celle for f, k in campi
                  for n in range(1, k + 1)}
        if set(d) != attese:
            colpe.append(f'{nome}: le celle del file non sono quelle della struttura')
        for chiave, testo in d.items():
            if not testo:
                colpe.append(f'{nome} {chiave}: vuoto')
                continue
            for c in difetti_di(chiave[0], chiave[1], testo):
                colpe.append(f'{nome} {chiave}: {c}')
            tutti.append((nome, chiave, testo))
    for (nome, chiave, testo), forme in zip(
            tutti, forme_del_genere([t for _, _, t in tutti])):
        if forme:
            colpe.append(f'{nome} {chiave}: genere di chi legge {forme}')
    # Le formule che si ripetono fra celle, sul file intero.
    from collections import Counter
    for nome in struttura():
        d = leggi(nome)
        for campo in ('titolo', 'apertura', 'fare'):
            celle = len({c for (c, f, n) in d if f == campo})
            if not celle:
                continue
            attacchi = Counter(' '.join(t.lower().split()[:2])
                               for (c, f, n), t in d.items() if f == campo and t)
            testi = sum(attacchi.values())
            # Sul file intero: nessun attacco apre piu' di un quarto dei
            # testi del campo. La ripetizione dentro la stessa lettura la
            # evita il motore (LetturaApprofondita).
            for attacco, quanti in attacchi.items():
                if quanti > testi // 4:
                    colpe.append(f'{nome} {campo}: "{attacco}" comincia {quanti} '
                                 f'testi su {celle} celle')
    for c in colpe:
        print(c)
    print(f'DIFETTI: {len(colpe)} su {len(tutti)} testi')
    return colpe


def dart_stringa(t):
    return "'" + t.replace('\\', '\\\\').replace("'", "\\'").replace('$', '\\$') + "'"


def genera():
    colpe = controlla()
    if colpe:
        raise SystemExit('LA FONTE NON E\' PRONTA: nessun Dart scritto a meta\'.')
    out = io.StringIO()
    out.write('// GENERATO da tool/il_corpus_della_sinastria.py dalla fonte in\n'
              '// docs/corpus/sinastria_approfondita/. Non si modifica a mano:\n'
              '// si corregge la fonte e si rigenera. Ordine FT voce FT.12.\n\n'
              '/// Il corpus della Sinastria approfondita: chiave '
              '"<file>|<cella>|<campo>", valore le varianti in ordine.\n'
              'const Map<String, List<String>> corpusDellaSinastriaApprofondita = {\n')
    for nome, celle in struttura().items():
        d = leggi(nome)
        for cella, campi in celle:
            for campo, k in campi:
                varianti = [d[(cella, campo, n)] for n in range(1, k + 1)]
                out.write(f"  '{nome}|{cella}|{campo}': [\n")
                for v in varianti:
                    out.write(f'    {dart_stringa(v)},\n')
                out.write('  ],\n')
    out.write('};\n')
    provvisorio = DART + '.nuovo'
    io.open(provvisorio, 'w', encoding='utf-8', newline='\n').write(out.getvalue())
    for _ in range(240):
        try:
            os.replace(provvisorio, DART)
            break
        except PermissionError:
            time.sleep(0.5)
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
    else:
        print(__doc__ or 'comandi: scheletro, riempi, controlla, conta, genera')
        sys.exit(2)
