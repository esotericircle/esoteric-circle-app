# -*- coding: utf-8 -*-
"""LE VOCI NEUTRE DELLE RUNE. Ordine GA voce GA.06, riapertura, 21 ottobre
2026.

Per le domande che non hanno un tipo nel corpus delle risposte dirette (la
giornata senza domanda, le domande aperte del Cerchio, le vaghe) e per la
scheda di una pietra quando nessuna coppia "come" sta nella misura, il
presagio sceglie le voci di PIETRA e CONSIGLIO (la scheda) e di RISPOSTA e
GESTO (il riquadro). Quei campi sono scritti per ogni domanda, e molte voci
presuppongono una situazione che la domanda non porta: "la persona
coinvolta", "il tuo capo", "una richiesta che rimandi", "la via e' aperta". Il
lettore cieco indipendente ha contato 21 schede su 34 col cosa fare slegato
dalla domanda e dalla propria risposta.

**Il consiglio segue il suo paragrafo, e il compositore li sceglieva in due
estrazioni separate.** Qui si decide quali voci stanno insieme:
- RISPOSTA e GESTO: la voce N con la voce N (lo stesso numero);
- PIETRA e CONSIGLIO: in meta' dei gruppi la voce N segue la N, nell'altra
  meta' l'ordine dei due elenchi non coincide (Fehu, Raidho, Hagalaz,
  Nauthiz, Isa, Algiz dritta, Dagaz, Othala...: nei primi giri le voci furono
  scritte e poi riordinate in modo indipendente). Allora a ogni PIETRA si
  accoppia il CONSIGLIO che le somiglia di piu' (le radici di parola che
  condividono, pesate per quanto sono rare), uno per uno, e solo se la
  somiglianza e' chiara.

Poi sceglie le coppie neutre: quelle in cui ne' l'una ne' l'altra presuppone
una persona, un evento, un tema o un futuro certo (le parole sono in
PRESUPPONE), meno quelle che una lettura ha escluso a mano
(`docs/corpus/rune/voci_non_neutre.txt`, una riga per voce con il motivo).

  python tool/genera_le_voci_neutre_delle_rune.py          scrive il generato
  python tool/genera_le_voci_neutre_delle_rune.py --stat   conta soltanto

Il generato e' `lib/core/rituals/le_voci_neutre.g.dart`, e la prova
`le_voci_neutre_delle_rune_test.dart` pretende che sia questo.
"""
import collections
import io
import math
import pathlib
import re
import sys

RADICE = pathlib.Path(__file__).resolve().parent.parent
CORPUS = RADICE / 'docs/corpus/rune'
USCITA = RADICE / 'lib/core/rituals/le_voci_neutre.g.dart'
ESCLUSE = CORPUS / 'voci_non_neutre.txt'

# (campo che si sceglie, campo che lo segue, accoppiamento per numero)
COPPIE = [('pietra', 'consiglio', False), ('risposta', 'gesto', True)]

PRESUPPONE = re.compile(
    r"(?<![a-zà-ÿ])(coinvolt\w*|l[’']altr[oa]|altra (persona|parte)|"
    r"altrui|persona interessata|capo|colleg\w*|partner|compagn[oa]|"
    r"figli\w*|genitor\w*|madre|padre|marit\w*|mogli\w*|"
    r"famigli\w*|fratell\w*|sorell\w*|parent\w*|lavor\w*|ufficio|progett\w*|"
    r"casa|denaro|soldi|conto|risparmi\w*|stipendi\w*|medic\w*|salute|"
    r"richiest\w*|propost\w*|offert\w*|invit\w*|trattativ\w*|contratt\w*|"
    r"scadenz\w*|rimandat\w*|rimandi|rimandare|da troppo tempo|"
    r"ti ha (dato|detto|aiutat\w*|offert\w*)|hai (rifiutat\w*|promess\w*|"
    r"tenut\w* in gola|lasciat\w* cadere|già (fatto|detto|dato))|"
    r"ultima volta|ultimi giorni|di recente|tempo fa|"
    r"confessa\w*|dichiara\w*|annunci\w*|"
    r"questione|colpo|provocazion\w*|decisione|decidere|"
    r"decidi|conversazion\w*|parlane|"
    r"discussion\w*|litig\w*|conflitt\w*|torto|colpa|perdon\w*|"
    r"promessa|promesso|debito|ricambi\w*|"
    r"esame|colloquio|eredit\w*|discordia|equivoc\w*|"
    r"sta finendo|è aperta|si consolida|arriverà|arriveranno|tornerà|"
    r"riceverai|otterrai|avrai|vedrai|incontrerai|ritroverai|accadrà|"
    r"succederà|troverai|sarà|saranno|diventerà|maturerà|"
    r"porterà|darà)(?![a-zà-ÿ])", re.I)

# **I DIVIETI CHE NESSUN LIVELLO LASCIA CADERE.** Il conflitto e l'avversario
# che una domanda non porta (lettura severa del terzo giro: "senza rivalsa",
# "se ti provocano", "chi colpisce per primo"), un fastidio o un disagio dati
# per presenti, e un fatto del passato dato per vero ("hai cominciato con
# slancio", "hai trascurato", "hai lasciato a meta'": il lettore cieco legge
# "presuppone"). Le liste di sopra si allargano quando un gruppo resta con
# meno di SOGLIA coppie; questa no.
DURO = re.compile(
    r"(?<![a-zà-ÿ])(ripicc\w*|rimprover\w*|rivalsa|rabbia|arrabbi\w*|"
    r"irritazion\w*|alza(re|no)? (la voce|il tono)|provoc\w*|accus\w*|"
    r"nemic\w*|avversar\w*|rival\w*|per primo|prima mossa|respingend\w*|"
    r"appartiene ad altri|fastidi\w*|disagi\w*|è perduto|rancor\w*|astio|"
    r"livore|risentiment\w*|"
    r"si è solo fermato|trascur\w*|abbandonat\w*|messo da parte|"
    r"messa da parte|lasciat[oa] a metà|dimenticat\w*|fatto nascere|"
    r"avevi|non hai voluto|giorni scorsi|settimane scorse|"
    r"ultimi (giorni|mesi|anni)|"
    r"hai (cominciato|lasciato|trascurato|chiuso|seguito|saltato|dimenticato|"
    r"scordato|preso|trattenuto|detto|dato|speso|tenuto|corretto|"
    r"considerato|raggiunto|camminato|scelto|preparato|piantato|coltivato|"
    r"curato|visto|trovato|superato|attraversato|imparato|accumulato|usato|"
    r"ottenuto|promesso|rifiutato|ricevuto|rimandato|evitato|cercato|perso|"
    r"perduto))(?![a-zà-ÿ])", re.I)

# **I FATTI E LE PERSONE PRECISE**, che una domanda non porta: qualcuno che
# insiste, un messaggio, una lettera, una critica, un rifiuto, una porta
# sbattuta, una scossa, un pettegolezzo. Una pietra puo' dire "un ostacolo" o
# "una fretta che ferisce" a chiunque; non puo' dire "qualcuno sfiora il tuo
# confine e tu fingi di non accorgertene".
SPECIFICI = re.compile(
    r"(?<![a-zà-ÿ])(qualcuno|qualcun altro|chiunque|persone che|persona che|"
    r"chi ti (sta|vuole|stima|ha|è|chiede|porta|parla|segue|offre)|"
    r"chi (ha|può|sa) |messagg\w*|lettera|mail|chiamat\w*|telefonat\w*|"
    r"gruppo|documenti|segnale che aspetti|evento|scoss\w*|critic\w*|"
    r"rifiut\w*|sbattut\w*|chiusa|pettegol\w*|voci|ti vuole bene|"
    r"dimostrato|affront\w*|offes\w*|offender\w*|scus\w*|"
    r"perdit\w*|promesse|accordo|patto|incontro|riunione|cena|vicin[oi]|"
    r"bussa|bussare|ringrazi\w*|grazie)(?![a-zà-ÿ])", re.I)

# Sotto questa soglia la stretta lascia un gruppo con troppe poche voci per i
# sessanta giorni: Ehwaz e Othala sono le rune dell'alleanza e dell'eredita',
# e il loro senso nomina sempre qualcuno. Allora vale la regola larga, e se
# nemmeno quella basta, tutte le voci meno quelle escluse a mano.
SOGLIA = 5

LARGA = re.compile(
    r"(?<![a-zà-ÿ])(coinvolt\w*|l[’']altra (persona|parte)|"
    r"persona interessata|capo|colleg\w*|ufficio|"
    r"richiest\w*|rimandat\w*|rimandi|da troppo tempo|"
    r"ti ha (dato|detto|aiutat\w*|offert\w*)|hai (rifiutat\w*|promess\w*|"
    r"tenut\w* in gola|lasciat\w* cadere)|ultima volta|"
    r"sta finendo|è aperta|si consolida|arriverà|arriveranno|tornerà|"
    r"riceverai|otterrai|avrai|vedrai|incontrerai|ritroverai|accadrà|"
    r"succederà|troverai|sarà|saranno|diventerà)(?![a-zà-ÿ])", re.I)

class _Unione:
    """Piu' espressioni: vale se una qualunque combacia."""

    def __init__(self, *regole):
        self.regole = regole

    def search(self, testo):
        for r in self.regole:
            m = r.search(testo)
            if m:
                return m
        return None


# **LA PAURA CHE UNA DOMANDA NON PORTA** ("Fai oggi la cosa che temi", "senza
# l'ansia di risolvere"): il lettore cieco del terzo giro ha letto una paura
# di non farcela sotto un colloquio che non la nominava. Le coppie che la
# danno per presente restano fuori finche' ne restano abbastanza.
PAURA = re.compile(
    r"(?<![a-zà-ÿ])(paur[a-zà-ÿ]*|timor[a-zà-ÿ]*|ansi[a-zà-ÿ]*|temi|temere|"
    r"angosc[a-zà-ÿ]*|panic[a-zà-ÿ]*|spavent[a-zà-ÿ]*)(?![a-zà-ÿ])", re.I)

RIGOROSA = _Unione(PRESUPPONE, SPECIFICI, DURO)
RIGOROSA_SENZA_PAURA = _Unione(PRESUPPONE, SPECIFICI, DURO, PAURA)
MEDIA = _Unione(SPECIFICI, LARGA, DURO)
SOLO_DURO = _Unione(LARGA, DURO)

STOP = set('''di a da in con su per tra fra il lo la i gli le un uno una e ed o
ma che non si ti tuo tua tuoi tue come più piu del della dei delle al alla ai
alle nel nella è sei se poi già gia anche solo ogni cui questo questa quel
quella ciò cosa cose prima dopo mentre quando dove senza sul sulla ancora
dentro verso tutto tutti tutte molto quanto quante stesso stessa oggi giorno
giorni settimana runa dritta rovesciata ombra pietra'''.split())


def leggi(campo):
    testo = io.open(CORPUS / f'{campo}.md', encoding='utf-8').read()
    out = {}
    for m in re.finditer(r'^## (.+?)\n(.*?)(?=^## |\Z)', testo, re.S | re.M):
        gruppo = m.group(1).strip().replace(', in ombra', '/ombra').replace(
            ', dritta', '/dritta')
        # **L'INDICE E' L'ETICHETTA DELLA VOCE, non la posizione fra quelle
        # scritte**: l'Architetto lascia dei numeri senza testo (le voci da
        # scrivere, o tolte), anche in mezzo al gruppo, e il codice legge la
        # voce N dal numero N. Contare solo le righe con un testo spostava ogni
        # voce dopo un buco, e accoppiava un RISPOSTA con un GESTO che non era
        # il suo (riapertura della voce GA.06, lettura dei sessanta giorni).
        voci = {}
        for riga in m.group(2).splitlines():
            r = re.match(r'^(\d+)\.\s?(.*)$', riga)
            if r:
                voci[int(r.group(1))] = r.group(2).rstrip()
        out[gruppo] = [voci.get(k, '') for k in range(1, max(voci, default=0) + 1)]
    return out


def escluse():
    """{(campo, gruppo, numero)}: le voci escluse a mano."""
    fuori = set()
    if not ESCLUSE.exists():
        return fuori
    for riga in io.open(ESCLUSE, encoding='utf-8').read().splitlines():
        riga = riga.strip()
        if not riga or riga.startswith('#'):
            continue
        # campo | Runa/verso | numero | motivo
        parti = [p.strip() for p in riga.split('|')]
        fuori.add((parti[0], parti[1], int(parti[2])))
    return fuori


def ripete(a, b, k=5):
    """La seconda voce ripete la prima: condividono una frase di [k] parole
    consecutive (confrontate per le prime cinque lettere). Il lettore cieco
    del terzo giro ha letto un cosa fare che copiava il suo paragrafo
    ("Perthro": "sceglilo con cura" e poi "Scegli con cura la prima mossa").
    """
    def parole(x):
        return [w[:5] for w in re.findall(r"[a-zà-ÿ]+",
                                          x.lower().replace('{cosa}', ' '))]

    ra, rb = parole(a), parole(b)
    ga = {tuple(ra[i:i + k]) for i in range(len(ra) - k + 1)}
    gb = {tuple(rb[i:i + k]) for i in range(len(rb) - k + 1)}
    return bool(ga & gb)


def radici(testo):
    testo = testo.replace('{cosa}', ' ')
    return {w[:6] for w in re.findall(r"[a-zà-ÿ]+", testo.lower())
            if len(w) > 3 and w not in STOP}


def accoppia(a, b):
    """{indice di a: indice di b}, 0-based, uno per uno: a ogni voce di a la
    voce di b con cui condivide piu' radici di parola rare. Se la voce dello
    stesso numero e' quasi altrettanto vicina, si tiene quella."""
    n = len(a)
    ra = [radici(x) for x in a]
    rb = [radici(x) for x in b]
    df = collections.Counter(w for s in ra + rb for w in s)
    idf = {w: math.log(2 * n / c) for w, c in df.items()}

    def punti(i, j):
        return sum(idf[w] for w in ra[i] & rb[j])

    candidati = []
    for i in range(n):
        tutti = sorted(((punti(i, j), j) for j in range(len(b))),
                       reverse=True)
        (p1, j1), (p2, _) = tutti[0], tutti[1]
        stesso = punti(i, i) if i < len(b) else 0
        if stesso >= 4 and stesso >= p1 - 1.0:
            candidati.append((stesso + 100, i, i))
        elif p1 >= 7 and p1 - p2 >= 1.5:
            candidati.append((p1, i, j1))
    usate, out = set(), {}
    for _, i, j in sorted(candidati, reverse=True):
        if j in usate or i in out:
            continue
        out[i] = j
        usate.add(j)
    return out


def coppie_grezze():
    """{campo: {gruppo: [(i, j)]}}, numeri da uno."""
    out = {}
    for primo, secondo, posizionale in COPPIE:
        a, b = leggi(primo), leggi(secondo)
        assert list(a) == list(b), f'{primo}/{secondo}: gruppi diversi'
        out[primo] = {}
        for g in a:
            n = max(len(a[g]), len(b[g]))
            a[g] += [''] * (n - len(a[g]))
            b[g] += [''] * (n - len(b[g]))
            m = ({i: i for i in range(n) if a[g][i].strip() and b[g][i].strip()}
                 if posizionale else accoppia(a[g], b[g]))
            out[primo][g] = [(i + 1, j + 1) for i, j in sorted(m.items())
                             if a[g][i].strip() and b[g][j].strip()]
    return out


def neutre(larghe=False):
    """{campo: {gruppo: [(i, j)]}}: le coppie neutre.

    Con [larghe] le coppie in piu' che la scelta usa SOLO quando la persona ha
    letto, nei sessanta giorni, tutte le strette del gruppo: tutte quelle che
    non portano i divieti duri, meno le strette. Meglio una voce che qui e li'
    puo' presupporre qualcosa che una voce gia' letta di recente: lo pretende
    la regola dei sessanta giorni (ordine EX voce 03), e l'ordine "prima le
    strette" la guardia `il_corpus_delle_rune_test`."""
    manuali = escluse()
    grezze = coppie_grezze()
    out = {}
    for primo, secondo, _ in COPPIE:
        a, b = leggi(primo), leggi(secondo)
        for g in a:
            n = max(len(a[g]), len(b[g]))
            a[g] += [''] * (n - len(a[g]))
            b[g] += [''] * (n - len(b[g]))
        out[primo] = {}
        for g, coppie in grezze[primo].items():

            def buoni(regola, senza_eco=False):
                return [
                    (i, j) for i, j in coppie
                    if (regola is None
                        or (not regola.search(a[g][i - 1])
                            and not regola.search(b[g][j - 1])))
                    and (primo, g, i) not in manuali
                    and not (senza_eco and ripete(a[g][i - 1], b[g][j - 1]))
                ]

            # Prima le coppie in cui il consiglio non copia il paragrafo; se
            # ne restano meno di SOGLIA, anche quelle che lo ripetono.
            scelte = buoni(RIGOROSA_SENZA_PAURA, senza_eco=True)
            if len(scelte) < SOGLIA:
                scelte = buoni(RIGOROSA_SENZA_PAURA)
            if len(scelte) < SOGLIA:
                scelte = buoni(RIGOROSA, senza_eco=True)
            if len(scelte) < SOGLIA:
                scelte = buoni(RIGOROSA)
            if len(scelte) < SOGLIA:
                scelte = buoni(MEDIA)
            if len(scelte) < SOGLIA:
                scelte = buoni(SOLO_DURO)
            if len(scelte) < SOGLIA:
                scelte = buoni(DURO)
            if larghe:
                prese = set(scelte)
                scelte = [c for c in buoni(DURO) if c not in prese]
            out[primo][g] = scelte
    return out


def main():
    dati = neutre()
    if '--stat' in sys.argv:
        for campo, gruppi in dati.items():
            tot = sum(len(v) for v in gruppi.values())
            minimo = min(len(v) for v in gruppi.values())
            print(f'{campo}: {tot} coppie neutre, al minimo {minimo} per gruppo')
        return 0
    righe = [
        '// GENERATO da tool/genera_le_voci_neutre_delle_rune.py: non '
        'modificare a mano.',
        '// Le coppie neutre dei campi PIETRA/CONSIGLIO e RISPOSTA/GESTO '
        '(ordine GA voce GA.06).',
        '',
        '/// Per campo (`pietra`, `risposta`) e gruppo `Runa/verso`, le coppie '
        '(numero della',
        '/// voce scelta, numero della voce che la segue), da uno, che non '
        'presuppongono',
        '/// una situazione.',
        'const Map<String, Map<String, List<(int, int)>>> leVociNeutre = {',
    ]
    for campo, gruppi in dati.items():
        righe.append(f"  '{campo}': {{")
        for g, coppie in gruppi.items():
            elenco = ', '.join(f'({i}, {j})' for i, j in coppie)
            righe.append(f"    '{g}': [{elenco}],")
        righe.append('  },')
    righe.append('};')
    righe += [
        '',
        "/// Le coppie in piu', usate solo quando la persona ha letto nei "
        'sessanta giorni',
        '/// tutte le coppie di [leVociNeutre] del gruppo (stessa forma).',
        'const Map<String, Map<String, List<(int, int)>>> '
        'leVociNeutreLarghe = {',
    ]
    for campo, gruppi in neutre(larghe=True).items():
        righe.append(f"  '{campo}': {{")
        for g, coppie in gruppi.items():
            elenco = ', '.join(f'({i}, {j})' for i, j in coppie)
            righe.append(f"    '{g}': [{elenco}],")
        righe.append('  },')
    righe.append('};')
    USCITA.write_text('\n'.join(righe) + '\n', encoding='utf-8', newline='')
    print(f'{USCITA.relative_to(RADICE)}: scritto')
    return 0


if __name__ == '__main__':
    sys.stdout.reconfigure(encoding='utf-8')
    sys.exit(main())
