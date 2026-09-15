# -*- coding: utf-8 -*-
"""La prova del rosso della guardia della domanda nel responso, regola A."""
import io
import subprocess

NL = chr(10)
CR = chr(13)
A = chr(39)
PROVA = 'test/la_stella_si_tocca_davvero_test.dart'
SENSI = 'lib/features/tarot/stesa_senses.dart'
SCHERMATA = 'lib/features/rituals/dream_rite_screen.dart'
MODULO = 'lib/core/tarot/domanda_della_persona.dart'

INNESTI = [
    ('le stelle tornano sotto il testo nella pila',
     SCHERMATA,
     "                if (_fase != _Fase.nebbia) ..._costellazione(w, h)," + NL +
     "              ]," + NL,
     "              ]," + NL,
     lambda t: t.count('..._costellazione(w, h)') == 0),
    ('la fascia di cielo si allarga e il testo entra sulle stelle',
     SCHERMATA,
     "const double fasciaCielo = 0.46;",
     "const double fasciaCielo = 0.14;",
     lambda t: 'fasciaCielo = 0.14' in t),
    ('il tocco sulla stella non conta piu',
     SCHERMATA,
     "          onTocco: _allUnione,",
     "          onTocco: (_) {},",
     lambda t: 'onTocco: (_) {}' in t),
]


def esegui():
    righe = []
    rossi = 0
    for nome, percorso, vecchio, nuovo, verifica in INNESTI:
        grezzo = io.open(percorso, 'rb').read().decode('utf-8')
        crlf = (CR + NL) in grezzo
        originale = grezzo.replace(CR + NL, NL) if crlf else grezzo

        def scrivi(testo, crlf=crlf, percorso=percorso):
            io.open(percorso, 'wb').write(
                (testo.replace(NL, CR + NL) if crlf else testo).encode('utf-8'))

        assert originale.count(vecchio) >= 1, ('innesto non applicabile', nome)
        # **IL RIPRISTINO STA IN UN FINALLY**: un ripristino che si esegue solo
        # quando tutto va bene non e' un ripristino.
        try:
            scrivi(originale.replace(vecchio, nuovo, 1))
            dentro = io.open(percorso, 'rb').read().decode('utf-8')
            assert verifica(dentro), ('innesto NON entrato nel file', nome)
            out = subprocess.run(['flutter', 'test', PROVA],
                                 capture_output=True, text=True, shell=True,
                                 encoding='utf-8', errors='replace')
            # **L'USCITA PUO' ARRIVARE VUOTA, e allora non si conclude
            # niente.** Leggere `None` come "non contiene All tests passed"
            # avrebbe scritto ROSSA su una prova che non e' mai partita.
            uscita = (out.stdout or '') + (out.stderr or '')
            assert uscita.strip(), ('la prova non ha stampato niente', nome)
            caduta = 'All tests passed' not in uscita
            rossi += 1 if caduta else 0
            righe.append(('ROSSA' if caduta else 'VERDE') + '     ' + nome)
        finally:
            scrivi(originale)
        assert io.open(percorso, 'rb').read().decode('utf-8') == grezzo, \
            ('IL FILE NON E RITORNATO COME PRIMA', percorso)
    print(NL.join(righe))
    print('INNESTI CHE HANNO FATTO ROSSA LA GUARDIA: ' + str(rossi) + ' su ' +
          str(len(INNESTI)))


esegui()
