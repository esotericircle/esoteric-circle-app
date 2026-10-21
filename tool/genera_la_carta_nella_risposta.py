# -*- coding: utf-8 -*-
"""LA CARTA NELLA RISPOSTA, I TESTI SCRITTI. Ordine GA voce GA.06, 21 ottobre
2026.

Il lettore cieco indipendente ha letto la risposta di casa dei Tarocchi
composta a frammenti e l'ha trovata cucita: "aggiunge un gesto" in 27
responsi su 40, "All'esito c'e' X, cioe' Y" in 19, motivazioni che non
motivano ("si', perche' Re di Coppe indica che serve calma emotiva"), la
posizione della carta ignorata. Da qui i testi si SCRIVONO: per ogni
carta-verso, cio' che la carta dice quando risponde (al centro della stesa o
in fondo) e cio' che aggiunge quando sta accanto, in ognuno dei sette ruoli
che una posizione puo' avere. Li scrivono gli scrittori (agenti di Code, mai
un modello a pagamento), ognuno sulle sue carte, in un file a parte; questo
strumento li controlla e scrive il Dart.

La fonte sta in docs/corpus/tarocchi_risposta/:

- `carte_*.md`: le carte, `## Il Matto`, i versi `### dritta`, `### capovolta`
  e per ogni verso le righe `- risposta_ora:`, `- risposta_esito:`,
  `- nota_ora:`, `- nota_passato:`, `- nota_esito:`, `- nota_ostacolo:`,
  `- nota_influenza:`, `- nota_ambiente:`, `- nota_timori:`;
- `gesti.md`: i gesti della domanda per tono, `## <situazione o lente>`,
  `### favorevole` (e `condizionato`, `sfavorevole`), righe `- azione_1:`,
  `- azione_2:`, `- azione_3:`, `- non_1:`, `- non_2:`.

**Ogni testo della carta e' un PREDICATO**: comincia col verbo, in minuscolo,
senza punto in fondo, e la voce gli mette davanti la posizione e il nome
della carta ("In fondo alla stesa, il Due di Coppe rovesciato" + "segnala un
malinteso..."). Le misure: risposta da 16 a 22 parole, nota da 7 a 11. I
gesti sono frasi intere: azione da 10 a 18 parole, cosa da non fare da 7 a 13
parole e comincia con "Non".

    python tool/genera_la_carta_nella_risposta.py --controlla <file.md> [...]
    python tool/genera_la_carta_nella_risposta.py

Con `--controlla` controlla i file dati e non scrive niente. Senza, legge
tutta la fonte, si ferma se manca una carta-verso o un gesto o se c'e' un
difetto, e scrive lib/core/tarot/la_carta_nella_risposta_scritta.dart.
"""
import io
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import genera_carte_nella_posizione as g  # noqa: E402

RADICE = g.RADICE
FONTE = os.path.join(RADICE, 'docs', 'corpus', 'tarocchi_risposta')
USCITA = os.path.join(RADICE, 'lib', 'core', 'tarot',
                      'la_carta_nella_risposta_scritta.dart')

RUOLI = ('ora', 'passato', 'esito', 'ostacolo', 'influenza', 'ambiente',
         'timori')
CHIAVI_DELLA_CARTA = (['risposta_ora', 'risposta_esito'] +
                      ['nota_%s' % r for r in RUOLI] + ['gesto'])
PAROLE_DELLA_RISPOSTA = (16, 22)
PAROLE_DELLA_NOTA = (7, 11)
# Il gesto della carta e' una frase intera, all'imperativo col tu, che vale
# per qualunque domanda: entra nel "Cosa fare adesso" accanto ai gesti della
# domanda, senza formule che lo presentino.
PAROLE_DEL_GESTO_DELLA_CARTA = (10, 16)
TONI = ('favorevole', 'condizionato', 'sfavorevole')
CHIAVI_DEI_GESTI = ('azione_1', 'azione_2', 'azione_3', 'non_1', 'non_2')
PAROLE_DELL_AZIONE = (10, 18)
PAROLE_DEL_NON = (7, 13)

# Le situazioni e le lenti di `lib/core/tarot/la_domanda_letta.dart`, piu' la
# domanda vaga: i gruppi dei gesti.
GRUPPI_DEI_GESTI = (
    'colloquio esame promozione offerta lasciareIlLavoro attivita progetto '
    'capo ritorno fiducia sentimenti dichiararsi coppia distanza incontro '
    'pace figli genitori famigliaDiLui trasferimento casa amicizia studi '
    'attesa stallo cambiamento '
    'amoreQuadro scegliereTraDue lavoroTrovare denaro affare momentoCheVivo '
    'bivio famiglia amiciziaLente progettoLente vaga'
).split()

# Il lessico delle figure di `lib/core/tarot/figure_della_stesa.dart`: la
# stessa immagine in due pezzi dello stesso responso e' il difetto
# dell'ordine DS voce 09, e i testi della voce non ne portano nessuna.
FIGURE = [re.compile(p) for p in (
    r'\b(mur[oi]|ostacol[oi])\b', r'\b(nod[oi]|sciogli\w*|sciolt[aoie])\b',
    r'\b(strad[ae])\b', r'\b(pass[oi])\b', r'\b(passaggi[oi]?)\b',
    r'\b(terren[oi])\b', r'\b(rott[ae])\b', r'\b(vent[oi])\b',
    r'\b(granell[oi])\b', r'\b(fran[ae])\b', r'\b(intopp[oi])\b',
    r'\b(traguard[oi])\b', r'\b(fren[oia]|frenare)\b', r'\b(sogli[ae])\b',
    r'\b(pont[ei])\b', r'\b(sem[ei])\b', r'\b(radic[ei])\b',
    r'\b(luc[ei])\b', r'\b(ombr[ae])\b', r'\b(nebbi[ae])\b',
    r'\b(fuoc[oh]i?)\b', r'\b(chiav[ei])\b', r'\b(pes[oi])\b')]

NON_FUTURI = {'però', 'perciò', 'già', 'concrete', 'discrete', 'segrete',
              'pareti', 'rete'}
FUTURO = re.compile(r'(?<![%s])([%s]+(?:rò|rà|rai|remo|rete|ranno))'
                    r'(?![%s])' % (g.LETTERE, g.LETTERE, g.LETTERE), re.I)
VIETATE = re.compile(r'(?<![%s])(cioè|sì|tendenza|sentenza|destino)'
                     r'(?![%s])' % (g.LETTERE, g.LETTERE), re.I)


def parole(t):
    return len(t.split())


def difetti_del_testo(dove, t, carta=None):
    colpe = []
    basso = t.lower()
    if not t.strip():
        return ['%s: vuoto' % dove]
    if re.search(r'\d', t):
        colpe.append('una cifra')
    if '—' in t or '–' in t:
        colpe.append('il trattino lungo')
    if re.search(r'\bvoce\b', basso):
        colpe.append('la parola voce')
    if re.search(r', (e|ed) ', t):
        colpe.append('una virgola seguita da e')
    if '!' in t or '[' in t or '|' in t:
        colpe.append('un punto esclamativo o una marca')
    if carta and carta.lower() in basso:
        colpe.append('il nome della carta')
    if 'rovesciat' in basso or 'capovolt' in basso:
        colpe.append('il verso nominato')
    for m in FUTURO.finditer(t):
        if m.group(1).lower() not in NON_FUTURI:
            colpe.append('un futuro (%s)' % m.group(1))
    for f in g.forme_del_genere(t):
        colpe.append('il genere di chi legge (%s)' % f)
    for m in g.PRESUPPOSTI.finditer(t):
        colpe.append('una persona o un ruolo dato per scontato (%s)' %
                     m.group(1))
    for p in g.PROMESSE + g.CERTEZZE:
        if re.search(p, basso):
            colpe.append('una promessa o una certezza (%s)' %
                         re.search(p, basso).group(0))
    return ['%s: %s' % (dove, c) for c in colpe]


def difetti_del_predicato(dove, t, carta, misura):
    colpe = difetti_del_testo(dove, t, carta)
    n = parole(t)
    if not misura[0] <= n <= misura[1]:
        colpe.append('%s: %d parole, fuori da %d-%d' % ((dove, n) + misura))
    if t[:1] != t[:1].lower():
        colpe.append('%s: comincia in maiuscolo (e\' un predicato)' % dove)
    if t.rstrip().endswith(('.', '?')):
        colpe.append('%s: finisce col punto' % dove)
    if ':' in t:
        colpe.append('%s: i due punti (il verdetto li ha gia\')' % dove)
    for f in FIGURE:
        m = f.search(t.lower())
        if m:
            colpe.append('%s: la figura "%s"' % (dove, m.group(0)))
    m = VIETATE.search(t)
    if m:
        colpe.append('%s: la parola "%s"' % (dove, m.group(0)))
    return colpe


def difetti_del_gesto(dove, t, chiave):
    colpe = difetti_del_testo(dove, t)
    n = parole(t)
    misura = PAROLE_DEL_NON if chiave.startswith('non') else PAROLE_DELL_AZIONE
    if not misura[0] <= n <= misura[1]:
        colpe.append('%s: %d parole, fuori da %d-%d' % ((dove, n) + misura))
    if chiave.startswith('non') and not t.startswith('Non '):
        colpe.append('%s: la cosa da non fare non comincia con "Non"' % dove)
    if not t.rstrip().endswith('.'):
        colpe.append('%s: non finisce col punto' % dove)
    for f in FIGURE:
        m = f.search(t.lower())
        if m:
            colpe.append('%s: la figura "%s"' % (dove, m.group(0)))
    m = VIETATE.search(t)
    if m:
        colpe.append('%s: la parola "%s"' % (dove, m.group(0)))
    return colpe


def difetti_del_gesto_della_carta(dove, t, carta):
    colpe = difetti_del_testo(dove, t, carta)
    n = parole(t)
    misura = PAROLE_DEL_GESTO_DELLA_CARTA
    if not misura[0] <= n <= misura[1]:
        colpe.append('%s: %d parole, fuori da %d-%d' % ((dove, n) + misura))
    if t[:1] != t[:1].upper():
        colpe.append('%s: il gesto comincia in minuscolo (e\' una frase)' %
                     dove)
    if not t.rstrip().endswith('.'):
        colpe.append('%s: non finisce col punto' % dove)
    if t.startswith('Non '):
        colpe.append('%s: il gesto e\' una cosa da fare, non da non fare' %
                     dove)
    for f in FIGURE:
        m = f.search(t.lower())
        if m:
            colpe.append('%s: la figura "%s"' % (dove, m.group(0)))
    m = VIETATE.search(t)
    if m:
        colpe.append('%s: la parola "%s"' % (dove, m.group(0)))
    return colpe


def leggi_file(percorso):
    """{(sezione, sottosezione, chiave): testo} e le righe fuori posto."""
    dati, colpe = {}, []
    sez = sub = None
    for n, riga in enumerate(io.open(percorso, encoding='utf-8-sig')
                             .read().splitlines(), 1):
        if riga.startswith('## '):
            sez, sub = riga[3:].strip(), None
        elif riga.startswith('### '):
            sub = riga[4:].strip()
        elif riga.startswith('- '):
            m = re.match(r'- ([a-z_0-9]+): ?(.*)$', riga)
            if not m or sez is None or sub is None:
                colpe.append('%s riga %d: riga fuori posto' % (
                    os.path.basename(percorso), n))
                continue
            k = (sez, sub, m.group(1))
            if k in dati:
                colpe.append('%s riga %d: chiave ripetuta %s' % (
                    os.path.basename(percorso), n, k))
            dati[k] = m.group(2).strip()
    return dati, colpe


def controlla_carte(dati, carte_del_mazzo):
    colpe = []
    for (carta, verso, k), t in dati.items():
        dove = '%s, %s, %s' % (carta, verso, k)
        if carta not in carte_del_mazzo:
            colpe.append('%s: carta sconosciuta' % dove)
            continue
        if verso not in g.VERSI:
            colpe.append('%s: verso sconosciuto' % dove)
            continue
        if k not in CHIAVI_DELLA_CARTA:
            colpe.append('%s: chiave sconosciuta' % dove)
            continue
        if k == 'gesto':
            colpe += difetti_del_gesto_della_carta(dove, t, carta)
            continue
        misura = (PAROLE_DELLA_RISPOSTA if k.startswith('risposta')
                  else PAROLE_DELLA_NOTA)
        colpe += difetti_del_predicato(dove, t, carta, misura)
    # Le due risposte e le note della stessa carta-verso non si somigliano.
    per = {}
    for (carta, verso, k), t in dati.items():
        per.setdefault((carta, verso), []).append((k, t))
    for (carta, verso), testi in per.items():
        for i in range(len(testi)):
            for j in range(i + 1, len(testi)):
                s = g.jaccard(g.parole(testi[i][1]), g.parole(testi[j][1]))
                if s > g.JACCARD:
                    colpe.append('%s, %s: %s e %s si somigliano (%.2f)' % (
                        carta, verso, testi[i][0], testi[j][0], s))
    return colpe


def controlla_gesti(dati):
    colpe = []
    for (gruppo, tono, k), t in dati.items():
        dove = 'gesti %s, %s, %s' % (gruppo, tono, k)
        if gruppo not in GRUPPI_DEI_GESTI:
            colpe.append('%s: gruppo sconosciuto' % dove)
        if tono not in TONI:
            colpe.append('%s: tono sconosciuto' % dove)
        if k not in CHIAVI_DEI_GESTI:
            colpe.append('%s: chiave sconosciuta' % dove)
            continue
        colpe += difetti_del_gesto(dove, t, k)
    return colpe


def e_gesti(percorso):
    return os.path.basename(percorso).startswith('gesti')


def main(argv):
    carte = g.carte_del_mazzo()
    if argv and argv[0] == '--controlla':
        colpe = []
        for p in argv[1:]:
            dati, c = leggi_file(p)
            colpe += c
            colpe += controlla_gesti(dati) if e_gesti(p) else \
                controlla_carte(dati, carte)
            if not e_gesti(p):
                vuote = [k for k, t in dati.items() if not t]
                colpe += ['%s: da scrivere' % (k,) for k in vuote]
        for c in colpe:
            print(c)
        print('difetti: %d' % len(colpe))
        return 1 if colpe else 0
    tutte, gesti, colpe = {}, {}, []
    for nome in sorted(os.listdir(FONTE)):
        if not nome.endswith('.md'):
            continue
        p = os.path.join(FONTE, nome)
        dati, c = leggi_file(p)
        colpe += c
        bersaglio = gesti if e_gesti(p) else tutte
        for k, t in dati.items():
            if k in bersaglio:
                colpe.append('%s: chiave in due file' % (k,))
            bersaglio[k] = t
    colpe += controlla_carte(tutte, carte)
    colpe += controlla_gesti(gesti)
    for c in carte:
        for v in g.VERSI:
            for k in CHIAVI_DELLA_CARTA:
                if not tutte.get((c, v, k)):
                    colpe.append('%s, %s, %s: manca' % (c, v, k))
    for gr in GRUPPI_DEI_GESTI:
        for tono in TONI:
            for k in CHIAVI_DEI_GESTI:
                if not gesti.get((gr, tono, k)):
                    colpe.append('gesti %s, %s, %s: manca' % (gr, tono, k))
    if colpe:
        for c in colpe[:80]:
            print(c)
        print('difetti: %d, il Dart non si scrive' % len(colpe))
        return 1
    righe = [
        '// GENERATO da tool/genera_la_carta_nella_risposta.py da '
        'docs/corpus/tarocchi_risposta/: non toccare a mano.',
        '',
        '/// I testi scritti della carta nella risposta, ordine GA voce GA.06:',
        '/// la chiave e\' `nome|verso` (`dritta` o `capovolta`), poi la '
        'chiave del testo.',
        'const Map<String, Map<String, String>> testiDelleCarte = {',
    ]
    for c in carte:
        for v in g.VERSI:
            righe.append('  %s: {' % g.dart('%s|%s' % (c, v)))
            for k in CHIAVI_DELLA_CARTA:
                righe.append('    %s: %s,' % (g.dart(k),
                                              g.dart(tutte[(c, v, k)])))
            righe.append('  },')
    righe += ['};', '',
              '/// I gesti della domanda per tono: la chiave e\' '
              '`gruppo|tono`, poi la chiave del gesto.',
              'const Map<String, Map<String, String>> gestiDellaDomanda = {']
    for gr in GRUPPI_DEI_GESTI:
        for tono in TONI:
            righe.append('  %s: {' % g.dart('%s|%s' % (gr, tono)))
            for k in CHIAVI_DEI_GESTI:
                righe.append('    %s: %s,' % (g.dart(k),
                                              g.dart(gesti[(gr, tono, k)])))
            righe.append('  },')
    righe += ['};', '']
    io.open(USCITA, 'w', encoding='utf-8', newline='\n').write(
        '\n'.join(righe))
    print('scritto %s' % USCITA)
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
