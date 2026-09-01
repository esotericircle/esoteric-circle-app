import 'package:esoteric_circle/design_system/components/scroll_reveal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// La comparsa si deve VEDERE, non solo esistere.
///
/// ScrollReveal era stata dichiarata chiusa per due ordini di seguito, e a
/// schermo non si notava. Il codice era corretto: opacita' da zero a uno e un
/// piccolo scostamento verso l'alto. Il difetto stava nel MOMENTO.
///
/// La comparsa dura 260 millisecondi e partiva al primo frame utile. Ma una
/// schermata si apre con la transizione della sua rotta, che dura circa 300
/// millisecondi: la comparsa finiva mentre la schermata stava ancora entrando,
/// quindi quando la si vedeva era gia' conclusa. Un'animazione che si esaurisce
/// dietro le quinte non e' un'animazione.
///
/// La correzione aspetta che la rotta sia entrata, poi rivela.
void main() {
  /// L'opacita' applicata dalla comparsa, letta dall'albero.
  double opacitaDi(WidgetTester tester, Key chiave) {
    final op = find
        .ancestor(of: find.byKey(chiave), matching: find.byType(Opacity))
        .first;
    return tester.widget<Opacity>(op).opacity;
  }

  Future<void> apriUnaRotta(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (ctx) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => Navigator.of(ctx).push(MaterialPageRoute<void>(
                builder: (_) => const Scaffold(
                  body: SingleChildScrollView(
                    child: ScrollReveal(
                      child: SizedBox(
                          key: Key('cosa_che_compare'),
                          height: 100,
                          width: 100),
                    ),
                  ),
                ),
              )),
              child: const Text('apri'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('apri'));
  }

  testWidgets('Mentre la rotta entra, la comparsa non e\' ancora finita',
      (tester) async {
    await apriUnaRotta(tester);
    // A meta' della transizione della rotta: la schermata sta entrando, quindi
    // la comparsa non puo' essere gia' esaurita.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    expect(opacitaDi(tester, const Key('cosa_che_compare')), lessThan(0.99),
        reason: 'la comparsa e\' gia\' finita mentre la rotta sta ancora '
            'entrando: nessuno la vedra\' mai');
  });

  testWidgets('A rotta entrata la comparsa e\' ancora in corso',
      (tester) async {
    await apriUnaRotta(tester);
    await tester.pump();
    // Fine della transizione della rotta, piu' un filo.
    await tester.pump(const Duration(milliseconds: 340));

    final o = opacitaDi(tester, const Key('cosa_che_compare'));
    expect(o, lessThan(0.99),
        reason:
            'appena la schermata e\' visibile la comparsa e\' gia\' finita: '
            'e\' questo il motivo per cui non si vedeva niente');
  });

  testWidgets('Poco dopo si e\' completata, senza restare a meta\'',
      (tester) async {
    await apriUnaRotta(tester);
    await tester.pumpAndSettle();

    expect(opacitaDi(tester, const Key('cosa_che_compare')), 1.0,
        reason: 'la comparsa e\' rimasta a meta\': l\'elemento resta velato');
  });

  testWidgets('La comparsa dura abbastanza da vedersi', (tester) async {
    // La causa vera del "non si vede" era la DURATA: 260 millisecondi stanno
    // sotto la soglia di cio' che l'occhio registra, e la transizione della
    // rotta ne dura circa 300, quindi la comparsa si consumava mentre la
    // schermata stava ancora entrando.
    expect(ScrollReveal.duration.inMilliseconds, greaterThanOrEqualTo(350),
        reason: 'la comparsa dura troppo poco per sopravvivere all ingresso '
            'della schermata');

    // L'ampiezza invece NON si puo' alzare, e non e' una rinuncia per pigrizia:
    // provata a 18 piu 6, tre prove del dominio sono diventate rosse perche'
    // gli elementi vicini si sovrappongono durante la comparsa e il tocco
    // finisce sulla voce sbagliata. Questo controllo fissa il limite trovato,
    // cosi' nessuno lo alza senza prima sospendere il tocco.
    expect(ScrollReveal.slideFor(0), lessThanOrEqualTo(12),
        reason: 'lo scostamento e stato alzato: verifica che gli elementi '
            'vicini non si sovrappongano durante la comparsa, altrimenti un '
            'tocco in quel momento colpisce la voce sbagliata');
  });
}
