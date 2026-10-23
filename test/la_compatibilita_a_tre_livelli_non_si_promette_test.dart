import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/strade_dello_sblocco.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'sorgenti_di_lib.dart';

/// **LA COMPATIBILITA' A TRE LIVELLI NON SI PROMETTE.** Ordine FU voce FU.16,
/// 15 ottobre 2026.
///
/// La card dell'Illuminato prometteva "Compatibilità a tre livelli,
/// esclusiva", e la tabella di confronto dei piani ne aveva la riga. Il
/// rapporto dell'ordine FT ha scritto che nessuna parte dell'app la esegue:
/// la Sinastria evolutiva legge due cieli veri in cinque capitoli, senza
/// livello angelico ne' archetipico. Il fondatore: *"hai inserito di togliere
/// la promessa falsa sulla compatibilità a tre livelli?"* e *"Ok, scrivilo"*.
///
/// **Si guarda tutta `lib`, e non soltanto il catalogo dei piani**: una
/// schermata, un paywall o una notifica che la annunciasse con parole sue
/// sarebbe la stessa promessa. I commenti non contano, perche' non li legge
/// nessuno a schermo (le lapidi che raccontano cosa c'era stanno proprio
/// li'); le stringhe si. Le stringhe spezzate in due pezzi accostati
/// (`'Compatibilità a tre ' 'livelli'`) si rileggono intere, se no basterebbe
/// andare a capo per passare.
void main() {
  test(
      'NESSUNA STRINGA DI lib PROMETTE UNA COMPATIBILITA\' A TRE LIVELLI, '
      'e i piani non la contano', () {
    final vietata = RegExp(
      // La compatibilita' o la sinastria a tre livelli, nei due ordini.
      r'(compatibilit|sinastri|coppia)[^.]{0,40}\b(tre|3) livelli'
      r'|\b(tre|3) livelli[^.]{0,40}(compatibilit|sinastri|coppia)'
      // I livelli per nome: astrale, angelico e archetipico.
      r'|livell\w* (astral|angelic|archetipic)'
      r'|astral\w*,? angelic\w*'
      r'|angelic\w*,? e archetipic\w*'
      // Il nome che l'ordine ER le aveva dato in un punto.
      r'|compatibilit\S* unificata',
      caseSensitive: false,
    );
    // Un letterale fra apici semplici o doppi, con gli apici scappati.
    final letterale = RegExp(r"'(?:[^'\\\n]|\\.)*'" '|' r'"(?:[^"\\\n]|\\.)*"');
    // **DALLA PORTA COMUNE**, che porta con se' il suo cardinale minimo.
    final colpevoli = <String>[];
    var stringheLette = 0;
    for (final f in sorgentiDiLib()) {
      final codice = senzaCommenti(f.readAsStringSync());
      // I letterali accostati, separati solo da spazi e a capo, si leggono
      // come una stringa sola: e' cosi' che Dart li unisce.
      final pezzi = letterale.allMatches(codice).toList();
      var i = 0;
      while (i < pezzi.length) {
        final testo = StringBuffer(_dentro(pezzi[i].group(0)!));
        var j = i;
        while (j + 1 < pezzi.length &&
            codice.substring(pezzi[j].end, pezzi[j + 1].start).trim().isEmpty) {
          j++;
          testo.write(_dentro(pezzi[j].group(0)!));
        }
        stringheLette++;
        if (vietata.hasMatch(testo.toString())) {
          colpevoli.add('${f.path}: $testo');
        }
        i = j + 1;
      }
    }
    // **IL CARDINALE DELLE STRINGHE.** La porta conta i file, non le
    // stringhe: se il riconoscimento dei letterali si rompesse, la guardia
    // girerebbe su file veri senza leggere niente. Il 15 ottobre 2026 sono
    // state lette 61.458 stringhe; il minimo dichiarato e' quarantamila, un
    // margine di ventimila che regge una ripulitura seria.
    cardinaleMinimo(
      stringheLette,
      40000,
      cosa: 'stringhe lette dentro lib',
      perche: 'Senza stringhe lette la guardia non puo\' trovare la '
          'promessa, e sarebbe verde senza aver guardato.',
    );
    final illuminato = PlanCatalog.forTier(Tier.tier3).highlights;
    final tutti = Tier.values
        .expand((t) => PlanCatalog.forTier(t).highlights)
        .toList(growable: false);
    final righe = PlanCatalog.matrix.map((r) => r.label).toList();
    // ignore: avoid_print
    print('ORDINE FU VOCE FU.16: stringhe lette $stringheLette, stringhe che '
        'la promettono ${colpevoli.length}, vantaggi dell\'Illuminato '
        '${illuminato.length}, righe della matrice ${righe.length}');
    expect(colpevoli, isEmpty, reason: colpevoli.join('\n'));
    expect(tutti.where(vietata.hasMatch), isEmpty,
        reason: 'un piano conta ancora la compatibilità a tre livelli');
    expect(righe.where(vietata.hasMatch), isEmpty,
        reason: 'la tabella dei piani la mostra ancora');
    expect(
        StradeDelloSblocco.soloAbbonamento
            .where((id) => id.contains('three_levels')),
        isEmpty,
        reason: 'l\'elenco di cio\' che gli Eos non comprano nomina ancora '
            'una funzione che non esiste');
  });
}

/// Il contenuto di un letterale, senza i suoi apici.
String _dentro(String letterale) =>
    letterale.substring(1, letterale.length - 1);
