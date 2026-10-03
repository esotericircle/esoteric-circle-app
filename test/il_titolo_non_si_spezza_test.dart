import 'package:esoteric_circle/core/sigilli/sentieri.dart';
import 'package:esoteric_circle/design_system/components/titolo_che_non_si_spezza.dart';
import 'package:esoteric_circle/design_system/tokens/typography_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// UN TITOLO NON SI SPEZZA IN MEZZO A UNA PAROLA. Ordine AS voce 05.
///
/// **Il difetto, e nessuna prova poteva vederlo.** Nella celebrazione il nome
/// "La Costellazione nascente" a corpo 34 usciva `LA COSTELLAZI` a capo
/// `ONE NASCENTE`. Il testo c'era tutto e il widget stava nell'albero: ogni
/// prova di presenza era verde. Si e' visto guardando l'anteprima.
///
/// **Come si misura adesso.** Col `TextPainter`, che e' lo stesso motore che
/// disegna: si chiede quante righe vengono e se una riga finisce dentro una
/// parola. E si passano i nomi VERI del corpus, tutti e centosessantacinque,
/// non un esempio scelto bene.
void main() {
  /// La larghezza vera del contenuto della celebrazione: schermo di Mauro, 360
  /// punti, meno i margini della colonna.
  const larghezza = 360.0 - 24.0 * 2;

  /// Vero se il testo, a questo stile e a questa larghezza, viene tagliato
  /// dentro una parola.
  bool siSpezza(String testo, TextStyle stile) {
    final pittore = TextPainter(
      text: TextSpan(text: testo, style: stile),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: larghezza);
    // Le righe rese, come le vede l'occhio.
    final righe = pittore.computeLineMetrics();
    if (righe.length < 2) return false;
    // Si ricostruisce dove finisce ogni riga e si guarda il carattere li'
    // attorno: se prima e dopo il taglio ci sono due lettere, la parola e'
    // stata tagliata.
    for (var i = 0; i < righe.length - 1; i++) {
      final fine =
          pittore.getPositionForOffset(Offset(larghezza, righe[i].baseline));
      final dove = fine.offset;
      if (dove <= 0 || dove >= testo.length) continue;
      final prima = testo[dove - 1];
      final dopo = testo[dove];
      final lettera = RegExp(r'[A-Za-zÀ-ÿ]');
      if (lettera.hasMatch(prima) && lettera.hasMatch(dopo)) return true;
    }
    return false;
  }

  test('i nomi del corpus si spezzano davvero, a corpo pieno', () {
    // **PRIMA SI DIMOSTRA CHE IL DIFETTO ESISTE**, se no la prova sotto
    // sarebbe verde per il motivo sbagliato: potrebbe darsi che nessun nome
    // sia abbastanza lungo, e allora non si starebbe misurando niente.
    final stile = TypographyTokens.cerimonialeGrande();
    final spezzati = [
      for (final t in Sentieri.tuttiITraguardi)
        if (siSpezza(t.nome.toUpperCase(), stile)) t.nome,
    ];
    // ignore: avoid_print
    print('ORDINE AS VOCE 05: nomi che a corpo 34 si spezzano dentro una '
        'parola ${spezzati.length} su ${Sentieri.tuttiITraguardi.length} '
        '(${spezzati.take(3).join(", ")})');
    expect(spezzati, isNotEmpty,
        reason: 'nessun nome del corpus si spezza a corpo pieno: questa prova '
            'girerebbe a vuoto, e la guardia sotto non proverebbe niente');
  });

  testWidgets('il titolo adattivo non spezza nessun nome del corpus',
      (tester) async {
    var osservati = 0;
    final colpe = <String>[];
    for (final traguardo in Sentieri.tuttiITraguardi) {
      osservati++;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: larghezza,
                child: TitoloCheNonSiSpezza(
                  traguardo.nome.toUpperCase(),
                  stile: TypographyTokens.cerimonialeGrande(),
                ),
              ),
            ),
          ),
        ),
      );
      final testo = tester.widget<Text>(find.byType(Text));
      final stile = testo.style!;
      if (siSpezza(traguardo.nome.toUpperCase(), stile)) {
        colpe.add('${traguardo.id} "${traguardo.nome}" a corpo '
            '${stile.fontSize}');
      }
    }
    // ignore: avoid_print
    print('ORDINE AS VOCE 05: titoli osservati $osservati, ancora spezzati '
        '${colpe.length}');
    expect(osservati, 165);
    expect(colpe, isEmpty,
        reason: 'questi nomi si spezzano ancora dentro una parola: '
            '${colpe.take(5).join("; ")}');
  });
}
