import 'package:esoteric_circle/core/astro/zodiac_controller.dart';
import 'package:esoteric_circle/core/maestro/maestro_controller.dart';
import 'package:esoteric_circle/core/motion/parallax_controller.dart';
import 'package:esoteric_circle/core/quality/quality_tier.dart';
import 'package:esoteric_circle/core/rituals/daily_elements.dart';
import 'package:esoteric_circle/core/rituals/finestra_del_dono.dart';
import 'package:esoteric_circle/core/rituals/scelta_degli_avvisi.dart';
import 'package:esoteric_circle/design_system/theme/maestro_scope.dart';
import 'package:esoteric_circle/features/santuario/daily_strip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cardinale_minimo.dart';

/// **I DONI SI APRONO ALLA LORO ORA.** Ordine DD voce 05, 10 settembre 2026.
///
/// **Il fatto del fondatore**: i cinque Doni si aprono a qualunque ora. Il Rito
/// dell'Alba si puo' fare a mezzanotte e il Sigillo del Sogno alle sette del
/// mattino, quindi l'appuntamento con la giornata non esiste: **se tutto e'
/// disponibile sempre, niente ha un'ora sua**.
///
/// **La legge**: un Dono si apre all'ora della sua notifica e resta aperto fino
/// al rinnovo, cioe' alla stessa ora del giorno dopo.
///
/// **LA PROVA GIRA ORA PER ORA, come l'ordine chiede.** Ventiquattro ore per
/// cinque Doni sono centoventi risposte, e ognuna si confronta con l'ora di
/// apertura di quel Dono. Una prova su un'ora sola direbbe che la legge vale
/// per averla vista in un punto.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('ORA PER ORA: ogni Dono e chiuso prima della sua ora e aperto dopo', () {
    final avvisi = SceltaDegliAvvisi();
    var risposte = 0;
    final sbagliate = <String>[];
    for (final dono in DailyElement.values) {
      final apre = avvisi.minutiDi(dono);
      for (var ora = 0; ora < 24; ora++) {
        final adesso = DateTime(2026, 9, 10, ora, 0);
        final aperto =
            FinestraDelDono.aperto(dono, avvisi: avvisi, adesso: adesso);
        final dovrebbe = ora * 60 >= apre;
        risposte++;
        if (aperto != dovrebbe) {
          sbagliate.add('${dono.shortLabel} alle $ora:00 e '
              '${aperto ? "aperto" : "chiuso"} e dovrebbe essere '
              '${dovrebbe ? "aperto" : "chiuso"}');
        }
      }
    }
    // ignore: avoid_print
    print('ORDINE DD VOCE 05: risposte guardate $risposte, sbagliate '
        '${sbagliate.length}');
    cardinaleMinimo(risposte, 120,
        cosa: 'coppie Dono-ora guardate',
        perche: 'Con poche ore questa prova direbbe che la legge vale per '
            'averla vista in un punto del giorno.');
    expect(sbagliate, isEmpty,
        reason: 'questi Doni non rispettano la loro ora: '
            '${sbagliate.join(" | ")}');
  });

  test('LE ORE DI CASA SONO QUELLE CONCORDATE, per chi non ha scelto', () {
    // **REGOLA H, il contrario della prima**: la prima prova sarebbe verde
    // anche se tutte le ore di apertura fossero zero, perche' confronterebbe
    // la stessa risposta sbagliata con se stessa. Qui si pretende che le ore
    // di casa siano quelle che il fondatore ha concordato.
    final avvisi = SceltaDegliAvvisi();
    const attese = {
      DailyElement.dawn: 7 * 60,
      DailyElement.breath: 10 * 60 + 30,
      DailyElement.oracle: 13 * 60,
      DailyElement.rune: 18 * 60 + 30,
      DailyElement.night: 22 * 60 + 30,
    };
    cardinaleMinimo(DailyElement.values.length, 5,
        cosa: 'Doni del giorno',
        perche: 'Con meno di cinque Doni questa prova non copre la striscia.');
    for (final dono in DailyElement.values) {
      final m = avvisi.minutiDi(dono);
      // ignore: avoid_print
      print('ORDINE DD VOCE 05: ${dono.shortLabel} apre alle '
          '${(m ~/ 60).toString().padLeft(2, '0')}:'
          '${(m % 60).toString().padLeft(2, '0')}');
      expect(m, attese[dono],
          reason: 'l ora di casa di ${dono.shortLabel} e cambiata senza che '
              'nessuno lo dicesse');
      expect(m, greaterThan(0),
          reason: '${dono.shortLabel} apre a mezzanotte, cioe non ha nessuna '
              'ora sua');
    }
  });

  test('L ORA SCELTA DALLA PERSONA VINCE SU QUELLA DI CASA', () async {
    // **La seconda verita che non deve nascere.** Chi sposta l avviso dell
    // Alba alle nove non deve trovare il Dono aperto dalle sette.
    final avvisi = SceltaDegliAvvisi();
    await avvisi.scegliLOra(DailyElement.dawn, ora: 9, minuto: 0);
    final alleOtto = DateTime(2026, 9, 10, 8, 0);
    final alleNove = DateTime(2026, 9, 10, 9, 0);
    // ignore: avoid_print
    print('ORDINE DD VOCE 05: con l Alba spostata alle 9, alle 8 e '
        '${FinestraDelDono.aperto(DailyElement.dawn, avvisi: avvisi, adesso: alleOtto) ? "aperta" : "chiusa"}'
        ' e alle 9 e '
        '${FinestraDelDono.aperto(DailyElement.dawn, avvisi: avvisi, adesso: alleNove) ? "aperta" : "chiusa"}');
    expect(
        FinestraDelDono.aperto(DailyElement.dawn,
            avvisi: avvisi, adesso: alleOtto),
        isFalse,
        reason: 'l Alba spostata alle nove si apre lo stesso alle otto: l ora '
            'della notifica e quella dell apertura sono due verita diverse '
            'sullo stesso appuntamento');
    expect(
        FinestraDelDono.aperto(DailyElement.dawn,
            avvisi: avvisi, adesso: alleNove),
        isTrue,
        reason: 'l Alba spostata alle nove non si apre alle nove');
  });

  test('LA CARD CHIUSA DICE QUANDO SI APRE, con l ora', () {
    final avvisi = SceltaDegliAvvisi();
    final detti = <String>[];
    for (final dono in DailyElement.values) {
      // Un istante prima dell apertura: la card e chiusa e deve parlare.
      final apre = avvisi.minutiDi(dono);
      final prima = DateTime(2026, 9, 10, apre ~/ 60, apre % 60)
          .subtract(const Duration(minutes: 1));
      final detto =
          FinestraDelDono.quandoSiApre(dono, avvisi: avvisi, adesso: prima);
      detti.add(detto);
      // ignore: avoid_print
      print('ORDINE DD VOCE 05: ${dono.shortLabel} chiusa dice "$detto"');
      // **L ORA CI DEVE ESSERE, in cifre.** "Non ancora disponibile" e una
      // porta che sembra rotta; con l orario e un appuntamento.
      expect(RegExp(r'\d{2}:\d{2}').hasMatch(detto), isTrue,
          reason: 'la card chiusa di ${dono.shortLabel} non dice nessuna ora: '
              '"$detto"');
      final atteso = '${(apre ~/ 60).toString().padLeft(2, '0')}:'
          '${(apre % 60).toString().padLeft(2, '0')}';
      expect(detto.contains(atteso), isTrue,
          reason: 'la card chiusa di ${dono.shortLabel} annuncia un ora che '
              'non e la sua: dice "$detto" e apre alle $atteso');
    }
    cardinaleMinimo(detti.length, 5,
        cosa: 'frasi delle card chiuse',
        perche: 'Con meno di cinque frasi non si e guardata tutta la '
            'striscia.');
  });

  test('APERTO, IL RINNOVO E DOMANI ALLA STESSA ORA', () {
    // **"Resta aperto fino al rinnovo"** e la seconda meta della legge, e
    // senza questa prova un Dono che si richiude a mezzanotte passerebbe le
    // altre.
    final avvisi = SceltaDegliAvvisi();
    for (final dono in DailyElement.values) {
      final apre = avvisi.minutiDi(dono);
      // Un minuto dopo l apertura, e poi l ultimo minuto prima di mezzanotte.
      for (final quando in [
        DateTime(2026, 9, 10, apre ~/ 60, apre % 60)
            .add(const Duration(minutes: 1)),
        DateTime(2026, 9, 10, 23, 59),
      ]) {
        if (quando.hour * 60 + quando.minute < apre) continue;
        expect(FinestraDelDono.aperto(dono, avvisi: avvisi, adesso: quando),
            isTrue,
            reason: '${dono.shortLabel} si e richiuso a $quando, prima del '
                'rinnovo');
      }
      final dopoLApertura = DateTime(2026, 9, 10, apre ~/ 60, apre % 60)
          .add(const Duration(minutes: 1));
      final rinnovo = FinestraDelDono.prossimaApertura(dono,
          avvisi: avvisi, adesso: dopoLApertura);
      // ignore: avoid_print
      print('ORDINE DD VOCE 05: ${dono.shortLabel} aperto il 10, il rinnovo '
          'cade il ${rinnovo.day} alle ${rinnovo.hour}:'
          '${rinnovo.minute.toString().padLeft(2, '0')}');
      expect(rinnovo.day, 11,
          reason: 'il rinnovo di ${dono.shortLabel} non cade il giorno dopo');
      expect(rinnovo.hour * 60 + rinnovo.minute, apre,
          reason: 'il rinnovo di ${dono.shortLabel} cade a un ora diversa da '
              'quella di apertura');
    }
  });

  // ---------------------------------------------------------------- A VIDEO

  /// La striscia dentro l'impalcatura minima, **con la scelta degli avvisi in
  /// albero**: e' quella che decide l'ora, e senza di lei la striscia per
  /// legge lascia tutto aperto.
  Widget striscia(DateTime quando) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MaestroController()),
          ChangeNotifierProvider(create: (_) => ParallaxController()),
          ChangeNotifierProvider(create: (_) => QualityTierController()),
          ChangeNotifierProvider(create: (_) => ZodiacController()),
          ChangeNotifierProvider(create: (_) => SceltaDegliAvvisi()),
        ],
        child: MaterialApp(
          home: MaestroScope(
            child: Scaffold(body: DailyStrip(clock: () => quando)),
          ),
        ),
      );

  testWidgets('A VIDEO: prima dell ora la casella porta l orologio',
      (tester) async {
    // Le sei del mattino: solo il Sigillo del Sogno di ieri sarebbe passato,
    // e con la legge nuova **tutti e cinque** i Doni di oggi sono chiusi.
    await tester.pumpWidget(striscia(DateTime(2026, 9, 10, 6, 0)));
    await tester.pump();

    var conOrologio = 0;
    for (final dono in DailyElement.values) {
      final casella = find.byKey(Key('daily_element_${dono.name}'));
      expect(casella, findsOneWidget,
          reason: 'la casella di ${dono.shortLabel} non e nella striscia');
      final orologio = find.descendant(
          of: casella, matching: find.byIcon(Icons.schedule_rounded));
      if (orologio.evaluate().isNotEmpty) conOrologio++;
    }
    // ignore: avoid_print
    print('ORDINE DD VOCE 05: alle 6:00 le caselle con l orologio sono '
        '$conOrologio su ${DailyElement.values.length}');
    expect(conOrologio, DailyElement.values.length,
        reason: 'alle sei del mattino $conOrologio caselle su '
            '${DailyElement.values.length} si dichiarano chiuse: le altre '
            'promettono un Dono che non c e ancora');
  });

  testWidgets('A VIDEO: passata l ora la casella torna il suo segno',
      (tester) async {
    // **REGOLA H, la meta opposta.** Una striscia sempre chiusa passerebbe la
    // prova qui sopra e sarebbe peggio del difetto: alle undici e mezza Alba,
    // Soffio sono aperti e i loro segni tornano.
    await tester.pumpWidget(striscia(DateTime(2026, 9, 10, 11, 30)));
    await tester.pump();

    for (final dono in [DailyElement.dawn, DailyElement.breath]) {
      final casella = find.byKey(Key('daily_element_${dono.name}'));
      final orologio = find.descendant(
          of: casella, matching: find.byIcon(Icons.schedule_rounded));
      // ignore: avoid_print
      print('ORDINE DD VOCE 05: alle 11:30 ${dono.shortLabel} '
          '${orologio.evaluate().isEmpty ? "e aperto" : "e ancora chiuso"}');
      expect(orologio, findsNothing,
          reason: '${dono.shortLabel} e ancora chiuso alle 11:30, dopo la sua '
              'ora');
    }
    for (final dono in [
      DailyElement.oracle,
      DailyElement.rune,
      DailyElement.night
    ]) {
      final casella = find.byKey(Key('daily_element_${dono.name}'));
      final orologio = find.descendant(
          of: casella, matching: find.byIcon(Icons.schedule_rounded));
      expect(orologio, findsOneWidget,
          reason: '${dono.shortLabel} e gia aperto alle 11:30, prima della '
              'sua ora');
    }
  });
}
