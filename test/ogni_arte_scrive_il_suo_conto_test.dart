/// OGNI ARTE VIVA SCRIVE IL SUO CONTO. Ordine CG voce 10.
///
/// **La domanda che nessuna guardia faceva.** `ogni_arte_entra_nel_cammino`
/// va dai TRAGUARDI ai gesti: chiede se un traguardo scritto nel corpus puo'
/// accendersi. Qui la domanda e' l'opposta: un'arte VIVA del catalogo scrive
/// il suo conto? Un'arte nuova che nascesse domani senza scriverlo non farebbe
/// cadere nessuna guardia di prima, perche' nessun traguardo la nominerebbe:
/// comparirebbe nel Santuario e sparirebbe dai Ricordi.
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:esoteric_circle/core/arts/art_catalog.dart';
import 'package:esoteric_circle/core/ricordi/conti_delle_arti.dart';
import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:esoteric_circle/core/sigilli/gesti_delle_arti.dart';

/// Le arti VIVE del catalogo, prese dallo stato e non da un elenco a mano.
List<ArtEntry> _artiVive() {
  return [
    for (final arte in ArtCatalog.all)
      if (arte.state == ArtState.attiva) arte,
  ];
}

void main() {
  test('ogni arte VIVA del catalogo dichiara il gesto che ne tiene il conto',
      () {
    final vive = _artiVive();
    expect(vive, isNotEmpty,
        reason: 'nessuna arte viva trovata nel catalogo: e\' la prova a essere '
            'rotta, non il codice');

    final senzaConto = <String>[];
    for (final arte in vive) {
      final conto = ContiDelleArti.di(arte.id);
      if (conto == null) {
        senzaConto.add('${arte.id}  (non censita)');
      } else if (!conto.contato && (conto.perche ?? '').trim().isEmpty) {
        senzaConto.add('${arte.id}  (censita senza conto e senza ragione)');
      }
    }

    // ignore: avoid_print
    print('ORDINE CG VOCE 10: arti vive nel catalogo ${vive.length}, '
        'censite con un conto ${ContiDelleArti.contate.length}, '
        'dichiarate senza conto ${ContiDelleArti.senzaConto.length}');

    expect(senzaConto, isEmpty,
        reason: 'queste arti sono vive nel Santuario e nei Ricordi non '
            'lasciano traccia: $senzaConto. IL ROSSO SI DIMOSTRA aggiungendo '
            'al catalogo un\'arte ArtState.attiva che non scrive il suo '
            'conto, e questa prova deve cadere nominandola');
  });

  test('il gesto di ogni conto esiste davvero nel registro dei gesti', () {
    // **Un conto che nomina un gesto inesistente e' peggio di nessun conto**:
    // la timeline mostrerebbe zero per sempre, e zero sembra una giornata
    // vuota invece che una misura rotta.
    final inventati = <String>[];
    for (final conto in ContiDelleArti.contate) {
      if (GestiDelleArti.di(conto.gesto!) == null) {
        inventati.add('${conto.arte} -> ${conto.gesto}');
      }
    }
    expect(inventati, isEmpty,
        reason: 'questi conti nominano un gesto che il registro non conosce: '
            '$inventati');
  });

  test('tutti e cinque i Doni hanno il loro conto, e sono quelli veri', () {
    final senza = <DailyElement>[];
    for (final dono in DailyElement.values) {
      if (ContiDelleArti.gestoDelDono(dono) == null) senza.add(dono);
    }
    expect(senza, isEmpty,
        reason: 'questi Doni non hanno un conto: $senza. IL ROSSO SI DIMOSTRA '
            'togliendo una riga dalla mappa dei Doni');
    expect(ContiDelleArti.gestiDeiDoni.length, DailyElement.values.length,
        reason: 'i Doni censiti devono essere tanti quanti i Doni che ci sono');

    // E i gesti nominati devono essere quelli che le schermate mandano
    // davvero, non parole simili.
    final inventati = <String>[];
    for (final gesto in ContiDelleArti.gestiDeiDoni.values) {
      if (GestiDelleArti.di(gesto) == null) inventati.add(gesto);
    }
    expect(inventati, isEmpty,
        reason: 'questi gesti dei Doni non esistono nel registro: $inventati');
  });

  test('nessun gesto e\' contato due volte da due arti diverse', () {
    // **Due conteggi della stessa cosa sono la famiglia di difetti piu'
    // numerosa di questo progetto**, e il fondatore l'ha scritto nell'ordine
    // CF. Due arti che scrivessero lo stesso gesto darebbero alla timeline un
    // numero che non appartiene a nessuna delle due.
    final visti = <String, String>{};
    final doppi = <String>[];
    for (final conto in ContiDelleArti.contate) {
      final gia = visti[conto.gesto!];
      if (gia != null) {
        doppi.add('${conto.gesto}: $gia e ${conto.arte}');
      }
      visti[conto.gesto!] = conto.arte;
    }
    for (final voce in ContiDelleArti.gestiDeiDoni.entries) {
      final gia = visti[voce.value];
      if (gia != null) doppi.add('${voce.value}: $gia e il Dono ${voce.key}');
      visti[voce.value] = 'il Dono ${voce.key}';
    }
    expect(doppi, isEmpty,
        reason: 'questi gesti sono contati da due parti: $doppi');
  });
}
