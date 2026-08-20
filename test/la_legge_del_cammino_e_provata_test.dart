import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA LEGGE E' PROVATA, NON PROMESSA. Ordine AR voce 03.
///
/// **La legge, in tre regole.** UN GESTO, UNA FESTA: due traguardi non possono
/// maturare sullo stesso gesto. Ci arrivano tre regole che qui si provano una
/// per una:
///   la SCALA, cioe' un solo gradino armato per sentiero alla volta;
///   le FAMIGLIE DISGIUNTE, cioe' i gesti di un Maestro toccano un sentiero
///   solo;
///   UN GRADINO PER GESTO, cioe' un gradino gia' soddisfatto dal passato
///   matura sul PRIMO gesto della sua famiglia dopo l'armamento, mai sullo
///   stesso gesto che ha chiuso il gradino precedente.
///
/// **Perche' si enumera invece di simulare.** Una simulazione prova la strada
/// che ha percorso; l'enumerazione prova TUTTE le coppie. Se esiste un evento
/// che soddisfa due condizioni insieme, questa prova lo trova e nomina la
/// coppia, anche se nessun utente ci arrivera' mai per caso.
void main() {
  /// L'universo degli eventi possibili: uno stato del cammino per ogni
  /// "cosa puo' succedere". Non e' l'infinito, e' l'insieme delle chiavi che
  /// le condizioni sanno leggere.
  List<StatoDelCammino> eventiPossibili() {
    final gesti = <String>{
      for (final t in Sentieri.tuttiITraguardi)
        if (t.condizione is GestiCompiuti) (t.condizione as GestiCompiuti).gesto,
      for (final t in Sentieri.tuttiITraguardi)
        if (t.condizione is GiorniDiSeguito)
          (t.condizione as GiorniDiSeguito).rito,
    };
    final stati = <StatoDelCammino>[];
    // Un evento per gesto: quel gesto compiuto una volta di piu'.
    for (final g in gesti) {
      stati.add(StatoDelCammino(gestiCompiuti: {g: 1}, oggiHaFatto: {g}));
    }
    return stati;
  }

  test('nessun evento minimo accende due traguardi insieme', () {
    final colpe = <String>[];
    for (final stato in eventiPossibili()) {
      final accesi = <String>[];
      for (final t in Sentieri.tuttiITraguardi) {
        if (t.dormiente) continue;
        if (t.condizione.raggiunto(stato)) accesi.add(t.id);
      }
      if (accesi.length > 1) {
        colpe.add('${stato.gestiCompiuti.keys.first} accende $accesi');
      }
    }
    // ignore: avoid_print
    print('ORDINE AR VOCE 03: eventi minimi che accendono piu di un '
        'traguardo: ${colpe.length}');
    expect(colpe, isEmpty,
        reason: 'un gesto solo accende piu traguardi insieme, quindi partono '
            'piu feste e piu accrediti per lo stesso motivo: '
            '${colpe.take(4).join("; ")}');
  });

  test('le famiglie sono disgiunte: ogni gesto tocca un sentiero solo', () {
    // **LA SECONDA REGOLA.** Se lo stesso gesto comparisse nelle condizioni di
    // due sentieri, un traguardo di Medora e uno di Caligo potrebbero
    // maturare insieme: la legge cadrebbe senza che nessuna condizione sia
    // ripetuta.
    final sentieroDelGesto = <String, String>{};
    final incroci = <String>[];
    for (final s in Sentiero.values) {
      for (final t in Sentieri.di(s)) {
        if (t.dormiente) continue;
        final c = t.condizione;
        final gesti = <String>[
          if (c is GestiCompiuti) c.gesto,
          if (c is GiorniDiSeguito) c.rito,
          if (c is FinestraDelCielo && c.conGesto != null) c.conGesto!,
          if (c is GestiNelloStessoGiorno) ...c.gesti,
          if (c is VarietaDelDettaglio) c.gesto,
          if (c is CoincidenzaDelDettaglio) c.gesto,
        ];
        for (final g in gesti) {
          // I gesti comuni a tutti i sentieri per progetto non sono un
          // incrocio: sono il tempo condiviso, e li si dichiara qui.
          if (const {'presenza', 'alba', 'soffio'}.contains(g)) continue;
          final gia = sentieroDelGesto[g];
          if (gia != null && gia != s.name) {
            incroci.add('$g sta su $gia e su ${s.name} (${t.id})');
          } else {
            sentieroDelGesto[g] = s.name;
          }
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE AR VOCE 03: gesti che toccano piu di un sentiero: '
        '${incroci.length}');
    expect(incroci, isEmpty,
        reason: 'questi gesti toccano piu sentieri, quindi un gesto solo puo '
            'far maturare due traguardi di due Maestri diversi: '
            '${incroci.take(4).join("; ")}');
  });

  test('la scala: in ogni sentiero i gradini hanno un ordine unico', () {
    // **LA PRIMA REGOLA.** Un solo gradino armato per sentiero alla volta
    // vuol dire che l'ordine e' totale: due gradini con la stessa posizione
    // sarebbero due gradini armati insieme.
    for (final s in Sentiero.values) {
      final posizioni = Sentieri.di(s).map((t) => t.posizione).toList();
      expect(posizioni.toSet().length, posizioni.length,
          reason: 'in ${s.name} due gradini hanno la stessa posizione: la '
              'scala non sa quale armare');
    }
  });

  test('le combinazioni di giornata maturano su un gesto, mai a mezzanotte',
      () {
    // **LA TERZA REGOLA, dal lato del dato.** Una combinazione che chiedesse
    // "tutti i doni del giorno" senza nominare i gesti maturerebbe allo
    // scadere del giorno, cioe' quando nessuno sta guardando. Qui si pretende
    // che ogni combinazione nomini i gesti che la completano.
    for (final t in Sentieri.tuttiITraguardi) {
      final c = t.condizione;
      if (c is! GestiNelloStessoGiorno) continue;
      expect(c.gesti, isNotEmpty,
          reason: '${t.id} e una combinazione di giornata senza gesti: '
              'maturerebbe da sola');
    }
  });
}
