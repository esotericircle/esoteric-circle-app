# -*- coding: utf-8 -*-
"""IL CONTROLLO DELLE RISPOSTE DIRETTE DELLE RUNE. Ordine GA voce GA.06, la
cura delle Rune di Caligo, 21 ottobre 2026.

Due campi nuovi del corpus, scritti per pietra (runa e verso) e per TIPO di
domanda, in docs/corpus/rune/:
- diretta.md, il paragrafo 1 del responso: la prima frase risponde alla
  domanda di quel tipo, dal senso di quella pietra in quel verso;
- azione.md, il riquadro "Cosa fare adesso": un'azione che si puo' fare,
  legata alla domanda, nel modo di quella pietra.

I tipi: decisione ("Devo...?"), scelta ("X o Y?"), come ("Come...?"),
quando ("Quando...?"), previsione ("Passero'...?", "Andra' bene...?"),
altrui ("Che cosa prova lui?", "Tornera' da me?"), vaga ("Andra' tutto
bene?", "Che cosa mi aspetta?", "Dimmi qualcosa").

Il lettore cieco dell'ordine GA, dopo la prima cura (paragrafi composti da
frammenti): il cosa fare era una formula al posto dell'azione ("cura con
costanza ciò che dipende da te" cinque volte), la persona della domanda
spariva dietro un ambito ("per il lavoro" al posto del capo), "Lo chiede la
pietra che decide" in 21 responsi su 40. Qui si scrive per pietra e per tipo,
con la cosa della domanda dentro il testo, e questo strumento e' il
guardiano: misura, spazi, regole della prima frase per tipo, formule vietate,
nessuna voce e nessuna frase uguale nemmeno contro il corpus di prima,
nessuna apertura ripetuta oltre un tetto.

GLI SPAZI (uno solo per voce, sempre):
- {azione}, nei gruppi "decisione": l'infinito della domanda con i suoi
  complementi, le persone girate ("accettare l’offerta della nuova azienda",
  "dirle che sei innamorato di lei"; se la domanda non si lascia riprendere,
  "prendere questa decisione"). Da 1 a 6 parole. Sempre dopo "di" ("prima
  di {azione}", "decidere di {azione}").
- {cosa}, in tutti gli altri gruppi: cio' di cui la persona chiede, con
  l'articolo o il possessivo ("il conflitto con il tuo capo", "tuo figlio",
  "l’esame di stato a dicembre", "il legame con Marco", "il lavoro", "il tuo
  momento"). Da 1 a 6 parole. Sempre e solo dopo "per" ("per {cosa}").
Con lo spazio da 1 a 6 parole, ogni voce sta fra 39 e 44 parole fuori dallo
spazio, cioe' fra 40 e 50 a video.

    python tool/controlla_le_risposte_dirette_delle_rune.py
        i due campi interi, coi conti
    python tool/controlla_le_risposte_dirette_delle_rune.py --parte <campo> <parte.md>...
        una parte di uno scrittore, contro il corpus di oggi (tutti i campi)

Le parti si applicano con:
    python tool/controlla_le_risposte_dirette_delle_rune.py --applica <campo> <parte.md>...
"""
import collections
import os
import pathlib
import re
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import controlla_il_corpus_delle_rune as base  # noqa: E402

RADICE = base.RADICE
CARTELLA = pathlib.Path(os.environ.get('CARTELLA_DEL_CORPUS',
                                       RADICE / 'docs/corpus/rune'))
CAMPI = ['diretta', 'azione']
TIPI = ['decisione', 'scelta', 'come', 'quando', 'previsione', 'altrui', 'vaga']

# Le voci per gruppo: le otto simmetriche escono il doppio delle altre (non
# si dividono fra dritta e ombra), quindi ne hanno di piu'.
QUANTE_SIMMETRICA = 8
QUANTE_ALTRA = 5

# Il tetto delle aperture: le prime tre parole di una voce si ripetono al
# piu' TETTO_APERTURA volte nel campo (il lettore cieco: "Lo chiede la
# pietra che decide" 21 volte su 40, "Le rune non predicono l'esito" 10).
TETTO_APERTURA = 40

# I valori di misura degli spazi: il piu' corto e il piu' lungo ammessi.
VALORI = {
    'cosa': ['Marco', 'il conflitto con il tuo capo'],
    'azione': ['partire', 'dirle che sei innamorato di lei'],
}

# Le formule che il lettore cieco ha contato come formule al posto della
# risposta o dell'azione: non tornano.
FORMULE = [
    'ciò che dipende da te', 'primo passo concreto', 'un gesto preciso',
    'lo chiede la pietra', 'telefonata, un incontro o un messaggio',
    'pietre su', 'la pietra è una sola', 'la gettata indica',
    'è questa la via', 'cioè ciò che', 'non annunciare prima del tempo',
    'cura con costanza', 'un gesto piccolo', 'nei giorni che mancano',
    'la pietra che decide', 'sono tutte dritte', 'è in ombra',
    'scegli quella che lo fa di più',
]

LIMITE = re.compile(r'\b(rune|runa|pietr\w*|gettata|segni)\b', re.I)
NEGA = re.compile(r'\b(non|nessun\w*|né)\b', re.I)
INVITO = re.compile(r'(precis\w*|riformul\w*|dimmi\b|raccontami|una domanda '
                    r'(più|meglio)|domanda (concreta|mirata)|nomina\b|'
                    r'restringi|scegli una (cosa|domanda))', re.I)
VERDETTO = re.compile(r'^(Sì|No\b|Non\b|Ancora no|Aspetta|Rimanda|Fermati|'
                      r'Meglio|Prima\b)')


def gruppo_da_titolo(titolo):
    parti = [x.strip() for x in titolo.split(',')]
    if len(parti) != 3:
        raise ValueError(titolo)
    runa, verso, tipo = parti
    return f"{runa}/{'ombra' if verso == 'in ombra' else 'dritta'}/{tipo}"


def titolo_da_gruppo(gruppo):
    runa, verso, tipo = gruppo.split('/')
    return f"{runa}, {'in ombra' if verso == 'ombra' else 'dritta'}, {tipo}"


def gruppi_attesi():
    return [f'{r}/{v}/{t}' for r in base.RUNE for v in ('dritta', 'ombra')
            if not (v == 'ombra' and r in base.SIMMETRICHE) for t in TIPI]


def quante_servono(gruppo):
    return QUANTE_SIMMETRICA if gruppo.split('/')[0] in base.SIMMETRICHE \
        else QUANTE_ALTRA


def leggi(campo, percorso=None):
    p = percorso or CARTELLA / f'{campo}.md'
    gruppi, g, difetti = {}, None, []
    if not p.exists():
        return gruppi, []
    for n_riga, riga in enumerate(p.read_text(encoding='utf-8').splitlines(), 1):
        t = re.match(r'^## (.+)$', riga)
        if t:
            try:
                g = gruppo_da_titolo(t.group(1))
            except ValueError:
                difetti.append(f'{campo}.md riga {n_riga}: titolo fuori forma')
                g = None
                continue
            if g in gruppi:
                difetti.append(f'{campo}.md riga {n_riga}: gruppo {g} ripetuto')
            gruppi[g] = []
            continue
        v = re.match(r'^(\d+)\.\s?(.*)$', riga)
        if v and g is not None:
            if int(v.group(1)) != len(gruppi[g]) + 1:
                difetti.append(f'{campo}.md, {g}, voce {v.group(1)}: numero '
                               f'fuori fila')
            gruppi[g].append(v.group(2).rstrip())
        elif riga.strip() and not riga.startswith('#') and g is not None:
            difetti.append(f'{campo}.md riga {n_riga}: riga fuori forma')
    return gruppi, difetti


def prima_frase(voce):
    m = re.search(r'[.?](\s+|$)', voce)
    return voce if not m else voce[:m.end()].strip()


def difetti_della_voce(campo, gruppo, voce):
    out = []
    runa, verso, tipo = gruppo.split('/')
    spazio = 'azione' if tipo == 'decisione' else 'cosa'
    usati = re.findall(r'\{([a-z]+)\}', voce)
    if usati != [spazio]:
        out.append(f'spazi {usati}: nel gruppo {tipo} ne serve uno solo, '
                   f'{{{spazio}}}')
    # La misura: fuori dallo spazio da 39 a 44, con ogni forma del genere.
    forme, malformata = base.le_forme_del_genere(voce)
    if malformata:
        out.append(malformata)
    for f in forme:
        for val in VALORI[spazio]:
            n = base.parole(f.replace('{' + spazio + '}', val))
            if not 40 <= n <= 50:
                out.append(f'{n} parole con «{val}» (fuori dallo spazio '
                           f'{base.parole(re.sub(r"[{][a-z]+[}]", " ", f))}, '
                           f'la finestra e\' 39-44)')
                break
    # Dove sta lo spazio.
    if spazio == 'cosa' and re.search(r'(?<!\bper )(?<!\bPer )\{cosa\}', voce):
        out.append('{cosa} sta solo dopo "per" ("per {cosa}")')
    if spazio == 'azione' and re.search(r'(?<!\bdi )\{azione\}', voce):
        out.append('{azione} sta solo dopo "di" ("prima di {azione}")')
    if re.search(r'(^|[.?:]\s+)\{(cosa|azione)\}', voce):
        out.append('lo spazio a inizio di frase')
    # La lingua: le regole del corpus di prima (nessun nome di runa, niente
    # trattino lungo, niente virgola prima di "e", niente futuri certi,
    # niente salute, denaro e legge, il genere, il "ti" col participio).
    out += [d for d in base.difetti_di_lingua('risposta', gruppo,
                                              voce.replace('{azione}', '{cosa}'))
            if '{cosa}' not in d or spazio == 'cosa']
    basso = voce.lower()
    for f in FORMULE:
        if f in basso:
            out.append(f'formula vietata «{f}»')
    # La prima frase, per tipo (solo il paragrafo 1).
    if campo == 'diretta':
        p = prima_frase(voce)
        if tipo == 'decisione':
            if not VERDETTO.search(p):
                out.append('la prima frase non comincia con un verdetto '
                           '(Sì, No, Non ancora, Non adesso, Aspetta...)')
            if '{azione}' not in p:
                out.append('la prima frase non nomina {azione}')
        else:
            if '{cosa}' not in p:
                out.append('la prima frase non nomina {cosa}')
            if re.match(r'^(Sì|No)\b', p):
                out.append('un "sì" o un "no" a una domanda che non li chiede')
        if tipo == 'scelta' and not re.search(r'scegl|strad|preferisc', p, re.I):
            out.append('la prima frase non da\' il criterio di scelta')
        if tipo in ('quando', 'previsione', 'altrui', 'vaga') and not (
                LIMITE.search(p) and NEGA.search(p)):
            out.append('la prima frase non dice il limite delle rune')
        if tipo == 'vaga' and not INVITO.search(voce):
            out.append('la domanda vaga non e\' invitata a farsi precisa')
    return out


def frasi(voce):
    return list(base.frasi(voce))


def apertura(voce):
    return ' '.join(re.sub(r'[^\w{} ]', '', voce.lower()).split()[:3])


def il_corpus_di_prima():
    """{(campo, gruppo, n): voce} del corpus di prima, per le frasi uguali."""
    out = {}
    for c in base.CAMPI:
        gruppi, _ = base.leggi_il_campo(c)
        for g, voci in gruppi.items():
            for i, v in enumerate(voci):
                if v:
                    out[f'{c}/{g}/{i + 1}'] = v
    return out


def controlla(corpus, attesi_completi):
    """corpus: {campo: {gruppo: [voce]}}. I difetti di tutto."""
    difetti = []
    for campo in CAMPI:
        gruppi = corpus.get(campo, {})
        for g, voci in gruppi.items():
            if g not in gruppi_attesi():
                difetti.append(f'{campo}: il gruppo {g} non esiste')
                continue
            for i, v in enumerate(voci):
                if v:
                    difetti += [f'{campo}/{g}/{i + 1}: {d}'
                                for d in difetti_della_voce(campo, g, v)]
            if attesi_completi:
                piene = sum(1 for v in voci if v)
                if piene < quante_servono(g):
                    difetti.append(f'{campo}/{g}: {piene} voci, ne servono '
                                   f'{quante_servono(g)}')
        if attesi_completi:
            mancano = set(gruppi_attesi()) - set(gruppi)
            if mancano:
                difetti.append(f'{campo}: mancano {len(mancano)} gruppi, per '
                               f'esempio {sorted(mancano)[:3]}')
        aperture = collections.Counter(
            apertura(v) for voci in gruppi.values() for v in voci if v)
        for a, n in aperture.items():
            if n > TETTO_APERTURA:
                difetti.append(f'{campo}: l\'apertura «{a}» torna {n} volte, il '
                               f'tetto e\' {TETTO_APERTURA}')
    # Nessuna voce e nessuna frase uguale, fra i due campi nuovi e contro il
    # corpus di prima.
    viste, frasi_viste = {}, {}
    for vid, v in il_corpus_di_prima().items():
        for f in frasi(v):
            frasi_viste.setdefault(f, vid)
    for campo in CAMPI:
        for g, voci in corpus.get(campo, {}).items():
            for i, v in enumerate(voci):
                if not v:
                    continue
                vid = f'{campo}/{g}/{i + 1}'
                k = ' '.join(v.lower().split())
                if k in viste:
                    difetti.append(f'{vid}: voce uguale a {viste[k]}')
                viste.setdefault(k, vid)
                for f in frasi(v):
                    if f in frasi_viste and frasi_viste[f] != vid:
                        difetti.append(f'{vid}: frase uguale a '
                                       f'{frasi_viste[f]}: "{f}"')
                    frasi_viste.setdefault(f, vid)
    return difetti


def leggi_parte(percorso):
    out, g, difetti = {}, None, []
    for n_riga, riga in enumerate(pathlib.Path(percorso).read_text(
            encoding='utf-8').splitlines(), 1):
        t = re.match(r'^## (.+)$', riga)
        if t:
            try:
                g = gruppo_da_titolo(t.group(1))
            except ValueError:
                difetti.append(f'{percorso} riga {n_riga}: titolo fuori forma '
                               f'("## Fehu, dritta, decisione")')
                g = None
                continue
            if g not in gruppi_attesi():
                difetti.append(f'{percorso} riga {n_riga}: il gruppo {g} non '
                               f'esiste')
            out.setdefault(g, {})
            continue
        v = re.match(r'^(\d+)\.\s?(.*)$', riga)
        if v and g is not None:
            out[g][int(v.group(1))] = v.group(2).rstrip()
        elif riga.strip() and not riga.startswith('#') and g is not None:
            difetti.append(f'{percorso} riga {n_riga}: riga fuori forma')
    return out, difetti


def unisci(campo, percorsi):
    """Il campo di oggi con le parti sopra: (corpus del campo, difetti)."""
    gruppi, difetti = leggi(campo)
    nuovo = {g: list(v) for g, v in gruppi.items()}
    for p in percorsi:
        pg, d = leggi_parte(p)
        difetti += d
        for g, voci in pg.items():
            elenco = nuovo.setdefault(g, [])
            for n, testo in sorted(voci.items()):
                if n <= len(elenco):
                    elenco[n - 1] = testo
                elif n == len(elenco) + 1:
                    elenco.append(testo)
                else:
                    difetti.append(f'{campo}/{g}: la voce {n} lascia un buco')
    return nuovo, difetti


def scrivi(campo, gruppi):
    righe = []
    for g in gruppi_attesi():
        if g not in gruppi:
            continue
        righe.append(f'## {titolo_da_gruppo(g)}')
        righe += [f'{i + 1}. {v}' for i, v in enumerate(gruppi[g])]
        righe.append('')
    (CARTELLA / f'{campo}.md').write_text('\n'.join(righe), encoding='utf-8',
                                          newline='\n')


def main(argv):
    if argv[:1] in (['--parte'], ['--applica']):
        campo, percorsi = argv[1], argv[2:]
        if campo not in CAMPI:
            sys.exit(f'campo sconosciuto {campo}: {CAMPI}')
        nuovo, difetti = unisci(campo, percorsi)
        corpus = {c: (nuovo if c == campo else leggi(c)[0]) for c in CAMPI}
        tutti = controlla(corpus, attesi_completi=False)
        toccati = set()
        for p in percorsi:
            toccati |= set(leggi_parte(p)[0])
        # Della parte si stampano i difetti suoi e quelli che tocca.
        mie = [d for d in tutti if any(f'{campo}/{g}/' in d for g in toccati)
               or 'apertura' in d]
        difetti += mie
        print(f'{campo}: {len(toccati)} gruppi nella parte, difetti '
              f'{len(difetti)}')
        for d in difetti:
            print('  ' + d)
        if difetti:
            return 1
        if argv[0] == '--applica':
            scrivi(campo, nuovo)
            print(f'{campo}.md: scritto')
        else:
            print('la parte e\' a posto')
        return 0
    corpus = {c: leggi(c)[0] for c in CAMPI}
    difetti = controlla(corpus, attesi_completi=True)
    for c in CAMPI:
        gruppi = corpus[c]
        voci = sum(1 for vv in gruppi.values() for v in vv if v)
        print(f'{c}: {len(gruppi)} gruppi su {len(gruppi_attesi())}, {voci} '
              f'voci (ne servono '
              f'{sum(quante_servono(g) for g in gruppi_attesi())})')
    print(f'difetti: {len(difetti)}')
    for d in difetti[:400]:
        print('  ' + d)
    return 1 if difetti else 0


if __name__ == '__main__':
    sys.stdout.reconfigure(encoding='utf-8')
    sys.exit(main(sys.argv[1:]))
