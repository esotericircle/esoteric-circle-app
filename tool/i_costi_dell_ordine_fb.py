# -*- coding: utf-8 -*-
"""I COSTI IN EURO DELL'ORDINE FB, prima (ordine FA) e dopo.

Il fondatore, 4 ottobre 2026: "Quando parli di costi voglio sapere a quanto
ammontano." Questo conto mette i prezzi veri di Firestore accanto alle
letture e alle scritture del Cerchio, e scrive l'esito in
`docs/collaudo/FB/i_costi_in_euro.txt`.

**I prezzi** sono quelli del catalogo di Google (Cloud Billing Catalog API,
servizio Cloud Firestore EE2C-7FAC-5E08, voci "Belgium", cioe' europe-west1,
edizione Standard, in euro), letti il 4 ottobre 2026: lettura 0,029 euro ogni
100.000, scrittura 0,0871, cancellazione 0,0096. La quota gratuita del
progetto (50.000 letture e 20.000 scritture al giorno) NON e' sottratta: e'
condivisa con tutta l'app, e toglierla qui farebbe sembrare gratis cio' che
consuma la quota degli altri.

**Le letture e le scritture** sono quelle del codice, voce per voce, con le
stesse ipotesi per prima e dopo: ogni presente lo e' per l'ora intera (un
passo al minuto), apre la tendina due volte all'ora e ha fino a dieci amici
presenti; un'istanza del server ogni ottanta presenti, e ognuna rilegge
l'istantanea al piu' una volta ogni trenta secondi; l'istantanea si rifa'
una volta ogni trenta secondi.

PRIMA, ordine FA (commit 6d0ba515): il passo conta i presenti con
un'aggregazione ogni mille voci d'indice, a ogni minuto, piu' le due letture
del primo passo; l'apertura legge 4 documenti fissi e gli amici presenti fino
a sei; la ricostruzione fa quattordici aggregazioni (una per arte) ogni mille
presenti e legge la vetrina di ventiquattro.

DOPO, ordine FB: il passo legge l'identita' una volta (al primo passo) e
prende il numero dall'istantanea in memoria; l'apertura legge 4 documenti
fissi e nessuno per amico; la ricostruzione legge il turno e i frammenti che
esistono (al piu' uno per presente, al piu' novantasei) e scrive
l'istantanea e il turno.
"""
import io
import math
import os

RADICE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(RADICE)

LETTURA = 0.029 / 100_000
SCRITTURA = 0.0871 / 100_000
RICOSTRUZIONI = 120
APERTURE = 2
FRAMMENTI = 96


def istanze(n):
    return max(1, math.ceil(n / 80))


def amici_presenti(n):
    return min(10, n - 1)


def prima(n):
    mille = max(1, math.ceil(n / 1000))
    letture = (n * (60 * mille + 2)
               + n * APERTURE * (4 + max(1, min(amici_presenti(n), 6)))
               + istanze(n) * RICOSTRUZIONI
               + RICOSTRUZIONI * (14 * mille + min(24, n)))
    scritture = n * 60 + RICOSTRUZIONI
    return letture, scritture


def frammenti_occupati(n, peggiore=False):
    """Quanti frammenti esistono con n presenti: nel caso peggiore uno per
    presente fino a novantasei; atteso, con l'identificativo sparso
    dall'impronta SHA-256, F * (1 - (1 - 1/F)^n)."""
    if peggiore:
        return max(1, min(FRAMMENTI, n))
    return max(1.0, FRAMMENTI * (1 - (1 - 1 / FRAMMENTI) ** n))


def dopo(n, peggiore=False):
    letture = (n * 1
               + n * APERTURE * 4
               + istanze(n) * RICOSTRUZIONI
               + RICOSTRUZIONI * (1 + frammenti_occupati(n, peggiore)))
    letture = round(letture)
    scritture = n * 60 + RICOSTRUZIONI * 2
    return letture, scritture


def euro(l, s):
    return l * LETTURA + s * SCRITTURA


def main():
    righe = [
        "I COSTI IN EURO DELL'ORDINE FB, scritti da tool/i_costi_dell_ordine_fb.py",
        "Prezzi Firestore Standard europe-west1 dal catalogo di Google, letti il "
        "4 ottobre 2026: lettura 0,029 euro / 100.000, scrittura 0,0871 euro / 100.000.",
        "Un'ora con N persone presenti per tutta l'ora; il mese e' 720 ore cosi'.",
        "",
    ]
    peggio = []
    for n in (1, 10, 100, 1000, 5000):
        lp, sp = prima(n)
        ld, sd = dopo(n)
        lw, sw = dopo(n, peggiore=True)
        ep, ed, ew = euro(lp, sp), euro(ld, sd), euro(lw, sw)
        if ed > ep:
            peggio.append(n)
        righe.append(
            "%5d presenti | prima (FA) %9d letture %7d scritture = %.4f euro/ora, "
            "%7.2f euro/mese | dopo (FB) %9d letture %7d scritture = %.4f euro/ora, "
            "%7.2f euro/mese | differenza %+.2f euro/mese | nel caso peggiore dei "
            "frammenti (uno per presente) %+.2f euro/mese" % (
                n, lp, sp, ep, ep * 720, ld, sd, ed, ed * 720, (ed - ep) * 720,
                (ew - ep) * 720))
    righe.append("")
    righe.append("Frammenti occupati attesi: con 10 presenti %.1f, con 100 %.1f, "
                 "con 1000 %.1f; nel caso peggiore 10, 96, 96." % (
                     frammenti_occupati(10), frammenti_occupati(100),
                     frammenti_occupati(1000)))
    righe.append("Scale dove il dopo atteso costa piu' del prima: %s" % (
        ', '.join(str(n) for n in peggio) if peggio else 'nessuna'))
    righe.append("Le scritture del passo (60 all'ora per presente) sono le stesse "
                 "prima e dopo: sono la parte piu' grande del costo, e l'ordine FB "
                 "non le tocca.")
    os.makedirs('docs/collaudo/FB', exist_ok=True)
    with io.open('docs/collaudo/FB/i_costi_in_euro.txt', 'w', encoding='utf-8',
                 newline='\n') as f:
        f.write('\n'.join(righe) + '\n')
    print('\n'.join(righe))


if __name__ == '__main__':
    main()
