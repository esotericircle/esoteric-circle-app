# -*- coding: utf-8 -*-
"""CQ1.03: la cattura preme il pulsante DOPO lo scatto dell'ultima carta."""
NL = chr(10)
CR = chr(13)
Q = chr(39)
P = 'test/screenshot_capture_test.dart'

grezzo = open(P, 'rb').read().decode('utf-8')
crlf = CR in grezzo
s = grezzo.replace(CR + NL, NL) if crlf else grezzo

PRESSIONE = """    // **E ADESSO IL PULSANTE, che e' cio' che apre la lettura.** Ordine CQ
    // voce 1.03: la finestra che questa cattura fotografa comincia da qui e
    // non piu' dalla terza carta. Si aspetta che si accenda, cioe' che
    // l'ultima carta sia arrivata nel suo slot.
    final apre = find.byKey(const Key('stesa_inizia'));
    for (var i = 0; i < 30; i++) {
      if (apre.evaluate().isNotEmpty &&
          tester.widget<FilledButton>(apre).onPressed != null) {
        await tester.tap(apre, warnIfMissed: false);
        break;
      }
      await tester.pump(const Duration(milliseconds: 100));
    }
"""

assert s.count(PRESSIONE) == 1, s.count(PRESSIONE)
s = s.replace(PRESSIONE, '')

ANCORA = """    expect(find.byKey(const Key('stesa_attesa')), findsNothing,
        reason: 'lo scatto e\\' arrivato dopo l\\'inizio della riflessione');
"""
assert s.count(ANCORA) == 1, s.count(ANCORA)
s = s.replace(ANCORA, ANCORA + NL + PRESSIONE)

open(P, 'wb').write((s.replace(NL, CR + NL) if crlf else s).encode('utf-8'))
controllo = open(P, 'rb').read().decode('utf-8').replace(CR + NL, NL)
i_scatto = controllo.index("'stesa-dopo-l-ultima-carta.png'")
i_pressione = controllo.index("final apre = find.byKey(const Key('stesa_inizia'));")
assert i_pressione > i_scatto, 'il pulsante si preme ancora prima dello scatto'
print('FATTO: il pulsante si preme dopo lo scatto dell ultima carta.')
