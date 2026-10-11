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

`--prepara` crea i file della fonte che non ci sono, con le intestazioni e le
righe vuote; non riscrive mai un file che esiste gia'.
"""
import io
import os
import re
import sys
import time

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FONTE = os.path.join(RADICE, 'docs', 'corpus', 'tarocchi_posizione')
REGISTRI = os.path.join(FONTE, 'registri.md')
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


def leggi_file(percorso, chiavi, carte):
    """{(carta, verso): {chiave: testo o ''}} da un file della fonte.

    Pretende le 78 carte nell'ordine del mazzo, i due versi e tutte le
    righe delle [chiavi], anche vuote: una riga che non c'e' o che sta fuori
    posto ferma lo script.
    """
    testo = io.open(percorso, encoding='utf-8', newline='').read()
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


def controlla_testo(dove, t, carta):
    """I controlli di un testo solo; la lista dei difetti trovati."""
    colpe = []
    if not LUNGHEZZA[0] <= len(t) <= LUNGHEZZA[1]:
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


def controlla(scheletri, registri, carte):
    """I controlli sull'insieme: doppioni, somiglianza, prime parole."""
    colpe = []
    tutti = {}
    for (pos, carta, verso), varianti in scheletri.items():
        for i, t in enumerate(varianti, 1):
            dove = '%s, %s, %s, variante %d' % (pos, carta, verso, i)
            colpe += controlla_testo(dove, t, carta)
            if t in tutti:
                colpe.append('%s: doppione di %s' % (dove, tutti[t]))
            tutti[t] = dove
        prime = [t.split()[0].lower().strip(",.'") for t in varianti]
        if len(varianti) == 3 and len(set(prime)) < 3:
            colpe.append('%s, %s, %s: le tre varianti cominciano con la '
                         'stessa parola' % (pos, carta, verso))
    for (carta, verso), righe in registri.items():
        for g, t in zip(GRUPPI, righe):
            dove = 'registro %s, %s, %s' % (carta, verso, g)
            if t in tutti:
                colpe.append('%s: doppione di %s' % (dove, tutti[t]))
            tutti[t] = dove
    # Jaccard sopra 0,6: dentro la stessa posizione e fra le posizioni della
    # stessa carta-verso, dove due testi si incontrano davvero. Tutte le
    # coppie dei 7.956 testi sarebbero 31 milioni.
    gruppi = {}
    for (pos, carta, verso), varianti in scheletri.items():
        for i, t in enumerate(varianti, 1):
            voce = ('%s, %s, %s, variante %d' % (pos, carta, verso, i),
                    parole(t))
            gruppi.setdefault(('pos', pos), []).append(voce)
            gruppi.setdefault(('carta', carta, verso), []).append(voce)
    viste = set()
    for elenco in gruppi.values():
        for i in range(len(elenco)):
            for j in range(i + 1, len(elenco)):
                coppia = (elenco[i][0], elenco[j][0])
                if coppia in viste:
                    continue
                viste.add(coppia)
                s = jaccard(elenco[i][1], elenco[j][1])
                if s > JACCARD:
                    colpe.append('%s e %s: somiglianza %.2f' % (
                        coppia[0], coppia[1], s))
    return colpe


def leggi():
    """(scheletri, registri, conto) dalla fonte, controllati.

    scheletri: {(posizione, carta, verso): [variante, ...]} per le sole
    posizioni con almeno una variante piena; registri: {(carta, verso):
    [amore, lavoro, vita]}, vuoto se il file dei registri e' vuoto.
    """
    carte = carte_del_mazzo()
    scheletri = {}
    conto = {}
    for dart, file, _ in POSIZIONI:
        percorso = os.path.join(FONTE, file + '.md')
        if not os.path.exists(percorso):
            raise FonteIncompleta('manca %s: lanciare con --prepara' %
                                  percorso)
        dati = leggi_file(percorso, VARIANTI, carte)
        piene = colonne_piene(file + '.md', dati, VARIANTI, carte, True)
        conto[dart] = len(piene)
        for c in carte:
            for v in VERSI:
                if piene:
                    scheletri[(dart, c, v)] = [dati[(c, v)][k] for k in piene]
    dati = leggi_file(REGISTRI, GRUPPI, carte)
    pieni = colonne_piene('registri.md', dati, GRUPPI, carte, False)
    if pieni and pieni != list(GRUPPI):
        raise FonteIncompleta('registri.md: i gruppi pieni sono %s, ma un '
                              'registro vale solo coi tre gruppi' %
                              ', '.join(pieni))
    registri = {}
    if pieni:
        for c in carte:
            for v in VERSI:
                registri[(c, v)] = [dati[(c, v)][g] for g in GRUPPI]
    colpe = controlla(scheletri, registri, carte)
    if colpe:
        raise FonteIncompleta('%d difetti nella fonte:\n%s' % (
            len(colpe), '\n'.join(colpe[:40])))
    return scheletri, registri, conto


def dart(s):
    return "'" + s.replace('\\', '\\\\').replace("'", "\\'").replace(
        '$', '\\$') + "'"


def scrivi(scheletri, registri):
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
    # Come la scrive dart format: una mappa vuota sta su una riga sola.
    if not registri:
        righe[-1] += '};'
    else:
        righe.append('};')
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
    return creati


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
        scheletri, registri, conto = leggi()
    except FonteIncompleta as e:
        print('FONTE NON VALIDA, nessun file scritto.\n%s' % e)
        sys.exit(1)
    scrivi(scheletri, registri)
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
    sys.exit(0)
