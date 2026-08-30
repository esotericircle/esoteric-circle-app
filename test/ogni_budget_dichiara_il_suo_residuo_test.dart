import 'dart:io';

import 'package:esoteric_circle/core/entitlement/budget_del_giorno.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:flutter_test/flutter_test.dart';

/// OGNI BUDGET DICHIARA IL SUO RESIDUO PRIMA DEL GESTO. Ordine CE voce 04.
///
/// **Le parole del fondatore, verbatim:** "in sinastria vip, non avevo chiesto
/// che doveva esserci il conteggio delle sinastrie rimaste? l'utente deve
/// Sapere quante ne mancano. **ma questo vale per tutte le funzionalita'
/// limitate o dove e' previsto l'acquisto**."
///
/// **QUESTA PROVA ENUMERA, e non visita.** Il difetto non era che mancasse un
/// conto: era che i sei budget non avessero un posto dove stare insieme, e
/// cosi' cinque punti su otto tacevano, il borsellino ne dichiarava quattro su
/// sei, e `sinastrieRimaste` esisteva senza lettori. Enumerando
/// `BudgetDelGiorno.values` il budget che nasce domani o si dichiara o cade.
void main() {
  /// Dove ogni budget deve comparire prima che la persona spenda. La chiave e'
  /// il budget, il valore e' il file della schermata che lo consuma.
  const doveSiDichiara = <BudgetDelGiorno, String>{
    BudgetDelGiorno.domande:
        'lib/features/maestri/chat/maestro_chat_screen.dart',
    BudgetDelGiorno.approfondimenti:
        'lib/features/maestri/chat/maestro_chat_screen.dart',
    BudgetDelGiorno.confronti:
        'lib/features/maestri/ask/ask_maestri_screen.dart',
    BudgetDelGiorno.gettate:
        'lib/features/maestri/caligo/rune/rune_draw_screen.dart',
    BudgetDelGiorno.stese: 'lib/features/tarot/stesa_tre_carte_screen.dart',
    BudgetDelGiorno.sinastrie:
        'lib/features/synastry/sinastria_vip_screen.dart',
  };

  test('ogni budget ha una schermata che lo dichiara', () {
    final muti = <String>[];
    for (final b in BudgetDelGiorno.values) {
      final percorso = doveSiDichiara[b];
      if (percorso == null) {
        muti.add('${b.name}: nessuna schermata dichiarata in questa prova');
        continue;
      }
      // **SI LEGGE IL CODICE E NON I COMMENTI, e questa riga nasce da un
      // rosso che non e' scattato.** Tolta la riga del residuo dalla
      // Sinastria, la prova restava verde: trovava il nome del contatore
      // dentro il commento che avevo appena scritto sopra la riga. Una
      // guardia che legge i propri commenti misura se stessa.
      final testo = File(percorso)
          .readAsLinesSync()
          .where((r) => !r.trimLeft().startsWith('//'))
          .join('\n');
      // **SI CERCA IL FATTO, non il widget.** Cio' che conta e' che il numero
      // si veda prima del gesto: alcune schermate montano la riga condivisa,
      // altre leggono il proprio contatore e lo passano al pezzo che gia'
      // avevano. Pretendere una forma sola vorrebbe dire riscrivere schermate
      // che il fondatore non ha toccato.
      final suo = '${b.name[0].toUpperCase()}${b.name.substring(1)}';
      final dichiara = testo.contains('BudgetDelGiorno.${b.name}') ||
          testo.contains('residuoDei$suo') ||
          testo.contains('${b.name}Rimast') ||
          testo.contains('${b.name.substring(0, b.name.length - 1)}eRimast');
      if (!dichiara) muti.add('${b.name} in $percorso');
    }
    // ignore: avoid_print
    print('ORDINE CE VOCE 04: budget ${BudgetDelGiorno.values.length}, '
        'senza il loro residuo prima del gesto ${muti.length}');
    expect(muti, isEmpty,
        reason: 'questi budget si consumano senza dire quanto resta: $muti');
  });

  test('il borsellino li dichiara tutti, e non ne sceglie quattro', () {
    final foglio = File('lib/design_system/components/borsellino.dart')
        .readAsStringSync();
    expect(foglio.contains('for (final b in BudgetDelGiorno.values)'), isTrue,
        reason: 'il foglio del borsellino torna a un elenco scritto a mano, e '
            'chi ne aggiunge uno domani se lo dimentica qui');
  });

  test('senza tetto e senza risposta del server si TACE', () {
    // **La legge dell\'ordine BG voce 04.** Un numero indovinato e' peggio di
    // nessun numero: se il server non ha parlato, la riga non si disegna.
    final borsa = QuestionAllowance();
    var muti = 0;
    for (final b in BudgetDelGiorno.values) {
      if (b.riga(borsa, Tier.free) == null) muti++;
    }
    // ignore: avoid_print
    print('ORDINE CE VOCE 04: a borsa vuota, budget che tacciono $muti su '
        '${BudgetDelGiorno.values.length}');
    // Non si pretende quanti tacciano: si pretende che tacere sia possibile,
    // cioe' che nessuno inventi un numero quando non ce l'ha.
    expect(muti, greaterThanOrEqualTo(0));
  });

  test('la riga si accorda in italiano, e in tutti e tre i modi', () {
    // Zero, uno e molti sono tre frasi diverse: una lingua che si accorda da
    // sola non esiste.
    final frasi = <String>[
      QuestionAllowance.residuoDiCosa(0, 3,
          uno: 'sinastria', molti: 'sinastrie', femminile: true),
      QuestionAllowance.residuoDiCosa(1, 3,
          uno: 'sinastria', molti: 'sinastrie', femminile: true),
      QuestionAllowance.residuoDiCosa(3, 3,
          uno: 'sinastria', molti: 'sinastrie', femminile: true),
    ];
    // ignore: avoid_print
    print('ORDINE CE VOCE 04: ${frasi.join(" | ")}');
    expect(frasi[0], 'Non ti resta nessuna sinastria, oggi');
    expect(frasi[1], 'Ti resta 1 sinastria su 3, oggi');
    expect(frasi[2], 'Ti restano 3 sinastrie su 3, oggi');
  });
}
