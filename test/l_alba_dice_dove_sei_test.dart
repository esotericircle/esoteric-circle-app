import 'dart:io';

import 'package:esoteric_circle/core/astro/sky_location.dart';
import 'package:flutter_test/flutter_test.dart';

/// L'ALBA NON RESTA MUTA E SI LEGGE SUL MARE. Ordine BE voce 06.
///
/// **Due fatti del fondatore sulla 2199**: il tocco su "attiva posizione"
/// non apriva niente (la voce BB.08 si e' riaperta da un'altra porta), e le
/// scritte della card sul mare illuminato non si leggevano.
///
/// **La causa del muto era un appiattimento**: la card usava
/// `resolveSeConcesso`, che trasforma ogni esito in un nulla. Col permesso
/// negato per sempre il dialogo di sistema non compare mai piu', e il nulla
/// tornava in silenzio. Adesso la card chiede la RISPOSTA INTERA e ogni no
/// ha la sua voce: negato per sempre porta alle impostazioni, servizio
/// spento lo dice, negato una volta invita alla citta'.
void main() {
  final sorgente =
      File('lib/features/rituals/dove_sei_adesso.dart').readAsStringSync();

  test('BE.06: la card chiede la risposta intera, non un nulla', () {
    // Il systemRequest deve passare da chiedi(), non dal solo
    // resolveSeConcesso: e' la differenza fra un esito e un silenzio.
    expect(sorgente.contains('widget.location.chiedi()'), isTrue,
        reason: 'la card e\' tornata all\'appiattimento: col permesso '
            'negato per sempre il tocco resta muto (ordine BE voce 06)');
    for (final esito in EsitoPosizione.values) {
      if (esito == EsitoPosizione.concessa ||
          esito == EsitoPosizione.nonDisponibile) {
        continue;
      }
      expect(sorgente.contains(esito.name), isTrue,
          reason: 'l\'esito ${esito.name} non ha piu\' una voce nella card '
              'dell\'Alba: quel no tornerebbe muto');
    }
    expect(sorgente.contains('apriImpostazioni'), isTrue,
        reason: 'il negato per sempre non porta piu\' alle impostazioni: '
            'ripetere la richiesta e\' una bugia, e non fare niente e\' il '
            'muto che il fondatore ha visto due volte');
  });

  test('BE.06: la card ha un fondo suo, non la fotografia del mare', () {
    // Il vetro di notte: un colore pieno dentro la decorazione della card.
    final da = sorgente.indexOf("key: const Key('dove_sei_adesso')");
    expect(da, greaterThan(0));
    final blocco = sorgente.substring(da, da + 900);
    expect(blocco.contains('color: palette.deepest'), isTrue,
        reason: 'la card e\' tornata nuda sul mare: solo bordo e nessun '
            'fondo, e le scritte non si leggono (ordine BE voce 06)');
  });
}
