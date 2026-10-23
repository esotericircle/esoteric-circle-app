import 'dart:convert';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/viaggio/diario_dei_viaggi.dart';
import 'package:esoteric_circle/core/viaggio/l_animale_di_potere.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **L'AVVISO DELLA MIGRAZIONE ARRIVA AL VIAGGIO.** Ordine FZ voce 02: chi era
/// a meta' col vecchio sistema riparte da capo *"con un avviso di una riga"*.
///
/// **Il fatto**, simulazione da persona del 20 ottobre 2026 sul Realme
/// 767f596c: la migrazione la completa la prima schermata che carica il
/// Diario, quasi sempre la home, che l'avviso non lo mostra; il Viaggio
/// trovava la migrazione gia' fatta e nessun avviso, e chi era a meta' vedeva
/// sparire i suoi progressi senza una parola. Padre: ordine FZ voce 02.
///
/// **Cosa misura**: la home completa la migrazione e butta l'avviso; il
/// Viaggio, dopo, con un Diario suo, lo ritrova; e una volta sola.
void main() {
  test('LA HOME MIGRA, IL VIAGGIO RITROVA L\'AVVISO, E UNA VOLTA SOLA',
      () async {
    SharedPreferences.setMockInitialValues({
      'viaggio.quante': 2,
      'viaggio.diario': [
        for (var i = 0; i < 2; i++)
          jsonEncode(UnViaggio(
            quando: DateTime(2026, 10, 10 + i),
            domanda: '',
            temaDellaDomanda: '',
            pezzi: const [],
            animaleSeguito: 'Lupo',
            nitidezza: 1,
          ).toJson()),
      ],
    });
    // **LA HOME**: carica, migra, e l'avviso lo butta.
    final dellaHome =
        await AnimaleDiPotere.caricaERisolvi(DiarioDeiViaggi(), Zodiac.cancer);
    expect(dellaHome.avviso, isNotNull,
        reason: 'lo stato a meta\' non ha prodotto l\'avviso: la prova non '
            'guarda il caso giusto');
    // **IL VIAGGIO**, con un Diario suo: la migrazione e' gia' fatta.
    final diarioDelViaggio = DiarioDeiViaggi();
    final delViaggio =
        await AnimaleDiPotere.caricaERisolvi(diarioDelViaggio, Zodiac.cancer);
    expect(delViaggio.avviso, isNull);
    final lasciato = await diarioDelViaggio.prendiLAvvisoDellaMigrazione();
    expect(lasciato, dellaHome.avviso,
        reason: 'il Viaggio non ritrova l\'avviso lasciato dalla home: chi '
            'era a meta\' vede sparire i suoi progressi senza una parola');
    // **UNA VOLTA SOLA.**
    expect(await DiarioDeiViaggi().prendiLAvvisoDellaMigrazione(), isNull,
        reason: 'l\'avviso torna a ogni apertura del Viaggio');
  });
}
