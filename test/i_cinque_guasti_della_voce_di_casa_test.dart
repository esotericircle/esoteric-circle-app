import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:esoteric_circle/core/viaggio/la_voce_del_mondo_di_sotto.dart';
import 'package:esoteric_circle/core/viaggio/le_guardie_del_responso.dart';
import 'package:flutter_test/flutter_test.dart';

/// **I CINQUE GUASTI DELLA VOCE DI CASA, E IL GERGO CHE NON LO E'.** Ordine
/// DQ voci 07 e 09, 15 settembre 2026.
///
/// Sono i guasti numero 1, 2, 4, 5 e 7 del rapporto dell'ordine DN, riferiti
/// e non curati quando il fondatore ha fermato l'ordine alla build 2261. Ogni
/// prova qui sotto e' nata rossa sul codice di quel giorno.
void main() {
  const neutra = CourtesyForm.neutral;
  const l = 'a-zàèéìòù';

  group('DQ.09 punto 1, il tema della persona senza marca di genere', () {
    test('nessuna risposta di casa del tema persona dice le, lei o la', () {
      // **IL FATTO**, sedici risposte su 1.100 nella misura dell'ordine DN:
      // *"Hai affidato alla discesa una persona. Quanto tempo le dedichi"*
      // alla domanda sul padre, *"Stai aspettando che sia lei a nominare la
      // cosa"* al marito che beve. La persona di cui si chiede puo' essere un
      // uomo o una donna, e la risposta di casa non lo sa: non ne porta il
      // genere, in nessuna forma.
      final pronome = RegExp(
          // Il pronome tonico.
          '(?<![$l])(?:lei|lui)(?![$l])|'
          // Il clitico davanti al verbo di chi legge, in testa alla frase o
          // dopo che: *"Le stai dando"*, *"le dedichi"*. Il verbo in -i, la
          // seconda persona: *"La domanda vera"* e' un articolo.
          '(?:^|che |non )(?:la|lo) [$l]+i(?![$l])|'
          // *Le* e *gli* anche in mezzo: *"Quanto tempo le dedichi"*.
          '(?<![$l])(?:le|gli) [$l]+i(?![$l])|'
          // Il clitico attaccato all'infinito: *"tenerla"*, *"trattarla"*.
          // Senza *lo*: *"quello che manca e' dirlo"* dice la cosa.
          '[$l]+(?:ar|er|ir)(?:la|le|gli)(?![$l])',
          caseSensitive: false);
      final risposte = LaVoceDelMondoDiSotto.rispostePerTema['persona']!;
      // Il cardinale: le dodici risposte del tema.
      expect(risposte.length, 12);
      final colGenere = [
        for (final r in risposte)
          if (pronome.hasMatch(r.replaceAll(RegExp('lo sai'), ''))) r,
      ];
      expect(colGenere, isEmpty,
          reason: 'risposte che danno un genere a chi non lo ha:\n'
              '${colGenere.join('\n')}');
    });
  });

  group('DQ.09 punto 2, i gesti di casa valgono per ogni domanda', () {
    test('nessun gesto presuppone una scelta fra due strade', () {
      // *"Datti tre giorni. Alla fine scegli comunque."* detto a chi voleva
      // accendere una candela per il nonno, nove volte su 1.100. I venti
      // gesti sono di tutti i temi: nessuno puo' dare per scontato che la
      // domanda sia una scelta.
      final scelta = RegExp(
          '(?<![$l])(?:scegli|sceglier[$l]*|decid[$l]*|deciso|decisione|'
          'opzion[$l]*|colonne|dire di no|informazioni)(?![$l])',
          caseSensitive: false);
      const gesti = LaVoceDelMondoDiSotto.cosaPuoiFare;
      expect(gesti.length, 20);
      final presuppongono = [
        for (final g in gesti)
          if (scelta.hasMatch(g)) g,
      ];
      expect(presuppongono, isEmpty,
          reason: 'gesti che danno per scontata una scelta:\n'
              '${presuppongono.join('\n')}');
    });

    test('nessun gesto comincia da un pronome che non ha a chi riferirsi', () {
      // *"Dilla a una persona sola"*, otto volte su 1.100: la che cosa? Il
      // gesto e' la prima cosa del suo paragrafo, e un pronome in testa non
      // ha niente prima di se'.
      // L'imperativo col clitico dopo una vocale o raddoppiato: *"Dilla"*,
      // *"Mettila"*, *"Piegali"*. *"Togli"* e' un verbo intero.
      final senzaAntecedente =
          RegExp('^[A-ZÀ-Ý][$l]*(?:[aeiou](?:la|lo|li|le)|ll[aoie])(?![$l])');
      final orfani = [
        for (final g in LaVoceDelMondoDiSotto.cosaPuoiFare)
          if (senzaAntecedente.hasMatch(g)) g,
      ];
      expect(orfani, isEmpty, reason: orfani.join('\n'));
    });
  });

  group('DQ.09 punto 3 e DQ.07, il dizionario del gergo', () {
    MotivoDelloScarto? risp(String r) => LeGuardieDelResponso.dellaRisposta(r,
        domanda: 'Devo lasciare la banca per la bottega?', forma: neutra);

    test('le due varianti che la guardia non conosceva', () {
      // Dalla lettura delle 1.100 risposte dell'ordine DN: *"e' gia' in te"*
      // nove volte, *"Abbi fiducia nel processo"* una.
      expect(risp('Quello che cerchi sulla bottega è già in te.'),
          MotivoDelloScarto.gergo);
      expect(risp('Sulla bottega abbi fiducia nel processo.'),
          MotivoDelloScarto.gergo);
    });

    test('il tuo spazio non e gergo', () {
      // **ORDINE DQ VOCE 07**: *"scartare risposte decenti per una locuzione
      // che in italiano e' normale e' un prezzo che non paga"*.
      expect(risp('Sulla bottega puoi prenderti il tuo spazio.'), isNull);
      expect(
          LeGuardieDelResponso.delTitolo('Cerca il tuo spazio',
              domanda: 'Devo lasciare la banca per la bottega?', forma: neutra),
          isNull);
    });
  });

  group('DQ.09 punto 4, il pronome del gesto del modello concorda', () {
    MotivoDelloScarto? gesto(String a) => LeGuardieDelResponso.dellAzione(a,
        domanda: 'Che strada prendo dopo la laurea?', forma: neutra);

    test('dopo un foglio si piega il foglio', () {
      // *"scrivi su un foglio tutti i possibili passi futuri. Piegali e
      // mettili sotto il cuscino"*: si piega il foglio, non i passi.
      expect(
          gesto('Stasera scrivi su un foglio tutti i possibili passi futuri. '
              'Piegali e mettili sotto il cuscino.'),
          MotivoDelloScarto.pronomeSenzaAccordo);
      expect(
          gesto('Stasera scrivi su un pezzo di carta le tue paure. '
              'Strappale e gettale.'),
          MotivoDelloScarto.pronomeSenzaAccordo);
    });

    test('il singolare giusto e il plurale che ha i suoi fogli passano', () {
      expect(
          gesto('Stasera scrivi su un foglio tutti i possibili passi futuri. '
              'Piegalo e mettilo sotto il cuscino.'),
          isNull);
      expect(
          gesto('Stasera scrivi su due fogli le due strade. '
              'Piegali e mettili sotto il cuscino.'),
          isNull);
    });
  });

  group('DQ.09 punto 5, un tempo solo: la risposta di casa non ne ha', () {
    test('nessuna risposta di casa porta un tempo suo', () {
      // *"Una direzione per oggi basta: domani la correggi"*, tre volte, e
      // *"Muovi una cosa piccola adesso"*, cinque, sopra il gesto che il suo
      // tempo lo porta sempre. Il tempo del responso e' quello del gesto.
      final tutte = [
        for (final r in LaVoceDelMondoDiSotto.rispostePerTema.values) ...r,
        ...LaVoceDelMondoDiSotto.risposteSenzaDomanda,
      ];
      // Il cardinale: settantadue risposte coi temi, otto senza.
      expect(tutte.length, 80);
      final colTempo = [
        for (final r in tutte)
          if (LeGuardieDelResponso.indicazioneDiTempo.hasMatch(r)) r,
      ];
      expect(colTempo, isEmpty, reason: colTempo.join('\n'));
    });
  });
}
