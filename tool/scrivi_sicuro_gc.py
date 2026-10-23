"""Scrive un sorgente anche se un processo lo tiene mappato (Windows).

Uso come modulo: from scrivi_sicuro import scrivi, sostituisci
"""
import os
import time

BLOCCATI = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'bloccati')


def scrivi(percorso, testo):
    dati = testo.encode('utf-8')
    try:
        with open(percorso, 'wb') as f:
            f.write(dati)
    except OSError:
        os.makedirs(BLOCCATI, exist_ok=True)
        via = os.path.join(BLOCCATI, '%s.%d' % (os.path.basename(percorso),
                                                time.time_ns()))
        os.rename(percorso, via)
        with open(percorso, 'wb') as f:
            f.write(dati)
    assert open(percorso, 'rb').read() == dati, percorso


def sostituisci(percorso, coppie):
    s = open(percorso, encoding='utf-8').read()
    for vecchio, nuovo in coppie:
        assert s.count(vecchio) == 1, (percorso, s.count(vecchio), vecchio[:90])
        s = s.replace(vecchio, nuovo)
    scrivi(percorso, s)
