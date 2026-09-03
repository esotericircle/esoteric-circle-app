# -*- coding: utf-8 -*-
"""CQ1.03: il gruppo CO.07 misura la legge nuova."""
NL = chr(10)
CR = chr(13)
P = 'test/la_stesa_comincia_quando_lo_dici_test.dart'

grezzo = open(P, 'rb').read().decode('utf-8')
crlf = CR in grezzo
s = grezzo.replace(CR + NL, NL) if crlf else grezzo


def cambia(vecchio, nuovo, quante=1):
    global s
    assert s.count(vecchio) == quante, (s.count(vecchio), vecchio[:80])
    s = s.replace(vecchio, nuovo)


cambia("""/// **CO.07, il rito cominciava da solo.** La schermata si apriva su un
/// ventaglio di carte coperte e nient'altro: niente diceva che si cominciava
/// toccando una carta, e la stesa partiva sul primo tocco. Un rito che comincia
/// senza che nessuno l'abbia cominciato non è un rito, è un incidente. E chi
/// non poteva stenderla lo scopriva toccando una carta che poi non si muoveva.""",
"""/// **CO.07, il rito cominciava da solo, e la cura e' stata ribaltata.** La
/// schermata si apriva su un ventaglio di carte coperte e nient'altro: niente
/// diceva che si cominciava toccando una carta, e la stesa partiva sul primo
/// tocco. CO.07 ci aveva messo un pulsante PRIMA delle carte, cioe' faceva
/// premere per ottenere il permesso di scegliere. **L'ordine CQ voce 1.03, lo
/// stesso giorno, lo ha rovesciato per decisione del fondatore**: il ventaglio
/// e' vivo da subito e il pulsante sta dopo le tre carte, dove apre la
/// lettura. Il gruppo qui sotto misura la legge nuova; il comportamento a
/// video lo misura `il_ventaglio_vive_subito_test.dart`, che e' una guardia di
/// scena e vede cose che leggere il sorgente non fa vedere.""")

cambia("""  group('CO.07, il rito lo comincia chi lo compie', () {
    test('il ventaglio non risponde a chi non ha cominciato', () {
      expect(codice, contains('if (!_letturaAvviata) return;'),
          reason: 'il ventaglio posa una carta anche senza che nessuno abbia '
              'premuto per cominciare: la stesa riparte sul primo tocco, che è '
              'il difetto che questa voce chiude');
    });

    test('il pulsante esiste e sparisce quando ha fatto il suo lavoro', () {
      expect(schermata, contains("Key('stesa_inizia')"),
          reason: 'il pulsante che comincia la lettura non c è piu');
      expect(codice, contains('if (!_letturaAvviata) ...['),
          reason: 'il pulsante resta acceso anche a lettura avviata: una cosa '
              'in piu da capire, che ha gia fatto il suo lavoro');
    });
""",
"""  group('CQ.1.03, si sceglie subito e si preme per leggere', () {
    test('il ventaglio non chiede il permesso a nessuno', () {
      expect(codice, isNot(contains('_letturaAvviata')),
          reason: 'il ventaglio chiede ancora che qualcuno abbia premuto per '
              'cominciare: e la legge dell ordine CO voce 07, che il '
              'fondatore ha rovesciato con l ordine CQ voce 1.03');
    });

    test('il pulsante si accende sulle tre carte, e non prima', () {
      expect(schermata, contains("Key('stesa_inizia')"),
          reason: 'il pulsante che apre il responso non c è piu');
      expect(codice, contains('onPressed: _complete && !_stoPerRiflettere'),
          reason: 'il pulsante non e appeso al compimento della stesa: o e '
              'sempre premibile, oppure lo governa qualcos altro');
      expect(codice, contains('if (!_responsoPronto) ...['),
          reason: 'il pulsante non e appeso al responso: se sparisse prima, '
              'sparirebbe proprio quando deve accendersi, ed e il difetto '
              'della prima stesura di questa voce');
    });

    test('il consumo sta sul pulsante, non sulla terza carta', () {
      // **IL GESTO CHE SI PAGA E' UNO SOLO, ed e' quello che apre la
      // lettura.** Ordine CQ voce 1.03: tre carte posate e poi ripensarci non
      // costa niente. Si misura la posizione nel file, perche' e' li' che il
      // difetto vivrebbe: `registraStesa` dentro `_pick` vorrebbe dire che la
      // terza carta paga.
      expect('registraStesa('.allMatches(codice).length, 1,
          reason: 'la stesa si registra da piu di un punto, oppure da '
              'nessuno');
      final pesca = codice.indexOf('Future<void> _pick(');
      final apre = codice.indexOf('Future<void> _apriIlResponso(');
      final consumo = codice.indexOf('registraStesa(');
      expect(pesca, greaterThanOrEqualTo(0));
      expect(apre, greaterThan(pesca),
          reason: 'il metodo che apre il responso non esiste');
      expect(consumo, greaterThan(apre),
          reason: 'il consumo della stesa sta dentro il metodo che pesca la '
              'carta: la terza carta paga, e chi ci ripensa prima di leggere '
              'ha pagato per niente');
    });
""")

open(P, 'wb').write((s.replace(NL, CR + NL) if crlf else s).encode('utf-8'))
print('FATTO')
