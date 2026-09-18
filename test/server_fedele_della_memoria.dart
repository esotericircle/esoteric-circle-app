import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:esoteric_circle/core/cammino/cammino_da_custodire.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/services/server/porta_del_cerchio.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

/// **IL SERVER DELLA MEMORIA, fedele a quello vero.** Ordine DV.
///
/// Fa cio' che fa `scriviLaMemoria` in `functions/src/cerchio.ts`:
/// `messaggio` aggiunge un documento nuovo col suo tempo, `ultimoMessaggio`
/// riscrive l'ultimo. E risponde con un ritardo, come la rete: e' quel ritardo
/// a far sovrapporre le scritture della chat, cioe' il caso in cui la coda
/// mandava la stessa domanda due volte.
///
/// Serve alle prove e alle catture che vogliono la chat col **repository
/// vero**: quello in memoria non ha la coda, e al banco il difetto dell'ordine
/// DV non esisteva proprio per questo.
class ServerFedeleDellaMemoria extends PortaDelCerchio {
  ServerFedeleDellaMemoria(this.db, this.uid,
      {this.ritardo = const Duration(milliseconds: 15)});

  final FakeFirebaseFirestore db;
  final String uid;
  final Duration ritardo;
  int _tempo = 0;

  CollectionReference<Map<String, dynamic>> messaggiDi(Maestro m) =>
      _messaggi(m.id);

  CollectionReference<Map<String, dynamic>> _messaggi(String? maestro) => db
      .collection('users')
      .doc(uid)
      .collection('maestri')
      .doc(maestro)
      .collection('messages');

  @override
  bool get viva => true;

  @override
  Future<bool> scriviLaMemoria({
    required String operazione,
    String? maestro,
    Map<String, Object?> campi = const {},
  }) async {
    await Future<void>.delayed(ritardo);
    final col = _messaggi(maestro);
    switch (operazione) {
      case 'messaggio':
        await col.add({
          ...campi,
          // Il tempo del server cresce sempre: due scritture non hanno mai
          // lo stesso istante, come il timestamp vero.
          'createdAt': Timestamp.fromMillisecondsSinceEpoch(
              1789700000000 + (_tempo++) * 1000),
        });
        return true;
      case 'ultimoMessaggio':
        final ultimi =
            await col.orderBy('createdAt', descending: true).limit(1).get();
        if (ultimi.docs.isEmpty) return false;
        await ultimi.docs.first.reference
            .set(campi.cast<String, dynamic>(), SetOptions(merge: true));
        return true;
      default:
        return true;
    }
  }

  @override
  Future<StatoDelCerchio?> stato(
          {CamminoDaCustodire? cammino, bool azzeraIlCammino = false}) async =>
      null;

  @override
  Future<EsitoDelConsumo?> consuma({
    required String budget,
    required String idMovimento,
  }) async =>
      null;

  @override
  Future<int?> muoviGliEos({
    required String causale,
    required String motivo,
    required String idMovimento,
    int? quanti,
  }) async =>
      null;

  @override
  Future<bool> cancellaIlCerchio() async => true;
}
