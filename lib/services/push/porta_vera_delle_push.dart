/// LA PORTA VERA DELLE SCELTE DELLE PUSH. Ordine CI voce 07.
///
/// **Perche' passa dalle funzioni.** Le regole di sicurezza vietano al
/// telefono ogni scrittura sotto `users/{uid}`, e il recapito del dispositivo
/// vive li'. E' la stessa scelta della memoria dei Maestri, dell'indice dei
/// Ricordi e dello scrigno: qui non se ne apre una quarta diversa.
///
/// **Un errore di rete non perde niente.** Il token resta sul telefono, e la
/// sincronia riparte al giro dopo: `CustodeDellePush` manda solo quando
/// qualcosa e' davvero cambiato, quindi un fallimento non si perde, si
/// ripete.
library;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

import 'porta_delle_push.dart';

class PortaVeraDelleScelte extends PortaDelleScelte {
  PortaVeraDelleScelte({FirebaseFunctions? funzioni})
      : _funzioni =
            funzioni ?? FirebaseFunctions.instanceFor(region: 'europe-west1');

  final FirebaseFunctions _funzioni;

  @override
  Future<bool> manda(ScelteDaMandare scelte) async {
    try {
      await _funzioni
          .httpsCallable('scriviLeScelteDellePush')
          .call<Object?>(scelte.aMappa());
      return true;
    } catch (errore) {
      debugPrint('Push: le scelte non sono salite. $errore');
      return false;
    }
  }

  @override
  Future<bool> togli() async {
    try {
      await _funzioni
          .httpsCallable('togliLeScelteDellePush')
          .call<Object?>(<String, Object?>{});
      return true;
    } catch (errore) {
      debugPrint('Push: il recapito non si toglie. $errore');
      return false;
    }
  }
}
