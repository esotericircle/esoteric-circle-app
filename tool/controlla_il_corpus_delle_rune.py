# -*- coding: utf-8 -*-
"""IL CONTROLLO DEL CORPUS DELLE RUNE. Ordine EX voce 03, 2 ottobre 2026;
riscritto per l'ordine GA voce GA.07, 20 ottobre 2026.

Legge i campi in docs/corpus/rune/ e controlla le regole della specifica
(SPECIFICA.md, sezioni 2, 3 e 7) prima che il generatore li porti nel
codice: i gruppi, i numeri delle voci, le voci che servono, gli spazi
permessi per campo, la misura in PAROLE, le regole di lingua. Non cambia
nessun testo: stampa ogni voce che non passa col file, il gruppo e il numero.

LA MISURA DELL'ORDINE GA (voce GA.03): ogni paragrafo del responso ha da 40 a
50 parole, contate separate da uno spazio come le conta
`LaFormaDelResponso.parole` (lib/core/responsi/la_forma_del_responso.dart).
Gli spazi fra graffe si misurano con OGNI valore che l'app ci mette, letti
dal sorgente e non a memoria: `{cosa}` da
lib/core/rituals/il_presagio_dal_corpus.dart (le cose delle domande del
Cerchio, le famiglie di parole, "la tua giornata", "ciò che hai chiesto"),
`{gettata}`, `{posizione}` e `{glossa}` da lib/core/rituals/rune_cast.dart.
La marca del genere `[maschile|femminile|neutra]` si misura in tutte e tre le
forme.

I campi e le finestre (parole a spazi riempiti, con ogni valore):
- RISPOSTA: un solo `{cosa}`, da 20 a 28 parole riempite, cioe' da 19 a 22
  parole fuori dallo spazio. E' la prima meta' del paragrafo della risposta.
- VERDETTO: nessuno spazio, da 20 a 22 parole. E' la seconda meta'.
- RISPOSTA + VERDETTO, il paragrafo composto: da 40 a 50 parole per OGNI
  coppia (ogni verdetto puo' seguire ogni risposta: la famiglia che domina
  e il tono non dipendono solo dalla pietra che decide) e ogni valore.
- GESTO, il riquadro "Cosa fare adesso": da 40 a 50, al piu' un `{cosa}`
  (con lo spazio, da 39 a 44 parole fuori).
- LEGAME, l'approfondimento della Lunga: da 40 a 50, al piu' uno spazio
  (`{cosa}` o `{gettata}`, quest'ultima vale il nome della gettata del
  gruppo).
- PIETRA, il paragrafo della scheda di una runa: da 40 a 50, un solo
  `{cosa}` (da 39 a 44 parole fuori), niente `{glossa}` ne' `{posizione}`
  (la testata della scheda le mostra gia'); nomina la sua runa.
- CONSIGLIO, campo nuovo, il riquadro "Cosa fare adesso" della scheda: da 40
  a 50, nessuno spazio.

    python tool/controlla_il_corpus_delle_rune.py
        il corpus intero: i conti per campo, poi ogni difetto
    python tool/controlla_il_corpus_delle_rune.py --conti
        solo i conti per campo
    python tool/controlla_il_corpus_delle_rune.py --parte <campo> <parte.md>...
        una parte di uno scrittore, prima di consegnarla: controlla solo le
        voci della parte, i numeri contro il corpus e il paragrafo composto
        contro le voci del corpus gia' a misura

La cartella del corpus si cambia con CARTELLA_DEL_CORPUS (per le prove su una
copia); i sorgenti dell'app si leggono sempre dal repository.
"""
import itertools
import os
import pathlib
import re
import sys
from dataclasses import dataclass, field

RADICE = pathlib.Path(__file__).resolve().parent.parent
CARTELLA = pathlib.Path(os.environ.get('CARTELLA_DEL_CORPUS',
                                       RADICE / 'docs/corpus/rune'))
PRESAGIO = RADICE / 'lib/core/rituals/il_presagio_dal_corpus.dart'
GETTATE_DART = RADICE / 'lib/core/rituals/rune_cast.dart'
CATALOGO_DART = RADICE / 'lib/core/rituals/runes.dart'

RUNE = ['Fehu', 'Uruz', 'Thurisaz', 'Ansuz', 'Raidho', 'Kenaz', 'Gebo', 'Wunjo',
        'Hagalaz', 'Nauthiz', 'Isa', 'Jera', 'Eihwaz', 'Perthro', 'Algiz',
        'Sowilo', 'Tiwaz', 'Berkano', 'Ehwaz', 'Mannaz', 'Laguz', 'Ingwaz',
        'Dagaz', 'Othala']
SIMMETRICHE = {'Gebo', 'Hagalaz', 'Isa', 'Jera', 'Eihwaz', 'Sowilo', 'Ingwaz',
               'Dagaz'}
AETT = {r: ['Freyr', 'Hagal', 'Tyr'][i // 8] for i, r in enumerate(RUNE)}


@dataclass(frozen=True)
class Regola:
    spazi: frozenset          # gli spazi permessi
    quanti: tuple             # quanti spazi, il primo e l'ultimo numero
    finestra: tuple           # parole a spazi riempiti, con ogni valore
    nomina: bool = False      # nomina la sua runa (e nessun'altra)
    dove: str = ''            # dove sta a video


REGOLE = {
    'risposta': Regola(frozenset({'cosa'}), (1, 1), (20, 28), False,
                       'la risposta, prima meta\' (19-22 parole fuori dallo spazio)'),
    'verdetto': Regola(frozenset(), (0, 0), (20, 22), False,
                       'la risposta, seconda meta\''),
    'pietra': Regola(frozenset({'cosa'}), (1, 1), (40, 50), True,
                     'il paragrafo della scheda di una runa'),
    'legame': Regola(frozenset({'cosa', 'gettata'}), (0, 1), (40, 50), False,
                     'l\'approfondimento della Lunga'),
    'gesto': Regola(frozenset({'cosa'}), (0, 1), (40, 50), False,
                    'il riquadro "Cosa fare adesso" del responso'),
    'consiglio': Regola(frozenset(), (0, 0), (40, 50), False,
                        'il riquadro "Cosa fare adesso" della scheda di una runa'),
}
CAMPI = list(REGOLE)
# Il paragrafo composto: la risposta a video e' RISPOSTA + " " + VERDETTO
# (IlPresagioDalCorpus.componi).
COMPOSTI = [('risposta', 'verdetto', (40, 50))]

VIETATE = ['guarigion', 'guarir', 'salute', 'malatt', 'fertilit', 'longevit',
           'vittori', 'ricchezz', 'tesor', 'armi',
           # Il confine del responso (ordine S voce 17): niente salute,
           # denaro, legge. Solo le parole che non hanno un senso figurato:
           # "debito", "contratto", "legale" ("legale a mazzetti"), "per
           # forza" detto al negativo, "castigo" come la persona vive una
           # rinuncia, sono uscite al primo giro sul corpus di oggi come
           # falsi allarmi e non ci sono.
           'soldi', 'denar', 'investiment', 'prestit', 'stipend',
           'medic', 'farmac', 'terapi', 'diagnos', 'sintom',
           'avvocat', 'tribunal', 'denunc', 'querel']
ASTRI = ['pianet', 'zodiac', 'oroscop', 'astral', 'costellazion']
CERTEZZE = ['sicuramente', 'certamente', 'di certo', 'senza dubbio',
            'garantit', 'inevitabil']
MINACCE = ['maledi', 'sventur', 'morte', 'morir', 'sciagur', 'pagherai']
DICHIARA_LA_FONTE = ['il corpus', 'il sistema', "l'algoritmo", 'l’algoritmo']


# ---------------------------------------------------------------------------
# I valori degli spazi, dal sorgente
# ---------------------------------------------------------------------------

def _blocco(testo, inizio, apre, chiude):
    i = testo.index(inizio)
    j = testo.index(apre, i)
    k = testo.index(chiude, j)
    return testo[j:k]


def valori_di_cosa():
    """Ogni valore di `{cosa}`, dal compositore del presagio."""
    t = PRESAGIO.read_text(encoding='utf-8')
    valori = re.findall(r"'([^']+)'",
                        _blocco(t, '_coseDelleDomande =', '[', '];'))
    valori += re.findall(r"'\s*:\s*'([^']+)'",
                         _blocco(t, '_famiglie =', '{', '};'))
    corpo = t[t.index('static String cosaDellaDomanda'):]
    corpo = corpo[:corpo.index('\n  }\n')]
    valori += re.findall(r"return '([^']+)';", corpo)
    valori = list(dict.fromkeys(valori))
    # Il cardinale minimo: dodici cose delle domande, otto famiglie (due,
    # l'amore e il lavoro, uguali a quelle delle domande), la giornata e la
    # domanda non riconosciuta: venti valori diversi.
    if len(valori) < 20:
        sys.exit(f'valori di {{cosa}} letti dal sorgente: {len(valori)}, '
                 f'ne servono almeno 20: il sorgente e\' cambiato')
    return valori


def le_gettate():
    """id -> (nome come lo scrive l'app nello spazio, posizioni)."""
    t = GETTATE_DART.read_text(encoding='utf-8')
    out = {}
    for m in re.finditer(r"const GettataRune \w+ = GettataRune\((.*?)\n\);",
                         t, re.S):
        corpo = m.group(1)
        gid = re.search(r"id: '(\w+)'", corpo).group(1)
        nome = re.search(r"nome: '([^']+)'", corpo).group(1)
        pos = [(a, b or c) for a, b, c in re.findall(
            r"PosizioneGettata\('([^']*)',\s*(?:'([^']*)'|\"([^\"]*)\")\)",
            corpo)]
        # `{gettata}` vale `esito.gettata.nome.toLowerCase()`.
        out[gid] = (nome.lower(), pos)
    if set(out) != {'odino', 'norne', 'croce', 'telo'}:
        sys.exit(f'gettate lette dal sorgente: {sorted(out)}')
    return out


def il_catalogo():
    """Runa -> chiave, significato, riga dritta, riga d'ombra."""
    t = CATALOGO_DART.read_text(encoding='utf-8')
    out = {}
    t = t[t.index('const List<Rune> kElderFuthark'):]
    pezzi = re.split(r'\n  Rune\(', t)[1:]
    for corpo in pezzi:
        nome = re.search(r"name: '(\w+)'", corpo).group(1)

        def campo(nome):
            c = re.search(nome + r":\s*((?:'(?:[^'\\]|\\.)*'\s*)+)", corpo)
            if not c:
                return ''
            return ''.join(re.findall(r"'((?:[^'\\]|\\.)*)'", c.group(1))
                           ).replace("\\'", "'")
        out[nome] = {'chiave': campo('keyword'),
                           'significato': campo('meaning'),
                           'dritta': campo('upright'),
                           'ombra': campo('shadow')}
    return out


COSA = valori_di_cosa()
GETTATE = le_gettate()
GLOSSE = list(dict.fromkeys(g for _, pos in GETTATE.values() for _, g in pos))
POSIZIONI = list(dict.fromkeys(p for _, pos in GETTATE.values() for p, _ in pos))


def valori_dello_spazio(spazio, campo, gruppo):
    if spazio == 'cosa':
        return COSA
    if spazio == 'gettata':
        if campo == 'legame':
            return [GETTATE[gruppo.split('/')[0]][0]]
        return [n for n, _ in GETTATE.values()]
    if spazio == 'glossa':
        return GLOSSE
    if spazio == 'posizione':
        return POSIZIONI
    return ['']


# ---------------------------------------------------------------------------
# Le parole
# ---------------------------------------------------------------------------

def parole(testo):
    """Come `LaFormaDelResponso.parole`: separate da uno spazio."""
    return len(testo.split())


def le_forme_del_genere(voce):
    """Le tre forme della marca del genere, o un difetto."""
    t = voce.replace('[[', '\x01').replace(']]', '\x02')
    marche = re.findall(r'\[([^\[\]]*)\]', t)
    if not marche:
        return [voce], None
    for m in marche:
        if m.count('|') != 2:
            return [voce], f'marca del genere malformata "[{m}]"'
    forme = []
    for i in range(3):
        forme.append(re.sub(r'\[([^\[\]]*)\]', lambda m: m.group(1).split('|')[i],
                            t).replace('\x01', '[').replace('\x02', ']'))
    return forme, None


def la_misura(campo, gruppo, voce):
    """(minimo, massimo) delle parole con ogni valore degli spazi e ogni
    forma del genere."""
    forme, _ = le_forme_del_genere(voce)
    lo, hi = 10 ** 9, -1
    for f in forme:
        usati = re.findall(r'\{([a-z]+)\}', f)
        base = parole(re.sub(r'\{[a-z]+\}', ' ', f))
        # Uno spazio attaccato a una parola ("d{cosa}") non aggiunge una
        # parola nuova: si conta come la scrive l'app.
        attaccati = len(re.findall(r'\S\{[a-z]+\}|\{[a-z]+\}\S', f))
        if attaccati:
            combinazioni = itertools.product(
                *[valori_dello_spazio(s, campo, gruppo) for s in sorted(set(usati))])
            for c in combinazioni:
                pieno = f
                for s, v in zip(sorted(set(usati)), c):
                    pieno = pieno.replace('{' + s + '}', v)
                n = parole(pieno)
                lo, hi = min(lo, n), max(hi, n)
            continue
        mi = base + sum(min(parole(v) for v in valori_dello_spazio(s, campo, gruppo))
                        for s in usati)
        ma = base + sum(max(parole(v) for v in valori_dello_spazio(s, campo, gruppo))
                        for s in usati)
        lo, hi = min(lo, mi), max(hi, ma)
    return lo, hi


def parole_fuori(voce):
    forme, _ = le_forme_del_genere(voce)
    return max(parole(re.sub(r'\{[a-z]+\}', ' ', f)) for f in forme)


# ---------------------------------------------------------------------------
# Le regole di una voce
# ---------------------------------------------------------------------------

def difetti_di_misura(campo, gruppo, voce):
    r = REGOLE[campo]
    out = []
    usati = re.findall(r'\{([a-z]+)\}', voce)
    non = sorted(set(usati) - r.spazi)
    if non:
        out.append(f'spazio non permesso {non}')
    if not r.quanti[0] <= len(usati) <= r.quanti[1]:
        if r.quanti[0] == r.quanti[1]:
            out.append(f'{len(usati)} spazi, ne vuole esattamente {r.quanti[0]}')
        else:
            out.append(f'{len(usati)} spazi, al piu\' {r.quanti[1]}')
    lo, hi = la_misura(campo, gruppo, voce)
    a, b = r.finestra
    if lo < a or hi > b:
        out.append(f'{lo}-{hi} parole con i valori degli spazi, la finestra '
                   f'e\' {a}-{b} (fuori dagli spazi {parole_fuori(voce)})')
    return out


def difetti_di_lingua(campo, gruppo, voce):
    r = REGOLE[campo]
    out = []
    _, malformata = le_forme_del_genere(voce)
    if malformata:
        out.append(malformata)
    if '—' in voce or '–' in voce:
        out.append('trattino lungo')
    if re.search(r',\s+(e|ed)\s', voce, re.I):
        out.append('virgola prima di "e" o "ed"')
    if '!' in voce:
        out.append('punto esclamativo')
    if re.search(r'\d', voce):
        out.append('cifra')
    fut = [w for w in re.findall(r'\b(\w+rai)\b', voce.lower())
           if not w.endswith('trai')]
    if fut:
        out.append(f'futuro in -rai {fut}')
    basso = voce.lower()
    for p in VIETATE:
        if re.search(r'\b' + p, basso):
            out.append(f'parola vietata "{p}"')
    for p in ASTRI:
        if p in basso:
            out.append(f'astro "{p}"')
    for p in CERTEZZE:
        if re.search(r'\b' + p, basso):
            out.append(f'certezza "{p}"')
    for p in MINACCE:
        if re.search(r'\b' + p, basso):
            out.append(f'minaccia "{p}"')
    for p in DICHIARA_LA_FONTE:
        if p in basso:
            out.append(f'dichiara la fonte "{p}"')
    nominate = [x for x in RUNE if re.search(r'\b' + x + r'\b', voce)]
    if nominate and not r.nomina:
        out.append(f'nomina la runa {nominate}')
    if r.nomina:
        runa = gruppo.split('/')[0]
        if runa not in nominate:
            out.append(f'non nomina la sua runa {runa}')
        altre = [x for x in nominate if x != runa]
        if altre:
            out.append(f'nomina un\'altra runa {altre}')
    if re.search(r"\b(e|perche|poiche|cosi|gia|piu|puo|cio|pero|sara|"
                 r"verra|potra)'", basso):
        out.append('apostrofo al posto dell\'accento')
    if 'ascolta te stess' in basso:
        out.append('"ascolta te stesso"')
    # `{cosa}` porta il suo articolo ("il lavoro", "l’amore", "ciò che hai
    # chiesto"): dopo di, a, da, in, su l'app scriverebbe "di il lavoro"; e a
    # inizio di frase scriverebbe la minuscola.
    m = re.search(r'\b(di|a|da|in|su)\s+\{cosa\}', voce, re.I)
    if m:
        out.append(f'"{m.group(0)}": {{cosa}} ha gia\' l\'articolo, usa per, '
                   f'con, dentro, verso, sopra, fra')
    if re.search(r'(^|[.?]\s+)\{cosa\}', voce):
        out.append('{cosa} a inizio di frase: l\'app lo scrive minuscolo')
    return out


def difetti_della_voce(campo, gruppo, voce):
    return difetti_di_misura(campo, gruppo, voce) + \
        difetti_di_lingua(campo, gruppo, voce)


def frasi(voce):
    """Le frasi di almeno sei parole, per la regola "nessuna frase uguale"."""
    for f in re.split(r'[.?:;]\s+', voce):
        f = re.sub(r'[^\w{} ]', '', f.lower()).strip()
        if len(f.split()) >= 6:
            yield ' '.join(f.split())


# ---------------------------------------------------------------------------
# I file
# ---------------------------------------------------------------------------

def gruppo_da_titolo(campo, titolo):
    a, b = [x.strip() for x in titolo.split(',', 1)]
    if campo in ('risposta', 'pietra', 'gesto', 'consiglio'):
        return f"{a}/{'ombra' if b == 'in ombra' else 'dritta'}"
    return f'{a}/{b}'


def titolo_da_gruppo(campo, gruppo):
    a, b = gruppo.split('/')
    if campo in ('risposta', 'pietra', 'gesto', 'consiglio'):
        return f"{a}, {'in ombra' if b == 'ombra' else 'dritta'}"
    return f'{a}, {b}'


def gruppi_attesi(campo):
    if campo == 'verdetto':
        return [f'{t}/{f}' for t in ('luce', 'misto', 'ombra')
                for f in ('Freyr', 'Hagal', 'Tyr')]
    if campo == 'legame':
        return [f'{g}/{t}' for g in ('odino', 'norne', 'croce', 'telo')
                for t in ('luce', 'misto', 'ombra')
                if not (g == 'odino' and t == 'misto')]
    return [f'{r}/{v}' for r in RUNE for v in ('dritta', 'ombra')
            if not (v == 'ombra' and r in SIMMETRICHE)]


def leggi_il_campo(campo, percorso=None):
    """{gruppo: [voce, ...]} e i difetti di forma del file."""
    p = percorso or CARTELLA / f'{campo}.md'
    gruppi, g, difetti = {}, None, []
    if not p.exists():
        return gruppi, [f'{campo}.md: manca']
    for n_riga, riga in enumerate(p.read_text(encoding='utf-8').splitlines(), 1):
        t = re.match(r'^## (.+)$', riga)
        if t:
            g = gruppo_da_titolo(campo, t.group(1))
            if g in gruppi:
                difetti.append(f'{campo}.md riga {n_riga}: gruppo {g} ripetuto')
            gruppi[g] = []
            continue
        v = re.match(r'^(\d+)\.\s?(.*)$', riga)
        if not v or g is None:
            if riga.strip() and g is not None:
                difetti.append(f'{campo}.md riga {n_riga}: riga fuori forma')
            continue
        n = int(v.group(1))
        if n != len(gruppi[g]) + 1:
            difetti.append(f'{campo}.md, {g}, voce {n}: numero fuori fila')
        gruppi[g].append(v.group(2).rstrip())
    return gruppi, difetti


def leggi_le_voci_che_servono():
    out, campo = {}, None
    for r in (CARTELLA / 'le_voci_che_servono.txt').read_text(
            encoding='utf-8').splitlines():
        t = re.match(r'^([A-Z]+): \d+ gruppi', r)
        if t:
            campo = t.group(1).lower()
            out[campo] = {}
            continue
        v = re.match(r'^  (\S+) / (\S+): (\d+)$', r)
        if v and campo:
            out[campo][f'{v.group(1)}/{v.group(2)}'] = int(v.group(3))
    return out


def leggi_la_parte(campo, percorso):
    """{gruppo: {numero: testo}} di una parte; testo vuoto = voce tolta."""
    out, g = {}, None
    difetti = []
    for n_riga, riga in enumerate(pathlib.Path(percorso).read_text(
            encoding='utf-8').splitlines(), 1):
        t = re.match(r'^## (.+)$', riga)
        if t:
            try:
                g = gruppo_da_titolo(campo, t.group(1))
            except ValueError:
                difetti.append(f'{percorso} riga {n_riga}: titolo fuori forma')
                g = None
                continue
            if g not in gruppi_attesi(campo):
                difetti.append(f'{percorso} riga {n_riga}: il gruppo {g} non '
                               f'esiste nel campo {campo}')
            out.setdefault(g, {})
            continue
        v = re.match(r'^(\d+)\.\s?(.*)$', riga)
        if v and g is not None:
            n = int(v.group(1))
            if n in out[g]:
                difetti.append(f'{percorso}, {g}, voce {n}: numero ripetuto')
            out[g][n] = v.group(2).rstrip()
        elif riga.strip() and not riga.startswith('#') and g is not None:
            difetti.append(f'{percorso} riga {n_riga}: riga fuori forma '
                           f'(una voce e\' "N. testo" su una riga sola)')
    return out, difetti


# ---------------------------------------------------------------------------
# Il paragrafo composto
# ---------------------------------------------------------------------------

def misure_del_campo(campo, gruppi):
    return [(f'{campo}/{g}/{i + 1}', *la_misura(campo, g, v))
            for g, voci in gruppi.items() for i, v in enumerate(voci) if v]


def coppie_fuori(prime, seconde, finestra):
    """Le coppie (prima, seconda) fuori dalla finestra, con ogni valore."""
    a, b = finestra
    fuori = []
    for id1, lo1, hi1 in prime:
        for id2, lo2, hi2 in seconde:
            if lo1 + lo2 < a or hi1 + hi2 > b:
                fuori.append((id1, id2, lo1 + lo2, hi1 + hi2))
    return fuori


# ---------------------------------------------------------------------------
# Il corpus intero
# ---------------------------------------------------------------------------

def controlla_tutto(solo_conti=False):
    servono = leggi_le_voci_che_servono()
    difetti = []
    corpus = {}
    conti = {}
    for campo in CAMPI:
        gruppi, d = leggi_il_campo(campo)
        difetti += d
        corpus[campo] = gruppi
        attesi = set(gruppi_attesi(campo))
        if set(gruppi) != attesi:
            difetti.append(f'{campo}.md: gruppi mancanti '
                           f'{sorted(attesi - set(gruppi))}, in piu\' '
                           f'{sorted(set(gruppi) - attesi)}')
        piene = a_misura = di_lingua = 0
        per_gruppo = {}
        for g, voci in gruppi.items():
            buone = 0
            for i, voce in enumerate(voci):
                if not voce:
                    continue
                piene += 1
                dove = f'{campo}.md, {g}, voce {i + 1}'
                dm = difetti_di_misura(campo, g, voce)
                dl = difetti_di_lingua(campo, g, voce)
                if not dm:
                    a_misura += 1
                if dl:
                    di_lingua += 1
                if not dm and not dl:
                    buone += 1
                difetti += [f'{dove}: {x}' for x in dm + dl]
            per_gruppo[g] = buone
            serve = servono.get(campo, {}).get(g)
            piene_g = sum(1 for v in voci if v)
            if serve is not None and piene_g < serve:
                difetti.append(f'{campo}.md, {g}: {piene_g} voci, ne servono '
                               f'{serve}')
        if campo not in servono:
            difetti.append(f'le_voci_che_servono.txt: manca il campo {campo}')
        serve_tot = sum(servono.get(campo, {}).values())
        buone_utili = sum(min(per_gruppo.get(g, 0), n)
                          for g, n in servono.get(campo, {}).items())
        conti[campo] = dict(gruppi=len(gruppi), voci=piene, a_misura=a_misura,
                            con_difetti_di_lingua=di_lingua,
                            buone=sum(per_gruppo.values()), servono=serve_tot,
                            da_scrivere=serve_tot - buone_utili)
    # Il paragrafo composto.
    composti = []
    for c1, c2, fin in COMPOSTI:
        m1 = misure_del_campo(c1, corpus[c1])
        m2 = misure_del_campo(c2, corpus[c2])
        fuori = coppie_fuori(m1, m2, fin)
        composti.append((c1, c2, fin, len(m1) * len(m2), fuori))
        if fuori:
            difetti.append(f'paragrafo {c1.upper()} + {c2.upper()}: '
                           f'{len(fuori)} coppie su {len(m1) * len(m2)} fuori '
                           f'da {fin[0]}-{fin[1]} parole')
            for id1, id2, lo, hi in fuori[:20]:
                difetti.append(f'  {id1} + {id2}: {lo}-{hi} parole')
    # Nessuna voce uguale, nessuna frase uguale.
    viste, frasi_viste = {}, {}
    for campo in CAMPI:
        for g, voci in corpus[campo].items():
            for i, v in enumerate(voci):
                if not v:
                    continue
                vid = f'{campo}/{g}/{i + 1}'
                chiave = ' '.join(v.lower().split())
                if chiave in viste:
                    difetti.append(f'{vid}: voce uguale a {viste[chiave]}')
                viste.setdefault(chiave, vid)
                for f in frasi(v):
                    if f in frasi_viste and frasi_viste[f] != vid:
                        difetti.append(f'{vid}: frase uguale a {frasi_viste[f]}: '
                                       f'"{f}"')
                    frasi_viste.setdefault(f, vid)

    print('CAMPO       gruppi  voci  a misura  lingua  buone  servono  da scrivere')
    for campo, c in conti.items():
        print(f'{campo:<11} {c["gruppi"]:>6} {c["voci"]:>5} {c["a_misura"]:>9} '
              f'{c["con_difetti_di_lingua"]:>7} {c["buone"]:>6} '
              f'{c["servono"]:>8} {c["da_scrivere"]:>12}')
    for c1, c2, fin, tot, fuori in composti:
        print(f'paragrafo {c1} + {c2}: {tot - len(fuori)} coppie su {tot} '
              f'fra {fin[0]} e {fin[1]} parole')
    print('(a misura: spazi e parole nella finestra con ogni valore; lingua: '
          'voci con almeno un difetto di lingua; buone: a misura e senza '
          'difetti; da scrivere: quante voci buone mancano al fabbisogno dei '
          '60 giorni, gruppo per gruppo)')
    print(f'difetti: {len(difetti)}')
    if not solo_conti:
        for d in difetti:
            print('  ' + d)
    return (1 if difetti else 0), conti


# ---------------------------------------------------------------------------
# Una parte
# ---------------------------------------------------------------------------

def controlla_le_parti(campo, percorsi, stampa=True):
    """Controlla le parti di uno scrittore contro il corpus di oggi.
    Restituisce (difetti, parte unita, gruppi del corpus)."""
    if campo not in REGOLE:
        sys.exit(f'campo sconosciuto {campo}: uno di {", ".join(CAMPI)}')
    gruppi, d0 = leggi_il_campo(campo)
    difetti = list(d0)
    parte = {}
    for p in percorsi:
        pg, d = leggi_la_parte(campo, p)
        difetti += d
        for g, voci in pg.items():
            for n, testo in voci.items():
                if n in parte.get(g, {}):
                    difetti.append(f'{campo}, {g}, voce {n}: in due parti')
                parte.setdefault(g, {})[n] = testo
    toccate = 0
    for g, voci in parte.items():
        oggi = gruppi.get(g, [])
        nuovi = sorted(n for n in voci if n > len(oggi))
        attesi = list(range(len(oggi) + 1, len(oggi) + 1 + len(nuovi)))
        if nuovi != attesi:
            difetti.append(f'{campo}, {g}: le voci nuove sono {nuovi[:5]}..., '
                           f'devono partire da {len(oggi) + 1} e seguirsi '
                           f'senza buchi')
        for n, testo in sorted(voci.items()):
            dove = f'{campo}, {g}, voce {n}'
            if n < 1:
                difetti.append(f'{dove}: numero non valido')
                continue
            if n <= len(oggi) and not oggi[n - 1] and testo:
                difetti.append(f'{dove}: numero tolto, non si riusa')
            if n > len(oggi) and not testo:
                difetti.append(f'{dove}: una voce nuova non puo\' essere vuota')
            if not testo:
                continue
            toccate += 1
            difetti += [f'{dove}: {x}' for x in difetti_della_voce(campo, g, testo)]
    # Il paragrafo composto: ogni voce toccata con ogni voce dell'altro campo
    # gia' a misura (le altre si riscrivono: il controllo intero le
    # rimisura).
    for c1, c2, fin in COMPOSTI:
        if campo not in (c1, c2):
            continue
        altro = c2 if campo == c1 else c1
        ag, _ = leggi_il_campo(altro)
        buone = [(f'{altro}/{g}/{i + 1}', *la_misura(altro, g, v))
                 for g, voci in ag.items() for i, v in enumerate(voci)
                 if v and not difetti_di_misura(altro, g, v)]
        mie = [(f'{campo}/{g}/{n}', *la_misura(campo, g, t))
               for g, voci in parte.items() for n, t in voci.items() if t]
        fuori = coppie_fuori(mie, buone, fin) if campo == c1 else \
            [(b, a, lo, hi) for a, b, lo, hi in coppie_fuori(mie, buone, fin)]
        for id1, id2, lo, hi in fuori[:30]:
            difetti.append(f'paragrafo {c1} + {c2}: {id1} + {id2} fa {lo}-{hi} '
                           f'parole, la finestra e\' {fin[0]}-{fin[1]}')
        if len(fuori) > 30:
            difetti.append(f'paragrafo {c1} + {c2}: altre {len(fuori) - 30} coppie '
                           f'fuori misura')
    # Nessuna voce uguale e nessuna frase uguale, dentro la parte e contro il
    # corpus di tutti i campi (le voci che la parte sostituisce non contano).
    sostituite = {f'{campo}/{g}/{n}' for g, v in parte.items() for n in v}
    gia = {}
    for c in CAMPI:
        cg = gruppi if c == campo else leggi_il_campo(c)[0]
        for g, voci in cg.items():
            for i, v in enumerate(voci):
                vid = f'{c}/{g}/{i + 1}'
                if v and vid not in sostituite:
                    gia.setdefault(' '.join(v.lower().split()), vid)
                    for f in frasi(v):
                        gia.setdefault(('frase', f), vid)
    for g, voci in sorted(parte.items()):
        for n, t in sorted(voci.items()):
            if not t:
                continue
            vid = f'{campo}/{g}/{n}'
            k = ' '.join(t.lower().split())
            if k in gia:
                difetti.append(f'{vid}: voce uguale a {gia[k]}')
            gia.setdefault(k, vid)
            for f in frasi(t):
                if ('frase', f) in gia and gia[('frase', f)] != vid:
                    difetti.append(f'{vid}: frase uguale a {gia[("frase", f)]}: '
                                   f'"{f}"')
                gia.setdefault(('frase', f), vid)
    if stampa:
        print(f'{campo}: {len(parte)} gruppi, {toccate} voci scritte, '
              f'{sum(1 for v in parte.values() for t in v.values() if not t)} '
              f'tolte')
        print(f'difetti: {len(difetti)}')
        for d in difetti:
            print('  ' + d)
        if not difetti:
            print('la parte e\' a posto')
    return difetti, parte, gruppi


def main(argv):
    if argv[:1] == ['--parte']:
        if len(argv) < 3:
            sys.exit(__doc__)
        difetti, _, _ = controlla_le_parti(argv[1], argv[2:])
        return 1 if difetti else 0
    esito, _ = controlla_tutto(solo_conti=argv[:1] == ['--conti'])
    return esito


if __name__ == '__main__':
    sys.stdout.reconfigure(encoding='utf-8')
    sys.exit(main(sys.argv[1:]))
