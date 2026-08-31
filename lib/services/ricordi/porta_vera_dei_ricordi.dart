/// LA PORTA VERA DELL'INDICE DEI RICORDI. Ordine CG voce 03.
///
/// **Perche' passa dalle funzioni e non scrive dritta.** Le regole di
/// sicurezza vietano al telefono ogni scrittura sotto `users/{uid}`: una porta
/// aperta su un ramo e' aperta su tutto il ramo, e su quel ramo ci sono anche
/// i contatori e il saldo. E' la stessa scelta gia' presa per la memoria dei
/// Maestri nell'ordine N voce 2b, e qui non se ne apre una seconda diversa.
///
/// **Un errore di rete non e' un no.** Quando la chiamata non arriva, `manda`
/// torna falso: il registro tiene il mese fra gli sporchi e riprova domani.
/// Nessuna riga si perde e nessuna si duplica, perche' la chiave di riga e'
/// deterministica e il server fonde con `merge`.
library;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

import '../../core/ricordi/registro_dei_ricordi.dart';
import '../../core/ricordi/voce_del_ricordo.dart';

class PortaVeraDeiRicordi extends PortaDeiRicordi {
  PortaVeraDeiRicordi({FirebaseFunctions? funzioni})
      : _funzioni =
            funzioni ?? FirebaseFunctions.instanceFor(region: 'europe-west1');

  final FirebaseFunctions _funzioni;

  @override
  Future<bool> manda(String mese, List<VoceDelRicordo> righe) async {
    if (righe.isEmpty) return true;
    try {
      await _funzioni.httpsCallable('scriviIRicordi').call<Object?>({
        'mese': mese,
        // La mappa da chiave di riga alla riga: e' la forma che permette a due
        // apparecchi di sommarsi invece di cancellarsi.
        'righe': {for (final r in righe) r.chiave: r.aMappa()},
      });
      return true;
    } catch (errore) {
      // **IL FALSO E' LA RISPOSTA, e non e' una perdita.** Il registro lascia
      // il mese fra gli sporchi e riprova alla prossima sincronia.
      debugPrint('Ricordi: la sincronia del mese $mese non e\' passata. $errore');
      return false;
    }
  }

  @override
  Future<List<MovimentoDelRicordo>> movimenti() async {
    try {
      final esito =
          await _funzioni.httpsCallable('leggiIMovimenti').call<Object?>({});
      final dati = esito.data;
      if (dati is! Map) return const [];
      final righe = dati['movimenti'];
      if (righe is! List) return const [];
      final fuori = <MovimentoDelRicordo>[];
      for (final voce in righe) {
        final m = MovimentoDelRicordo.daMappa(voce);
        if (m != null) fuori.add(m);
      }
      return fuori;
    } catch (errore) {
      // **IL VUOTO E' LA RISPOSTA, e i Ricordi lo dicono a video.** Un elenco
      // vuoto per rete assente non deve sembrare una persona che non ha mai
      // guadagnato niente.
      debugPrint('Ricordi: i movimenti non si rileggono. $errore');
      return const [];
    }
  }

  @override
  Future<List<VoceDelRicordo>> leggi(String mese) async {
    try {
      final esito = await _funzioni
          .httpsCallable('leggiIRicordi')
          .call<Object?>({'mese': mese});
      final dati = esito.data;
      if (dati is! Map) return const [];
      final righe = dati['righe'];
      if (righe is! Map) return const [];
      final fuori = <VoceDelRicordo>[];
      for (final voce in righe.values) {
        final riga = VoceDelRicordo.daMappa(voce);
        if (riga != null) fuori.add(riga);
      }
      return fuori;
    } catch (errore) {
      debugPrint('Ricordi: il mese $mese non si rilegge. $errore');
      return const [];
    }
  }
}
