// ignore_for_file: avoid_print
import 'package:esoteric_circle/core/amici/amici_offline.dart';
import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/horoscope/astro_tradition.dart';
import 'package:esoteric_circle/core/horoscope/i_segni_delle_tradizioni.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/design_system/theme/maestro_palette.dart';
import 'package:esoteric_circle/design_system/tokens/spacing_tokens.dart';
import 'package:esoteric_circle/features/horoscope/la_testa_della_tradizione.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'cardinale_minimo.dart';
import 'l_oroscopo_di_un_amico_nelle_prove.dart';

/// **IL NOME DEL SEGNO NON SI SPEZZA, E IL SEGNO DI UN AMICO E' IL SUO.**
/// Ordine ES voci 10 e 12, 30 settembre 2026.
///
/// Visto sul Realme nell'oroscopo di un'amica nata il 12 gennaio 1990: in
/// cima "CAPRICORN / O", con l'ultima lettera a capo, e sotto la figura "Il
/// tuo segno è Capricorno", quando il segno era di Lucia. Il primo viene
/// dalla voce ES.10, che ha messo il punto interrogativo accanto al nome e
/// gli ha lasciato 224 punti; il secondo dalla voce ES.12, che ha riusato la
/// testa della tradizione scritta per chi usa l'app.
void main() {
  final palette = MaestroPalette.forKey(const ThemeKey.of(Maestro.medora));

  /// Le parole del [testo] che il paragrafo dipinge su piu' di una riga.
  List<String> spezzate(RenderParagraph p, String testo) {
    final rotte = <String>[];
    var da = 0;
    for (final parola in testo.split(' ')) {
      final a = da + parola.length;
      final righe = p
          .getBoxesForSelection(TextSelection(baseOffset: da, extentOffset: a))
          .map((b) => b.top.round())
          .toSet();
      if (righe.length > 1) rotte.add(parola);
      da = a + 1;
    }
    return rotte;
  }

  testWidgets('ES.10: nessun nome di segno va a capo dentro una parola',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    // I nomi che le tre tradizioni con la lettura mettono in cima.
    final nomi = <String>{
      for (final z in Zodiac.values) z.italianName,
      for (final (nome, _) in ISegniDelleTradizioni.animali) nome,
      for (var i = 0; i < 12; i++)
        '${ISegniDelleTradizioni.rashi[i]} (${Zodiac.values[i].italianName})',
    };
    cardinaleMinimo(nomi.length, 36, cosa: 'nomi dei segni in cima');
    final rotti = <String>[];
    for (final scala in [1.0, 1.3]) {
      for (final nome in nomi) {
        await tester.pumpWidget(MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
                size: const Size(360, 800),
                textScaler: TextScaler.linear(scala)),
            child: Scaffold(
              // Il margine delle due schermate che montano la testa.
              body: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: SpacingTokens.lg),
                child: NomeConLaNota(
                    nome: nome,
                    tradizione: AstroTradition.occidentale,
                    palette: palette,
                    chiave: const Key('nome')),
              ),
            ),
          ),
        ));
        final p =
            tester.renderObject<RenderParagraph>(find.byKey(const Key('nome')));
        final parole = spezzate(p, nome);
        if (parole.isNotEmpty) rotti.add('$nome a scala $scala: $parole');
        // E sta dentro lo schermo.
        final r = tester.getRect(find.byKey(const Key('nome')));
        if (r.left < 0 || r.right > 360) rotti.add('$nome: fuori schermo');
      }
    }
    print('ORDINE ES VOCE 10, IL NOME DEL SEGNO: nomi con una parola spezzata '
        '${rotti.length} su ${nomi.length * 2}'
        '${rotti.isEmpty ? '' : ': ${rotti.join('; ')}'}');
    expect(rotti, isEmpty);
  });

  test('ES.12: il segno di un amico si dice di lui, per un anno di nascite',
      () {
    var frasi = 0;
    final colTuo = <String>[];
    final senzaNome = <String>[];
    for (var giorno = 0; giorno < 366; giorno++) {
      final nascita = DateTime(1990, 1, 1 + giorno);
      for (final oraNota in [true, false]) {
        final amico = Amico(
            id: 'a',
            nome: 'Lucia',
            nascita: nascita,
            ora: oraNota ? '08:10' : null);
        final n = NascitaDeiSegni(
            locale: amico.momento, oraNota: amico.oraNota, fuso: amico.fuso);
        for (final t in const [
          AstroTradition.occidentale,
          AstroTradition.cinese,
          AstroTradition.vedica,
        ]) {
          final segno = ISegniDelleTradizioni.per(t, n).dettoDi('Lucia');
          for (final testo in [
            segno.frase,
            if (segno.nota != null) segno.nota!
          ]) {
            frasi++;
            if (RegExp(r'\b(tuo|tua|tuoi|tue)\b', caseSensitive: false)
                .hasMatch(testo)) {
              colTuo.add('${t.name} $nascita: $testo');
            }
          }
          if (!segno.frase.contains('Lucia')) {
            senzaNome.add('${t.name} $nascita: ${segno.frase}');
          }
        }
      }
    }
    cardinaleMinimo(frasi, 2196, cosa: 'frasi del segno dell\'amico');
    print('ORDINE ES VOCE 12, IL SEGNO DELL\'AMICO: frasi e note che dicono '
        '"tuo" ${colTuo.length} su $frasi; frasi senza il nome '
        '${senzaNome.length}');
    expect(colTuo, isEmpty, reason: colTuo.take(3).join('\n'));
    expect(senzaNome, isEmpty, reason: senzaNome.take(3).join('\n'));
  });

  test('ES.12: la frase di chi usa l\'app resta com\'era', () {
    final mio = ISegniDelleTradizioni.per(AstroTradition.occidentale,
        NascitaDeiSegni(locale: DateTime(1990, 1, 12, 12), oraNota: false));
    expect(mio.frase, 'Il tuo segno è Capricorno');
    expect(mio.dettoDi('Lucia').frase, 'Il segno di Lucia è Capricorno');
  });

  testWidgets(
      'ES.12: la schermata dell\'amico dice il segno di Lucia, nelle tre '
      'tradizioni', (tester) async {
    tester.view.physicalSize = const Size(360, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    // LAPIDE, ordine FC voce 02: qui si montava la schermata dell'amico;
    // adesso e' l'Oroscopo col soggetto impostato su Lucia.
    await tester.pumpWidget(lOroscopoDiUnAmico(
        Amico(id: 'l', nome: 'Lucia', nascita: DateTime(1990, 1, 12)),
        adesso: DateTime(2026, 9, 30, 12)));
    await tester.pump(const Duration(milliseconds: 300));
    final viste = <String>[];
    for (final (t, attesa) in const [
      ('occidentale', 'Il segno di Lucia è Capricorno'),
      ('cinese', 'Il segno cinese di Lucia è il Serpente'),
      ('vedica', 'Il segno vedico di Lucia è Karka (Cancro)'),
    ]) {
      final chip = find.byKey(Key('oroscopo_tradition_$t'));
      await tester.ensureVisible(chip);
      await tester.tap(chip);
      await tester.pump(const Duration(milliseconds: 300));
      final frasi = find.byKey(Key('oroscopo_frase_$t'));
      if (frasi.evaluate().isEmpty) {
        await tester.scrollUntilVisible(frasi, -300,
            scrollable: find.byType(Scrollable).first);
      }
      final frase =
          tester.widget<Text>(find.byKey(Key('oroscopo_frase_$t'))).data!;
      viste.add(frase);
      expect(frase, attesa);
      expect(find.textContaining('Il tuo segno'), findsNothing);
    }
    print('ORDINE ES VOCE 12, LA SCHERMATA DELL\'AMICO: ${viste.join('; ')}');
  });
}
