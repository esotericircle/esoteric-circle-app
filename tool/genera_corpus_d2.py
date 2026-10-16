# -*- coding: utf-8 -*-
"""IL CORPUS SI CORREGGE QUI. Ordine AU voce 03.

**Perche' questo file esiste.** La revisione D2 non arriva da fuori: la
dettano le correzioni dell'ordine AU voce 03, e siccome sono ventitre',
applicarle a mano su un file di centosessantacinque voci vuol dire sbagliarne
una. Qui si dichiarano come dato e si applicano a macchina, e ogni correzione
che non trova la sua voce fa cadere il programma invece di passare in
silenzio: una correzione che non morde e' peggio di una correzione mancante,
perche' sembra fatta.

**IL CONTO DELL'ORDINE NON TORNA, e si dichiara invece di aggirarlo.**
L'ordine annuncia "diciotto correzioni" e poi ne elenca ventitre': DODICI
condizioni sotto un titolo che dice dieci, e UNDICI nomi sotto un titolo che
dice undici. Si applicano tutte quelle ELENCATE, perche' l'elenco e' il dato e
il titolo e' il riassunto, e il conto vero si dichiara nel rapporto.

**Il difetto che si sta curando** e' nato da una conversione automatica: la
revisione D ha trasformato ventidue gradini di costanza da "giorni
consecutivi" a "giorni dentro un arco", ma ha messo nell'arco il numero
sbagliato, e sono usciti gradini che chiedono quattordici giorni dentro tre.
Senza una guardia rinasce alla prossima conversione, ed e' per questo che
insieme al file nasce `test/la_finestra_e_una_volta_e_mezza_test.dart`.
"""
import json
import pathlib

RADICE = pathlib.Path(__file__).resolve().parent.parent
SORGENTE = RADICE / 'docs' / 'corpus' / 'Traguardi_165_Revisione_D.json'
USCITA = RADICE / 'docs' / 'corpus' / 'Traguardi_165_Revisione_D2.json'

# **LA LEGGE DELLA FINESTRA.** Ordine AU voce 03: l'arco vale circa una volta e
# mezza il numero richiesto. Vive qui e nella guardia, e il codice che legge il
# corpus non deve indovinarla.
LEGGE_DELLA_FINESTRA = {
    2: 3, 3: 5, 5: 8, 7: 10, 14: 20, 21: 30, 30: 45, 40: 60, 60: 85, 90: 130,
}

# Le condizioni riscritte, dalla vecchia alla nuova. La vecchia si dichiara per
# intero: se non e' quella, la correzione non si applica e il programma cade.
CONDIZIONI = {
    'med_51': (
        "Dodici mesi di seguito in cui hai letto l'Oroscopo mentre la Luna "
        "passava nel tuo segno.",
        "Dodici volte hai letto l'Oroscopo mentre la Luna passava nel tuo "
        "segno."),
    'cal_28': ("Due settimane di presenza, nell'arco di 3 giorni.",
               "Quattordici giorni di presenza, nell'arco di 20 giorni."),
    'cal_34': ("Un mese di presenza consecutiva.",
               "Trenta giorni di presenza, nell'arco di 45 giorni."),
    'cal_40': ("Tre settimane di Rune del Tramonto, nell'arco di 5 giorni.",
               "Ventuno Rune del Tramonto, nell'arco di 30 giorni."),
    'cal_45': ("Due mesi di presenza, nell'arco di 3 giorni.",
               "Sessanta giorni di presenza, nell'arco di 85 giorni."),
    'cal_50': ("Dodici Lune nuove di seguito con una gettata in ciascuna.",
               "Dodici Lune nuove con una gettata in ciascuna."),
    'cal_52': ("Tre mesi di presenza, nell'arco di 5 giorni.",
               "Novanta giorni di presenza, nell'arco di 130 giorni."),
    'aur_34': ("Tre settimane di Riti dell'Alba, nell'arco di 5 giorni.",
               "Ventuno Riti dell'Alba, nell'arco di 30 giorni."),
    'aur_39': ("Un mese di Riti dell'Alba consecutivi.",
               "Trenta Riti dell'Alba, nell'arco di 45 giorni."),
    'aur_45': ("Due mesi di Riti dell'Alba, nell'arco di 3 giorni.",
               "Sessanta Riti dell'Alba, nell'arco di 85 giorni."),
    'aur_46': ("Dodici Lune piene di seguito con un Soffio del Destino in "
               "ciascuna.",
               "Dodici Lune piene con un Soffio del Destino in ciascuna."),
    'aur_53': ("Tre mesi di Riti dell'Alba, nell'arco di 5 giorni.",
               "Novanta Riti dell'Alba, nell'arco di 130 giorni."),
}

# **I NOMI CHE MENTIVANO.** Promettevano giorni di seguito su condizioni a
# finestra: chi legge "Due sere di seguito" e salta una sera crede di aver
# perso il gradino, e invece ce l'ha ancora.
NOMI = {
    'cal_9': ("Due sere di seguito", "Due sere"),
    'cal_13': ("Tre sere di seguito", "Tre sere"),
    'cal_40': ("Ventuno sere di seguito", "Ventuno sere"),
    'cal_49': ("Quaranta sere di seguito", "Quaranta sere"),
    'aur_8': ("Due mattine di seguito", "Due mattine"),
    'aur_13': ("Tre mattine di seguito", "Tre mattine"),
    'aur_20': ("Cinque mattine di seguito", "Cinque mattine"),
    'aur_34': ("Ventuno mattine di seguito", "Ventuno mattine"),
    'aur_39': ("Trenta mattine di seguito", "Trenta mattine"),
    'aur_45': ("Sessanta mattine di seguito", "Sessanta mattine"),
    'aur_53': ("Novanta mattine di seguito", "Novanta mattine"),
}

# **I SETTE CHE TORNANO VIVI.** Erano dichiarati dormienti perche' chiedevano
# piu' giorni di quanti ne concedesse il loro arco, cioe' non potevano maturare
# mai. Corretta la finestra, la ragione della dormienza sparisce.
RISVEGLIATI = ['cal_28', 'cal_40', 'cal_45', 'cal_52', 'aur_34', 'aur_45',
               'aur_53']


def main():
    corpus = json.loads(SORGENTE.read_text(encoding='utf-8'))
    per_id = {v['id']: v for s in corpus['sentieri'] for v in s['voci']}

    fatte, mancate = 0, []
    for chiave, (vecchia, nuova) in CONDIZIONI.items():
        voce = per_id.get(chiave)
        se_ce = voce['condizione'] if voce else 'nessuna voce'
        if voce is None or voce['condizione'] != vecchia:
            mancate.append(f"condizione {chiave}: nel corpus c'e' '{se_ce}'")
            continue
        voce['condizione'] = nuova
        coda = (" Revisione D2: la finestra vale una volta e mezza il numero "
                "richiesto." if "nell'arco" in nuova else
                " Revisione D2: niente giorni consecutivi.")
        voce['note'] = (voce.get('note') or '') + coda
        fatte += 1

    for chiave, (vecchio, nuovo) in NOMI.items():
        voce = per_id.get(chiave)
        se_ce = voce['nome'] if voce else 'nessuna voce'
        if voce is None or voce['nome'] != vecchio:
            mancate.append(f"nome {chiave}: nel corpus c'e' '{se_ce}'")
            continue
        voce['nome'] = nuovo
        fatte += 1

    svegliati = 0
    for chiave in RISVEGLIATI:
        voce = per_id.get(chiave)
        if voce is None:
            mancate.append(f"risveglio {chiave}: voce assente")
            continue
        voce['dormiente'] = False
        svegliati += 1

    if mancate:
        raise SystemExit('CORREZIONI CHE NON HANNO MORSO:\n  ' +
                         '\n  '.join(mancate))

    corpus['revisione'] = 'D2'
    corpus['data'] = '2026-08-22'
    corpus['legge_della_finestra'] = {
        'regola': "l'arco vale circa una volta e mezza il numero richiesto",
        'scala': {str(k): v for k, v in LEGGE_DELLA_FINESTRA.items()},
        'divieti': [
            'nessun gradino puo chiedere piu giorni di quanti ne concede il '
            'suo arco',
            'nessun gradino puo chiedere giorni consecutivi',
        ],
    }
    USCITA.write_text(
        json.dumps(corpus, ensure_ascii=False, indent=1), encoding='utf-8')

    # **IL CONTO SI RIFA', non si eredita.** Gli Eos non si toccano, ma un
    # totale scritto a mano e' un totale che un giorno mente.
    voci = [v for s in corpus['sentieri'] for v in s['voci']]
    per_sentiero = [sum(v['eos'] for v in s['voci']) for s in corpus['sentieri']]
    dormienti = sum(1 for v in voci if v.get('dormiente'))
    print(f'correzioni applicate: {fatte} su {len(CONDIZIONI) + len(NOMI)} '
          f'({len(CONDIZIONI)} condizioni piu {len(NOMI)} nomi)')
    print(f'gradini risvegliati: {svegliati}')
    print(f'gradini: {len(voci)}, Eos per sentiero: {per_sentiero}, '
          f'Eos totali: {sum(per_sentiero)}')
    print(f'dormienti residui nel corpus: {dormienti}')
    print(f'scritto: {USCITA.name}')


if __name__ == '__main__':
    main()
