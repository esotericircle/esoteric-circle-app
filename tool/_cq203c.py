# -*- coding: utf-8 -*-
"""CQ2.03: la guardia P.17 si rovescia, il rito non si monta piu'."""
NL = chr(10)
CR = chr(13)
P = 'test/i_doni_si_agganciano_test.dart'

grezzo = open(P, 'rb').read().decode('utf-8')
crlf = CR in grezzo
s = grezzo.replace(CR + NL, NL) if crlf else grezzo

apri = s.index("    test('ogni schermata di rito monta le tre righe', () {")
chiudi = s.index("    test('il respiro contato non e\\' piu\\' un testo da leggere', () {")

nuovo = """    test('nessuna schermata di rito annuncia piu un rito', () {
      // **LA LEGGE SI E' ROVESCIATA. Ordine CQ voce 2.03**, 3 settembre 2026.
      //
      // L'ordine P voce 17 aveva chiesto che ogni rito dichiarasse cosa fai,
      // perche' e cosa ti resta, e la ragione era buona: i riti dicevano il
      // nome e mostravano un gesto, e chi apriva non sapeva cosa ne avrebbe
      // portato via.
      //
      // **Il fondatore ha misurato l'effetto e non l'intenzione**: l'Arcano
      // *"annuncia un rito che non esiste"*, e la prima cosa che si legge
      // aprendo un Dono e' un compito. La voce 2.00 lo ha trovato in tutti e
      // cinque, non solo li'. Cio' che resta al posto delle tre righe e' la
      // risposta, che l'ordine CO voce 17 aveva gia' scritto e messo sopra.
      //
      // **Le tre righe non sono state cancellate dal dato**: vivono ancora su
      // `DailyElement` e descrivono il Dono nel menu' degli avvisi, dove una
      // descrizione serve davvero. Cio' che esce e' la loro comparsa in cima
      // al responso.
      const schermate = [
        'lib/features/rituals/ritual_gift_card.dart', // Alba e Soffio
        'lib/features/rituals/ritual_view.dart', // Oracolo
        'lib/features/rituals/sunset_rune_screen.dart', // Tramonto
        'lib/features/rituals/dream_rite_screen.dart', // Sogno
      ];
      final conIlRito = <String>[];
      var guardate = 0;
      for (final file in schermate) {
        guardate++;
        if (File(file).readAsStringSync().contains('LeTreRigheDelRito(')) {
          conIlRito.add(file);
        }
      }
      // ignore: avoid_print
      print('ORDINE CQ VOCE 2.03: schermate di rito guardate $guardate, che '
          'annunciano ancora un rito ${conIlRito.length}');
      expect(guardate, 4,
          reason: 'l elenco delle schermate si e svuotato: questa prova '
              'sarebbe verde senza aver guardato niente');
      expect(conIlRito, isEmpty,
          reason: 'queste schermate annunciano ancora un rito con le sue tre '
              'righe di istruzioni:\\n${conIlRito.join("\\n")}');
    });

"""
s = s[:apri] + nuovo + s[chiudi:]
open(P, 'wb').write((s.replace(NL, CR + NL) if crlf else s).encode('utf-8'))
print('FATTO')
