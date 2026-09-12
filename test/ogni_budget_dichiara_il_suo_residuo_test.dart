import 'dart:io';

import 'package:esoteric_circle/core/entitlement/budget_del_giorno.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:flutter_test/flutter_test.dart';

import 'sorgenti_di_lib.dart';

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
    // **LA GALLERIA E NON IL VERDETTO, ordine CF voce 11.** Il gesto che
    // consuma una sinastria e' scegliere un volto, e si sceglie qui: nella
    // schermata del verdetto il numero arriva a consumo avvenuto.
    BudgetDelGiorno.sinastrie:
        'lib/features/synastry/sinastria_gallery_screen.dart',
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
      // **ADESSO SI CERCA IL WIDGET, non una menzione. Ordine CF voce 11.**
      //
      // **Questa prova era verde mentre il difetto era a schermo**, ed e' il
      // motivo per cui la voce CF.11 esiste. Accettava che il nome del budget
      // comparisse da qualche parte nel file: nella Sinastria compariva, ma
      // dentro la lista del VERDETTO, cioe' DOPO che la coppia era stata
      // scelta e il consumo era gia' avvenuto. Il fondatore non lo vedeva
      // perche' arrivava quando non serviva piu', e la prova diceva di si'.
      //
      // Adesso si pretende la riga vera, `RigaDelResiduo`, montata col suo
      // budget: una forma sola, che e' anche cio' che ha permesso di togliere
      // i due contatori privati delle rune e dei tarocchi.
      final dichiara = testo.contains('RigaDelResiduo(') &&
          testo.contains('budget: BudgetDelGiorno.${b.name}');
      if (!dichiara) muti.add('${b.name} in $percorso');
    }
    // ignore: avoid_print
    print('ORDINE CE VOCE 04: budget ${BudgetDelGiorno.values.length}, '
        'senza il loro residuo prima del gesto ${muti.length}');
    expect(muti, isEmpty,
        reason: 'questi budget si consumano senza dire quanto resta: $muti');
  });

  test('il borsellino li dichiara tutti, e non ne sceglie quattro', () {
    final foglio =
        File('lib/design_system/components/borsellino.dart').readAsStringSync();
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
    // **ADESSO SI PRETENDE IL SILENZIO INTERO, ordine CF voce 11.** Questa
    // riga diceva `greaterThanOrEqualTo(0)`, cioe' non pretendeva niente: un
    // numero maggiore o uguale a zero lo e' sempre. Intanto il codice
    // scriveva il numero LOCALE anche senza la risposta del server, mentre la
    // sua stessa documentazione dichiarava di tacere. Fra il codice e il
    // commento vince il fondatore: si tace, e adesso la prova lo misura.
    expect(muti, BudgetDelGiorno.values.length,
        reason: 'senza la risposta del server $muti budget su '
            '${BudgetDelGiorno.values.length} tacciono: gli altri scrivono un '
            'numero che nessuno ha confermato');
  });

  test('la porta delle prove non e\' mai aperta nell\'app', () {
    // **`ilServerHaParlato` esiste per le prove e per nessun altro.**
    // Ordine CF voce 11: senza questa riga la seconda porta diventerebbe
    // un modo per far dire alla riga del residuo un numero che il server
    // non ha mai confermato, cioe' esattamente il difetto che la voce ha
    // appena chiuso.
    final colpe = <String>[];
    for (final f in sorgentiDiLib()) {
      final percorso = f.path.replaceAll(r'\\', '/');
      if (percorso.endsWith('question_allowance.dart')) continue;
      if (f.readAsStringSync().contains('ilServerHaParlato')) {
        colpe.add(percorso);
      }
    }
    // ignore: avoid_print
    print('ORDINE CF VOCE 11: punti dell\'app che aprono la porta delle '
        'prove ${colpe.length}');
    expect(colpe, isEmpty,
        reason: 'questi punti dell\'app dichiarano da soli che il server ha '
            'parlato: $colpe');
  });

  test('la riga si accorda in italiano, e in tutti e quattro i modi', () {
    // Zero, uno e molti sono tre frasi diverse: una lingua che si accorda da
    // sola non esiste.
    //
    // **E IL QUARTO MODO E' IL BUDGET INTATTO, ordine CO voce 11**, 3
    // settembre 2026. Il fondatore ha letto "Ti restano 50 gettate di rune su
    // 50, oggi": il numero era giusto e la frase era una tautologia. Restare
    // dice che qualcosa e' stato tolto, e davanti a un budget intatto non c'e'
    // niente da cui restare. Prima del primo gesto e' una DOTAZIONE, dopo e'
    // un residuo.
    final frasi = <String>[
      QuestionAllowance.residuoDiCosa(0, 3,
          uno: 'sinastria', molti: 'sinastrie', femminile: true),
      QuestionAllowance.residuoDiCosa(1, 3,
          uno: 'sinastria', molti: 'sinastrie', femminile: true),
      QuestionAllowance.residuoDiCosa(2, 3,
          uno: 'sinastria', molti: 'sinastrie', femminile: true),
      QuestionAllowance.residuoDiCosa(3, 3,
          uno: 'sinastria', molti: 'sinastrie', femminile: true),
    ];
    // ignore: avoid_print
    print('ORDINE CE VOCE 04 con CO VOCE 11: ${frasi.join(" | ")}');
    expect(frasi[0], 'Non ti resta nessuna sinastria, oggi');
    expect(frasi[1], 'Ti resta 1 sinastria su 3, oggi');
    expect(frasi[2], 'Ti restano 2 sinastrie su 3, oggi');
    expect(frasi[3], 'Oggi hai 3 sinastrie',
        reason: 'col budget intatto la riga dice ancora "ne restano tre su '
            'tre", che e\' la frazione che vale sempre uno e suggerisce una '
            'sottrazione che non e\' avvenuta');

    // E il tetto di uno, che e' il caso in cui dotazione e ultimo pezzo
    // coincidono: il singolare deve reggere anche li'.
    expect(
        QuestionAllowance.residuoDiCosa(1, 1,
            uno: 'gettata di rune', molti: 'gettate di rune', femminile: true),
        'Oggi hai 1 gettata di rune',
        reason: 'col tetto a uno la frase cade sul plurale, ed e\' proprio il '
            'piano del Viandante per le gettate');
  });
}
