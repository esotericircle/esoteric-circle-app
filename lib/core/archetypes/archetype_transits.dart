import 'package:flutter/foundation.dart';

import 'archetype.dart';
import 'archetype_corpus.dart';
import 'archetype_scoring.dart';

/// I dieci pianeti che la tabella lega agli archetipi.
enum Pianeta {
  sole('Sole'),
  luna('Luna'),
  mercurio('Mercurio'),
  venere('Venere'),
  marte('Marte'),
  giove('Giove'),
  saturno('Saturno'),
  urano('Urano'),
  nettuno('Nettuno'),
  plutone('Plutone');

  const Pianeta(this.nome);

  final String nome;
}

/// La riga che spiega perche' un pianeta ha spinto un archetipo.
@immutable
class MotivazioneTransito {
  const MotivazioneTransito({
    required this.pianeta,
    required this.archetipo,
    required this.testo,
  });

  final Pianeta pianeta;
  final Archetype archetipo;
  final String testo;
}

/// Il profilo modulato dai transiti, con le sue motivazioni.
@immutable
class ArchetypeModulazione {
  const ArchetypeModulazione({
    required this.base,
    required this.modulato,
    required this.motivazioni,
  });

  /// Il profilo dalle sole risposte, che resta sempre visibile: la modalita'
  /// base e' quella fedele alla tradizione e non si perde mai.
  final ArchetypeProfile base;

  /// Il profilo dopo la spinta dei transiti.
  final ArchetypeProfile modulato;

  /// Una riga per ogni pianeta che incide, nell'ordine dei pianeti.
  final List<MotivazioneTransito> motivazioni;
}

/// La modulazione del profilo coi transiti del giorno.
///
/// Qui NON si calcolano le effemeridi: i pianeti attivi arrivano come input.
/// E' una scelta precisa, cosi' la funzione resta pura e verificabile, e il
/// collegamento alle effemeridi gia' presenti sul dispositivo sta fuori, dove
/// c'e' l'orologio e il luogo.
///
/// La cornice e' la SINCRONICITA': il cielo non causa nulla, offre un
/// significato che si accosta a quel che sei. La spinta e' piccola per
/// costruzione, perche' il risultato deve restare quello delle risposte.
class ArchetypeTransits {
  const ArchetypeTransits._();

  /// Quanti punti percentuali aggiunge un pianeta a ciascuno dei suoi due
  /// archetipi, prima della normalizzazione. Piccola per scelta.
  static const double spinta = 3.0;

  /// La cornice, da mostrare dove compaiono le motivazioni.
  static const String corniceSincronicita =
      'Il cielo di oggi non ti cambia: si accosta a te. Quello che segue è '
      'sincronicità, cioè significato, non causa.';

  /// Curatela nostra sui significati tradizionali dei pianeti: due archetipi
  /// per pianeta, il primo e' quello piu' proprio.
  static const Map<Pianeta, List<Archetype>> tabella = {
    Pianeta.sole: [Archetype.eroe, Archetype.sovrano],
    Pianeta.luna: [Archetype.custode, Archetype.innocente],
    Pianeta.mercurio: [Archetype.saggio, Archetype.giullare],
    Pianeta.venere: [Archetype.amante, Archetype.creatore],
    Pianeta.marte: [Archetype.eroe, Archetype.ribelle],
    Pianeta.giove: [Archetype.saggio, Archetype.sovrano],
    Pianeta.saturno: [Archetype.sovrano, Archetype.realista],
    Pianeta.urano: [Archetype.ribelle, Archetype.mago],
    Pianeta.nettuno: [Archetype.mago, Archetype.innocente],
    Pianeta.plutone: [Archetype.mago, Archetype.ribelle],
  };

  /// Il testo di una motivazione, da un template deterministico.
  ///
  /// La chiusa non e' scritta a mano pianeta per pianeta: e' l'essenza
  /// dell'archetipo presa dal corpus, con l'iniziale minuscola. Cosi' non c'e'
  /// un secondo corpus da tenere allineato, e la riga dice sempre una cosa vera
  /// di quell'archetipo.
  static String motivazione(Pianeta p, Archetype a) {
    final essenza = ArchetypeCorpus.di(a).essenza;
    final chiusa = essenza.isEmpty
        ? essenza
        : essenza[0].toLowerCase() + essenza.substring(1);
    return 'Oggi ${p.nome} accende il tuo ${a.nome}: $chiusa';
  }

  /// Applica la spinta dei pianeti attivi e restituisce base, modulato e righe.
  ///
  /// I pianeti si leggono nell'ordine di [Pianeta.values] e non in quello in
  /// cui arrivano, cosi' lo stesso insieme da' sempre le stesse righe nello
  /// stesso ordine.
  static ArchetypeModulazione applica(
    ArchetypeProfile base,
    Set<Pianeta> attivi,
  ) {
    final punti = {
      for (final a in Archetype.values) a: base.percentualeDi(a),
    };
    for (final p in Pianeta.values) {
      if (!attivi.contains(p)) continue;
      for (final a in tabella[p]!) {
        punti[a] = punti[a]! + spinta;
      }
    }

    final totale = punti.values.fold<double>(0, (s, v) => s + v);
    final percentuali = {
      for (final a in Archetype.values)
        a: totale == 0 ? 0.0 : punti[a]! * 100.0 / totale,
    };

    var dominante = Archetype.values.first;
    for (final a in Archetype.values) {
      if (percentuali[a]! > percentuali[dominante]!) dominante = a;
    }
    Archetype? secondo;
    for (final a in Archetype.values) {
      if (a == dominante) continue;
      if (secondo == null || percentuali[a]! > percentuali[secondo]!) {
        secondo = a;
      }
    }
    if (secondo != null &&
        percentuali[dominante]! - percentuali[secondo]! >
            ArchetypeScoring.sogliaSecondo) {
      secondo = null;
    }
    if (secondo != null && percentuali[secondo]! <= 0) secondo = null;

    final modulato = ArchetypeProfile(
      percentuali: percentuali,
      dominante: dominante,
      secondo: secondo,
    );

    // Una riga per pianeta attivo. Fra i suoi due archetipi si nomina quello
    // che dopo la spinta sta piu' in alto, coi pareggi sciolti dall'ordine
    // canonico: la riga parla della corda che ha davvero vibrato di piu'.
    final righe = <MotivazioneTransito>[];
    for (final p in Pianeta.values) {
      if (!attivi.contains(p)) continue;
      final coppia = tabella[p]!;
      var scelto = coppia.first;
      for (final a in coppia) {
        final piuAlto = percentuali[a]! > percentuali[scelto]!;
        final pariMaPrima = percentuali[a]! == percentuali[scelto]! &&
            a.ordineCanonico < scelto.ordineCanonico;
        if (piuAlto || pariMaPrima) scelto = a;
      }
      righe.add(MotivazioneTransito(
        pianeta: p,
        archetipo: scelto,
        testo: motivazione(p, scelto),
      ));
    }

    return ArchetypeModulazione(
      base: base,
      modulato: modulato,
      motivazioni: righe,
    );
  }
}
