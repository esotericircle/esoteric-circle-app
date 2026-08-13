import 'dart:math';

import 'package:esoteric_circle/core/astro/zodiac.dart';
import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/entitlement/entitlement_service.dart';
import 'package:esoteric_circle/core/entitlement/question_allowance.dart';
import 'package:esoteric_circle/core/maestro/maestro.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/maestri/caligo/rune/rune_draw_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:esoteric_circle/core/rituals/rune_cast.dart';
import 'package:esoteric_circle/core/rituals/rune_voce.dart';
import 'package:flutter_test/flutter_test.dart';

/// LA SCHEDA DELLA RUNA NON DICE DUE VOLTE LA STESSA COSA. Ordine S voce 24.
///
/// **Il difetto, e l'ha trovato l'anteprima.** La scheda di una runa mostra la sua
/// riga breve in una bolla, e subito sotto la "voce", cioe' la runa dentro il giorno.
/// La voce apriva con "Nel tuo giorno, questa pietra dice:" e poi RICOPIAVA la stessa
/// riga, parola per parola, due centimetri sotto l'originale. Chi legge la seconda
/// volta pensa di aver perso il segno.
///
/// **La grandezza misurata e' la frase, non la parola.** Due frasi identiche nella
/// stessa scheda sono un difetto; due parole ripetute sono l'italiano.
void main() {
  /// Le frasi di un testo, spezzate sui punti e ripulite. Sotto i venti caratteri
  /// non si contano: "Mistero." o "Sì." possono ripetersi senza che nessuno se ne
  /// accorga, e pretendere il contrario renderebbe la prova un fastidio invece di
  /// una guardia.
  List<String> frasi(String testo) => testo
      .split(RegExp(r'[.!?]'))
      .map((f) => f.trim().toLowerCase())
      .where((f) => f.length >= 20)
      .toList();

  test('la voce non ripete la riga della runa', () {
    // ENUMERA le quattro gettate per quaranta semi: la voce cambia con la persona,
    // col giorno, con la domanda e con la runa, quindi una scheda sola non dice
    // niente delle altre.
    final ripetizioni = <String>[];
    for (final g in gettate) {
      for (var seme = 0; seme < 40; seme++) {
        final esito = RuneCast.getta(g, random: Random(seme));
        for (final r in esito.rune) {
          final voce = RuneVoce.voce(
            runa: r,
            persona: 'prova',
            giorno: DateTime(2026, 8, 13),
            domanda: 'Nel lavoro, quale passo fare?',
          );
          // La riga della runa sta nella bolla sopra: se ricompare nella voce, la
          // scheda la dice due volte.
          final riga = r.riga.trim().toLowerCase();
          if (riga.length >= 20 && voce.toLowerCase().contains(riga)) {
            ripetizioni.add('${g.id} seme $seme, ${r.rune.name}: la voce '
                'ricopia la riga');
          }
        }
      }
    }
    expect(ripetizioni, isEmpty,
        reason: 'la voce ripete la riga che la scheda mostra gia\' sopra:\n'
            '${ripetizioni.take(6).join("\n")}');
  });

  test('dentro la voce nessuna frase compare due volte', () {
    // Il presidio piu' largo: non solo la riga della runa, ma qualunque frase.
    final doppie = <String>[];
    for (final g in gettate) {
      for (var seme = 0; seme < 40; seme++) {
        final esito = RuneCast.getta(g, random: Random(seme));
        for (final r in esito.rune) {
          final voce = RuneVoce.voce(
            runa: r,
            persona: 'prova',
            giorno: DateTime(2026, 8, 13),
            domanda: '',
          );
          final viste = <String>{};
          for (final f in frasi(voce)) {
            if (!viste.add(f)) {
              doppie.add('${g.id} seme $seme, ${r.rune.name}: "$f"');
            }
          }
        }
      }
    }
    expect(doppie, isEmpty, reason: doppie.take(6).join('\n'));
  });

  test('la voce dice ancora cio\' che aggiunge: materia, cielo e chiusa', () {
    // **IL PRESIDIO OPPOSTO, e serve.** Togliere la ripetizione non vuol dire
    // svuotare la voce: se un giorno restasse solo la chiusa, questa prova cade.
    // La voce esiste per portare tre cose che la riga non ha: la materia antica del
    // corpus, il cielo vero di oggi e un invito a portarla con se'.
    final povere = <String>[];
    for (final g in gettate) {
      for (var seme = 0; seme < 20; seme++) {
        final esito = RuneCast.getta(g, random: Random(seme));
        for (final r in esito.rune) {
          final voce = RuneVoce.voce(
            runa: r,
            persona: 'prova',
            giorno: DateTime(2026, 8, 13),
            domanda: '',
          );
          // Il cielo di oggi c'e' sempre: nomina il segno del Sole e la Luna.
          if (!voce.contains('Sole')) {
            povere.add('${r.rune.name}: la voce non porta il cielo di oggi');
          }
          if (voce.trim().length < 80) {
            povere.add('${r.rune.name}: la voce e\' rimasta un moncone di '
                '${voce.trim().length} caratteri');
          }
        }
      }
    }
    expect(povere, isEmpty, reason: povere.take(6).join('\n'));
  });

  test('la domanda entra nella voce come eco, una volta sola', () {
    final esito = RuneCast.getta(gettataNorne, random: Random(5));
    final con = RuneVoce.voce(
      runa: esito.rune.first,
      persona: 'prova',
      giorno: DateTime(2026, 8, 13),
      domanda: 'Nel lavoro, quale passo fare?',
    );
    final senza = RuneVoce.voce(
      runa: esito.rune.first,
      persona: 'prova',
      giorno: DateTime(2026, 8, 13),
      domanda: '',
    );
    expect(con, isNot(senza),
        reason: 'la domanda non cambia niente nella voce della runa');
    expect('è qui che guarda'.allMatches(con).length, 1,
        reason: 'l\'eco della domanda compare piu\' di una volta');
  });

  testWidgets('a schermo la glossa della posizione compare una volta per scheda',
      (tester) async {
    // **LA SECONDA META' DEL DIFETTO, e anche questa l'ha trovata l'anteprima.** La
    // scheda apriva con la giuntura in corsivo, "Dal fondo del pozzo, cio' che fu:",
    // e tre centimetri sotto il sottotitolo diceva "Urdhr - cio' che fu". La stessa
    // glossa due volte nello stesso riquadro.
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/sensors/method'),
      (call) async => null,
    );
    for (final name in const [
      'dev.fluttercommunity.plus/sensors/accelerometer',
      'dev.fluttercommunity.plus/sensors/user_accel',
      'dev.fluttercommunity.plus/sensors/gyroscope',
      'dev.fluttercommunity.plus/sensors/magnetometer',
    ]) {
      messenger.setMockStreamHandler(
        EventChannel(name),
        MockStreamHandler.inline(onListen: (args, events) {}),
      );
    }
    tester.view.physicalSize = const Size(430, 3600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) =>
                MaestroController(initial: const ThemeKey.of(Maestro.caligo))),
        ChangeNotifierProvider(create: (_) => QualityTierController()),
        ChangeNotifierProvider(create: (_) => ParallaxController()),
        ChangeNotifierProvider(create: (_) => EntitlementService()),
        ChangeNotifierProvider(create: (_) => QuestionAllowance()),
        ChangeNotifierProvider(create: (_) => ZodiacController()),
      ],
      child: MaterialApp(
        builder: (ctx, child) => MediaQuery(
          data: MediaQuery.of(ctx).copyWith(disableAnimations: true),
          child: MaestroScope(child: child!),
        ),
        home: RuneDrawScreen(userSign: Zodiac.aries, random: Random(3)),
      ),
    ));
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    // Le tre Norne: e' la gettata che ha le giunture, cioe' quella del difetto.
    await tester.tap(find.byKey(const Key('rune_segment_norne')));
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }
    final cast = find.byKey(const Key('rune_cast_button'));
    await tester.ensureVisible(cast);
    await tester.pump();
    await tester.tap(cast);
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 150));
    }

    final esito = RuneCast.getta(gettataNorne, random: Random(3));
    for (var i = 0; i < esito.rune.length; i++) {
      final scheda = find.byKey(Key('rune_card_$i'));
      expect(scheda, findsOneWidget);
      final testi = tester
          .widgetList<Text>(find.descendant(of: scheda, matching: find.byType(Text)))
          .map((t) => t.data ?? '')
          .toList();
      final glossa = esito.rune[i].posizione.glossa;
      final quante = testi.where((t) => t.contains(glossa)).length;
      expect(quante, lessThanOrEqualTo(1),
          reason: 'nella scheda $i la glossa "$glossa" compare $quante volte: '
              '${testi.where((t) => t.contains(glossa)).join(" || ")}');
    }
  });
}
