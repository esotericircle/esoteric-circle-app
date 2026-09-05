# -*- coding: utf-8 -*-
"""Sostituzione mirata che rispetta i fine riga del file, con assert.

Nasce dal difetto ripetuto: i pattern scritti con \n non trovano niente in un
file CRLF, e il replace muto non lo dice. Qui si normalizza, si verifica il
conteggio e si ripristina il fine riga originale.
"""
import sys


def sostituisci(percorso, vecchio, nuovo, attesi=1):
    b = open(percorso, 'rb').read()
    crlf = b.count(b'\r\n') > 0
    testo = b.decode('utf-8')
    if crlf:
        testo = testo.replace('\r\n', '\n')
    quanti = testo.count(vecchio)
    if quanti != attesi:
        raise SystemExit(
            'INNESTO MANCATO in %s: trovate %d occorrenze invece di %d'
            % (percorso, quanti, attesi))
    testo = testo.replace(vecchio, nuovo)
    if crlf:
        testo = testo.replace('\n', '\r\n')
    open(percorso, 'wb').write(testo.encode('utf-8'))
    print('INNESTO FATTO in %s, %d sostituzioni' % (percorso, quanti))


if __name__ == '__main__':
    sys.exit('modulo, non eseguibile')
