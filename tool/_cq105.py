# -*- coding: utf-8 -*-
"""CQ1.05: la domanda libera sta SUBITO sotto le suggerite, non in fondo."""
NL = chr(10)
CR = chr(13)
P = 'lib/features/tarot/tarot_selectors.dart'

grezzo = open(P, 'rb').read().decode('utf-8')
crlf = CR in grezzo
s = grezzo.replace(CR + NL, NL) if crlf else grezzo


def cambia(vecchio, nuovo, quante=1):
    global s
    assert s.count(vecchio) == quante, (s.count(vecchio), vecchio[:80])
    s = s.replace(vecchio, nuovo)


# --- via dal fondo del pannello ----------------------------------------
cambia("""          const SizedBox(height: SpacingTokens.sm),
          // **E SOTTO LE SEI SUGGERITE, LA PROPRIA.** Ordine CO voce 05.
          //
          // Sta SOTTO e non al posto loro: le sei sono un punto di partenza
          // per chi non sa da dove cominciare, ed e' la maggioranza delle
          // volte. Chi sa cosa vuole chiedere scrive qui.
          _DomandaScritta(
            testo: setup.domandaLibera,
            palette: palette,
            onChanged: (t) => onChanged(setup.copyWith(domandaLibera: t)),
          ),
        ],""", """        ],""")

# --- e subito sotto la tendina delle suggerite -------------------------
cambia("""                  // Il tipo di stesa: da qui viene anche il titolo in alto.
                  SizedBox(
                    width: w,""",
       """                  // **E SUBITO SOTTO LE SUGGERITE, LA PROPRIA.**
                  // Ordine CO voce 05 per l'esistenza, ordine CQ voce 1.05
                  // del 3 settembre 2026 per il posto.
                  //
                  // **Il campo c'era e il fondatore non l'ha trovato**, e la
                  // ragione si vede aprendo il pannello: stava in fondo,
                  // dopo altre cinque tendine, mentre le domande suggerite
                  // stanno in cima. Fra la cosa e la sua alternativa c'era
                  // tutto il contorno della stesa, cioe' abbastanza da far
                  // credere che l'alternativa non esistesse.
                  //
                  // Prende la riga intera e non mezza: e' un campo in cui si
                  // scrive una frase, non una tendina da cui si sceglie, e a
                  // meta' riga si scriverebbe una frase dentro una feritoia.
                  SizedBox(
                    width: constraints.maxWidth,
                    child: _DomandaScritta(
                      testo: setup.domandaLibera,
                      palette: palette,
                      onChanged: (t) =>
                          onChanged(setup.copyWith(domandaLibera: t)),
                    ),
                  ),
                  // Il tipo di stesa: da qui viene anche il titolo in alto.
                  SizedBox(
                    width: w,""")

open(P, 'wb').write((s.replace(NL, CR + NL) if crlf else s).encode('utf-8'))
controllo = open(P, 'rb').read().decode('utf-8')
assert controllo.count('_DomandaScritta(') == 2, controllo.count('_DomandaScritta(')
print('FATTO: la domanda libera e la seconda voce del pannello.')
