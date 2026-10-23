# -*- coding: utf-8 -*-
"""La prova del rosso della guardia della domanda nel responso, regola A."""
import io
import subprocess

NL = chr(10)
CR = chr(13)
A = chr(39)
PROVA = 'test/il_soffio_non_si_accavalla_test.dart'
SENSI = 'lib/features/tarot/stesa_senses.dart'
SOFFIO = 'lib/features/rituals/breath_destiny_screen.dart'
ABITO = 'lib/design_system/theme/abito_del_responso.dart'
MODULO = 'lib/core/tarot/domanda_della_persona.dart'

INNESTI = [
    ('il cartello LA RISPOSTA torna sopra il responso',
     SOFFIO,
     "          if (risposta.apre != null)",
     "          Text('LA RISPOSTA')," + NL + "          if (risposta.apre != null)",
     lambda t: "Text('LA RISPOSTA')" in t),
    ('il riquadro della risposta perde la sua chiave',
     SOFFIO,
     "      key: const Key('soffio_risposta'),",
     "      key: const Key('soffio_qualcosa'),",
     lambda t: "Key('soffio_risposta')" not in t),
    ('i due comandi si accavallano a video',
     'lib/features/ricordi/azioni_del_responso.dart',
     "          const SizedBox(height: SpacingTokens.sm),",
     "          const SizedBox(height: -40),",
     lambda t: 'SizedBox(height: -40)' in t),
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
