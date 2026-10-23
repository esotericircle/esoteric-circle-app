import 'la_lettura_evolutiva.dart';
import 'legame_e_eta.dart';

/// Un capitolo come viaggia verso l'amico del Cerchio: nome, titolo,
/// paragrafi, "Da dove viene". Nient'altro.
class CapitoloCondiviso {
  const CapitoloCondiviso({
    required this.capitolo,
    required this.titolo,
    required this.paragrafi,
    required this.daDoveViene,
  });

  final Capitolo capitolo;
  final String titolo;
  final List<String> paragrafi;
  final String daDoveViene;
}

/// **LA SINASTRIA CONDIVISA.** Ordine GD voce GD.21, 23 ottobre 2026
/// (proposta dell'Architetto approvata dal fondatore con "2 si"): quando la
/// persona della sinastria e' un amico del Cerchio, il responso arriva anche
/// a lei, con l'avviso che il vostro cielo e' stato letto.
///
/// **LO STESSO RESPONSO, NON UNA COPIA SCRITTA A MANO**: [dai] prende i
/// capitoli che la schermata ha appena composto (`LetturaEvolutiva.componi`)
/// e li mette nella forma della porta, campo per campo; chi riceve li
/// rilegge con [da]. Viaggiano solo i capitoli che il piano di chi legge ha
/// aperto: l'amico riceve cio' che e' stato letto, non di piu'.
///
/// **NESSUNA NASCITA**: la forma non ha un campo per una data, un'ora o un
/// luogo e il server butta ogni campo che non sia di un responso
/// (`sinastriaDaCorpo` in `functions/src/sinastria_evolutiva.ts`).
class LaSinastriaCondivisa {
  const LaSinastriaCondivisa({
    required this.legame,
    required this.segno,
    required this.capitoli,
  });

  final Legame legame;

  /// Il segno della relazione (il Sole del Tema Composito), per nome.
  final String segno;
  final List<CapitoloCondiviso> capitoli;

  factory LaSinastriaCondivisa.dai(
          {required Legame legame,
          required String segno,
          required List<CapitoloLetto> capitoli}) =>
      LaSinastriaCondivisa(
        legame: legame,
        segno: segno,
        capitoli: [
          for (final c in capitoli)
            CapitoloCondiviso(
              capitolo: c.capitolo,
              titolo: c.titolo,
              paragrafi: List.unmodifiable(c.paragrafi),
              daDoveViene: c.daDoveViene,
            ),
        ],
      );

  /// La forma della porta `mandaLaSinastria`.
  Map<String, Object?> comeDati() => {
        'legame': legame.name,
        'segno': segno,
        'capitoli': [
          for (final c in capitoli)
            {
              'capitolo': c.capitolo.name,
              'titolo': c.titolo,
              'paragrafi': c.paragrafi,
              'daDoveViene': c.daDoveViene,
            },
        ],
      };

  /// La sinastria ricevuta, dalla forma della porta; nulla se non e' intera.
  static LaSinastriaCondivisa? da(Map<String, Object?> d) {
    Legame? legame;
    for (final l in Legame.values) {
      if (l.name == d['legame']) legame = l;
    }
    final segno = d['segno'];
    final capitoli = d['capitoli'];
    if (legame == null || segno is! String || capitoli is! List) return null;
    final letti = <CapitoloCondiviso>[];
    for (final x in capitoli) {
      if (x is! Map) return null;
      Capitolo? c;
      for (final k in Capitolo.values) {
        if (k.name == x['capitolo']) c = k;
      }
      final titolo = x['titolo'];
      final paragrafi = x['paragrafi'];
      final fonte = x['daDoveViene'];
      if (c == null ||
          titolo is! String ||
          paragrafi is! List ||
          fonte is! String) {
        return null;
      }
      letti.add(CapitoloCondiviso(
        capitolo: c,
        titolo: titolo,
        paragrafi: [for (final p in paragrafi) '$p'],
        daDoveViene: fonte,
      ));
    }
    if (letti.isEmpty) return null;
    return LaSinastriaCondivisa(legame: legame, segno: segno, capitoli: letti);
  }
}
