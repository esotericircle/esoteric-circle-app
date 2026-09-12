# -*- coding: utf-8 -*-
"""GENERA LA REVISIONE F: il JSON del corpus e i tre file Dart dei sentieri.

Ordine CP voce 05, 3 settembre 2026.

**Qui non si interpreta niente.** Il generatore della revisione E leggeva la
condizione dall'italiano con milleseicento righe di riconoscimento del testo:
cambiare una parola nella frase cambiava cio' che l'app misurava. Qui la
condizione arriva gia' strutturata da `corpus_traguardi_dati.py` e si trascrive;
**la frase che la persona legge si COMPONE dalla condizione**, quindi non puo'
contraddirla nemmeno volendo.

Uso:
    python tool/genera_corpus_f.py            scrive il JSON e i tre Dart
    python tool/genera_corpus_f.py --conta    stampa i conti e non scrive
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import corpus_traguardi as ct  # noqa: E402
import corpus_traguardi_dati as dati  # noqa: E402

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

EOS_MINI = ct.EOS_MINI
EOS_GRANDE = ct.EOS_GRANDE
FASCE = ct.FASCE

# Il nome Dart della costante del cielo, dal nome in serpente del corpus.
def _camel(evento):
    pezzi = evento.split('_')
    return pezzi[0] + ''.join(p.capitalize() for p in pezzi[1:])


def _arte(gesto):
    return ct.ARTE[gesto][0]


def _maiuscola(s):
    """La prima lettera maiuscola, **e il resto intatto**.

    `str.capitalize()` abbassa tutto il resto: "la Luna e' piena" diventava
    "La luna e' piena", e il nome proprio della Luna spariva. Il difetto e'
    arrivato in venti frasi su centosessantacinque prima che qualcuno le
    leggesse.
    """
    return s[:1].upper() + s[1:]


# L'ora rituale con la sua preposizione: "dell'alba", "del tramonto", "della
# notte". Senza questa tavola il composto scriveva "dell'tramonto".
ORA_INPAROLE = {
    'alba': 'dell\u2019alba',
    'tramonto': 'del tramonto',
    'notte': 'della notte',
}


def _elenco(voci):
    """Un elenco italiano: a, b e c. Mai la virgola prima della e."""
    if len(voci) == 1:
        return voci[0]
    return '%s e %s' % (', '.join(voci[:-1]), voci[-1])


def frase(c):
    """LA FRASE DELLA FESTA, composta dalla condizione.

    **Non e' scritta a mano, ed e' il punto.** Una frase scritta a mano puo'
    dire cinque dove il codice conta sette, e nessuno se ne accorge finche' un
    utente non conta i giorni. Qui i numeri della frase SONO i numeri della
    condizione, perche' vengono dallo stesso dato.
    """
    t = c['tipo']
    if t == 'PezzoDellIdentita':
        return ('Hai dato al Cerchio %s: da adesso ogni responso parte da qui.'
                % _arte(c['pezzo']))
    if t == 'GestiCompiuti':
        if c.get('inGiorniDiversi'):
            return ('Hai compiuto %s in %d giorni diversi.'
                    % (_arte(c['gesto']), c['quanti']))
        return 'Hai compiuto %s per la prima volta.' % _arte(c['gesto'])
    if t == 'GiorniDentroUnArco':
        return ('%d giorni con %s negli ultimi %d: nessuno te l’ha '
                'chiesto.'
                % (c['quanti'], _arte(c['rito']), c['arco']))
    if t == 'StessaOraPerGiorni':
        return ('%d giorni alla stessa ora con %s: l’abitudine ha trovato il '
                'suo posto.' % (c['quantiGiorni'], _arte(c['gesto'])))
    if t == 'GestoNellOraGiusta':
        # **LA CODA SPIEGATIVA E' USCITA DALLA FRASE.** Ordine CP voce 05,
        # coda: diceva "quella del cielo e non quella dell’orologio" e
        # portava la frase a centouno caratteri. Una spiegazione nel momento
        # della festa e' una spiegazione che nessuno legge: quel che l'ora
        # rituale sia lo dice la porta che il gradino apre.
        return ('%d volte %s nell’ora vera %s.'
                % (c['quanteVolte'], _arte(c['gesto']),
                   ORA_INPAROLE[c['ora']]))
    if t == 'FinestraDelCielo':
        return ('%s: tu eri qui con %s.'
                % (_maiuscola(ct.INPAROLE[c['evento']]),
                   _arte(c['conGesto'])))
    if t == 'GiornateInsieme':
        # **DUE ARTI SI NOMINANO, TRE O PIU' SI CONTANO.** Ordine CP voce 05,
        # coda: enumerarne sei dava una frase di centosettantotto caratteri,
        # contro i sessantasei della revisione precedente. Nel momento della
        # festa un elenco di sei nomi non si legge, si scorre.
        if len(c['gesti']) <= 2:
            return ('%d giornate chiuse con %s, nello stesso giorno.'
                    % (c['quantiGiorni'],
                       _elenco([_arte(g) for g in c['gesti']])))
        return ('%d giornate con %d arti diverse, nello stesso giorno.'
                % (c['quantiGiorni'], len(c['gesti'])))
    raise SystemExit('condizione senza frase: %s' % t)


# **E LA ACCA MUTA**, che in italiano si elide come una vocale: "il cielo
# che l’ha attraversato" e' scritto giusto.
VOCALI = 'aeiouàèéìòùhAEIOUH'


def controllaLaFrase(frase, condizione, chi):
    """**IL GENERATORE SI RIFIUTA DI SCRIVERE UNA FRASE SGRAMMATICATA.**

    Due difetti veri, trovati LEGGENDO le frasi generate il 3 settembre
    2026. Il primo: dell’tramonto, nato da una preposizione incollata
    senza tavola. Il secondo: L’arcano del giorno, nato da capitalize(),
    che alza la prima lettera e ABBASSA tutto il resto.

    Una lettura a video li avrebbe visti; **una prova che conta i gradini
    no**, ed e' il motivo per cui il controllo sta qui, dove la frase
    nasce, invece che in una guardia che conta.
    """
    for elisione in ('l’', 'L’'):
        for pezzo in frase.split(elisione)[1:]:
            if pezzo and pezzo[0] not in VOCALI:
                raise SystemExit('%s: elisione davanti a consonante in "%s"'
                                 % (chi, frase))
    # **CHI SI CONTA NON SI NOMINA.** Le frasi che dicono "tre arti diverse"
    # non nominano le arti per scelta, e pretendere il nome le farebbe
    # rifiutare: qui si pretende allora il NUMERO, che e' cio' che promettono.
    gesti = gestiDi(condizione)
    if condizione['tipo'] == 'GiornateInsieme' and len(gesti) > 2:
        if '%d arti diverse' % len(gesti) not in frase:
            raise SystemExit('%s: la frase non dice quante arti sono: "%s"'
                             % (chi, frase))
        return frase
    for gesto in gesti:
        if _arte(gesto) not in frase:
            raise SystemExit('%s: la frase non nomina "%s": "%s"'
                             % (chi, _arte(gesto), frase))
    return frase


def dart(c):
    """La condizione trascritta in Dart, verbatim dal dato."""
    t = c['tipo']
    if t == 'PezzoDellIdentita':
        return "const PezzoDellIdentita('%s')" % c['pezzo']
    if t == 'GestiCompiuti':
        if c.get('inGiorniDiversi'):
            return ("const GestiCompiuti('%s', %d, inGiorniDiversi: true)"
                    % (c['gesto'], c['quanti']))
        return "const GestiCompiuti('%s', %d)" % (c['gesto'], c['quanti'])
    if t == 'GiorniDentroUnArco':
        return ("const GiorniDentroUnArco('%s', %d, %d)"
                % (c['rito'], c['quanti'], c['arco']))
    if t == 'StessaOraPerGiorni':
        return ("const StessaOraPerGiorni('%s', %d)"
                % (c['gesto'], c['quantiGiorni']))
    if t == 'GestoNellOraGiusta':
        return ("const GestoNellOraGiusta('%s', '%s', quanteVolte: %d)"
                % (c['gesto'], c['ora'], c['quanteVolte']))
    if t == 'FinestraDelCielo':
        return ("const FinestraDelCielo(EventiDelCielo.%s, conGesto: '%s')"
                % (_camel(c['evento']), c['conGesto']))
    if t == 'GiornateInsieme':
        gesti = ', '.join("'%s'" % g for g in c['gesti'])
        return ("const GiornateInsieme([%s], %d)" % (gesti, c['quantiGiorni']))
    raise SystemExit('condizione senza forma Dart: %s' % t)


def gestiDi(c):
    """I gesti che la condizione nomina. Serve alla regola 2, che vieta a due
    gradini di pari costo di nominare lo stesso gesto."""
    t = c['tipo']
    if t in ('GestiCompiuti', 'StessaOraPerGiorni', 'GestoNellOraGiusta',
             'VarietaDelDettaglio', 'GestoDelCerchio'):
        return [c['gesto']]
    if t in ('GiorniDentroUnArco', 'GiorniDiSeguito'):
        return [c['rito']]
    if t == 'FinestraDelCielo':
        return [c['conGesto']]
    if t == 'GiornateInsieme':
        return list(c['gesti'])
    if t == 'PezzoDellIdentita':
        return [c['pezzo']]
    return []


def costruisci():
    """I 165, con posizione, fascia, Eos e famiglia gia' decisi dal dato."""
    fuori = []
    for sigla, titolo, maestro, prefisso, voci, sezioni in dati.SENTIERI:
        if len(voci) != 55:
            raise SystemExit('%s ha %d voci invece di 55' % (sigla, len(voci)))
        gradini = []
        for indice, (cond, nome, porta) in enumerate(voci):
            posizione = indice + 1
            fascia = (posizione - 1) // 11
            eGrande = posizione % 11 == 0
            gradini.append({
                'id': '%s_%d' % (prefisso, posizione),
                'nome': nome,
                'posizione': posizione,
                'fascia': FASCE[fascia],
                'sezione': sezioni[fascia],
                'eGrande': eGrande,
                'eos': EOS_GRANDE[fascia] if eGrande else EOS_MINI[fascia],
                'famiglia': ct.famigliaDi(cond),
                'ragione': ct.RAGIONE[cond['tipo']],
                'condizione': cond,
                'costoInGiorni': ct.costo(cond),
                'frase': controllaLaFrase(
                    frase(cond), cond,
                    '%s_%d' % (prefisso, posizione)),
                'cosaApre': porta,
                'gestiNominati': gestiDi(cond),
            })
        fuori.append({
            'sentiero': sigla,
            'titolo': titolo,
            'maestro': maestro,
            'prefisso': prefisso,
            'gradini': gradini,
        })
    return fuori


INTESTAZIONE = '''// GENERATO DA tool/genera_corpus_f.py: NON SI SCRIVE A MANO.
// Ordine CP voce 05, 3 settembre 2026.
//
// La fonte e' docs/corpus/Traguardi_165_Revisione_F.json, scritto a sua
// volta da tool/corpus_traguardi_dati.py. **La condizione si dichiara,
// non si deduce**: qui non c'e' nessun riconoscimento di testo, la
// condizione arriva strutturata e si trascrive. La frase che la persona
// legge si compone DALLA condizione, quindi non puo' contraddirla.
//
// Per cambiare un traguardo si cambia il dato e si rigenera, mai il
// contrario. Le regole stanno in docs/regole_dei_traguardi.md.

import 'eventi_del_cielo.dart';
import 'traguardo.dart';

'''

NOMEVAR = {
    'costellazione': 'sentieroDellaCostellazione',
    'loto': 'sentieroDelLoto',
    'albero': 'sentieroDellAlbero',
}


def _stringa(s):
    """Una stringa Dart a virgolette singole, con gli apostrofi protetti."""
    return "'%s'" % s.replace('\\', '\\\\').replace("'", "\\'")


def scriviDart(sentiero):
    righe = [INTESTAZIONE,
             'final List<Traguardo> %s = [\n' % NOMEVAR[sentiero['sentiero']]]
    for g in sentiero['gradini']:
        righe.append('  Traguardo(\n')
        righe.append('    id: %s,\n' % _stringa(g['id']))
        righe.append('    nome: %s,\n' % _stringa(g['nome']))
        righe.append('    famiglia: FamigliaDelTraguardo.%s,\n' % g['famiglia'])
        righe.append('    condizione: %s,\n' % dart(g['condizione']))
        righe.append('    frase: %s,\n' % _stringa(g['frase']))
        righe.append('    posizione: %d,\n' % g['posizione'])
        righe.append('    percheConta: FamigliaDelTraguardo.%s'
                     '.percheContaLaFamiglia,\n' % g['famiglia'])
        righe.append('    cosaApre: %s,\n' % _stringa(g['cosaApre']))
        righe.append('    eGrande: %s,\n' % ('true' if g['eGrande'] else 'false'))
        righe.append('    eos: %d,\n' % g['eos'])
        righe.append('    fascia: %s,\n' % _stringa(g['fascia']))
        righe.append('    dormiente: false,\n')
        righe.append('    ragione: %s,\n' % _stringa(g['ragione']))
        righe.append('    sezioneDelCammino: %s,\n' % _stringa(g['sezione']))
        righe.append('  ),\n')
    righe.append('];\n')
    return ''.join(righe)


MAESTRO_INTESTAZIONE = '''// GENERATO DA tool/genera_corpus_f.py: NON SI SCRIVE A MANO.
// Ordine CP voce 05.
//
// **Di chi e' un gesto.** Non e' una scelta di questo file: e' cio' che il
// corpus dichiara, perche' un gesto compare nelle condizioni di un sentiero
// solo. Serve ai gradini del ritorno, che chiedono da quanti giorni non si
// cercava QUEL Maestro.
//
// I gesti nominati da piu' sentieri non entrano qui: non sono di nessuno, e
// una mappa che rispondesse lo stesso direbbe il falso.

const Map<String, String> sentieroDelGesto = {
'''


def scriviMaestroDelGesto(sentieri):
    di = {}
    for s in sentieri:
        for g in s['gradini']:
            for gesto in g['gestiNominati']:
                di.setdefault(gesto, set()).add(s['sentiero'])
    righe = [MAESTRO_INTESTAZIONE]
    for gesto in sorted(di):
        if len(di[gesto]) == 1:
            righe.append("  '%s': '%s',\n" % (gesto, list(di[gesto])[0]))
    righe.append('};\n')
    return ''.join(righe)


ATTESA_INTESTAZIONE = '''// GENERATO DA tool/genera_corpus_f.py: NON SI SCRIVE A MANO.
// Ordine CP voce 05.
//
// **L'ATTESA TIPICA DI OGNI EVENTO DEL CIELO, in giorni.** Non e' una
// probabilita': e' quanto si aspetta al peggio ragionevole, perche' un
// evento raro vale come traguardo solo se l'attesa e' quella che si
// dichiara. E' il costo in giorni di una FinestraDelCielo, cioe' la
// grandezza su cui poggia tutta la scala dei traguardi.
//
// La tavola vive in tool/corpus_traguardi.py e si rigenera: due tavole
// scritte a mano in due lingue sono due verita' che un giorno divergono.

const Map<String, int> attesaTipicaDelCielo = {
'''


def scriviAttesa():
    righe = [ATTESA_INTESTAZIONE]
    for evento in sorted(ct.ATTESA):
        righe.append("  '%s': %d,\n" % (evento, ct.ATTESA[evento]))
    righe.append('};\n')
    return ''.join(righe)


def main():
    sentieri = costruisci()
    soloConti = '--conta' in sys.argv

    if not soloConti:
        percorso = os.path.join(RADICE, 'docs', 'corpus',
                                'Traguardi_165_Revisione_F.json')
        with open(percorso, 'w', encoding='utf-8') as f:
            json.dump({'revisione': 'F', 'ordine': 'CP voce 05',
                       'sentieri': sentieri}, f, ensure_ascii=False, indent=2)
            f.write('\n')
        for s in sentieri:
            dove = os.path.join(RADICE, 'lib', 'core', 'sigilli',
                                'sentiero_%s.dart' % s['sentiero'])
            with open(dove, 'w', encoding='utf-8', newline='\n') as f:
                f.write(scriviDart(s))
        dove = os.path.join(RADICE, 'lib', 'core', 'sigilli',
                            'attesa_del_cielo.dart')
        with open(dove, 'w', encoding='utf-8', newline=chr(10)) as f:
            f.write(scriviAttesa())
        dove = os.path.join(RADICE, 'lib', 'core', 'sigilli',
                            'maestro_del_gesto.dart')
        with open(dove, 'w', encoding='utf-8', newline='\n') as f:
            f.write(scriviMaestroDelGesto(sentieri))
        # **IL FORMATO LO METTE IL GENERATORE**, non chi rigenera: un file
        # generato che poi va formattato a mano e' un file che prima o poi
        # arriva nel ramo non formattato.
        os.system('dart format %s' % ' '.join(
            os.path.join(RADICE, 'lib', 'core', 'sigilli', n)
            for n in ('sentiero_costellazione.dart', 'sentiero_loto.dart',
                      'sentiero_albero.dart', 'maestro_del_gesto.dart')))

    tutti = [g for s in sentieri for g in s['gradini']]
    print('GRADINI %d, Eos %d' % (len(tutti), sum(g['eos'] for g in tutti)))
    for s in sentieri:
        fam = {}
        for g in s['gradini']:
            fam[g['famiglia']] = fam.get(g['famiglia'], 0) + 1
        print('  %-14s Eos %d, famiglie %s'
              % (s['sentiero'], sum(g['eos'] for g in s['gradini']),
                 dict(sorted(fam.items()))))
    unGiorno = [g['id'] for g in tutti if g['costoInGiorni'] <= 1]
    print('COSTO UN GIORNO SOLO: %s' % unGiorno)
    print('EOS IN UNA SESSIONE: %d'
          % sum(g['eos'] for g in tutti if g['costoInGiorni'] <= 1))
    firme = {}
    for g in tutti:
        chiave = json.dumps(g['condizione'], sort_keys=True)
        firme.setdefault(chiave, []).append(g['id'])
    doppi = {k: v for k, v in firme.items() if len(v) > 1}
    print('CONDIZIONI RIPETUTE: %d %s' % (len(doppi), list(doppi.values())))


if __name__ == '__main__':
    main()
