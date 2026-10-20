import 'package:esoteric_circle/core/responsi/la_forma_del_responso.dart';
import 'package:esoteric_circle/design_system/components/il_responso_interpretato.dart';
import 'package:esoteric_circle/design_system/components/titolo_del_responso.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// **LA FORMA DEL RESPONSO.** Ordine GA, voci GA.03, GA.04 e GA.05, 20
/// ottobre 2026. Il fondatore: *"tutte le risposte composte da paragrafi
/// ognuno con tra 40 a 50 parole ognuno. Per le risposte brevi 2 paragrafi di
/// cui il secondo messo in evidenza in un riquadro e questo riquadro deve
/// intitolarsi 'cosa fare adesso' [...] Per le risposte lunghe aggiungi 2
/// paragrafi [...] Sotto sempre il paragrafo in corsivo 'da dove viene'"*.
///
/// Qui si prova la forma in se': la misura, i riquadri coi loro titoli, il
/// "Da dove viene" in corsivo, il titolo che passa da [TitoloDelResponso]. I
/// testi delle quattro arti si misurano nelle prove dei loro corpora.
String _parole(int n, String seme) =>
    List.generate(n, (i) => '$seme${i + 1}').join(' ');

ResponsoInterpretato _responso({
  int risposta = 45,
  int cosaFare = 45,
  int? approfondimento,
  int? rito,
  String? daDoveViene = 'Dalla tradizione.',
}) =>
    ResponsoInterpretato(
      arte: ArteInterpretata.rune,
      titolo: 'La strada si apre',
      risposta: _parole(risposta, 'r'),
      cosaFare: _parole(cosaFare, 'c'),
      approfondimento:
          approfondimento == null ? null : _parole(approfondimento, 'a'),
      rito: rito == null ? null : _parole(rito, 'g'),
      daDoveViene: daDoveViene,
    );

void main() {
  test('le parole si contano come le conta chi legge', () {
    expect(LaFormaDelResponso.parole('  una  due\ntre  '), 3);
    expect(LaFormaDelResponso.parole("l'anno è già qui"), 4);
    expect(LaFormaDelResponso.aMisura(_parole(39, 'x')), isFalse);
    expect(LaFormaDelResponso.aMisura(_parole(40, 'x')), isTrue);
    expect(LaFormaDelResponso.aMisura(_parole(50, 'x')), isTrue);
    expect(LaFormaDelResponso.aMisura(_parole(51, 'x')), isFalse);
  });

  test('un responso a misura non ha difetti, breve o lungo', () {
    expect(_responso().difetti(), isEmpty);
    expect(_responso(approfondimento: 44, rito: 46).difetti(), isEmpty);
    // La singola carta o runa: breve e senza il "Da dove viene".
    expect(_responso(daDoveViene: null).difetti(conLaFonte: false), isEmpty);
  });

  test('i difetti portano il nome dell\'arte e del testo', () {
    final corto = _responso(risposta: 32).difetti();
    expect(corto.single, contains('Rune di Caligo'));
    expect(corto.single, contains('«La strada si apre»'));
    expect(corto.single, contains('la risposta ha 32 parole'));
    expect(_responso(cosaFare: 51).difetti().single,
        contains('il riquadro "Cosa fare adesso" ha 51 parole'));
    expect(_responso(approfondimento: 45).difetti().single,
        contains('manca il riquadro "Il galdr propiziatorio"'));
    expect(_responso(rito: 45).difetti().single,
        contains('manca l\'approfondimento'));
    expect(_responso(daDoveViene: null).difetti().single,
        contains('manca il "Da dove viene"'));
  });

  test('il titolo del rito cambia con l\'arte, come l\'ha scelto l\'ordine',
      () {
    expect(LaFormaDelResponso.titoloDelRito(ArteInterpretata.rune),
        'Il galdr propiziatorio');
    expect(LaFormaDelResponso.titoloDelRito(ArteInterpretata.oracolo),
        'Il salmo propiziatorio');
    expect(LaFormaDelResponso.titoloDelRito(ArteInterpretata.tarocchi),
        'La contemplazione propiziatoria');
    expect(
        LaFormaDelResponso.titoloDelRito(ArteInterpretata.oroscopoOccidentale),
        'L\'inno propiziatorio');
    expect(LaFormaDelResponso.titoloDelRito(ArteInterpretata.oroscopoVedico),
        'Il mantra propiziatorio');
    expect(LaFormaDelResponso.titoloDelRito(ArteInterpretata.oroscopoCinese),
        'Il gesto propiziatorio');
  });

  Future<void> monta(WidgetTester tester, ResponsoInterpretato r) =>
      tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: IlResponsoInterpretato(
              responso: r,
              stileDelTitolo: const TextStyle(fontSize: 22),
              stile: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ));

  testWidgets(
      'il responso breve: titolo, risposta, il riquadro "Cosa fare '
      'adesso" e il "Da dove viene" in corsivo, in quest\'ordine',
      (tester) async {
    await monta(tester, _responso());
    expect(find.byType(TitoloDelResponso), findsOneWidget);
    expect(find.text('Cosa fare adesso'), findsOneWidget);
    expect(find.text('Da dove viene'), findsOneWidget);
    expect(find.byKey(const Key('responso_approfondimento')), findsNothing);
    expect(find.byKey(const Key('responso_rito')), findsNothing);
    final fonte =
        tester.widget<Text>(find.byKey(const Key('responso_da_dove_viene')));
    expect(fonte.style?.fontStyle, FontStyle.italic);
    final y = [
      'responso_titolo',
      'responso_risposta',
      'responso_titolo_cosa_fare',
      'responso_cosa_fare',
      'responso_da_dove_viene',
    ].map((k) => tester.getTopLeft(find.byKey(Key(k))).dy).toList();
    for (var i = 1; i < y.length; i++) {
      expect(y[i], greaterThan(y[i - 1]), reason: 'l\'ordine dei pezzi');
    }
  });

  testWidgets(
      'il responso lungo aggiunge l\'approfondimento e il riquadro '
      'del rito col suo titolo, prima del "Da dove viene"', (tester) async {
    await monta(tester, _responso(approfondimento: 45, rito: 45));
    expect(find.text('Il galdr propiziatorio'), findsOneWidget);
    final y = [
      'responso_cosa_fare',
      'responso_approfondimento',
      'responso_titolo_rito',
      'responso_rito',
      'responso_da_dove_viene',
    ].map((k) => tester.getTopLeft(find.byKey(Key(k))).dy).toList();
    for (var i = 1; i < y.length; i++) {
      expect(y[i], greaterThan(y[i - 1]), reason: 'l\'ordine dei pezzi');
    }
  });
}
