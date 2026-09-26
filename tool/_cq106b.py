# -*- coding: utf-8 -*-
"""CQ1.06: la guardia BF.05a passa dal tocco al pulsante."""
NL = chr(10)
CR = chr(13)
Q = chr(39)
P = 'test/dopo_il_responso_niente_scelte_test.dart'

grezzo = open(P, 'rb').read().decode('utf-8')
crlf = CR in grezzo
s = grezzo.replace(CR + NL, NL) if crlf else grezzo

vecchio = (
    "    // E il tocco su un" + Q + "altra pillola getta DAVVERO con quella stesa." + NL +
    "    await tester.ensureVisible(find.byKey(const Key(" + Q + "rune_segment_norne" + Q + ")));" + NL +
    "    await tester.pump();" + NL +
    "    await tester.tap(find.byKey(const Key(" + Q + "rune_segment_norne" + Q + ")));" + NL +
    "    await passo(tester);" + NL +
    "    expect(find.text(" + Q + "LE TRE NORNE" + Q + "), findsOneWidget," + NL +
    "        reason: " + Q + "il tocco sulla pillola delle Norne non ha gettato con le " + Q + NL +
    "            " + Q + "Norne: la scelta dal responso e" + chr(92) + Q + " muta" + Q + ");"
)

nuovo = (
    "    // **E IL TOCCO SU UN" + Q + "ALTRA PILLOLA NON GETTA PIU" + Q + ".**" + NL +
    "    // Ordine CQ voce 1.06, 3 settembre 2026, e ribalta l" + Q + "ordine BF voce" + NL +
    "    // 05.a su un punto solo: le pillole restano, ma **toccarle sceglie e" + NL +
    "    // basta**. Il fondatore ha visto partire il responso mentre stava" + NL +
    "    // ancora scegliendo, e una gettata consumata senza averla chiesta." + NL +
    "    await tester.ensureVisible(find.byKey(const Key(" + Q + "rune_segment_norne" + Q + ")));" + NL +
    "    await tester.pump();" + NL +
    "    await tester.tap(find.byKey(const Key(" + Q + "rune_segment_norne" + Q + ")));" + NL +
    "    await passo(tester);" + NL +
    "    expect(find.text(" + Q + "LE TRE NORNE" + Q + "), findsNothing," + NL +
    "        reason: " + Q + "il tocco sulla pillola ha gettato da solo: e il difetto " + Q + NL +
    "            " + Q + "che l ordine CQ voce 1.06 chiude" + Q + ");" + NL +
    NL +
    "    // E" + Q + " il pulsante a gettare, con la stesa appena scelta." + NL +
    "    await tester.ensureVisible(find.byKey(const Key(" + Q + "rune_recast" + Q + ")));" + NL +
    "    await tester.pump();" + NL +
    "    await tester.tap(find.byKey(const Key(" + Q + "rune_recast" + Q + ")));" + NL +
    "    await passo(tester);" + NL +
    "    expect(find.text(" + Q + "LE TRE NORNE" + Q + "), findsOneWidget," + NL +
    "        reason: " + Q + "premuto Getta ancora dopo aver scelto le Norne, la lettura " + Q + NL +
    "            " + Q + "non e quella delle Norne: la scelta non arriva al getto, e dal " + Q + NL +
    "            " + Q + "responso non si cambia piu stesa in nessun modo" + Q + ");"
)

assert s.count(vecchio) == 1, s.count(vecchio)
s = s.replace(vecchio, nuovo)
open(P, 'wb').write((s.replace(NL, CR + NL) if crlf else s).encode('utf-8'))
assert 'il tocco sulla pillola ha gettato da solo' in \
    open(P, 'rb').read().decode('utf-8')
print('FATTO')
