# -*- coding: utf-8 -*-
"""CQ1.03: le tre guardie che pescano premono DOPO la terza carta."""
NL = chr(10)
CR = chr(13)
Q = chr(39)

PREAMBOLO = """    // **PRIMA SI PREME PER COMINCIARE. Ordine CO voce 07**, 3 settembre 2026:
    // il fondatore ha chiesto un pulsante esplicito, e il ventaglio non
    // risponde piu' a chi non ha cominciato. Il pulsante c'e' solo prima della
    // prima carta, quindi da qui in poi questa riga non fa niente.
    final inizia = find.byKey(const Key('stesa_inizia'));
    if (tester.widgetList(inizia).isNotEmpty) {
      await tester.tap(inizia, warnIfMissed: false);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
    }
"""

POSTAMBOLO = """    // **SI PREME DOPO L'ULTIMA CARTA, E NON PRIMA DELLA PRIMA.**
    // Ordine CQ voce 1.03, 3 settembre 2026, e ribalta l'ordine CO voce 07.
    // Il ventaglio adesso e' vivo da subito, e il pulsante apre il responso
    // quando le tre carte sono posate. Per questa guardia l'istante da
    // osservare resta lo stesso, cioe' quello in cui la lettura comincia:
    // cambia solo quale gesto lo produce. Nessun pump fra la carta e il
    // pulsante, o l'istante osservato non sarebbe piu' quello.
    final pulsante = find.byKey(const Key('stesa_inizia'));
    if (pulsante.evaluate().isNotEmpty &&
        tester.widget<FilledButton>(pulsante).onPressed != null) {
      await tester.tap(pulsante, warnIfMissed: false);
    }
"""

FILE = {
    'test/medora_non_resta_sola_test.dart': """    final carta = find.byKey(Key("stesa_fan_$indice"));
    expect(carta, findsOneWidget, reason: "la carta $indice non e nell arco");
    final r = tester.getRect(carta);
    await tester.tapAt(Offset(r.left + 6, r.center.dy));
    await tester.pump();
  }""",
    'test/il_responso_non_lampeggia_test.dart': """    final carta = find.byKey(Key('stesa_fan_$indice'));
    expect(carta, findsOneWidget,
        reason: 'la carta $indice non e\\' nell\\'arco');
    final r = tester.getRect(carta);
    await tester.tapAt(Offset(r.left + 6, r.center.dy));
    await tester.pump();
  }""",
    'test/la_stesa_si_capisce_test.dart': """    final carta = find.byKey(Key('stesa_fan_$indice'));
    expect(carta, findsOneWidget,
        reason: 'la carta $indice non e\\' nell\\'arco');
    final r = tester.getRect(carta);
    await tester.tapAt(Offset(r.left + 6, r.center.dy));
    await tester.pump();
    // Il volo, poi il flip: due attese distinte, perche' il flip parte quando
    // la carta e' arrivata nel suo slot.
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 200));
  }""",
}

for percorso, coda in FILE.items():
    grezzo = open(percorso, 'rb').read().decode('utf-8')
    crlf = CR in grezzo
    s = grezzo.replace(CR + NL, NL) if crlf else grezzo
    assert s.count(PREAMBOLO) == 1, (percorso, 'preambolo',
                                     s.count(PREAMBOLO))
    s = s.replace(PREAMBOLO, '')
    assert s.count(coda) == 1, (percorso, 'coda', s.count(coda))
    # il pulsante si preme DOPO il tocco sulla carta, dentro lo stesso aiuto
    nuovo = coda[:-len('  }')] + POSTAMBOLO + '  }'
    s = s.replace(coda, nuovo)
    if 'material.dart' not in s:
        s = s.replace("import 'package:flutter_test/flutter_test.dart';",
                      "import 'package:flutter/material.dart';" + NL +
                      "import 'package:flutter_test/flutter_test.dart';")
    open(percorso, 'wb').write(
        (s.replace(NL, CR + NL) if crlf else s).encode('utf-8'))
    print('FATTO', percorso, 'postambolo presente:', POSTAMBOLO[:30] in s)
