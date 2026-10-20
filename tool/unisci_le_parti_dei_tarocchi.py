# -*- coding: utf-8 -*-
"""UNISCI LE PARTI DEI TAROCCHI. Ordine GA voce GA.07, 20 ottobre 2026.

Il corpus delle carte nella loro posizione (`docs/corpus/tarocchi_posizione/`)
si porta nella forma nuova da piu' scrittori in parallelo, ognuno sulle sue
carte: scrive i titoli, i "cosa fare" e le riscritture di scheletri e
registri in un file a parte; questo strumento le rimette nei file della
fonte. Una parte ha quattro sezioni, ognuna facoltativa, con dentro le carte
(`## Il Matto`), i versi (`### dritta`, `### capovolta`) e le righe:

    # REGISTRI                     righe `- amore:`, `- lavoro:`, `- vita:`
    # POSIZIONE: esito             righe `- 1:`, `- 2:`, `- 3:` (una per
                                   variante riscritta); vale il nome del
                                   file (`speranze_o_timori`) o quello di
                                   `SpreadPosition` (`speranzeOTimori`)
    # TITOLI                       righe `- passato:` ... `- speranzeOTimori:`
    # COSA FARE                    righe `- amore_1:` ... `- vita_3:`

Ogni riga sostituisce la riga con la stessa chiave nel file della fonte. Le
altre righe della parte (vuote, citazioni che cominciano con `>`, note) non
contano; una riga che comincia col trattino e non ha una chiave della sua
sezione ferma lo strumento.

    python tool/unisci_le_parti_dei_tarocchi.py --controlla <parte.md> [...]
    python tool/unisci_le_parti_dei_tarocchi.py <parte.md> [...]

Con `--controlla` non scrive niente: rimette le parti nella fonte in
memoria, fa i controlli di `tool/genera_carte_nella_posizione.py` con la
forma nuova in vigore, ristretti alle carte delle parti (e alle coppie di
testi in cui almeno uno e' loro); stampa i difetti e il conto. Le righe
ancora vuote della parte si contano come da scrivere.

Senza `--controlla` unisce davvero, ma SI FERMA SENZA SCRIVERE NIENTE se una
sezione, una carta, un verso o una chiave non esistono nella fonte, se una
chiave o una carta stanno in due parti, se una riga della parte e' vuota, o
se il controllo trova anche un solo difetto. Una carta toccata deve uscire
intera nella forma nuova: i trenta titoli, i diciotto "cosa fare" e ogni
paragrafo fra 40 e 50 parole con ognuno dei tre registri. Dopo, si rilancia
`python tool/genera_carte_nella_posizione.py`, che controlla tutta la fonte
e scrive il Dart quando tutte le carte sono arrivate.
"""
import io
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import genera_carte_nella_posizione as g  # noqa: E402

SEZIONI = {
    'REGISTRI': (g.REGISTRI, g.GRUPPI),
    'TITOLI': (g.TITOLI, g.CHIAVI_DEI_TITOLI),
    'COSA FARE': (g.COSA_FARE, g.CHIAVI_DEL_COSA_FARE),
}
for _dart, _file, _ in g.POSIZIONI:
    SEZIONI['POSIZIONE: %s' % _file] = (os.path.join(g.FONTE, _file + '.md'),
                                        g.VARIANTI)
    SEZIONI['POSIZIONE: %s' % _dart] = SEZIONI['POSIZIONE: %s' % _file]


class Fermo(Exception):
    pass


def chiave_del_file(percorso):
    return os.path.normcase(os.path.abspath(percorso))


def leggi_la_parte(percorso, carte):
    """{(file della fonte, carta, verso, chiave): testo} e le righe vuote.

    Si ferma su una sezione, una carta, un verso o una chiave che non
    esistono o su una chiave scritta due volte.
    """
    nome = os.path.basename(percorso)
    righe = {}
    vuote = []
    sezione = carta = verso = None
    testo = io.open(percorso, encoding='utf-8-sig').read()
    for numero, riga in enumerate(testo.splitlines(), 1):
        riga = riga.rstrip()
        m = re.match(r'^# (.+)$', riga)
        if m:
            sezione = m.group(1).strip()
            if sezione not in SEZIONI:
                raise Fermo('%s, riga %d: la sezione «%s» non esiste; valgono '
                            'REGISTRI, TITOLI, COSA FARE e POSIZIONE: <nome>'
                            % (nome, numero, sezione))
            carta = verso = None
            continue
        m = re.match(r'^## (.+)$', riga)
        if m:
            carta = m.group(1).strip()
            if sezione is None:
                raise Fermo('%s, riga %d: una carta prima di ogni sezione' %
                            (nome, numero))
            if carta not in carte:
                raise Fermo('%s, riga %d: la carta «%s» non e\' nel mazzo' %
                            (nome, numero, carta))
            verso = None
            continue
        m = re.match(r'^### (.+)$', riga)
        if m:
            verso = m.group(1).strip()
            if verso not in g.VERSI or carta is None:
                raise Fermo('%s, riga %d: il verso «%s» non esiste o sta '
                            'fuori da una carta' % (nome, numero, verso))
            continue
        if not riga.startswith('-'):
            continue
        file_fonte, chiavi = SEZIONI.get(sezione, (None, ()))
        m = re.match(r'^- ([^:]+):(.*)$', riga)
        if not m or m.group(1).strip() not in chiavi:
            raise Fermo('%s, riga %d: «%s» non e\' una riga della sezione %s '
                        '(chiavi: %s)' % (nome, numero, riga[:40], sezione,
                                          ', '.join(chiavi)))
        if verso is None:
            raise Fermo('%s, riga %d: una riga fuori da carta e verso' %
                        (nome, numero))
        k = (file_fonte, carta, verso, m.group(1).strip())
        if k in righe or k in vuote:
            raise Fermo('%s, riga %d: la riga %s, %s, %s della sezione %s e\' '
                        'scritta due volte' % (nome, numero, carta, verso,
                                               k[3], sezione))
        t = re.sub(r'\s+', ' ', m.group(2)).strip()
        if t:
            righe[k] = t
        else:
            vuote.append(k)
    return righe, vuote


def sostituisci(percorso, testo, sostituzioni):
    """Il [testo] del file della fonte con le righe sostituite.

    Tiene i fine riga del file, riga per riga (un file della fonte in CRLF
    resta in CRLF). Si ferma se una riga da sostituire non c'e'.
    """
    righe = testo.split('\n')
    carta = verso = None
    fatte = set()
    for i, riga in enumerate(righe):
        nuda = riga.rstrip('\r')
        m = re.match(r'^## (.+)$', nuda)
        if m:
            carta, verso = m.group(1).strip(), None
            continue
        m = re.match(r'^### (dritta|capovolta)$', nuda)
        if m:
            verso = m.group(1)
            continue
        m = re.match(r'^- ([^:]+):', nuda)
        if m and (carta, verso, m.group(1)) in sostituzioni:
            k = (carta, verso, m.group(1))
            if k in fatte:
                raise Fermo('%s: la riga %s, %s, %s compare due volte nella '
                            'fonte' % ((os.path.basename(percorso),) + k))
            fatte.add(k)
            righe[i] = '- %s: %s%s' % (m.group(1), sostituzioni[k],
                                       '\r' if riga.endswith('\r') else '')
    mancanti = sorted(set(sostituzioni) - fatte)
    if mancanti:
        raise Fermo('%s: la fonte non ha la riga %s' % (
            os.path.basename(percorso), ', '.join(mancanti[0])))
    return '\n'.join(righe)


def unisci(parti, solo_controllo):
    carte = g.carte_del_mazzo()
    tutte = {}
    vuote = []
    padrone = {}
    for p in parti:
        righe, v = leggi_la_parte(p, carte)
        for k in righe:
            if k in tutte:
                raise Fermo('la riga %s, %s, %s di %s sta in due parti' % (
                    k[1], k[2], k[3], os.path.relpath(k[0], g.RADICE)))
        for k in list(righe) + v:
            if padrone.setdefault(k[1], p) != p:
                raise Fermo('la carta %s sta in due parti, %s e %s: le parti '
                            'si dividono per carte' % (
                                k[1], os.path.basename(padrone[k[1]]),
                                os.path.basename(p)))
        tutte.update(righe)
        vuote += v
    if vuote and not solo_controllo:
        raise Fermo('%d righe vuote nelle parti, la prima: %s, %s, %s di %s; '
                    'nessun file scritto' % ((len(vuote),) + vuote[0][1:] + (
                        os.path.relpath(vuote[0][0], g.RADICE),)))
    per_file = {}
    for (f, carta, verso, k), t in tutte.items():
        per_file.setdefault(f, {})[(carta, verso, k)] = t
    testi = {}
    originali = {}
    for f, sost in per_file.items():
        if not os.path.exists(f):
            raise Fermo('manca %s: lanciare tool/genera_carte_nella_posizione'
                        '.py --prepara' % f)
        vecchio = io.open(f, encoding='utf-8', newline='').read()
        originali[f] = vecchio
        testi[chiave_del_file(f)] = sostituisci(f, vecchio, sost)
    solo = set(padrone)
    try:
        fonte = g.controlla_la_fonte(testi=testi, solo=solo,
                                     forma_nuova=True)
    except g.FonteIncompleta as e:
        raise Fermo('la fonte con le parti non si legge: %s' % e)
    colpe = fonte.colpe
    # Le righe vuote della parte compaiono gia' fra le colpe come "da
    # scrivere" se sono titoli o "cosa fare"; uno scheletro lasciato vuoto
    # resta quello di oggi.
    misure = g.misura_dei_paragrafi(fonte.scheletri, fonte.registri, solo)
    comb = sum(len(m) for m in misure.values())
    ok = sum(1 for m in misure.values() for x in g.GRUPPI
             if g.a_misura(*m[x]))
    titoli = sum(1 for (_, c, _), _t in fonte.titoli.items() if c in solo)
    cosa = sum(len(x) for (c, _, _), x in fonte.cosa_fare.items()
               if c in solo)
    print('carte: %d (%s)' % (len(solo), ', '.join(
        c for c in carte if c in solo)))
    print('righe nelle parti: %d scritte, %d vuote' % (len(tutte),
                                                        len(vuote)))
    print('titoli: %d su %d' % (titoli, len(solo) * 2 *
                                len(g.CHIAVI_DEI_TITOLI)))
    print('cosa fare: %d su %d' % (cosa, len(solo) * 2 *
                                   len(g.CHIAVI_DEL_COSA_FARE)))
    print('paragrafi a misura (scheletro + registro, %d-%d parole): %d su %d'
          % (g.PAROLE_DEL_PARAGRAFO + (ok, comb)))
    if colpe:
        # Prima i difetti dei testi scritti, poi in una riga sola le righe
        # ancora da scrivere: cento titoli vuoti non devono nascondere un
        # paragrafo fuori misura.
        da_scrivere = [c for c in colpe if c.endswith(': da scrivere')]
        altri = [c for c in colpe if not c.endswith(': da scrivere')]
        print('\n%d DIFETTI%s:' % (len(colpe), '' if solo_controllo else
                                    ', nessun file scritto'))
        for c in altri[:400]:
            print('- ' + c)
        if len(altri) > 400:
            print('... e altri %d' % (len(altri) - 400))
        if da_scrivere:
            print('- %d righe ancora da scrivere, la prima: %s' % (
                len(da_scrivere), da_scrivere[0].rsplit(':', 1)[0]))
        return 1
    if solo_controllo:
        print('\nNessun difetto: la parte si puo\' unire.')
        return 0
    for f in per_file:
        nuovo = testi[chiave_del_file(f)]
        if nuovo != originali[f]:
            io.open(f, 'w', encoding='utf-8', newline='').write(nuovo)
    print('\nUnite %d righe in %d file della fonte. Ora: python '
          'tool/genera_carte_nella_posizione.py' % (len(tutte),
                                                   len(per_file)))
    return 0


if __name__ == '__main__':
    # Gli accenti e le virgolette basse arrivano interi anche alla console di
    # Windows, che altrimenti scrive nella sua tabella.
    if hasattr(sys.stdout, 'reconfigure'):
        sys.stdout.reconfigure(encoding='utf-8')
    argomenti = [a for a in sys.argv[1:] if a != '--controlla']
    if not argomenti:
        raise SystemExit(__doc__)
    try:
        sys.exit(unisci(argomenti, '--controlla' in sys.argv))
    except Fermo as e:
        print('FERMO, nessun file scritto: %s' % e)
        sys.exit(2)
