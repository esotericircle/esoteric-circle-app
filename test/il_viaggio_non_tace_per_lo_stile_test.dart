// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:esoteric_circle/core/maestro/natal_context.dart';
import 'package:esoteric_circle/core/rituals/animal_catalog.dart';
import 'package:esoteric_circle/core/viaggio/la_scena_dal_modello.dart';
import 'package:esoteric_circle/core/viaggio/le_guardie_del_responso.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **LO STILE NON FA TACERE IL MONDO DI SOTTO.** Ordine EV, 1 ottobre 2026.
///
/// Il fondatore: *"premo su Risali e mi risponde che oggi il mondo di sotto
/// non ha parlato"*. Alla sonda del primo strato
/// (`tool/sonda_viaggio_primo_strato.dart`) 8 discese su 12 finivano nel
/// silenzio, quasi sempre per le due guardie dello stile. Un modello finto
/// che risponde sempre con una risposta scartata solo per lo stile: la
/// risposta arriva. Uno che risponde sempre con una previsione certa: il
/// silenzio resta, perche' le guardie dure non si saltano mai.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  final lupo = AnimalCatalog.animals.firstWhere((a) => a.name == 'Lupo');
  CioCheSiSa domanda(String d) => CioCheSiSa(
        domanda: d,
        tema: null,
        animale: lupo,
        natale: const NatalContext(sunSign: 'Cancro'),
        memoria: '',
        ultimeScene: const [],
        strato: 1,
      );

  Future<(String?, List<MotivoDelloScarto>)> discesa(
      String d, String risposta) async {
    final motivi = <MotivoDelloScarto>[];
    final scritta = await LaScenaDalModello.chiediTutto(
      domanda(d),
      chiamata: (i, r, a) async => jsonEncode({
        'luogo': 'radura',
        'cosa': 'chiave',
        'gesto': 'aspetta',
        'momento': 'alba',
        'titolo': 'Una porta socchiusa',
        'risposta': risposta,
        'azione': 'Domani chiedi a chi ti conosce bene che cosa ne pensa.',
      }),
      prendiUnaChiamata: () async => true,
      seScartata: (r) {
        if (r.pezzo == 'risposta') motivi.add(r.motivo);
      },
    );
    return (scritta.testi.risposta, motivi);
  }

  test('ORDINE EV, VIAGGIO: la risposta scartata per lo stile arriva',
      () async {
    final (risposta, motivi) = await discesa(
        'Mi trasferisco a Berlino per lavoro?',
        'I segni del viaggio dicono di sì, se sai che cosa lasci. Non guardare '
            'solo quello che trovi a Berlino. Guarda quello che perdi qui.');
    print('ORDINE EV, VIAGGIO: scarti $motivi, risposta $risposta');
    expect(motivi, contains(MotivoDelloScarto.nonPrendePosizione),
        reason: 'la prova non misura: la risposta non e\' piu\' scartata per '
            'lo stile');
    expect(risposta, isNotNull,
        reason: 'una risposta scartata solo per lo stile manda la persona nel '
            'silenzio');
  });

  test('ORDINE EV, VIAGGIO: un sì a una domanda sul come non passa', () async {
    final (risposta, motivi) = await discesa(
        'Come va la mia relazione con Laura?',
        'I segni del viaggio dicono di sì, se ti permetti di non sapere ancora. '
            'Hai tempo per vedere come evolve il vostro rapporto con Laura.');
    print('ORDINE EV, VIAGGIO: scarti $motivi, risposta $risposta');
    expect(motivi, contains(MotivoDelloScarto.nonPrendePosizione));
    expect(risposta, isNull,
        reason: 'un sì a "come va?" e\' passato dalla strada dello stile');
  });

  test('ORDINE EV, VIAGGIO: la parola del genere troncata non passa', () {
    // Dalla sonda del primo strato, col profilo neutro.
    const troncata = 'I segni del viaggio dicono di sì, se sei dispost a '
        'riconoscere che il lavoro a Berlino ti chiede una parte nuova.';
    print('ORDINE EV, VIAGGIO: troncata '
        '${LeGuardieDelResponso.parolaDelGenereTroncata(troncata)}');
    expect(LeGuardieDelResponso.parolaDelGenereTroncata(troncata), isTrue);
    for (final buona in const [
      'Se sei disposto a riconoscerlo, comincia domani.',
      'Le persone intorno sono ben disposte.',
      'Scrivi a tuo fratello stasera.',
    ]) {
      expect(LeGuardieDelResponso.parolaDelGenereTroncata(buona), isFalse,
          reason: buona);
    }
  });

  test('ORDINE EV, VIAGGIO: la previsione certa non passa mai', () async {
    final (risposta, motivi) = await discesa(
        'Quando mi sposerò?',
        'I segni del viaggio dicono di sì. Il matrimonio arriverà presto. '
            'Sarà con chi saprà vederti.');
    print('ORDINE EV, VIAGGIO: scarti $motivi, risposta $risposta');
    expect(motivi, isNotEmpty);
    expect(risposta, isNull,
        reason: 'una previsione certa e\' passata dalla strada dello stile');
  });
}
