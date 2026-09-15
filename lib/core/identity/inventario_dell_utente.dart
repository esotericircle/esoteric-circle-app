import 'quando_chiedere_la_custodia.dart';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../maestro/maestro.dart';

/// TUTTO CIO' CHE APPARTIENE A UNA PERSONA, elencato voce per voce.
///
/// **A cosa serve.** L'ordine N chiede che elevando l'account anonimo a
/// account vero non si perda NIENTE, e che a dirlo non sia un controllo di
/// tre cose a mano ma un elenco: si fotografa cio' che c'e' prima, si eleva,
/// si rifotografa, e le due fotografie devono coincidere elemento per
/// elemento. Se domani nascera' un dato nuovo dell'utente, si aggiunge qui e
/// la prova lo sorveglia da subito, senza che nessuno debba ricordarsene.
///
/// **Perche' i rami sono nominati e non scoperti.** Il client di Firestore
/// non sa elencare le sottocollezioni di un documento: chiederglielo darebbe
/// un elenco vuoto e una prova sempre verde, che e' peggio di nessuna prova.
/// Quindi i rami si dichiarano, e sono quelli che l'app usa davvero.
///
/// **L'impronta e' il contenuto, non solo la presenza.** Un elemento che c'e'
/// ancora ma e' stato svuotato sarebbe perso lo stesso.
class InventarioDellUtente {
  const InventarioDellUtente(this.voci);

  /// Chiave della voce (il percorso, o il nome del dato locale) e impronta
  /// del suo contenuto.
  final Map<String, String> voci;

  int get quante => voci.length;

  /// Le chiavi che compaiono in uno e non nell'altro, piu' quelle che
  /// compaiono in tutti e due con contenuto diverso. Vuoto vuol dire identici.
  List<String> differenzeCon(InventarioDellUtente altro) {
    final differenze = <String>[];
    for (final voce in voci.entries) {
      if (!altro.voci.containsKey(voce.key)) {
        differenze.add('${voce.key}: sparita');
      } else if (altro.voci[voce.key] != voce.value) {
        differenze.add(
            '${voce.key}: cambiata da ${voce.value} a ${altro.voci[voce.key]}');
      }
    }
    for (final chiave in altro.voci.keys) {
      if (!voci.containsKey(chiave)) differenze.add('$chiave: comparsa');
    }
    return differenze;
  }

  static String _impronta(Object? dati) {
    if (dati == null) return 'assente';
    return jsonEncode(dati, toEncodable: (o) {
      if (o is Timestamp) return o.millisecondsSinceEpoch;
      if (o is DateTime) return o.millisecondsSinceEpoch;
      return o.toString();
    });
  }

  /// LE PREFERENZE CHE NON CONTANO, e la ragione per cui si escludono.
  ///
  /// Sono quelle che cambiano per conto loro col passare del tempo o col
  /// gesto stesso di elevare (l'ultimo avviso mostrato, i rimandi): tenerle
  /// dentro farebbe cadere la prova per un motivo che non e' una perdita.
  static const Set<String> _fuoriDalConto = {
    'account.rimandi',
    // La chiave vive nella sua casa (BJ.01): qui solo il riferimento.
    QuandoChiedereLaCustodia.chiaveUltimoInvito,
  };

  /// Fotografa tutto: il ramo dell'utente sul server e cio' che vive sul
  /// dispositivo.
  static Future<InventarioDellUtente> fotografa({
    required String? uid,
    required FirebaseFirestore db,
    SharedPreferences? preferenze,
  }) async {
    final voci = <String, String>{};
    voci['account.uid'] = uid ?? 'assente';

    if (uid != null) {
      final utente = db.collection('users').doc(uid);
      voci['users/$uid'] = _impronta((await utente.get()).data());

      for (final maestro in Maestro.values) {
        final ramo = utente.collection('maestri').doc(maestro.id);
        voci['users/$uid/maestri/${maestro.id}'] =
            _impronta((await ramo.get()).data());
        final messaggi = await ramo.collection('messages').get();
        voci['users/$uid/maestri/${maestro.id}/messages'] = _impronta(
          messaggi.docs.map((d) => d.data()).toList(growable: false),
        );
      }

      for (final documento in const [
        'contatori',
        'borsellino',
        'abbonamento'
      ]) {
        final snap = await utente.collection('stato').doc(documento).get();
        voci['users/$uid/stato/$documento'] = _impronta(snap.data());
      }

      final movimenti = await utente.collection('movimenti').get();
      voci['users/$uid/movimenti'] = _impronta(
        movimenti.docs.map((d) => d.data()).toList(growable: false),
      );
    }

    final prefs = preferenze ?? await SharedPreferences.getInstance();
    for (final chiave in prefs.getKeys()) {
      if (_fuoriDalConto.contains(chiave)) continue;
      voci['locale.$chiave'] = _impronta(prefs.get(chiave));
    }
    return InventarioDellUtente(voci);
  }
}
