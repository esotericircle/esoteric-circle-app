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
  2026, 1,1204 dollari per euro.

    python tool/i_limiti_degli_annuali.py
"""
IVA, STORE, QUOTA, CAMBIO = 0.22, 0.15, 0.30, 1.1204
DOMANDA, FE, LIVE = 0.00428, 0.000235, 0.0213

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


def tetto(prezzo_al_mese):
    return prezzo_al_mese / (1 + IVA) * (1 - STORE) * CAMBIO * QUOTA


def costo(i, domande, minuti):
    base = PEGGIORE_EX[i] + DOMANDE[i] * 30 * FE
    return (base + (domande - DOMANDE[i]) * 30 * (DOMANDA + FE)
            + (minuti - MINUTI[i]) * LIVE)


def main():
    sotto = True
    for i, nome in enumerate(PIANI):
        for ciclo, prezzo, d, m in [
            ('mensile', PREZZO_MENSILE[i], DOMANDE_MENSILE[i], MINUTI[i]),
            ('annuale', PREZZO_ANNUALE[i] / 12, DOMANDE_ANNUALE[i],
             MINUTI_ANNUALE[i]),
        ]:
            c, t = costo(i, d, m), tetto(prezzo)
            netto = t / QUOTA
            print(f'{nome} {ciclo}: {d} domande al giorno, {m} minuti di LIVE '
                  f'al mese; caso peggiore {c:.2f} dollari, tetto {t:.2f}, '
                  f'{c / netto * 100:.1f} per cento del netto')
            if c > t:
                sotto = False
    print('TUTTI I CICLI SOTTO IL TETTO' if sotto
          else 'UN CICLO SOPRA IL TETTO')


if __name__ == '__main__':
    main()
