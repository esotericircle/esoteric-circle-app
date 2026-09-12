# -*- coding: utf-8 -*-
"""La prova del rosso della guardia della domanda nel responso, regola A."""
import io
import subprocess

NL = chr(10)
Q = chr(34)
CR = chr(13)
A = chr(39)
PROVA = 'test/la_card_si_manda_test.dart'
SENSI = 'lib/features/tarot/stesa_senses.dart'
VOCE = 'lib/core/rituals/rune_voce.dart'
CARD = 'lib/design_system/components/card_da_mandare.dart'
SCALA = 'lib/design_system/tokens/typography_tokens.dart'
PORTA = 'lib/design_system/components/da_dove_nasce.dart'
LUNA = 'lib/core/astro/moon_phase.dart'
ABITO = 'lib/design_system/theme/abito_del_responso.dart'
MODULO = 'lib/core/tarot/domanda_della_persona.dart'

INNESTI = [
    ('la card si riempie di righe di servizio',
     CARD,
     "            Text('Esoteric Circle',",
     "            Text('riga di troppo uno')," + NL +
     "            Text('riga di troppo due')," + NL +
     "            Text('Esoteric Circle',",
     lambda t: 'riga di troppo uno' in t),
    ('il marchio sale sopra la frase',
     CARD,
     "        child: Column(" + NL + "          children: [" + NL +
     "            Text(arte.toUpperCase(),",
     "        child: Column(" + NL + "          children: [" + NL +
     "            Text('Esoteric Circle', key: const Key('card_marchio'))," + NL +
     "            Text(arte.toUpperCase(),",
     lambda t: "Text('Esoteric Circle', key: const Key('card_marchio'))," in t),
    ('la frase torna piccola come il testo di servizio',
     CARD,
     "                      style: TypographyTokens.cerimoniale(weight: 500)",
     "                      style: TypographyTokens.etichetta()",
     lambda t: 'style: TypographyTokens.etichetta()' + NL + '                          .copyWith(color: ColorTokens.textPrimary,' in t),
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
