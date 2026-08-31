/// LA PORTA VERA DELLO SCRIGNO DEI CUSTODITI. Ordine CG voce 06.
///
/// **Perche' passa dalle funzioni.** Le regole di sicurezza vietano al
/// telefono ogni scrittura sotto `users/{uid}`. E' la stessa scelta della
/// memoria dei Maestri e dell'indice dei Ricordi, e qui non se ne apre una
/// terza diversa.
///
/// **Un errore di rete non perde niente.** Il custodito e' gia' sul telefono
/// prima che questa porta venga chiamata: il server e' la copia che permette
/// di ritrovarlo su un altro apparecchio, non l'originale.
library;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

import '../../core/ricordi/ricordo_custodito.dart';
import '../../core/ricordi/scrigno_dei_custoditi.dart';

class PortaVeraDelloScrigno extends PortaDelloScrigno {
  PortaVeraDelloScrigno({FirebaseFunctions? funzioni})
      : _funzioni =
            funzioni ?? FirebaseFunctions.instanceFor(region: 'europe-west1');

  final FirebaseFunctions _funzioni;

  @override
  Future<bool> custodisci(RicordoCustodito ricordo) async {
    try {
      await _funzioni.httpsCallable('custodisciIlResponso').call<Object?>({
        'chiave': ricordo.chiave,
        'ricordo': ricordo.aMappa(),
      });
      return true;
    } catch (errore) {
      debugPrint('Scrigno: il custodito non è salito. $errore');
      return false;
    }
  }

  @override
  Future<List<RicordoCustodito>> tutti() async {
    try {
      final esito = await _funzioni
          .httpsCallable('leggiICustoditi')
          .call<Object?>({});
      final dati = esito.data;
      if (dati is! Map) return const [];
      final righe = dati['custoditi'];
      if (righe is! List) return const [];
      final fuori = <RicordoCustodito>[];
      for (final voce in righe) {
        final r = RicordoCustodito.daMappa(voce);
        if (r != null) fuori.add(r);
      }
      return fuori;
    } catch (errore) {
      debugPrint('Scrigno: i custoditi non si rileggono. $errore');
      return const [];
    }
  }

  @override
  Future<bool> lascia(String chiave) async {
    try {
      await _funzioni
          .httpsCallable('lasciaIlResponso')
          .call<Object?>({'chiave': chiave});
      return true;
    } catch (errore) {
      debugPrint('Scrigno: il custodito non si lascia. $errore');
      return false;
    }
  }
}
