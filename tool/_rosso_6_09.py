# -*- coding: utf-8 -*-
"""La prova del rosso della guardia della domanda nel responso, regola A."""
import io
import subprocess

NL = chr(10)
CR = chr(13)
A = chr(39)
PROVA = 'test/la_terza_carta_non_apre_una_schermata_test.dart'
MOTORE = 'lib/core/tarot/tarot_reading.dart'
SCHERMATA = 'lib/features/tarot/stesa_tre_carte_screen.dart'
MODULO = 'lib/core/tarot/domanda_della_persona.dart'

INNESTI = [
    ('il blocco delle carte scelte sparisce alla terza',
     SCHERMATA,
     "            key: const Key('stesa_blocco_carte_scelte'),",
     "            key: const Key('stesa_blocco_carte_altro'),",
     lambda t: 'stesa_blocco_carte_scelte' not in t),
    ('le carte scelte spariscono del tutto, come prima',
     SCHERMATA,
     "          _BloccoDelleCarte(" + NL +
     "            key: const Key('stesa_blocco_carte_scelte')," + NL +
     "            carte: _spread.cards," + NL +
     "            palette: palette," + NL +
     "          )," + NL,
     "",
     lambda t: '_BloccoDelleCarte(' + NL + "            key: const Key('stesa_blocco_carte_scelte')" not in t),
    ('il pulsante torna a dire Leggi il responso',
     SCHERMATA,
     "              label: const Text('Leggi le Carte'),",
     "              label: const Text('Leggi il responso'),",
     lambda t: "Text('Leggi il responso')" in t),
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
