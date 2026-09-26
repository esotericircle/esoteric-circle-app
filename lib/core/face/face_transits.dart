import '../archetypes/archetype_transits.dart' show Pianeta, ArchetypeTransits;
import 'face_trait.dart';

/// La modulazione della Costellazione del Viso col cielo del giorno.
///
/// Come nel Test Archetipo: NON si calcolano effemeridi nuove, i pianeti attivi
/// arrivano come input (il Sole sempre, la Luna quando e' abbastanza piena) e la
/// cornice e' la SINCRONICITA', non la causa. Qui la spinta non cambia i tratti,
/// che vengono dalla geometria e restano quelli: il cielo aggiunge solo una riga
/// di senso accanto al tratto piu' marcato.
class FaceTransits {
  const FaceTransits._();

  /// La cornice di sincronicita', la stessa del Test Archetipo.
  static const String cornice = ArchetypeTransits.corniceSincronicita;

  /// La riga di modulazione dal cielo del giorno, deterministica dai pianeti
  /// attivi e dal tratto dominante. Vuota se non c'e' nessun pianeta.
  static String? riga(FaceTrait dominante, Set<Pianeta> pianeti) {
    if (pianeti.isEmpty) return null;
    final nomi = _nomiPianeti(pianeti);
    return 'Oggi $nomi mettono in luce il tratto che più ti segna, '
        '${dominante.nome.toLowerCase()}.';
  }

  /// I nomi dei pianeti attivi con l'articolo, uniti senza la virgola prima
  /// della congiunzione. Oggi il dispositivo calcola solo Sole e Luna.
  static String _nomiPianeti(Set<Pianeta> pianeti) {
    final ordinati = [
      for (final p in Pianeta.values)
        if (pianeti.contains(p)) p,
    ];
    final conArticolo = ordinati.map(_conArticolo).toList();
    if (conArticolo.length == 1) return conArticolo.first;
    final ultimo = conArticolo.removeLast();
    return '${conArticolo.join(', ')} e $ultimo';
  }

  static String _conArticolo(Pianeta p) {
    switch (p) {
      case Pianeta.luna:
      case Pianeta.venere:
        return 'la ${p.nome}';
      default:
        return 'il ${p.nome}';
    }
  }
}
