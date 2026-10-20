"""Genera le carte nella loro posizione e i loro registri, dalla fonte.

Ordine EQ voce 04, 27 settembre 2026, esteso dall'ordine FI (voci 17, 20,
23, 24 e aggiunta A3 e A4, 11 ottobre 2026) alle diciassette posizioni delle
cinque stese, alle tre varianti di ogni testo e ai tre registri di ogni carta.

**Questo tool non chiama nessun modello.** I testi li scrive l'Architetto
(aggiunta A1): il tool legge la fonte, fa i controlli e scrive il Dart.

La fonte sta in docs/corpus/tarocchi_posizione/:
- un file per posizione, `<posizione>.md`, con le 78 carte nell'ordine del
  mazzo, i due versi e per ogni verso le tre varianti, `- 1:`, `- 2:`, `- 3:`;
- `registri.md`, con le 78 carte, i due versi e per ogni verso i tre gruppi
  dell'argomento, `- amore:`, `- lavoro:`, `- vita:`.

Una riga senza testo e' un testo che non c'e' ancora. Il conto si fa per
colonna: una variante (o il registro) e' o piena in tutte le 156 carte-verso
o vuota in tutte. A meta' il tool si FERMA e nomina le righe che mancano,
invece di scrivere un file dati a meta'. La variante 2 non esiste senza la 1,
la 3 non esiste senza la 2.

L'uscita e' lib/core/tarot/le_carte_nella_posizione_dati.dart. Il corpus si
tocca alla fonte: si modifica il markdown e si rilancia questo script.

    python tool/genera_carte_nella_posizione.py
    python tool/genera_carte_nella_posizione.py --prepara
    python tool/genera_carte_nella_posizione.py --misura
    python tool/genera_carte_nella_posizione.py --forma-nuova

`--prepara` crea i file della fonte che non ci sono, con le intestazioni e le
righe vuote; non riscrive mai un file che esiste gia'.

**LA FORMA NUOVA, ordine GA voce 07, 20 ottobre 2026.** Il fondatore, 19
ottobre 2026: *"tutte le risposte composte da paragrafi ognuno con tra 40 a 50
parole ognuno"* e *"Restano all'inizio i titoli, anche per le singola
carte"*; 20 ottobre 2026, "Carte dal corpus": in ogni stesa le singole carte
vengono dal corpus, ognuna col suo titolo, un paragrafo e il riquadro "Cosa
fare adesso". Da qui la fonte porta due file in piu':
- `titoli.md`, per carta e verso un titolo per ognuna delle quindici
  posizioni, `- passato:`, `- presente:` eccetera coi nomi di
  `SpreadPosition`, uno per le tre varianti dello scheletro;
- `cosa_fare.md`, per carta e verso tre varianti per ognuno dei tre gruppi
  dell'argomento, `- amore_1:` ... `- vita_3:`, che girano con le uscite come
  gli scheletri.
Il paragrafo della carta resta lo scheletro della posizione seguito dal
registro del gruppo (`LeCarteNellaPosizione.letturaDiCasa`); la forma nuova
lo misura in PAROLE separate da uno spazio, come `LaFormaDelResponso.parole`:
fra 40 e 50 con ognuno dei tre registri, ognuna delle tre varianti e ognuna
delle tre forme della marca del genere. Il "cosa fare" sta fra 40 e 50 parole,
il titolo fra tre e otto.

La forma nuova e' IN VIGORE appena `titoli.md` o `cosa_fare.md` portano un
testo, oppure con `--forma-nuova`: allora la misura in parole e i controlli
di lingua nuovi (niente punto esclamativo, niente futuro in "-rai", niente
apostrofo al posto dell'accento, niente forme col genere di chi legge fuori
dalla marca) fermano lo script come gli altri. Finche' non e' in vigore lo
script scrive il Dart di oggi, con le due mappe nuove vuote. `--misura`
stampa quante combinazioni stanno gia' nella misura e quanti testi vanno
riscritti, senza scrivere niente. Le parti degli scrittori si rimettono nella
fonte con `tool/unisci_le_parti_dei_tarocchi.py`.
"""
import io
import os
import re
import sys
import time

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FONTE = os.path.join(RADICE, 'docs', 'corpus', 'tarocchi_posizione')
REGISTRI = os.path.join(FONTE, 'registri.md')
TITOLI = os.path.join(FONTE, 'titoli.md')
COSA_FARE = os.path.join(FONTE, 'cosa_fare.md')
MAZZO = os.path.join(RADICE, 'lib', 'core', 'tarot', 'tarot_card.dart')
USCITA = os.path.join(RADICE, 'lib', 'core', 'tarot',
                      'le_carte_nella_posizione_dati.dart')

VERSI = ('dritta', 'capovolta')
VARIANTI = ('1', '2', '3')
GRUPPI = ('amore', 'lavoro', 'vita')

# Le quindici posizioni nell'ordine di `SpreadPosition` (diciassette fino
# all'ordine FJ, aggiunta 2, che ha tolto il ferro di cavallo e le sue tre
# posizioni orfane: consiglio, ostacolo, ambiente; piu' `dietro`, la quinta
# carta della Croce Celtica, dall'ordine FK voce 8): il nome nel Dart,
# il nome del file e come la posizione si legge, per l'Architetto.
POSIZIONI = (
    ('passato', 'passato', 'Il passato della stesa a tre carte.'),
    ('presente', 'presente', 'Il presente della stesa a tre carte.'),
    ('futuro', 'futuro', 'Il futuro della stesa a tre carte.'),
    ('cartaSola', 'carta_sola', 'La carta sola della stesa a una carta.'),
    ('consultante', 'consultante',
     'Il consultante della croce di Dora: la situazione reale, il punto in '
     'cui si trova chi chiede, non il futuro (voce FI.22).'),
    ('lato', 'lato',
     'Il lato della croce di Dora: che cosa la carta mette sulla strada, '
     'senza chiamarla consiglio ne\' ostacolo (voce FI.21).'),
    ('esito', 'esito',
     'L\'esito della croce di Dora e della Croce Celtica.'),
    ('copre', 'copre', 'Cio\' che copre, la prima della Croce Celtica.'),
    ('attraversa', 'attraversa', 'Cio\' che attraversa, di traverso.'),
    ('corona', 'corona', 'Cio\' che corona, nella Croce Celtica.'),
    ('sotto', 'sotto', 'Il fondamento della Croce Celtica.'),
    ('dietro', 'dietro',
     'Cio\' che e\' dietro, la quinta carta della Croce Celtica (ordine FK '
     'voce 8). Waite 1911, Parte III, sezione 7: "This is behind him. It '
     'gives the influence that is just passed, or is now passing away." Due '
     'stati: cio\' che e\' appena trascorso e cio\' che sta svanendo adesso. '
     'Non e\' il fondamento, il passato fatto proprio, che e\' la quarta.'),
    ('seStesso', 'se_stesso', 'Te stesso, nella Croce Celtica.'),
    ('laCasa', 'la_casa', 'La tua casa, nella Croce Celtica.'),
    ('speranzeOTimori', 'speranze_o_timori',
     'Speranze o timori, nella Croce Celtica.'),
)

LUNGHEZZA = (110, 280)

# **LA FORMA NUOVA**, ordine GA voce 07. Le chiavi dei due file nuovi, le
# misure in parole e i tetti del titolo, quelli che `la_lettura_dal_modello`
# chiede al titolo del responso (da tre a otto parole, settanta caratteri,
# niente due punti ne' punto di domanda).
CHIAVI_DEI_TITOLI = tuple(d for d, _, _ in POSIZIONI)
CHIAVI_DEL_COSA_FARE = tuple('%s_%s' % (g, k) for g in GRUPPI
                             for k in VARIANTI)
PAROLE_DEL_PARAGRAFO = (40, 50)
PAROLE_DEL_TITOLO = (3, 8)
CARATTERI_DEL_TITOLO = 70

# Promesse che il Cerchio non fa (salute, denaro, leggi, morte) e previsioni
# date per certe: i controlli che il corpus del 27 settembre ha passato.
PROMESSE = (
    r'\bguari\w*', r'\bmalatti\w*', r'\bdiagnos\w*',
    r'\bvincit\w*', r'\blotteri\w*', r'\beredit\w*', r'\barricch\w*',
    r'\bcausa (legale|civile|penale)', r'\btribunal\w*', r'\bsentenz\w*',
    r'\bmorir\w*', r'\bmorte\b', r'\bmorrai\b',
)
CERTEZZE = (
    r'\bsicuramente\b', r'\bcertamente\b', r'\bsenza dubbio\b',
    r'\bdi certo\b', r'\bsuccedera\'?\b', r'\bsuccederà\b',
    r'\baccadra\'?\b', r'\baccadrà\b', r'\barrivera\'?\b', r'\barriverà\b',
    r'\bincontrerai\b', r'\botterrai\b', r'\btroverai\b',
)
JACCARD = 0.6

# **LA SECONDA PERSONA**, ordine FM voce 04. L'intestazione di ogni file del
# corpus pretende testi "rivolte alla persona col tu", e fino all'ordine FM
# nessuno lo misurava: 343 testi su 4.212 non avevano un solo segno del tu.
# Un testo passa se porta almeno un segno: un pronome del tu, un verbo breve
# alla seconda persona, un presente frequente alla seconda persona, o una
# desinenza che in italiano e' solo del tu (il futuro in -rai, l'imperfetto
# in -avi ed -evi, il condizionale in -resti, l'infinito col "ti" in -arti,
# -erti, -irti). Le parole qui sotto finiscono allo stesso modo senza essere
# del tu, e non contano.
LETTERE = 'a-zàèéìòù'
TU_PAROLE = (
    'tu ti te tuo tua tuoi tue teco vi voi vostro vostra vostri vostre '
    'hai sei sai fai stai vai puoi vuoi devi avevi eri '
    'senti stringi reggi corri tieni vedi guardi chiedi pensi credi '
    'scegli lasci aspetti provi prendi metti perdi trovi '
    'speri ascolti conosci capisci dici decidi rimani torni entri '
    'esci apri chiudi chiami costruisci difendi nascondi offri '
    'segui sostieni trattieni raccogli accogli spendi muovi '
    'attendi insegui rinunci accetti eviti rimandi ripeti '
    'dimentichi guadagni possiedi custodisci proteggi '
    'nutri coltivi parli taci '
    'tenti cominci finisci cedi vinci fuggi resisti sbagli impari '
    'tendi continui ritrovi percorri impugni rialzi riconosci affronti '
    'sciogli scopri'
).split()
# Fuori dall'elenco i presenti che sono anche nomi comuni (sogni, desideri,
# ricordi, cerchi, mostri, temi, cammini, lavori, rifiuti, dai e altri):
# darebbero il passaggio a un testo in terza persona.
TU_DESINENZE = (r'[%s]{2,}(?:rai|avi|evi)' % LETTERE,
                r'[%s]{2,}resti' % LETTERE,
                r'[%s]{3,}(?:arti|erti|irti)' % LETTERE,
                r'[%s]{3,}(?:andoti|endoti)' % LETTERE,
                r'(?:op|pro|com|dis)porti')
NON_DEL_TU = set((
    'chiavi navi gravi schiavi bravi brevi lievi nevi allievi rilievi '
    'sollievi foresti offerti coperti scoperti esperti deserti concerti '
    'inserti inerti certi incerti aperti sofferti conserti diserti '
    'scarti quarti'
).split())

# **I CONTROLLI DI LINGUA DELLA FORMA NUOVA**, ordine GA voce 07: gli stessi
# di `tool/le_parole_dei_responsi.py`, che li fa valere sull'Oroscopo.
NON_FUTURI = {'distrai', 'attrai', 'estrai', 'sottrai', 'trai', 'ritrai',
              'contrai'}
FUTURO = re.compile(r'(?<![%s])([%s]+rai)(?![%s])' % (LETTERE, LETTERE,
                                                      LETTERE), re.I)
ACCENTO_COL_APOSTROFO = re.compile(
    r"\b(piu|perche|gia|cosi|puo|pero|finche|poiche|affinche|cioe|"
    r"nonche)'", re.I)

# **IL GENERE DI CHI LEGGE**, il criterio di
# `lib/core/chat/le_forme_del_genere.dart` (`formeDelGenere`) portato qui
# parola per parola, perche' chi scrive veda la forma accordata prima che la
# guardia `il_genere_non_si_indovina` la trovi nel Dart. Se cambia la, va
# cambiato anche qui.
DIZIONARIO_DEL_GENERE = (
    'arrivato nato sceso andato tornato stato rimasto uscito venuto entrato '
    'disposto chiamato protetto difeso riconosciuto guadagnato caricato '
    'speso imposto diventato scordato '
    'pronto sicuro solo stanco curioso attento bloccato assediato '
    'sopraffatto libero generoso concentrato espressivo socievole caloroso '
    'essenziale misurato raccolto prezioso onesto deluso forte').split()
_INVARIABILI = {'socievole', 'essenziale', 'forte'}
_NON_PARTICIPI = set((
    'questo questa quanto quanta tanto tanta tutto tutta molto molta poco '
    'poca visto vista giusto giusta posto posta canto conto conta punto '
    'punta santo santa volto volta mondo gesto gesta testo resto resta costo '
    'costa lato adesso spesso presto processo successo interesse').split())
_DOPO_L_AGGETTIVO_SOLO = set((
    'con e ed davanti in quando mentre per di a al alla nel nella tra fra '
    'come anche o ma').split())
_L = LETTERE
_PAROLE_COL_GENERE = '|'.join(
    x for p in DIZIONARIO_DEL_GENERE if p not in _INVARIABILI
    for x in (p, p[:-1] + 'a'))
_V2 = (r'sei|eri|sarai|saresti|fossi|ti senti|ti sentirai|'
       r'ti sentiresti|ti sentivi|ti sei|ti eri|resti|rimani|diventi|'
       r'diventerai|sembri|ti trovi|ti ritrovi|ti scopri|ti scoprirai|'
       r'sentendoti')
_VI_SEMPRE = (r'sentirti|esserti|ritrovarti|trovarti|farti trovare|'
              r'fatti trovare|sentendoti')
_VI = (r'essere|esserne|stare|restare|rimanere|diventare|restando|'
       r'rimanendo')
_AVV = (r'(?:(?:più|così|già|molto|troppo|ancora|davvero|anche|sempre|mai|'
        r'poco|tanto|meno|ben|abbastanza|di nuovo|forse|oggi|qui|sì|'
        r'stat[oa]) )*')
_PART = '[%s]{2,}(?:at|ut|it|es|ess|ott|st|nt)[oa]' % _L
_VERBO = re.compile(
    r"(?<![%s'])(?<!\blo )(?<!\bla )(?<!\bli )(?<!\ble )(?<!l')"
    r'(?:%s) %s(%s|%s)(?![%s])' % (_L, _V2, _AVV, _PAROLE_COL_GENERE, _PART,
                                   _L), re.I)
_VERBO_DA = re.compile(r"(?<![%s'])(?:%s) da (%s)(?![%s])" % (
    _L, _V2, _PAROLE_COL_GENERE, _L), re.I)
_INFINITO_SEMPRE = re.compile(r"(?<![%s'])(?:%s) %s(%s)(?![%s])" % (
    _L, _VI_SEMPRE, _AVV, _PAROLE_COL_GENERE, _L), re.I)
_INFINITO = re.compile(r"(?<![%s'])(?:%s) %s(%s)(?![%s])" % (
    _L, _VI, _AVV, _PAROLE_COL_GENERE, _L), re.I)
_SECONDA_PERSONA = re.compile(
    r'(?<![%s])(ti|tu|sei|hai|puoi|vuoi|devi|sai|riesci|aspetti|temi|rischi|'
    r'smetti|provi|cerchi|preferisci|scegli|serve)(?![%s])' % (_L, _L), re.I)
_STESSO = re.compile(r'(?<![%s])(te stess[oa]|tu stess[oa])(?![%s])' % (
    _L, _L), re.I)
_VOCATIVO = re.compile(
    r'(?:^|[.!?]\s+|\n)\s*(Benvenut[oa]|Bentornat[oa]|Car[oa])(?=[ ,!])')
MARCA = re.compile(r'\[[^\[\]|]*\|[^\[\]|]*\|[^\[\]]*\]')


def _solo_avverbio(t, m):
    if m.group(1).lower() != 'solo':
        return False
    dopo = re.match(r'^\s+([%s]+)' % _L, t[m.end():], re.I)
    if dopo is None:
        return False
    return dopo.group(1).lower() not in _DOPO_L_AGGETTIVO_SOLO


def forme_del_genere(testo):
    """Le forme di [testo] che dicono il genere di chi legge, fuori dalle
    marche: `formeDelGenere` di `le_forme_del_genere.dart`."""
    t = MARCA.sub('', testo)
    colpi = []
    for m in _VERBO.finditer(t):
        if m.group(1).lower() in _NON_PARTICIPI or _solo_avverbio(t, m):
            continue
        colpi.append(m.group(0))
    colpi += [m.group(0) for m in _VERBO_DA.finditer(t)]
    for m in _INFINITO_SEMPRE.finditer(t):
        if not _solo_avverbio(t, m):
            colpi.append(m.group(0))
    for m in _INFINITO.finditer(t):
        if _solo_avverbio(t, m):
            continue
        inizio = max(t.rfind(s, 0, m.start() + 1) for s in '.!?\n')
        prima = t[inizio + 1:m.start()]
        if (not prima.strip() or _SECONDA_PERSONA.search(prima)
                or prima.endswith(' di ')):
            colpi.append(m.group(0))
    colpi += [m.group(0) for m in _STESSO.finditer(t)]
    colpi += [m.group(1) for m in _VOCATIVO.finditer(t)]
    return colpi


def le_tre_forme(t):
    """Il testo con la marca del genere risolta nelle sue tre forme,
    maschile, femminile e neutra, come `LaMarcaDelGenere.risolvi`."""
    if '[' not in t:
        return [t]
    return [MARCA.sub(lambda m, i=i: m.group(0)[1:-1].split('|')[i], t)
            for i in range(3)]


def conta_parole(t):
    """(meno, piu') parole fra le tre forme del testo, separate da uno
    spazio come le conta `LaFormaDelResponso.parole`."""
    n = [len(f.split()) for f in le_tre_forme(t)]
    return min(n), max(n)


def difetti_di_lingua(t):
    """I controlli di lingua che la forma nuova aggiunge a ogni testo."""
    colpe = []
    if '!' in t:
        colpe.append('un punto esclamativo')
    for m in FUTURO.finditer(t):
        if m.group(1).lower() not in NON_FUTURI:
            colpe.append('un futuro rivolto a chi legge (%s)' % m.group(1))
    if ACCENTO_COL_APOSTROFO.search(t) or re.search(r"\be' ", t):
        colpe.append('un apostrofo al posto dell\'accento')
    if not any(frase in t for frase in FRASI_DICHIARATE):
        for f in forme_del_genere(t):
            colpe.append('il genere di chi legge fuori dalla marca (%s)' % f)
    return colpe


# Le frasi del corpus in cui la forma presa dal criterio non e' di chi legge,
# dichiarate una per una in `test/il_genere_non_si_indovina_test.dart`
# (`frasiDelCorpus`): qui solo quelle dei tarocchi.
FRASI_DICHIARATE = (
    'purché la direzione resti incollata agli occhi tuoi',
)


class FonteIncompleta(ValueError):
    pass


def carte_del_mazzo():
    """I 78 nomi nell'ordine di `TarotDeck.cards`, letti dal Dart."""
    testo = io.open(MAZZO, encoding='utf-8').read()
    nomi = re.findall(r"^\s*name: '((?:[^'\\]|\\.)*)',", testo, re.M)
    nomi = [n.replace("\\'", "'") for n in nomi]
    if len(nomi) != 78 or len(set(nomi)) != 78:
        raise ValueError('il mazzo in %s porta %d nomi, non 78' %
                         (MAZZO, len(nomi)))
    return nomi


def testo_del_file(percorso, testi=None):
    """Il contenuto di un file della fonte; [testi], {percorso: contenuto},
    lo sostituisce senza toccare il disco (lo usa
    `tool/unisci_le_parti_dei_tarocchi.py` per controllare prima di
    scrivere)."""
    if testi and os.path.normcase(os.path.abspath(percorso)) in testi:
        return testi[os.path.normcase(os.path.abspath(percorso))]
    return io.open(percorso, encoding='utf-8', newline='').read()


def leggi_file(percorso, chiavi, carte, testi=None):
    """{(carta, verso): {chiave: testo o ''}} da un file della fonte.

    Pretende le 78 carte nell'ordine del mazzo, i due versi e tutte le
    righe delle [chiavi], anche vuote: una riga che non c'e' o che sta fuori
    posto ferma lo script.
    """
    testo = testo_del_file(percorso, testi)
    nome = os.path.relpath(percorso, RADICE).replace('\\', '/')
    dati = {}
    trovate = []
    carta = verso = None
    regola = re.compile(r'^- (%s):(.*)$' % '|'.join(chiavi))
    for numero, riga in enumerate(testo.split('\n'), 1):
        riga = riga.rstrip('\r')
        m = re.match(r'^## (.+)$', riga)
        if m:
            carta = m.group(1).strip()
            trovate.append(carta)
            verso = None
            continue
        m = re.match(r'^### (dritta|capovolta)$', riga)
        if m:
            if carta is None or (carta, m.group(1)) in dati:
                raise FonteIncompleta('%s, riga %d: verso fuori posto' %
                                      (nome, numero))
            verso = m.group(1)
            dati[(carta, verso)] = {}
            continue
        m = regola.match(riga)
        if m:
            if verso is None or m.group(1) in dati[(carta, verso)]:
                raise FonteIncompleta('%s, riga %d: riga fuori posto' %
                                      (nome, numero))
            dati[(carta, verso)][m.group(1)] = m.group(2).strip()
        elif riga.startswith('- '):
            raise FonteIncompleta('%s, riga %d: riga che il tool non sa '
                                  'leggere' % (nome, numero))
    if trovate != carte:
        diverse = [c for c in carte if c not in trovate] + [
            c for c in trovate if c not in carte]
        raise FonteIncompleta('%s: le carte non sono le 78 del mazzo '
                              'nell\'ordine del mazzo (%s)' %
                              (nome, ', '.join(diverse[:5]) or 'ordine'))
    mancanti = ['%s, %s, %s' % (c, v, k) for c in carte for v in VERSI
                for k in chiavi if k not in dati.get((c, v), {})]
    if mancanti:
        raise FonteIncompleta('%s: %d righe mancanti, la prima: %s' %
                              (nome, len(mancanti), mancanti[0]))
    return dati


def colonne_piene(nome, dati, chiavi, carte, contigue):
    """Le [chiavi] piene in tutte le 156 carte-verso.

    Una colonna a meta' ferma lo script nominando le righe vuote; con
    [contigue] una colonna piena dopo una vuota lo ferma pure.
    """
    piene = []
    for k in chiavi:
        vuote = ['%s, %s' % (c, v) for c in carte for v in VERSI
                 if not dati[(c, v)][k]]
        if len(vuote) == len(carte) * len(VERSI):
            continue
        if vuote:
            raise FonteIncompleta(
                '%s, colonna %s: %d testi su %d, ne mancano %d (%s%s)' % (
                    nome, k, len(carte) * 2 - len(vuote), len(carte) * 2,
                    len(vuote), '; '.join(vuote[:3]),
                    ', ...' if len(vuote) > 3 else ''))
        piene.append(k)
    if contigue and piene != list(chiavi[:len(piene)]):
        raise FonteIncompleta('%s: le varianti piene sono %s, ma la 2 non '
                              'esiste senza la 1 e la 3 senza la 2' %
                              (nome, ', '.join(piene)))
    return piene


def parole(t):
    return set(re.findall(r"[a-zàèéìòù]+", t.lower()))


def jaccard(a, b):
    return len(a & b) / float(len(a | b) or 1)


def segni_del_tu(t):
    """I segni della seconda persona nel testo (ordine FM voce 04)."""
    basso = t.lower()
    trovati = []
    for p in re.findall(r"(?<![%s])([%s]+)(?![%s])" % (
            LETTERE, LETTERE, LETTERE), basso):
        if p in NON_DEL_TU:
            continue
        if p in TU_PAROLE or any(re.fullmatch(d, p) for d in TU_DESINENZE):
            trovati.append(p)
    trovati += re.findall(r"(?<![%s])t'" % LETTERE, basso)
    return trovati


def controlla_testo(dove, t, carta, lunghezza=True, tu=True):
    """I controlli di un testo solo; la lista dei difetti trovati.

    [lunghezza] e [tu] restano veri per gli scheletri, come prima della forma
    nuova; i registri non si misurano in caratteri e non parlano col tu
    (sono l'ambito, non la frase rivolta alla persona), il "cosa fare" si
    misura in parole.
    """
    colpe = []
    if lunghezza and not LUNGHEZZA[0] <= len(t) <= LUNGHEZZA[1]:
        colpe.append('lunghezza %d fuori da %d-%d' % ((len(t),) + LUNGHEZZA))
    basso = t.lower()
    # La guardia tarot_accordo_rovescio vieta la parola del rovescio nelle
    # stringhe dei tarocchi: si prende da TarotCard.reversedWord.
    if 'rovesciat' in basso or 'capovolt' in basso:
        colpe.append('il verso nominato')
    # Il nome della carta stessa: "il mondo" o "la forza" dentro un'altra
    # carta sono parole, non nomi.
    if carta.lower() in basso:
        colpe.append('il nome della carta')
    if re.search(r'\d', t):
        colpe.append('una cifra')
    if tu and not segni_del_tu(t):
        colpe.append('non si rivolge alla persona col tu')
    if '—' in t or '–' in t:
        colpe.append('il trattino lungo')
    if re.search(r'\bvoce\b', basso):
        colpe.append('la parola voce')
    if re.search(r', (e|ed) ', t):
        colpe.append('una virgola seguita da e')
    # La marca del genere si scrive per intero, [maschile|femminile|neutra]:
    # la guardia il_genere_non_si_indovina legge poi ogni stringa del Dart.
    for marca in re.findall(r'\[[^\]]*\]', t):
        if marca.count('|') != 2 or '' in marca[1:-1].split('|'):
            colpe.append('marca del genere storta %s' % marca)
    for p in PROMESSE:
        if re.search(p, basso):
            colpe.append('una promessa (%s)' % re.search(p, basso).group(0))
    for p in CERTEZZE:
        if re.search(p, basso):
            colpe.append('una previsione certa (%s)' %
                         re.search(p, basso).group(0))
    return ['%s: %s' % (dove, c) for c in colpe]


def controlla_titolo(dove, t, carta):
    """I controlli del titolo di una carta in una posizione (forma nuova).

    Il titolo a colpo d'occhio e' gia' la risposta della carta in quel posto:
    da tre a otto parole, al piu' settanta caratteri, senza due punti, punto
    di domanda, punto esclamativo o punto finale, con la maiuscola in testa.
    """
    colpe = controlla_testo(dove, t, carta, lunghezza=False, tu=False)
    meno, piu = conta_parole(t)
    if meno < PAROLE_DEL_TITOLO[0] or piu > PAROLE_DEL_TITOLO[1]:
        colpe.append('%s: il titolo ha %s parole, fuori da %d-%d' % (
            dove, meno if meno == piu else '%d-%d' % (meno, piu),
            PAROLE_DEL_TITOLO[0], PAROLE_DEL_TITOLO[1]))
    lungo = max(len(f) for f in le_tre_forme(t))
    if lungo > CARATTERI_DEL_TITOLO:
        colpe.append('%s: il titolo ha %d caratteri, oltre %d' % (
            dove, lungo, CARATTERI_DEL_TITOLO))
    if re.search(r'[:;?]', t):
        colpe.append('%s: il titolo ha i due punti, il punto e virgola o il '
                     'punto di domanda' % dove)
    if t.rstrip().endswith('.'):
        colpe.append('%s: il titolo finisce col punto' % dove)
    if not re.match(r'^[A-ZÀÈÉÌÒÙ]', t):
        colpe.append('%s: il titolo non comincia con la maiuscola' % dove)
    colpe += ['%s: %s' % (dove, c) for c in difetti_di_lingua(t)]
    return colpe


def controlla_cosa_fare(dove, t, carta):
    """I controlli di un "cosa fare" (forma nuova): quelli degli scheletri,
    il tu compreso, con la misura in parole al posto dei caratteri."""
    colpe = controlla_testo(dove, t, carta, lunghezza=False)
    meno, piu = conta_parole(t)
    if meno < PAROLE_DEL_PARAGRAFO[0] or piu > PAROLE_DEL_PARAGRAFO[1]:
        colpe.append('%s: %s parole, fuori da %d-%d' % (
            dove, meno if meno == piu else '%d-%d' % (meno, piu),
            PAROLE_DEL_PARAGRAFO[0], PAROLE_DEL_PARAGRAFO[1]))
    colpe += ['%s: %s' % (dove, c) for c in difetti_di_lingua(t)]
    return colpe


def parole_del_paragrafo(scheletro, registro):
    """Le parole del paragrafo della carta, lo scheletro e dopo di lui il
    registro (`LeCarteNellaPosizione.letturaDiCasa`), in ognuna delle tre
    forme della marca: [(forma, parole)]."""
    fs, fr = le_tre_forme(scheletro), le_tre_forme(registro)
    n = max(len(fs), len(fr))
    return [len(fs[min(i, len(fs) - 1)].split()) +
            len(fr[min(i, len(fr) - 1)].split()) for i in range(n)]


def misura_dei_paragrafi(scheletri, registri, solo=None):
    """{(posizione, carta, verso, variante): {gruppo: (meno, piu')}} per
    ogni scheletro, col registro di ogni gruppo."""
    misure = {}
    for (pos, carta, verso), varianti in scheletri.items():
        if solo is not None and carta not in solo:
            continue
        righe = registri.get((carta, verso))
        if not righe:
            continue
        for i, t in enumerate(varianti, 1):
            m = {}
            for g, r in zip(GRUPPI, righe):
                n = parole_del_paragrafo(t, r)
                m[g] = (min(n), max(n))
            misure[(pos, carta, verso, i)] = m
    return misure


def a_misura(meno, piu):
    return PAROLE_DEL_PARAGRAFO[0] <= meno and piu <= PAROLE_DEL_PARAGRAFO[1]


def controlla(scheletri, registri, carte, titoli=None, cosa_fare=None,
              solo=None, forma_nuova=False):
    """I controlli sull'insieme: doppioni, somiglianza, prime parole e, con
    la [forma_nuova], le misure in parole e la lingua.

    [titoli]: {(posizione, carta, verso): titolo}; [cosa_fare]: {(carta,
    verso, gruppo): [variante, ...]}; solo i testi pieni. Con [solo], un
    insieme di nomi di carte, si guardano i testi di quelle carte e le coppie
    in cui almeno uno dei due e' loro: e' il controllo di una parte.
    """
    titoli = titoli or {}
    cosa_fare = cosa_fare or {}

    def tocca(carta):
        return solo is None or carta in solo

    colpe = []
    tutti = {}

    def doppione(dove, carta, t):
        if t in tutti and (tocca(carta) or tocca(tutti[t][1])):
            colpe.append('%s: doppione di %s' % (dove, tutti[t][0]))
        tutti[t] = (dove, carta)

    for (pos, carta, verso), varianti in scheletri.items():
        for i, t in enumerate(varianti, 1):
            dove = '%s, %s, %s, variante %d' % (pos, carta, verso, i)
            if tocca(carta):
                colpe += controlla_testo(dove, t, carta)
                if forma_nuova:
                    colpe += ['%s: %s' % (dove, c)
                              for c in difetti_di_lingua(t)]
            doppione(dove, carta, t)
        prime = [t.split()[0].lower().strip(",.'") for t in varianti]
        if tocca(carta) and len(varianti) == 3 and len(set(prime)) < 3:
            colpe.append('%s, %s, %s: le tre varianti cominciano con la '
                         'stessa parola' % (pos, carta, verso))
    for (carta, verso), righe in registri.items():
        for g, t in zip(GRUPPI, righe):
            dove = 'registro %s, %s, %s' % (carta, verso, g)
            if tocca(carta):
                colpe += controlla_testo(dove, t, carta, lunghezza=False,
                                         tu=False)
                if forma_nuova:
                    colpe += ['%s: %s' % (dove, c)
                              for c in difetti_di_lingua(t)]
            doppione(dove, carta, t)
    # I titoli: nessun doppione fra i titoli, in nessuna carta e in nessuna
    # posizione. Un titolo che starebbe sotto due carte non e' la risposta di
    # nessuna delle due (voce GA.06).
    visti = {}
    for (pos, carta, verso), t in titoli.items():
        dove = 'titolo %s, %s, %s' % (pos, carta, verso)
        if tocca(carta):
            colpe += controlla_titolo(dove, t, carta)
        chiave = t.strip().lower()
        if chiave in visti and (tocca(carta) or tocca(visti[chiave][1])):
            colpe.append('%s: lo stesso titolo di %s' % (dove,
                                                        visti[chiave][0]))
        visti[chiave] = (dove, carta)
    for (carta, verso, g), varianti in cosa_fare.items():
        for i, t in enumerate(varianti, 1):
            dove = 'cosa fare %s, %s, %s %d' % (carta, verso, g, i)
            if tocca(carta):
                colpe += controlla_cosa_fare(dove, t, carta)
            doppione(dove, carta, t)
        prime = [t.split()[0].lower().strip(",.'") for t in varianti]
        if tocca(carta) and len(varianti) == 3 and len(set(prime)) < 3:
            colpe.append('cosa fare %s, %s, %s: le tre varianti cominciano '
                         'con la stessa parola' % (carta, verso, g))
    # **LA MISURA DEL PARAGRAFO DELLA CARTA**, in parole: lo scheletro con
    # ognuno dei tre registri, in ognuna delle tre forme della marca.
    if forma_nuova:
        for (pos, carta, verso, i), m in misure_ordinate(
                misura_dei_paragrafi(scheletri, registri, solo), carte):
            fuori = [g for g in GRUPPI if not a_misura(*m[g])]
            if fuori:
                colpe.append(
                    '%s, %s, %s, variante %d: il paragrafo con il registro '
                    'fa %s parole, fuori da %d-%d con %s' % (
                        pos, carta, verso, i, ', '.join(
                            '%s %s' % (g, m[g][0] if m[g][0] == m[g][1]
                                       else '%d-%d' % m[g]) for g in GRUPPI),
                        PAROLE_DEL_PARAGRAFO[0], PAROLE_DEL_PARAGRAFO[1],
                        ', '.join(fuori)))
    # Jaccard sopra 0,6: dentro la stessa posizione e fra le posizioni della
    # stessa carta-verso, dove due testi si incontrano davvero; per il "cosa
    # fare", fra i testi della stessa carta-verso (scheletri compresi: il
    # riquadro non ripete il paragrafo) e fra tutti quelli dello stesso
    # gruppo. Tutte le coppie degli oltre novemila testi sarebbero quaranta
    # milioni.
    gruppi = {}
    for (pos, carta, verso), varianti in scheletri.items():
        for i, t in enumerate(varianti, 1):
            voce = ('%s, %s, %s, variante %d' % (pos, carta, verso, i),
                    parole(t), carta)
            gruppi.setdefault(('pos', pos), []).append(voce)
            gruppi.setdefault(('carta', carta, verso), []).append(voce)
    for (carta, verso, g), varianti in cosa_fare.items():
        for i, t in enumerate(varianti, 1):
            voce = ('cosa fare %s, %s, %s %d' % (carta, verso, g, i),
                    parole(t), carta)
            gruppi.setdefault(('cosa', g), []).append(voce)
            gruppi.setdefault(('carta', carta, verso), []).append(voce)
    viste = set()
    for elenco in gruppi.values():
        for i in range(len(elenco)):
            for j in range(i + 1, len(elenco)):
                if not (tocca(elenco[i][2]) or tocca(elenco[j][2])):
                    continue
                coppia = (elenco[i][0], elenco[j][0])
                if coppia in viste:
                    continue
                viste.add(coppia)
                s = jaccard(elenco[i][1], elenco[j][1])
                if s > JACCARD:
                    colpe.append('%s e %s: somiglianza %.2f' % (
                        coppia[0], coppia[1], s))
    return colpe


def misure_ordinate(misure, carte):
    """Le misure nell'ordine delle posizioni e del mazzo."""
    pos = [d for d, _, _ in POSIZIONI]
    return sorted(misure.items(), key=lambda kv: (
        pos.index(kv[0][0]), carte.index(kv[0][1]), VERSI.index(kv[0][2]),
        kv[0][3]))


class Fonte(object):
    """La fonte letta: i testi, le colpe; se la forma nuova e' in vigore."""

    def __init__(self):
        self.carte = []
        self.scheletri = {}
        self.registri = {}
        self.titoli = {}
        self.cosa_fare = {}
        self.conto = {}
        self.colpe = []
        self.forma_nuova = False
        self.titoli_pieni = False
        self.cosa_fare_pieni = False


def controlla_la_fonte(testi=None, solo=None, forma_nuova=None):
    """Legge la fonte e la controlla; una `Fonte` con le colpe trovate.

    Si ferma con `FonteIncompleta` se la forma della fonte e' rotta (una
    carta fuori posto, una riga mancante, una colonna degli scheletri a
    meta'). [testi], {percorso: contenuto}, sostituisce i file sul disco;
    [solo], un insieme di carte, restringe i controlli a quelle carte e
    pretende che ognuna esca intera nella forma nuova (e' il controllo
    delle parti); [forma_nuova] None vuol dire: in vigore se titoli.md o
    cosa_fare.md portano un testo.
    """
    f = Fonte()
    carte = f.carte = carte_del_mazzo()
    for dart, file, _ in POSIZIONI:
        percorso = os.path.join(FONTE, file + '.md')
        if not os.path.exists(percorso):
            raise FonteIncompleta('manca %s: lanciare con --prepara' %
                                  percorso)
        dati = leggi_file(percorso, VARIANTI, carte, testi)
        piene = colonne_piene(file + '.md', dati, VARIANTI, carte, True)
        f.conto[dart] = len(piene)
        for c in carte:
            for v in VERSI:
                if piene:
                    f.scheletri[(dart, c, v)] = [dati[(c, v)][k]
                                                 for k in piene]
    dati = leggi_file(REGISTRI, GRUPPI, carte, testi)
    pieni = colonne_piene('registri.md', dati, GRUPPI, carte, False)
    if pieni and pieni != list(GRUPPI):
        raise FonteIncompleta('registri.md: i gruppi pieni sono %s, ma un '
                              'registro vale solo coi tre gruppi' %
                              ', '.join(pieni))
    if pieni:
        for c in carte:
            for v in VERSI:
                f.registri[(c, v)] = [dati[(c, v)][g] for g in GRUPPI]
    # **I DUE FILE DELLA FORMA NUOVA.** Si leggono riga per riga: un file
    # intero e' pieno in tutte le righe o vuoto in tutte, ma nel controllo di
    # una parte conta solo che le carte della parte siano intere.
    for percorso in (TITOLI, COSA_FARE):
        if not os.path.exists(percorso) and not (
                testi and os.path.normcase(os.path.abspath(percorso))
                in testi):
            raise FonteIncompleta('manca %s: lanciare con --prepara' %
                                  percorso)
    tit = leggi_file(TITOLI, CHIAVI_DEI_TITOLI, carte, testi)
    cf = leggi_file(COSA_FARE, CHIAVI_DEL_COSA_FARE, carte, testi)
    for c in carte:
        for v in VERSI:
            for k in CHIAVI_DEI_TITOLI:
                if tit[(c, v)][k]:
                    f.titoli[(k, c, v)] = tit[(c, v)][k]
            for g in GRUPPI:
                varianti = [cf[(c, v)]['%s_%s' % (g, k)] for k in VARIANTI]
                if any(varianti):
                    f.cosa_fare[(c, v, g)] = [t for t in varianti if t]
    attesi_t = len(carte) * len(VERSI) * len(CHIAVI_DEI_TITOLI)
    attesi_c = len(carte) * len(VERSI) * len(CHIAVI_DEL_COSA_FARE)
    scritti_c = sum(len(x) for x in f.cosa_fare.values())
    f.titoli_pieni = len(f.titoli) == attesi_t
    f.cosa_fare_pieni = scritti_c == attesi_c
    f.forma_nuova = (bool(f.titoli or f.cosa_fare) if forma_nuova is None
                     else forma_nuova)
    if solo is None:
        if 0 < len(f.titoli) < attesi_t:
            f.colpe.append('titoli.md: %d titoli su %d; il file e\' pieno in '
                           'tutte le righe o vuoto in tutte' % (
                               len(f.titoli), attesi_t))
        if 0 < scritti_c < attesi_c:
            f.colpe.append('cosa_fare.md: %d testi su %d; il file e\' pieno '
                           'in tutte le righe o vuoto in tutte' % (
                               scritti_c, attesi_c))
    else:
        for c in carte:
            if c not in solo:
                continue
            for v in VERSI:
                for k in CHIAVI_DEI_TITOLI:
                    if not tit[(c, v)][k]:
                        f.colpe.append('titolo %s, %s, %s: da scrivere' % (
                            k, c, v))
                for k in CHIAVI_DEL_COSA_FARE:
                    if not cf[(c, v)][k]:
                        f.colpe.append('cosa fare %s, %s, %s: da scrivere' %
                                       (c, v, k.replace('_', ' ')))
    if f.forma_nuova and not f.registri:
        f.colpe.append('registri.md e\' vuoto: il paragrafo della forma nuova '
                       'e\' lo scheletro col registro')
    f.colpe += controlla(f.scheletri, f.registri, carte, f.titoli,
                         f.cosa_fare, solo, f.forma_nuova)
    return f


def leggi():
    """(scheletri, registri, conto) dalla fonte, controllati.

    scheletri: {(posizione, carta, verso): [variante, ...]} per le sole
    posizioni con almeno una variante piena; registri: {(carta, verso):
    [amore, lavoro, vita]}, vuoto se il file dei registri e' vuoto.
    """
    f = controlla_la_fonte()
    if f.colpe:
        raise FonteIncompleta('%d difetti nella fonte:\n%s' % (
            len(f.colpe), '\n'.join(f.colpe[:40])))
    return f.scheletri, f.registri, f.conto


# **IL PIANO DELLE RISCRITTURE**, ordine GA voce 07. Per ogni carta-verso
# i tre registri valgono in tutte e quindici le posizioni, quindi conviene
# sceglierne la fascia insieme agli scheletri: con i registri fra [basso] e
# [alto] parole ogni scheletro sta a misura con tutti e tre se ha da
# 40 - basso a 50 - alto parole. Si sceglie la fascia che costa meno parole
# da riscrivere, contando sedici parole per un registro e ventinove per uno
# scheletro, le loro medie di oggi.
PAROLE_DI_UN_REGISTRO = 16
PAROLE_DI_UNO_SCHELETRO = 29


def piano_della_carta(scheletri_della_carta, registri_della_carta):
    """La fascia dei registri e cosa riscrivere per una carta-verso.

    [scheletri_della_carta]: {(posizione, variante): testo};
    [registri_della_carta]: [amore, lavoro, vita]. Torna (basso, alto,
    registri da riscrivere [gruppo], scheletri da riscrivere [(posizione,
    variante)]).
    """
    r = [conta_parole(t) for t in registri_della_carta]
    s = {k: conta_parole(t) for k, t in scheletri_della_carta.items()}
    migliore = None
    for basso in range(6, 30):
        for alto in range(basso, basso + 11):
            da_r = [g for g, (m, p) in zip(GRUPPI, r)
                    if m < basso or p > alto]
            da_s = [k for k, (m, p) in s.items()
                    if m < 40 - basso or p > 50 - alto]
            costo = (len(da_r) * PAROLE_DI_UN_REGISTRO +
                     len(da_s) * PAROLE_DI_UNO_SCHELETRO)
            # A parita' di costo: meno scheletri, poi la fascia piu' larga,
            # poi la piu' vicina alle sedici parole di oggi.
            chiave = (costo, len(da_s), -(alto - basso),
                      abs((basso + alto) / 2.0 - 16))
            if migliore is None or chiave < migliore[0]:
                migliore = (chiave, basso, alto, da_r, sorted(da_s))
    return migliore[1:]


def piano_delle_riscritture(fonte):
    """{(carta, verso): (basso, alto, registri, scheletri)} sulla fonte.

    Agli scheletri fuori misura si aggiungono quelli che la forma nuova
    vieta per la lingua (un futuro in "-rai", un punto esclamativo, una
    forma col genere): vanno riscritti comunque.
    """
    piano = {}
    for c in fonte.carte:
        for v in VERSI:
            sch = {(pos, i): t for (pos, cc, vv), varianti in
                   fonte.scheletri.items() if cc == c and vv == v
                   for i, t in enumerate(varianti, 1)}
            basso, alto, da_r, da_s = piano_della_carta(
                sch, fonte.registri[(c, v)])
            lingua = sorted(k for k, t in sch.items()
                            if difetti_di_lingua(t) and k not in da_s)
            lingua_r = [g for g, t in zip(GRUPPI, fonte.registri[(c, v)])
                        if difetti_di_lingua(t) and g not in da_r]
            piano[(c, v)] = (basso, alto, da_r + lingua_r,
                             sorted(da_s + lingua))
    return piano


def stampa_la_misura(fonte):
    """Il rapporto di `--misura`: quante combinazioni stanno gia' a misura
    e quanti testi vanno riscritti o scritti."""
    misure = misura_dei_paragrafi(fonte.scheletri, fonte.registri)
    print('LA MISURA IN PAROLE DEL PARAGRAFO DELLA CARTA (scheletro + '
          'registro, %d-%d, ogni forma della marca)' % PAROLE_DEL_PARAGRAFO)
    # Una combinazione e' uno scheletro con un registro; uno scheletro e' a
    # misura quando lo e' con tutti e tre i registri.
    print('%-18s %12s %12s %24s' % ('posizione', 'combinazioni', 'a misura',
                                    'scheletri a misura coi 3'))
    tot_c = tot_m = tot_s = tot_n = 0
    for d, _, _ in POSIZIONI:
        mm = [(k, m) for k, m in misure.items() if k[0] == d]
        comb = sum(len(m) for _, m in mm)
        ok = sum(1 for _, m in mm for g in GRUPPI if a_misura(*m[g]))
        sch = sum(1 for _, m in mm if all(a_misura(*m[g]) for g in GRUPPI))
        tot_c += comb
        tot_m += ok
        tot_s += sch
        tot_n += len(mm)
        print('%-18s %12d %7d %3d%% %10d su %d' % (
            d, comb, ok, round(100.0 * ok / (comb or 1)), sch, len(mm)))
    print('%-18s %12d %7d %3d%% %10d su %d' % (
        'TOTALE', tot_c, tot_m, round(100.0 * tot_m / (tot_c or 1)), tot_s,
        tot_n))
    piano = piano_delle_riscritture(fonte)
    n_r = sum(len(p[2]) for p in piano.values())
    n_s = sum(len(p[3]) for p in piano.values())
    print()
    print('IL PIANO DELLE RISCRITTURE (fascia dei registri scelta per '
          'carta-verso)')
    print('registri da riscrivere: %d su %d' % (n_r, 3 * len(piano)))
    print('scheletri da riscrivere: %d su %d' % (n_s, tot_n))
    print('titoli scritti: %d su %d' % (
        len(fonte.titoli), len(fonte.carte) * 2 * len(CHIAVI_DEI_TITOLI)))
    print('cosa fare scritti: %d su %d' % (
        sum(len(x) for x in fonte.cosa_fare.values()),
        len(fonte.carte) * 2 * len(CHIAVI_DEL_COSA_FARE)))
    print('forma nuova in vigore: %s' % ('si\'' if fonte.forma_nuova
                                          else 'no'))


def dart(s):
    return "'" + s.replace('\\', '\\\\').replace("'", "\\'").replace(
        '$', '\\$') + "'"


def scrivi(scheletri, registri, titoli=None, cosa_fare=None):
    righe = dati_dart(scheletri, registri, titoli, cosa_fare)
    # Su Windows l'analizzatore tiene il file aperto per qualche istante
    # (errno 22 e 1224): si riprova per due minuti al massimo.
    dati = ('\n'.join(righe) + '\n').encode('utf-8')
    for _ in range(240):
        try:
            with open(USCITA, 'wb') as f:
                f.write(dati)
            with open(USCITA, 'rb') as f:
                if f.read() == dati:
                    return
        except OSError:
            pass
        time.sleep(0.5)
    raise OSError('non riesco a scrivere %s' % USCITA)


def _chiudi(righe, vuota):
    # Come la scrive dart format: una mappa vuota sta su una riga sola.
    if vuota:
        righe[-1] += '};'
    else:
        righe.append('};')


def dati_dart(scheletri, registri, titoli=None, cosa_fare=None):
    """Le righe del file Dart generato."""
    titoli = titoli or {}
    cosa_fare = cosa_fare or {}
    righe = [
        '// GENERATO da tool/genera_carte_nella_posizione.py da '
        'docs/corpus/tarocchi_posizione/: non toccare a mano.',
        '',
        '/// Le carte nella loro posizione, ordine EQ voce 04 esteso '
        'dall\'ordine FI.',
        '///',
        '/// La chiave e\' il nome della posizione come in `SpreadPosition`, '
        'il nome',
        '/// della carta come in `TarotCard.name` e il verso, `dritta` oppure',
        '/// `capovolta`, separati da una barra verticale. Il valore sono le '
        'varianti',
        '/// piene, da una a tre. Una posizione che non c\'e\' aspetta ancora '
        'i suoi',
        '/// testi.',
        'const Map<String, List<String>> scheletriDelleCarte = {',
    ]
    for dart_pos, _, _ in POSIZIONI:
        for chiave, varianti in scheletri.items():
            if chiave[0] != dart_pos:
                continue
            righe.append('  %s: [' % dart('|'.join(chiave)))
            for t in varianti:
                righe.append('    %s,' % dart(t))
            righe.append('  ],')
    righe += [
        '};',
        '',
        '/// I registri delle carte, il metodo di Dora (ordine FI voce 20): '
        'per',
        '/// carta e verso, di che cosa parla la carta in amore, nel lavoro e '
        'nel',
        '/// cammino, nell\'ordine di `TarotTopicGroup`. Vuoto finche\' la '
        'fonte',
        '/// non li porta.',
        'const Map<String, List<String>> registriDelleCarte = {',
    ]
    for chiave, gruppi in registri.items():
        righe.append('  %s: [' % dart('|'.join(chiave)))
        for t in gruppi:
            righe.append('    %s,' % dart(t))
        righe.append('  ],')
    _chiudi(righe, not registri)
    righe += [
        '',
        '/// **I TITOLI DELLE CARTE NELLA LORO POSIZIONE**, ordine GA voce 07: '
        'il',
        '/// titolo che a colpo d\'occhio e\' gia\' la risposta della carta in '
        'quel',
        '/// posto, uno per le tre varianti dello scheletro. La chiave e\' '
        'quella di',
        '/// [scheletriDelleCarte]. Vuoto finche\' la fonte non li porta.',
        'const Map<String, String> titoliDelleCarte = {',
    ]
    for dart_pos, _, _ in POSIZIONI:
        for chiave, t in titoli.items():
            if chiave[0] != dart_pos:
                continue
            riga = '  %s: %s,' % (dart('|'.join(chiave)), dart(t))
            if len(riga) <= 80:
                righe.append(riga)
            else:
                righe.append('  %s:' % dart('|'.join(chiave)))
                righe.append('      %s,' % dart(t))
    _chiudi(righe, not titoli)
    righe += [
        '',
        '/// **IL "COSA FARE ADESSO" DI OGNI CARTA**, ordine GA voce 07: per '
        'carta,',
        '/// verso e gruppo dell\'argomento (`amore`, `lavoro`, `vita`, i nomi '
        'di',
        '/// `TarotTopicGroup`), separati da una barra verticale, le tre '
        'varianti,',
        '/// che girano con le uscite come quelle dello scheletro. Vuoto '
        'finche\' la',
        '/// fonte non li porta.',
        'const Map<String, List<String>> cosaFareDelleCarte = {',
    ]
    for chiave, varianti in cosa_fare.items():
        righe.append('  %s: [' % dart('|'.join(chiave)))
        for t in varianti:
            righe.append('    %s,' % dart(t))
        righe.append('  ],')
    _chiudi(righe, not cosa_fare)
    return righe


TESTA_POSIZIONE = '''# {titolo}

{descrizione}

**Fonte da riempire.** Per ogni carta e per ogni verso tre varianti dello
stesso scheletro, `- 1:`, `- 2:`, `- 3:`, scritte dall'Architetto (ordine FI,
aggiunta A1 e A4). Una riga vuota e' un testo che non c'e' ancora. Una
variante e' piena in tutte le 156 carte-verso o vuota in tutte: a meta', il
tool si ferma e nomina le righe che mancano.

**Regole dei testi** (voce FI.23, le stesse del corpus del 27 settembre):
una o due frasi fra 110 e 280 caratteri, rivolte alla persona col tu. Ne' il
nome della carta ne' il suo verso. Nessuna parola che dia un genere a chi
legge, oppure la marca intera `[maschile|femminile|neutra]`. Niente cifre,
niente la parola voce, niente trattino lungo, mai una virgola seguita da "e"
o "ed", accenti veri. Nessuna previsione certa, solo tendenze; nessuna
promessa su salute, denaro, leggi o morte. Le tre varianti di una carta
cominciano con parole diverse; nessun doppione e nessuna coppia con
somiglianza di Jaccard sopra 0,6.

**Come si tocca.** Si riempie qui, poi si rilancia
`python tool/genera_carte_nella_posizione.py`, che controlla e scrive
`lib/core/tarot/le_carte_nella_posizione_dati.dart`.
'''

TESTA_REGISTRI = '''# I REGISTRI DELLE CARTE, il metodo di Dora (voce FI.20)

Per ogni carta e per ogni verso tre righe, una per gruppo dell'argomento
(`TarotTopicGroup`): `amore` (Amore e sentimenti), `lavoro` (Lavoro e
denaro), `vita` (Vita e cammino). Ogni riga dice di che cosa parla quella
carta in quell'ambito; il registro si sceglie dal gruppo dell'argomento che la
persona ha scelto, e non dipende dal modello.

**Fonte da riempire**, dall'Architetto (ordine FI, aggiunta A1 e A4). Un
gruppo e' pieno in tutte le 156 carte-verso o vuoto in tutte, e i registri
valgono solo coi tre gruppi pieni: a meta', il tool si ferma.

**Come si tocca.** Si riempie qui, poi si rilancia
`python tool/genera_carte_nella_posizione.py`.
'''


def prepara(carte, vecchio=None):
    """Crea i file della fonte che non ci sono; quanti ne ha creati.

    [vecchio] e' il corpus del 27 settembre letto per carta, verso e
    posizione: se c'e', diventa la variante 1 del passato, del presente e
    del futuro, con la sua provenienza scritta in testa.
    """
    if not os.path.isdir(FONTE):
        os.makedirs(FONTE)
    creati = 0
    for dart_pos, file, descrizione in POSIZIONI:
        percorso = os.path.join(FONTE, file + '.md')
        if os.path.exists(percorso):
            continue
        testa = TESTA_POSIZIONE.format(
            titolo='LA POSIZIONE: %s' % file.replace('_', ' ').upper(),
            descrizione=descrizione)
        if vecchio and dart_pos in ('passato', 'presente', 'futuro'):
            testa += PROVENIENZA
        righe = [testa]
        for c in carte:
            righe.append('## %s\n' % c)
            for v in VERSI:
                righe.append('### %s\n' % v)
                for k in VARIANTI:
                    t = ''
                    if vecchio and k == '1' and dart_pos in (
                            'passato', 'presente', 'futuro'):
                        t = vecchio[(c, v)][dart_pos]
                    righe.append(('- %s: %s' % (k, t)).rstrip())
                righe.append('')
        io.open(percorso, 'w', encoding='utf-8', newline='\n').write(
            '\n'.join(righe))
        creati += 1
    if not os.path.exists(REGISTRI):
        righe = [TESTA_REGISTRI]
        for c in carte:
            righe.append('## %s\n' % c)
            for v in VERSI:
                righe.append('### %s\n' % v)
                righe += ['- %s:' % g for g in GRUPPI]
                righe.append('')
        io.open(REGISTRI, 'w', encoding='utf-8', newline='\n').write(
            '\n'.join(righe))
        creati += 1
    for percorso, testa, chiavi in ((TITOLI, TESTA_TITOLI, CHIAVI_DEI_TITOLI),
                                    (COSA_FARE, TESTA_COSA_FARE,
                                     CHIAVI_DEL_COSA_FARE)):
        if os.path.exists(percorso):
            continue
        righe = [testa]
        for c in carte:
            righe.append('## %s\n' % c)
            for v in VERSI:
                righe.append('### %s\n' % v)
                righe += ['- %s:' % k for k in chiavi]
                righe.append('')
        io.open(percorso, 'w', encoding='utf-8', newline='\n').write(
            '\n'.join(righe))
        creati += 1
    return creati


TESTA_TITOLI = '''# I TITOLI DELLE CARTE NELLA LORO POSIZIONE (ordine GA voce 07)

Il fondatore, 19 ottobre 2026: "Restano all'inizio i titoli, anche per le
singola carte o le singole rune"; 3 settembre 2026: "un titolo che a colpo
d'occhio e' gia' una risposta diretta". Per ogni carta e per ogni verso un
titolo per ognuna delle quindici posizioni, coi nomi di `SpreadPosition`:
passato, presente, futuro, cartaSola, consultante, lato, esito, copre,
attraversa, corona, sotto, dietro, seStesso, laCasa, speranzeOTimori. Il
titolo dice a colpo d'occhio che cosa la carta dice in quel posto; vale
per le tre varianti dello scheletro della posizione.

**Regole** (controllate da `tool/genera_carte_nella_posizione.py`): da tre a
otto parole, al piu' settanta caratteri; niente due punti, punto e virgola,
punto di domanda, punto esclamativo o punto finale; la maiuscola in testa.
Ne' il nome della carta ne' il suo verso, niente cifre, niente trattino
lungo, niente la parola voce, mai una virgola seguita da "e" o "ed", accenti
veri, nessun futuro in "-rai", nessuna previsione certa, nessuna promessa su
salute, denaro, leggi o morte. Nessuna parola che dia un genere a chi legge,
oppure la marca intera `[maschile|femminile|neutra]`. Nessun titolo uguale a
un altro, in nessuna carta e in nessuna posizione.

**Come si tocca.** Il file e' pieno in tutte le righe o vuoto in tutte. Le
parti degli scrittori si rimettono qui con
`python tool/unisci_le_parti_dei_tarocchi.py`; poi
`python tool/genera_carte_nella_posizione.py` controlla e scrive il Dart.
'''

TESTA_COSA_FARE = '''# IL "COSA FARE ADESSO" DI OGNI CARTA (ordine GA voce 07)

Il fondatore, 19 ottobre 2026: "il secondo messo in evidenza in un riquadro e
questo riquadro deve intitolarsi "cosa fare adesso" e di conseguenza adattare
il testo"; "L'utente deve avere una risposta o una guida, deve sapere cosa
fare o non fare". Per ogni carta e per ogni verso tre varianti per ognuno dei
tre gruppi dell'argomento (`TarotTopicGroup`): `amore_1`, `amore_2`,
`amore_3` (Amore e sentimenti), `lavoro_1` ... (Lavoro e denaro), `vita_1`
... (Vita e cammino). Il gruppo e' quello dell'argomento che la persona ha
scelto prima della stesa; la variante gira con le uscite della carta, come
quella dello scheletro.

**Regole** (controllate da `tool/genera_carte_nella_posizione.py`): fra
quaranta e cinquanta parole contate separate da uno spazio, in ognuna delle
tre forme della marca; rivolte alla persona col tu; dicono che cosa fare o
non fare adesso, con un gesto concreto che viene dal significato della carta
in quel verso. Ne' il nome della carta ne' il suo verso, niente cifre,
niente trattino lungo, niente la parola voce, niente punto esclamativo, mai
una virgola seguita da "e" o "ed", accenti veri, nessun futuro in "-rai",
nessuna previsione certa, nessuna promessa su salute, denaro, leggi o morte.
Nessuna parola che dia un genere a chi legge, oppure la marca intera
`[maschile|femminile|neutra]`. Le tre varianti di un gruppo cominciano con
parole diverse; nessun doppione e nessuna coppia con somiglianza di Jaccard
sopra 0,6 fra i testi della stessa carta-verso (scheletri compresi) e fra
quelli dello stesso gruppo.

**Come si tocca.** Il file e' pieno in tutte le righe o vuoto in tutte. Le
parti degli scrittori si rimettono qui con
`python tool/unisci_le_parti_dei_tarocchi.py`; poi
`python tool/genera_carte_nella_posizione.py` controlla e scrive il Dart.
'''


PROVENIENZA = '''
**La variante 1 viene dal corpus del 27 settembre 2026** (ordine EQ voce 04,
`docs/corpus/tarocchi_nella_posizione.md` fino all'ordine FI): generata da
Gemini 2.5 Flash su Vertex AI in `europe-west1` coi controlli qui sopra, poi
riletta uno per uno, con 45 testi corretti a mano nella fonte. E' l'unica
parte del corpus dei tarocchi scritta da un modello; le varianti 2 e 3 le
scrive l'Architetto.
'''


def leggi_vecchio(percorso, carte):
    """Il corpus del 27 settembre: {(carta, verso): {posizione: testo}}."""
    testo = io.open(percorso, encoding='utf-8', newline='').read()
    dati = {}
    carta = verso = None
    for riga in testo.split('\n'):
        riga = riga.rstrip('\r')
        m = re.match(r'^## (.+)$', riga)
        if m:
            carta = m.group(1).strip()
            continue
        m = re.match(r'^### (dritta|capovolta)$', riga)
        if m:
            verso = m.group(1)
            dati[(carta, verso)] = {}
            continue
        m = re.match(r'^- (passato|presente|futuro): (.+)$', riga)
        if m:
            dati[(carta, verso)][m.group(1)] = m.group(2).strip()
    for c in carte:
        for v in VERSI:
            if len(dati.get((c, v), {})) != 3:
                raise ValueError('corpus vecchio: %s, %s incompleto' % (c, v))
    return dati


if __name__ == '__main__':
    if '--prepara' in sys.argv:
        carte = carte_del_mazzo()
        vecchio_file = os.path.join(RADICE, 'docs', 'corpus',
                                    'tarocchi_nella_posizione.md')
        vecchio = (leggi_vecchio(vecchio_file, carte)
                   if os.path.exists(vecchio_file) else None)
        print('file della fonte creati: %d' % prepara(carte, vecchio))
    try:
        fonte = controlla_la_fonte(
            forma_nuova=True if '--forma-nuova' in sys.argv else None)
    except FonteIncompleta as e:
        print('FONTE NON VALIDA, nessun file scritto.\n%s' % e)
        sys.exit(1)
    if '--misura' in sys.argv:
        # Il rapporto e basta: la misura in parole si guarda anche quando la
        # forma nuova non e' ancora in vigore; non si scrive niente.
        stampa_la_misura(fonte)
        sys.exit(0)
    if fonte.colpe:
        print('FONTE NON VALIDA, nessun file scritto.\n%d difetti nella '
              'fonte:\n%s' % (len(fonte.colpe), '\n'.join(fonte.colpe[:40])))
        sys.exit(1)
    scheletri, registri, conto = fonte.scheletri, fonte.registri, fonte.conto
    scrivi(scheletri, registri,
           fonte.titoli if fonte.titoli_pieni else None,
           fonte.cosa_fare if fonte.cosa_fare_pieni else None)
    testi = sum(len(v) for v in scheletri.values())
    pronte = [d for d, n in conto.items() if n == 3]
    parziali = ['%s (%d)' % (d, n) for d, n in conto.items() if 0 < n < 3]
    attese = [d for d, n in conto.items() if n == 0]
    print('scheletri %d su %d; registri %d su %d' % (
        testi, len(POSIZIONI) * 156 * 3, len(registri) * 3, 156 * 3))
    print('posizioni con le tre varianti: %d %s' % (len(pronte), pronte))
    print('posizioni con una parte delle varianti: %d %s' % (
        len(parziali), parziali))
    print('posizioni che aspettano i testi: %d %s' % (len(attese), attese))
    print('titoli %d su %d; cosa fare %d su %d; forma nuova in vigore: %s' % (
        len(fonte.titoli), len(fonte.carte) * 2 * len(CHIAVI_DEI_TITOLI),
        sum(len(x) for x in fonte.cosa_fare.values()),
        len(fonte.carte) * 2 * len(CHIAVI_DEL_COSA_FARE),
        'si\'' if fonte.forma_nuova else 'no'))
    sys.exit(0)
