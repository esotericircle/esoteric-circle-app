# -*- coding: utf-8 -*-
"""La prova del rosso della guardia della domanda nel responso, regola A."""
import io
import subprocess

NL = chr(10)
CR = chr(13)
A = chr(39)
PROVA = 'test/la_domanda_entra_nel_responso_test.dart'
MOTORE = 'lib/core/tarot/tarot_reading.dart'
SCHERMATA = 'lib/features/tarot/stesa_tre_carte_screen.dart'
MODULO = 'lib/core/tarot/domanda_della_persona.dart'

INNESTI = [
    ('la domanda torna a non entrare nel consiglio',
     MOTORE,
     "          DomandaDellaPersona.apertura(domandaScritta)),",
     "          null),",
     lambda t: 'DomandaDellaPersona.apertura(domandaScritta)' not in t),
    ('la chiusura torna quella pescata dal corpus',
     MOTORE,
     "    final domanda = sua ?? domandaDi(spread, topic);",
     "    final domanda = domandaDi(spread, topic);",
     lambda t: 'sua ?? domandaDi' not in t),
    ('la lente non si deduce piu dalla domanda',
     MOTORE,
     "        : DomandaDellaPersona.lenteDedotta(sua) ?? topic;",
     "        : topic;",
     lambda t: 'lenteDedotta(sua)' not in t),
    ('la schermata smette di passare la domanda',
     SCHERMATA,
     "      domandaScritta: _setup.domandaScritta);",
     "      domandaScritta: null);",
     lambda t: 'domandaScritta: _setup.domandaScritta' not in t),
    ('una lente resta senza parole che la nominino',
     MODULO,
     "    TarotTopic.amicizia: ['amicizia', 'amico', 'amica', 'amici'],",
     "    TarotTopic.amicizia: [],",
     lambda t: "TarotTopic.amicizia: []," in t),
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
                                 capture_output=True, text=True, shell=True)
            caduta = 'All tests passed' not in out.stdout
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
