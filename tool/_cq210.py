# -*- coding: utf-8 -*-
"""CQ2.10 e CQ2.07: la runa singola si accorcia, il Sigillo dice a cosa serve."""
NL = chr(10)
CR = chr(13)
P = 'lib/features/maestri/caligo/rune/rune_draw_screen.dart'


def cambia(vecchio, nuovo, quante=1):
    grezzo = open(P, 'rb').read().decode('utf-8')
    crlf = CR in grezzo
    s = grezzo.replace(CR + NL, NL) if crlf else grezzo
    assert s.count(vecchio) == quante, (s.count(vecchio), vecchio[:70])
    s = s.replace(vecchio, nuovo)
    open(P, 'wb').write(
        (s.replace(NL, CR + NL) if crlf else s).encode('utf-8'))
    assert nuovo.split(NL)[0].strip() in \
        open(P, 'rb').read().decode('utf-8')
    print('FATTO')


# --- 1. la scheda sa se e' sola ----------------------------------------
cambia("""            _LetturaRuna(
                runa: esito.rune[i],
                indice: i,
                palette: palette,
                libera: esito.gettata.libera,""",
       """            _LetturaRuna(
                runa: esito.rune[i],
                indice: i,
                palette: palette,
                libera: esito.gettata.libera,
                // **QUANTE NE SONO USCITE IN TUTTO. Ordine CQ voce 2.10**, 4
                // settembre 2026: a una runa sola la scheda intera diventa
                // tutto cio' che c'e' a schermo, e il responso si legge come
                // una pagina di manuale invece che come una risposta.
                sola: esito.rune.length == 1,""")

cambia("""  /// Nel getto libero le rune lette sono in luce, non hanno il verso d'ombra.
  final bool libera;""",
       """  /// Nel getto libero le rune lette sono in luce, non hanno il verso d'ombra.
  final bool libera;

  /// **VERO QUANDO LA GETTATA E' DI UNA RUNA SOLA.**
  /// Ordine CQ voce 2.10, 4 settembre 2026.
  ///
  /// **Il fatto, parole del fondatore:** il responso della runa singola e'
  /// troppo lungo, tre paragrafi.
  ///
  /// **Misurato:** la scheda intera porta in media 264 caratteri contro i 50
  /// della sola risposta, cioe' **cinque volte e un quarto**, e su una gettata
  /// a tre o cinque rune quel corpo e' la lettura ed e' giusto che ci sia. Su
  /// una sola diventa l'unica cosa a schermo.
  ///
  /// **Il corpus non si tocca**: le stesse frasi restano, e restano
  /// leggibili. Cambia quante ne arrivano insieme: la risposta subito, il
  /// resto sotto una porta che si apre.
  final bool sola;""")

cambia("""      this.libera = false,
      this.voce,
      this.giuntura});""",
       """      this.libera = false,
      this.sola = false,
      this.voce,
      this.giuntura});""")

print('parte della scheda fatta')
