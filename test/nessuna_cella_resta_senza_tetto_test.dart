import 'package:esoteric_circle/core/entitlement/plan_catalog.dart';
import 'package:esoteric_circle/core/entitlement/tier.dart';
import 'package:flutter_test/flutter_test.dart';

/// NESSUNA CELLA DELLA MATRICE RESTA SENZA TETTO. Ordine CE voce 08.
///
/// **Le parole del fondatore, verbatim:** "illimitato mi espone all'abuso o uso
/// incontrollato o bot, quindi e' da eliminare e da sostituire con un numero
/// abbastanza ampio da essere piu' che sufficiente per l'utente ovvero
/// difficilmente raggiungera' il limite imposto anche con uso intensivo." E il
/// principio che aveva gia' dichiarato: "tu mi hai insegnato di non fare nulla
/// di illimitato".
///
/// **QUESTA PROVA ENUMERA OGNI CELLA**, riga per riga e piano per piano: non
/// bastava togliere la parola dalle sei righe che ce l'avevano, perche' la
/// LOGICA che traduceva "illimitat" in "nessun tetto" sarebbe rimasta aperta al
/// primo che riscrive una cella.
void main() {
  const piani = [Tier.free, Tier.tier1, Tier.tier2, Tier.tier3];

  test('nessuna cella promette qualcosa di illimitato', () {
    final colpe = <String>[];
    for (final riga in PlanCatalog.matrix) {
      for (final cella in riga.values) {
        if (cella.toLowerCase().contains('illimitat')) {
          colpe.add('${riga.label}: "$cella"');
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE CE VOCE 08: righe della matrice ${PlanCatalog.matrix.length}, '
        'celle che promettono l\'illimitato ${colpe.length}');
    expect(colpe, isEmpty,
        reason: 'queste celle promettono qualcosa senza tetto: $colpe');
  });

  test('e nessuna riga con un numero torna "nessun tetto"', () {
    // **La logica, non solo le parole.** Una cella che porta un numero deve
    // sempre produrre quel numero: se `limiteGiornaliero` tornasse nullo per
    // una di queste, il tetto non esisterebbe comunque.
    final senzaTetto = <String>[];
    for (final riga in PlanCatalog.matrix) {
      for (var i = 0; i < piani.length; i++) {
        final cella = riga.values[i];
        if (!RegExp(r'\d').hasMatch(cella)) continue;
        // Le celle che parlano di Eos dicono che quella cosa si compra, e
        // valgono zero usi gratis: e' l'ordine BN voce 09 e non e' un tetto
        // mancante.
        if (cella.toLowerCase().contains('eos')) continue;
        final limite = PlanCatalog.limiteGiornaliero(riga.label, piani[i]);
        if (limite == null) {
          senzaTetto.add('${riga.label} / ${piani[i].name}: "$cella"');
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE CE VOCE 08: celle con un numero che restano senza tetto '
        '${senzaTetto.length}');
    expect(senzaTetto, isEmpty, reason: '$senzaTetto');
  });

  test('la strada per riaprire l\'illimitato e\' chiusa', () {
    // **Se domani qualcuno riscrive "Illimitato" in una cella, quella cella
    // vale ZERO e non "senza tetto".** Nel dubbio si sbaglia dalla parte del
    // tetto, non dell'abuso: e' l'unico verso in cui l'errore non espone al
    // bot che il fondatore teme.
    expect(PlanCatalog.limiteGiornaliero('Confronti nel Cerchio', Tier.tier3),
        isNotNull,
        reason: 'la riga dei confronti e\' tornata senza tetto');
  });

  test('i tetti dell\'Illuminato sono ampi, e sono quelli decisi', () {
    // I numeri li ha scelti Code e stanno scritti nel manifesto con la loro
    // ragione: ogni tetto e' almeno tre volte quello del piano sotto, e
    // nessuno e' raggiungibile con un uso umano intensivo.
    const attesi = <String, int>{
      'Domande a un Maestro': 50,
      'Vai più a fondo': 30,
      'Confronti nel Cerchio': 20,
      'Tarocchi carta singola': 50,
      'Gettate di rune': 50,
      'Sinastria VIP': 25,
    };
    final sbagliati = <String>[];
    attesi.forEach((riga, atteso) {
      final vero = PlanCatalog.limiteGiornaliero(riga, Tier.tier3);
      if (vero != atteso) sbagliati.add('$riga: $vero invece di $atteso');
    });
    // ignore: avoid_print
    print('ORDINE CE VOCE 08: tetti dell\'Illuminato fuori posto '
        '${sbagliati.length} su ${attesi.length}');
    expect(sbagliati, isEmpty, reason: '$sbagliati');
  });
}
