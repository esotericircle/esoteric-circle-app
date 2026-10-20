import 'dart:io';
import 'dart:math';

import 'package:esoteric_circle/core/responsi/la_forma_del_responso.dart';
import 'package:esoteric_circle/core/rituals/il_corpus_del_presagio.g.dart';
import 'package:esoteric_circle/core/rituals/il_presagio_dal_corpus.dart';
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
///
/// **DALL'ORDINE GA, voce GA.05, 20 ottobre 2026, la runa sola E' il
/// responso principale.** Il fondatore, 20 ottobre 2026 alle 00:10:
/// *"Profondità lunga solo dal tier 1 e solo per il responso principale"*, e
/// l'ordine: *"La stesa a una carta e la runa singola: il responso
/// principale è quello della carta o della runa, nella forma di GA.03, senza
/// ripetere un secondo blocco per la stessa carta."* La misura in caratteri
/// della scheda (al piu' 280 caratteri a vista) non vale piu': a vista ci
/// sono il titolo e due paragrafi da 40 a 50 parole nella Breve. Cio' che
/// resta vero di questa voce si misura qui in parole: **a vista non c'e'
/// una lezione**, cioe' due paragrafi e non di piu' nella Breve, e il
/// significato del segno e la strofa (la "lezione") stanno dietro la porta,
/// non nei paragrafi a vista.
void main() {
  test(
      'a una runa sola il responso e\' quello principale, breve, senza '
      'scheda', () {
    var guardate = 0;
    final lunghe = <String>[];
    var somma = 0;
    for (var seme = 0; seme < 200; seme++) {
      final esito = RuneCast.getta(gettate.first, random: Random(seme));
      expect(esito.rune.length, 1);
      final p = IlPresagioDalCorpus.componi(
        corpus: corpusDelPresagio,
        esito: esito,
        domanda: '',
        persona: 'runa-sola-$seme',
        oggi: DateTime(2026, 10, 20),
        memoria: LaMemoriaDelPresagio(),
      );
      guardate++;
      final parole = p.principale.paragrafi
          .map(LaFormaDelResponso.parole)
          .fold<int>(0, (a, b) => a + b);
      somma += parole;
      if (p.principale.paragrafi.length != 2 ||
          parole > 2 * LaFormaDelResponso.massimo ||
          p.schede.isNotEmpty) {
        lunghe.add('${esito.rune.first.rune.name}: '
            '${p.principale.paragrafi.length} paragrafi, $parole parole, '
            '${p.schede.length} schede');
      }
    }
    // ignore: avoid_print
    print('ORDINE GA VOCE 05: rune sole guardate $guardate; a vista in media '
        '${(somma / guardate).round()} parole in due paragrafi');
    cardinaleMinimo(guardate, 200,
        cosa: 'gettate a una runa composte',
        perche: 'Con un corpus vuoto la misura sarebbe zero parole, e la '
            'prova verde per assenza.');
    expect(lunghe, isEmpty,
        reason: 'a una runa sola a vista c\'e\' piu\' del responso breve: '
            '${lunghe.take(4).join(", ")}');
  });

  test('e la lezione sta dietro la porta, non nei paragrafi a vista', () {
    // **UNA PROVA CHE MISURA SOLO IL DOPO NON DICE SE QUALCOSA E' CAMBIATO.**
    // Il significato del segno e la strofa del poema sono la lezione: non
    // devono comparire nei paragrafi a vista, e la porta "Da dove nasce
    // questa runa" deve portarli.
    var guardate = 0;
    final dentro = <String>[];
    for (final r in kElderFuthark) {
      final esito = EsitoGettata(gettata: gettate.first, rune: [
        RunaGettata(
            rune: r,
            verso: RuneVerso.dritto,
            posizione: gettate.first.posizioni.first),
      ]);
      final p = IlPresagioDalCorpus.componi(
        corpus: corpusDelPresagio,
        esito: esito,
        domanda: '',
        persona: 'lezione',
        oggi: DateTime(2026, 10, 20),
        memoria: LaMemoriaDelPresagio(),
      );
      guardate++;
      final aVista = p.principale.paragrafi.join(' ');
      final strofa = kRuneLore[r.name]?.strofe.first.traduzione;
      if (aVista.contains(r.meaning) ||
          (strofa != null && aVista.contains(strofa))) {
        dentro.add(r.name);
      }
    }
    final schermata =
        File('lib/features/maestri/caligo/rune/rune_draw_screen.dart')
            .readAsStringSync();
    final porta = schermata.indexOf('class _IlRestoDellaRunaState');
    cardinaleMinimo(guardate, 24,
        cosa: 'rune del Futhark antico misurate',
        perche: 'tutte e ventiquattro, dritte');
    expect(dentro, isEmpty,
        reason: 'la lezione e\' a vista per ${dentro.join(", ")}');
    expect(porta, greaterThan(0), reason: 'la porta non c\'e\' piu\'');
    for (final chiave in const ['rune_meaning_', 'rune_strofa_']) {
      expect(schermata.indexOf("Key('$chiave", porta), greaterThan(porta),
          reason: '$chiave non sta dietro la porta');
    }
  });
}
