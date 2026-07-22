import 'package:flutter/foundation.dart';

import 'archetype.dart';
import 'archetype_quiz.dart';

/// Il profilo archetipico: quanto pesa ciascuno dei dodici, in percentuale.
///
/// Le percentuali sommano a cento (a meno dell'arrotondamento in virgola
/// mobile). Il dominante c'e' sempre, il secondo solo quando e' abbastanza
/// vicino da avere voce anche lui.
@immutable
class ArchetypeProfile {
  const ArchetypeProfile({
    required this.percentuali,
    required this.dominante,
    this.secondo,
  });

  /// La percentuale di ciascuno dei dodici, sempre tutti e dodici presenti.
  final Map<Archetype, double> percentuali;

  /// L'archetipo piu' alto. A parita' vince l'ordine canonico.
  final Archetype dominante;

  /// Il secondo, quando sta entro la soglia dal primo. Null se il dominante e'
  /// staccato: in quel caso il responso parla di uno solo, senza inventare
  /// compagnia.
  final Archetype? secondo;

  double percentualeDi(Archetype a) => percentuali[a] ?? 0;

  /// I dodici ordinati dal piu' alto al piu' basso, coi pareggi sciolti
  /// dall'ordine canonico.
  List<Archetype> get graduatoria {
    final lista = [...Archetype.values];
    lista.sort((x, y) {
      final d = percentualeDi(y).compareTo(percentualeDi(x));
      return d != 0 ? d : x.ordineCanonico.compareTo(y.ordineCanonico);
    });
    return lista;
  }
}

/// Il calcolo del profilo, puro e deterministico.
///
/// Stesse risposte, stesso risultato: nessuna casualita', nessuna AI, nessuna
/// dipendenza dalla data o da uno stato esterno. E' la garanzia che la stessa
/// persona che rifa' il test senza cambiare idea ritrova se stessa, e insieme
/// e' cio' che rende il confronto nel tempo un dato e non un rumore.
class ArchetypeScoring {
  const ArchetypeScoring._();

  /// Quanto puo' stare sotto il dominante un archetipo per affiancarglisi,
  /// in punti percentuali.
  static const double sogliaSecondo = 10.0;

  /// Calcola il profilo dalle dodici risposte scelte.
  ///
  /// [scelte] e' lungo quanto le domande e contiene, per ciascuna, l'indice
  /// della risposta scelta. Un input malformato solleva invece di produrre in
  /// silenzio un profilo sbagliato: e' un errore del chiamante, non un caso
  /// d'uso.
  static ArchetypeProfile calcola(List<int> scelte) {
    if (scelte.length != ArchetypeQuiz.tutte.length) {
      throw ArgumentError(
          'servono ${ArchetypeQuiz.tutte.length} risposte, ricevute ${scelte.length}');
    }
    final punti = {for (final a in Archetype.values) a: 0};
    for (var i = 0; i < scelte.length; i++) {
      final domanda = ArchetypeQuiz.tutte[i];
      final scelta = scelte[i];
      if (scelta < 0 || scelta >= domanda.risposte.length) {
        throw ArgumentError(
            'risposta ${domanda.id} fuori intervallo: $scelta');
      }
      domanda.risposte[scelta].pesi.forEach((a, p) => punti[a] = punti[a]! + p);
    }

    final totale = punti.values.fold<int>(0, (s, v) => s + v);
    final percentuali = {
      for (final a in Archetype.values)
        a: totale == 0 ? 0.0 : punti[a]! * 100.0 / totale,
    };

    // Il dominante: il massimo, e a parita' chi viene prima nell'ordine
    // canonico. Si scorre `Archetype.values`, che E' quell'ordine, tenendo il
    // primo trovato: cosi' il pareggio si scioglie da se'.
    var dominante = Archetype.values.first;
    for (final a in Archetype.values) {
      if (percentuali[a]! > percentuali[dominante]!) dominante = a;
    }

    // Il secondo: il piu' alto fra i restanti, se sta entro la soglia.
    Archetype? secondo;
    for (final a in Archetype.values) {
      if (a == dominante) continue;
      if (secondo == null || percentuali[a]! > percentuali[secondo]!) {
        secondo = a;
      }
    }
    if (secondo != null &&
        percentuali[dominante]! - percentuali[secondo]! > sogliaSecondo) {
      secondo = null;
    }
    // Un secondo a zero non e' un secondo: sarebbe compagnia inventata.
    if (secondo != null && percentuali[secondo]! <= 0) secondo = null;

    return ArchetypeProfile(
      percentuali: percentuali,
      dominante: dominante,
      secondo: secondo,
    );
  }
}
