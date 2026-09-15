# -*- coding: utf-8 -*-
"""CQ6.23: i cinque Doni, la stessa cura data alle rune.

**Parole del fondatore, 4 settembre 2026**: *"sono le stesse identiche
richieste degli ultimi 2 ordini. non capisco perche' non li vuoi lavorare"*.

**Aveva ragione, e la colpa e' di una lettura mia.** Quando ha scritto
*dobbiamo rivedere tutti i doni* l'ho letta come "fermati", mentre era "falle
anche li'".

**Il censimento, prima di toccare.** Nella prosa dei cinque Doni convivevano
piu' misure nella stessa schermata: tre nella card di Alba e Soffio, tre nel
Tramonto, tre nel Sigillo del Sogno, due nell'Arcano. Solo il Soffio ne aveva
una sola.

**La cura e' quella delle rune, e non e' un'alzata della scala.** Ogni blocco
di PROSA passa a `letturaAmpia`, venti punti, che e' un gradino dichiarato
della scala e non una misura scritta a mano. **Restano dove sono i titoli e le
etichette in maiuscoletto**, che non sono prosa: se salissero anche loro, la
gerarchia sparirebbe e la schermata diventerebbe un blocco unico.

**Cosa NON si tocca, e si dichiara**: `ParagrafiDiLettura` resta la porta del
testo narrato. Qui cambia la misura, non la porta.
"""
import io
import re

NL = chr(10)
CR = chr(13)

# I cinque Doni, con le loro schermate. L'elenco sta qui e non si scopre
# leggendo una cartella: scoperto, il giorno che un Dono cambia file la cura
# lo salterebbe in silenzio.
SCHERMATE = [
    'lib/features/rituals/ritual_gift_card.dart',
    'lib/features/rituals/day_oracle_screen.dart',
    'lib/features/rituals/sunset_rune_screen.dart',
    'lib/features/rituals/dream_rite_screen.dart',
    'lib/features/rituals/breath_destiny_screen.dart',
]


def prosa(riga_intorno):
    """Vero se questo stile veste PROSA e non un'etichetta.

    **La distinzione non si indovina dal nome del ruolo**: si guarda cosa gli
    sta attorno. Un testo dentro `ParagrafiDiLettura` e' narrato per
    costruzione; un testo con `letterSpacing` alto e' un'etichetta in
    maiuscoletto, e alzarla la farebbe gridare.
    """
    if 'letterSpacing' in riga_intorno:
        spazio = re.search(r'letterSpacing:\s*([\d.]+)', riga_intorno)
        if spazio and float(spazio.group(1)) >= 1.0:
            return False
    return True


def cura(percorso):
    grezzo = io.open(percorso, 'rb').read().decode('utf-8')
    crlf = (CR + NL) in grezzo
    s = grezzo.replace(CR + NL, NL) if crlf else grezzo
    fuori = []
    cambiati = 0
    for m in re.finditer(r'TypographyTokens\.(lettura|corpo|didascalia)\(\)',
                         s):
        inizio = max(0, m.start() - 260)
        fine = min(len(s), m.end() + 260)
        intorno = s[inizio:fine]
        if not prosa(intorno):
            continue
        fuori.append((m.start(), m.end()))
    # Si sostituisce dal fondo, o gli indici slittano sotto le mani.
    for inizio, fine in reversed(fuori):
        s = s[:inizio] + 'TypographyTokens.letturaAmpia()' + s[fine:]
        cambiati += 1
    io.open(percorso, 'wb').write(
        (s.replace(NL, CR + NL) if crlf else s).encode('utf-8'))
    return cambiati


for percorso in SCHERMATE:
    quanti = cura(percorso)
    print(str(quanti).rjust(2) + ' blocchi di prosa portati alla misura ampia '
          'in ' + percorso.split('/')[-1])
