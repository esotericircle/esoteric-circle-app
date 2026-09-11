import 'package:esoteric_circle/core/viaggio/diario_dei_viaggi.dart';
import 'package:esoteric_circle/core/viaggio/scena_del_viaggio.dart';
import 'package:esoteric_circle/core/viaggio/vocabolario_del_viaggio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// **L'ANIMALE LONTANO, E LA VIA DEL RITORNO IN UN GESTO SOLO.**
/// Ordine DE voce 12, 11 settembre 2026.
///
/// **CHE COSA C'ERA GIA', e va detto prima di ogni altra cosa.** La nitidezza
/// che scende col tempo esiste dall'ordine DC voce 08: sette giorni di
/// grazia, ventotto per arrivare al minimo, curva lineare, e la scena povera
/// quando l'animale e' lontano. **La voce DE.12 non la duplica.**
///
/// **CIO' CHE MANCAVA ERANO DUE COSE, e sono quelle che questa guardia
/// sorveglia.**
///
/// **Uno: la nitidezza poteva solo scendere.** La costante
/// `quantiGiorniValeUnNutrimento` era scritta e **nessuno la spendeva**: una
/// misura che peggiora e non risale non e' una distanza, e' una condanna.
///
/// **Due: il gesto non poteva valere quattro volte di seguito.** Senza un
/// limite, quattro colpi di tamburo riporterebbero la nitidezza da zero a uno
/// in quattro secondi, e una distanza che si annulla con quattro tocchi non e'
/// una distanza.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  UnViaggio viaggioDel(DateTime d) => UnViaggio(
        quando: d,
        domanda: 'una domanda',
        temaDellaDomanda: '',
        pezzi: const ['a', 'b', 'c', 'd'],
        animaleSeguito: 'Lupo',
        nitidezza: 1.0,
      );

  test('LA CURVA E QUELLA DICHIARATA, e a tre settimane la scena e confusa',
      () {
    final misure = <int, double>{
      for (final g in [0, 7, 10, 14, 21, 28, 40])
        g: NitidezzaDellaScena.dopoGiorni(g),
    };
    // ignore: avoid_print
    print('ORDINE DE VOCE 12: nitidezza per giorni di distanza '
        '${misure.map((k, v) => MapEntry(k, v.toStringAsFixed(3)))}');
    expect(misure[7], 1.0,
        reason: 'la settimana di grazia non e piena');
    expect(misure[28], 0.0, reason: 'a ventotto giorni non si tocca il fondo');
    // **Tre settimane, che e il caso nominato dalla voce DE.15.**
    expect(misure[21]!, closeTo(0.333, 0.005),
        reason: 'a ventuno giorni la nitidezza e ${misure[21]}');
    expect(NitidezzaDellaScena.laRiga(misure[21]!), isNotNull,
        reason: 'a tre settimane non si legge nessun avviso');
    // ignore: avoid_print
    print('ORDINE DE VOCE 12: a ventun giorni si legge '
        '"${NitidezzaDellaScena.laRiga(misure[21]!)}"');
  });

  test('L AVVISO E UNA CONSTATAZIONE, MAI UN RIMPROVERO', () {
    // **Le parole vietate**, e sono quelle che l ordine nomina: la colpa
    // rivolta alla persona. *"Non ti sei preso cura di lui"* e una colpa e fa
    // chiudere l app.
    const vietate = [
      'non ti sei',
      'hai trascurato',
      'ti sei dimenticato',
      'colpa',
      'dovevi',
      'avresti dovuto',
      'ti eri',
    ];
    final righe = <String>[];
    for (final n in [0.0, 0.2, 0.4, 0.5, 0.65]) {
      final r = NitidezzaDellaScena.laRiga(n);
      if (r != null) righe.add(r);
    }
    // ignore: avoid_print
    print('ORDINE DE VOCE 12: righe dell avviso trovate ${righe.length}: '
        '$righe');
    expect(righe, isNotEmpty,
        reason: 'sotto la soglia non si legge nessun avviso: questa prova '
            'cercherebbe dentro il nulla');
    for (final r in righe) {
      for (final v in vietate) {
        expect(r.toLowerCase().contains(v), isFalse,
            reason: 'l avviso rimprovera: "$r" contiene "$v"');
      }
    }
    // **REGOLA H: sopra la soglia non si dice NIENTE.** Un avviso che compare
    // anche a chi e vicino e un avviso che nessuno legge piu.
    expect(NitidezzaDellaScena.laRiga(1.0), isNull,
        reason: 'chi e sceso ieri legge che il suo animale e lontano');
    expect(NitidezzaDellaScena.laRiga(NitidezzaDellaScena.nitida), isNull);
  });

  test('IL TAMBURO RIAVVICINA SUBITO DI UN PASSO', () async {
    final oggi = DateTime(2026, 9, 11, 12);
    final diario = DiarioDeiViaggi(orologio: () => oggi);
    await diario.carica();
    // Ultima discesa ventun giorni fa: scena confusa.
    await diario.segna(viaggioDel(oggi.subtract(const Duration(days: 21))));

    final prima = diario.giorniDiDistanza!;
    final nitidezzaPrima = NitidezzaDellaScena.dopoGiorni(prima);
    await diario.nutri();
    final dopo = diario.giorniDiDistanza!;
    final nitidezzaDopo = NitidezzaDellaScena.dopoGiorni(dopo);
    // ignore: avoid_print
    print('ORDINE DE VOCE 12: prima del tamburo la distanza e $prima giorni '
        '(nitidezza ${nitidezzaPrima.toStringAsFixed(3)}), dopo e $dopo '
        'giorni (nitidezza ${nitidezzaDopo.toStringAsFixed(3)})');
    expect(dopo, prima - NitidezzaDellaScena.quantiGiorniValeUnNutrimento,
        reason: 'il tamburo non toglie i sette giorni che vale');
    expect(nitidezzaDopo, greaterThan(nitidezzaPrima),
        reason: 'dopo il tamburo la nitidezza non migliora: il gesto non '
            'serve a niente');
    // **E IL PASSO SI LEGGE, non e solo un decimale.** La grandezza misurata
    // qui non e la nitidezza: e **la frase che compare a schermo**. Un gesto
    // che sposta un numero da 0,333 a 0,667 senza cambiare una parola di
    // cio che la persona legge e un gesto che sembra non aver fatto niente.
    final rigaPrima = NitidezzaDellaScena.laRiga(nitidezzaPrima);
    final rigaDopo = NitidezzaDellaScena.laRiga(nitidezzaDopo);
    // ignore: avoid_print
    print('ORDINE DE VOCE 12: prima si leggeva "$rigaPrima", dopo si legge '
        '"${rigaDopo ?? 'niente, la scena e nitida'}"');
    expect(rigaPrima, isNotNull,
        reason: 'a ventun giorni non si legge nessun avviso');
    expect(rigaDopo, isNot(rigaPrima),
        reason: 'il tamburo non cambia una parola di quello che si legge: il '
            'gesto sembra non aver fatto niente');
    // E anche il numero degli elementi leggibili sale, che e la cosa che
    // cambia davvero nella risposta.
    expect(ScenaDelViaggio(luogo: VocabolarioDelViaggio.luoghi.first,
            cosa: VocabolarioDelViaggio.cose.first,
            gesto: VocabolarioDelViaggio.gesti.first,
            momento: VocabolarioDelViaggio.momenti.first,
            nitidezza: nitidezzaDopo).quantiSiVedono,
        greaterThan(ScenaDelViaggio(luogo: VocabolarioDelViaggio.luoghi.first,
            cosa: VocabolarioDelViaggio.cose.first,
            gesto: VocabolarioDelViaggio.gesti.first,
            momento: VocabolarioDelViaggio.momenti.first,
            nitidezza: nitidezzaPrima).quantiSiVedono),
        reason: 'dopo il tamburo la scena non porta su un elemento in piu');
  });

  test('REGOLA H: IL TAMBURO NON SI BATTE DUE VOLTE NELLO STESSO GIORNO',
      () async {
    final oggi = DateTime(2026, 9, 11, 12);
    final diario = DiarioDeiViaggi(orologio: () => oggi);
    await diario.carica();
    await diario.segna(viaggioDel(oggi.subtract(const Duration(days: 28))));

    expect(diario.siPuoNutrireOggi(), isTrue);
    await diario.nutri();
    // ignore: avoid_print
    print('ORDINE DE VOCE 12: dopo un colpo si puo ancora battere oggi? '
        '${diario.siPuoNutrireOggi()}, distanza ${diario.giorniDiDistanza}');
    expect(diario.siPuoNutrireOggi(), isFalse,
        reason: 'il tamburo si batte due volte nello stesso giorno: quattro '
            'colpi di seguito annullano un mese di distanza in quattro '
            'secondi');
  });

  test('I NUTRIMENTI CONTANO AL MASSIMO TRE, e scendere azzera il conto',
      () async {
    var quando = DateTime(2026, 9, 1, 12);
    final diario = DiarioDeiViaggi(orologio: () => quando);
    await diario.carica();
    await diario.segna(viaggioDel(DateTime(2026, 8, 1, 12)));

    // Cinque giorni, cinque colpi.
    for (var i = 0; i < 5; i++) {
      quando = DateTime(2026, 9, 1 + i, 12);
      await diario.nutri();
    }
    // ignore: avoid_print
    print('ORDINE DE VOCE 12: cinque colpi in cinque giorni, ne contano '
        '${diario.nutrimentiCheContano}');
    expect(diario.nutrimentiCheContano,
        DiarioDeiViaggi.quantiNutrimentiContano,
        reason: 'i nutrimenti si accumulano oltre il tetto dichiarato');

    // **E SCENDERE AZZERA IL CONTO.** Senza, i battiti vecchi diventerebbero
    // credito: si tornerebbe dopo un mese e la scena sarebbe gia' nitida per
    // colpi dati settimane prima.
    await diario.segna(viaggioDel(quando));
    // ignore: avoid_print
    print('ORDINE DE VOCE 12: dopo una discesa i nutrimenti che contano sono '
        '${diario.nutrimentiCheContano}');
    expect(diario.nutrimentiCheContano, 0,
        reason: 'dopo una discesa i colpi vecchi contano ancora: sono credito '
            'accumulato');
  });

  test('CHI NON E MAI SCESO NON E LONTANO', () async {
    final diario = DiarioDeiViaggi(orologio: () => DateTime(2026, 9, 11));
    await diario.carica();
    // ignore: avoid_print
    print('ORDINE DE VOCE 12: senza nessuna discesa la distanza e '
        '${diario.giorniDiDistanza}');
    expect(diario.giorniDiDistanza, isNull,
        reason: 'chi apre la soglia la prima volta legge che il suo animale e '
            'lontano, e non ne ha ancora uno');
    expect(NitidezzaDellaScena.laRiga(NitidezzaDellaScena.dopoGiorni(0)),
        isNull);
  });

  test('IL TAMBURO NON E UNA DISCESA', () async {
    final oggi = DateTime(2026, 9, 11, 12);
    final diario = DiarioDeiViaggi(orologio: () => oggi);
    await diario.carica();
    await diario.segna(viaggioDel(oggi.subtract(const Duration(days: 20))));
    final prima = diario.quanteDiscese;
    await diario.nutri();
    // ignore: avoid_print
    print('ORDINE DE VOCE 12: discese prima del tamburo $prima, dopo '
        '${diario.quanteDiscese}');
    expect(diario.quanteDiscese, prima,
        reason: 'il tamburo conta come una discesa: il riconoscimento si '
            'otterrebbe battendo quattro volte');
    expect(diario.quanteOggi, 0,
        reason: 'il tamburo brucia la discesa del giorno');
  });
}
