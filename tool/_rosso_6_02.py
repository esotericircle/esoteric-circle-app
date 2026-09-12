# -*- coding: utf-8 -*-
"""La prova del rosso della guardia dei suoni sintetizzati, regola A.

**Ogni innesto porta la sua verifica, e non una spia sola per tutti.** La
prima stesura di questo script cercava la PRESENZA di un pezzo anche per
l'innesto che quel pezzo lo toglie, e si e' fermata da sola: la verifica
dell'innesto va scritta per l'innesto, o misura un'altra cosa.
"""
import io
import re
import subprocess

NL = chr(10)
CR = chr(13)
A = chr(39)
PROVA = 'test/nessun_suono_sintetizzato_esce_dai_responsi_test.dart'
VOCE = 'lib/core/sensi/voce_del_responso.dart'


def _quanti_responsi(testo):
    return len(re.findall(r"'\w+': Maestro\.",
                          testo.split('deiResponsi')[1]))


INNESTI = [
    ('il generatore torna nella voce del responso',
     VOCE,
     "  /// A quale Maestro appartiene ognuno degli otto responsi dell" + A +
     "app.",
     "  static Uint8List byteDi(Maestro m) => _generatore.wav(leftHz: 1);" +
     NL + NL +
     "  /// A quale Maestro appartiene ognuno degli otto responsi dell" + A +
     "app.",
     lambda t: 'byteDi(Maestro m)' in t),
    ('la mappa degli otto responsi si svuota',
     VOCE,
     "    'sinastria': Maestro.medora," + NL +
     "    'angelo_custode': Maestro.medora," + NL,
     "",
     lambda t: _quanti_responsi(t) == 6),
    ('un sorgente qualunque torna a generare un tono',
     'lib/features/rituals/dawn_rite_screen.dart',
     "import 'package:flutter/material.dart';",
     "import 'package:flutter/material.dart';" + NL +
     "// ToneGenerator innestato dalla prova del rosso",
     lambda t: 'ToneGenerator innestato' in t),
]


def esegui():
    righe = []
    rossi = 0
    for nome, percorso, vecchio, nuovo, verifica in INNESTI:
        # **SI LAVORA SUI BYTE, e il fine riga si conserva.** Questi file
        # stanno a CRLF: un pezzo scritto con LF non si trova, e un ripristino
        # che normalizza i fine riga cambierebbe il file senza dirlo.
        grezzo = io.open(percorso, 'rb').read().decode('utf-8')
        crlf = (CR + NL) in grezzo
        originale = grezzo.replace(CR + NL, NL) if crlf else grezzo

        def scrivi(testo, crlf=crlf, percorso=percorso):
            io.open(percorso, 'wb').write(
                (testo.replace(NL, CR + NL) if crlf else testo).encode('utf-8'))

        assert originale.count(vecchio) >= 1, ('innesto non applicabile', nome)
        # **IL RIPRISTINO STA IN UN FINALLY, e la ragione e' un file rotto.**
        # La prima stesura ripristinava dopo la verifica: quando la verifica
        # e' scattata, lo script si e' fermato lasciando il sorgente
        # innestato, cioe' la mappa degli otto responsi svuotata a sei. Un
        # ripristino che si esegue solo quando tutto va bene non e' un
        # ripristino.
        try:
            scrivi(originale.replace(vecchio, nuovo, 1))
            # **LA VERIFICA PRIMA DELL'ESITO.** Regola A: chi legge l'esito
            # senza aver verificato che il difetto sia entrato misura un
            # errore suo.
            dentro = io.open(percorso, 'rb').read().decode('utf-8')
            assert verifica(dentro), ('innesto NON entrato nel file', nome)
            out = subprocess.run(['flutter', 'test', PROVA],
                                 capture_output=True, text=True, shell=True)
            caduta = 'All tests passed' not in out.stdout
            rossi += 1 if caduta else 0
            righe.append(('ROSSA' if caduta else 'VERDE') + '     ' + nome)
        finally:
            scrivi(originale)
        # **IL RIPRISTINO SI VERIFICA COL BYTE.**
        assert io.open(percorso, 'rb').read().decode('utf-8') == grezzo, \
            ('IL FILE NON E RITORNATO COME PRIMA', percorso)
    print(NL.join(righe))
    print('INNESTI CHE HANNO FATTO ROSSA LA GUARDIA: ' + str(rossi) + ' su ' +
          str(len(INNESTI)))


esegui()
