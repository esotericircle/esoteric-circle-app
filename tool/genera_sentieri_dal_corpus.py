# -*- coding: utf-8 -*-
"""GENERA I TRE SENTIERI DAL CORPUS. Ordine AR voce 02.

**Perche' si genera invece di trascrivere.** Centosessantacinque voci copiate
a mano introducono errori silenziosi: un nome storpiato, una soglia sbagliata,
un Eos che non torna. Il dato comanda, e il codice ne e' la conseguenza: qui
si legge il file e si scrivono i tre file Dart, cosi' il codice e' fedele al
corpus per costruzione e non per diligenza.

**Le condizioni non si inventano.** Ogni voce passa da una REGOLA dichiarata,
che traduce la frase italiana in un costruttore tipizzato. Se nessuna regola
riconosce la frase, la voce diventa DORMIENTE e finisce nell'elenco che il
manifesto dichiara: e' la strada che l'ordine chiede, "se non si puo'
costruire, si dichiara".

Uso:
  python tool/genera_sentieri_dal_corpus.py
"""
import json
import pathlib
import re
import sys
import unicodedata

RADICE = pathlib.Path(__file__).resolve().parent.parent
# **IL CORPUS E' LA REVISIONE D2. Ordine AU voce 03.** La D aveva portato
# ventidue gradini di costanza dai giorni consecutivi ai giorni dentro un arco,
# ma con l'arco sbagliato: ne uscivano gradini che chiedevano quattordici
# giorni dentro tre, cioe' che non potevano maturare mai. La D2 applica la
# LEGGE DELLA FINESTRA, l'arco vale circa una volta e mezza il numero
# richiesto, e cosi' sette gradini dichiarati dormienti tornano vivi.
# **IL CORPUS E' LA REVISIONE E. Ordine BS voce 01.** La D2 lasciava
# centotrentadue voci senza 'cosa apre', che e' il campo di ammissione, e una
# soglia che prometteva ventidue Arcani Maggiori e ne chiedeva uno. La E porta
# le sezioni, la ragione di ogni voce, la porta che apre su tutte e 165 e
# cinquantuno dormienti dichiarati dal corpus stesso invece che dedotti.
CORPUS = RADICE / 'docs' / 'corpus' / 'Traguardi_165_Revisione_E.json'

# I gesti che l'app REGISTRA davvero, censiti sui punti che chiamano la regia.
# Una condizione che chiedesse un gesto fuori da questo elenco non potrebbe
# maturare mai, e infatti diventa dormiente.
GESTI_VIVI = {
    'alba', 'angelo_custode', 'animale_guida', 'archetipo', 'carta_natale',
    'gettata', 'luogo_di_nascita', 'numero_della_vita', 'ora_di_nascita',
    'oracolo', 'oroscopo', 'passaporto', 'sigillo', 'sinastria', 'soffio',
    'sogno', 'stesa', 'tramonto', 'viso',
    # Ordine BF voce 05.b: la meditazione ha una fine, e alla fine la regia
    # registra il gesto. Prima non arrivava mai, e i suoi gradini dormivano.
    'meditazione',
}

# Come si chiama, nel corpus, ciascun gesto dell'app.
NOMI_DEI_GESTI = [
    # **I NOMI DELLA REVISIONE E.** Ordine BS voce 01. Il corpus E scrive le
    # condizioni in seconda persona e chiama i doni col nome di oggi:
    # l'Arcano del Giorno al posto dell'Oracolo, il Segno del Tramonto al
    # posto della Runa. Senza queste righe quarantaquattro voci non venivano
    # riconosciute da nessuna regola e sarebbero dormite per un motivo che non
    # esiste.
    ('arcani del giorno', 'oracolo'),
    ('arcano del giorno', 'oracolo'),
    ('segni del tramonto', 'tramonto'),
    ('segno del tramonto', 'tramonto'),
    ('settantadue angeli', 'angelo_custode'),
    ('persona famosa', 'sinastria'),
    ('persone famose', 'sinastria'),
    # I PLURALI CONTANO: il corpus dice "Tre Oracoli del Giorno", e un elenco
    # che conosce solo il singolare lascia dormienti cinque traguardi veri.
    ('oracoli del giorno', 'oracolo'),
    ('oracoli', 'oracolo'),
    ('stese', 'stesa'),
    ('gettate', 'gettata'),
    ('sinastrie', 'sinastria'),
    ('meditazioni', 'meditazione'),
    ('meditazione', 'meditazione'),
    ('soffi', 'soffio'),
    ('rune del tramonto', 'tramonto'),
    ('oracolo del giorno', 'oracolo'),
    ('oracolo', 'oracolo'),
    ('stesa di tarocchi', 'stesa'),
    ('stesa', 'stesa'),
    ('oroscopo', 'oroscopo'),
    ('sinastria', 'sinastria'),
    ('runa del tramonto', 'tramonto'),
    ('rune del tramonto', 'tramonto'),
    ('gettata', 'gettata'),
    ('rito del sogno', 'sogno'),
    ('sogno', 'sogno'),
    ('sigillo dell', 'sigillo'),
    ('rito dell alba', 'alba'),
    ('alba', 'alba'),
    ('soffio', 'soffio'),
    ('respiro', 'soffio'),
    ('costellazione del viso', 'viso'),
    ('viso', 'viso'),
    ('test archetipo', 'archetipo'),
    ('archetipo', 'archetipo'),
    ('animale guida', 'animale_guida'),
    ('angelo custode', 'angelo_custode'),
    ('carta natale', 'carta_natale'),
]

NUMERI = {
    'un': 1, 'una': 1, 'la prima': 1, 'il primo': 1, 'primo': 1, 'prima': 1,
    'due': 2, 'secondo': 2, 'seconda': 2, 'tre': 3, 'terzo': 3, 'terza': 3,
    'quattro': 4, 'quarta': 4, 'quarto': 4, 'cinque': 5, 'quinta': 5,
    'sei': 6, 'sette': 7, 'otto': 8, 'nove': 9, 'dieci': 10,
    'undici': 11, 'dodici': 12, 'tredici': 13, 'quattordici': 14,
    'quindici': 15, 'sedici': 16, 'diciassette': 17, 'diciotto': 18,
    'diciannove': 19, 'venti': 20, 'ventuno': 21, 'ventun': 21,
    'ventidue': 22, 'ventitre': 23, 'ventiquattro': 24, 'venticinque': 25,
    'ventotto': 28, 'trenta': 30, 'trentadue': 32, 'trentatre': 33,
    'trentacinque': 35, 'quaranta': 40, 'quarantatre': 43,
    'quarantacinque': 45, 'cinquanta': 50, 'sessanta': 60, 'settanta': 70,
    'settantotto': 78, 'ottanta': 80, 'novanta': 90, 'cento': 100,
    'cinquantaquattro': 54, 'settantadue': 72, 'trentanove': 39,
    'centoventi': 120, 'centottanta': 180, 'trecentosessantacinque': 365,
}

# Gli eventi del cielo, come li nomina il corpus.
EVENTI = [
    # **I NOMI DELLA REVISIONE E.** Ordine BS voce 01: il corpus E dice "passa
    # sul grado del tuo Sole di nascita" dove la D2 diceva "transita sul tuo
    # Sole". Il motore del cielo e' lo stesso, cambia solo come lo si nomina.
    ('grado del tuo sole', 'transitoSulSole'),
    ('grado del tuo ascendente', 'transitoSullAscendente'),
    ('grado della tua luna', 'transitoSullaLuna'),
    # **I PIU' SPECIFICI PRIMA**: "Luna piena nel tuo segno" e' un evento suo,
    # e riconoscerlo come "luna piena" perderebbe proprio cio' che lo rende
    # raro. Il motore del cielo li ha gia' tutti.
    ('luna piena cade nel tuo segno', 'lunaPienaNelTuoSegno'),
    ('luna piena nel tuo segno', 'lunaPienaNelTuoSegno'),
    ('luna nuova cade nel tuo segno', 'lunaNuovaNelTuoSegno'),
    ('luna nuova nel tuo segno', 'lunaNuovaNelTuoSegno'),
    ('pianeta transita sul tuo sole', 'transitoSulSole'),
    ('pianeta passa sul tuo sole', 'transitoSulSole'),
    ('grado che sorgeva', 'transitoSullAscendente'),
    ('sul tuo ascendente', 'transitoSullAscendente'),
    ('sulla tua luna', 'transitoSullaLuna'),
    ('su venere', 'transitoSuVenere'),
    ('su marte', 'transitoSuMarte'),
    ('tre transiti', 'treTransitiInsieme'),
    ('saturno retrogrado', 'saturnoRetrogrado'),
    ('saturno diretto', 'saturnoDiretto'),
    ('luna piena', 'lunaPiena'),
    ('luna nuova', 'lunaNuova'),
    ('primo quarto', 'primoQuarto'),
    ('ultimo quarto', 'ultimoQuarto'),
    ('luna sta crescendo', 'lunaCrescente'),
    ('luna crescente', 'lunaCrescente'),
    ('luna calante', 'lunaCalante'),
    ('luna attraversa il tuo segno', 'lunaNelTuoSegno'),
    ('luna nel tuo segno', 'lunaNelTuoSegno'),
    ('segno opposto', 'lunaNelSegnoOpposto'),
    ('sole nel tuo segno', 'soleNelTuoSegno'),
    ('ritorno solare', 'ritornoSolare'),
    ('compleanno', 'ritornoSolare'),
    ('solstizio', 'solstizio'),
    ('equinozio', 'equinozio'),
    ('mercurio retrogrado', 'mercurioRetrogrado'),
    ('mercurio diretto', 'mercurioDiretto'),
    ('venere retrograda', 'venereRetrograda'),
    ('venere diretta', 'venereDiretta'),
    ('marte retrogrado', 'marteRetrogrado'),
    ('marte diretto', 'marteDiretto'),
    ('giove retrogrado', 'gioveRetrogrado'),
    ('giove diretto', 'gioveDiretto'),
]


def senzaAccenti(s):
    return ''.join(c for c in unicodedata.normalize('NFD', s)
                   if unicodedata.category(c) != 'Mn').lower()


def numeroIn(testo):
    """Il primo numero nominato nella frase, in cifre o in lettere."""
    m = re.search(r'\b(\d+)\b', testo)
    if m:
        return int(m.group(1))
    for parola, valore in sorted(NUMERI.items(), key=lambda x: -len(x[0])):
        if re.search(r'\b' + parola + r'\b', testo):
            return valore
    return None


def gestoIn(testo):
    for nome, gesto in NOMI_DEI_GESTI:
        if nome in testo:
            return gesto
    return None


def eventoIn(testo):
    for nome, evento in EVENTI:
        if nome in testo:
            return evento
    return None


# --- LE REGOLE, in ordine di precedenza ------------------------------------
#
# Ognuna guarda la frase e, se la riconosce, torna il costruttore Dart. La
# prima che riconosce vince: l'ordine conta, e per questo le regole piu'
# specifiche stanno prima.

def regolaDormienteDichiarato(v, testo):
    """Il corpus stesso dice che quella voce dorme."""
    if v.get('dormiente'):
        # **IL PERCHE' NON PUO' ESSERE UN TELEGRAMMA.** Ordine BS voce 01: la
        # revisione E scrive note brevissime come "DORMIENTE: fase 4", e chi
        # trovera' quel gradino fra sei mesi non sapra' cosa manca. Si compone
        # la ragione lunga attorno alla nota del corpus, senza toccarla: la
        # nota resta verbatim, e attorno c'e' scritto chi lo ha deciso.
        nota = (v.get('note') or '').strip()
        if nota.upper().startswith('DORMIENTE'):
            nota = nota.split(':', 1)[1].strip() if ':' in nota else nota
        if not nota:
            nota = 'nessuna ragione scritta nel corpus'
        return ('DORMIENTE',
                'il corpus della revisione E lo dichiara dormiente. La sua '
                'ragione e\' questa: ' + nota)
    return None


def regolaGradini(v, testo):
    """I gradini di un sentiero che si hanno gia' alle spalle.

    **LA REVISIONE E SPEZZA LA FRASE.** Ordine BS voce 01: il corpus E dice
    "Dieci gradini qualunque della Costellazione alle spalle", e cercare la
    coppia di parole attaccata, come faceva la revisione D2 con "gradini alle
    spalle", non trovava piu' niente. Sono le quindici perle dei tre sentieri:
    senza questa riga dormivano tutte e quindici, cioe' ogni gradino grande.
    """
    if 'gradini' not in testo or 'alle spalle' not in testo:
        return None
    # "Tutti i gradini alle spalle" e' il gradino che chiude il sentiero: sono
    # i cinquantaquattro che lo precedono.
    if 'tutti i gradini' in testo:
        return f"GradiniAlleSpalle('{v['_sentiero']}', 54)", None
    quanti = numeroIn(testo)
    if quanti is None:
        return None
    return f"GradiniAlleSpalle('{v['_sentiero']}', {quanti})", None


def regolaVarieta(v, testo):
    # "Coppe, Spade, Denari e Bastoni: ognuno uscito almeno una volta"
    if 'coppe' in testo and 'spade' in testo and 'denari' in testo:
        return "VarietaDelDettaglio('stesa', 'semi', 4)", None
    if 'intero ventaglio' in testo or 'tutti i sedici argomenti' in testo:
        return "VarietaDelDettaglio('stesa', 'argomento', 16)", None
    # **"OTTO DEI SEDICI" VUOL DIRE OTTO.** Il numero che conta e' il primo:
    # il secondo dice quanti ce ne sono in tutto, non quanti ne servono.
    m = re.search(r'([a-z]+) dei ([a-z]+) (argomenti|modi|semi)', testo)
    if m:
        quanti = NUMERI.get(m.group(1))
        chiave = {'argomenti': ('stesa', 'argomento'),
                  'modi': ('gettata', 'modo'),
                  'semi': ('stesa', 'semi')}[m.group(3)]
        if quanti:
            return (f"VarietaDelDettaglio('{chiave[0]}', '{chiave[1]}', "
                    f"{quanti})", None)
    if 'argoment' in testo and ('diversi' in testo or 'provati' in testo
                               or 'provato' in testo):
        quanti = numeroIn(testo)
        if quanti:
            return f"VarietaDelDettaglio('stesa', 'argomento', {quanti})", None
    if 'arcano maggiore' in testo or 'arcani maggiori' in testo or 'ventidue maggiori' in testo:
        quanti = numeroIn(testo) or 22
        return f"VarietaDelDettaglio('stesa', 'maggiori', {quanti})", None
    # **"TRENTANOVE CARTE DIVERSE" E' UNA VARIETA', non un conteggio di stese.**
    # Ordine BS voce 01: senza questa riga la frase finiva nella regola del
    # conteggio e diventava "una Stesa qualunque", cioe' la stessa condizione
    # della primissima Stesa. Lo ha trovato la guardia che vieta due traguardi
    # con la stessa firma.
    if 'carte diverse' in testo:
        quanti = numeroIn(testo)
        if quanti:
            return f"VarietaDelDettaglio('stesa', 'carte', {quanti})", None
    if 'carta del mazzo' in testo or 'carte del mazzo' in testo or 'settantotto' in testo:
        return "VarietaDelDettaglio('stesa', 'carte', 78)", None
    if 'elder futhark' in testo or ('runa' in testo and 'ogni' in testo):
        # "Meta' dell'Elder Futhark" sono dodici delle ventiquattro.
        quanti = 12 if 'meta' in testo else 24
        # Le rune viste vengono dal TRAMONTO: la gettata non puo' passare le
        # rune uscite dal punto in cui registra il gesto (ordine AR voce 11).
        chiave = 'tramonto'
        return f"VarietaDelDettaglio('{chiave}', 'runa', {quanti})", None
    if 'rune' in testo and ('diverse' in testo or 'tutte' in testo):
        quanti = numeroIn(testo) or 24
        return f"VarietaDelDettaglio('tramonto', 'runa', {quanti})", None
    if 'modi' in testo and 'gettata' in testo:
        quanti = 4 if 'i quattro modi' in testo else (numeroIn(testo) or 4)
        return f"VarietaDelDettaglio('gettata', 'modo', {quanti})", None
    if 'persone diverse' in testo and 'sinastri' in testo:
        quanti = numeroIn(testo)
        if quanti:
            return f"VarietaDelDettaglio('sinastria', 'vip', {quanti})", None
    return None


def regolaCoincidenza(v, testo):
    if 'stessa carta' in testo:
        quanti = numeroIn(testo) or 2
        return f"CoincidenzaDelDettaglio('stesa', 'carte', {quanti})", None
    if 'stesso arcano' in testo:
        quanti = numeroIn(testo) or 3
        return f"CoincidenzaDelDettaglio('stesa', 'maggiori', {quanti})", None
    if 'stessa runa' in testo:
        quanti = numeroIn(testo) or 2
        return f"CoincidenzaDelDettaglio('tramonto', 'runa', {quanti})", None
    return None


def regolaCielo(v, testo):
    evento = eventoIn(testo)
    if evento is None and not v.get('finestra_del_cielo'):
        return None
    if evento is None:
        evento = eventoIn(senzaAccenti(v['finestra_del_cielo']))
    if evento is None:
        return None
    # **UNA FINESTRA DEL CIELO GUARDA OGGI, e non sa contare.** Ordine AU voce
    # 03, coda: `FinestraDelCielo` risponde vero quando l'evento c'e' OGGI e il
    # gesto e' stato fatto oggi. Una condizione che ne chiede DODICI, come
    # "dodici volte hai letto l'Oroscopo mentre la Luna passava nel tuo segno",
    # chiede una memoria per evento che il diario non tiene, la stessa che gia'
    # rende dormienti cal_50 e aur_46.
    #
    # **Senza questa riga il difetto era peggio della dormienza**: la
    # condizione usciva identica a quella del traguardo che ne chiede UNA
    # sola, med_14, quindi med_51 si sarebbe acceso alla PRIMA lettura, cioe'
    # un traguardo dell'anno regalato il primo giorno. Lo ha trovato una prova
    # che non c'entrava, quella che vieta due traguardi con la stessa firma.
    # **IL NUMERO CONTA SOLO SE CONTA GLI EVENTI**, e la prima stesura di
    # questa riga ne spegneva tre a torto: in "un Oroscopo letto in un giorno
    # che porta TRE transiti" il tre descrive il giorno, non quante volte; e in
    # "sotto l'ultimo QUARTO di Luna" trovava perfino un quattro. Vale solo il
    # numero di "N volte", oppure quello con cui la frase COMINCIA, come in
    # "Dodici Lune nuove con una gettata in ciascuna".
    conVolte = re.search(r'(\w+)\s+volte', testo)
    if conVolte:
        quante = numeroIn(conVolte.group(1))
    else:
        prima = testo.split()
        quante = numeroIn(prima[0]) if prima else None
    if quante is not None and quante > 1:
        return 'DORMIENTE', (
            'la costanza LUNGA su un evento del cielo (%d volte) chiede una '
            'memoria per evento che il diario non tiene: si conta la serie dei '
            'GIORNI, non quella degli eventi' % quante)
    gesto = gestoIn(testo)
    if gesto is None:
        return f"FinestraDelCielo(EventiDelCielo.{evento})", None
    if gesto not in GESTI_VIVI:
        return 'DORMIENTE', f'il gesto {gesto} non arriva alla regia'
    return (f"FinestraDelCielo(EventiDelCielo.{evento}, conGesto: '{gesto}')",
            None)


# **LA LEGGE DELLA FINESTRA.** Ordine AU voce 03: l'arco vale circa una volta e
# mezza il numero richiesto. Nessun gradino puo' chiedere piu' giorni di quanti
# ne concede il suo arco, e nessuno puo' chiedere giorni consecutivi. La stessa
# legge sta scritta nel corpus e sorvegliata da
# `test/la_finestra_e_una_volta_e_mezza_test.dart`: qui serve perche' il
# generatore se ne accorga mentre traduce, non dopo.
LEGGE_DELLA_FINESTRA = {
    2: 3, 3: 5, 5: 8, 7: 10, 14: 20, 21: 30, 30: 45, 40: 60, 60: 85, 90: 130,
}


def regolaCostanzaLarga(v, testo):
    """**LA COSTANZA LARGA DEL CORPUS D. Ordine AS voce 12.**

    Il corpus della revisione D dice "Sette Oracoli del Giorno, nell'arco di 10
    giorni" dove la C diceva "in sette giorni consecutivi". La ragione la
    spiega la misura della voce AR.04: con la serie consecutiva chi non apre
    l'app tutti i giorni non la completa mai, e la scala essendo sequenziale si
    blocca li' per sempre.

    **Sta PRIMA della regola della serie consecutiva**, perche' molte di queste
    frasi nominano ancora i giorni e la regola vecchia le riconoscerebbe come
    serie, cioe' rimetterebbe il muro che il corpus nuovo toglie.
    """
    if "nell'arco di" not in testo and 'nell arco di' not in testo:
        return None
    # **LA PRESENZA E' UN RITO ANCHE QUI**, come nella regola della serie: il
    # corpus la dice "sette giorni di presenza, qualunque gesto conti", e il
    # diario la conta col rito `presenza`. Senza questo caso quella voce
    # resterebbe dormiente per un motivo che non esiste.
    gesto = 'presenza' if 'presenza' in testo else gestoIn(testo)
    if gesto is None:
        return None
    # Due numeri: quanti giorni servono e quanto e' largo l'arco.
    import re as _re
    numeri = [int(n) for n in _re.findall(r'(\d+)', testo)]
    quanti = numeroIn(testo.split("nell")[0])
    arco = numeri[-1] if numeri else None
    if quanti is None or arco is None or arco <= 0:
        return None
    # Settimane e mesi si riportano a giorni, come fa la regola della serie: il
    # dato dice la durata, il diario conta giorni.
    if 'settimana' in testo or 'settimane' in testo:
        quanti = quanti * 7
    elif 'mese' in testo or 'mesi' in testo:
        quanti = quanti * 30
    # **UN ARCO PIU' STRETTO DI QUANTI GIORNI SERVONO E' IMPOSSIBILE, e non si
    # aggiusta di nascosto.** Il corpus D porta tre voci cosi': "due settimane
    # di presenza, nell'arco di 3 giorni", cioe' quattordici giorni dentro tre.
    # Nascono dalla conversione automatica della revisione, che ha preso il
    # numero della durata al posto di quello dell'arco. Qui si DICHIARA: la
    # voce diventa dormiente col suo perche', e il rapporto lo porta
    # all'Architetto, che e' l'unico che puo' correggere il dato.
    if arco < quanti:
        return ('DORMIENTE',
                'il corpus chiede %d giorni dentro un arco di %d, che e '
                'aritmeticamente impossibile: il dato va corretto nel corpus'
                % (quanti, arco))
    return f"GiorniDentroUnArco('{gesto}', {quanti}, {arco})", None


def regolaCostanzaDentro(v, testo):
    """**"DUE SEGNI DEL TRAMONTO DENTRO TRE GIORNI".** Ordine BS voce 01.

    La revisione D2 diceva "nell'arco di 3 giorni" e scriveva i numeri in
    cifre; la E dice "dentro tre giorni" e li scrive in lettere. E' la stessa
    condizione, `GiorniDentroUnArco`, e senza questa regola le voci di costanza
    larga della E finivano nella regola del conteggio, che le avrebbe rese
    "due gesti in tutto", cioe' un traguardo di costanza regalato in un
    pomeriggio.
    """
    if 'dentro' not in testo:
        return None
    m = re.search(r'dentro\s+([a-z]+)\s+giorni', testo)
    if m is None:
        return None
    arco = numeroIn(m.group(1))
    if arco is None:
        return None
    gesto = 'presenza' if 'presenza' in testo else gestoIn(testo)
    if gesto is None:
        return None
    quanti = numeroIn(testo.split('dentro')[0])
    if quanti is None:
        return None
    if gesto not in GESTI_VIVI:
        return 'DORMIENTE', f'il gesto {gesto} non arriva alla regia'
    # **UN ARCO PIU' STRETTO DI QUANTI GIORNI SERVONO E' IMPOSSIBILE**, e si
    # dichiara invece di aggiustarlo di nascosto: il dato va corretto nel
    # corpus, non qui.
    if arco < quanti:
        return ('DORMIENTE',
                'il corpus chiede %d giorni dentro un arco di %d, che e '
                'aritmeticamente impossibile: il dato va corretto nel corpus'
                % (quanti, arco))
    return f"GiorniDentroUnArco('{gesto}', {quanti}, {arco})", None


def regolaModiDellaGettata(v, testo):
    """**I MODI DI GETTARE LE RUNE.** Ordine BS voce 01.

    "Provi due modi diversi di gettare le rune" e "Ogni modo di gettare le rune
    provato almeno una volta" sono varieta' sul dettaglio `modo`, che la
    schermata della gettata manda davvero. Senza questa regola la prima
    finiva nel conteggio come "due gettate qualunque", che e' un'altra cosa.
    """
    if 'gettare le rune' not in testo and 'modi di gettare' not in testo:
        return None
    if 'ogni modo' in testo or 'tutti i modi' in testo:
        return "VarietaDelDettaglio('gettata', 'modo', 4)", None
    if 'modi' in testo:
        quanti = numeroIn(testo)
        if quanti:
            return f"VarietaDelDettaglio('gettata', 'modo', {quanti})", None
    return None


def regolaGiorniDiSeguito(v, testo):
    if 'consecutiv' not in testo and 'di seguito' not in testo:
        return None
    quanti = numeroIn(testo)
    if quanti is None:
        return None
    # **"GIORNI DI PRESENZA" E' IL RITO DI CHI C'E', qualunque cosa faccia.**
    # Il corpus lo dice cosi': "sette giorni di presenza consecutivi,
    # qualunque gesto conti". Il diario conta la presenza col rito
    # `presenza`, che e' il gesto comune a tutti i sentieri.
    if 'presenza' in testo:
        if 'settiman' in testo:
            quanti = quanti * 7
        elif 'mese' in testo or 'mesi' in testo:
            quanti = quanti * 30
        return f"GiorniDiSeguito('presenza', {quanti})", None
    # Settimane e mesi si riportano a giorni: il dato dice la durata, e la
    # condizione la conta in giorni perche' il diario conta giorni.
    if 'settimana' in testo or 'settimane' in testo:
        quanti = quanti * 7
    elif 'mese' in testo or 'mesi' in testo:
        quanti = quanti * 30
    gesto = gestoIn(testo)
    if gesto is None:
        return None
    if gesto not in GESTI_VIVI:
        return 'DORMIENTE', f'il gesto {gesto} non arriva alla regia'
    return f"GiorniDiSeguito('{gesto}', {quanti})", None


def regolaStessoGiorno(v, testo):
    if 'stesso giorno' not in testo:
        return None
    gesti = []
    for nome, gesto in NOMI_DEI_GESTI:
        if nome in testo and gesto not in gesti:
            gesti.append(gesto)
    if len(gesti) < 2:
        return None
    for g in gesti:
        if g not in GESTI_VIVI:
            return 'DORMIENTE', f'il gesto {g} non arriva alla regia'
    dentro = ', '.join(f"'{g}'" for g in gesti)
    return f"GestiNelloStessoGiorno([{dentro}])", None


def regolaRitorno(v, testo):
    """Chi torna dopo essere stato via.

    **LA REVISIONE E NON DICE PIU' "ASSENZA".** Ordine BS voce 01: dice "Torni
    a Medora dopo sette giorni in cui non l'hai cercata". La parola che regge
    la condizione e' il verbo, non il sostantivo.
    """
    if ('assenza' not in testo and 'torni nel cerchio' not in testo
            and not (testo.startswith('torni a') and 'giorni' in testo)):
        return None
    quanti = numeroIn(testo) or 3
    return f"RitornoDopoAssenza({quanti})", None


def regolaMemoria(v, testo):
    """Cio' che il Cerchio si ricorda: consulti ripresi, temi che tornano."""
    if 'rilegg' in testo and 'consulto' in testo:
        dopo = numeroIn(testo) or 7
        return f"MemoriaDelCerchio('riletture', 1, dopoGiorni: {dopo})", None
    if 'stesso tema' in testo:
        quanti = numeroIn(testo) or 3
        return f"MemoriaDelCerchio('temi', {quanti})", None
    return None


def regolaIdentita(v, testo):
    pezzi = [
        ('giorno, ora e luogo', 'nascita_completa'),
        ('sigillo che il cerchio', 'sigillo_del_cerchio'),
        ('nome', 'nome_proprio'),
        ('luna che vegliava', 'luna_natale'),
        ('numero della vita', 'numero_della_vita'),
        ('numero che ti accompagna', 'numero_della_vita'),
        ('ora precisa della tua nascita', 'ora_di_nascita'),
        ('ora della tua nascita', 'ora_di_nascita'),
        ('volto', 'viso'),
        ('data, ora e luogo', 'nascita_completa'),
        ('sigillo personale', 'sigillo_del_cerchio'),
        ('nome proprio', 'nome_proprio'),
        ('luna della tua carta', 'luna_natale'),
        ('numero che ti accompagna', 'numero_della_vita'),
    ]
    if v.get('ragione') not in ('Identità', 'Identita', "Identita'"):
        return None
    for nome, pezzo in pezzi:
        if nome in testo:
            return f"PezzoDellIdentita('{pezzo}')", None
    return None


def regolaCondivisione(v, testo):
    if 'condivid' in testo or 'condivisi' in testo:
        quanti = numeroIn(testo) or 1
        # **LA CONDIVISIONE E' DI UN SENTIERO, non della app.** Il corpus dice
        # "un traguardo della Costellazione", "dell'Albero", "del Loto": sono
        # tre traguardi diversi, e una condizione sola per tutti e tre li
        # avrebbe resi la stessa cosa detta in tre modi.
        perSentiero = {'costellazione': 'condivisione_stella',
                       'albero': 'condivisione_frutto',
                       'loto': 'condivisione_petalo'}[v['_sentiero']]
        return f"GestoDelCerchio('{perSentiero}', {quanti})", None
    if 'invit' in testo:
        quanti = numeroIn(testo) or 1
        return f"GestoDelCerchio('invito', {quanti})", None
    return None


def regolaNonCostruibile(v, testo):
    # **QUANDO DUE FRASI DIVERSE FINISCONO SULLA STESSA CONDIZIONE, UNA DELLE
    # DUE STA FINGENDO.** Ordine BS voce 00. Le ha trovate la guardia che vieta
    # a due traguardi di chiedere la stessa identica cosa: ognuna di queste
    # frasi promette qualcosa in piu' di cio' che la condizione misura, e senza
    # queste righe il gradino si accendeva sul gesto nudo, cioe' regalava una
    # promessa che non aveva mantenuto.
    if 'senza interrompersi' in testo or 'fino alla fine' in testo:
        return ('DORMIENTE',
                "il Soffio non dice se e' stato tenuto fino alla fine: la "
                'scena manda il gesto compiuto e basta. Servirebbe che '
                "passasse la durata e l'interruzione")
    if 'prima che il sole sorga' in testo:
        return ('DORMIENTE',
                "l app sa se un gesto cade nell ora rituale dell alba, non se "
                'cade PRIMA del sorgere vero nel luogo di chi lo compie: '
                "servirebbe l'ora del sorgere confrontata con l'istante del "
                'gesto')
    if 'ne avevi saltati' in testo:
        return ('DORMIENTE',
                "il diario conta i giorni di assenza dall app, non quelli in "
                'cui si e saltato UN gesto in particolare: e una memoria per '
                'rito che non tiene')
    if 'con quella di un' in testo and 'persona' in testo:
        return ('DORMIENTE',
                'confrontare la propria lettura con quella di un altro chiede '
                "il Cerchio degli altri, che nell app non esiste")
    if 'cielo ti e' in testo and 'contrario' in testo:
        return ('DORMIENTE',
                'il catalogo del cielo non conosce nessun evento che si chiami '
                "cielo contrario: sono transiti, fasi e retrogradi. "
                'Inventarne uno vorrebbe dire inventare un astrologia')
    if 'nella notte del solstizio' in testo:
        return ('DORMIENTE',
                "l ora del rito non viaggia con l'evento del cielo: l app sa "
                'che oggi e solstizio e che il gesto e stato compiuto, non che '
                'sia stato compiuto di notte')
    if 'torni a medora' in testo:
        return ('DORMIENTE',
                "l app registra i gesti, non da quale Maestro si torni: "
                '"torni a Medora dopo sette giorni" e "torni a Caligo dopo '
                'sette giorni" misurano lo stesso identico fatto. Due '
                'gradini per un fatto solo sono un gradino detto due volte')
    # **LA COINCIDENZA DENTRO UNA FINESTRA DI TEMPO NON SI PUO' MISURARE.**
    # Ordine BS voce 00. Il diario conta quante volte un valore e' tornato DA
    # SEMPRE, non quante volte e' tornato dentro una settimana o dentro un mese:
    # sono due domande diverse, e rispondere alla prima fingendo di rispondere
    # alla seconda regala un traguardo dell anno al primo giorno.
    #
    # **Non e' teoria: e' il difetto trovato da questa voce.** med_31 prometteva
    # "lo stesso Arcano del Giorno esce due volte in una settimana" e chiedeva
    # una coincidenza sola, cioe' si accendeva alla prima carta; aur_32
    # prometteva "lo stesso archetipo esce due volte in una settimana" e
    # chiedeva un archetipo qualunque, cioe' si accendeva al primo test.
    if ('stesso' in testo or 'stessa' in testo) and (
            'in una settimana' in testo or 'in un mese' in testo
            or 'in tre mesi' in testo or 'a distanza di' in testo):
        return ('DORMIENTE',
                'il diario conta le ripetizioni DA SEMPRE, non dentro una '
                'finestra di tempo: "due volte in una settimana" chiede una '
                'memoria con le date che il diario non tiene')
    # **CIO' CHE ESCE DALL ARCANO DEL GIORNO NON VIAGGIA.** La scena manda il
    # gesto e basta: quale carta sia uscita non lo sa nessuno, quindi "lo stesso
    # Arcano" non e' verificabile.
    if 'stesso arcano del giorno' in testo or 'stesso arcano' in testo and 'giorno' in testo:
        return ('DORMIENTE',
                "l Arcano del Giorno non passa quale carta e' uscita: la scena "
                'manda il gesto e basta. Servirebbe un dettaglio nuovo')
    # **IL CONTENUTO DI UN SOGNO NON VIAGGIA.** Vale per il simbolo che torna e
    # per l Animale Guida che vi compare: il rito manda il gesto, non cio' che
    # si e' sognato.
    if 'sogn' in testo and ('compare' in testo or 'simbolo' in testo
                            or 'annotat' in testo):
        return ('DORMIENTE',
                'il rito del sogno non passa cio che si e sognato: la scena '
                'manda il gesto e basta. Servirebbe un dettaglio nuovo')
    # **UNA RILETTURA CHE TROVA QUALCOSA DI DIVERSO** chiede di confrontare due
    # letture nel tempo: il diario tiene i conti, non le letture.
    if 'rilegg' in testo and 'divers' in testo:
        return ('DORMIENTE',
                'confrontare due letture a distanza di tempo chiede la memoria '
                'delle letture, che il diario non tiene: tiene i conti')
    # **LE VOCI DELLA REVISIONE E CHE CHIEDONO CIO' CHE L'APP NON MISURA.**
    # Ordine BS voce 00. Ognuna dice quale gesto o quale dettaglio manca e dove
    # andrebbe registrato: e' la differenza fra un traguardo che aspetta e un
    # traguardo che finge.
    if 'leggi fino in fondo' in testo or 'fino in fondo' in testo:
        return ('DORMIENTE',
                'la lettura FINO IN FONDO non arriva alla regia: la schermata '
                "manda il gesto quando si apre, non quando si e' letta tutta. "
                'Servirebbe che la scena segnasse la fine della lettura')
    if 'rovesciat' in testo:
        return ('DORMIENTE',
                'la carta rovesciata non viaggia coi dettagli della stesa: la '
                "scena manda carte, semi, maggiori e argomento. Servirebbe un "
                'dettaglio nuovo, il verso della carta')
    if 'runa coperta' in testo or 'girandola tu' in testo:
        return ('DORMIENTE',
                'girare una runa coperta invece di lasciarla al caso e un '
                'gesto che la scena non distingue: manda la gettata e il suo '
                'modo, non chi ha scoperto la runa')
    if 'gli altri del cerchio' in testo:
        return ('DORMIENTE',
                'guardare cosa accompagna gli altri chiede il Cerchio degli '
                'altri, che nell app non esiste: nessuna schermata lo mostra e '
                'nessun gesto lo registra')
    if 'sogni annotati' in testo or ('simbolo' in testo and 'sogn' in testo):
        return ('DORMIENTE',
                'il sogno non passa i propri simboli: la scena manda il gesto '
                'e basta. Servirebbe un dettaglio nuovo sul rito del sogno')
    if 'stessa ora' in testo:
        return ('DORMIENTE',
                "l app sa se un gesto cade nell ora rituale dell alba, del "
                'tramonto o della notte, non se cade sempre alla STESSA ora: '
                'servirebbe la memoria dell ora di ogni gesto')
    if 'in privato' in testo:
        return ('DORMIENTE',
                'mandare un responso in privato invece che al mondo chiede il '
                'canale della condivisione, che il gesto non porta: la regia '
                'sa che si e condiviso, non dove')
    # **QUATTRO CONDIZIONI CHE L'APP OGGI NON SA RISPONDERE**, e il motivo va
    # scritto per intero perche' l'Architetto sappia cosa manca.
    if 'transiti di oggi' in testo and 'archetipo' in testo:
        return ('DORMIENTE',
                "rileggere l'archetipo coi transiti di oggi è un gesto che la "
                "scena non registra: l'archetipo manda un gesto solo, "
                "quello del test compiuto")
    if 'a un anno dal primo' in testo:
        return ('DORMIENTE',
                'il diario non tiene QUANDO un gesto è stato compiuto la prima '
                'volta, quindi "a un anno dal primo" non è verificabile')
    if 'fasi lunari diverse' in testo:
        return ('DORMIENTE',
                'la fase lunare non viaggia coi dettagli del gesto: servirebbe '
                'che la scena la passasse. È un dettaglio nuovo')
    if 'piu lunghi del tuo primo' in testo:
        return ('DORMIENTE',
                'il soffio non passa la propria durata: senza quel dettaglio '
                '"più lungo del primo" non si può confrontare')
    # La costanza LUNGA su un evento del cielo: "dodici mesi di seguito in
    # cui...", "dodici Lune nuove di seguito". Il diario conta la serie dei
    # GIORNI, non quella degli eventi, e sono due cose diverse.
    if ('di seguito' in testo or 'consecutiv' in testo
            or 'in ciascuna' in testo) and (
            eventoIn(testo) is not None or 'lune' in testo
            or 'luna pass' in testo or 'mesi di seguito' in testo):
        return ('DORMIENTE',
                'la costanza LUNGA su un evento del cielo (dodici Lune di '
                'seguito) chiede una memoria per evento che il diario non '
                'tiene: si conta la serie dei GIORNI, non quella degli eventi')
    """**QUELLO CHE NON SI PUO' COSTRUIRE SI DICHIARA, non si inventa.**

    Sono i casi in cui il dato chiede qualcosa che l'app oggi non sa
    rispondere, e il motivo va scritto per intero: da qui nascono le voci che
    il manifesto elenca fra i dormienti.
    """
    if 'ogni mese' in testo and 'anno' in testo:
        return ('DORMIENTE',
                'il diario tiene i giorni e le serie, non i gesti mese per '
                'mese: "un gesto ogni mese per un anno" non è verificabile')
    if 'stesso presagio' in testo:
        return ('DORMIENTE',
                'il tramonto passa la runa incisa ma non il presagio: '
                'servirebbe un dettaglio che la scena oggi non manda')
    return None


def regolaScoperta(v, testo):
    """**"SCOPRI QUALE DEI SETTANTADUE ANGELI TI ACCOMPAGNA" E' UNA VOLTA SOLA.**

    Ordine BS voce 01. Il numero che la frase nomina dice quanti ce ne sono in
    tutto, non quante volte bisogna compiere il gesto: senza questa regola il
    conteggio leggeva settantadue e chiedeva settantadue scoperte dell Angelo
    custode, cioe' un traguardo dei primi giorni diventava irraggiungibile.
    Lo ha trovato la prova della curva, guardando quali gradini non si
    accendevano mai in un anno.
    """
    if 'quale dei' not in testo and 'quale delle' not in testo:
        return None
    gesto = gestoIn(testo)
    if gesto is None:
        return None
    if gesto not in GESTI_VIVI:
        return 'DORMIENTE', f'il gesto {gesto} non arriva alla regia'
    return f"GestiCompiuti('{gesto}', 1)", None


def regolaConteggio(v, testo):
    """L'ultima spiaggia: quante volte un gesto e' stato compiuto."""
    gesto = gestoIn(testo)
    if gesto is None:
        return None
    if gesto not in GESTI_VIVI:
        return 'DORMIENTE', f'il gesto {gesto} non arriva alla regia'
    quanti = numeroIn(testo) or 1
    inGiorniDiversi = 'giorni diversi' in testo
    if inGiorniDiversi:
        return (f"GestiCompiuti('{gesto}', {quanti}, inGiorniDiversi: true)",
                None)
    return f"GestiCompiuti('{gesto}', {quanti})", None


# --- LA VERIFICA, dopo la traduzione ---------------------------------------
#
# **UN TRAGUARDO CHE FINGE DI MISURARE E' PEGGIO DI UNO CHE ASPETTA.** Ordine BS
# voce 00. Una regola puo' produrre un costruttore ben formato che pero' nomina
# un gesto che nessuna schermata manda, un dettaglio che la scena non passa o un
# pezzo dell'identita' che non esiste: la condizione compila, non e' dormiente,
# e non si accendera' mai. E' successo davvero, e nessuno se n'era accorto.
#
# Qui si controlla ogni costruttore contro il vocabolario VERO dell'app, censito
# dal codice e non ricordato a memoria. Cio' che non passa diventa dormiente col
# suo perche', come tutto il resto.

# I dettagli che ogni scena manda davvero, letti uno per uno dalle chiamate a
# `dopoUnGesto`. Un dettaglio fuori da qui e' un dettaglio che non viaggia.
DETTAGLI_VIVI = {
    'stesa': {'carte', 'semi', 'maggiori', 'argomento'},
    'gettata': {'modo'},
    'tramonto': {'runa'},
    'sinastria': {'vip'},
    'oroscopo': {'periodo'},
    'archetipo': {'archetipo'},
    'animale_guida': {'animale'},
}

# I pezzi dell'identita' che maturano davvero: i nove di
# `PezziDellIdentita.tutti` piu' i quattro composti che
# `RegiaDelCammino.pezziDellIdentitaMaturi` aggiunge.
PEZZI_VIVI = {
    'carta_natale', 'passaporto', 'angelo_custode', 'animale_guida',
    'archetipo', 'viso', 'numero_della_vita', 'ora_di_nascita',
    'luogo_di_nascita',
    'nascita_completa', 'sigillo_del_cerchio', 'luna_natale', 'nome_proprio',
}

# I gesti del Cerchio che la regia deriva davvero.
CERCHIO_VIVI = {'condivisione_stella', 'condivisione_frutto',
                'condivisione_petalo'}

# I riti su cui il diario tiene una serie di giorni.
RITI_VIVI = set(GESTI_VIVI) | {'presenza'}


def verifica(costruttore):
    """Il motivo per cui questo costruttore non potrebbe accendersi mai."""
    m = re.match(r"(\w+)\((.*)\)$", costruttore, re.S)
    if m is None:
        return None
    forma, dentro = m.group(1), m.group(2)
    pezzi = [p.strip().strip(chr(39)) for p in dentro.split(',')]
    if forma in ('VarietaDelDettaglio', 'CoincidenzaDelDettaglio'):
        gesto, chiave = pezzi[0], pezzi[1]
        if gesto not in DETTAGLI_VIVI:
            return (f'il gesto {gesto} non passa nessun dettaglio alla regia, '
                    f'quindi la varieta di {chiave} non si puo contare')
        if chiave not in DETTAGLI_VIVI[gesto]:
            return (f'il dettaglio {chiave} non viaggia col gesto {gesto}: la '
                    f'scena manda {", ".join(sorted(DETTAGLI_VIVI[gesto]))}')
    elif forma == 'PezzoDellIdentita':
        if pezzi[0] not in PEZZI_VIVI:
            return (f'il pezzo dell identita {pezzi[0]} non matura mai: non e '
                    'fra quelli che la regia compone')
    elif forma == 'GestoDelCerchio':
        if pezzi[0] not in CERCHIO_VIVI:
            return (f'il gesto del Cerchio {pezzi[0]} non arriva alla regia')
    elif forma in ('GiorniDiSeguito', 'GiorniDentroUnArco'):
        if pezzi[0] not in RITI_VIVI:
            return f'il rito {pezzi[0]} non arriva alla regia'
    elif forma == 'GestiCompiuti':
        if pezzi[0] not in GESTI_VIVI:
            return f'il gesto {pezzi[0]} non arriva alla regia'
    elif forma == 'GestiNelloStessoGiorno':
        for g in re.findall(chr(39) + r"(\w+)" + chr(39), dentro):
            if g not in GESTI_VIVI:
                return f'il gesto {g} non arriva alla regia'
    elif forma == 'GradiniAlleSpalle':
        if pezzi[0] not in ('costellazione', 'albero', 'loto'):
            return f'il sentiero {pezzi[0]} non esiste'
    return None


REGOLE = [
    regolaDormienteDichiarato,
    # **CIO' CHE NON SI PUO' COSTRUIRE VIENE PRIMA DI TUTTO IL RESTO**, e
    # l'ordine e' la sostanza: messa in fondo, una regola piu' generosa
    # arrivava prima e traduceva "dodici Lune del tuo segno" in "una Luna nel
    # tuo segno", cioe' un traguardo lungo un anno diventava lo stesso di uno
    # da un giorno.
    regolaNonCostruibile,
    regolaGradini,
    regolaVarieta,
    regolaCoincidenza,
    regolaCielo,
    regolaCostanzaLarga,
    regolaCostanzaDentro,
    regolaModiDellaGettata,
    regolaGiorniDiSeguito,
    regolaStessoGiorno,
    regolaRitorno,
    regolaMemoria,
    regolaIdentita,
    regolaCondivisione,
    regolaScoperta,
    regolaConteggio,
]


FAMIGLIE = {
    # **LE RAGIONI DELLA REVISIONE E.** Ordine BS voce 01: la E scrive
    # "Profondita'" e "Identita'" con l'apostrofo e aggiunge "Ritorno" e
    # "Perla". Senza queste righe ogni dormiente di quelle ragioni finiva nella
    # famiglia di ripiego, e i minimi di famiglia cadevano su tre sentieri per
    # un motivo che non c'entrava niente col cammino.
    "Profondita'": 'profondita',
    "Identita'": 'identita',
    'Ritorno': 'ritorno',
    'Perla': 'profondita',
    'Cielo': 'cielo',
    'Costanza': 'ritorno',
    'Coincidenza': 'giornata',
    'Profondità': 'profondita',
    'Dedizione': 'profondita',
    'Legame': 'cerchio',
    'Identità': 'identita',
    'Prima volta': 'ampiezza',
}

SENTIERI = {
    'med': ('costellazione', 'sentieroDellaCostellazione',
            'sentiero_costellazione'),
    'cal': ('albero', 'sentieroDellAlbero', 'sentiero_albero'),
    'aur': ('loto', 'sentieroDelLoto', 'sentiero_loto'),
}


# **I NOMI DEI DONI CAMBIANO, E IL CORPUS NON LO SA. Ordine AS voce 08.**
#
# L'Oracolo del Giorno e' diventato l'Arcano del Giorno, e il Rito del Sogno il
# Sigillo del Sogno: sono decisioni di prodotto prese DOPO che il corpus era
# stato scritto, e le frasi dei traguardi continuano a nominare i doni col nome
# vecchio. Correggerle a valle, dentro i file Dart generati, sarebbe inutile: al
# primo rigenero tornerebbero.
#
# Qui la traduzione avviene mentre si scrive, ed e' un elenco dichiarato invece
# di una sostituzione sparsa: chi rinomina un dono domani sa dove aggiungere la
# riga, e chi legge sa che quei nomi non vengono dal corpus.
NOMI_NUOVI_DEI_DONI = {
    'Oracolo del Giorno': 'Arcano del Giorno',
    'Rito del Sogno': 'Sigillo del Sogno',
}


# --- GLI ACCENTI VERI, e non l'apostrofo -----------------------------------
#
# **IL CORPUS SCRIVE "e\'" E "Meta\'", L'APP DEVE MOSTRARE "è" E "Metà".** Il
# corpus e' un file di lavoro e chi lo scrive batte l'apostrofo; le stringhe che
# finiscono a video, invece, hanno una regola di casa sorvegliata da
# `testo_a_video_test`: l'accento e' un accento, non un apostrofo, perche' a
# video la differenza si vede e fa sembrare l'app scritta male.
#
# **Non e' una riformulazione**: la parola resta identica, cambia il segno che
# la chiude. I testi del corpus si usano verbatim, e questa e' ortografia, non
# scrittura.
VOCALI_ACCENTATE = {'a': 'à', 'e': 'è', 'i': 'ì', 'o': 'ò', 'u': 'ù'}

# Le parole che vogliono l'accento ACUTO e non grave: sono quelle in -che' e i
# due monosillabi ne' e se'.
ACUTE = ('che', 'ne', 'se')


def _accentaParola(parola):
    corpo = parola[:-1]
    if not corpo:
        return parola
    ultima = corpo[-1].lower()
    if ultima not in VOCALI_ACCENTATE:
        return parola
    if any(corpo.lower().endswith(a) for a in ACUTE):
        accentata = 'é'
    else:
        accentata = VOCALI_ACCENTATE[ultima]
    if corpo[-1].isupper():
        accentata = accentata.upper()
    return corpo[:-1] + accentata


def conGliAccenti(testo):
    """La stessa frase, con gli accenti veri al posto degli apostrofi."""
    return re.sub(r"\b\w+'(?![a-zA-Z])",
                  lambda m: _accentaParola(m.group(0)), testo)


def coiNomiNuovi(testo):
    """La frase del corpus, coi doni chiamati col loro nome di oggi."""
    for vecchio, nuovo in NOMI_NUOVI_DEI_DONI.items():
        testo = testo.replace(vecchio, nuovo)
    return conGliAccenti(testo)


def scappa(s):
    return s.replace(chr(92), chr(92) * 2).replace(chr(39), chr(92) + chr(39)).replace(chr(36), chr(92) + chr(36))


def costruisci(v):
    """Il costruttore Dart della condizione, o il motivo per cui dorme."""
    testo = senzaAccenti(v['condizione'])
    for regola in REGOLE:
        esito = regola(v, testo)
        if esito is None:
            continue
        costruttore, perche = esito
        if costruttore == 'DORMIENTE':
            return None, perche
        # **LA VERIFICA E' L'ULTIMA PAROLA**: una condizione ben formata che
        # nomina cio' che l'app non misura non passa di qui.
        storto = verifica(costruttore)
        if storto is not None:
            return None, storto
        return costruttore, None
    return None, 'nessuna regola riconosce questa condizione'


def main():
    corpus = json.loads(CORPUS.read_text(encoding='utf-8'))
    dormienti = []
    for sentiero in corpus['sentieri']:
        prefisso = sentiero['prefisso_id']
        nomeSentiero, nomeLista, nomeFile = SENTIERI[prefisso]
        righe = []
        for v in sentiero['voci']:
            v['_sentiero'] = nomeSentiero
            costruttore, perche = costruisci(v)
            eDormiente = costruttore is None
            if eDormiente:
                dormienti.append((v['id'], v['nome'], perche))
                # **UN DORMIENTE NON SI INVENTA E NON SPARISCE**: resta nel
                # dato con una condizione che nessuno stato soddisfa mai.
                # **UN DORMIENTE PORTA IL SUO PERCHE' NEL DATO.** Con una
                # condizione finta uguale per tutti sarebbero sembrati lo
                # stesso traguardo diciotto volte, e la guardia della legge
                # li avrebbe accusati di accendersi insieme.
                delCielo = (v.get('ragione') == 'Cielo'
                            or bool(v.get('finestra_del_cielo')))
                costruttore = (f"Dormiente('{v['id']}', "
                               f"'{scappa(conGliAccenti(perche))}'"
                               + (', eraDelCielo: true' if delCielo else '')
                               + ")")
            # **LA FAMIGLIA SEGUE LA CONDIZIONE, non l'etichetta.** La
            # ragione del corpus dice perche' quel traguardo esiste; la
            # famiglia dice di che natura e' la sua condizione, ed e' quello
            # che le guardie contano (quanti dipendono dal cielo, quanti non
            # si chiudono in giornata). Dedurla dal costruttore le tiene
            # allineate per costruzione.
            if costruttore.startswith('FinestraDelCielo'):
                famiglia = 'cielo'
            elif (costruttore.startswith('GiorniDiSeguito')
                  or costruttore.startswith('GiorniDentroUnArco')
                  or costruttore.startswith('RitornoDopoAssenza')):
                famiglia = 'ritorno'
            elif costruttore.startswith('GestiNelloStessoGiorno'):
                famiglia = 'giornata'
            elif costruttore.startswith('VarietaDelDettaglio') or                     costruttore.startswith('GradiniAlleSpalle'):
                famiglia = 'profondita'
            elif costruttore.startswith('CoincidenzaDelDettaglio') or                     costruttore.startswith('MemoriaDelCerchio'):
                famiglia = 'memoria'
            elif costruttore.startswith('PezzoDellIdentita'):
                famiglia = 'identita'
            elif costruttore.startswith('GestoDelCerchio'):
                famiglia = 'cerchio'
            elif costruttore.startswith('Dormiente'):
                famiglia = FAMIGLIE.get(v.get('ragione'), 'profondita')
            elif costruttore.startswith('GestiCompiuti') and                     not costruttore.endswith(', 1)'):
                # **UN GESTO RIPETUTO E' DEDIZIONE, non prima volta.** Ordine
                # BF voce 05.b: svegliando aur_51 (sette meditazioni) la
                # regola piatta "ogni conteggio e' ampiezza" lo strappava
                # dalla Profondita' dichiarata dal corpus e il minimo di
                # famiglia del Loto cadeva. SOLO Profondita' e Dedizione
                # contano qui: le altre ragioni restano ampiezza, perche' la
                # famiglia segue la condizione e un conteggio non dipende
                # dal cielo ne' dalla giornata qualunque etichetta porti.
                famiglia = ('profondita'
                            if v.get('ragione') in ('Profondità', 'Dedizione')
                            else 'ampiezza')
            else:
                famiglia = 'ampiezza'
            righe.append(
                "  Traguardo(\n"
                f"    id: '{v['id']}',\n"
                f"    nome: '{scappa(coiNomiNuovi(v['nome']))}',\n"
                f"    famiglia: FamigliaDelTraguardo.{famiglia},\n"
                f"    condizione: const {costruttore},\n"
                f"    frase: '{scappa(coiNomiNuovi(v['condizione']))}',\n"
                f"    posizione: {v['posizione']},\n"
                "    percheConta: FamigliaDelTraguardo."
                f"{famiglia}.percheContaLaFamiglia,\n"
                f"    cosaApre: '{scappa(coiNomiNuovi(v.get('porta_che_apre') or ''))}',\n"
                f"    eGrande: {str(bool(v['grande'])).lower()},\n"
                f"    eos: {v['eos']},\n"
                f"    fascia: '{scappa(conGliAccenti(v['fascia']))}',\n"
                f"    dormiente: {str(eDormiente).lower()},\n"
                f"    ragione: '{scappa(conGliAccenti(v.get('ragione') or ''))}',\n"
                f"    sezioneDelCammino: '{scappa(conGliAccenti(v.get('famiglia') or ''))}',\n"
                "  ),")
        testa = (
            "// GENERATO DA tool/genera_sentieri_dal_corpus.py: NON SI SCRIVE\n"
            "// A MANO. Ordine AR voce 02.\n"
            "//\n"
            f"// La fonte e' docs/corpus/{CORPUS.name}, e il\n"
            "// dato comanda: nomi, condizioni, fasce, Eos e porte vengono da\n"
            "// li' verbatim. Per cambiare un traguardo si cambia il corpus e\n"
            "// si rigenera, mai il contrario.\n\n"
            "import 'eventi_del_cielo.dart';\n"
            "import 'traguardo.dart';\n\n"
            f"final List<Traguardo> {nomeLista} = [\n")
        (RADICE / 'lib' / 'core' / 'sigilli' / f'{nomeFile}.dart').write_text(
            testa + '\n'.join(righe) + '\n];\n', encoding='utf-8')
    print(f'generati tre sentieri, dormienti {len(dormienti)}')
    for id_, nome, perche in dormienti:
        print(f'  {id_} "{nome}": {perche}')


if __name__ == '__main__':
    main()
