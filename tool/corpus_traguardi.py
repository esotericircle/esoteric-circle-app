# -*- coding: utf-8 -*-
"""IL CORPUS DEI TRAGUARDI, REVISIONE F. Ordine CP voce 05, 3 settembre 2026.

**Riscritto da zero**, non corretto. Parole del fondatore: *"riscriviamo tutti
i traguardi da zero con regole definitive."*

**La condizione si dichiara, non si deduce.** Il corpus della revisione E
scriveva la condizione in italiano e un generatore di milleseicento righe la
traduceva in codice riconoscendo il testo: cambiare una parola nella frase
cambiava ciò che l'app misurava. Qui ogni gradino porta la sua condizione in
forma strutturata, e il generatore la trascrive senza interpretare niente. La
frase italiana resta come DESCRIZIONE, e non puo' piu' contraddire il codice
perche' non lo genera.

Le regole che governano questo file stanno in `docs/regole_dei_traguardi.md`,
e la prova che le verifica su ogni singolo gradino e'
`test/le_regole_dei_traguardi_sono_rispettate_test.dart`.

Uso:
    python tool/corpus_traguardi.py            scrive il JSON e i tre Dart
    python tool/corpus_traguardi.py --conta    stampa i conti e non scrive
"""
import io
import json
import os
import sys

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# ---------------------------------------------------------------------------
# L'ATTESA TIPICA DEGLI EVENTI DEL CIELO, in giorni.
#
# Non e' una probabilita': e' quanto si aspetta al peggio ragionevole. Un
# evento raro vale come traguardo solo se l'attesa e' quella dichiarata.
# ---------------------------------------------------------------------------
ATTESA = {
    'luna_crescente': 2,
    'luna_calante': 2,
    'primo_quarto': 8,
    'ultimo_quarto': 8,
    'luna_piena': 15,
    'luna_nuova': 15,
    'luna_nel_tuo_segno': 28,
    'luna_nel_segno_opposto': 28,
    'transito_sulla_luna': 30,
    'transito_sull_ascendente': 45,
    'transito_sul_sole': 45,
    'transito_su_venere': 60,
    'transito_su_marte': 60,
    'mercurio_retrogrado': 60,
    'eclissi': 90,
    'solstizio': 91,
    'equinozio': 91,
    'mercurio_diretto': 120,
    'giove_retrogrado': 120,
    'saturno_retrogrado': 120,
    'sole_nel_tuo_segno': 180,
    'tre_transiti_insieme': 180,
    'giove_diretto': 240,
    'saturno_diretto': 240,
    'venere_retrograda': 290,
    'venere_diretta': 290,
    'marte_retrogrado': 390,
    'marte_diretto': 390,
    'luna_piena_nel_tuo_segno': 365,
    'luna_nuova_nel_tuo_segno': 365,
    'ritorno_solare': 365,
}

# L'evento detto in italiano, per la frase che la persona legge.
INPAROLE = {
    'luna_crescente': 'la Luna cresce',
    'luna_calante': 'la Luna cala',
    'primo_quarto': 'la Luna è al primo quarto',
    'ultimo_quarto': 'la Luna è all’ultimo quarto',
    'luna_piena': 'la Luna è piena',
    'luna_nuova': 'la Luna è nuova',
    'luna_nel_tuo_segno': 'la Luna passa nel tuo segno',
    'luna_nel_segno_opposto': 'la Luna sta nel segno opposto al tuo',
    'transito_sulla_luna': 'un pianeta transita sulla tua Luna',
    'transito_sull_ascendente': 'un pianeta transita sul tuo Ascendente',
    'transito_sul_sole': 'un pianeta transita sul tuo Sole',
    'transito_su_venere': 'un pianeta transita sulla tua Venere',
    'transito_su_marte': 'un pianeta transita sul tuo Marte',
    'mercurio_retrogrado': 'Mercurio è retrogrado',
    'eclissi': 'il cielo porta un’eclissi',
    'solstizio': 'il Sole tocca il solstizio',
    'equinozio': 'il Sole tocca l’equinozio',
    'mercurio_diretto': 'Mercurio torna diretto',
    'giove_retrogrado': 'Giove è retrogrado',
    'saturno_retrogrado': 'Saturno è retrogrado',
    'sole_nel_tuo_segno': 'il Sole attraversa il tuo segno',
    'tre_transiti_insieme': 'tre transiti si affacciano insieme',
    'giove_diretto': 'Giove torna diretto',
    'saturno_diretto': 'Saturno torna diretto',
    'venere_retrograda': 'Venere è retrograda',
    'venere_diretta': 'Venere torna diretta',
    'marte_retrogrado': 'Marte è retrogrado',
    'marte_diretto': 'Marte torna diretto',
    'luna_piena_nel_tuo_segno': 'la Luna è piena nel tuo segno',
    'luna_nuova_nel_tuo_segno': 'la Luna è nuova nel tuo segno',
    'ritorno_solare': 'il Sole torna dov’era quando sei nato',
}

# Il gesto detto in italiano: il nome dell'arte come la persona la chiama.
ARTE = {
    'carta_natale': ('la carta natale', 'calcoli la tua carta natale'),
    'ascendente': ('l’Ascendente', 'scopri il tuo Ascendente'),
    'oroscopo': ('l’Oroscopo', 'interroghi il cielo'),
    'stesa': ('la stesa di tarocchi', 'stendi le tre carte'),
    'oracolo': ('l’Arcano del Giorno', 'scopri l’Arcano del Giorno'),
    'sinastria': ('la Sinastria VIP', 'confronti il tuo cielo con un volto'),
    'angelo_custode': ('l’Angelo Custode', 'chiami il tuo Angelo Custode'),
    'alba': ('il Rito dell’Alba', 'compi il Rito dell’Alba'),
    'soffio': ('il Soffio del Destino', 'liberi il Soffio del Destino'),
    'viso': ('la Costellazione del Viso',
             'leggi la tua Costellazione del Viso'),
    'archetipo': ('l’Archetipo', 'trovi il tuo Archetipo'),
    'due_volti': ('i Due Volti', 'metti a confronto i tuoi due volti'),
    'meditazione': ('la Meditazione', 'porti a termine una Meditazione'),
    'gettata': ('la gettata di rune', 'getti le rune'),
    'tramonto': ('la Runa del Tramonto', 'ricevi la Runa del Tramonto'),
    'sogno': ('il Sigillo del Sogno', 'chiudi il giorno col Sigillo del Sogno'),
    'runa_girata': ('la runa girata', 'giri la pietra fra le dita'),
    'sigillo': ('il Sigillo d’Intenzione', 'incidi un Sigillo d’Intenzione'),
    'animale_guida': ('l’Animale Guida', 'incontri il tuo Animale Guida'),
    'bosco': ('il Bosco del Cerchio', 'entri nel Bosco del Cerchio'),
}

# I riti che tengono una serie di giorni, per GiorniDentroUnArco.
RITI = {'alba', 'tramonto', 'oracolo', 'sogno', 'soffio'}

# Le chiavi di dettaglio che una schermata manda DAVVERO. Nessun gradino puo'
# nominarne una che non sia qui: e' la regola di forma numero 6.
DETTAGLI = {
    'sinastria': 'vip',
    'viso': 'tratto',
    'stesa': 'semi',
    'tramonto': 'runa',
    'oroscopo': 'periodo',
    'gettata': 'modo',
    'archetipo': 'archetipo',
    'oracolo': 'arcano',
    'animale_guida': 'animale',
}
DETTAGLIO_INPAROLE = {
    'vip': 'volti diversi', 'tratto': 'tratti dominanti diversi',
    'semi': 'semi diversi', 'runa': 'rune diverse',
    'periodo': 'orizzonti diversi', 'modo': 'modi diversi',
    'archetipo': 'archetipi diversi', 'arcano': 'Arcani diversi',
    'animale': 'animali diversi',
}

# Gli Eos, invariati dalla revisione E: mini e grande per fascia.
EOS_MINI = [10, 20, 30, 45, 55]
EOS_GRANDE = [40, 60, 80, 100, 130]
FASCE = ['Primi giorni', 'Prima settimana', 'Primo mese', 'La stagione',
         "L'anno"]
# **LE BANDE, in giorni.** La prima arriva a otto e non a sette perche' il
# gradino grande della prima fascia e' una finestra del cielo, e il primo
# quarto di Luna si aspetta al peggio otto giorni: la banda segue il cielo,
# non il contrario.
BANDE = [(1, 8), (9, 30), (31, 90), (91, 190), (191, 365)]

# **LA FAMIGLIA SEGUE LA CONDIZIONE**, e non e' una scelta libera: le guardie
# contano le famiglie per sapere di che natura e' un sentiero, e una famiglia
# scritta a mano direbbe di un gradino una cosa che il suo codice non fa.
FAMIGLIA = {
    'PezzoDellIdentita': 'identita',
    'GestiCompiuti': 'profondita',
    'VarietaDelDettaglio': 'profondita',
    'GiorniDentroUnArco': 'ritorno',
    'GiorniDiSeguito': 'ritorno',
    'StessaOraPerGiorni': 'ritorno',
    'GestoNellOraGiusta': 'cielo',
    'FinestraDelCielo': 'cielo',
    'GestoDelCerchio': 'cerchio',
}

# La ragione, con la parola del corpus: dice PERCHE' il gradino e' stato
# scritto, dove la famiglia dice di che natura e' la sua condizione.
RAGIONE = {
    'PezzoDellIdentita': 'Identita',
    'GestiCompiuti': 'Profondita',
    'VarietaDelDettaglio': 'Profondita',
    'GiorniDentroUnArco': 'Costanza',
    'GiorniDiSeguito': 'Costanza',
    'StessaOraPerGiorni': 'Costanza',
    'GestoNellOraGiusta': 'Cielo',
    'FinestraDelCielo': 'Cielo',
    'GiornateInsieme': 'Legame',
    'GestoDelCerchio': 'Legame',
}


def famigliaDi(c):
    """**Due gesti nello stesso giorno sono una giornata chiusa, tre o piu'
    sono ampiezza fra le arti.** Non e' una sfumatura: una coppia si chiude
    dentro un rito solo, tre arti obbligano ad attraversare il Cerchio."""
    if c['tipo'] == 'GiornateInsieme':
        return 'giornata' if len(c['gesti']) == 2 else 'ampiezza'
    return FAMIGLIA[c['tipo']]


def costo(c):
    """Il costo in giorni di una condizione dichiarata."""
    t = c['tipo']
    if t == 'Dormiente':
        return None
    if t == 'GestiCompiuti':
        return c['quanti'] if c.get('inGiorniDiversi') else 1
    if t in ('GiorniDentroUnArco', 'GiorniDiSeguito'):
        return c['quanti']
    if t == 'StessaOraPerGiorni':
        return c['quantiGiorni']
    if t == 'GestoNellOraGiusta':
        return c.get('quanteVolte', 1)
    if t == 'GestiNelloStessoGiorno':
        return 1
    if t in ('VarietaDelDettaglio', 'VarietaPerValore'):
        return c['quanti']
    if t == 'RitornoAlMaestro':
        return c['giorniDiAssenza'] + 1
    if t == 'RitornoAlRito':
        return c['giorniSaltati'] + 1
    if t == 'RitornoDopoAssenza':
        return c['giorniDiAssenza'] + 1
    if t == 'FinestraDelCielo':
        return ATTESA[c['evento']]
    if t == 'PezzoDellIdentita':
        return 1
    if t == 'GestoDelCerchio':
        return c['quanti']
    if t == 'GiornateInsieme':
        return c['quantiGiorni']
    raise SystemExit('condizione senza costo dichiarato: %s' % t)


# --- le forme brevi con cui si scrivono i gradini --------------------------
def prima(g):
    return {'tipo': 'GestiCompiuti', 'gesto': g, 'quanti': 1}


def volte(g, n):
    return {'tipo': 'GestiCompiuti', 'gesto': g, 'quanti': n,
            'inGiorniDiversi': True}


def arco(r, n, a):
    return {'tipo': 'GiorniDentroUnArco', 'rito': r, 'quanti': n, 'arco': a}


def seguito(r, n):
    return {'tipo': 'GiorniDiSeguito', 'rito': r, 'quanti': n}


def cielo(ev, g=None):
    c = {'tipo': 'FinestraDelCielo', 'evento': ev}
    if g:
        c['conGesto'] = g
    return c


def ora(g, quando, n=1):
    return {'tipo': 'GestoNellOraGiusta', 'gesto': g, 'ora': quando,
            'quanteVolte': n}


def stessaOra(g, n):
    return {'tipo': 'StessaOraPerGiorni', 'gesto': g, 'quantiGiorni': n}


def varieta(g, n):
    return {'tipo': 'VarietaDelDettaglio', 'gesto': g,
            'chiave': DETTAGLI[g], 'quanti': n}


def insieme(gesti):
    return {'tipo': 'GestiNelloStessoGiorno', 'gesti': gesti}


def ritorno(sent, n):
    return {'tipo': 'RitornoAlMaestro', 'sentiero': sent, 'giorniDiAssenza': n}


def pezzo(p):
    return {'tipo': 'PezzoDellIdentita', 'pezzo': p}


def cerchio(g, n):
    return {'tipo': 'GestoDelCerchio', 'gesto': g, 'quanti': n}


def giornate(gesti, n):
    """In quanti giorni DIVERSI tutti quei gesti sono caduti insieme."""
    return {'tipo': 'GiornateInsieme', 'gesti': sorted(gesti),
            'quantiGiorni': n}
