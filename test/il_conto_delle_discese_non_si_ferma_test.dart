import 'dart:convert';

import 'package:esoteric_circle/core/viaggio/diario_dei_viaggi.dart';
import 'package:esoteric_circle/core/viaggio/il_nome_si_puo_dire.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **IL CONTO DELLE DISCESE NON SI FERMA A NOVANTA.** Ordine DJ voce 07,
/// 13 settembre 2026.
///
/// *"Il Diario conserva novanta discese e dalla novantunesima il conto resta
/// fermo a novanta, per esempio nel riassunto per i Maestri. [...] Il totale
/// delle discese diventa un contatore a se', che cresce a ogni discesa e non
/// dipende da quante se ne conservano. La lista resta a novanta."*
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  UnViaggio unViaggio(DateTime quando) => UnViaggio(
        quando: quando,
        domanda: 'Una scelta da fare',
        temaDellaDomanda: 'scelta',
        pezzi: const ['radura', 'ramo_secco', 'si_ferma', 'alba'],
        animaleSeguito: 'Lupo',
        nitidezza: 1,
      );

  test('NOVANTACINQUE DISCESE: il conto dice novantacinque, la lista ne tiene '
      'novanta, e lo sanno il riassunto per i Maestri e il Diario riaperto',
      () async {
    final inizio = DateTime(2026, 1, 1, 12);
    var oggi = inizio;
    final diario = DiarioDeiViaggi(orologio: () => oggi);
    await diario.carica();
    for (var i = 0; i < 95; i++) {
      oggi = inizio.add(Duration(days: i));
      await diario.segna(unViaggio(oggi));
    }
    expect(diario.viaggi, hasLength(DiarioDeiViaggi.quantiNeTiene),
        reason: 'la lista deve restare a novanta');
    expect(diario.quanteDiscese, 95,
        reason: 'dalla novantunesima il conto resta fermo alla lista');
    expect(diario.riassuntoPerIMaestri, contains('ha fatto 95 discese'));

    final riaperto = DiarioDeiViaggi(orologio: () => oggi);
    await riaperto.carica();
    expect(riaperto.quanteDiscese, 95,
        reason: 'riaprendo il Diario il conto torna alla lunghezza della lista');
    expect(IlNomeSiPuoDire.quanteDisceseNote, 95);
  });

  test('UN DIARIO DI PRIMA, senza conto, comincia dalla sua lista', () async {
    final inizio = DateTime(2026, 1, 1, 12);
    SharedPreferences.setMockInitialValues({
      'viaggio.diario': [
        for (var i = 0; i < 90; i++)
          jsonEncode(unViaggio(inizio.add(Duration(days: i))).toJson()),
      ],
    });
    final diario =
        DiarioDeiViaggi(orologio: () => inizio.add(const Duration(days: 90)));
    await diario.carica();
    expect(diario.quanteDiscese, 90);
    await diario.segna(unViaggio(inizio.add(const Duration(days: 90))));
    expect(diario.quanteDiscese, 91);
    expect(diario.viaggi, hasLength(90));
  });

  test('UN CONTO SOTTO LA LISTA non vale, e il comando di demo lo azzera',
      () async {
    final inizio = DateTime(2026, 1, 1, 12);
    SharedPreferences.setMockInitialValues({
      'viaggio.quante': 2,
      'viaggio.diario': [
        for (var i = 0; i < 5; i++)
          jsonEncode(unViaggio(inizio.add(Duration(days: i))).toJson()),
      ],
    });
    final diario = DiarioDeiViaggi();
    await diario.carica();
    expect(diario.quanteDiscese, 5);
    await diario.ricomincia(demo: true);
    expect(diario.quanteDiscese, 0);
    final riaperto = DiarioDeiViaggi();
    await riaperto.carica();
    expect(riaperto.quanteDiscese, 0,
        reason: 'il comando di demo lascia il conto sul telefono');
  });
}
