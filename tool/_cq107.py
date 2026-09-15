# -*- coding: utf-8 -*-
"""CQ1.07: la stella resta nella fascia di cielo, e nessuna etichetta la copre."""
NL = chr(10)
CR = chr(13)
P = 'lib/features/rituals/dream_rite_screen.dart'

grezzo = open(P, 'rb').read().decode('utf-8')
crlf = CR in grezzo
s = grezzo.replace(CR + NL, NL) if crlf else grezzo

vecchio = """          mappa: (p) => Offset(
            (0.12 + p.dx * 0.76) * w + off.dx,
            (0.13 + p.dy * 0.30) * h + off.dy,
          ),"""

nuovo = """          // **LA STELLA NON ESCE DALLA FASCIA DI CIELO. Ordine CQ voce
          // 1.07**, 3 settembre 2026.
          //
          // **Il fatto, parole del fondatore:** *"l'area di tocco della
          // stella e' coperta dall'etichetta sopra di essa."*
          //
          // La mappa senza spostamento tiene le stelle fra il 13 e il 43 per
          // cento dell'altezza, cioe' dentro la fascia, che finisce al 46.
          // **Ma lo spostamento le porta via**: `_spostamento` moltiplica
          // l'inclinazione per trecentoventi, qui si prende il cinquantacinque
          // per cento, e su uno schermo alto ottocentoquaranta punti sono
          // centosettantasei punti di scorrimento. La stella scivolava sotto
          // il blocco del testo, che sta piu' in alto nella pila e mangia il
          // tocco su tutta la sua area: **il dito arrivava sulla riga "Tocca
          // la stella che pulsa" invece che sulla stella.**
          //
          // Si limita la sola verticale, e si lascia intera l'orizzontale: e'
          // in verticale che la fascia confina con qualcosa, e togliere la
          // parallasse per intero vorrebbe dire spegnere il cielo per curare
          // un bordo.
          mappa: (p) => Offset(
            (0.12 + p.dx * 0.76) * w + off.dx,
            (((0.13 + p.dy * 0.30) * h) + off.dy)
                .clamp(h * 0.06, h * (_fasciaCielo - 0.05)),
          ),"""

assert s.count(vecchio) == 1, s.count(vecchio)
s = s.replace(vecchio, nuovo)
open(P, 'wb').write((s.replace(NL, CR + NL) if crlf else s).encode('utf-8'))
assert 'clamp(h * 0.06' in open(P, 'rb').read().decode('utf-8')
print('FATTO: la verticale della stella e limitata alla fascia di cielo.')
