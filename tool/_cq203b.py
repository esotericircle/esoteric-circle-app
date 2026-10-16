# -*- coding: utf-8 -*-
"""CQ2.03: la guardia di CO.17 passa dalla gerarchia all'assenza del rito."""
NL = chr(10)
CR = chr(13)
P = 'test/il_dono_risponde_prima_di_chiedere_test.dart'

grezzo = open(P, 'rb').read().decode('utf-8')
crlf = CR in grezzo
s = grezzo.replace(CR + NL, NL) if crlf else grezzo

apri = s.index("      const doveGuardare = <String, (String risposta, String gesto)>{")
chiudi = s.index("    test('a schermo il titolo viene PRIMA del gesto', () {")
nuovo = """      // **E ADESSO IL GESTO NON C'E' PIU' AFFATTO.**
      // Ordine CQ voce 2.03, 3 settembre 2026.
      //
      // CO.17 aveva messo la risposta SOPRA le tre righe del rito, e questa
      // prova misurava proprio quell'ordine. Il fondatore le ha poi fatte
      // togliere del tutto: *l'Arcano annuncia un rito che non esiste*, e la
      // misura della voce 2.00 ha trovato lo stesso compito in tutti e
      // cinque i Doni, non solo li'.
      //
      // **La pretesa cambia di grandezza, non si ammorbidisce**: prima
      // chiedeva che la risposta stesse prima del gesto, adesso chiede che il
      // gesto annunciato non compaia in nessuna delle cinque schermate. E' la
      // stessa legge portata fino in fondo.
      const schermate = <String, String>{
        'lib/features/rituals/day_oracle_screen.dart': 'arcano_sommario',
        'lib/features/rituals/sunset_rune_screen.dart': 'sunset_risposta',
        'lib/features/rituals/dream_rite_screen.dart': 'dream_message_title',
        'lib/features/rituals/ritual_gift_card.dart': 'risposta.titolo',
        'lib/features/rituals/ritual_view.dart': 'rito_ripiego',
      };
      var guardate = 0;
      final conIlRito = <String>[];
      for (final voce in schermate.entries) {
        // **SI LEGGE IL SORGENTE VERO E NON QUELLO SENZA TESTO.** Le chiavi
        // dei widget SONO stringhe, e la porta che toglie il testo le
        // toglierebbe insieme ai commenti.
        final s = File(voce.key).readAsStringSync();
        guardate++;
        expect(s.indexOf(voce.value), greaterThanOrEqualTo(0),
            reason: '${voce.key} non mostra piu ${voce.value}: questa prova '
                'sta guardando una schermata che non esiste piu cosi');
        if (codiceSenzaTesto(s).contains('LeTreRigheDelRito')) {
          conIlRito.add(voce.key);
        }
      }
      // ignore: avoid_print
      print('ORDINE CQ VOCE 2.03: schermate guardate $guardate, che annunciano '
          'ancora un rito ${conIlRito.length}');
      expect(conIlRito, isEmpty,
          reason: 'queste schermate annunciano ancora un rito con le sue tre '
              'righe di istruzioni: ${conIlRito.join(", ")}');
      cardinaleMinimo(guardate, 5,
          cosa: 'schermate dei Doni con una gerarchia da sorvegliare',
          perche: 'Se una schermata sparisse da questo elenco, la sua '
              'gerarchia smetterebbe di essere sorvegliata senza che nessuno '
              'se ne accorga.');
    });

    test('il componente delle tre righe non esiste piu in nessun sorgente',
        () {
      // **CIO' CHE NON DEVE COMPARIRE NON DEVE NEMMENO ESISTERE.** Un
      // componente che nessuno monta e' un invito a rimontarlo, e la prima
      // schermata nuova che ne avesse bisogno lo troverebbe li' pronto,
      // insieme al compito che il fondatore ha fatto togliere.
      final vivo = File('lib/design_system/components/le_tre_righe_del_rito.dart')
          .existsSync();
      // ignore: avoid_print
      print('ORDINE CQ VOCE 2.03: il componente delle tre righe esiste $vivo');
      expect(vivo, isFalse,
          reason: 'il componente delle tre righe del rito e ancora nel '
              'progetto: nessuno lo monta, ma il primo che ne avesse bisogno '
              'lo troverebbe pronto');
    });

"""
s = s[:apri] + nuovo + s[chiudi:]

# la seconda prova misurava la stessa cosa sulla scheda: adesso misura che il
# titolo apra la scheda e che il rito non ci sia.
vecchio = """      final treRighe = scheda.indexOf('LeTreRigheDelRito');"""
assert s.count(vecchio) == 1
s = s.replace(vecchio, """      final treRighe = scheda.indexOf('LeTreRigheDelRito');
      // **NON C'E' PIU', ordine CQ voce 2.03**: `indexOf` torna meno uno, e
      // una pretesa scritta su quel meno uno direbbe il falso. Si dichiara
      // qui che l'assenza e' voluta, e la sorveglia la prova qui sopra.
      expect(treRighe, -1,
          reason: 'le tre righe del rito sono tornate nella scheda del Dono');""")

apri2 = s.index("      expect(risposta, greaterThan(titolo),")
chiudi2 = s.index('    });', apri2)
s = s[:apri2] + """      expect(risposta, greaterThan(titolo),
          reason: 'nella scheda la risposta viene prima del titolo');
""" + s[chiudi2:]

open(P, 'wb').write((s.replace(NL, CR + NL) if crlf else s).encode('utf-8'))
print('FATTO')
