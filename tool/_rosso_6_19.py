# -*- coding: utf-8 -*-
"""La prova del rosso della guardia della domanda nel responso, regola A."""
import io
import subprocess

NL = chr(10)
Q = chr(34)
CR = chr(13)
A = chr(39)
PROVA = 'test/la_gettata_a_tre_rune_risponde_test.dart'
SENSI = 'lib/features/tarot/stesa_senses.dart'
VOCE = 'lib/core/rituals/rune_voce.dart'
SCHERMO = 'lib/features/maestri/caligo/rune/rune_draw_screen.dart'
LUNA = 'lib/core/astro/moon_phase.dart'
ABITO = 'lib/design_system/theme/abito_del_responso.dart'
MODULO = 'lib/core/tarot/domanda_della_persona.dart'

INNESTI = [
    ('la porta delle fonti torna alla sola runa singola',
     SCHERMO,
     "            if ((daDoveNasce != null && daDoveNasce!.trim().isNotEmpty) ||",
     "            if (sola)" + NL + "            if (false && (daDoveNasce != null) ||",
     lambda t: 'if (sola)' in t),
    ('un paragrafo torna a una misura sua',
     SCHERMO,
     "                key: Key('rune_riga_$indice')," + NL +
     "                testo: runa.riga," + NL +
     "                stile: TypographyTokens.letturaAmpia()",
     "                key: Key('rune_riga_$indice')," + NL +
     "                testo: runa.riga," + NL +
     "                stile: TypographyTokens.corpo()",
     lambda t: 'TypographyTokens.corpo()' in t),
    ('il paragrafo di mezzo perde il bianco',
     SCHERMO,
     "                stile: TypographyTokens.letturaAmpia()" + NL +
     "                    .copyWith(color: ColorTokens.textPrimary))," + NL +
     "            // **TRE. Il cielo",
     "                stile: TypographyTokens.letturaAmpia()" + NL +
     "                    .copyWith(color: palette.goldSoft))," + NL +
     "            // **TRE. Il cielo",
     lambda t: 'textPrimary)),' + NL + '            // **TRE. Il cielo' not in t),
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
