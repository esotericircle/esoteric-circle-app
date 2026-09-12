import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/rituals/rune_lore.g.dart';
import 'package:esoteric_circle/core/rituals/runes.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';

/// **LA RUNA SINGOLA NON E' UNA LEZIONE.** Ordine CQ voce 2.10,
/// 4 settembre 2026.
///
/// **Il fatto, parole del fondatore:** il responso della runa singola e' troppo
/// lungo, tre paragrafi.
///
/// **La causa, misurata.** La scheda di una runa mostra cinque testi uno sotto
/// l'altro: la parola chiave, la descrizione del simbolo, la riga di risposta,
/// la Voce della Runa e la strofa attestata con la sua fonte. Su una gettata a
/// **tre o cinque rune** quei cinque testi sono il corpo della lettura, e
/// stanno bene dove sono; su una gettata a **una runa sola** diventano tutto
/// cio' che c'e' a schermo, e il responso si legge come una pagina di manuale
/// invece che come una risposta.
///
/// **Cosa cambia e cosa no.** Il corpus non si tocca: le stesse frasi restano,
/// e restano leggibili. Cambia **quante ne arrivano insieme** quando la
/// gettata e' di una runa sola: la risposta e il simbolo, e il resto sotto una
/// porta che si apre.
///
/// **La grandezza misurata sono i CARATTERI a schermo**, non i paragrafi: un
/// paragrafo puo' essere di due righe o di dieci, e contarli direbbe poco.
void main() {
  /// Quanto testo porta la scheda di una runa, contando i pezzi che la
  /// schermata mostra sempre.
  int caratteriDi(Rune r, {required bool tutto}) {
    final dritta = RunaGettata(
        rune: r,
        verso: RuneVerso.dritto,
        posizione: const PosizioneGettata('Prova', 'la posizione della prova'));
    var quanti = r.keyword.length + dritta.riga.length;
    if (tutto) {
      quanti += r.meaning.length;
      final lore = kRuneLore[r.name];
      if (lore != null && lore.strofe.isNotEmpty) {
        quanti += lore.strofe.first.traduzione.length +
            lore.strofe.first.fonte.length;
      }
    }
    return quanti;
  }

  test('a una runa sola il responso sta sotto la misura di una risposta', () {
    var guardate = 0;
    final lunghe = <String>[];
    var sommaCorta = 0;
    var sommaLunga = 0;
    for (final r in kElderFuthark) {
      guardate++;
      final corta = caratteriDi(r, tutto: false);
      final lunga = caratteriDi(r, tutto: true);
      sommaCorta += corta;
      sommaLunga += lunga;
      // **DUECENTOTTANTA CARATTERI**, e il numero non e' scelto a caso: e' la
      // misura di un messaggio che si legge in un colpo d'occhio senza
      // scorrere, ed e' circa quattro righe piene a diciotto punti su uno
      // schermo da 390. Sopra questa misura una risposta smette di essere una
      // risposta e diventa un testo da leggere.
      if (corta > 280) lunghe.add('${r.name} a $corta caratteri');
    }
    // ignore: avoid_print
    print('ORDINE CQ VOCE 2.10: rune guardate $guardate; a una runa sola la '
        'scheda porta in media ${(sommaCorta / guardate).round()} caratteri, '
        'con tutto ne porterebbe ${(sommaLunga / guardate).round()}');
    cardinaleMinimo(guardate, 24,
        cosa: 'rune del Futhark antico misurate',
        perche: 'Con un corpus vuoto la misura sarebbe zero caratteri, e la '
            'prova verde per assenza.');
    expect(lunghe, isEmpty,
        reason: 'queste rune, da sole, portano piu di 280 caratteri: '
            '${lunghe.take(4).join(", ")}');
  });

  test('e il taglio e vero: con tutto sarebbe piu del doppio', () {
    // **UNA PROVA CHE MISURA SOLO IL DOPO NON DICE SE QUALCOSA E' CAMBIATO.**
    // Qui si misura anche il prima, cioe' quanto porterebbe la scheda intera,
    // cosi' il numero racconta il taglio invece di dichiararlo.
    var corta = 0;
    var lunga = 0;
    for (final r in kElderFuthark) {
      corta += caratteriDi(r, tutto: false);
      lunga += caratteriDi(r, tutto: true);
    }
    final rapporto = lunga / corta;
    // ignore: avoid_print
    print('ORDINE CQ VOCE 2.10: la scheda intera e ${rapporto.toStringAsFixed(2)} '
        'volte quella corta');
    expect(rapporto, greaterThan(2.0),
        reason: 'la scheda intera e solo ${rapporto.toStringAsFixed(2)} volte '
            'quella corta: allora non c era niente da accorciare, e questa '
            'voce sta curando una cosa che non esiste');
  });
}
