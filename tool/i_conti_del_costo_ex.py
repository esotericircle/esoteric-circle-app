# -*- coding: utf-8 -*-
"""IL COSTO PER UTENTE DOPO L'ORDINE EX. Voce EX.11, 2 ottobre 2026.

La giornata al massimo di ogni piano coi limiti NUOVI (EX.02) e i costi per
uso dopo le voci EX, per trenta giorni, col LIVE dentro.

Da dove vengono i costi per uso (dollari, senza cache e con la cache
misurata):
- la chat (una domanda) e il "Vai più a fondo" (un tocco): il costo misurato
  dall'ordine EW (docs/costi/i_conti_del_costo.txt, memoria piena) per il
  rapporto fra il giro finale e il giro "prima2" del banco della qualità
  (tool/i_conti_della_qualita.py), sugli stessi trenta casi. Il giro "prima2"
  a freddo costa come l'EW (0,00690 contro 0,00694): i due banchi
  misurano la stessa cosa.
- le stese: l'EW misura una stesa da tre carte, 0,00207; la carta costa un
  terzo, 0,00069. Le stese da 1, 5 e 10 carte non esistono ancora: il loro
  costo e' una STIMA, carte per 0,00069, dichiarata come stima.
- le gettate di rune: 0,00601 come nell'EW finche' il corpus dell'EX.03 non
  c'e'; con il corpus completo, 0.
- le discese del Viaggio: 0,00350 come nell'EW (EX.10 aperta).
- tutto il resto (confronti, sigilli, segni, titoli, Ricordi) come nell'EW.
- il LIVE: 0,0213 dollari al minuto in conversazione (EW.07, Realme), coi
  minuti del mese dell'EX.02. Le risposte dette nel LIVE sono domande del
  giorno e stanno gia' nelle domande.

  python tool/i_conti_del_costo_ex.py
"""
import importlib.util
import pathlib

RADICE = pathlib.Path(__file__).resolve().parent.parent
_spec = importlib.util.spec_from_file_location(
    'conti_qualita', RADICE / 'tool/i_conti_della_qualita.py')
_q = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_q)

GIRO_PRIMA = 'prima2'
GIRO_DOPO = 'fine3'

# I costi per uso dell'ordine EW (docs/costi/i_conti_del_costo.txt):
# (senza cache, con la cache misurata).
EW = {
    'domanda_vuota': (0.00521, 0.00252),
    'domanda': (0.00694, 0.00431),
    'tocco': (0.00430, 0.00236),
    'confronto': (0.00250, 0.00219),
    'stesa3': (0.00207, 0.00203),
    'gettata': (0.00601, 0.00405),
    'discesa': (0.00350, 0.00345),
    'segno': (0.00012, 0.00012),
    'sigilli': (0.00045 + 0.00012 + 0.00014, 0.00045 + 0.00012 + 0.00014),
    'titolo': (0.00002, 0.00002),
    'ricordi': (0.00010, 0.00010),
}
LIVE_AL_MINUTO = 0.0213

PIANI = ['Viandante', 'Iniziato', 'Adepto', 'Illuminato']
TETTI = [None, 2.36, 4.72, 7.08]
PREZZI_EURO = [0, 9.99, 19.99, 29.99]

# La matrice dell'EX.02 (e le righe che l'ordine lascia come sono).
NUOVI = {
    'domande': [3, 6, 10, 13],
    'approfondimenti': [0, 2, 2, 3],
    'confronti': [0, 1, 2, 3],
    'carte': [3, 6, 10, 15],
    'gettate': [1, 2, 3, 3],
    'discese': [1, 1, 1, 2],
    'segni': [1 / 7, 3 / 7, 1, 5],
    'sigilli': [1, 2, 3, 5],
    'ricordi': [0, 1 / 30, 1 / 30, 1 / 30],
    'minuti_live': [0, 0, 60, 120],
}
PRIMA = {
    'domande': [3, 5, 10, 50],
    'approfondimenti': [0, 3, 10, 30],
    'confronti': [0, 3, 5, 20],
    'stese': [1, 4, 7, 20],
    'gettate': [1, 20, 30, 50],
    'discese': [1, 1, 1, 2],
    'segni': [1 / 7, 3 / 7, 1, 5],
    'sigilli': [1, 2, 3, 5],
    'ricordi': [0, 1 / 30, 1 / 30, 1 / 30],
    'minuti_live': [0, 0, 100, 250],
}


def rapporti():
    p = _q.conti(GIRO_PRIMA)
    d = _q.conti(GIRO_DOPO)
    return {
        'domanda': (d['costo_risposta_freddo'] / p['costo_risposta_freddo'],
                    d['costo_risposta'] / p['costo_risposta']),
        'tocco': (d['costo_tocco_freddo'] / p['costo_tocco_freddo'],
                  d['costo_tocco'] / p['costo_tocco']),
    }, p, d


def giornata(limiti, i, costo, k, nuovo, rune_dal_corpus=False):
    """Il costo di un giorno al massimo del piano i; k=0 senza cache, 1 con."""
    vuota = i == 0
    domanda = costo['domanda_vuota' if vuota else 'domanda'][k]
    voci = {
        'domande': limiti['domande'][i] * (domanda + costo['titolo'][k]),
        'Vai più a fondo': limiti['approfondimenti'][i] * costo['tocco'][k],
        'confronti': limiti['confronti'][i] * costo['confronto'][k],
        'tarocchi': (limiti['carte'][i] * costo['stesa3'][k] / 3 if nuovo
                     else limiti['stese'][i] * costo['stesa3'][k]),
        'gettate': 0 if rune_dal_corpus else limiti['gettate'][i] * costo['gettata'][k],
        'discese': limiti['discese'][i] * costo['discesa'][k],
        'segni': limiti['segni'][i] * costo['segno'][k],
        'sigilli': limiti['sigilli'][i] * costo['sigilli'][k],
        'Ricordi': limiti['ricordi'][i] * costo['ricordi'][k],
    }
    return voci


def main():
    r, p, d = rapporti()
    dopo = dict(EW)
    for chiave in ('domanda', 'domanda_vuota'):
        dopo[chiave] = (EW[chiave][0] * r['domanda'][0],
                        EW[chiave][1] * r['domanda'][1])
    dopo['tocco'] = (EW['tocco'][0] * r['tocco'][0],
                     EW['tocco'][1] * r['tocco'][1])
    print('== I RAPPORTI DEL BANCO DELLA QUALITA\' (dopo / prima, senza cache e '
          'con la cache)')
    print(f"domanda: {r['domanda'][0]:.3f} e {r['domanda'][1]:.3f}; tocco del "
          f"Vai più a fondo: {r['tocco'][0]:.3f} e {r['tocco'][1]:.3f}")
    print(f"{GIRO_PRIMA}: risposta {p['costo_risposta_freddo']:.5f} a freddo, "
          f"tocco {p['costo_tocco_freddo']:.5f}; {GIRO_DOPO}: risposta "
          f"{d['costo_risposta_freddo']:.5f}, tocco "
          f"{d['costo_tocco_freddo']:.5f}")
    print()
    print('== I COSTI PER USO (senza cache, con la cache)')
    for k in EW:
        print(f'{k}: prima {EW[k][0]:.5f} {EW[k][1]:.5f}; dopo '
              f'{dopo[k][0]:.5f} {dopo[k][1]:.5f}')
    print()
    for k, nome in ((0, 'SENZA CACHE'), (1, 'CON LA CACHE MISURATA')):
        print(f'== IL MESE AL MASSIMO, {nome} (dollari, 30 giorni, LIVE '
              'compreso)')
        for i, piano in enumerate(PIANI):
            prima = giornata(PRIMA, i, EW, k, False)
            nuovo = giornata(NUOVI, i, dopo, k, True)
            corpus = giornata(NUOVI, i, dopo, k, True, rune_dal_corpus=True)
            lp = PRIMA['minuti_live'][i] * LIVE_AL_MINUTO
            ln = NUOVI['minuti_live'][i] * LIVE_AL_MINUTO
            mp = sum(prima.values()) * 30 + lp
            mn = sum(nuovo.values()) * 30 + ln
            mc = sum(corpus.values()) * 30 + ln
            tetto = TETTI[i]
            print(f'{piano}: prima {mp:.2f} (LIVE {lp:.2f}); dopo {mn:.2f} '
                  f'(LIVE {ln:.2f}); dopo, con le rune dal corpus {mc:.2f}; '
                  f'tetto {tetto if tetto is not None else "nessuno"}')
            print('   dopo, al giorno: ' + '; '.join(
                f'{n} {v:.4f}' for n, v in nuovo.items()))
            if tetto is not None:
                dom = dopo['domanda'][k] + dopo['titolo'][k]
                spazio = (tetto - mn) / 30 / dom
                print(f'   domande in piu\' al giorno sotto il tetto: '
                      f'{spazio:.1f} (a {dom:.5f} l\'una)')
        print()


if __name__ == '__main__':
    main()
