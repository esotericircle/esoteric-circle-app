import 'dart:math';

import 'attribuzioni_degli_arcani.dart';

/// Uno dei quarantaquattro stati dell'Arcano dell'Alba: una carta dei
/// maggiori, diritta o rovescia.
///
/// **L'ESTRAZIONE NON HA MEMORIA. Ordine DU voce 11, 17 settembre 2026.**
///
/// Fino alla build 2267 qui c'era un sacchetto senza reimbussolamento: ogni
/// stato usciva una volta per ciclo e la stessa carta non poteva tornare prima
/// di undici giorni. **Il fondatore ha deciso il contrario, e ha ragione sulla
/// natura della cosa**: *"alla roulette puo' uscire lo stesso numero due
/// volte"*. Una carta che non puo' tornare e' una carta che qualcuno sta
/// amministrando, e chi la riceve lo sente.
///
/// Quindi ogni giorno si estrae **a caso fra tutti e quarantaquattro**, senza
/// guardare cio' che e' gia' uscito. La stessa carta due giorni di fila capita
/// una volta su ventidue, e non e' un difetto: e' il caso.
///
/// **Cio' che non si ripete sono i TESTI**, voce 12, e quello lo tiene il
/// diario della persona con le sue code e i suoi registri.
class StatoDellAlba {
  const StatoDellAlba(this.carta, {required this.rovescio});

  factory StatoDellAlba.daId(int id) =>
      StatoDellAlba(id ~/ 2, rovescio: id.isOdd);

  /// Uno stato qualunque, con la stessa probabilita' per tutti.
  ///
  /// [caso] e' la sola fonte d'incertezza: chi riceve la carta non la vede,
  /// non la sceglie e non la puo' prevedere. **E nemmeno il verso**, voce 07:
  /// il verso esce da qui, non dalla carta toccata.
  factory StatoDellAlba.aCaso(Random caso) =>
      StatoDellAlba.daId(caso.nextInt(quanti));

  /// Quante carte: i maggiori che hanno un'attribuzione.
  static int get carte => AttribuzioneDellArcano.tutte.length;

  /// Quanti stati: ogni carta nei due versi.
  static int get quanti => carte * 2;

  /// L'indice della carta fra i maggiori, nell'ordine del mazzo.
  final int carta;
  final bool rovescio;

  int get id => carta * 2 + (rovescio ? 1 : 0);

  @override
  bool operator ==(Object other) => other is StatoDellAlba && other.id == id;

  @override
  int get hashCode => id;

  @override
  String toString() => 'StatoDellAlba($carta${rovescio ? ' rovescia' : ''})';
}
