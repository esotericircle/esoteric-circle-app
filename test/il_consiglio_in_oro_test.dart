import 'dart:io';

import 'package:esoteric_circle/core/maestro/consiglio_finale.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/services/ai/maestro_persona.dart';
import 'package:esoteric_circle/core/chat/maestro_memory.dart';
import 'package:esoteric_circle/core/chat/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

/// IL CONSIGLIO FINALE, CON LA STELLA.
///
/// Ogni risposta di ogni Maestro finisce con UNA riga sola, in oro, preceduta
/// da una stella. Non una freccia: la freccia promette un altrove, la stella
/// dichiara un dono. E quella che stava li' non era nemmeno toccabile.
void main() {
  const testo = 'Il tuo Sole in Cancro chiede riparo prima di chiedere '
      'strada. Quello che senti come confusione è un confine che si sposta.\n'
      '✦ Non è il momento di decidere, è il momento di guardare dove ti fermi.';

  group('La riga si solleva dal testo del Maestro', () {
    test('La sintesi e\' quella marcata, e il corpo non la contiene', () {
      expect(ConsiglioFinale.sintesiDa(testo),
          'Non è il momento di decidere, è il momento di guardare dove ti fermi.');
      expect(ConsiglioFinale.corpoDa(testo),
          isNot(contains(ConsiglioFinale.stella)));
      expect(ConsiglioFinale.corpoDa(testo), isNot(contains('Non è il momento')));
      // E il corpo resta intero: si toglie la riga, non una parola di piu'.
      expect(ConsiglioFinale.corpoDa(testo), contains('Il tuo Sole in Cancro'));
      expect(ConsiglioFinale.corpoDa(testo), contains('un confine che si sposta.'));
    });

    test('Senza marcatore resta il solo INVITO, e NIENTE si ripete', () {
      // **UNA PROVA VECCHIA HA BOCCIATO IL PRIMO RIPIEGO, ed era giusto.**
      // Prendeva la prima frase del corpo, che pero' sta gia' a schermo in
      // bianco due righe sopra: la persona la leggeva due volte, e la seconda
      // in oro, cioe' col rilievo di una cosa nuova. Meglio mezza riga vera.
      const senza = 'Il tuo Sole in Cancro chiede riparo. Poi viene il resto.';
      expect(ConsiglioFinale.sintesiDa(senza), isNull);
      final riga = ConsiglioFinale.componi(Maestro.medora,
          testo: senza, quando: DateTime(2026, 8, 4), identita: 'prova');
      expect(riga, isNotEmpty,
          reason: 'senza marcatore la riga sparisce del tutto, mentre '
              'l\'invito a tornare non dipende da cio\' che il Maestro ha '
              'scritto');
      expect(riga, isNot(contains(ConsiglioFinale.primaFraseDi(senza))),
          reason: 'la riga in oro ripete una frase che sta gia\' nel corpo');
      expect(riga,
          ConsiglioFinale.invitoDelRitorno(Maestro.medora,
              quando: DateTime(2026, 8, 4), identita: 'prova'));
    });

    test('La riga intera e\' sintesi PIU\' invito, mai una sola delle due', () {
      final riga = ConsiglioFinale.componi(Maestro.medora,
          testo: testo, quando: DateTime(2026, 8, 4), identita: 'prova');
      expect(riga, contains('Non è il momento di decidere'));
      expect(riga.length,
          greaterThan(ConsiglioFinale.sintesiDa(testo)!.length + 10),
          reason: 'la riga porta solo la sintesi: manca l\'invito a tornare');
    });
  });

  group('L\'invito e\' agganciato a cio\' che cambia da solo', () {
    /// QUANTO POSSONO SOMIGLIARSI DUE INVITI DI GIORNI VICINI.
    ///
    /// **Il numero e' misurato, non scelto.** Su sessanta coppie di giorni
    /// consecutivi la somiglianza peggiore misurata vale 0,333 per Medora,
    /// 0,222 per Aura e 0,059 per Caligo. Medora e' la piu' alta perche' la
    /// Luna resta due giorni e mezzo nello stesso segno, quindi capita che
    /// cambi solo la forma della frase. La soglia sta a 0,45, cioe' col
    /// trentacinque per cento di margine sopra il caso peggiore vero.
    ///
    /// Si misura sulle PAROLE condivise, non sui caratteri: due frasi diverse
    /// che parlano della stessa cosa condividono le parole, ed e' esattamente
    /// cio' che l'ordine chiama "un sinonimo pescato dal modello".
    const soglia = 0.45;

    double somiglianza(String a, String b) {
      Set<String> parole(String s) => s
          .toLowerCase()
          .replaceAll(RegExp(r'[^\wàèéìòùÀÈÉÌÒÙ ]'), '')
          .split(RegExp(r'\s+'))
          .where((p) => p.isNotEmpty)
          .toSet();
      final x = parole(a), y = parole(b);
      if (x.isEmpty || y.isEmpty) return 0;
      return x.intersection(y).length / x.union(y).length;
    }

    test('Due giorni consecutivi non si somigliano, per nessun Maestro', () {
      var confronti = 0;
      for (final m in Maestro.values) {
        for (var g = 0; g < 60; g++) {
          final oggi = DateTime(2026, 8, 4).add(Duration(days: g));
          final a = ConsiglioFinale.invitoDelRitorno(m,
              quando: oggi, identita: 'prova');
          final b = ConsiglioFinale.invitoDelRitorno(m,
              quando: oggi.add(const Duration(days: 1)), identita: 'prova');
          confronti++;
          expect(somiglianza(a, b), lessThan(soglia),
              reason: '${m.displayName}, giorno $g:\n  "$a"\n  "$b"');
        }
      }
      // Senza questa riga un ciclo che non gira lascerebbe la prova verde.
      expect(confronti, Maestro.values.length * 60);
    });

    test('Nessun invito e\' vuoto, e ognuno nomina un dato di domani', () {
      for (final m in Maestro.values) {
        for (var g = 0; g < 14; g++) {
          final invito = ConsiglioFinale.invitoDelRitorno(m,
              quando: DateTime(2026, 8, 4).add(Duration(days: g)),
              identita: 'prova');
          expect(invito.trim(), isNotEmpty);
          // Ogni invito parla del DOMANI, non di un altrove generico.
          expect(
              invito.toLowerCase(),
              anyOf(contains('domani'), contains('ripassa'),
                  contains('rivediamoci')),
              reason: '${m.displayName}: "$invito" non invita a tornare');
        }
      }
    });

    test('Ogni Maestro ha il SUO aggancio, e non quello di un altro', () {
      // Il cielo per Medora, la runa della sera per Caligo, il chakra per
      // Aura: se due Maestri invitassero a tornare per la stessa cosa,
      // l'aggancio non sarebbe piu' suo.
      final visti = <Maestro, Set<String>>{};
      for (final m in Maestro.values) {
        visti[m] = {
          for (var g = 0; g < 30; g++)
            ConsiglioFinale.invitoDelRitorno(m,
                quando: DateTime(2026, 8, 4).add(Duration(days: g)),
                identita: 'prova')
        };
      }
      for (final a in Maestro.values) {
        for (final b in Maestro.values) {
          if (a == b) continue;
          expect(visti[a]!.intersection(visti[b]!), isEmpty,
              reason: '${a.displayName} e ${b.displayName} invitano a tornare '
                  'per la stessa cosa');
        }
      }
    });
  });

  group('Il consiglio non costa una chiamata in piu\'', () {
    test('L\'istruzione entra nella persona di OGNI Maestro', () {
      for (final m in Maestro.values) {
        final istr = MaestroPersona.systemInstruction(
          maestro: m,
          profile: UserProfile.empty,
          memory: MaestroMemory.empty,
        );
        expect(istr, contains(ConsiglioFinale.istruzione),
            reason: '${m.displayName} non sa che deve chiudere col consiglio');
        // E anche nella lettura BREVE, cioe' quella del Viandante: il
        // consiglio non e' un contenuto premium.
        final breve = MaestroPersona.systemInstruction(
          maestro: m,
          profile: UserProfile.empty,
          memory: MaestroMemory.empty,
        );
        expect(breve, contains(ConsiglioFinale.istruzione),
            reason: '${m.displayName} non da\' il consiglio a chi legge la '
                'lettura breve, che e\' proprio chi legge solo quella');
      }
    });

    test('Il consiglio non si puo\' nemmeno CHIEDERE, per costruzione', () {
      // **LA PRIMA STESURA GUARDAVA UNA FORMA, non la proprieta'.** Cercava le
      // righe che nominassero `ConsiglioFinale` accanto a un `await`, e una
      // prova del rosso l'ha smentita: un metodo asincrono aggiunto DENTRO la
      // classe non nomina la classe sulla propria riga, quindi passava.
      //
      // Qui si guarda la cosa vera: **cio' che non si puo' attendere non puo'
      // costare una chiamata**. Se in questo file comparisse un `Future`, un
      // `async` o un `await`, il consiglio smetterebbe di essere una riga che
      // si solleva da un testo gia' arrivato e diventerebbe qualcosa che si va
      // a prendere.
      final sorgente =
          File('lib/core/maestro/consiglio_finale.dart').readAsLinesSync();
      final colpe = <String>[];
      for (var i = 0; i < sorgente.length; i++) {
        final r = sorgente[i];
        if (r.trimLeft().startsWith('//')) continue;
        for (final segno in ['Future', 'async', 'await ']) {
          if (r.contains(segno)) colpe.add('riga ${i + 1}: ${r.trim()}');
        }
      }
      expect(colpe, isEmpty,
          reason: 'il consiglio e\' diventato qualcosa che si aspetta:\n'
              '${colpe.join("\n")}');

      // E la riga a video si costruisce senza aspettare niente.
      final riga = File('lib/design_system/components/riga_del_consiglio.dart')
          .readAsStringSync();
      expect(riga, isNot(contains('FutureBuilder')),
          reason: 'la riga del consiglio aspetta qualcosa per disegnarsi');
      expect(riga, isNot(contains('await')),
          reason: 'la riga del consiglio aspetta qualcosa per disegnarsi');
    });
  });

  group('Resta l\'ultima riga, anche col seguito', () {
    test('Il corpo mostrato non contiene MAI la riga del consiglio', () {
      // E' il vincolo che decide dove si infila il seguito: la bolla e'
      // corpo, poi seguito, poi stella. Un consiglio in mezzo al testo non e'
      // piu' un consiglio.
      final corpo = ConsiglioFinale.corpoDa(_lungo);
      expect(corpo, isNot(contains(ConsiglioFinale.stella)));
      expect(corpo, isNot(contains('Guarda dove ti fermi')),
          reason: 'la sintesi del consiglio e\' rimasta nel corpo');
      expect(corpo, contains('Il tuo Sole in Cancro'),
          reason: 'si toglie la riga, non il resto');
    });
  });
}

const String _lungo =
    'Il tuo Sole in Cancro chiede riparo prima di chiedere strada. '
    'Quello che senti come confusione è un confine che si sposta. '
    'Sotto la superficie lavora un secondo movimento, più lento, che dura da '
    'mesi senza chiedere il tuo permesso. Non è la scelta a spaventarti, è '
    'quello che la scelta rende definitivo. Aspetta la prossima luna nuova.\n'
    '✦ Guarda dove ti fermi a respirare: quella è la direzione.';
