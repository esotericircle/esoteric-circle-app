# -*- coding: utf-8 -*-
"""CQ1.03: la guardia del gating passa dal tocco al pulsante."""
NL = chr(10)
CR = chr(13)
P = 'test/il_gating_della_stesa_test.dart'

grezzo = open(P, 'rb').read().decode('utf-8')
crlf = CR in grezzo
s = grezzo.replace(CR + NL, NL) if crlf else grezzo


def cambia(vecchio, nuovo, quante=1):
    global s
    assert s.count(vecchio) == quante, (s.count(vecchio), vecchio[:80])
    s = s.replace(vecchio, nuovo)


# --- gli aiuti: si pesca liberamente, si preme per leggere --------------
cambia("""  /// **PRIMA SI PREME PER COMINCIARE. Ordine CO voce 07**, 3 settembre 2026.
  ///
  /// Il fondatore ha chiesto un pulsante esplicito, e con lui il cancello del
  /// piano si e' spostato: prima si guardava sul PRIMO TOCCO di una carta,
  /// adesso si guarda quando si preme "Inizia la lettura". E' il momento
  /// giusto, ed e' il motivo per cui queste quattro prove sono diventate rosse
  /// prima di essere aggiornate: toccavano il ventaglio senza aver cominciato,
  /// e il ventaglio non risponde piu' a chi non ha cominciato.
  ///
  /// Torna vero se la lettura si e' avviata. Falso vuol dire che il cancello
  /// ha sbarrato, ed e' un esito legittimo che alcune di queste prove
  /// pretendono.
  Future<bool> comincia(WidgetTester tester) async {
    final pulsante = find.byKey(const Key('stesa_inizia'));
    if (tester.widgetList(pulsante).isEmpty) return true;
    await tester.tap(pulsante, warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    return tester.widgetList(find.byKey(const Key('stesa_inizia'))).isEmpty;
  }

  Future<void> pesca(WidgetTester tester, int indice) async {
    // **SE IL CANCELLO HA SBARRATO NON SI PESCA, e non e' un fallimento.**
    // Ordine CO voce 07: l'invito a salire di livello copre la scena, e
    // cercare una carta sotto di lui vorrebbe dire cercarla dietro un foglio.
    // Le prove che verificano lo sbarramento arrivano qui apposta.
    if (!await comincia(tester)) return;
    final carta = find.byKey(Key('stesa_fan_$indice'));""",
"""  /// **IL CANCELLO STA SUL PULSANTE, E IL PULSANTE STA DOPO LE CARTE.**
  /// Ordine CQ voce 1.03, 3 settembre 2026, e ribalta l'ordine CO voce 07.
  ///
  /// CO.07 aveva spostato il cancello dal primo tocco al pulsante, e il
  /// pulsante stava PRIMA delle carte. Adesso il ventaglio e' vivo da subito e
  /// il pulsante sta DOPO: si sceglie senza pagare, si paga per leggere. Il
  /// cancello resta uno solo e si guarda qui.
  ///
  /// Torna vero se la lettura si e' aperta. Falso vuol dire che il cancello ha
  /// sbarrato, ed e' un esito legittimo che alcune di queste prove
  /// pretendono.
  Future<bool> apri(WidgetTester tester) async {
    final pulsante = find.byKey(const Key('stesa_inizia'));
    for (var i = 0; i < 40; i++) {
      if (pulsante.evaluate().isNotEmpty &&
          tester.widget<FilledButton>(pulsante).onPressed != null) {
        break;
      }
      await tester.pump(const Duration(milliseconds: 200));
    }
    if (pulsante.evaluate().isEmpty) return true;
    await tester.tap(pulsante, warnIfMissed: false);
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    return find.byKey(const Key('stesa_inizia')).evaluate().isEmpty;
  }

  /// Le tre carte, e poi il pulsante. Torna cio' che torna [apri].
  Future<bool> stendiEApri(WidgetTester tester) async {
    for (final indice in const [38, 39, 40]) {
      await pesca(tester, indice);
    }
    return apri(tester);
  }

  Future<void> pesca(WidgetTester tester, int indice) async {
    final carta = find.byKey(Key('stesa_fan_$indice'));""")

# --- il consumo si sposta sul pulsante ---------------------------------
cambia("""    // Una carta sola: la stesa e' cominciata e non e' compiuta.
    await pesca(tester, 38);
    expect(borsa.steseRimaste(Tier.tier2), 7,
        reason: 'una stesa cominciata ha gia\\' consumato: chi cambia idea '
            'alla prima carta paga per niente');

    // La seconda e la terza: adesso la stesa e' compiuta.
    await pesca(tester, 39);
    expect(borsa.steseRimaste(Tier.tier2), 7,
        reason: 'la seconda carta ha consumato: il conto e\\' per carta e '
            'non per stesa');
    await pesca(tester, 40);
    await tester.pump(const Duration(seconds: 5));
    expect(borsa.steseRimaste(Tier.tier2), 6,
        reason: 'la stesa e\\' compiuta e non ha consumato niente: il '
            'listino promette un tetto che nessuno impone');""",
"""    // Una carta sola: la stesa e' cominciata e non e' compiuta.
    await pesca(tester, 38);
    expect(borsa.steseRimaste(Tier.tier2), 7,
        reason: 'una stesa cominciata ha gia\\' consumato: chi cambia idea '
            'alla prima carta paga per niente');

    // La seconda e la terza: le carte sono posate e ancora non si paga.
    // **Ordine CQ voce 1.03**: il conto e' del pulsante, non delle carte.
    await pesca(tester, 39);
    expect(borsa.steseRimaste(Tier.tier2), 7,
        reason: 'la seconda carta ha consumato: il conto e\\' per carta e '
            'non per stesa');
    await pesca(tester, 40);
    await tester.pump(const Duration(seconds: 5));
    expect(borsa.steseRimaste(Tier.tier2), 7,
        reason: 'tre carte posate hanno gia\\' consumato la stesa: chi ci '
            'ripensa prima di leggere paga per niente, ed e\\' cio\\' che '
            'l\\'ordine CQ voce 1.03 chiude');

    // Il pulsante: e' questo il gesto che si paga.
    await apri(tester);
    await tester.pump(const Duration(seconds: 5));
    expect(borsa.steseRimaste(Tier.tier2), 6,
        reason: 'la lettura e\\' aperta e non ha consumato niente: il '
            'listino promette un tetto che nessuno impone');""")

# --- la riserva finita: sbarra il pulsante, non il tocco ---------------
cambia("""    await pesca(tester, 38);
    expect(find.byKey(const Key('upgrade_invite')), findsOneWidget,
        reason: 'il ventaglio e\\' muto a riserva finita: e\\' un vicolo cieco');""",
"""    await stendiEApri(tester);
    expect(find.byKey(const Key('upgrade_invite')), findsOneWidget,
        reason: 'il pulsante e\\' muto a riserva finita: e\\' un vicolo cieco');""")

# --- il Viandante ------------------------------------------------------
cambia("""    await pesca(tester, 38);
    expect(find.byKey(const Key('upgrade_invite')), findsNothing,
        reason: 'la PRIMA stesa del giorno chiede gli Eos al Viandante: e\\' '
            'quella compresa nel piano');
    expect(find.byKey(const Key('stesa_blocco_carte')), findsOneWidget,
        reason: 'la prima stesa del giorno non e\\' partita');""",
"""    await stendiEApri(tester);
    expect(find.byKey(const Key('upgrade_invite')), findsNothing,
        reason: 'la PRIMA stesa del giorno chiede gli Eos al Viandante: e\\' '
            'quella compresa nel piano');
    expect(find.byKey(const Key('stesa_blocco_carte')), findsOneWidget,
        reason: 'la prima stesa del giorno non e\\' partita');""")

cambia("""    await monta(tester, piano: Tier.free, borsa: dopo);
    await pesca(tester, 38);
    expect(find.byKey(const Key('upgrade_invite')), findsOneWidget,""",
"""    await monta(tester, piano: Tier.free, borsa: dopo);
    await stendiEApri(tester);
    expect(find.byKey(const Key('upgrade_invite')), findsOneWidget,""")

cambia("""    // **A RISCATTO AVVENUTO LA LETTURA E' AVVIATA, e le carte si scelgono.**
    // Ordine CO voce 07, 3 settembre 2026, e questa riga cambia di misura ma
    // non di legge. Prima il riscatto ripartiva col TOCCO che era stato
    // sbarrato, cioe' posava la carta: era giusto finche' il primo tocco era
    // l'inizio della stesa. Adesso l'inizio e' il pulsante, quindi il riscatto
    // riprende da li': il ventaglio e' vivo e la prima carta la sceglie la
    // persona. **La legge resta intera**, cioe' che a riscatto avvenuto non si
    // chiede un secondo gesto per rifare quello appena sbarrato.
    expect(find.byKey(const Key('stesa_inizia')), findsNothing,
        reason: 'a riscatto avvenuto la lettura non e\\' partita: chiede di '
            'premere di nuovo il pulsante che era appena stato sbarrato');
    await pesca(tester, 38);
    expect(find.byKey(const Key('stesa_blocco_carte')), findsOneWidget,
        reason: 'col riscatto fatto e la lettura avviata il ventaglio non '
            'posa la carta');""",
"""    // **A RISCATTO AVVENUTO IL RESPONSO SI APRE DA SOLO.**
    // Ordine CQ voce 1.03, 3 settembre 2026, e la legge resta quella
    // dell'ordine BN voce 09: a riscatto avvenuto non si chiede un secondo
    // gesto per rifare quello appena sbarrato. Cambia quale gesto era stato
    // sbarrato: prima era il tocco sulla carta, con l'ordine CO voce 07 era il
    // pulsante che apriva la scelta, adesso e' il pulsante che apre la
    // lettura. Le tre carte erano gia' posate quando il cancello ha sbarrato,
    // quindi cio' che riprende e' la lettura, e si vede subito.
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 400));
    }
    expect(find.byKey(const Key('stesa_inizia')), findsNothing,
        reason: 'a riscatto avvenuto la lettura non e\\' partita: chiede di '
            'premere di nuovo il pulsante che era appena stato sbarrato');
    expect(find.byKey(const Key('stesa_blocco_carte')), findsOneWidget,
        reason: 'col riscatto fatto il responso non si apre');""")

open(P, 'wb').write((s.replace(NL, CR + NL) if crlf else s).encode('utf-8'))
print('FATTO. apri presente:', 'Future<bool> apri(' in s,
      '| comincia rimasto:', s.count('comincia(tester)'))
