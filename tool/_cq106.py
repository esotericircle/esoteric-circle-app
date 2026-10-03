# -*- coding: utf-8 -*-
"""CQ1.06: scegliere la gettata non getta, ci vuole il pulsante."""
NL = chr(10)
CR = chr(13)
P = 'lib/features/maestri/caligo/rune/rune_draw_screen.dart'

grezzo = open(P, 'rb').read().decode('utf-8')
crlf = CR in grezzo
s = grezzo.replace(CR + NL, NL) if crlf else grezzo


def cambia(vecchio, nuovo, quante=1):
    global s
    assert s.count(vecchio) == quante, (s.count(vecchio), vecchio[:80])
    s = s.replace(vecchio, nuovo)


# --- 1. la scelta smette di gettare ------------------------------------
cambia("""                  onAncora: _gettaAncora,
                  onAltraGettata: (g) {
                    setState(() => _gettata = g);
                    _gettaAncora();
                  },""",
       """                  onAncora: _gettaAncora,
                  // **SCEGLIERE NON GETTA. Ordine CQ voce 1.06**, 3 settembre
                  // 2026, e ribalta l'ordine BF voce 05.a. Li' il tocco su
                  // una pillola gettava subito con la stesa scelta; il
                  // fondatore ha visto partire il responso mentre stava
                  // ancora scegliendo, e chiede che il getto lo faccia il
                  // pulsante. **La pillola dice cosa si stendera', il
                  // pulsante lo stende.**
                  onAltraGettata: (g) => setState(() => _gettata = g),
                  scelta: _gettata,""")

# --- 2. il responso conosce la scelta in corso -------------------------
cambia("""    required this.onAncora,
    required this.onAltraGettata,
    required this.gettateFinite,""",
       """    required this.onAncora,
    required this.onAltraGettata,
    required this.scelta,
    required this.gettateFinite,""")

cambia("""  /// **LE PILLOLE RESTANO DOPO IL GETTO, ordine BF voce 05.a.** L'ordine S
  /// voce 23 aveva verificato che nessun selettore sopravviveva al responso
  /// e l'aveva dichiarato giusto; il fondatore ha poi deciso il contrario,
  /// concordandolo con l'Architetto: dal responso si cambia stesa
  /// direttamente, senza tornare indietro. Il tocco getta subito con la
  /// stesa scelta, e a gettate finite passa dallo stesso invito del
  /// pulsante.
  final ValueChanged<GettataRune> onAltraGettata;""",
       """  /// **LE PILLOLE RESTANO DOPO IL GETTO, ordine BF voce 05.a.** L'ordine S
  /// voce 23 aveva verificato che nessun selettore sopravviveva al responso
  /// e l'aveva dichiarato giusto; il fondatore ha poi deciso il contrario,
  /// concordandolo con l'Architetto: dal responso si cambia stesa
  /// direttamente, senza tornare indietro.
  ///
  /// **MA IL TOCCO NON GETTA PIU'. Ordine CQ voce 1.06**, 3 settembre 2026.
  /// Nell'ordine BF il tocco gettava subito con la stesa scelta, e il
  /// fondatore ha visto partire il responso mentre stava ancora scegliendo:
  /// *"cliccando sul tipo di gettata parte subito il responso, deve
  /// richiedere il pulsante getta ancora."* La pillola dice cosa si
  /// stendera', il pulsante lo stende. Cosi' il gesto che consuma una
  /// gettata e' uno solo, ed e' quello che si preme apposta.
  final ValueChanged<GettataRune> onAltraGettata;

  /// La gettata scelta in questo momento, che non e' quella dell'esito a
  /// video finche' non si preme. **Prima le pillole mostravano
  /// `esito.gettata`**, ed era giusto quando scegliere gettava subito: le due
  /// cose coincidevano sempre. Adesso non coincidono nell'istante che conta,
  /// cioe' fra la scelta e il pulsante, e mostrare l'esito vecchio vorrebbe
  /// dire non far vedere la scelta appena fatta.
  final GettataRune scelta;""")

# --- 3. le pillole mostrano la scelta, e stanno SOPRA il pulsante ------
cambia("""          // LE PILLOLE DELLA STESA, anche qui: vedi il commento sul campo
          // onAltraGettata.
          const SizedBox(height: SpacingTokens.md),
          _SelettoreGettate(
            corrente: esito.gettata,
            palette: palette,
            onSelect: onAltraGettata,
          ),
""", '')

cambia("""            onPressed: onAncora,
            icon: Icon(gettateFinite
                ? Icons.lock_outline_rounded
                : Icons.casino_outlined),
            label: const Text('Getta ancora'),
          ),""",
       """            onPressed: onAncora,
            icon: Icon(gettateFinite
                ? Icons.lock_outline_rounded
                : Icons.casino_outlined),
            label: const Text('Getta ancora'),
          ),""")

# le pillole entrano PRIMA del pulsante: si sceglie, poi si getta
cambia("""          // GETTA ANCORA STA QUI, subito sotto la scena, dall'ordine H: era in
          // fondo, dopo presagio e sigillo, e per rigettare si attraversava
          // tutta la lettura.
          const SizedBox(height: SpacingTokens.md),""",
       """          // **LE PILLOLE STANNO SOPRA IL PULSANTE. Ordine CQ voce 1.06.**
          // Stavano sotto, e potevano starci finche' il tocco su una pillola
          // gettava da solo: erano una scorciatoia, non un passaggio. Adesso
          // sono il primo dei due gesti, e un gesto che viene prima si legge
          // prima.
          const SizedBox(height: SpacingTokens.md),
          _SelettoreGettate(
            corrente: scelta,
            palette: palette,
            onSelect: onAltraGettata,
          ),
          // GETTA ANCORA STA QUI, subito sotto la scena, dall'ordine H: era in
          // fondo, dopo presagio e sigillo, e per rigettare si attraversava
          // tutta la lettura.
          const SizedBox(height: SpacingTokens.md),""")

open(P, 'wb').write((s.replace(NL, CR + NL) if crlf else s).encode('utf-8'))
print('parte 1 fatta')
