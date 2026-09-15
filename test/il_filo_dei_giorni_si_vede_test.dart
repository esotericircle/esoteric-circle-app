import 'dart:io';

import 'package:esoteric_circle/core/sigilli/diario_del_cammino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// IL FILO DEI GIORNI SI VEDE NEL PASSPORT, E NON RICATTA. Ordine BG voce
/// 06, mossa 3 del documento RETENTION: "un segno discreto di continuita',
/// nel Passport e non in faccia: la serie invita, non ricatta".
///
/// La logica sta nel diario (le serie vive), qui si prova la SCELTA del
/// filo: solo i cinque Doni contano, vince il piu' lungo, sotto i due
/// giorni si tace. Il widget intero vive dentro il Passport, che le prove
/// non montano per intero: la scelta e' la parte che puo' mentire.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('la serie dei riti cresce coi giorni di seguito, e un buco la azzera',
      () async {
    var giorno = DateTime(2026, 8, 20, 9);
    final diario = DiarioDelCammino(orologio: () => giorno);
    await diario.segna('alba');
    giorno = DateTime(2026, 8, 21, 9);
    await diario.segna('alba');
    expect(diario.seriePerRito['alba'], 2,
        reason: 'due giorni di seguito devono valere un filo di due');
    // Un giorno saltato: il filo di ieri non si legge piu' intero.
    giorno = DateTime(2026, 8, 23, 9);
    expect(diario.seriePerRito.containsKey('alba'), isFalse,
        reason: 'la serie rotta non deve comparire come viva');
  });

  test('anche il passaporto ha una serie nel diario, ma il filo non lo dice',
      () async {
    // Il diario tiene una serie per OGNI gesto: la prova documenta il fatto
    // che rende necessario il filtro sui cinque Doni dentro _FiloDeiGiorni.
    var giorno = DateTime(2026, 8, 20, 9);
    final diario = DiarioDelCammino(orologio: () => giorno);
    await diario.segna('passaporto');
    giorno = DateTime(2026, 8, 21, 9);
    await diario.segna('passaporto');
    expect(diario.seriePerRito['passaporto'], 2,
        reason: 'se il diario smette di tracciare i gesti non rituali, il '
            'filtro del filo va riletto');
  });

  test('il filo sta scritto nel Passport, coi cinque Doni e il silenzio', () {
    // La guardia sul file: il widget esiste, filtra sui cinque Doni, tace
    // sotto i due giorni e senza fili vivi sparisce del tutto.
    final s = File('lib/features/passport/cosmic_passport_screen.dart')
        .readAsStringSync();
    expect(s.contains("Key('filo_dei_giorni')"), isTrue,
        reason: 'il filo dei giorni e sparito dal Passport');
    expect(s.contains('_nomi.containsKey(voce.key)'), isTrue,
        reason: 'il filo non filtra piu sui cinque Doni: mostrerebbe le '
            'serie di gesti come il passaporto o il viso');
    expect(s.contains('voce.value >= 2'), isTrue,
        reason: 'il filo parla anche al primo giorno: un uno non e un filo');
    expect(s.contains('if (migliore == null) return const SizedBox.shrink();'),
        isTrue,
        reason: 'senza fili vivi la riga deve tacere, non mostrare uno zero');
  });
}
