"""Le contraddizioni dichiarate e quelle a tradimento, nei giri gia' giudicati.

Ordine FF voce 08, 7 ottobre 2026. Il giudice del filo ha adesso quattro
verdetti (tool/banchi_col_modello/i_verdetti_del_filo.dart), ma la regola
dell'ordine FF vieta di chiamare un modello: i giri gia' fatti non si
rigiudicano. Questo strumento li riclassifica in modo DETERMINISTICO, e lo
dichiara: una risposta che il giudice ha detto CONTRADDICE e' contata come
DICHIARATA se il suo testo dice apertamente che cambia lettura (una delle
formule qui sotto) E dice perche' (un "perche'" o un "poiche'" o un
"infatti" nella stessa risposta); altrimenti e' A TRADIMENTO.

Stampa anche, come seconda colonna, quante dichiarano senza dire perche':
la regola della coerenza (FE.10) vuole tutte e due le cose, e il conto
largo serve a vedere quanto pesa il secondo requisito.

E' una misura per difetto delle dichiarate: una dichiarazione con parole
che le formule non conoscono resta contata a tradimento.

Uso: python tool/le_contraddizioni_dichiarate.py [cartella_dei_giri]
Scrive su stdout una riga per giro e percorso, e il totale.
"""
import io
import os
import re
import sys

DICHIARA = re.compile(
    r"leggo diversamente|vedo diversamente|leggo in modo diverso"
    r"|diversamente da (medora|aura|caligo)"
    r"|non sono d'accordo|non concordo|cambio (parere|idea|lettura)"
    r"|mi correggo|correggo quanto|rivedo quanto|ripensando"
    r"|a differenza di (medora|aura|caligo)"
    r"|contrariamente a",
    re.IGNORECASE)
PERCHE = re.compile(r"perch[eé]|poich[eé]|infatti", re.IGNORECASE)

RISPOSTA = re.compile(r'^\[(\d+)\] (?!PERSONA)([A-Z]+)')
VERDETTO = re.compile(r'^\s+GIUDICE: ([A-Z_]+)')


def risposte_giudicate(testo):
    """(verdetto, testo della risposta) per ogni risposta giudicata."""
    fuori = []
    corrente = []
    dentro = False
    for riga in testo.splitlines():
        if RISPOSTA.match(riga):
            corrente = [riga]
            dentro = True
            continue
        m = VERDETTO.match(riga)
        if m:
            fuori.append((m.group(1), '\n'.join(corrente)))
            dentro = False
            continue
        if riga.startswith('[') or riga.startswith('==='):
            dentro = False
            continue
        if dentro:
            corrente.append(riga)
    return fuori


def dichiarata(risposta):
    return bool(DICHIARA.search(risposta)) and bool(PERCHE.search(risposta))


def main():
    radice = sys.argv[1] if len(sys.argv) > 1 else \
        'docs/collaudo/banchi_col_modello/filo'
    tot = {'giudicate': 0, 'contraddice': 0, 'dichiarate': 0,
           'tradimento': 0, 'solo_formula': 0, 'oltre_due_largo': 0,
           'percorsi': 0, 'oltre_due': 0,
           'oltre_due_prima': 0}
    for giro in sorted(os.listdir(radice)):
        cartella = os.path.join(radice, giro)
        if not os.path.isdir(cartella):
            continue
        for nome in sorted(os.listdir(cartella)):
            if not re.match(r'percorso_[a-z]\.txt$', nome):
                continue
            testo = io.open(os.path.join(cartella, nome),
                            encoding='utf-8').read()
            giudicate = risposte_giudicate(testo)
            c = [r for v, r in giudicate if v == 'CONTRADDICE']
            d = sum(1 for r in c if dichiarata(r))
            solo = sum(1 for r in c if DICHIARA.search(r))
            t = len(c) - d
            tot['giudicate'] += len(giudicate)
            tot['contraddice'] += len(c)
            tot['dichiarate'] += d
            tot['tradimento'] += t
            tot['percorsi'] += 1
            tot['oltre_due'] += t > 2
            tot['solo_formula'] += solo
            tot['oltre_due_largo'] += len(c) - solo > 2
            tot['oltre_due_prima'] += len(c) > 2
            print(f'{giro} {nome[9]}: giudicate {len(giudicate)}, '
                  f'contraddice {len(c)}, dichiarate {d} '
                  f"(conto largo {solo}), a tradimento {t}")
    print(f"TOTALE: percorsi {tot['percorsi']}, giudicate "
          f"{tot['giudicate']}, contraddice {tot['contraddice']}, "
          f"dichiarate {tot['dichiarate']} (conto largo, senza il perche': "
          f"{tot['solo_formula']}), a tradimento "
          f"{tot['tradimento']}; percorsi oltre due contraddizioni: "
          f"{tot['oltre_due_prima']} contandole tutte, "
          f"{tot['oltre_due']} contando solo quelle a tradimento, "
          f"{tot['oltre_due_largo']} col conto largo")


if __name__ == '__main__':
    main()
