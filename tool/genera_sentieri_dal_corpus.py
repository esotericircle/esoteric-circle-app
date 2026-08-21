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
CORPUS = RADICE / 'docs' / 'corpus' / 'Traguardi_165_Revisione_C.json'

# I gesti che l'app REGISTRA davvero, censiti sui punti che chiamano la regia.
# Una condizione che chiedesse un gesto fuori da questo elenco non potrebbe
# maturare mai, e infatti diventa dormiente.
GESTI_VIVI = {
    'alba', 'angelo_custode', 'animale_guida', 'archetipo', 'carta_natale',
    'gettata', 'luogo_di_nascita', 'numero_della_vita', 'ora_di_nascita',
    'oracolo', 'oroscopo', 'passaporto', 'sigillo', 'sinastria', 'soffio',
    'sogno', 'stesa', 'tramonto', 'viso',
}

# Come si chiama, nel corpus, ciascun gesto dell'app.
NOMI_DEI_GESTI = [
    # I PLURALI CONTANO: il corpus dice "Tre Oracoli del Giorno", e un elenco
    # che conosce solo il singolare lascia dormienti cinque traguardi veri.
    ('oracoli del giorno', 'oracolo'),
    ('oracoli', 'oracolo'),
    ('stese', 'stesa'),
    ('gettate', 'gettata'),
    ('sinastrie', 'sinastria'),
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
    'centoventi': 120, 'centottanta': 180, 'trecentosessantacinque': 365,
}

# Gli eventi del cielo, come li nomina il corpus.
EVENTI = [
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
        return 'DORMIENTE', v.get('note') or 'dichiarato dormiente dal corpus'
    return None


def regolaGradini(v, testo):
    if 'gradini alle spalle' not in testo:
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
    gesto = gestoIn(testo)
    if gesto is None:
        return f"FinestraDelCielo(EventiDelCielo.{evento})", None
    if gesto not in GESTI_VIVI:
        return 'DORMIENTE', f'il gesto {gesto} non arriva alla regia'
    return (f"FinestraDelCielo(EventiDelCielo.{evento}, conGesto: '{gesto}')",
            None)


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
    if 'assenza' not in testo and 'torni nel cerchio' not in testo:
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
    ]
    if v.get('ragione') != 'Identità':
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
    regolaGiorniDiSeguito,
    regolaStessoGiorno,
    regolaRitorno,
    regolaMemoria,
    regolaIdentita,
    regolaCondivisione,
    regolaConteggio,
]


FAMIGLIE = {
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


def coiNomiNuovi(testo):
    """La frase del corpus, coi doni chiamati col loro nome di oggi."""
    for vecchio, nuovo in NOMI_NUOVI_DEI_DONI.items():
        testo = testo.replace(vecchio, nuovo)
    return testo


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
                costruttore = (f"Dormiente('{v['id']}', "
                               f"'{scappa(perche)}')")
            # **LA FAMIGLIA SEGUE LA CONDIZIONE, non l'etichetta.** La
            # ragione del corpus dice perche' quel traguardo esiste; la
            # famiglia dice di che natura e' la sua condizione, ed e' quello
            # che le guardie contano (quanti dipendono dal cielo, quanti non
            # si chiudono in giornata). Dedurla dal costruttore le tiene
            # allineate per costruzione.
            if costruttore.startswith('FinestraDelCielo'):
                famiglia = 'cielo'
            elif costruttore.startswith('GiorniDiSeguito') or                     costruttore.startswith('RitornoDopoAssenza'):
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
                f"    fascia: '{scappa(v['fascia'])}',\n"
                f"    dormiente: {str(eDormiente).lower()},\n"
                "  ),")
        testa = (
            "// GENERATO DA tool/genera_sentieri_dal_corpus.py: NON SI SCRIVE\n"
            "// A MANO. Ordine AR voce 02.\n"
            "//\n"
            "// La fonte e' docs/corpus/Traguardi_165_Revisione_C.json, e il\n"
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
