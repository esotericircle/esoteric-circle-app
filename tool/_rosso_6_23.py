# -*- coding: utf-8 -*-
"""La prova del rosso della guardia della domanda nel responso, regola A."""
import io
import subprocess

NL = chr(10)
Q = chr(34)
CR = chr(13)
A = chr(39)
PROVA = 'test/il_mood_del_cerchio_test.dart'
SENSI = 'lib/features/tarot/stesa_senses.dart'
VOCE = 'lib/core/rituals/rune_voce.dart'
CORPUS = 'lib/core/rituals/risposta_del_dono.dart'
SCALA = 'lib/design_system/tokens/typography_tokens.dart'
PORTA = 'lib/design_system/components/da_dove_nasce.dart'
LUNA = 'lib/core/astro/moon_phase.dart'
ABITO = 'lib/design_system/theme/abito_del_responso.dart'
MODULO = 'lib/core/tarot/domanda_della_persona.dart'

INNESTI = [
    ('un titolo torna a descrivere il cielo, lungo',
     CORPUS,
     "        'Oggi il tuo tempo chiede {parola}.',",
     "        'Il tuo tempo di oggi e gia cominciato e chiede proprio {parola}.',",
     lambda t: 'gia cominciato e chiede proprio' in t),
    ('un titolo promette un esito',
     CORPUS,
     "        'Oggi il tuo corpo chiede {parola}.',",
     "        'Oggi otterrai {parola}.',",
     lambda t: "'Oggi otterrai {parola}.'," in t),
    ('la prosa torna a diciotto punti',
     SCALA,
     "      body(size: 20, weight: weight).copyWith(height: 1.55);",
     "      body(size: 18, weight: weight).copyWith(height: 1.55);",
     lambda t: 'body(size: 18, weight: weight).copyWith(height: 1.55)' in t),
    ('una schermata si apre una porta propria',
     'lib/features/rituals/day_oracle_screen.dart',
     "import 'package:flutter/material.dart';",
     "import 'package:flutter/material.dart';" + NL +
     "const _mio = 'Approfondisci';",
     lambda t: "const _mio = 'Approfondisci';" in t),
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
