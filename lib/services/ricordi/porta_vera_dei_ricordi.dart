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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      debugPrint('Ricordi: la sincronia del mese $mese non è passata. $errore');
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

  /// L'utente del Cerchio, o null se non c'e' ancora.
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  DocumentReference<Map<String, dynamic>> _anno(String uid, String anno) =>
      FirebaseFirestore.instance.doc('users/$uid/diario/$anno');

  /// **UN MESE DEL DIARIO, dall'indice sul server. Ordine FE voce 22.14.**
  /// Una lettura: il documento del mese con le sue righe. Prima dell'ordine
  /// FE qui si leggeva il vecchio indice, che saliva dal telefono una volta
  /// sola per installazione.
  @override
  Future<List<VoceDelRicordo>> leggi(String mese) async {
    final uid = _uid;
    if (uid == null) return const [];
    try {
      final d = await _anno(uid, mese.substring(0, 4))
          .collection('mesi')
          .doc(mese.substring(5, 7))
          .get();
      final righe = d.data()?['righe'];
      if (righe is! Map) return const [];
      return [
        for (final e in righe.entries)
          if (VoceDelRicordo.dalDiario('${e.key}', e.value) case final v?) v,
      ];
    } catch (errore) {
      debugPrint('Diario: il mese $mese non si legge. $errore');
      return const [];
    }
  }

  @override
  Future<Map<String, Object?>?> leggiAnno(String anno) async {
    final uid = _uid;
    if (uid == null) return null;
    try {
      return (await _anno(uid, anno).get()).data();
    } catch (errore) {
      debugPrint('Diario: l\'anno $anno non si legge. $errore');
      return null;
    }
  }

  @override
  Future<bool> annota({
    required String chiave,
    required DateTime quando,
    required String tipo,
    required String arte,
    required String maestro,
    required String titolo,
    required Map<String, Object?> contenuto,
  }) async {
    try {
      await _funzioni.httpsCallable('annotaNelDiario').call<Object?>({
        'chiave': chiave,
        'q': quando.millisecondsSinceEpoch,
        'k': tipo,
        'a': arte,
        'm': maestro,
        't': titolo,
        'contenuto': contenuto,
      });
      return true;
    } catch (errore) {
      debugPrint('Diario: la voce $chiave non si annota. $errore');
      return false;
    }
  }

  @override
  Future<bool> stella({
    required String chiave,
    required DateTime quando,
    required bool stella,
    String? nota,
  }) async {
    try {
      await _funzioni.httpsCallable('stellaNelDiario').call<Object?>({
        'chiave': chiave,
        'q': quando.millisecondsSinceEpoch,
        'stella': stella,
        if (nota != null) 'nota': nota,
      });
      return true;
    } catch (errore) {
      debugPrint('Diario: la stella di $chiave non si scrive. $errore');
      return false;
    }
  }

  @override
  Future<Map<String, Object?>?> leggiVoce(String chiave) async {
    try {
      final esito = await _funzioni
          .httpsCallable('leggiLaVoce')
          .call<Object?>({'chiave': chiave});
      final dati = esito.data;
      if (dati is! Map) return null;
      final voce = dati['voce'];
      if (voce is! Map) return null;
      return {
        ...voce.map((k, v) => MapEntry('$k', v)),
        'dallArchivio': dati['dallArchivio'] == true,
      };
    } catch (errore) {
      debugPrint('Diario: la voce $chiave non si apre. $errore');
      return null;
    }
  }

  @override
  Future<int> riempi() async {
    try {
      final esito =
          await _funzioni.httpsCallable('riempiIlDiario').call<Object?>({});
      final dati = esito.data;
      return dati is Map && dati['righe'] is num
          ? (dati['righe'] as num).toInt()
          : 0;
    } catch (errore) {
      debugPrint('Diario: il riempimento non e\' passato. $errore');
      return 0;
    }
  }
}
