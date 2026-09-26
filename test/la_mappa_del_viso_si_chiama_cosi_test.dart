import 'package:esoteric_circle/core/arts/art_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **LA COSTELLAZIONE DEL VISO SI CHIAMA MAPPA DEL VISO.** Ordine EN voce 11,
/// 25 settembre 2026.
///
/// Il fondatore: *"Mappa del Viso senza articolo"*, e *"Va bene mappa del
/// viso"*. Il nome a video cambia ovunque: catalogo, schermata, Passaporto,
/// traguardi, testi dei Maestri, card da condividere.
///
/// **La grandezza misurata e' ogni riga di codice di `lib` che una persona
/// puo' leggere**, cioe' tutte tranne i commenti: i commenti raccontano la
/// storia col nome di allora, e cambiarli la riscriverebbe. Resta una sola
/// eccezione dichiarata, la parola chiave con cui la persona puo' ancora
/// chiedere l'arte in chat col vecchio nome.
void main() {
  test('nessun testo a video porta piu\' il vecchio nome', () {
    const eccezioni = {
      'lib/core/chat/immersive_intents.dart': "'costellazione del viso',",
    };
    final vecchio = RegExp(r'costellazion[ei] del viso', caseSensitive: false);
    final trovate = <String>[];
    var guardati = 0;
    var nuove = 0;
    for (final f in sorgentiDiLib()) {
      guardati++;
      final percorso = f.path.replaceAll(r'\', '/');
      for (final riga in f.readAsLinesSync()) {
        final pulita = riga.trim();
        if (pulita.startsWith('//')) continue;
        if (pulita.contains('Mappa del Viso') ||
            pulita.contains('MAPPA DEL VISO')) {
          nuove++;
        }
        if (!vecchio.hasMatch(pulita)) continue;
        if (eccezioni[percorso] == pulita) continue;
        trovate.add('$percorso: $pulita');
      }
    }
    cardinaleMinimo(guardati, 500, cosa: 'file di lib');
    expect(trovate, isEmpty,
        reason: 'il vecchio nome e\' ancora a video: ${trovate.join(' | ')}');
    // **Il cardinale del nome nuovo**: ventitre righe rinominate il 25
    // settembre 2026. Senza, una prova che cerca solo l'assenza del vecchio
    // sarebbe verde anche se l'arte sparisse del tutto.
    expect(nuove, greaterThanOrEqualTo(23),
        reason: 'il nome nuovo compare in $nuove righe');
  });

  test('il catalogo la chiama Mappa del Viso, senza articolo', () {
    final arte = ArtCatalog.all.where((a) => a.title.contains('del Viso'));
    expect(arte.map((a) => a.title), ['Mappa del Viso']);
  });
}
