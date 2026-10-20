# -*- coding: utf-8 -*-
"""I LIMITI DEGLI ANNUALI. Ordine FE voce 20, 6 ottobre 2026.

Il tetto del fondatore: *"30% Dopo iva e Store"* (docs/costi/
costo_per_utente_dopo_ex.md:5), al caso peggiore (ogni limite usato ogni
giorno per trenta giorni, LIVE compreso, senza cache). Il conto dell'ordine
EX (tool/i_conti_del_costo_ex.py) l'ha fatto solo sui prezzi mensili: sui
prezzi annuali l'Adepto e l'Illuminato erano gia' sopra (37 e 38 per cento).
Scelta del fondatore del 6 ottobre 2026: *"Domande e minuti insieme"*.

Da dove vengono i numeri:
- il caso peggiore dei piani dopo le EX Aggiunte 5 e 6, ai limiti di oggi:
  1,91, 4,58 e 6,93 dollari (docs/costi/costo_per_utente_dopo_ex.md, tabella
  "Dopo le Aggiunte 5 e 6");
- una domanda a freddo 0,00428 dollari con 1,38 chiamate per risposta (stesso
  documento); il LIVE 0,0213 dollari al minuto (EW.07);
- l'ordine FE aggiunge a ogni domanda 0,000235 dollari a freddo (il filo, la
  rete della coerenza e le sue correzioni leggere: meta' della differenza per
  consulto di due turni in docs/collaudo/FE/costo/il_costo_a_freddo.txt,
  giro delle 16:41, 0,00447 contro 0,00400);
- IVA 22 per cento e commissione dello store 15 per cento, i valori che
  rifanno al centesimo i tre tetti dell'ordine EX; cambio BCE del 5 ottobre
  2026, 1,1204 dollari per euro;
- dall'ordine FU voce FU.10 (15 ottobre 2026) le consultazioni dell'Oracolo
  degli Angeli: una chiamata a Gemini 2.5 Flash-Lite per consultazione, 804
  token in ingresso (misurati dalla prova "LA STIMA DI UNA CONSULTAZIONE" di
  test/l_oracolo_degli_angeli_test.dart) e al piu' 300 in uscita nella
  Breve (Iniziato) o 600 nella Lunga (Adepto e Illuminato), al listino
  Vertex di 0,10 e 0,40 dollari per milione (docs/costi/
  stima_costi_30_giorni.md, la riga dei prezzi). L'assaggio del Viandante
  non chiama il modello.
- dall'ordine GA voci GA.01, GA.02 e GA.05 (20 ottobre 2026) i Tarocchi si
  contano a STESE: il caso peggiore e' ogni stesa del giorno fatta con la
  stesa piu' cara che il piano apre (la croce a 4 carte per l'Iniziato, la
  stesa a 10 per l'Adepto e l'Illuminato), sempre in Lunga. Una carta costa
  0,00069 dollari (un terzo della stesa a tre misurata dall'EW, docs/costi/
  costo_per_utente_dopo_ex.md); la Lunga aggiunge i due approfondimenti, 840
  caratteri cioe' circa 280 gettoni d'uscita a 2,50 dollari per milione
  (Gemini 2.5 Flash) per 1,75 chiamate a lettura, 0,0012 dollari: una
  STIMA, nessuna chiamata nuova al modello (regola R2 dell'ordine GA). Dal
  caso peggiore dell'ordine EX si tolgono i Tarocchi contati a carte
  (0,0041, 0,0069 e 0,0103 dollari al giorno). L'Oracolo degli Angeli e' in
  Lunga dall'Iniziato (GA.05).
- dall'ordine GA voce 02, 20 ottobre 2026 sera, la scelta del fondatore
  "Carte dal corpus" vale per OGNI stesa (una, tre, quattro, dieci carte): le
  singole carte vengono dal corpus e Gemini 2.5 Flash scrive SOLO il
  responso principale (titolo, risposta, cosaFare e nella Lunga
  l'approfondimento, ognuno da 40 a 50 parole). Il costo di una stesa e' il
  costo di quel solo responso. Da dove viene il numero:
  * la misura vera della lettura della stesa, docs/costi/
    costo_per_funzione_misure.txt, riga "Tarocchi, la lettura della stesa
    [lettura_tarocchi]": 20 usi, 1,75 chiamate per uso, 49.127 gettoni in
    ingresso e 10.647 in uscita, cioe' circa 1.404 in ingresso e 304 in
    uscita per chiamata, 0,00203 dollari per uso, al listino Flash di 0,30 e
    2,50 dollari per milione;
  * col solo responso principale il modello scrive titolo e tre paragrafi
    da 45 parole al piu' (Lunga), circa 150 parole cioe' circa 230 gettoni
    d'uscita per chiamata (1,5 gettoni a parola); la richiesta piu' grande e'
    quella della Croce Celtica, circa 1.950 gettoni in ingresso (STIMA della
    ricognizione dei Tarocchi del 20 ottobre 2026, nessuna chiamata nuova al
    modello, regola R2 dell'ordine GA);
  * (1950 * 0,30 + 230 * 2,50) / 1e6 * 1,75 = 0,00203 dollari: la stesa piu'
    cara in Lunga, usata per ogni piano (prudente).
  La stesa a dieci carte e' una al giorno (STESE_DA_DIECI) DENTRO le stese
  del giorno: col solo responso principale costa come le altre, quindi il
  caso peggiore resta STESE * costo della stesa.

    python tool/i_limiti_degli_annuali.py
"""
IVA, STORE, QUOTA, CAMBIO = 0.22, 0.15, 0.30, 1.1204
DOMANDA, FE, LIVE = 0.00428, 0.000235, 0.0213
# Una consultazione dell'Oracolo degli Angeli, Breve e Lunga (ordine FU).
ORACOLO_BREVE = 804 * 0.10e-6 + 300 * 0.40e-6
ORACOLO_LUNGA = 804 * 0.10e-6 + 600 * 0.40e-6

PIANI = ['Iniziato', 'Adepto', 'Illuminato']
PREZZO_MENSILE = [9.99, 19.99, 29.99]
PREZZO_ANNUALE = [99.99, 189.99, 279.99]
PEGGIORE_EX = [1.91, 4.58, 6.93]
# Le domande del conto EX, quelle del caso peggiore qui sopra.
DOMANDE = [12, 18, 22]
MINUTI = [0, 80, 150]

# I limiti del mensile: dal 6 ottobre 2026 17 e 21 per l'Adepto e
# l'Illuminato, scelta del fondatore "Una domanda in meno".
DOMANDE_MENSILE = [12, 17, 21]

# I limiti dell'annuale: la scelta del fondatore, "Domande e minuti
# insieme", coi valori piu' vicini alla proposta (11; 14 e 60; 18 e 100) che
# stanno sotto il tetto.
DOMANDE_ANNUALE = [11, 14, 18]
MINUTI_ANNUALE = [0, 55, 95]

# Le consultazioni dell'Oracolo degli Angeli al giorno, ordine FU voce
# FU.10: Iniziato in Breve, Adepto e Illuminato in Lunga. Le stesse del
# mensile e dell'annuale, e la prova test/i_limiti_degli_annuali_test.dart
# pretende che siano quelle della matrice.
ORACOLI = [3, 5, 6]
# Ordine GA voce GA.05: la Lunga dall'Iniziato.
ORACOLO = [ORACOLO_LUNGA, ORACOLO_LUNGA, ORACOLO_LUNGA]

# I Tarocchi dell'ordine GA, contati a stese.
# STORIA, ordine GA voci 01 e 02 prima della sera del 20 ottobre 2026: la
# stesa costava tre carte di costo (CARTA = 0.00069, un terzo della stesa a
# tre misurata dall'EW) piu' la Lunga dei due approfondimenti
# (LUNGA_DELLA_STESA = 280 * 2.50e-6 * 1.75), cioe' 0,0033 dollari, e
# entravano STESE = [3, 2, 3] e STESE_ANNUALE = [1, 2, 3]. Prima ancora, coi
# conti a 4 e 10 carte (CARTE_DELLA_PIU_CARA = [4, 10, 10]), 3 e 1, 1 e 0, 1
# e 1 stese.
#
# Dalla sera del 20 ottobre 2026 ("Carte dal corpus" per ogni stesa) la
# stesa costa il solo responso principale: la richiesta piu' grande (la
# Croce Celtica, circa 1.950 gettoni in ingresso, STIMA) e circa 230
# gettoni d'uscita (la Lunga, tre paragrafi da 45 parole piu' il titolo),
# per le 1,75 chiamate a lettura misurate (docs/costi/
# costo_per_funzione_misure.txt, [lettura_tarocchi]), al listino Flash.
INGRESSO_DELLA_STESA = 1950
USCITA_DELLA_STESA = 230
CHIAMATE_PER_STESA = 1.75
STESA = ((INGRESSO_DELLA_STESA * 0.30 + USCITA_DELLA_STESA * 2.50) / 1e6
         * CHIAMATE_PER_STESA)
TAROCCHI_DEL_CONTO_EX = [0.0041, 0.0069, 0.0103]
# Le stese chieste dal fondatore il 20 ottobre 2026 ("viandante 1, iniziato
# 3, adepto 6, illuminato 10"), e quelle della matrice dopo il conto
# (ordine GA voce 02, la sera del 20 ottobre 2026).
STESE_CHIESTE = [3, 6, 10]
# Ordine GA, decisione del 20 ottobre 2026: il server non distingue il ciclo
# mensile dall'annuale (un solo tetto per piano in functions/src/budget.ts),
# e con quattro stese l'annuale dell'Adepto saliva al 30,08 per cento del
# netto. L'Adepto ha tre stese in entrambi i cicli: era STESE = [3, 4, 5].
STESE = [3, 3, 5]
STESE_ANNUALE = [3, 3, 5]
# La stesa a dieci carte, una al giorno all'Adepto e all'Illuminato, DENTRO
# le stese del giorno (il fondatore, la sera del 20 ottobre 2026: "sarà
# disponibile solo per Tier 2 e 3 e solo 1 al giorno"). Non aggiunge costo:
# col solo responso principale costa come ogni altra stesa, ed e' gia' la
# stesa del conto (la piu' cara). La prova test/i_limiti_degli_annuali_test
# .dart pretende che sia la riga "Stesa da 10 carte" della matrice.
STESE_DA_DIECI = [0, 1, 1]


def stesa(i):
    return STESA


def tetto(prezzo_al_mese):
    return prezzo_al_mese / (1 + IVA) * (1 - STORE) * CAMBIO * QUOTA


def costo(i, domande, minuti, stese=None, annuale=False):
    if stese is None:
        stese = STESE_ANNUALE[i] if annuale else STESE[i]
    base = (PEGGIORE_EX[i] - TAROCCHI_DEL_CONTO_EX[i] * 30
            + DOMANDE[i] * 30 * FE)
    return (base + (domande - DOMANDE[i]) * 30 * (DOMANDA + FE)
            + (minuti - MINUTI[i]) * LIVE
            + ORACOLI[i] * 30 * ORACOLO[i]
            + stese * 30 * stesa(i))


def stese_che_entrano(i, domande, minuti, prezzo):
    n = 0
    while costo(i, domande, minuti, n + 1) <= tetto(prezzo):
        n += 1
    return n


def main():
    sotto = True
    print(f'Una stesa di tarocchi, il solo responso principale in Lunga: '
          f'{STESA:.5f} dollari')
    for i, nome in enumerate(PIANI):
        for ciclo, prezzo, d, m in [
            ('mensile', PREZZO_MENSILE[i], DOMANDE_MENSILE[i], MINUTI[i]),
            ('annuale', PREZZO_ANNUALE[i] / 12, DOMANDE_ANNUALE[i],
             MINUTI_ANNUALE[i]),
        ]:
            c = costo(i, d, m, annuale=ciclo == 'annuale')
            t = tetto(prezzo)
            netto = t / QUOTA
            chieste = costo(i, d, m, STESE_CHIESTE[i])
            print(f'{nome} {ciclo}, i tarocchi a stese: con le '
                  f'{STESE_CHIESTE[i]} stese chieste {chieste:.2f} dollari, '
                  f'{chieste / netto * 100:.1f} per cento del netto; stese '
                  f'che entrano sotto il tetto: '
                  f'{stese_che_entrano(i, d, m, prezzo)}')
            stese = STESE_ANNUALE[i] if ciclo == 'annuale' else STESE[i]
            print(f'{nome} {ciclo}: {d} domande al giorno, {m} minuti di LIVE '
                  f'al mese, {ORACOLI[i]} consultazioni dell\'Oracolo al '
                  f'giorno, {stese} stese di tarocchi al giorno (a dieci '
                  f'carte {STESE_DA_DIECI[i]}); caso peggiore {c:.2f} '
                  f'dollari, tetto {t:.2f}, '
                  f'{c / netto * 100:.1f} per cento del netto')
            if c > t:
                sotto = False
    print('TUTTI I CICLI SOTTO IL TETTO' if sotto
          else 'UN CICLO SOPRA IL TETTO')


if __name__ == '__main__':
    main()
