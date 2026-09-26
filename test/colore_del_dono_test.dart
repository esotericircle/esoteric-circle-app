import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// LA PROVA DELLA VOCE 2: il colore della scheda nasce dal Maestro del giorno.
///
/// **DALL'ORDINE DT RESTA LA META' CHE HA ANCORA UN OGGETTO.** Le prove a
/// video misuravano l'accento della parola del giorno sul vetro chiaro della
/// scheda del Rito dell'Alba: quel dono non c'e' piu', la parola non sta piu'
/// sulla scheda e il vetro chiaro non lo porta nessun dono. Resta cio' che vale
/// per ogni scheda: che l'accento si derivi da un punto solo, e che la scheda
/// non accetti un colore da fuori. L'accento della riga di chi parla
/// sull'Arcano dell'Alba lo misura sul fotogramma vero
/// `test/l_alba_si_legge_test.dart`.
void main() {
  group('Un punto solo decide quel colore', () {
    test('nessun altro punto in lib deriva l\'accento della scheda', () {
      // Se un secondo punto decidesse questo colore, prima o poi i due
      // direbbero cose diverse e nessuno saprebbe quale comanda.
      //
      // **LA PORTA SI E SPOSTATA, e questa prova ha fatto il suo mestiere.**
      // Ordine BB voce 09: l accento non dipende piu solo dal Maestro del
      // giorno ma anche dall ABITO del responso, perche lo stesso oro che si
      // legge sul vetro crema dell Alba sparirebbe sul vetro notturno del
      // Soffio. Spostata la derivazione, questa e caduta indicando il file
      // vecchio: era esattamente cio che doveva fare, e la porta nuova e
      // `AbitoDelResponso.accentoDi`.
      const laPorta = 'lib/design_system/theme/abito_del_responso.dart';

      final definizioni = <String>[];
      final colpevoli = <String>[];
      var guardati = 0;
      for (final f in Directory('lib')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))) {
        final percorso = f.path.replaceAll(r'\', '/');
        final relativo = percorso.substring(percorso.indexOf('lib/'));
        final testo = f.readAsStringSync();
        guardati++;
        for (final _ in RegExp(r'Color\s+accentoDi\s*\(').allMatches(testo)) {
          definizioni.add(relativo);
        }
        if (relativo == laPorta) continue;
        // Nessun altro file deve costruire la scheda passandole un colore, ne
        // derivare una palette per lei.
        if (testo.contains('RitualGiftCard(') &&
            RegExp(r'RitualGiftCard\([^)]*(accento|palette)').hasMatch(testo)) {
          colpevoli.add('$relativo: passa un colore alla scheda');
        }
      }
      expect(guardati, greaterThan(100),
          reason: 'la ricerca ha guardato solo $guardati sorgenti');
      expect(definizioni, [laPorta],
          reason: 'l\'accento si deriva in piu\' di un punto: $definizioni');
      expect(colpevoli, isEmpty,
          reason: 'qualcuno passa il colore da fuori: $colpevoli');
    });

    test('la scheda non accetta un colore dall\'esterno', () {
      // Se il costruttore lo accettasse, il secondo punto sarebbe possibile
      // anche senza che nessuno lo usi ancora.
      final sorgente =
          File('lib/features/rituals/ritual_gift_card.dart').readAsStringSync();
      final costruttore = sorgente.substring(
        sorgente.indexOf('const RitualGiftCard('),
        sorgente.indexOf('final DawnGift gift;'),
      );
      for (final vietato in ['accento', 'palette', 'Color']) {
        expect(costruttore.contains(vietato), isFalse,
            reason: 'il costruttore della scheda accetta "$vietato": e\' la '
                'porta da cui entrerebbe il secondo punto');
      }
    });
  });
}
